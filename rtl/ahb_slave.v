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
       input   wire         HREADYin,
       output  reg          HREADYout
);
   /*********************************************************/
   /*********************************************************/ 

  reg [DATA_WIDTH-1:0] HRDATA_reg0;
  reg [DATA_WIDTH-1:0] HRDATA_reg1;
  reg [DATA_WIDTH-1:0] HRDATA_reg2;


  reg [ADDR_WIDTH-1:0] HADDR_reg0;
  //reg [DATA_WIDTH-1:0] HWDATA_reg0;
  //reg [ 1:0] HRESP_reg0;
  reg        HREADYout_reg0;
  reg [ 2:0] HBURST_reg0;
  reg [ 1:0] HTRANS_reg0;
  reg        HREADYin_reg0;
  reg        HSEL_reg0;

  reg[DATA_WIDTH-1:0] HSIZE_reg0;
  reg HWRITE_reg0;

  reg [ADDR_WIDTH-1:0] HADDR_reg1;  
  reg [DATA_WIDTH-1:0] HWDATA_reg1;
  reg [ 1:0] HRESP_reg1;
  reg        HREADYout_reg1;
  reg [ 2:0] HBURST_reg1;
  reg [ 1:0] HTRANS_reg1;
  reg        HREADYin_reg1;
  reg        HSEL_reg1;

  reg[DATA_WIDTH-1:0] HSIZE_reg1;

  reg [DATA_WIDTH-1-1:0] mem [ADDR_DEPTH-1:0];

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



    always @ (posedge HCLK or negedge HRESETn) begin
      if (HRESETn==0) begin
        HRESP         <= 2'b00; 
        HREADYout     <= 1'b1;
        HRDATA_reg0    <= 'b0;
        state         <= IDLE;
        burst_counter_reg <= 0;
        wrap_counter_reg <= 0;
      end 
      else begin 
        HRDATA_reg1         <= HRDATA_reg0;

        state               <= next_state;

        HBURST_reg0     <= HBURST;
        HTRANS_reg0     <= HTRANS;
        HSEL_reg0       <= HSEL;
        HADDR_reg0      <= HADDR[ADDR_WIDTH-$clog2(NO_OF_SLAVES)-1:0];
        HREADYin_reg0   <= HREADYin;
        HSIZE_reg0      <= HSIZE;
        HWRITE_reg0     <= HWRITE;


        HREADYout      <= HREADYout_reg1;
        HRDATA_reg2    <= HRDATA_reg1;

        burst_counter  <= burst_counter_reg;
        wrap_counter   <= wrap_counter_reg;

        HBURST_reg1     <= HBURST_reg0;
        HTRANS_reg1     <= HTRANS_reg0;
        HSEL_reg1       <= HSEL_reg0;
        HADDR_reg1      <= HADDR_reg0;
        HREADYin_reg1   <= HREADYin_reg0;
        HSIZE_reg1      <= HSIZE_reg0;

        HWDATA_reg1     <= HWDATA;
      end 
   end


  always@(*) begin //next_state logic
    if (HSEL_reg0 && HREADYin_reg0) begin
      //$display("time: %0t aaaaaaaaaaaaaaaaaaaaa", $time());
      case(HBURST_reg0)
        SINGLE, INCR, INCR4, INCR8, INCR16, WRAP4, WRAP8, WRAP16: begin
        //$display("time: %0t xxxxxxxxxxxxxxxxxxxxxxxxxxxxx", $time());
          case (HTRANS_reg0) 
            2'b00: begin 
              next_state    <= IDLE; 
            end 
            2'b01: begin 
              next_state    <= BUSY; 
            end 
            2'b10, 2'b11: begin 
              //HREADYout <= 1'b0; 
              if((HADDR_reg0 + burst_counter < ADDR_DEPTH) & (HADDR_reg0 + wrap_counter < ADDR_DEPTH)) begin 
                if (HWRITE_reg0) begin 
                  next_state <= WRITE; 
                end 
                else if(~HWRITE_reg0) begin 
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
          endcase //HTRANS
        end
        default: begin
          next_state <= IDLE;
        end
      endcase // HBURST
    end
    else if(HSEL_reg0 && !HREADYin_reg0)begin
      next_state <= ERROR;
    end 
    else begin
      next_state <= IDLE;
    end
  end


  always@(*) begin //output logic
      case(state)

        IDLE: begin
          burst_counter_reg = 0;        
          HRDATA_reg1 = HRDATA;
          if(HSEL_reg1 && HREADYin_reg1) begin
            HRESP = 2'b00;
            HREADYout_reg1 = 1'b1;
          end
          else if (HSEL_reg1 && !HREADYin_reg1) begin
            HRESP = 2'b01;
            HREADYout_reg1 = 1'b0;
          end
          else begin
            HRESP = 2'b00;
            HREADYout_reg1 = 1'b1;
          end
        end

        WRITE: begin     
          HREADYout_reg1 = 1'b1;
          case(HTRANS_reg1)
            2'b00, 2'b01: begin
              HRESP = 2'b00;
              burst_counter_reg = 0 ;
            end
            2'b10, 2'b11: begin
              if((HADDR_reg1 + burst_counter < ADDR_DEPTH) & (HADDR_reg1 + wrap_counter < ADDR_DEPTH)) begin
                HRESP = 2'b00;
                case(HBURST_reg1)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[7:0];
                      HALFWORD_P: mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[15:0];
                      default:     mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[DATA_WIDTH-1:0];
                    endcase // HSIZE_reg1
                    burst_counter_reg = burst_counter_reg + 1;
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     mem[HADDR_reg1 + wrap_counter] = HWDATA_reg1[7:0];
                      HALFWORD_P: mem[HADDR_reg1 + wrap_counter] = HWDATA_reg1[15:0];
                      default:     mem[HADDR_reg1 + wrap_counter] = HWDATA_reg1[DATA_WIDTH-1:0];
                    endcase //HSIZE_reg1
                    wrap_counter_reg = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[7:0];
                      HALFWORD_P: mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[15:0];
                      default:     mem[HADDR_reg1 + burst_counter] = HWDATA_reg1[DATA_WIDTH-1:0];
                    endcase //HSIZE_reg1
                    burst_counter_reg = 0 ;
                  end
                endcase // HBURST_reg1
              end
              else begin
                HRESP = 2'b01; //error
              end
            end
          endcase // HTRANS_reg1                    
        end

        READ: begin
          HREADYout_reg1              = 1'b1;
          //HRDATA_reg1                 = mem[HADDR_reg1  +burst_counter_reg];

          case(HTRANS_reg1)
            2'b00, 2'b01: begin
              HRESP         = 2'b00; //`HRESP_OKAY;
              burst_counter_reg = 0 ;
            end
            2'b10, 2'b11: begin
              if((HADDR_reg1 + burst_counter < ADDR_DEPTH) & (HADDR_reg1 + wrap_counter < ADDR_DEPTH)) begin
                case(HBURST_reg1)
                  INCR, INCR4, INCR8, INCR16: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     HRDATA_reg1[7:0] = mem[HADDR_reg1  + burst_counter];
                      HALFWORD_P: HRDATA_reg1[15:0] = mem[HADDR_reg1  + burst_counter];
                      default:     HRDATA_reg1[DATA_WIDTH-1:0] = mem[HADDR_reg1  + burst_counter];
                    endcase //HSIZE_reg1                
                    burst_counter_reg = burst_counter_reg + 1;
                  end
                  WRAP4, WRAP8, WRAP16: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     HRDATA_reg1[7:0] = mem[HADDR_reg1  + wrap_counter];
                      HALFWORD_P: HRDATA_reg1[15:0] = mem[HADDR_reg1  + wrap_counter];
                      default:     HRDATA_reg1[DATA_WIDTH-1:0] = mem[HADDR_reg1  + wrap_counter];
                    endcase //HSIZE_reg1     
                    wrap_counter_reg  = wrap_counter_reg - 1;
                  end
                  default: begin
                    case(HSIZE_reg1) 
                      BYTE_P:     HRDATA_reg1[7:0] = mem[HADDR_reg1  + burst_counter];
                      HALFWORD_P: HRDATA_reg1[15:0] = mem[HADDR_reg1  + burst_counter];
                      default:     HRDATA_reg1[DATA_WIDTH-1:0] = mem[HADDR_reg1  + burst_counter];
                    endcase //HSIZE_reg1     
                    burst_counter_reg = 0 ;
                  end
                endcase // HBURST_reg1
              end 
              else begin
                HRESP = 2'b01;
              end
            end
          endcase // HTRANS_reg1  
        end

        ERROR: begin
          HRESP     = 2'b01;
          HREADYout_reg1 =  1'b1;
          HRDATA_reg1    = HRDATA;
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


  assign HRDATA = HRDATA_reg2;

endmodule
// `endif





