`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 06:52:38 PM
// Design Name: 
// Module Name: tb_bin2dec_str
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


`define CLK_PRD 10

module tb_bin2dec_str();
    localparam FIELD_WIDTH = 7;

    reg clk, reset_n;

    reg start;
    reg [$clog2(`PASSWD_RANGE)-1 : 0] bin;

    wire [FIELD_WIDTH*8-1 : 0] dec_str;
    wire valid;

    // uut
    bin2dec_str #(
        .FIELD_WIDTH(FIELD_WIDTH)
    ) uut (
        .clk(clk), .reset_n(reset_n),

        .start_i(start),
        .bin_i(bin),

        .dec_str_o(dec_str),
        .valid_o(valid)
    );

    initial begin
        clk = 0;
        forever #(`CLK_PRD/2) clk = ~clk;
    end
    
    initial begin
        start = 0;
        bin = 0;

        // reset ckt
        reset_n = 1;
        #(2*`CLK_PRD)
        reset_n = 0;
        #(2*`CLK_PRD)
        reset_n = 1;
        #(2*`CLK_PRD)

       // validate input for 1 clock period
       @(posedge clk);
       start = 1;
       bin = 1203201;
       @(posedge clk);
       start = 0;
       bin = 0;

        // check answer
        @(valid);
        $display("dec_str = %s", dec_str);

        #(`CLK_PRD) $finish;
    end
endmodule
