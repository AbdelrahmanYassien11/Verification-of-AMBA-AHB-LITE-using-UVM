class sequence_item extends uvm_sequence_item;
 	`uvm_object_utils(sequence_item);

 	function new(string name = "sequence_item");
 		super.new(name);
 	endfunction

rand int unsigned randomized_number_of_tests;

static int PREDICTOR_transaction_counter;
static int COMPARATOR_transaction_counter;

rand int unsigned sequence_randomizer;

rand int unsigned INCR_CONTROL;

rand bit reset_flag;

bit ERROR_ON_EXECUTE_IDLE;

rand HRESET_e     RESET_op;
rand HWRITE_e     WRITE_op;
rand HTRANS_e     TRANS_op;
rand HBURST_e     BURST_op;
rand HSIZE_e      SIZE_op;
rand HSEL_e       SEL_op;

    HRESP_e      RESP_op;
    HREADY_e     READY_op;

  // AHB lite Control Signals

  bit         [BITS_FOR_SUBORDINATES-1:0] HSEL;
  rand bit    [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] HADDRx;

  bit   HRESETn;    // reset (active low)

  bit   HWRITE;

  bit   [TRANS_WIDTH:0] HTRANS; 
  bit   [SIZE_WIDTH:0]  HSIZE;
  bit   [BURST_WIDTH:0] HBURST;
  rand  bit   [PROT_WIDTH:0]  HPROT; 

  bit   [ADDR_WIDTH-1:0]  HADDR;     
  rand  bit   [DATA_WIDTH-1:0]  HWDATA; 

    // AHB lite output Signals
    logic   [DATA_WIDTH-1:0]  HRDATA;
    logic   [RESP_WIDTH-1:0]  HRESP; 
    logic   [DATA_WIDTH-1:0]  HREADY;   

    // constraint randomized_seq_c { sequence_randomizer dist {[0:22]:=1};
    constraint randomized_seq_c { sequence_randomizer dist {[0:20]:=1};
    }

    constraint RESET_c {RESET_op dist {RESETING:/1, WORKING:/99}; 
    }

    constraint RESET_midburst_c {reset_flag dist {1:/1, 0:/99}; 
    }

    constraint HADDR_SEL_c {    RESET_op == WORKING  -> SEL_op dist {SUB1:/20, SUB2:/20, SUB3:/20, SUB4:/10, SUB5:/15, SUB6:/15};
                                RESET_op == RESETING -> SEL_op == NSEL;
    }

    constraint HADDR_c {  
      RESET_op == WORKING  -> {
        HADDRx dist {0:=1, (ADDR_DEPTH-1):=1, ['h00000001 : (ADDR_DEPTH-2)]:=1};
      }      
    }

    constraint HWRITE_rand_c { 
      RESET_op == WORKING -> {
        TRANS_op != IDLE -> {
          WRITE_op dist { WRITE:=50, READ:=50 };
        }
        TRANS_op == IDLE -> WRITE_op == READ;
      }
    }

    // constraint HWRITE_rand_c { RESET_op == WORKING  -> WRITE_op dist { WRITE:=50, READ:=50 };
    //                            RESET_op == RESETING -> WRITE_op == READ;
    // }
    constraint HADDR_VAL_BURST {BURST_op == WRAP4  -> ((HADDRx > 2) && (HADDRx < (ADDR_DEPTH-1)));
                                BURST_op == WRAP8  -> ((HADDRx > 4) && (HADDRx < (ADDR_DEPTH-3)));
                                BURST_op == WRAP16 -> ((HADDRx > 8) && (HADDRx < (ADDR_DEPTH-7)));

                                BURST_op == INCR4   -> (HADDRx < ADDR_DEPTH-3  );
                                BURST_op == INCR8   -> (HADDRx < ADDR_DEPTH-7  );
                                BURST_op == INCR16  -> (HADDRx < ADDR_DEPTH-15 );

                                BURST_op == INCR    -> (HADDRx < ADDR_DEPTH-INCR_CONTROL );
    }

    constraint INCR_CONTROL_c {INCR_CONTROL inside {[1:ADDR_DEPTH-1]}; 
    }

    constraint HPROT_c {  SEL_op inside {[SUB1:SUB4]}    -> HPROT dist {4'b0001:/25, 4'b0000:/25, 4'b0010:/25, 4'b0011:/25};
                        (SEL_op == SUB5 && WRITE_op == WRITE)  -> HPROT dist {4'b0011:/50, 4'b0010:/50};
                        (SEL_op == SUB5 && WRITE_op == READ)  -> HPROT dist {4'b0001:/25, 4'b0000:/25, 4'b0010:/25, 4'b0011:/25};
                        (SEL_op == SUB6               )  -> HPROT dist {4'b0011:/50, 4'b0010:/50};
    }

    constraint SIZE_c1 {
                        DATA_WIDTH == BYTE_WIDTH      -> SIZE_op == 0;
                        DATA_WIDTH == HALFWORD_WIDTH  -> SIZE_op dist {0:=1, 1:=1};
                        DATA_WIDTH == WORD_WIDTH      -> SIZE_op dist {0:=1, 1:=1, 2:=1};
                        DATA_WIDTH == WORD2_WIDTH     -> SIZE_op dist {0:=1, 1:=1, 2:=1, 3:=1};
                        DATA_WIDTH == WORD4_WIDTH     -> SIZE_op dist {0:=1, 1:=1, 2:=1, 3:=1, 4:=1};
                        DATA_WIDTH == WORD8_WIDTH     -> SIZE_op dist {0:=1, 1:=1, 2:=1, 3:=1, 4:=1, 5:=1};
                        DATA_WIDTH == WORD16_WIDTH    -> SIZE_op dist {0:=1, 1:=1, 2:=1, 3:=1, 4:=1, 5:=1, 6:=1};
                        DATA_WIDTH == WORD32_WIDTH    -> SIZE_op dist {0:=1, 1:=1, 2:=1, 3:=1, 4:=1, 5:=1, 6:=1, 7:=1};
    }

    constraint HWDATA_c {
        RESET_op == WORKING -> {

            TRANS_op != IDLE -> {
                (SIZE_op == BYTE) ->
                    HWDATA dist { 'h0 := 1, BYTE_MAX := 1, ['h01 : BYTE_MAX - 1] := 1 };

                (SIZE_op == HALFWORD) ->
                    HWDATA dist { 'h0 := 1, HALFWORD_MAX := 1, ['h01 : HALFWORD_MAX - 1] := 1 };

                (SIZE_op == WORD) ->
                    HWDATA dist { 'h0 := 1, WORD_MAX := 1, ['h01 : WORD_MAX - 1] := 1 };

                (SIZE_op == WORD2) ->
                    HWDATA dist { 'h0 := 1, WORD2_MAX := 1, ['h01 : WORD2_MAX - 1] := 1 };

                (SIZE_op == WORD4) ->
                    HWDATA dist { 'h0 := 1, WORD4_MAX := 1, ['h01 : WORD4_MAX - 1] := 1 };

                (SIZE_op == WORD8) ->
                    HWDATA dist { 'h0 := 1, WORD8_MAX := 1, ['h01 : WORD8_MAX - 1] := 1 };

                (SIZE_op == WORD16) ->
                    HWDATA dist { 'h0 := 1, WORD16_MAX := 1, ['h01 : WORD16_MAX - 1] := 1 };

                (SIZE_op == WORD32) ->
                    HWDATA dist { 'h0 := 1, WORD32_MAX := 1, ['h01 : WORD32_MAX - 1] := 1 };
            }
            TRANS_op == IDLE -> HWDATA == 0;
        }

        RESET_op == RESETING -> HWDATA == 0;
    }


    constraint randomized_test_number_c { randomized_number_of_tests inside {[100:150]};    
    }


    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
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

    function void post_randomize ();
      // Wait for the data phase to complete
      if(this.ERROR_ON_EXECUTE_IDLE) begin
        `uvm_info("SEQUENCE_ITEM", "OVERWRITING FOR ERROR RESPONSE", UVM_MEDIUM)
        this.HRESETn = 1;
        this.HWRITE  = 0;
        this.HTRANS  = 0;
        this.HBURST  = 0;
        this.HWDATA  = 0;
        this.ERROR_ON_EXECUTE_IDLE = 0;
        `uvm_info("SEQUENCE_ITEM", {"ERROR_RESPONSE: ", this.input2string()}, UVM_MEDIUM)
      end
    endfunction

    virtual function void do_copy(uvm_object rhs);
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
        HSEL       = to_be_copied.HSEL;

        HRDATA     = to_be_copied.HRDATA;
        HRESP      = to_be_copied.HRESP;
        HREADY     = to_be_copied.HREADY;
    endfunction : do_copy

    virtual function sequence_item clone_me();
      sequence_item clone;
      uvm_object tmp;

      tmp = this.clone;
      $cast(clone, tmp);
      return clone;
    endfunction : clone_me

    virtual function string convert2string();
      string s;

      s = $sformatf("atlas-----------------------------------------------------------------------------------------------------------------------------------------
                     time: %0t  HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, HRDATA = %0h, HRESP = %0d, HREADY = %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                     $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction : convert2string


    virtual function string input2string();
      string s;
      s = $sformatf("atlas-----------------------------------------------------------------------------------------------------------------------------------------
                    time: %0t HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                    $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction

    virtual function string output2string();
      string s;
      s = $sformatf("atlas-----------------------------------------------------------------------------------------------------------------------------------------
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