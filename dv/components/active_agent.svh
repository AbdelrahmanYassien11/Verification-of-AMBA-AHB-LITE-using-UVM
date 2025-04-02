/******************************************************************
 * File: comparator.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11
 * Date: 25/12/2024
 * Description: This class defines a UVM agent component used
 *              to drive & read from DUT and report results.
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 *****************************************************************/

class active_agent extends uvm_agent;
  `uvm_component_utils(active_agent);

  // Configuration object for the active agent
  active_agent_config active_agent_config_h;

  // Handles for sequencer, driver, and inputs_monitor components
  sequencer sequencer_h;
  sequencer burst_sequencer_h;
  sequencer runall_sequencer_h;
  driver driver_h;
  inputs_monitor inputs_monitor_h;

  // Analysis port for sequence items
  uvm_analysis_port #(sequence_item) tlm_analysis_port_inputs;

  // Port list for TLM connections (currently unused)
  uvm_port_list list;

  // Virtual interface handle for communicating with the DUT
  virtual inf my_vif;

  // Constructor for the active agent component
  function new (string name = "active_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase for component creation and configuration
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the configuration object from the UVM config database
    if(!uvm_config_db#(active_agent_config)::get(this, "", "active_config", active_agent_config_h)) begin
      `uvm_fatal("active_agent", "Failed to get active_agent_config object");
    end

    // Check if the agent is active based on the configuration
    is_active = active_agent_config_h.get_is_active();

    // Create sequencer and driver if the agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer_h = sequencer::type_id::create("sequencer_h", this);
      burst_sequencer_h = sequencer::type_id::create("burst_sequencer_h", this);
      runall_sequencer_h = sequencer::type_id::create("runall_sequencer_h", this);

      driver_h = driver::type_id::create("driver_h", this);  
    end    

    // Create the inputs_monitor component
    inputs_monitor_h = inputs_monitor::type_id::create("inputs_monitor_h", this);

    // Set the virtual interface for driver and inputs_monitor from the configuration
    uvm_config_db#(virtual inf)::set(this, "driver_h", "my_vif", active_agent_config_h.active_agent_config_my_vif);
    uvm_config_db#(virtual inf)::set(this, "inputs_monitor_h", "my_vif", active_agent_config_h.active_agent_config_my_vif);

    // Create the TLM analysis port
    tlm_analysis_port_inputs = new("tlm_analysis_port_inputs", this);

    // Display message indicating the build phase is complete
    $display("my_active_agent build phase");
  endfunction

  // Connect phase for connecting ports and analysis channels
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the inputs_monitor's TLM analysis port to the TLM analysis port of the agent
    inputs_monitor_h.tlm_analysis_port.connect(tlm_analysis_port_inputs);

    // Connect the driver’s sequence item port to the sequencer’s sequence item export if the agent is active
    if (get_is_active() == UVM_ACTIVE) begin
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
      //driver_h.seq_item_port.connect(runall_sequencer_h.seq_item_export);
    end

    // Display message indicating the connect phase is complete
    $display("my_active_agent connect phase");
  endfunction

  // End of elaboration phase for final setup and checks
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // Display message indicating the end_of_elaboration phase is complete
    $display("my_monitor end_of_elaboration_phase");
  endfunction

  // Run phase for executing the agent's functionality
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // Display message indicating the run phase is active
    $display("my_active_agent run phase");
  endtask

endclass