// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/tests/clkmgr_off_trans_impl.h"

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/dif/dif_aes.h"
#include "sw/device/lib/dif/dif_aon_timer.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_clkmgr.h"
#include "sw/device/lib/dif/dif_hmac.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/dif/dif_pwrmgr.h"
#include "sw/device/lib/dif/dif_rstmgr.h"
#include "sw/device/lib/dif/dif_rv_core_ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/aon_timer_testutils.h"
#include "sw/device/lib/testing/rstmgr_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "aes_regs.h"
#include "hmac_regs.h"
#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "kmac_regs.h"
#include "otbn_regs.h"

static const dt_pwrmgr_t kPwrmgrDt = 0;
static_assert(kDtPwrmgrCount == 1, "this test expects a pwrmgr");
static_assert(kDtAonTimerCount >= 1,
              "this test expects at least one aon_timer");
static const dt_aon_timer_t kAonTimerDt = 0;

/**
 * Test an access to a transactional unit that has been disabled causes
 * a hang access, resulting in a watchdog reset. Check the crash dump
 * data address and current pc after the reset.
 */
OTTF_DEFINE_TEST_CONFIG();

static dif_aon_timer_t aon_timer;

static dif_aes_t aes;
static dif_hmac_t hmac;
static dif_kmac_t kmac;
static dif_otbn_t otbn;

typedef struct clock_error_info {
  /**
   * The unit being tested.
   */
  const char *name;

  /**
   * The memory location that causes the error.
   * This is the expected value of crash_dump's mdaa.
   */
  uint32_t csr_offset;

  /**
   * The address of the function causing the error.  The functions
   * that cause the error are chosen so they perform a CSR read
   * shortly after the function entry, so crash_dump's mcpc is
   * expected to be past the possible error pc by no more than about 8
   * instructions, meaning 8 * 4 bytes.
   */
  uint32_t crash_function;
} clock_error_info_t;

enum { kPcSpread = 8 * 4 };

inline uint32_t addr_as_offset(mmio_region_t base, uint32_t offset) {
  return (uint32_t)base.base + offset;
}

/**
 * Send CSR access to aes, expecting to timeout.
 */
OT_NOINLINE void aes_csr_access(void) {
  CHECK_DIF_OK(dif_aes_alert_force(&aes, kDifAesAlertRecovCtrlUpdateErr));
}

OT_NOINLINE static void hmac_csr_access(void) {
  dif_hmac_irq_state_snapshot_t snapshot;
  CHECK_DIF_OK(dif_hmac_irq_get_state(&hmac, &snapshot));
}

OT_NOINLINE static void kmac_csr_access(void) {
  dif_kmac_status_t status;
  CHECK_DIF_OK(dif_kmac_get_status(&kmac, &status));
}

OT_NOINLINE static void otbn_csr_access(void) {
  dif_otbn_err_bits_t err_bits;
  CHECK_DIF_OK(dif_otbn_get_err_bits(&otbn, &err_bits));
}

static void trans_csr_access(dif_clkmgr_hintable_clock_t trans) {
  switch (trans) {
    case kTopEarlgreyHintableClocksMainAes:
      aes_csr_access();
      break;
    case kTopEarlgreyHintableClocksMainHmac:
      hmac_csr_access();
      break;
    case kTopEarlgreyHintableClocksMainKmac:
      kmac_csr_access();
      break;
    case kTopEarlgreyHintableClocksMainOtbn:
      otbn_csr_access();
      break;
    default:
      LOG_ERROR("Invalid hintable clock (%d)", trans);
      break;
  }
}

/**
 * Test that disabling a 'hintable' unit's clock causes the unit to become
 * unresponsive to CSR accesses. Configure a watchdog reset, and if it triggers
 * the test is successful.
 */
static void test_hintable_clocks_off(const dif_clkmgr_t *clkmgr,
                                     dif_clkmgr_hintable_clock_t clock) {
  // Make sure the clock for the unit is on.
  CHECK_DIF_OK(
      dif_clkmgr_hintable_clock_set_hint(clkmgr, clock, kDifToggleEnabled));

  // Disable the unit, set the aon timer to bite, and issue a CSR read.
  CHECK_DIF_OK(
      dif_clkmgr_hintable_clock_set_hint(clkmgr, clock, kDifToggleDisabled));
  // Short wait to make sure clocks reacted to hints.
  busy_spin_micros(5);

  // Check all units but the hinted one are alive.
  for (dif_clkmgr_hintable_clock_t other = 0;
       other <= kTopEarlgreyHintableClocksLast; ++other) {
    if (other != clock) {
      trans_csr_access(other);
    }
  }

  // Set the watchdog with some time to run the necessary code before the
  // access that should hang.
  uint32_t bite_us = 20;
  uint32_t bite_cycles = 0;
  CHECK_STATUS_OK(
      aon_timer_testutils_get_aon_cycles_32_from_us(bite_us, &bite_cycles));
  LOG_INFO("Setting bite reset for %u us (%u cycles)", bite_us, bite_cycles);
  CHECK_STATUS_OK(aon_timer_testutils_watchdog_config(&aon_timer, UINT32_MAX,
                                                      bite_cycles, false));
  // This should hang.
  trans_csr_access(clock);
  LOG_ERROR("Access to disabled unit should freeze and cause a reset");
}

