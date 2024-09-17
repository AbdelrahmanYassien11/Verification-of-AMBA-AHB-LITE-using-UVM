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

interface inf (input bit clk);

import AHB_pkg::*;                  // Import AHB package for AHB constants

// AHB lite Control Signals
bit   HRESETn;    // reset (active low)

bit   HWRITE;

bit   [TRANS_WIDTH:0]  HTRANS; 
bit   [SIZE_WIDTH:0]  HSIZE;
bit   [BURST_WIDTH:0]  HBURST;
bit   [PROT_WIDTH:0]  HPROT; 

bit   [ADDR_WIDTH-1:0]  HADDR;     
bit   [DATA_WIDTH-1:0]  HWDATA; 

// AHB lite output Signals
logic   [DATA_WIDTH-1:0]  HRDATA;
logic   [RESP_WIDTH-1:0]  HRESP; 
logic   [DATA_WIDTH-1:0]  HREADY;   


event control_phase_finished;
event interconnect_is_resetting;

// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor

HRESET_e     RESET_op;
HWRITE_e     WRITE_op;
HRESP_e      RESP_op;
HTRANS_e     TRANS_op;
HBURST_e     BURST_op;
HSIZE_e      SIZE_op;



sequence_item previous_seq_item;

// Task: Handle generic receiving operations based on reset and enable signals
task generic_reciever( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                        input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                        input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                        input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
                        input HRESET_e iWRITE_op, input HRESET_e iTRANS_op,
                        input HRESET_e iBURST_op, input HRESET_e iSIZE_op
);
    @(negedge clk);//like an always block @negedge,
    if(HRESP === RETRY) begin
        iHRESETn    = previous_seq_item.HRESETn;
        iHWRITE     = previous_seq_item.HWRITE;
        iHTRANS     = previous_seq_item.HTRANS;
        iHSIZE      = previous_seq_item.HSIZE;  
        iHBURST     = previous_seq_item.HBURST; 
        iHPROT      = previous_seq_item.HPROT;  
        iHADDR      = previous_seq_item.HADDR; 
        iHWDATA     = previous_seq_item.HWDATA;

        iRESET_op = previous_seq_item.RESET_op;
        iWRITE_op = previous_seq_item.WRITE_op;
        iTRANS_op = previous_seq_item.TRANS_op;
        iBURST_op = previous_seq_item.BURST_op;
        iSIZE_op  = previous_seq_item.SIZE_op;
    end
    if(HREADY === 1'b1  || iHRESETn === 1'b0) begin
        
        RESET_op = iRESET_op;
        WRITE_op = iWRITE_op;
        TRANS_op = iTRANS_op;
        BURST_op = iBURST_op;
        SIZE_op  = iSIZE_op;

        send_inputs(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, HRESP, HREADY, iHRESP_o);
        fork
            control_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
            data_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
        join_none
    end
    endtask : generic_reciever



    // always(@negedge clk) begin
    //     if(HREADY === 1'b1 || iHRESETn === 1'b0) begin



    task control_phase( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                        input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                        input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR     
                        );
        //@(negedge clk); //added it in the generic_reciever, not here cause I dont want the inputs to both function calls to somehow be overwritten (being cautious)
        HRESETn <= iHRESETn;
        // if(HREADY === 1'b1) begin
            HWRITE  <= iHWRITE;
            HTRANS  <= iHTRANS;
            HSIZE   <= iHSIZE;
            HBURST  <= iHBURST;
            HPROT   <= iHPROT;
            HADDR   <= iHADDR;
            -> control_phase_finished;
        //end
    endtask : control_phase

    task data_phase(input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                    input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                    input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR  
                        );
        @(control_phase_finished);
        @(negedge clk);
        if(iHRESETn === 1'b0)
            reset_AHB();
        else if(HWRITE === 1'b1) begin
            write_AHB(iHWDATA);
        end
        else if(HWRITE === 1'b0) begin
            read_AHB();
        end
        send_outputs(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
    endtask : data_phase


    // Task: Reset AHB pointers and flags
    task reset_AHB();
        repeat(15)
            @(negedge clk);
        //HRESETn <= 1'b1
    endtask : reset_AHB


    // Task: Write data into the AHB and handle pointer updates
    task write_AHB(input bit [ADDR_WIDTH-1:0] iHWDATA);
        case(HTRANS)
            IDLE, BUSY: begin
            end

            NONSEQ, SEQ: begin
                HWDATA = iHWDATA;
            end
        endcase // HTRANS
    endtask : write_AHB

    // Task: Read data from the AHB and handle pointer updates
    task read_AHB();
        case(HTRANS)
            IDLE, BUSY: begin

            end
            NONSEQ, SEQ: begin
                wait(HREADY === 1'b1);
            end
        endcase // HTRANS
    endtask : read_AHB



    // Function to send inputs to the input monitor
    function void send_inputs( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                               input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                               input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                               input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
                               input HRESET_e iWRITE_op, input HRESET_e iTRANS_op,
                               input HRESET_e iBURST_op, input HSIZE_e iSIZE_op);

        previous_seq_item.HRESETn = iHRESETn;
        previous_seq_item.HWRITE = iHWRITE;
        previous_seq_item.HTRANS = iHTRANS;
        previous_seq_item.HSIZE  = iHSIZE;
        previous_seq_item.HBURST = iHBURST;
        previous_seq_item.HPROT  = iHPROT;
        previous_seq_item.HADDR  = iHADDR;
        previous_seq_item.HWDATA = iHWDATA;

        previous_seq_item.RESET_op = iRESET_op;
        previous_seq_item.WRITE_op = iWRITE_op;
        previous_seq_item.TRANS_op = iTRANS_op;
        previous_seq_item.SIZE_op  = iSIZE_op;
        previous_seq_item.BURST_op = iBURST_op;
        previous_seq_item.RESET_op = iRESET_op;

        inputs_monitor_h.write_to_monitor(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, iRESET_op, iWRITE_op, iTRANS_op, iSIZE_op, iBURST_op, iRESET_op);
    endfunction : send_inputs

    // Function to send outputs to the output monitor
    function void send_outputs();

        outputs_monitor_h.write_to_monitor(HRDATA, HRESP, HREADY);
    endfunction : send_outputs


    always@(negedge clk) begin
        if(HREADY === 1'b1 && HRESETn === 1'b1) begin
            send_outputs();
    end

endinterface : inf