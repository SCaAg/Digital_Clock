`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/25 09:40:00
// Design Name: 
// Module Name: unixCounter
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


module unixCounter
  #(parameter N = 64, //计数器位数
    parameter M = 26) //分频计数器位数
    (
    input clk,reset_n,load_n,go,
    input [N-1:0] setCounter,
    output reg[N-1:0] counter
    );
    reg[M-1:0] fenpingCounter;
    wire clk1Hz;
    //localparam fenpingM=50000000;
    localparam fenpingM=5;
    initial 
        begin
            fenpingCounter=64'b0;
            counter=64'b1;
        end
    
    
    //分频计数器加
    always @(posedge clk)
        begin
        if(!reset_n)
            begin
                counter<=0;
                fenpingCounter<=0;
            end
        else if(!load_n)
            begin
                counter<=setCounter;
                fenpingCounter<=0;
            end
        else if(go)
            if(fenpingCounter<fenpingM)
                fenpingCounter<=fenpingCounter+1;
            else 
                fenpingCounter<=0;
        end
        
    
    assign clk1Hz=(fenpingCounter==fenpingM)? 1'b1:1'b0;
    
    //1Hz上升沿
    always @(posedge clk1Hz)
        counter<=counter+1;
        
endmodule
