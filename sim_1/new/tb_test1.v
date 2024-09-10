`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 20:12:02
// Design Name: 
// Module Name: tb_test1
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


module tb_test1 ();

  // 定义输入信号
  reg clk;
  reg rst_n;
  reg [15:0] year_bcd_in;
  reg [7:0] month_bcd_in, day_bcd_in, hour_bcd_in, minute_bcd_in, second_bcd_in;
  reg [3:0] up_btn, down_btn, left_btn, right_btn, enter_btn, return_btn, gobal_state;

  // 定义输出信号
  wire [15:0] year_bcd_out;
  wire [7:0] month_bcd_out, day_bcd_out, hour_bcd_out, minute_bcd_out, second_bcd_out;
  wire [3:0] led0, led1, led2, led3, led4, led5, led6, led7;
  wire [7:0] blink, dot;
  wire is_blink;

  // 实例化被测试模块
  test1 uut (
      .clk(clk),
      .rst_n(rst_n),
      .year_bcd_in(year_bcd_in),
      .month_bcd_in(month_bcd_in),
      .day_bcd_in(day_bcd_in),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .year_bcd_out(year_bcd_out),
      .month_bcd_out(month_bcd_out),
      .day_bcd_out(day_bcd_out),
      .hour_bcd_out(hour_bcd_out),
      .minute_bcd_out(minute_bcd_out),
      .second_bcd_out(second_bcd_out),
      .up_btn(up_btn),
      .down_btn(down_btn),
      .left_btn(left_btn),
      .right_btn(right_btn),
      .enter_btn(enter_btn),
      .return_btn(return_btn),
      .gobal_state(gobal_state),
      .led0(led0),
      .led1(led1),
      .led2(led2),
      .led3(led3),
      .led4(led4),
      .led5(led5),
      .led6(led6),
      .led7(led7),
      .blink(blink),
      .dot(dot),
      .is_blink(is_blink)
  );

  // 生成时钟信号
  always #5 clk = ~clk;

  // 初始化测试
  initial begin
    // 初始化输入信号
    clk = 0;
    rst_n = 0;
    year_bcd_in = 16'h2024;
    month_bcd_in = 8'h03;
    day_bcd_in = 8'h15;
    hour_bcd_in = 8'h10;
    minute_bcd_in = 8'h30;
    second_bcd_in = 8'h00;
    up_btn = 4'h0;
    down_btn = 4'h0;
    left_btn = 4'h0;
    right_btn = 4'h0;
    enter_btn = 4'h0;
    return_btn = 4'h0;
    gobal_state = 4'h0;

    // 复位
    #10 rst_n = 1;

    // 测试显示模式
    #20;
    $display("显示模式测试:");
    $display("时间: %h:%h:%h", hour_bcd_out, minute_bcd_out, second_bcd_out);
    $display("日期: %h-%h-%h", year_bcd_out, month_bcd_out, day_bcd_out);

    // 测试进入编辑模式
    #10 enter_btn = 4'h2;
    #10 enter_btn = 4'h0;
    #10;
    $display("进入编辑模式");

    // 测试编辑时间
    #10 up_btn = 4'h1;
    #10 up_btn = 4'h0;
    #10;
    $display("编辑后时间: %h:%h:%h", hour_bcd_out, minute_bcd_out, second_bcd_out);

    #10 right_btn = 4'h1;
    #10 right_btn = 4'h0;
    #10 up_btn = 4'h1;
    #10 up_btn = 4'h0;
    #10;
    $display("编辑后日期: %h-%h-%h", year_bcd_out, month_bcd_out, day_bcd_out);

    // 测试退出编辑模式
    #10 enter_btn = 4'h1;
    #10 enter_btn = 4'h0;
    #10;
    $display("退出编辑模式");

    // 结束仿真
    #100 $finish;
  end

endmodule
