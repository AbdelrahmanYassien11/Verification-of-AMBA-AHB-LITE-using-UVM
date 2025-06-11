/******************************************************************
 * File: AHB_lite_uvm_pkg.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 01/11/2024
 * Description: This module defines a package for an AMBA AHB lite-interconnect 
 *              in a UVM testbench. It is responsible for setting parameters,
 *              typedefs, and including the uvm_environment components.
 *
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/
package AHB_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "config/AHB_subordinate_defines.vh"
	`include "config/AHB_subordinate_config.svh"

	AHB_SUBORDINATE_config subordinate_cfg = new();

	parameter ADDR_WIDTH 			= subordinate_cfg.ADDR_WIDTH;
	parameter DATA_WIDTH 			= subordinate_cfg.DATA_WIDTH;
	parameter ADDR_DEPTH 			= subordinate_cfg.ADDR_DEPTH;
	parameter BITS_FOR_SUBORDINATES = subordinate_cfg.BITS_FOR_SUBORDINATES;
	parameter NO_OF_SUBORDINATES    = subordinate_cfg.NO_OF_SUBORDINATES;
	parameter AVAILABLE_SIZES 		= subordinate_cfg.AVAILABLE_SIZES;

	parameter CLOCK_PERIOD = 5;


	typedef enum {RESETING, WORKING} HRESET_e;

	typedef enum {READ, WRITE} HWRITE_e;

	typedef enum {OKAY, ERROR, RETRY} HRESP_e;

	typedef enum {IDLE, BUSY, NONSEQ, SEQ} HTRANS_e;

	typedef enum {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} HBURST_e;

	typedef enum {BYTE, HALFWORD, WORD, WORD2, WORD4, WORD8, WORD16, WORD32} HSIZE_e;

	typedef enum {NOT_READY, READY} HREADY_e;

	typedef enum {NSEL, SUB1, SUB2, SUB3, SUB4, SUB5, SUB6} HSEL_e;

	localparam logic [7:0]    BYTE_MAX     = 8'hFF;
	localparam logic [15:0]   HALFWORD_MAX = 16'hFFFF;
	localparam logic [31:0]   WORD_MAX     = 32'hFFFFFFFF;
	localparam logic [63:0]   WORD2_MAX    = 64'hFFFFFFFFFFFFFFFF;
	localparam logic [127:0]  WORD4_MAX    = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
	localparam logic [255:0]  WORD8_MAX    = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
	localparam logic [511:0]  WORD16_MAX   = 512'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
	localparam logic [1023:0] WORD32_MAX   = 1024'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;



	//HSIZE PARAMETERS
	parameter BYTE_P		= 3'b000;
	parameter HALFWORD_P	= 3'b001;
	parameter WORD_P		= 3'b010;
	parameter WORD2_P		= 3'b011;
	parameter WORD4_P		= 3'b100;
	parameter WORD8_P		= 3'b101;
	parameter WORD16_P		= 3'b110;
	parameter WORD32_P		= 3'b111;


	parameter BYTE_WIDTH		= 8;
	parameter HALFWORD_WIDTH	= 16;
	parameter WORD_WIDTH		= 32;
	parameter WORD2_WIDTH		= 64;
	parameter WORD4_WIDTH		= 128;
	parameter WORD8_WIDTH		= 256;
	parameter WORD16_WIDTH		= 512;
	parameter WORD32_WIDTH		= 1024;


	//HPROT PARAMETERS




	//control phase signal parameters
	parameter RESET_WIDTH = 1;
	parameter WRITE_WIDTH = 1;
   	parameter TRANS_WIDTH = 2;
   	parameter SIZE_WIDTH = 3;
   	parameter BURST_WIDTH = 3;
   	parameter PROT_WIDTH = 4;

   	//data phase signal parameters
   	parameter RESP_WIDTH = 2;
   	parameter READY_WIDTH = 1;

  	int incorrect_counter;
   	int correct_counter;

   	//******************************************************************************************************************//
   	//												UVM ENVIRONMENT COMPONENTS
   	//*****************************************************************************************************************//


	`include "sequence_item.svh"
	`include "sequence_item_trial.svh"
	`include "sequencer.svh"

	`include "passive_agent_config.svh"
	`include "active_agent_config.svh"
	`include "env_config.svh"

	`include "predictor.svh"
	`include "comparator.svh"

	`include "base_sequence.svh"

   	//******************************************************************************************************************//
   	//												UVM AMBA AHB LITE SEQUENCES
   	//*****************************************************************************************************************//
	`include "reset_sequence.sv"

	`include "IDLE_sequence.svh"

	`include "WRITE_SINGLE_sequence.svh"
	`include "READ_SINGLE_sequence.svh"

	`include "WRITE_READ_SINGLE_sequence.svh"


	`include "WRITE_WRAP4_sequence.svh"
	`include "WRITE_WRAP8_sequence.svh"
	`include "WRITE_WRAP16_sequence.svh"

	`include "WRITE_INCR_sequence.svh"
	`include "WRITE_INCR4_sequence.svh"
	`include "WRITE_INCR8_sequence.svh"
	`include "WRITE_INCR16_sequence.svh"


	`include "READ_WRAP4_sequence.svh"
	`include "READ_WRAP8_sequence.svh"
	`include "READ_WRAP16_sequence.svh"

	`include "READ_INCR_sequence.svh"
	`include "READ_INCR4_sequence.svh"
	`include "READ_INCR8_sequence.svh"
	`include "READ_INCR16_sequence.svh"

	`include "WRITE_READ_INCR_sequence.svh"
	`include "WRITE_READ_INCR4_sequence.svh"
	`include "WRITE_READ_WRAP4_sequence.svh"
	`include "WRITE_READ_INCR8_sequence.svh"
	`include "WRITE_READ_WRAP8_sequence.svh"
	`include "WRITE_READ_INCR16_sequence.svh"
	`include "WRITE_READ_WRAP16_sequence.svh"

	`include "twice_IDLE_sequence.svh"
	`include "twice_reset_sequence.svh"
	`include "SINGLE_IDLE_sequence.svh"

	`include "test_sequence.svh"
	`include "ADDRESS_ERROR_INJECTION_sequence.svh"
	`include "PRIVELEGE_ERROR_INJECTION_sequence.svh"

	`include "runall_waited_sequence.svh"
	`include "runall_sequence.svh"

	`include "driver.svh"
	`include "inputs_monitor.svh"
	`include "outputs_monitor.svh"

	`include "active_agent.svh"
	`include "passive_agent.svh"

	`include "scoreboard.svh"
	`include "coverage.svh"

	`include "env.svh"

   	//******************************************************************************************************************//
   	//												UVM AMBA AHB LITE TESTS
   	//*****************************************************************************************************************//

	`include "base_test.svh"
	`include "reset_test.svh"

	`include "IDLE_test.svh"

	`include "WRITE_SINGLE_test.svh"
	`include "READ_SINGLE_test.svh"

	`include "WRITE_READ_SINGLE_test.svh"

	`include "WRITE_WRAP4_test.svh"
	`include "WRITE_WRAP8_test.svh"
	`include "WRITE_WRAP16_test.svh"

	`include "WRITE_INCR_test.svh"
	`include "WRITE_INCR4_test.svh"
	`include "WRITE_INCR8_test.svh"
	`include "WRITE_INCR16_test.svh"

	`include "READ_WRAP4_test.svh"
	`include "READ_WRAP8_test.svh"
	`include "READ_WRAP16_test.svh"

	`include "READ_INCR_test.svh"
	`include "READ_INCR4_test.svh"
	`include "READ_INCR8_test.svh"
	`include "READ_INCR16_test.svh"

	`include "WRITE_READ_INCR_test.svh"
	`include "WRITE_READ_INCR4_test.svh"
	`include "WRITE_READ_WRAP4_test.svh"
	`include "WRITE_READ_INCR8_test.svh"
	`include "WRITE_READ_WRAP8_test.svh"
	`include "WRITE_READ_INCR16_test.svh"
	`include "WRITE_READ_WRAP16_test.svh"

	`include "runall_waited_test.svh"
	`include "runall_test.svh"
	`include "test_test.svh"
	`include "ADDRESS_ERROR_INJECTION_test.svh"
	`include "PRIVELEGE_ERROR_INJECTION_test.svh"

	`include "twice_IDLE_test.svh"
	`include "twice_reset_test.svh"
	`include "SINGLE_IDLE_test.svh"

	`include "runall_test_arb.svh"

endpackage : AHB_pkg