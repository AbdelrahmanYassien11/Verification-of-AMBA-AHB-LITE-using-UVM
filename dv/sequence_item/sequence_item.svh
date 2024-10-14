
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

static bit last_item;
static int PREDICTOR_transaction_counter;
static int COMPARATOR_transaction_counter;



  // AHB lite Control Signals
  rand  bit   HRESETn;    // reset (active low)

  rand  bit   HWRITE;

  rand  bit   [TRANS_WIDTH:0] HTRANS; 
  rand  bit   [SIZE_WIDTH:0]  HSIZE;
  rand  bit   [BURST_WIDTH:0] HBURST;
        bit   [PROT_WIDTH:0]  HPROT; 

  rand  bit   [ADDR_WIDTH-1:0]  HADDR;     
  rand  bit   [DATA_WIDTH-1:0]  HWDATA; 

        // AHB lite output Signals
        logic   [DATA_WIDTH-1:0]  HRDATA;
        logic   [RESP_WIDTH-1:0]  HRESP; 
        logic   [DATA_WIDTH-1:0]  HREADY;   

      // the values that will be randomized
      //rand bit [FIFO_WIDTH-1:0] data_to_write;
      // active low synchronous reset

       // constraint HWRITE_rand_c { WRITE_op dist { WRITE:=50, READ:=50 };
       // }


      constraint HWDATA_c { HSIZE == BYTE     -> HWDATA dist {'h00000000:/1, 'h000000FF:/1, ['h01 : 'h000000FE]:/40};
                            HSIZE == HALFWORD -> HWDATA dist {'h00000000:/1, 'h0000FFFF:/1, ['h01 : 'h0000FFFE]:/40};
                            HSIZE == HALFWORD -> HWDATA dist {'h00000000:/1, 'hFFFFFFFF:/1, ['h01 : 'hFFFFFFFE]:/40};
      }

      constraint HWADDR_SEL_c { HADDR[ADDR_WIDTH-1:(ADDR_WIDTH-BITS_FOR_PERIPHERALS)] dist {0:/30, NO_OF_PERIPHERALS-NO_OF_PERIPHERALS+1:/30, NO_OF_PERIPHERALS-NO_OF_PERIPHERALS+2:/30, NO_OF_PERIPHERALS-NO_OF_PERIPHERALS+3:/10};
      }

      constraint HADDR_c { HADDR[(ADDR_WIDTH-BITS_FOR_PERIPHERALS)-1:0] dist {'h00000000:/1, 'h0000000F:/1, ['h00000001 : 'h0000000E]:/40};
      }

      constraint RESET_c {RESET_op == RESETING -> HRESETn == 1'b0;
                          RESET_op == WORKING  -> HRESETn == 1'b1; 
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

      constraint SIZE_c  {SIZE_op == BYTE       -> HSIZE == 3'b000 && HWDATA[DATA_WIDTH-1:8]  == 'h0;
                          SIZE_op == HALFWORD   -> HSIZE == 3'b001 && HWDATA[DATA_WIDTH-1:16] == 'h0;
                          SIZE_op == WORD       -> HSIZE == 3'b010; 
                          SIZE_op == WORD2      -> HSIZE == 3'b011;
                          SIZE_op == WORD4      -> HSIZE == 3'b100;
                          SIZE_op == WORD8      -> HSIZE == 3'b101;
                          SIZE_op == WORD16     -> HSIZE == 3'b110;
                          SIZE_op == WORD32     -> HSIZE == 3'b111;
      }

      constraint randomized_test_number_c { randomized_number_of_tests inside {[100 :150]};    
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
        same = super.do_compare(rhs, comparer) && 
               (tested.HRDATA === HRDATA) &&
               (tested.HRESP  === HRESP);
               //(tested.HREADY == HREADY) &&
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
                     $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction : convert2string


    function string input2string();
      string s;
      s = $sformatf("-----------------------------------------------------------------------------------------------------------------------------------------
                    time: %0t HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                    $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction

    function string output2string();
      string s;
      s = $sformatf("-----------------------------------------------------------------------------------------------------------------------------------------
                    time: %0t HSEL: %0d  HRDATA: %0h  HRESP: %0d   HREADY: %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d",
                    $time, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
      return s;
    endfunction



    // function string convert2string();
    //   string s;

    //   s = $sformatf("  \n 
    //                 time: %0t  HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, HRDATA = %0h, HRESP = %0d, HREADY = %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d  \n
    //                 ******************************************************************************************************************************************************************************************************************",
    //                 $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction : convert2string


    // function string input2string();
    //   string s;
    //   s= $sformatf(" \n
    //                 time: %0t HRESETn = %0d, HSEL= %0d, HWRITE = %0d, HTRANS =  %0d, HSIZE = %0d, HBURST = %0d, HPROT = %0d, HADDR = %0h, HWDATA = %0h, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d \n
    //                 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
    //                 $time, HRESETn, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HWRITE, HTRANS, HSIZE, HBURST, HPROT, HADDR, HWDATA, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction

    // function string output2string();
    //   string s;
    //   s= $sformatf("  \m
    //                 time: %0t HSEL: %0d  HRDATA: %0h  HRESP: %0d   HREADY: %0d, PREDICTOR_transaction_counter = %0d, COMPARATOR_transaction_counter= %0d \n
    //                 ====================================================================================================================================================================================================================",
    //                 $time, HADDR[ADDR_WIDTH-1:ADDR_WIDTH-BITS_FOR_PERIPHERALS], HRDATA, HRESP, HREADY, PREDICTOR_transaction_counter, COMPARATOR_transaction_counter);
    //   return s;
    // endfunction


 endclass