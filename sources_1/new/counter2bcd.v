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


module counter2bcd (
    input wire clk,
    input wire rst_n,
    input wire [63:0] counter,
    input wire display_year,
    output reg [39:0] eight_segment,
    output wire [5:0] second_out
);



  wire [13:0] year;
  wire [ 3:0] month;  // 输出范围 1~12
  wire [ 4:0] day;  // 输出范围 1~31
  wire [ 2:0] weekday;  // 输出范围 0~6 (代表星期天~星期六)
  wire [ 4:0] hour;  // 输出范围 0~23
  wire [ 5:0] minute;  // 输出范围 0~59
  wire [ 5:0] second;  // 输出范围 0~59
  assign second_out = second;


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

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      eight_segment <= 40'd0;
    end else begin
      if (display_year) begin
        eight_segment <= {year_bcd, month_bcd, day_bcd, 8'b11101010};
      end else begin
        eight_segment <= {hour_bcd, 4'd10, minute_bcd, 4'd10, second_bcd, 8'b11111111};
      end
    end
  end

endmodule
