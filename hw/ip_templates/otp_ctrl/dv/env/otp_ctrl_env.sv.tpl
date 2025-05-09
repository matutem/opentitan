// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class otp_ctrl_env #(
      type CFG_T = otp_ctrl_env_cfg,
      type COV_T = otp_ctrl_env_cov,
      type VIRTUAL_SEQUENCER_T = otp_ctrl_virtual_sequencer,
      type SCOREBOARD_T = otp_ctrl_scoreboard
    )
  extends cip_base_env #(
    .CFG_T              (CFG_T),
    .COV_T              (COV_T),
    .VIRTUAL_SEQUENCER_T(VIRTUAL_SEQUENCER_T),
    .SCOREBOARD_T       (SCOREBOARD_T)
  );
  `uvm_component_param_utils(otp_ctrl_env #(CFG_T, COV_T, VIRTUAL_SEQUENCER_T, SCOREBOARD_T))

  `uvm_component_new

  push_pull_agent#(.DeviceDataWidth(SRAM_DATA_SIZE))  m_sram_pull_agent[NumSramKeyReqSlots];
  push_pull_agent#(.DeviceDataWidth(OTBN_DATA_SIZE))  m_otbn_pull_agent;
% if enable_flash_key:
  push_pull_agent#(.DeviceDataWidth(FLASH_DATA_SIZE)) m_flash_addr_pull_agent;
  push_pull_agent#(.DeviceDataWidth(FLASH_DATA_SIZE)) m_flash_data_pull_agent;
% endif
  push_pull_agent#(.DeviceDataWidth(1), .HostDataWidth(LC_PROG_DATA_SIZE)) m_lc_prog_pull_agent;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // build sram-otp pull agent
    for (int i = 0; i < NumSramKeyReqSlots; i++) begin
      string sram_agent_name = $sformatf("m_sram_pull_agent[%0d]", i);
      m_sram_pull_agent[i] = push_pull_agent#(.DeviceDataWidth(SRAM_DATA_SIZE))::type_id::create(
                             sram_agent_name, this);
      uvm_config_db#(push_pull_agent_cfg#(.DeviceDataWidth(SRAM_DATA_SIZE)))::set(this,
                     $sformatf("%0s*", sram_agent_name), "cfg", cfg.m_sram_pull_agent_cfg[i]);
    end

    // build otbn-otp pull agent
    m_otbn_pull_agent = push_pull_agent#(.DeviceDataWidth(OTBN_DATA_SIZE))::type_id::create(
        "m_otbn_pull_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.DeviceDataWidth(OTBN_DATA_SIZE)))::set(
        this, "m_otbn_pull_agent", "cfg", cfg.m_otbn_pull_agent_cfg);
% if enable_flash_key:

    // build flash-otp pull agent
    m_flash_addr_pull_agent = push_pull_agent#(.DeviceDataWidth(FLASH_DATA_SIZE))::type_id::create(
        "m_flash_addr_pull_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.DeviceDataWidth(FLASH_DATA_SIZE)))::set(
        this, "m_flash_addr_pull_agent", "cfg", cfg.m_flash_addr_pull_agent_cfg);
    m_flash_data_pull_agent = push_pull_agent#(.DeviceDataWidth(FLASH_DATA_SIZE))::type_id::create(
        "m_flash_data_pull_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.DeviceDataWidth(FLASH_DATA_SIZE)))::set(
        this, "m_flash_data_pull_agent", "cfg", cfg.m_flash_data_pull_agent_cfg);
% endif

    // build lc-otp program pull agent
    m_lc_prog_pull_agent = push_pull_agent#(.HostDataWidth(LC_PROG_DATA_SIZE), .DeviceDataWidth(1))
        ::type_id::create("m_lc_prog_pull_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.HostDataWidth(LC_PROG_DATA_SIZE), .DeviceDataWidth(1)))::
        set(this, "m_lc_prog_pull_agent", "cfg", cfg.m_lc_prog_pull_agent_cfg);

    // config mem virtual interface
    if (!uvm_config_db#(mem_bkdr_util)::get(this, "", "mem_bkdr_util", cfg.mem_bkdr_util_h)) begin
      `uvm_fatal(`gfn, "failed to get mem_bkdr_util from uvm_config_db")
    end

    // config otp_ctrl output data virtual interface
    if (!uvm_config_db#(otp_ctrl_vif)::get(this, "", "otp_ctrl_vif", cfg.otp_ctrl_vif)) begin
      `uvm_fatal(`gfn, "failed to get otp_ctrl_vif from uvm_config_db")
    end

    // Check if `NumPart` constant is assigned to the correct value.
    `DV_CHECK(NumPart == (LifeCycleIdx + 1))

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect SRAM sequencer and analysis ports
    for (int i = 0; i < NumSramKeyReqSlots; i++) begin
      virtual_sequencer.sram_pull_sequencer_h[i] = m_sram_pull_agent[i].sequencer;
      if (cfg.en_scb) begin
        m_sram_pull_agent[i].monitor.analysis_port.connect(
            scoreboard.sram_fifos[i].analysis_export);
      end
    end

    virtual_sequencer.otbn_pull_sequencer_h       = m_otbn_pull_agent.sequencer;
  % if enable_flash_key:
    virtual_sequencer.flash_addr_pull_sequencer_h = m_flash_addr_pull_agent.sequencer;
    virtual_sequencer.flash_data_pull_sequencer_h = m_flash_data_pull_agent.sequencer;
  % endif
    virtual_sequencer.lc_prog_pull_sequencer_h    = m_lc_prog_pull_agent.sequencer;

    if (cfg.en_scb) begin
      m_otbn_pull_agent.monitor.analysis_port.connect(scoreboard.otbn_fifo.analysis_export);
    % if enable_flash_key:
      m_flash_addr_pull_agent.monitor.analysis_port.connect(
          scoreboard.flash_addr_fifo.analysis_export);
      m_flash_data_pull_agent.monitor.analysis_port.connect(
          scoreboard.flash_data_fifo.analysis_export);
    % endif
      m_lc_prog_pull_agent.monitor.analysis_port.connect(scoreboard.lc_prog_fifo.analysis_export);
    end

    // connect the DUT cfg instance to the handle in the otp_ctrl_vif
    this.cfg.otp_ctrl_vif.dut_cfg = this.cfg.dut_cfg;
  endfunction

endclass
