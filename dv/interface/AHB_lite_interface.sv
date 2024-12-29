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

bit RECEIVING_PHASE_FLAG;
bit CONTROL_PHASE_FLAG;
bit DATA_PHASE_FLAG;
bit OUTPUTS_PHASE_FLAG_1;
bit OUTPUTS_PHASE_FLAG_2;
//bit OUTPUTS_PHASE_FLAG_3;

semaphore pipeline_s1 = new(1);
semaphore pipeline_s2 = new(1);

// Monitor handles
driver driver_h; //handle to driver
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

sequence_item pipeline_seq_item1;
sequence_item pipeline_seq_item2;

event do_data_phase;
event do_sampling_phase;

bit pipeline_locked1;
bit pipeline_locked2;

  modport SVA (input clk, HRESETn, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY);

// // Task: Handle generic receiving operations based on reset and enable signals
//     task generic_reciever( sequence_item driven_item );  

//         wait((counter == 0 || counter >= 2) && CONTROL_PHASE_FLAG );
//         //#1step;
//         // if(HRESP === RETRY) begin
//         //     iHRESETn    = previous_seq_item.HRESETn;
//         //     iHWRITE     = previous_seq_item.HWRITE;
//         //     iHTRANS     = previous_seq_item.HTRANS;
//         //     iHSIZE      = previous_seq_item.HSIZE;  
//         //     iHBURST     = previous_seq_item.HBURST; 
//         //     iHPROT      = previous_seq_item.HPROT;  
//         //     iHADDR      = previous_seq_item.HADDR; 
//         //     iHWDATA     = previous_seq_item.HWDATA;

//         //     iRESET_op   = previous_seq_item.RESET_op;
//         //     iWRITE_op   = previous_seq_item.WRITE_op;
//         //     iTRANS_op   = previous_seq_item.TRANS_op;
//         //     iBURST_op   = previous_seq_item.BURST_op;
//         //     iSIZE_op    = previous_seq_item.SIZE_op;
//         // end
//             //$display("RECIEVING PHASE: ASSSINGING RANDOMIZED VALUES");

//             driven_item = seq_item.clone_me();

//             HRESETn_global = driven_item.HRESETn;

//             if(driven_item.HRESETn) begin
//                 counter = counter +1;
//             end


//             if(~HRESETn_global) begin
//                 fork
//                     begin
//                         @(negedge clk);
//                         send_inputs(seq_item.HRESETn, seq_item.HWRITE, seq_item.HTRANS, seq_item.HSIZE, seq_item.HBURST, seq_item.HPROT, seq_item.HADDR, seq_item.HWDATA, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);
//                     end
//                 join_none
//             end
            

//         RECEIVING_PHASE_FLAG = 1;

