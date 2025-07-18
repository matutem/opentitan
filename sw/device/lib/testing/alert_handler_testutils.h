// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_ALERT_HANDLER_TESTUTILS_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_ALERT_HANDLER_TESTUTILS_H_

#include <stdbool.h>

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/dif/dif_alert_handler.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_rstmgr.h"

#include "alert_handler_regs.h"

enum {
  kAlertHandlerTestutilsDefaultPingTimeout = 256,
};

typedef enum alert_handler_class_state {
  kCstateIdle = 0,
  kCstateTimeout = 1,
  kCstateTerminal = 3,
  kCstatePhase0 = 4,
  kCstatePhase1 = 5,
  kCstatePhase2 = 6,
  kCstatePhase3 = 7,
  kCstateFsmError = 2
} alert_handler_class_state_t;

/**
 * Represents the hardware alert crash dump in a more software-friendly manner.
 */
typedef struct alert_info_testutils_info {
  bool alert_cause[ALERT_HANDLER_PARAM_N_ALERTS];
  uint8_t loc_alert_cause;                                  // 7bit
  uint16_t class_accum_cnt[ALERT_HANDLER_PARAM_N_CLASSES];  // 4x16bit
  uint32_t class_esc_cnt[ALERT_HANDLER_PARAM_N_CLASSES];    // 4x32bit
  alert_handler_class_state_t
      class_esc_state[ALERT_HANDLER_PARAM_N_CLASSES];  // 4x3bit
} alert_handler_testutils_info_t;

/**
 * Converts the hardware alert crash dump into an
 * `alert_handler_testutils_info_t`. This makes it easier to compare and display
 * the different fields.
 * @param dump Buffer containing the dump.
 * @param dump_size The size of the `dump` in words.
 * @param[out] info The parsed info.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_info_parse(
    const dif_rstmgr_alert_info_dump_segment_t *dump, int dump_size,
    alert_handler_testutils_info_t *info);

/**
 * Displays an alert_handler_testutils_info_t as strings.
 */
void alert_handler_testutils_info_dump(
    const alert_handler_testutils_info_t *info);

/**
 * Configures alert handler with all required runtime information.
 *
 * This operation is lock-protected, meaning once the configuration is locked,
 * it cannot be reconfigured until after a system reset. If `locked` is set to
 * `kDifToggleEnabled`, then every lockable configuration will be locked.
 * Otherwise, configurations may only be locked by performing subsequent calls
 * to each component-specific locking DIF: `dif_alert_handler_lock_*(...)`.
 *
 * @param alert_handler An alert handler handle.
 * @param config Runtime configuration parameters.
 * @param locked The locked state to set for each configuration.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_configure_all(
    const dif_alert_handler_t *alert_handler, dif_alert_handler_config_t config,
    dif_toggle_t locked);

/**
 * Returns the number of cycles corresponding to the given microseconds.
 *
 * @param microseconds The number of microseconds.
 * @param[out] cycles The number of AON clock cycles.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_get_cycles_from_us(uint64_t microseconds,
                                                    uint32_t *cycles);

/**
 * Returns a scaling factor for conversion of time to cycles.
 *
 * Setting escalation cycle counts must be such that the ISRs have time to
 * complete before the next escalation stage starts. We tend to generate cycle
 * counts from time durations, and given that the relevant clock frequencies
 * are much lower in non-sim_dv devices we may end up having to set quite high
 * time durations to avoid incomplete ISRs for fpga or verilator.
 *
 * This function allows the time durations to be set for the sim_dv clock
 * frequencies, and other platforms get the cycle count rescaled by a factor
 * of 10. It should be used in the conversion of time duration to cycle counts,
 * as in
 *  cycles = udiv64_slow(micros * clockFreqHz, 1000000, NULL) *
 *           cycle_rescaling_factor();
 */
uint32_t alert_handler_testutils_cycle_rescaling_factor(void);

/**
 * Logs the status of the alert handler.
 *
 * This function will log the state of each alert class, including the
 * number of alerts that have been accumulated.
 *
 * Only the alert classes that have accumulated alerts will be logged.
 *
 * @param alert_handler An alert handler handle.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_status_log(
    const dif_alert_handler_t *alert_handler);

/**
 * Logs the alert handler crash dump.
 *
 * This function will log the state of each alert class, including the
 * number of alerts that have been accumulated.
 *
 * Only alerts that have been set will be logged, as well as the alert
 * classes that are in non-idle states.
 *
 * @param rstmgr A RSTMGR handle.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_dump_log(const dif_rstmgr_t *rstmgr);

/**
 * Enables the alert handler crash dump.
 *
 * This function will enable the alert handler crash dump, which will
 * cause the alert handler to dump its state to the RSTMGR when an
 * alert is triggered.
 *
 * @param alert_handler An alert handler handle.
 * @param rstmgr A RSTMGR handle.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t alert_handler_testutils_dump_enable(
    const dif_alert_handler_t *alert_handler, const dif_rstmgr_t *rstmgr);

#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_ALERT_HANDLER_TESTUTILS_H_
