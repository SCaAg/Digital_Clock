// This module has been tested in sim_1/new/tb_bcd2alarm.v and it works.
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


  wire [63:0] alarm_stamp_tmp;

  // Instantiate time2stamp module
  time2stamp time2stamp0 (
      .year_bcd(alarm_year_bcd),
      .month_bcd(alarm_month_bcd),
      .day_bcd(alarm_day_bcd),
      .hour_bcd(alarm_hour_bcd),
      .minute_bcd(alarm_minute_bcd),
      .second_bcd(alarm_second_bcd),
      .time_stamp(alarm_stamp_tmp)  // Ensure this matches the port name in time2stamp module
  );

  // Generate final alarm timestamp
  assign alarm_stamp = alarm_stamp_tmp > counter ? alarm_stamp_tmp : alarm_stamp_tmp + 64'd86400;

endmodule
