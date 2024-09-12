`timescale 1ns / 1ps

// This module has been tested in sim_1/new/tb_alarm.v and it works well.

module alarm (
    //--basic input--//
    input wire clk,
    input wire rst_n,
    //---interface to set alarm---//
    input wire set,
    input wire [15:0] alarm_year_bcd_in,
    input wire [7:0] alarm_month_bcd_in,
    input wire [7:0] alarm_day_bcd_in,
    input wire [7:0] alarm_hour_bcd_in,
    input wire [7:0] alarm_minute_bcd_in,
    input wire [7:0] alarm_second_bcd_in,
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
  reg  [63:0] alarm0_stamp = 64'd946684799;
  reg  [63:0] alarm1_stamp = 64'd946684799;
  reg  [63:0] alarm2_stamp = 64'd2147483647;

  //--convert alarm time to alarm stamp--//
  reg  [63:0] alarm_stamp_tmp;
  wire [15:0] year_bcd;
  wire [ 7:0] month_bcd;
  wire [ 7:0] day_bcd;
  wire [ 7:0] hour_bcd;
  wire [ 7:0] minute_bcd;
  wire [ 7:0] second_bcd;

  stamp2time stamp2time0 (
      .clk(clk),
      .rst_n(rst_n),
      .counter(alarm_stamp_tmp),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd)
  );

  //--switch between 3 alarms--//
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      alarm_stamp_tmp <= alarm0_stamp;
    end else begin
      case (selected_alarm)
        2'b00:   alarm_stamp_tmp <= alarm0_stamp;
        2'b01:   alarm_stamp_tmp <= alarm1_stamp;
        2'b10:   alarm_stamp_tmp <= alarm2_stamp;
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
      alarm_hour_bcd   <= hour_bcd;
      alarm_minute_bcd <= minute_bcd;
      alarm_second_bcd <= second_bcd;
    end
  end

  //--save the traget alarm if the set is 1--//
  wire [63:0] alarm2save;
  bcd_time2alarm_time bcd_time2alarm_time0 (
      .alarm_year_bcd(alarm_year_bcd_in),
      .alarm_month_bcd(alarm_month_bcd_in),
      .alarm_day_bcd(alarm_day_bcd_in),
      .alarm_hour_bcd(alarm_hour_bcd_in),
      .alarm_minute_bcd(alarm_minute_bcd_in),
      .alarm_second_bcd(alarm_second_bcd_in),
      .counter(counter),
      .alarm_stamp(alarm2save)
  );

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      alarm0_stamp <= 64'd946684799;
      alarm1_stamp <= 64'd946684799;
      alarm2_stamp <= 64'd2147483647;
    end else if (set) begin
      case (selected_alarm)
        2'b00:   alarm0_stamp <= alarm2save;
        2'b01:   alarm1_stamp <= alarm2save;
        2'b10:   alarm2_stamp <= alarm2save;
        default: alarm0_stamp <= alarm2save;
      endcase
    end
  end

  //--check to ring--//
  reg [27:0] ring_counter;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      ring_counter <= 28'd0;
      ring <= 1'b0;
    end else begin
      if ((counter == alarm0_stamp) || (counter == alarm1_stamp) || (counter == alarm2_stamp)) begin
        ring <= 1'b1;
        ring_counter <= 28'd0;
      end else if (~cancel && ring) begin
        if (ring_counter < 28'd24999999) begin
          ring_counter <= ring_counter + 1;
          ring <= 1'b1;
        end else if (ring_counter < 28'd74999999) begin
          ring_counter <= ring_counter + 1;
          ring <= 1'b0;
        end else if (ring_counter < 28'd99999999) begin
          ring_counter <= ring_counter + 1;
          ring <= 1'b1;
        end else begin
          ring_counter <= 28'd0;
          ring <= 1'b0;
        end
      end else if (~cancel && ~ring && ring_counter >= 28'd24999999) begin
        if (ring_counter < 28'd74999999) begin
          ring_counter <= ring_counter + 1;
          ring <= 1'b0;
        end else begin
          ring_counter <= ring_counter + 1;
          ring <= 1'b1;
        end
      end else begin
        ring_counter <= 28'd0;
        ring <= 1'b0;
      end
    end
  end


endmodule

