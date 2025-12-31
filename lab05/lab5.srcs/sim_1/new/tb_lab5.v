`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2025 10:53:33 AM
// Design Name: 
// Module Name: tb_lab5
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


module tb_lab5;
    localparam CLK_PERIOD = 10; // 100 MHz clock

    reg clk;
    reg reset_n;
    reg [3:0] usr_btn;

    wire [3:0] usr_led;
    wire LCD_RS;
    wire LCD_RW;
    wire LCD_E;
    wire [3:0] LCD_D;

    lab5 dut (
        .clk(clk), .reset_n(reset_n),

        .usr_btn(usr_btn),

        .usr_led(usr_led),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_E(LCD_E),
        .LCD_D(LCD_D)
    );

    // clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // basic reset and stimulus
    initial begin
        clk = 0;
        usr_btn = 0;

        // reset
        reset_n = 1;
        #(3*CLK_PERIOD);
        reset_n = 0;
        #(3*CLK_PERIOD);
        reset_n = 1;
    end

    initial begin
        // scroll up -> scroll down
        #50000 
        usr_btn[3] = 1;
        #(30*CLK_PERIOD);
        usr_btn[3] = 0;

        // scroll down -> scroll up
        #10000 
        usr_btn[3] = 1;
        #(30*CLK_PERIOD);
        usr_btn[3] = 0;
    end
endmodule
