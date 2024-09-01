/******************************************************************
 * File: reset_write_read_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing a 
 *              series of operations including resetting, writing,
 *              and reading data. It extends the base_sequence class
 *              and manages two primary sequences: write_all_sequence
 *              and read_all_sequence.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class reset_write_read_all_sequence extends base_sequence;
  `uvm_object_utils(reset_write_read_all_sequence);

  // Handles for write_all_sequence and read_all_sequence
  protected write_all_sequence write_all_sequence_h;
  protected read_all_sequence read_all_sequence_h;

  // Constructor
  function new(string name = "reset_write_read_all_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Call the pre_body task of the base class
    super.pre_body();

    // Create instances of the write_all_sequence and read_all_sequence
    write_all_sequence_h = write_all_sequence::type_id::create("write_all_sequence_h");
    read_all_sequence_h = read_all_sequence::type_id::create("read_all_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  task body();
    // Start the write_all_sequence on the sequencer
    `uvm_do_on(write_all_sequence_h, sequencer_h)

    // Start the read_all_sequence on the sequencer
    `uvm_do_on(read_all_sequence_h, sequencer_h)
  endtask : body

endclass
