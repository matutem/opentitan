// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This package has functions that perform mem_bkdr_util accesses to different partitions in OTP.
// These functions end up performing reads and writes to the underlying simulated otp memory, so
// the functions must get a handle to the mem_bkdr_util instance for otp_ctrl as an argument.
//
// NB: this package is only suitable for top-level environments since it depends on SKU-dependent
// OTP ctrl fields.

package otp_ctrl_mem_bkdr_util_pkg;

  import otp_ctrl_part_pkg::*;
  import otp_ctrl_reg_pkg::*;
  import otp_scrambler_pkg::*;

  function automatic void otp_write_lc_partition_state(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      lc_ctrl_state_pkg::lc_state_e lc_state
  );
    for (int i = 0; i < LcStateSize; i += 4) begin
      mem_bkdr_util_h.write32(i + LcStateOffset, lc_state[i*8+:32]);
    end
  endfunction : otp_write_lc_partition_state

  function automatic lc_ctrl_state_pkg::lc_state_e otp_read_lc_partition_state(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h
  );
    lc_ctrl_state_pkg::lc_state_e lc_state;
    for (int i = 0; i < LcStateSize; i += 4) begin
      lc_state[i*8 +: 32] = mem_bkdr_util_h.read32(i + LcStateOffset);
    end

    return lc_state;
  endfunction : otp_read_lc_partition_state

  function automatic void otp_write_lc_partition_cnt(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      lc_ctrl_state_pkg::lc_cnt_e lc_cnt
  );
    for (int i = 0; i < LcTransitionCntSize; i += 4) begin
      mem_bkdr_util_h.write32(i + LcTransitionCntOffset, lc_cnt[i*8+:32]);
    end
  endfunction : otp_write_lc_partition_cnt

  function automatic void otp_write_lc_partition(mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
                                                 lc_ctrl_state_pkg::lc_cnt_e lc_cnt,
                                                 lc_ctrl_state_pkg::lc_state_e lc_state);

    otp_write_lc_partition_cnt(mem_bkdr_util_h, lc_cnt);
    otp_write_lc_partition_state(mem_bkdr_util_h, lc_state);
  endfunction : otp_write_lc_partition

  // The following steps are needed to backdoor write a secret partition:
  // 1). Scramble the RAW input data.
  // 2). Backdoor write the scrambled input data to OTP memory.
  // 3). Calculate the correct digest for the secret partition.
  // 4). Backdoor write digest data to OTP memory.
  function automatic void otp_write_secret0_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      bit [TestUnlockTokenSize*8-1:0] unlock_token,
      bit [TestExitTokenSize*8-1:0]   exit_token
  );
    bit [Secret0DigestSize*8-1:0] digest;

    bit [TestUnlockTokenSize*8-1:0] scrambled_unlock_token;
    bit [TestExitTokenSize*8-1:0] scrambled_exit_token;
    bit [bus_params_pkg::BUS_DW-1:0] secret_data[$];

    for (int i = 0; i < TestUnlockTokenSize; i += 8) begin
      scrambled_unlock_token[i*8+:64] = scramble_data(unlock_token[i*8+:64], Secret0Idx);
      mem_bkdr_util_h.write64(i + TestUnlockTokenOffset, scrambled_unlock_token[i*8+:64]);
    end
    for (int i = 0; i < TestExitTokenSize; i += 8) begin
      scrambled_exit_token[i*8+:64] = scramble_data(exit_token[i*8+:64], Secret0Idx);
      mem_bkdr_util_h.write64(i + TestExitTokenOffset, scrambled_exit_token[i*8+:64]);
    end

    secret_data = {<<32{scrambled_exit_token, scrambled_unlock_token}};
    digest = cal_digest(Secret0Idx, secret_data);

    mem_bkdr_util_h.write64(Secret0DigestOffset, digest);
  endfunction

  function automatic void otp_write_secret1_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      bit [SramDataKeySeedSize*8-1:0]  sram_data_key_seed
  );
    bit [Secret1DigestSize*8-1:0] digest;

    bit [SramDataKeySeedSize*8-1:0] scrambled_sram_data_key;
    bit [bus_params_pkg::BUS_DW-1:0] secret_data[$];

    for (int i = 0; i < SramDataKeySeedSize; i += 8) begin
      scrambled_sram_data_key[i*8+:64] = scramble_data(sram_data_key_seed[i*8+:64], Secret1Idx);
      mem_bkdr_util_h.write64(i + SramDataKeySeedOffset, scrambled_sram_data_key[i*8+:64]);
    end

    secret_data = {<<32 {scrambled_sram_data_key}};
    digest = cal_digest(Secret1Idx, secret_data);

    mem_bkdr_util_h.write64(Secret1DigestOffset, digest);
  endfunction

  function automatic void otp_write_secret2_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      bit [RmaTokenSize*8-1:0] rma_unlock_token,
      bit [CreatorRootKeyShare0Size*8-1:0] creator_root_key0,
      bit [CreatorRootKeyShare1Size*8-1:0] creator_root_key1
  );

    bit [Secret2DigestSize*8-1:0] digest;

    bit [RmaTokenSize*8-1:0] scrambled_unlock_token;
    bit [CreatorRootKeyShare0Size*8-1:0] scrambled_root_key0;
    bit [CreatorRootKeyShare1Size*8-1:0] scrambled_root_key1;
    bit [bus_params_pkg::BUS_DW-1:0] secret_data[$];

    for (int i = 0; i < RmaTokenSize; i+=8) begin
      scrambled_unlock_token[i*8+:64] = scramble_data(rma_unlock_token[i*8+:64], Secret2Idx);
      mem_bkdr_util_h.write64(i + RmaTokenOffset, scrambled_unlock_token[i*8+:64]);
    end
    for (int i = 0; i < CreatorRootKeyShare0Size; i+=8) begin
      scrambled_root_key0[i*8+:64] = scramble_data(creator_root_key0[i*8+:64], Secret2Idx);
      mem_bkdr_util_h.write64(i + CreatorRootKeyShare0Offset, scrambled_root_key0[i*8+:64]);
    end
    for (int i = 0; i < CreatorRootKeyShare1Size; i+=8) begin
      scrambled_root_key1[i*8+:64] = scramble_data(creator_root_key1[i*8+:64], Secret2Idx);
      mem_bkdr_util_h.write64(i + CreatorRootKeyShare1Offset, scrambled_root_key1[i*8+:64]);
    end

    secret_data = {<<32 {scrambled_root_key1, scrambled_root_key0, scrambled_unlock_token}};
    digest = cal_digest(Secret2Idx, secret_data);

    mem_bkdr_util_h.write64(Secret2DigestOffset, digest);
  endfunction

  function automatic void otp_write_hw_cfg0_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      bit [DeviceIdSize*8-1:0] device_id, bit [ManufStateSize*8-1:0] manuf_state
  );
    bit [HwCfg0DigestSize*8-1:0] digest;

    bit [bus_params_pkg::BUS_DW-1:0] hw_cfg0_data[$];

    for (int i = 0; i < DeviceIdSize; i += 4) begin
      mem_bkdr_util_h.write32(i + DeviceIdOffset, device_id[i*8+:32]);
    end
    for (int i = 0; i < ManufStateSize; i += 4) begin
      mem_bkdr_util_h.write32(i + ManufStateOffset, manuf_state[i*8+:32]);
    end

    hw_cfg0_data = {<<32 {manuf_state, device_id}};
    digest = cal_digest(HwCfg0Idx, hw_cfg0_data);

    mem_bkdr_util_h.write64(HwCfg0DigestOffset, digest);
  endfunction

  function automatic void otp_write_hw_cfg1_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h,
      bit [EnCsrngSwAppReadSize*8-1:0] en_csrng_sw_app_read,
      bit [EnSramIfetchSize*8-1:0] en_sram_ifetch,
      bit [EnSramIfetchSize*8-1:0] dis_rv_dm_late_debug
  );
    bit [HwCfg1DigestSize*8-1:0] digest;

    bit [bus_params_pkg::BUS_DW-1:0] hw_cfg1_data[$];

    mem_bkdr_util_h.write32(EnSramIfetchOffset,
                            {dis_rv_dm_late_debug, en_csrng_sw_app_read, en_sram_ifetch});

    hw_cfg1_data = {<<32 {32'h0, dis_rv_dm_late_debug, en_csrng_sw_app_read, en_sram_ifetch}};
    digest = cal_digest(HwCfg1Idx, hw_cfg1_data);

    mem_bkdr_util_h.write64(HwCfg1DigestOffset, digest);
  endfunction

  // Functions that clear the provisioning state of the buffered partitions.
  // This is useful in tests that make front-door accesses for provisioning purposes.
  function automatic void otp_clear_secret0_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h
  );
    for (int i = 0; i < Secret0Size; i += 4) begin
      mem_bkdr_util_h.write32(i + Secret0Offset, 32'h0);
    end
  endfunction

  function automatic void otp_clear_secret1_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h
  );
    for (int i = 0; i < Secret1Size; i += 4) begin
      mem_bkdr_util_h.write32(i + Secret1Offset, 32'h0);
    end
  endfunction

  function automatic void otp_clear_secret2_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h
  );
    for (int i = 0; i < Secret2Size; i += 4) begin
      mem_bkdr_util_h.write32(i + Secret2Offset, 32'h0);
    end
  endfunction

  function automatic void otp_clear_hw_cfg0_partition(
      mem_bkdr_util_pkg::mem_bkdr_util mem_bkdr_util_h
  );
    for (int i = 0; i < HwCfg0Size; i += 4) begin
      mem_bkdr_util_h.write32(i + HwCfg0Offset, 32'h0);
    end
  endfunction
endpackage : otp_ctrl_mem_bkdr_util_pkg
