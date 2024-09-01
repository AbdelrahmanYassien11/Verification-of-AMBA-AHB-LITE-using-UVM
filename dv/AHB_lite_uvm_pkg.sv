package FIFO_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	parameter CYCLE_WRITE = 5;
	parameter CYCLE_READ  = 10;

	typedef enum {RESET, READ , WRITE, WRITE_READ} STATE_e;

	//control phase signal parameters
	parameter ADDR_WIDTH = 32;
   	parameter TRANS_WIDTH = 1;
   	parameter SIZE_WIDTH = 2;
   	parameter BURST_WIDTH = 2;
   	parameter PROT_WIDTH = 3;

   	//data phase signal parameters
   	parameter DATA_WIDTH = 32;
   	parameter RESP_WIDTH = 1;


   	parameter P_SLAVE0_START = 16'h0000;
  	parameter P_SLAVE0_ADDR_SIZE = 'h0010;
  	parameter P_SLAVE0_END = P_ADDR_START0 + P_ADDR_SIZE0 - 1;


   	parameter P_SLAVE1_START = P_SLAVE0_END + 1;
  	parameter P_SLAVE1_ADDR_SIZE = 'h0100;
  	parameter P_SLAVE1_END = P_ADDR_START1 + P_ADDR_SIZE1 - 1;


   	parameter P_SLAVE2_START = P_SLAVE1_END + 1;
  	parameter P_SLAVE2_ADDR_SIZE = 'h1000;
	parameter P_SLAVE2_END = P_ADDR_START1 + P_ADDR_SIZE1 - 1;

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

	// `include "write_once_sequence.svh"
	// `include "read_once_sequence.svh"
	
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
	// `include "write_once_test.svh"
	// `include "read_once_test.svh"

	// `include "write_all_test.svh"
	// //`include "read_all_test.svh" //obselete
	// `include "reset_write_read_all_test.svh"

	// `include "write_once_rand_test.svh"
	// `include "read_once_rand_test.svh"
	// `include "write_read_rand_test.svh"

	// `include "concurrent_write_read_once_test.svh"
	// `include "concurrent_write_read_rand_test.svh"

endpackage : FIFO_pkg