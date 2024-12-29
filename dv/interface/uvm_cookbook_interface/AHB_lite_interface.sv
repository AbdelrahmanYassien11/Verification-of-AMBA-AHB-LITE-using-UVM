/******************************************************************
 * File: inf.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This interface provides control and monitoring 
 *              for a AHB (First-In-First-Out) memory module. 
 *              It includes tasks for AHB operations such as reading, 
 *              writing, and resetting. The interface also contains 
 *              assertions to validate the AHB's status signals (full 
 *              and empty) and functions for sending input and output 
 *              data to monitors.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/
`timescale 1ns/1ns

interface inf (input bit clk);

import AHB_pkg::*;                  // Import AHB package for AHB constants

// AHB lite Control Signals
logic   HRESETn;    // reset (active low)

bit   HWRITE;

bit   [TRANS_WIDTH:0]  HTRANS; 
bit   [SIZE_WIDTH:0]  HSIZE;
bit   [BURST_WIDTH:0]  HBURST;
bit   [PROT_WIDTH:0]  HPROT; 

bit   [ADDR_WIDTH-1:0]  HADDR;     
bit   [DATA_WIDTH-1:0]  HWDATA; 

// AHB lite output Signals
logic   [DATA_WIDTH-1:0]  HRDATA;
logic   [RESP_WIDTH:0]  HRESP; 
logic   [READY_WIDTH:0]  HREADY;  

logic   HRESETn_reg;    // reset (active low)

bit   HWRITE_reg;

bit   [TRANS_WIDTH:0]  HTRANS_reg; 
bit   [SIZE_WIDTH:0]  HSIZE_reg;
bit   [BURST_WIDTH:0]  HBURST_reg;
bit   [PROT_WIDTH:0]  HPROT_reg; 

bit   [ADDR_WIDTH-1:0]  HADDR_reg;     
bit   [DATA_WIDTH-1:0]  HWDATA_reg; 

// AHB lite output Signals
logic   [DATA_WIDTH-1:0]  HRDATA_reg;
logic   [RESP_WIDTH:0]  HRESP_reg; 
logic   [READY_WIDTH:0]  HREADY_reg; 

bit pipeline_lock1;
bit pipeline_lock2;
bit pipeline_lock3;
bit pipeline_lock4;

// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor

HRESET_e     RESET_op;
HWRITE_e     WRITE_op;
HRESP_e      RESP_op;
HTRANS_e     TRANS_op;
HBURST_e     BURST_op;
HSIZE_e      SIZE_op;

sequence_item previous_seq_item, seq_item;

sequence_item command_tr;
sequence_item data_tr;
sequence_item subordinate_sampling_tr;
sequence_item mux_sampling_tr;
sequence_item top_sampling_tr;

event do_data_phase;
event do_subordinate_sampling_phase;
event do_mux_sampling_phase;
event do_top_sampling_phase;

driver driver_h;

  modport SVA (input clk, HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY);

// Task: Handle generic receiving operations based on reset and enable signals
    task begin_transfer( sequence_item p_seq_item );  

        command_phase(p_seq_item);

        if(p_seq_item.HRESETn) begin
            $display("A SAILOR, A GREAT PRETENDER");
            pipeline_lock_get1();

            command_tr = p_seq_item;
            ->do_data_phase;
        end


        //$display("RECIEVING PHASE: ASSSINGING RANDOMIZED VALUES");
    endtask : begin_transfer

    task command_phase(sequence_item p_seq_item);
            HRESETn <= p_seq_item.HRESETn;
            HWRITE  <= p_seq_item.HWRITE;
            HTRANS  <= p_seq_item.HTRANS;
            HSIZE   <= p_seq_item.HSIZE;
            HBURST  <= p_seq_item.HBURST;
            HPROT   <= p_seq_item.HPROT;
            HADDR   <= p_seq_item.HADDR;

        //so the HWDATA is assigned in the command phase if the reset is asserted since there is no data_phase if that happens.
        if(~p_seq_item.HRESETn) begin
            HWDATA <= p_seq_item.HWDATA;
        end

        send_inputs(p_seq_item);

        @(posedge clk);

        if(~p_seq_item.HRESETn) begin
            wait_for_reset;
        end

        while(~HREADY) begin
            @(posedge clk);
        end
    endtask : command_phase

    always begin
        @do_data_phase;
        @(posedge clk);

        data_phase(command_tr);

        pipeline_lock_put1();
        pipeline_lock_get2();
    end

    task data_phase(sequence_item p_seq_item);
        while(~HREADY) begin
            @(posedge clk);
        end

        if(p_seq_item.HWRITE) begin
            HWDATA <= p_seq_item.HWDATA;
        end

        data_tr = p_seq_item;
        ->do_subordinate_sampling_phase;
    endtask : data_phase

    always begin
        @do_subordinate_sampling_phase;
        @(posedge clk);

        subordinate_sampling_phase(data_tr);

        pipeline_lock_put2();
        pipeline_lock_get3();
    end

    task subordinate_sampling_phase(sequence_item p_seq_item);
        while(~HREADY) begin
            @(posedge clk);
        end

        subordinate_sampling_tr = p_seq_item;

        ->do_mux_sampling_phase;

    endtask : subordinate_sampling_phase

    always begin
        @do_mux_sampling_phase;
        @(posedge clk);

        mux_sampling_phase(subordinate_sampling_tr);

        pipeline_lock_put3();
        pipeline_lock_get4();
    end

    task mux_sampling_phase(sequence_item p_seq_item);
        while(~HREADY) begin
            @(posedge clk);
        end

        mux_sampling_tr = p_seq_item;

        ->do_top_sampling_phase;
        
    endtask : mux_sampling_phase

    always begin
        @do_top_sampling_phase;
        @(posedge clk);

        top_sampling_phase(mux_sampling_tr);

        driver_h.send_tr_back(top_sampling_tr);

        pipeline_lock_put4();
    end

    task top_sampling_phase(sequence_item p_seq_item);
        while(~HREADY) begin
            @(posedge clk);
        end

        p_seq_item.HRESP = HRESP;
        p_seq_item.HRDATA = HRDATA;
        p_seq_item.HREADY = HREADY;

        send_outputs();

        //dont think this is valid, because HRDATA then would be = to x and sent to the sequencer? whats the point of that?
        // if(~p_seq_item.HWRITE) begin
        //     p_seq_item.HRDATA = HRDATA;
        // end

        top_sampling_tr = p_seq_item;
        
    endtask : top_sampling_phase


    task wait_for_reset();
        repeat(15) begin
            @(posedge clk);
        end
        send_outputs();
    endtask

    task pipeline_lock_get1();
      while (pipeline_lock1) begin
        @(posedge clk);
      end
      pipeline_lock1 = 1;
    endtask: pipeline_lock_get1

    function void pipeline_lock_put1();
      pipeline_lock1 = 0;
    endfunction: pipeline_lock_put1



    task pipeline_lock_get2();
      while (pipeline_lock2) begin
        @(posedge clk);
      end
      pipeline_lock2 = 1;
    endtask: pipeline_lock_get2

    function void pipeline_lock_put2();
      pipeline_lock2 = 0;
    endfunction: pipeline_lock_put2



    task pipeline_lock_get3();
      while (pipeline_lock3) begin
        @(posedge clk);
      end
      pipeline_lock3 = 1;
    endtask: pipeline_lock_get3

    function void pipeline_lock_put3();
      pipeline_lock3 = 0;
    endfunction: pipeline_lock_put3




    task pipeline_lock_get4();
      while (pipeline_lock4) begin
        @(posedge clk);
      end
      pipeline_lock4 = 1;
    endtask: pipeline_lock_get4

    function void pipeline_lock_put4();
      pipeline_lock4 = 0;
    endfunction: pipeline_lock_put4


    // Function to send inputs to the input monitor
    function void send_inputs( sequence_item input_seq_item);

        // previous_seq_item.HRESETn = iHRESETn;
        // previous_seq_item.HWRITE = iHWRITE;
        // previous_seq_item.HTRANS = iHTRANS;
        // previous_seq_item.HSIZE  = iHSIZE;
        // previous_seq_item.HBURST = iHBURST;
        // previous_seq_item.HPROT  = iHPROT;
        // previous_seq_item.HADDR  = iHADDR;
        // previous_seq_item.HWDATA = iHWDATA;

        // previous_seq_item.RESET_op = iRESET_op;
        // previous_seq_item.WRITE_op = iWRITE_op;
        // previous_seq_item.TRANS_op = iTRANS_op;
        // previous_seq_item.SIZE_op  = iSIZE_op;
        // previous_seq_item.BURST_op = iBURST_op;

        inputs_monitor_h.write_to_monitor(input_seq_item.HRESETn, input_seq_item.HWRITE, input_seq_item.HTRANS, input_seq_item.HSIZE, input_seq_item.HBURST, input_seq_item.HPROT, input_seq_item.HADDR, input_seq_item.HWDATA, input_seq_item.RESET_op, input_seq_item.WRITE_op, input_seq_item.TRANS_op, input_seq_item.BURST_op, input_seq_item.SIZE_op);
    endfunction : send_inputs

    // Function to send outputs to the output monitor
    function void send_outputs();
        outputs_monitor_h.write_to_monitor(HRDATA, HRESP, HREADY);
    endfunction : send_outputs


    function void create_sequence_item();
        seq_item = sequence_item::type_id::create("seq_item");
        previous_seq_item = sequence_item::type_id::create("previous_seq_item");
    endfunction

    initial begin
        create_sequence_item();
        HRESETn <= 1'b1;
    end

    //assign HRESETn_global = (seq_item.HRESETn)? 1:0;

endinterface : inf