`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2026 06:53:57 PM
// Design Name: 
// Module Name: md5
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: implementation of the Message Digest 5 (MD5) hashing ckt
// when the input ranges from 0000_0000 to 9999_9999
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "defines.vh"

module md5(
    input clk, reset_n,

    input start_i,
    input [$clog2(`PASSWD_RANGE)-1 : 0] lower_bound_i,
    input [0 : 128-1] golden_i,
    input ans_valid_i, // any MD5 instance have cracked the password
    input [5-1 : 0] r_i,
    input [32-1 : 0] k_i,

    output [8*8-1 : 0] passwd_o, // holds cracked password when valid_o is asserted
    output rotate_o,
    output valid_o
);
    // --------------- VARIABLES & SUBMODULES ---------------
    // counters
    reg [$clog2(`PASSWD_RANGE)-1 : 0] current_passwd = 0;
    reg [6-1 : 0] main_loop_counter = 0;
    reg rotate_left_counter = 0;
    reg preprocess_counter = 0;

    // intermediate states
    // hash
    reg [0 : 128-1] hash = 0;

    // hash stored in little endianness to match C endianness
    wire [0:127] hash_le = { hash[24  +: 8], hash[16  +: 8], hash[8   +: 8], hash[0  +: 8],
                             hash[56  +: 8], hash[48  +: 8], hash[40  +: 8], hash[32 +: 8],
                             hash[88  +: 8], hash[80  +: 8], hash[72  +: 8], hash[64 +: 8],
                             hash[120 +: 8], hash[112 +: 8], hash[104 +: 8], hash[96 +: 8]};

    reg [32-1 : 0] a = 0;
    reg [32-1 : 0] b = 0;
    reg [32-1 : 0] c = 0;
    reg [32-1 : 0] d = 0;

    reg [32-1 : 0] f = 0;
    reg [32-1 : 0] g = 0;
    reg [32-1 : 0] w_g = 0; // w[g] (we optimize out the MD5 msg buffer logic (Sw-HW co-design))
    reg [0 : 32-1] rotate_left_buf = 0;

    // converts password from binary to decimal string format
    reg passwd_dec_str_start = 0;
    wire [8*8-1 : 0] passwd_dec_str;
    reg [8*8-1 : 0] passwd_dec_str_reg = 0;
    wire passwd_dec_str_valid;

    integer i;

    // converts password from binary to decimal string format
    bin2dec_str passwd_bin2dec_str (
        .clk(clk), .reset_n(reset_n),

        .start_i(passwd_dec_str_start),
        .bin_i(current_passwd),

        .dec_str_o(passwd_dec_str),
        .valid_o(passwd_dec_str_valid)
    );

    // --------------- END VARIABLES & SUBMODULES ---------------

    // --------------- FSM ---------------
    localparam S_MD5_IDLE = 0;
    localparam S_MD5_PREPROCESS = 1; // reset hash & convert password to decimal string format
    localparam S_MD5_FG = 2; // calculate f, g & fill rotate_left_buf
    localparam S_MD5_ROTATE_LEFT = 3; // rotate left r[i] times
    localparam S_MD5_ABCD = 4; // update a, b, c, d
    localparam S_MD5_COMPUTE_HASH = 5; // update hahs (h0 ~ h3)
    localparam S_MD5_COMPARE = 6; // compare hash to golden & increment current_passwd if unmatched
    localparam S_MD5_DONE = 7; // enters this state as soon as any MD5 instance asserts valid

    reg [3-1 : 0] MD5_state = S_MD5_IDLE;
    reg [3-1 : 0] MD5_n_state;

    always @(posedge clk) begin
        if (~reset_n) MD5_state <= S_MD5_IDLE;
        else MD5_state <= MD5_n_state;
    end

    always @* begin
        case (MD5_state)
            S_MD5_IDLE: MD5_n_state = (start_i)? S_MD5_PREPROCESS : S_MD5_IDLE;
            S_MD5_PREPROCESS: begin
                if (ans_valid_i) MD5_n_state = S_MD5_DONE;
                else if (passwd_dec_str_valid) MD5_n_state = S_MD5_FG; // conversion done
                else MD5_n_state = S_MD5_PREPROCESS;
            end
            S_MD5_FG: begin
                if (ans_valid_i) MD5_n_state = S_MD5_DONE;
                else MD5_n_state = S_MD5_ROTATE_LEFT;
            end
            S_MD5_ROTATE_LEFT: begin
                if (ans_valid_i) MD5_n_state = S_MD5_DONE;
                else if (rotate_left_counter == 1) MD5_n_state = S_MD5_ABCD;
                else MD5_n_state = S_MD5_ROTATE_LEFT;
            end
            S_MD5_ABCD: begin
                if (ans_valid_i) MD5_n_state = S_MD5_DONE;
                else if (main_loop_counter == `RAM_SIZE-1) MD5_n_state = S_MD5_COMPUTE_HASH; // exit main loop
                else MD5_n_state = S_MD5_FG;
            end
            S_MD5_COMPUTE_HASH: begin
                if (ans_valid_i) MD5_n_state = S_MD5_DONE;
                else MD5_n_state = S_MD5_COMPARE;
            end
            S_MD5_COMPARE: begin
                if (ans_valid_i || hash_le == golden_i) MD5_n_state = S_MD5_DONE; // password cracked
                else MD5_n_state = S_MD5_PREPROCESS;
            end
            S_MD5_DONE: MD5_n_state = S_MD5_DONE;
            default: MD5_n_state = S_MD5_IDLE;
        endcase
    end
    // --------------- END FSM ---------------

    // --------------- COUNTERS ---------------
    // current_passwd
    always @(posedge clk) begin
        if (~reset_n) current_passwd <= 0;
        else begin
            case (MD5_state)
                S_MD5_IDLE: current_passwd <= lower_bound_i;
                S_MD5_COMPARE: current_passwd <= current_passwd+1;
            endcase
        end
    end

    // main_loop_counter
    always @(posedge clk) begin
        if (~reset_n) main_loop_counter <= 0;
        else begin
            case (MD5_state)
                S_MD5_PREPROCESS: main_loop_counter <= 0;
                S_MD5_ABCD: main_loop_counter <= main_loop_counter+1;
            endcase
        end
    end

    // rotate_left_counter
    always @(posedge clk) begin
        if (~reset_n) rotate_left_counter <= 0;
        else begin
            case (MD5_state)
                S_MD5_IDLE: rotate_left_counter <= 0;
                S_MD5_FG: rotate_left_counter <= 0;
                S_MD5_ROTATE_LEFT: rotate_left_counter <= rotate_left_counter+1;
            endcase
        end
    end

    // preprocess_counter
    always @(posedge clk) begin
        if (~reset_n) preprocess_counter <= 0;
        else begin
            case (MD5_state)
                S_MD5_IDLE: preprocess_counter <= 0;
                S_MD5_PREPROCESS: preprocess_counter <= (!preprocess_counter)? 1 : preprocess_counter;
                S_MD5_FG: preprocess_counter <= 0;
            endcase
        end
    end
    // --------------- END COUNTERS ---------------

    // --------------- PASSWORD FORMAT CONVERSION ---------------
    // passwd_dec_str_start
    always @* begin
        case (MD5_state)
            S_MD5_PREPROCESS: passwd_dec_str_start = !preprocess_counter; // asserts only at the 1st cycle of the preprocess state
            default: passwd_dec_str_start = 0;
        endcase
    end

    // passwd_dec_str_reg
    always @(posedge clk) begin
        if (~reset_n) passwd_dec_str_reg <= 0;
        else begin
            if (passwd_dec_str_valid) begin
                passwd_dec_str_reg <= passwd_dec_str;
            end
        end
    end
    // --------------- END PASSWORD FORMAT CONVERSION ---------------

    // --------------- INTERMEDIATE STATES ---------------
    // hash (h0, h1, h2, h3)
    always @(posedge clk) begin
        if (~reset_n) hash <= 0;
        else begin
            case (MD5_state)
                S_MD5_IDLE: hash <= 0;
                S_MD5_PREPROCESS: begin // reset hash
                    hash[0  +: 32] <= 32'h67452301; // h0
                    hash[32 +: 32] <= 32'hefcdab89; // h1
                    hash[64 +: 32] <= 32'h98badcfe; // h2
                    hash[96 +: 32] <= 32'h10325476; // h3
                end
                S_MD5_COMPUTE_HASH: begin
                    hash[0  +: 32] <= hash[0  +: 32] + a; // h0 = h0 + a
                    hash[32 +: 32] <= hash[32 +: 32] + b; // h1 = h1 + b
                    hash[64 +: 32] <= hash[64 +: 32] + c; // h2 = h2 + c
                    hash[96 +: 32] <= hash[96 +: 32] + d; // h3 = h3 + d
                end
            endcase
        end
    end

    // a, b, c, d
    always @(posedge clk) begin
        if (~reset_n) begin
            a <= 0;
            b <= 0;
            c <= 0;
            d <= 0;
        end
        else begin
            case (MD5_state)
                S_MD5_IDLE: begin
                    a <= 0;
                    b <= 0;
                    c <= 0;
                    d <= 0;
                end
                S_MD5_PREPROCESS: begin
                    a <= 32'h67452301;
                    b <= 32'hefcdab89;
                    c <= 32'h98badcfe;
                    d <= 32'h10325476;
                end
                S_MD5_ABCD: begin
                    a <= d;
                    b <= b + rotate_left_buf;
                    c <= b;
                    d <= c;
                end
            endcase
        end
    end

    // f, g
    always @(posedge clk) begin
        if (~reset_n) begin
            f <= 0;
            g <= 0;
        end else begin
            case (MD5_state)
                S_MD5_IDLE: begin
                    f <= 0;
                    g <= 0;
                end
                S_MD5_PREPROCESS: begin
                    f <= 0;
                    g <= 0;
                end
                S_MD5_FG: begin
                    case (main_loop_counter[5 : 4]) // 2 MSBs
                        2'b00: begin // 0 ~ 15
                            f <= (b & c) | ((~b) & d);
                            g <= main_loop_counter;
                        end
                        2'b01: begin // 16 ~ 31
                            f <= (d & b) | ((~d) & c);
                            g <= 5*main_loop_counter + 1;
                        end
                        2'b10: begin // 32 ~ 47
                            f <= b ^ c ^ d;
                            g <= 3*main_loop_counter + 5;
                        end
                        2'b11: begin // 48 ~ 63
                            f <= c ^ (b | (~d));
                            g <= 7*main_loop_counter;
                        end
                    endcase
                end
            endcase
        end
    end

    // w_g (we optimize out the MD5 msg buffer logic (SW-HW co-design))
    always @* begin
        case (MD5_state)
            S_MD5_ROTATE_LEFT: begin
                case (g[3 : 0]) // 4 LSBs (mod 16)
                    // w[0] uses message bytes 0..3: reverse dec_str_reg bytes 7..4 into little-endian word
                    0: w_g = {passwd_dec_str_reg[39:32], passwd_dec_str_reg[47:40],
                              passwd_dec_str_reg[55:48], passwd_dec_str_reg[63:56]};
                    // w[1] uses message bytes 4..7: reverse dec_str_reg bytes 3..0 into little-endian word
                    1: w_g = {passwd_dec_str_reg[7:0],   passwd_dec_str_reg[15:8],
                              passwd_dec_str_reg[23:16], passwd_dec_str_reg[31:24]};
                    // 2: w_g = 1 << 31; // append a single '1' bit to the message
                    2: w_g = 32'h0000_0080;
                    // 14: w_g = 1 << 30; // 64 (password length in bits = 8*8)
                    14: w_g = 32'h0000_0040;
                    default: w_g = 0;
                endcase
            end
            default: w_g = 0;
        endcase
    end

    // rotate_left_buf
    always @(posedge clk) begin
        if (~reset_n) rotate_left_buf <= 0;
        else begin
            case (MD5_state)
                S_MD5_IDLE : rotate_left_buf <= 0;
                S_MD5_ROTATE_LEFT: begin
                    if (rotate_left_counter == 0) begin
                        rotate_left_buf <= a + f + k_i + w_g;
                    end else begin
                        // rotate left by r_i
                        for (i = 0; i < 32; i = i + 1) begin
                            rotate_left_buf[i] <= rotate_left_buf[(i + r_i) % 32];
                        end
                    end
                end
            endcase
        end
    end
    // --------------- END INTERMEDIATE STATES ---------------

    // --------------- OUTPUT ---------------
    // passwd_o
    assign passwd_o = passwd_dec_str_reg;

    // rotate_o
    assign rotate_o = (MD5_state == S_MD5_ABCD);

    // valid_o (byte-swap hash to little-endian for comparison with golden)
    assign valid_o = (MD5_state == S_MD5_COMPARE && hash_le == golden_i);
    // --------------- END OUTPUT ---------------
endmodule
