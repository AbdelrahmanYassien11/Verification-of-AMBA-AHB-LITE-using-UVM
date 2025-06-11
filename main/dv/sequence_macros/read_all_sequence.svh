/******************************************************************
 * File: read_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing read operations
 *              multiple times. It extends from the read_once_sequence class
 *              and uses the `read_once_sequence` handle to execute read operations
 *              repeatedly until the FIFO depth is reached.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_all_sequence extends read_once_sequence;
  `uvm_object_utils(read_all_sequence);

  // Handle for the read_once_sequence sequence
  read_once_sequence read_once_sequence_h;

  // Constructor
  function new(string name = "read_all_sequence");
    super.new(name);
  endfunction

  // Pre-body task where setup actions are performed before the main sequence
  task pre_body();
    $display("start of pre_body task");
    super.pre_body();
    // Create an instance of read_once_sequence
    read_once_sequence_h = read_once_sequence::type_id::create("read_once_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  task body();

    // Set the reset flag to ensure that the sequence is executed with reset conditions
    read_once_sequence::reset_flag = 1'b1;
    
    // Repeat the read_once_sequence for FIFO depth + 1 times
    repeat(FIFO_DEPTH+1) begin
      `uvm_do_on(read_once_sequence_h, sequencer_h)
    end
  endtask : body

endclass
