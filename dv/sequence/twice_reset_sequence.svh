/******************************************************************
 * File: twice_reset_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that performs an twice_reset
 *              operation. It inherits from `base_sequence` and includes 
 *              functionality to start the reset sequence if needed 
 *              and perform an twice_reset operation with randomized 
 *              sequence item values.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class twice_reset_sequence extends base_sequence;
  `uvm_object_utils(twice_reset_sequence);
  
  // Static flag to determine if reset is needed
  static bit reset_flag;

  // Handle to the reset sequence
  reset_sequence reset_sequence_h;

  // Constructor
  function new(string name = "twice_reset_sequence");
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

    `uvm_info("twice_reset_sequence: ", "STARTING" , UVM_HIGH)

    if(~reset_flag)
      reset_sequence_h.start(sequencer_h);

    repeat(2) begin
      reset_sequence_h.start(m_sequencer, this);
    end

  endtask : body

endclass
