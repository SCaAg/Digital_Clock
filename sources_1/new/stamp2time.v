`timescale 1ns / 1ps
// This module has been tested in sim_1/new/tb_stamp2time.v and it works.

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

  bin2bcd #(
      .W(14)
  ) bin2bcd1 (
      .bin(year),
      .bcd(year_bcd)
  );

  assign month_bcd[7:5] = 3'b000;
  bin2bcd #(
      .W(4)
  ) bin2bcd2 (
      .bin(month),
      .bcd(month_bcd[4:0])
  );

  assign day_bcd[7:6] = 2'b00;
  bin2bcd #(
      .W(5)
  ) bin2bcd3 (
      .bin(day),
      .bcd(day_bcd[5:0])
  );

  assign hour_bcd[7:6] = 2'b00;
  bin2bcd #(
      .W(5)
  ) bin2bcd4 (
      .bin(hour),
      .bcd(hour_bcd[5:0])
  );

  assign minute_bcd[7] = 1'b0;
  bin2bcd #(
      .W(6)
  ) bin2bcd5 (
      .bin(minute),
      .bcd(minute_bcd[6:0])
  );

  assign second_bcd[7] = 1'b0;
  bin2bcd #(
      .W(6)
  ) bin2bcd6 (
      .bin(second),
      .bcd(second_bcd[6:0])
  );

endmodule
