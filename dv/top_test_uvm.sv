`timescale 1ns/1ns
module top_test_uvm();
	import uvm_pkg::*;
	import AHB_pkg::*;


	bit clk;
	always begin
     	#CLOCK_PERIOD clk = ~clk;
    end

	inf f_if(clk);

	ahb_lite_s3	 DUT(
				.HCLK(clk),
				.HRESETn(f_if.HRESETn),
				.M_HADDR(f_if.HADDR),
				.M_HTRANS(f_if.HTRANS),
				.M_HWRITE(f_if.HWRITE),
				.M_HSIZE(f_if.HSIZE),
				.M_HBURST(f_if.HBURST),
				.M_HPROT(f_if.HPROT),
				.M_HWDATA(f_if.HWDATA),
				.M_HRDATA(f_if.HRDATA),
				.M_HRESP(f_if.HRESP),
				.M_HREADY(f_if.HREADY)
		);

	//bind fifo1 FIFO_sva sva(f_if);

	initial begin
		uvm_config_db#(virtual inf)::set(null,"uvm_test_top", "my_vif", f_if);
		run_test();
	end

endmodule
