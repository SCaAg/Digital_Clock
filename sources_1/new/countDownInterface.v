`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/07 02:50:07
// Design Name: 
// Module Name: countDownInterface
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
//倒计时模块接口 输入状态,按钮 输出led灯

module countDownInterface(
    input clk,
    input reset_n,
    input [3:0] totalstate,

    input wire [3:0] button0,
    input wire [3:0] button1,
    input wire [3:0] button2,
    input wire [3:0] button3,
    input wire [3:0] button4,
    input wire [3:0] button5,

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
    output wire led,
    output [3:0] count_down_state
    );
    reg [7:0] hour_bcd_in;
    reg [7:0] minute_bcd_in;
    reg [7:0] second_bcd_in;
    wire [7:0] hour_bcd_out;
    wire [7:0] minute_bcd_out;
    wire [7:0] second_bcd_out;

    wire [3:0] enter_button;
    assign enter_button = button5;
    wire [3:0] start_button;
    assign start_button = button4;
    wire [3:0] left_button;
    assign left_button = button0;
    wire [3:0] right_button;
    assign right_button = button1;
    wire [3:0] up_button;
    assign up_button = button2;
    wire [3:0] down_button;
    assign down_button = button3;

    wire counter_down_reset_n;
    assign counter_down_reset_n = (mode_state==MODE_COUNT&&totalstate==3)?reset_n:1'b0;

    counter_down_timerv2 counter_down_timerv2_t(
        .clk(clk),
        .rst_n(counter_down_reset_n),
        .start(left_button),
        .pause(up_button),
        .reset(down_button),
        .hour_bcd_in(hour_bcd_in),
        .minute_bcd_in(minute_bcd_in),
        .second_bcd_in(second_bcd_in),
        .hour_out_bcd(hour_bcd_out),
        .minute_out_bcd(minute_bcd_out),
        .second_out_bcd(second_bcd_out),
        .ring(led)
    );
    reg [2:0] position_state;
    //assign position_state_out = position_state;
    localparam SECOND_LOW=0,SECOND_HIGH=1,MINUTE_LOW=2,MINUTE_HIGH=3,HOUR_LOW=4,HOUR_HIGH=5;
    
    reg mode_state;
    assign count_down_state = mode_state;
    //assign mode_state_out = mode_state;
    localparam MODE_SET=0,MODE_COUNT=1;

    reg button_state;
    localparam BUTTON_RELEASE=0,BUTTON_PRESS=1;

    //处理按键输入


    //调整时间逻辑
    always @(posedge clk)begin
        if(!reset_n)begin//初始化
            hour_bcd_in <= 8'h00;
            minute_bcd_in <= 8'h00;
            second_bcd_in <= 8'h00;
            mode_state <= MODE_COUNT;
        end
        if(totalstate==3)begin
        case(mode_state)
            MODE_COUNT:begin
                if(enter_button == 2)begin
                    mode_state<=MODE_SET;
                    position_state<=SECOND_LOW;
                end
            end
            MODE_SET:begin
                if(enter_button == 1)mode_state<=MODE_COUNT;
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
        endcase
        end
    end

    always @* begin
        case(mode_state)
            MODE_COUNT:begin
                led1Number=second_bcd_out[3:0];
                led2Number=second_bcd_out[7:4];
                led3Number=4'b1010;
                led4Number=minute_bcd_out[3:0];
                led5Number=minute_bcd_out[7:4];
                led6Number=4'b1010;
                led7Number=hour_bcd_out[3:0];
                led8Number=hour_bcd_out[7:4];
                point=8'b11111111;
                is_shine=0;
                which_shine=8'b0;
            end
            MODE_SET:begin
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
        endcase

    end

endmodule