//         if(driven_item.last_item)begin
//             //$display("RECIEVING PHASE: TIME: %0t WAITING FOR COUNTERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",$time());
//             wait(HRESETn && !RECEIVING_PHASE_FLAG && (sequence_item::COMPARATOR_transaction_counter == sequence_item::PREDICTOR_transaction_counter /*&& HREADY*/) /*&& !OUTPUTS_PHASE_FLAG && !DATA_PHASE_FLAG*/); //so the driver doesnt keep driving when the sequence is already driven to the interface/dut
//         end
//         else begin
//             $display("RECIEVING PHASE: TIME: %0t WAITING FOR CONTROL PHASE TO transaction_finished",$time());
//              wait(HRESETn && !RECEIVING_PHASE_FLAG /*&& HREADY*/);
//         end
//     endtask : generic_reciever

    task begin_transaction(sequence_item transaction_item);
        address_phase(transaction_item);


        if(transaction_item.HRESETn) begin
            pipeline_lock_get1();
            //pipeline_s1.get();

            pipeline_seq_item1.do_copy(transaction_item);
            $display("data_phase_event");
            -> do_data_phase;
        end
    endtask : begin_transaction


    task address_phase(sequence_item address_phase_item);
        //T0
        HRESETn <= address_phase_item.HRESETn;
        HWRITE  <= address_phase_item.HWRITE;
        HTRANS  <= address_phase_item.HTRANS;
        HSIZE   <= address_phase_item.HSIZE;
        HBURST  <= address_phase_item.HBURST;
        HPROT   <= address_phase_item.HPROT;
        HADDR   <= address_phase_item.HADDR;

        // send_inputs(address_phase_item);
        send_inputs(address_phase_item.HRESETn, address_phase_item.HWRITE, address_phase_item.HTRANS, address_phase_item.HSIZE, address_phase_item.HBURST, address_phase_item.HPROT, address_phase_item.HADDR, address_phase_item.HWDATA, address_phase_item.RESET_op, address_phase_item.WRITE_op, address_phase_item.TRANS_op, address_phase_item.BURST_op, address_phase_item.SIZE_op);

        if(~address_phase_item.HRESETn) begin
            pipeline_seq_item2.do_copy(address_phase_item);
            wait_for_reset();
        end
        else begin
            @(posedge clk);
        //T1
        end

        while(~HREADY) begin
            @(posedge clk);
        end
    endtask : address_phase

    task wait_for_reset();
        repeat(14) begin
            @(posedge clk);
        end
        -> do_sampling_phase;
    endtask : wait_for_reset

    always begin
        @do_data_phase;
        $display("starting data_phase1");
        data_phase(pipeline_seq_item1);

        pipeline_lock_put1();
        pipeline_lock_get2();
        //pipeline_s2.put();

        pipeline_seq_item2.do_copy(pipeline_seq_item1);
        ->do_sampling_phase;
    end


    task data_phase(sequence_item data_phase_item);
        while(~HREADY) begin
            @(posedge clk);
        end
                $display("starting data_phase2");
        HWDATA <= data_phase_item.HWDATA;
        //@(posedge clk);
        //T2
    endtask : data_phase

    always begin
        @do_sampling_phase;
        @(posedge clk);
                $display("starting sampling_phase");
        //T3
        send_outputs();
        pipeline_seq_item2.HRESP  = HRESP;
        pipeline_seq_item2.HREADY = HREADY;
        pipeline_seq_item2.HRDATA = HRDATA;
        driver_h.end_transfer(pipeline_seq_item2);

        pipeline_lock_put2();
        //pipeline_s2.put();
    end


    task pipeline_lock_get1();
        while(pipeline_locked1) begin
            @(posedge clk);
        end
        pipeline_locked1 = 1;
    endtask : pipeline_lock_get1

    task pipeline_lock_put1();
        pipeline_locked1 = 0;
    endtask : pipeline_lock_put1

    
    task pipeline_lock_get2();
        while(pipeline_locked2) begin
            @(posedge clk);
        end
        pipeline_locked2 = 1;
    endtask : pipeline_lock_get2

    task pipeline_lock_put2();
        pipeline_locked2 = 0;
    endtask : pipeline_lock_put2




    // always@(posedge clk or negedge HRESETn_global ) begin //CONTROL_PHASE
    //     if(HRESETn_global /*&& HREADY*/)begin
    //         if(counter >= 1 && RECEIVING_PHASE_FLAG) begin
    //             $display("CONTROL PHASE: TIME:%0t ASSIGINING SIGNALS", $time());
    //          		HRESETn <= seq_item.HRESETn;
    //                 HWRITE  <= seq_item.HWRITE;
    //                 HTRANS  <= seq_item.HTRANS;
    //                 HSIZE   <= seq_item.HSIZE;
    //                 HBURST  <= seq_item.HBURST;
    //                 HPROT   <= seq_item.HPROT;
    //                 HADDR   <= seq_item.HADDR;

    //                 HRESETn_reg <= seq_item.HRESETn;
    //                 HWRITE_reg  <= seq_item.HWRITE;
    //                 HTRANS_reg  <= seq_item.HTRANS;
    //                 HSIZE_reg   <= seq_item.HSIZE;
    //                 HBURST_reg  <= seq_item.HBURST;
    //                 HPROT_reg   <= seq_item.HPROT;
    //                 HADDR_reg   <= seq_item.HADDR;
    //                 HWDATA_reg  <= seq_item.HWDATA;

    //                 //$display("seq_item.HADDR: %0h ", seq_item.HADDR);

    //                 send_inputs(seq_item.HRESETn, seq_item.HWRITE, seq_item.HTRANS, seq_item.HSIZE, seq_item.HBURST, seq_item.HPROT, seq_item.HADDR, seq_item.HWDATA, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);


    //             if(seq_item.HRESETn) begin
    //                 counter = counter + 1;
    //                 DATA_PHASE_FLAG = 1;
    //             end
    //         end
    //         CONTROL_PHASE_FLAG = 1; //probably obslete
    //         RECEIVING_PHASE_FLAG = 0;
    //     end
    //     else begin
    //         HRESETn <= seq_item.HRESETn; //forced design reset at the start of any sim
    //         HADDR   <= seq_item.HADDR;
    //         CONTROL_PHASE_FLAG = 1;
    //     end
    //     //wait(HREADY);
    // end

    // always@(negedge HRESETn_global) begin
    //     //$display("DATA_PHASE: TIME:%0t ASSERTING RESET", $time());
    //     reset_AHB();
    // end

    // // Task: Reset AHB pointers and flags
    // task reset_AHB();
    //     repeat(15) begin
    //         @(posedge clk);
    //     end
    //     HRESETn_global = 1'b1; //to prevent the control phase always block from re-itterating right after finishing the reset_task & before a new sequence is driven (it causes an endless)
    //     HRESETn <= 1'b1;
    //     counter = 0;
    // endtask : reset_AHB

    // always@(posedge HRESETn_global) begin
    //     //$display("OUTPUT_PHASE_RESET: TIME:%0t SENDING OUTPUTS", $time());
    //     send_outputs();
    //     OUTPUTS_PHASE_FLAG_1 = 0;
    //     OUTPUTS_PHASE_FLAG_2 = 0;
    //     //OUTPUTS_PHASE_FLAG_3 = 0;
    // end

    // always@(posedge clk) begin //DATA_PHASE //DATA_PHASE_FLAG might be obselete
    //     if((counter >= 3) && (HRESETn === 1) /*&& DATA_PHASE_FLAG*/ /*&& HREADY*/) begin // HRESETn to make it work after the reset cycle is done
    //         $display("DATA_PHASE: TIME:%0t ASSIGNING SIGNALS", $time());
    //         // The counter & data_phase_flag to make it work after a transaction is sent after reset cycle is done
    //         //send_inputs(HRESETn_reg, HWRITE_reg, HTRANS_reg, HSIZE_reg, HBURST_reg, HPROT_reg, HADDR_reg, HWDATA_reg, seq_item.RESET_op, seq_item.WRITE_op, seq_item.TRANS_op, seq_item.BURST_op, seq_item.SIZE_op);
    //         if(HWRITE_reg == 1'b1) begin
    //             //$display("DATA_PHASE_WRITE: TIME:%0t ASSIGNING SIGNALS", $time());
    //             write_AHB(HWDATA_reg);
    //         end
    //         else if(HWRITE_reg == 1'b0) begin
    //             //$display("DATA_PHASE_READ: TIME:%0t ASSIGNING SIGNALS", $time());
    //             read_AHB();
    //         end
    //         counter = counter + 1;
    //         DATA_PHASE_FLAG = 0;
    //         OUTPUTS_PHASE_FLAG_1 = 1;
    //         OUTPUTS_PHASE_FLAG_2 = 1;
    //     end
    //     $display("%0t BEFORE WAIT",$time());
    //     wait(HREADY);
    //     //$display("%0t AFTER WAIT",$time());
    // end

    // always@(posedge clk) begin
    //     if( (HRESETn === 1) && counter >= 5 && OUTPUTS_PHASE_FLAG_1 /*&& HREADY*/) begin
    //         $display("OUTPUT_1_PHASE_SIGNALS: TIME:%0t ", $time());
    //         //counter = counter + 1;
    //         OUTPUTS_PHASE_FLAG_1 = 0;
    //         //OUTPUTS_PHASE_FLAG_2 = 1;
    //         send_outputs();
    //     end
    //     //wait(HREADY);
    // end

    // always@(posedge clk) begin
    //     if(HRESETn && counter >= 4 && OUTPUTS_PHASE_FLAG_2 && HREADY) begin
    //         //$display("OUTPUT_2_PHASE_SIGNALS: TIME:%0t", $time());
    //         send_outputs();
    //         OUTPUTS_PHASE_FLAG_2 = 0;
    //         //OUTPUTS_PHASE_FLAG_3 = 1;
    //     end
    //     wait(HREADY);
    // end

    // always@(posedge clk) begin
    //     if(HRESETn && counter >= 5 && OUTPUTS_PHASE_FLAG_3) begin
    //         //$display("OUTPUT_3_PHASE_SIGNALS: TIME:%0t SENDING OUTPUTS", $time());
    //         send_outputs();
    //         OUTPUTS_PHASE_FLAG_3 = 0;
    //     end
    // end

    // Task: Write data into the AHB 
    // task write_AHB(input bit [DATA_WIDTH-1:0] iHWDATA);
    //     case(HTRANS_reg)
    //         IDLE, BUSY: begin
    //         end

    //         NONSEQ, SEQ: begin
    //             //wait(HREADY == 1'b1);
    //             HWDATA <= iHWDATA;
    //         end
    //     endcase // HTRANS
    // endtask : write_AHB

    // // Task: Read data from the AHB 
    // task read_AHB();
    //     case(HTRANS)
    //         IDLE, BUSY: begin
    //         end

    //         NONSEQ, SEQ: begin
    //             //wait(HREADY == 1'b1);
    //         end
    //     endcase // HTRANS
    // endtask : read_AHB

    // initial begin
    //     fork
    //         forever begin
    //             $monitor("TIME:%0t counter: %0d",$time(), counter);
    //             $monitor("TIME:%0t OUTPUTS_PHASE_FLAG_1: %0d",$time(), OUTPUTS_PHASE_FLAG_1);
    //         end
    //     join_none
    // end

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


    function void create_sequence_item();
        seq_item = sequence_item::type_id::create("seq_item");
        previous_seq_item = sequence_item::type_id::create("previous_seq_item");
        
        pipeline_seq_item1 = sequence_item::type_id::create("pipeline_seq_item1");
        pipeline_seq_item2 = sequence_item::type_id::create("pipeline_seq_item2");

    endfunction

    initial begin
        create_sequence_item();
        HRESETn <= 1'b1;
    end

    function assign_sequence_item (input sequence_item seq_item, input bit iHRESETn, input bit   iHWRITE, input bit  [TRANS_WIDTH:0] iHTRANS, 
                            input bit  [SIZE_WIDTH:0] iHSIZE, input bit  [BURST_WIDTH:0] iHBURST,
                            input bit  [PROT_WIDTH:0] iHPROT, input bit  [ADDR_WIDTH-1:0] iHADDR,     
                            input bit  [DATA_WIDTH-1:0] iHWDATA, input HRESET_e iRESET_op,
                            input HWRITE_e iWRITE_op, input HTRANS_e iTRANS_op,
                            input HBURST_e iBURST_op, input HSIZE_e iSIZE_op, input bit last_item );

        iHRESETn    = seq_item.HRESETn;
        iHWRITE     = seq_item.HWRITE;
        iHTRANS     = seq_item.HTRANS;
        iHSIZE      = seq_item.HSIZE;  
        iHBURST     = seq_item.HBURST; 
        iHPROT      = seq_item.HPROT;  
        iHADDR      = seq_item.HADDR; 
        iHWDATA     = seq_item.HWDATA;

        iRESET_op = seq_item.RESET_op;
        iWRITE_op = seq_item.WRITE_op;
        iTRANS_op = seq_item.TRANS_op;
        iBURST_op = seq_item.BURST_op;
        iSIZE_op  = seq_item.SIZE_op;


    endfunction 

endinterface : inf




    // task pipeline_lock_get1();
    //     while(~pipeline_key) begin
    //         @(posedge clk);
    //     end
    //     pipeline_key = 0;
    // endtask : pipeline_lock_get1

    // task pipeline_lock_put1();
    //     while(pipeline_key) begin
    //         @(posedge clk);
    //     end
    //     pipeline_key = 1;
    // endtask : pipeline_lock_put1