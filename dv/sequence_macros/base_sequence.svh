/******************************************************************
 * File: base_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This is an abstract base sequence class that serves
 *              as a foundation for other sequences. It defines common
 *              functionality for all sequences, including initialization
 *              of sequence items and setup tasks. It is intended to be
 *              extended by other sequence classes which should override
 *              the `body` task to provide specific sequence behavior.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class base_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(base_sequence)

  // Handle to the sequencer that will be used by the sequence
  sequencer sequencer_h;

  // Sequence item to be used within the sequence
  sequence_item seq_item;

  // Constructor
  function new(string name = "base_sequence");
    super.new(name);
  endfunction

  // Task executed before the main sequence body
  task pre_body();
    $display("start of pre_body task");
    // Create an instance of the sequence item for this sequence
    seq_item = sequence_item::type_id::create("seq_item");
  endtask : pre_body

  // Main task where the sequence logic is defined
  task body();
    // This is an abstract task; it should be overridden in derived classes
    $fatal(1, "You cannot use base directly. You must override it");
  endtask : body

endclass : base_sequence
