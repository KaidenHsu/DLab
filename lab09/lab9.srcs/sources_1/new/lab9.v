`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2026 03:14:01 PM
// Design Name: 
// Module Name: lab9
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


`define POS_RANGE 959 // the max value of the current position
`define CORR_WINDOW 64

module lab9(
    input clk, reset_n,

    input [3:0] usr_btn,

    output [3:0] usr_led,
    // 1602 LCD Module Interface
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
);
    // debounce, one-pulse, LEDs
    wire [4-1 : 0] debounced_btn;
    wire [4-1 : 0] one_pulsed_btn;
    assign usr_led = usr_btn;

    // declare SRAM control signals
    wire        sram_we, sram_en;
    wire [10:0] sram_addr;
    wire [7:0]  data_in;
    wire [7:0]  data_out;

    reg [7-1 : 0] corr_counter = 0;
    reg [$clog2(1087)-1 : 0] curr_pos = 0; // current position 

    reg signed [8-1 : 0] f [0 : `CORR_WINDOW-1]; // buffer the current processing window of f
    reg signed [8-1 : 0] g [0 : `CORR_WINDOW-1]; // the correlation filter

    // the correlation result of the current processing window
    // added log64 = 6 guard bits
    reg signed [8+8+6-1 : 0] corr = 0;

    reg [3*4-1 : 0] max_pos = 0;
    reg signed [6*4-1 : 0] max_val = 0;

    // format conversion
    wire [3*8-1 : 0] max_pos_hex_str;
    wire [6*8-1 : 0] max_val_hex_str;

    // LCD display buffers
    reg [128-1 : 0] row_A = "Press BTN0 to do";
    reg [128-1 : 0] row_B = "x-correlation...";

    integer i;
    genvar idx;

    initial begin
        for (i = 0; i < `CORR_WINDOW; i=i+1) begin
            f[i] = 0;
            g[i] = 0;
        end
    end

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



    // ------------------------------------------------------------------------
    // An initialized SRAM memory block storing 1024+64 8-bit signed data samples.
    sram ram0(
        .clk(clk),

        .we(sram_we), .en(sram_en),
        .addr(sram_addr), .data_i(data_in),

        .data_o(data_out)
    );

    assign sram_addr = curr_pos;
    assign data_in = 8'b0; // SRAM is read-only so we tie inputs to zeros.
    // End of the SRAM memory block.
    // ------------------------------------------------------------------------

    // --------------- FSM ---------------
    localparam S_IDLE = 0;
    localparam S_WAIT_G = 1;
    localparam S_READ_G = 2;
    localparam S_WAIT_F = 3;
    localparam S_READ_F = 4;
    localparam S_COMPUTE_CORR = 5;
    localparam S_COMPARE = 6;
    localparam S_LCD = 7;
    localparam S_DONE = 8;

    reg [4-1 : 0] state = S_IDLE;
    reg [4-1 : 0] n_state;

    always @(posedge clk) begin
        if (~reset_n) state <= S_IDLE;
        else state <= n_state;
    end

    always @* begin
        case (state)
            S_IDLE: n_state = S_WAIT_G;
            S_WAIT_G: n_state = S_READ_G;
            S_READ_G: n_state = (curr_pos == 1087)? S_WAIT_F : S_READ_G;
            S_WAIT_F: n_state = S_READ_F;
            S_READ_F: n_state = (curr_pos == 63)? S_COMPUTE_CORR : S_READ_F;
            S_COMPUTE_CORR: n_state = (corr_counter == 63)? S_COMPARE : S_COMPUTE_CORR;
            S_COMPARE: n_state = (curr_pos == 1024)? S_LCD : S_COMPUTE_CORR;
            S_LCD: n_state = S_DONE;
            S_DONE: n_state = S_DONE;
            default: n_state = S_IDLE;
        endcase
    end
    // --------------- END FSM ---------------
    
    // In this demo, we do not write the SRAM. However,
    // if you set 'we' to 0, Vivado fails to synthesize
    // ram0 into BRAM -- this is a bug in Vivado.
    // sram_we
    assign sram_we = (state == S_DONE);

    // sram_en
    assign sram_en = (state == S_READ_G || state == S_READ_F || state == S_COMPUTE_CORR || state == S_COMPARE);


    // corr_counter
    always @(posedge clk) begin
        if (~reset_n) corr_counter <= 0;
        else begin
            case (state)
                S_IDLE: corr_counter <= 0;
                S_READ_F: corr_counter <= 0;
                S_COMPUTE_CORR: corr_counter <= corr_counter+1;
                S_COMPARE: corr_counter <= 0;
            endcase
        end
    end

    // curr_pos
    always @(posedge clk) begin
        if (~reset_n) curr_pos <= 1024;
        else begin
            case (state)
                S_IDLE: curr_pos <= 1024;
                S_WAIT_G: curr_pos <= curr_pos+1;
                S_READ_G: curr_pos <= (curr_pos == 1087)? 0 : curr_pos+1;
                S_WAIT_F: curr_pos <= curr_pos+1;
                S_READ_F: curr_pos <= curr_pos+1;
                S_COMPARE: curr_pos <= curr_pos+1;
            endcase
        end
    end

    // f
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < `CORR_WINDOW; i=i+1) begin
                f[i] <= 0;
            end
        end else begin
            case (state)
                S_IDLE: begin
                    for (i = 0; i < `CORR_WINDOW; i=i+1) begin
                        f[i] <= 0;
                    end
                end
                S_READ_F, S_COMPARE: begin
                        for (i = 0; i < `CORR_WINDOW-1; i=i+1) begin
                            f[i] <= f[i+1];
                        end

                        f[`CORR_WINDOW-1] <= data_out;
                end
            endcase
        end
    end

    // g
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < `CORR_WINDOW; i=i+1) begin
                g[i] <= 0;
            end
        end else begin
            case (state)
                S_IDLE: begin
                    for (i = 0; i < `CORR_WINDOW; i=i+1) begin
                        g[i] <= 0;
                    end
                end
                S_READ_G, S_WAIT_F: begin
                    for (i = 0; i < `CORR_WINDOW-1; i=i+1) begin
                        g[i] <= g[i+1];
                    end

                    g[`CORR_WINDOW-1] <= data_out;
                end
            endcase
        end
    end

    // corr
    always @(posedge clk) begin
        if (~reset_n) corr <= 0;
        else begin
            case (state)
                S_IDLE: corr <= 0;
                S_READ_F: corr <= 0;
                S_COMPUTE_CORR: corr <= corr + f[corr_counter]*g[corr_counter];
                S_COMPARE: corr <= 0;
            endcase
        end
    end

    // max_pos
    always @(posedge clk) begin
        if (~reset_n) max_pos <= 0;
        else begin
            case (state)
                S_IDLE: max_pos <= 0;
                S_COMPARE: begin
                    if (corr > max_val) begin
                        max_pos <= curr_pos-64;
                    end
                end
            endcase
        end
    end

    // max_val
    always @(posedge clk) begin
        if (~reset_n) max_val <= {1'b1, {23{1'b0}}};
        else begin
            case (state)
                S_IDLE: max_val <= {1'b1, {23{1'b0}}};
                S_COMPARE: begin
                    if (corr > max_val) begin
                        max_val <= corr;
                    end
                end
            endcase
        end
    end


    // --------------- OUTPUT ---------------
    // max_pos_hex_str
    assign max_pos_hex_str = {
        bin2hex_char(max_pos[3*4-1 -: 4]),
        bin2hex_char(max_pos[2*4-1 -: 4]),
        bin2hex_char(max_pos[1*4-1 -: 4])
    };

    // max_val_hex_str
    assign max_val_hex_str = {
        bin2hex_char(max_val[6*4-1 -: 4]),
        bin2hex_char(max_val[5*4-1 -: 4]),
        bin2hex_char(max_val[4*4-1 -: 4]),
        bin2hex_char(max_val[3*4-1 -: 4]),
        bin2hex_char(max_val[2*4-1 -: 4]),
        bin2hex_char(max_val[1*4-1 -: 4])
    };

    // row_A, row_B (LCD display buffers)
    always @(posedge clk) begin
        if (~reset_n) begin
            // Initialize the text when the user hits the reset button
            row_A <= "Press BTN0 to do";
            row_B <= "x-correlation...";
        end else begin
            if (state == S_LCD) begin
                row_A <= {"Max value ", max_val_hex_str};
                row_B <= {"Max location ", max_pos_hex_str};
            end else if (one_pulsed_btn[3]) begin
                row_A <= "Computing       ";
                row_B <= "x-correlation...";
            end
        end
    end
    // --------------- END OUTPUT ---------------

    function [8-1 : 0] bin2hex_char;
        input [4-1 : 0] bin;
        begin
            bin2hex_char = (bin < 10)? bin+48 : bin+55;
        end
    endfunction
endmodule
