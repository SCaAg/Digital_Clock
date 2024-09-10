`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 15:07:53
// Design Name: 
// Module Name: fpga_matrixKeyboard
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

//锟斤拷锟斤拷fpga锟斤拷锟斤拷
module fpga_matrixKeyboard (
    input clk,
    input reset_n,
    input key1,
    input key2,
    input key3,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg,
    output [7:0] an,
    output led,
    input rx_pin,
    output tx_pin
);

    wire [3:0] key_code;
    wire key_vaild;
    matrixKeyboard matrixKeyboard1 (
        .clk(clk),
        .reset_n(reset_n),
        .row(row),
        .col(col),
        .key_code(key_code),
        .key_vaild(key_vaild)
    );

    wire [3:0] key0_state;
    wire [3:0] key1_state;
    wire [3:0] key2_state;
    wire [3:0] key3_state;
    wire [3:0] key4_state;
    wire [3:0] key5_state;

    keyState keyState1 (
        .clk(clk),
        .reset_n(reset_n),
        .key_code(key_code),
        .key_vaild(key_vaild),
        .key0_state(key0_state),
        .key1_state(key1_state),
        .key2_state(key2_state),
        .key3_state(key3_state),
        .key4_state(key4_state),
        .key5_state(key5_state)
    );

    reg load_n;
    reg go ;
    wire [63:0] counter;
    reg [63:0] setCounter;
    unixCounter counter1 (
        .clk(clk),
        .reset_n(reset_n),
        .load_n(load_n),
        .setCounter(setCounter),
        .go(go),
        .counter(counter)
    );

    wire [4:0] hour;
    wire [5:0] minute;
    wire [5:0] second;
    wire [13:0] year;
    wire [3:0] month;
    wire [4:0] day;

    unix64_to_UTC unix64_to_UTC1(
        .clk(clk),
        .rst_n(reset_n),
        .unix_time(counter),
        .hour(hour),
        .minute(minute),
        .second(second),
        .year(year),
        .month(month),
        .day(day)
    );

    wire [15:0] year_bcd;
    wire [7:0] month_bcd;
    wire [7:0] day_bcd;
    wire [7:0] hour_bcd;
    wire [7:0] minute_bcd;
    wire [7:0] second_bcd;

    bin2bcd #(
        .W(14)
    ) bin2bcd1 (
        .bin(year),
        .bcd(year_bcd)
    );
    assign month_bcd[7:5] = 3'b000;
    bin2bcd #(
        .W(4)
    ) bin2bcd2 (
        .bin(month),
        .bcd(month_bcd[4:0])
    );

    assign day_bcd[7:6] = 2'b00;
    bin2bcd #(
        .W(5)
    ) bin2bcd3 (
        .bin(day),
        .bcd(day_bcd[5:0])
    );

    assign hour_bcd[7:6] = 2'b00;
    bin2bcd #(
        .W(5)
    ) bin2bcd4 (
        .bin(hour),
        .bcd(hour_bcd[5:0])
    );

    assign minute_bcd[7] = 1'b0;
    bin2bcd #(
        .W(6)
    ) bin2bcd5 (
        .bin(minute),
        .bcd(minute_bcd[6:0])
    );

    assign second_bcd[7] = 1'b0;
    bin2bcd #(
        .W(6)
    ) bin2bcd6 (
        .bin(second),
        .bcd(second_bcd[6:0])
    );

  reg [7:0] point_show;
  reg [3:0] led1Number_show;
  reg [3:0] led2Number_show;
  reg [3:0] led3Number_show;
  reg [3:0] led4Number_show;
  reg [3:0] led5Number_show;
  reg [3:0] led6Number_show;
  reg [3:0] led7Number_show;
  reg [3:0] led8Number_show;
  reg is_shine_show;
  reg [7:0] which_shine_show;

  ledScan ledScan1 (
      .clk(clk),
      .reset_n(reset_n),
      .led1Number(led1Number_show),
      .led2Number(led2Number_show),
      .led3Number(led3Number_show),
      .led4Number(led4Number_show),
      .led5Number(led5Number_show),
      .led6Number(led6Number_show),
      .led7Number(led7Number_show),
      .led8Number(led8Number_show),
      .point(point_show),
      .ledCode(seg),
      .an(an),
      .is_shine(is_shine_show),
      .which_shine(which_shine_show)
  );
    
    
    reg [3:0] totalstate_enter;

    wire [7:0] point_count_down;
    wire [3:0] led1Number_count_down;
    wire [3:0] led2Number_count_down;
    wire [3:0] led3Number_count_down;
    wire [3:0] led4Number_count_down;
    wire [3:0] led5Number_count_down;
    wire [3:0] led6Number_count_down;
    wire [3:0] led7Number_count_down;
    wire [3:0] led8Number_count_down;
    wire is_shine_count_down;
    wire [7:0] which_shine_count_down;
    wire [3:0] count_down_state;
    
    countDownInterface countDownInterface1(
        .clk(clk),
        .reset_n(reset_n),
        .totalstate(totalstate_enter),
        .button0(key0_state),
        .button1(key1_state),
        .button2(key2_state),
        .button3(key3_state),
        .button4(key4_state),
        .button5(key5_state),
        .led8Number(led8Number_count_down),
        .led7Number(led7Number_count_down),
        .led6Number(led6Number_count_down),
        .led5Number(led5Number_count_down),
        .led4Number(led4Number_count_down),
        .led3Number(led3Number_count_down),
        .led2Number(led2Number_count_down),
        .led1Number(led1Number_count_down),
        .is_shine(is_shine_count_down),
        .which_shine(which_shine_count_down),
        .point(point_count_down),
        .led(led),
        .count_down_state(count_down_state)
    );
    

    wire [7:0] point_set_alarm;
    wire [3:0] led1Number_set_alarm;
    wire [3:0] led2Number_set_alarm;
    wire [3:0] led3Number_set_alarm;
    wire [3:0] led4Number_set_alarm;
    wire [3:0] led5Number_set_alarm;
    wire [3:0] led6Number_set_alarm;
    wire [3:0] led7Number_set_alarm;
    wire [3:0] led8Number_set_alarm;
    wire is_shine_set_alarm;
    wire [7:0] which_shine_set_alarm;

    setAlarm setAlarm1(
        .clk(clk),
        .reset_n(reset_n),
        .totalstate(totalstate_enter),
        .enter_button(enter_button),
        .return_button(return_button),
        .left_button(left_button),
        .right_button(right_button),
        .up_button(up_button),
        .down_button(down_button),

        .led8Number(led8Number_set_alarm),
        .led7Number(led7Number_set_alarm),
        .led6Number(led6Number_set_alarm),
        .led5Number(led5Number_set_alarm),
        .led4Number(led4Number_set_alarm),
        .led3Number(led3Number_set_alarm),
        .led2Number(led2Number_set_alarm),
        .led1Number(led1Number_set_alarm),
        .is_shine(is_shine_set_alarm),
        .which_shine(which_shine_set_alarm),
        .point(point_set_alarm)   
    );

    wire [7:0] point_show_time;
    wire [3:0] led1Number_show_time;
    wire [3:0] led2Number_show_time;
    wire [3:0] led3Number_show_time;
    wire [3:0] led4Number_show_time;
    wire [3:0] led5Number_show_time;
    wire [3:0] led6Number_show_time;
    wire [3:0] led7Number_show_time;
    wire [3:0] led8Number_show_time;
    wire is_shine_show_time;
    wire [7:0] which_shine_show_time;

    showTimeInterface showTimeInterface1(
        .clk(clk),
        .reset_n(reset_n),
        .totalstate(totalstate_enter),
        .year_bcd(year_bcd),
        .month_bcd(month_bcd),
        .day_bcd(day_bcd),
        .hour_bcd(hour_bcd),
        .minute_bcd(minute_bcd),
        .second_bcd(second_bcd),
        .up_button(up_button),
        .down_button(down_button),
        .enter_button(enter_button),
        .return_button(return_button),
        .left_button(left_button),
        .right_button(right_button),
        .led1Number(led1Number_show_time),
        .led2Number(led2Number_show_time),
        .led3Number(led3Number_show_time),
        .led4Number(led4Number_show_time),
        .led5Number(led5Number_show_time),
        .led6Number(led6Number_show_time),
        .led7Number(led7Number_show_time),
        .led8Number(led8Number_show_time),
        .is_shine(is_shine_show_time),
        .which_shine(which_shine_show_time),
        .point(point_show_time)
    );

    reg en;
    wire finished;
    wire [31:0] timeout;
    internetTimeSet uut(
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .finished(finished),
        .tx_pin(tx_pin),
        .rx_pin(rx_pin),
        .timeout(timeout)
    );

    wire [3:0] enter_button;
    assign enter_button = key5_state;
    wire [3:0] return_button;
    assign return_button = key4_state;
    wire [3:0] left_button;
    assign left_button = key0_state;
    wire [3:0] right_button;
    assign right_button = key1_state;
    wire [3:0] up_button;
    assign up_button = key2_state;
    wire [3:0] down_button;
    assign down_button = key3_state;

    reg [3:0] totalstate;

    reg[3:0] button_state;
    localparam BUTTON_RELEASE=0, BUTTON_PRESS=1;
    
    reg [3:0] menu_state;
    localparam MENU_SWITCH=0, MENU_ENTER=1,MENU_GETTIME=2;

    reg[3:0] gettime_st;
    localparam START=0,WAITTIME=1,SETTIME=2,FINISHED=3;

    always@(posedge clk)begin
        if(!reset_n)begin
            totalstate<=0;
            totalstate_enter<=0;
            button_state<=BUTTON_RELEASE;
            menu_state<=MENU_SWITCH;
            load_n<=1;
            go<=1;
            en<=0;
        end
        else if(button_state==BUTTON_RELEASE)begin
            case(menu_state)
                MENU_SWITCH:begin
                    if(enter_button==1)begin menu_state<=MENU_ENTER;button_state<=BUTTON_PRESS;totalstate_enter<=totalstate;end
                    else totalstate_enter<=5;
                    if(up_button==2)begin menu_state<=MENU_GETTIME;gettime_st<=START;button_state<=BUTTON_PRESS;end
                    case(totalstate)
                        0:begin
                            if(right_button==1)begin totalstate<=1;button_state<=BUTTON_PRESS;end
                            if(left_button==1)begin totalstate<=3;button_state<=BUTTON_PRESS;end
                        end
                        1:begin
                            if(right_button==1)begin totalstate<=2;button_state<=BUTTON_PRESS;end
                            if(left_button==1)begin totalstate<=0;button_state<=BUTTON_PRESS;end
                        end
                        2:begin
                            if(right_button==1)begin totalstate<=3;button_state<=BUTTON_PRESS;end
                            if(left_button==1)begin totalstate<=1;button_state<=BUTTON_PRESS;end
                        end
                        3:begin
                            if(right_button==1)begin totalstate<=0;button_state<=BUTTON_PRESS;end
                            if(left_button==1)begin totalstate<=2;button_state<=BUTTON_PRESS;end
                        end
                    endcase
                end
                MENU_ENTER:begin
                    if(return_button==1)begin menu_state<=MENU_SWITCH;button_state<=BUTTON_PRESS;end
                end
                MENU_GETTIME:begin
                    case(gettime_st)
                        START: begin
                            gettime_st<=WAITTIME;
                            en<=1;
                        end
                        WAITTIME: begin
                            en<=0;
                            if(finished) begin
                                gettime_st<=SETTIME;
                                load_n<=0;
                                setCounter<=timeout;
                            end
                        end
                        SETTIME: begin
                            gettime_st<=FINISHED;
                            load_n<=1;
                        end
                        FINISHED: begin
                            menu_state<=MENU_SWITCH;
                        end
                    endcase
                end
            endcase
        end
        if(left_button == 0&&right_button == 0&&enter_button==0&&return_button==0&&up_button==0&&down_button==0)button_state<=BUTTON_RELEASE;
    end
    /*
    always@*begin
     led1Number_show=left_button;
     led2Number_show=right_button;
     led3Number_show=up_button;
     led4Number_show=down_button;
     led5Number_show=enter_button;
     led6Number_show=return_button;
    end
    */
    
    always@*begin
        case(menu_state)
            MENU_SWITCH:begin
                case(totalstate)
                    0:begin
                        led1Number_show=key0_state;
                        led2Number_show=key1_state;
                        led3Number_show=key2_state;
                        led4Number_show=key3_state;
                        led5Number_show=key4_state;
                        led6Number_show=key5_state;
                        led7Number_show=key_vaild;
                        led8Number_show=0;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                    1:begin
                        led1Number_show=key0_state;
                        led2Number_show=key1_state;
                        led3Number_show=key2_state;
                        led4Number_show=key3_state;
                        led5Number_show=key4_state;
                        led6Number_show=key5_state;
                        led7Number_show=key_vaild;
                        led8Number_show=1;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                    2:begin
                        led1Number_show=key0_state;
                        led2Number_show=key1_state;
                        led3Number_show=key2_state;
                        led4Number_show=key3_state;
                        led5Number_show=key4_state;
                        led6Number_show=key5_state;
                        led7Number_show=key_vaild;
                        led8Number_show=2;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                    3:begin
                        led1Number_show=key0_state;
                        led2Number_show=key1_state;
                        led3Number_show=key2_state;
                        led4Number_show=key3_state;
                        led5Number_show=key4_state;
                        led6Number_show=key5_state;
                        led7Number_show=key_vaild;
                        led8Number_show=3;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                endcase
            end
            MENU_ENTER:begin
                case(totalstate_enter)
                    0:begin
                        led1Number_show=led1Number_show_time;
                        led2Number_show=led2Number_show_time;
                        led3Number_show=led3Number_show_time;
                        led4Number_show=led4Number_show_time;
                        led5Number_show=led5Number_show_time;
                        led6Number_show=led6Number_show_time;
                        led7Number_show=led7Number_show_time;
                        led8Number_show=led8Number_show_time;
                        point_show=point_show_time;
                        is_shine_show=is_shine_show_time;
                        which_shine_show=which_shine_show_time;
                    end
                    1:begin
                        led1Number_show=1;
                        led2Number_show=1;
                        led3Number_show=1;
                        led4Number_show=1;
                        led5Number_show=1;
                        led6Number_show=1;
                        led7Number_show=1;
                        led8Number_show=1;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                    2:begin
                        led1Number_show=led1Number_set_alarm;
                        led2Number_show=led2Number_set_alarm;
                        led3Number_show=led3Number_set_alarm;
                        led4Number_show=led4Number_set_alarm;
                        led5Number_show=led5Number_set_alarm;
                        led6Number_show=led6Number_set_alarm;
                        led7Number_show=led7Number_set_alarm;
                        led8Number_show=led8Number_set_alarm;
                        point_show=point_set_alarm;
                        is_shine_show=is_shine_set_alarm;
                        which_shine_show=which_shine_set_alarm;
                    end
                    3:begin
                        led1Number_show=led1Number_count_down;
                        led2Number_show=led2Number_count_down;
                        led3Number_show=led3Number_count_down;
                        led4Number_show=led4Number_count_down;
                        led5Number_show=led5Number_count_down;
                        led6Number_show=led6Number_count_down;
                        led7Number_show=led7Number_count_down;
                        led8Number_show=led8Number_count_down;
                        point_show=point_count_down;
                        is_shine_show=is_shine_count_down;
                        which_shine_show=which_shine_count_down;
                    end
                endcase
            end
            MENU_GETTIME:begin
                led1Number_show=4'b1010;
                led2Number_show=4'b1010;
                led3Number_show=4'b1010;
                led4Number_show=4'b1010;
                led5Number_show=4'b1010;
                led6Number_show=4'b1010;
                led7Number_show=4'b1010;
                led8Number_show=4'b1010;
                point_show=8'b11111111;;
                is_shine_show=0;
                which_shine_show=8'b00000000;
            end
        endcase
    end
    




endmodule
