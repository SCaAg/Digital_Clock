`timescale 1ns / 1ps  // Define the time scale (1 ns step with precision of 1 ps)

module tb_clk_divider_50M_to_10k ();

  // 定义寄存器和线网
  reg  clk_in_50M;
  reg  rst_n;
  wire clk_out_500Hz;
  wire clk_out_4Hz;
  wire clk_out_1Hz;

  // 实例化被测试模块
  clk_divider uut (
      .clk_in_50M(clk_in_50M),
      .rst_n(rst_n),
      .clk_out_500Hz(clk_out_500Hz),
      .clk_out_4Hz(clk_out_4Hz),
      .clk_out_1Hz(clk_out_1Hz)
  );

  // 生成50MHz时钟信号
  always #10 clk_in_50M = ~clk_in_50M;

  // 初始化过程
  initial begin
    // 初始化输入
    clk_in_50M = 0;
    rst_n = 0;

    // 等待100ns后释放复位
    #100 rst_n = 1;

    // 运行仿真1秒
    #1000000000;

    // 结束仿真
    $finish;
  end



endmodule
