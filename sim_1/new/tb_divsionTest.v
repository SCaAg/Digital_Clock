`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 09:43:42
// Design Name: 
// Module Name: tb_divsionTest
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


module tb_divsionTest();
    reg clk;
    reg[63:0] time_counter;
    reg[63:0] result1,result2;
    localparam N=1023;
    initial begin
        clk=0;
        time_counter=65478898;
        forever #5 clk=~clk;
    end
    always @(posedge clk) begin
        result1=time_counter/N;
        result2=time_counter%N;
    end
endmodule
