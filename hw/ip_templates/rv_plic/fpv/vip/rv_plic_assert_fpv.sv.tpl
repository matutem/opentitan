// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Testbench module for ${module_instance_name}. Intended to use with a formal tool.

`include "prim_assert.sv"

module ${module_instance_name}_assert_fpv #(parameter int NumSrc = 1,
                            parameter int NumTarget = 1,
                            parameter int NumAlerts = 1,
                            parameter int PRIOW = $clog2(7+1)
) (
  input clk_i,
  input rst_ni,
  input [NumSrc-1:0] intr_src_i,
  input prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i,
  input prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o,
  input [NumTarget-1:0] irq_o,
  input [$clog2(NumSrc)-1:0] irq_id_o [NumTarget],
  input [NumTarget-1:0] msip_o,
  // probe design signals
  input [NumSrc-1:0] ip,
  input [NumSrc-1:0] ie [NumTarget],
  input [NumSrc-1:0] claim,
  input [NumSrc-1:0] complete,
  input [NumSrc-1:0][PRIOW-1:0] prio,
  input [PRIOW-1:0]  threshold [NumTarget],
  input logic        fatal_alert_i,
  input tlul_pkg::tl_d2h_t tl_o
);

  localparam int SrcIdxWidth = NumSrc > 1 ? $clog2(NumSrc - 1) : 1;
  localparam int TgtIdxWidth = NumTarget > 1 ? $clog2(NumTarget - 1) : 1;

  logic claim_reg, claimed;
  logic max_priority;
  logic irq;
  logic [$clog2(NumSrc)-1:0] i_high_prio;

  // symbolic variables
  bit [SrcIdxWidth-1:0] src_sel;
  bit [TgtIdxWidth-1:0] tgt_sel;

  `ASSUME_FPV(IsrcRange_M, src_sel >  0 && src_sel < NumSrc, clk_i, !rst_ni)
  `ASSUME_FPV(ItgtRange_M, tgt_sel >= 0 && tgt_sel < NumTarget, clk_i, !rst_ni)
  `ASSUME_FPV(IsrcStable_M, ##1 $stable(src_sel), clk_i, !rst_ni)
  `ASSUME_FPV(ItgtStable_M, ##1 $stable(tgt_sel), clk_i, !rst_ni)

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      claim_reg <= 1'b0;
    end else if (claim[src_sel]) begin
      claim_reg <= 1'b1;
    end else if (complete[src_sel]) begin
      claim_reg <= 1'b0;
    end
  end

  assign claimed = claim_reg || claim[src_sel];

  always_comb begin
    max_priority = 1'b1;
    for (int i = 0; i < NumSrc; i++) begin
      // conditions that if src_sel has the highest priority with the lowest ID
      if (i != src_sel && ip[i] && ie[tgt_sel][i] &&
            (prio[i] > prio[src_sel] || (prio[i] == prio[src_sel] && i < src_sel))) begin
        max_priority = 1'b0;
        break;
      end
    end
  end

  always_comb begin
    automatic logic [31:0] max_prio = 0;
    for (int i = NumSrc-1; i >= 0; i--) begin
      if (ip[i] && ie[tgt_sel][i] && prio[i] >= max_prio) begin
        max_prio = prio[i];
        i_high_prio = i; // i is the smallest id if have IPs with the same priority
      end
    end
    if (max_prio > threshold[tgt_sel]) irq = 1'b1;
    else irq = 1'b0;
  end

  // when IP is set, previous cycle should follow edge or level triggered criteria
  `ASSERT(LevelTriggeredIp_A, ##3 $rose(ip[src_sel]) |-> $past(intr_src_i[src_sel], 3))

  // when interrupt is trigger, and nothing claimed yet, then next cycle should assert IP.
  `ASSERT(LevelTriggeredIpWithClaim_A, ##2 $past(intr_src_i[src_sel], 2) &&
          !claimed |=> ip[src_sel])

  // ip stays stable until claimed, reset to 0 after claimed, and stays 0 until complete
  `ASSERT(IpStableAfterTriggered_A, ip[src_sel] && !claimed  |=> ip[src_sel])
  `ASSERT(IpClearAfterClaim_A, ip[src_sel] && claim[src_sel] |=> !ip[src_sel])
  `ASSERT(IpStableAfterClaimed_A, claimed |=> !ip[src_sel])

  // when ip is set and priority is the largest and above threshold, and interrupt enable is set,
  // assertion irq_o at next cycle
  `ASSERT(TriggerIrqForwardCheck_A, ip[src_sel] && prio[src_sel] > threshold[tgt_sel] &&
          max_priority && ie[tgt_sel][src_sel] |=> irq_o[tgt_sel])

  `ASSERT(TriggerIrqBackwardCheck_A, $rose(irq_o[tgt_sel]) |->
          $past(irq) && (irq_id_o[tgt_sel] == $past(i_high_prio)))

  // when irq ID changed, but not to ID=0, irq_o should be high, or irq represents the largest prio
  // but smaller than the threshold
  `ASSERT(IdChangeWithIrq_A, !$stable(irq_id_o[tgt_sel]) && irq_id_o[tgt_sel] != 0 |->
          irq_o[tgt_sel] || ((irq_id_o[tgt_sel]) == $past(i_high_prio) && !$past(irq)))

  // If a response is coming back from the device, then check if it contains the correct integrity
  // bits.
  `ASSERT(DataIntg_A,
          tl_o.d_valid -> (tlul_pkg::get_data_intg(tl_o.d_data) == tl_o.d_user.data_intg))

  `ASSERT(RspIntg_A,
          tl_o.d_valid ->
          (prim_secded_pkg::prim_secded_inv_64_57_enc({51'b0, tlul_pkg::extract_d2h_rsp_intg(tl_o)})
          >> (64-tlul_pkg::D2HRspIntgWidth)) == tl_o.d_user.rsp_intg)

  // When fatal alert happens then only reset can clear it.
  `ASSERT(FatalAlertNeverdrops_A, ##1 !$fell(fatal_alert_i))
endmodule : ${module_instance_name}_assert_fpv
