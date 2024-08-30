`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/25 10:36:24
// Design Name: 
// Module Name: tb_unixCounter
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


module tb_unixCounter();
    reg clk;
    reg reset_n;
    reg load_n;
    reg go;
    reg [63:0] inputcounter;
    unixCounter counter1(
        .clk(clk),
        .reset_n(reset_n),
        .load_n(load_n),
        .setCounter(inputcounter),
        .go(go)
    );
    
    initial 
        begin
            clk=0;
            reset_n=0;
            load_n=1;
            go=1;
            inputcounter=64'b11;
            #100 reset_n=1;
            #100 load_n=0;
            #100 load_n=1;
            #1000 $stop;
        end
        
     always
        begin
            #10 clk=~clk;
        end
    
endmodule
