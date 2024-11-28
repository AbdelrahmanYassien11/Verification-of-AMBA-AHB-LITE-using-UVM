// `ifndef AHB_SUBORDINATE_CONFIG
// `define AHB_SUBORDINATE_CONFIG
//--------------------------------------------------------
//  * File: ahb_subordinate.v
//  * Author: Abdelrahman Mohamad Yassien
//  * Email: Abdelrahman.Yassien11@gmail.com
//  * Date: 25/10/2024
//  * Description: This module works as an AHB DEFAULT SUBORDINATE as per 
//                  described per AMBA SPECIFICATION by ARM corporation.
//--------------------------------------------------------
//--------------------------------------------------------
//`include "../dv/AHB_subordinate_defines.vh"
`timescale 1ns/1ns
module ahb_default_subordinate #(parameter ADDR_WIDTH, DATA_WIDTH)
(
       input   wire                   HRESETn,
       input   wire                   HCLK,
       input   wire                   HSEL,
       input   wire  [ADDR_WIDTH-1:0] HADDR,
       input   wire  [ 1:0]           HTRANS,
       input   wire                   HWRITE,
       input   wire  [ 2:0]           HSIZE,
       input   wire  [ 2:0]           HBURST,
       input   wire  [DATA_WIDTH-1:0] HWDATA,
       input   wire                   HREADYin,

       output  reg  [DATA_WIDTH-1:0]  HRDATA,
       output  reg   [ 1:0]           HRESP,
       output  reg                    HREADYout
);
   /*********************************************************/
    reg state, next_state;
    localparam IDLE   = 1'b0, ERROR = 1'b1;
   /*********************************************************/
    reg [1:0] HRESP_reg;
    reg  HSEL_reg;

  //always block to manage OUTPUT/SAMPLING _phase signals
  always @(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      HRESP <= 0;
    end 
    else begin
      HRESP <= HRESP_reg;
    end
  end

  //always block to manage CONTROL_phase signals
  always @ (posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin 
      HREADYout     <= 1'b1;
      HRDATA        <= 'b0;
      state         <= IDLE;
      //HRESP_reg     <= 2'b00;
    end 
    else begin 
		HREADYout 	  <= 1'b1;
		HRDATA 		  <= 'b0;
      HSEL_reg      <= HSEL;
      state         <= next_state;
    end 
  end 

  //next_state logic combinational always block
  always@(*) begin //next_state logic
  
    if (HSEL_reg) begin
      next_state = ERROR;
    end
    else begin
      next_state = IDLE;
    end
	 
  end  

  // always block to manage DATA_phase signals
  always@(*) begin //output logic
    case(state)

      IDLE: begin
        HRESP_reg = 2'b00;
      end
      ERROR: begin 
        HRESP_reg = 2'b01;
      end

    endcase // state
  end

endmodule
