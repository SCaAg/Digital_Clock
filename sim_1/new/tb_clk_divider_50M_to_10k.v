`timescale 1ns / 1ps  // Define the time scale (1 ns step with precision of 1 ps)

module tb_clk_divider_50M_to_10k ();

  // Testbench signals
  reg  clk_in_50M;  // Input clock (50 MHz)
  reg  rst_n;  // Active-low reset
  wire clk_out_10k;  // Output clock (10 kHz)
  wire clk_out_1k;  // Output clock (1 kHz)

  // Instantiate the clock divider module
  clk_divider_50M_to_10k uut (
      .clk_in_50M(clk_in_50M),
      .rst_n(rst_n),
      .clk_out_10k(clk_out_10k),
      .clk_out_1k(clk_out_1k)
  );

  // Generate a 50 MHz clock (period = 20 ns)
  initial begin
    clk_in_50M = 0;
    forever #10 clk_in_50M = ~clk_in_50M;  // Toggle every 10 ns to create a 50 MHz clock
  end

  // Testbench sequence
  initial begin
    // Initialize signals
    rst_n = 0;
    #50;  // Wait for 50 ns

    rst_n = 1;  // Deassert reset

    // Simulation will run for some time to observe the 10 kHz output
    #500000;  // Run simulation for 500,000 ns (enough time to observe the output clock)

    $stop;  // Stop the simulation
  end

endmodule
