`timescale 1ns / 1ps

module tb_time2stamp ();

  // 定义输入和输出信号
  reg clk;
  reg rst_n;
  reg [7:0] hour;
  reg [7:0] min;
  reg [7:0] sec;
  wire [31:0] stamp;

  // 实例化被测试的模块
  time2stamp uut (
      .clk  (clk),
      .rst_n(rst_n),
      .hour (hour),
      .min  (min),
      .sec  (sec),
      .stamp(stamp)
  );

  // 生成时钟信号
  always #5 clk = ~clk;

  // 测试过程
  initial begin
    // 初始化输入
    clk   = 0;
    rst_n = 0;
    hour  = 0;
    min   = 0;
    sec   = 0;

    // 复位
    #10 rst_n = 1;

    // 测试用例1: 00:00:00
    #10 hour = 8'd0;
    min = 8'd0;
    sec = 8'd0;
    #10 $display("Time: %02d:%02d:%02d, Stamp: %d", hour, min, sec, stamp);

    // 测试用例2: 12:30:45
    #10 hour = 8'd12;
    min = 8'd30;
    sec = 8'd45;
    #10 $display("Time: %02d:%02d:%02d, Stamp: %d", hour, min, sec, stamp);

    // 测试用例3: 23:59:59
    #10 hour = 8'd23;
    min = 8'd59;
    sec = 8'd59;
    #10 $display("Time: %02d:%02d:%02d, Stamp: %d", hour, min, sec, stamp);

    // 结束仿真
    #10 $finish;
  end

endmodule
