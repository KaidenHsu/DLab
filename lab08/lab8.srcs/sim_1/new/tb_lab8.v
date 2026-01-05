`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 06:33:02 PM
// Design Name: 
// Module Name: tb_lab8
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

module tb_lab8();
    reg clk, reset_n;
    reg [3:0] usr_btn;

    lab8 uut(
        .clk(clk), .reset_n(reset_n),

        .usr_btn(usr_btn),

        .usr_led(),
        .LCD_RS(),
        .LCD_RW(),
        .LCD_E(),
        .LCD_D()
    );

    initial begin
        clk = 0;
        forever #(`CLK_PRD/2) clk = ~clk;
    end

    initial begin
        usr_btn = 0;

        reset_n = 1;
        #(3*`CLK_PRD)
        reset_n = 0;
        #(3*`CLK_PRD)
        reset_n = 1;
        #(50*`CLK_PRD)

        // press button 3 for 50 clock periods
        usr_btn[3] = 1;
        #(50*`CLK_PRD)
        usr_btn[3] = 0;

        // @(uut.timer_dec_str_valid)
        // @(posedge clk)
        // $strobe("row_A = %s, row_B = %s", uut.row_A, uut.row_B);
        // #(10*`CLK_PRD)
        // $finish;
    end
endmodule
