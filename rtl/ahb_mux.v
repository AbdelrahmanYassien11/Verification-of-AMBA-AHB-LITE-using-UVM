
`timescale 1ns/1ns
module ahb_mux #(parameter ADDR_WIDTH, NO_OF_SUBORDINATES, BITS_FOR_SUBORDINATES, DATA_WIDTH)
(
  input   wire        HRESETn,
  input   wire        HCLK,

  input   wire        HSEL1,
  input   wire        HSEL2,
  input   wire        HSEL3,
  input   wire        HSELd,

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

  output  reg  [DATA_WIDTH-1:0] HRDATA,
  output  reg  [1:0]            HRESP,
  output  reg                   HREADY
);
 /********************************************************/
  localparam P_HSEL_bus1      = 4'b0001; //sel0 //1
  localparam P_HSEL_bus2      = 4'b0010; //sel1 //2
  localparam P_HSEL_bus3      = 4'b0100; //sel2 //4
  localparam P_HSEL_busd      = 4'b1000;
  localparam P_HSEL_bus_reset = 4'b0000;

  wire [3:0] HSEL_bus      = {HSELd,HSEL3,HSEL2,HSEL1};
  reg  [3:0] HSEL_bus_reg_c, HSEL_bus_reg_d, HSEL_bus_reg_s;


  always @(posedge HCLK or negedge HRESETn) begin //DATA_PHASE_SYNC
    if(~HRESETn) begin
       HSEL_bus_reg_s <= 0;
    end
    else begin
      if(HREADY1 && HREADY2 && HREADY3 && HREADYd) begin
        HSEL_bus_reg_s <= HSEL_bus_reg_d;
      end
      else begin
        HSEL_bus_reg_s <= HSEL_bus_reg_s;
      end
    end
  end  

  always @(posedge HCLK or negedge HRESETn) begin //DATA_PHASE_SYNC
    if(~HRESETn) begin
       HSEL_bus_reg_d <= 0;
    end
    else begin
      if(HREADY1 && HREADY2 && HREADY3 && HREADYd) begin
        HSEL_bus_reg_d <= HSEL_bus_reg_c;
      end
      else begin
        HSEL_bus_reg_d <= HSEL_bus_reg_d;
      end
    end
  end  

  always @(negedge HRESETn or posedge HCLK) begin //CONTROL_PHASE_SYNC
    if (~HRESETn) begin
      HSEL_bus_reg_c <= 'h0;
    end
    else begin
      if(HREADY1 && HREADY2 && HREADY3 && HREADYd) begin
        HSEL_bus_reg_c <= HSEL_bus;
      end
      else begin
        HSEL_bus_reg_c <= HSEL_bus_reg_c;
      end
    end
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1: HREADY <= HREADY1; 
      P_HSEL_bus2: HREADY <= HREADY2;
      P_HSEL_bus3: HREADY <= HREADY3;
      P_HSEL_busd: HREADY <= HREADYd;
      P_HSEL_bus_reset: HREADY <= 1'b1;
      default: HREADY <= 1'b1;
    endcase
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1: HRDATA <= HRDATA1;
      P_HSEL_bus2: HRDATA <= HRDATA2;
      P_HSEL_bus3: HRDATA <= HRDATA3;
      P_HSEL_busd: HRDATA <= HRDATAd;
      P_HSEL_bus_reset: HRDATA <= 0;
      default: HRDATA <= HRDATA;
    endcase
  end

  always @(*) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus1: HRESP <= HRESP1;
      P_HSEL_bus2: HRESP <= HRESP2;
      P_HSEL_bus3: HRESP <= HRESP3;
      P_HSEL_busd: HRESP <= HRESPd;
      P_HSEL_bus_reset: HRESP <= 2'b00;
      default: HRESP <= 2'b01; 
    endcase
  end
  
endmodule

