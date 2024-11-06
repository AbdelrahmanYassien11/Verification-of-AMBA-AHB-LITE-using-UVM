// `ifndef AHB_SUBORDINATE_CONFIG
// `define AHB_SUBORDINATE_CONFIG
//----------------------------------------------------------------
//  * File: ahb_slave.v
//  * Author: Abdelrahman Mohamad Yassien
//  * Email: Abdelrahman.Yassien11@gmail.com
//  * Date: 25/10/2024
//  * Description: This module works as an AHB SUBORDINATE as per 
//                  described per AMBA SPECIFICATION by ARM.
//----------------------------------------------------------------
//----------------------------------------------------------------
`timescale 1ns/1ns

`include "../dv/AHB_subordinate_defines.vh"

module ahb_slave 
  #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, ADDR_DEPTH = 16, NO_OF_SUBORDINATES = 4, BITS_FOR_SUBORDINATES = $clog2(NO_OF_SUBORDINATES))
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

       input   wire         HREADYin,

       output  reg   [DATA_WIDTH-1:0] HRDATA,
       output  reg   [ 1:0]           HRESP,
       output  reg                    HREADYout
);
   /*********************************************************/
     
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
   /*********************************************************/ 

  //reg [DATA_WIDTH-1:0] HRDATA_reg_s;
  reg [DATA_WIDTH-1:0] HRDATA_reg_d;
  //reg [DATA_WIDTH-1:0] HRDATA_reg2;
  reg [ 1:0] HRESP_reg_d;


  reg [ADDR_WIDTH-1:0] HADDR_reg_c;
  //reg [DATA_WIDTH-1:0] HWDATA_reg_c;
  //reg        HREADYout_reg_c;
  reg [ 2:0] HBURST_reg_c;
  reg [ 1:0] HTRANS_reg_c;
  reg        HREADYin_reg_c;
  reg        HSEL_reg_c;

  reg[DATA_WIDTH-1:0] HSIZE_reg_c;
  reg HWRITE_reg_c;

  reg [ADDR_WIDTH-1:0] HADDR_reg_d;  
  reg [DATA_WIDTH-1:0] HWDATA_reg_d;
  reg        HREADYout_reg_d;
  reg [ 2:0] HBURST_reg_d;
  reg [ 1:0] HTRANS_reg_d;
  reg        HREADYin_reg_d;
  reg        HSEL_reg_d;

  reg[DATA_WIDTH-1:0] HSIZE_reg_d;

  reg [DATA_WIDTH-1:0] mem [ADDR_DEPTH-1:0];

  integer burst_counter;
  integer burst_counter_reg;

  integer wrap_counter;
  integer wrap_counter_reg;

  `ifdef HWDATA_WIDTH32


  `endif


   /*********************************************************/
       reg [2:0] state, next_state;

   /*********************************************************/

  `ifdef HWDATA_WIDTH64
    `define HWDATA_WIDTH32
  `elsif HWDATA_WIDTH128
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
  `elsif HWDATA_WIDTH256
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
  `elsif HWDATA_WIDTH512
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
    `define HWDATA_WIDTH256
  `elsif HWDATA_WIDTH1024
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
    `define HWDATA_WIDTH256
    `define HWDATA_WIDTH512
  `else 
    `define HWDATA_WIDTH32
  `endif

   `define HSIZE_conditional_WRITE_def(counter) \
      `ifdef HWDATA_WIDTH32 \
                          HSIZE_BYTE      : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[7:0]; \
                          HSIZE_HALFWORD  : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[15:0]; \
                          HSIZE_WORD      : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[31:0]; \
      `endif
      `ifdef HWDATA_WIDTH64 \
                          HSIZE_WORD2     : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[63:0]; \
      `endif
      `ifdef HWDATA_WIDTH128 \
                          HSIZE_WORD4     : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[127:0]; \
      `endif
      `ifdef HWDATA_WIDTH256 \
                          HSIZE_WORD8     : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[255:0]; \
      `endif
      `ifdef HWDATA_WIDTH512 \
                          HSIZE_WORD16    : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[511:0]; \
      `endif
      `ifdef HWDATA_WIDTH1024 \
                          HSIZE_WORD32    : mem[HADDR_reg_d + counter]  = HWDATA_reg_d[1023:0]; \
      `endif

  `define HSIZE_conditional_READ_def(counter) \
    `ifdef HWDATA_WIDTH32 \
                        HSIZE_BYTE      : HRDATA_reg_d[7:0]     = mem[HADDR_reg_d + counter]; \
                        HSIZE_HALFWORD  : HRDATA_reg_d[15:0]    = mem[HADDR_reg_d + counter]; \
                        HSIZE_WORD      : HRDATA_reg_d[31:0]    = mem[HADDR_reg_d + counter]; \
    `endif
    `ifdef HWDATA_WIDTH64 \
                        HSIZE_WORD2     : HRDATA_reg_d[63:0]    = mem[HADDR_reg_d + counter]; \
    `endif
    `ifdef HWDATA_WIDTH128 \
                        HSIZE_WORD4     : HRDATA_reg_d[127:0]   = mem[HADDR_reg_d + counter]; \
    `endif
    `ifdef HWDATA_WIDTH256 \
                        HSIZE_WORD8     : HRDATA_reg_d[255:0]   = mem[HADDR_reg_d + counter]; \
    `endif
    `ifdef HWDATA_WIDTH512 \
                        HSIZE_WORD16    : HRDATA_reg_d[511:0]   = mem[HADDR_reg_d + counter]; \
    `endif
    `ifdef HWDATA_WIDTH1024 \
                        HSIZE_WORD32    : HRDATA_reg_d[1023:0]  = mem[HADDR_reg_d + counter]; \
    `endif

    //always block to manage OUTPUT/SAMPLING _phase signals
    always@(posedge HCLK or negedge HRESETn) begin
      if (~HRESETn) begin
        HRESP         <= 2'b00; 
        HREADYout     <= 1'b1;
        HRDATA        <= 0;
      end 
      else begin
        HREADYout     <= HREADYout_reg_d;
        HRDATA        <= HRDATA_reg_d;
        HRESP         <= HRESP_reg_d;        
      end
    end

    //always block to manage CONTROL_phase signals
    always@(posedge HCLK or negedge HRESETn) begin
      if (~HRESETn) begin
        state             <= IDLE;
        burst_counter_reg <= 0;
        wrap_counter_reg  <= 0;

        HADDR_reg_c       <= 0;
        HBURST_reg_c      <= 0;
        HTRANS_reg_c      <= 0;
        HSEL_reg_c        <= 0;
        HREADYin_reg_c    <= 1;
        HSIZE_reg_c       <= 0;
        HWRITE_reg_c      <= 0;     
      end 
      else begin 
        state             <= next_state;

        HBURST_reg_c      <= HBURST;
        HTRANS_reg_c      <= HTRANS;
        HSEL_reg_c        <= HSEL;
        HADDR_reg_c       <= HADDR[ADDR_WIDTH-$clog2(NO_OF_SUBORDINATES)-1:0];
        HREADYin_reg_c    <= HREADYin;
        HSIZE_reg_c       <= HSIZE;
        HWRITE_reg_c      <= HWRITE;

        burst_counter     <= burst_counter_reg;
        wrap_counter      <= wrap_counter_reg;
      end
    end

    // always block to manage DATA_phase signals
    always @ (posedge HCLK or negedge HRESETn) begin
      if (~HRESETn) begin
        HRDATA_reg_d      <= 0;
        HRESP_reg_d       <= 0;
        HREADYout_reg_d   <= 1;

        HADDR_reg_d       <= 0;
        HTRANS_reg_d      <= 0;
        HBURST_reg_d      <= 0;
        HSEL_reg_d        <= 0;
        HSIZE_reg_d       <= 0;
        
        HWDATA_reg_d      <= 0;
      end 
      else begin 
        HBURST_reg_d     <= HBURST_reg_c;
        HTRANS_reg_d     <= HTRANS_reg_c;
        HSEL_reg_d       <= HSEL_reg_c;
        HADDR_reg_d      <= HADDR_reg_c;
        HSIZE_reg_d      <= HSIZE_reg_c;

        HWDATA_reg_d     <= HWDATA;
      end 
   end

  //next_state logic combinational always block
  always@(*) begin
    case(state)

      WRITE, READ, IDLE, BUSY: begin
        if (HSEL_reg_c && HREADYin) begin

          case (HTRANS_reg_c) 
            2'b00: begin 
              next_state    <= IDLE; 
            end 
            2'b01: begin 
              next_state    <= BUSY; 
            end 

            2'b11, 2'b10: begin 
              if((HADDR_reg_c + burst_counter < ADDR_DEPTH) & ((HADDR_reg_c + wrap_counter) < ADDR_DEPTH) /*& ((HADDR_reg_c + wrap_counter) > 0)*/) begin 
                if (HWRITE_reg_c) begin 
                  next_state <= WRITE; 
                end 
                else if(~HWRITE_reg_c) begin 
                  next_state <= READ; 
                end
                else begin 
                  next_state <= ERROR;
                end 
              end 
              else begin 
                next_state <= ERROR; 
              end
            end
            default: begin
              next_state <= IDLE;
            end 
          endcase //HTRANS_reg_c
        end

        else if(HSEL_reg_c && !HREADYin)begin
          if(state == ERROR) begin
            next_state <= IDLE;
          end
          else begin
            next_state <= state;
          end
        end

        else begin
          next_state <= IDLE;
        end
      end

      ERROR: begin
        if(HBURST == SINGLE) begin
          next_state <= IDLE;
        end
        else begin
          next_state <= state;
        end
      end
    endcase
  end

  //output logic combinational always block
  always@(*) begin //output logic
      case(state)

        IDLE: begin
          burst_counter_reg = 0;
          HREADYout_reg_d = 1;
          //wrap_counter_reg = -10;        
          HRDATA_reg_d = HRDATA_reg_d;
          if(HSEL_reg_d && HREADYin_reg_c) begin
            if(HRESP_reg_d == 2'b01) begin
              HRESP_reg_d = 2'b01;
            end
            else begin
              HRESP_reg_d = 2'b00;
            end
          end
          else if (HSEL_reg_d && !HREADYin_reg_c) begin
            HRESP_reg_d = 2'b01;
          end
          else begin
            HRESP_reg_d = 2'b00;
          end
        end

        WRITE: begin     
          HREADYout_reg_d = 1'b1;
          case(HTRANS_reg_d)
            2'b00, 2'b01: begin
              HRESP_reg_d = 2'b00;
              burst_counter_reg = 0 ;
            end

            2'b10, 2'b11: begin
              if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & ((HADDR_reg_d + wrap_counter) < ADDR_DEPTH)) begin
                HRESP_reg_d = 2'b00;
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_WRITE_def(burst_counter)
                      default         : HRESP_reg_d = 2'b01;
                    endcase // HSIZE_reg_d
                    burst_counter_reg = burst_counter_reg + 1;
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_WRITE_def(wrap_counter)
                      default         : HRESP_reg_d = 2'b01;
                    endcase //HSIZE_reg_d
                    wrap_counter_reg = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_WRITE_def(0)
                      default         : HRESP_reg_d = 2'b01;
                    endcase //HSIZE_reg_d
                    burst_counter_reg = 0 ;
                  end
                endcase // HBURST_reg_d
              end
              else begin
                HRESP_reg_d = 2'b01; //error
                HRDATA_reg_d = HRDATA_reg_d;
                HREADYout_reg_d = 0;
              end
            end
          endcase // HTRANS_reg_d                    
        end

        READ: begin
          HREADYout_reg_d = 1'b1;
          //HRDATA_reg_d  = mem[HADDR_reg_d + burst_counter_reg];
          $display("%0t WHY AM I HERE NOW1?", $time());
          case(HTRANS_reg_d)
            2'b00, 2'b01: begin
              HRESP_reg_d       = 2'b00; //`HRESP_OKAY;
              burst_counter_reg = 0 ;
            end

            2'b10, 2'b11: begin
              if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & ((HADDR_reg_d + wrap_counter) < ADDR_DEPTH)) begin
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_READ_def(burst_counter)
                      default         : HRESP_reg_d = 2'b01;
                    endcase //HSIZE_reg_d                
                    burst_counter_reg = burst_counter_reg + 1;
                    $display("%0t WHY AM I HERE NOW2?", $time());
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_READ_def(wrap_counter)
                      default         : HRESP_reg_d = 2'b01;
                    endcase //HSIZE_reg_d     
                    wrap_counter_reg  = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg_d) 
                      `HSIZE_conditional_READ_def(0)
                      default         : HRESP_reg_d = 2'b01;
                    endcase //HSIZE_reg_d     
                    burst_counter_reg = 0 ;
                  end
                endcase // HBURST_reg_d
              end 
              else begin
                HRESP_reg_d = 2'b01;
                HRDATA_reg_d = HRDATA_reg_d;
                HREADYout_reg_d = 0;
              end
            end
          endcase // HTRANS_reg_d  
        end

        ERROR: begin
          HRESP_reg_d     = 2'b01;
          HRDATA_reg_d    = HRDATA_reg_d;
          if(next_state == ERROR) begin
            HREADYout_reg_d =  1'b0;
          end
          else begin
            HREADYout_reg_d = 1;
          end
        end
      endcase // state
  end

  // An always block to manage WRAP_COUNTER values
  always @(HBURST) begin
    if(state != IDLE) begin 
      case(HBURST)
        WRAP4:  wrap_counter_reg = 1;
        WRAP8:  wrap_counter_reg = 3;
        WRAP16: wrap_counter_reg = 7;
        default: wrap_counter_reg = wrap_counter_reg;
      endcase
    end
    else begin
      wrap_counter_reg = wrap_counter_reg;
    end
  end


endmodule


