`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 15:07:53
// Design Name: 
// Module Name: fpga_matrixKeyboard
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

//键盘fpga测试
module fpga_matrixKeyboard(
    input clk,
    input reset_n,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg,
    output [7:0] an
    );

    //按键
    wire [3:0] key_code;
    wire key_vaild;
    matrixKeyboard matrixKeyboard1(
        .clk(clk),
        .reset_n(reset_n),
        .row(row),
        .col(col),
        .key_code(key_code),
        .key_vaild(key_vaild)
    );

    wire [3:0] key0_state;
    wire [3:0] key1_state;
    wire [3:0] key2_state;
    wire [3:0] key3_state;
    wire [3:0] key4_state;
    wire [3:0] key5_state;

    keyState keyState1(
        .clk(clk),
        .reset_n(reset_n),
        .key_code(key_code),
        .key_vaild(key_vaild),
        .key0_state(key0_state),
        .key1_state(key1_state),
        .key2_state(key2_state),
        .key3_state(key3_state),
        .key4_state(key4_state),
        .key5_state(key5_state)
    );

    //计数器
    reg load_n=1;
    reg go=1;
    wire [63:0] counter;

    unixCounter counter1(
        .clk(clk),
        .reset_n(reset_n),
        .load_n(load_n),
        .setCounter(inputcounter),
        .go(go),
        .counter(counter)
    );

    //数码管显示
    wire[7:0] point;
    wire[3:0] led1Number;
    wire[3:0] led2Number;
    wire[3:0] led3Number;
    wire[3:0] led4Number;
    wire[3:0] led5Number;
    wire[3:0] led6Number;
    wire[3:0] led7Number;
    wire[3:0] led8Number;

    ledScan ledScan1(
        .clk(clk),
        .reset_n(reset_n),
        .led1Number(led1Number),
        .led2Number(led2Number),
        .led3Number(led3Number),
        .led4Number(led4Number),
        .led5Number(led5Number),
        .led6Number(led6Number),
        .led7Number(led7Number),
        .led8Number(led8Number),
        .point(point),
        .ledCode(seg),
        .an(an)
    );

    //计数器转BCD
    counter2bcd counter2bcd1(
        .clk(clk),
        .rst_n(reset_n),
        .counter(counter),
        .display_year(key0_state),
        .eight_segment({led8Number,led7Number,led6Number,led5Number,led4Number,led3Number,led2Number,led1Number})
    );

endmodule
