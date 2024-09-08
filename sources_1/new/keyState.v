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
//锟斤拷锟斤拷 clk 时锟斤拷 key_vaild 锟斤拷锟斤拷锟角凤拷锟斤拷效 key_code 锟斤拷锟斤拷锟斤拷锟斤拷 
//锟斤拷锟� key0_state key1_state key2_state key3_state key4_state key5_state 锟斤拷锟斤拷状态
//锟斤拷锟斤拷状态 0锟斤拷锟斤拷锟斤拷锟酵凤拷 1锟斤拷锟斤拷锟斤拷锟教帮拷 2锟斤拷锟斤拷锟斤拷锟酵凤拷 3锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷

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
    wire clk_1kHz; //1kHz锟斤拷频
    reg [31:0] counter;
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

    reg [3:0]st;
    localparam STABLE=0,DOUDONG=1;
    reg [3:0] before_key;

    always @(posedge clk_1kHz)begin
        if(key_vaild)begin
            if(before_key!=key_code)begin
                counter<=0;
                before_key<=key_code;
            end
            else begin
                counter<=counter+1;
            end
            if(counter>=1000)begin
                case(key_code)
                    4'hd:begin
                        key0_state<=2;
                    end
                    4'h5:begin
                        key1_state<=2;
                    end
                    4'h8:begin
                        key2_state<=2;
                    end
                    4'ha:begin
                        key3_state<=2;
                    end
                    4'h0:begin
                        key4_state<=2;
                    end
                    4'h9:begin
                        key5_state<=2;
                    end
                endcase
            end
            else if(counter>=20)begin
                case(key_code)
                    4'hd:begin
                        key0_state<=1;
                    end
                    4'h5:begin
                        key1_state<=1;
                    end
                    4'h8:begin
                        key2_state<=1;
                    end
                    4'ha:begin
                        key3_state<=1;
                    end
                    4'h0:begin
                        key4_state<=1;
                    end
                    4'h9:begin
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
        else begin
            key0_state<=0;
            key1_state<=0;
            key2_state<=0;
            key3_state<=0;
            key4_state<=0;
            key5_state<=0;
            counter<=0;
        end
    end

endmodule
