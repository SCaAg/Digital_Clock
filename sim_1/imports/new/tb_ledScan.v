`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/25 12:33:46
// Design Name: 
// Module Name: tb_ledScan
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


module tb_ledScan();
    reg clk,reset_n;
    reg [3:0] led1Number,led2Number,led3Number,led4Number,led5Number,led6Number,led7Number,led8Number;
    reg [7:0] point;
    ledScan ledscan1(
        .led1Number(led1Number),
        .led2Number(led2Number),
        .led3Number(led3Number),
        .led4Number(led4Number),
        .led5Number(led5Number),
        .led6Number(led6Number),
        .led7Number(led7Number),
        .led8Number(led8Number),
        .clk(clk),
        .reset_n(reset_n),
        .point(point)
    );
    
    initial
        begin
            led1Number=4'h1;
            led2Number=4'h2;
            led3Number=4'h3;
            led4Number=4'h4;
            led5Number=4'h5;
            led6Number=4'h6;
            led7Number=4'h7;
            led8Number=4'h8;
            point=8'b00010000;
            clk=0;
            reset_n=0;
            #100 reset_n=1;
            #1000 $stop;
        end
    always
        begin
            #10 clk=~clk;
        end
endmodule
