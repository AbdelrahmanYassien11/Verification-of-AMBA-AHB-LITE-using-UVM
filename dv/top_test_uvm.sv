`timescale 1ns/1ns
module top_test_uvm();
	import uvm_pkg::*;
	import AHB_pkg::*;


	bit clk;
	always begin
     	#CLOCK_PERIOD clk = ~clk;
    end

	inf f_if(clk);

	ahb_lite	 #(.NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES))  DUT(
				.HCLK(clk),
				.HRESETn(f_if.HRESETn),
				.HADDR(f_if.HADDR),
				.HTRANS(f_if.HTRANS),
				.HWRITE(f_if.HWRITE),
				.HSIZE(f_if.HSIZE),
				.HBURST(f_if.HBURST),
				.HPROT(f_if.HPROT),
				.HWDATA(f_if.HWDATA),
				.HRDATA(f_if.HRDATA),				
				.HRESP(f_if.HRESP),
				.HREADY(f_if.HREADY)
		);

	bind ahb_lite AHB_subordinate_sva#(/*.TRANS_WIDTH(TRANS_WIDTH), .SIZE_WIDTH(SIZE_WIDTH), .BURST_WIDTH(BURST_WIDTH), .PROT_WIDTH(PROT_WIDTH),*/ .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)/*,/* .RESP_WIDTH(RESP_WIDTH), .READY_WIDTH(READY_WIDTH)*/) sva(f_if.SVA); // bind / dut / module to be instentiated / instance name()

	initial begin
		uvm_config_db#(virtual inf)::set(null,"uvm_test_top", "my_vif", f_if);
		run_test();
	end
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, top_test_uvm);
	end

	initial begin
		$display("Simulation started at %0t", $time());
		#1000000; // 1ms timeout
		$display("Simulation finished at %0t", $time());
		$finish;
	end

	initial begin
		string test_name;
		#1ns;
		if(!(uvm_config_db#(string)::get(null,"uvm_test_top.env_h","test_name",test_name)))
		`uvm_fatal("ALU_TOP_TB", "COULDN'T GET TEST NAME")		
	end

endmodule
