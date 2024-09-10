`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/08 15:09:20
// Design Name: 
// Module Name: oledInterface
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
//显示屏接口

module oledInterface(
    input clk,
    input reset_n,
    input [4:0] hour,
    input [5:0] minute,
    input [5:0] second,
    input [13:0] year,
    input [3:0] month,
    input [4:0] day,
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
    //oled绘图
    wire oled_draw_spi_send;
    wire [7:0] oled_draw_spi_data;
    wire oled_draw_dc;
    oledDrawv5 oledDraw1(
        .clk(spi_clk),
        .reset_n(reset_n),
        .send_done(spi_send_done),
        .is_draw(init_done),
        .spi_send(oled_draw_spi_send),
        .spi_data(oled_draw_spi_data),
        .dc(oled_draw_dc),
        .hour(hour),
        .minute(minute),
        .second(second),
        .year(year),
        .month(month),
        .day(day)
    );
    assign spi_send = (!init_done)? oled_init_spi_send : oled_draw_spi_send;
    assign spi_data = (!init_done)? oled_init_spi_data : oled_draw_spi_data;
    assign dc=(!init_done)? oled_init_dc : oled_draw_dc;
    assign reset_oled = reset_n;

endmodule
