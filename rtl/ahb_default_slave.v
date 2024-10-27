`timescale 1ns/1ns
module ahb_default_slave #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)
(
       input   wire         HRESETn,
       input   wire         HCLK,
       input   wire         HSEL,
       input   wire  [ADDR_WIDTH-1:0] HADDR,
       input   wire  [ 1:0] HTRANS,
       input   wire         HWRITE,
       input   wire  [ 2:0] HSIZE,
       input   wire  [ 2:0] HBURST,
       input   wire  [DATA_WIDTH-1:0] HWDATA,
       input   wire         HREADYin,

       output   wire         error_idle_control,
       output  reg  [DATA_WIDTH-1:0] HRDATA,
       output  reg   [ 1:0] HRESP,
       output  reg          HREADYout
);
   /*********************************************************/
   /*********************************************************/
    reg state, next_state;
    localparam IDLE   = 2'h0, ERROR = 2'h1;
   /*********************************************************/
    reg [1:0] HRESP_reg;
    //reg       HREADYout_reg;
    reg  HSEL_reg;

  always @(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      HRESP <= 0;
    end 
    else begin
      HRESP     <= HRESP_reg;
    end
  end

  always @ (posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin 
      HREADYout     <= 1'b1;
      HRDATA        <= 'b0;
      state         <= IDLE;
      HRESP_reg     <= 2'b00;
    end 
    else begin 
      HSEL_reg      <= HSEL;
      state         <= next_state;
    end 
  end 

  always@(*) begin //next_state logic

    if (HSEL_reg) begin
      next_state = ERROR;
    end
    else begin
      next_state = IDLE;
    end 
  end  

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
