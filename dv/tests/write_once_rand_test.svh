/******************************************************************
 * File: write_once_rand_test.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a UVM test component that 
 *              sets up and executes the `write_once_rand_sequence`.
 *              It extends the `base_test` class and overrides
 *              the `build_phase` to configure the sequence type.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class write_once_rand_test extends base_test;
   `uvm_component_utils(write_once_rand_test);

   // Constructor for the test class
   function new(string name = "write_once_rand_test", uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase where configuration and setup occur
   function void build_phase(uvm_phase phase);
      // Override the type of sequence used by the base_sequence class
      base_sequence::type_id::set_type_override(write_once_rand_sequence::type_id::get());
      // Call the build_phase method of the base class
      super.build_phase(phase);	
   endfunction

endclass
