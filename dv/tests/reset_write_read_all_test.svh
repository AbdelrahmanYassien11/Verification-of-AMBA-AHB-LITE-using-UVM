/******************************************************************
 * File: reset_write_read_all_test.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM test component that 
 *              sets up and executes the `reset_write_read_all_sequence`.
 *              It extends the `base_test` class and overrides
 *              the `build_phase`, `connect_phase`, and `report_phase`
 *              to configure the sequence type, establish connections,
 *              and handle reporting.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class reset_write_read_all_test extends base_test;
   `uvm_component_utils(reset_write_read_all_test);

   // Virtual interface for the test
   virtual inf my_vif;

   // Constructor for the test class
   function new(string name = "reset_write_read_all_test", uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase where configuration and setup occur
   function void build_phase(uvm_phase phase);
      // Override the type of sequence used by the base_sequence class
      base_sequence::type_id::set_type_override(reset_write_read_all_sequence::type_id::get());
      // Call the build_phase method of the base class
      super.build_phase(phase);
      // Display a message indicating the build phase of the test
      $display("my_test build phase");
   endfunction

   // Connect phase where connections are made
   function void connect_phase(uvm_phase phase);
      // Call the connect_phase method of the base class
      super.connect_phase(phase);
      // Display a message indicating the connect phase of the test
      $display("my_test connect phase");
   endfunction

   // Report phase where test reports and results are handled
   function void report_phase(uvm_phase phase);
      // Call the report_phase method of the base class
      super.report_phase(phase);
   endfunction

endclass
