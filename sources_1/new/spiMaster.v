`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 15:31:49
// Design Name: 
// Module Name: spiMaster
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
//spi主机
//

module spiMaster (
    output reg sck,
    output reg mosi,
    output reg cs,
    output dc,

    input dc_in,
    input [7:0] spi_data_out,
    input spi_send,

    output reg spi_send_done,
    input clk,
    input reset_n,
    output spi_clk
    );
    assign dc= (!cs)?dc_in:0; 
    initial begin sck=0;mosi=0;cs=0;sck_reg=0;count=0;cur_st=0;nxt_st=0;reg_data=0;delay_count=0;end
    localparam IDLE = 0,CS_L=1,DATA=2,FINISH=3;
    reg[4:0] cur_st,nxt_st;
    reg [31:0]delay_count;
    reg sck_reg;
    reg [3:0]count;//计数器，用于计数数据位
    reg [7:0] reg_data;
    always @(posedge clk) begin
        /*if(!reset_n) begin
            delay_count<=0;
            sck_reg<=0;
        end*/
        if(delay_count==4) begin
        //if(delay_count==3) begin
            delay_count<=0;
            sck_reg<=~sck_reg;
        end
        else delay_count<=delay_count+1;
    end
    assign spi_clk=sck_reg;

    always @(*)
        if(cs) sck=1;
        else if(cur_st==FINISH) sck=1; 
        else if(!cs) sck=sck_reg;
        else sck=1;

    always@(posedge sck_reg)
        if(!reset_n) cur_st<=0;
        else cur_st<=nxt_st;

    always@(*) begin
        nxt_st=cur_st;
        case(cur_st)
            IDLE: if(spi_send) nxt_st=CS_L;//从等待到发送
            CS_L: nxt_st=DATA;//片选拉低，进入数据发送
            DATA: if(count==7) nxt_st=FINISH;//数据位发送完成，进入结束状态
            FINISH: nxt_st=IDLE;//发送完成，回到等待状态
            default: nxt_st=IDLE;
        endcase
    end

    always@(*)
        if(!reset_n) 
            spi_send_done=0;
        else if(cur_st==FINISH)
            spi_send_done=1;
        else spi_send_done=0;

    always@(posedge sck_reg)
        if(!reset_n) cs<=1;
        else if(cur_st==CS_L) cs<=0;
        else if(cur_st==DATA) cs<=0;
        else cs<=1;

    always@(posedge sck_reg)
        if(!reset_n)
            count<=0;
        else if(cur_st==DATA)
            count<=count+1;
        else if(cur_st==IDLE | cur_st==FINISH)
            count<=0;
    
    always@(negedge sck_reg)
        if(!reset_n)
            mosi<=0;	
        else if(cur_st==DATA)
        begin
            reg_data[7:1]<=reg_data[6:0];
            mosi<=reg_data[7];
        end
        else if(spi_send)
            reg_data<=spi_data_out;
endmodule
