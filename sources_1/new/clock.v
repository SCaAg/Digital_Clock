`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 21:29:05
// Design Name: 
// Module Name: clock
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
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 15:07:53
// Design Name: 
// Module Name: fpga_matrixKeyboard
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

//锟斤拷锟斤拷fpga锟斤拷锟斤拷
module clock (
    input clk,
    input reset_n,
    input key1,
    input key2,
    input key3,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg,
    output [7:0] an,
    output led,
    input rx_pin,
    output tx_pin,
    output sck,
    output mosi,
    output dc_out,
    output cs,
    output reset_oled

);
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  oledInterface oledInterface1 (
      .clk(clk),
      .reset_n(reset_n),
      .hour(hour),
      .minute(minute),
      .second(second),
      .sck(sck),
      .mosi(mosi),
      .dc_out(dc_out),
      .cs(cs),
      .reset_oled(reset_oled),
      .year(year),
      .month(month),
      .day(day)
  );

  wire [3:0] key_code;
  wire key_vaild;
  matrixKeyboard matrixKeyboard1 (
      .clk(clk),
      .reset_n(reset_n),
      .row(row),
      .col(col),
      .key_code(key_code),
      .key_vaild(key_vaild)
  );

  wire [3:0] key0_state;
  wire [3:0] key1_state;
  wire [3:0] key2_state;
  wire [3:0] key3_state;
  wire [3:0] key4_state;
  wire [3:0] key5_state;

  keyState keyState1 (
      .clk(clk),
      .reset_n(reset_n),
      .key_code(key_code),
      .key_vaild(key_vaild),
      .key0_state(key0_state),
      .key1_state(key1_state),
      .key2_state(key2_state),
      .key3_state(key3_state),
      .key4_state(key4_state),
      .key5_state(key5_state)
  );

  reg en;
  wire finished;
  wire [31:0] timeout;
  internetTimeSet uut (
      .clk(clk),
      .reset_n(reset_n),
      .en(en),
      .finished(finished),
      .tx_pin(tx_pin),
      .rx_pin(rx_pin),
      .timeout(timeout)
  );

  wire mode_btn;
  assign mode_btn = key5_state[0];
  wire adjust_btn;
  assign adjust_btn = key4_state[0];
  wire left_button;
  assign left_button = key0_state[0];
  wire right_button;
  assign right_button = key1_state[0];
  wire up_btn;
  assign up_btn = key2_state[0];
  wire down_btn;
  assign down_btn = key3_state[0];


  clock_interface clock_interface_inst (
      .clk(clk),
      .up_btn(up_btn),
      .down_btn(down_btn),
      .mode_btn(mode_btn),
      .adjust_btn(adjust_btn),
      .seg(seg),
      .an(an)
  );



endmodule

