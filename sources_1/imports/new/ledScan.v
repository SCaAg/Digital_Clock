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
module ledScan (
    input wire clk,
    input wire reset_n,
    input wire [3:0] led1Number,
    input wire [3:0] led2Number,
    input wire [3:0] led3Number,
    input wire [3:0] led4Number,
    input wire [3:0] led5Number,
    input wire [3:0] led6Number,
    input wire [3:0] led7Number,
    input wire [3:0] led8Number,
    input wire [7:0] point,
    output reg [7:0] ledCode,
    output reg [7:0] an
);
  //localparam N=16;
  localparam N = 3;
  reg [N-1:0] regN;
  reg [3:0] hexin;
  reg dp;
  always @(posedge clk)
    if (!reset_n) regN <= 0;
    else regN <= regN + 1;
  always @*
    case (regN[N-1:N-3])
      //片选高平使能
      3'b000: begin
        an = 8'b00000001;
        hexin = led1Number;
        dp = point[0];
      end
      3'b001: begin
        an = 8'b00000010;
        hexin = led2Number;
        dp = point[1];
      end
      3'b010: begin
        an = 8'b00000100;
        hexin = led3Number;
        dp = point[2];
      end
      3'b011: begin
        an = 8'b00001000;
        hexin = led4Number;
        dp = point[3];
      end
      3'b100: begin
        an = 8'b00010000;
        hexin = led5Number;
        dp = point[4];
      end
      3'b101: begin
        an = 8'b00100000;
        hexin = led6Number;
        dp = point[5];
      end
      3'b110: begin
        an = 8'b01000000;
        hexin = led7Number;
        dp = point[6];
      end
      3'b111: begin
        an = 8'b10000000;
        hexin = led8Number;
        dp = point[7];
      end
    endcase

  always @* begin
    case (hexin)
      4'b0000: ledCode[6:0] = 7'b1000_000;  //7'b0111_111;//七段译码
      4'b0001: ledCode[6:0] = 7'b1111_001;  //7'b0000_110;
      4'b0010: ledCode[6:0] = 7'b0100_100;  //7'b1011_011;
      4'b0011: ledCode[6:0] = 7'b0110_000;  //7'b1001_111;
      4'b0100: ledCode[6:0] = 7'b0011_001;  //7'b1100_110;
      4'b0101: ledCode[6:0] = 7'b0010_010;  //7'b1101_101;
      4'b0110: ledCode[6:0] = 7'b0000_010;  //7'b1111_101;
      4'b0111: ledCode[6:0] = 7'b1111_000;  //7'b0000_111;
      4'b1000: ledCode[6:0] = 7'b0000_000;  //7'b1111_111;
      4'b1001: ledCode[6:0] = 7'b0010_000;  //7'b1101_111;
      4'b1010: ledCode[6:0] = 7'b0001_000;  //7'b1110_111;
      4'b1011: ledCode[6:0] = 7'b0000_011;  //7'b1111_100;
      4'b1100: ledCode[6:0] = 7'b1000_110;  //7'b0111_001;
      4'b1101: ledCode[6:0] = 7'b0100_001;  //7'b1011_110;
      4'b1110: ledCode[6:0] = 7'b0000_110;  //7'b1111_001;
      4'b1111: ledCode[6:0] = 7'b0001_110;  //7'b1110_001;
      default: ledCode[6:0] = 7'b1000_000;  //7'b0111_111;
    endcase
    ledCode[7] = dp;
  end
endmodule
