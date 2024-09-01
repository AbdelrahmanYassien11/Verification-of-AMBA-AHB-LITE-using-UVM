/******************************************************************
 * File: rand_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This virtual class defines a sequence for performing
 *              random operations once. It extends from `base_sequence`
 *              and includes a reset sequence to handle initial setup
 *              conditions before executing the main sequence body.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

virtual class rand_once_sequence extends base_sequence;
  `uvm_object_utils(rand_once_sequence);

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "rand_once_sequence");
    super.new(name);
  endfunction

  // Pre-body task where setup actions are performed before the main sequence
  virtual task pre_body(); 
    super.pre_body();
    // Create an instance of reset_sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  virtual task body();
    // Start the reset sequence if needed (not invoked here directly)
    `uvm_do_on(seq_item, sequencer_h);
    `uvm_info("rand_once_sequence", $sformatf(" rand_once only: %s", seq_item.convert2string), UVM_HIGH)
  endtask : body

endclass
