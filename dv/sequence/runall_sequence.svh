/******************************************************************
 * File: runall_sequence.svh
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

class runall_sequence extends base_sequence;
  `uvm_object_utils(runall_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  static base_sequence base_sequence_r [17:0];

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

  // Constructor
  function new(string name = "runall_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
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

    // genvar i;
    // generate
    //   for(i = 0; i<18; i++)begin
    //     base_sequence_r[i] = new();
    //   end
    // endgenerate

    for(int i = 0; i <18; i++) begin
      base_sequence_r[i] = new();
    end

    base_sequence_r = '{reset_sequence_h, IDLE_sequence_h, WRITE_SINGLE_sequence_h, WRITE_INCR_sequence_h, WRITE_INCR4_sequence_h, WRITE_INCR8_sequence_h,
                        WRITE_INCR16_sequence_h, WRITE_WRAP4_sequence_h, WRITE_WRAP8_sequence_h, WRITE_WRAP16_sequence_h, READ_SINGLE_sequence_h, READ_INCR_sequence_h,
                        READ_INCR4_sequence_h, READ_INCR8_sequence_h, READ_INCR16_sequence_h, READ_WRAP4_sequence_h, READ_WRAP8_sequence_h, READ_WRAP16_sequence_h};

  endtask : pre_body

  // Main task body for executing the READ operation
  virtual task body();

    int tests_randomized = $urandom_range(100,200);

    reset_sequence::last_test = 1'b1;
    IDLE_sequence::last_test = 1'b1;

    WRITE_SINGLE_sequence::last_test = 1'b1;

    WRITE_INCR_sequence::last_test = 1'b1;

    WRITE_WRAP4_sequence::last_test = 1'b1;
    WRITE_WRAP8_sequence::last_test = 1'b1;
    WRITE_WRAP16_sequence::last_test = 1'b1;
    WRITE_INCR4_sequence::last_test = 1'b1;
    WRITE_INCR8_sequence::last_test = 1'b1;
    WRITE_INCR16_sequence::last_test = 1'b1;

    READ_SINGLE_sequence::last_test = 1'b1;
    READ_INCR_sequence::last_test = 1'b1;
    READ_WRAP4_sequence::last_test = 1'b1;
    READ_WRAP8_sequence::last_test = 1'b1;
    READ_WRAP16_sequence::last_test = 1'b1;
    READ_INCR4_sequence::last_test = 1'b1;
    READ_INCR8_sequence::last_test = 1'b1;
    READ_INCR16_sequence::last_test = 1'b1;


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


    `uvm_info("runall_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);


    for(int i = 0; i < tests_randomized ; i++) begin

      assert(seq_item.randomize());

      `uvm_info("runall_sequence", {seq_item.convert2string()}, UVM_LOW)

      if(seq_item.RESET_op == WORKING) begin
        if(seq_item.TRANS_op !== IDLE)begin
          if(seq_item.WRITE_op == WRITE) begin
            case (seq_item.BURST_op)
              SINGLE: WRITE_SINGLE_sequence_h.start(sequencer_h);
              INCR:   WRITE_INCR_sequence_h.start(sequencer_h);
              INCR4:  WRITE_INCR4_sequence_h.start(sequencer_h);
              INCR8:  WRITE_INCR8_sequence_h.start(sequencer_h);
              INCR16: WRITE_INCR16_sequence_h.start(sequencer_h);
              WRAP4:  WRITE_WRAP4_sequence_h.start(sequencer_h);
              WRAP8:  WRITE_WRAP8_sequence_h.start(sequencer_h);
              WRAP16: WRITE_WRAP16_sequence_h.start(sequencer_h);                                                                                                          
            endcase // seq_item.HBURST
          end
          else if(seq_item.WRITE_op == READ) begin
            case(seq_item.BURST_op)
              SINGLE: READ_SINGLE_sequence_h.start(sequencer_h);
              INCR:   READ_INCR_sequence_h.start(sequencer_h);
              INCR4:  READ_INCR4_sequence_h.start(sequencer_h);
              INCR8:  READ_INCR8_sequence_h.start(sequencer_h);
              INCR16: READ_INCR16_sequence_h.start(sequencer_h);
              WRAP4:  READ_WRAP4_sequence_h.start(sequencer_h);
              WRAP8:  READ_WRAP8_sequence_h.start(sequencer_h);
              WRAP16: READ_WRAP16_sequence_h.start(sequencer_h);
            endcase // seq_item.HBURST
          end
        end
        else begin
          IDLE_sequence_h.start(sequencer_h);
        end
      end
      else begin
        reset_sequence_h.start(sequencer_h);
      end


      //   if(seq_item.HBURST == SINGLE) begin
      //     WRITE_SINGLE_sequence_h.start(sequencer_h);
      //   end
      //   else if(seq_item.HBURST == INCR) begin
      //     WRITE_INCR_sequence_h.start(sequencer_h);
      //   end
      //   else if(seq_item.HBURST == INCR4)begin
      //     WRITE_INCR4_sequence_h.start(sequencer_h);
      //   end
      //   else if(seq_item.HBURST == INCR8
      // end
      // else if


      // `uvm_info("runall_sequence",{$sformatf("Index: %0d, Expected Sequence: %s", seq_item.randomized_sequences, base_sequence_r[seq_item.randomized_sequences].get_name())}, UVM_LOW);

      // base_sequence_r[seq_item.randomized_sequences].start(sequencer_h);

      // $display("LOVELOVELOVELOVELOVELOVELOVLEOLVOELOVELOVELOVE");

    end

    if(~last_test)
      seq_item.last_item = 1'b1;

    IDLE_sequence_h.start(sequencer_h);

  endtask : body

endclass