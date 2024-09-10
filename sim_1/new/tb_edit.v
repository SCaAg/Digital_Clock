`timescale 1ns / 1ps

module tb_edit ();

  // 定义输入信号
  reg clk;
  reg rst_n;
  reg [3:0] state;
  reg down_btn;
  reg [15:0] year_bcd_in;
  reg [7:0] month_bcd_in;
  reg [7:0] day_bcd_in;
  reg [7:0] hour_bcd_in;
  reg [7:0] minute_bcd_in;
  reg [7:0] second_bcd_in;

  // 定义输出信号
  wire [15:0] year_bcd_out;
  wire [7:0] month_bcd_out;
  wire [7:0] day_bcd_out;
  wire [7:0] hour_bcd_out;
  wire [7:0] minute_bcd_out;
  wire [7:0] second_bcd_out;

  // 实例化被测模块
  edit uut (
      .clk(clk),
      .rst_n(rst_n),
      .state(state),
      .down_btn(down_btn),
      .year_bcd_in(year_bcd_in),
      .month_bcd_in(month_bcd_in),
      .day_bcd_in(day_bcd_in),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .year_bcd_out(year_bcd_out),
      .month_bcd_out(month_bcd_out),
      .day_bcd_out(day_bcd_out),
      .hour_bcd_out(hour_bcd_out),
      .minute_bcd_out(minute_bcd_out),
      .second_bcd_out(second_bcd_out)
  );

  // 时钟生成
  always begin
    #5 clk = ~clk;
  end

  // 测试过程
  initial begin
    // 初始化输入
    clk = 0;
    rst_n = 0;
    state = 4'd0;
    down_btn = 1;
    year_bcd_in = 16'h2023;
    month_bcd_in = 8'h05;
    day_bcd_in = 8'h15;
    hour_bcd_in = 8'h12;
    minute_bcd_in = 8'h30;
    second_bcd_in = 8'h45;

    // 复位
    #10 rst_n = 1;

    // 测试秒编辑
    #10 state = 4'd2;  // TIME_EDIT_SECOND
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 测试分钟编辑
    #10 state = 4'd3;  // TIME_EDIT_MINUTE
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 测试小时编辑
    #10 state = 4'd4;  // TIME_EDIT_HOUR
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 测试日期编辑
    #10 state = 4'd5;  // TIME_EDIT_DAY
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 测试月份编辑
    #10 state = 4'd6;  // TIME_EDIT_MONTH
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 测试年份编辑
    #10 state = 4'd7;  // TIME_EDIT_YEAR
    #10 down_btn = 0;
    #10 down_btn = 1;

    // 结束仿真
    #10 $finish;
  end

  // 监视输出
  initial begin
    $monitor(
        "Time=%0t, State=%0d, Down_btn=%0b, Year=%0h, Month=%0h, Day=%0h, Hour=%0h, Minute=%0h, Second=%0h",
        $time, state, down_btn, year_bcd_out, month_bcd_out, day_bcd_out, hour_bcd_out,
        minute_bcd_out, second_bcd_out);
  end

endmodule
