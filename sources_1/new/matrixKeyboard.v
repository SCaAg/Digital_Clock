`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 14:28:05
// Design Name: 
// Module Name: matrixKeyboard
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

//矩阵键盘扫描
//输入：clk 时钟信号 reset_n 复位信号 row[3:0] 行信号
//输出：col 列信号 key_vaild 按键有效信号 key_code[3:0] 按键编码
module matrixKeyboard(
	input clk,  //50MHZ
	input reset_n, //复位高电平有效
	input [3:0] row,  //行
	output reg [3:0] col,   //列
	output key_vaild,
	output reg [3:0] key_code  //键值
    );
    reg key_flag; //按键标志位
    reg [2:0]state=0;  //状态机状态
    reg clk_500khz;  //500KHZ时钟信号
    reg [5:0] counter;  //计数器
    reg [3:0] col_reg;  //寄存扫描列值
	reg [3:0] row_reg;  //寄存扫描行值
    localparam counterN =50 ;
    //localparam counterN=2 ;
    assign key_vaild = key_flag;
    always @(posedge clk ) begin
        if(!reset_n) begin
            clk_500khz <= 0;
            counter <= 0;
        end
        else if(counter<counterN) begin
            counter <= counter + 1;
        end
        else begin
            clk_500khz <= ~clk_500khz;
            counter <= 0;
        end
    end

    always @(posedge clk_500khz) begin
        if(!reset_n) begin
            col <= 4'b0000;
            state<=0;
        end
        else begin
            case(state)//扫描开始
                0: begin
                    col <= 4'b0000;
                    key_flag<=1'b0;
                    if(row[3:0]!=4'b1111) begin state<=1;col[3:0]<=4'b1110;end //有键按下，扫描第一行
                    else state<=0;
                end
                1: begin
                    if(row[3:0]!=4'b1111) begin state<=5;end   //判断是否是第一行
				    else  begin state<=2;col[3:0]<=4'b1101;end  //扫描第二行
                end
                2:	begin    
                if(row[3:0]!=4'b1111) begin state<=5;end    //判断是否是第二行
                else  begin state<=3;col[3:0]<=4'b1011;end  //扫描第三行
                end
                3:   begin    
				if(row[3:0]!=4'b1111) begin state<=5;end   //判断是否是第三一行
				else  begin state<=4;col[3:0]<=4'b0111;end  //扫描第四行
                end
                
                4:  begin    
                    if(row[3:0]!=4'b1111) begin state<=5;end  //判断是否是第一行
                    else  state<=0;
                end

                5:  begin  
                    if(row[3:0]!=4'b1111) 
                        begin
                            col_reg<=col;  //保存扫描列值
                            row_reg<=row;  //保存扫描行值
                            state<=5;
                            key_flag<=1'b1;  //有键按下
                        end             
                    else
                        begin state<=0;end
                end    
		endcase
        end
    end

    always @(clk_500khz or col_reg or row_reg)
    begin
      if(key_flag==1'b1) 
        begin
            case ({row_reg,col_reg})
                 8'b1110_1110:key_code<=4'H0;
                 8'b1110_1101:key_code<=4'H1;
                 8'b1110_1011:key_code<=4'H2;
                 8'b1110_0111:key_code<=4'H3;
                 8'b1101_1110:key_code<=4'H4;
                 8'b1101_1101:key_code<=4'H5;
                 8'b1101_1011:key_code<=4'H6;
                 8'b1101_0111:key_code<=4'H7;
                 8'b1011_1110:key_code<=4'H8;
                 8'b1011_1101:key_code<=4'H9;
                 8'b1011_1011:key_code<=4'Ha;
                 8'b1011_0111:key_code<=4'Hb;
                 8'b0111_1110:key_code<=4'Hc;
                 8'b0111_1101:key_code<=4'Hd;
                 8'b0111_1011:key_code<=4'He;
                 8'b0111_0111:key_code<=4'Hf;     
            endcase 
        end   
   end
endmodule
