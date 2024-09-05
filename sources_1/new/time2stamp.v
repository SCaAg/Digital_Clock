`timescale 1ns / 1ps

// This module has been tested in sim_1/new/tb_time2stamp.v and it works well.

module time2stamp (
    input  wire [13:0] year,
    input  wire [ 3:0] month,
    input  wire [ 4:0] day,
    input  wire [ 4:0] hour,
    input  wire [ 5:0] minute,
    input  wire [ 5:0] second,
    output wire [63:0] time_stamp
);

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
