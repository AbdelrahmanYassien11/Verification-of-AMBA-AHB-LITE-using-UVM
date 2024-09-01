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

interface inf (
    clk                             // Write clock
    );

import AHB_pkg::*;                  // Import AHB package for AHB constants

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
logic   [DATA_WIDTH-1:0]  HRDATA;
logic   [RESP_WIDTH-1:0]  HRESP; 
logic   [DATA_WIDTH-1:0]  HREADY;   


event control_phase_finished;

// Monitor handles
inputs_monitor inputs_monitor_h;    // Handle to input monitor
outputs_monitor outputs_monitor_h;  // Handle to output monitor
STATE_e operation_interface;        // State of the AHB interface

// Task: Handle generic receiving operations based on reset and enable signals
task generic_reciever( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                        input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                        input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                        input bit  [DATA_WIDTH-1:0] iHWDATA, input STATE_e ioperation
);

    operation_interface = ioperation; 
    send_inputs(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
    // wrst_n = iwrst_n;
    // rrst_n = irrst_n;
        fork
            control_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
            data_phase(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
        join_any

endtask : generic_reciever


    task control_phase( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                        input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                        input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR     
                        );
        @(negedge clk);
        HRESETn <= iHRESETn;
        if(HREADY === 1'b1 && iHRESETn == 1'b1) begin
            HWRITE  <= iHWRITE;
            HTRANS  <= iHTRANS;
            HSIZE   <= iHSIZE;
            HBURST  <= iHBURST;
            HPROT   <= iHPROT;
            HADDR   <= iHADDR;
            -> control_phase_finished;
        end
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
        HRESETn = 1'b1
    endtask : reset_AHB


    // Task: Write data into the AHB and handle pointer updates
    task write_AHB(input bit [ADDR_WIDTH-1:0] iHWDATA);
        HWDATA <= iHWDATA;
        @(negedge clk);
    endtask : write_AHB

    // Task: Read data from the AHB and handle pointer updates
    task read_AHB();
        if(HREADY === 1'b1)
            @(negedge clk);
    endtask : read_AHB


    // Function to send inputs to the input monitor
    function void send_inputs(input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                              input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                              input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                              input bit  [DATA_WIDTH-1:0] iHWDATA);

        inputs_monitor_h.write_to_monitor(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA);
    endfunction : send_inputs

    // Function to send outputs to the output monitor
    function void send_outputs( input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                                input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                                input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                                input bit  [DATA_WIDTH-1:0] iHWDATA);

    outputs_monitor_h.write_to_monitor(iHRESETn, iHWRITE, iHTRANS, iHSIZE, iHBURST, iHPROT, iHADDR, iHWDATA, HRDATA, HRESP, HREADY, operation_interface);
endfunction : send_outputs



endinterface : inf
