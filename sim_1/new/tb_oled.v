`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 18:36:04
// Design Name: 
// Module Name: tb_oled
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


module tb_oled();


    reg clk;
    reg reset_n;

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
    
    unix64_to_UTC unix64_to_UTC1(
        .clk(clk),
        .rst_n(reset_n),
        .unix_time(unixCounter),
        .hour(hour),
        .minute(minute),
        .second(second)
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
        .reset_oled(reset_oled)
    );
    initial begin
        clk = 0;
        reset_n = 0;
        #1000 reset_n=1;
    end

    always #10 clk = ~clk;

endmodule
