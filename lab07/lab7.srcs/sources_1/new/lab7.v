`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 10:21:47 PM
// Design Name: 
// Module Name: lab7
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


module lab7(
    input clk, reset_n,

    input [3:0] usr_btn,
    input uart_rx,

    output [3:0] usr_led,
    output uart_tx
);
    // --------------- VARIABLES & SUBMODULES ---------------
    localparam INIT_DELAY = 100_000; // 1 msec @ 100 MHz

    // "The result is:" => 14 chars
    // 4 rows x (30 chars/row) => 120 chars
    // 6 <Enter>'s (CR + LF) => 12 chars
    // termination character 8'h0 => 1 char
    // total = 14 + 120 + 12 + 1 = 147 chars
    localparam MEM_SIZE = 147;

    wire [4-1 : 0] debounced_btn;
    wire [4-1 : 0] one_pulsed_btn;
    assign usr_led = usr_btn;

    // uart
    wire transmit;
    wire received;

    wire [8-1 : 0] rx_byte;
    reg  [8-1 : 0] rx_temp;
    wire [8-1 : 0] tx_byte;

    wire is_receiving;
    wire is_transmitting;
    wire recv_error;

    wire print_enable, print_done;
    reg  [8-1 : 0] print_buf [0 : MEM_SIZE-1];
    reg [$clog2(MEM_SIZE):0] send_counter;

    // counters
    reg [2-1 : 0] curr_col;
    reg [5-1 : 0] counter;

    // SRAM control signals
    wire sram_we, sram_en;
    reg  [5-1 : 0] sram_addr;
    wire [8-1 : 0] data_out;

    // intermediate registers
    reg [8-1 : 0] a [0 : 4-1][0 : 4-1]; // buffer the entire a matrix
    reg [8-1 : 0] b [0 : 4-1]; // buffer the current col of b
    reg [18-1 : 0] t [0 : 4-1]; // pipeline registers t
    reg [18-1 : 0] c [0 : 4-1][0 : 4-1]; // ans

    integer i, j;
    genvar idx;

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

    // uart
    /* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
    uart_teacher uart(
        .clk(clk), .rst(~reset_n),

        .rx(uart_rx),
        .transmit(transmit),
        .tx_byte(tx_byte),

        .tx(uart_tx),
        .received(received),
        .rx_byte(rx_byte),
        .is_receiving(is_receiving),
        .is_transmitting(is_transmitting),
        .recv_error(recv_error)
    );

    // sram
    sram ram0(
        .clk(clk),

        .we(sram_we), .en(sram_en),
        .addr(sram_addr), .data_i(8'b0),

        .data_o(data_out)
    );

    assign sram_we = 0;
    assign sram_en = 1;
    // --------------- END VARIABLES & SUBMODULES ---------------



    // --------------- main FSM ---------------
    localparam S_MAIN_IDLE = 0;
    localparam S_MAIN_PREP_A_ADDR = 1;
    localparam S_MAIN_LOAD_A = 2;
    localparam S_MAIN_PREP_B_ADDR = 3;
    localparam S_MAIN_LOAD_B = 4;
    localparam S_MAIN_COL_MULT = 5;
    localparam S_MAIN_COL_ADD = 6;
    localparam S_MAIN_UART = 7;
    localparam S_MAIN_DONE = 8;

    reg [4-1 : 0] state = S_MAIN_IDLE;
    reg [4-1 : 0] n_state;

    always @(posedge clk) begin
        if (~reset_n) state <= S_MAIN_IDLE;
        else state <= n_state;
    end
    
    always @* begin
        case (state)
            S_MAIN_IDLE: n_state = (one_pulsed_btn[1])? S_MAIN_PREP_A_ADDR : S_MAIN_IDLE;
            S_MAIN_PREP_A_ADDR: n_state = (counter)? S_MAIN_LOAD_A : S_MAIN_PREP_A_ADDR;
            S_MAIN_LOAD_A: n_state = (counter == 15)? S_MAIN_PREP_B_ADDR : S_MAIN_LOAD_A;
            S_MAIN_PREP_B_ADDR: n_state = (counter)? S_MAIN_LOAD_B : S_MAIN_PREP_B_ADDR;
            S_MAIN_LOAD_B: n_state = (counter == 3)? S_MAIN_COL_MULT : S_MAIN_LOAD_B;
            S_MAIN_COL_MULT: n_state = S_MAIN_COL_ADD;
            S_MAIN_COL_ADD: n_state = (curr_col == 3)? S_MAIN_UART : S_MAIN_LOAD_B;
            S_MAIN_UART: n_state = (print_done)? S_MAIN_DONE : S_MAIN_UART;
            S_MAIN_DONE: n_state = S_MAIN_DONE;
            default: n_state = S_MAIN_IDLE;
        endcase
    end
    // --------------- END main FSM ---------------

    // curr_col
    always @(posedge clk) begin
        if (~reset_n) curr_col <= 0;
        else begin
            case (state)
                S_MAIN_IDLE: curr_col <= 0;
                S_MAIN_COL_ADD: curr_col <= curr_col+1;
            endcase
        end
    end

    // counter
    always @(posedge clk) begin
        if (~reset_n) counter <= 0;
        else begin
            case (state)
                S_MAIN_IDLE: counter <= 0;
                S_MAIN_PREP_A_ADDR: counter <= (counter)? 0 : 1;
                S_MAIN_LOAD_A: counter <= (counter == 15)? 0 : counter+1;
                S_MAIN_PREP_B_ADDR: counter <= (counter)? 0 : 1;
                S_MAIN_LOAD_B: counter <= (counter == 3)? 0 : counter+1;
            endcase
        end
    end

    // sram_addr
    always @(posedge clk) begin
        if (~reset_n) sram_addr <= 0;
        else begin
            case (state)
                S_MAIN_IDLE: sram_addr <= 0;
                S_MAIN_PREP_A_ADDR: if (counter) sram_addr <= sram_addr+1;
                S_MAIN_LOAD_A: if (sram_addr < 16) sram_addr <= sram_addr+1;
                S_MAIN_PREP_B_ADDR: if (counter) sram_addr <= sram_addr+1;
                S_MAIN_LOAD_B: if (counter != 3) sram_addr <= sram_addr+1;
                S_MAIN_COL_ADD: sram_addr <= sram_addr+1;
            endcase
        end
    end

    // a
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 4; i=i+1) begin
                for (j = 0; j < 4; j=j+1) begin
                    a[i][j] <= 0;
                end
            end
        end else begin
            case (state)
                S_MAIN_IDLE: begin
                    for (i = 0; i < 4; i=i+1) begin
                        for (j = 0; j < 4; j=j+1) begin
                            a[i][j] <= 0;
                        end
                    end
                end
                S_MAIN_LOAD_A: a[counter[1 : 0]][counter[3 : 2]] <= data_out;
            endcase
        end
    end

    // b
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 4; i=i+1) begin
                b[i] <= 0;
            end
        end else begin
            case (state)
                S_MAIN_IDLE: begin
                    for (i = 0; i < 4; i=i+1) begin
                        b[i] <= 0;
                    end
                end
                S_MAIN_LOAD_B: b[counter] <= data_out;
            endcase
        end
    end

    // t
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 4; i=i+1) begin
                t[i] <= 0;
            end
        end else begin
            case (state)
                S_MAIN_IDLE: begin
                    for (i = 0; i < 4; i=i+1) begin
                        t[i] <= 0;
                    end
                end
                S_MAIN_COL_MULT: begin
                    for (i = 0; i < 4; i=i+1) begin
                        t[i] <= a[i][0]*b[0] + a[i][1]*b[1] + a[i][2]*b[2] + a[i][3]*b[3];
                    end
                end
            endcase
        end
    end

    // c
    always @(posedge clk) begin
        if (~reset_n) begin
            for (i = 0; i < 4; i=i+1) begin
                for (j = 0; j < 4; j=j+1) begin
                    c[i][j] <= 0;
                end
            end
        end else begin
            case (state)
                S_MAIN_IDLE: begin
                    for (i = 0; i < 4; i=i+1) begin
                        for (j = 0; j < 4; j=j+1) begin
                            c[i][j] <= 0;
                        end
                    end
                end
                S_MAIN_COL_ADD: begin
                    for (i = 0; i < 4; i=i+1) begin
                        c[i][curr_col] <= t[i];
                    end
                end
            endcase
        end
    end

    // print_buf
    always @* begin
        // header "The result is:<enter>"
        print_buf[0]  = "T"; print_buf[1]  = "h"; print_buf[2]  = "e"; print_buf[3]  = " ";
        print_buf[4]  = "r"; print_buf[5]  = "e"; print_buf[6]  = "s"; print_buf[7]  = "u";
        print_buf[8]  = "l"; print_buf[9]  = "t"; print_buf[10] = " "; print_buf[11] = "i";
        print_buf[12] = "s"; print_buf[13] = ":";
        print_buf[14] = 8'h0D; print_buf[15] = 8'h0A;


        // row 0 opening
        print_buf[16] = "["; print_buf[17] = " ";
        // row 0 col 0
        {print_buf[18], print_buf[19], print_buf[20], print_buf[21], print_buf[22]} =
            {bin2hex_char({2'b0, c[0][0][17 : 16]}), bin2hex_char(c[0][0][15 : 12]), bin2hex_char(c[0][0][11 : 8]), bin2hex_char(c[0][0][7 : 4]), bin2hex_char(c[0][0][3 : 0])};
        print_buf[23] = ","; print_buf[24] = " ";
        // row 0 col 1
        {print_buf[25], print_buf[26], print_buf[27], print_buf[28], print_buf[29]} =
            {bin2hex_char({2'b0, c[0][1][17 : 16]}), bin2hex_char(c[0][1][15 : 12]), bin2hex_char(c[0][1][11 : 8]), bin2hex_char(c[0][1][7 : 4]), bin2hex_char(c[0][1][3 : 0])};
        print_buf[30] = ","; print_buf[31] = " ";
        // row 0 col 2
        {print_buf[32], print_buf[33], print_buf[34], print_buf[35], print_buf[36]} =
            {bin2hex_char({2'b0, c[0][2][17 : 16]}), bin2hex_char(c[0][2][15 : 12]), bin2hex_char(c[0][2][11 : 8]), bin2hex_char(c[0][2][7 : 4]), bin2hex_char(c[0][2][3 : 0])};
        print_buf[37] = ","; print_buf[38] = " ";
        // row 0 col 3
        {print_buf[39], print_buf[40], print_buf[41], print_buf[42], print_buf[43]} =
            {bin2hex_char({2'b0, c[0][3][17 : 16]}), bin2hex_char(c[0][3][15 : 12]), bin2hex_char(c[0][3][11 : 8]), bin2hex_char(c[0][3][7 : 4]), bin2hex_char(c[0][3][3 : 0])};
        // row 0 closer " ]<enter>"
        print_buf[44] = " "; print_buf[45] = "]"; print_buf[46] = 8'h0D; print_buf[47] = 8'h0A;


        // row 1 opening
        print_buf[48] = "["; print_buf[49] = " ";
        // row 1 col 0
        {print_buf[50], print_buf[51], print_buf[52], print_buf[53], print_buf[54]} =
            {bin2hex_char({2'b0, c[1][0][17 : 16]}), bin2hex_char(c[1][0][15 : 12]), bin2hex_char(c[1][0][11 : 8]), bin2hex_char(c[1][0][7 : 4]), bin2hex_char(c[1][0][3 : 0])};
        print_buf[55] = ","; print_buf[56] = " ";
        // row 1 col 1
        {print_buf[57], print_buf[58], print_buf[59], print_buf[60], print_buf[61]} =
            {bin2hex_char({2'b0, c[1][1][17 : 16]}), bin2hex_char(c[1][1][15 : 12]), bin2hex_char(c[1][1][11 : 8]), bin2hex_char(c[1][1][7 : 4]), bin2hex_char(c[1][1][3 : 0])};
        print_buf[62] = ","; print_buf[63] = " ";
        // row 1 col 2
        {print_buf[64], print_buf[65], print_buf[66], print_buf[67], print_buf[68]} =
            {bin2hex_char({2'b0, c[1][2][17 : 16]}), bin2hex_char(c[1][2][15 : 12]), bin2hex_char(c[1][2][11 : 8]), bin2hex_char(c[1][2][7 : 4]), bin2hex_char(c[1][2][3 : 0])};
        print_buf[69] = ","; print_buf[70] = " ";
        // row 1 col 3
        {print_buf[71], print_buf[72], print_buf[73], print_buf[74], print_buf[75]} =
            {bin2hex_char({2'b0, c[1][3][17 : 16]}), bin2hex_char(c[1][3][15 : 12]), bin2hex_char(c[1][3][11 : 8]), bin2hex_char(c[1][3][7 : 4]), bin2hex_char(c[1][3][3 : 0])};
        // row 1 closer " ]<enter>"
        print_buf[76] = " "; print_buf[77] = "]"; print_buf[78] = 8'h0D; print_buf[79] = 8'h0A;


        // row 2 opening
        print_buf[80] = "["; print_buf[81] = " ";
        // row 2 col 0
        {print_buf[82], print_buf[83], print_buf[84], print_buf[85], print_buf[86]} =
            {bin2hex_char({2'b0, c[2][0][17 : 16]}), bin2hex_char(c[2][0][15 : 12]), bin2hex_char(c[2][0][11 : 8]), bin2hex_char(c[2][0][7 : 4]), bin2hex_char(c[2][0][3 : 0])};
        print_buf[87] = ","; print_buf[88] = " ";
        // row 2 col 1
        {print_buf[89], print_buf[90], print_buf[91], print_buf[92], print_buf[93]} =
            {bin2hex_char({2'b0, c[2][1][17 : 16]}), bin2hex_char(c[2][1][15 : 12]), bin2hex_char(c[2][1][11 : 8]), bin2hex_char(c[2][1][7 : 4]), bin2hex_char(c[2][1][3 : 0])};
        print_buf[94] = ","; print_buf[95] = " ";
        // row 2 col 2
        {print_buf[96], print_buf[97], print_buf[98], print_buf[99], print_buf[100]} =
            {bin2hex_char({2'b0, c[2][2][17 : 16]}), bin2hex_char(c[2][2][15 : 12]), bin2hex_char(c[2][2][11 : 8]), bin2hex_char(c[2][2][7 : 4]), bin2hex_char(c[2][2][3 : 0])};
        print_buf[101] = ","; print_buf[102] = " ";
        // row 2 col 3
        {print_buf[103], print_buf[104], print_buf[105], print_buf[106], print_buf[107]} =
            {bin2hex_char({2'b0, c[2][3][17 : 16]}), bin2hex_char(c[2][3][15 : 12]), bin2hex_char(c[2][3][11 : 8]), bin2hex_char(c[2][3][7 : 4]), bin2hex_char(c[2][3][3 : 0])};
        // row 2 closer " ]<enter>"
        print_buf[108] = " "; print_buf[109] = "]"; print_buf[110] = 8'h0D; print_buf[111] = 8'h0A;


        // row 3 opening
        print_buf[112] = "["; print_buf[113] = " ";
        // row 3 col 0
        {print_buf[114], print_buf[115], print_buf[116], print_buf[117], print_buf[118]} =
            {bin2hex_char({2'b0, c[3][0][17 : 16]}), bin2hex_char(c[3][0][15 : 12]), bin2hex_char(c[3][0][11 : 8]), bin2hex_char(c[3][0][7 : 4]), bin2hex_char(c[3][0][3 : 0])};
        print_buf[119] = ","; print_buf[120] = " ";
        // row 3 col 1
        {print_buf[121], print_buf[122], print_buf[123], print_buf[124], print_buf[125]} =
            {bin2hex_char({2'b0, c[3][1][17 : 16]}), bin2hex_char(c[3][1][15 : 12]), bin2hex_char(c[3][1][11 : 8]), bin2hex_char(c[3][1][7 : 4]), bin2hex_char(c[3][1][3 : 0])};
        print_buf[126] = ","; print_buf[127] = " ";
        // row 3 col 2
        {print_buf[128], print_buf[129], print_buf[130], print_buf[131], print_buf[132]} =
            {bin2hex_char({2'b0, c[3][2][17 : 16]}), bin2hex_char(c[3][2][15 : 12]), bin2hex_char(c[3][2][11 : 8]), bin2hex_char(c[3][2][7 : 4]), bin2hex_char(c[3][2][3 : 0])};
        print_buf[133] = ","; print_buf[134] = " ";
        // row 3 col 3
        {print_buf[135], print_buf[136], print_buf[137], print_buf[138], print_buf[139]} =
            {bin2hex_char({2'b0, c[3][3][17 : 16]}), bin2hex_char(c[3][3][15 : 12]), bin2hex_char(c[3][3][11 : 8]), bin2hex_char(c[3][3][7 : 4]), bin2hex_char(c[3][3][3 : 0])};
        // row 3 closer " ]<enter>"
        print_buf[140] = " "; print_buf[141] = "]"; print_buf[142] = 8'h0D; print_buf[143] = 8'h0A;


        // "<enter>"
        print_buf[144] = 8'h0D; print_buf[145] = 8'h0A;


        // termination character
        print_buf[146] = 8'h0;
    end

    // --------------- print string FSM ---------------
    localparam S_UART_IDLE = 0;
    localparam S_UART_WAIT = 1;
    localparam S_UART_SEND = 2;
    localparam S_UART_INCR = 3;

    reg [1:0] Q = S_UART_IDLE;
    reg [1:0] Q_next;

    always @(posedge clk) begin
        if (~reset_n) Q <= S_UART_IDLE;
        else Q <= Q_next;
    end

    always @(*) begin
        case (Q)
            S_UART_IDLE: // wait for the print_string flag
                if (print_enable) Q_next = S_UART_WAIT;
                else Q_next = S_UART_IDLE;
            S_UART_WAIT: // wait for the transmission of current data byte begins
                if (is_transmitting == 1) Q_next = S_UART_SEND;
                else Q_next = S_UART_WAIT;
            S_UART_SEND: // wait for the transmission of current data byte finishes
                if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
                else Q_next = S_UART_SEND;
            S_UART_INCR:
                if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
                else Q_next = S_UART_WAIT;
        endcase
    end

    assign print_enable = (state == S_MAIN_COL_ADD && curr_col == 3);
    assign transmit = (Q_next == S_UART_WAIT || print_enable);
    assign tx_byte = print_buf[send_counter];
    assign print_done = (tx_byte == 8'h0);

    // send_counter
    always @(posedge clk) begin
        if (~reset_n) send_counter <= 0;
        else begin
            case (state)
                S_MAIN_IDLE: send_counter <= 0;
                S_MAIN_UART: send_counter <= send_counter + (Q_next == S_UART_INCR);
            endcase
        end
    end
    // --------------- END print string FSM ---------------

    // ------------------------------------------------------------------------
    // The following logic stores the UART input in a temporary buffer.
    // The input character will stay in the buffer for one clock cycle.
    always @(posedge clk) begin
        rx_temp <= (received)? rx_byte : 8'h0;
    end
    // ------------------------------------------------------------------------



    // format conversion
    function [8-1 : 0] bin2hex_char;
        input [4-1 : 0] bin;
        begin
            bin2hex_char = (bin > 9)? bin+55 : bin+48;
        end
    endfunction
endmodule
