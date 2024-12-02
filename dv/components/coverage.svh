/******************************************************************
 * File: coverage.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM coverage component used
 *              to collect coverage data on various signals and
 *              operations related to the generated stimulus.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/
 covergroup HWDATA_df_cg(input bit [DATA_WIDTH-1:0] position, ref bit [DATA_WIDTH-1:0] vector);
    df: coverpoint (vector & position) != 0;
    option.per_instance = 1;
 endgroup : HWDATA_df_cg

 covergroup HWDATA_dt_cg(input bit [DATA_WIDTH-1:0] position, ref bit [DATA_WIDTH-1:0] vector);
    dt: coverpoint (vector & position) != 0 {
          bins tr[] = (0 => 1, 1 => 0);
      }
    option.per_instance = 1;
 endgroup : HWDATA_dt_cg

 covergroup HADDR_df_cg(input bit [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] position, ref bit [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] vector);
    df: coverpoint (vector & position) != 0;
    option.per_instance = 1;
 endgroup : HADDR_df_cg

 covergroup HADDR_dt_cg(input bit [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] position, ref bit [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] vector);
    dt: coverpoint (vector & position) != 0 {
          bins tr[] = (0 => 1, 1 => 0);
      }
    option.per_instance = 1;
 endgroup : HADDR_dt_cg

 covergroup HSEL_df_cg(input bit [BITS_FOR_SUBORDINATES-1:0] position, ref bit [BITS_FOR_SUBORDINATES-1:0] vector);
    df: coverpoint (vector & position) != 0;
    option.per_instance = 1;
 endgroup : HSEL_df_cg

  covergroup HSEL_dt_cg(input bit [BITS_FOR_SUBORDINATES-1:0] position, ref bit [BITS_FOR_SUBORDINATES-1:0] vector);
    dt: coverpoint (vector & position) != 0 {
          bins tr[] = (0 => 1, 1 => 0);
      }
    option.per_instance = 1;
  endgroup : HSEL_dt_cg

  // covergroup HSIZE_df_cg(input bit [SIZE_WIDTH:0] position, ref bit [SIZE_WIDTH:0] vector);
  //   df: coverpoint (vector & position) != 0;
  //   option.per_instance = 1;
  // endgroup : HSIZE_df_cg

  covergroup HSIZE_dt_cg_bits(input bit [SIZE_WIDTH:0] position, ref bit [SIZE_WIDTH:0] vector);
    dt:coverpoint vector {
      bins tr[] = (vector => position);
    }
    option.per_instance = 1;
  endgroup : HSIZE_dt_cg_bits  

class coverage extends uvm_subscriber #(sequence_item);
  `uvm_component_utils(coverage);

  //typedef uvm_subscriber #(my_first_sequence_item) this_type; //chipverify tlm_analysis_port, also to be used in the X_imp classes to be instantiated there
  //uvm_analysis_imp(my_first_sequence_item, my_first_subscriber); //giving the type of packet & the uvm_subscriber data type so he can instantiate there

  // Virtual interface used for connecting to the Design Under Test (DUT)
  virtual inf my_vif;

  // AHB lite Control Signals
        bit   HRESETn_cov;    // reset (active low)

        bit   HWRITE_cov;

        bit   [TRANS_WIDTH:0]  HTRANS_cov; 
        bit   [SIZE_WIDTH:0]  HSIZE_cov;
        bit   [BURST_WIDTH:0] HBURST_cov;
        bit   [PROT_WIDTH:0]  HPROT_cov; 

        bit   [ADDR_WIDTH-1:0]  HADDR_cov;     
        bit   [DATA_WIDTH-1:0]  HWDATA_cov;

        bit   [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] HADDR_VALID_cov;
        bit   [BITS_FOR_SUBORDINATES-1:0] HSEL_cov; 

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

  HWDATA_df_cg HWDATA_df_cg_bits  [DATA_WIDTH-1:0];
  HWDATA_dt_cg HWDATA_dt_cg_bits  [DATA_WIDTH-1:0];

  HADDR_df_cg  HADDR_df_cg_bits   [ADDR_WIDTH-1-BITS_FOR_SUBORDINATES:0];
  HADDR_dt_cg  HADDR_dt_cg_bits   [ADDR_WIDTH-1-BITS_FOR_SUBORDINATES:0];

  HSEL_df_cg  HSEL_df_cg_bits   [BITS_FOR_SUBORDINATES-1:0];
  HSEL_dt_cg  HSEL_dt_cg_bits   [BITS_FOR_SUBORDINATES-1:0];

  // HSIZE_df_cg HSIZE_df_cg_bits  [SIZE_WIDTH:0];
  //HSIZE_dt_cg HSIZE_dt_cg_bits  [SIZE_WIDTH:0];

  HSIZE_dt_cg_bits HSIZE_dt_cg_bits_t [AVAILABLE_SIZES-1:0];


  // Covergroup for RESET-related coverage
  covergroup RESET_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HRESETn_cov {
      bins RESET_Operation     =  {RESETING};
      bins NON_RESET_Operation =  {WORKING};
      //bins READ_Operation_for_FIFO_SIZE = (READ [* 8]);
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HRESETn_cov {
      bins RESETING_WORKING_Transition     = (RESETING => WORKING);
      bins WORKING_RESETING_Transition     = (WORKING => RESETING);
    }

  endgroup

  // Covergroup for WRITE-related coverage
  covergroup WRITE_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HWRITE_cov iff (HRESETn_cov) {
      bins WRITE_Operation = {WRITE};
      bins READ_Operation =  {READ};
      //bins READ_Operation_for_FIFO_SIZE = (READ [* 8]);
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HWRITE_cov iff(HRESETn_cov) {
      bins WRITE_READ_Transition     = (READ => WRITE);
      bins READ_WRITE_Transition     = (WRITE => READ);
    }

  endgroup

    // Covergroup for TRANS-related coverage
  covergroup TRANS_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HTRANS_cov iff (HRESETn_cov) {
      bins IDLE_Operation   = {IDLE};
      // bins BUSY_Operation   =  {BUSY};
      bins NONSEQ_Operation =  {NONSEQ};
      bins SEQ_Operation    =  {SEQ};
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HTRANS_cov iff(HRESETn_cov) {
      bins IDLE_IDLE_Transition       = (IDLE => IDLE);    
      // bins IDLE_BUSY_Transition       = (IDLE => BUSY);
      bins IDLE_NONSEQ_Transition     = (IDLE => NONSEQ);
      // bins IDLE_SEQ_Transition        = (IDLE => SEQ);

      // bins BUSY_BUSY_Transition       = (BUSY => BUSY);
      // bins BUSY_IDLE_Transition       = (BUSY => IDLE);
      // bins BUSY_NONSEQ_Transition     = (BUSY => NONSEQ);
      // bins BUSY_SEQ_Transition        = (BUSY => SEQ);

      bins NONSEQ_NONSEQ_Transition    = (NONSEQ => NONSEQ);
      bins NONSEQ_IDLE_Transition     = (NONSEQ => IDLE);
      // bins NONSEQ_BUSY_Transition     = (NONSEQ => BUSY);
      bins NONSEQ_SEQ_Transition      = (NONSEQ => SEQ);

      bins SEQ_SEQ_Transition       = (SEQ => SEQ);
      bins SEQ_WRITE_Transition       = (SEQ => IDLE);
      // bins SEQ_BUSY_Transition        = (SEQ => BUSY);
      // bins SEQ_NONSEQ_Transition      = (SEQ => NONSEQ);

      //bins WRITE_Operation_for_FIFO_SIZE = (WRITE [* 8]);

      bins SEQ_Operation_BURST4_OPERATIONS = (SEQ [* 3]);
      bins SEQ_Operation_BURST8_OPERATIONS = (SEQ [* 7]);
      bins SEQ_Operation_BURST16_OPERATIONS = (SEQ [* 15]);
    }

  endgroup

    // Covergroup for TRANS-related coverage
  covergroup BURST_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HBURST_cov iff (HRESETn_cov) {
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
    dt_operation: coverpoint HBURST_cov iff(HRESETn_cov) {
      bins SINGLE_SINGLE_Transition    = (SINGLE => SINGLE);
      bins SINGLE_INCR_Transition      = (SINGLE => INCR);
      bins SINGLE_WRAP4_Transition     = (SINGLE => WRAP4);
      bins SINGLE_INCR4_Transition     = (SINGLE => INCR4);
      bins SINGLE_WRAP8_Transition     = (SINGLE => WRAP8);
      bins SINGLE_INCR8_Transition     = (SINGLE => INCR8);
      bins SINGLE_WRAP16_Transition    = (SINGLE => WRAP16);
      bins SINGLE_INCR16_Transition    = (SINGLE => INCR16);


      bins INCR_SINGLE_Transition      = (INCR => SINGLE);

      bins WRAP4_SINGLE_Transition     = (WRAP4 => SINGLE);

      bins INCR4_SINGLE_Transition     = (INCR4 => SINGLE);

      bins WRAP8_SINGLE_Transition     = (WRAP8 => SINGLE);

      bins INCR8_SINGLE_Transition     = (INCR8 => SINGLE);

      bins WRAP16_SINGLE_Transition    = (WRAP16 => SINGLE);

      bins INCR16_SINGLE_Transition    = (INCR16 => SINGLE);
    }

  endgroup 


    // Covergroup for TRANS-related coverage
  covergroup SIZE_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HSIZE_cov iff (HRESETn_cov) {
    `ifdef HWDATA_WIDTH32
      bins BYTE_Operation       =  {BYTE};
      bins HALFWORD_Operation   =  {HALFWORD};
      bins WORD_Operation       =  {WORD};
    `endif
    `ifdef HWDATA_WIDTH64
      bins INCR4_Operation      =  {WORD2};
    `endif
    `ifdef HWDATA_WIDTH128
      bins WRAP8_Operation      =  {WORD4};
    `endif
    `ifdef HWDATA_WIDTH256
      bins INCR8_Operation      =  {WORD8};
    `endif
    `ifdef HWDATA_WIDTH512
      bins WRAP16_Operation     =  {WORD16};
    `endif
    `ifdef HWDATA_WIDTH1024
      bins INCR16_Operation     =  {WORD32};
    `endif
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HSIZE_cov iff(HRESETn_cov) {
    `ifdef HWDATA_WIDTH32

      bins BYTE_BYTE_Transition          = (BYTE => BYTE);
      bins BYTE_HALFWORD_Transition      = (BYTE => HALFWORD);
      bins BYTE_WORD_Transition          = (BYTE => WORD);
      bins BYTE_WORD2_Transition         = (BYTE => WORD2);
      bins BYTE_WORD4_Transition         = (BYTE => WORD4);
      bins BYTE_WORD8_Transition         = (BYTE => WORD8);
      bins BYTE_WORD16_Transition        = (BYTE => WORD16);
      bins BYTE_WORD32_Transition        = (BYTE => WORD32);


      bins HALFWORD_BYTE_Transition      = (HALFWORD => BYTE);
      bins HALFWORD_HALFWORD_Transition  = (HALFWORD => HALFWORD);
      bins HALFWORD_WORD_Transition      = (HALFWORD => WORD);
      bins HALFWORD_WORD2_Transition     = (HALFWORD => WORD2);
      bins HALFWORD_WORD4_Transition     = (HALFWORD => WORD4);
      bins HALFWORD_WORD8_Transition     = (HALFWORD => WORD8);
      bins HALFWORD_WORD16_Transition    = (HALFWORD => WORD16);
      bins HALFWORD_WORD32_Transition      = (HALFWORD => WORD32);

      bins WORD_BYTE_Transition          = (WORD => BYTE);
      bins WORD_HALFWORD_Transition      = (WORD => HALFWORD);
      bins WORD_WORD_Transition          = (WORD => WORD);
      bins WORD_WORD2_Transition         = (WORD => WORD2);
      bins WORD_WORD4_Transition         = (WORD => WORD4);
      bins WORD_WORD8_Transition         = (WORD => WORD8);
      bins WORD_WORD16_Transition        = (WORD => WORD16);
      bins WORD_WORD32_Transition        = (WORD => WORD32);

    `endif

    `ifdef HWDATA_WIDTH64

      bins WORD2_BYTE_Transition          = (WORD2 => BYTE);
      bins WORD2_HALFWORD_Transition      = (WORD2 => HALFWORD);
      bins WORD2_WORD_Transition          = (WORD2 => WORD);
      bins WORD2_WORD2_Transition         = (WORD2 => WORD2);
      bins WORD2_WORD4_Transition         = (WORD2 => WORD4);
      bins WORD2_WORD8_Transition         = (WORD2 => WORD8);
      bins WORD2_WORD16_Transition        = (WORD2 => WORD16);
      bins WORD2_WORD32_Transition        = (WORD2 => WORD32);

    `endif
    `ifdef HWDATA_WIDTH128

      bins WORD4_BYTE_Transition          = (WORD4 => BYTE);
      bins WORD4_HALFWORD_Transition      = (WORD4 => HALFWORD);
      bins WORD4_WORD_Transition          = (WORD4 => WORD);
      bins WORD4_WORD2_Transition         = (WORD4 => WORD2);
      bins WORD4_WORD4_Transition         = (WORD4 => WORD4);
      bins WORD4_WORD8_Transition         = (WORD4 => WORD8);
      bins WORD4_WORD16_Transition        = (WORD4 => WORD16);
      bins WORD4_WORD32_Transition        = (WORD4 => WORD32);

    `endif

    `ifdef HWDATA_WIDTH256 

      bins WORD8_BYTE_Transition          = (WORD8 => BYTE);
      bins WORD8_HALFWORD_Transition      = (WORD8 => HALFWORD);
      bins WORD8_WORD_Transition          = (WORD8 => WORD);
      bins WORD8_WORD2_Transition         = (WORD8 => WORD2);
      bins WORD8_WORD4_Transition         = (WORD8 => WORD4);
      bins WORD8_WORD8_Transition         = (WORD8 => WORD8);
      bins WORD8_WORD16_Transition        = (WORD8 => WORD16);
      bins WORD8_WORD32_Transition        = (WORD8 => WORD32);

    `endif 

    `ifdef HWDATA_WIDTH512

      bins WORD16_BYTE_Transition          = (WORD16 => BYTE);
      bins WORD16_HALFWORD_Transition      = (WORD16 => HALFWORD);
      bins WORD16_WORD_Transition          = (WORD16 => WORD);
      bins WORD16_WORD2_Transition         = (WORD16 => WORD2);
      bins WORD16_WORD4_Transition         = (WORD16 => WORD4);
      bins WORD16_WORD8_Transition         = (WORD16 => WORD8);
      bins WORD16_WORD16_Transition        = (WORD16 => WORD16);
      bins WORD16_WORD32_Transition        = (WORD16 => WORD32);

    `endif

    `ifdef HWDATA_WIDTH1024

      bins WORD32_BYTE_Transition          = (WORD32 => BYTE);
      bins WORD32_HALFWORD_Transition      = (WORD32 => HALFWORD);
      bins WORD32_WORD_Transition          = (WORD32 => WORD);
      bins WORD32_WORD2_Transition         = (WORD32 => WORD2);
      bins WORD32_WORD4_Transition         = (WORD32 => WORD4);
      bins WORD32_WORD8_Transition         = (WORD32 => WORD8);
      bins WORD32_WORD16_Transition        = (WORD32 => WORD16);
      bins WORD32_WORD32_Transition        = (WORD32 => WORD32);

    `endif
    }

  endgroup


  covergroup SUBORDINATE_SELECT_covgrp;

    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_operation: coverpoint HADDR_cov[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] iff (HRESETn_cov) {
      bins SUBORDINATE1_Operation             =  {'b001};
      bins SUBORDINATE2_Operation             =  {'b010};
      bins SUBORDINATE3_Operation             =  {'b011};
      bins SUBORDINATE_DEFAULT_Operation      =  {'b100};
    }

    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
    dt_operation: coverpoint HADDR_cov[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] iff(HRESETn_cov)  {
      bins SUBORDINATE1_SUBORDINATE1_Transition          = (3'b001 => 3'b001);
      bins SUBORDINATE1_SUBORDINATE2_Transition          = (3'b001 => 3'b010);
      bins SUBORDINATE1_SUBORDINATE3_Transition          = (3'b001 => 3'b011);
      bins SUBORDINATE1_DEFAULT_Transition               = (3'b001 => 3'b100);

      bins SUBORDINATE2_SUBORDINATE1_Transition          = (3'b010 => 3'b001);
      bins SUBORDINATE2_SUBORDINATE2_Transition          = (3'b010 => 3'b010);
      bins SUBORDINATE2_SUBORDINATE3_Transition          = (3'b010 => 3'b011);
      bins SUBORDINATE2_DEFAULT_Transition               = (3'b010 => 3'b100);

      bins SUBORDINATE3_SUBORDINATE1_Transition          = (3'b011 => 3'b001);
      bins SUBORDINATE3_SUBORDINATE2_Transition          = (3'b011 => 3'b010);
      bins SUBORDINATE3_SUBORDINATE3_Transition          = (3'b011 => 3'b011);
      bins SUBORDINATE3_DEFAULT_Transition               = (3'b011 => 3'b100);

      bins DEFAULT_SUBORDINATE1_Transition         = (3'b100 => 3'b001);
      bins DEFAULT_SUBORDINATE2_Transition         = (3'b100 => 3'b010);
      bins DEFAULT_SUBORDINATE3_Transition         = (3'b100 => 3'b011);
      bins DEFAULT_DEFAULT_Transition              = (3'b100 => 3'b100);
    }
  endgroup 

  covergroup ADDR_covgrp;
    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */  
    `ifdef ADDR_WIDTH32
    df_operation: coverpoint HADDR_cov[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1: 0] iff ( HRESETn_cov ) {
      bins ADDR_values_others          =  {[(2**(ADDR_WIDTH-BITS_FOR_SUBORDINATES))-2:'h1]};
      bins ADDR_values_zeros           =  {'h0};
      bins ADDR_values_ones            =  {(2**(ADDR_WIDTH-BITS_FOR_SUBORDINATES))-1};
    }
    `endif
  endgroup 

 `ifdef HWDATA_WIDTH32
  covergroup HWDATA_covgrp;
    /* --------------------------------------------------------------------------------------Data Frame coverage of the current operation (either write or read)---------------------------------------------------------------------------------------------- */
    df_BYTE_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === BYTE)) {
      bins HWDATA_BYTE_values_others          =  {['h000000FE:'h00000001]};
      bins HWDATA_BYTE_values_zeros           =  {'h00000000};
      bins HWDATA_BYTE_values_ones            =  {'h000000FF};
    }

    df_HALFWORD_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === HALFWORD)) {
      bins HWDATA_HALFWORD_values_others      =  {['h0000FFFE:'h00000001]};
      bins HWDATA_HALFWORD_values_zeros       =  {'h00000000};
      bins HWDATA_HALFWORD_values_ones        =  {'h0000FFFF};
    }

    df_WORD_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD_values_others          =  {['hFFFFFFFE:'h00000001]};
      bins HWDATA_WORD_values_zeros           =  {'h00000000};
      bins HWDATA_WORD_values_ones            =  {'hFFFFFFFF};
    }
  `endif
  `ifdef HWDATA_WIDTH64 
    df_WORD2_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD2_values_others          =  {['hFFFFFFFFFFFFFFFE:'h1]};
      bins HWDATA_WORD2_values_zeros           =  {'h0};
      bins HWDATA_WORD2_values_ones            =  {'hFFFFFFFFFFFFFFFF};
    }
  `endif
  `ifdef HWDATA_WIDTH128
    df_WORD4_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD4_values_others          =  {['hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE:'h1]};
      bins HWDATA_WORD4_values_zeros           =  {'h0};
      bins HWDATA_WORD4_values_ones            =  {'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
    }
  `endif
  `ifdef HWDATA_WIDTH256
    df_WORD8_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD8_values_others          =  {['hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE:'h1]};
      bins HWDATA_WORD8_values_zeros           =  {'h0};
      bins HWDATA_WORD8_values_ones            =  {'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
    }
  `endif
  `ifdef HWDATA_WIDTH512
    df_WORD16_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD16_values_others          =  {['hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE:'h1]};
      bins HWDATA_WORD16_values_zeros           =  {'h0};
      bins HWDATA_WORD16_values_ones            =  {'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
    }
  `endif
  `ifdef HWDATA_WIDTH1024
    df_WORD32_operation: coverpoint HWDATA_cov iff (HRESETn_cov && (HSIZE_cov === WORD)) {
      bins HWDATA_WORD32_values_others          =  {['hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE:'h1]};
      bins HWDATA_WORD32_values_zeros           =  {'h0};
      bins HWDATA_WORD32_values_ones            =  {'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF};
    }
  `endif
    /* -------------------------------------------------------------------------------Data Transition coverage of the current operation (from write to read and vice versa)---------------------------------------------------------------------------------------------- */
  endgroup 


  // Function to update coverage based on sequence item
  function void write (sequence_item t);
    HRESETn_cov    = t.HRESETn;
    HWRITE_cov     = t.HWRITE;
    HTRANS_cov     = t.HTRANS;
    HSIZE_cov      = t.HSIZE;  
    HBURST_cov     = t.HBURST; 
    HPROT_cov      = t.HPROT;  
    HADDR_cov      = t.HADDR; 
    HWDATA_cov     = t.HWDATA;

    HADDR_VALID_cov = t.HADDR[ADDR_WIDTH-1-BITS_FOR_SUBORDINATES:0];
    HSEL_cov        = t.HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES];

    HRDATA_cov     = t.HRDATA;
    HRESP_cov      = t.HRESP;
    HREADY_cov     = t.HREADY;

    RESET_op_cov = t.RESET_op;
    WRITE_op_cov = t.WRITE_op;
    TRANS_op_cov = t.TRANS_op;
    BURST_op_cov = t.BURST_op;
    SIZE_op_cov  = t.SIZE_op;

    RESET_covgrp.sample();
    WRITE_covgrp.sample();
    TRANS_covgrp.sample();
    BURST_covgrp.sample();
    SIZE_covgrp.sample();
    SUBORDINATE_SELECT_covgrp.sample();
    ADDR_covgrp.sample();
    HWDATA_covgrp.sample();

    foreach(HSIZE_dt_val_cg_bits[i]) HSIZE_dt_val_cg_bits[i].sample();

    foreach(HWDATA_df_cg_bits[i]) HWDATA_df_cg_bits[i].sample();

    foreach(HWDATA_dt_cg_bits[i]) HWDATA_dt_cg_bits[i].sample();

    foreach(HADDR_df_cg_bits[i]) HADDR_df_cg_bits[i].sample();
    foreach(HADDR_dt_cg_bits[i]) HADDR_dt_cg_bits[i].sample();

    foreach(HSEL_df_cg_bits[i]) HSEL_df_cg_bits[i].sample();
    foreach(HSEL_dt_cg_bits[i]) HSEL_dt_cg_bits[i].sample();

    `uvm_info("COVERAGE", {"SAMPLE: ", t.convert2string}, UVM_HIGH)
  endfunction

  // Constructor for the coverage component
  function new(string name, uvm_component parent);

    super.new(name, parent);

    RESET_covgrp        = new;
    WRITE_covgrp        = new;
    TRANS_covgrp        = new;
    BURST_covgrp        = new;
    SIZE_covgrp         = new;
    SUBORDINATE_SELECT_covgrp = new;
    ADDR_covgrp         = new;
    HWDATA_covgrp       = new;

    foreach(HWDATA_df_cg_bits[i]) HWDATA_df_cg_bits[i] = new(1'b1<<i,HWDATA_cov);
    foreach(HWDATA_dt_cg_bits[i]) HWDATA_dt_cg_bits[i] = new(1'b1<<i,HWDATA_cov);

    foreach(HADDR_df_cg_bits[i]) HADDR_df_cg_bits[i] = new(1'b1<<i,HADDR_VALID_cov);
    foreach(HADDR_dt_cg_bits[i]) HADDR_dt_cg_bits[i] = new(1'b1<<i,HADDR_VALID_cov);

    foreach(HSEL_df_cg_bits[i]) HSEL_df_cg_bits[i] = new(1'b1<<i,HSEL_cov);
    foreach(HSEL_dt_cg_bits[i]) HSEL_dt_cg_bits[i] = new(1'b1<<i,HSEL_cov);

    // foreach(HSIZE_df_cg_bits[i]) HSIZE_df_cg_bits[i] = new(1'b1<<i,HSIZE_cov);

    //foreach(HSIZE_dt_cg_bits[i]) HSIZE_dt_cg_bits[i] = new(1'b1<<i,HSIZE_cov);

    foreach(HSIZE_dt_val_cg_bits[i]) HSIZE_dt_val_cg_bits[i]= new(i, HSIZE_cov);

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
