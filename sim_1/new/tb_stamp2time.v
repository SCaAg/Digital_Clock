`timescale 1ns / 1ps

module stamp2time_tb;

  // Inputs
  reg clk;
  reg rst_n;
  reg [63:0] counter;

  // Outputs
  wire [15:0] year_bcd;
  wire [7:0] month_bcd;
  wire [7:0] day_bcd;
  wire [7:0] hour_bcd;
  wire [7:0] minute_bcd;
  wire [7:0] second_bcd;

  // Instantiate the Unit Under Test (UUT)
  stamp2time uut (
      .clk(clk),
      .rst_n(rst_n),
      .counter(counter),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd)
  );

  initial begin
    // Initialize Inputs
    clk = 0;
    rst_n = 0;
    counter = 64'd0;

    // Wait 100 ns for global reset to finish
    #100;
    rst_n   = 1;

    // Apply test cases
    // Example: Unix timestamp for 2023-10-27 10:30:00 UTC is 1698409800
    counter = 64'd1698409800;
    #5000;

    // Another example: Unix timestamp for 2000-01-01 00:00:00 UTC is 946684800
    counter = 64'd946684800;
    #5000;

    // Add more test cases as needed


    $finish;
  end

  always #1 clk = ~clk;

  always @(posedge clk) begin
    if (rst_n) begin
      $display("Time: Year=%d%d%d%d, Month=%d%d, Day=%d%d, Hour=%d%d, Minute=%d%d, Second=%d%d",
               year_bcd[15:12], year_bcd[11:8], year_bcd[7:4], year_bcd[3:0], month_bcd[7:4],
               month_bcd[3:0], day_bcd[7:4], day_bcd[3:0], hour_bcd[7:4], hour_bcd[3:0],
               minute_bcd[7:4], minute_bcd[3:0], second_bcd[7:4], second_bcd[3:0]);
    end
  end

endmodule
