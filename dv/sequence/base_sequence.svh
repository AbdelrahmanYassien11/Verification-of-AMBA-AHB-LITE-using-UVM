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

  base_sequence reset_sequence_h;

  event finished_sequence;

  bit break_burst;

  // Constructor
  function new(string name = "base_sequence");
    super.new(name);
  endfunction

  // Task executed before the main body task
  task pre_body();
    // Display a message indicating the start of the pre_body task
    `uvm_info(get_type_name(), "start of pre_body Task", UVM_HIGH)
    // Create a new instance of the sequence item
    seq_item = sequence_item::type_id::create("seq_item");
  endtask : pre_body



  // Main task body, to be overridden by derived classes
  task body();
    // Report an error if the base_sequence is used directly
    // $fatal(1, "You cannot use base directly. You must override it");
    fork
      response_check();
    join_none

  endtask : body

  virtual task post_body();
    string test_name;
    if(!($value$plusargs("UVM_TESTNAME=%s", test_name))) `uvm_fatal(get_type_name(), "Could not get test_name");
    case (test_name)
      "runall_waited_test": begin
        #10ns;
        `uvm_info(get_type_name(), "waitedd", UVM_LOW)
      end
    endcase
  endtask : post_body

  task response_check();
    // fork
    //   begin
        forever begin
          sequence_item rsp;
          // Wait for the data phase to complete
          get_response(rsp);
          `uvm_info(get_type_name(), {"RESPONSE_RETRIEVED: ", rsp.output2string()}, UVM_MEDIUM)
          `uvm_info(get_type_name(), $sformatf("Sequence ID: %0d", rsp.get_sequence_id()), UVM_MEDIUM)

          if (rsp.HREADY == NOT_READY && rsp.HRESP == ERROR) begin
            `uvm_info(get_type_name(), $sformatf("%0t ERROR DETECTED",$time()), UVM_MEDIUM) //180
            seq_item.ERROR_ON_EXECUTE_IDLE = 1;
            break_burst = 1;
          end
        end
    //   end
    //   begin
    //     #20ns;
    //   end
    // join_any;
    // disable fork;
  endtask : response_check


  task do_burst(input HBURST_e burst_type, input HWRITE_e write_type, input HTRANS_e trans_type);
    repeat(determine_burst_counter(burst_type, trans_type)) begin
      if(break_burst && (~seq_item.ERROR_ON_EXECUTE_IDLE)) begin
        `uvm_info(get_type_name(),$sformatf("%0t BURST BROKEN DUE TO ERROR", $time()), UVM_MEDIUM)
        break; //185
      end
      start_item(seq_item);
        assert(seq_item.randomize() with {RESET_op == WORKING; WRITE_op == write_type; TRANS_op == trans_type; BURST_op == burst_type;});
      finish_item(seq_item);
      if(seq_item.reset_flag && trans_type != NONSEQ) begin
        factory.set_type_override_by_name("base_sequence", "reset_sequence");
        reset_sequence_h = base_sequence::type_id::create("reset_sequence_h");
        `uvm_info("get_type_name()", {"checking the reset_sequence instance",$sformatf("%s",reset_sequence_h.get_full_name())}, UVM_MEDIUM)

        `uvm_info(get_type_name(),"BREAKING BURST WITH RESET", UVM_MEDIUM);
        reset_sequence_h.start(m_sequencer, this);
        `uvm_info(get_type_name(),"RESET MID BURST FINISHED", UVM_MEDIUM);
        break;
      end
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
