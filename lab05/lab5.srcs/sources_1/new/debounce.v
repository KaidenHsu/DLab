`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2025 01:41:27 PM
// Design Name: 
// Module Name: debounce
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


`define DEBOUNCE_WINDOW 20000000
// `define DEBOUNCE_WINDOW 1000

module debounce(
    input clk,
    input btn_input,

    output btn_output
);
    localparam [1:0] S_IDLE = 0, S_WAITING = 1;
    reg [1:0] S, S_next;
    reg [24:0] counter;

    assign btn_output = (S == S_IDLE && S_next == S_WAITING);

    always @(posedge clk) begin
        S <= S_next;

        case (S)
            S_IDLE: counter <= `DEBOUNCE_WINDOW;
            S_WAITING: counter <= counter - 1;
            default: counter <= `DEBOUNCE_WINDOW;
        endcase
    end

    always @(*) begin
        case (S)
            S_IDLE: begin
                if(btn_input) S_next = S_WAITING;
                else S_next = S_IDLE;
            end
            S_WAITING: begin
                if(counter > 0) S_next = S_WAITING;
                else S_next = S_IDLE;
            end
            default: S_next = S_IDLE;
        endcase
    end
endmodule
