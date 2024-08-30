`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 16:48:17
// Design Name: 
// Module Name: tb_keyState
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


module tb_keyState();
    reg clk;
    reg reset_n;
    reg key_vaild;
    reg [3:0]key_code;

    keyState keyState1(
        .clk(clk),
        .reset_n(reset_n),
        .key_vaild(key_vaild),
        .key_code(key_code)
    );

    initial begin
        clk = 0;
        reset_n=0;
        key_vaild=0;
        key_code=4'b0000;
        #100 reset_n=1;
        #100 key_vaild=1;key_code=4'b0001;
        #100 key_vaild=0;
        #100 key_vaild=1;key_code=4'b0011;
        #100 key_vaild=0;
        #1000 $stop;
    end
    always
        begin
            #10 clk=~clk;
        end
endmodule
