

class AHB_SUBORDINATE_config;




  `ifdef HWDATA_WIDTH32
    parameter DATA_WIDTH = 32;
  `elsif HWDATA_WIDTH64
    parameter DATA_WIDTH = 64;
  `elsif HWDATA_WIDTH128
    parameter DATA_WIDTH = 128;
  `elsif HWDATA_WIDTH256
    parameter DATA_WIDTH = 256;
  `elsif HWDATA_WIDTH512
    parameter DATA_WIDTH = 512;
  `elsif HWDATA_WIDTH1024
    parameter DATA_WIDTH = 1024;
  `else 
    parameter DATA_WIDTH = 32;
  `endif

  `ifdef ADDR_WIDTH10
    parameter ADDR_WIDTH = 10;
  `elsif ADDR_WIDTH32
    parameter ADDR_WIDTH = 32;
  `elsif ADDR_WIDTH64
    parameter ADDR_WIDTH = 64;
  `else 
    parameter ADDR_WIDTH = 32;
  `endif

  parameter ADDR_DEPTH = 32;
  parameter NO_OF_SUBORDINATES = 4;
  parameter BITS_FOR_SUBORDINATES = $clog2(NO_OF_SUBORDINATES);

  // `ifdef ADDR_DEPTH32
  //   parameter ADDR_DEPTH = 32,
  // `elsif ADDR_DEPTH64
  //   parameter ADDR_DEPTH = 64,
  // `elsif ADDR_DEPTH128
  //   parameter ADDR_DEPTH = 128,
  // `elsif ADDR_DEPTH256
  //   parameter ADDR_DEPTH = 256,
  // `elsif ADDR_DEPTH512
  //   parameter ADDR_DEPTH = 512,
  // `elsif ADDR_DEPTH1024
  //   parameter ADDR_DEPTH = 1024,
  // `else 
  //   parameter ADDR_DEPTH = 256
  // `endif
endclass