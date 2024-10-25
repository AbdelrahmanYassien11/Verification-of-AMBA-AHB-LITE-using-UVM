
`timescale 1ns/1ns
module ahb_mux #(parameter ADDR_WIDTH = 32, NO_OF_PERIPHERALS = 4, P_BITS = $clog2(NO_OF_PERIPHERALS), DATA_WIDTH = 32)
(
  input   wire        HRESETn,
  input   wire        HCLK,

  input   wire        HSEL0,
  input   wire        HSEL1,
  input   wire        HSEL2,
  input   wire        HSELd,

  input   wire [DATA_WIDTH-1:0] HRDATA0,
  input   wire [1:0]            HRESP0,
  input   wire                  HREADY0,

  input   wire [DATA_WIDTH-1:0] HRDATA1,
  input   wire [1:0]            HRESP1,
  input   wire                  HREADY1,

  input   wire [DATA_WIDTH-1:0] HRDATA2,
  input   wire [1:0]            HRESP2,
  input   wire                  HREADY2,

  input   wire [DATA_WIDTH-1:0] HRDATAd,
  input   wire [1:0]            HRESPd,
  input   wire                  HREADYd,

  output  reg  [DATA_WIDTH-1:0] HRDATA,
  output  reg  [1:0]            HRESP,
  output  reg                   HREADY
);
 /********************************************************/
  localparam P_HSEL_bus0      = 4'b0001; //sel0 //
  localparam P_HSEL_bus1      = 4'b0010; //sel1 //
  localparam P_HSEL_bus2      = 4'b0100; //sel2
  localparam P_HSEL_busd      = 4'b1000;
  localparam P_HSEL_bus_reset = 4'b0000;

  wire [3:0] HSEL_bus      = {HSELd,HSEL2,HSEL1,HSEL0};
  reg  [3:0] HSEL_bus_reg_c, HSEL_bus_reg_d, HSEL_bus_reg_s;


  always @(posedge HCLK or negedge HRESETn) begin //DATA_PHASE_SYNC
    if(~HRESETn) begin
       HSEL_bus_reg_s <= 0;
    end
    else begin
      if(HREADY0 && HREADY1 && HREADY2 && HREADYd) begin
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
      if(HREADY0 && HREADY1 && HREADY2 && HREADYd) begin
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
      if(HREADY0 && HREADY1 && HREADY2 && HREADYd) begin
        HSEL_bus_reg_c <= HSEL_bus;
      end
      else begin
        HSEL_bus_reg_c <= HSEL_bus_reg_c;
      end
    end
  end

  always @(HREADY0 or HREADY1 or HREADY2 or HREADYd) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus0: HREADY <= HREADY0; 
      P_HSEL_bus1: HREADY <= HREADY1;
      P_HSEL_bus2: HREADY <= HREADY2;
      P_HSEL_busd: HREADY <= HREADYd;
      P_HSEL_bus_reset: HREADY <= 1'b1;
      default: HREADY <= 1'b1;
    endcase
  end

  always @(HRDATA0 or HRDATA1 or HRDATA2 or HRDATAd) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus0: HRDATA <= HRDATA0;
      P_HSEL_bus1: HRDATA <= HRDATA1;
      P_HSEL_bus2: HRDATA <= HRDATA2;
      P_HSEL_busd: HRDATA <= HRDATAd;
      P_HSEL_bus_reset: HRDATA <= 0;
      default: HRDATA <= HRDATA;
    endcase
  end

  always @(HRESP0 or HRESP1 or HRESP2 or HRESPd) begin
    case(HSEL_bus_reg_s) 
      P_HSEL_bus0: HRESP <= HRESP0;
      P_HSEL_bus1: HRESP <= HRESP1;
      P_HSEL_bus2: HRESP <= HRESP2;
      P_HSEL_busd: HRESP <= HRESPd;
      P_HSEL_bus_reset: HRESP <= 2'b00;
      default: HRESP <= 2'b01; 
    endcase
  end




  // always @ (HSEL_bus_reg_c or HREADY0 or HREADY1 or HREADY2 or HREADYd) begin
  //   case(HSEL_bus_reg_c) 
  //     P_HSEL_bus0: HREADY = HREADY0; 
  //     P_HSEL_bus1: HREADY = HREADY1;
  //     P_HSEL_bus2: HREADY = HREADY2;
  //     P_HSEL_busd: HREADY = HREADYd;
  //     P_HSEL_bus_reset: HREADY = 1'b1;
  //     default: HREADY = 1'b1;
  //   endcase
  // end

  // always @ (HSEL_bus_reg_c or HRDATA0 or HRDATA1 or HRDATA2 or HRDATAd) begin
  //   case(HSEL_bus_reg_c) 
  //     P_HSEL_bus0: HRDATA = HRDATA0;
  //     P_HSEL_bus1: HRDATA = HRDATA1;
  //     P_HSEL_bus2: HRDATA = HRDATA2;
  //     P_HSEL_busd: HRDATA = HRDATAd;
  //     P_HSEL_bus_reset: HRDATA = 0;
  //     default: HRDATA = HRDATA;
  //   endcase
  // end

  // always @ (HSEL_bus_reg_c or HRESP0 or HRESP1 or HRESP2 or HRESPd) begin
  //   case(HSEL_bus_reg_c) 
  //     P_HSEL_bus0: HRESP = HRESP0;
  //     P_HSEL_bus1: HRESP = HRESP1;
  //     P_HSEL_bus2: HRESP = HRESP2;
  //     P_HSEL_busd: HRESP = HRESPd;
  //     P_HSEL_bus_reset: HRESP = 2'b00;
  //     default: HRESP = 2'b01; 
  //   endcase
  // end

endmodule

