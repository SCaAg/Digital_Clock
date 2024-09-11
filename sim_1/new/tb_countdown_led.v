`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 23:50:57
// Design Name: 
// Module Name: tb_countdown_led
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


module tb_countdown_led();
    reg clk;  //需要1khz时钟
    reg reset_n;
    reg ring;
    countdown_led countdown_led1(
    .clk(clk),
    .reset_n(reset_n),
    .ring(ring)
    );
    initial begin
        clk = 0;
        reset_n = 0;
        ring = 0;
        #10000 reset_n = 1;
        #500000 ring = 1;
        #2500 ring=0;
    end
    always #10 clk = ~clk;
endmodule
