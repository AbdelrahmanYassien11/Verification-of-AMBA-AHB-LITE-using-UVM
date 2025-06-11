/******************************************************************
 * File: read_once_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a randomized sequence for performing
 *              a read operation once. It extends from the rand_once_sequence
 *              class and ensures that a reset operation, if required, is performed
 *              before executing the read operation with randomized inputs.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_once_rand_sequence extends rand_once_sequence;
  `uvm_object_utils(read_once_rand_sequence);

  // Static flag to indicate whether a reset is required
  static bit reset_flag;
  
  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "read_once_rand_sequence");
    super.new(name);
  endfunction

  // Main task body where the sequence execution occurs
  task body();
    // If reset_flag is not set, start the reset sequence
    if(!reset_flag) begin
      `uvm_do_on(reset_sequence_h, sequencer_h)
    end

    // Execute the sequence item with the condition that data_in is 0 and operation is READ
    `uvm_do_with(seq_item, {data_in == 0; operation == READ;})
  endtask : body

endclass
