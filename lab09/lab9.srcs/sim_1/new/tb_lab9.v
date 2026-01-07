`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2026 11:15:55 PM
// Design Name: 
// Module Name: tb_lab9
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

module tb_lab9();

    reg clk;
    reg reset_n;
    reg [3:0] usr_btn;
    
    wire [3:0] usr_led;
    wire LCD_RS, LCD_RW, LCD_E;
    wire [3:0] LCD_D;
    
    // Instantiate the Unit Under Test (UUT)
    lab9 uut (
        .clk(clk),
        .reset_n(reset_n),
        .usr_btn(usr_btn),
        .usr_led(usr_led),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_E(LCD_E),
        .LCD_D(LCD_D)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(`CLK_PRD/2) clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        usr_btn = 4'b0000;

        reset_n = 1;
        #(`CLK_PRD * 2);
        reset_n = 0;
        #(`CLK_PRD * 2);
        reset_n = 1;
        
        // Wait a few clocks
        #(`CLK_PRD * 5);
        
        // Press button 3 for 50 clock cycles
        usr_btn[3] = 1;
        #(`CLK_PRD * 50);
        usr_btn[3] = 0;
    end
endmodule
