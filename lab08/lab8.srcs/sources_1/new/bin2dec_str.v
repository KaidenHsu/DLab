`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 01:11:37 AM
// Design Name: 
// Module Name: bin2dec_str
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


`include "defines.vh"

module bin2dec_str #(
    parameter FIELD_WIDTH = 8
)(
    input clk, reset_n,

    input start_i,
    input [$clog2(`PASSWD_RANGE)-1 : 0] bin_i,

    output [FIELD_WIDTH*8-1 : 0] dec_str_o,
    output valid_o
);
    reg [$clog2(FIELD_WIDTH+3)-1 : 0] counter = 0;

    reg [$clog2(`PASSWD_RANGE)-1 : 0] quotient = 0;
    reg [4-1 : 0] remainder = 0;

    reg [FIELD_WIDTH*8-1 : 0] dec_str = 0;

    genvar idx;



    // counter
    always @(posedge clk) begin
        if (~reset_n) counter <= 0;
        else begin
            if (!counter && start_i) counter <= 1;
            else if (counter) counter <= (counter == FIELD_WIDTH+3)? 0 : counter+1;
        end
    end



    // quotient
    always @(posedge clk) begin
        if (~reset_n) quotient <= 0;
        else begin
            if (start_i) quotient <= bin_i;
            else quotient <= quotient / 10;
        end
    end

    // remainder
    always @(posedge clk) begin
        if (~reset_n) remainder <= 0;
        else begin
            if (counter) remainder <= quotient % 10;
        end
    end

    // dec_str
    always @(posedge clk) begin
        if (~reset_n) dec_str <= 0;
        else begin
            if (counter > 1 && counter <= FIELD_WIDTH+1) begin
                dec_str[8*(counter-2)+7 -: 8] <= remainder + 48; // converts 0-9 to '0'-9'
            end
        end
    end
    


    // dec_str_o
    assign dec_str_o = dec_str;

    // valid_o
    // assign valid_o = (!quotient && remainder);
    assign valid_o = (counter == FIELD_WIDTH+2);
endmodule
