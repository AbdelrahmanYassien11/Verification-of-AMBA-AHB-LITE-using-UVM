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
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class sequencer extends uvm_sequencer#(sequence_item);
  `uvm_component_utils(sequencer);

  function new(string name = "sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------------
  // Build phase for component creation, initialization & Setters
  //-------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase completed", UVM_LOW)
    // Additional build phase configuration can be added here
  endfunction

  //---------------------------------------------------------
  // Connect Phase to connect the Enviornment TLM Components
  //---------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase completed", UVM_LOW)
    // Connect ports and exports here
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Run phase started", UVM_LOW)
  endtask

endclass
