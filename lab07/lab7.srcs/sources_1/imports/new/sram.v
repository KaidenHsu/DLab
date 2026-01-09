`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/06 20:47:51
// Design Name: 
// Module Name: sram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// This module show you how to infer an initialized SRAM block
// in your circuit using the standard Verilog code.  The initial
// values of the SRAM cells is defined in the text file "signals.dat"
// Each line defines a cell value. The number of data in signals.dat
// must match the size of the sram block exactly.
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sram #(
	parameter DATA_WIDTH = 8, ADDR_WIDTH = 5, RAM_SIZE = 32
)(
	input clk, 
	input we, en,
	input [ADDR_WIDTH-1 : 0] addr,
	input [DATA_WIDTH-1 : 0] data_i,

	output reg [DATA_WIDTH-1 : 0] data_o
);
	// Declareation of the memory cells
	reg [DATA_WIDTH-1 : 0] RAM [0 : RAM_SIZE-1];

	// SRAM cell initialization
	initial begin
		// $readmemh is only synthesizable in FPGAs
		$readmemh("matrix.mem", RAM);
	end

	// SRAM read operation
	always @(posedge clk) begin
		if (en & we) data_o <= data_i;
		else data_o <= RAM[addr];
	end

	// SRAM write operation
	always @(posedge clk) begin
		if (en & we) RAM[addr] <= data_i;
	end
endmodule
