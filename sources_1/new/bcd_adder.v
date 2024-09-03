`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 02:05:25
// Design Name: 
// Module Name: bcd_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bcd_adder (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire cin,
    output wire [3:0] sum,
    output wire cout

);
  reg [4:0] temp;
  reg [3:0] sum;
  reg cout;
  always @(a, b, cin) begin
    temp = a + b + cin;
    if (temp > 9) begin
      temp = temp + 6;  //add 6, if result is more than 9.
      cout = 1;  //set the carry output
      sum  = temp[3:0];
    end else begin
      cout = 0;
      sum  = temp[3:0];
    end
  end

endmodule
