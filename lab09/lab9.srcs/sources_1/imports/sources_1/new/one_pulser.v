`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2026 09:24:10 PM
// Design Name: 
// Module Name: one_pulser
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


module one_pulser(
    input clk, rst,

    input btn_input,

    output btn_output
);
    reg prev_btn_level;

    always @(posedge clk) begin
        if (rst) prev_btn_level  <= 0;
        else prev_btn_level <= prev_btn_level;
    end

    assign btn_output = (btn_input == 1 && prev_btn_level == 0);
endmodule
