/******************************************************************
 * File: WRITE_READ_WRAP4_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs a WRAP4 WRITE 
 *              and WRAP4 READ from the same addresses. It inherits from 
 *              `base_sequence` and includes functionality to start 
 *              the reset sequence if needed and perform a the  
 *              operation with randomized sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_READ_WRAP4_sequence extends base_sequence;
  `uvm_object_utils(WRITE_READ_WRAP4_sequence);

  // Static flag to determine if reset is needed
  static bit reset_flag;
  static bit last_test;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;


  // Constructor
  function new(string name = "WRITE_READ_WRAP4_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    $display("start of pre_body task");
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body for executing the write operation
  virtual task body();

    reset_sequence::last_test = 1'b1;

    `uvm_info("WRITE_READ_WRAP4_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

      seq_item.RESET_op.rand_mode(0);
      seq_item.WRITE_op.rand_mode(0);
      seq_item.TRANS_op.rand_mode(0);
      seq_item.BURST_op.rand_mode(0);
      //seq_item.SIZE_op.rand_mode(0);

    /***************************************************************************************/
    //                                 STARTING WRITE_WRAP4
    /**************************************************************************************/   
    start_item(seq_item); // Start the sequence item

      // Set the operation type to WRITE
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = WRITE;
      seq_item.TRANS_op = NONSEQ;
      seq_item.BURST_op = WRAP4;

      assert(seq_item.randomize()); // Randomize the sequence item

    finish_item(seq_item);

    for (int i = 0; i < 3; i++) begin
      start_item(seq_item); // Start the sequence item

        seq_item.SIZE_op.rand_mode(0);
        seq_item.HADDR.rand_mode(0);
        
        // Set the operation type to WRITE
        seq_item.RESET_op = WORKING;
        seq_item.WRITE_op = WRITE;
        seq_item.TRANS_op = SEQ;
        seq_item.BURST_op = WRAP4;

        assert(seq_item.randomize()); // Randomize the sequence item

      finish_item(seq_item);
    end

    start_item(seq_item); // Start the sequence item

      // Set the operation type to READ
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = READ;
      seq_item.TRANS_op = IDLE;
      seq_item.BURST_op = SINGLE;

      // Randomize the sequence item
      assert(seq_item.randomize()); 

    finish_item(seq_item);


    /***************************************************************************************/
    //                                 STARTING READ_WRAP4
    /**************************************************************************************/       

    start_item(seq_item); // Start the sequence item

      // Set the operation type to READ
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = READ;
      seq_item.TRANS_op = NONSEQ;
      seq_item.BURST_op = WRAP4;

      assert(seq_item.randomize()); // Randomize the sequence item

    finish_item(seq_item);

    for (int i = 0; i < 3; i++) begin
      //seq_item.HREAD_rand_c.constraint_mode(0);

      start_item(seq_item); // Start the sequence item

        // Set the operation type to READ
        seq_item.RESET_op = WORKING;
        seq_item.WRITE_op = READ;
        seq_item.TRANS_op = SEQ;
        seq_item.BURST_op = WRAP4;
        assert(seq_item.randomize()); // Randomize the sequence item

      finish_item(seq_item);
    end

     if(~last_test)
      seq_item.last_item = 1'b1;

    start_item(seq_item); // Start the sequence item

      // Set the operation type to READ
      seq_item.RESET_op = WORKING;
      seq_item.WRITE_op = READ;
      seq_item.TRANS_op = IDLE;
      seq_item.BURST_op = SINGLE;
      seq_item.SIZE_op  = BYTE;

      // Randomize the sequence item
      assert(seq_item.randomize()); 

    finish_item(seq_item);

  endtask : body

endclass
