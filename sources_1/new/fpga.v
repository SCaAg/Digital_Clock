`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 09:53:19
// Design Name: 
// Module Name: fpga
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


module fpga (
    input clk,
    input reset_n,
    input btn0,
    output [7:0] seg,
    output [7:0] an
);


  wire [3:0] led1Number;
  wire [3:0] led2Number;
  wire [3:0] led3Number;
  wire [3:0] led4Number;
  wire [3:0] led5Number;
  wire [3:0] led6Number;
  wire [3:0] led7Number;
  wire [3:0] led8Number;
  wire [7:0] point;


  reg display_year = 1'b0;



  reg go = 1'b1;
  reg load_n = 1'b1;
  wire [63:0] counter;
  unixCounter unixCounter1 (
      .clk(clk),
      .reset_n(reset_n),
      .go(go),
      .load_n(load_n),
      .counter(counter)
  );

  wire [39:0] display_bcd;

  assign {led8Number,led7Number,led6Number,led5Number,led4Number,led3Number,led2Number,led1Number,point} = display_bcd;

  ledScan ledScan1 (
      .clk(clk),
      .reset_n(reset_n),
      .led1Number(led1Number),
      .led2Number(led2Number),
      .led3Number(led3Number),
      .led4Number(led4Number),
      .led5Number(led5Number),
      .led6Number(led6Number),
      .led7Number(led7Number),
      .led8Number(led8Number),
      .point(point),
      .ledCode(seg),
      .an(an)
  );
endmodule
