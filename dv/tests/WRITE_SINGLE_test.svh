/******************************************************************
 * File: WRITE_SINGLE_test.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM test component that 
 *              sets up and executes the `WRITE_SINGLE_sequence`.
 *              It extends the `base_test` class and overrides
 *              the `build_phase` and `connect_phase` to configure
 *              the sequence type and establish connections.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class WRITE_SINGLE_test extends base_test;
   `uvm_component_utils(WRITE_SINGLE_test);

   // Virtual interface for connecting to the DUT
   virtual inf my_vif;

   // Constructor
   function new(string name = "WRITE_SINGLE_test", uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase where configuration and setup occur
   function void build_phase(uvm_phase phase);
      // Override the type of sequence used by the base_sequence class
      base_sequence::type_id::set_type_override(WRITE_SINGLE_sequence::type_id::get());
      // Call the build_phase method of the base class
      super.build_phase(phase);
      // Display message indicating that the build phase has started
      $display("my_test build phase");
   endfunction

   // Connect phase where connections to interfaces and other components are made
   function void connect_phase(uvm_phase phase);
      // Call the connect_phase method of the base class
      super.connect_phase(phase);
      // Display message indicating that the connect phase has started
      $display("my_test connect phase");
   endfunction

endclass

