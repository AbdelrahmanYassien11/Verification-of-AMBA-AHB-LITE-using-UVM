package AHB_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "AHB_SUBORDINATE_config.svh"

	parameter CLOCK_PERIOD = 5;


	typedef enum {RESETING, WORKING} HRESET_e;

	typedef enum {READ, WRITE} HWRITE_e;

	typedef enum {OKAY, ERROR, RETRY} HRESP_e;

	typedef enum {IDLE, BUSY, NONSEQ, SEQ} HTRANS_e;

	typedef enum {SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} HBURST_e;

	typedef enum {BYTE, HALFWORD, WORD, WORD2, WORD4, WORD8, WORD16, WORD32} HSIZE_e;

	typedef enum {NOT_READY, READY} HREADY_e;


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
	parameter ADDR_WIDTH = 32;
   	parameter TRANS_WIDTH = 1;
   	parameter SIZE_WIDTH = 2;
   	parameter BURST_WIDTH = 2;
   	parameter PROT_WIDTH = 3;

   	//data phase signal parameters
   	parameter RESP_WIDTH = 1;
   	parameter READY_WIDTH = 0;


 //   	parameter P_SLAVE0_START = 16'h0000;
 //  	parameter P_SLAVE0_ADDR_SIZE = 'h0010;
 //  	//parameter P_SLAVE0_END = P_ADDR_START0 + P_ADDR_SIZE0 - 1;
 //  	parameter P_SLAVE0_END = P_SLAVE0_START + P_SLAVE0_ADDR_SIZE - 1;


	// parameter P_SLAVE1_START = 16'h0100;
 //   	//parameter P_SLAVE1_START = P_SLAVE0_END + 1;
 //  	parameter P_SLAVE1_ADDR_SIZE = 'h0010;
 //  	//parameter P_SLAVE1_END = P_ADDR_START1 + P_ADDR_SIZE1 - 1;
	// parameter P_SLAVE1_END = P_SLAVE1_START + P_SLAVE1_ADDR_SIZE - 1;

	// parameter P_SLAVE2_START = 16'h0200;
 //   	//parameter P_SLAVE2_START = P_SLAVE1_END + 1;
 //  	parameter P_SLAVE2_ADDR_SIZE = 'h0010;
	// //parameter P_SLAVE2_END = P_ADDR_START1 + P_ADDR_SIZE1 - 1;
	// parameter P_SLAVE2_END = P_SLAVE2_START + P_SLAVE2_ADDR_SIZE - 1;

  	int incorrect_counter;
   	int correct_counter;


	`include "sequence_item.svh"
	`include "sequencer.svh"

	`include "passive_agent_config.svh"
	`include "active_agent_config.svh"
	`include "env_config.svh"

	`include "predictor.svh"
	`include "comparator.svh"

	`include "base_sequence.svh"
	`include "reset_sequence.svh"

	`include "IDLE_sequence.svh"

	`include "WRITE_SINGLE_sequence.svh"
	`include "READ_SINGLE_sequence.svh"
	`include "write_twice_sequence.svh"

	`include "WRITE_WRAP4_sequence.svh"
	`include "WRITE_WRAP8_sequence.svh"
	`include "WRITE_WRAP16_sequence.svh"

	`include "WRITE_INCR4_sequence.svh"
	`include "WRITE_INCR8_sequence.svh"
	`include "WRITE_INCR16_sequence.svh"

	`include "READ_WRAP4_sequence.svh"
	`include "READ_WRAP8_sequence.svh"
	`include "READ_WRAP16_sequence.svh"

	`include "READ_INCR4_sequence.svh"
	`include "READ_INCR8_sequence.svh"
	`include "READ_INCR16_sequence.svh"
	
	
	// `include "write_all_sequence.svh"
	// `include "read_all_sequence.svh"
	// `include "reset_write_read_all_sequence.svh"

	// `include "rand_once_sequence.svh"
	// `include "write_once_rand_sequence.svh"
	// `include "read_once_rand_sequence.svh"
	// `include "write_read_rand_sequence.svh"

	// `include "concurrent_write_read_once_sequence.svh"
	// `include "concurrent_write_read_rand_sequence.svh"

	`include "driver.svh"
	`include "inputs_monitor.svh"
	`include "outputs_monitor.svh"

	`include "active_agent.svh"
	`include "passive_agent.svh"
	`include "scoreboard.svh"
	`include "coverage.svh"

	`include "env.svh"

	`include "base_test.svh"
	`include "reset_test.svh"
	`include "WRITE_SINGLE_test.svh"
	`include "write_twice_test.svh"
	// `include "read_once_test.svh"

	// `include "write_all_test.svh"
	// //`include "read_all_test.svh" //obselete
	// `include "reset_write_read_all_test.svh"

	// `include "write_once_rand_test.svh"
	// `include "read_once_rand_test.svh"
	// `include "write_read_rand_test.svh"

	// `include "concurrent_write_read_once_test.svh"
	// `include "concurrent_write_read_rand_test.svh"

endpackage : AHB_pkg