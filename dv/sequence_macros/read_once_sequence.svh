/******************************************************************
 * File: read_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing a 
 *              read operation once. It extends the base_sequence class
 *              and implements a sequence where the read operation is
 *              executed, potentially following a reset operation.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_once_sequence extends base_sequence;
  `uvm_object_utils(read_once_sequence);

  // Static flag to indicate whether a reset is required
  static bit reset_flag;
  
  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "read_once_sequence");
    super.new(name);
  endfunction

  // Task executed before the body task
  task pre_body();
    // Display message indicating the start of the pre_body task
    $display("start of pre_body task");
    
    // Call the base class's pre_body method
    super.pre_body();

    // Create an instance of the reset_sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  task body();

    // If reset_flag is not set, start the reset sequence
    if(!reset_flag)
      `uvm_do_on(reset_sequence_h, sequencer_h);
    
    // Execute the sequence item with the condition that operation is READ
    `uvm_do_on_with(seq_item, sequencer_h, {operation == READ;})

    // Log information about the read operation
    `uvm_info("read_once_SEQUENCE", $sformatf(" read_once only: %s", seq_item.convert2string), UVM_HIGH)
  endtask : body

endclass
