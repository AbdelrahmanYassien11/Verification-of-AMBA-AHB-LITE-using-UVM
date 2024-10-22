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

  logic [DATA_WIDTH-1:0] slave0 [P_SLAVE0_START:P_SLAVE0_END];
  logic [DATA_WIDTH-1:0] slave1 [P_SLAVE1_START:P_SLAVE1_END];
  logic [DATA_WIDTH-1:0] slave2 [P_SLAVE2_START:P_SLAVE2_END];

  // AHB lite Control Signals
  bit                   HRESETn;    // reset (active low)
  bit   HWRITE;

  bit   [TRANS_WIDTH:0]  HTRANS; 
  bit   [SIZE_WIDTH:0]  HSIZE;
  bit   [BURST_WIDTH:0]  HBURST;
  bit   [PROT_WIDTH:0]  HPROT; 

  bit   [ADDR_WIDTH-1:0]  HADDR;     
  bit   [DATA_WIDTH-1:0]  HWDATA; 

  // AHB lite output Signals
  logic   [DATA_WIDTH-1:0]  HRDATA_expected;
  logic   [RESP_WIDTH-1:0]  HRESP; 
  logic   [DATA_WIDTH-1:0]  HREADY;

  logic [FIFO_WIDTH-1:0] data_out_expected;
  bit [FIFO_WIDTH-1:0] data_write_queue [$];
  HRESP_e HRESP_o;

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
      generic_predictor();
      wait(expected_outputs_written.triggered);
      analysis_port_expected_outputs.write(seq_item_expected);
      `uvm_info("PREDICTOR", {"EXPECTED_DATA: ", seq_item_expected.convert2string()}, UVM_HIGH)
    end
  endtask

  // Write method for processing sequence items
  function void write(sequence_item t);
    HWRITE  <= t.HWRITE;
    HTRANS  <= t.HTRANS;
    HSIZE   <= t.HSIZE;
    HBURST  <= t.HBURST;
    HPROT   <= t.HPROT;
    HADDR   <= t.HADDR;

    HRESP <= t.HRESP;
    HREADY  <= t.HREADY;
    data_str   = $sformatf("HRESETn:%0d, HWRITE:%0d, HTRANS:%0d, HSIZE:%0d, HBURST:%0d, HPROT:%0d, HADDR:%0d, HWDATA:%0d",
                            HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA));
    -> inputs_written;
  endfunction

  // Task for processing AHB operations based on inputs
  task generic_predictor( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                        input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                        input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                        input bit  [DATA_WIDTH-1:0] iHWDATA);
        //fork
            //control_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
            data_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
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

    seq_item_expected.HRESP       = HRESP;
    seq_item_expected.HREADY      = HREADY;
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
        //@(control_phase_finished);
        //@(negedge clk);
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
        repeat(15)
            @(negedge clk);
        HRESP = OKAY;
        HREADY = READY;
        HTRANS = IDLE;
    endtask : reset_AHB


    // Task: Write data into the AHB and handle pointer updates
  task write_AHB();
    logic [ADDR_WIDTH-1:0] HADDR_WRAP;
    case (HBURST)
      INCR4: begin
        repeat(3) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
        end
      end
      INCR8: begin
        repeat(8) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
      end
      INCR16: begin
        repeat(16) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
        end
      WRAP4: begin
        repeat(4) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
      end
      WRAP8: begin
        repeat(8) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
      end
      WRAP16: begin
        repeat(16) begin
          if(HADDR >= 0 && HADDR <= 15)
            slave0[HADDR] = HWDATA;
          else if(HADDR >= 16 && HADDR <= 31)
            slave1[HADDR] = HWDATA;
          else if(HADDR >= 32 && HADDR <= 47)
            slave2[HADDR] = HWDATA;
          else
            HRESP = ERROR;
          HADDR = HADDR + HSIZE;
      end
      default : /* default */;
    endcase
    if(HADDR >= 0 && HADDR <= 15)
      slave0[HADDR] = HWDATA;
    else if(HADDR >= 16 && HADDR <= 31)
      slave1[HADDR] = HWDATA;
    else if(HADDR >= 32 && HADDR <= 47)
      slave2[HADDR] = HWDATA;
    else
      HRESP = ERROR;
      //@(negedge clk);
    endtask : write_AHB

    // Task: Read data from the AHB and handle pointer updates
    task read_AHB();
      if(HADDR >= 0 && HADDR <= 15)
        HRDATA = slave0[HADDR];
      else if(HADDR >= 16 && HADDR <= 31)
        HRDATA = slave1[HADDR];
      else if(HADDR >= 32 && HADDR <= 47)
        HRDATA = slave2[HADDR];
      else
        HRESP = ERROR;
          //@(negedge clk);
    endtask : read_AHB











  // Reset FIFO state
  task reset_FIFO();
    empty_expected = 1;
    full_expected  = 0;
    fork
      read_reset();
      write_reset();
    join
    just_reset = 1;
    data_write_queue.delete();
  endtask : reset_FIFO

  // Reset read pointer
  task read_reset();
    read_pointer = 0;
  endtask : read_reset

  // Reset write pointer
  task write_reset();
    write_pointer = 0;
  endtask : write_reset

  // Task to handle FIFO read and write operations
  task write_read_FIFO();
    if((w_en === 1'b1) && (r_en === 1'b1)) begin
      fork
        read_FIFO();
        write_FIFO();
      join
      FLAGS();
    end
    else if ((w_en === 1'b1) && (r_en === 1'b0)) begin
      write_FIFO();
      FLAGS();
    end
    else if ((w_en === 1'b0) && (r_en === 1'b1)) begin
      read_FIFO();
      FLAGS();
    end
  endtask : write_read_FIFO

  // Write data to FIFO
  task write_FIFO();
    if(full_expected === 0) begin
      data_write_queue.push_back(data_in);
      if(write_pointer === FIFO_SIZE-1) begin
        write_pointer = 0;
        wrap_around = 1;
      end
      else begin
        write_pointer = write_pointer + 1;
      end
    end
    FLAGS();
  endtask : write_FIFO

  // Read data from FIFO
  task read_FIFO();
    #1step;
    if(just_reset && !empty_expected) begin
      just_reset = 0;
      if(read_pointer === FIFO_SIZE-1) begin
        read_pointer = 0;
        wrap_around = 0;
      end
      else begin
        read_pointer = read_pointer + 1;
      end
      FLAGS();
      data_out_expected = data_write_queue.pop_front();
    end
    if(empty_expected === 0) begin
      data_out_expected = data_write_queue.pop_front();
      $display("QUEUE = %p", data_write_queue);
      data_out_old = data_out_expected;
      if(read_pointer === FIFO_SIZE-1) begin
        read_pointer = 0;
        wrap_around = 0;
      end
      else begin
        read_pointer = read_pointer + 1;
      end
    end
    else begin
      just_reset = 1;
    end
    FLAGS();
    $display("WRITE_POINTER = %0d", write_pointer);
    $display("READ_POINTER = %0d", read_pointer);
  endtask : read_FIFO

  // Update FIFO status flags
  task FLAGS();
    if(read_pointer === write_pointer) begin
      if((wrap_around && (read_pointer === write_pointer))) begin
        full_expected = 1;
        empty_expected = 0;
      end
      else begin
        full_expected = 0;
        empty_expected = 1;
      end
    end
    else begin
      full_expected = 0;
      empty_expected = 0;
    end
  endtask : FLAGS

endclass : predictor
