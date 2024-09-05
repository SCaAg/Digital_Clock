`timescale 1ns / 1ps

module tb_time2stamp ();

  // 输入信号
  reg  [13:0] year;
  reg  [ 3:0] month;
  reg  [ 4:0] day;
  reg  [ 4:0] hour;
  reg  [ 5:0] minute;
  reg  [ 5:0] second;

  // 输出信号
  wire [63:0] time_stamp;

  // 实例化被测试模块
  time2stamp uut (
      .year(year),
      .month(month),
      .day(day),
      .hour(hour),
      .minute(minute),
      .second(second),
      .time_stamp(time_stamp)
  );

  // 测试用例数组
  reg [13:0] test_years[0:9];
  reg [3:0] test_months[0:9];
  reg [4:0] test_days[0:9];
  reg [4:0] test_hours[0:9];
  reg [5:0] test_minutes[0:9];
  reg [5:0] test_seconds[0:9];

  integer i;

  initial begin
    // 初始化测试用例
    test_years[0] = 1970;
    test_months[0] = 1;
    test_days[0] = 1;
    test_hours[0] = 0;
    test_minutes[0] = 0;
    test_seconds[0] = 0;
    test_years[1] = 2000;
    test_months[1] = 2;
    test_days[1] = 29;
    test_hours[1] = 12;
    test_minutes[1] = 30;
    test_seconds[1] = 45;
    test_years[2] = 2024;
    test_months[2] = 9;
    test_days[2] = 2;
    test_hours[2] = 10;
    test_minutes[2] = 52;
    test_seconds[2] = 38;
    test_years[3] = 1999;
    test_months[3] = 12;
    test_days[3] = 31;
    test_hours[3] = 23;
    test_minutes[3] = 59;
    test_seconds[3] = 59;
    test_years[4] = 2100;
    test_months[4] = 3;
    test_days[4] = 1;
    test_hours[4] = 0;
    test_minutes[4] = 0;
    test_seconds[4] = 0;
    test_years[5] = 1971;
    test_months[5] = 1;
    test_days[5] = 1;
    test_hours[5] = 0;
    test_minutes[5] = 0;
    test_seconds[5] = 0;
    test_years[6] = 2023;
    test_months[6] = 6;
    test_days[6] = 15;
    test_hours[6] = 8;
    test_minutes[6] = 30;
    test_seconds[6] = 0;
    test_years[7] = 2050;
    test_months[7] = 10;
    test_days[7] = 31;
    test_hours[7] = 18;
    test_minutes[7] = 45;
    test_seconds[7] = 30;
    test_years[8] = 1980;
    test_months[8] = 2;
    test_days[8] = 28;
    test_hours[8] = 23;
    test_minutes[8] = 0;
    test_seconds[8] = 0;
    test_years[9] = 2222;
    test_months[9] = 12;
    test_days[9] = 12;
    test_hours[9] = 12;
    test_minutes[9] = 12;
    test_seconds[9] = 12;

    // 运行测试用例
    for (i = 0; i < 10; i = i + 1) begin
      year = test_years[i];
      month = test_months[i];
      day = test_days[i];
      hour = test_hours[i];
      minute = test_minutes[i];
      second = test_seconds[i];

      #10;  // 等待10个时间单位

      $display("测试用例 %0d:", i + 1);
      $display("输入: 年=%0d, 月=%0d, 日=%0d, 时=%0d, 分=%0d, 秒=%0d", year, month, day,
               hour, minute, second);
      $display("输出: 时间戳=%0d", time_stamp);
      $display("------------------------");
    end

    $finish;
  end

endmodule
