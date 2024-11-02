// `include "ahb_decoder_s3.v"
// `include "ahb_s2m_s3.v"
// `include "ahb_default_slave.v"
import AHB_lite_uvm_pkg::**;
`timescale 1ns/1ns

module ahb_lite #(parameter P_BITS = $clog2(NO_OF_PERIPHERALS), ADDR_WIDTH = 32, DATA_WIDTH = 32, ADDR_DEPTH = 256, NO_OF_PERIPHERALS = 4)
(
      input   wire                   HRESETn,
      input   wire                   HCLK,
      input   wire  [ADDR_WIDTH-1:0] HADDR,
      input   wire  [1:0]            HTRANS,
      input   wire                   HWRITE,
      input   wire  [2:0]            HSIZE,
      input   wire  [2:0]            HBURST,
      input   wire  [3:0]            HPROT,
      input   wire  [DATA_WIDTH-1:0] HWDATA,

      output    [DATA_WIDTH-1:0]  HRDATA,
      output    [1:0]             HRESP,
      output                      HREADY

);
   /*********************************************************/
   /*********************************************************/
   wire [3:0]            HSEL_bus;
   wire [DATA_WIDTH-1:0] HRDATA_bus [3:0]; 
   wire [1:0]            HRESP_bus  [3:0]; 
   wire                  HREADY_bus [3:0]; 
   
   wire                  HREADYin;

   assign HREADYin = HREADY;
   /*********************************************************/
   ahb_decoder #(.NO_OF_PERIPHERALS(NO_OF_PERIPHERALS), .P_BITS(P_BITS), .ADDR_WIDTH(ADDR_WIDTH)) decoder1 
              ( 
              .HADDR(HADDR),
              .HREADY(HREADY),
              .HSEL0(HSEL_bus[0]),
              .HSEL1(HSEL_bus[1]),
              .HSEL2(HSEL_bus[2]),
              .HSELd(HSEL_bus[3])
              );
   /*********************************************************/ //MUX
   ahb_mux #(.NO_OF_PERIPHERALS(NO_OF_PERIPHERALS), .P_BITS(P_BITS), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mux1 
          (
          .HRESETn(HRESETn),
          .HCLK   (HCLK),

          .HSEL0  (HSEL_bus[0]),
          .HSEL1  (HSEL_bus[1]),
          .HSEL2  (HSEL_bus[2]),
          .HSELd  (HSEL_bus[3]),

          .HRDATA (HRDATA),
          .HRESP  (HRESP),
          .HREADY (HREADY),

          .HRDATA0(HRDATA_bus[0]),
          .HRESP0 ( HRESP_bus[0]),
          .HREADY0(HREADY_bus[0]),

          .HRDATA1(HRDATA_bus[1]),
          .HRESP1 ( HRESP_bus[1]),
          .HREADY1(HREADY_bus[1]),

          .HRDATA2(HRDATA_bus[2]),
          .HRESP2 ( HRESP_bus[2]),
          .HREADY2(HREADY_bus[2]),

          .HRDATAd(HRDATA_bus[3]),
          .HRESPd ( HRESP_bus[3]),
          .HREADYd(HREADY_bus[3])
          );

   /*********************************************************/
   ahb_default_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) default_slave 
                    (
                    .HRESETn          (HRESETn),
                    .HCLK                (HCLK),
                    .HSEL         (HSEL_bus[3]),
                    .HADDR              (HADDR),
                    .HTRANS             (HTRANS),
                    .HWRITE             (HWRITE),
                    .HSIZE               (HSIZE),
                    .HBURST             (HBURST),
                    .HWDATA             (HWDATA),
                    .HREADYin           (HREADY),
                   
                    .HRDATA      (HRDATA_bus[3]),
                    .HRESP        (HRESP_bus[3]),
                    .HREADYout   (HREADY_bus[3])
                    );
   /*********************************************************/
   ahb_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_PERIPHERALS(NO_OF_PERIPHERALS)) slave0 
            (
            .HRESETn               (HRESETn),
            .HCLK                     (HCLK),
            .HSEL              (HSEL_bus[0]),
            .HADDR                   (HADDR),
            .HTRANS                 (HTRANS),
            .HWRITE                 (HWRITE),
            .HSIZE                   (HSIZE),
            .HBURST                 (HBURST),
            .HWDATA                 (HWDATA),
            .HREADYin                (HREADY),

            .HRDATA           (HRDATA_bus[0]),
            .HRESP             (HRESP_bus[0]),
            .HREADYout        (HREADY_bus[0])
            );
   /*********************************************************/
   ahb_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_PERIPHERALS(NO_OF_PERIPHERALS)) slave1 
            (
            .HRESETn               (HRESETn),
            .HCLK                     (HCLK),
            .HSEL              (HSEL_bus[1]),
            .HADDR                   (HADDR),
            .HTRANS                 (HTRANS),
            .HWRITE                 (HWRITE),
            .HSIZE                   (HSIZE),
            .HBURST                 (HBURST),
            .HWDATA                 (HWDATA),
            .HREADYin               (HREADY),

            .HRDATA          (HRDATA_bus[1]),
            .HRESP            (HRESP_bus[1]),
            .HREADYout       (HREADY_bus[1])

            );
   /*********************************************************/
   ahb_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_PERIPHERALS(NO_OF_PERIPHERALS)) slave2 
            (
            .HRESETn               (HRESETn),
            .HCLK                     (HCLK),
            .HSEL              (HSEL_bus[2]),
            .HADDR                   (HADDR),
            .HTRANS                 (HTRANS),
            .HWRITE                 (HWRITE),
            .HSIZE                   (HSIZE),
            .HBURST                 (HBURST),
            .HWDATA                 (HWDATA),
            .HREADYin               (HREADY),

            .HRDATA          (HRDATA_bus[2]),
            .HRESP            (HRESP_bus[2]),
            .HREADYout       (HREADY_bus[2])
            );

endmodule
