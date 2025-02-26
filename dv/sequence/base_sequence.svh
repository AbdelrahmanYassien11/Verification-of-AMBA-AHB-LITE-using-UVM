/******************************************************************
 * File: base_sequence.svh
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class serves as a base class for UVM sequences.
 *              It provides common functionality and should be 
 *              extended by other sequence classes. It includes
 *              basic methods for initialization and sequence execution.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class base_sequence extends uvm_sequence #(sequence_item);
  `uvm_object_utils(base_sequence)

  // Handle for the sequence item used in this sequence
  sequence_item seq_item;
  sequencer sequencer_h;
  sequencer burst_sequencer_h;
  sequencer runall_sequencer_h;

  bit break_burst;

  // Constructor
  function new(string name = "base_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Display a message indicating the start of the pre_body task
    $display("start of pre_body task");
    // Create a new instance of the sequence item
    seq_item = sequence_item::type_id::create("seq_item");
  endtask : pre_body



  // Main task body, to be overridden by derived classes
  task body();
    // Report an error if the base_sequence is used directly
    // $fatal(1, "You cannot use base directly. You must override it");
    fork
      ccheck_response();
    join_none

  endtask : body

  task ccheck_response();
    forever begin
      sequence_item rsp;
      // Wait for the data phase to complete
      get_response(rsp);
      //`uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)

      `uvm_info("SEQUENCE", {"RESPONSE_RETRIEVED: ", rsp.output2string()}, UVM_LOW)

      if (rsp.HREADY == NOT_READY && rsp.HRESP == ERROR) begin
        $display("%0t ERROR DETECTED",$time()); //180
        seq_item.ERROR_ON_EXECUTE_IDLE = 1;
        break_burst = 1;
      end
    end
  endtask : ccheck_response


  // task add_burst_constraints(input IDLE_sequence X);
  //   X.HADDR_reserve = seq_item.HADDR;
  //   seq_item.SIZE_op.rand_mode(0);
  //   seq_item.HADDR.rand_mode(0);
  //   seq_item.HPROT.rand_mode(0);
  // endtask : add_burst_constraints

  task do_burst(input HBURST_e burst_type, input HWRITE_e write_type, input HTRANS_e trans_type);
    repeat(determine_burst_counter(burst_type, trans_type)) begin
      if(break_burst && (~seq_item.ERROR_ON_EXECUTE_IDLE)) begin
        $display("BURST BROKEN %0t",$time());
        break; //185
      end
      start_item(seq_item);
        assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == write_type; TRANS_op == trans_type; BURST_op == burst_type;});
        $display("atlas %0t", $time()); //175
      finish_item(seq_item);
    end
    break_burst = 0;
  endtask : do_burst

  function int determine_burst_counter (input HBURST_e burst_type, input HTRANS_e trans_type);
    if(trans_type == NONSEQ) begin
      return 1;
    end
    else begin
      case (burst_type)
        //SINGLE:         return 0;
        INCR:           return seq_item.INCR_CONTROL;
        WRAP4, INCR4:   return  3;
        WRAP8, INCR8:   return  7;
        WRAP16, INCR16: return 15;
      endcase
    end
  endfunction : determine_burst_counter


endclass : base_sequence
