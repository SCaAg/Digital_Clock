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

//�������ɨ��?1?7
//���룺clk ʱ���ź� reset_n ��λ�ź� row[3:0] ���ź�
//�����col ���ź� key_vaild ������Ч�ź� key_code[3:0] ��������
module matrixKeyboard(
	input clk,  //50MHZ
	input reset_n, //��λ�ߵ�ƽ��Ч
	input [3:0] row,  //��
	output reg [3:0] col,   //��
	output key_vaild,
	output reg [3:0] key_code  //��ֵ
    );
    reg key_flag; //������־λ
    reg [2:0]state;  //״̬��״̬
    reg clk_500khz;  //500KHZʱ���ź�
    reg [5:0] counter;  //������
    reg [3:0] col_reg;  //�Ĵ�ɨ����ֵ
	reg [3:0] row_reg;  //�Ĵ�ɨ����ֵ
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

    always @(posedge clk_500khz or negedge reset_n) begin
        if(!reset_n) begin
            col <= 4'b0000;
            state<=0;
        end
        else begin
            case(state)//ɨ�迪ʼ
                0: begin
                    col <= 4'b0000;
                    key_flag<=1'b0;
                    if(row[3:0]!=4'b1111) begin state<=1;col[3:0]<=4'b1110;end //�м����£�ɨ���һ��?1?7
                    else begin state<=0;end
                end
                1: begin
                    if(row[3:0]!=4'b1111) begin state<=5;end   //�ж��Ƿ��ǵ�һ��
				    else  begin state<=2;col[3:0]<=4'b1101;end  //ɨ��ڶ���?1?7
                end
                2:	begin    
                if(row[3:0]!=4'b1111) begin state<=5;end    //�ж��Ƿ��ǵڶ���
                else  begin state<=3;col[3:0]<=4'b1011;end  //ɨ�������?1?7
                end
                3:   begin    
				if(row[3:0]!=4'b1111) begin state<=5;end   //�ж��Ƿ��ǵ���һ��
				else  begin state<=4;col[3:0]<=4'b0111;end  //ɨ�������?1?7
                end
                
                4:  begin    
                    if(row[3:0]!=4'b1111) begin state<=5;end  //�ж��Ƿ��ǵ�һ��
                    else  state<=0;
                end

                5:  begin  
                    if(row[3:0]!=4'b1111) 
                        begin
                            col_reg<=col;  //����ɨ����ֵ
                            row_reg<=row;  //����ɨ����ֵ
                            state<=5;
                            key_flag<=1'b1;  //�м�����
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
