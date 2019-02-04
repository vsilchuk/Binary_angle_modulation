// Module: gpio.v
// Main project: BAM (Binary angle modulation) module for a single-cycle MIPS processor.
// Module description: General purpose input-output module - inout pins and tri-state buffers.
// Author: github.com/vsilchuk

module GPIO(i_clk, i_arst, i_DATA, i_ALT, i_ALT_IN, i_DDIR_WE, o_DIN, i_DIN_RE, i_DOUT_WE, io_IO, BAM_output);

input i_clk;						// Input clock signal
input i_arst;						// Reset
input [31:0] i_DATA;					// Input data 
input i_ALT;						// Work enable flag for alternative data source as output
input i_ALT_IN;						// Alternative data source for output (BAM signal)
input i_DDIR_WE;					// WE signal for the DDIR register
input i_DOUT_WE;					// WE signal for the DOUT register
input i_DIN_RE;						// Read enable
output reg [31:0] o_DIN;				// Read data to MIPS
inout [31:0] io_IO;					// Inout pins

output BAM_output;
assign BAM_output = (i_ALT) ? i_ALT_IN : 1'bz;		// Separate pin for the alternative data output

reg [31:0] DDIR;					// 1: io_IO <=> i_DOUT, 0: "Z" state
reg [31:0] DOUT;				

genvar g_cnt;				
generate 
	for(g_cnt = 0; g_cnt < 32; g_cnt = g_cnt + 1) begin: GPIO_z
		assign io_IO[g_cnt] = (DDIR[g_cnt]) ? DOUT[g_cnt] : 1'bz;	// Tri-state buffers behaviour
end
endgenerate

always @(posedge i_clk, posedge i_arst) begin		// DDIR behaviour
	if(i_arst) begin
		DDIR <= 32'd0;
	end else begin
		if(i_DDIR_WE) begin
			DDIR <= i_DATA;
		end else begin
			DDIR <= DDIR;
		end
	end
end

always @(posedge i_clk, posedge i_arst) begin		// DOUT behaviour
	if(i_arst) begin
		DOUT <= 32'd0;
	end else begin
		if(i_DOUT_WE) begin
			DOUT <= i_DATA;
		end else begin
			DOUT <= DOUT;
		end
	end
end

always @(posedge i_clk, posedge i_arst) begin		// DIN behaviour
	if(i_arst) begin
		o_DIN <= 32'd0;
	end else begin
		if(i_DIN_RE) begin
			o_DIN <= io_IO;
		end else begin
			o_DIN <= o_DIN;
		end
	end
end
endmodule 