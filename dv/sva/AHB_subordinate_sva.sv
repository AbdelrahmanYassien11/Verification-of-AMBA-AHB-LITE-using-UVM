/******************************************************************
 * File: AHB_subordinate_sva.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 01/11/2024
 * Description: This module defines a AHB_subordinate SV Assertions for a AMBA AHB 
 *              lite-subordinate. It is responsible for monitoring the state of  
 *              the inputs and outputs of the AMBA AHB subordinate and providing   
 *              assertion based verification of the DUT.
 *
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/
module AHB_subordinate_sva #(parameter TRANS_WIDTH = 1, SIZE_WIDTH = 2, BURST_WIDTH = 2, PROT_WIDTH = 1, ADDR_WIDTH, DATA_WIDTH, RESP_WIDTH = 1, READY_WIDTH = 0) (inf.SVA f_if);


	// AHB lite Control Signals
	logic   HRESETn;    // reset (active low)

	bit   HWRITE;

	bit   [TRANS_WIDTH:0]  HTRANS; 
	bit   [SIZE_WIDTH:0]  HSIZE;
	bit   [BURST_WIDTH:0]  HBURST;
	bit   [PROT_WIDTH:0]  HPROT; 

	bit   [ADDR_WIDTH-1:0]  HADDR;     
	bit   [DATA_WIDTH-1:0]  HWDATA; 

	// AHB lite output Signals
	logic   [DATA_WIDTH-1:0]  HRDATA;
	logic   [RESP_WIDTH:0]  HRESP; 
	logic   [READY_WIDTH:0]  HREADY;  

	assign clk = f_if.clk;

	assign HRESETn		= f_if.HRESETn;
	assign HWRITE		= f_if.HWRITE;
	assign HTRANS 		= f_if.HTRANS;
	assign HBURST 	 	= f_if.HBURST;
	assign HPROT		= f_if.HPROT;

	assign HADDR 		= f_if.HADDR;
	assign HRDATA		= f_if.HRDATA;
	assign HRESP 		= f_if.HRESP;
	assign HREADY 		= f_if.HREADY;

	property burst_trans_seq;

		@(posedge clk) (HBURST != 0) && (HBURST != 1) && (HTRANS == 2'b10) |=> (HTRANS == 2'b11);

	endproperty

	property burst_trans_nonseq;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST != 0) ) |-> ##[0:1] (HTRANS == 2'b10);

	endproperty

	property burst_trans_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 0) ) |-> ##[0:1] (HTRANS == 2'b00);

	endproperty

	property reset_duration;

		@(posedge clk) $fell(HRESETn) |=> ##15 (HRESETn);

	endproperty

	property reset_addr;

		@(posedge clk)	~HRESETn |-> HADDR == 0;

	endproperty

	property idle_ready;

		@(posedge clk) HTRANS  == 0 |=> ##3 (HREADY);

	endproperty

	property idle_inputs;

		@(posedge clk)	HTRANS == 0 |-> (HSIZE ==  0) && (HBURST == 0) && (HWRITE == 0);

	endproperty

	property incr4_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 3) ) |-> ##4 (HTRANS==0);

	endproperty

	property incr8_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 5) ) |-> ##8 (HTRANS==0);

	endproperty

	property incr16_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 7) )|-> ##16 (HTRANS==0);

	endproperty



	property wrap4_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 2) ) |-> ##4 (HTRANS==0);

	endproperty

	property wrap8_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 4) ) |-> ##8 (HTRANS==0);

	endproperty

	property wrap16_idle;

		@(posedge clk) ( ( $rose(HBURST[0]) || $rose(HBURST[1]) || $rose(HBURST[2]) || $fell(HBURST[0]) || $fell(HBURST[1]) || $fell(HBURST[2]) ) && (HBURST == 6) ) |-> ##16 (HTRANS==0);

	endproperty


	burst_trans_seq_assert:     assert property (burst_trans_seq);
	burst_trans_nonseq_assert:  assert property (burst_trans_nonseq);
	reset_duration_assert:  	assert property (reset_duration);
	reset_addr_assert: 			assert property (reset_addr);
	idle_ready_assert: 			assert property (idle_ready);
	idle_inputs_assert: 		assert property (idle_inputs);

	incr4_idle_assert: 			assert property (incr4_idle);
	incr8_idle_assert: 			assert property (incr8_idle);
	incr16_idle_assert: 		assert property (incr16_idle);

	wrap4_idle_assert: 			assert property (wrap4_idle);
	wrap8_idle_assert: 			assert property (wrap8_idle);
	wrap16_idle_assert: 		assert property (wrap16_idle);





endmodule : AHB_subordinate_sva











