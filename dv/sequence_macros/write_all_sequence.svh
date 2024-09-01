/******************************************************************
 * File: write_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for writing data to a FIFO
 *              multiple times. It extends the `write_once_sequence` and
 *              ensures that the write operation is performed repeatedly
 *              for a specified number of cycles.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_all_sequence extends write_once_sequence;
  `uvm_object_utils(write_all_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle for write_once_sequence
  write_once_sequence write_once_sequence_h;

  // Constructor
  function new(string name = "write_all_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    super.pre_body();

    // Create an instance of write_once_sequence
    write_once_sequence_h = write_once_sequence::type_id::create("write_once_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  task body();
    // If reset_flag is not set, execute the reset sequence
    if (!reset_flag)
      `uvm_do_on(reset_sequence_h, sequencer_h)

    // Set the reset flag in the parent sequence
    write_once_sequence::reset_flag = 1'b1;

    // Perform the write operation FIFO_DEPTH+1 times
    repeat(FIFO_DEPTH+1) begin
      `uvm_do_on(write_once_sequence_h, sequencer_h)
    end
  endtask : body

endclass
