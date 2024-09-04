`timescale 1ns / 1ps

module tb_alarm ();

  // 定义输入和输出信号
  reg clk;
  reg rst_n;
  reg set;
  reg [15:0] alarm_year_bcd_in;
  reg [7:0]
      alarm_month_bcd_in,
      alarm_day_bcd_in,
      alarm_hour_bcd_in,
      alarm_minute_bcd_in,
      alarm_second_bcd_in;
  reg [1:0] selected_alarm;
  reg [63:0] counter;
  reg cancel;

  wire [7:0] alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd;
  wire ring;

  // 实例化被测试的模块
  alarm uut (
      .clk(clk),
      .rst_n(rst_n),
      .set(set),
      .alarm_year_bcd_in(alarm_year_bcd_in),
      .alarm_month_bcd_in(alarm_month_bcd_in),
      .alarm_day_bcd_in(alarm_day_bcd_in),
      .alarm_hour_bcd_in(alarm_hour_bcd_in),
      .alarm_minute_bcd_in(alarm_minute_bcd_in),
      .alarm_second_bcd_in(alarm_second_bcd_in),
      .selected_alarm(selected_alarm),
      .counter(counter),
      .cancel(cancel),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .ring(ring)
  );

  // 生成时钟
  always #5 clk = ~clk;

  // 测试过程
  initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    set = 0;
    alarm_year_bcd_in = 16'h2023;
    alarm_month_bcd_in = 8'h12;
    alarm_day_bcd_in = 8'h31;
    alarm_hour_bcd_in = 8'h23;
    alarm_minute_bcd_in = 8'h59;
    alarm_second_bcd_in = 8'h59;
    selected_alarm = 2'b00;
    counter = 64'd0;
    cancel = 0;

    // 复位
    #10 rst_n = 1;

    // 设置闹钟
    #10 set = 1;
    #10 set = 0;

    // 模拟时间流逝
    repeat (100) begin
      #10 counter = counter + 1;
    end

    // 触发闹钟
    counter = {16'h2023, 8'h12, 8'h31, 8'h23, 8'h59, 8'h59};
    #20;

    // 取消闹钟
    #50 cancel = 1;
    #10 cancel = 0;

    // 结束仿真
    #100 $finish;
  end

  // 监控输出
  initial begin
    $monitor("Time=%0t, Ring=%b, Hour=%h, Minute=%h, Second=%h", $time, ring, alarm_hour_bcd,
             alarm_minute_bcd, alarm_second_bcd);
  end

endmodule
