/******************************************************************
 * File: READ_SINGLE_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing a
 *              single read operation on the FIFO. It handles the
 *              necessary reset sequences and sets the appropriate
 *              control signals for a read operation.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class READ_SINGLE_sequence extends base_sequence;
  `uvm_object_utils(READ_SINGLE_sequence);

  // Static flag to determine if a reset is required
  static bit reset_flag;
  static bit last_test;

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "READ_SINGLE_sequence");
    super.new(name);
  endfunction

  // Preparation task before the main sequence body is executed
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    super.pre_body();
    // Create a new reset_sequence object for handling resets
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body to perform the read operation
  task body();
    super.body();
    // Log information about the read operation
    `uvm_info("READ_SINGLE_SEQUENCE: ", "STARTING", UVM_HIGH);

    reset_sequence::last_test = 1'b1;

    // If reset_flag is not set, start the reset sequence
    if (~reset_flag)
      reset_sequence_h.start(sequencer_h);

    if(~last_test)
      seq_item.last_item = 1'b1;

    // Start the sequence item
    start_item(seq_item);

    // Configure the sequence item for the write operation
    // Randomize the sequence item
    assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == READ; TRANS_op == NONSEQ; BURST_op == SINGLE;});

    // Finish the sequence item
    finish_item(seq_item);

  endtask : body

endclass
