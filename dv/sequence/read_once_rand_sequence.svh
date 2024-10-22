/******************************************************************
 * File: read_once_rand_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a randomized sequence for performing
 *              a single read operation on the FIFO. It inherits from
 *              `rand_once_sequence` and includes functionality to
 *              manage reset sequences and set control signals for a
 *              read operation with randomized data.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_once_rand_sequence extends rand_once_sequence;
  `uvm_object_utils(read_once_rand_sequence);

  // Static flag to determine if a reset is required
  static bit reset_flag;

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "read_once_rand_sequence");
    super.new(name);
  endfunction

  // Main task body to perform the read operation with randomization
  task body();
    // If reset_flag is not set, start the reset sequence
    if(!reset_flag) begin
      // Create and start a new reset_sequence object
      reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
      reset_sequence_h.start(m_sequencer);
    end

    // Set randomization mode for sequence item fields
    seq_item.w_en.rand_mode(0);      // Disable randomization for write enable
    seq_item.data_in.rand_mode(0);  // Disable randomization for data input
    seq_item.operation.rand_mode(0); // Disable randomization for operation field

    // Set the operation to READ
    seq_item.operation = READ;

    // Call the parent class's body task to execute the sequence
    super.body();
  endtask : body

endclass
