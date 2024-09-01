/******************************************************************
 * File: inputs_monitor.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class extends `uvm_monitor` to monitor the
 *              inputs of a DUT (Device Under Test). It provides
 *              functionality for collecting and analyzing sequence
 *              items through an analysis port.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class inputs_monitor extends uvm_monitor;
  `uvm_component_utils(inputs_monitor);

  // Virtual interface for DUT interaction
  virtual inf my_vif;

  // Analysis port to provide data to other components
  uvm_analysis_port #(sequence_item) tlm_analysis_port;

  // Constructor for the monitor class
  function new (string name = "inputs_monitor", uvm_component parent);
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

    $display("Inputs monitor build phase complete.");
  endfunction

  // Connect phase: Establish connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Link the monitor with the virtual interface
    my_vif.inputs_monitor_h = this;

    $display("Inputs monitor connect phase complete.");
  endfunction

  // End of elaboration phase: Finalize and check connections
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Optionally, you can use these lines to check connections
    // tlm_analysis_port.get_connected_to(list);
    // tlm_analysis_port.get_provided_to(list);

    $display("Inputs monitor end of elaboration phase complete.");
  endfunction

  // Virtual function to write data to the monitor
  virtual function void write_to_monitor (
      input bit irrst_n, 
      input bit iwrst_n, 
      input bit [FIFO_WIDTH-1:0] idata_in, 
      input bit iw_en, 
      input bit ir_en
  );

    // Create a new sequence item and populate it with data
    sequence_item seq_item;
    seq_item = new("seq_item");

    seq_item.rrst_n = irrst_n;
    seq_item.wrst_n = iwrst_n;
    seq_item.data_in = idata_in;
    seq_item.w_en = iw_en;
    seq_item.r_en = ir_en;

    // Write the sequence item to the analysis port
    tlm_analysis_port.write(seq_item);

  endfunction : write_to_monitor

endclass
