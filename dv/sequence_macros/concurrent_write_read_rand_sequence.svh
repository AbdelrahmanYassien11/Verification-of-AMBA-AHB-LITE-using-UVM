/******************************************************************
 * File: concurrent_write_read_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs concurrent
 *              write and read operations with randomization. It extends
 *              `base_sequence` and uses multiple handles to manage
 *              different sequence operations. The sequence includes
 *              reset and execution tasks for setting up and running
 *              the concurrent operations.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class concurrent_write_read_rand_sequence extends base_sequence;
  `uvm_object_utils(concurrent_write_read_rand_sequence);

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Handle for the concurrent write-read once sequence
  concurrent_write_read_once_sequence concurrent_write_read_once_sequence_h;

  // Sequence item for random test cases
  sequence_item seq_item_rand_tests;

  // Constructor
  function new(string name = "concurrent_write_read_rand_sequence");
    super.new(name);
  endfunction

  // Pre-body task for initial setup
  task pre_body();
    $display("start of pre_body task");
    super.pre_body();
    // Create an instance of reset_sequence if not already created
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    concurrent_write_read_once_sequence_h = concurrent_write_read_once_sequence::type_id::create("concurrent_write_read_once_sequence_h");
  endtask : pre_body

  // Main task body where sequence execution occurs
  task body();
    // Set the reset flag for the concurrent write-read once sequence
    concurrent_write_read_once_sequence::reset_flag = 1;

    // Create and configure the sequence item for random tests
    seq_item_rand_tests = sequence_item::type_id::create("seq_item_rand_tests");
    seq_item_rand_tests.operation_rand_c.constraint_mode(0);

    // Start the reset sequence
    `uvm_do_on(reset_sequence_h, sequencer_h)

    // Randomize the sequence item
    assert(seq_item_rand_tests.randomize());

    // Execute the concurrent write-read once sequence for the number of tests
    repeat(seq_item_rand_tests.randomized_number_of_tests) begin
      `uvm_do_on(concurrent_write_read_once_sequence_h, sequencer_h)
    end
  endtask : body

endclass
