//----------------------------------------------------------------
//  * File: ahb_mux.v
//  * Author: Abdelrahman Mohamad Yassien
//  * Email: Abdelrahman.Yassien11@gmail.com
//  * Date: 25/12/2024
//  * Description: This module as the multiplexor defined & 
//                 described per AMBA SPECIFICATION by ARM,
//                 which samples the outputs of all subordinates
//                 and drives the correct one to the ahb master
//----------------------------------------------------------------

`timescale 1ns/1ns
module ahb_mux #(parameter ADDR_WIDTH, NO_OF_SUBORDINATES, BITS_FOR_SUBORDINATES, DATA_WIDTH)
(
  input   wire        HRESETn,
  input   wire        HCLK,

  input   wire        HSEL1,
  input   wire        HSEL2,
  input   wire        HSEL3,
  input   wire        HSELd,
  input   wire        HSEL_p_r,
  input   wire        HSEL_p_wr,

  input   wire [DATA_WIDTH-1:0] HRDATA1,
  input   wire [1:0]            HRESP1,
  input   wire                  HREADY1,

  input   wire [DATA_WIDTH-1:0] HRDATA2,
  input   wire [1:0]            HRESP2,
  input   wire                  HREADY2,

  input   wire [DATA_WIDTH-1:0] HRDATA3,
  input   wire [1:0]            HRESP3,
  input   wire                  HREADY3,

  input   wire [DATA_WIDTH-1:0] HRDATAd,
  input   wire [1:0]            HRESPd,
  input   wire                  HREADYd,

  input   wire [DATA_WIDTH-1:0] HRDATA_p_r,
  input   wire [1:0]            HRESP_p_r,
  input   wire                  HREADY_p_r,

  input   wire [DATA_WIDTH-1:0] HRDATA_p_wr,
  input   wire [1:0]            HRESP_p_wr,
  input   wire                  HREADY_p_wr,

  output  reg  [DATA_WIDTH-1:0] HRDATA,
  output  reg  [1:0]            HRESP,
  output  reg                   HREADY
);
 /********************************************************/
  localparam P_HSEL_bus1      = 6'b000001; //sel0 //1
  localparam P_HSEL_bus2      = 6'b000010; //sel1 //2
  localparam P_HSEL_bus3      = 6'b000100; //sel2 //4
  localparam P_HSEL_busd      = 6'b001000; //sel3 //8  defualt sub
  localparam P_HSEL_bus_p_r   = 6'b010000; //sel4 //16 priveleged sub read
  localparam P_HSEL_bus_p_wr  = 6'b100000; //sel5 //32 priveleged sub write/read
  localparam P_HSEL_bus_reset = 6'b000000; //sel6 //0  0

  wire [5:0] HSEL_bus      = {HSEL_p_wr,HSEL_p_r,HSELd,HSEL3,HSEL2,HSEL1};
  reg  [5:0] HSEL_bus_reg_c, HSEL_bus_reg_d, HSEL_bus_reg_s;

  //SAMPLING_PHASE_SYNC
  always @(*) begin 
    if(~HRESETn) begin
       HSEL_bus_reg_s = 0;
    end
    else begin
      HSEL_bus_reg_s = HSEL_bus_reg_d;
    end
  end  

  // always @(negedge HRESETn or negedge HCLK) begin //DATA_PHASE_SYNC
  //   if(~HRESETn) begin
  //      HSEL_bus_reg_d <= 0;
  //   end
  //   else begin
  //     HSEL_bus_reg_d <= HSEL_bus_reg_c;
  //   end
  // end

  //DATA_PHASE_SYNC
  always @(*) begin 
    if(~HRESETn) begin
      HSEL_bus_reg_d = 0;
    end
    else begin
      HSEL_bus_reg_d = HSEL_bus_reg_c;
    end
  end  

  //CONTROL_PHASE_SYNC
  always @(negedge HRESETn or posedge HCLK) begin 
    if (~HRESETn) begin
      HSEL_bus_reg_c <= 'h0;
    end
    else begin
      HSEL_bus_reg_c <= HSEL_bus;
    end
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1     : HREADY = HREADY1; 
      P_HSEL_bus2     : HREADY = HREADY2;
      P_HSEL_bus3     : HREADY = HREADY3;
      P_HSEL_busd     : HREADY = HREADYd;
      P_HSEL_bus_p_r  : HREADY = HREADY_p_r;
      P_HSEL_bus_p_wr : HREADY = HREADY_p_wr;
      P_HSEL_bus_reset: HREADY = 1'b1;
      default: HREADY = 1'b1;
    endcase
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1     : HRDATA = HRDATA1;
      P_HSEL_bus2     : HRDATA = HRDATA2;
      P_HSEL_bus3     : HRDATA = HRDATA3;
      P_HSEL_busd     : HRDATA = HRDATAd;
      P_HSEL_bus_p_r  : HRDATA = HRDATA_p_r;
      P_HSEL_bus_p_wr : HRDATA = HRDATA_p_wr;
      P_HSEL_bus_reset: HRDATA = 0;
      default: HRDATA = 'h0;
    endcase
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1     : HRESP = HRESP1;
      P_HSEL_bus2     : HRESP = HRESP2;
      P_HSEL_bus3     : HRESP = HRESP3;
      P_HSEL_busd     : HRESP = HRESPd;
      P_HSEL_bus_p_r  : HRESP = HRESP_p_r;
      P_HSEL_bus_p_wr : HRESP = HRESP_p_wr;
      P_HSEL_bus_reset: HRESP = 2'b00;
      default: HRESP = 2'b01; 
    endcase
  end
  
endmodule

