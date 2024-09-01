/******************************************************************
 * File: write_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a write 
 *              operation to the FIFO once. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a write 
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_once_sequence extends base_sequence;
  `uvm_object_utils(write_once_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "write_once_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    // If reset_flag is not set, start the reset sequence
    if (!reset_flag)
      reset_sequence_h.start(m_sequencer);

    // Configure the sequence item for the write operation
    seq_item.operation.rand_mode(0); // Set the randomization mode to constrained random
    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.operation = WRITE;
    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing
    seq_item.rrst_n = 1'b1;
    seq_item.wrst_n = 1'b1;
    seq_item.w_en = 1'b1;
    seq_item.r_en = 1'b0;

    // Finish the sequence item
    finish_item(seq_item);

    // Log the operation for debugging
    `uvm_info("write_once_SEQUENCE", $sformatf("write_once only: %s", seq_item.convert2string()), UVM_HIGH)
  endtask : body

endclass
