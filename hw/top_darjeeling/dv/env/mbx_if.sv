// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// All mailboxes instantiated within the Darjeeling system have their SoC-facing
// TL-UL ports connected to an internal crossbar. The common-port of this
// crossbar is routed out of the system (mbx_tl).  This excludes the jtag
// mailbox, which is routed out of the system via the dbg_xbar (dmi_tl_if). The
// SoC-facing interrupts generated by each individual mailbox are routed out of
// the system individually (mbx_intr).
//
// This is a hierarchical interface that wraps other interfaces required for
// the darjeeling mailboxes to communicate with an external SoC.

interface mbx_if (
  input logic clk,
  input logic rst_n
  );

  import chip_common_pkg::*;

  // IF Signals
  tl_if mbx_tl_if(.clk(clk), .rst_n(rst_n)); // from mbx_xbar
  wire mbx_intr_signals_t[chip_common_pkg::NUM_MBXS-1:0] interrupts;

  // Internal Signals
  // wire tlul_pkg::tl_h2d_t h2d; // req
  // wire tlul_pkg::tl_d2h_t d2h; // rsp
  bit disconnected;

  // assign tl_if.d2h = disconnected ? 'z : d2h;
  // assign h2d = disconnected ? 'z : tl_if.h2d;

  clocking interrupts_cb @(posedge clk);
    input interrupts;
  endclocking
  modport interrupts_mp (clocking interrupts_cb);

endinterface