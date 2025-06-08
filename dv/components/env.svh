/******************************************************************
 * File: env.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines a UVM environment component which
 *              coordinates the different agents, scoreboard, and
 *              coverage components in the testbench. It handles
 *              their configuration, connection, and lifecycle phases.
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class env extends uvm_env;

  `uvm_component_utils(env);

  // Configuration objects for the agents
  env_config env_config_h;
  active_agent_config active_agent_config_h;
  passive_agent_config passive_agent_config_h;

  // Instances of agents and other components
  passive_agent passive_agent_h;
  active_agent active_agent_h;
  scoreboard scoreboard_h;
  coverage coverage_h;

  // List for handling port connections
  uvm_port_list list;

  // Virtual interface to the DUT
  virtual inf my_vif;

  // Constructor for the environment component
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------------
  // Build phase for component creation, initialization & Setters
  //-------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the environment configuration from the config database
    if (!uvm_config_db#(env_config)::get(this, "", "config", env_config_h)) begin
      `uvm_fatal(get_full_name(), "Failed to get env configuration");
    end

    // Create and configure agent configurations
    active_agent_config_h = new(
      .active_agent_config_my_vif(env_config_h.env_config_my_vif),
      .is_active(UVM_ACTIVE)
    );
    passive_agent_config_h = new(
      .passive_agent_config_my_vif(env_config_h.env_config_my_vif),
      .is_passive(UVM_PASSIVE)
    );

    // Set the configuration objects in the config database
    uvm_config_db#(passive_agent_config)::set(this, "passive_agent_h", "config", passive_agent_config_h);
    uvm_config_db#(active_agent_config)::set(this, "active_agent_h", "active_config", active_agent_config_h);


    // Configure virtual interfaces
    uvm_config_db#(virtual inf)::set(this, "coverage_h", "my_vif", my_vif);
    uvm_config_db#(virtual inf)::set(this, "scoreboard_h", "my_vif", my_vif);

    // Create instances of the environment components
    active_agent_h = active_agent::type_id::create("active_agent_h", this);
    passive_agent_h = passive_agent::type_id::create("passive_agent_h", this);
    scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
    coverage_h = coverage::type_id::create("coverage_h", this);

    `uvm_info(get_type_name(), "Build phase completed", UVM_LOW)
  endfunction

  //---------------------------------------------------------
  // Connect Phase to connect the Enviornment TLM Components
  //---------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect analysis ports and exports
    active_agent_h.tlm_analysis_port_inputs.connect(coverage_h.analysis_export);
    active_agent_h.tlm_analysis_port_inputs.connect(scoreboard_h.analysis_export_inputs);
    passive_agent_h.tlm_analysis_port_outputs.connect(scoreboard_h.analysis_export_outputs);

    // reactive_agent_h.tlm_analysis_port_inputs.connect(coverage.analysis_export_inputs);
    // reactive_agent_h.tlm_analysis_port_inputs.connect(scoreboard_h.analysis_export_inputs);

    `uvm_info(get_type_name(), "Connect phase completed", UVM_LOW)
  endfunction

  // End of elaboration phase for reporting connection details
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Set verbosity level for the scoreboard
    scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);

    // Log connections and provided ports/exports
    coverage_h.analysis_export.get_provided_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_inputs.get_provided_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_outputs.get_provided_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    `uvm_info(get_type_name(), "FINISHED GET_PROVIDED_TO", UVM_LOW)

    coverage_h.analysis_export.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_inputs.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_outputs.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    `uvm_info(get_type_name(), "FINISHED GET_CONNECTED_TO", UVM_LOW)

    `uvm_info(get_type_name(), "End of Elaboration phase completed", UVM_LOW)
  endfunction

  // Run phase where the environment executes
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
