`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 16:14:50
// Design Name: 
// Module Name: counter2bcd
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


module stamp2time (
    //--basic input--//
    input wire clk,
    input wire rst_n,
    //--Unix time stamp--//
    input wire [63:0] counter,
    //--output time in bcd code--//
    output wire [15:0] year_bcd,
    output wire [7:0] month_bcd,
    output wire [7:0] day_bcd,
    output wire [7:0] hour_bcd,
    output wire [7:0] minute_bcd,
    output wire [7:0] second_bcd
);

  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 2:0] weekday;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;

  unix64_to_UTC unix64_to_UTC1 (
      .clk(clk),
      .rst_n(rst_n),
      .unix_time(counter),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second)
  );

  bin2bcd #(14) bin2bcd1 (
      .bin(year),
      .bcd(year_bcd)
  );

  bin2bcd #(4) bin2bcd2 (
      .bin(month),
      .bcd(month_bcd)
  );

  bin2bcd #(3) bin2bcd3 (
      .bin(day),
      .bcd(day_bcd)
  );

  bin2bcd #(5) bin2bcd4 (
      .bin(hour),
      .bcd(hour_bcd)
  );

  bin2bcd #(6) bin2bcd5 (
      .bin(minute),
      .bcd(minute_bcd)
  );

  bin2bcd #(6) bin2bcd6 (
      .bin(second),
      .bcd(second_bcd)
  );

endmodule
