`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 10:28:56
// Design Name: 
// Module Name: setAlarm
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
//设置闹钟接口

module setAlarm(
    input clk,
    input reset_n,
    input [3:0] totalstate,

    input wire [3:0] up_button,
    input wire [3:0] down_button,
    input wire [3:0] left_button,
    input wire [3:0] right_button,
    input wire [3:0] enter_button,
    input wire [3:0] return_button,

    output reg [3:0] led1Number,
    output reg [3:0] led2Number,
    output reg [3:0] led3Number,
    output reg [3:0] led4Number,
    output reg [3:0] led5Number,
    output reg [3:0] led6Number,
    output reg [3:0] led7Number,
    output reg [3:0] led8Number,
    output reg [7:0] point,
    output reg [7:0] which_shine,
    output reg is_shine,

    output [63:0] alarm_counter1,
    output [63:0] alarm_counter2,
    output [63:0] alarm_counter3
    );

    reg [7:0] hour1;
    reg [7:0] minute1;
    reg [7:0] second1;
    reg [7:0] hour2;
    reg [7:0] minute2;
    reg [7:0] second2;
    reg [7:0] hour3;
    reg [7:0] minute3;
    reg [7:0] second3;

    reg [7:0] hour_bcd_in;
    reg [7:0] minute_bcd_in;
    reg [7:0] second_bcd_in;

    reg [3:0] which_alarm;
    localparam ALARM1_BEGIN=0,ALARM2_BEGIN=2,ALARM3_BEGIN=4,ALARM_SET=5,ALARM_SHOW=6;
    reg [3:0] alarm_num;
    reg button_state;
    localparam BUTTON_RELEASE=0,BUTTON_PRESS=1;

    reg [2:0] position_state;
    //assign position_state_out = position_state;
    localparam SECOND_LOW=0,SECOND_HIGH=1,MINUTE_LOW=2,MINUTE_HIGH=3,HOUR_LOW=4,HOUR_HIGH=5;
    
    always@(posedge clk) begin
        if(!reset_n)begin
            hour1<=0;
            minute1<=0;
            second1<=0;
            hour2<=0;
            minute2<=0;
            second2<=0;
            hour3<=0;
            minute3<=0;
            second3<=0;
            which_alarm<=ALARM1_BEGIN;
            button_state<=BUTTON_RELEASE;
            position_state<=SECOND_LOW;
        end
        if(totalstate==3)begin
        case(which_alarm)
            ALARM1_BEGIN:begin
                hour_bcd_in<=hour1;
                minute_bcd_in<=minute1;
                second_bcd_in<=second1;
                which_alarm<=ALARM_SHOW;
                alarm_num<=0;
            end
            ALARM2_BEGIN:begin
                hour_bcd_in<=hour2;
                minute_bcd_in<=minute2;
                second_bcd_in<=second2;
                which_alarm<=ALARM_SHOW;   
                alarm_num<=1;             
            end
            ALARM3_BEGIN:begin
                hour_bcd_in<=hour3;
                minute_bcd_in<=minute3;
                second_bcd_in<=second3;
                which_alarm<=ALARM_SHOW;
                alarm_num<=2;
            end
            ALARM_SET:begin
                if(enter_button == 1)which_alarm<=ALARM_SHOW;
                case(alarm_num)
                    0:begin
                        hour1<=hour_bcd_in;
                        minute1<=minute_bcd_in;
                        second1<=second_bcd_in;
                    end
                    1:begin
                        hour2<=hour_bcd_in;
                        minute2<=minute_bcd_in;
                        second2<=second_bcd_in;
                    end
                    2:begin
                        hour3<=hour_bcd_in;
                        minute3<=minute_bcd_in;
                        second3<=second_bcd_in;
                    end
                endcase
                if(button_state == BUTTON_RELEASE)begin
                    case(position_state)
                        SECOND_LOW:begin
                            if(left_button == 1)begin position_state<=SECOND_HIGH;button_state<=BUTTON_PRESS;end                   
                            if(right_button == 1)begin position_state<=HOUR_HIGH;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(second_bcd_in[3:0] == 4'h9)second_bcd_in[3:0] <= 4'h0;
                                else second_bcd_in[3:0] <= second_bcd_in[3:0] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(second_bcd_in[3:0] == 4'h0)second_bcd_in[3:0] <= 4'h9;
                                else second_bcd_in[3:0] <= second_bcd_in[3:0] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                        SECOND_HIGH:begin
                            if(left_button == 1)begin position_state<=MINUTE_LOW;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin position_state<=SECOND_LOW;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(second_bcd_in[7:4] == 4'h5)second_bcd_in[7:4] <= 4'h0;
                                else second_bcd_in[7:4] <= second_bcd_in[7:4] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(second_bcd_in[7:4] == 4'h0)second_bcd_in[7:4] <= 4'h5;
                                else second_bcd_in[7:4] <= second_bcd_in[7:4] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                        MINUTE_LOW:begin
                            if(left_button == 1)begin position_state<=MINUTE_HIGH;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin position_state<=SECOND_HIGH;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(minute_bcd_in[3:0] == 4'h9)minute_bcd_in[3:0] <= 4'h0;
                                else minute_bcd_in[3:0] <= minute_bcd_in[3:0] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(minute_bcd_in[3:0] == 4'h0)minute_bcd_in[3:0] <= 4'h9;
                                else minute_bcd_in[3:0] <= minute_bcd_in[3:0] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                        MINUTE_HIGH:begin
                            if(left_button == 1)begin position_state<=HOUR_LOW;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin position_state<=MINUTE_LOW;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(minute_bcd_in[7:4] == 4'h5)minute_bcd_in[7:4] <= 4'h0;
                                else minute_bcd_in[7:4] <= minute_bcd_in[7:4] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(minute_bcd_in[7:4] == 4'h0)minute_bcd_in[7:4] <= 4'h5;
                                else minute_bcd_in[7:4] <= minute_bcd_in[7:4] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                        HOUR_LOW:begin
                            if(left_button == 1)begin position_state<=HOUR_HIGH;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin position_state<=MINUTE_HIGH;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(hour_bcd_in[3:0] == 4'h9)hour_bcd_in[3:0] <= 4'h0;
                                else hour_bcd_in[3:0] <= hour_bcd_in[3:0] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(hour_bcd_in[3:0] == 4'h0)hour_bcd_in[3:0] <= 4'h9;
                                else hour_bcd_in[3:0] <= hour_bcd_in[3:0] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                        HOUR_HIGH:begin
                            if(left_button == 1)begin position_state<=SECOND_LOW;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin position_state<=HOUR_LOW;button_state<=BUTTON_PRESS;end
                            if(up_button==1)begin
                                if(hour_bcd_in[7:4] == 4'h2)hour_bcd_in[7:4] <= 4'h0;
                                else hour_bcd_in[7:4] <= hour_bcd_in[7:4] + 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                            if(down_button==1)begin
                                if(hour_bcd_in[7:4] == 4'h0)hour_bcd_in[7:4] <= 4'h2;
                                else hour_bcd_in[7:4] <= hour_bcd_in[7:4] - 1'b1;
                                button_state<=BUTTON_PRESS;
                            end
                        end
                    endcase
                end
                if(left_button == 0&&right_button == 0&&up_button==0&&down_button==0)button_state<=BUTTON_RELEASE;
            end
            ALARM_SHOW:begin
                if(enter_button == 2)begin
                    which_alarm<=ALARM_SET;
                    position_state<=SECOND_LOW;
                end
                if(button_state == BUTTON_RELEASE)begin
                    case(alarm_num)
                        0:begin
                            if(left_button == 1)begin which_alarm<=ALARM3_BEGIN;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin which_alarm<=ALARM2_BEGIN;button_state<=BUTTON_PRESS;end
                        end
                        1:begin
                            if(left_button == 1)begin which_alarm<=ALARM1_BEGIN;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin which_alarm<=ALARM3_BEGIN;button_state<=BUTTON_PRESS;end
                        end
                        2:begin
                            if(left_button == 1)begin which_alarm<=ALARM2_BEGIN;button_state<=BUTTON_PRESS;end
                            if(right_button == 1)begin which_alarm<=ALARM1_BEGIN;button_state<=BUTTON_PRESS;end
                        end
                    endcase
                end
                if(left_button == 0&&right_button == 0&&up_button==0&&down_button==0)button_state<=BUTTON_RELEASE;
            end
        endcase
        end
    end

    always @* begin
        case(which_alarm)
            ALARM_SHOW:begin
                led1Number=second_bcd_in[3:0];
                led2Number=second_bcd_in[7:4];
                led3Number=4'b1010;
                led4Number=minute_bcd_in[3:0];
                led5Number=minute_bcd_in[7:4];
                led6Number=4'b1010;
                led7Number=hour_bcd_in[3:0];
                led8Number=hour_bcd_in[7:4];
                point=8'b11111111;
                is_shine=0;
            end
            ALARM_SET:begin
                led1Number=second_bcd_in[3:0];
                led2Number=second_bcd_in[7:4];
                led3Number=4'b1010;
                led4Number=minute_bcd_in[3:0];
                led5Number=minute_bcd_in[7:4];
                led6Number=4'b1010;
                led7Number=hour_bcd_in[3:0];
                led8Number=hour_bcd_in[7:4];
                point=8'b11111111;
                is_shine=1;
                case(position_state)
                    SECOND_LOW:which_shine=8'b00000001;
                    SECOND_HIGH:which_shine=8'b00000010;
                    MINUTE_LOW:which_shine=8'b00001000;
                    MINUTE_HIGH:which_shine=8'b00010000;
                    HOUR_LOW:which_shine=8'b01000000;
                    HOUR_HIGH:which_shine=8'b10000000;
                endcase
            end
            default:begin
                led1Number=second_bcd_in[3:0];
                led2Number=second_bcd_in[7:4];
                led3Number=4'b1010;
                led4Number=minute_bcd_in[3:0];
                led5Number=minute_bcd_in[7:4];
                led6Number=4'b1010;
                led7Number=hour_bcd_in[3:0];
                led8Number=hour_bcd_in[7:4];
                point=8'b11111111;
                is_shine=0;
            end
        endcase
    end
endmodule
