// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>

#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/status.h"
#include "sw/ip/pinmux/driver/pinmux.h"
#include "sw/ip/pinmux/test/utils/pinmux_testutils.h"
#include "sw/ip/uart/dif/dif_uart.h"
#include "sw/ip/uart/driver/uart.h"
#include "sw/lib/sw/device/arch/device.h"
#include "sw/lib/sw/device/runtime/log.h"
#include "sw/lib/sw/device/runtime/print.h"

static dif_uart_t uart;
static dif_pinmux_t pinmux;

void sram_main(void) {
  // Initialize UART console.
  CHECK_DIF_OK(
      dif_pinmux_init(mmio_region_from_addr(kPinmuxAonBaseAddr[0]), &pinmux));
  CHECK_DIF_OK(dif_uart_init(mmio_region_from_addr(kUartBaseAddr[0]), &uart));
  pinmux_testutils_init(&pinmux);
  CHECK(kUartBaudrate <= UINT32_MAX, "kUartBaudrate must fit in uint32_t");
  CHECK(kClockFreqPeripheralHz <= UINT32_MAX,
        "kClockFreqPeripheralHz must fit in uint32_t");
  CHECK_DIF_OK(dif_uart_configure(
      &uart, (dif_uart_config_t){
                 .baudrate = (uint32_t)kUartBaudrate,
                 .clk_freq_hz = (uint32_t)kClockFreqPeripheralHz,
                 .parity_enable = kDifToggleDisabled,
                 .parity = kDifUartParityEven,
                 .tx_enable = kDifToggleEnabled,
                 .rx_enable = kDifToggleEnabled,
             }));
  base_uart_stdout(&uart);

  LOG_INFO("hello");

  // Make sure that the function returns so that the CRT can notify the host.
}