// Module: data_memory.v
// Main project: BAM (Binary angle modulation) module for a single-cycle MIPS processor.
// Module description: Data memory (RAM) module for MIPS, 128 x 32-bit cells by default parameters.
// Author: github.com/vsilchuk

module data_memory(i_clk, i_we, i_arst, i_address, i_write_data, o_read_data);

parameter DATA_WIDTH = 32;					// 32-bit data
parameter ADDR_WIDTH = 32;					// 32-bit address, 2^32 = 4294967296 possible cells addresses
parameter CELLS_NUMBER = 128;					// 128 cells in this RAM, with indexes from [0] to [127]

input i_clk;							// Input clock signal, 50MHz system clock on Altera DE2 FPGA board, for example
input i_we;							// Write enable signal from Control Unit module
input i_arst;							// Reset
input [ADDR_WIDTH-1:0] i_address;				// 32-bit address for writing/reading into/from
input [DATA_WIDTH-1:0] i_write_data;				// 32-bit data for writing into data memory at the cell with address i_address, using i_we signal and positive edge of i_clk for writing
output wire [DATA_WIDTH-1:0] o_read_data;			// Output 32-bit data, storaged in the cell with i_address

reg [DATA_WIDTH-1:0] data_mem [CELLS_NUMBER-1:0];		// 128 x 32-bit cells in array data_mem

parameter [DATA_WIDTH-1:0] DEFAULT_DATA = {DATA_WIDTH{1'b0}};	// Default data is zero

integer i;

initial begin
	for(i = 0; i < CELLS_NUMBER; i = i + 1) begin
		data_mem[i] = DEFAULT_DATA;			// Filling with zeros
	end
end

assign o_read_data = (i_address < CELLS_NUMBER) ? data_mem[i_address] : DEFAULT_DATA;	// Asynchronous reading 

always @(posedge i_clk, posedge i_arst) begin
	if(i_arst) begin
		for(i = 0; i < CELLS_NUMBER; i = i + 1) begin
			data_mem[i] = DEFAULT_DATA;		// If RESET signal is active - filling with zeros 
		end
	end else if(i_we) begin	
		if(i_address < CELLS_NUMBER) begin
			data_mem[i_address] <= i_write_data;	// Write i_write_data to the data_mem, if i_address is in possible indexes range
		end else begin					
			for(i = 0; i < CELLS_NUMBER; i = i + 1) begin
				data_mem[i] <= data_mem[i];	
			end					
		end	
	end else begin 
		for(i = 0; i < CELLS_NUMBER; i = i + 1) begin
			data_mem[i] <= data_mem[i];		// Just save the state, if i_we && i_arst == 0
		end
	end
end
endmodule

		