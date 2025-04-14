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

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "READ_SINGLE_sequence");
    super.new(name);
  endfunction

  // Preparation task before the main sequence body is executed
  task pre_body();
    // Display a message indicating the start of the pre_body task
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
    super.pre_body();
    // Create a new reset_sequence object for handling resets
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body to perform the read operation
  task body();
    super.body();
    // Log information about the read operation
    `uvm_info("READ_SINGLE_SEQUENCE: ", "STARTING", UVM_HIGH);

    // If reset_flag is not set, start the reset sequence
    if (~reset_flag)
      reset_sequence_h.start(sequencer_h);

    do_burst(SINGLE, READ, NONSEQ);

  endtask : body

endclass
