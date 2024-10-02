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

class write_twice_sequence extends base_sequence;
  `uvm_object_utils(write_twice_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  write_once_sequence write_once_sequence_h;

  // Constructor
  function new(string name = "write_twice_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    write_once_sequence_h = write_once_sequence::type_id::create("write_once_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    write_once_sequence::reset_flag = 1'b1;

    reset_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);

    // Log the operation for debugging
    `uvm_info("write_twice_SEQUENCE", $sformatf("write_twice only: %s", seq_item.convert2string()), UVM_HIGH)
  endtask : body

endclass
