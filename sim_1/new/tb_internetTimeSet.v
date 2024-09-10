`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/09 16:18:11
// Design Name: 
// Module Name: tb_internetTimeSet
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


module tb_internetTimeSet();
    reg reset_n;
    reg clk;
    reg en;

    fpga_uart2 uut(
        .clk(clk),
        .reset_n(reset_n)
    );

    initial begin
        clk = 0;
        reset_n = 0;
        en=0;
        #1000 reset_n=1;
        #1000 en=1;
    end

    always #10 clk = ~clk;
endmodule
