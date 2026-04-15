module mul8(
    input clk, rst_n,
    input start_i,
    input [8-1 : 0] A_i, B_i,
    output [16-1 : 0] product_o,
    output done
);
    wire load, add, shift;
    wire M0;

    mul8_datapath u1 (
        .clk(clk), .rst_n(rst_n),
        .A_i(A_i), .B_i(B_i),
        .load_i(load), .add_i(add), .shift_i(shift),
        .product_o(product_o),
        .M0_o(M0)
    );

    mul8_controller u2 (
        .clk(clk), .rst_n(rst_n),
        .M0_i(M0), .start_i(start_i),
        .load_o(load), .add_o(add), .shift_o(shift),
        .done(done)
    );

endmodule