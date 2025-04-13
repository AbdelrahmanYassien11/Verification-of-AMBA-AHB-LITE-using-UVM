/******************************************************************
 * File: IDLE_sequence.svh
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

class IDLE_sequence extends base_sequence;
  `uvm_object_utils(IDLE_sequence);
  // Static flag to determine if reset is needed
  static bit reset_flag;
  bit [ADDR_WIDTH-1:0] HADDR_reserve;


  // Handle to the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "IDLE_sequence");
    super.new(name);
  endfunction

  // Pre-body phase task for setup operations
  task pre_body();
    `uvm_info(get_type_name, "start of pre_body task", UVM_HIGH)
    super.pre_body(); // Call the base class pre_body
    // Create an instance of the reset sequence
    reset_sequence_h = reset_sequence::type_id::create("reset_sequence_h");
  endtask : pre_body

  // Main task body for executing the READ operation
  virtual task body();
    super.body();
    `uvm_info(get_type_name(),$sformatf("HADDR_reserve = %0h",HADDR_reserve), UVM_HIGH);


    `uvm_info("IDLE_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);


    seq_item.SIZE_op.rand_mode(0);
    
    start_item(seq_item); // Start the sequence item

    `uvm_info(get_type_name(),$sformatf("seq_item.HADDR = %0d",seq_item.HADDR), UVM_HIGH);

    if(HADDR_reserve[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] != 'h0) begin
      // Randomize the sequence item
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == READ; TRANS_op == IDLE; BURST_op == SINGLE; SEL_op == HADDR_reserve[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES]; HADDRx == HADDR_reserve[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];});
    end
    else begin
      assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == READ; TRANS_op == IDLE; BURST_op == SINGLE;});      
    end
    finish_item(seq_item);


  endtask : body

  virtual task post_body();
  endtask : post_body

endclass
