// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/dif/dif_lc_ctrl.h"
#include "sw/device/lib/dif/dif_rv_core_ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/rv_core_ibex_testutils.h"
#include "sw/device/lib/testing/test_framework/ujson_ottf.h"
#include "sw/device/lib/ujson/ujson.h"
#include "sw/device/tests/penetrationtests/firmware/lib/pentest_lib.h"
#include "sw/device/tests/penetrationtests/json/lc_ctrl_fi_commands.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

static dif_rv_core_ibex_t rv_core_ibex;
static dif_lc_ctrl_t lc;

status_t handle_lc_ctrl_fi_init(ujson_t *uj) {
  penetrationtest_cpuctrl_t uj_cpuctrl_data;
  TRY(ujson_deserialize_penetrationtest_cpuctrl_t(uj, &uj_cpuctrl_data));
  penetrationtest_sensor_config_t uj_sensor_data;
  TRY(ujson_deserialize_penetrationtest_sensor_config_t(uj, &uj_sensor_data));
  penetrationtest_alert_config_t uj_alert_data;
  TRY(ujson_deserialize_penetrationtest_alert_config_t(uj, &uj_alert_data));

  pentest_select_trigger_type(kPentestTriggerTypeSw);
  // As we are using the software defined trigger, the first argument of
  // pentest_init is not needed. kPentestTriggerSourceAes is selected as a
  // placeholder.
  pentest_init(kPentestTriggerSourceAes,
               kPentestPeripheralIoDiv4 | kPentestPeripheralCsrng,
               uj_sensor_data.sensor_ctrl_enable,
               uj_sensor_data.sensor_ctrl_en_fatal);

  // Configure the CPU for the pentest.
  penetrationtest_device_info_t uj_output;
  TRY(pentest_configure_cpu(
      uj_cpuctrl_data.enable_icache, &uj_output.icache_en,
      uj_cpuctrl_data.enable_dummy_instr, &uj_output.dummy_instr_en,
      uj_cpuctrl_data.dummy_instr_count, uj_cpuctrl_data.enable_jittery_clock,
      uj_cpuctrl_data.enable_sram_readback, &uj_output.clock_jitter_locked,
      &uj_output.clock_jitter_en, &uj_output.sram_main_readback_locked,
      &uj_output.sram_ret_readback_locked, &uj_output.sram_main_readback_en,
      &uj_output.sram_ret_readback_en));

  // Configure Ibex to allow reading ERR_STATUS register.
  TRY(dif_rv_core_ibex_init(
      mmio_region_from_addr(TOP_EARLGREY_RV_CORE_IBEX_CFG_BASE_ADDR),
      &rv_core_ibex));

  // Configure LC Controller.
  mmio_region_t lc_reg =
      mmio_region_from_addr(TOP_EARLGREY_LC_CTRL_REGS_BASE_ADDR);
  TRY(dif_lc_ctrl_init(lc_reg, &lc));

  // Configure the alert handler. Alerts triggered by IP blocks are captured
  // and reported to the test.
  pentest_configure_alert_handler(
      uj_alert_data.alert_classes, uj_alert_data.enable_alerts,
      uj_alert_data.enable_classes, uj_alert_data.accumulation_thresholds,
      uj_alert_data.signals, uj_alert_data.duration_cycles,
      uj_alert_data.ping_timeout);

  // Read device ID and return to host.
  TRY(pentest_read_device_id(uj_output.device_id));
  RESP_OK(ujson_serialize_penetrationtest_device_info_t, uj, &uj_output);

  // Read the sensor config.
  TRY(pentest_send_sensor_config(uj));

  // Read the alert config.
  TRY(pentest_send_alert_config(uj));

  // Read different SKU config fields and return to host.
  TRY(pentest_send_sku_config(uj));

  return OK_STATUS();
}

status_t handle_lc_ctrl_fi_runtime_corruption(ujson_t *uj) {
  // Clear registered alerts in alert handler.
  pentest_registered_alerts_t reg_alerts = pentest_get_triggered_alerts();
  // Clear the AST recoverable alerts.
  pentest_clear_sensor_recov_alerts();

  // Read LC CTRL to get reference values.
  dif_lc_ctrl_state_t lc_state_ref;
  uint8_t lc_count_ref;
  TRY(dif_lc_ctrl_get_state(&lc, &lc_state_ref));
  TRY(dif_lc_ctrl_get_attempts(&lc, &lc_count_ref));

  pentest_set_trigger_high();
  asm volatile(NOP100);
  asm volatile(NOP100);
  asm volatile(NOP100);
  pentest_set_trigger_low();

  // Get registered alerts from alert handler.
  reg_alerts = pentest_get_triggered_alerts();
  // Get fatal and recoverable AST alerts from sensor controller.
  pentest_sensor_alerts_t sensor_alerts = pentest_get_sensor_alerts();

  // Check if we have managed to manipulate the LC Controller.
  dif_lc_ctrl_state_t lc_state_cmp;
  uint8_t lc_count_cmp;
  TRY(dif_lc_ctrl_get_state(&lc, &lc_state_cmp));
  TRY(dif_lc_ctrl_get_attempts(&lc, &lc_count_cmp));

  // Do the comparison. Return res = 0 if no mismatch was detected. 1 is
  // returned if only the lc_state was manipulated. 2 if only the counter was
  // manipulated. 3 if state and counter was manipulated.
  lc_ctrl_fi_corruption_t uj_output;
  uj_output.res = 0;
  if (lc_state_cmp != lc_state_ref) {
    uj_output.res = 1;
  }

  if (lc_count_cmp != lc_count_ref) {
    if (uj_output.res) {
      uj_output.res = 3;
    } else {
      uj_output.res = 2;
    }
  }

  // Read ERR_STATUS register from Ibex.
  dif_rv_core_ibex_error_status_t err_ibx;
  TRY(dif_rv_core_ibex_get_error_status(&rv_core_ibex, &err_ibx));

  // Send result & ERR_STATUS to host.
  uj_output.state = lc_state_cmp;
  uj_output.counter = lc_count_cmp;
  uj_output.err_status = err_ibx;
  memcpy(uj_output.alerts, reg_alerts.alerts, sizeof(reg_alerts.alerts));
  memcpy(uj_output.ast_alerts, sensor_alerts.alerts,
         sizeof(sensor_alerts.alerts));
  RESP_OK(ujson_serialize_lc_ctrl_fi_corruption_t, uj, &uj_output);

  return OK_STATUS();
}

status_t handle_lc_ctrl_fi(ujson_t *uj) {
  lc_ctrl_fi_subcommand_t cmd;
  TRY(ujson_deserialize_lc_ctrl_fi_subcommand_t(uj, &cmd));
  switch (cmd) {
    case kLcCtrlFiSubcommandInit:
      return handle_lc_ctrl_fi_init(uj);
    case kLcCtrlFiSubcommandRuntimeCorruption:
      return handle_lc_ctrl_fi_runtime_corruption(uj);
    default:
      LOG_ERROR("Unrecognized LC CTRL FI subcommand: %d", cmd);
      return INVALID_ARGUMENT();
  }
  return OK_STATUS();
}
