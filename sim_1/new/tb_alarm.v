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
  always #1 clk = ~clk;
  always #2 counter = counter + 1;

  // 测试过程
  initial begin
    // 初始化信号
    clk = 1;
    rst_n = 0;
    set = 0;
    counter = 64'd300;
    cancel = 0;

    // 复位
    #10 rst_n = 1;

    // 设置闹钟1
    alarm_year_bcd_in = 16'h2024;
    alarm_month_bcd_in = 8'h01;
    alarm_day_bcd_in = 8'h01;
    alarm_hour_bcd_in = 8'h00;
    alarm_minute_bcd_in = 8'h00;
    alarm_second_bcd_in = 8'h00;
    selected_alarm = 2'b00;
    #10 set = 1;
    #10 set = 0;

    // 设置闹钟2
    alarm_year_bcd_in = 16'h2024;
    alarm_month_bcd_in = 8'h01;
    alarm_day_bcd_in = 8'h01;
    alarm_hour_bcd_in = 8'h00;
    alarm_minute_bcd_in = 8'h00;
    alarm_second_bcd_in = 8'h20;
    selected_alarm = 2'b01;
    #10 set = 1;
    #10 set = 0;

    // 设置闹钟3
    alarm_year_bcd_in = 16'h2024;
    alarm_month_bcd_in = 8'h01;
    alarm_day_bcd_in = 8'h01;
    alarm_hour_bcd_in = 8'h00;
    alarm_minute_bcd_in = 8'h00;
    alarm_second_bcd_in = 8'h30;
    selected_alarm = 2'b10;
    #10 set = 1;
    #10 set = 0;

    //查看闹钟1
    selected_alarm = 2'b00;
    #100;
    $display("alarm_hour_bcd = %h, alarm_minute_bcd = %h, alarm_second_bcd = %h", alarm_hour_bcd,
             alarm_minute_bcd, alarm_second_bcd);
    //查看闹钟2
    selected_alarm = 2'b01;
    #100;
    $display("alarm_hour_bcd = %h, alarm_minute_bcd = %h, alarm_second_bcd = %h", alarm_hour_bcd,
             alarm_minute_bcd, alarm_second_bcd);
    //查看闹钟3
    selected_alarm = 2'b10;
    #100;
    $display("alarm_hour_bcd = %h, alarm_minute_bcd = %h, alarm_second_bcd = %h", alarm_hour_bcd,
             alarm_minute_bcd, alarm_second_bcd);

    // 触发闹钟1
    counter = 64'd1704067199;
    //闹钟1响，等待40个时钟周期
    #40;
    //闹钟2响，等待3个时钟周期后取消
    #3cancel = 1;
    #10 cancel = 0;
    //闹钟3响，等待3个时钟周期后取消


    // 结束仿真
    #100 $finish;
  end


endmodule
