//----------------------------------------------------------------
//  * File: ahb_subordinate.v
//  * Author: Abdelrahman Mohamad Yassien
//  * Email: Abdelrahman.Yassien11@gmail.com
//  * Date: 25/10/2024
//  * Description: This module works as an AHB SUBORDINATE as per 
//                  described per AMBA SPECIFICATION by ARM.
//----------------------------------------------------------------
//----------------------------------------------------------------
`timescale 1ns/1ns

module ahb_subordinate_priveleged_r 
  #(parameter DATA_WIDTH, ADDR_WIDTH, ADDR_DEPTH, NO_OF_SUBORDINATES, BITS_FOR_SUBORDINATES)
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
       input   wire  [3:0]            HPROT,

       input   wire         HREADYin,

       output  reg   [DATA_WIDTH-1:0] HRDATA,
       output  reg   [ 1:0]           HRESP,
       output  reg                    HREADYout
);

  /*============================================================== Needed Local Parameters =================================================================== */
  // STATE PARAMETERS
  localparam IDLE   = 3'b000;
  localparam BUSY   = 3'b001;
  localparam WRITE  = 3'b010;
  localparam READ   = 3'b011;
  localparam ERROR  = 3'b101;

  // HBURST PARAMETERS
  localparam SINGLE     = 3'b000;
  localparam INCR       = 3'b001;
  localparam WRAP4      = 3'b010;
  localparam INCR4      = 3'b011;
  localparam WRAP8      = 3'b100;
  localparam INCR8      = 3'b101;
  localparam WRAP16     = 3'b110;
  localparam INCR16     = 3'b111;

  // HSIZE PARAMETERS
  localparam HSIZE_BYTE     = 3'b000;
  localparam HSIZE_HALFWORD = 3'b001;
  localparam HSIZE_WORD     = 3'b010;
  localparam HSIZE_WORD2    = 3'b011;
  localparam HSIZE_WORD4    = 3'b100;
  localparam HSIZE_WORD8    = 3'b101;
  localparam HSIZE_WORD16   = 3'b110;
  localparam HSIZE_WORD32   = 3'b111;

  //WIDTH PARAMETERS
  localparam BYTE_WIDTH        = 8;
  localparam HALFWORD_WIDTH    = 16;
  localparam WORD_WIDTH        = 32;
  localparam WORD2_WIDTH       = 64;
  localparam WORD4_WIDTH       = 128;
  localparam WORD8_WIDTH       = 256;
  localparam WORD16_WIDTH      = 512;
  localparam WORD32_WIDTH      = 1024;

  /*======== Intermediate Signals ==============================================================================================*/

  // A flag to indicate that the wrap burst reached the positive end of its index 
  reg half_of_wrap;

  wire [ADDR_WIDTH-1:0] HADDR_reg_c;

  reg [ADDR_WIDTH-1:0] HADDR_reg_d;  
  reg [DATA_WIDTH-1:0] HWDATA_reg_d;
  reg                  HREADYout_reg_d;
  reg [           2:0] HBURST_reg_d;
  reg [           1:0] HTRANS_reg_d;
  reg                  HREADYin_reg_d;
  reg                  HSEL_reg_d;
  reg [           2:0] HSIZE_reg_d;
  reg                  HWRITE_reg_d;

  // Internal Memory
  reg [DATA_WIDTH-1:0] mem [ADDR_DEPTH-1:0];

  // Counters assigned synchronously to keep track of the burst operation
  integer wrap_counter;
  integer burst_counter;

  // Counters assigned asynchronously to keep track of the burst operation
  integer burst_counter_reg;
  integer wrap_counter_reg;

  // State & Next State value holders
  reg [2:0] state, next_state;

  // Initializing the Internal Signals & the Memory
  initial begin
    burst_counter_reg = 0;
    wrap_counter_reg  = 0;
    for (i = 0; i < ADDR_DEPTH; i = i+1) begin
      mem[i] = 'h0;
    end
  end

  // Macro to Write Operations dependeing on the HSIZE value keeping in mind the padding.
  `define HSIZE_conditional_WRITE_def(counter) \
    `ifdef HWDATA_WIDTH1024 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin mem[HADDR_reg_d + counter] [WORD2_WIDTH-1:0]    <= HWDATA[WORD2_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin mem[HADDR_reg_d + counter] [WORD4_WIDTH-1:0]    <= HWDATA[WORD4_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin mem[HADDR_reg_d + counter] [WORD8_WIDTH-1:0]    <= HWDATA[WORD8_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD8_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD8_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD16    : begin mem[HADDR_reg_d + counter] [WORD16_WIDTH-1:0]   <= HWDATA[WORD16_WIDTH-1:0];   mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD16_WIDTH]   <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD16_WIDTH];   HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD32    : begin mem[HADDR_reg_d + counter] [WORD32_WIDTH-1:0]   <= HWDATA[WORD32_WIDTH-1:0];                                                                                                                         HREADYout <= 1; HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH512 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin mem[HADDR_reg_d + counter] [WORD2_WIDTH-1:0]    <= HWDATA[WORD2_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin mem[HADDR_reg_d + counter] [WORD4_WIDTH-1:0]    <= HWDATA[WORD4_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin mem[HADDR_reg_d + counter] [WORD8_WIDTH-1:0]    <= HWDATA[WORD8_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD8_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD8_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD16    : begin mem[HADDR_reg_d + counter] [WORD16_WIDTH-1:0]   <= HWDATA[WORD16_WIDTH-1:0];                                                                                                                         HREADYout <= 1; HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH256 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin mem[HADDR_reg_d + counter] [WORD2_WIDTH-1:0]    <= HWDATA[WORD2_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin mem[HADDR_reg_d + counter] [WORD4_WIDTH-1:0]    <= HWDATA[WORD4_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD4_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin mem[HADDR_reg_d + counter] [WORD8_WIDTH-1:0]    <= HWDATA[WORD8_WIDTH-1:0];                                                                                                                          HREADYout <= 1; HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH128 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin mem[HADDR_reg_d + counter] [WORD2_WIDTH-1:0]    <= HWDATA[WORD2_WIDTH-1:0];    mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH]    <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD2_WIDTH];    HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin mem[HADDR_reg_d + counter] [WORD4_WIDTH-1:0]    <= HWDATA[WORD4_WIDTH-1:0];                                                                                                                          HREADYout <= 1; HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH64 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:WORD_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin mem[HADDR_reg_d + counter] [WORD2_WIDTH-1:0]    <= HWDATA[WORD2_WIDTH-1:0];                                                                                                                          HREADYout <= 1; HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH32 \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];                                                                                                                           HREADYout <= 1; HRESP <= 2'b00; end \
    `else \
                        HSIZE_BYTE      : begin mem[HADDR_reg_d + counter] [BYTE_WIDTH-1:0]     <= HWDATA[BYTE_WIDTH-1:0];     mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH]     <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:BYTE_WIDTH];     HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin mem[HADDR_reg_d + counter] [HALFWORD_WIDTH-1:0] <= HWDATA[HALFWORD_WIDTH-1:0]; mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH] <= mem[HADDR_reg_d + counter] [DATA_WIDTH-1:HALFWORD_WIDTH]; HREADYout <= 1; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin mem[HADDR_reg_d + counter] [WORD_WIDTH-1:0]     <= HWDATA[WORD_WIDTH-1:0];                                                                                                                           HREADYout <= 1; HRESP <= 2'b00; end \
    `endif

  // Macro to Read Operations dependeing on the HSIZE value keeping in mind the padding.
  `define HSIZE_conditional_READ_def(counter) \
    `ifdef HWDATA_WIDTH1024 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD_WIDTH]     <= HRDATA[DATA_WIDTH-1:WORD_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin HRDATA[WORD2_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD2_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD2_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD2_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin HRDATA[WORD4_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD4_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD4_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD4_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin HRDATA[WORD8_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD8_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD8_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD8_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD16    : begin HRDATA[WORD16_WIDTH-1:0]    <= mem[HADDR_reg_d+counter][WORD16_WIDTH-1:0];   HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD16_WIDTH]   <= HRDATA[DATA_WIDTH-1:WORD16_WIDTH];   HRESP <= 2'b00; end \
                        HSIZE_WORD32    : begin HRDATA[WORD32_WIDTH-1:0]    <= mem[HADDR_reg_d+counter][WORD32_WIDTH-1:0];   HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH512 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD_WIDTH]     <= HRDATA[DATA_WIDTH-1:WORD_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin HRDATA[WORD2_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD2_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD2_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD2_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin HRDATA[WORD4_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD4_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD4_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD4_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin HRDATA[WORD8_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD8_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD8_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD8_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD16    : begin HRDATA[WORD16_WIDTH-1:0]    <= mem[HADDR_reg_d+counter][WORD16_WIDTH-1:0];   HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH256 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD_WIDTH]     <= HRDATA[DATA_WIDTH-1:WORD_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin HRDATA[WORD2_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD2_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD2_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD2_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin HRDATA[WORD4_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD4_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD4_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD4_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD8     : begin HRDATA[WORD8_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD8_WIDTH-1:0];    HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH128 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD_WIDTH]     <= HRDATA[DATA_WIDTH-1:WORD_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin HRDATA[WORD2_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD2_WIDTH-1:0];    HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD2_WIDTH]    <= HRDATA[DATA_WIDTH-1:WORD2_WIDTH];    HRESP <= 2'b00; end \
                        HSIZE_WORD4     : begin HRDATA[WORD4_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD4_WIDTH-1:0];    HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH64 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:WORD_WIDTH]     <= HRDATA[DATA_WIDTH-1:WORD_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_WORD2     : begin HRDATA[WORD2_WIDTH-1:0]     <= mem[HADDR_reg_d+counter][WORD2_WIDTH-1:0];    HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `elsif HWDATA_WIDTH32 \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `else \
                        HSIZE_BYTE      : begin HRDATA[BYTE_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][BYTE_WIDTH-1:0];     HREADYout <= 1; HRDATA[DATA_WIDTH-1:BYTE_WIDTH]     <= HRDATA[DATA_WIDTH-1:BYTE_WIDTH];     HRESP <= 2'b00; end \
                        HSIZE_HALFWORD  : begin HRDATA[HALFWORD_WIDTH-1:0]  <= mem[HADDR_reg_d+counter][HALFWORD_WIDTH-1:0]; HREADYout <= 1; HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH] <= HRDATA[DATA_WIDTH-1:HALFWORD_WIDTH]; HRESP <= 2'b00; end \
                        HSIZE_WORD      : begin HRDATA[WORD_WIDTH-1:0]      <= mem[HADDR_reg_d+counter][WORD_WIDTH-1:0];     HREADYout <= 1;                                                                             HRESP <= 2'b00; end \
    `endif

  // ========== Wrap counter always block (Synthiazability) ================================================================= */
  always @(negedge HCLK or negedge HRESETn) begin        
    if(~HRESETn) begin
      wrap_counter_reg <= 0;
    end 
    else begin
      if((HPROT[3:1] == 3'b001 && HWRITE) || (HPROT[3:2] == 2'b00 && ~HWRITE)) begin
        case (HTRANS)
          2'b10: begin
            if(HSEL && HREADYin) begin
              if(($signed(HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] + wrap_counter_reg) < ADDR_DEPTH)) begin
                case(HBURST)
                  INCR, INCR4, INCR8, INCR16: wrap_counter_reg <= wrap_counter_reg;
                  WRAP4, WRAP8, WRAP16: begin
                    wrap_counter_reg <= wrap_counter_reg + 1;
                  end
                  default: begin
                    //$display("time: %0t, I AM HERE NOW SINGLE BURST ", $time());
                    wrap_counter_reg <= wrap_counter_reg;
                  end
                endcase // HBURST_reg_d
              end
              else begin
                wrap_counter_reg <= wrap_counter_reg;
              end
            end
            else begin
              wrap_counter_reg <= wrap_counter_reg;
            end
          end
          2'b11: begin
            if(HSEL_reg_d && HREADYin)begin
              if(($signed(HADDR_reg_d + wrap_counter_reg) < ADDR_DEPTH)) begin
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    wrap_counter_reg <= wrap_counter_reg;
                    // $display("time: %0t, I AM HERE NOW INCR BURST ", $time());
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    if(~half_of_wrap) begin
                      wrap_counter_reg <= wrap_counter_reg + 1;
                    end
                    else begin
                      wrap_counter_reg <= (~(wrap_counter_reg) + 1) -1;
                    end
                    // $display("time: %0t, I AM HERE NOW WRAP BURST ", $time());
                  end
                  default: begin
                    //$display("time: %0t, I AM HERE NOW SINGLE BURST ", $time());
                    wrap_counter_reg <= wrap_counter_reg;
                  end
                endcase // HBURST_reg_d
              end
              else begin
                wrap_counter_reg <= wrap_counter_reg;
              end
            end
            else begin
              wrap_counter_reg <= wrap_counter_reg;
            end
          end
          2'b01: begin
              wrap_counter_reg <= wrap_counter_reg;       
          end
          default: begin
            wrap_counter_reg <= 0;
          end
        endcase // HTRANS_reg_d
      end
      else begin
        wrap_counter_reg <= wrap_counter_reg;
      end
    end
  end

  // ========== Burst counter always block (Synthiazability) ================================================================= */
  always @(negedge HCLK or negedge HRESETn) begin        
    if(~HRESETn) begin
      burst_counter_reg <= 0;
    end 
    else begin
      if((HPROT[3:1] == 3'b001 && HWRITE) || (HPROT[3:2] == 2'b00 && ~HWRITE)) begin
        case (HTRANS)
          2'b10: begin
            if(HSEL && HREADYin) begin
              if(((HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] + burst_counter_reg) < ADDR_DEPTH)) begin
                case(HBURST)
                  INCR, INCR4, INCR8, INCR16: burst_counter_reg <= burst_counter_reg + 1;
                  WRAP4, WRAP8, WRAP16: burst_counter_reg <= burst_counter_reg;
                  default: begin
                    //$display("time: %0t, I AM HERE NOW SINGLE BURST ", $time());
                    burst_counter_reg <= burst_counter_reg;
                  end
                endcase // HBURST_reg_d
              end
              else begin
                $display("a7eeh1b");
                burst_counter_reg <= burst_counter_reg;
              end
            end
            else begin
              burst_counter_reg <= burst_counter_reg;
            end
          end
          2'b11: begin
            if(HSEL_reg_d && HREADYin)begin
              if(((HADDR_reg_d + burst_counter_reg) < ADDR_DEPTH)) begin
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    burst_counter_reg <= burst_counter_reg+1;
                    // $display("time: %0t, I AM HERE NOW INCR BURST ", $time());
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    burst_counter_reg <= burst_counter_reg;
                    // $display("time: %0t, I AM HERE NOW WRAP BURST ", $time());
                  end
                  default: begin
                    //$display("time: %0t, I AM HERE NOW SINGLE BURST ", $time());
                    burst_counter_reg <= burst_counter_reg;
                  end
                endcase // HBURST_reg_d
              end
              else begin
                burst_counter_reg <= burst_counter_reg;
              end
            end
            else begin
              burst_counter_reg <= burst_counter_reg;
            end
          end
          2'b01: begin
              burst_counter_reg <= burst_counter_reg;       
          end
          default: begin
            burst_counter_reg <= 0;
          end
        endcase // HTRANS_reg_d
      end
      else begin
        burst_counter_reg <= burst_counter_reg;
      end
    end
  end


  // ========== Ouput logic assignment sequential always block ================================================================= */
  always @(negedge HCLK negedge HRESETn) begin 
    if(~HRESETn) begin
        HRDATA      <= 0;
        HRESP       <= 0;
        HREADYout   <= 1;
    end
    else begin
      case(state)

        IDLE: begin
          HREADYout <= 1;        
          HRDATA    <= HRDATA;
          if(HSEL_reg_d && HREADYin) begin
            if(HRESP == 2'b01) begin
              HRESP     <= 2'b01;
            end
            else begin
              HRESP <= 2'b00;
            end
          end
          else if (HSEL_reg_d && !HREADYin) begin
            HRESP   <= 2'b01;
          end
          else begin
            HRESP <= 2'b00;
          end
        end

        WRITE: begin
          HRDATA <= HRDATA;
          if(HSEL_reg_d && HREADYin) begin     
            case(HTRANS_reg_d)
              2'b00, 2'b01: begin
                HRESP <= 2'b00;
                HREADYout <= 1'b1;
              end

              2'b10, 2'b11: begin
                if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & ($signed(HADDR_reg_d + wrap_counter) < ADDR_DEPTH)) begin
                  case(HBURST_reg_d)
                    INCR, INCR4, INCR8, INCR16: begin
                      case(HSIZE_reg_d) 
                        `HSIZE_conditional_WRITE_def(burst_counter)
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; end
                      endcase // HSIZE_reg_d
                    end
                    WRAP4, WRAP8, WRAP16: begin
                      case(HSIZE_reg_d) 
                        `HSIZE_conditional_WRITE_def(wrap_counter)
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; end
                      endcase //HSIZE_reg_d
                    end
                    default: begin
                      case(HSIZE_reg_d) 
                        `HSIZE_conditional_WRITE_def(0)
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; end
                      endcase //HSIZE_reg_d
                    end
                  endcase // HBURST_reg_d
                end
                else begin
                  HRESP <= 2'b01; //error
                  HREADYout <= 0;
                end
              end
            endcase // HTRANS_reg_d                    
          end
          else if (HSEL_reg_d && !HREADYin) begin
            HRESP <= 2'b01;
            HREADYout <= 0;
          end
          else begin
            HRESP <= 2'b00;
            HREADYout <= 1;
          end
        end

        READ: begin

          if(HSEL_reg_d && HREADYin) begin 
            case(HTRANS_reg_d)
              2'b00, 2'b01: begin
                HRESP       <= 2'b00; //`HRESP_OKAY;
                HREADYout   <= 1;
                HRDATA <= HRDATA;
              end

              2'b10, 2'b11: begin
                if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & ($signed(HADDR_reg_d + wrap_counter) < ADDR_DEPTH)) begin
                  case(HBURST_reg_d)
                    INCR, INCR4, INCR8, INCR16: begin
                      case(HSIZE_reg_d) 
                        `HSIZE_conditional_READ_def(burst_counter)
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; HRDATA <= HRDATA; end
                      endcase //HSIZE_reg_d                
                    end
                    WRAP4, WRAP8, WRAP16: begin
                      case(HSIZE_reg_d) 
                        `HSIZE_conditional_READ_def(wrap_counter)
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; HRDATA <= HRDATA; end
                      endcase //HSIZE_reg_d     
                    end
                    default: begin
                      case(HSIZE_reg_d)
                        `HSIZE_conditional_READ_def(0) 
                        default         : begin HRESP <= 2'b01; HREADYout <= 0; HRDATA <= HRDATA; end
                      endcase //HSIZE_reg_d     
                    end
                  endcase // HBURST_reg_d
                end 
                else begin
                  HRESP <= 2'b01;
                  HRDATA <= HRDATA;
                  HREADYout <= 0;
                end
              end
            endcase // HTRANS_reg_d  
          end
          else if (HSEL_reg_d && !HREADYin) begin
            HRESP     <= 2'b01;
            HREADYout <= 0;
            HRDATA <= HRDATA;
          end
          else begin
            HRESP <= 2'b00;
            HREADYout <= 1;
            HRDATA <= HRDATA;
          end
        end

        ERROR: begin
          HRDATA    <= HRDATA;
          if(HSEL_reg_d && HREADYin) begin 
            HRESP     <= 2'b01;
            if(state == ERROR) begin
              HREADYout <=  0;
            end
            else begin
              HREADYout <= 1;
            end
          end
          else if (HSEL_reg_d && !HREADYin) begin
            HRESP <= 2'b01;
            HREADYout <= 0;
          end
          else begin
            HRESP <= 2'b00;
            HREADYout <= 1;
          end            
        end

        default: begin
          HRDATA <= HRDATA;
          HREADYout <= HREADYout;
          HRESP <= HRESP;
        end

      endcase // state
    end
  end


  // ========== Always block to manage Address Phase signals ================================================================== */
  always@(negedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      // burst_counter <= 0;
      // wrap_counter  <= 0;
    end 
    else begin 
      burst_counter     <= burst_counter_reg;
      wrap_counter      <= wrap_counter_reg;
    end
  end

  // always block for State logic Synchronous assignment
  always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      state <= IDLE;
    end
    else begin
      state <= next_state;
    end
  end

  assign HADDR_reg_c       = HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];

  // always block to manage DATA_phase signals
  always @ (negedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      HADDR_reg_d       <= 0;
      HTRANS_reg_d      <= 0;
      HBURST_reg_d      <= 0;
      HSEL_reg_d        <= 0;
      HSIZE_reg_d       <= 0;
      
      HWDATA_reg_d      <= 0;

      HWRITE_reg_d      <= 0;

      HREADYin_reg_d    <= 1;

      // HRDATA_reg_d      <= 0;
      // HRESP_reg_d       <= 0;
      // HREADYout_reg_d   <= 1;
    end 
    else begin 
      HBURST_reg_d     <= HBURST;
      HTRANS_reg_d     <= HTRANS;
      HSEL_reg_d       <= HSEL;
      HADDR_reg_d      <= HADDR_reg_c;
      HSIZE_reg_d      <= HSIZE;
      HWDATA_reg_d     <= HWDATA;
      HWRITE_reg_d     <= HWRITE;
      HREADYin_reg_d   <= HREADYin;
    end 
  end

  // next_state logic combinational always block
  always@(*) begin
    if(~HRESETn) begin
      next_state = IDLE;
    end
    else begin
      case(state)

        IDLE, BUSY: begin
          if (HSEL && HREADYin && HPROT[3:2] == 2'b00) begin

            case (HTRANS) 
              2'b00: begin 
               next_state    = IDLE; 
              end 
              2'b01: begin 
               next_state    = BUSY; 
              end

              2'b10: begin 
                if (HWRITE && HPROT[3:1] == 3'b001) begin 
                  next_state = WRITE; 
                end 
                else if(~HWRITE && HPROT[3:2] == 2'b00) begin 
                  next_state = READ; 
                end
                else begin 
                  next_state = ERROR;
                end 
              end

              2'b11: begin
                next_state = ERROR;
              end 

              default: begin
                next_state = IDLE;
              end 
            endcase //HTRANS_reg_c

          end
          else if(HSEL && (~HREADYin || HPROT[3:2] != 2'b00))begin
            if(next_state == ERROR) begin
              case (HTRANS)
                2'b00: next_state = IDLE;
                default : next_state = ERROR;
              endcase
            end
            else begin
              next_state = ERROR;
            end
          end

          else begin
            next_state = state;
          end
        end

        WRITE, READ : begin
          if (HSEL && HREADYin && HPROT[3:2] == 2'b00) begin

            case (HTRANS) 
              2'b00: begin 
                next_state    = IDLE; 
              end 
              2'b01: begin 
                next_state    = BUSY; 
              end 

              2'b11, 2'b10: begin 
                if((HADDR_reg_c + burst_counter < ADDR_DEPTH) & ($signed(HADDR_reg_c + wrap_counter) < ADDR_DEPTH) /*& ((HADDR_reg_c + wrap_counter) > 0)*/) begin 
                  if (HWRITE && HPROT [1] == 1'b1) begin 
                    next_state = WRITE; 
                  end 
                  else if(~HWRITE) begin 
                    next_state = READ; 
                  end
                  else begin 
                    next_state = ERROR;
                  end 
                end 
                else begin
                  next_state = ERROR; 
                end
              end

              default: begin
                next_state = IDLE;
              end 
            endcase //HTRANS_reg_c
          end

          else if(HSEL && (~HREADYin || HPROT[3:2] != 2'b00))begin
            case (HTRANS)
              2'b00: begin
                next_state = IDLE;
              end
              default: next_state = ERROR;
            endcase
          end

          else begin
            next_state = state;
          end
        end

        ERROR: begin
          if(HTRANS == 2'b00) begin
            next_state = IDLE;
          end
          else begin
            next_state = ERROR;
          end
        end
      endcase
    end
  end

  // Controls wrap_counte_reg which later gets assigned to wrap_counter assignment to keep syhtizablity & correct behaviour
  always@(*) begin
    case(HBURST)
      WRAP4: begin
        if(wrap_counter_reg == 1) begin half_of_wrap = 1; end
        else                      begin half_of_wrap = 0; end
      end
      WRAP8: begin
        if(wrap_counter_reg == 3) begin half_of_wrap = 1; end
        else                      begin half_of_wrap = 0; end
      end
      WRAP16: begin
        if(wrap_counter_reg == 7) begin half_of_wrap = 1; end
        else                      begin half_of_wrap = 0; end
      end
      default: half_of_wrap = 0;
    endcase // HBURST
  end


endmodule


