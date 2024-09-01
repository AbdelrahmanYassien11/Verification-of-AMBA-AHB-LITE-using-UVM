/******************************************************************
 * File: write_read_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a random sequence for testing
 *              a FIFO-based system. It creates and manages several
 *              other sequence handles, and executes various sequences
 *              based on randomized test cases.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_read_rand_sequence extends base_sequence;
  `uvm_object_utils(write_read_rand_sequence);

  // Handles for various sequence types
  reset_sequence reset_sequence_h;
  write_once_rand_sequence write_once_rand_sequence_h;
  read_once_rand_sequence read_once_rand_sequence_h;

  write_all_sequence write_all_sequence_h;
  read_all_sequence read_all_sequence_h;

  // Sequence item for randomized tests
  sequence_item seq_item_rand_tests;

  // Flags for checking FIFO status
  bit full_check;
  bit empty_check;

  // Constructor
  function new(string name = "write_read_rand_sequence");
    super.new(name);
  endfunction

  // Main task body
  task body();
    // Create a new sequence item for randomized tests
    seq_item_rand_tests = sequence_item::type_id::create("seq_item_rand_tests");

    // Initialize reset flags for various sequences
    write_once_rand_sequence::reset_flag = 1'b1;
    read_once_rand_sequence::reset_flag = 1'b1;
    write_all_sequence::reset_flag = 1'b1;

    // The reset_sequence_h handle is used to start the reset sequence
    // `uvm_do_on executes the reset_sequence_h sequence on the sequencer_h
    `uvm_do_on(reset_sequence_h, sequencer_h)
    
    // Randomize the sequence item for testing
    assert(seq_item_rand_tests.randomize());

    // Loop through the number of randomized tests
    repeat(seq_item_rand_tests.randomized_number_of_tests) begin
      // Randomize the sequence item for each iteration
      assert(seq_item.randomize());

      // Execute the appropriate sequence based on the operation
      if (seq_item.operation == WRITE) begin
        if (!full_check) begin
          // Start the write_all_sequence if FIFO is not full
          `uvm_do_on(write_all_sequence_h, sequencer_h)
          full_check = 1;
        end else begin
          // Otherwise, execute write_once_rand_sequence
          `uvm_do_on(write_once_rand_sequence_h, sequencer_h)
        end
      end else if (seq_item.operation == READ) begin
        if (!empty_check) begin
          // Start the read_all_sequence if FIFO is not empty
          `uvm_do_on(read_all_sequence_h, sequencer_h)	
          empty_check = 1;
        end else begin
          // Otherwise, execute read_once_rand_sequence
          `uvm_do_on(read_once_rand_sequence_h, sequencer_h)
        end
      end else if (seq_item.operation == RESET) begin
        // Execute the reset_sequence if operation is RESET
        `uvm_do_on(reset_sequence_h, sequencer_h)
      end
    end
  endtask : body
endclass
