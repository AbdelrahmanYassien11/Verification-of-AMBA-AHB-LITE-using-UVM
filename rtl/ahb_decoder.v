module ahb_decoder #(parameter ADDR_WIDTH = 32, NO_OF_PERIPHERALS = 4, P_BITS = $clog2(NO_OF_PERIPHERALS))
(
    input   wire [31:0] HADDR,
    input   wire        HREADY, 
    output  reg        	HSELd,
    output  reg         HSEL0,
    output  reg         HSEL1,
    output  reg         HSEL2
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

				'h3: begin
					HSEL0 = 0;
					HSEL1 = 0;
					HSEL2 = 0;
					HSELd = 1;
				end

				default: begin
					HSEL0 = 0;
					HSEL1 = 0;
					HSEL2 = 0;
					HSELd = 0;
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