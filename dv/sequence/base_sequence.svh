/******************************************************************
 * File: base_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class serves as a base class for UVM sequences.
 *              It provides common functionality and should be 
 *              extended by other sequence classes. It includes
 *              basic methods for initialization and sequence execution.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class base_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(base_sequence)

  // Handle for the sequence item used in this sequence
  sequence_item seq_item;
  sequencer sequencer_h;
  sequencer burst_sequencer_h;
  sequencer runall_sequencer_h;


  // Constructor
  function new(string name = "base_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    // Create a new instance of the sequence item
    seq_item = sequence_item::type_id::create("seq_item");
  endtask : pre_body



  // Main task body, to be overridden by derived classes
  task body();
    // Report an error if the base_sequence is used directly
    // $fatal(1, "You cannot use base directly. You must override it");
    fork
      ccheck_response();
    join_none

  endtask : body

  task ccheck_response();
    forever begin
      sequence_item rsp;
      // Wait for the data phase to complete
      get_response(rsp);
      //`uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)

      `uvm_info("SEQUENCE", {"RESPONSE_RETRIEVED: ", rsp.output2string()}, UVM_LOW)

      if (rsp.HREADY == NOT_READY && rsp.HRESP == ERROR) begin
        $display("%0t ERROR DETECTED",$time());
        seq_item.ERROR_ON_EXECUTE_IDLE = 1;
      end
    end
  endtask : ccheck_response



endclass : base_sequence
