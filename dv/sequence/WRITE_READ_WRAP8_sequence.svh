/******************************************************************
 * File: WRITE_READ_WRAP8_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a WRAP8 WRITE 
 *              and WRAP8 READ from the same addresses. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a the  
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_READ_WRAP8_sequence extends base_sequence;
  `uvm_object_utils(WRITE_READ_WRAP8_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  IDLE_sequence IDLE_sequence_h;


  // Constructor
  function new(string name = "WRITE_READ_WRAP8_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
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
      reset_sequence_h.start(m_sequencer, this);

    /***************************************************************************************/
    //                                 STARTING WRITE_WRAP8
    /**************************************************************************************/   

    // Set the operation type to WRITE
    do_burst(WRAP8, WRITE, NONSEQ);
    
    IDLE_sequence_h.HADDR_reserve = {seq_item.SEL_op,seq_item.HADDRx};
    seq_item.SIZE_op.rand_mode(0);
    seq_item.SEL_op.rand_mode(0);
    seq_item.HADDRx.rand_mode(0);
    seq_item.HPROT.rand_mode(0);

    do_burst(WRAP8, WRITE, SEQ);

    IDLE_sequence_h.start(m_sequencer, this);


    /***************************************************************************************/
    //                                 STARTING READ_WRAP8
    /**************************************************************************************/       

    do_burst(WRAP8, READ, NONSEQ);

    do_burst(WRAP8, READ, SEQ);

    IDLE_sequence_h.start(sequencer_h);

  endtask : body

endclass
