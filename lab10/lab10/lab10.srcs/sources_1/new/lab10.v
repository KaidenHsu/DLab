`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2026 04:09:10 PM
// Design Name: 
// Module Name: lab10
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


module lab10(
    input  clk, reset_n,

    input  [3:0] usr_btn,



    output [3:0] usr_led,

    // VGA sync signals
    output VGA_HSYNC,
    output VGA_VSYNC,

    // 12-bit RGB color output
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
);
    // video buffer size
    localparam VBUF_W = 320; // video buffer width
    localparam VBUF_H = 240; // video buffer height

    localparam FW_FRAMES = 5;
    localparam FW_BUF_W = 100;
    localparam FW_BUF_H = 67;
    


    // system variables
    reg [33:0] moon_clock;
    reg [30:0] fw_clock;
    wire [9:0] pos;

    wire moon_region; // assert when current pixel is within moon region
    wire fw_region;

    // SRAM signals
    wire sram_we, sram_en;
    wire [$clog2(64*40)-1 : 0] data_in;
    wire [12-1 : 0] data_moon_out;
    wire [12-1 : 0] data_bg_out;
    wire [12-1 : 0] data_fw_out;

    // general VGA control signals
    wire vga_clk;       // 50MHz clock for VGA control
    wire video_on;      // when video_on is 0, the VGA controller is sending
                        // synchronization signals to the display device.
    
    wire pixel_tick;    // when pixel tick is 1, we must update the RGB value
                        // based for the new coordinate (pixel_x, pixel_y)
    
    wire [9:0] pixel_x; // x coordinate of the next pixel (between 0 ~ 639) 
    wire [9:0] pixel_y; // y coordinate of the next pixel (between 0 ~ 479)
    
    reg  [11:0] rgb_reg;  // RGB value for the current pixel
    reg  [11:0] rgb_next; // RGB value for the next pixel
    
    // application-specific VGA signals
    reg [$clog2(VBUF_W*VBUF_H)-1 : 0] pixel_bg_addr;
    reg [$clog2(64*40)-1 : 0] pixel_moon_addr;
    reg [$clog2(FW_FRAMES*FW_BUF_W*FW_BUF_H)-1 : 0] pixel_fw_addr;



    // VGA sync signal generator
    vga_sync vs0(
        .clk(vga_clk), .reset(~reset_n),

        .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
        .visible(video_on), .p_tick(pixel_tick),
        .pixel_x(pixel_x), .pixel_y(pixel_y)
    );

    clk_divider #(
        2
    ) clk_divider0 (
        .clk(clk), .reset(~reset_n),

        .clk_out(vga_clk)
    );

    // ------------------------------------------------------------------------
    // The following code describes an initialized SRAM memory block that
    // stores an 320x240 12-bit city image, plus a 64x40 moon image.

    // moon
    sram #(
        .DATA_WIDTH(12),
        .ADDR_WIDTH($clog2(64*40)),
        .RAM_SIZE(64*40),
        .MEM_FILE("moon.mem")
    ) ram_moon (
        .clk(clk),

        .we(sram_we), .en(sram_en),
        .addr(pixel_moon_addr), .data_i(data_in),

        .data_o(data_moon_out)
    );

    // background
    sram #(
        .DATA_WIDTH(12),
        .ADDR_WIDTH($clog2(VBUF_W*VBUF_H)),
        .RAM_SIZE(VBUF_W*VBUF_H),
        .MEM_FILE("bg.mem")
    ) ram_bg (
        .clk(clk),

        .we(sram_we), .en(sram_en),
        .addr(pixel_bg_addr), .data_i(data_in),

        .data_o(data_bg_out)
    );

    // fireworks
    sram #(
        .DATA_WIDTH(12),
        .ADDR_WIDTH($clog2(FW_FRAMES*FW_BUF_W*FW_BUF_H)),
        .RAM_SIZE(FW_FRAMES*FW_BUF_W*FW_BUF_H),
        .MEM_FILE("fireworks.mem")
    ) ram_fw (
      .clk(clk), 

      .we(sram_we), .en(sram_en),
      .addr(pixel_fw_addr), .data_i(data_in), 

      .data_o(data_fw_out)
    );


    assign usr_led = usr_btn;



    // ------------------------------------------------------------------------
    // SRAM memory block
    // In this demo, we do not write the SRAM. However,
    // if you set 'we' to 0, Vivado fails to synthesize
    // ram0 as a BRAM -- this is a bug in Vivado.
    assign sram_we = usr_btn[0];

    assign sram_en = 1;          // Here, we always enable the SRAM block.
    assign data_in = 12'h000; // SRAM is read-only so we tie inputs to zeros.
    // End of the SRAM memory block.
    // ------------------------------------------------------------------------



    // VGA color pixel generator
    assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;

    // ------------------------------------------------------------------------
    // An animation clock for the motion of the moon, upper bits of the
    // moon clock is the x position of the moon in the VGA screen
    
    // pos
    assign pos = moon_clock[33:24];
    
    // fw_count
    assign fw_count = fw_clock[29 : 27];

    // moon_clock
    always @(posedge clk) begin
        if (~reset_n || moon_clock[33:25] > VBUF_W + 64) moon_clock <= 0;
        else moon_clock <= moon_clock+1;
    end

    // fw_clock
    always @(posedge clk) begin
      if (~reset_n || fw_count >= FW_FRAMES || moon_clock == 0) fw_clock <= 0;
      else fw_clock <= fw_clock+1;
    end
    // End of the animation clock code.
    // ------------------------------------------------------------------------



    // ------------------------------------------------------------------------
    // Video frame buffer address generation unit (AGU) with scaling control
    // Note that the width x height of the moon image is 64x40, when scaled
    // up to the screen, it becomes 128x80

    // moon_region
    assign moon_region = (pixel_x+127 >= pos && pixel_x < pos+1) && (pixel_y >= 0 && pixel_y < 80);

    // fw_region
    assign fw_region = (pixel_x >= 219 && pixel_x <= 420) && (pixel_y >= 39 && pixel_y <= 174);

    // pixel_bg_addr
    always @(posedge clk) begin
        if (~reset_n) pixel_bg_addr <= 0;
        else begin
            // Scale up a 320x240 image for the 640x480 display.
            // (pixel_x, pixel_y) ranges from (0,0) to (639, 379)
            pixel_bg_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
        end
    end

    // pixel_moon_addr
    always @(posedge clk) begin
        if (~reset_n) pixel_moon_addr <= 0;
        else pixel_moon_addr <= ((pixel_y & 10'h3FE) << 5) + ((pixel_x-pos+127) >> 1);
    end

    // pixel_fw_addr
    always @ (posedge clk) begin
      if (~reset_n) pixel_fw_addr <= 0;
      else pixel_fw_addr <= fw_count*FW_BUF_W*FW_BUF_H + ((pixel_y-40) >> 1) * FW_BUF_W + ((pixel_x-220) >> 1);
    end
    // End of the AGU code.
    // ------------------------------------------------------------------------



    // ------------------------------------------------------------------------
    // Send the video data in the sram to the VGA controller
    
    // rgb_reg
    always @(posedge clk) begin
        if (pixel_tick) rgb_reg <= rgb_next;
    end

    // rgb_next
    always @(*) begin
        if (~video_on) rgb_next = 12'h000; // Synchronization period, must set RGB values to zero.
        else if(fw_region && data_fw_out != 12'h000) rgb_next = data_fw_out;
        else if (moon_region && data_moon_out != 12'h0f0) rgb_next = data_moon_out;
        else rgb_next = data_bg_out; // RGB value at (pixel_x, pixel_y)
    end
    // End of the video data display code.
    // ------------------------------------------------------------------------
endmodule
