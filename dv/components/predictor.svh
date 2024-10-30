/******************************************************************
 * File: predictor.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a predictor for a FIFO-based system 
 *              in a UVM testbench. It is responsible for monitoring 
 *              the FIFO and providing expected outputs based on its 
 *              internal state. The class includes methods for writing 
 *              and reading from the FIFO, and it maintains the FIFO 
 *              state including pointers and flags.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class predictor extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(predictor);

  // Virtual interface to interact with the DUT
  virtual inf my_vif;

  // Analysis port for sending expected outputs
  uvm_analysis_port #(sequence_item) analysis_port_expected_outputs;

  // Sequence item for expected output values
  sequence_item seq_item_expected;

  // Events for synchronization
  event inputs_written;
  event expected_outputs_written;


  // logic [DATA_WIDTH-1:0] slave0 [P_SLAVE0_START:P_SLAVE0_END];
  // logic [DATA_WIDTH-1:0] slave1 [P_SLAVE1_START:P_SLAVE1_END];
  // logic [DATA_WIDTH-1:0] slave2 [P_SLAVE2_START:P_SLAVE2_END];

  // AHB lite Control Signals
  bit                   HRESETn;    // reset (active low)
  logic   HWRITE;

  bit   [TRANS_WIDTH:0]  HTRANS; 
  bit   [SIZE_WIDTH:0]  HSIZE;
  bit   [BURST_WIDTH:0]  HBURST;
  bit   [PROT_WIDTH:0]  HPROT; 

  bit   [ADDR_WIDTH-1:0]  HADDR; 
  bit   [ADDR_WIDTH-BITS_FOR_PERIPHERALS-1:0] HADDR_VALID;
  bit   [ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS] HSEL;  
  bit   [DATA_WIDTH-1:0]  HWDATA; 

  // AHB lite output Signals
  logic   [DATA_WIDTH-1:0]  HRDATA_expected;
  logic   [RESP_WIDTH-1:0]  HRESP_expected; 
  logic   [DATA_WIDTH-1:0]  HREADY_expected;

  logic   [DATA_WIDTH-1:0]  HRDATA_expected0;
  logic   [DATA_WIDTH-1:0]  HRDATA_expected1;
  logic   [DATA_WIDTH-1:0]  HRDATA_expected2;
  logic   [DATA_WIDTH-1:0]  HRDATA_expected3;

  logic [DATA_WIDTH-1:0] slave0 [ADDR_DEPTH-1:0];
  logic [DATA_WIDTH-1:0] slave1 [ADDR_DEPTH-1:0];
  logic [DATA_WIDTH-1:0] slave2 [ADDR_DEPTH-1:0];

  HRESET_e     RESET_op;
  HWRITE_e     WRITE_op;
  HTRANS_e     TRANS_op;
  HBURST_e     BURST_op;
  HSIZE_e      SIZE_op;

  integer burst_counter;
  integer wrap_counter;  

  HRESP_e      RESP_op;
  string data_str;
  // Constructor
  function new(string name = "predictor", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    analysis_port_expected_outputs = new("analysis_port_expected_outputs", this);

    if(!uvm_config_db#(virtual inf)::get(this,"","my_vif",my_vif)) begin
      `uvm_fatal(get_full_name(),"Error");
    end

    $display("my_predictor build phase");
  endfunction : build_phase

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    $display("my_predictor connect phase");
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin      
      $display("my_predictor run phase");
      seq_item_expected = sequence_item::type_id::create("seq_item_expected");
      @(inputs_written);
      // `uvm_info("PREDICTOR", {"WRITTEN_DATA: ", data_str}, UVM_HIGH)
      generic_predictor();
      wait(expected_outputs_written.triggered);
      //if(HREADY_expected == 1) begin
        sequence_item::PREDICTOR_transaction_counter = sequence_item::PREDICTOR_transaction_counter + 1;
        analysis_port_expected_outputs.write(seq_item_expected);
        `uvm_info("PREDICTOR", {"EXPECTED_DATA: ", seq_item_expected.input2string()}, UVM_HIGH)
      //end
    end
  endtask

  // Write method for processing sequence items
  function void write(sequence_item t);
    if(HSEL != 3 && HRESP_expected == ERROR && HTRANS != IDLE && t.HBURST == SINGLE) begin
      HTRANS  = 0;
      $display("OVERRIDING TO IDLE");
    end
    else begin
      HTRANS  = t.HTRANS;
    end
      HRESETn = t.HRESETn;
      HWRITE  = t.HWRITE;
      HADDR   = t.HADDR;
      HSIZE   = t.HSIZE;
      HBURST  = t.HBURST;
      HPROT   = t.HPROT;
      HWDATA  = t.HWDATA;
      HADDR_VALID = HADDR[ADDR_WIDTH-BITS_FOR_PERIPHERALS-1:0];//29:0
      HSEL        = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS];//31:30
      RESET_op   = t.RESET_op;
      WRITE_op   = t.WRITE_op;
      TRANS_op   = t.TRANS_op;
      BURST_op   = t.BURST_op;          
      SIZE_op    = t.SIZE_op;
     data_str   = $sformatf("HRESETn:%0d, HWRITE:%0d, HTRANS:%0d, HSIZE:%0d, HBURST:%0d, HPROT:%0d, HADDR:%0d, HWDATA:%0d",
                             HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA);
    -> inputs_written;
  endfunction

  // Task for processing AHB operations based on inputs
  task generic_predictor();
    data_phase();
  endtask : generic_predictor

  // Send expected results to the analysis port
  function void send_results();
    seq_item_expected.HRESETn     = HRESETn;
    seq_item_expected.HWRITE      = HWRITE;
    seq_item_expected.HTRANS      = HTRANS;
    seq_item_expected.HSIZE       = HSIZE;
    seq_item_expected.HBURST      = HBURST;
    seq_item_expected.HPROT       = HPROT;
    seq_item_expected.HADDR       = HADDR;
    seq_item_expected.HWDATA      = HWDATA;

    seq_item_expected.HRESP       = HRESP_expected;
    seq_item_expected.HREADY      = HREADY_expected;
    seq_item_expected.HRDATA      = HRDATA_expected;
    -> expected_outputs_written;
  endfunction : send_results

    task data_phase();
      if(HRESETn === 1'b0)
          reset_AHB();
      else if(HWRITE === 1'b1) begin
          write_AHB();
      end
      else if(HWRITE === 1'b0) begin
          read_AHB();
      end
      send_results(/*iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA*/);
    endtask : data_phase


    // Task: Reset AHB pointers and flags
    task reset_AHB();
      HRESP_expected   = OKAY;
      HREADY_expected  = READY;
      HRDATA_expected  = 0;
      HRDATA_expected0 = 0;
      HRDATA_expected1 = 0;
      HRDATA_expected2 = 0;
      HRDATA_expected3 = 0;
      HTRANS           = IDLE;
      wrap_counter     = -10;
      burst_counter    = 0;
    endtask : reset_AHB

    // Task: Write data into the AHB and handle pointer updates
  task write_AHB();
    HRESP_expected = OKAY;
    HREADY_expected = READY;
    if(HSEL != 3) begin
      case(HTRANS)
        IDLE, BUSY: begin
          if(HBURST == SINGLE) begin
            if(~(((HADDR_VALID + burst_counter) < ADDR_DEPTH) & (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH))) begin
              HRESP_expected = ERROR;
            end
          end
          else begin
            if(~(/*(signed'(HADDR_VALID + wrap_counter) > 0) &*/ ((HADDR_VALID + burst_counter) < ADDR_DEPTH) & (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH))) begin
              HRESP_expected = ERROR;
            end       
          end
          wrap_counter  = -10;
          burst_counter = 0;
          HRDATA_expected = HRDATA_expected;
        end

        NONSEQ, SEQ:  begin
          case(HBURST)
            INCR, INCR4, INCR8, INCR16: begin
              write_process(burst_counter);
              if(HADDR_VALID + burst_counter < ADDR_DEPTH)
                burst_counter = burst_counter +1;
            end
            WRAP4, WRAP8, WRAP16: begin
              if(wrap_counter == -10) begin
                case(HBURST)
                  WRAP4:  wrap_counter = 1;
                  WRAP8:  wrap_counter = 3;
                  WRAP16: wrap_counter = 7;
                endcase // HBURST
              end
              write_process(wrap_counter);
              if(/*(signed'(HADDR_VALID + wrap_counter) > 0) &*/ (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) 
                wrap_counter = wrap_counter -1;
            end

            default: begin
              write_process(0);
            end

          endcase // HBURST
        end
      endcase // HTRANS
    end
    else begin
      HRESP_expected  = 1;
      HRDATA_expected = 0;
    end

  endtask : write_AHB

    task write_process(input int counter);
      // int size;
      // size = size_determiner();
      if(((HADDR_VALID + counter) < ADDR_DEPTH) /*& ((HADDR_VALID + counter) > 0)*/) begin
        case (HSIZE)

          BYTE_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                slave0[HADDR_VALID + counter] = HWDATA[BYTE_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE0:", $sformatf("%0h, %0h, %0h", slave0[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end
              2'b01: begin
                slave1[HADDR_VALID + counter] = HWDATA[BYTE_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE1:", $sformatf("%0h, %0h, %0h", slave1[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)

              end
              2'b10: begin
                slave2[HADDR_VALID + counter] = HWDATA[BYTE_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE2:", $sformatf("%0h, %0h, %0h", slave2[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end
              default: begin
                HRESP_expected = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          HALFWORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                slave0[HADDR_VALID + counter] = HWDATA[HALFWORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE0:", $sformatf("%0h, %0h", slave0[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              2'b01: begin
                slave1[HADDR_VALID + counter] = HWDATA[HALFWORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE1:", $sformatf("%0h, %0h", slave1[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)

              end
              2'b10: begin
                slave2[HADDR_VALID + counter] = HWDATA[HALFWORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE2:", $sformatf("%0h, %0h", slave2[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          default : begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                slave0[HADDR_VALID + counter] = HWDATA[WORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE0:", $sformatf("%0h, %0h", slave0[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              2'b01: begin
                slave1[HADDR_VALID + counter] = HWDATA[WORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE1:", $sformatf("%0h, %0h", slave1[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)

              end
              2'b10: begin
                slave2[HADDR_VALID + counter] = HWDATA[WORD_WIDTH-1:0];
                `uvm_info("PREDICTOR", {"WRITE_SLAVE2:", $sformatf("%0h, %0h", slave2[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase 
          end

        endcase
      end
      else begin
        HRESP_expected = ERROR;
        HREADY_expected = NOT_READY;
      end
    endtask : write_process

    // Task: Read data from the AHB and handle pointer updates
  task read_AHB();
    HRESP_expected = OKAY;
    HREADY_expected = READY;
    if(HSEL != 3) begin
      case(HTRANS)

        IDLE, BUSY: begin
          wrap_counter = -10;
          burst_counter = 0;  
          if(HBURST == SINGLE) begin  
            if(~(/*(signed'(HADDR_VALID + wrap_counter) > 0) &*/ ((HADDR_VALID + burst_counter) < ADDR_DEPTH) & (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH))) begin
              HRESP_expected = ERROR;
            end
          end
          else begin
            if(~(/*(signed'(HADDR_VALID + wrap_counter) > 0) &*/ ((HADDR_VALID + burst_counter) < ADDR_DEPTH) & (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH))) begin
              HRESP_expected = ERROR;
            end       
          end
          HRDATA_expected = HRDATA_expected;
        end

        NONSEQ, SEQ: begin
          case(HBURST)

            INCR, INCR4, INCR8, INCR16: begin
              read_process(burst_counter);
              if(HADDR_VALID + burst_counter < ADDR_DEPTH)
                burst_counter = burst_counter +1;
            end

            WRAP4, WRAP8, WRAP16: begin
              if(wrap_counter == -10) begin
                case(HBURST)
                  WRAP4:  wrap_counter = 1;
                  WRAP8:  wrap_counter = 3;
                  WRAP16: wrap_counter = 7;
                endcase // HBURST
              end
              read_process(wrap_counter);
              if(/*(signed'(HADDR_VALID + wrap_counter) > 0) &*/ (signed'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) 
                wrap_counter = wrap_counter -1;
            end

            default: begin
              read_process(0);
            end

          endcase // HBURST
        end
      endcase // HTRANS
    end
    else begin
      HRESP_expected  = 1;
      HRDATA_expected = 0;
    end
  endtask : read_AHB


    task read_process(input int counter);
      if(((HADDR_VALID + counter) < ADDR_DEPTH) /*& ((HADDR_VALID + counter) > 0)*/) begin
        case (HSIZE)
          BYTE_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                HRDATA_expected[BYTE_WIDTH-1:0] = slave0[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE0:", $sformatf("%0h  %0h", slave0[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              2'b01: begin
                HRDATA_expected[BYTE_WIDTH-1:0] = slave1[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE1:", $sformatf("%0h  %0h", slave1[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              2'b10: begin
                HRDATA_expected[BYTE_WIDTH-1:0] = slave2[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE2:", $sformatf("%0h  %0h", slave2[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              default: begin
                HRDATA_expected[BYTE_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          HALFWORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                HRDATA_expected[HALFWORD_WIDTH-1:0] = slave0[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE0:", $sformatf("%0h", slave0[HADDR_VALID+counter])}, UVM_LOW)
              end
              2'b01: begin
                HRDATA_expected[HALFWORD_WIDTH-1:0] = slave1[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE1:", $sformatf("%0h", slave1[HADDR_VALID+counter])}, UVM_LOW)
              end
              2'b10: begin
                HRDATA_expected[HALFWORD_WIDTH-1:0] = slave2[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE2:", $sformatf("%0h", slave2[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expected[HALFWORD_WIDTH-1:0] = 0;
                HRESP_expected = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end


          default : begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS])
              2'b00: begin
                HRDATA_expected[WORD_WIDTH-1:0] = slave0[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE0:", $sformatf("%0h", slave0[HADDR_VALID+counter])}, UVM_LOW)
              end
              2'b01: begin
                HRDATA_expected[WORD_WIDTH-1:0] = slave1[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE1:", $sformatf("%0h", slave1[HADDR_VALID+counter])}, UVM_LOW)
              end
              2'b10: begin
                HRDATA_expected[WORD_WIDTH-1:0] = slave2[HADDR_VALID+counter];
                `uvm_info("PREDICTOR", {"READ_SLAVE2:", $sformatf("%0h", slave2[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expected[WORD_WIDTH-1:0] = 0;
                HRESP_expected = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

        endcase
      end
      else begin
        HRESP_expected = ERROR;
        HREADY_expected = NOT_READY;
      end
    endtask : read_process

endclass : predictor