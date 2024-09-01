/******************************************************************
 * File: write_once_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a random sequence for writing
 *              data to a FIFO once. It extends the `rand_once_sequence`
 *              and incorporates randomization features for the write
 *              operation.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_once_rand_sequence extends rand_once_sequence;
  `uvm_object_utils(write_once_rand_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle for reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "write_once_rand_sequence");
    super.new(name);
  endfunction

  // Main task body where the sequence execution occurs
  task body();
    // If reset_flag is not set, execute the reset sequence
    if (!reset_flag) begin
      `uvm_do_on(reset_sequence_h, sequencer_h)
    end

    // Randomize the sequence item and set the operation to WRITE
    `uvm_do_on_with(seq_item, sequencer_h, {operation == WRITE;})
  endtask : body

endclass
