`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2026 11:36:00 AM
// Design Name: 
// Module Name: lab8
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

module lab8(
    input clk, reset_n,

    input [3:0] usr_btn,

    output [3:0] usr_led,
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
);
    // --------------- VARIABLES & SUBMODULES ---------------
    wire [4-1 : 0] debounced_btn;
    wire [4-1 : 0] one_pulsed_btn;

    wire [8*8-1 : 0] passwd_arr [0 : `HASHERS-1];
    wire [0 : `HASHERS-1] rotate_arr;
    wire [0 : `HASHERS-1] valid_arr;
    reg [0 : 128-1] passwd_hash = 128'hE9982EC5CA981BD365603623CF4B2277; // golden
    // reg [0 : 128-1] passwd_hash = 128'hb684c3e50210eefca8494574456dd36f; // 32
        

    wire md5_start;

    reg [8*8-1 : 0] ans = 0; // the cracked password
    wire ans_valid = |valid_arr;

    wire [5-1 : 0] r;
    wire [32-1 : 0] k;

    reg [$clog2(`MAX_TIME)-1 : 0] timer = 0; // keep time
    reg [$clog2(10**5)-1 : 0] time_conversion_counter = 0;

    wire [7*8-1 : 0] timer_dec_str;
    wire timer_dec_str_valid;

    // 1st & 2nd row of LCD display buffer (16 characters each)
    reg [128-1 : 0] row_A = "Push button 3 to";
    reg [128-1 : 0] row_B = "crack password. ";

    integer i;
    genvar idx;

    // LCD
    LCD_module lcd0(
        .clk(clk), .reset(~reset_n),
        .row_A(row_A), .row_B(row_B),
        .LCD_E(LCD_E), .LCD_RS(LCD_RS), .LCD_RW(LCD_RW), .LCD_D(LCD_D)
    );


    // debounce and one-pulse all buttons
    generate
        for (idx = 0; idx < 4; idx = idx + 1) begin
            debounce u_db (
                .clk       (clk),
                .btn_input (usr_btn[idx]),
                .btn_output(debounced_btn[idx])
            );

            one_pulser u_op (
                .clk       (clk),
                .rst       (~reset_n),
                .btn_input (debounced_btn[idx]),
                .btn_output(one_pulsed_btn[idx])
            );
        end
    endgenerate

    assign usr_led = usr_btn;

    // md5 password hasher
    generate
        for (idx = 0; idx < `HASHERS; idx=idx+1) begin: genloop
            md5 md5(
                .clk(clk), .reset_n(reset_n),

                .start_i(md5_start),
                .lower_bound_i(idx*(`PASSWD_RANGE/`HASHERS)),
                .golden_i(passwd_hash),
                .ans_valid_i(ans_valid),
                .r_i(r),
                .k_i(k),

                .passwd_o(passwd_arr[idx]),
                .rotate_o(rotate_arr[idx]),
                .valid_o(valid_arr[idx])
            );
        end
    endgenerate

    // r, k RAM
    rkRAM rkRAM (
        .clk(clk), .reset_n(reset_n),

        .rotate_i(rotate_arr[0]), // all rotate_arr signals should be in sync

        .r_o(r), .k_o(k)
    );

    // convert the timer to decimal string for LCD display
    bin2dec_str #(
        .FIELD_WIDTH(7) // timer field width
    ) timer_bin2dec_str (
        .clk(clk), .reset_n(reset_n),

        .start_i(ans_valid),
        .bin_i({{($clog2(`PASSWD_RANGE)-$clog2(`MAX_TIME)){1'b0}}, timer}),

        .dec_str_o(timer_dec_str),
        .valid_o(timer_dec_str_valid)
    );

    // --------------- END VARIABLES & SUBMODULES ---------------



    // --------------- FSM ---------------
    localparam S_IDLE = 0;
    localparam S_WAIT_BTN = 1; // wait for button3 press
    localparam S_MAIN_LOOP = 2;
    localparam S_DISPLAY = 3;
    
    reg [2-1 : 0] state = S_IDLE;
    reg [2-1 : 0] n_state;

    always @(posedge clk) begin
        if (~reset_n) state <= S_IDLE;
        else state <= n_state;
    end

    always @* begin
        case (state)
            S_IDLE: n_state = S_WAIT_BTN;
            S_WAIT_BTN: n_state = (one_pulsed_btn[3])? S_MAIN_LOOP : S_WAIT_BTN;
            S_MAIN_LOOP: n_state = (ans_valid)? S_DISPLAY : S_MAIN_LOOP;
            S_DISPLAY: n_state = S_DISPLAY;
            default: n_state = S_IDLE;
        endcase
    end
    // --------------- END FSM ---------------



    assign md5_start = (state == S_WAIT_BTN && one_pulsed_btn[3]);

    // ans
    always @(posedge clk) begin
        if (~reset_n) ans <= 0;
        else begin
            case (state)
                S_IDLE: ans <= 0;
                S_MAIN_LOOP: begin
                    if (ans_valid) begin
                        case (valid_arr)
                            10'b1000000000: ans <= passwd_arr[0];
                            10'b0100000000: ans <= passwd_arr[1];
                            10'b0010000000: ans <= passwd_arr[2];
                            10'b0001000000: ans <= passwd_arr[3];
                            10'b0000100000: ans <= passwd_arr[4];
                            10'b0000010000: ans <= passwd_arr[5];
                            10'b0000001000: ans <= passwd_arr[6];
                            10'b0000000100: ans <= passwd_arr[7];
                            10'b0000000010: ans <= passwd_arr[8];
                            10'b0000000001: ans <= passwd_arr[9];
                        endcase
                    end
                end
            endcase
        end
    end
    
    // timer
    always @(posedge clk) begin
        if (~reset_n) timer <= 0;
        else begin
            if (one_pulsed_btn[3]) timer <= 0; // start timer as soon as button 3 is pressed
            else if (timer == `MAX_TIME) timer <= `MAX_TIME;
            else if (time_conversion_counter == 10**5) timer <= timer+1;
        end
    end

    // time_conversion_counter
    always @(posedge clk) begin
        if (~reset_n) time_conversion_counter <= 0;
        else begin
            if (one_pulsed_btn[3]) time_conversion_counter <= 0; // start timer as soon as button 3 is pressed
            else time_conversion_counter <= (time_conversion_counter == 10**5)? 0 : time_conversion_counter+1; // 1ms / 10^(-8) = 10^5
        end
    end

    // --------------- OUTPUT ---------------
    // row_A, row_B (LCD display buffers)
    always @(posedge clk) begin
        if (~reset_n) begin
            // Initialize the text when the user hits the reset button
            row_A <= "Push button 3 to";
            row_B <= "crack password. ";
        end else begin
            if (timer_dec_str_valid) begin
                row_A <= {"Passwd: ", ans};
                row_B <= {"Time: ", timer_dec_str, " ms"};
            end else if (one_pulsed_btn[3]) begin
                row_A <= "Cracking        ";
                row_B <= "Password ...    ";
            end
        end
    end
    // --------------- END OUTPUT ---------------
endmodule
