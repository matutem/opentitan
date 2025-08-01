// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#include <stdbool.h>

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/ujson_ottf.h"
#include "sw/device/lib/ujson/ujson.h"

// Include commands
#include "sw/device/tests/penetrationtests/json/commands.h"
#include "sw/device/tests/penetrationtests/json/cryptolib_sca_sym_commands.h"

// Include handlers
#include "lib/extclk_sca_fi.h"
#include "lib/pentest_lib.h"
#include "sca/cryptolib_sca_sym.h"

OTTF_DEFINE_TEST_CONFIG(.enable_uart_flow_control = true);

status_t process_cmd(ujson_t *uj) {
  while (true) {
    penetrationtest_cmd_t cmd;
    TRY(ujson_deserialize_penetrationtest_cmd_t(uj, &cmd));
    switch (cmd) {
      case kPenetrationtestCommandCryptoLibScaSym:
        RESP_ERR(uj, handle_cryptolib_sca_sym(uj));
        break;
      default:
        LOG_ERROR("Unrecognized command: %d", cmd);
        RESP_ERR(uj, INVALID_ARGUMENT());
    }
  }

  return OK_STATUS();
}

bool test_main(void) {
  CHECK_STATUS_OK(entropy_complex_init());
  ujson_t uj = ujson_ottf_console();
  return status_ok(process_cmd(&uj));
}
