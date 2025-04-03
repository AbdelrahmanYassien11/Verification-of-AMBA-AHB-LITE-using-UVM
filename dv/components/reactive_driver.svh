/******************************************************************
 * File: reactive_driver.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This class defines a UVM reactive_driver component for 
 *              sending sequence items to the Design Under Test (DUT).
 * 
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class reactive_driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(reactive_driver);

  // Sequence item to be driven
  sequence_item seq_item;

  // Virtual interface to the DUT
  virtual inf my_vif;

  // Constructor for the reactive_driver component
  function new(string name = "reactive_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase for component setup and initialization
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual inf)::get(this, "", "my_vif", my_vif)) begin
      `uvm_fatal(get_full_name(), "Error retrieving virtual interface");
    end

    // Create an instance of sequence_item
    seq_item = sequence_item::type_id::create("seq_item");

    $display("my_reactive_driver build phase");
  endfunction

  // Connect phase for setting up connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    $display("my_reactive_driver connect phase");
  endfunction

  // Run phase where the reactive_driver executes and interacts with the DUT
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // forever begin
    //   // Get the next sequence item from the sequence
    //   // seq_item_port.get_next_item(seq_item);

    //   // #1ps
    //   // `uvm_info(get_full_name(), { "DRIVEN_ITEM:", seq_item.input2string} , UVM_LOW)
    //   // //$display("HWRITE ========================================================== HWRITE = %0d", seq_item.HWRITE);
    //   // // Send the sequence item data to the DUT via the virtual interface
    //   // my_vif.generic_reciever( seq_item.HRESETn, seq_item.HWRITE, seq_item.HTRANS, seq_item.HSIZE, seq_item.HBURST, seq_item.HPROT,
    //   //                          seq_item.HADDR, seq_item.HWDATA, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, 
    //   //                          seq_item.SIZE_op, seq_item.last_item );

    //   // // Indicate that the item has been processed
    //   // seq_item_port.item_done();
    // end

    $display("my_reactive_driver run phase");
  endtask

endclass
