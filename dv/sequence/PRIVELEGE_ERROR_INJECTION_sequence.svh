/******************************************************************
 * File: PRIVELEGE_ERROR_INJECTION_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a INCR8 WRITE 
 *              and INCR8 READ from the same addresses. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a the  
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class PRIVELEGE_ERROR_INJECTION_sequence extends base_sequence;
  `uvm_object_utils(PRIVELEGE_ERROR_INJECTION_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  IDLE_sequence IDLE_sequence_h;


  // Constructor
  function new(string name = "PRIVELEGE_ERROR_INJECTION_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name(), "start of pre_body task", UVM_HIGH)
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    IDLE_sequence_h  = IDLE_sequence::type_id::create("IDLE_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();
    super.body();
    IDLE_sequence::reset_flag = 1'b1;
    `uvm_info(get_type_name(), "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    seq_item.HADDR_VAL_BURST.constraint_mode(0);
    seq_item.HADDR_SEL_c.constraint_mode(0);
    seq_item.HPROT_c.constraint_mode(0);

    /***************************************************************************************/
    //                                 STARTING WRITE_INCR8
    /**************************************************************************************/   
    start_item(seq_item); // Start the sequence item

      // Set the operation type to WRITE
      assert(seq_item.randomize() with { RESET_op == WORKING; WRITE_op == WRITE; TRANS_op == NONSEQ; BURST_op == INCR8; SIZE_op == WORD;/* HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] == 255;*/ HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 5; HPROT == 4'b0001;}); // Randomize the sequence item

    finish_item(seq_item);

    IDLE_sequence_h.HADDR_reserve = {seq_item.SEL_op,seq_item.HADDRx};
    seq_item.SIZE_op.rand_mode(0);
    seq_item.HADDRx.rand_mode(0);
    seq_item.SEL_op.rand_mode(0);
    seq_item.HPROT.rand_mode(0);

    do_burst(INCR8, WRITE, SEQ);

    IDLE_sequence_h.start(m_sequencer, this);


    /***************************************************************************************/
    //                                 STARTING READ_INCR8
    /**************************************************************************************/       

    // Set the operation type to READ
    start_item(seq_item);
      assert(seq_item.randomize() with { RESET_op == WORKING; WRITE_op == READ; TRANS_op == NONSEQ; BURST_op == INCR8;}); // Randomize the sequence item
    finish_item(seq_item);


    do_burst(INCR8, READ, SEQ);

    IDLE_sequence_h.start(m_sequencer, this);

  endtask : body

endclass
