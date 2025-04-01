`timescale 1ns/1ns

module ahbslave_tb();

  logic         HRESETn;
  logic         HSEL;
  logic  [31:0] HADDR;
  logic  [ 1:0] HTRANS;
  logic         HWRITE;
  logic  [ 2:0] HSIZE;
  logic  [ 2:0] HBURST;
  logic  [31:0] HWDATA;
  logic  [31:0] HRDATA;
  logic  [ 1:0] HRESP;
  logic         HREADYin;						
  logic        HREADYout;

	
   bit clk;
	always begin
		#5 clk = ~clk;
	end

	ahb_lite ahb1(
		.HCLK(clk),
		.HRESETn(HRESETn),
		.HSEL(HSEL),
		.HADDR(HADDR),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HWDATA(HWDATA),
		.HRDATA(HRDATA),
		.HRESP(HRESP),
		.HREADYin(HREADYin),
		.HREADYout(HREADYout)
		);

	initial begin
		#10;
		HRESETn = 1'b1;
		#15;
		HRESETn = 1'b0;
		#10;
		@(negedge clk);
		HRESETn = 1'b1;
		HSEL = 1; //SELECTED
		HADDR = 2; //2
		HTRANS = 2'b00; ////IDLE
		HWRITE = 1; //WRITE
		HSIZE  = 0; //BYTE
		HBURST = 0; //SINGLE
		HREADYin = 1;
		//$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		@(negedge clk);
		@(negedge clk); //60ns
		HWDATA = 5; 
		HTRANS = 2'b10; //NONSEQ
		@(negedge clk); //70ns
		HWRITE = 0; //READ
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		//HTRANS = 2'b00;
		@(negedge clk);//80ns
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		HREADYin = 0;
		//HWRITE = 0;
		@(negedge clk); //90
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		@(negedge clk); //100
		HREADYin = 1;
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		@(negedge clk); //110
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		@(negedge clk); //120
		$display("time :%0t HRDATA = %0d", $time(), HRDATA);
		//HTRANS = 2;
		HWRITE = 1;
		HBURST = 1;
		HWDATA = 9;
		@(negedge clk); //130
		HTRANS = 3;
		@(negedge clk); //140
		@(negedge clk); //150
		@(negedge clk); //160
		HTRANS = 0;
		@(negedge clk); //170
		HADDR = 5;
		HWDATA = 7;
		HTRANS = 2;
		HBURST = 2;
		@(negedge clk); //180
		HTRANS = 3;
		@(negedge clk); //190
		@(negedge clk); //200
		@(negedge clk); //210
		HTRANS = 0;
		@(negedge clk); //220
		HSEL = 0;
		@(negedge clk); //230
		HSEL = 1;
		@(negedge clk);
		HADDR = 7;
		HWDATA = 512;
		HTRANS = 2;
		HBURST = 3;
		@(negedge clk);
		HTRANS = 3;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		HTRANS = 0;
		#100;
		$stop;
	end

endmodule : ahbslave_tb