// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class i2c_agent_cfg extends dv_base_agent_cfg;
  // this parameters can be set by test to slow down the agent's responses
  int host_latency_cycles = 0;
  int device_latency_cycles = 0;

  i2c_target_addr_mode_e target_addr_mode = Addr7BitMode;

  timing_cfg_t    timing_cfg;
  bit host_stretch_test_mode = 0;

  uvm_event got_nack;

  virtual i2c_if  vif;

  // Performance Monitoring Variables
  uvm_event start_perf_monitor, stop_perf_monitor;
  time period_q[$];

  bit     host_scl_start;
  bit     host_scl_stop;
  bit     host_scl_force_high;
  bit     host_scl_force_low;

  // In i2c test, between every transaction, assuming a new timing
  // parameter is programmed. This means during a transaction,
  // test should not update timing parameter.
  // This variable indicates target DUT receives the end of the transaction
  // and allow tb to program a new timing parameter.
  // TODO(#23920) Remove this.
  bit     got_stop = 0;

  int     rcvd_rd_byte = 0; // Increment each time the agent reads a byte.

  // this variables can be configured from host test
  uint i2c_host_min_data_rw = 1;
  uint i2c_host_max_data_rw = 10;

  // If 'host_scl_pause' is enabled, 'host_scl_pause_cyc' should be set to non zero value.
  bit     host_scl_pause_en = 0;
  bit     host_scl_pause_req = 0;
  bit     host_scl_pause_ack = 0;
  bit     host_scl_pause = 0;
  int     host_scl_pause_cyc = 0;

  // ack-stop test mode
  // This mode is used to generate stimulus that expects the assertion of the 'unexp_stop' irq
  bit     allow_ack_stop = 0; // Enable the test mode, including generating the modified stimulus
  bit     ack_stop_det = 0; // The monitor asserts this when an ack-then-stop stimulus has occurred

  ////////////////
  // Addressing //
  ////////////////

  // Store the DUT's programmed target addresses
  bit [6:0] target_addr0;
  bit [6:0] target_addr1;

  // i2c_target_bad_addr //////////////////////
  //
  // Store history of good and bad read target addresses ( '1' = good, '0' = bad )
  // This is used by the env's scoreboard to adjust its expectations, and also
  // to adjust the stimulus for reads, so we don't put data into the TXFIFO that will
  // never be read out.
  // Note. that this queue is only queried immediately before writing to the TXFIFO, and we only
  // push new values to the queue when the monitor decodes the address.
  // TODO(#23920) Remove knowledge of the DUT Addresses from the i2c_agent
  bit       read_addr_q[$];
  /////////////////////////////////////////////

  ////////////
  // Resets //
  ////////////

  // reset driver only without resetting dut
  bit       driver_rst = 0;
  // reset monitor only without resetting dut
  bit       monitor_rst = 0;

  `uvm_object_utils_begin(i2c_agent_cfg)
    `uvm_field_int(en_monitor,                                UVM_DEFAULT)
    `uvm_field_enum(i2c_target_addr_mode_e, target_addr_mode, UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSetupStart,                    UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tHoldStart,                     UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tClockStart,                    UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tClockLow,                      UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSetupBit,                      UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tClockPulse,                    UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tHoldBit,                       UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tClockStop,                     UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSetupStop,                     UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tHoldStop,                      UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tTimeOut,                       UVM_DEFAULT)
    `uvm_field_int(timing_cfg.enbTimeOut,                     UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tStretchHostClock,              UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSdaUnstable,                   UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSdaInterference,               UVM_DEFAULT)
    `uvm_field_int(timing_cfg.tSclInterference,               UVM_DEFAULT)

    `uvm_field_int(i2c_host_min_data_rw,                      UVM_DEFAULT)
    `uvm_field_int(i2c_host_max_data_rw,                      UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
    got_nack = new("got_nack");
    start_perf_monitor = new("start_perf_monitor");
    stop_perf_monitor = new("stop_perf_monitor");
  endfunction


  // TODO(#23920) Remove knowledge of the DUT Addresses from the i2c_agent
  function bit is_target_addr(bit [6:0] addr);
    return (addr == target_addr0 || addr == target_addr1);
  endfunction


endclass : i2c_agent_cfg
