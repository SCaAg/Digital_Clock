`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 23:38:51
// Design Name: 
// Module Name: countdown_led
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
//倒计时模块led闪烁

module countdown_led(
    input clk,//5MHz 5000000 2500000
    input reset_n,
    input ring,
    output reg led
    );

    reg[3:0] led_st;
    localparam LED_WAITE=0,LED_ON=1,LED_FINISH=2;

    reg[31:0] cnt_5s;
    //localparam CNT_5S_M=25000000;
    localparam CNT_5S_M=250;
    always @(posedge clk) begin
        if(!reset_n)begin
            led_st<=LED_WAITE;
            cnt_5s<=0;
            led<=0;
        end
        else begin
            case(led_st)
                LED_WAITE:begin
                    cnt_5s<=0;
                    led<=0;
                    if(ring)led_st<=LED_ON;
                end
                LED_ON:begin
                    cnt_5s<=cnt_5s+1;
                    if(!ring)led_st<=LED_WAITE;
                    else if(cnt_5s>=CNT_5S_M)led_st<=LED_FINISH;
                    //if(cnt_5s%2500000==0)led<=~led;
                    if(cnt_5s%25==0)led<=~led;
                end
                LED_FINISH:begin
                    cnt_5s<=0;
                    led<=0;
                    if(!ring)led_st<=LED_WAITE;
                end
            endcase
        end
    end
endmodule
