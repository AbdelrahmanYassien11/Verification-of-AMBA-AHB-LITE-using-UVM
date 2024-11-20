/******************************************************************
 * File: test_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs an IDLE
 *              operation. It inherits from `base_sequence` and includes 
 *              functionality to start the reset sequence if needed 
 *              and perform an IDLE operation with randomized 
 *              sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class test_sequence extends base_sequence;
  `uvm_object_utils(test_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  READ_INCR8_sequence READ_INCR8_sequence_h;

  // Constructor
  function new(string name = "test_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    READ_INCR8_sequence_h = READ_INCR8_sequence::type_id::create("READ_INCR8_sequence_h");
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body for executing the READ operation
  virtual task body();

    reset_sequence::last_test = 1'b1;
    READ_INCR8_sequence::last_test = 1'b1;
    READ_INCR8_sequence::reset_flag = 1'b1;


    `uvm_info("test_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    if(~last_test)
      seq_item.last_item = 1'b1;


    //READ_INCR8_sequence_h.start(sequencer_h);
    // Start the sequence item
    start_item(seq_item);
    
    // Configure the sequence item for the write operation
    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);

    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = WRITE;
    seq_item.TRANS_op = NONSEQ;
    seq_item.BURST_op = SINGLE;
    seq_item.SIZE_op  = HALFWORD;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    // Finish the sequence item
    finish_item(seq_item);

  endtask : body

endclass
