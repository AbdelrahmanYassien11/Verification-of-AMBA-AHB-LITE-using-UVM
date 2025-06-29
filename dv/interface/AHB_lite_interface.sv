/******************************************************************
 * File: inf.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/12/2024
 * Description: This interface provides control and monitoring 
 *              for a AHB (First-In-First-Out) memory module. 
 *              It includes tasks for AHB operations such as reading, 
 *              writing, and resetting. The interface also contains 
 *              assertions to validate the AHB's status signals (full 
 *              and empty) and functions for sending input and output 
 *              data to monitors.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/
`timescale 1ns/1ns

interface inf (input bit clk);

import AHB_pkg::*;                  // Import AHB package for AHB constants

// AHB lite Control Signals
logic   HRESETn;    // reset (active low)

bit   HWRITE;

bit   [TRANS_WIDTH-1:0]  HTRANS; 
bit   [SIZE_WIDTH-1:0]  HSIZE;
bit   [BURST_WIDTH-1:0]  HBURST;
bit   [PROT_WIDTH-1:0]  HPROT; 

bit   [ADDR_WIDTH-1:0]  HADDR;     
bit   [DATA_WIDTH-1:0]  HWDATA; 

// AHB lite output Signals
logic   [DATA_WIDTH-1:0]  HRDATA;
logic   [RESP_WIDTH-1:0]  HRESP; 
logic   [READY_WIDTH-1:0]  HREADY;
bit         [ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] HSEL;
  bit         [BITS_FOR_SUBORDINATES-1:0] HSELx;

// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor

//Enums to observe inputs and make it readable through the waveform
HRESET_e     RESET_op;
HWRITE_e     WRITE_op;
HTRANS_e     TRANS_op;
HBURST_e     BURST_op;
HSIZE_e      SIZE_op;
//HPROT_e      PROT_op;
HSEL_e       SEL_op;

//Enums to observe output and make it readable through the waveform
HRESP_e      RESP_op;
HREADY_e     READY_op;

//Previous Seq_item used in case of needing to resend the past transaction (not tested).
sequence_item_trial previous_seq_item;

//Pipelined seq_items, each handing its properties to the rest over the course of the Address & Data Phase
sequence_item_trial pipeline1, pipeline2, pipeline3, pipeline4;
	
//To monitor the current req status globally, does not seem to be of any use, but elt's kep it for now
sequence_item_trial global_req;

// A handle from the driver to be able to call end_transfer function to send back responses
driver driver_h;

//to prevent race conditions between Address & Data Phases
bit key1;

// Event to continue sending stimulus when the reset is finished
event reset_finished;

//Events to control the always begin block of each phase
event dataPhase_event, samplingPhase_event;

  modport SVA (input clk, HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY);



    task generic_reciever( sequence_item req);
    	global_req.do_copy(req);  
    	$display("req: %0s",req.convert2string());
    	pipeline1.do_copy(req);
    	//$display("[INTERFACE] PIPELINE1: %s", pipeline1.input2string);
    	send_inputs(pipeline1);
    	addressPhase(req);

    	lock1();

    	-> dataPhase_event;

    endtask : generic_reciever


	task addressPhase(sequence_item addressPhase_req);

		HRESETn <= addressPhase_req.RESET_op;
		HWRITE  <= addressPhase_req.WRITE_op;
		HTRANS  <= addressPhase_req.TRANS_op;
		HSIZE   <= addressPhase_req.SIZE_op;
		HBURST  <= addressPhase_req.BURST_op;

		HPROT   <= addressPhase_req.HPROT;
		HADDR   <= {addressPhase_req.SEL_op, addressPhase_req.HADDRx};

        RESET_op <= addressPhase_req.RESET_op;
        WRITE_op <= addressPhase_req.WRITE_op;
        TRANS_op <= addressPhase_req.TRANS_op;
        BURST_op <= addressPhase_req.BURST_op;
        SEL_op   <= addressPhase_req.SEL_op;

		@(posedge clk);

		while((~HREADY) && (HRESP == OKAY)) begin
			$display("%0t:	Address Phase: Waiting for READY & OKAY ",$time());
			@(posedge clk);
		end
	endtask : addressPhase

	always begin
		@(dataPhase_event);
		dataPhase(pipeline1);
		pipeline2.do_copy(pipeline1);
		//$display("[INTERFACE] PIPELINE2: %s", pipeline2.input2string);
		unlock1();

		-> samplingPhase_event;

	end

	task dataPhase(sequence_item dataPhase_req);
		if(dataPhase_req.HWRITE)begin
			HWDATA = dataPhase_req.HWDATA;
		end
		while ((~HREADY) && (HRESP == OKAY)) begin
			$display("%0t:	Data Phase: Waiting for READY & OKAY ",$time());
			@(posedge clk);
		end
	endtask : dataPhase

	always begin
		@(samplingPhase_event);

		pipeline3.do_copy(pipeline2);
		$display("[INTERFACE] PIPELINE3: %s", pipeline3.input2string);
		@(negedge clk);
		#1ns;
		if(~(pipeline3.HRESETn && pipeline2.HRESETn && pipeline1.HRESETn)) begin
			@(reset_finished);
		end
		pipeline4.do_copy(pipeline3);
		pipeline4.HRESP  = HRESP;
		pipeline4.HRDATA = HRDATA;
		pipeline4.HREADY = HREADY;
        // RESP_op  = HRESP_e'(HRESP);
        // READY_op = HREADY_e'(HREADY);
		driver_h.end_transfer(pipeline4);
		send_outputs(pipeline4);
	end

	function void lock1();
		key1 = 0;
	endfunction : lock1

	task unlock1();
		if(key1) begin
			@(posedge clk);
		end
		key1 = 1;
	endtask : unlock1

    // Function to send inputs to the input monitor
    function void send_inputs( sequence_item input_req);

    	previous_seq_item.do_copy(input_req);
        inputs_monitor_h.write_to_monitor(input_req);
    endfunction : send_inputs

    // Function to send outputs to the output monitor
    function void send_outputs(sequence_item outputs_req);
        outputs_monitor_h.write_to_monitor(outputs_req);
    endfunction : send_outputs

    function void create_sequence_item_trial();
        previous_seq_item = sequence_item_trial::type_id::create("previous_seq_item");
        pipeline1 = sequence_item_trial::type_id::create("pipeline1");
        pipeline2 = sequence_item_trial::type_id::create("pipeline2");
        pipeline3 = sequence_item_trial::type_id::create("pipeline3");
        global_req = sequence_item_trial::type_id::create("global_req");
        pipeline4 = sequence_item_trial::type_id::create("pipeline4");
    endfunction

    initial begin
        create_sequence_item_trial();
        HRESETn <= 1'b1;
    end


    assign RESP_op  = HRESP_e'(HRESP);
    assign READY_op = HREADY_e'(HREADY);

endinterface : inf

