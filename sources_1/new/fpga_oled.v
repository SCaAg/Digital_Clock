`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 09:14:13
// Design Name: 
// Module Name: fpga_oled
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


module fpga_oled(
    input clk,
    input reset_n,
    output sck,
    output mosi,
    output dc_out,
    output cs,
    output reset_oled
    );
    
    //spi初始化
    wire dc;
    wire [7:0] spi_data;
    wire spi_send;
    wire spi_send_done;
    wire spi_clk;
    spiMaster spoMaster1(
        .clk(clk),
        .reset_n(reset_n),
        .dc_in(dc),
        .spi_data_out(spi_data),
        .spi_send(spi_send),
        .spi_send_done(spi_send_done),
        .spi_clk(spi_clk),
        .dc(dc_out),
        .sck(sck),
        .mosi(mosi),
        .cs(cs)
    );

    //oled初始化
    wire oled_init_spi_send;
    wire [7:0] oled_init_spi_data;
    wire init_done;
    wire oled_init_dc;
    oled_init oled_init1(
        .send_done(spi_send_done),
        .spi_send(oled_init_spi_send),
        .spi_data(oled_init_spi_data),
        .clk(spi_clk),
        .dc(oled_init_dc),
        .reset_n(reset_n),
        .init_done(init_done)
    );

    wire oled_draw_spi_send;
    wire [7:0] oled_draw_spi_data;
    wire oled_draw_dc;
    oledDraw oledDraw1(
        .clk(spi_clk),
        .reset_n(reset_n),
        .send_done(spi_send_done),
        .is_draw(init_done),
        .spi_send(oled_draw_spi_send),
        .spi_data(oled_draw_spi_data),
        .dc(oled_draw_dc)
    );

    assign spi_send = (!init_done)? oled_init_spi_send : oled_draw_spi_send;
    assign spi_data = (!init_done)? oled_init_spi_data : oled_draw_spi_data;
    assign dc=(!init_done)? oled_init_dc : oled_draw_dc;
    assign reset_oled = reset_n;



endmodule