bool execute_off_trans_test(dif_clkmgr_hintable_clock_t clock) {
  dif_clkmgr_t clkmgr;
  dif_pwrmgr_t pwrmgr;
  dif_rstmgr_t rstmgr;

  CHECK_DIF_OK(dif_rstmgr_init(
      mmio_region_from_addr(TOP_EARLGREY_RSTMGR_AON_BASE_ADDR), &rstmgr));

  CHECK_DIF_OK(dif_clkmgr_init(
      mmio_region_from_addr(TOP_EARLGREY_CLKMGR_AON_BASE_ADDR), &clkmgr));

  CHECK_DIF_OK(dif_pwrmgr_init_from_dt(kPwrmgrDt, &pwrmgr));

  // Initialize aon timer.
  CHECK_DIF_OK(dif_aon_timer_init_from_dt(kAonTimerDt, &aon_timer));

  // Initialize aes.
  CHECK_DIF_OK(
      dif_aes_init(mmio_region_from_addr(TOP_EARLGREY_AES_BASE_ADDR), &aes));

  // Initialize hmac.
  CHECK_DIF_OK(
      dif_hmac_init(mmio_region_from_addr(TOP_EARLGREY_HMAC_BASE_ADDR), &hmac));

  // Initialize kmac.
  CHECK_DIF_OK(
      dif_kmac_init(mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR), &kmac));

  // Initialize otbn.
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  // Initialize the expected error data address and execution address.
  clock_error_info_t clock_error_info[kTopEarlgreyHintableClocksLast + 1] = {
      {"aes", addr_as_offset(aes.base_addr, AES_ALERT_TEST_REG_OFFSET),
       (uint32_t)&aes_csr_access},
      {"hmac", addr_as_offset(hmac.base_addr, HMAC_INTR_STATE_REG_OFFSET),
       (uint32_t)&hmac_csr_access},
      {"kmac", addr_as_offset(kmac.base_addr, KMAC_STATUS_REG_OFFSET),
       (uint32_t)&kmac_csr_access},
      {"otbn", addr_as_offset(otbn.base_addr, OTBN_ERR_BITS_REG_OFFSET),
       (uint32_t)&otbn_csr_access}};

  // Enable cpu dump capture.
  CHECK_DIF_OK(dif_rstmgr_cpu_info_set_enabled(&rstmgr, kDifToggleEnabled));

  if (UNWRAP(rstmgr_testutils_is_reset_info(&rstmgr, kDifRstmgrResetInfoPor))) {
    // Enable watchdog bite reset.
    dif_pwrmgr_request_sources_t reset_sources;
    CHECK_DIF_OK(dif_pwrmgr_find_request_source(
        &pwrmgr, kDifPwrmgrReqTypeReset, dt_aon_timer_instance_id(kAonTimerDt),
        kDtAonTimerResetReqAonTimer, &reset_sources));
    CHECK_DIF_OK(dif_pwrmgr_set_request_sources(
        &pwrmgr, kDifPwrmgrReqTypeReset, reset_sources, kDifToggleEnabled));
    CHECK_STATUS_OK(rstmgr_testutils_pre_reset(&rstmgr));

    test_hintable_clocks_off(&clkmgr, clock);

    // This should never be reached.
    LOG_ERROR("This is unreachable since a reset should have been triggered");
    return false;
  } else if (UNWRAP(rstmgr_testutils_is_reset_info(
                 &rstmgr, kDifRstmgrResetInfoWatchdog))) {
    // Verify the cpu crash dump.
    LOG_INFO("Got an expected watchdog reset when reading for clock %d", clock);
    dif_rv_core_ibex_crash_dump_info_t crash_dump;
    // The sizes for dif_rstmgr_cpu_info_dump_read are measured in
    // units of dif_rstmgr_cpu_info_dump_segment_t.
    size_t size_read;
    CHECK_DIF_OK(dif_rstmgr_cpu_info_dump_read(
        &rstmgr, (dif_rstmgr_cpu_info_dump_segment_t *)&crash_dump,
        sizeof(crash_dump) / sizeof(dif_rstmgr_cpu_info_dump_segment_t),
        &size_read));
    // crash_dump.fault_state.mdaa is the DATA ADDRESS that caused the error.
    CHECK(crash_dump.fault_state.mdaa == clock_error_info[clock].csr_offset);
    // The functions that cause the error are chosen so they perform a
    // CSR read shortly after the function entry, so this expects
    // crash_dump.fault_state.mcpc to be past the crash_function by no
    // more than about 8 instructions, meaning 8 * 4 bytes.
    CHECK(crash_dump.fault_state.mcpc >=
              clock_error_info[clock].crash_function &&
          crash_dump.fault_state.mcpc <=
              clock_error_info[clock].crash_function + kPcSpread);

    return true;
  } else {
    dif_rstmgr_reset_info_bitfield_t reset_info;
    reset_info = rstmgr_testutils_reason_get();
    LOG_ERROR("Unexpected reset_info 0x%x", reset_info);
  }
  return false;
}
