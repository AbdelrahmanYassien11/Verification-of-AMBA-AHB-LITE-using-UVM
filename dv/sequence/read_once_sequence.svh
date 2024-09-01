/******************************************************************
 * File: read_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for performing a
 *              single read operation on the FIFO. It handles the
 *              necessary reset sequences and sets the appropriate
 *              control signals for a read operation.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class read_once_sequence extends base_sequence;
  `uvm_object_utils(read_once_sequence);

  // Static flag to determine if a reset is required
  static bit reset_flag;

  // Handle for the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "read_once_sequence");
    super.new(name);
  endfunction

  // Preparation task before the main sequence body is executed
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    super.pre_body();
    
    // Create a new reset_sequence object for handling resets
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body to perform the read operation
  task body();
    // If reset_flag is not set, start the reset sequence
    if(!reset_flag) begin
      reset_sequence_h.start(m_sequencer);
    end

    // Start the sequence item for the read operation
    start_item(seq_item);
    
    // Set control signals for a read operation
    seq_item.wrst_n = 1'b1;  // Ensure write reset is deasserted
    seq_item.rrst_n = 1'b1;  // Ensure read reset is deasserted
    seq_item.w_en  = 1'b0;   // Disable write enable
    seq_item.r_en  = 1'b1;   // Enable read operation

    // Finish the sequence item after setting control signals
    finish_item(seq_item);

    // Log information about the read operation
    `uvm_info("read_once_SEQUENCE", $sformatf("read_once only: %s", seq_item.convert2string()), UVM_HIGH);
  endtask : body

endclass
