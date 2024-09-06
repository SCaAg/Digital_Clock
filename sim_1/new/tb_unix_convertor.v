`timescale 1ns / 1ps

module tb_unix64_to_UTC;

  // 定义输入和输出信号
  reg clk;
  reg rst_n;
  reg [63:0] unix_time;
  wire [13:0] year;
  wire [3:0] month;
  wire [4:0] day;
  wire [2:0] weekday;
  wire [4:0] hour;
  wire [5:0] minute;
  wire [5:0] second;
  wire [3:0] state;

  // 实例化被测试模块
  unix64_to_UTC uut (
      .clk(clk),
      .rst_n(rst_n),
      .unix_time(unix_time),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second),
      .state(state)
  );

  // 时钟生成
  always #1 clk = ~clk;

  // 测试过程
  initial begin
    // 初始化信号
    clk = 0;
    rst_n = 0;
    unix_time = 0;

    // 复位
    #10 rst_n = 1;

    // 测试用例1: 2023年5月1日 12:34:56 (UTC)
    #10 unix_time = 64'd1682944496;
    #5000;
    display_result();

    // 测试用例2: 2000年1月1日 00:00:00 (UTC)
    #10 unix_time = 64'd946684800;
    #5000;
    display_result();

    // 测试用例3: 2038年1月19日 03:14:07 (UTC) - 32位unix时间戳的最大值
    #10 unix_time = 64'd2147483647;
    #5000;
    display_result();

    // 测试用例4: 1970年1月1日 00:00:00 (UTC) - unix时间戳的起点
    #10 unix_time = 64'd0;
    #5000;
    display_result();

    // 测试用例5: 2100年12月31日 23:59:59 (UTC)
    #10 unix_time = 64'd4133980799;
    #5000;
    display_result();

    // 新增的测试用例
    // 测试用例6: 2050年6月15日 08:30:00 (UTC)
    #10 unix_time = 64'd2540803800;
    #5000;
    display_result();

    // 测试用例7: 1999年12月31日 23:59:59 (UTC) - 千年虫问题前夕
    #10 unix_time = 64'd946684799;
    #5000;
    display_result();

    // 测试用例8: 2023年10月31日 12:00:00 (UTC) - 万圣节
    #10 unix_time = 64'd1698753600;
    #5000;
    display_result();

    // 测试用例9: 2024年2月29日 15:45:30 (UTC) - 闰年
    #10 unix_time = 64'd1709220330;
    #5000;
    display_result();

    // 测试用例10: 2077年7月7日 07:07:07 (UTC) - 特殊日期 cyberpunk2077 :)
    #10 unix_time = 64'd3392631227;
    #5000;
    display_result();

    $finish;
  end

  // 显示结果的任务
  task display_result;
    begin
      $display("Unix时间戳: %d", unix_time);
      $display("转换结果: %d年%d月%d日 %d:%02d:%02d (星期%d)", year, month, day, hour,
               minute, second, weekday);
      $display("状态: %d", state);
      $display("------------------------");
    end
  endtask

endmodule
