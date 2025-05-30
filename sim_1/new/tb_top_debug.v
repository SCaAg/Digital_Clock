`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 23:21:45
// Design Name: 
// Module Name: tb_top_debug
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_top_debug ();
  localparam TIME_DISP = 4'd0;
  localparam DATE_DISP = 4'd1;
  localparam TIME_EDIT_SECOND = 4'd2;
  localparam TIME_EDIT_MINUTE = 4'd3;
  localparam TIME_EDIT_HOUR = 4'd4;
  localparam TIME_EDIT_DAY = 4'd5;
  localparam TIME_EDIT_MONTH = 4'd6;
  localparam TIME_EDIT_YEAR = 4'd7;
  localparam ALARM_DISP = 4'd8;
  localparam ALARM_EDIT_SECOND = 4'd9;
  localparam ALARM_EDIT_MINUTE = 4'd10;
  localparam ALARM_EDIT_HOUR = 4'd11;
  localparam TIMER_DISP = 4'd12;
  localparam TIMER_EDIT_SECOND = 4'd13;
  localparam TIMER_EDIT_MINUTE = 4'd14;
  localparam TIMER_EDIT_HOUR = 4'd15;

  // 定义输入信号
  reg clk;
  reg rst_n;
  reg [3:0] state;
  reg [63:0] counter;
  reg up_btn;
  reg down_btn;

  // 定义输出信号
  wire set_counter;
  wire ring;
  wire [3:0] led0, led1, led2, led3, led4, led5, led6, led7;
  wire [ 7:0] blink;
  wire [ 7:0] dot;
  wire [63:0] counter_out;

  // 实例化被测试模块
  led_interface uut (
      .clk(clk),
      .rst_n(rst_n),
      .state(state),
      .counter(counter),
      .up_btn(up_btn),
      .down_btn(down_btn),
      .set_counter(set_counter),
      .ring(ring),
      .led0({blink[0], dot[0], led0}),
      .led1({blink[1], dot[1], led1}),
      .led2({blink[2], dot[2], led2}),
      .led3({blink[3], dot[3], led3}),
      .led4({blink[4], dot[4], led4}),
      .led5({blink[5], dot[5], led5}),
      .led6({blink[6], dot[6], led6}),
      .led7({blink[7], dot[7], led7}),
      .counter_out(counter_out)
  );

  // 时钟生成
  always begin
    #100 clk = ~clk;
  end

  // 定义一个任务来模拟按下up_btn
  task press_up_btn;
    begin
      up_btn = 0;
      #200;
      up_btn = 1;
    end
  endtask


  // 定义一个任务来模拟按下up_btn
  task press_down_btn;
    begin
      down_btn = 0;
      #100;
      down_btn = 1;
    end
  endtask

  // 测试过程
  initial begin
    // 初始化输入
    clk = 0;
    rst_n = 0;
    state = TIME_DISP;
    counter = 64'd1625097600;  // 2021-07-01 12:00:00
    up_btn = 1;
    down_btn = 1;

    // 复位
    #100 rst_n = 1;

    #5000 $display("current time:%h%h%h%h%h%h%h%h", led7, led6, led5, led4, led3, led2, led1, led0);
    #5000 state = DATE_DISP;
    $finish;
  end



endmodule
