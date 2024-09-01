/******************************************************************
 * File: write_once_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a single 
 *              write operation with randomized sequence item values. 
 *              It inherits from `rand_once_sequence` and includes 
 *              functionality to start the reset sequence if needed and 
 *              perform a write operation.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_once_rand_sequence extends rand_once_sequence;
  `uvm_object_utils(write_once_rand_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "write_once_rand_sequence");
    super.new(name);
  endfunction

  // Main task body for executing the write operation
  task body();
    // If reset_flag is not set, start the reset sequence
    if (!reset_flag) begin
      // Create an instance of the reset sequence
      reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
      // Start the reset sequence
      reset_sequence_h.start(m_sequencer);
    end
    
    // Configure the sequence item for the write operation
    seq_item.operation.rand_mode(0); // Set the randomization mode to constrained random
    seq_item.operation = WRITE; // Set the operation type to WRITE
    
    // Call the base class body method to handle further operations
    super.body();
  endtask : body

endclass
