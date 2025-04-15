// Define the base_test class which extends uvm_test
// Use different base classes based on the simulation tool if necessary
// `ifdef QUESTA
// virtual class base_test extends uvm_test;
// `else 
class base_test extends uvm_test;
   `uvm_component_utils(base_test)
// `endif
   
   // Virtual interface for connecting to the DUT
   virtual inf my_vif;

   // Environment configuration object
   env_config env_config_h;

   // Environment instance
   env       env_h;

   // Sequencer instance
   sequencer sequencer_h;

   // Base sequence instance
   base_sequence base_sequence_h;


   // Constructor for the base_test class
   function new (string name = "base_test", uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // Build phase for configuring the test
   virtual function void build_phase(uvm_phase phase);

      // Retrieve the virtual interface from the configuration database
      if(!uvm_config_db#(virtual inf)::get(this,"","my_vif",my_vif)) begin
         `uvm_fatal(get_full_name(),"Error: Virtual Interface not found in the configuration database");
      end

      sequence_item::type_id::set_type_override(sequence_item_trial::type_id::get());
      // Create and configure the environment configuration object
      env_config_h = new(.env_config_my_vif(my_vif));

      // Set the environment configuration in the configuration database
      uvm_config_db#(env_config)::set(this, "env_h", "config", env_config_h);

      // Create instances of the environment and base sequence
      env_h = env::type_id::create("env_h", this);
      base_sequence_h = base_sequence::type_id::create("base_sequence_h");

      // Set the name of the test tot he entire environment so it can get parameterized accordingly
      uvm_config_db#(string)::set(this,"*","test_name",get_type_name());

      // Display message indicating the build phase completion
      `uvm_info(get_type_name(), "Build Phase", UVM_LOW)
   endfunction : build_phase

   // Connect phase for connecting components
   virtual function void connect_phase(uvm_phase phase);
      // Call the base class's connect_phase method
      super.connect_phase(phase);
      `uvm_info(get_type_name(), "Connect Phase", UVM_LOW)
   endfunction

   // End of elaboration phase for final setup
   virtual function void end_of_elaboration_phase(uvm_phase phase);
      // Obtain the sequencer from the active agent in the environment
      sequencer_h = env_h.active_agent_h.sequencer_h;
      // Set the sequencer in the base sequence
      base_sequence_h.sequencer_h = sequencer_h;
      `uvm_info(get_type_name(), "End of Elaboration Phase", UVM_LOW)
   endfunction : end_of_elaboration_phase

   // Run phase for executing the test
   virtual task run_phase(uvm_phase phase);
      // Call the base class's run_phase method

      `uvm_info(get_type_name(), "Run phase Started", UVM_LOW)

      super.run_phase(phase);
      
      // Raise an objection to prevent the phase from ending prematurely
      phase.raise_objection(this);

      // Start the base sequence
      base_sequence_h.start(sequencer_h);

      //wait(sequence_item::PREDICTOR_transaction_counter == sequence_item::COMPARATOR_transaction_counter);
      // Drop the objection to allow the phase to end
      phase.drop_objection(this);

      // Display message indicating the run phase completion
      `uvm_info(get_type_name(), "Run phase Finished", UVM_LOW)
   endtask

   // virtual function void show_arb_cfg();
   //       UVM_SEQ_ARB_TYPE cur_arb;
   //    cur_arb = sequencer_h.get_arbitration();
   //    `uvm_info("TEST", $sformatf("Seqr set to %s", cur_arb.name()), UVM_LOW)
   // endfunction

   // Report phase for printing final results
   function void report_phase (uvm_phase phase);
      // Call the base class's report_phase method
      super.report_phase(phase);

      // Display results related to flag assertion/deassertion
      $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------");
      $display("INCORRECT FLAG ASSERTION/DEASSERTION COUNTER = %0d", incorrect_counter);
      $display("CORRECT FLAG ASSERTION/DEASSERTION COUNTER = %0d", correct_counter);
      $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------");
   endfunction 

endclass
