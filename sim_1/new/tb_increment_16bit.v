module tb_bcd_increment_16bit;
  reg  [15:0] bcd_in;
  reg  [15:0] bcd_max;
  wire [15:0] bcd_out;

  // Instantiate the BCD increment module
  bcd_increment_16bit uut (
      .bcd_in (bcd_in),
      .bcd_max(bcd_max),
      .bcd_out(bcd_out)
  );

  // Helper task to display BCD numbers in four-digit format
  task display_bcd(input [15:0] bcd);
    $display("%d%d%d%d", bcd[15:12], bcd[11:8], bcd[7:4], bcd[3:0]);
  endtask

  initial begin
    // Set the maximum value for the BCD (for example: 9999)
    bcd_max = 16'h9999;  // Max BCD value is 9999

    // Test case 1: Increment from 0000
    bcd_in  = 16'h0000;  // Initial value 0000
    $display("Test Case 1: Initial bcd_in = ");
    display_bcd(bcd_in);
    #10;
    $display("Test Case 1: After increment, bcd_out = ");
    display_bcd(bcd_out);

    // Test case 2: Increment from 1234
    bcd_in = 16'h1234;  // Initial value 1234
    $display("Test Case 2: Initial bcd_in = ");
    display_bcd(bcd_in);
    #10;
    $display("Test Case 2: After increment, bcd_out = ");
    display_bcd(bcd_out);

    // Test case 3: Increment from 9999 (should reset to 0000)
    bcd_in = 16'h9999;  // Initial value 9999
    $display("Test Case 3: Initial bcd_in = ");
    display_bcd(bcd_in);
    #10;
    $display("Test Case 3: After increment, bcd_out = ");
    display_bcd(bcd_out);

    // Test case 4: Increment from 0999
    bcd_in = 16'h0999;  // Initial value 0999
    $display("Test Case 4: Initial bcd_in = ");
    display_bcd(bcd_in);
    #10;
    $display("Test Case 4: After increment, bcd_out = ");
    display_bcd(bcd_out);

    // Test case 5: Increment from 5678
    bcd_in = 16'h5678;  // Initial value 5678
    $display("Test Case 5: Initial bcd_in = ");
    display_bcd(bcd_in);
    #10;
    $display("Test Case 5: After increment, bcd_out = ");
    display_bcd(bcd_out);

    // End of simulation
    $stop;
  end
endmodule
