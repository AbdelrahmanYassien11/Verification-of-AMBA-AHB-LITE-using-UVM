/******************************************************************
 * File: read_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing multiple 
 *              read operations on the FIFO. It inherits from 
 *              `read_once_sequence` and is responsible for reading 
 *              from the FIFO until it is empty or the FIFO depth is 
 *              reached.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_all_sequence extends read_once_sequence;
  `uvm_object_utils(read_all_sequence);

  // Handle for the read_once_sequence object
  read_once_sequence read_once_sequence_h;

  // Constructor
  function new(string name = "read_all_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    
    // Call the parent class's pre_body task
    super.pre_body();
    
    // Create a new instance of read_once_sequence
    read_once_sequence_h = read_once_sequence::type_id::create("read_once_sequence_h");
  endtask : pre_body

  // Main task body to perform multiple read operations
  task body();
    // Set the reset_flag to 1'b1 to ensure the reset condition is handled
    read_once_sequence::reset_flag = 1'b1;

    // Repeat the read operation for the number of times specified by FIFO_DEPTH+1
    repeat(FIFO_DEPTH+1) begin
      // Start the read_once_sequence for each read operation
      read_once_sequence_h.start(m_sequencer);
    end
  endtask : body

endclass
