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

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  WRITE_READ_INCR8_sequence WRITE_READ_INCR8_sequence_h;
  WRITE_READ_INCR4_sequence WRITE_READ_INCR4_sequence_h;
  WRITE_READ_INCR16_sequence WRITE_READ_INCR16_sequence_h;

  WRITE_READ_WRAP4_sequence WRITE_READ_WRAP4_sequence_h;
  WRITE_READ_WRAP8_sequence WRITE_READ_WRAP8_sequence_h;
  WRITE_READ_WRAP16_sequence WRITE_READ_WRAP16_sequence_h;

  twice_reset_sequence twice_reset_sequence_h;

  // Constructor
  function new(string name = "test_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");

    WRITE_READ_INCR8_sequence_h = WRITE_READ_INCR8_sequence::type_id::create("WRITE_READ_INCR8_sequence_h");
    WRITE_READ_INCR4_sequence_h = WRITE_READ_INCR4_sequence::type_id::create("WRITE_READ_INCR4_sequence_h");
    WRITE_READ_INCR16_sequence_h = WRITE_READ_INCR16_sequence::type_id::create("WRITE_READ_INCR16_sequence_h");

    WRITE_READ_WRAP8_sequence_h = WRITE_READ_WRAP8_sequence::type_id::create("WRITE_READ_WRAP8_sequence_h");
    WRITE_READ_WRAP16_sequence_h = WRITE_READ_WRAP16_sequence::type_id::create("WRITE_READ_WRAP16_sequence_h");
    WRITE_READ_WRAP4_sequence_h = WRITE_READ_WRAP4_sequence::type_id::create("WRITE_READ_WRAP4_sequence_h");


    twice_reset_sequence_h = twice_reset_sequence::type_id::create("twice_reset_sequence_h");
  endtask : pre_body

  // Main task body for executing the READ operation
  virtual task body();

    WRITE_READ_INCR8_sequence::reset_flag = 1'b1;
    WRITE_READ_INCR4_sequence::reset_flag = 1'b1;
    WRITE_READ_INCR16_sequence::reset_flag = 1'b1;
    WRITE_READ_WRAP8_sequence::reset_flag = 1'b1;
    WRITE_READ_WRAP4_sequence::reset_flag = 1'b1;
    WRITE_READ_WRAP16_sequence::reset_flag = 1'b1;
    twice_reset_sequence::reset_flag = 1'b1;


    `uvm_info("test_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    //READ_INCR8_sequence_h.start(sequencer_h);
    // Start the sequence item

    WRITE_READ_INCR8_sequence_h.start(sequencer_h);
    WRITE_READ_INCR8_sequence_h.start(sequencer_h);
    WRITE_READ_INCR4_sequence_h.start(sequencer_h);
    WRITE_READ_INCR16_sequence_h.start(sequencer_h);

    WRITE_READ_WRAP8_sequence_h.start(sequencer_h);

    WRITE_READ_WRAP16_sequence_h.start(sequencer_h);

    WRITE_READ_WRAP4_sequence_h.start(sequencer_h);
    // reset_sequence_h.start(sequencer_h);

    // twice_reset_sequence_h.start(sequencer_h);

    WRITE_READ_INCR8_sequence_h.start(sequencer_h);



  endtask : body

endclass
