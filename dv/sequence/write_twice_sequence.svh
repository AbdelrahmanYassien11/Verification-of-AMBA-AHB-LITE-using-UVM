/******************************************************************
 * File: write_once_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a write 
 *              operation to the FIFO once. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a write 
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_twice_sequence extends base_sequence;
  `uvm_object_utils(write_twice_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  WRITE_SINGLE_sequence WRITE_SINGLE_sequence_h;
  READ_SINGLE_sequence READ_SINGLE_sequence_h;

  // Constructor
  function new(string name = "write_twice_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    WRITE_SINGLE_sequence_h = WRITE_SINGLE_sequence::type_id::create("WRITE_SINGLE_sequence_h");
    READ_SINGLE_sequence_h = READ_SINGLE_sequence::type_id::create("READ_SINGLE_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    write_once_sequence::reset_flag = 1'b1;
    read_once_sequence::reset_flag = 1'b1;

    reset_sequence::last_test = 1'b1;
    READ_SINGLE_sequence::last_test = 1'b1;
    WRITE_SINGLE_sequence::last_test = 1'b1;


    reset_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);

    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = WRITE;
    seq_item.TRANS_op = NONSEQ;
    seq_item.BURST_op = INCR4;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

    for (int i = 0; i < 3; i++) begin
      seq_item.RESET_op.rand_mode(0);
      seq_item.WRITE_op.rand_mode(0);
      seq_item.TRANS_op.rand_mode(0);
      seq_item.BURST_op.rand_mode(0);
      seq_item.SIZE_op.rand_mode(0);
      seq_item.HADDR.rand_mode(0);
      //seq_item.HWRITE_rand_c.constraint_mode(0);

      start_item(seq_item); // Start the sequence item
      
      // Set the operation type to WRITE
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = WRITE;
      seq_item.TRANS_op = SEQ;
      seq_item.BURST_op = INCR4;
      seq_item.SIZE_op  = BYTE;

      assert(seq_item.randomize()); // Randomize the sequence item
      // Set the control signals for writing

      finish_item(seq_item);
    end


    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = WRITE;
    seq_item.TRANS_op = IDLE;
    seq_item.BURST_op = SINGLE;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);
    write_once_sequence_h.start(sequencer_h);

    for(int i = 0; i<10; i++) begin
      read_once_sequence_h.start(sequencer_h);
    end

    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = READ;
    seq_item.TRANS_op = NONSEQ;
    seq_item.BURST_op = INCR4;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

    for (int i = 0; i < 3; i++) begin
      seq_item.RESET_op.rand_mode(0);
      seq_item.WRITE_op.rand_mode(0);
      seq_item.TRANS_op.rand_mode(0);
      seq_item.BURST_op.rand_mode(0);
      seq_item.SIZE_op.rand_mode(0);
      seq_item.HADDR.rand_mode(0);
      //seq_item.HWRITE_rand_c.constraint_mode(0);

      start_item(seq_item); // Start the sequence item
      
      // Set the operation type to WRITE
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = READ;
      seq_item.TRANS_op = SEQ;
      seq_item.BURST_op = INCR4;
      seq_item.SIZE_op  = BYTE;

      assert(seq_item.randomize()); // Randomize the sequence item
      // Set the control signals for writing

      finish_item(seq_item);
    end

    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = READ;
    seq_item.TRANS_op = IDLE;
    seq_item.BURST_op = SINGLE;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

        seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = READ;
    seq_item.TRANS_op = NONSEQ;
    seq_item.BURST_op = WRAP4;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

    for (int i = 0; i < 3; i++) begin
      seq_item.RESET_op.rand_mode(0);
      seq_item.WRITE_op.rand_mode(0);
      seq_item.TRANS_op.rand_mode(0);
      seq_item.BURST_op.rand_mode(0);
      seq_item.SIZE_op.rand_mode(0);
      seq_item.HADDR.rand_mode(0);
      //seq_item.HWRITE_rand_c.constraint_mode(0);

      start_item(seq_item); // Start the sequence item
      
      // Set the operation type to WRITE
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = READ;
      seq_item.TRANS_op = SEQ;
      seq_item.BURST_op = WRAP4;
      seq_item.SIZE_op  = BYTE;

      assert(seq_item.randomize()); // Randomize the sequence item
      // Set the control signals for writing

      finish_item(seq_item);
    end

    seq_item.RESET_op.rand_mode(0);
    seq_item.WRITE_op.rand_mode(0);
    seq_item.TRANS_op.rand_mode(0);
    seq_item.BURST_op.rand_mode(0);
    seq_item.SIZE_op.rand_mode(0);
    //seq_item.HWRITE_rand_c.constraint_mode(0);

    start_item(seq_item); // Start the sequence item
    
    // Set the operation type to WRITE
    seq_item.RESET_op = WORKING;
    seq_item.WRITE_op = READ;
    seq_item.TRANS_op = IDLE;
    seq_item.BURST_op = SINGLE;
    seq_item.SIZE_op  = BYTE;

    assert(seq_item.randomize()); // Randomize the sequence item
    // Set the control signals for writing

    finish_item(seq_item);

    if(~last_test)
    seq_item.last_item = 1'b1;

    read_once_sequence_h.start(sequencer_h);

    // Log the operation for debugging
    `uvm_info("write_twice_SEQUENCE", $sformatf("write_twice only: %s", seq_item.convert2string()), UVM_HIGH)
  endtask : body

endclass
