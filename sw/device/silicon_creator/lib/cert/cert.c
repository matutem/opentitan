// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/cert/cert.h"

#include "sw/device/lib/base/hardened.h"
#include "sw/device/silicon_creator/lib/base/util.h"
#include "sw/device/silicon_creator/lib/cert/asn1.h"
#include "sw/device/silicon_creator/lib/drivers/flash_ctrl.h"
#include "sw/device/silicon_creator/lib/drivers/hmac.h"
#include "sw/device/silicon_creator/lib/drivers/keymgr.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/otbn_boot_services.h"
#include "sw/device/silicon_creator/lib/sigverify/ecdsa_p256_key.h"

#include "flash_ctrl_regs.h"  // Generated.

static uint8_t actual_serial_number[kCertX509Asn1SerialNumberSizeInBytes] = {0};

/**
 * Helper function to convert an attestation public key from little to big
 * endian in place.
 */
static void curr_pubkey_le_to_be_convert(ecdsa_p256_public_key_t *pubkey) {
  util_reverse_bytes(pubkey->x, kEcdsaP256PublicKeyCoordBytes);
  util_reverse_bytes(pubkey->y, kEcdsaP256PublicKeyCoordBytes);
}

rom_error_t cert_ecc_p256_keygen(sc_keymgr_ecc_key_t key,
                                 hmac_digest_t *pubkey_id,
                                 ecdsa_p256_public_key_t *pubkey) {
  HARDENED_RETURN_IF_ERROR(sc_keymgr_state_check(key.required_keymgr_state));

  // Generate / sideload key material into OTBN, and generate the ECC keypair.
  HARDENED_RETURN_IF_ERROR(otbn_boot_attestation_keygen(
      key.keygen_seed_idx, key.type, *key.keymgr_diversifier, pubkey));

  // Keys are represented in certificates in big endian format, but the key is
  // output from OTBN in little endian format, so we convert the key to
  // big endian format.
  curr_pubkey_le_to_be_convert(pubkey);

  // Generate the key ID.
  //
  // Note: the certificate generation functions expect the digest to be in big
  // endian form, but the HMAC driver returns the digest in little endian, so we
  // re-format it.
  hmac_sha256(pubkey, sizeof(*pubkey), pubkey_id);
  util_reverse_bytes(pubkey_id, sizeof(*pubkey_id));

  return kErrorOk;
}

uint32_t cert_x509_asn1_decode_size_header(const uint8_t *header) {
  if (header[0] != 0x30 || header[1] != 0x82) {
    return 0;
  }
  return (((uint32_t)header[2]) << 8) + header[3] + 4 /* size of the header */;
}

rom_error_t cert_x509_asn1_get_size_in_bytes(
    const flash_ctrl_info_page_t *info_page, uint32_t offset, uint32_t *size) {
  uint8_t asn1_header[sizeof(uint32_t)];
  RETURN_IF_ERROR(
      flash_ctrl_info_read(info_page, offset, /*word_count=*/1, &asn1_header));
  *size = cert_x509_asn1_decode_size_header(asn1_header);
  if (*size == 0) {
    return kErrorCertInvalidSize;
  }
  return kErrorOk;
}

rom_error_t cert_x509_asn1_check_serial_number(const uint8_t *cert_page_buffer,
                                               size_t offset,
                                               uint8_t *expected_sn_bytes,
                                               hardened_bool_t *matches,
                                               uint32_t *out_cert_size) {
  if (cert_page_buffer == NULL || expected_sn_bytes == NULL ||
      matches == NULL || offset >= FLASH_CTRL_PARAM_BYTES_PER_PAGE) {
    return kErrorCertInvalidArgument;
  }
  *matches = kHardenedBoolFalse;

  // Check if the cert is missing by checking if the ASN.1 header cannot be
  // decoded or the size is not large enough to include a serial number.
  uint32_t cert_size =
      cert_x509_asn1_decode_size_header(&cert_page_buffer[offset]);
  if (out_cert_size != NULL) {
    *out_cert_size = cert_size;
  }
  if (launder32(cert_size) < kCertX509Asn1FirstBytesWithSerialNumber) {
    HARDENED_CHECK_LT(cert_size, kCertX509Asn1FirstBytesWithSerialNumber);
    return kErrorOk;
  }

  // Extract tag and length of serial number field.
  uint8_t asn1_tag =
      cert_page_buffer[offset + kCertX509Asn1SerialNumberTagByteOffset];
  size_t asn1_integer_length = (size_t)
      cert_page_buffer[offset + kCertX509Asn1SerialNumberLengthByteOffset];

  // Validate tag and length values.
  // Tag should be 0x2 (the ASN.1 tag for an INTEGER).
  HARDENED_CHECK_EQ(asn1_tag, kAsn1TagNumberInteger);
  // Length should be less than or equal to 21 bytes (if the MSb of the
  // measurement is 1, a zero is added during ASN.1 encoding since the value is
  // unsigned), as specified in IETF RFC 5280, and hardcoded in the certificate
  // HJSON specifications.
  HARDENED_CHECK_LE(asn1_integer_length,
                    kCertX509Asn1SerialNumberSizeInBytes + 1);

  // If the length is 21 bytes, we skip the first 0 pad byte.
  size_t sn_bytes_offset =
      offset + kCertX509Asn1SerialNumberLengthByteOffset + 1;
  if (launder32(asn1_integer_length) ==
      kCertX509Asn1SerialNumberSizeInBytes + 1) {
    HARDENED_CHECK_EQ(asn1_integer_length,
                      kCertX509Asn1SerialNumberSizeInBytes + 1);
    sn_bytes_offset++;
    asn1_integer_length--;
  }

  // Extract serial number bytes from the certificate into a 20-byte array as
  // this is the full size of the serial number integer.
  //
  // We fill the end of the array to ensure we maintain any prefix zero padding.
  //
  // We make sure to clear out the staging buffer before copying the actual cert
  // bytes in case this function was previously called on a cert that had a
  // larger serial number than currently present.
  memset(actual_serial_number, 0, kCertX509Asn1SerialNumberSizeInBytes);
  memcpy(&actual_serial_number[kCertX509Asn1SerialNumberSizeInBytes -
                               asn1_integer_length],
         &cert_page_buffer[sn_bytes_offset], asn1_integer_length);

  // Check the serial number in the certificate matches what was expected.
  *matches = kHardenedBoolFalse;
  for (size_t i = 0; i < kCertX509Asn1SerialNumberSizeInBytes; ++i) {
    if (launder32(actual_serial_number[i]) != expected_sn_bytes[i]) {
      HARDENED_CHECK_NE(actual_serial_number[i], expected_sn_bytes[i]);
      return kErrorOk;
    }
  }

  *matches = kHardenedBoolTrue;

  return kErrorOk;
}
