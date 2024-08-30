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
  reg [7:0] point = 8'b0000_0000;



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





  wire [13:0] year;
  wire [ 3:0] month;  // 输出范围 1~12
  wire [ 4:0] day;  // 输出范围 1~31
  wire [ 2:0] weekday;  // 输出范围 0~6 (代表星期天~星期六)
  wire [ 4:0] hour;  // 输出范围 0~23
  wire [ 5:0] minute;  // 输出范围 0~59
  wire [ 5:0] second;  // 输出范围 0~59



  unix64_to_UTC unix64_to_UTC1 (
      .clk(clk),
      .rst_n(reset_n),
      .unix_time(counter),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second)
  );




  wire [15:0] year_bcd;
  bin2bcd #(14) bin2bcd1 (
      .bin(year),
      .bcd(year_bcd)
  );


  wire [7:0] month_bcd;
  bin2bcd #(4) bin2bcd2 (
      .bin(month),
      .bcd(month_bcd)
  );

  wire [7:0] day_bcd;
  bin2bcd #(3) bin2bcd3 (
      .bin(day),
      .bcd(day_bcd)
  );

  wire [7:0] hour_bcd;
  bin2bcd #(5) bin2bcd4 (
      .bin(hour),
      .bcd(hour_bcd)
  );

  wire [7:0] minute_bcd;
  bin2bcd #(6) bin2bcd5 (
      .bin(minute),
      .bcd(minute_bcd)
  );

  wire [7:0] second_bcd;
  bin2bcd #(6) bin2bcd6 (
      .bin(second),
      .bcd(second_bcd)
  );


  assign {led1Number, led2Number} = hour_bcd;
  assign led3Number = 'd10;
  assign {led4Number, led5Number} = minute_bcd;
  assign led6Number = 'd10;
  assign {led7Number, led8Number} = second_bcd;

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
