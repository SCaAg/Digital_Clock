`timescale 1ns / 1ps

// This module has been tested in sim_1/new/tb_time2stamp.v and it works well.

module time2stamp (
    input  wire [15:0] year_bcd,
    input  wire [ 7:0] month_bcd,
    input  wire [ 7:0] day_bcd,
    input  wire [ 7:0] hour_bcd,
    input  wire [ 7:0] minute_bcd,
    input  wire [ 7:0] second_bcd,
    output wire [63:0] time_stamp
);
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;
  assign year = year_bcd[15:12] * 1000 + year_bcd[11:8] * 100 + year_bcd[7:4] * 10 + year_bcd[3:0];
  assign month = month_bcd[7:4] * 10 + month_bcd[3:0];
  assign day = day_bcd[7:4] * 10 + day_bcd[3:0];
  assign hour = hour_bcd[7:4] * 10 + hour_bcd[3:0];
  assign minute = minute_bcd[7:4] * 10 + minute_bcd[3:0];
  assign second = second_bcd[7:4] * 10 + second_bcd[3:0];
  // Intermediate signals

  wire [31:0] leap_years;
  wire [ 8:0] days_in_months;
  wire [31:0] days;
  wire [63:0] seconds;


  // Leap year calculation
  assign leap_years = (year - 1969) / 4 - (year - 1901) / 100 + (year - 1601) / 400;

  // Days in previous months of the current year
  assign days_in_months = (month == 1) ? 0 :
                          (month == 2) ? 31 :
                          (month == 3) ? 59 :
                          (month == 4) ? 90 :
                          (month == 5) ? 120 :
                          (month == 6) ? 151 :
                          (month == 7) ? 181 :
                          (month == 8) ? 212 :
                          (month == 9) ? 243 :
                          (month == 10) ? 273 :
                          (month == 11) ? 304 : 334;

  // Days since 1970-01-01
  assign days = (year - 1970) * 365 + leap_years + days_in_months + (day - 1);

  // Handle leap year day adjustment if after February in a leap year
  wire is_leap_year = ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) ? 1 : 0;
  wire [31:0] all_days;
  assign all_days = (month > 2 && is_leap_year) ? days + 1 : days;

  // Convert days to seconds and add hours, minutes, and seconds
  assign seconds = all_days * 86400 + hour * 3600 + minute * 60 + second;

  // Output timestamp
  assign time_stamp = seconds;

endmodule
