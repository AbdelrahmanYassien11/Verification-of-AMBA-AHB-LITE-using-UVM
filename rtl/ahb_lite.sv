`include "../dv/config/AHB_subordinate_defines.vh"
`timescale 1ns/1ns

module ahb_lite #(parameter BITS_FOR_SUBORDINATES = 5, ADDR_WIDTH = 32, DATA_WIDTH = 32, ADDR_DEPTH = 256, NO_OF_SUBORDINATES = 4)
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
   /*====== Internal Signals ===================================================================================================*/
   wire [5:0]            HSEL_bus;
   wire [DATA_WIDTH-1:0] HRDATA_bus [5:0]; 
   wire [1:0]            HRESP_bus  [5:0]; 
   wire                  HREADY_bus [5:0]; 
   
   wire                  HREADYin;

   assign HREADYin = HREADY;
   /*===== AHB Decoder ======================================================================================================== */
   ahb_decoder #(.NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES), .ADDR_WIDTH(ADDR_WIDTH)) decoder1 
              ( 
              .HADDR(HADDR),
              .HREADY(HREADY),
              .HSEL1(HSEL_bus[0]),
              .HSEL2(HSEL_bus[1]),
              .HSEL3(HSEL_bus[2]),
              .HSELd(HSEL_bus[3]),
              .HSEL_p_r(HSEL_bus[4]),
              .HSEL_p_wr(HSEL_bus[5])
              );
   /*===== AHB MUX ============================================================================================================== */
   ahb_mux #(.NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mux1 
          (
          .HRESETn(HRESETn),
          .HCLK   (HCLK),

          .HSEL1  (HSEL_bus[0]),
          .HSEL2  (HSEL_bus[1]),
          .HSEL3  (HSEL_bus[2]),
          .HSELd  (HSEL_bus[3]),
          .HSEL_p_r (HSEL_bus[4]),
          .HSEL_p_wr(HSEL_bus[5]),

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
          .HREADYd(HREADY_bus[3]),

          .HRDATA_p_r(HRDATA_bus[4]),
          .HRESP_p_r ( HRESP_bus[4]),
          .HREADY_p_r(HREADY_bus[4]),

          .HRDATA_p_wr(HRDATA_bus[5]),
          .HRESP_p_wr ( HRESP_bus[5]),
          .HREADY_p_wr(HREADY_bus[5])
          );

   /*===== AHB Defualt Subordinate ============================================================================================= */
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
                    .HPROT              (HPROT),
                   
                    .HRDATA      (HRDATA_bus[3]),
                    .HRESP        (HRESP_bus[3]),
                    .HREADYout   (HREADY_bus[3])
                    );
   /*===== AHB Subordinate No.1 =============================================================================================== */
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
            .HPROT                  (HPROT),

            .HRDATA           (HRDATA_bus[0]),
            .HRESP             (HRESP_bus[0]),
            .HREADYout        (HREADY_bus[0])
            );
   /*===== AHB Subordinate No.2 =============================================================================================== */
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
            .HPROT                  (HPROT),

            .HRDATA          (HRDATA_bus[1]),
            .HRESP            (HRESP_bus[1]),
            .HREADYout       (HREADY_bus[1])

            );
   /*===== AHB Subordinate No.3 =============================================================================================== */
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
            .HPROT                  (HPROT),

            .HRDATA          (HRDATA_bus[2]),
            .HRESP            (HRESP_bus[2]),
            .HREADYout       (HREADY_bus[2])
            );

   /*===== AHB Subordinate which needs a privelege level to Read  ============================================================= */
   ahb_subordinate_priveleged_r #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES)) subordinate_p_r 
            (
            .HRESETn               (HRESETn),
            .HCLK                     (HCLK),
            .HSEL              (HSEL_bus[4]),
            .HADDR                   (HADDR),
            .HTRANS                 (HTRANS),
            .HWRITE                 (HWRITE),
            .HSIZE                   (HSIZE),
            .HBURST                 (HBURST),
            .HWDATA                 (HWDATA),
            .HREADYin               (HREADY),
            .HPROT                  (HPROT),

            .HRDATA          (HRDATA_bus[4]),
            .HRESP            (HRESP_bus[4]),
            .HREADYout       (HREADY_bus[4])
            );

   /*===== AHB Subordinate which needs a privelege level to Read or Write ====================================================== */
   ahb_subordinate_priveleged_wr #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDR_DEPTH(ADDR_DEPTH), .NO_OF_SUBORDINATES(NO_OF_SUBORDINATES), .BITS_FOR_SUBORDINATES(BITS_FOR_SUBORDINATES)) subordinate_p_wr 
            (
            .HRESETn               (HRESETn),
            .HCLK                     (HCLK),
            .HSEL              (HSEL_bus[5]),
            .HADDR                   (HADDR),
            .HTRANS                 (HTRANS),
            .HWRITE                 (HWRITE),
            .HSIZE                   (HSIZE),
            .HBURST                 (HBURST),
            .HWDATA                 (HWDATA),
            .HREADYin               (HREADY),
            .HPROT                  (HPROT),

            .HRDATA          (HRDATA_bus[5]),
            .HRESP            (HRESP_bus[5]),
            .HREADYout       (HREADY_bus[5])
            );

endmodule
