`timescale 1ns / 1ps
// This module has been tested in sim_1/new/tb_unixCounter.v and it works.


module unixCounter #(
    parameter N = 64,  //计数器位数
    parameter M = 26
)  //分频计数器位数
(
    input clk,
    reset_n,
    load_n,
    go,
    input [N-1:0] setCounter,
    output reg [N-1:0] counter
);
  reg [M-1:0] fenpingCounter;
  wire clk1Hz;
  localparam fenpingM = 50000000;
  //localparam fenpingM=5;
  //localparam fenpingM=5000000;
  initial begin
    fenpingCounter = 64'b0;
    counter = 64'b0;
  end

  //分频计数器加
  always @(posedge clk) begin
    if (!reset_n) begin
      counter <= 0;
      fenpingCounter <= 0;
    end else if (!load_n) begin
      counter <= setCounter;
      fenpingCounter <= 0;
    end else if (go)
      if (fenpingCounter < fenpingM) fenpingCounter <= fenpingCounter + 1;
      else fenpingCounter <= 0;
    if (clk1Hz) counter <= counter + 1;
  end

  assign clk1Hz = (fenpingCounter == fenpingM) ? 1'b1 : 1'b0;

endmodule
