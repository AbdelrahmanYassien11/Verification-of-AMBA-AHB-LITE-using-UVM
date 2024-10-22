/******************************************************************
 * File: write_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for writing data to
 *              a FIFO once. It extends the base sequence and handles
 *              operations specific to writing data.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_once_sequence extends base_sequence;
  `uvm_object_utils(write_once_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle for reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "write_once_sequence");
    super.new(name);
  endfunction

  // Pre-body phase where initialization tasks can be performed
  task pre_body();
    $display("start of pre_body task");
    super.pre_body();
    // Handle for reset sequence creation is commented out here
    //reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body where the sequence execution occurs
  virtual task body();

    // If reset_flag is not set, execute the reset sequence
    if (!reset_flag) begin
      `uvm_do_on(reset_sequence_h, sequencer_h);
    end

    // Set the operation of the sequence item to WRITE and start the sequence
    `uvm_do_on_with(seq_item, sequencer_h, {operation == WRITE;})

    // Log information about the sequence item being processed
    `uvm_info("write_once_SEQUENCE", $sformatf(" write_once only: %s", seq_item.convert2string), UVM_HIGH)
  endtask : body

endclass
