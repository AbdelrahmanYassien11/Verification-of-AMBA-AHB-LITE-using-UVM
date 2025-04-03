/******************************************************************
 * File: outputs_monitor.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class extends `uvm_monitor` to monitor the
 *              outputs of a DUT (Device Under Test). It collects
 *              and analyzes sequence items through an analysis port.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class outputs_monitor extends uvm_monitor;
  `uvm_component_utils(outputs_monitor);

  // Virtual interface for DUT interaction
  virtual inf my_vif;
  
  // Analysis port to provide data to other components
  uvm_analysis_port #(sequence_item) tlm_analysis_port;

  // Constructor for the monitor class
  function new (string name = "outputs_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Initializes components and sets up configurations
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual inf)::get(this, "", "my_vif", my_vif)) begin
      `uvm_fatal(get_full_name(), "Error: Virtual interface not found.");
    end

    // Create and initialize the analysis port
    tlm_analysis_port = new("tlm_analysis_port", this);

    `uvm_info("OUTPUTS MONITOR", "Build phase completed", UVM_LOW)
  endfunction

  // Connect phase: Establish connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Link the monitor with the virtual interface
    my_vif.outputs_monitor_h = this;

    `uvm_info("OUTPUTS MONITOR", "Connect phase completed", UVM_LOW)
  endfunction

  // End of elaboration phase: Finalize and check connections
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Optionally, you can use these lines to check connections
    // tlm_analysis_port.get_connected_to(list);
    // tlm_analysis_port.get_provided_to(list);

    `uvm_info("OUTPUTS MONITOR", "End of Elaboration phase completed", UVM_LOW)
  endfunction

  // Virtual function to write data to the monitor
  virtual function void write_to_monitor (sequence_item outputs_req);
  
    // Write the sequence item to the analysis port
    tlm_analysis_port.write(outputs_req);

    `uvm_info(get_full_name(),{"OUTPUTS SENT TO THE COMPARATOR", outputs_req.output2string()},UVM_HIGH)

  endfunction : write_to_monitor


endclass
