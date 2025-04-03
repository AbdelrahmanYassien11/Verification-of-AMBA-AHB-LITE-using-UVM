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

logic   HRESETn_reg;    // reset (active low)

bit   HWRITE_reg;

bit   [TRANS_WIDTH-1:0]  HTRANS_reg; 
bit   [SIZE_WIDTH-1:0]  HSIZE_reg;
bit   [BURST_WIDTH-1:0]  HBURST_reg;
bit   [PROT_WIDTH-1:0]  HPROT_reg; 

bit   [ADDR_WIDTH-1:0]  HADDR_reg;     
bit   [DATA_WIDTH-1:0]  HWDATA_reg; 

// AHB lite output Signals
logic   [DATA_WIDTH-1:0]  HRDATA_reg;
logic   [RESP_WIDTH-1:0]  HRESP_reg; 
logic   [READY_WIDTH-1:0]  HREADY_reg; 

bit RECEIVING_PHASE_FLAG;
bit CONTROL_PHASE_FLAG;
bit DATA_PHASE_FLAG;
bit OUTPUTS_PHASE_FLAG_1;
bit OUTPUTS_PHASE_FLAG_2;

// bit last_test;
// int atlas;

// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor

logic HRESETn_global;

HRESET_e     RESET_op;
HWRITE_e     WRITE_op;
HTRANS_e     TRANS_op;
HBURST_e     BURST_op;
HSIZE_e      SIZE_op;
//HPROT_e      PROT_op;
HSEL_e       SEL_op;

HRESP_e      RESP_op;
HREADY_e     READY_op;

int counter;

sequence_item previous_seq_item, seq_item;
sequence_item pipeline1, pipeline2, pipeline3, atlas;
	
sequence_item global_req;

driver driver_h;
string s;

bit key1;
event reset_finished;

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

		HRESETn <= addressPhase_req.HRESETn;
		HWRITE  <= addressPhase_req.HWRITE;
		HTRANS  <= addressPhase_req.HTRANS;
		HSIZE   <= addressPhase_req.HSIZE;
		HBURST  <= addressPhase_req.HBURST;
		HPROT   <= addressPhase_req.HPROT;
		HADDR   <= addressPhase_req.HADDR;

        RESET_op <= addressPhase_req.RESET_op;
        WRITE_op <= addressPhase_req.WRITE_op;
        TRANS_op <= addressPhase_req.TRANS_op;
        BURST_op <= addressPhase_req.BURST_op;
        SEL_op   <= addressPhase_req.SEL_op;

		@(posedge clk);
        
		while((~HREADY) && (HRESP == OKAY)) begin
			$display("ANNA1 %0t",$time());
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
			$display("ANNA2 %0t",$time());
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
		atlas.do_copy(pipeline3);
		//@(negedge clk);
		// wait(pipeline1.HRESETn && pipeline2.HRESETn && pipeline3.HRESETn);
		atlas.HRESP  = HRESP;
		atlas.HRDATA = HRDATA;
		atlas.HREADY = HREADY;
        // RESP_op  = HRESP_e'(HRESP);
        // READY_op = HREADY_e'(HREADY);
		//atlas = pipeline3.clone_me();
		driver_h.end_transfer(atlas);
		send_outputs(atlas);
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







	// always begin
	// 	if(~global_req.HRESETn) begin
	// 		repeat(15) begin
	// 			@(posedge clk);
	// 		end
	// 	end
	// end






















