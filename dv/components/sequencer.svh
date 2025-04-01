/******************************************************************
 * File: sequencer.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines a sequencer for a UVM testbench. 
 *              The sequencer is responsible for managing the sequence 
 *              items and starting sequences. It includes phases for 
 *              building, connecting, and running the sequencer, with 
 *              placeholders for additional configuration and logic.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class sequencer extends uvm_sequencer#(sequence_item);
  `uvm_component_utils(sequencer);

  function new(string name = "sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQUENCER", "Build phase executed", UVM_MEDIUM)
    // Additional build phase configuration can be added here
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SEQUENCER", "Connect phase executed", UVM_MEDIUM)
    // Connect ports and exports here
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SEQUENCER", "Run phase started", UVM_MEDIUM)
  endtask

endclass
