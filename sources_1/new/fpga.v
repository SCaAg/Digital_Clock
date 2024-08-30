`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 09:53:19
// Design Name: 
// Module Name: fpga
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


module fpga(
    input clk,
    input reset_n,
    output [7:0] seg,
    output [7:0] an
    );
    reg[3:0] led1Number;
    reg[3:0] led2Number;
    reg[3:0] led3Number;
    reg[3:0] led4Number;
    reg[3:0] led5Number;
    reg[3:0] led6Number;
    reg[3:0] led7Number;
    reg[3:0] led8Number;
    reg [7:0] point=8'b00000000;
    reg go=1;
    reg load_n=1;
    wire [63:0] counter;
    reg [63:0] dividecounter;
    unixCounter unixCounter1(
        .clk(clk),
        .reset_n(reset_n),
        .go(go),
        .load_n(load_n),
        .counter(counter)
    );
    reg [63:0] divideTemp2;
    reg [63:0] divideTemp3;
    reg [63:0] divideTemp4;
    reg [63:0] divideTemp5;
    reg [63:0] divideTemp6;
    reg [63:0] divideTemp7;
    reg [63:0] divideTemp8;
    always @(posedge clk) begin
        dividecounter<=counter;

        led1Number<=dividecounter%10;

        divideTemp2<=dividecounter/10;
        led2Number<=divideTemp2%10;

        divideTemp3<=dividecounter/100;
        led3Number<=divideTemp3%10;

        divideTemp4<=dividecounter/1000;
        led4Number<=divideTemp4%10;

        divideTemp5<=dividecounter/10000;
        led5Number<=divideTemp5%10;

        divideTemp6<=dividecounter/100000;
        led6Number<=divideTemp6%10;

        divideTemp7<=dividecounter/1000000;
        led7Number<=divideTemp7%10;

        divideTemp8<=dividecounter/10000000;
        led8Number<=divideTemp8%10;
    end
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
endmodule
