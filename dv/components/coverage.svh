/******************************************************************
 * File: coverage.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM coverage component used
 *              to collect coverage data on various signals and
 *              operations related to FIFO.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class coverage extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(coverage);

  //typedef uvm_subscriber #(my_first_sequence_item) this_type; //chipverify tlm_analysis_port, also to be used in the X_imp classes to be instantiated there
  //uvm_analysis_imp(my_first_sequence_item, my_first_subscriber); //giving the type of packet & the uvm_subscriber data type so he can instantiate there

  // Virtual interface used for connecting to the Design Under Test (DUT)
  virtual inf my_vif;

  // AHB lite Control Signals
  rand  bit   HRESETn_cov;    // reset (active low)

        bit   HWRITE_cov;

        bit   [TRANS_WIDTH:0]  HTRANS_cov; 
        bit   [SIZE_WIDTH:0]  HSIZE_cov;
        bit   [BURST_WIDTH:0]  HBURST_cov;
        bit   [PROT_WIDTH:0]  HPROT_cov; 

  rand  bit   [ADDR_WIDTH-1:0]  HADDR_cov;     
  rand  bit   [DATA_WIDTH-1:0]  HWDATA_Cov; 

        // AHB lite output Signals
        logic   [DATA_WIDTH-1:0]  HRDATA_cov;
        logic   [RESP_WIDTH-1:0]  HRESP_cov; 
        logic   [DATA_WIDTH-1:0]  HREADY_cov;

  HRESET_e     RESET_op_cov;
  HWRITE_e     WRITE_op_cov;
  HRESP_e      RESP_op_cov;
  HTRANS_e     TRANS_op_cov;
  HBURST_e     BURST_op_cov;
  HSIZE_e      SIZE_op_cov;


  // Covergroup for RESET-related coverage
  covergroup RESET_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint RESET_cov {
      bins RESET_Operation     =  {RESETING};
      bins NON_RESET_Operation =  {WORKING};
      //bins READ_Operation_for_FIFO_SIZE = (READ [* 8]);
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint WRITE_cov iff(HRESETn_cov) {
      bins RESETING_WORKING_Transition     = (RESETING => WORKING);
      bins WORKING_RESETING_Transition     = (WORKING => RESETING);
    }

  endgroup

  // Covergroup for WRITE-related coverage
  covergroup WRITE_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint WRITE_cov iff (HRESETn) {
      bins WRITE_Operation = {WRITE};
      bins READ_Operation =  {READ};
      //bins READ_Operation_for_FIFO_SIZE = (READ [* 8]);
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint WRITE_cov iff(HRESETn_cov) {
      bins WRITE_READ_Transition     = (READ => WRITE);
      bins READ_WRITE_Transition     = (WRITE => READ);
    }

  endgroup

    // Covergroup for TRANS-related coverage
  covergroup TRANS_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint TRANS_cov iff (HRESETn) {
      bins IDLE_Operation   = {IDLE};
      bins BUSY_Operation   =  {BUSY};
      bins NONSEQ_Operation =  {NONSEQ};
      bins SEQ_Operation    =  {SEQ};
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint TRANS_cov iff(HRESETn_cov) {
      bins IDLE_BUSY_Transition       = (IDLE => BUSY);
      bins IDLE_NONSEQ_Transition     = (IDLE => NONSEQ);
      bins IDLE_SEQ_Transition        = (IDLE => SEQ);

      bins BUSY_IDLE_Transition       = (BUSY => IDLE);
      bins BUSY_NONSEQ_Transition     = (BUSY => NONSEQ);
      bins BUSY_SEQ_Transition        = (BUSY => SEQ);

      bins NONSEQ_IDLE_Transition     = (NONSEQ => IDLE);
      bins NONSEQ_BUSY_Transition     = (NONSEQ => BUSY);
      bins NONSEQ_SEQ_Transition      = (NONSEQ => SEQ);

      bins SEQ_WRITE_Transition       = (SEQ => IDLE);
      bins SEQ_BUSY_Transition        = (SEQ => BUSY);
      bins SEQ_NONSEQ_Transition      = (SEQ => NONSEQ);

      bins SEQ_Operation_BURST_OPERATIONS = (NONSEQ => (SEQ [* 3]));
      bins SEQ_Operation_BURST_OPERATIONS = (NONSEQ => (SEQ [* 7]));
      bins SEQ_Operation_BURST_OPERATIONS = (NONSEQ => (SEQ [* 15]);
    }

  endgroup

    // Covergroup for TRANS-related coverage
  covergroup BURST_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint BURST_cov iff (HRESETn) {
      bins SINGLE_Operation   =  {SINGLE};
      bins INCR_Operation     =  {INCR};
      bins WRAP4_Operation    =  {WRAP4};
      bins INCR4_Operation    =  {INCR4};
      bins WRAP8_Operation    =  {WRAP8};
      bins INCR8_Operation    =  {INCR8};
      bins WRAP16_Operation   =  {WRAP16};
      bins INCR16_Operation   =  {INCR16};

    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint BURST_cov iff(HRESETn_cov) {
      bins SINGLE_SINGLE_Transition    = (SINGLE => SINGLE);
      bins SINGLE_INCR_Transition      = (SINGLE => INCR);
      bins SINGLE_WRAP4_Transition     = (SINGLE => WRAP4);
      bins SINGLE_INCR4_Transition     = (SINGLE => INCR4);
      bins SINGLE_WRAP8_Transition     = (SINGLE => WRAP8);
      bins SINGLE_INCR8_Transition     = (SINGLE => INCR8);
      bins SINGLE_WRAP16_Transition    = (SINGLE => WRAP16);
      bins SINGLE_INCR16_Transition    = (SINGLE => INCR16);


      bins INCR_SINGLE_Transition      = (INCR => SINGLE);
      bins INCR_INCR_Transition        = (INCR => INCR);
      bins INCR_WRAP4_Transition       = (INCR => WRAP4);
      bins INCR_INCR4_Transition       = (INCR => INCR4);
      bins INCR_WRAP8_Transition       = (INCR => WRAP8);
      bins INCR_INCR8_Transition       = (INCR => INCR8);
      bins INCR_WRAP16_Transition      = (INCR => WRAP16);
      bins INCR_INCR16_Transition      = (INCR => INCR16);

      bins WRAP4_SINGLE_Transition     = (WRAP4 => SINGLE);
      bins WRAP4_INCR_Transition       = (WRAP4 => INCR);
      bins WRAP4_WRAP4_Transition      = (WRAP4 => INCR4);
      bins WRAP4_INCR4_Transition      = (WRAP4 => WRAP4);
      bins WRAP4_WRAP8_Transition      = (WRAP4 => WRAP8);
      bins WRAP4_INCR8_Transition      = (WRAP4 => INCR8);
      bins WRAP4_WRAP16_Transition     = (WRAP4 => WRAP16);
      bins WRAP4_INCR16_Transition     = (WRAP4 => INCR16);

      bins INCR4_SINGLE_Transition     = (INCR4 => SINGLE);
      bins INCR4_INCR_Transition       = (INCR4 => INCR);
      bins INCR4_WRAP4_Transition      = (INCR4 => WRAP4);
      bins INCR4_INCR4_Transition      = (INCR4 => INCR4);
      bins INCR4_WRAP8_Transition      = (INCR4 => WRAP8);
      bins INCR4_INCR8_Transition      = (INCR4 => INCR8);
      bins INCR4_WRAP16_Transition     = (INCR4 => WRAP16);
      bins INCR4_INCR16_Transition     = (INCR4 => INCR16);

      bins WRAP8_SINGLE_Transition     = (WRAP8 => SINGLE);
      bins WRAP8_INCR_Transition       = (WRAP8 => INCR);
      bins WRAP8_WRAP4_Transition      = (WRAP8 => WRAP4);
      bins WRAP8_INCR4_Transition      = (WRAP8 => INCR4);
      bins WRAP8_WRAP8_Transition      = (WRAP8 => WRAP8);
      bins WRAP8_INCR8_Transition      = (WRAP8 => INCR8);
      bins WRAP8_WRAP16_Transition     = (WRAP8 => WRAP16);
      bins WRAP8_INCR16_Transition     = (WRAP8 => INCR16);

      bins INCR8_SINGLE_Transition     = (INCR8 => SINGLE);
      bins INCR8_INCR_Transition       = (INCR8 => INCR);
      bins INCR8_WRAP4_Transition      = (INCR8 => WRAP4);
      bins INCR8_INCR4_Transition      = (INCR8 => INCR4);
      bins INCR8_WRAP8_Transition      = (INCR8 => WRAP8);
      bins INCR8_INCR8_Transition      = (INCR8 => INCR8);
      bins INCR8_WRAP16_Transition     = (INCR8 => WRAP16);
      bins INCR8_INCR16_Transition     = (INCR8 => INCR16);

      bins WRAP16_SINGLE_Transition    = (WRAP16 => SINGLE);
      bins WRAP16_INCR_Transition      = (WRAP16 => INCR);
      bins WRAP16_WRAP4_Transition     = (WRAP16 => WRAP4);
      bins WRAP16_INCR4_Transition     = (WRAP16 => INCR4);
      bins WRAP16_WRAP8_Transition     = (WRAP16 => WRAP8);
      bins WRAP16_INCR8_Transition     = (WRAP16 => INCR8);
      bins WRAP16_WRAP16_Transition    = (WRAP16 => WRAP16);
      bins WRAP16_INCR16_Transition    = (WRAP16 => INCR16);

      bins INCR16_SINGLE_Transition    = (INCR16 => SINGLE);
      bins INCR16_INCR_Transition      = (INCR16 => INCR);
      bins INCR16_WRAP4_Transition     = (INCR16 => WRAP4);
      bins INCR16_INCR4_Transition     = (INCR16 => INCR4);
      bins INCR16_WRAP8_Transition     = (INCR16 => WRAP8);
      bins INCR16_INCR8_Transition     = (INCR16 => INCR8);
      bins INCR16_WRAP16_Transition    = (INCR16 => WRAP16);
      bins INCR16_INCR16_Transition    = (INCR16 => INCR16);
    }

  endgroup 


    // Covergroup for TRANS-related coverage
  covergroup SIZE_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint SIZE_cov iff (HRESETn) {
      bins SINGLE_Operation     =  {BYTE_P};
      bins INCR_Operation       =  {HALFWORD_P};
      bins WRAP4_Operation      =  {WORD_P};
      // bins INCR4_Operation      =  {2WORD};
      // bins WRAP8_Operation      =  {4WORD};
      // bins INCR8_Operation      =  {8WORD};
      // bins WRAP16_Operation     =  {16WORD};
      // bins INCR16_Operation     =  {32WORD};
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint SIZE_cov iff(HRESETn_cov) {
      bins BYTE_BYTE_Transition          = (BYTE_P => BYTE_P);
      bins BYTE_HALFWORD_Transition      = (BYTE_P => HALFWORD_P);
      bins BYTE_WORD_Transition          = (BYTE_P => WORD_P);

      bins HALFWORD_BYTE_Transition      = (HALFWORD_P => BYTE_P);
      bins HALFWORD_HALFWORD_Transition  = (HALFWORD_P => HALFWORD_P);
      bins HALFWORD_WORD_Transition      = (HALFWORD_P => WORD_P);

      bins WORD_BYTE_Transition          = (WORD_P => BYTE_P);
      bins WORD_HALFWORD_Transition      = (WORD_P => HALFWORD_P);
      bins WORD_WORD_Transition          = (WORD_P => WORD_P);
    }

  endgroup


  covergroup SLAVE_SELECT_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HADDR_cov[ADDR_WIDTH-1:(ADDR_WIDTH-($clog2(NO_OF_SLAVES)))] iff (HRESETn_cov) {
      bins SLAVE0_Operation             =  {'b00};
      bins SLAVE1_Operation             =  {'b01};
      bins SLAVE2_Operation             =  {'b10};
      bins SLAVE_DEFAULT_Operation      =  {'b11};
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HADDR_cov[ADDR_WIDTH-1:(ADDR_WIDTH-($clog2(NO_OF_SLAVES)))] iff(HRESETn_cov)  {
      bins SLAVE0_SLAVE0_Transition          = (2'b00 => 2'b00);
      bins SLAVE0_SLAVE1_Transition          = (2'b00 => 2'b01);
      bins SLAVE0_SLAVE2_Transition          = (2'b00 => 2'b10);
      bins SLAVE0_DEFAULT_Transition         = (2'b00 => 2'b11);

      bins SLAVE1_SLAVE0_Transition          = (2'b01 => 2'b00);
      bins SLAVE1_SLAVE1_Transition          = (2'b01 => 2'b01);
      bins SLAVE2_SLAVE2_Transition          = (2'b01 => 2'b10);
      bins SLAVE3_DEFAULT_Transition         = (2'b01 => 2'b11);

      bins SLAVE2_SLAVE0_Transition          = (2'b10 => 2'b00);
      bins SLAVE2_SLAVE1_Transition          = (2'b10 => 2'b01);
      bins SLAVE2_SLAVE2_Transition          = (2'b10 => 2'b10);
      bins SLAVE2_DEFAULT_Transition         = (2'b10 => 2'b11);

      bins SLAVE2_SLAVE0_Transition          = (2'b11 => 2'b00);
      bins SLAVE2_SLAVE1_Transition          = (2'b11 => 2'b01);
      bins SLAVE2_SLAVE2_Transition          = (2'b11 => 2'b10);
      bins SLAVE2_DEFAULT_Transition         = (2'b11 => 2'b11);
    }
  endgroup 

  covergroup HADDR_covgrp;
    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HADDR_cov[(ADDR_WIDTH-($clog2(NO_OF_SLAVES)))-1: 0] iff ( HRESETn_cov ) {
      bins ADDR_values_others          =  {['hE:'h1]};
      bins ADDR_values_zeros           =  {'h0};
      bins ADDR_values_ones            =  {'hF};
    }
  endgroup 

  covergroup HWDATA_covgrp;
    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === BYTE_P)) {
      bins HWDATA_BYTE_values_others          =  {['h000000FE:'h00000001]};
      bins HWDATA_BYTE_values_zeros           =  {'h00000000};
      bins HWDATA_BYTE_values_ones            =  {'h000000FF};

    df_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === HALFWORD_P)) {
      bins HWDATA_HALFWORD_values_others      =  {['h0000FFFE:'h00000001]};
      bins HWDATA_HALFWORD_values_zeros       =  {'h00000000};
      bins HWDATA_HALFWORD_values_ones        =  {'h0000FFFF};
    }

    df_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD_P)) {
      bins HWDATA_WORD_values_others          =  {['hFFFFFFFE:'h00000001]};
      bins HWDATA_WORD_values_zeros           =  {'h00000000};
      bins HWDATA_WORD_values_ones            =  {'hFFFFFFFF};
    }
    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
  endgroup 


  // Function to update coverage based on sequence item
  function void write (sequence_item t);
    HRESETn_cov    = t.HRESETn;
    HWRITE_cov     = t.HWRITE;
    HTRANS_cov     = t.HTRANS;
    HSIZE_cov      = t.HSIZE;  
    HBRUST_cov     = t.HBURST; 
    HPROT_cov      = t.HPROT;  
    HADDR_cov      = t.HADDR; 
    HWDATA_cov     = t.HWDATA;

    HRDATA_cov     = t.HRDATA;
    HRESP_cov      = t.HRESP;
    HREADY_cov     = t.HREADY;

    RESET_op_cov = t.RESET_op;
    WRITE_op_cov = t.WRITE_op;
    TRANS_op_cov = t.TRANS_op;
    BURST_op_cov = t.BURST_op;
    SIZE_op_cov  = t.SIZE_op;

    FLAGS_covgrp.sample();
    OPERATION_covgrp.sample();
    INPUTS_covgrp.sample();

    `uvm_info("COVERAGE", {"SAMPLE: ", t.convert2string}, UVM_HIGH)
  endfunction

  // Constructor for the coverage component
  function new(string name, uvm_component parent);
    super.new(name, parent);
    OPERATION_covgrp = new;
    FLAGS_covgrp     = new;
    INPUTS_covgrp    = new;
  endfunction

  // Build phase for component setup
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $display("coverage build_phase");
    if (!uvm_config_db#(virtual inf)::get(this, "", "my_vif", my_vif)) begin
      `uvm_fatal(get_full_name(), "Error retrieving virtual interface");
    end
  endfunction

  // Run phase for execution
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    $display("coverage run_phase");
  endtask

endclass : coverage
