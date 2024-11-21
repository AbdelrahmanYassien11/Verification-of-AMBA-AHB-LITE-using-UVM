`define HWDATA_WIDTH32
`define ADDR_WIDTH32

  `ifdef HWDATA_WIDTH64
    `define HWDATA_WIDTH32
  `elsif HWDATA_WIDTH128
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
  `elsif HWDATA_WIDTH256
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
  `elsif HWDATA_WIDTH512
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
    `define HWDATA_WIDTH256
  `elsif HWDATA_WIDTH1024
    `define HWDATA_WIDTH32
    `define HWDATA_WIDTH64
    `define HWDATA_WIDTH128
    `define HWDATA_WIDTH256
    `define HWDATA_WIDTH512
  `else 
    `define HWDATA_WIDTH32
  `endif
