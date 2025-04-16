class sequence_item_trial extends sequence_item;
 	`uvm_object_utils(sequence_item_trial);

 	function new(string name = "sequence_item_trial");
 		super.new(name);
 	endfunction

    // rand int unsigned randomized_number_of_tests;

    // rand int unsigned sequence_randomizer;

    // rand int unsigned INCR_CONTROL;

    // rand bit reset_flag;

    // bit ERROR_ON_EXECUTE_IDLE;

    // rand HRESET_e     RESET_op;
    // rand HWRITE_e     WRITE_op;
    // rand HTRANS_e     TRANS_op;
    // rand HBURST_e     BURST_op;
    // rand HSIZE_e      SIZE_op;
    // rand HSEL_e       SEL_op;

    // HRESP_e      RESP_op;
    // HREADY_e     READY_op;

    // AHB lite Control Signals
    // bit         [ADDR_WIDTH-BITS_FOR_SUBORDINATES-1:0]          HADDRx;

    // rand  bit   HRESETn;    // reset (active low)

    // rand  bit   HWRITE;

    // rand  bit   [TRANS_WIDTH:0] HTRANS; 
    // rand  bit   [SIZE_WIDTH:0]  HSIZE;
    // rand  bit   [BURST_WIDTH:0] HBURST;
    // rand  bit   [PROT_WIDTH:0]  HPROT; 

    // randc  bit   [ADDR_WIDTH-1:0]  HADDR;     
    // randc  bit   [DATA_WIDTH-1:0]  HWDATA; 

    // // AHB lite output Signals
    // logic   [DATA_WIDTH-1:0]  HRDATA;
    // logic   [RESP_WIDTH-1:0]  HRESP; 
    // logic   [DATA_WIDTH-1:0]  HREADY;   


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

    function void post_randomize ();
      HRESETn   = RESET_op;    // reset (active low)
      HSEL      = SEL_op;
      HWRITE    = WRITE_op;
      HTRANS    = TRANS_op; 
      HSIZE     = SIZE_op;
      HBURST    = BURST_op;
      HADDR     = {int'(SEL_op),HADDRx};
      $display("post_randomize HSEL %0d & SEL_op %0d, HSIZE %0d & SIZE_op %0d", HSEL, SEL_op, HSIZE, SIZE_op);         
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

 endclass