// `include "ahb_decoder_s3.v"
// `include "ahb_s2m_s3.v"
// `include "ahb_default_slave.v"
`timescale 1ns/1ns

module ahb_lite_s3
                #(parameter P_NUM  = 3
                  parameter P_BITS = $clog2(P_NUM)
                  parameter ADDR_WIDTH = 32
                  parameter DATA_WDITH = 32
                )
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

      input   wire                   HREADYin,

      output  reg  [DATA_WIDTH-1:0]  HRDATA,
      output  reg  [1:0]             HRESP,
      output  reg                    HREADY

);
   /*********************************************************/
   wire HSELd; // default slave
   wire [DATA_WIDTH-1:0] HRDATAd;
   wire [1:0]  HRESPd;
   wire        HREADYd;
   /*********************************************************/
   ahb_decoder decoder1 ( 
              .HADDR(HADDR),
              .HREADY(HREADY)
              );
   /*********************************************************/ //MUX
   ahb_mux mux1 (
          .HRESETn(HRESETn),
          .HCLK   (HCLK),
          .HSEL0  (HSEL0),
          .HSEL1  (HSEL1),
          .HSEL2  (HSEL2),
          .HSELd  (HSELd),
          .HRDATA(M_HRDATA),
          .HRESP (M_HRESP),
          .HREADY(M_HREADY),
          .HRDATA0(HRDATA0),
          .HRESP0 (HRESP0 ),
          .HREADY0(HREADY0),
          .HRDATA1(HRDATA1),
          .HRESP1 (HRESP1 ),
          .HREADY1(HREADY1),
          .HRDATA2(HRDATA2),
          .HRESP2 (HRESP2 ),
          .HREADY2(HREADY2),
          .HRDATAd(HRDATAd),
          .HRESPd (HRESPd ),
          .HREADYd(HREADYd)
          );

   /*********************************************************/
   ahb_default_slave default_slave (
                    .HRESETn(HRESETn),
                    .HCLK   (HCLK),
                    .HSEL   (HSELd),
                    .HADDR  (HADDR),
                    .HTRANS (HTRANS),
                    .HWRITE (HWRITE),
                    .HSIZE  (HSIZE),
                    .HBURST (HBURST),
                    .HWDATA (HWDATA),
                    .HRDATA(HRDATAd),
                    .HRESP (HRESPd),
                    .HREADYin(HREADY),
                    .HREADYout(HREADYd)
                    );
   /*********************************************************/
   ahb_slave slave0 (
            .HRESETn(HRESETn),
            .HCLK   (HCLK),
            .HSEL   (HSEL0),
            .HADDR  (HADDR),
            .HTRANS (HTRANS),
            .HWRITE (HWRITE),
            .HSIZE  (HSIZE),
            .HBURST (HBURST),
            .HWDATA (HWDATA),
            .HRDATA(HRDATA0),
            .HRESP (HRESP0),
            .HREADYin(HREADY),
            .HREADYout(HREADY0)
            );
   /*********************************************************/
   ahb_slave slave1 (
            .HRESETn(HRESETn),
            .HCLK   (HCLK),
            .HSEL   (HSEL1),
            .HADDR  (HADDR),
            .HTRANS (HTRANS),
            .HWRITE (HWRITE),
            .HSIZE  (HSIZE),
            .HBURST (HBURST),
            .HWDATA (HWDATA),
            .HRDATA(HRDATA1),
            .HRESP (HRESP1),
            .HREADYin(HREADY),
            .HREADYout(HREADY1)
            );
   /*********************************************************/
   ahb_slave slave2 (
            .HRESETn(HRESETn),
            .HCLK   (HCLK),
            .HSEL   (HSEL2),
            .HADDR  (HADDR),
            .HTRANS (HTRANS),
            .HWRITE (HWRITE),
            .HSIZE  (HSIZE),
            .HBURST (HBURST),
            .HWDATA (HWDATA),
            .HRDATA(HRDATA2),
            .HRESP (HRESP2),
            .HREADYin(HREADY),
            .HREADYout(HREADY2)
            );

endmodule
