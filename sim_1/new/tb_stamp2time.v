`timescale 1ns / 1ps

module tb_stamp2time ();

  // 定义输入输出信号
  reg clk;
  reg rst_n;
  reg [63:0] counter;
  wire [15:0] year_bcd;
  wire [7:0] month_bcd, day_bcd, hour_bcd, minute_bcd, second_bcd;

  // 实例化被测试模块
  stamp2time uut (
      .clk(clk),
      .rst_n(rst_n),
      .counter(counter),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd)
  );

  // 生成时钟信号
  always #5 clk = ~clk;

  // 初始化和测试过程
  initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    counter = 0;

    // 复位
    #10 rst_n = 1;

    // 测试用例1: 2024年1月1日 00:00:00
    #10 counter = 64'd1704067200;
    #20;
    $display("Test Case 1: 2024-01-01 00:00:00");
    $display("Year: %d, Month: %d, Day: %d, Hour: %d, Minute: %d, Second: %d", year_bcd, month_bcd,
             day_bcd, hour_bcd, minute_bcd, second_bcd);

    // 测试用例2: 2024年8月30日 16:14:50
    #10 counter = 64'd1724928890;
    #20;
    $display("Test Case 2: 2024-08-30 16:14:50");
    $display("Year: %d, Month: %d, Day: %d, Hour: %d, Minute: %d, Second: %d", year_bcd, month_bcd,
             day_bcd, hour_bcd, minute_bcd, second_bcd);

    // 测试用例3: 2030年12月31日 23:59:59
    #10 counter = 64'd1924991999;
    #20;
    $display("Test Case 3: 2030-12-31 23:59:59");
    $display("Year: %d, Month: %d, Day: %d, Hour: %d, Minute: %d, Second: %d", year_bcd, month_bcd,
             day_bcd, hour_bcd, minute_bcd, second_bcd);

    // 结束仿真
    #10 $finish;
  end

endmodule
