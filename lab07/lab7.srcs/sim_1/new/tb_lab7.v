`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/09/2026 06:44:15 PM
// Design Name: 
// Module Name: tb_lab7
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

module tb_lab7();
    reg clk, reset_n;
    reg [3:0] usr_btn;
    wire [3:0] usr_led;
    wire LCD_RS, LCD_RW, LCD_E;
    wire [3:0] LCD_D;
    wire uart_rx, uart_tx;

    always #(`CLK_PRD/2) clk = ~clk;

    lab7 u_lab7(
        .clk(clk), .reset_n(reset_n),

        .usr_btn(usr_btn),
        .uart_rx(uart_rx),

        .usr_led(usr_led),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_E(LCD_E),
        .LCD_D(LCD_D),
        .uart_tx(uart_tx)
    );

    // test stimulus
    initial begin
        clk = 0;
        usr_btn = 4'b0000;

        reset_n = 1;
        #(3*`CLK_PRD)
        reset_n = 0;
        #(3*`CLK_PRD)
        reset_n = 1;
        
        #(10*`CLK_PRD)
        usr_btn[1] = 1; // push button 1
        #(20*`CLK_PRD)
        usr_btn[1] = 0; // release button 1
    end
endmodule
