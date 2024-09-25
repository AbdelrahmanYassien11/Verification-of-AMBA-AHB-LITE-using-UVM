`timescale 1ns/1ns
module ahb_default_slave (
       input   wire         HRESETn,
       input   wire         HCLK,
       input   wire         HSEL,
       input   wire  [31:0] HADDR,
       input   wire  [ 1:0] HTRANS,
       input   wire         HWRITE,
       input   wire  [ 2:0] HSIZE,
       input   wire  [ 2:0] HBURST,
       input   wire  [31:0] HWDATA,
       output  wire  [31:0] HRDATA,
       output  reg   [ 1:0] HRESP,
       input   wire         HREADYin,
       output  reg          HREADYout
);
   /*********************************************************/
   assign HRDATA = 32'h0;
   /*********************************************************/
    reg [1:0] state;
    localparam IDLE   = 2'h0, ERROR  - 2'h1;
   /*********************************************************/
    reg [1:0] HRESP_reg;

  always @ (posedge HCLK or negedge HRESETn) begin
    if (HRESETn==0) begin
      HRESP         <= 2'b00; 
      HREADYout     <= 1'b1;
      HRDATA_reg    <= 'b0;
      state         <= IDLE;
    end 
    else begin 
      HRESP         <= HRESP_reg;
    end 
  end 

  always@(*) begin //next_state logic

    if (HSEL) begin
      next_state = ERROR;
    end
    else begin
      next_state = IDLE;
    end 
  end  

  always@(*) begin //output logic
    case(state)

      IDLE:  HRESP_reg = 2'b00;
      ERROR: HRESP_reg = 2'b01;

    endcase // state
  end

endmodule
