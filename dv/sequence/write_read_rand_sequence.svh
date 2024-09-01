/******************************************************************
 * File: write_read_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a random sequence generator for
 *              the UVM testbench. It creates and starts various
 *              sequences such as read, write, and reset sequences.
 *              It handles random operations and sequence control based
 *              on internal state checks.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_read_rand_sequence extends base_sequence;
  `uvm_object_utils(write_read_rand_sequence);

  // Sequence handles for different sequences
  reset_sequence reset_sequence_h;
  write_once_rand_sequence write_once_rand_sequence_h;
  read_once_rand_sequence read_once_rand_sequence_h;

  write_all_sequence write_all_sequence_h;
  read_all_sequence read_all_sequence_h;

  // Sequence item for random tests
  sequence_item seq_item_rand_tests;

  // Flags for checking FIFO status
  bit full_check;
  bit empty_check;

  // Constructor
  function new(string name = "write_read_rand_sequence");
    super.new(name);
  endfunction

  // Task body for executing the sequence
  task body();
    // Create sequence item for random tests
    seq_item_rand_tests = sequence_item::type_id::create("seq_item_rand_tests");

    // Initialize reset flags for sequences
    write_once_rand_sequence::reset_flag = 1'b1;
    read_once_rand_sequence::reset_flag = 1'b1;
    write_all_sequence::reset_flag = 1'b1;

    // Create handles for different sequences
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    write_once_rand_sequence_h = write_once_rand_sequence::type_id::create("write_once_rand_sequence_h");
    read_once_rand_sequence_h = read_once_rand_sequence::type_id::create("read_once_rand_sequence_h");
    write_all_sequence_h = write_all_sequence::type_id::create("write_all_sequence_h");
    read_all_sequence_h = read_all_sequence::type_id::create("read_all_sequence_h");

    // Start the reset sequence
    reset_sequence_h.start(m_sequencer);

    // Randomize the sequence item
    seq_item_rand_tests.randomize();

    // Repeat sequence execution based on the number of randomized tests
    repeat(seq_item_rand_tests.randomized_number_of_tests) begin
      // Randomize the sequence item
      assert(seq_item.randomize());

      // Perform actions based on the operation type
      if (seq_item.operation == WRITE) begin
        if (!full_check) begin
          // Start the sequence for writing all data if FIFO is not full
          write_all_sequence_h.start(m_sequencer);
          full_check = 1;
        end else begin
          // Start the sequence for writing once if FIFO is full
          write_once_rand_sequence_h.start(m_sequencer);
        end
      end else if (seq_item.operation == READ) begin
        if (!empty_check) begin
          // Start the sequence for reading all data if FIFO is not empty
          read_all_sequence_h.start(m_sequencer);
          full_check = 1;
        end else begin
          // Start the sequence for reading once if FIFO is not empty
          read_once_rand_sequence_h.start(m_sequencer);
        end
      end else if (seq_item.operation == RESET) begin
        // Start the sequence for resetting FIFO
        reset_sequence_h.start(m_sequencer);
      end
    end
  endtask : body

endclass
