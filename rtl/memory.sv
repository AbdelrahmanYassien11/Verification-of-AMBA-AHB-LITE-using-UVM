
module memory #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, ADDR_DEPTH = 16)
    (
    input logic clk,
    input logic en,
    input logic rst,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic valid
);

// Declare a 2D array of 32-bit words with 16 rows
logic [DATA_WIDTH-1:0] mem [ADDR_DEPTH-1:0];


// Write data to memory when enabled and address is valid
always @(posedge clk) begin
    if (!rst) begin
        mem <= '{default:'h0}; // Reset memory to zero
        data_out <= 'h0; // Reset output data to zero
        valid <= 'h0; // Reset output validity to zero
    end else if (en && (addr < ADDR_DEPTH)) begin // Check enable and address range
        mem[addr] <= data_in; // Assign memory location from input data 
        //data_out <= mem[addr]; // Assign output data from memory location 
        valid <= 'h0; // Set output validity to one 
    end else if((!en) && (addr < ADDR_DEPTH)) begin 
        data_out <= mem[addr]; // Assign output data from memory location 
        valid <= 'h0; // Clear output validity to zero otherwise 
    end
    else begin
        valid <= 'h1;
    end 
end

endmodule