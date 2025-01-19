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
  event finished;
  bit execute_idle;

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
      check_response();
    join_none

  endtask : body

  task check_response();
    forever begin
      sequence_item req;
      // Wait for the data phase to complete
      get_response(req);
      ///`uvm_info("SEQUENCE", $sformatf("RESPONSE_RETRIEVED: ", req.output2string()), UVM_LOW)
      if (req.HREADY == NOT_READY) begin
        // wait(finished.triggered());
        //`uvm_info("SEQUENCE NOT_READY: ", req.output2string(), UVM_LOW)
        execute_idle = 1;
        //sequencer_h.stop_sequences();
        // start_item(seq_item); // Start the sequence item

        //   // Set the operation type to READ
        //   seq_item.RESET_op = WORKING;
        //   seq_item.WRITE_op = READ;
        //   seq_item.TRANS_op = IDLE;
        //   seq_item.BURST_op = SINGLE;
        //   seq_item.SIZE_op  = BYTE;

        //   // Randomize the sequence item
        //   assert(seq_item.randomize());

        // finish_item(seq_item);

      end
    end
  endtask: check_response

endclass : base_sequence
