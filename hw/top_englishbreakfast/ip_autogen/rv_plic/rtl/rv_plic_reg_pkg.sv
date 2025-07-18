// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package rv_plic_reg_pkg;

  // Param list
  parameter int NumSrc = 88;
  parameter int NumTarget = 1;
  parameter int PrioWidth = 2;
  parameter int NumAlerts = 1;

  // Address widths within the block
  parameter int BlockAw = 27;

  // Number of registers for every interface
  parameter int NumRegs = 98;

  // Alert indices
  typedef enum int {
    AlertFatalFaultIdx = 0
  } rv_plic_alert_idx_t;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_prio_mreg_t;

  typedef struct packed {
    logic        q;
  } rv_plic_reg2hw_ie0_mreg_t;

  typedef struct packed {
    logic [1:0]  q;
  } rv_plic_reg2hw_threshold0_reg_t;

  typedef struct packed {
    logic [6:0]  q;
    logic        qe;
    logic        re;
  } rv_plic_reg2hw_cc0_reg_t;

  typedef struct packed {
    logic        q;
  } rv_plic_reg2hw_msip0_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } rv_plic_reg2hw_alert_test_reg_t;

  typedef struct packed {
    logic        d;
    logic        de;
  } rv_plic_hw2reg_ip_mreg_t;

  typedef struct packed {
    logic [6:0]  d;
  } rv_plic_hw2reg_cc0_reg_t;

  // Register -> HW type
  typedef struct packed {
    rv_plic_reg2hw_prio_mreg_t [87:0] prio; // [277:102]
    rv_plic_reg2hw_ie0_mreg_t [87:0] ie0; // [101:14]
    rv_plic_reg2hw_threshold0_reg_t threshold0; // [13:12]
    rv_plic_reg2hw_cc0_reg_t cc0; // [11:3]
    rv_plic_reg2hw_msip0_reg_t msip0; // [2:2]
    rv_plic_reg2hw_alert_test_reg_t alert_test; // [1:0]
  } rv_plic_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    rv_plic_hw2reg_ip_mreg_t [87:0] ip; // [182:7]
    rv_plic_hw2reg_cc0_reg_t cc0; // [6:0]
  } rv_plic_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_0_OFFSET = 27'h 0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_1_OFFSET = 27'h 4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_2_OFFSET = 27'h 8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_3_OFFSET = 27'h c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_4_OFFSET = 27'h 10;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_5_OFFSET = 27'h 14;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_6_OFFSET = 27'h 18;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_7_OFFSET = 27'h 1c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_8_OFFSET = 27'h 20;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_9_OFFSET = 27'h 24;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_10_OFFSET = 27'h 28;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_11_OFFSET = 27'h 2c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_12_OFFSET = 27'h 30;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_13_OFFSET = 27'h 34;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_14_OFFSET = 27'h 38;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_15_OFFSET = 27'h 3c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_16_OFFSET = 27'h 40;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_17_OFFSET = 27'h 44;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_18_OFFSET = 27'h 48;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_19_OFFSET = 27'h 4c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_20_OFFSET = 27'h 50;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_21_OFFSET = 27'h 54;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_22_OFFSET = 27'h 58;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_23_OFFSET = 27'h 5c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_24_OFFSET = 27'h 60;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_25_OFFSET = 27'h 64;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_26_OFFSET = 27'h 68;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_27_OFFSET = 27'h 6c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_28_OFFSET = 27'h 70;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_29_OFFSET = 27'h 74;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_30_OFFSET = 27'h 78;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_31_OFFSET = 27'h 7c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_32_OFFSET = 27'h 80;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_33_OFFSET = 27'h 84;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_34_OFFSET = 27'h 88;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_35_OFFSET = 27'h 8c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_36_OFFSET = 27'h 90;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_37_OFFSET = 27'h 94;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_38_OFFSET = 27'h 98;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_39_OFFSET = 27'h 9c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_40_OFFSET = 27'h a0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_41_OFFSET = 27'h a4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_42_OFFSET = 27'h a8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_43_OFFSET = 27'h ac;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_44_OFFSET = 27'h b0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_45_OFFSET = 27'h b4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_46_OFFSET = 27'h b8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_47_OFFSET = 27'h bc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_48_OFFSET = 27'h c0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_49_OFFSET = 27'h c4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_50_OFFSET = 27'h c8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_51_OFFSET = 27'h cc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_52_OFFSET = 27'h d0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_53_OFFSET = 27'h d4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_54_OFFSET = 27'h d8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_55_OFFSET = 27'h dc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_56_OFFSET = 27'h e0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_57_OFFSET = 27'h e4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_58_OFFSET = 27'h e8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_59_OFFSET = 27'h ec;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_60_OFFSET = 27'h f0;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_61_OFFSET = 27'h f4;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_62_OFFSET = 27'h f8;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_63_OFFSET = 27'h fc;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_64_OFFSET = 27'h 100;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_65_OFFSET = 27'h 104;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_66_OFFSET = 27'h 108;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_67_OFFSET = 27'h 10c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_68_OFFSET = 27'h 110;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_69_OFFSET = 27'h 114;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_70_OFFSET = 27'h 118;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_71_OFFSET = 27'h 11c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_72_OFFSET = 27'h 120;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_73_OFFSET = 27'h 124;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_74_OFFSET = 27'h 128;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_75_OFFSET = 27'h 12c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_76_OFFSET = 27'h 130;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_77_OFFSET = 27'h 134;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_78_OFFSET = 27'h 138;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_79_OFFSET = 27'h 13c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_80_OFFSET = 27'h 140;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_81_OFFSET = 27'h 144;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_82_OFFSET = 27'h 148;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_83_OFFSET = 27'h 14c;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_84_OFFSET = 27'h 150;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_85_OFFSET = 27'h 154;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_86_OFFSET = 27'h 158;
  parameter logic [BlockAw-1:0] RV_PLIC_PRIO_87_OFFSET = 27'h 15c;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_0_OFFSET = 27'h 1000;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_1_OFFSET = 27'h 1004;
  parameter logic [BlockAw-1:0] RV_PLIC_IP_2_OFFSET = 27'h 1008;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_0_OFFSET = 27'h 2000;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_1_OFFSET = 27'h 2004;
  parameter logic [BlockAw-1:0] RV_PLIC_IE0_2_OFFSET = 27'h 2008;
  parameter logic [BlockAw-1:0] RV_PLIC_THRESHOLD0_OFFSET = 27'h 200000;
  parameter logic [BlockAw-1:0] RV_PLIC_CC0_OFFSET = 27'h 200004;
  parameter logic [BlockAw-1:0] RV_PLIC_MSIP0_OFFSET = 27'h 4000000;
  parameter logic [BlockAw-1:0] RV_PLIC_ALERT_TEST_OFFSET = 27'h 4004000;

  // Reset values for hwext registers and their fields
  parameter logic [6:0] RV_PLIC_CC0_RESVAL = 7'h 0;
  parameter logic [0:0] RV_PLIC_ALERT_TEST_RESVAL = 1'h 0;

  // Register index
  typedef enum int {
    RV_PLIC_PRIO_0,
    RV_PLIC_PRIO_1,
    RV_PLIC_PRIO_2,
    RV_PLIC_PRIO_3,
    RV_PLIC_PRIO_4,
    RV_PLIC_PRIO_5,
    RV_PLIC_PRIO_6,
    RV_PLIC_PRIO_7,
    RV_PLIC_PRIO_8,
    RV_PLIC_PRIO_9,
    RV_PLIC_PRIO_10,
    RV_PLIC_PRIO_11,
    RV_PLIC_PRIO_12,
    RV_PLIC_PRIO_13,
    RV_PLIC_PRIO_14,
    RV_PLIC_PRIO_15,
    RV_PLIC_PRIO_16,
    RV_PLIC_PRIO_17,
    RV_PLIC_PRIO_18,
    RV_PLIC_PRIO_19,
    RV_PLIC_PRIO_20,
    RV_PLIC_PRIO_21,
    RV_PLIC_PRIO_22,
    RV_PLIC_PRIO_23,
    RV_PLIC_PRIO_24,
    RV_PLIC_PRIO_25,
    RV_PLIC_PRIO_26,
    RV_PLIC_PRIO_27,
    RV_PLIC_PRIO_28,
    RV_PLIC_PRIO_29,
    RV_PLIC_PRIO_30,
    RV_PLIC_PRIO_31,
    RV_PLIC_PRIO_32,
    RV_PLIC_PRIO_33,
    RV_PLIC_PRIO_34,
    RV_PLIC_PRIO_35,
    RV_PLIC_PRIO_36,
    RV_PLIC_PRIO_37,
    RV_PLIC_PRIO_38,
    RV_PLIC_PRIO_39,
    RV_PLIC_PRIO_40,
    RV_PLIC_PRIO_41,
    RV_PLIC_PRIO_42,
    RV_PLIC_PRIO_43,
    RV_PLIC_PRIO_44,
    RV_PLIC_PRIO_45,
    RV_PLIC_PRIO_46,
    RV_PLIC_PRIO_47,
    RV_PLIC_PRIO_48,
    RV_PLIC_PRIO_49,
    RV_PLIC_PRIO_50,
    RV_PLIC_PRIO_51,
    RV_PLIC_PRIO_52,
    RV_PLIC_PRIO_53,
    RV_PLIC_PRIO_54,
    RV_PLIC_PRIO_55,
    RV_PLIC_PRIO_56,
    RV_PLIC_PRIO_57,
    RV_PLIC_PRIO_58,
    RV_PLIC_PRIO_59,
    RV_PLIC_PRIO_60,
    RV_PLIC_PRIO_61,
    RV_PLIC_PRIO_62,
    RV_PLIC_PRIO_63,
    RV_PLIC_PRIO_64,
    RV_PLIC_PRIO_65,
    RV_PLIC_PRIO_66,
    RV_PLIC_PRIO_67,
    RV_PLIC_PRIO_68,
    RV_PLIC_PRIO_69,
    RV_PLIC_PRIO_70,
    RV_PLIC_PRIO_71,
    RV_PLIC_PRIO_72,
    RV_PLIC_PRIO_73,
    RV_PLIC_PRIO_74,
    RV_PLIC_PRIO_75,
    RV_PLIC_PRIO_76,
    RV_PLIC_PRIO_77,
    RV_PLIC_PRIO_78,
    RV_PLIC_PRIO_79,
    RV_PLIC_PRIO_80,
    RV_PLIC_PRIO_81,
    RV_PLIC_PRIO_82,
    RV_PLIC_PRIO_83,
    RV_PLIC_PRIO_84,
    RV_PLIC_PRIO_85,
    RV_PLIC_PRIO_86,
    RV_PLIC_PRIO_87,
    RV_PLIC_IP_0,
    RV_PLIC_IP_1,
    RV_PLIC_IP_2,
    RV_PLIC_IE0_0,
    RV_PLIC_IE0_1,
    RV_PLIC_IE0_2,
    RV_PLIC_THRESHOLD0,
    RV_PLIC_CC0,
    RV_PLIC_MSIP0,
    RV_PLIC_ALERT_TEST
  } rv_plic_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] RV_PLIC_PERMIT [98] = '{
    4'b 0001, // index[ 0] RV_PLIC_PRIO_0
    4'b 0001, // index[ 1] RV_PLIC_PRIO_1
    4'b 0001, // index[ 2] RV_PLIC_PRIO_2
    4'b 0001, // index[ 3] RV_PLIC_PRIO_3
    4'b 0001, // index[ 4] RV_PLIC_PRIO_4
    4'b 0001, // index[ 5] RV_PLIC_PRIO_5
    4'b 0001, // index[ 6] RV_PLIC_PRIO_6
    4'b 0001, // index[ 7] RV_PLIC_PRIO_7
    4'b 0001, // index[ 8] RV_PLIC_PRIO_8
    4'b 0001, // index[ 9] RV_PLIC_PRIO_9
    4'b 0001, // index[10] RV_PLIC_PRIO_10
    4'b 0001, // index[11] RV_PLIC_PRIO_11
    4'b 0001, // index[12] RV_PLIC_PRIO_12
    4'b 0001, // index[13] RV_PLIC_PRIO_13
    4'b 0001, // index[14] RV_PLIC_PRIO_14
    4'b 0001, // index[15] RV_PLIC_PRIO_15
    4'b 0001, // index[16] RV_PLIC_PRIO_16
    4'b 0001, // index[17] RV_PLIC_PRIO_17
    4'b 0001, // index[18] RV_PLIC_PRIO_18
    4'b 0001, // index[19] RV_PLIC_PRIO_19
    4'b 0001, // index[20] RV_PLIC_PRIO_20
    4'b 0001, // index[21] RV_PLIC_PRIO_21
    4'b 0001, // index[22] RV_PLIC_PRIO_22
    4'b 0001, // index[23] RV_PLIC_PRIO_23
    4'b 0001, // index[24] RV_PLIC_PRIO_24
    4'b 0001, // index[25] RV_PLIC_PRIO_25
    4'b 0001, // index[26] RV_PLIC_PRIO_26
    4'b 0001, // index[27] RV_PLIC_PRIO_27
    4'b 0001, // index[28] RV_PLIC_PRIO_28
    4'b 0001, // index[29] RV_PLIC_PRIO_29
    4'b 0001, // index[30] RV_PLIC_PRIO_30
    4'b 0001, // index[31] RV_PLIC_PRIO_31
    4'b 0001, // index[32] RV_PLIC_PRIO_32
    4'b 0001, // index[33] RV_PLIC_PRIO_33
    4'b 0001, // index[34] RV_PLIC_PRIO_34
    4'b 0001, // index[35] RV_PLIC_PRIO_35
    4'b 0001, // index[36] RV_PLIC_PRIO_36
    4'b 0001, // index[37] RV_PLIC_PRIO_37
    4'b 0001, // index[38] RV_PLIC_PRIO_38
    4'b 0001, // index[39] RV_PLIC_PRIO_39
    4'b 0001, // index[40] RV_PLIC_PRIO_40
    4'b 0001, // index[41] RV_PLIC_PRIO_41
    4'b 0001, // index[42] RV_PLIC_PRIO_42
    4'b 0001, // index[43] RV_PLIC_PRIO_43
    4'b 0001, // index[44] RV_PLIC_PRIO_44
    4'b 0001, // index[45] RV_PLIC_PRIO_45
    4'b 0001, // index[46] RV_PLIC_PRIO_46
    4'b 0001, // index[47] RV_PLIC_PRIO_47
    4'b 0001, // index[48] RV_PLIC_PRIO_48
    4'b 0001, // index[49] RV_PLIC_PRIO_49
    4'b 0001, // index[50] RV_PLIC_PRIO_50
    4'b 0001, // index[51] RV_PLIC_PRIO_51
    4'b 0001, // index[52] RV_PLIC_PRIO_52
    4'b 0001, // index[53] RV_PLIC_PRIO_53
    4'b 0001, // index[54] RV_PLIC_PRIO_54
    4'b 0001, // index[55] RV_PLIC_PRIO_55
    4'b 0001, // index[56] RV_PLIC_PRIO_56
    4'b 0001, // index[57] RV_PLIC_PRIO_57
    4'b 0001, // index[58] RV_PLIC_PRIO_58
    4'b 0001, // index[59] RV_PLIC_PRIO_59
    4'b 0001, // index[60] RV_PLIC_PRIO_60
    4'b 0001, // index[61] RV_PLIC_PRIO_61
    4'b 0001, // index[62] RV_PLIC_PRIO_62
    4'b 0001, // index[63] RV_PLIC_PRIO_63
    4'b 0001, // index[64] RV_PLIC_PRIO_64
    4'b 0001, // index[65] RV_PLIC_PRIO_65
    4'b 0001, // index[66] RV_PLIC_PRIO_66
    4'b 0001, // index[67] RV_PLIC_PRIO_67
    4'b 0001, // index[68] RV_PLIC_PRIO_68
    4'b 0001, // index[69] RV_PLIC_PRIO_69
    4'b 0001, // index[70] RV_PLIC_PRIO_70
    4'b 0001, // index[71] RV_PLIC_PRIO_71
    4'b 0001, // index[72] RV_PLIC_PRIO_72
    4'b 0001, // index[73] RV_PLIC_PRIO_73
    4'b 0001, // index[74] RV_PLIC_PRIO_74
    4'b 0001, // index[75] RV_PLIC_PRIO_75
    4'b 0001, // index[76] RV_PLIC_PRIO_76
    4'b 0001, // index[77] RV_PLIC_PRIO_77
    4'b 0001, // index[78] RV_PLIC_PRIO_78
    4'b 0001, // index[79] RV_PLIC_PRIO_79
    4'b 0001, // index[80] RV_PLIC_PRIO_80
    4'b 0001, // index[81] RV_PLIC_PRIO_81
    4'b 0001, // index[82] RV_PLIC_PRIO_82
    4'b 0001, // index[83] RV_PLIC_PRIO_83
    4'b 0001, // index[84] RV_PLIC_PRIO_84
    4'b 0001, // index[85] RV_PLIC_PRIO_85
    4'b 0001, // index[86] RV_PLIC_PRIO_86
    4'b 0001, // index[87] RV_PLIC_PRIO_87
    4'b 1111, // index[88] RV_PLIC_IP_0
    4'b 1111, // index[89] RV_PLIC_IP_1
    4'b 0111, // index[90] RV_PLIC_IP_2
    4'b 1111, // index[91] RV_PLIC_IE0_0
    4'b 1111, // index[92] RV_PLIC_IE0_1
    4'b 0111, // index[93] RV_PLIC_IE0_2
    4'b 0001, // index[94] RV_PLIC_THRESHOLD0
    4'b 0001, // index[95] RV_PLIC_CC0
    4'b 0001, // index[96] RV_PLIC_MSIP0
    4'b 0001  // index[97] RV_PLIC_ALERT_TEST
  };

endpackage
