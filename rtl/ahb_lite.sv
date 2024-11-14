`timescale 1ns/1ns

module ahb_lite #(parameter BITS_FOR_SUBORDINATES, ADDR_WIDTH, DATA_WIDTH, ADDR_DEPTH, NO_OF_SUBORDINATES)
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
   ahb_decoder #(.NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES), .ADDR_WIDTH(ADDR_WIDTH)) decoder1 
              ( 
              .HADDR(HADDR),
              .HREADY(HREADY),
              .HSEL1(HSEL_bus[0]),
              .HSEL2(HSEL_bus[1]),
              .HSEL3(HSEL_bus[2]),
              .HSELd(HSEL_bus[3])
              );
   /*********************************************************/ //MUX
   ahb_mux #(.NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mux1 
          (
          .HRESETn(HRESETn),
          .HCLK   (HCLK),

          .HSEL1  (HSEL_bus[0]),
          .HSEL2  (HSEL_bus[1]),
          .HSEL3  (HSEL_bus[2]),
          .HSELd  (HSEL_bus[3]),

          .HRDATA (HRDATA),
          .HRESP  (HRESP),
          .HREADY (HREADY),

          .HRDATA1(HRDATA_bus[0]),
          .HRESP1 ( HRESP_bus[0]),
          .HREADY1(HREADY_bus[0]),

          .HRDATA2(HRDATA_bus[1]),
          .HRESP2 ( HRESP_bus[1]),
          .HREADY2(HREADY_bus[1]),

          .HRDATA3(HRDATA_bus[2]),
          .HRESP3 ( HRESP_bus[2]),
          .HREADY3(HREADY_bus[2]),

          .HRDATAd(HRDATA_bus[3]),
          .HRESPd ( HRESP_bus[3]),
          .HREADYd(HREADY_bus[3])
          );

   /*********************************************************/
   ahb_default_subordinate #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) default_subordinate
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
   ahb_subordinate #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES)) subordinate1 
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
   ahb_subordinate #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES)) subordinate2 
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
   ahb_subordinate #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES)) subordinate3 
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
