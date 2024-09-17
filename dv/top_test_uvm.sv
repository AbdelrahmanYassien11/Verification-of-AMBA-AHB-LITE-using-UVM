module top_test_uvm();
	import uvm_pkg::*;
	import AHB_pkg::*;


	bit clk;

    always #CLOCK_PERIOD clk = ~clk;

	inf f_if(clk);

	ahb_lite_s3	 DUT(
				.HCLK(clk),
				.HRESETn(f_if.HRESETn),
				.HADDER(f_if.M_HADDER),
				.HTRANS(f_if.M_HTRANS),
				.HWRITE(f_if.M_HWRITE),
				.HSIZE(f_if.M_HSIZE),
				.HBRUST(f_if.HBURST),
				.HPROT(f_if.M_HPROT),
				.HWDATA(f_if.M_HWDATA),
				.HRDATA(f_if.M_HRDATA),
				.HRESP(f_if.M_RESP),
				.HREADY(f_if.M_HREADY),
		);

	//bind fifo1 FIFO_sva sva(f_if);

	initial begin
		uvm_config_db#(virtual inf)::set(null,"uvm_test_top", "my_vif", f_if);
		run_test();
	end

endmodule
