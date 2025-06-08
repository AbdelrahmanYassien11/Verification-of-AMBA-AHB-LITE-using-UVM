//----------------------------------------------------------------
//  * File: ahb_decoder.v
//  * Author: Abdelrahman Mohamad Yassien
//  * Email: Abdelrahman.Yassien11@gmail.com
//  * Date: 25/12/2024
//  * Description: This module as the decoder defined & 
//                 described per AMBA SPECIFICATION by ARM,
//                 which samples the inputs of all sent by the
// 				   ahb master & asserts the correct HSEL accordingly
//----------------------------------------------------------------
module ahb_decoder #(parameter ADDR_WIDTH, NO_OF_SUBORDINATES, BITS_FOR_SUBORDINATES)
(
    input   wire [ADDR_WIDTH-1:0] HADDR,
    input   wire        HREADY, 
    output  reg        	HSELd,
    output  reg         HSEL1,
    output  reg         HSEL2,
    output  reg         HSEL3,
    output  reg			HSEL_p_r,
    output  reg 		HSEL_p_wr
);

	// combinational always block to asser tthe correct HSELx accoridng to the bits allocated for management from HADDR PERIPHERAL
	always@(*) begin
		//if(HREADY) begin
			case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])

				'h0: begin
					HSEL1     = 0;
					HSEL2     = 0;
					HSEL3  	  = 0;
					HSELd 	  = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;
			    end

			    'h1: begin
					HSEL1     = 1;
					HSEL2     = 0;
					HSEL3  	  = 0;
					HSELd 	  = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;					
				end

				'h2: begin
					HSEL1     = 0;
					HSEL2     = 1;
					HSEL3  	  = 0;
					HSELd 	  = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;
				end

				'h3: begin
					HSEL1     = 0;
					HSEL2     = 0;
					HSEL3  	  = 1;
					HSELd 	  = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;
				end

				'h4: begin
					HSEL1     = 0;
					HSEL2     = 0;
					HSEL3  	  = 0;
					HSELd 	  = 1;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;
				end

				'h5: begin
					HSEL1     = 0;
					HSEL2     = 0;
					HSEL3  	  = 0;
					HSELd 	  = 0;
					HSEL_p_r  = 1;
					HSEL_p_wr = 0;
				end

				'h6: begin
					HSEL1     = 0;
					HSEL2     = 0;
					HSEL3  	  = 0;
					HSELd 	  = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 1;
				end

				default: begin
					HSEL1 = 0;
					HSEL2 = 0;
					HSEL3 = 0;
					HSELd = 0;
					HSEL_p_r  = 0;
					HSEL_p_wr = 0;
				end	
			endcase // HADDR
//		end
//		else begin
//			HSEL1 = HSEL1;
//			HSEL2 = HSEL2;
//			HSEL3 = HSEL3;
//			HSELd = HSELd;
//		end
	end

endmodule