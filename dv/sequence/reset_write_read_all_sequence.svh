/******************************************************************
 * File: reset_write_read_all_sequence.sv
 * Author: Abdelrahman Mohamad Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 25/08/2024
 * Description: This class defines a sequence that combines both
 *              write and read operations after a reset. It performs
 *              a complete sequence of writing to and reading from
 *              the FIFO, ensuring all operations are conducted
 *              sequentially.
 * 
 * Copyright (c) 2024 Abdelrahman Mohamad Yassien. All Rights Reserved.
 ******************************************************************/

class reset_write_read_all_sequence extends base_sequence;
  `uvm_object_utils(reset_write_read_all_sequence);

  // Handle to the write_all_sequence instance
  protected write_all_sequence write_all_sequence_h;

  // Handle to the read_all_sequence instance
  protected read_all_sequence read_all_sequence_h;

  // Constructor
  function new(string name = "reset_write_read_all_sequence");
    super.new(name);
  endfunction

  // Pre-body task to initialize sequence handles
  task pre_body();
    super.pre_body();
    // Create instances of the write_all_sequence and read_all_sequence
    write_all_sequence_h = write_all_sequence::type_id::create("write_all_sequence_h");
    read_all_sequence_h = read_all_sequence::type_id::create("read_all_sequence_h");
  endtask : pre_body

  // Main task body to execute the combined write and read sequences
  task body();
    // Start the write_all_sequence to perform multiple write operations
    write_all_sequence_h.start(m_sequencer);

    // Start the read_all_sequence to perform multiple read operations
    read_all_sequence_h.start(m_sequencer);
  endtask : body

endclass
