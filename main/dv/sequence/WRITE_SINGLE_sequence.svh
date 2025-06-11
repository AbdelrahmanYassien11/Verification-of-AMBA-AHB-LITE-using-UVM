/******************************************************************
 * File: WRITE_SINGLE_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 01/11/2024
 * Description: This class defines a sequence that performs a write 
 *              operation to the AHB_lite once. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a write 
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_SINGLE_sequence extends base_sequence;
  `uvm_object_utils(WRITE_SINGLE_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  IDLE_sequence IDLE_sequence_h;

  // Constructor
  function new(string name = "WRITE_SINGLE_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    IDLE_sequence_h = IDLE_sequence::type_id::create("IDLE_sequence_h");

  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();
    super.body();
    // Log the operation for debugging
    `uvm_info(get_type_name(), "STARTING", UVM_HIGH)

    // If reset_flag is not set, start the reset sequence
    if (~reset_flag)
      reset_sequence_h.start(sequencer_h);
    
    // Start the sequence item
    do_burst(SINGLE, WRITE, NONSEQ);
    

  endtask : body

endclass
