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
  // sequence_item seq_item;

  sequence_item pipelined_seq_items [$];
  sequence_item pipelined_seq_items_to_send_back [$];

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
    //seq_item = sequence_item::type_id::create("seq_item");

    $display("my_driver build phase");
  endfunction

  // Connect phase for setting up connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
        my_vif.driver_h = this;
    $display("my_driver connect phase");
  endfunction

  // Run phase where the driver executes and interacts with the DUT
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    do_pipelined_transfers();

    $display("my_driver run phase");
  endtask

  task do_pipelined_transfers();
    sequence_item seq_item;
    forever begin
    // Get the next sequence item from the sequence
      $display("NEXT ITEM PLEASE");
      seq_item_port.get_next_item(seq_item);
      accept_tr(seq_item, $time);
      void'(begin_tr(seq_item, "pipelined_driver"));

      `uvm_info(get_full_name(), { "DRIVEN_ITEM:", seq_item.input2string} , UVM_LOW)
      //$display("HWRITE ========================================================== HWRITE = %0d", seq_item.HWRITE);
      // Send the sequence item data to the DUT via the virtual interface
      my_vif.begin_transfer(seq_item);

      pipelined_seq_items.push_back(seq_item);
      pipelined_seq_items_to_send_back.push_back(seq_item);

      seq_item_port.item_done();
    end
  endtask : do_pipelined_transfers
  
  // Function to complete the sequence item - driver handshake back to the sequence 
  // item, decoupled from the point of the originating request
  function void end_transfer(sequence_item req);
    sequence_item rsp = pipelined_seq_items.pop_front();
    rsp.copy(req);
    //seq_item_port.put(rsp); // End of req item
    end_tr(rsp);
  endfunction: end_transfer

  function void send_tr_back (sequence_item req);
    sequence_item rsp;
    rsp = sequence_item::type_id::create("rsp");
    rsp = pipelined_seq_items_to_send_back.pop_front();
    rsp.copy(req);
    //put_response is a function instead of task:
    seq_item_port.put_response(rsp); // End of req item
  endfunction : send_tr_back

endclass
