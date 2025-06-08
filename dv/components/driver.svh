/******************************************************************
 * File: driver.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines a UVM driver component for 
 *              sending sequence items to the Design Under Test (DUT).
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver);

  // Sequence item to be driven
  sequence_item seq_item;
  event finished;


  // Virtual interface to the DUT
  virtual inf my_vif;

  // req seq_item queue to store input stimulus and assign it to the RSP item that is sent to the sequence
  local sequence_item req_seq_items [$];


  // Constructor for the driver component
  function new(string name = "driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  //-------------------------------------------------------------
  // Build phase for component creation, initialization & Setters
  //-------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual inf)::get(this, "", "my_vif", my_vif)) begin
      `uvm_fatal(get_full_name(), "Error retrieving virtual interface");
    end

    // Create an instance of sequence_item
    seq_item = sequence_item::type_id::create("seq_item");

    `uvm_info(get_type_name(), "Build phase completed", UVM_LOW)
  endfunction

  //---------------------------------------------------------
  // Connect Phase to connect the Enviornment TLM Components
  //---------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    my_vif.driver_h = this;
    `uvm_info(get_type_name(), "Connect phase completed", UVM_LOW)
  endfunction

  //--------------------------------------------------------------------
  // Run phase: The Driver sends stimulus to the DUT & samples responses
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    //super.run_phase(phase);
    sequence_item req;
    `uvm_info(get_type_name(), "Run phase Started", UVM_LOW)
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), { "DRIVEN_ITEM:", req.input2string} , UVM_LOW)
      accept_tr(req, $time);
      void'(begin_tr(req, "pipelined_driver"));

      // This blocking call performs the cmd phase of the request and then returns
      // right away before completing the data phase, thus allowing the cmd phase of 
      // the subsequent request (next loop iteration) to occur in parallel with the 
      // data phase of the current request, and so implementing the pipeline
      req_seq_items.push_back(req);
      my_vif.generic_reciever(req);


      wait_for_reset(req);
      seq_item_port.item_done();
    end

  endtask

  //------------------------------------------------
  // Function to wait for reset if it gets asserted
  //------------------------------------------------
  task wait_for_reset(sequence_item req_reset);
    if(~req_reset.HRESETn) begin
      repeat(15) begin
        @(posedge my_vif.clk);
      end
      -> my_vif.reset_finished;
    end
    // else begin
    //   (@negedge my_vif.clk);
    //   -> my_vif.reset_finished;
    // end
  endtask : wait_for_reset

  //------------------------------------------------------------------------------------------------------------------------------------------
  // Function to complete the sequence item - driver handshake back to the sequence item, decoupled from the point of the originating request 
  //------------------------------------------------------------------------------------------------------------------------------------------
  function void end_transfer(sequence_item t);
    sequence_item rsp;
    `uvm_info(get_type_name(),$sformatf("QUEUE SIZE: %0d",req_seq_items.size()), UVM_LOW)
    rsp = req_seq_items.pop_front();
    rsp.do_copy(t);
    //seq_item_port.put(rsp); // End of req item
    //put_response is a function instead of task:
    seq_item_port.put_response(rsp); // End of req item 
    end_tr(rsp);
  endfunction: end_transfer

endclass
