`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 11:50:45
// Design Name: 
// Module Name: showTimeInterface
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
//显示时间接口

module showTimeInterface(
    input clk,
    input reset_n,
    input [3:0] totalstate,

    input [15:0] year_bcd,
    input [7:0] month_bcd,
    input [7:0] day_bcd,
    input [7:0] hour_bcd,
    input [7:0] minute_bcd,
    input [7:0] second_bcd,

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
    output reg is_shine
    );
    reg[3:0] st;
    localparam SHOWHOUR=0,SHOWYEAR=1;
    reg button_state;
    localparam BUTTON_PRESS=0,BUTTON_RELEASE=1;
    reg [3:0] before_total_state;
    always @(posedge clk) begin
        if(!reset_n) begin
            st<=SHOWHOUR;
            button_state<=BUTTON_RELEASE;
            before_total_state<=5;
        end
        if(before_total_state!=totalstate) begin
            before_total_state<=totalstate;
            st<=SHOWHOUR;
            button_state<=BUTTON_PRESS;
        end
        else if(totalstate==0)begin
            if(button_state==BUTTON_RELEASE) begin
            case(st)
                SHOWHOUR: begin
                    if(enter_button==1) begin
                        st<=SHOWYEAR;
                        button_state<=BUTTON_PRESS;
                    end
                end
                SHOWYEAR: begin
                    if(enter_button==1) begin
                        st<=SHOWHOUR;
                        button_state<=BUTTON_PRESS;
                    end
                end
            endcase
            end
            if(enter_button==0) button_state<=BUTTON_RELEASE;
        end
    end
    always@ * begin
        case(st)
            SHOWHOUR: begin
                led1Number=second_bcd[3:0];
                led2Number=second_bcd[7:4];
                led3Number=4'b1010;
                led4Number=minute_bcd[3:0];
                led5Number=minute_bcd[7:4];
                led6Number=4'b1010;
                led7Number=hour_bcd[3:0];
                led8Number=hour_bcd[7:4];
                point=8'b11111111;
                is_shine=0;
                which_shine=8'b00000000;
            end
            SHOWYEAR: begin
                led1Number=day_bcd[3:0];
                led2Number=day_bcd[7:4];
                led3Number=month_bcd[3:0];
                led4Number=month_bcd[7:4];
                led5Number=year_bcd[3:0];
                led6Number=year_bcd[7:4];
                led7Number=year_bcd[11:8];
                led8Number=year_bcd[15:12];
                point=8'b11101011;
                is_shine=0;
                which_shine=8'b00000000;
            end
        endcase
    end
endmodule
