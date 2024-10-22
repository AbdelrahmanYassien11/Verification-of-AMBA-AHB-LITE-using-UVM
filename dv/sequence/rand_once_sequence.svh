/******************************************************************
 * File: rand_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This virtual class defines a sequence for performing
 *              random operations. It extends the `base_sequence` class
 *              and handles the randomization of sequence items.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

virtual class rand_once_sequence extends base_sequence;
  `uvm_object_utils(rand_once_sequence);

  // Handle for the reset_sequence object
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "rand_once_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  virtual task pre_body(); 
    // Call the parent class's pre_body task
    super.pre_body();
    
    // Create a new instance of reset_sequence
    reset_sequence_h = reset_sequence::type_id::create("");
  endtask : pre_body

  // Main task body to perform random operations
  virtual task body();
    // Start the sequence item
    start_item(seq_item);
    
    // Randomize the sequence item
    assert(seq_item.randomize());
    
    // Finish the sequence item
    finish_item(seq_item);
    
    // Log the randomized sequence item for debugging
    `uvm_info("rand_once_sequence", $sformatf(" Randomized sequence item: %s", seq_item.convert2string()), UVM_HIGH)
  endtask : body

endclass
