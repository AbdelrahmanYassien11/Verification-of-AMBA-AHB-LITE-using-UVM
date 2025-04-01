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
randc HSIZE_e      SIZE_op;
rand HSEL_e       SEL_op;


     HRESP_e      RESP_op;
     HREADY_e     READY_op;

//operation_e operation_o;

static bit last_item;
static int PREDICTOR_transaction_counter;
static int COMPARATOR_transaction_counter;

rand int unsigned sequence_randomizer;

rand int unsigned INCR_CONTROL;

rand bit reset_flag;

bit ERROR_ON_EXECUTE_IDLE;


  // AHB lite Control Signals

  bit         [ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] HSEL;

  rand  bit   HRESETn;    // reset (active low)

  rand  bit   HWRITE;

  rand  bit   [TRANS_WIDTH:0] HTRANS; 
  rand  bit   [SIZE_WIDTH:0]  HSIZE;
  rand  bit   [BURST_WIDTH:0] HBURST;
  rand  bit   [PROT_WIDTH:0]  HPROT; 

  randc  bit   [ADDR_WIDTH-1:0]  HADDR;     
  randc  bit   [DATA_WIDTH-1:0]  HWDATA; 

        // AHB lite output Signals
        logic   [DATA_WIDTH-1:0]  HRDATA;
        logic   [RESP_WIDTH-1:0]  HRESP; 
        logic   [DATA_WIDTH-1:0]  HREADY;   


      constraint randomized_seq_c { sequence_randomizer dist {[0:20]:=1};
      }

      constraint RESET_cmd {RESET_op dist {0:/1, 1:/99}; 
      }

      constraint RESET_midburst_c {reset_flag dist {1:/1, 0:/99}; 
      }

      constraint RESET_c {RESET_op == RESETING -> HRESETn == 0;
                          RESET_op == WORKING  -> HRESETn == 1;
      }

      constraint HADDR_SEL_c { /*HRESETn == 1  ->*/ SEL_op dist {1:/20, 2:/20, 3:/20, 4:/10, 5:/15, 6:/15};
                               // HRESETn == 0  -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 3'b0;
      }

      constraint HADDR_SEL_op_c { SEL_op == 1 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 1;
                                  SEL_op == 2 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 2;
                                  SEL_op == 3 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 3;
                                  SEL_op == 4 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 4;
                                  SEL_op == 5 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 5;
                                  SEL_op == 6 -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 6;
                                    
      };

      // constraint HADDR_SEL_c { /*HRESETn == 1  ->*/ HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] dist {1:/30, 2:/30, 3:/30, 4:/10};
      //                          // HRESETn == 0  -> HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 3'b0;
      // }
      constraint HADDR_c { /*HRESETn == 1  ->*/ HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] dist {0:=1, (ADDR_DEPTH-1):=1, ['h00000001 : (ADDR_DEPTH-2)]:=1};
                           // HRESETn == 0  -> HADDR[ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0] == 29'b0;
      }

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



      constraint WRITE_c {WRITE_op == READ   -> HWRITE == 1'b0;
                          WRITE_op == WRITE  -> HWRITE  == 1'b1; 
      }

      constraint HPROT_c {  HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] inside {[1:4]}       -> HPROT dist {4'b0001:/25, 4'b0000:/25, 4'b0010:/25, 4'b0011:/25};
                           (HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 5 && HWRITE == 1) -> HPROT dist {4'b0011:/50, 4'b0010:/50};
                           (HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 5 && HWRITE == 0) -> HPROT dist {4'b0001:/25, 4'b0000:/25, 4'b0010:/25, 4'b0011:/25};
                           (HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_SUBORDINATES] == 6               ) -> HPROT dist {4'b0011:/50, 4'b0010:/50};
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

      constraint SIZE_c  {
                          SIZE_op == BYTE       -> HSIZE == 3'b000;
                          SIZE_op == HALFWORD   -> HSIZE == 3'b001;
                          SIZE_op == WORD       -> HSIZE == 3'b010;
                          SIZE_op == WORD2      -> HSIZE == 3'b011;
                          SIZE_op == WORD4      -> HSIZE == 3'b100;
                          SIZE_op == WORD8      -> HSIZE == 3'b101;
                          SIZE_op == WORD16     -> HSIZE == 3'b110;
                          SIZE_op == WORD32     -> HSIZE == 3'b111;
      }

      constraint HWDATA_c { /*HRESETn == 1 ->*/ HSIZE == BYTE     -> HWDATA dist {'h0:=1, 'h000000FF:=1, ['h01 : 'h000000FE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == HALFWORD -> HWDATA dist {'h0:=1, 'h0000FFFF:=1, ['h01 : 'h0000FFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD     -> HWDATA dist {'h0:=1, 'h0FFFFFFFF:=1, ['h01 : 'h0FFFFFFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD2    -> HWDATA dist {'h0:=1, 'h0FFFFFFFFFFFFFFFF:=1, ['h01: 'h0FFFFFFFFFFFFFFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD4    -> HWDATA dist {'h0:=1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:=1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD8    -> HWDATA dist {'h0:=1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:=1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD16   -> HWDATA dist {'h0:=1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:=1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:=1};
                            /*HRESETn == 1 ->*/ HSIZE == WORD32   -> HWDATA dist {'h0:=1, 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:=1, ['h01: 'h0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE]:=1};
                            ///*HRESETn == 0 ->*/ HWDATA == 0;
                            HTRANS  == IDLE -> HWDATA == 0;
      }

      constraint randomized_test_number_c { randomized_number_of_tests inside {[100:150]};    
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

    // function void pre_randomize ();
    //   $display (" %0t This will be called just before randomization", $time());
    //   // Wait for the data phase to complete
    //   -> response_check;
    //   @(finished_response_checking);
    // endfunction

    function void post_randomize ();
      //$display (" %0t This will be called just after randomization", $time());
      // Wait for the data phase to complete
      if(this.ERROR_ON_EXECUTE_IDLE) begin
        $display("overwritting for error_response");
        this.HRESETn = 1;
        this.HWRITE  = 0;
        this.HTRANS  = 0;
        this.HBURST  = 0;
        this.HWDATA  = 0;
        this.ERROR_ON_EXECUTE_IDLE = 0;
        //`uvm_info("SEQUENCE_ITEM", {"ERROR_RESPONSE: ", this.input2string()}, UVM_LOW)
      end
      //this.ERROR_ON_EXECUTE_IDLE = 0;
    endfunction

    // task check_response1();
    //   forever begin
    //     sequence_item req;
    //     @(sequence_item::response_check);
    //     // Wait for the data phase to complete
    //     get_response(req);
    //     ///`uvm_info("SEQUENCE", $sformatf("RESPONSE_RETRIEVED: ", req.output2string()), UVM_LOW)
    //     if (req.HREADY == NOT_READY) begin
    //       IDLE_sequence_h.start(m_sequencer, this);
    //     end
    //     -> finished_response_checking;
    //   end
    // endtask: check_response1


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



    function void do_copy_nb(uvm_object rhs);
      sequence_item to_be_copied;

      $display("YOOOOOOOO1");
      assert(rhs != null) else
        $fatal(1,"Tried to copy null transaction");
      $display("YOOOOOOO2");
      assert($cast(to_be_copied,rhs)) else
        $fatal(1,"Faied cast in do_copy");

      $display("YOOOOOO3");
      super.do_copy(rhs); // give all the variables to the parent class, so it can be used by to_be_copied
        HRESETn    <= to_be_copied.HRESETn;
        HWRITE     <= to_be_copied.HWRITE;
        HTRANS     <= to_be_copied.HTRANS;
        HSIZE      <= to_be_copied.HSIZE;  
        HBURST     <= to_be_copied.HBURST; 
        HPROT      <= to_be_copied.HPROT;  
        HADDR      <= to_be_copied.HADDR; 
        HWDATA     <= to_be_copied.HWDATA;

        HRDATA     <= to_be_copied.HRDATA;
        HRESP      <= to_be_copied.HRESP;
        HREADY     <= to_be_copied.HREADY;
    endfunction : do_copy_nb

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