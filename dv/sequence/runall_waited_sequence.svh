/******************************************************************
 * File: runall_waited_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs an runall
 *              operation. It inherits from `base_sequence` and includes 
 *              functionality to start the reset sequence if needed 
 *              and perform an runall operation with randomized 
 *              sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class runall_waited_sequence extends base_sequence;
  `uvm_object_utils(runall_waited_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  `uvm_declare_p_sequencer(sequencer)

  static base_sequence base_sequence_r [21];

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;

  IDLE_sequence IDLE_sequence_h;

  WRITE_SINGLE_sequence WRITE_SINGLE_sequence_h;
  READ_SINGLE_sequence READ_SINGLE_sequence_h;  

  WRITE_INCR_sequence WRITE_INCR_sequence_h;
  READ_INCR_sequence READ_INCR_sequence_h;

  WRITE_INCR4_sequence WRITE_INCR4_sequence_h;
  WRITE_INCR8_sequence WRITE_INCR8_sequence_h;
  WRITE_INCR16_sequence WRITE_INCR16_sequence_h;

  READ_INCR4_sequence  READ_INCR4_sequence_h;
  READ_INCR8_sequence  READ_INCR8_sequence_h;
  READ_INCR16_sequence READ_INCR16_sequence_h;

  WRITE_WRAP4_sequence  WRITE_WRAP4_sequence_h;
  WRITE_WRAP8_sequence  WRITE_WRAP8_sequence_h;
  WRITE_WRAP16_sequence WRITE_WRAP16_sequence_h;

  READ_WRAP4_sequence  READ_WRAP4_sequence_h;
  READ_WRAP8_sequence  READ_WRAP8_sequence_h;
  READ_WRAP16_sequence READ_WRAP16_sequence_h;

  twice_IDLE_sequence twice_IDLE_sequence_h;
  twice_reset_sequence twice_reset_sequence_h;
  SINGLE_IDLE_sequence SINGLE_IDLE_sequence_h;

  // Constructor
  function new(string name = "runall_waited_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    IDLE_sequence_h = IDLE_sequence::type_id::create("IDLE_sequence_h");

    WRITE_SINGLE_sequence_h   = WRITE_SINGLE_sequence::type_id::create("WRITE_SINGLE_sequence_h");

    WRITE_INCR_sequence_h   = WRITE_INCR_sequence::type_id::create("WRITE_INCR_sequence_h");
    WRITE_INCR4_sequence_h  = WRITE_INCR4_sequence::type_id::create("WRITE_INCR4_sequence_h");
    WRITE_INCR8_sequence_h   = WRITE_INCR8_sequence::type_id::create("WRITE_INCR8_sequence_h");
    WRITE_INCR16_sequence_h = WRITE_INCR16_sequence::type_id::create("WRITE_INCR16_sequence_h");

    WRITE_WRAP4_sequence_h  = WRITE_WRAP4_sequence::type_id::create("WRITE_WRAP4_sequence_h");
    WRITE_WRAP8_sequence_h  = WRITE_WRAP8_sequence::type_id::create("WRITE_WRAP8_sequence_h");
    WRITE_WRAP16_sequence_h = WRITE_WRAP16_sequence::type_id::create("WRITE_WRAP16_sequence_h");


    READ_SINGLE_sequence_h    = READ_SINGLE_sequence::type_id::create("READ_SINGLE_sequence_h");

    READ_INCR_sequence_h    = READ_INCR_sequence::type_id::create("READ_INCR_sequence_h");
    READ_INCR4_sequence_h   = READ_INCR4_sequence::type_id::create("READ_INCR4_sequence_h");
    READ_INCR8_sequence_h    = READ_INCR8_sequence::type_id::create("READ_INCR8_sequence_h");
    READ_INCR16_sequence_h  = READ_INCR16_sequence::type_id::create("READ_INCR16_sequence_h");

    READ_WRAP4_sequence_h   = READ_WRAP4_sequence::type_id::create("READ_WRAP4_sequence_h");
    READ_WRAP8_sequence_h   = READ_WRAP8_sequence::type_id::create("READ_WRAP8_sequence_h");
    READ_WRAP16_sequence_h  = READ_WRAP16_sequence::type_id::create("READ_WRAP16_sequence_h");

    twice_IDLE_sequence_h   = twice_IDLE_sequence::type_id::create("twice_IDLE_sequence_h");
    twice_reset_sequence_h  = twice_reset_sequence::type_id::create("twice_reset_sequence_h");
    SINGLE_IDLE_sequence_h  = SINGLE_IDLE_sequence::type_id::create("SINGLE_IDLE_sequence_h");

    // genvar i;
    // generate
    //   for(i = 0; i<18; i++)begin
    //     base_sequence_r[i] = new();
    //   end
    // endgenerate

    for(int i = 0; i <21; i++) begin
      base_sequence_r[i] = new();
    end

    base_sequence_r = '{reset_sequence_h, IDLE_sequence_h, WRITE_SINGLE_sequence_h, WRITE_INCR_sequence_h, WRITE_INCR4_sequence_h, WRITE_INCR8_sequence_h,
                        WRITE_INCR16_sequence_h, WRITE_WRAP4_sequence_h, WRITE_WRAP8_sequence_h, WRITE_WRAP16_sequence_h, READ_SINGLE_sequence_h, READ_INCR_sequence_h,
                        READ_INCR4_sequence_h, READ_INCR8_sequence_h, READ_INCR16_sequence_h, READ_WRAP4_sequence_h, READ_WRAP8_sequence_h, READ_WRAP16_sequence_h, twice_IDLE_sequence_h,
                        twice_reset_sequence_h, SINGLE_IDLE_sequence_h};

  endtask : pre_body

  // Main task body for executing the READ operation
  virtual task body();

    IDLE_sequence::reset_flag = 1'b1;

    WRITE_SINGLE_sequence::reset_flag = 1'b1;
    WRITE_INCR_sequence::reset_flag = 1'b1;
    WRITE_WRAP4_sequence::reset_flag = 1'b1;
    WRITE_WRAP8_sequence::reset_flag = 1'b1;
    WRITE_WRAP16_sequence::reset_flag = 1'b1;
    WRITE_INCR4_sequence::reset_flag = 1'b1;
    WRITE_INCR8_sequence::reset_flag = 1'b1;
    WRITE_INCR16_sequence::reset_flag = 1'b1;

    READ_SINGLE_sequence::reset_flag = 1'b1;
    READ_INCR_sequence::reset_flag = 1'b1;
    READ_WRAP4_sequence::reset_flag = 1'b1;
    READ_WRAP8_sequence::reset_flag = 1'b1;
    READ_WRAP16_sequence::reset_flag = 1'b1;
    READ_INCR4_sequence::reset_flag = 1'b1;
    READ_INCR8_sequence::reset_flag = 1'b1;
    READ_INCR16_sequence::reset_flag = 1'b1;

    twice_IDLE_sequence::reset_flag = 1'b1;
    twice_reset_sequence::reset_flag = 1'b1;
    SINGLE_IDLE_sequence::reset_flag = 1'b1;

    `uvm_info(get_type_name(), "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    super.body();

    assert(seq_item.randomize());

    seq_item.randomized_number_of_tests.rand_mode(0);

    for(int i = 0; i < seq_item.randomized_number_of_tests ; i++) begin

      assert(seq_item.randomize());
        `uvm_info(get_type_name(), $sformatf("%s",base_sequence_r[seq_item.sequence_randomizer].get_full_name()), UVM_LOW); 
        base_sequence_r[seq_item.sequence_randomizer].start(sequencer_h);
        // @(finished_sequence);
        //IDLE_sequence_h.HADDR_reserve = base_sequence_r[seq_item.sequence_randomizer].seq_item.HADDR;
        
    end

    IDLE_sequence_h.start(sequencer_h);

  endtask : body

endclass
