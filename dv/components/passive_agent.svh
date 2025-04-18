/******************************************************************
 * File: passive_agent.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class extends `uvm_agent` to create a passive
 *              agent in the UVM testbench. The agent is responsible
 *              for sequencing and driving stimulus, as well as monitoring
 *              outputs. It configures and connects its components 
 *              based on its active/passive state.
 *
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class passive_agent extends uvm_agent;
  `uvm_component_utils(passive_agent);

  // Configuration object for the passive agent
  passive_agent_config passive_agent_config_h;

  // Components for the passive agent
  sequencer sequencer_h;
  driver driver_h;
  outputs_monitor outputs_monitor_h;

  // Analysis port to export sequence items
  uvm_analysis_port #(sequence_item) tlm_analysis_port_outputs;

  // Port list for connecting components
  uvm_port_list list;

  // Virtual interface for interacting with the DUT
  virtual inf my_vif;

  // Constructor for the passive agent
  function new (string name = "passive_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------------
  // Build phase for component creation, initialization & Setters
  //-------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the passive agent configuration from the config database
    if (!uvm_config_db#(passive_agent_config)::get(this, "", "config", passive_agent_config_h)) begin
      `uvm_fatal("passive_agent", "Failed to get passive_agent_config object");
    end

    // Check if the agent is active or passive
    is_active = passive_agent_config_h.get_is_passive();

    // Create sequencer and driver if the agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer_h = sequencer::type_id::create("sequencer_h", this);
      driver_h = driver::type_id::create("driver_h", this);
    end

    // Create the outputs monitor
    outputs_monitor_h = outputs_monitor::type_id::create("outputs_monitor_h", this);

    // Set virtual interface in the configuration database for driver and monitor
    uvm_config_db#(virtual inf)::set(this, "driver_h", "my_vif", passive_agent_config_h.passive_agent_config_my_vif);
    uvm_config_db#(virtual inf)::set(this, "outputs_monitor_h", "my_vif", passive_agent_config_h.passive_agent_config_my_vif);

    // Initialize the analysis port
    tlm_analysis_port_outputs = new("tlm_analysis_port_outputs", this);

    `uvm_info("PASSIVE AGENT", "Build phase", UVM_LOW)
  endfunction

  //---------------------------------------------------------
  // Connect Phase to connect the Enviornment TLM Components
  //---------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the outputs monitor to the analysis port
    outputs_monitor_h.tlm_analysis_port.connect(tlm_analysis_port_outputs);

    // Connect the driver to the sequencer if the agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
    end

    `uvm_info("PASSIVE AGENT", "Connect phase", UVM_LOW)
  endfunction

  // End of elaboration phase: Check and display connection status
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Optionally, you can use these lines to check connections
    // tlm_analysis_port_outputs.get_connected_to(list);
    // tlm_analysis_port_outputs.get_provided_to(list);

    `uvm_info("PASSIVE AGENT", "End of Elaboration phase", UVM_LOW)
  endfunction

  // Run phase: Executes the agent's operations
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("PASSIVE AGENT", "Run phase", UVM_LOW)
  endtask

endclass
