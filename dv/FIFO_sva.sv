module AHB_subordinate_sva (inf.SVA f_if);


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
	assign HBRUST 	 	= f_if.HBRUST;
	assign HPROT		= f_if.HPROT;

	assign HADDR 		= f_if.HADDR;
	assign HRDATA		= f_if.HRDATA;
	assign HRESP 		= f_if.HRESP;
	assign HREADY 		= f_if.HREADY;

	property reset_addr;

		@(posedge clk)	~HRESETn |-> HADDR == 0;

	endproperty

	property idle_ready;

		@(posedge clk) HTRANS == 0 |=> ##3 (HREADY);

	endproperty

	property idle_inputs;

		@(posedge clk)	HTRANS == 0 |-> (HSIZE ==  0) && (HBURST == 0) && (HWRITE == 0);

	endproperty

	property incr4_idle;

		@(posedge clk) HBURST == 3 |=> ##4 (HTRANS=0);

	endproperty

	property incr8_idle;

		@(posedge clk) HBURST == 5 |=> ##8 (HTRANS=0);

	endproperty

	property incr16_idle;

		@(posedge clk) HBURST == 7 |=> ##16 (HTRANS=0);

	endproperty



	property wrap4_idle;

		@(posedge clk) HBURST == 2 |=> ##4 (HTRANS=0);

	endproperty

	property wrap8_idle;

		@(posedge clk) HBURST == 4 |=> ##8 (HTRANS=0);

	endproperty

	property wrap16_idle;

		@(posedge clk) HBURST == 8 |=> ##16 (HTRANS=0);

	endproperty

	overflow_high_assert: 	assert property (overflow_high);
	underflow_high_assert: 	assert property (underflow_high);
	wr_ack_sva_high_assert: assert property (wr_ack_sva_high);
	wr_ack_sva_low_assert: 	assert property (wr_ack_sva_low);
	full_high_assert: 		assert property (full_high);
	empty_high_assert: 		assert property (empty_high);

	// Assertions coverage

	overflow_high_cover:   cover property (overflow_high);
	underflow_high_cover:  cover property (underflow_high);
	wr_ack_sva_high_cover: cover property (wr_ack_sva_high);
	wr_ack_sva_low_cover:  cover property (wr_ack_sva_low);
	full_high_cover: 	   cover property (full_high);
	empty_high_cover: 	   cover property (empty_high);


endmodule : FIFO_sva











