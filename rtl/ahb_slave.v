// `ifndef AHB_DEFAULT_SLAVE_V
// `define AHB_DEFAULT_SLAVE_V
//--------------------------------------------------------
// Copyright (c) 2007-2011 by Ando Ki.
// All right reserved.
//
// http://www.dynalith.com
// adki@dynalith.com
//--------------------------------------------------------
// VERSION: 2011.03.20.
//--------------------------------------------------------
// a simplified version of AMBA AHB default slave
//--------------------------------------------------------
`timescale 1ns/1ns


module ahb_slave #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ADDR_DEPTH = 16, NO_OF_SLAVES = 4)
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
       output  wire  [DATA_WIDTH-1:0] HRDATA,
       output  reg   [ 1:0] HRESP,
       output  reg       error_idle_control,
       input   wire         HREADYin,
       output  reg          HREADYout
);
   /*********************************************************/
   /*********************************************************/ 

  reg [DATA_WIDTH-1:0] HRDATA_reg_s;
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


   /*********************************************************/
       reg [2:0] state, next_state;
       localparam IDLE   = 3'b000,
                  BUSY   = 3'b001,
                  WRITE  = 3'b010,
                  READ   = 3'b011,
                  ERROR  = 3'b101;

                  //HBURST PARAMETERS
      localparam SINGLE     = 3'b000;
      localparam INCR       = 3'b001;
      localparam WRAP4      = 3'b010;
      localparam INCR4      = 3'b011;
      localparam WRAP8      = 3'b100;
      localparam INCR8      = 3'b101;
      localparam WRAP16     = 3'b110;
      localparam INCR16     = 3'b111;

      //HSIZE PARAMETERS
      localparam BYTE_P     = 3'b000;
      localparam HALFWORD_P = 3'b001;
      localparam WORD_P     = 3'b010;
      localparam WORD2_P    = 3'b011;
      localparam WORD4_P    = 3'b100;
      localparam WORD8_P    = 3'b101;
      localparam WORD16_P   = 3'b110;
      localparam WORD32_P   = 3'b111;
   /*********************************************************/


    always@(posedge HCLK or negedge HRESETn) begin
      if (HRESETn==0) begin
        HRESP         <= 2'b00; 
        HREADYout     <= 1'b1;
        HRDATA_reg_s    <= 'b0;
      end 
      else begin
        HREADYout                 <= HREADYout_reg_d;
        HRDATA_reg_s              <= HRDATA_reg_d;
        HRESP                     <= HRESP_reg_d;        
      end
    end

    always @ (posedge HCLK or negedge HRESETn) begin
      if (HRESETn==0) begin
        state         <= IDLE;
        burst_counter_reg <= 0;
        wrap_counter_reg <= 0;

        HRDATA_reg_d <= 0;
        HRESP_reg_d  <= 0;
        HREADYout_reg_d <= 1;
      end 
      else begin 
        state               <= next_state;

        HBURST_reg_c     <= HBURST;
        HTRANS_reg_c     <= HTRANS;
        HSEL_reg_c       <= HSEL;
        HADDR_reg_c      <= HADDR[ADDR_WIDTH-$clog2(NO_OF_SLAVES)-1:0];
        HREADYin_reg_c   <= HREADYin;
        HSIZE_reg_c      <= HSIZE;
        HWRITE_reg_c     <= HWRITE;


        burst_counter   <= burst_counter_reg;
        wrap_counter    <= wrap_counter_reg;

        HBURST_reg_d     <= HBURST_reg_c;
        HTRANS_reg_d     <= HTRANS_reg_c;
        HSEL_reg_d       <= HSEL_reg_c;
        HADDR_reg_d      <= HADDR_reg_c;
        HREADYin_reg_d   <= HREADYin_reg_c;
        HSIZE_reg_d      <= HSIZE_reg_c;

        HWDATA_reg_d     <= HWDATA;


      end 
   end


  always@(*) begin //next_state logic
    if (HSEL_reg_c && HREADYin_reg_c) begin

      case (HTRANS_reg_c) 
        2'b00: begin 
          next_state    <= IDLE;
          error_idle_control <= 0;  
        end 
        2'b01: begin 
          next_state    <= BUSY; 
        end 
        2'b10, 2'b11: begin 
          //HREADYout <= 1'b0; 
          if((HADDR_reg_c + burst_counter < ADDR_DEPTH) & (HADDR_reg_c + wrap_counter < ADDR_DEPTH)) begin 
            if (HWRITE_reg_c) begin 
              next_state <= WRITE; 
            end 
            else if(~HWRITE_reg_c) begin 
              next_state <= READ; 
            end
            else begin 
              next_state <= ERROR;
              error_idle_control <= 1; 
            end 
          end 
          else begin 
            next_state <= ERROR;
            error_idle_control <= 1;  
          end
        end
        default: begin
          next_state <= IDLE;
        end 
      endcase //HTRANS_reg_c
    end

    else if(HSEL_reg_c && !HREADYin_reg_c)begin
      next_state <= IDLE;
                error_idle_control <= 0;
    end 
    else begin
      next_state <= IDLE;
    end
  end


  always@(*) begin //output logic
      case(state)

        IDLE: begin
          burst_counter_reg = 0;
         // wrap_counter_reg = 0;        
          HRDATA_reg_d = HRDATA_reg_d;
          if(HSEL_reg_d && HREADYin_reg_d) begin
            HRESP_reg_d = 2'b00;
            HREADYout_reg_d = 1'b1;
          end
          else if (HSEL_reg_d && !HREADYin_reg_d) begin
            HRESP_reg_d = 2'b01;
            HREADYout_reg_d = 1'b1;
          end
          else begin
            HRESP_reg_d = 2'b00;
            HREADYout_reg_d = 1'b1;
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
              if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & (HADDR_reg_d + wrap_counter < ADDR_DEPTH)) begin
                HRESP_reg_d = 2'b00;
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[7:0];
                      HALFWORD_P: mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[15:0];
                      default:     mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[DATA_WIDTH-1:0];
                    endcase // HSIZE_reg_d
                    burst_counter_reg = burst_counter_reg + 1;
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     mem[HADDR_reg_d + wrap_counter] = HWDATA_reg_d[7:0];
                      HALFWORD_P: mem[HADDR_reg_d + wrap_counter] = HWDATA_reg_d[15:0];
                      default:     mem[HADDR_reg_d + wrap_counter] = HWDATA_reg_d[DATA_WIDTH-1:0];
                    endcase //HSIZE_reg_d
                    wrap_counter_reg = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[7:0];
                      HALFWORD_P: mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[15:0];
                      default:     mem[HADDR_reg_d + burst_counter] = HWDATA_reg_d[DATA_WIDTH-1:0];
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
          HREADYout_reg_d              = 1'b1;
          //HRDATA_reg_d                 = mem[HADDR_reg_d  +burst_counter_reg];
          $display("%0t WHY AM I HERE NOW1?", $time());
          case(HTRANS_reg_d)
            2'b00, 2'b01: begin
              HRESP_reg_d         = 2'b00; //`HRESP_OKAY;
              burst_counter_reg = 0 ;
            end
            2'b10, 2'b11: begin
              if((HADDR_reg_d + burst_counter < ADDR_DEPTH) & (HADDR_reg_d + wrap_counter < ADDR_DEPTH)) begin
                case(HBURST_reg_d)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     HRDATA_reg_d[7:0] = mem[HADDR_reg_d  + burst_counter];
                      HALFWORD_P: HRDATA_reg_d[15:0] = mem[HADDR_reg_d  + burst_counter];
                      default:     HRDATA_reg_d[DATA_WIDTH-1:0] = mem[HADDR_reg_d  + burst_counter];
                    endcase //HSIZE_reg_d                
                    burst_counter_reg = burst_counter_reg + 1;
                    $display("%0t WHY AM I HERE NOW2?", $time());
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     HRDATA_reg_d[7:0] = mem[HADDR_reg_d  + wrap_counter];
                      HALFWORD_P: HRDATA_reg_d[15:0] = mem[HADDR_reg_d  + wrap_counter];
                      default:     HRDATA_reg_d[DATA_WIDTH-1:0] = mem[HADDR_reg_d  + wrap_counter];
                    endcase //HSIZE_reg_d     
                    wrap_counter_reg  = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg_d) 
                      BYTE_P:     HRDATA_reg_d[7:0] = mem[HADDR_reg_d  + burst_counter];
                      HALFWORD_P: HRDATA_reg_d[15:0] = mem[HADDR_reg_d  + burst_counter];
                      default:     HRDATA_reg_d[DATA_WIDTH-1:0] = mem[HADDR_reg_d  + burst_counter];
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
          // if(HREADYin) begin
            HRESP_reg_d     = 2'b01;
            HREADYout_reg_d =  1'b0;
            HRDATA_reg_d    = HRDATA_reg_d;
          // end
          // else begin
          //   HRESP_reg_d     = 2'b01;
          //   HREADYout_reg_d =  1'b1;
          //   HRDATA_reg_d    = HRDATA;
          // end
        end
      endcase // state
  end

  always @(HBURST) begin 
    case(HBURST)
      WRAP4:  wrap_counter_reg = 1;
      WRAP8:  wrap_counter_reg = 3;
      WRAP16: wrap_counter_reg = 7;
      default: wrap_counter_reg = wrap_counter_reg;
    endcase
  end


  assign HRDATA = HRDATA_reg_s;

  //assign error_idle_control = (next_state == ERROR)? 1:0;

endmodule
// `endif





