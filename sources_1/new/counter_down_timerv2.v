`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/06 15:31:38
// Design Name: 
// Module Name: counter_down_timerv2
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


module counter_down_timerv2(
    input wire clk,  //in 1kHz
    input wire rst_n,
    input wire [3:0] start,
    input wire [3:0] pause,
    input wire [3:0] reset,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,

    output reg [7:0] hour_out_bcd,
    output reg [7:0] minute_out_bcd,
    output reg [7:0] second_out_bcd,
    output reg ring
    //output  [3:0]st_out,
    //output load_out
    );

    reg [3:0] st;
    //assign st_out = st;
    localparam WAIT=0,LOAD=1,COUNT=2,PAUSE=3;
    wire [31:0] set_seconds;
    assign set_seconds = ((hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]))*1000;

    reg load;
    //assign load_out = load;
    //生成1kHz时钟
    wire clk1kHz;
    reg[25:0] clk_1kHz_counter;
    localparam clk_1kHz_M=50000;
    //localparam clk_1kHz_M=10; //仿真用
    always @(posedge clk)begin
        if(!rst_n)begin clk_1kHz_counter <= 0;end
        else if(clk_1kHz_counter<clk_1kHz_M)clk_1kHz_counter <= clk_1kHz_counter + 1;
        else clk_1kHz_counter <= 0;
    end
    assign clk1kHz = (clk_1kHz_counter==clk_1kHz_M)?1:0;

    
    wire [31:0] total_seconds;
    reg clk_en;

    //倒计时模块
    reg [31:0] down_counter;
    always @(posedge clk)begin
        if(!rst_n)down_counter<=30000;
        if(load)down_counter<=set_seconds;   
        //else if(load)  
        else if(clk1kHz)
            if(clk_en)down_counter<=down_counter-1;
            else down_counter<=down_counter;
    end
    assign total_seconds = down_counter;

    //led灯闪烁
    reg [3:0] led_state;
    localparam LED_SHINE=0,LED_OFF=1;
    reg [31:0] led_counter;
    always @(posedge clk)begin
        if(!rst_n)begin led_state<=LED_OFF;led_counter<=0;end
        case(led_state)
            LED_OFF:begin
                ring<=0;
                if(st==COUNT&&total_seconds==0)begin led_state<=LED_SHINE;led_counter<=0;end
            end
            LED_SHINE:begin
                if(clk1kHz)led_counter<=led_counter+1;
                if(led_counter%250==0&&led_counter!=0)ring<=~ring;
                if(st!=WAIT||led_counter==5000)begin led_state<=LED_OFF;end
            end
        endcase
    end


    //按键定义
    reg [25:0] counter;

    //状态机
    always @(posedge clk)begin
        if(!rst_n)begin
            st <= WAIT;
        end
        case(st)
            WAIT:begin//等待状态
                //down_counter<=set_seconds;
                if(start==1)begin
                    st<=LOAD;
                    counter<=0;
                end
            end
            LOAD:begin
                //if(counter==2)begin
                    st<=COUNT;
                //end
            end
            COUNT:begin
                if(pause==1)
                    st<=PAUSE;
                if(total_seconds==0)  
                    st<=WAIT;
                if(reset==1)
                    st<=WAIT;
            end
            PAUSE:begin
                if(start==1)
                    st<=COUNT;
                if(reset==1)
                    st<=WAIT;
            end
        endcase
        end

    wire [7:0] hour_out;
    wire [7:0] minute_out;
    wire [7:0] second_out;

    assign hour_out = (total_seconds / 3600000) %24;
    assign minute_out = (total_seconds / 60000)%60;
    assign second_out = (total_seconds / 1000) % 60;

    wire [7:0] hour_bcd_zhuanhua;
    wire [7:0] minute_bcd_zhuanhua;
    wire [7:0] second_bcd_zhuanhua;

    /*
    bin2bcd #(8) bin2bcd_hour (
        .bin(hour_out),
        .bcd(hour_bcd_zhuanhua)
    );
    bin2bcd #(8) bin2bcd_minute (
        .bin(minute_out),
        .bcd(minute_bcd_zhuanhua)
    );
    bin2bcd #(8) bin2bcd_second (
        .bin(second_out),
        .bcd(second_bcd_zhuanhua)
    );
    */
    assign second_bcd_zhuanhua[3:0]=second_out%10;
    assign second_bcd_zhuanhua[7:4]=second_out/10;
    assign minute_bcd_zhuanhua[3:0]=minute_out%10;
    assign minute_bcd_zhuanhua[7:4]=minute_out/10;
    assign hour_bcd_zhuanhua[3:0]=hour_out%10;
    assign hour_bcd_zhuanhua[7:4]=hour_out/10;
    //根据状态机输出
    always @*begin
        case(st)
            WAIT:begin
                load=1;
                clk_en=1;
                hour_out_bcd = hour_bcd_zhuanhua;
                minute_out_bcd = minute_bcd_zhuanhua;
                second_out_bcd = second_bcd_zhuanhua;
            end
            LOAD:begin
                load=0;
                clk_en=1;
                hour_out_bcd = hour_bcd_zhuanhua;
                minute_out_bcd = minute_bcd_zhuanhua;
                second_out_bcd = second_bcd_zhuanhua;
            end
            COUNT:begin
                load=0;
                clk_en=1;
                hour_out_bcd = hour_bcd_zhuanhua;
                minute_out_bcd = minute_bcd_zhuanhua;
                second_out_bcd = second_bcd_zhuanhua;
            end
            PAUSE:begin
                load=0;
                clk_en=0;
                hour_out_bcd = hour_bcd_zhuanhua;
                minute_out_bcd = minute_bcd_zhuanhua;
                second_out_bcd = second_bcd_zhuanhua;
            end
        endcase
    end
endmodule
