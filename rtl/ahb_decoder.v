module ahb_decoder #(parameter P_NUM  = 3
					 parameter P_BITS = $clog2(P_NUM))
(
    input   wire [31:0] HADDR,
    input   wire        HREADY, 
    output  wire        HSELd,
    output  wire        HSEL0,
    output  wire        HSEL1,
    output  wire        HSEL2
);


	always@(*) begin
		if(HREADY) begin
			case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-P_BITS])

				'h0: begin
					HSEL0 = 1;
					HSEL1 = 0;
					HSEL2 = 0;
					HSELd = 0;
			    end

			    'h1: begin
					HSEL0 = 0;
					HSEL1 = 1;
					HSEL2 = 0;
					HSELd = 0;
				end

				'h2: begin
					HSEL0 = 0;
					HSEL1 = 0;
					HSEL2 = 1;
					HSELd = 0;
				end

				default: begin
					HSEL0 = 0;
					HSEL1 = 0;
					HSEL2 = 0;
					HSELd = 1;
				end	
			endcase // HADDR
		end
		else begin
			HSEL0 = HSEL0;
			HSEL1 = HSEL1;
			HSEL2 = HSEL2;
			HSELd = HSELd;
		end
	end

endmodule