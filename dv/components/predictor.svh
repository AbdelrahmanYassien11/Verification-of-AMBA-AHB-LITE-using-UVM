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
  bit   [DATA_WIDTH-1:0]  HWDATA; 

  // AHB lite output Signals
  logic   [DATA_WIDTH-1:0]  HRDATA_expected;
  logic   [RESP_WIDTH-1:0]  HRESP_expected; 
  logic   [DATA_WIDTH-1:0]  HREADY_expected;


  logic [DATA_WIDTH-1:0] slave0 [15:0];
  logic [DATA_WIDTH-1:0] slave1 [15:0];
  logic [DATA_WIDTH-1:0] slave2 [15:0];

  HRESET_e     RESET_op;
  HWRITE_e     WRITE_op;
  HTRANS_e     TRANS_op;
  HBURST_e     BURST_op;
  HSIZE_e      SIZE_op;  

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
    seq_item_expected = sequence_item::type_id::create("seq_item_expected");

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
      @(inputs_written);
      `uvm_info("PREDICTOR", {"WRITTEN_DATA: ", data_str}, UVM_HIGH)
      sequence_item::PREDICTOR_transaction_counter = sequence_item::PREDICTOR_transaction_counter + 1;
      generic_predictor();
      wait(expected_outputs_written.triggered);
      analysis_port_expected_outputs.write(seq_item_expected);
      `uvm_info("PREDICTOR", {"EXPECTED_DATA: ", seq_item_expected.input2string()}, UVM_HIGH)
    end
  endtask

  // Write method for processing sequence items
  function void write(sequence_item t);
    HRESETn = t.HRESETn;
    HWRITE  = t.HWRITE;
    HTRANS  = t.HTRANS;
    HSIZE   = t.HSIZE;
    HBURST  = t.HBURST;
    HPROT   = t.HPROT;
    HADDR   = t.HADDR;
    HWDATA  = t.HWDATA;

    RESET_op   = t.RESET_op;
    WRITE_op   = t.WRITE_op;
    TRANS_op   = t.TRANS_op;
    BURST_op   = t.BURST_op;          
    SIZE_op    = t.SIZE_op;


    //HREADY  <= t.HREADY;
     data_str   = $sformatf("HRESETn:%0d, HWRITE:%0d, HTRANS:%0d, HSIZE:%0d, HBURST:%0d, HPROT:%0d, HADDR:%0d, HWDATA:%0d",
                             HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA);
    -> inputs_written;
  endfunction

  // Task for processing AHB operations based on inputs
  task generic_predictor();
        //fork
            //control_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
            data_phase();
        //join_any

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


    // task control_phase( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
    //                     input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
    //                     input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR     
    //                     );
    //     //@(negedge clk);
    //     HRESETn <= iHRESETn;
    //     if(/*HREADY === 1'b1 &&*/ iHRESETn == 1'b1) begin
    //         HWRITE  <= iHWRITE;
    //         HTRANS  <= iHTRANS;
    //         HSIZE   <= iHSIZE;
    //         HBURST  <= iHBURST;
    //         HPROT   <= iHPROT;
    //         HADDR   <= iHADDR;
    //         -> control_phase_finished;
    //     end
    // endtask : control_phase

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
      HRESP_expected = OKAY;
      HREADY_expected = READY;
      HRDATA_expected = 0;
      HTRANS = IDLE;
    endtask : reset_AHB


    // Task: Write data into the AHB and handle pointer updates
  task write_AHB();
    HRESP_expected = OKAY;
    HREADY_expected = READY;
    case(HTRANS)
      IDLE, BUSY: begin
      end
      NONSEQ, SEQ:  begin
        if(HADDR[31:30] == 2'b00)
          slave0[HADDR] = HWDATA;
        else if(HADDR[31:30] == 2'b01)
          slave1[HADDR] = HWDATA;
        else if(HADDR[31:30] == 2'b10)
          slave2[HADDR] = HWDATA;
        else
          HRESP_expected = ERROR;
      end
    endcase // HTRANS
  endtask : write_AHB

    // Task: Read data from the AHB and handle pointer updates
  task read_AHB();
    HRESP_expected = OKAY;
    HREADY_expected = READY;
    case(HTRANS)
      IDLE, BUSY: begin
      end
      NONSEQ, SEQ: begin
        if(HADDR[31:30] == 2'b00)
          HRDATA_expected = slave0[HADDR];
        else if(HADDR[31:30] == 2'b01)
          HRDATA_expected = slave1[HADDR];
        else if(HADDR[31:30] == 2'b10)
          HRDATA_expected = slave2[HADDR];
        else
          HRESP_expected = ERROR;
      end
    endcase // HTRANS
  endtask : read_AHB

endclass : predictor
