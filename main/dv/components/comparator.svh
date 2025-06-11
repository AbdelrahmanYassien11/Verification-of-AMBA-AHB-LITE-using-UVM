/******************************************************************
 * File: comparator.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11
 * Date: 25/12/2024
 * Description: This class defines a UVM comparator component used
 *              to compare sequence items and report results.
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class comparator extends uvm_component;
  `uvm_component_utils(comparator);

 // A predictor instance to debug predictor ROMs when a fail occurs or during resets.
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

  //flag and counter used in controlling clearing the fifo
  int first_resset_shield;
  bit more_than_one_reset;

  //------------------------------------------
  // Constructor for the comparator component
  //------------------------------------------
  function new (string name = "comparator", uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------------
  // Build phase for component creation, initialization & Setters
  //-------------------------------------------------------------
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    seq_item_expected_unchanged = sequence_item::type_id::create("seq_item_expected_unchanged");

    // Create FIFOs for actual and expected sequence items
    fifo_expected_outputs = new("fifo_expected_outputs", this);
    fifo_actual_outputs  = new("fifo_actual_outputs", this);

    fifo_expected_outputs_cleared = new("fifo_expected_outputs_cleared", this);

    // Create analysis exports for expected and actual outputs
    analysis_expected_outputs = new("analysis_expected_outputs", this);
    analysis_actual_outputs = new("analysis_actual_outputs", this);

    analysis_expected_outputs_cleared = new("analysis_expected_outputs_cleared", this);

    // Display a message indicating the build phase is complete
    `uvm_info("COMPARATOR", "Build phase", UVM_LOW)
  endfunction

  //---------------------------------------------------------
  // Connect Phase to connect the Enviornment TLM Components
  //---------------------------------------------------------
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    // Connect the analysis exports to the respective FIFOs
    analysis_actual_outputs.connect(fifo_actual_outputs.analysis_export);
    analysis_expected_outputs.connect(fifo_expected_outputs.analysis_export);
    analysis_expected_outputs_cleared.connect(fifo_expected_outputs_cleared.analysis_export);

    // Display a message indicating the connect phase is complete
    `uvm_info(get_type_name(), "Connect phase completed", UVM_LOW)
  endfunction

  //-------------------------------------------------------
  // Run phase for comparing expected & actual outputs
  //------------------------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Run phase completed", UVM_LOW)  
    forever begin

    //creating the seq item expected at each loop so 
    seq_item_expected = sequence_item::type_id::create("seq_item_expected");

      // Get the expected sequence item from expected sequence item fifo
      fifo_expected_outputs.get(seq_item_expected);
      `uvm_info(get_type_name(), {"EXPECTED_SEQ_ITEM RECEIVED: ", 
                      seq_item_expected.convert2string()}, UVM_HIGH)

      // looping on the expected seq item fifo to clear it if a reset occurs
      clearing_fifo();

      // Get the actual sequence item from actual sequence item fifo
      fifo_actual_outputs.get(seq_item_actual);
      fifo_expected_outputs_cleared.try_get(seq_item_expected_reset);
      `uvm_info(get_type_name(), {"ACTUAL_SEQ_ITEM RECEIVED: ", 
                seq_item_actual.convert2string()}, UVM_HIGH)

      // Compare the actual and expected sequence items
      if (seq_item_actual.do_compare(seq_item_expected, comparer_h)) begin
        `uvm_info(get_type_name(), "PASS", UVM_HIGH)
      end
      else begin
        `uvm_error(get_type_name(), "FAIL")
        predictor_h.display_subordinates(seq_item_expected.HADDR, seq_item_expected.HSEL);
      end
      sequence_item::COMPARATOR_transaction_counter = sequence_item::COMPARATOR_transaction_counter + 1;
    end
  endtask

  task clearing_fifo();
    if(first_resset_shield >= 1) begin
      do begin
        #1;
        if(fifo_expected_outputs_cleared.used() > 0) begin
            int to_be_decremented = fifo_expected_outputs.used();
            if(fifo_expected_outputs_cleared.try_get(seq_item_expected_reset)) begin
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
