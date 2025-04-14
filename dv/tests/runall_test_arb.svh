/******************************************************************
 * File: runall_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM test component that sets up
 *              and executes the `runall_sequence`. It extends the 
 *              `base_test` class and overrides the `build_phase` 
 *              and `connect_phase` methods to configure the sequence 
 *              type and establish connections.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class runall_test_arb extends base_test;
   `uvm_component_utils(runall_test_arb);

   // Virtual interface for the test
   virtual inf my_vif;
   static bit last_test;

   base_sequence seq_array [18];

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


   // Constructor for the test class
   function new(string name = "runall_test_arb", uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase where configuration and setup occur
   function void build_phase(uvm_phase phase);
      // Override the type of sequence used by the base_sequence class
      base_sequence::type_id::set_type_override(runall_sequence::type_id::get());
      // Call the build_phase method of the base class
      super.build_phase(phase);

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

      seq_array = '{reset_sequence_h, IDLE_sequence_h, WRITE_SINGLE_sequence_h, WRITE_INCR_sequence_h, WRITE_INCR4_sequence_h, WRITE_INCR8_sequence_h,
                    WRITE_INCR16_sequence_h, WRITE_WRAP4_sequence_h, WRITE_WRAP8_sequence_h, WRITE_WRAP16_sequence_h, READ_SINGLE_sequence_h, READ_INCR_sequence_h,
                    READ_INCR4_sequence_h, READ_INCR8_sequence_h, READ_INCR16_sequence_h, READ_WRAP4_sequence_h, READ_WRAP8_sequence_h, READ_WRAP16_sequence_h};

      // Display a message indicating the build phase of the test
      `uvm_info(get_type_name(), "Build Phase", UVM_LOW)
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
    // reset_sequence::last_test = 1'b1;
    // IDLE_sequence::last_test = 1'b1;

    // WRITE_SINGLE_sequence::last_test = 1'b1;

    // WRITE_INCR_sequence::last_test = 1'b1;

    // WRITE_WRAP4_sequence::last_test = 1'b1;
    // WRITE_WRAP8_sequence::last_test = 1'b1;
    // WRITE_WRAP16_sequence::last_test = 1'b1;
    // WRITE_INCR4_sequence::last_test = 1'b1;
    // WRITE_INCR8_sequence::last_test = 1'b1;
    // WRITE_INCR16_sequence::last_test = 1'b1;

    // READ_SINGLE_sequence::last_test = 1'b1;
    // READ_INCR_sequence::last_test = 1'b1;
    // READ_WRAP4_sequence::last_test = 1'b1;
    // READ_WRAP8_sequence::last_test = 1'b1;
    // READ_WRAP16_sequence::last_test = 1'b1;
    // READ_INCR4_sequence::last_test = 1'b1;
    // READ_INCR8_sequence::last_test = 1'b1;
    // READ_INCR16_sequence::last_test = 1'b1;


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

      phase.raise_objection(this);

      // sequencer_h.set_arbitration(UVM_SEQ_ARB_FIFO);
      // show_arb_cfg();


      fork
        seq_array[0].start(sequencer_h);
        seq_array[1].start(sequencer_h);
        seq_array[2].start(sequencer_h);
        seq_array[3].start(sequencer_h);
        seq_array[4].start(sequencer_h);
        seq_array[5].start(sequencer_h);
        seq_array[6].start(sequencer_h);
        seq_array[7].start(sequencer_h);
        seq_array[8].start(sequencer_h);
        seq_array[9].start(sequencer_h);
        seq_array[10].start(sequencer_h);
        seq_array[11].start(sequencer_h);
        seq_array[13].start(sequencer_h);
        seq_array[14].start(sequencer_h);
        seq_array[15].start(sequencer_h);
        seq_array[16].start(sequencer_h);
        seq_array[17].start(sequencer_h);
        //seq_array[18].start(sequencer_h);
      join

      IDLE_sequence_h.start(sequencer_h);

      phase.drop_objection(this);
   endtask
   // Connect phase where connections are made
   function void connect_phase(uvm_phase phase);
      // Call the connect_phase method of the base class
      super.connect_phase(phase);
      // Display a message indicating the connect phase of the test
      `uvm_info(get_type_name(), "Connect Phase", UVM_LOW)
   endfunction


endclass
