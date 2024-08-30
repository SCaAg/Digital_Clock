`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 16:30:43
// Design Name: 
// Module Name: keyState
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
//输入 clk 时钟 key_vaild 按键是否有效 key_code 按键编码 
//输出 key0_state key1_state key2_state key3_state key4_state key5_state 按键状态
//按键状态 0：按键释放 1：按键短按 2：按键释放 3：按键长按

module keyState(
    input clk,
    input reset_n,
    input key_vaild,
    input [3:0]key_code,
    output reg [3:0]key0_state,
    output reg [3:0]key1_state,
    output reg [3:0]key2_state,
    output reg [3:0]key3_state,
    output reg [3:0]key4_state,
    output reg [3:0]key5_state
    );
    reg[26-1:0] fenpingCounter;
    localparam fenpingM=50000;
    //localparam fenpingM=2;
    wire clk_1kHz; //1kHz分频
    always @(posedge clk) begin
        if(!reset_n)begin
            fenpingCounter<=0;
        end
        else if(fenpingCounter<fenpingM)begin
            fenpingCounter<=fenpingCounter+1;
        end
        else begin
            fenpingCounter<=0;
        end
    end
    assign clk_1kHz=(fenpingCounter==fenpingM)?1'b1:1'b0;

    always @(posedge clk_1kHz)begin
        if(key_vaild)begin
            case(key_code)
                4'b0000:begin
                    key0_state<=1;
                end
                4'b0001:begin
                    key1_state<=1;
                end
                4'b0010:begin
                    key2_state<=1;
                end
                4'b0011:begin
                    key3_state<=1;
                end
                4'b0100:begin
                    key4_state<=1;
                end
                4'b0101:begin
                    key5_state<=1;
                end
            endcase
        end
        else begin
            key0_state<=0;
            key1_state<=0;
            key2_state<=0;
            key3_state<=0;
            key4_state<=0;
            key5_state<=0;
        end
    end

endmodule
