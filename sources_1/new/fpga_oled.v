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
    
    //计时器初始化
    reg load_n=1;
    reg go=1;
    wire [63:0] unixCounter;
    unixCounter unixCounter1(
        .clk(clk),
        .reset_n(reset_n),
        .load_n(load_n),
        .go(go),
        .counter(unixCounter)
    );

    wire [4:0] hour;
    wire [5:0] minute;
    wire [5:0] second;
    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;
    
    unix64_to_UTC unix64_to_UTC1(
        .clk(clk),
        .rst_n(reset_n),
        .unix_time(unixCounter),
        .hour(hour),
        .minute(minute),
        .second(second),
        .year(year),
        .month(month),
        .day(day)
    );

    oledInterface oledInterface1(
        .clk(clk),
        .reset_n(reset_n),
        .hour(hour),
        .minute(minute),
        .second(second),
        .sck(sck),
        .mosi(mosi),
        .dc_out(dc_out),
        .cs(cs),
        .reset_oled(reset_oled),
        .year(year),
        .month(month),
        .day(day)
    );





endmodule
