/******************************************************************
 * File: env.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM environment component which
 *              coordinates the different agents, scoreboard, and
 *              coverage components in the testbench. It handles
 *              their configuration, connection, and lifecycle phases.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

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
  function new(string name = "environment", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase for component setup and initialization
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

    // Create instances of the agents and components
    active_agent_h = active_agent::type_id::create("active_agent_h", this);
    passive_agent_h = passive_agent::type_id::create("passive_agent_h", this);
    scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
    coverage_h = coverage::type_id::create("coverage_h", this);

    $display("env build phase");
  endfunction

  // Connect phase for setting up connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect analysis ports and exports
    passive_agent_h.tlm_analysis_port_outputs.connect(coverage_h.analysis_export);
    active_agent_h.tlm_analysis_port_inputs.connect(scoreboard_h.analysis_export_inputs);
    passive_agent_h.tlm_analysis_port_outputs.connect(scoreboard_h.analysis_export_outputs);

    $display("env connect phase");
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
    $display("FINISHED GET_PROVIDED_TO");

    coverage_h.analysis_export.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_inputs.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    scoreboard_h.analysis_export_outputs.get_connected_to(list);
    `uvm_info(get_name(), $sformatf("%p", list), UVM_LOW);
    $display("my_monitor end_of_elaboration_phase");
  endfunction

  // Run phase where the environment executes
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    $display("env run phase");
  endtask

endclass