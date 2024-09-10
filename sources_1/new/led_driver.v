`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/25 11:55:21
// Design Name: 
// Module Name: ledScan
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

//LED扫描显示8个数码管
//小数点低电平有效
module ledScan (
    input wire clk,
    input wire reset_n,
    input wire [3:0] led0,
    input wire [3:0] led1,
    input wire [3:0] led2,
    input wire [3:0] led3,
    input wire [3:0] led4,
    input wire [3:0] led5,
    input wire [3:0] led6,
    input wire [3:0] led7,
    input wire [7:0] dot,
    input wire [7:0] blink,
    output reg [7:0] ledCode,
    output reg [7:0] an
);
  localparam N = 16;
  //localparam N=3;
  reg [N-1:0] regN;
  reg [3:0] hexin;
  reg dp;

  reg [25:0] clk_500Hz_counter;
  localparam clk_500Hz_M = 25000000;
  //localparam clk_500Hz_M=10;
  reg clk_500Hz = 0;



  always @(posedge clk) begin
    if (!reset_n) clk_500Hz_counter <= 0;
    else if (clk_500Hz_counter < clk_500Hz_M) clk_500Hz_counter <= clk_500Hz_counter + 1;
    else clk_500Hz_counter <= 0;
    if (clk_500Hz_counter == clk_500Hz_M) clk_500Hz <= ~clk_500Hz;
  end



  always @(posedge clk)
    if (!reset_n) regN <= 0;
    else regN <= regN + 1;
  always @*
    case (regN[N-1:N-3])
      //片选高平使能
      3'b000: begin
        an = (blink[0]) ? (clk_500Hz ? 8'b11111110 : 8'b11111111) : 8'b11111110;
        hexin = led0;
        dp = dot[0];
      end
      3'b001: begin
        an = (blink[1]) ? (clk_500Hz ? 8'b11111101 : 8'b11111111) : 8'b11111101;
        hexin = led1;
        dp = dot[1];
      end
      3'b010: begin
        an = (blink[2]) ? (clk_500Hz ? 8'b11111011 : 8'b11111111) : 8'b11111011;
        hexin = led2;
        dp = dot[2];
      end
      3'b011: begin
        an = (blink[3]) ? (clk_500Hz ? 8'b11110111 : 8'b11111111) : 8'b11110111;
        hexin = led3;
        dp = dot[3];
      end
      3'b100: begin
        an = (blink[4]) ? (clk_500Hz ? 8'b11101111 : 8'b11111111) : 8'b11101111;
        hexin = led4;
        dp = dot[4];
      end
      3'b101: begin
        an = (blink[5]) ? (clk_500Hz ? 8'b11011111 : 8'b11111111) : 8'b11011111;
        hexin = led5;
        dp = dot[5];
      end
      3'b110: begin
        an = (blink[6]) ? (clk_500Hz ? 8'b10111111 : 8'b11111111) : 8'b10111111;
        hexin = led6;
        dp = dot[6];
      end
      3'b111: begin
        an = (blink[7]) ? (clk_500Hz ? 8'b01111111 : 8'b11111111) : 8'b01111111;
        hexin = led7;
        dp = dot[7];
      end
    endcase

  always @* begin
    case (hexin)
      4'd0: ledCode[6:0] = 7'b1000_000;  //7'b0111_111;//七段译码
      4'd1: ledCode[6:0] = 7'b1111_001;  //7'b0000_110;
      4'd2: ledCode[6:0] = 7'b0100_100;  //7'b1011_011;
      4'd3: ledCode[6:0] = 7'b0110_000;  //7'b1001_111;
      4'd4: ledCode[6:0] = 7'b0011_001;  //7'b1100_110;
      4'd5: ledCode[6:0] = 7'b0010_010;  //7'b1101_101;
      4'd6: ledCode[6:0] = 7'b0000_010;  //7'b1111_101;
      4'd7: ledCode[6:0] = 7'b1111_000;  //7'b0000_111;
      4'd8: ledCode[6:0] = 7'b0000_000;  //7'b1111_111;
      4'd9: ledCode[6:0] = 7'b0010_000;  //7'b1101_111;
      4'd10: ledCode[6:0] = 7'b0111_111;  //7'b1110_111;
      4'd11: ledCode[6:0] = 7'b1111_111;  //7'b1111_100;
      4'd12: ledCode[6:0] = 7'b1000_110;  //7'b0111_001;
      4'd13: ledCode[6:0] = 7'b0100_001;  //7'b1011_110;
      4'd14: ledCode[6:0] = 7'b0000_110;  //7'b1111_001;
      4'd15: ledCode[6:0] = 7'b0001_110;  //7'b1110_001;
      default: ledCode[6:0] = 7'b1000_000;  //7'b0111_111;
    endcase
    ledCode[7] = dp;
  end
endmodule
