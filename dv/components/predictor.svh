/******************************************************************
 * File: predictor.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 01/12/2024
 * Description: This class defines a predictor for a AMBA AHB lite-interconnect 
 *              in a UVM testbench. It is responsible for recieving the input 
 *              stimulus the AMBA AHB lite and providing expected outputs.  
 *              The class includes methods for writing to and reading from the  
 *              AMBA AHB lite.
 *
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/

class predictor extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(predictor);

  // Virtual interface to interact with the DUT
  virtual inf my_vif;

  // Analysis port for sending expected outputs
  uvm_analysis_port #(sequence_item) analysis_port_expected_outputs;
  //uvm_analysis_port #(sequence_item) analysis_port_expected_outputs_clearing;

  // Sequence item for expected output values
  sequence_item seq_item_expected;

  // Events for synchronization
  event inputs_written;
  event expected_outputs_written;

  realtime async_reset_time;

  sequence_item seq_item_old;
  sequence_item seq_item_older;
  sequence_item seq_item_oldest;
  bit undo_on;

  integer undo_counter_old;
  integer undo_counter_older;
  integer undo_counter_oldest;

  logic   [DATA_WIDTH-1:0]  undo_HWDATA_old;
  logic   [DATA_WIDTH-1:0]  undo_HWDATA_older;
  logic   [DATA_WIDTH-1:0]  undo_HWDATA_oldest;

  // AHB lite Control Signals
  bit     HRESETn;    // reset (active low)
  logic   HWRITE;

  bit   [TRANS_WIDTH-1:0]  HTRANS; 
  bit   [SIZE_WIDTH-1:0]  HSIZE;
  bit   [BURST_WIDTH-1:0]  HBURST;
  bit   [PROT_WIDTH-1:0]  HPROT; 

  bit   [ADDR_WIDTH-1:0]  HADDR; 
  bit   [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] HADDR_VALID;
  bit   [ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] HSEL;  
  logic   [DATA_WIDTH-1:0]  HWDATA; 

  // AHB lite output Signals
  logic   [DATA_WIDTH-1:0]  HRDATA_expected;
  logic   [RESP_WIDTH-1:0]  HRESP_expected; 
  logic   [DATA_WIDTH-1:0]  HREADY_expected;

    logic   [DATA_WIDTH-1:0]  HRDATA_expected1;
      logic   [DATA_WIDTH-1:0]  HRDATA_expected2;
        logic   [DATA_WIDTH-1:0]  HRDATA_expected3;
          logic   [DATA_WIDTH-1:0]  HRDATA_expectedd;
          logic   [DATA_WIDTH-1:0]  HRDATA_expected5;
          logic   [DATA_WIDTH-1:0]  HRDATA_expected6;

  // bit [DATA_WIDTH-1:0] subordinate1 [ADDR_DEPTH-1:0];
  // bit [DATA_WIDTH-1:0] subordinate2 [ADDR_DEPTH-1:0];
  // bit [DATA_WIDTH-1:0] subordinate3 [ADDR_DEPTH-1:0];
  // bit [DATA_WIDTH-1:0] subordinate5 [ADDR_DEPTH-1:0];
  // bit [DATA_WIDTH-1:0] subordinate6 [ADDR_DEPTH-1:0];

  bit [DATA_WIDTH-1:0] subordinate1 [ADDR_DEPTH-1:0];
  bit [DATA_WIDTH-1:0] subordinate2 [ADDR_DEPTH-1:0];
  bit [DATA_WIDTH-1:0] subordinate3 [ADDR_DEPTH-1:0];
  bit [DATA_WIDTH-1:0] subordinate5 [ADDR_DEPTH-1:0];
  bit [DATA_WIDTH-1:0] subordinate6 [ADDR_DEPTH-1:0];

  HRESET_e     RESET_op;
  HWRITE_e     WRITE_op;
  HTRANS_e     TRANS_op;
  HBURST_e     BURST_op;
  HSIZE_e      SIZE_op;

  int burst_counter;
  int wrap_counter;  

  HRESP_e      RESP_op;

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

    seq_item_expected = sequence_item::type_id::create("seq_item_expected");
    seq_item_old = sequence_item::type_id::create("seq_item_old");
    seq_item_older = sequence_item::type_id::create("seq_item_older");
    seq_item_oldest = sequence_item::type_id::create("seq_item_oldest");


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
      generic_predictor();
    end
  endtask

  // Write method for processing sequence items
 function void write(sequence_item t);
    seq_item_old     <= t.clone_me();
    seq_item_older   <= seq_item_old.clone_me();
    seq_item_oldest  <= seq_item_older.clone_me();

    undo_counter_older <= undo_counter_old;
    undo_counter_oldest <= undo_counter_older;

    undo_HWDATA_older  <= undo_HWDATA_old;
    undo_HWDATA_oldest <= undo_HWDATA_older;


    //$display("async_reset_time: %0t and actual time: %0t",async_reset_time, $time());
    if(~t.HRESETn) begin
      undo_last_operation();
    end

    HTRANS      = t.HTRANS;
    HRESETn     = t.HRESETn;
    HWRITE      = t.HWRITE;
    HADDR       = t.HADDR;
    HSIZE       = t.HSIZE;
    HBURST      = t.HBURST;
    HPROT       = t.HPROT;
    HWDATA      = t.HWDATA;
    HADDR_VALID = HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];//28:0
    HSEL        = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES];//31:29
    RESET_op    = t.RESET_op;
    WRITE_op    = t.WRITE_op;
    TRANS_op    = t.TRANS_op;
    BURST_op    = t.BURST_op;          
    SIZE_op     = t.SIZE_op;

    `uvm_info("PREDICTOR", $sformatf("INPUTS WRITTEN: %s", t.input2string), UVM_MEDIUM)
  //Checking if this is the last cycle of a waited error response by any subordinate other than the default subordinate
  -> inputs_written;
  endfunction

  // Task for processing AHB operations based on inputs
  task generic_predictor();
    @(inputs_written);
    seq_item_expected = sequence_item::type_id::create("seq_item_expected");
    data_phase();
    wait(expected_outputs_written.triggered);
    sequence_item::PREDICTOR_transaction_counter = sequence_item::PREDICTOR_transaction_counter + 1;
    analysis_port_expected_outputs.write(seq_item_expected);
    `uvm_info("PREDICTOR", {"EXPECTED_DATA: ", seq_item_expected.convert2string()}, UVM_MEDIUM)
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

    seq_item_expected.HSEL        = HSEL;
    seq_item_expected.HRESP       = HRESP_expected;
    seq_item_expected.HREADY      = HREADY_expected;
    case (HSEL)
      3'b000:  seq_item_expected.HRDATA = 0;
      3'b001:  seq_item_expected.HRDATA = HRDATA_expected1;
      3'b010:  seq_item_expected.HRDATA = HRDATA_expected2;
      3'b011:  seq_item_expected.HRDATA = HRDATA_expected3;
      3'b100:  seq_item_expected.HRDATA = HRDATA_expectedd;
      3'b101:  seq_item_expected.HRDATA = HRDATA_expected5;
      3'b110:  seq_item_expected.HRDATA = HRDATA_expected6;
      default: begin 
        seq_item_expected.HRDATA = 'hx;
        //$display("I AM HERE NOW HSEL: %0d", HSEL);
      end 
    endcase
    //seq_item_expected.HRDATA      = HRDATA_expected;
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
      send_results();
    endtask : data_phase


    // Task: Reset AHB pointers and flags
    task reset_AHB();
      HRESP_expected   = OKAY;
      HREADY_expected  = READY;
      HRDATA_expected1 = 0;
      HRDATA_expected2 = 0;
      HRDATA_expected3 = 0;
      HRDATA_expectedd = 0;
      HRDATA_expected5 = 0;
      HRDATA_expected6 = 0;
      HTRANS           = IDLE;
      wrap_counter     = 0;
      burst_counter    = 0;
    endtask : reset_AHB

    // Task: Write data into the AHB and handle pointer updates
  task write_AHB();
    if(undo_on) `uvm_info("PREDICTOR", "RE_WRITE_TASK ON", UVM_HIGH)
    // HRESP_expected = OKAY;
    // HREADY_expected = READY;
    // if( HPROT[3:2] == 2'b00 &&    ((HSEL == 5 && HWRITE == 0 && HPROT[3:1] == 3'b001) || (HSEL == 6 && HPROT[3:1] == 3'b001))) begin
    if(HPROT[3:2] == 2'b00 && ((HSEL == 1 || HSEL == 2 || HSEL == 3) || (HSEL == 5 && ((HWRITE && HPROT[1] == 1) || ~HWRITE)) || (HSEL == 6 && HPROT[1] == 1))) begin
      case(HTRANS)
        IDLE, BUSY: begin
          //if(undo_on) $display("HTRANS : %0d", HTRANS);
          if (HBURST == SINGLE && HRESP_expected == ERROR && seq_item_old.HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] != 4) begin
              HRESP_expected = ERROR; HREADY_expected = READY;
          end
          // if(~( (int'(HADDR_VALID + wrap_counter +1) >= 0) & ((HADDR_VALID + burst_counter -1) < ADDR_DEPTH) & (int'(HADDR_VALID + wrap_counter -1) < ADDR_DEPTH))) begin
          //   HRESP_expected = ERROR; HREADY_expected = READY;
          //   $display("HADDR+WRAP:%0d",(int'(HADDR_VALID+wrap_counter)), HADDR_VALID, wrap_counter);
          //   `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why either counter is incrementing above address width in IDLE TRANSFER");
          // end
          else begin
            HRESP_expected = OKAY; HREADY_expected = READY;
          end
            wrap_counter  = 0;
            burst_counter = 0;
          // else begin
          //   `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why HBURST is not SINGLE during IDLE TRANSFER")
          //   if(~( (int'(HADDR_VALID + wrap_counter +1) >= 0) & ((HADDR_VALID + burst_counter -1) < ADDR_DEPTH) & (int'(HADDR_VALID + wrap_counter -1) < ADDR_DEPTH))) begin
          //     HRESP_expected = ERROR; HREADY_expected = READY;
          //     `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why either counter is incrementing above address width when HBURST is NOT SINGLE during IDLE TRANSFER");
          //   end
          //   HRESP_expected = ERROR; HREADY_expected = READY;       
          // end
        end

        NONSEQ:  begin
          case(HBURST)
            INCR, INCR4, INCR8, INCR16: begin
              if(~undo_on) begin
                write_process(burst_counter);
                if(HADDR_VALID + burst_counter < ADDR_DEPTH) begin
                  burst_counter = burst_counter +1;
                end
                else begin
                  $display("Crowdless crowdx1");
                  HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                end
              end
              else begin
                write_process(burst_counter);
              end
            end
            WRAP4, WRAP8, WRAP16: begin
              if(~undo_on) begin
                write_process(wrap_counter);
                if((int'(HADDR_VALID + wrap_counter) > 0) & (int'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) begin
                  wrap_counter = wrap_counter + 1;
                end
                else begin
                  `uvm_warning("PREDICTOR", "THE WRAP COUNTER BYPASSED ADDR_DEPTH")
                end
                if(wrap_counter == 2 && HBURST == WRAP4) begin
                  wrap_counter = (~wrap_counter) +1;
                end
                else if (wrap_counter == 4 && HBURST == WRAP8) begin
                  wrap_counter = (~wrap_counter) +1 ;
                end
                else if (wrap_counter == 8 && HBURST == WRAP16) begin                
                  wrap_counter = (~wrap_counter) +1 ;
                end
              end
              else begin
                write_process(wrap_counter);
              end
            end

            default: begin
              write_process(0);
            end

          endcase // HBURST
        end
        SEQ: begin
          if(seq_item_old.HTRANS == NONSEQ || seq_item_old.HTRANS == SEQ) begin
            case(HBURST)
              INCR, INCR4, INCR8, INCR16: begin
                if(~undo_on) begin
                  write_process(burst_counter);
                  if(HADDR_VALID + burst_counter < ADDR_DEPTH) begin
                    burst_counter = burst_counter +1;
                  end
                  else begin
                    HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                  end
                end
                else begin
                  write_process(burst_counter);
                end
              end
              WRAP4, WRAP8, WRAP16: begin
                if(~undo_on) begin
                  write_process(wrap_counter);
                  if((int'(HADDR_VALID + wrap_counter) > 0) & (int'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) begin
                    wrap_counter = wrap_counter + 1;
                  end
                  else begin
                    HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                    `uvm_warning("PREDICTOR", "THE WRAP COUNTER BYPASSED ADDR_DEPTH")
                  end
                  if(wrap_counter == 2 && HBURST == WRAP4) begin
                    wrap_counter = (~wrap_counter) +1;
                  end
                  else if (wrap_counter == 4 && HBURST == WRAP8) begin
                    wrap_counter = (~wrap_counter) +1 ;
                  end
                  else if (wrap_counter == 8 && HBURST == WRAP16) begin                
                    wrap_counter = (~wrap_counter) +1 ;
                  end
                end
                else begin
                  write_process(wrap_counter);
                end
              end

              default: begin
                write_process(0);
              end

            endcase // HBURST
          end
          else begin
            $display("Crowdless crowdx2");
            HRESP_expected  = ERROR;
            HREADY_expected = NOT_READY;
          end
        end
      endcase // HTRANS
    end
    else if(HSEL == 4) begin
      HRESP_expected = ERROR; HREADY_expected = READY;
    end
    else begin
      $display("Crowdless crowd");
      HRESP_expected  = ERROR; HREADY_expected = NOT_READY;
    end

  endtask : write_AHB

  task write_process(input int counter);
    // int array_indexing;
    // case (HSIZE)
    //   BYTE_P:     array_indexing = BYTE_WIDTH;
    //   HALFWORD_P: array_indexing = HALFWORD_WIDTH;
    //   WORD_P:     array_indexing = WORD_WIDTH;
    //   WORD2_P:    array_indexing = WORD2_WIDTH;
    //   WORD4_P:    array_indexing = WORD4_WIDTH;
    //   WORD8_P:    array_indexing = WORD8_WIDTH;
    //   WORD16_P:   array_indexing = WORD16_WIDTH;
    //   WORD32_P:   array_indexing = WORD32_WIDTH;
    //   default:    $display("array_indexing error");
    // endcase

    // if(undo_on) `uvm_info("PREDICTOR", "RE_WRITE_PROCESS ON", UVM_HIGH)
    // if((int'(HADDR_VALID + counter) < ADDR_DEPTH) & (int'(HADDR_VALID + counter) >= 0)) begin
    //   undo_counter_old = 'hx;
    //   undo_HWDATA_older = 'hx;
    //   case (HSEL)
    //     1: begin
    //       if(~undo_on) begin 
    //         undo_counter_old <= counter; undo_HWDATA_old[array_indexing-1:0] <= subordinate1[HADDR_VALID + counter];
    //       end
    //       subordinate1[HADDR_VALID + counter] [array_indexing-1:0] = HWDATA[array_indexing-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
    //       `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[array_indexing-1:0], (HADDR + counter))}, UVM_LOW)
    //     end
    //     2: begin
    //       if(~undo_on) begin 
    //         undo_counter_old <= counter; undo_HWDATA_old[array_indexing-1:0] <= subordinate2[HADDR_VALID + counter];
    //       end
    //       subordinate2[HADDR_VALID + counter] [array_indexing-1:0] = HWDATA[array_indexing-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
    //       `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[array_indexing-1:0], (HADDR + counter))}, UVM_LOW)
    //     end
    //     3: begin
    //       if(~undo_on) begin 
    //         undo_counter_old <= counter; undo_HWDATA_old[array_indexing-1:0] <= subordinate3[HADDR_VALID + counter];
    //       end
    //       subordinate3[HADDR_VALID + counter] [array_indexing-1:0] = HWDATA[array_indexing-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
    //       `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[array_indexing-1:0], (HADDR + counter))}, UVM_LOW)
    //     end
    //     5: begin
    //       if(~undo_on) begin 
    //         undo_counter_old <= counter; undo_HWDATA_old[array_indexing-1:0] <= subordinate5[HADDR_VALID + counter];
    //       end
    //       subordinate5[HADDR_VALID + counter] [array_indexing-1:0] = HWDATA[array_indexing-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
    //       `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[array_indexing-1:0], (HADDR + counter))}, UVM_LOW)
    //     end
    //     6: begin
    //       if(~undo_on) begin 
    //         undo_counter_old <= counter; undo_HWDATA_old[array_indexing-1:0] <= subordinate6[HADDR_VALID + counter];
    //       end
    //       subordinate6[HADDR_VALID + counter] [array_indexing-1:0] = HWDATA[array_indexing-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
    //       `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[array_indexing-1:0], (HADDR + counter))}, UVM_LOW)
    //     end
    //     default : begin
    //       $display("NOT_READY x3");
    //       HRESP_expected  = ERROR;
    //       HREADY_expected = NOT_READY; 
    //     end
    //   endcase
    // end
    // else begin
    //   $display("NOT_READY x4");
    //   $display("HADDR_VALID : %0d, counter: %0d, HADDR_VALID+counter:%0d", HADDR_VALID, counter, (int'(counter+HADDR_VALID)));
    // //   HRESP_expected  = ERROR;
    // //   HREADY_expected = NOT_READY;          
    // end

      if(undo_on) `uvm_info("PREDICTOR", "RE_WRITE_PROCESS ON", UVM_HIGH)
      if((int'(HADDR_VALID + counter) < ADDR_DEPTH) & (int'(HADDR_VALID + counter) >= 0)) begin
        undo_counter_old = 'hx;
        undo_HWDATA_older = 'hx;
        case (HSIZE)
        `ifdef HWDATA_WIDTH32
          BYTE_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[BYTE_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] [BYTE_WIDTH-1:0] = HWDATA[BYTE_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[BYTE_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] [BYTE_WIDTH-1:0] = HWDATA[BYTE_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)

              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[BYTE_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] [BYTE_WIDTH-1:0] = HWDATA[BYTE_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end

              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[BYTE_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] [BYTE_WIDTH-1:0] = HWDATA[BYTE_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end

              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[BYTE_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] [BYTE_WIDTH-1:0] = HWDATA[BYTE_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[BYTE_WIDTH-1:0], (HADDR + counter))}, UVM_LOW)
              end

              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end


          HALFWORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[HALFWORD_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] [HALFWORD_WIDTH-1:0] = HWDATA[HALFWORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[HALFWORD_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter] /*[HALFWORD_WIDTH-1]*/;
                end
                subordinate2[HADDR_VALID + counter] [HALFWORD_WIDTH-1:0] = HWDATA[HALFWORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[HALFWORD_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] [HALFWORD_WIDTH-1:0] = HWDATA[HALFWORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[HALFWORD_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] [HALFWORD_WIDTH-1:0] = HWDATA[HALFWORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[HALFWORD_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] [HALFWORD_WIDTH-1:0] = HWDATA[HALFWORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[HALFWORD_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          WORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] [WORD_WIDTH-1:0] = HWDATA[WORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] [WORD_WIDTH-1:0] = HWDATA[WORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] [WORD_WIDTH-1:0] = HWDATA[WORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] [WORD_WIDTH-1:0] = HWDATA[WORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] [WORD_WIDTH-1:0] = HWDATA[WORD_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD_WIDTH-1:0])}, UVM_LOW)
              end                              
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

        `endif

        `ifdef HWDATA_WIDTH64
          WORD2_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD2_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] [WORD2_WIDTH-1:0] = HWDATA[WORD2_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD2_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD2_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] [WORD2_WIDTH-1:0] = HWDATA[WORD2_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD2_WIDTH-1:0])}, UVM_LOW)
              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD2_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] [WORD2_WIDTH-1:0] = HWDATA[WORD2_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD2_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD2_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] [WORD2_WIDTH-1:0] = HWDATA[WORD2_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD2_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD2_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] [WORD2_WIDTH-1:0] = HWDATA[WORD2_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD2_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH128
          WORD4_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD4_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] = HWDATA[WORD4_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD4_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD4_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] = HWDATA[WORD4_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD4_WIDTH-1:0])}, UVM_LOW)
              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD4_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] = HWDATA[WORD4_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD4_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD4_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] = HWDATA[WORD4_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD4_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD4_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] = HWDATA[WORD4_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD4_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH256
          WORD8_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD8_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] = HWDATA[WORD8_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD8_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD8_WIDTH-1:0] <<= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] = HWDATA[WORD8_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD8_WIDTH-1:0])}, UVM_LOW)

              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD8_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] = HWDATA[WORD8_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD8_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD8_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] = HWDATA[WORD8_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD8_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD8_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] = HWDATA[WORD8_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD8_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH512
          WORD16_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD16_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] = HWDATA[WORD16_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD16_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD16_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] = HWDATA[WORD16_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD16_WIDTH-1:0])}, UVM_LOW)
              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD16_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] = HWDATA[WORD16_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD16_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD16_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] = HWDATA[WORD16_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD16_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD16_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] = HWDATA[WORD16_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD16_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH1024
          WORD32_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD32_WIDTH-1:0] <= subordinate1[HADDR_VALID + counter];
                end
                subordinate1[HADDR_VALID + counter] = HWDATA[WORD32_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY; 
                `uvm_info("PREDICTOR", {"WRITE_subordinate1:", $sformatf("%0h, %0h", subordinate1[HADDR_VALID+counter], HWDATA[WORD32_WIDTH-1:0])}, UVM_LOW)
              end
              3'b010: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD32_WIDTH-1:0] <= subordinate2[HADDR_VALID + counter];
                end
                subordinate2[HADDR_VALID + counter] = HWDATA[WORD32_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY; 
                `uvm_info("PREDICTOR", {"WRITE_subordinate2:", $sformatf("%0h, %0h", subordinate2[HADDR_VALID+counter], HWDATA[WORD32_WIDTH-1:0])}, UVM_LOW)

              end
              3'b011: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD32_WIDTH-1:0] <= subordinate3[HADDR_VALID + counter];
                end
                subordinate3[HADDR_VALID + counter] = HWDATA[WORD32_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate3:", $sformatf("%0h, %0h", subordinate3[HADDR_VALID+counter], HWDATA[WORD32_WIDTH-1:0])}, UVM_LOW)
              end
              5: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD32_WIDTH-1:0] <= subordinate5[HADDR_VALID + counter];
                end
                subordinate5[HADDR_VALID + counter] = HWDATA[WORD32_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate5:", $sformatf("%0h, %0h", subordinate5[HADDR_VALID+counter], HWDATA[WORD32_WIDTH-1:0])}, UVM_LOW)
              end
              6: begin
                if(~undo_on) begin 
                  undo_counter_old <= counter; undo_HWDATA_old[WORD32_WIDTH-1:0] <= subordinate6[HADDR_VALID + counter];
                end
                subordinate6[HADDR_VALID + counter] = HWDATA[WORD32_WIDTH-1:0]; HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"WRITE_subordinate6:", $sformatf("%0h, %0h", subordinate6[HADDR_VALID+counter], HWDATA[WORD32_WIDTH-1:0])}, UVM_LOW)
              end
              default: begin
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

          default : begin
            $display("NOT_READY x4");
            HRESP_expected  = ERROR;
            HREADY_expected = NOT_READY; 
          end

        endcase

      end
      else begin
        $display("NOT_READY x3");
        $display("HADDR_VALID : %0d, counter: %0d, HADDR_VALID+counter:%0d", HADDR_VALID, counter, (int'(counter+HADDR_VALID)));
        HRESP_expected  = ERROR;
        HREADY_expected = NOT_READY;
      end
    endtask : write_process

  // Task: Read data from the AHB peripheral
  task read_AHB();
    // HRESP_expected = OKAY;
    // HREADY_expected = READY;
    if(HPROT[3:2] == 2'b00 && ((HSEL == 1 || HSEL == 2 || HSEL == 3) || (HSEL == 5 && ((HWRITE && HPROT[1] == 1) || ~HWRITE)) || (HSEL == 6 && HPROT[1] == 1))) begin
      case(HTRANS)

        IDLE, BUSY: begin
          if(HRESP_expected == ERROR && HBURST == SINGLE && seq_item_old.HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] != 4) begin
              $display("weleeeeeeeeeeeeh");
              HRESP_expected = ERROR; HREADY_expected = READY;
          end          
          // if(~( (int'(HADDR_VALID + wrap_counter +1 ) >= 0 ) & ((HADDR_VALID + burst_counter - 1) < ADDR_DEPTH) & (int'(wrap_counter+(HADDR_VALID - 1)) < ADDR_DEPTH))) begin
          //   $display("HADDR+WRAP:%0d, HADDR:%0d, wrap_counter:%0d",(int'(HADDR_VALID+wrap_counter)), HADDR_VALID, wrap_counter);
          //   HRESP_expected = ERROR; HREADY_expected = READY;
          //   `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why either counter is incrementing above address width in IDLE TRANSFER");
          // end
          else begin
            HRESP_expected = OKAY; HREADY_expected = READY;
          end
          $display("RESETING THE COUNTERS");
            wrap_counter = 0;
            burst_counter = 0;
          // else begin
          //   HRESP_expected = ERROR; HREADY_expected = READY;
          //   `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why HBURST is not SINGLE during IDLE TRANSFER")
          //   if(~( (int'(HADDR_VALID + wrap_counter +1 ) >= 0) & ((HADDR_VALID + burst_counter - 1) < ADDR_DEPTH) & (int'(HADDR_VALID + wrap_counter - 1) < ADDR_DEPTH))) begin //might be obsolete
          //     HRESP_expected = OKAY; HREADY_expected = READY;
          //     `uvm_warning("PREDICTOR", "This shouldnt be hit, please check why either counter is incrementing above address width when HBURST is NOT SINGLE during IDLE TRANSFER");
          //   end       
          // end
          // HRDATA_expected1 = HRDATA_expected1;
          // HRDATA_expected2 = HRDATA_expected2;
          // HRDATA_expected3 = HRDATA_expected3;
          // HRDATA_expectedd = HRDATA_expectedd;
        end

        NONSEQ: begin
          case(HBURST)

            INCR, INCR4, INCR8, INCR16: begin
              read_process(burst_counter);
              if(HADDR_VALID + burst_counter < ADDR_DEPTH) begin 
                burst_counter = burst_counter +1;
              end
              else begin
                HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                $display("HELLO counter %0d, %0t",burst_counter, $time());
              end
            end

            WRAP4, WRAP8, WRAP16: begin
              if(~undo_on) begin
                read_process(wrap_counter);
                if((int'(HADDR_VALID + wrap_counter) > 0) & (int'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) begin
                  wrap_counter = wrap_counter + 1;
                end
                else begin
                  HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                  `uvm_warning("PREDICTOR", "THE WRAP COUNTER BYPASSED ADDR_DEPTH")
                end
                if(wrap_counter == 2 && HBURST == WRAP4) begin
                  wrap_counter = (~wrap_counter) +1;
                end
                else if (wrap_counter == 4 && HBURST == WRAP8) begin
                  wrap_counter = (~wrap_counter) +1;
                end
                else if (wrap_counter == 8 && HBURST == WRAP16) begin                
                  wrap_counter = (~wrap_counter) +1;
                end
              end
              else begin
                read_process(wrap_counter);
              end
            end

            default: begin
              read_process(0);
            end

          endcase // HBURST
        end
        SEQ: begin
          if(seq_item_old.HTRANS == NONSEQ || seq_item_old.HTRANS == SEQ) begin
            case(HBURST)

              INCR, INCR4, INCR8, INCR16: begin
                read_process(burst_counter);
                if(HADDR_VALID + burst_counter < ADDR_DEPTH) begin
                  burst_counter = burst_counter +1;
                end
                else begin
                    HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                end
              end

              WRAP4, WRAP8, WRAP16: begin
                if(~undo_on) begin
                  read_process(wrap_counter);
                  if((int'(HADDR_VALID + wrap_counter) > 0) & (int'(HADDR_VALID + wrap_counter) < ADDR_DEPTH)) begin
                    wrap_counter = wrap_counter + 1;
                  end
                  else begin
                    `uvm_warning("PREDICTOR", "THE WRAP COUNTER BYPASSED ADDR_DEPTH") 
                     HRESP_expected = ERROR; HREADY_expected = NOT_READY;
                  end
                  if(wrap_counter == 2 && HBURST == WRAP4) begin
                    wrap_counter = (~wrap_counter) +1;
                  end
                  else if (wrap_counter == 4 && HBURST == WRAP8) begin
                    wrap_counter = (~wrap_counter) +1;
                  end
                  else if (wrap_counter == 8 && HBURST == WRAP16) begin                
                    wrap_counter = (~wrap_counter) +1;
                  end
                end
                else begin
                  read_process(wrap_counter);
                end
              end

              default: begin
                read_process(0);
              end

            endcase // HBURST
          end
          else begin
            case (HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: HRDATA_expected1 = HRDATA_expected1;
              3'b010: HRDATA_expected2 = HRDATA_expected2;
              3'b011: HRDATA_expected3 = HRDATA_expected3;
              5:      HRDATA_expected5 = HRDATA_expected5;
              6:      HRDATA_expected6 = HRDATA_expected6;
              3'b100: HRDATA_expectedd = HRDATA_expectedd;
            endcase
            HREADY_expected  = NOT_READY;
            HRESP_expected   = ERROR;
          end
        end
      endcase // HTRANS
    end
    else if(HSEL == 4) begin
      $display("atlasicoooo");
      HRESP_expected = ERROR; HREADY_expected = READY; HRDATA_expectedd = 0;
    end
    else begin
      HRESP_expected   = ERROR;
      HREADY_expected  = NOT_READY;
    end
  endtask : read_AHB


    task read_process(input int counter);
      if((int'(HADDR_VALID + counter) < ADDR_DEPTH) & (int'(HADDR_VALID + counter) >= 0)) begin
        case (HSIZE)

        `ifdef HWDATA_WIDTH32
          BYTE_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[BYTE_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h  %0h", subordinate1[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[BYTE_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h  %0h", subordinate2[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[BYTE_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h  %0h", subordinate3[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[BYTE_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h  %0h", subordinate5[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[BYTE_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h  %0h", subordinate6[HADDR_VALID+counter], (HADDR_VALID+counter))}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[BYTE_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          HALFWORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[HALFWORD_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[HALFWORD_WIDTH-1:0] = subordinate2[HADDR_VALID+counter] /*[HALFWORD_WIDTH-1:0]*/;  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[HALFWORD_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[HALFWORD_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[HALFWORD_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[HALFWORD_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end

          WORD_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH64
          WORD2_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD2_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD2_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD2_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD2_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD2_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD2_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH128
          WORD4_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD4_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD4_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD4_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD4_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD4_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD4_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH256
          WORD8_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD8_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD8_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD8_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD8_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD8_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD8_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH512
          WORD16_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD16_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD16_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD16_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD16_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD16_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD16_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

        `ifdef HWDATA_WIDTH1024
          WORD32_P: begin
            case(HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: begin
                HRDATA_expected1[WORD32_WIDTH-1:0] = subordinate1[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate1:", $sformatf("%0h", subordinate1[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b010: begin
                HRDATA_expected2[WORD32_WIDTH-1:0] = subordinate2[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate2:", $sformatf("%0h", subordinate2[HADDR_VALID+counter])}, UVM_LOW)
              end
              3'b011: begin
                HRDATA_expected3[WORD32_WIDTH-1:0] = subordinate3[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate3:", $sformatf("%0h", subordinate3[HADDR_VALID+counter])}, UVM_LOW)
              end
              5: begin
                HRDATA_expected5[WORD32_WIDTH-1:0] = subordinate5[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate5:", $sformatf("%0h", subordinate5[HADDR_VALID+counter])}, UVM_LOW)
              end
              6: begin
                HRDATA_expected6[WORD32_WIDTH-1:0] = subordinate6[HADDR_VALID+counter];  HRESP_expected = OKAY; HREADY_expected = READY;
                `uvm_info("PREDICTOR", {"READ_subordinate6:", $sformatf("%0h", subordinate6[HADDR_VALID+counter])}, UVM_LOW)
              end
              default: begin
                HRDATA_expectedd[WORD32_WIDTH-1:0] = 0;
                HRESP_expected  = ERROR;
                HREADY_expected = NOT_READY;
              end
            endcase
          end
        `endif

          default : begin
            case (HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES])
              3'b001: HRDATA_expected1 = HRDATA_expected1;
              3'b010: HRDATA_expected2 = HRDATA_expected2;
              3'b011: HRDATA_expected3 = HRDATA_expected3;
              5:      HRDATA_expected5 = HRDATA_expected5;
              6:      HRDATA_expected6 = HRDATA_expected6;
              3'b100: HRDATA_expectedd = HRDATA_expectedd;
            endcase
            $display("NOT_READY x2");
            HRESP_expected  = ERROR;
            HREADY_expected = NOT_READY;
          end
        endcase
      end
    else begin
      $display("NOT_READY x1");
      $display("HADDR_VALID : %0d, counter: %0d, HADDR_VALID+counter:%0d", HADDR_VALID, counter, (int'(counter+HADDR_VALID)));
      HRESP_expected  = ERROR;
      HREADY_expected = NOT_READY;
    end
  endtask : read_process



    function void undo_last_operation();
      $display("TIME : %0t correcting the predictor mem", $time());
        $display("SSsubordinate1 MEM AFTER RESET: %p", subordinate1);
        $display("SSsubordinate2 MEM AFTER RESET: %p", subordinate2);
        $display("SSsubordinate3 MEM AFTER RESET: %p", subordinate3);
      if(seq_item_old.HWRITE == 1) begin
        `uvm_info("PREDICTOR: ", {"seq_item_old: ", seq_item_old.convert2string()}, UVM_LOW)
        undo_on = 1;
        HRESETn     = seq_item_old.HRESETn;
        HWRITE      = seq_item_old.HWRITE;
        HTRANS      = seq_item_old.HTRANS;
        HADDR       = seq_item_old.HADDR;
        HSIZE       = seq_item_old.HSIZE;
        HBURST      = seq_item_old.HBURST;
        HPROT       = seq_item_old.HPROT;
        HWDATA      = undo_HWDATA_old;
        HADDR_VALID = HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];//29:0
        HSEL        = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES];//31:30
        `uvm_info("PREDICTOR: ", {$sformatf("undo_counter_old %0d: ", undo_counter_old)}, UVM_LOW)
        `uvm_info("PREDICTOR: ", {$sformatf("undo_HWDATA_old %0h: ", undo_HWDATA_old)}, UVM_LOW)
        case(HBURST)
          WRAP4, WRAP8, WRAP16: begin
            wrap_counter = undo_counter_old;
          end
          INCR, INCR4, INCR8, INCR16: begin
            burst_counter = undo_counter_old;
          end
        endcase
        write_AHB();
        $display("HTRANS VALUE: %0d", HTRANS);
        undo_on = 0;

      end
      // if(seq_item_older.HWRITE == 1) begin
      // `uvm_info("PREDICTOR: ", {"seq_item_older: ", seq_item_older.convert2string()}, UVM_LOW) 
      // `uvm_info("PREDICTOR: ", {"seq_item_old: ", seq_item_old.convert2string()}, UVM_LOW) 
      // `uvm_info("PREDICTOR: ", {$sformatf("undo_HWDATA_older: %0h ", undo_HWDATA_older)}, UVM_LOW) 
      //   undo_on     = 1;
      //   HRESETn     = seq_item_older.HRESETn;
      //   HWRITE      = seq_item_older.HWRITE;
      //   HTRANS      = seq_item_older.HTRANS;
      //   HADDR       = seq_item_older.HADDR;
      //   HSIZE       = seq_item_older.HSIZE;
      //   HBURST      = seq_item_older.HBURST;
      //   HPROT       = seq_item_older.HPROT;
      //   HWDATA      = undo_HWDATA_older;
      //   HADDR_VALID = HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];//29:0
      //   HSEL        = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES];//31:30
      //   `uvm_info("PREDICTOR: ", {$sformatf("undo_counter_older %0d: ", undo_counter_older)}, UVM_LOW)
      //   case(HBURST)
      //     WRAP4, WRAP8, WRAP16: begin
      //       wrap_counter = undo_counter_older;
      //     end
      //     INCR, INCR4, INCR8, INCR16: begin
      //       burst_counter = undo_counter_older;
      //     end
      //   endcase
      //   write_AHB();
      //   undo_on     = 0;
      // $display("DDsubordinate1 MEM AFTER RESET: %p", subordinate1);
      // $display("DDsubordinate2 MEM AFTER RESET: %p", subordinate2);
      // $display("DDsubordinate3 MEM AFTER RESET: %p", subordinate3);
      // end
      // if(seq_item_oldest.HWRITE == 1) begin
      // `uvm_info("PREDICTOR: ", {"seq_item_oldest: ", seq_item_oldest.convert2string()}, UVM_LOW) 
      // `uvm_info("PREDICTOR: ", {"seq_item_old: ", seq_item_old.convert2string()}, UVM_LOW) 
      // `uvm_info("PREDICTOR: ", {$sformatf("undo_HWDATA_oldest: %0h ", undo_HWDATA_oldest)}, UVM_LOW) 
      //   undo_on     = 1;
      //   HRESETn     = seq_item_oldest.HRESETn;
      //   HWRITE      = seq_item_oldest.HWRITE;
      //   HTRANS      = seq_item_oldest.HTRANS;
      //   HADDR       = seq_item_oldest.HADDR;
      //   HSIZE       = seq_item_oldest.HSIZE;
      //   HBURST      = seq_item_oldest.HBURST;
      //   HPROT       = seq_item_oldest.HPROT;
      //   HWDATA      = undo_HWDATA_oldest;
      //   HADDR_VALID = HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0];//29:0
      //   HSEL        = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES];//31:30
      //   `uvm_info("PREDICTOR: ", {$sformatf("undo_counter_oldest %0d: ", undo_counter_oldest)}, UVM_LOW)
      //   case(HBURST)
      //     WRAP4, WRAP8, WRAP16: begin
      //       wrap_counter = undo_counter_oldest;
      //     end
      //     INCR, INCR4, INCR8, INCR16: begin
      //       burst_counter = undo_counter_oldest;
      //     end
      //   endcase
      //   write_AHB();
      //   undo_on     = 0;
      // $display("DDsubordinate1 MEM AFTER RESET: %p", subordinate1);
      // $display("DDsubordinate2 MEM AFTER RESET: %p", subordinate2);
      // $display("DDsubordinate3 MEM AFTER RESET: %p", subordinate3);
      // end

      $display("TIME : %0t AFTER correcting the predictor mem", $time());
      // undo_HWDATA_older = 'hx;
      // undo_HWDATA_old = 'hx;
      
    endfunction : undo_last_operation

    function void display_subordinates(bit [ADDR_WIDTH-1:0] HADDRx, bit [ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] HSEL );
      case (HSEL)
        1: $display("subordinate1 MEM AFTER FAIL: %0h",subordinate1[HADDRx]);
        2: $display("subordinate2 MEM AFTER FAIL: %0h",subordinate2[HADDRx]);
        3: $display("subordinate3 MEM AFTER FAIL: %0h",subordinate3[HADDRx]);
        //4: $display("subordinate4 MEM AFTER FAIL: %0h",subordinate4[HADDRx]);
        5: $display("subordinate5 MEM AFTER FAIL: %0h",subordinate5[HADDRx]);
        6: $display("subordinate6 MEM AFTER FAIL: %0h",subordinate6[HADDRx]);
      endcase
      $display("subordinate1 MEM AFTER FAIL: %p", subordinate1);
      $display("subordinate2 MEM AFTER FAIL: %p", subordinate2);
      $display("subordinate3 MEM AFTER FAIL: %p", subordinate3);
      $display("subordinate5 MEM AFTER FAIL: %p", subordinate5);
      $display("subordinate6 MEM AFTER FAIL: %p", subordinate6);
      $display("subordinate2 MEM AFTER fail: %p", subordinate2);
      $display("subordinate3 MEM AFTER fail: %p", subordinate3);
    endfunction 


endclass : predictor