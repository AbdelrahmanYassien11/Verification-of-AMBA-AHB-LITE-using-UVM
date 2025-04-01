/******************************************************************
 * File: comparator.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11
 * Date: 25/12/2024
 * Description: This class defines a UVM comparator component used
 *              to compare sequence items and report results.
 * 
 * Copyright (c) [Year] [Your Company/Organization]. All Rights Reserved.
 * This file is part of the Asynchronous FiFO project.
 * 

 ******************************************************************/

class comparator extends uvm_component;
  `uvm_component_utils(comparator);

  predictor predictor_h;

  // Sequence items to be compared
  sequence_item seq_item_actual;
  sequence_item seq_item_expected;
  sequence_item seq_item_expected_unchanged;
  sequence_item seq_item_expected_reset;

  // Handle for the comparer component
  uvm_comparer comparer_h;

  // Analysis exports to connect to TLM analysis channels
  uvm_analysis_export #(sequence_item) analysis_actual_outputs;
  uvm_analysis_export #(sequence_item) analysis_expected_outputs;
  uvm_analysis_export #(sequence_item) analysis_expected_outputs_cleared;

  // TLM analysis FIFOs for storing sequence items
  uvm_tlm_analysis_fifo #(sequence_item) fifo_actual_outputs;
  uvm_tlm_analysis_fifo #(sequence_item) fifo_expected_outputs;
  uvm_tlm_analysis_fifo #(sequence_item) fifo_expected_outputs_cleared;

  int first_resset_shield;

  bit more_than_one_reset;

  // Constructor for the comparator component
  function new (string name = "comparator", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase for component creation and initialization
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    // seq_item_actual = sequence_item::type_id::create("seq_item_actual");
    // seq_item_expected = sequence_item::type_id::create("seq_item_expected");
    seq_item_expected_unchanged = sequence_item::type_id::create("seq_item_expected_unchanged");
    //seq_item_expected_unchanged = sequence_item::type_id::create("seq_item_expected_unchanged");


    // Create FIFOs for actual and expected sequence items
    fifo_expected_outputs = new("fifo_expected_outputs", this);
    fifo_actual_outputs  = new("fifo_actual_outputs", this);

    fifo_expected_outputs_cleared = new("fifo_expected_outputs_cleared", this);

    // Create analysis exports for expected and actual outputs
    analysis_expected_outputs = new("analysis_expected_outputs", this);
    analysis_actual_outputs = new("analysis_actual_outputs", this);

    analysis_expected_outputs_cleared = new("analysis_expected_outputs_cleared", this);

    // Display a message indicating the build phase is complete
    $display("my_comparator build phase");
  endfunction

  // Connect phase for connecting analysis exports to FIFOs
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    // Connect the analysis exports to the respective FIFOs
    analysis_actual_outputs.connect(fifo_actual_outputs.analysis_export);
    analysis_expected_outputs.connect(fifo_expected_outputs.analysis_export);
    analysis_expected_outputs_cleared.connect(fifo_expected_outputs_cleared.analysis_export);

    // Display a message indicating the connect phase is complete
    $display("my_comparator connect phase");
  endfunction

  // Run phase for performing comparisons
  task run_phase(uvm_phase phase);
    forever begin
      `uvm_info("COMPARATOR", "RUN PHASE", UVM_HIGH)
    seq_item_expected = sequence_item::type_id::create("seq_item_expected");
      // Get sequence items from FIFOs
      fifo_expected_outputs.get(seq_item_expected);
      `uvm_info("COMPARATOR", {"EXPECTED_SEQ_ITEM RECEIVED: ", 
                      seq_item_expected.convert2string()}, UVM_HIGH)

      clearing_fifo();

      fifo_actual_outputs.get(seq_item_actual);
      fifo_expected_outputs_cleared.try_get(seq_item_expected_reset);
      `uvm_info("COMPARATOR", {"ACTUAL_SEQ_ITEM RECEIVED: ", 
                seq_item_actual.convert2string()}, UVM_HIGH)
      // Compare the actual and expected sequence items
      if (seq_item_actual.do_compare(seq_item_expected, comparer_h)) begin
        `uvm_info("SCOREBOARD", "PASS", UVM_HIGH)
      end
      else begin
        `uvm_error("SCOREBOARD", "FAIL")
        predictor_h.display_subordinates(seq_item_expected.HADDR, seq_item_expected.HSEL);
      end
      sequence_item::COMPARATOR_transaction_counter = sequence_item::COMPARATOR_transaction_counter + 1;
    end
  endtask

  task clearing_fifo();
    if(first_resset_shield >= 1) begin
      do begin
        //$display("DEAR1 : %0t",$time());
        #1;
        if(fifo_expected_outputs_cleared.used() > 0) begin
                 // $display("DEAR2 : %0t",$time());
          // for(int i = 0; i < fifo_expected_outputs.used(); i++)begin
            int to_be_decremented = fifo_expected_outputs.used();
            //$display("DEAR3 : %0t",$time());
            if(fifo_expected_outputs_cleared.try_get(seq_item_expected_reset)) begin
              //$display("DEAR4 : %0t",$time());
              if(~seq_item_expected_reset.HRESETn && ~more_than_one_reset) begin
                more_than_one_reset = 1;
                $display("TIME : %0t fifo_expected_outputs.used(): %0d & to_be_decremented %0d", $time(), fifo_expected_outputs.used(), to_be_decremented);
                fifo_expected_outputs.flush();
                fifo_expected_outputs_cleared.flush();
                sequence_item::PREDICTOR_transaction_counter = sequence_item::PREDICTOR_transaction_counter - to_be_decremented;
                seq_item_expected.HRDATA  = 0;
                seq_item_expected.HRESP   = 0;
                seq_item_expected.HREADY  = 1;
                $display("TIME : %0t fifo_expected_outputs.used(): %0d & to_be_decremented %0d", $time(), fifo_expected_outputs.used(), to_be_decremented);
                $display("TIME : %0t FIXING EXPECTED_SEQ_ITEM", $time());
              end
              else if (seq_item_expected_reset.HRESETn && more_than_one_reset) begin
                  more_than_one_reset = 0;
              end
            end
          //end
        end
      end while((fifo_actual_outputs.used() == 0) && (sequence_item::COMPARATOR_transaction_counter != sequence_item::PREDICTOR_transaction_counter));
    end
    else begin
      first_resset_shield = first_resset_shield + 1;
    end
  endtask : clearing_fifo

endclass : comparator
