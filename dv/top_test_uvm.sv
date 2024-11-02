`timescale 1ns/1ns
module top_test_uvm();
	import uvm_pkg::*;
	import AHB_pkg::*;


	bit clk;
	always begin
     	#CLOCK_PERIOD clk = ~clk;
    end

	inf f_if(clk);

	ahb_lite	 DUT(
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

	//bind fifo1 FIFO_sva sva(f_if); // bind / dut / module to be instentiated / instance name()

	initial begin
		uvm_config_db#(virtual inf)::set(null,"uvm_test_top", "my_vif", f_if);
		run_test();
	end

endmodule
