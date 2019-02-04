`timescale 1ns / 1ns

module testbench;

parameter PERIOD = 2;	// 500MHz. Use "= 20" to get 50MHz clock frequency

reg clock;
reg reset;
reg we;
reg [31:0] address;
reg [31:0] write_data;
wire [31:0] read_data;
wire [31:0] IO;
wire BAM;

address_space addr_space_inst (.i_clk(clock),
				.i_we(we),
				.i_arst(reset),
				.i_address(address),
				.i_write_data(write_data),
				.o_read_data(read_data),
				.io_IO(IO),
				.bam_output(BAM));

initial begin
#0
	clock = 0;
	forever #(PERIOD/2) clock = ~clock;
end

initial begin
#0
reset = 0;

#5
reset = 1;

#5
reset = 0;

#5
we = 1'b1;

#5
address = 32'b00000000000000000000000010000011;		// DCYCLE register - [131]		
write_data = 32'b00000000000000001000000000000000;	// 50%, 0b1000000000000000

#100
address = 32'b00000000000000000000000010000100;		// CONFIG register - [132]
write_data = 32'b00000000000000000000000000000001;	// 000, 1:1, START

#250000
address = 32'b00000000000000000000000010000100;		// CONFIG register - [132]
write_data = 32'b00000000000000000000000000000000;	// 000, 1:1, STOP

#10
address = 32'b00000000000000000000000010000011;		// DCYCLE register - [131]		
write_data = 32'b00000000000000001010101010101010;	// ~67%, 0b1010101010101010

#100
address = 32'b00000000000000000000000010000100;		// CONFIG register - [132]
write_data = 32'b00000000000000000000000000000011;	// 001, 1:2, START

#265000
$finish;  
end
  
endmodule
