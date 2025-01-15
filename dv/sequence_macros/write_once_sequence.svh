/******************************************************************
 * File: WRITE_SINGLE_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence for writing data to
 *              a FIFO once. It extends the base sequence and handles
 *              operations specific to writing data.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_SINGLE_sequence extends base_sequence;
  `uvm_object_utils(WRITE_SINGLE_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle for reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "WRITE_SINGLE_sequence");
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
    `uvm_info("WRITE_SINGLE_sequence", $sformatf(" WRITE_SINGLE only: %s", seq_item.convert2string), UVM_HIGH)
  endtask : body

endclass

/******************************************************************
 * File: WRITE_SINGLE_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 01/11/2024
 * Description: This class defines a sequence that performs a write 
 *              operation to the AHB_lite once. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a write 
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_SINGLE_sequence extends base_sequence;
  `uvm_object_utils(WRITE_SINGLE_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  IDLE_sequence IDLE_sequence_h;

  // Constructor
  function new(string name = "WRITE_SINGLE_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    IDLE_sequence_h = IDLE_sequence::type_id::create("IDLE_sequence_h");

  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    reset_sequence::last_test = 1'b1;

    // Log the operation for debugging
    `uvm_info("WRITE_SINGLE_SEQUENCE: ", "STARTING", UVM_HIGH)

    // If reset_flag is not set, start the reset sequence
    if (!reset_flag)
      `uvm_do_on(reset_sequence_h, sequencer_h);


    if(~last_test)
      seq_item.last_item = 1'b1;
    
    `uvm_do_on_with(seq_item, sequencer_h, {RESET_op == WORKING; WRITE_op = WRITE; TRANS_op = NONSEQ; BURST_op = SINGLE})
    
  endtask : body

endclass
