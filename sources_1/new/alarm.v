`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 16:42:29
// Design Name: 
// Module Name: alarm
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


module alarm (
    //--basic input--//
    input wire clk,
    input wire rst_n,
    //---interface to set alarm---//
    input wire set,
    input wire [15:0] alarm_year_bcd,
    input wire [7:0] alarm_month_bcd,
    input wire [7:0] alarm_day_bcd,
    input wire [7:0] alarm_hour_bcd,
    input wire [7:0] alarm_minute_bcd,
    input wire [7:0] alarm_second_bcd,
    input wire [1:0] selected_alarm,
    //---access to the counter---//
    input wire [63:0] counter,
    //---display selected alarm---//
    output reg [7:0] alarm_hour_bcd,
    output reg [7:0] alarm_minute_bcd,
    output reg [7:0] alarm_second_bcd,
    //---ring--//
    input wire cancel,
    output reg ring
);
  //---alarm storage---//
  reg  [63:0] alarm0_stamp = 64'd0;
  reg  [63:0] alarm1_stamp = 64'd0;
  reg  [63:0] alarm2_stamp = 64'd0;

  //--convert alarm time to alarm stamp--//
  reg  [63:0] alarm_stamp_tmp;
  wire [15:0] year_bcd;
  wire [ 7:0] month_bcd;
  wire [ 7:0] day_bcd;
  wire [ 7:0] hour_bcd;
  wire [ 7:0] minute_bcd;
  wire [ 7:0] second_bcd;
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 2:0] weekday;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;

  stamp2time stamp2time0 (
      .clk(clk),
      .rst_n(rst_n),
      .counter(alarm_stamp_tmp),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second)
  );

  //--switch between 3 alarms--//
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      alarm_stamp_tmp <= alarm0_stamp;
    end else begin
      case (selected_alarm)
        2'd0: alarm_stamp_tmp <= alarm0_stamp;
        2'd1: alarm_stamp_tmp <= alarm0_stamp;
        2'd2: alarm_stamp_tmp <= alarm0_stamp;
        default: alarm_stamp_tmp <= alarm0_stamp;
      endcase
    end
  end

  //--output the converted alarm in bcd--//
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      alarm_hour_bcd   <= 8'b00000000;
      alarm_minute_bcd <= 8'b00000000;
      alarm_second_bcd <= 8'b00000000;

    end else begin
      alarm_year_bcd  <= year_bcd;
      alarm_month_bcd <= month_bcd;
      alarm_day_bcd   <= day_bcd;

    end
  end

  //--save the traget alarm if the set is 1--//
  wire [63:0] alarm2save;
  bcd_time2alarm_time bcd_time2alarm_time0 (
      .alarm_year_bcd(alarm_year_bcd),
      .alarm_month_bcd(alarm_month_bcd),
      .alarm_day_bcd(alarm_day_bcd),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .counter(counter),
      .alarm_stamp(alarm2save)
  );
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      alarm0_stamp <= 64'd0;
      alarm1_stamp <= 64'd0;
      alarm2_stamp <= 64'd0;
    end else if (set) begin
      case (selected_alarm)
        2'd0: alarm0_stamp <= alarm2save;
        2'd1: alarm1_stamp <= alarm2save;
        2'd2: alarm2_stamp <= alarm2save;
        default: alarm0_stamp <= alarm2save;
      endcase
    end
  end

  //--check to ring--//
  reg [2:0] ring_counter;
  reg [3:0] snooze_counter;
  reg ring;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      ring <= 1'b0;
      ring_counter <= 3'd0;
      snooze_counter <= 4'd0;
    end else begin
      if (ring) begin
        if (cancel) begin
          ring <= 1'b0;
          ring_counter <= 3'd0;
          snooze_counter <= 4'd0;
        end else if (ring_counter < 3'd5) begin
          ring_counter <= ring_counter + 1;
        end else if (snooze_counter < 4'd10) begin
          ring <= 1'b0;
          snooze_counter <= snooze_counter + 1;
        end else begin
          ring <= 1'b1;
          ring_counter <= 3'd0;
          snooze_counter <= 4'd0;
        end
      end else begin
        if ((counter == alarm0_stamp) || (counter == alarm1_stamp) || (counter == alarm2_stamp)) begin
          ring <= 1'b1;
          ring_counter <= 3'd0;
          snooze_counter <= 4'd0;
        end
      end
    end
  end


endmodule