// Task: Handle generic receiving operations based on reset and enable signals
    // task generic_reciever( sequence_item req);  

    //     wait((counter == 0 || counter >= 2) && CONTROL_PHASE_FLAG );
    //     //#1step;
    //     if(HRESP === RETRY) begin
    //         seq_item.do_copy(previous_seq_item);
    //     end
    //     else begin
    //         seq_item.do_copy(req);
    //        // $display("RECIEVING PHASE: ASSSINGING RANDOMIZED VALUES");
    //     end

    //         HRESETn_global      = seq_item.HRESETn;

    //         pipeline1.do_copy(seq_item);
    //         //$display("[INTERFACE] PIPELINE1: %s", pipeline1.input2string);
    //         //$sformatf("[INTERFACE] PIPELINE1: %s", pipeline1.input2string());   
    //         if(seq_item.HRESETn && seq_item.HBURST == SINGLE) begin
    //             counter = counter + 2;
    //         end
    //         else if(seq_item.HRESETn) begin
    //             counter = counter + 1;
    //         end
    //         if(~HRESETn_global) begin
    //             fork
    //                 begin
    //                     @(negedge clk);
    //                     send_inputs(seq_item.HRESETn, seq_item.HWRITE, seq_item.HTRANS, seq_item.HSIZE, seq_item.HBURST, seq_item.HPROT, seq_item.HADDR, seq_item.HWDATA, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);
    //                 end
    //             join_none
    //         end
            

    //     RECEIVING_PHASE_FLAG = 1;

    //     if(seq_item.last_item)begin
    //         //$display("RECIEVING PHASE: TIME: %0t WAITING FOR COUNTERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",$time());
    //         wait(HRESETn && !RECEIVING_PHASE_FLAG && (sequence_item::COMPARATOR_transaction_counter == sequence_item::PREDICTOR_transaction_counter /*&& HREADY*/) /*&& !OUTPUTS_PHASE_FLAG && !DATA_PHASE_FLAG*/); //so the driver doesnt keep driving when the sequence is already driven to the interface/dut
    //     end
    //     else begin
    //         //$display("RECIEVING PHASE: TIME: %0t WAITING FOR CONTROL PHASE TO transaction_finished",$time());
    //         if(HREADY == NOT_READY && HRESP == OKAY) begin
    //             $display("RECEIVING_PHASE: WAITING FOR HREADY", $time());
    //             wait(HREADY && HRESETn && !RECEIVING_PHASE_FLAG);
    //         end
    //         else begin
    //             wait(HRESETn && !RECEIVING_PHASE_FLAG /*&& HREADY*/);
    //         end
    //     end
    // endtask : generic_reciever


    // always@(posedge clk or negedge HRESETn_global ) begin //CONTROL_PHASE
    //     if(HRESETn_global /*&& HREADY*/)begin
    //         if(counter >= 1 && RECEIVING_PHASE_FLAG) begin
    //             //$display("CONTROL PHASE: TIME:%0t ASSIGINING SIGNALS", $time());
    //          		HRESETn <= seq_item.HRESETn;
    //                 HWRITE  <= seq_item.HWRITE;
    //                 HTRANS  <= seq_item.HTRANS;
    //                 HSIZE   <= seq_item.HSIZE;
    //                 HBURST  <= seq_item.HBURST;
    //                 HPROT   <= seq_item.HPROT;
    //                 HADDR   <= seq_item.HADDR;

    //                 HRESETn_reg <= seq_item.HRESETn;
    //                 HWRITE_reg  <= seq_item.HWRITE;
    //                 HTRANS_reg  <= seq_item.HTRANS;
    //                 HSIZE_reg   <= seq_item.HSIZE;
    //                 HBURST_reg  <= seq_item.HBURST;
    //                 HPROT_reg   <= seq_item.HPROT;
    //                 HADDR_reg   <= seq_item.HADDR;
    //                 HWDATA_reg  <= seq_item.HWDATA;

    //                 //$sformatf("[INTERFACE] PIPELINE1: %s", pipeline1.input2string());
    //                 //$display("[INTERFACE] PIPELINE1: %s", pipeline1.input2string);            
    //                 pipeline2.do_copy(pipeline1);
    //                 //$sformatf("[INTERFACE] PIPELINE2: %s", pipeline2.input2string());
    //                 //$display("[INTERFACE] PIPELINE2: %s", pipeline2.input2string);

    //                 //$display("seq_item.HADDR: %0h ", seq_item.HADDR);

    //                 send_inputs(seq_item.HRESETn, seq_item.HWRITE, seq_item.HTRANS, seq_item.HSIZE, seq_item.HBURST, seq_item.HPROT, seq_item.HADDR, seq_item.HWDATA, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);


    //             if(seq_item.HRESETn) begin
    //                 counter = counter + 1;
    //                 DATA_PHASE_FLAG = 1;
    //             end
    //         end
    //         CONTROL_PHASE_FLAG = 1; //probably obslete
    //         RECEIVING_PHASE_FLAG = 0;
    //     end
    //     else begin
    //         HRESETn <= seq_item.HRESETn; //forced design reset at the start of any sim
    //         HADDR   <= seq_item.HADDR;
    //         CONTROL_PHASE_FLAG = 1;
    //     end
    //     if(HREADY == NOT_READY && HRESP == OKAY) begin
    //         $display("CONTROL_PHASE: WAITING FOR HREADY", $time());
    //         wait(HREADY);
    //     end
    // end

    // always@(negedge HRESETn_global) begin
    //     //$display("DATA_PHASE: TIME:%0t ASSERTING RESET", $time());
    //     //$sformatf("[INTERFACE] PIPELINE1: %s", pipeline1.input2string());
    //     //$display("[INTERFACE] PIPELINE1: %s", pipeline1.input2string);        
    //     pipeline2.do_copy(pipeline1);
    //     //$sformatf("[INTERFACE] PIPELINE2: %s", pipeline2.input2string());
    //     //$display("[INTERFACE] PIPELINE2: %s", pipeline2.input2string);
    //     reset_AHB();
    // end

    // // Task: Reset AHB pointers and flags
    // task reset_AHB();
    //     repeat(15) begin
    //         @(posedge clk);
    //     end
    //     HRESETn_global = 1'b1; //to prevent the control phase always block from re-itterating right after finishing the reset_task & before a new sequence is driven (it causes an endless)
    //     HRESETn <= 1'b1;
    //     counter = 0;
    // endtask : reset_AHB

    // always@(posedge HRESETn_global) begin
    //     //$display("OUTPUT_PHASE_RESET: TIME:%0t SENDING OUTPUTS", $time());
    //     send_outputs();
    //     pipeline2.HREADY = HREADY;
    //     pipeline2.HRDATA = HRDATA;
    //     pipeline2.HRESP  = HRESP;
    //     //$sformatf("[INTERFACE] PIPELINE2: %s", pipeline2.output2string());
    //     //$sformatf("[INTERFACE] PIPELINE2: %s", pipeline2.input2string());
    //     //$display("[INTERFACE] PIPELINE2: %s", pipeline2.output2string);
    //     //$display("[INTERFACE] PIPELINE2: %s", pipeline2.input2string);
    //     driver_h.end_transfer(pipeline2);

    //     OUTPUTS_PHASE_FLAG_1 = 0;
    //     OUTPUTS_PHASE_FLAG_2 = 0;
    //     //OUTPUTS_PHASE_FLAG_3 = 0;
    // end

    // always@(posedge clk) begin //DATA_PHASE //DATA_PHASE_FLAG might be obselete
    //     if((counter >= 3) && (HRESETn === 1) /*&& DATA_PHASE_FLAG*/ /*&& HREADY*/) begin // HRESETn to make it work after the reset cycle is done
    //         //$display("DATA_PHASE: TIME:%0t ASSIGNING SIGNALS", $time());
    //         //$sformatf("[INTERFACE] PIPELINE2: %s", pipeline2.input2string());
    //         //$display("[INTERFACE] PIPELINE2: %s", pipeline2.input2string);
    //         pipeline3.do_copy(pipeline2);
    //         // $sformatf("[INTERFACE] PIPELINE3: %s", pipeline3.input2string());
    //         //$display("[INTERFACE] PIPELINE3: %s", pipeline3.input2string());
    //         // The counter & data_phase_flag to make it work after a transaction is sent after reset cycle is done
    //         //send_inputs(HRESETn_reg, HWRITE_reg, HTRANS_reg, HSIZE_reg, HBURST_reg, HPROT_reg, HADDR_reg, HWDATA_reg, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);
    //         if(HWRITE_reg == 1'b1) begin
    //             //$display("DATA_PHASE_WRITE: TIME:%0t ASSIGNING SIGNALS", $time());
    //             write_AHB(HWDATA_reg);
    //         end
    //         else if(HWRITE_reg == 1'b0) begin
    //             //$display("DATA_PHASE_READ: TIME:%0t ASSIGNING SIGNALS", $time());
    //             read_AHB();
    //         end
    //         counter = counter + 1;
    //         DATA_PHASE_FLAG = 0;
    //         OUTPUTS_PHASE_FLAG_1 = 1;
    //         OUTPUTS_PHASE_FLAG_2 = 1;
    //     end
    //     //$display("%0t BEFORE WAIT",$time());
    //     if(HREADY == NOT_READY && HRESP == OKAY) begin
    //         $display("DATA_PHASE: WAITING FOR HREADY", $time());
    //         wait(HREADY);
    //     end
    //     //$display("%0t AFTER WAIT",$time());
    // end

    // always@(posedge clk) begin
    // 	#1ns;
    // 	if( (HRESETn === 1) && counter > 5 /*&& OUTPUTS_PHASE_FLAG_1 /*&& HREADY*/) begin
    //         //$display("OUTPUT_1_PHASE_SIGNALS: TIME:%0t ", $time());
    //         //counter = counter + 1;
    //         pipeline3.HREADY = HREADY;
    //         pipeline3.HRDATA = HRDATA;
    //         pipeline3.HRESP  = HRESP;
    //         // $sformatf("[INTERFACE] PIPELINE3: %s", pipeline3.output2string());
    //         // $sformatf("[INTERFACE] PIPELINE3: %s", pipeline3.input2string());
    //         //$display("[INTERFACE PIPELINE3: %s", pipeline3.output2string());
    //         $display("[INTERFACE PIPELINE3: %s", pipeline3.input2string());
    //         driver_h.end_transfer(pipeline3);
    //         OUTPUTS_PHASE_FLAG_1 = 0;
    //         //OUTPUTS_PHASE_FLAG_2 = 1;
    //         send_outputs();
    //     end
    //     if(HREADY == NOT_READY && HRESP == OKAY) begin
    //         $display("SAMPLING_PHASE: WAITING FOR HREADY", $time());
    //         wait(HREADY);
    //     end
    // end

    // // always@(posedge clk) begin
    // //     if(HRESETn && counter >= 4 && OUTPUTS_PHASE_FLAG_2 && HREADY) begin
    // //         //$display("OUTPUT_2_PHASE_SIGNALS: TIME:%0t", $time());
    // //         send_outputs();
    // //         OUTPUTS_PHASE_FLAG_2 = 0;
    // //         //OUTPUTS_PHASE_FLAG_3 = 1;
    // //     end
    // //     wait(HREADY);
    // // end

    // // always@(posedge clk) begin
    // //     if(HRESETn && counter >= 5 && OUTPUTS_PHASE_FLAG_3) begin
    // //         //$display("OUTPUT_3_PHASE_SIGNALS: TIME:%0t SENDING OUTPUTS", $time());
    // //         send_outputs();
    // //         OUTPUTS_PHASE_FLAG_3 = 0;
    // //     end
    // // end

    // // Task: Write data into the AHB 
    // task write_AHB(input bit [DATA_WIDTH-1:0] iHWDATA);
    //     case(HTRANS_reg)
    //         IDLE, BUSY: begin
    //         end

    //         NONSEQ, SEQ: begin
    //             //wait(HREADY == 1'b1);
    //             HWDATA <= iHWDATA;
    //         end
    //     endcase // HTRANS
    // endtask : write_AHB

    // // Task: Read data from the AHB 
    // task read_AHB();
    //     case(HTRANS)
    //         IDLE, BUSY: begin
    //         end

    //         NONSEQ, SEQ: begin
    //             //wait(HREADY == 1'b1);
    //         end
    //     endcase // HTRANS
    // endtask : read_AHB

    // // initial begin
    // //     fork
    // //         forever begin
    // //             $monitor("TIME:%0t counter: %0d",$time(), counter);
    // //             $monitor("TIME:%0t OUTPUTS_PHASE_FLAG_1: %0d",$time(), OUTPUTS_PHASE_FLAG_1);
    // //         end
    // //     join_none
    // // end

    // // Function to send inputs to the input monitor
    // function void send_inputs( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
    //                            input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
    //                            input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
    //                            input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
    //                            input HWRITE_e iWRITE_op, input HTRANS_e iTRANS_op,
    //                            input HBURST_e iBURST_op, input HSIZE_e iSIZE_op);

    //     previous_seq_item.HRESETn = iHRESETn;
    //     previous_seq_item.HWRITE = iHWRITE;
    //     previous_seq_item.HTRANS = iHTRANS;
    //     previous_seq_item.HSIZE  = iHSIZE;
    //     previous_seq_item.HBURST = iHBURST;
    //     previous_seq_item.HPROT  = iHPROT;
    //     previous_seq_item.HADDR  = iHADDR;
    //     previous_seq_item.HWDATA = iHWDATA;

    //     previous_seq_item.RESET_op = iRESET_op;
    //     previous_seq_item.WRITE_op = iWRITE_op;
    //     previous_seq_item.TRANS_op = iTRANS_op;
    //     previous_seq_item.SIZE_op  = iSIZE_op;
    //     previous_seq_item.BURST_op = iBURST_op;

    //     inputs_monitor_h.write_to_monitor(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, iRESET_op, iWRITE_op, iTRANS_op, iBURST_op, iSIZE_op);
    // endfunction : send_inputs

    // Function to send inputs to the input monitor
    function void send_inputs( sequence_item input_req);

    	previous_seq_item.do_copy(input_req);
  //   	atlas = atlas +1;
		// $display("atlas %0d  %0t",atlas, $realtime());

        inputs_monitor_h.write_to_monitor(input_req);
    endfunction : send_inputs

    // // Function to send outputs to the output monitor
    // function void send_outputs();
    //     outputs_monitor_h.write_to_monitor(HRDATA, HRESP, HREADY);
    // endfunction : send_outputs
    
    // Function to send outputs to the output monitor
    function void send_outputs(sequence_item outputs_req);
        outputs_monitor_h.write_to_monitor(outputs_req);
    endfunction : send_outputs

    function void create_sequence_item();
        seq_item = sequence_item::type_id::create("seq_item");
        previous_seq_item = sequence_item::type_id::create("previous_seq_item");
        pipeline1 = sequence_item::type_id::create("pipeline1");
        pipeline2 = sequence_item::type_id::create("pipeline2");
        pipeline3 = sequence_item::type_id::create("pipeline3");
        global_req = sequence_item::type_id::create("global_req");
        atlas = sequence_item::type_id::create("atlas");
    endfunction

    initial begin
        create_sequence_item();
        HRESETn <= 1'b1;
    end


endinterface : inf

