`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 01:29:18
// Design Name: 
// Module Name: clock_interface
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

module clock_interface (
    input wire clk,
    input wire rst_n,
    input wire up_btn,
    input wire down_btn,
    input wire mode_btn,
    input wire adjust_btn,
    output [7:0] seg,
    output [7:0] an
);
  // 实例化 unixCounter 模块
  wire [63:0] counter;
  wire [63:0] setCounter;
  wire load_n, go;
  wire clk_out_10k, clk_out_1k;
  clk_divider_50M_to_10k clk_divider_50M_to_10k_inst (
      .clk_in_50M(clk),
      .rst_n(rst_n),
      .clk_out_10k(clk_out_10k),
      .clk_out_1k(clk_out_1k)
  );

  unixCounter #(
      .N(64),
      .M(26)
  ) unixCounter_inst (
      .clk(clk),
      .reset_n(rst_n),
      .load_n(load_n),
      .go(go),
      .setCounter(setCounter),
      .counter(counter)
  );

  // 实例化 state_machine 模块
  wire [3:0] state;

  state_machine state_machine_inst (
      .clk(clk_out_10k),
      .rst_n(rst_n),
      .adjust_btn(adjust_btn),
      .mode_btn(mode_btn),
      .state(state)
  );

  // 实例化 led_interface 模块
  wire set_counter;
  wire ring;
  wire [3:0] led0, led1, led2, led3, led4, led5, led6, led7;
  wire [63:0] counter_out;
  wire [7:0] dot_reg, blink_reg;

  led_interface led_interface_inst (
      .clk(clk_out_10k),
      .rst_n(rst_n),
      .state(state),
      .counter(counter),
      .set_counter(set_counter),
      .up_btn(up_btn),
      .down_btn(down_btn),
      .ring(ring),
      .led0(led0),
      .led1(led1),
      .led2(led2),
      .led3(led3),
      .led4(led4),
      .led5(led5),
      .led6(led6),
      .led7(led7),
      .counter_out(counter_out),
      .dot_reg(dot_reg),
      .blink_reg(blink_reg)
  );

  // 连接 unixCounter 和 led_interface
  assign load_n = ~set_counter;
  assign setCounter = counter_out;
  assign go = 1'b1;  // 假设计数器始终运行

  // 实例化 ledScan 模块来驱动数码管显示
  ledScan ledScan_inst (
      .clk(clk_out_10k),
      .reset_n(rst_n),
      .led0(led0),
      .led1(led1),
      .led2(led2),
      .led3(led3),
      .led4(led4),
      .led5(led5),
      .led6(led6),
      .led7(led7),
      .dot(dot_reg),
      .blink(blink_reg),
      .ledCode(seg),
      .an(an)
  );

endmodule
