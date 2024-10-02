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

event transaction_finished;
event starting_phases;
event interconnect_is_resetting;

bit RECEIVING_PHASE_FLAG;
bit CONTROL_PHASE_FLAG;
bit DATA_PHASE_FLAG;
bit OUTPUTS_PHASE_FLAG;

mailbox mbx = new(1);
// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor

logic HRESETn_global;

HRESET_e     RESET_op;
HWRITE_e     WRITE_op;
HRESP_e      RESP_op;
HTRANS_e     TRANS_op;
HBURST_e     BURST_op;
HSIZE_e      SIZE_op;

int counter;

sequence_item previous_seq_item, seq_item;

// Task: Handle generic receiving operations based on reset and enable signals
    task generic_reciever( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                            input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                            input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                            input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
                            input HWRITE_e iWRITE_op, input HTRANS_e iTRANS_op,
                            input HBURST_e iBURST_op, input HSIZE_e iSIZE_op
    );  
        wait(!RECEIVING_PHASE_FLAG /*&& !CONTROL_PHASE_FLAG*/);
        #1step;
        //@(negedge clk);//like an always block @negedge,
        $display("time: %0t negedge my bitchhhhhhhhhh", $time());
        if(HRESP === RETRY) begin
            iHRESETn    = previous_seq_item.HRESETn;
            iHWRITE     = previous_seq_item.HWRITE;
            iHTRANS     = previous_seq_item.HTRANS;
            iHSIZE      = previous_seq_item.HSIZE;  
            iHBURST     = previous_seq_item.HBURST; 
            iHPROT      = previous_seq_item.HPROT;  
            iHADDR     = previous_seq_item.HADDR; 
            iHWDATA     = previous_seq_item.HWDATA;

            iRESET_op = previous_seq_item.RESET_op;
            iWRITE_op = previous_seq_item.WRITE_op;
            iTRANS_op = previous_seq_item.TRANS_op;
            iBURST_op = previous_seq_item.BURST_op;
            iSIZE_op  = previous_seq_item.SIZE_op;
        end
        if(HREADY === 1'b1  || iHRESETn === 1'b0) begin
            $display("ASSSINGING RANDOMIZED VALUES");
            
            seq_item.RESET_op = iRESET_op;
            seq_item.WRITE_op = iWRITE_op;
            seq_item.TRANS_op = iTRANS_op;
            seq_item.BURST_op = iBURST_op;
            seq_item.SIZE_op  = iSIZE_op;

            seq_item.HRESETn    = iHRESETn;
            seq_item.HWRITE     = iHWRITE;
            seq_item.HTRANS     = iHTRANS;
            seq_item.HSIZE      = iHSIZE;  
            seq_item.HBURST     = iHBURST; 
            seq_item.HPROT      = iHPROT;  
            seq_item.HADDR      = iHADDR; 
            seq_item.HWDATA     = iHWDATA;

            HRESETn_global      = iHRESETn;

            RECEIVING_PHASE_FLAG = 1'b1;
            counter = counter +1;
            // @(starting_phases); // to stop the always blocks from continously running without new sequences being driven
            // -> transaction_finished;
            $display("RESETTTTTTTTTTTTTTTTTTTTT VALUE %0d", iHRESETn);
            send_inputs(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, iRESET_op, iWRITE_op, iTRANS_op, iBURST_op, iSIZE_op);
            wait(!RECEIVING_PHASE_FLAG /*&& !CONTROL_PHASE_FLAG*/);
            wait(HRESETn); //so the driver doesnt keep driving when the sequence is already driven to the interface/dut
        end
    endtask : generic_reciever

    always@(negedge clk or negedge HRESETn_global ) begin //CONTROL_PHASE
        $display("BEFORE EVENTSSSSSSSSS");
        // -> starting_phases;
        // @(transaction_finished);
        if(counter >= 1) begin
            if(RECEIVING_PHASE_FLAG) begin
                $display("time :%0t AFTER EVENTSSSSSSSSS", $time());
         		HRESETn <= seq_item.HRESETn;
                wait(HREADY == 1'b1);
                HWRITE  <= seq_item.HWRITE;
                HTRANS  <= seq_item.HTRANS;
                HSIZE   <= seq_item.HSIZE;
                HBURST  <= seq_item.HBURST;
                HPROT   <= seq_item.HPROT;
                HADDR   <= seq_item.HADDR;

                // HRESETn_reg <= seq_item.HRESETn;
                HWRITE_reg  <= seq_item.HWRITE;
                HTRANS_reg  <= seq_item.HTRANS;
                HSIZE_reg   <= seq_item.HSIZE;
                HBURST_reg  <= seq_item.HBURST;
                HPROT_reg   <= seq_item.HPROT;
                HADDR_reg   <= seq_item.HWDATA;
                HWDATA_reg  <= seq_item.HADDR;
                RECEIVING_PHASE_FLAG = 0;
                CONTROL_PHASE_FLAG = 1;
                counter = counter + 1;
            end
        end
    end

    always@(negedge HRESETn_global or negedge clk) begin
        if(counter >= )
        if(CONTROL_PHASE_FLAG) begin
            if(~HRESETn) begin
                $display("time:%0t starting_reset_task", $time());
                reset_AHB();
                CONTROL_PHASE_FLAG = 0;
            end
            counter = counter + 1;
        end
    end

    always@(negedge clk) begin //DATA_PHASE
        if(RECEIVING_PHASE_FLAG || !CONTROL_PHASE_FLAG) ((RECEIVING_PHASE_FLAG && ) || ) begin
            if(HRESETn) begin
                wait(HREADY == 1'b1);
                if(HWRITE_reg == 1'b1) begin
                    write_AHB(HWDATA_reg);
                end
                else if(HWRITE_reg == 1'b0) begin
                    read_AHB();
                end
                $display("time:%0t send_outputs HWRITE = %0d", $time(), HWRITE);
            end
            CONTROL_PHASE_FLAG = 0;
            DATA_PHASE_FLAG = 1;
        end
    end

    // Task: Reset AHB pointers and flags
    task reset_AHB();
    	$display("time :%0t resetting the interconnect", $time());
        repeat(15) begin
            @(negedge clk);
        end
        //send_outputs();
        HRESETn <= 1'b1;
        DATA_PHASE_FLAG = 0;
        $display("time:%0t HRESETn: %0d RESET DE-ASSERTED", $time(), HRESETn);
    endtask : reset_AHB


    // Task: Write data into the AHB and handle pointer updates
    task write_AHB(input bit [ADDR_WIDTH-1:0] iHWDATA);
        case(HTRANS_reg)
            IDLE, BUSY: begin
            end

            NONSEQ, SEQ: begin
                HWDATA <= iHWDATA;
            end
        endcase // HTRANS
        DATA_PHASE_FLAG = 0;
        // @(negedge clk);
        // send_outputs();
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
        DATA_PHASE_FLAG = 0;
        // @(negedge clk);
        // send_outputs();
    endtask : read_AHB


    always@(negedge clk) begin
        if(HRESETn == 1'b1) begin
            if((!DATA_PHASE_FLAG && !CONTROL_PHASE_FLAG) || OUTPUTS_PHASE_FLAG)begin
                send_outputs();
                OUTPUTS_PHASE_FLAG = 1'b1;
            end
        end
    end

    // Function to send inputs to the input monitor
    function void send_inputs( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                               input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                               input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                               input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
                               input HWRITE_e iWRITE_op, input HTRANS_e iTRANS_op,
                               input HBURST_e iBURST_op, input HSIZE_e iSIZE_op);

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

        inputs_monitor_h.write_to_monitor(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, iRESET_op, iWRITE_op, iTRANS_op, iBURST_op, iSIZE_op);
    endfunction : send_inputs

    // Function to send outputs to the output monitor
    function void send_outputs();
        outputs_monitor_h.write_to_monitor(HRDATA, HRESP, HREADY);
    endfunction : send_outputs


    // always@(negedge clk) begin
    //     if(HREADY === 1'b1 && HRESETn === 1'b1) begin
    //         send_outputs();
    //     end
    // end

    function void create_sequence_item();
        $display("CREATEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
        seq_item = sequence_item::type_id::create("seq_item");
        previous_seq_item = sequence_item::type_id::create("previous_seq_item");
    endfunction

    initial begin
        $monitor(" RESET VALUE ----------> HRESETn = %0d", HRESETn);
        create_sequence_item();
    end

    //assign HRESETn_global = (seq_item.HRESETn)? 1:0;

endinterface : inf