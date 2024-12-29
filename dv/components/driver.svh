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

  sequence_item req_seq_items [$];

  sequence_item unchanged;


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
    unchanged = sequence_item::type_id::create("unchanged");

    $display("my_driver build phase");
  endfunction

  // Connect phase for setting up connections between components
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    my_vif.driver_h = this;
    $display("my_driver connect phase");
  endfunction

  // function to create interface sequence items
  // function void create_sequence_item();
  //   //$display("CREATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
  //   my_vif.seq_item = sequence_item::type_id::create("seq_item");
  //   my_vif.previous_seq_item = sequence_item::type_id::create("previous_seq_item");
  // endfunction

  // Run phase where the driver executes and interacts with the DUT
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // forever begin
    //   // Get the next sequence item from the sequence
    //   seq_item_port.get_next_item(seq_item);

      // unchanged = seq_item.clone_me();
      // req_seq_items.push_back(unchanged);

      // accept_tr(req, $time);
      // void'(begin_tr(req, "pipelined_driver"));

      do_pipelined_transfers();
      // #1ps
      //$display("HWRITE ========================================================== HWRITE = %0d", seq_item.HWRITE);
      // Send the sequence item data to the DUT via the virtual interface
      // my_vif.generic_reciever(seq_item);

      // // Indicate that the item has been processed
      // if(my_vif.counter === 0) begin
      //   $display("%0t RESPONSE: RESET", $time());
      //   rsp.do_copy(req_seq_items.pop_front());
      //   rsp.HRESP  = my_vif.HRESP;
      //   rsp.HREADY = my_vif.HREADY;
      //   rsp.HRDATA = my_vif.HRDATA;
      //   seq_item_port.item_done(rsp);        
      // end
      // else if(my_vif.counter >= 5) begin
      //   $display("%0t RESPONSE: NORMAL", $time());
      //   rsp.do_copy(req_seq_items.pop_front());
      //   rsp.HRESP  = my_vif.HRESP;
      //   rsp.HREADY = my_vif.HREADY;
      //   rsp.HRDATA = my_vif.HRDATA;
      //   seq_item_port.item_done(rsp);
      // end
      // else begin
      //   $display("%0t NO_RESPONSE: ",$time());
      //   seq_item_port.item_done();
      // end
      // seq_item_port.item_done();

    // end

    $display("my_driver run phase");
  endtask


  task do_pipelined_transfers();
    sequence_item req;
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_full_name(), { "DRIVEN_ITEM:", req.input2string} , UVM_LOW)
      accept_tr(req, $time);
      void'(begin_tr(req, "pipelined_driver"));

      // This blocking call performs the cmd phase of the request and then returns
      // right away before completing the data phase, thus allowing the cmd phase of 
      // the subsequent request (next loop iteration) to occur in parallel with the 
      // data phase of the current request, and so implementing the pipeline
      my_vif.begin_transaction(req);
      req_seq_items.push_back(req);
      seq_item_port.item_done();
    end
  endtask: do_pipelined_transfers

  // Function to complete the sequence item - driver handshake back to the sequence 
  // item, decoupled from the point of the originating request
  function void end_transfer(sequence_item req);
    sequence_item rsp = req_seq_items.pop_front();
    rsp.copy(req);
    //seq_item_port.put(rsp); // End of req item
    //put_response is a function instead of task:
    seq_item_port.put_response(rsp); // End of req item
    end_tr(rsp);
  endfunction: end_transfer

  // function void end_transfer(sequence_item req);
  //   sequence_item rsp = req_seq_items.pop_front();
  //   rsp.copy(req);
  //   //seq_item_port.put(rsp); // End of req item
  //   //put_response is a function instead of task:
  //   seq_item_port.put_response(rsp); // End of req item
  //   end_tr(rsp);
  // endfunction: end_transfer

endclass
