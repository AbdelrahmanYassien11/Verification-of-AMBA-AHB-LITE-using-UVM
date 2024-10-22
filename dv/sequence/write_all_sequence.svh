/******************************************************************
 * File: write_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs multiple 
 *              write operations in a row. It inherits from 
 *              `write_once_sequence` and ensures that a reset sequence 
 *              is initiated if necessary before performing a series 
 *              of write operations.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_all_sequence extends write_once_sequence;
  `uvm_object_utils(write_all_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the write_once_sequence instance
  write_once_sequence write_once_sequence_h;

  // Constructor
  function new(string name = "write_all_sequence");
    super.new(name);
  endfunction

  // Pre-body task to initialize the write_once_sequence handle
  task pre_body();
    $display("start of pre_body task");
    super.pre_body();
    // Create an instance of the write_once_sequence
    write_once_sequence_h = write_once_sequence::type_id::create("write_once_sequence_h");
  endtask : pre_body

  // Main task body for performing multiple write operations
  task body();
    // If reset_flag is not set, start the reset sequence
    if (!reset_flag) begin
      // Start the reset sequence
      reset_sequence_h.start(m_sequencer);
    end
    
    // Set the reset_flag in the write_once_sequence base class
    write_once_sequence::reset_flag = 1'b1;
    
    // Perform a series of write operations
    repeat(FIFO_DEPTH+1) begin
      write_once_sequence_h.start(m_sequencer);
    end
  endtask : body

endclass
