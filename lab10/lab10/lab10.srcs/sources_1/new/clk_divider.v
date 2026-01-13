`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2026 04:21:15 PM
// Design Name: 
// Module Name: clk_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_divider #(
    parameter divider = 16
)(
    input clk, reset,

    output reg clk_out
);
    reg [7:0] counter;

    // counter
    always @(posedge clk) begin
        if (reset) counter <= 0;
        else counter <= (counter == divider-1)? 0 : counter+1;
    end

    // clk_out
    always @(posedge clk) begin
        if (reset) clk_out <= 0;
        else clk_out <= (counter < divider/2)? 1 : 0;
    end
endmodule
