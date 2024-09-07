`timescale 1ns / 1ps
//This is a testbench for count_down_timer
module count_down_timer_tb ();

  // 定义输入和输出信号
  reg clk_50M;  //需要1khz时钟
  reg clk_1k;
  reg rst_n;
  reg set;
  reg play;
  reg stop;
  reg [7:0] hour_bcd_in;
  reg [7:0] minute_bcd_in;
  reg [7:0] second_bcd_in;
  wire [7:0] hour_out_bcd;
  wire [7:0] minute_out_bcd;
  wire [7:0] second_out_bcd;
  wire ring;
  wire counting;

  // 实例化被测试模块
  count_down_timer uut (
      .clk_50M(clk_50M),
      .clk_1k(clk_1k),
      .rst_n(rst_n),
      .set(set),
      .play(play),
      .stop(stop),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .hour_out_bcd(hour_out_bcd),
      .minute_out_bcd(minute_out_bcd),
      .second_out_bcd(second_out_bcd),
      .ring(ring),
      .counting(counting)
  );

  // 生成时钟信号
  always #100000 clk_50M = ~clk_50M;  // 50MHz时钟
  always #500000 clk_1k = ~clk_1k;  // 1kHz时钟

  // 测试过程
  initial begin
    // 初始化信号
    clk_50M = 0;
    clk_1k = 0;
    rst_n = 0;
    set = 0;
    play = 0;
    stop = 0;
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
    set = 1;
    // 等待50ms
    #1000000 set = 0;


    $display("设置倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // 开始计时

    $display("开始倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // 等待1000ms
    #1000000000;
    stop = 1;
    //等待50ms
    #1000000 stop = 0;
    $display("暂停后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // 等待1000ms
    #1000000000;
    play = 1;
    //等待50ms
    #1000000 play = 0;
    $display("继续倒计时时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // 等待1000ms

    // 测试重置功能
    #1000000000;
    set = 1;
    #1000000 set = 0;
    $display("重置后时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);


    // 测试重置功能
    play = 1;
    #1000000;
    play = 0;

    $display("倒计时结束时间: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    $display("铃声状态: %b", ring);
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    set = 1;
    #1000000 set = 0;
    // 结束仿真
    $finish;
  end

endmodule
