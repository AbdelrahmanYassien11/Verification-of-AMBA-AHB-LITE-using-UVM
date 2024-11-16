
class sequence_item extends uvm_sequence_item;
 	`uvm_object_utils(sequence_item);

 	function new(string name = "sequence_item");
 		super.new(name);
 	endfunction

rand int unsigned randomized_number_of_tests;

rand HRESET_e     RESET_op;
rand HWRITE_e     WRITE_op;
rand HTRANS_e     TRANS_op;
rand HBURST_e     BURST_op;
rand HSIZE_e      SIZE_op;
     HRESP_e      RESP_op;

//operation_e operation_o;

static bit last_item;
static int PREDICTOR_transaction_counter;
static int COMPARATOR_transaction_counter;

//rand int unsigned randomized_sequences;

rand int unsigned INCR_CONTROL;



  // AHB lite Control Signals
  rand  bit   HRESETn;    // reset (active low)

  rand  bit   HWRITE;

  rand  bit   [TRANS_WIDTH:0] HTRANS; 
  rand  bit   [SIZE_WIDTH:0]  HSIZE;
  rand  bit   [BURST_WIDTH:0] HBURST;
        bit   [PROT_WIDTH:0]  HPROT; 

  randc  bit   [ADDR_WIDTH-1:0]  HADDR;     
  randc  bit   [DATA_WIDTH-1:0]  HWDATA; 

        // AHB lite output Signals
        logic   [DATA_WIDTH-1:0]  HRDATA;
        logic   [RESP_WIDTH-1:0]  HRESP; 
        logic   [DATA_WIDTH-1:0]  HREADY;   

      // the values that will be randomized
      //rand bit [FIFO_WIDTH-1:0] data_to_write;
      // active low synchronous reset


      // constraint randomized_seq { randomized_sequences inside {[0:17]};
      // }

      constraint RESET_cmd {RESET_op dist {0:/5, 1:/95}; 
      }

      constraint RESET_c {RESET_op == RESETING -> HRESETn == 0;
                          RESET_op == WORKING  -> HRESETn == 1;
      }

      // constraint operation_c { operation_e == RESETING -> HRESETn == 1'b0 && TRANS_op == IDLE  && WRITE_op == READ  && HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 0                              && HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] == 0;
      //                          operation_e == WRITTING -> HRESETn == 1'b1 &&                      WRITE_op == WRITE && HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] dist {1:/30, 2:/30, 3:/30, 4:/10} && HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] dist {0:/1, (ADDR_DEPTH-1):/1, ['h00000001 : (ADDR_DEPTH-2)]:=40};
      //                          operation_e == READ     -> HRESETn == 1'b1 &&                      WRITE_op == READ  && HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] dist {1:/30, 2:/30, 3:/30, 4:/10} && HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] dist {0:/1, (ADDR_DEPTH-1):/1, ['h00000001 : (ADDR_DEPTH-2)]:=40};
      //                          operation_e == IDLE     -> HRESETn == 1'b1 && TRANS_op == IDLE  && WRITE_op == READ;  
      // }

      constraint HWRITE_rand_c { WRITE_op dist { WRITE:=50, READ:=50 };
      }

      constraint HADDR_VAL_BURST { BURST_op == WRAP4  -> ((HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] > 2) && (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < (ADDR_DEPTH-1)));
                                   BURST_op == WRAP8  -> ((HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] > 4) && (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < (ADDR_DEPTH-3)));
                                   BURST_op == WRAP16 -> ((HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] > 8) && (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < (ADDR_DEPTH-7)));

                                   BURST_op == INCR4   -> (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < ADDR_DEPTH-3  );
                                   BURST_op == INCR8   -> (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < ADDR_DEPTH-7  );
                                   BURST_op == INCR16  -> (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < ADDR_DEPTH-15 );

                                   BURST_op == INCR    -> (HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] < ADDR_DEPTH-INCR_CONTROL );
      }

      constraint INCR_CONTROL_c {INCR_CONTROL inside {[1:ADDR_DEPTH-1]}; 
      }


      constraint HADDR_SEL_c { /*HRESETn == 1  -> */HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] dist {1:/30, 2:/30, 3:/30, 4:/10};
                               //HRESETn == 0  -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 0;
      }

      constraint HADDR_c { /*RESET_op == WORKING  ->*/ HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] dist {0:/1, (ADDR_DEPTH-1):/1, ['h00000001 : (ADDR_DEPTH-2)]:=40};
                           //RESET_op == RESETING -> HADDR[(ADDR_WIDTH-BITS_FOR_SUBORDINATES)-1:0] == 0;

      }


      constraint WRITE_c {WRITE_op == READ   -> HWRITE == 1'b0;
                          WRITE_op == WRITE  -> HWRITE  == 1'b1; 
      }

      constraint TRANS_c {TRANS_op == IDLE    -> HTRANS == 2'b00;
                          TRANS_op == BUSY    -> HTRANS == 2'b01;
                          TRANS_op == NONSEQ  -> HTRANS == 2'b10; 
                          TRANS_op == SEQ     -> HTRANS == 2'b11;
      }

      constraint BURST_c {BURST_op == SINGLE    -> HBURST == 3'b000;
                          BURST_op == INCR      -> HBURST == 3'b001;
                          BURST_op == WRAP4     -> HBURST == 3'b010; 
                          BURST_op == INCR4     -> HBURST == 3'b011;
                          BURST_op == WRAP8     -> HBURST == 3'b100;
                          BURST_op == INCR8     -> HBURST == 3'b101;
                          BURST_op == WRAP16    -> HBURST == 3'b110;
                          BURST_op == INCR16    -> HBURST == 3'b111;
      }


      constraint SIZE_c1 { DATA_WIDTH == BYTE_WIDTH      -> SIZE_op == 0;
                           DATA_WIDTH == HALFWORD_WIDTH  -> SIZE_op inside {[0:1]};
                           DATA_WIDTH == WORD_WIDTH      -> SIZE_op inside {[0:2]};
                           DATA_WIDTH == WORD2_WIDTH     -> SIZE_op inside {[0:3]};
                           DATA_WIDTH == WORD4_WIDTH     -> SIZE_op inside {[0:4]};
                           DATA_WIDTH == WORD8_WIDTH     -> SIZE_op inside {[0:5]};
                           DATA_WIDTH == WORD16_WIDTH    -> SIZE_op inside {[0:6]};
                           DATA_WIDTH == WORD32_WIDTH    -> SIZE_op inside {[0:7]};
      }

      constraint SIZE_c  {SIZE_op == BYTE       -> HSIZE == 3'b000;
                          SIZE_op == HALFWORD   -> HSIZE == 3'b001;
                          SIZE_op == WORD       -> HSIZE == 3'b010; 
                          SIZE_op == WORD2      -> HSIZE == 3'b011;
                          SIZE_op == WORD4      -> HSIZE == 3'b100;
                          SIZE_op == WORD8      -> HSIZE == 3'b101;
                          SIZE_op == WORD16     -> HSIZE == 3'b110;
                          SIZE_op == WORD32     -> HSIZE == 3'b111;
      }

      constraint HWDATA_c { HSIZE == BYTE     -> HWDATA dist {'h0:/1, 'h000000FF:/1, ['h01 : 'h000000FE]:/40};
                            HSIZE == HALFWORD -> HWDATA dist {'h0:/1, 'h0000FFFF:/1, ['h01 : 'h0000FFFE]:/40};
                            HSIZE == WORD     -> HWDATA dist {'h0:/1, 'h0FFFFFFFF:/1, ['h01 : 'h0FFFFFFFE]:/40};
                            HSIZE == WORD2    -> HWDATA dist {'h0:/1, 'h0FFFFFFFFFFFFFFFF:/1, ['h01: 'h0FFFFFFFFFFFFFFFE]:/40};
                            HSIZE == WORD4    -> HWDATA dist {'h0:/1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:/1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:/40};
                            HSIZE == WORD8    -> HWDATA dist {'h0:/1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:/1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:/40};
                            HSIZE == WORD16   -> HWDATA dist {'h0:/1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:/1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:/40};
                            HSIZE == WORD32   -> HWDATA dist {'h0:/1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:/1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:/40};
      }

      constraint randomized_test_number_c { randomized_number_of_tests inside {[450:500]};    
      }



    function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
      sequence_item tested;
      bit               same;
      
      if (rhs==null) `uvm_fatal(get_type_name(), 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(tested,rhs)) begin
        same = 0;
        $display("couldnt compare");
      end
      else begin
        if(tested.HTRANS == IDLE) begin
          same = super.do_compare(rhs, comparer) && /*(tested.HRDATA === HRDATA) &&*/ (tested.HREADY == HREADY) && (tested.HRESP  === HRESP);
        end
        else begin
          same = super.do_compare(rhs, comparer) && (tested.HRDATA === HRDATA) && (tested.HREADY == HREADY) && (tested.HRESP  === HRESP);
        end
      end
      return same;
    endfunction : do_compare




    function void do_copy(uvm_object rhs);
      sequence_item to_be_copied;

      assert(rhs != null) else
        $fatal(1,"Tried to copy null transaction");

      assert($cast(to_be_copied,rhs)) else
        $fatal(1,"Faied cast in do_copy");

      super.do_copy(rhs);	// give all the variables to the parent class, so it can be used by to_be_copied
        HRESETn    = to_be_copied.HRESETn;
        HWRITE     = to_be_copied.HWRITE;
        HTRANS     = to_be_copied.HTRANS;
        HSIZE      = to_be_copied.HSIZE;  
        HBURST     = to_be_copied.HBURST; 
        HPROT      = to_be_copied.HPROT;  
        HADDR      = to_be_copied.HADDR; 
        HWDATA     = to_be_copied.HWDATA;

        HRDATA     = to_be_copied.HRDATA;
        HRESP      = to_be_copied.HRESP;
        HREADY     = to_be_copied.HREADY;
    endfunction : do_copy

    function sequence_item clone_me();
      sequence_item clone;
      uvm_object tmp;

      tmp = this.clone;
      $cast(clone, tmp);
      return clone;
    endfunction : clone_me


    function string convert2string();
      string s;

      s = $sformatf("-----------------------------------------------------------------------------------------------------------------------------------------
                     time: %0t  HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, HRDATA = %0h, HRESP = %0d, HREADY = %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                     $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction : convert2string


    function string input2string();
      string s;
      s = $sformatf("-----------------------------------------------------------------------------------------------------------------------------------------
                    time: %0t HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                    $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction

    function string output2string();
      string s;
      s = $sformatf("-----------------------------------------------------------------------------------------------------------------------------------------
                    time: %0t HSEL: %0d  HRDATA: %0h  HRESP: %0d   HREADY: %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                    $time, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction



    // function string convert2string();
    //   string s;

    //   s = $sformatf("  \n 
    //                 time: %0t  HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, HRDATA = %0h, HRESP = %0d, HREADY = %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d  \n
    //                 ******************************************************************************************************************************************************************************************************************",
    //                 $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction : convert2string


    // function string input2string();
    //   string s;
    //   s= $sformatf(" \n
    //                 time: %0t HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d \n
    //                 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
    //                 $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction

    // function string output2string();
    //   string s;
    //   s= $sformatf("  \m
    //                 time: %0t HSEL: %0d  HRDATA: %0h  HRESP: %0d   HREADY: %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d \n
    //                 ====================================================================================================================================================================================================================",
    //                 $time, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction


 endclass