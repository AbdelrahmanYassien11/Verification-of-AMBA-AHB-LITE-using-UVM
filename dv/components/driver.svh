/******************************************************************
 * File: driver.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM driver component for 
 *              sending sequence items to the Design Under Test (DUT).
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver);

  // Sequence item to be driven
  sequence_item seq_item;

  // Virtual interface to the DUT
  virtual inf my_vif;

  // Constructor for the driver component
  function new(string name = "driver", uvm_component parent);
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

    $display("my_driver build phase");
  endfunction

  // Connect phase for setting up connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    $display("my_driver connect phase");
  endfunction

  // Run phase where the driver executes and interacts with the DUT
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      // Get the next sequence item from the sequence
      seq_item_port.get_next_item(seq_item);

      // Send the sequence item data to the DUT via the virtual interface
      my_vif.generic_reciever(
        seq_item.rrst_n,
        seq_item.wrst_n,
        seq_item.data_in,
        seq_item.w_en,
        seq_item.r_en,
        seq_item.operation
      );

      // Indicate that the item has been processed
      seq_item_port.item_done();
    end

    $display("my_driver run phase");
  endtask

endclass
