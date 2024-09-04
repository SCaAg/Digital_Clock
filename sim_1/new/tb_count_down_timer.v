`timescale 1ns / 1ps

module count_down_timer_tb ();

  // 定义输入和输出信号
  reg clk;
  reg rst_n;
  reg set_timer;
  reg reset_timer;
  reg pause;
  reg [7:0] hour_bcd_in;
  reg [7:0] minute_bcd_in;
  reg [7:0] second_bcd_in;
  wire [7:0] hour_out_bcd;
  wire [7:0] minute_out_bcd;
  wire [7:0] second_out_bcd;
  wire ring;

  // 实例化被测试模块
  count_down_timer uut (
      .clk(clk),
      .rst_n(rst_n),
      .set_timer(set_timer),
      .reset_timer(reset_timer),
      .pause(pause),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .hour_out_bcd(hour_out_bcd),
      .minute_out_bcd(minute_out_bcd),
      .second_out_bcd(second_out_bcd),
      .ring(ring)
  );

  // 生成时钟信号
  always #5 clk = ~clk;

  // 测试过程
  initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    set_timer = 0;
    reset_timer = 0;
    pause = 0;
    hour_bcd_in = 0;
    minute_bcd_in = 0;
    second_bcd_in = 0;

    // 复位
    #10 rst_n = 1;

    // 测试设置计时器
    #10;
    hour_bcd_in = 8'h01;  // 1小时
    minute_bcd_in = 8'h30;  // 30分钟
    second_bcd_in = 8'h15;  // 15秒
    set_timer = 1;
    #10 set_timer = 0;

    // 等待一段时间并检查输出
    #100;
    $display("时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // 测试暂停功能
    pause = 1;
    #50;
    $display("暂停后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    pause = 0;

    // 测试重置功能
    #50 reset_timer = 1;
    #10 reset_timer = 0;
    $display("重置后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // 等待计时器结束
    #5000;
    $display("计时结束时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    $display("响铃状态: %b", ring);

    // 结束仿真
    #100 $finish;
  end

endmodule
