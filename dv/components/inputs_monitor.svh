/******************************************************************
 * File: inputs_monitor.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
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
  // virtual function void write_to_monitor ( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
  //                       input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
  //                       input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
  //                       input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
  //                       input HWRITE_e iWRITE_op, input HTRANS_e iTRANS_op,
  //                       input HBURST_e iBURST_op, input HSIZE_e iSIZE_op
  // );

  //     // Create a new sequence item and populate it with data
  //     sequence_item seq_item;
  //     seq_item = new("seq_item");
  //     seq_item.HRESETn    = iHRESETn;
  //     seq_item.HWRITE     = iHWRITE;
  //     seq_item.HTRANS     = iHTRANS;
  //     seq_item.HSIZE      = iHSIZE;
  //     seq_item.HBURST     = iHBURST;
  //     seq_item.HPROT      = iHPROT;                
  //     seq_item.HADDR      = iHADDR;
  //     seq_item.HWDATA     = iHWDATA;
      
  //     seq_item.RESET_op   = iRESET_op;
  //     seq_item.WRITE_op   = iWRITE_op;
  //     seq_item.TRANS_op   = iTRANS_op;
  //     seq_item.BURST_op   = iBURST_op;          
  //     seq_item.SIZE_op    = iSIZE_op;

  //   // Write the sequence item to the analysis port
  //   tlm_analysis_port.write(seq_item);

  // endfunction : write_to_monitor

  virtual function void write_to_monitor (sequence_item input_req);

    // Write the sequence item to the analysis port
    tlm_analysis_port.write(input_req);
    `uvm_info(get_full_name(),"INPUTS SENT TO THE PREDICTOR",UVM_LOW)

  endfunction : write_to_monitor

endclass
