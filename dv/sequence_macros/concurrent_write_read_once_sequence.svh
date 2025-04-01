/******************************************************************
 * File: concurrent_write_read_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for concurrent write and
 *              read operations where the operations are executed once
 *              per sequence item. It extends `base_sequence` and includes
 *              a handle for the reset sequence. The class manages sequence
 *              item creation, randomization, and execution.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class concurrent_write_read_once_sequence extends base_sequence;
  `uvm_object_utils(concurrent_write_read_once_sequence);

  // Static flag used to control whether to perform reset operations
  static bit reset_flag;

  // Sequence item specifically for concurrent operations
  sequence_item seq_item_concurrent;

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "concurrent_write_read_once_sequence");
    super.new(name);
  endfunction

  // Pre-body task for setup before the main sequence body
  task pre_body();
    $display("start of pre_body task");
    super.pre_body();
    // Create an instance of the sequence item if not already created
    // Uncomment if using `uvm_create` method for the sequence item
    // `uvm_create(seq_item_concurrent)
  endtask : pre_body

  // Main task body where sequence execution occurs
  task body();
    // If reset_flag is not set, start the reset sequence
    if (!reset_flag)
      `uvm_do_on(reset_sequence_h, sequencer_h)

    // Create and configure the sequence item for concurrent operations
    `uvm_create(seq_item_concurrent)
    seq_item_concurrent.operation_rand_c.constraint_mode(0);

    // Randomize the sequence item with WRITE_READ operation
    assert(seq_item_concurrent.randomize() with { operation == WRITE_READ; });

    // Send the sequence item for processing
    `uvm_send(seq_item_concurrent)
  endtask : body

endclass
