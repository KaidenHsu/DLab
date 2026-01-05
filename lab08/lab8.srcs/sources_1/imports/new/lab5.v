`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2025 01:34:09 PM
// Design Name: 
// Module Name: lab5
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


`define LIMIT 1024
`define CLK_PRD 10
`define DSPLY_PRD (7*(10**8)) // 500 for simulation, set to 7*(10**(8)) before demo

module lab5(
    input clk, reset_n,

    input [3:0] usr_btn,

    output [3:0] usr_led,
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
);
    // variables
    // turn off all LEDs
    assign usr_led = 4'b0000;

    wire btn_level, btn_pressed;
    reg prev_btn_level;
    reg [127:0] row_A, row_B;

    reg [11-1 : 0] counter; // universal counter

    reg [0 : `LIMIT] primes; // primes[1024] is a dummy entry
    reg [14-1 : 0] jdx; // use 3 extra bits to prevent unexpected overflow
    reg nxt_idx_found, out_of_bounds;

    reg [10-1 : 0] ans [0 : 200-1];
    reg [8-1 : 0] ans_cnt;

    reg [3*8-1 : 0] ans_hex [0 : 200-1];
    reg [3*8-1 : 0] dsply_buf [0 : 2-1];
    reg [$clog2(`DSPLY_PRD/`CLK_PRD) : 0] display_counter; // periodically referesh the LCD display
    reg [11-1 : 0] second_row_counter; // counter of the second row
    reg wrap_around;
    reg [2-1 : 0] reverse_counter; // a support counter to deal with shifting during reverse

    integer i;

    // submodules
    LCD_module lcd0(
        .clk(clk), .reset(~reset_n),

        .row_A(row_A),
        .row_B(row_B),

        .LCD_E(LCD_E),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_D(LCD_D)
    );
        
    debounce btn_db0(
        .clk(clk),

        .btn_input(usr_btn[3]),

        .btn_output(btn_level)
    );

    // ----------------- FSM -----------------------
    localparam S_IDLE = 0;
    localparam S_SIEVE_INC_JDX = 1;
    localparam S_SIEVE_FIND_NXT_IDX = 2;
    localparam S_WRITE_ANS = 3;
    localparam S_LCD_UP = 4;
    localparam S_LCD_DOWN = 5;

    reg [3-1 : 0] state, n_state;

    always @(posedge clk) begin
        if (~reset_n) state <= S_IDLE;
        else state <= n_state;
    end

    always @* begin
        case (state)
            S_IDLE: n_state = S_SIEVE_INC_JDX;
            S_SIEVE_INC_JDX: begin
                n_state = (jdx >= `LIMIT)? S_SIEVE_FIND_NXT_IDX : S_SIEVE_INC_JDX;
            end
            S_SIEVE_FIND_NXT_IDX: begin
                if (out_of_bounds) n_state = S_WRITE_ANS;
                else if (nxt_idx_found) n_state = S_SIEVE_INC_JDX;
                else n_state = S_SIEVE_FIND_NXT_IDX;
            end
            S_WRITE_ANS: n_state = (counter == `LIMIT)? S_LCD_UP : S_WRITE_ANS;
            S_LCD_UP: n_state = (btn_pressed)? S_LCD_DOWN : S_LCD_UP;
            S_LCD_DOWN: n_state = (btn_pressed)? S_LCD_UP : S_LCD_DOWN;
            default: n_state = S_IDLE;
        endcase
    end
    // ----------------- END FSM -----------------------

    // counter (universal counter)
    always @(posedge clk) begin
        if (~reset_n) counter <= 0;
        else begin
            case (state)
                S_IDLE: counter <= 2; // idx = 2 at the beginning
                S_SIEVE_FIND_NXT_IDX: begin // idx
                    if (counter == `LIMIT) counter <= 2; // start printing
                    else if (!primes[counter]) counter <= counter+1; // continue
                end
                S_SIEVE_INC_JDX: if (jdx >= `LIMIT) counter <= counter+1;
                S_WRITE_ANS: counter <= (counter == `LIMIT)? 1 : counter+1;
                S_LCD_UP: begin
                    if (display_counter == (`DSPLY_PRD/`CLK_PRD) && !btn_pressed) begin
                        counter <= (counter == ans_cnt)? 1 : counter+1;
                    end
                end
                S_LCD_DOWN: begin
                    if (display_counter == (`DSPLY_PRD/`CLK_PRD) && !btn_pressed) begin
                        counter <= (counter == 1)? ans_cnt : counter-1;
                    end
                end
            endcase
        end
    end

    // nxt_idx_found
    always @* begin
        case (state)
            S_SIEVE_FIND_NXT_IDX: begin
                nxt_idx_found = primes[counter];
            end
            default: nxt_idx_found = 0;
        endcase
    end

    // out_of_bounds
    always @* begin
        case (state)
            S_SIEVE_FIND_NXT_IDX: begin
                out_of_bounds = (counter == `LIMIT);
            end
            default: out_of_bounds = 0;
        endcase
    end

    // primes
    always @(posedge clk) begin
        if (~reset_n) primes <= {{(`LIMIT){1'b1}}, 1'b0};
        else begin
            case (state)
                S_IDLE: primes <= {{(`LIMIT){1'b1}}, 1'b0};
                S_SIEVE_INC_JDX: begin
                    // Sieve algorithm
                    if (primes[counter] && jdx >= 0) begin
                        primes[jdx] <= 0;
                    end
                end
            endcase
        end
    end

    // jdx
    always @(posedge clk) begin
        if (~reset_n) jdx <= 0;
        else begin
            case (state)
                S_IDLE: jdx <= 4; // jdx = 2 * 2 at the beginning
                S_SIEVE_INC_JDX: jdx <= jdx + counter;
                S_SIEVE_FIND_NXT_IDX: jdx <= 2 * counter;
            endcase
        end
    end

    // ans
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 200; i=i+1) begin
                ans[i] <= 0;
            end
        end else begin
            case (state)
                S_IDLE: begin
                    for (i = 0; i < 200; i=i+1) begin
                        ans[i] <= 0;
                    end
                end
                S_WRITE_ANS: begin
                    if (primes[counter]) begin
                        ans[ans_cnt] <= counter;
                    end
                end
            endcase
        end
    end

    // ans_cnt
    always @(posedge clk) begin
        if (~reset_n) ans_cnt <= 0;
        else begin
            case (state)
                S_IDLE: ans_cnt <= 0;
                S_WRITE_ANS: begin
                    if (primes[counter]) begin
                        ans_cnt <= ans_cnt + 1;
                    end
                end
            endcase
        end
    end

    // ----------------- OUTPUT -----------------------
    // display_counter (refresh display every DSPLY_PRD seconds)
    always @(posedge clk) begin
        if (~reset_n) display_counter <= 0;
        else begin
            case (state)
                S_LCD_UP, S_LCD_DOWN: begin
                    display_counter <= (display_counter == (`DSPLY_PRD/`CLK_PRD))? 0 : display_counter+1;
                end
                default: display_counter <= 0;
            endcase
        end
    end
    
    // ans_hex
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 200; i=i+1) begin
                ans_hex[i] <= 0;
            end
        end else begin
            case (state)
                S_IDLE: begin
                    for (i = 0; i < 200; i=i+1) begin
                        ans_hex[i] <= 0;
                    end
                end
                S_WRITE_ANS: begin
                    if (counter == `LIMIT-1) begin
                        for (i = 0; i < 200; i=i+1) begin
                            ans_hex[i][3*8-1 -: 8] <= bin2hex(ans[i][9 : 8]);
                            ans_hex[i][2*8-1 -: 8] <= bin2hex(ans[i][7 : 4]);
                            ans_hex[i][1*8-1 -: 8] <= bin2hex(ans[i][3 : 0]);
                        end
                    end else if (counter == `LIMIT) begin // scroll up one number
                        // ans_hex[0 : 198]
                        for (i = 0; i < 199; i=i+1) begin
                            ans_hex[i] <= ans_hex[i+1];
                        end

                        ans_hex[199] <= ans_hex[0];
                    end
                end
                S_LCD_UP: begin
                    if (display_counter == (`DSPLY_PRD/`CLK_PRD-1) || ans_hex[0] == "000" || reverse_counter == 2 || reverse_counter == 3) begin
                        // ans_hex[0 : 198]
                        for (i = 0; i < 199; i=i+1) begin
                            ans_hex[i] <= ans_hex[i+1];
                        end

                        ans_hex[199] <= ans_hex[0];
                    end
                end
                S_LCD_DOWN: begin
                    if (display_counter == (`DSPLY_PRD/`CLK_PRD-1) || ans_hex[0] == "000" || reverse_counter == 2 || reverse_counter == 3) begin
                        ans_hex[0] <= ans_hex[199];

                        // ans_hex[1 : 199]
                        for (i = 1; i < 200; i=i+1) begin
                            ans_hex[i] <= ans_hex[i-1];
                        end
                    end
                end
            endcase
        end
    end

    // prev_btn_level
    always @(posedge clk) begin
        if (~reset_n) prev_btn_level <= 1;
        else prev_btn_level <= btn_level;
    end

    // btn_pressed
    assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);

    // dsply_buf
    always @(posedge clk) begin
        if (~reset_n) begin
            dsply_buf[0] <= 0;
            dsply_buf[1] <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    dsply_buf[0] <= 0;
                    dsply_buf[1] <= 0;
                end
                S_WRITE_ANS: begin
                    if (counter == `LIMIT) begin
                        dsply_buf[0] <= ans_hex[0];
                        dsply_buf[1] <= ans_hex[1];
                    end
                end
                S_LCD_UP: begin
                    if (reverse_counter == 1) begin
                        dsply_buf[1] <= ans_hex[0];
                    end else if (display_counter == (`DSPLY_PRD/`CLK_PRD) && ans_hex[0]) begin
                        dsply_buf[0] <= dsply_buf[1];
                        dsply_buf[1] <= ans_hex[0];
                    end

                    if (wrap_around) begin
                        dsply_buf[1] <= ans_hex[1];
                    end
                end
                S_LCD_DOWN: begin
                    if (reverse_counter == 1) begin
                        dsply_buf[1] <= ans_hex[0];
                    end else if (display_counter == (`DSPLY_PRD/`CLK_PRD) && ans_hex[0]) begin
                        dsply_buf[1] <= ans_hex[0];
                        dsply_buf[0] <= dsply_buf[1];
                    end

                    if (wrap_around) begin
                        dsply_buf[1] <= ans_hex[199];
                    end
                end
            endcase
        end
    end

    // second_row_counter
    always @* begin
        case (state)
            S_LCD_UP: begin
                second_row_counter = (counter == ans_cnt)? 1 : counter+1;
            end
            S_LCD_DOWN: begin
                second_row_counter = (counter == 1)? ans_cnt : counter-1;
            end
            default: second_row_counter = 0;
        endcase
    end

    // wrap_around
    always @* begin
        case (state)
            S_LCD_UP: begin
                wrap_around = (ans_hex[0] == "000" && ans_hex[1] != "000");
            end
            S_LCD_DOWN: begin
                wrap_around = (ans_hex[0] == "000" && ans_hex[199] != "000");
            end
            default: wrap_around = 0;
        endcase
    end
    
    // reverse_counter
    always @(posedge clk) begin
        if (~reset_n) reverse_counter <= 0;
        else begin
            case (state)
                S_LCD_UP, S_LCD_DOWN: begin
                    if (btn_pressed) reverse_counter <= 3;
                    else reverse_counter <= (reverse_counter == 0)? 0 : reverse_counter-1;
                end
            endcase
        end
    end

    // row_A, row_B
    always @* begin
        case (state)
            S_LCD_UP, S_LCD_DOWN: begin
                row_A = {"Prime #", bin2hex(counter[7 : 4]), bin2hex(counter[3 : 0]), " is ", dsply_buf[0]};
                row_B = {"Prime #", bin2hex(second_row_counter[7 : 4]), bin2hex(second_row_counter[3 : 0]), " is ", dsply_buf[1]};
            end
            default: begin
                row_A = "                ";
                row_B = "                ";
            end
        endcase
    end
    // ----------------- END OUTPUT -----------------------

    function [8-1 : 0] bin2hex;
        input [4-1 : 0] bin;

        begin
            bin2hex = (bin > 9)? bin+55 : bin+48;
        end
    endfunction
endmodule
