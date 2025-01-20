/******************************************************************
 * File: WRITE_READ_INCR16_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a INCR16 WRITE 
 *              and INCR16 READ from the same addresses. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a the  
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_READ_INCR16_sequence extends base_sequence;
  `uvm_object_utils(WRITE_READ_INCR16_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;
  IDLE_sequence IDLE_sequence_h;


  // Constructor
  function new(string name = "WRITE_READ_INCR16_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
    IDLE_sequence_h  = IDLE_sequence::type_id::create("IDLE_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    reset_sequence::last_test = 1'b1;
    IDLE_sequence::last_test = 1'b1;
    IDLE_sequence::reset_flag = 1'b1;

    //READ_INCR16_sequence::last_test = 1'b1;
    `uvm_info("WRITE_READ_INCR16_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    /***************************************************************************************/
    //                                 STARTING WRITE_INCR16
    /**************************************************************************************/      

    start_item(seq_item); // Start the sequence item

      // Set the operation type to WRITE
      // Randomize the sequence item
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == WRITE; TRANS_op == NONSEQ; BURST_op == INCR16;});

    finish_item(seq_item);

    IDLE_sequence_h.HADDR_reserve = seq_item.HADDR;
    seq_item.SIZE_op.rand_mode(0);
    seq_item.HADDR.rand_mode(0);

    //IDLE_sequence_h.seq_item.do_copy(seq_item);

    for (int i = 0; i < 15; i++) begin
      start_item(seq_item); // Start the sequence item

      // Set the operation type to WRITE
      // Randomize the sequence item
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == WRITE; TRANS_op == SEQ; BURST_op == INCR16;});

      finish_item(seq_item);
    end

    //Starting IDLE sequence
    IDLE_sequence_h.start(m_sequencer, this);

    /***************************************************************************************/
    //                                 STARTING READ_INCR16
    /**************************************************************************************/
    start_item(seq_item); // Start the sequence item

      // Set the operation type to READ
      // Randomize the sequence item
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == READ; TRANS_op == NONSEQ; BURST_op == INCR16;});

    finish_item(seq_item);

    for (int i = 0; i < 15; i++) begin

      start_item(seq_item); // Start the sequence item
        
      // Set the operation type to READ
      // Randomize the sequence item
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == READ; TRANS_op == SEQ; BURST_op == INCR16;});

      finish_item(seq_item);
    end

    if(~last_test)
      seq_item.last_item = 1'b1;

    IDLE_sequence_h.start(m_sequencer, this);

  endtask : body

endclass
