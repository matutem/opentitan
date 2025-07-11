# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# The port data_o in u_data_chk is untied and used nowhere.
check_cov -waiver -add -start_line 25 -end_line 56 -type {statement} -instance\
 {dut.u_reg.u_chk.u_tlul_data_integ_dec.u_data_chk} -comment {data_o is untied}

# The port data_o in u_data_chk is untied and used nowhere.
check_cov -waiver -add -start_line 25 -end_line 81 -type {statement} -instance\
 {dut.u_reg.u_chk.u_chk} -comment {data_o is untied}

# Since the interrupts are level triggered, we don't use scr_q register in rv_plic_gateway. So,
# even if this logic is broken, nobody (in the assertions world) cares.
check_cov -waiver -add -start_line 33 -end_line 33 -instance {dut.u_gateway} -comment\
 {Interrupts are level triggered and this assignment would not affect any assertions}

# To support the waivers above, this assertion is added. So, if interrupts are no longer level
# triggered, this will fail.
assert -name InterruptsLevelTriggered_A {!$rose(dut.u_gateway.le_i)}

# The ds output port is not connected for any instantiation of prim_subreg or prim_subreg_ext in
# rv_plic. This would only be connected for a writeable register that has an asynchronous clock
# (see reg_top.sv.tpl), and rv_plic doesn't have any of these. As such, the code that is waived
# here (which drives the port) is undetectable.
check_cov -waiver -add -source_file {src/lowrisc_prim_subreg_0/rtl/prim_subreg.sv}\
 -start_line 64 -end_line 64 -type {branch} -comment {Checker coverage is undetectable as ds is\
 unconnected}

# For all the ip registers, de is true and hence wr_en is true. The branch misses the else part and
# appeared dead.
check_cov -waiver -add -source_file {src/lowrisc_prim_subreg_0/rtl/prim_subreg.sv} -start_line\
 58 -end_line 58 -type {branch} -comment {wr_en is true and the branch doesn't contain the else\
 part}

# The waivers below are waiving the branch and statement (inside those branches) in mubi(4-16)_and
# function in prim_mubi_pkg used in rv_plic_csr_assert_fpv. Since, rv_plic registers doesn't have
# any regwen types therefore all the mubi(4-16)_and functions are unused.
check_cov -waiver -add -start_line 119 -end_line 139 -instance {prim_mubi_pkg} -comment {Unused\
 code block}

check_cov -waiver -add -start_line 258 -end_line 278 -instance {prim_mubi_pkg} -comment {Unused\
 code block}

check_cov -waiver -add -start_line 397 -end_line 417 -instance {prim_mubi_pkg} -comment {Unused\
 code block}

check_cov -waiver -add -start_line 536 -end_line 556 -instance {prim_mubi_pkg} -comment {Unused\
 code block}

# These two blocking assignment appear as undetectable and making an assertion for them looks
# unreasonable as for this particular instance, they will always be generated as zero.
check_cov -waiver -add -start_line 67 -end_line 68 -type {statement} -instance\
 {dut.u_reg.u_reg_if.u_rsp_intg_gen} -comment {Rsp and Data Intg will always be zero}

# Waiving all the alert instances for coverage.
foreach alert_sender_inst [get_design_info -list instance -filter "prim_alert_sender$" -regexp] {
  check_cov -waiver -add -instance "$alert_sender_inst"\
    -comment {FPV for Alerts has already been done elsewhere}
}
