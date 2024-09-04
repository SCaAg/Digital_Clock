`timescale 1ns / 1ps

module bcd_time2alarm_time_tb;

  // 输入信号
  reg [15:0] alarm_year_bcd;
  reg [7:0] alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd;
  reg  [63:0] counter;

  // 输出信号
  wire [63:0] alarm_stamp;

  // 实例化被测试模块
  bcd_time2alarm_time uut (
      .alarm_year_bcd(alarm_year_bcd),
      .alarm_month_bcd(alarm_month_bcd),
      .alarm_day_bcd(alarm_day_bcd),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .counter(counter),
      .alarm_stamp(alarm_stamp)
  );

  // 测试过程
  initial begin
    // 测试用例1
    alarm_year_bcd   = 16'h2023;  // 2023年
    alarm_month_bcd  = 8'h05;  // 5月
    alarm_day_bcd    = 8'h15;  // 15日
    alarm_hour_bcd   = 8'h10;  // 10时
    alarm_minute_bcd = 8'h30;  // 30分
    alarm_second_bcd = 8'h00;  // 00秒
    counter          = 64'd1684130400;  // 2023-05-15 09:00:00

    #10;  // 等待10个时间单位
    $display("测试用例1:");
    $display("输入: 年=%h, 月=%h, 日=%h, 时=%h, 分=%h, 秒=%h", alarm_year_bcd,
             alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd);
    $display("当前时间戳: %d", counter);
    $display("输出闹钟时间戳: %d", alarm_stamp);
    $display("");

    // 测试用例2
    alarm_year_bcd   = 16'h2023;  // 2023年
    alarm_month_bcd  = 8'h12;  // 12月
    alarm_day_bcd    = 8'h31;  // 31日
    alarm_hour_bcd   = 8'h23;  // 23时
    alarm_minute_bcd = 8'h59;  // 59分
    alarm_second_bcd = 8'h59;  // 59秒
    counter          = 64'd1704067199;  // 2023-12-31 23:59:59

    #10;  // 等待10个时间单位
    $display("测试用例2:");
    $display("输入: 年=%h, 月=%h, 日=%h, 时=%h, 分=%h, 秒=%h", alarm_year_bcd,
             alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd);
    $display("当前时间戳: %d", counter);
    $display("输出闹钟时间戳: %d", alarm_stamp);

    $finish;
  end

endmodule
