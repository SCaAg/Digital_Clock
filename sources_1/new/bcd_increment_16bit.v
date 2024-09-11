`timescale 1ns / 1ps

// This module has been tested in sim_1/new/tb_bcd_increment_16bit.v and it works well.

module bcd_increment_16bit (
    input  wire [15:0] bcd_in,
    input  wire [15:0] bcd_max,
    output wire [15:0] bcd_out
);
  wire carry0, carry1, carry2;
  wire [15:0] bcd_tmp;

  // Increment least significant BCD digit
  bcd_adder bcd_adder_0 (
      .a(bcd_in[3:0]),
      .b(4'b0001),
      .cin(1'b0),
      .sum(bcd_tmp[3:0]),
      .cout(carry0)
  );

  // Propagate carry and increment next BCD digit
  bcd_adder bcd_adder_1 (
      .a(bcd_in[7:4]),
      .b(4'b0000),
      .cin(carry0),
      .sum(bcd_tmp[7:4]),
      .cout(carry1)
  );

  // Continue carry propagation and increment
  bcd_adder bcd_adder_2 (
      .a(bcd_in[11:8]),
      .b(4'b0000),
      .cin(carry1),
      .sum(bcd_tmp[11:8]),
      .cout(carry2)
  );

  // Increment most significant BCD digit
  bcd_adder bcd_adder_3 (
      .a(bcd_in[15:12]),
      .b(4'b0000),
      .cin(carry2),
      .sum(bcd_tmp[15:12]),
      .cout()  // `cout` is ignored
  );

  // Ensure correct BCD increment and reset if max value is reached
  assign bcd_out = (bcd_tmp >= bcd_max) ? 16'd0 : bcd_tmp;
endmodule

