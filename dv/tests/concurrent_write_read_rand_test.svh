/******************************************************************
 * File: concurrent_write_read_rand_test.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This UVM test class configures and executes the 
 *              `concurrent_write_read_rand_sequence` for testing.
 *              It extends the `base_test` class and overrides 
 *              the `build_phase` and `connect_phase` methods.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class concurrent_write_read_rand_test extends base_test;
   `uvm_component_utils(concurrent_write_read_rand_test);

   // Interface instance
   virtual inf my_vif;

   // Constructor for the test class
   function new(string name = "concurrent_write_read_rand_test", uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase for test configuration
   function void build_phase(uvm_phase phase);
      // Override the sequence type used by the base_sequence class
      base_sequence::type_id::set_type_override(concurrent_write_read_rand_sequence::type_id::get());
      // Call the build_phase method of the base class
      super.build_phase(phase);
      $display("my_test build phase");
   endfunction

   // Connect phase for connecting components
   function void connect_phase(uvm_phase phase);
      // Call the connect_phase method of the base class
      super.connect_phase(phase);
      $display("my_test connect phase");
   endfunction

endclass
