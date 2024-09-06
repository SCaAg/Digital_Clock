`timescale 1ns / 1ps

module tb_test ();

  // 定义参数
  parameter CLK_PERIOD = 10;  // 时钟周期为10ns

  // 定义信号
  reg clk;
  reg ce;
  reg load;
  reg [15:0] l;
  wire thresho;
  wire [15:0] q;

  // 实例化被测单元
  c_counter_binary_0 uut (
      .CLK(clk),
      .CE(ce),
      .LOAD(load),
      .L(l),
      .THRESH0(thresho),
      .Q(q)
  );

  // 生成时钟
  always begin
    clk = 0;
    #(CLK_PERIOD / 2);
    clk = 1;
    #(CLK_PERIOD / 2);
  end

  // 测试过程
  initial begin
    // 初始化
    ce = 0;
    load = 0;
    l = 16'h0000;

    // 等待几个时钟周期
    #(CLK_PERIOD * 5);

    // 启用计数器
    ce = 1;

    // 等待计数器递减
    #(CLK_PERIOD * 20);

    // 加载值
    load = 1;
    l = 16'h0003;
    #CLK_PERIOD;
    load = 0;

    // 继续计数
    #(CLK_PERIOD * 20);

    // 结束仿真
    $finish;
  end

  // 监视输出
  always @(q) begin
    $display("Time=%0t, Counter Value=%h", $time, q);
  end

  // 监视阈值输出
  always @(thresho) begin
    $display("Time=%0t, Threshold Reached", $time);
  end

endmodule
