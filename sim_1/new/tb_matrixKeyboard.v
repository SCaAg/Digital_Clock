`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 14:46:41
// Design Name: 
// Module Name: tb_matrixKeyboard
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
/*
	input clk,  //50MHZ
	input reset_n, //��λ�ߵ�ƽ��Ч
	input [3:0] row,  //��
	output reg [3:0] col,   //��
	output key_valid,
	output reg [3:0] key_code  //��ֵ
*/
module tb_matrixKeyboard();
    reg clk;
    reg reset_n;
    reg [3:0] row;

    reg[7:0] point;
    reg[3:0] led1Number=0;
    reg[3:0] led2Number=0;
    reg[3:0] led3Number=0;
    reg[3:0] led4Number=0;
    reg[3:0] led5Number=0;
    reg[3:0] led6Number=0;
    reg[3:0] led7Number=0;
    reg[3:0] led8Number=0;

    ledScan ledScan1(
        .clk(clk),
        .reset_n(reset_n),
        .led1Number(led1Number),
        .led2Number(led2Number),
        .led3Number(led3Number),
        .led4Number(led4Number),
        .led5Number(led5Number),
        .led6Number(led6Number),
        .led7Number(led7Number),
        .led8Number(led8Number),
        .point(point),
        .ledCode(seg),
        .an(an)
    );

    wire [3:0] key_code;
    wire key_vaild;
    matrixKeyboard matrixKeyboard1(
        .clk(clk),
        .reset_n(reset_n),
        .row(row),
        .col(col),
        .key_code(key_code),
        .key_vaild(key_vaild)
    );

    always @*begin
        if (key_vaild) begin
            led8Number=1;
        end
        else begin
            led8Number=0;
        end
    end

    initial begin
        clk = 0;
        reset_n=0;
        row=4'b0111;
        #100 reset_n=1;
        #500 row=4'b1011;
        #500 row=4'b1111;
        #1000 $stop;
    end
    always
        begin
            #10 clk=~clk;
        end
endmodule
