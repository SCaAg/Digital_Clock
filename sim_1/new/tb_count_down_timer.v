`timescale 1ns / 1ps
//This is a testbench for count_down_timer
module count_down_timer_tb ();

  // 定义输入和输出信号
  reg clk;  //需要1khz时钟
  reg rst_n;
  reg load;
  reg clock_en;
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
      .load(load),
      .clock_en(clock_en),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .hour_out_bcd(hour_out_bcd),
      .minute_out_bcd(minute_out_bcd),
      .second_out_bcd(second_out_bcd),
      .ring(ring)
  );

  // 生成时钟信号
  always #500000 clk = ~clk;  // 1kHz时钟

  // 测试过程
  initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    load = 0;
    clock_en = 0;
    hour_bcd_in = 0;
    minute_bcd_in = 0;
    second_bcd_in = 0;

    // 复位
    #1000000 rst_n = 1;

    // 测试设置计时器
    #1000000;
    hour_bcd_in = 8'h00;  // 0小时
    minute_bcd_in = 8'h00;  // 0分钟
    second_bcd_in = 8'h3;  // 3秒
    load = 1;
    #1000000 load = 0;


    $display("设置倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // 开始计时
    clock_en = 1;
    $display("开始倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    #1000000000;
    clock_en = 0;
    $display("暂停后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    #1000000000;
    clock_en = 1;
    $display("继续倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // 测试重置功能
    #100000000 load = 1;
    #1000000 load = 0;
    $display("重置后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);


    // 测试重置功能
    #100000000 load = 1;
    #1000000 load = 0;

    $display("倒计时结束时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    $display("铃声状态: %b", ring);
    // 测试重置功能
    #100000000 load = 1;
    #100000000 load = 0;
    // 结束仿真
    $finish;
  end

endmodule
