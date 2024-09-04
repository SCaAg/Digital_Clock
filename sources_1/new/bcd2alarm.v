module bcd_time2alarm_time (
    input  wire [15:0] alarm_year_bcd,
    input  wire [ 7:0] alarm_month_bcd,
    input  wire [ 7:0] alarm_day_bcd,
    input  wire [ 7:0] alarm_hour_bcd,
    input  wire [ 7:0] alarm_minute_bcd,
    input  wire [ 7:0] alarm_second_bcd,
    input  wire [63:0] counter,
    output wire [63:0] alarm_stamp
);
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;

  // BCD to binary conversion
  assign year = 1000 * alarm_year_bcd[15:12] + 100 * alarm_year_bcd[11:8] + 10 * alarm_year_bcd[7:4] + alarm_year_bcd[3:0];
  assign month = 10 * alarm_month_bcd[7:4] + alarm_month_bcd[3:0];
  assign day = 10 * alarm_day_bcd[7:4] + alarm_day_bcd[3:0];
  assign hour = 10 * alarm_hour_bcd[7:4] + alarm_hour_bcd[3:0];
  assign minute = 10 * alarm_minute_bcd[7:4] + alarm_minute_bcd[3:0];
  assign second = 10 * alarm_second_bcd[7:4] + alarm_second_bcd[3:0];

  wire [63:0] alarm_stamp_tmp;

  // Instantiate time2stamp module
  time2stamp time2stamp0 (
      .year(year),
      .month(month),
      .day(day),
      .hour(hour),
      .minute(minute),
      .second(second),
      .time_stamp(alarm_stamp_tmp)  // Ensure this matches the port name in time2stamp module
  );

  // Generate final alarm timestamp
  assign alarm_stamp = alarm_stamp_tmp > counter ? alarm_stamp_tmp : alarm_stamp_tmp + 64'd86400;

endmodule
