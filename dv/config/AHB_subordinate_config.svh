
`include "AHB_subordinate_defines.vh"
class AHB_SUBORDINATE_config;


  `ifdef HWDATA_WIDTH1024
    parameter DATA_WIDTH = 1024;
    parameter AVAILABLE_SIZES = 8;
  `elsif HWDATA_WIDTH512
    parameter DATA_WIDTH = 512;
    parameter AVAILABLE_SIZES = 7;
  `elsif HWDATA_WIDTH256
    parameter DATA_WIDTH = 256;
    parameter AVAILABLE_SIZES = 6;
  `elsif HWDATA_WIDTH128
    parameter DATA_WIDTH = 128;
    parameter AVAILABLE_SIZES = 5;
  `elsif HWDATA_WIDTH64
    parameter DATA_WIDTH = 64;
    parameter AVAILABLE_SIZES = 4;
  `elsif HWDATA_WIDTH32
    parameter DATA_WIDTH = 32;
    parameter AVAILABLE_SIZES = 3;
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

  parameter ADDR_DEPTH = 256;
  parameter NO_OF_SUBORDINATES = 4;
  parameter BITS_FOR_SUBORDINATES = $clog2(NO_OF_SUBORDINATES+1);


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