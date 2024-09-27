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


module ahb_slave #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ADDR_DEPTH = 16)
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

  reg [DATA_WIDTH-1:0] HRDATA_reg;
  reg [DATA_WIDTH-1:0] HRDATA_reg1;
  reg [ADDR_WIDTH-1:0] HADDR_reg;
  reg [DATA_WIDTH-1:0] HWDATA_reg;
  reg [ 1:0] HRESP_reg;
  reg        HREADYout_reg;
  reg [ 2:0] HBURST_reg;
  reg [ 1:0] HTRANS_reg;
  reg        HREADYin_reg;
  reg        HSEL_reg;

  reg[DATA_WIDTH-1:0] HSIZE_reg;

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
        HRDATA_reg    <= 'b0;
        state         <= IDLE;
        burst_counter_reg <= 0;
        wrap_counter_reg <= 0;
        // synced_wrap_reg <= 0;
      end 
      else begin 
        HRESP          <= HRESP_reg;
        HREADYout      <= HREADYout;
        HRDATA_reg1    <= HRDATA_reg;
        burst_counter  <= burst_counter_reg;
        wrap_counter   <= wrap_counter_reg;
        state          <= next_state;
        HBURST_reg     <= HBURST;
        HTRANS_reg     <= HTRANS;
        HSEL_reg       <= HSEL;
        HADDR_reg      <= HADDR;
        HREADYin_reg   <= HREADYin;
        HWDATA_reg     <= HWDATA;
        HSIZE_reg      <= HSIZE;
      end 
   end 

  always@(*) begin //next_state logic

    if (HSEL && HREADYin) begin
      //$display("time: %0t aaaaaaaaaaaaaaaaaaaaa", $time());
      case(HBURST)
        SINGLE, INCR, INCR4, INCR8, INCR16, WRAP4, WRAP8, WRAP16: begin
        //$display("time: %0t xxxxxxxxxxxxxxxxxxxxxxxxxxxxx", $time());
          case (HTRANS) 
            2'b00: begin 
              next_state    = IDLE; 
            end 
            2'b01: begin 
              next_state    = BUSY; 
            end 
            2'b10, 2'b11: begin 
              //HREADYout = 1'b0; 
              if((HADDR + burst_counter) < ADDR_DEPTH) begin 
                if (HWRITE) begin 
                  next_state = WRITE; 
                end 
                else if(!HWRITE) begin 
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
          endcase
        end
        default: begin
          next_state = IDLE;
        end
      endcase // HBURST
    end
    else if(HSEL && !HREADYin)begin
      next_state = ERROR;
    end 
    else begin
      next_state = IDLE;
    end
  end


  always@(*) begin //output logic
    case(state)

      IDLE: begin
        burst_counter_reg = 0;        
        HRDATA_reg = HRDATA;
        if(HSEL_reg && HREADYin_reg) begin
          HRESP_reg = 2'b00;
          HREADYout_reg = 1'b1;
        end
        else if (HSEL_reg && !HREADYin_reg) begin
          HRESP_reg = 2'b01;
          HREADYout_reg = 1'b0;
        end
        else begin
          HRESP_reg = 2'b00;
          HREADYout_reg = 1'b1;
        end
      end

      WRITE: begin     
        HRESP_reg = 2'b00;
        HREADYout_reg = 1'b1;
        case(HTRANS_reg)
          2'b00, 2'b01: begin
            burst_counter_reg = 0 ;
          end
          2'b10, 2'b11: begin
            case(HBURST_reg)
              INCR, INCR4, INCR8, INCR16: begin
                case(HSIZE_reg) 
                  BYTE_P:     mem[HADDR_reg + burst_counter] = HWDATA_reg[7:0];
                  HALFWORD_P: mem[HADDR_reg + burst_counter] = HWDATA_reg[15:0];
                  default:     mem[HADDR_reg + burst_counter] = HWDATA_reg[DATA_WIDTH-1:0];
                endcase // HSIZE_reg
                burst_counter_reg = burst_counter_reg + 1;
              end
              WRAP4, WRAP8, WRAP16: begin
                case(HSIZE_reg) 
                  BYTE_P:     mem[HADDR_reg + burst_counter] = HWDATA_reg[7:0];
                  HALFWORD_P: mem[HADDR_reg + burst_counter] = HWDATA_reg[15:0];
                  default:     mem[HADDR_reg + burst_counter] = HWDATA_reg[DATA_WIDTH-1:0];
                endcase //HSIZE_reg
                wrap_counter_reg = wrap_counter_reg - 1;
              end
              default: begin
                case(HSIZE_reg) 
                  BYTE_P:     mem[HADDR_reg + burst_counter] = HWDATA_reg[7:0];
                  HALFWORD_P: mem[HADDR_reg + burst_counter] = HWDATA_reg[15:0];
                  default:     mem[HADDR_reg + burst_counter] = HWDATA_reg[DATA_WIDTH-1:0];
                endcase //HSIZE_reg
                burst_counter_reg = 0 ;
              end
            endcase // HBURST_reg
          end
        endcase // HTRANS_reg                    
      end

      READ: begin
        HRESP_reg                  = 2'b00; //`HRESP_OKAY;
        HREADYout_reg              = 1'b1;
        HRDATA_reg                 = mem[HADDR_reg  +burst_counter_reg];

        case(HTRANS_reg)
          2'b00, 2'b01: begin
            burst_counter_reg = 0 ;
          end
          2'b10, 2'b11: begin
            case(HBURST_reg)
              INCR, INCR4, INCR8, INCR16: begin
                case(HSIZE_reg) 
                  BYTE_P:     HRDATA_reg[7:0] = mem[HADDR_reg  + burst_counter];
                  HALFWORD_P: HRDATA_reg[15:0] = mem[HADDR_reg  + burst_counter];
                  default:     HRDATA_reg[DATA_WIDTH-1:0] = mem[HADDR_reg  + burst_counter];
                endcase //HSIZE_reg                
                burst_counter_reg = burst_counter_reg + 1;
              end
              WRAP4, WRAP8, WRAP16: begin
                case(HSIZE_reg) 
                  BYTE_P:     HRDATA_reg[7:0] = mem[HADDR_reg  + burst_counter];
                  HALFWORD_P: HRDATA_reg[15:0] = mem[HADDR_reg  + burst_counter];
                  default:     HRDATA_reg[DATA_WIDTH-1:0] = mem[HADDR_reg  + burst_counter];
                endcase //HSIZE_reg     
                wrap_counter_reg  = wrap_counter_reg - 1;
              end
              default: begin
                case(HSIZE_reg) 
                  BYTE_P:     HRDATA_reg[7:0] = mem[HADDR_reg  + burst_counter];
                  HALFWORD_P: HRDATA_reg[15:0] = mem[HADDR_reg  + burst_counter];
                  default:     HRDATA_reg[DATA_WIDTH-1:0] = mem[HADDR_reg  + burst_counter];
                endcase //HSIZE_reg     
                burst_counter_reg = 0 ;
              end
            endcase // HBURST_reg
          end
        endcase // HTRANS_reg  
      end

      ERROR: begin
        HRESP_reg     = 2'b01;
        HREADYout_reg =  1'b1;
        HRDATA_reg    = HRDATA;
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


  assign HRDATA = HRDATA_reg1;

endmodule
// `endif





