/******************************************************************
 * File: comparator.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11
 * Date: 25/08/2024
 * Description: This class defines a UVM comparator component used
 *              to compare sequence items and report results.
 * 
 * Copyright (c) [Year] [Your Company/Organization]. All Rights Reserved.
 * This file is part of the Asynchronous FiFO project.
 * 

 ******************************************************************/

class comparator extends uvm_component;
  `uvm_component_utils(comparator);

  // Sequence items to be compared
  sequence_item seq_item_actual;
  sequence_item seq_item_expected;

  // Handle for the comparer component
  uvm_comparer comparer_h;

  // Analysis exports to connect to TLM analysis channels
  uvm_analysis_export #(sequence_item) analysis_actual_outputs;
  uvm_analysis_export #(sequence_item) analysis_expected_outputs;

  // TLM analysis FIFOs for storing sequence items
  uvm_tlm_analysis_fifo #(sequence_item) fifo_actual_outputs;
  uvm_tlm_analysis_fifo #(sequence_item) fifo_expected_outputs;

  // Constructor for the comparator component
  function new (string name = "comparator", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase for component creation and initialization
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    // Create FIFOs for actual and expected sequence items
    fifo_expected_outputs = new("fifo_expected_outputs", this);
    fifo_actual_outputs  = new("fifo_actual_outputs", this);

    // Create analysis exports for expected and actual outputs
    analysis_expected_outputs = new("analysis_expected_outputs", this);
    analysis_actual_outputs = new("analysis_actual_outputs", this);

    // Display a message indicating the build phase is complete
    $display("my_comparator build phase");
  endfunction

  // Connect phase for connecting analysis exports to FIFOs
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    // Connect the analysis exports to the respective FIFOs
    analysis_actual_outputs.connect(fifo_actual_outputs.analysis_export);
    analysis_expected_outputs.connect(fifo_expected_outputs.analysis_export);

    // Display a message indicating the connect phase is complete
    $display("my_comparator connect phase");
  endfunction

  // Run phase for performing comparisons
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("COMPARATOR", "RUN PHASE", UVM_HIGH)  
    
      // Get sequence items from FIFOs
      fifo_expected_outputs.get(seq_item_expected);
      `uvm_info("COMPARATOR", {"EXPECTED_SEQ_ITEM RECEIVED: ", 
                      seq_item_expected.convert2string()}, UVM_HIGH)
      fifo_actual_outputs.get(seq_item_actual);
      `uvm_info("COMPARATOR", {"ACTUAL_SEQ_ITEM RECEIVED: ", 
                      seq_item_actual.convert2string()}, UVM_HIGH)

      // Compare the actual and expected sequence items
      if (seq_item_actual.do_compare(seq_item_expected, comparer_h)) begin
        `uvm_info("SCOREBOARD", "PASS", UVM_HIGH)
      end
      else begin
        `uvm_error("SCOREBOARD", "FAIL")
      end
    end
  endtask

endclass : comparator
