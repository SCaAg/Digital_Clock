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
    input clk,
    reset_n,
    input [3:0] led1Number,
    led2Number,
    led3Number,
    led4Number,
    led5Number,
    led6Number,
    led7Number,
    led8Number,
    input [7:0] point,
    output reg [7:0] ledCode,
    output reg [7:0] an,
    input is_shine,
    input [7:0] which_shine
);
  // N = 16;
  localparam N=3;
  reg [N-1:0] regN;
  reg [3:0] hexin;
  reg dp;

  reg[25:0] clk_500Hz_counter;
  localparam clk_500Hz_M=25000000;
  //localparam clk_500Hz_M=10;
  reg clk_500Hz=0;



  always @(posedge clk)begin
    if(!reset_n) clk_500Hz_counter<=0;
    else if(clk_500Hz_counter<clk_500Hz_M) clk_500Hz_counter<=clk_500Hz_counter+1;
    else clk_500Hz_counter<=0;
    if(clk_500Hz_counter==clk_500Hz_M) clk_500Hz<=~clk_500Hz;
  end

  

  always @(posedge clk)
    if (!reset_n) regN <= 0;
    else regN <= regN + 1;
  always @*
    case (regN[N-1:N-3])
      //片选高平使能
      3'b000: begin
        an =(is_shine&&which_shine[0])?(clk_500Hz?8'b11111110:8'b11111111):8'b11111110;
        hexin = led1Number;
        dp = point[0];
      end
      3'b001: begin
        an =(is_shine&&which_shine[1])?(clk_500Hz?8'b11111101:8'b11111111):8'b11111101;
        hexin = led2Number;
        dp = point[1];
      end
      3'b010: begin
        an =(is_shine&&which_shine[2])?(clk_500Hz?8'b11111011:8'b11111111):8'b11111011;
        hexin = led3Number;
        dp = point[2];
      end
      3'b011: begin
        an =(is_shine&&which_shine[3])?(clk_500Hz?8'b11110111:8'b11111111):8'b11110111;
        hexin = led4Number;
        dp = point[3];
      end
      3'b100: begin
        an =(is_shine&&which_shine[4])?(clk_500Hz?8'b11101111:8'b11111111):8'b11101111;
        hexin = led5Number;
        dp = point[4];
      end
      3'b101: begin
        an =(is_shine&&which_shine[5])?(clk_500Hz?8'b11011111:8'b11111111):8'b11011111;
        hexin = led6Number;
        dp = point[5];
      end
      3'b110: begin
        an =(is_shine&&which_shine[6])?(clk_500Hz?8'b10111111:8'b11111111):8'b10111111;
        hexin = led7Number;
        dp = point[6];
      end
      3'b111: begin
        an =(is_shine&&which_shine[7])?(clk_500Hz?8'b01111111:8'b11111111):8'b01111111;
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
      4'b1010: ledCode[6:0] = 7'b0111_111;  //7'b1110_111;
      4'b1011: ledCode[6:0] = 7'b1111_111;  //7'b1111_100;
      4'b1100: ledCode[6:0] = 7'b1000_110;  //7'b0111_001;
      4'b1101: ledCode[6:0] = 7'b0100_001;  //7'b1011_110;
      4'b1110: ledCode[6:0] = 7'b0000_110;  //7'b1111_001;
      4'b1111: ledCode[6:0] = 7'b0001_110;  //7'b1110_001;
      default: ledCode[6:0] = 7'b1000_000;  //7'b0111_111;
    endcase
    ledCode[7] = dp;
  end
endmodule
