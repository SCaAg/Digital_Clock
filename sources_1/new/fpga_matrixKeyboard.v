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
    output led
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

  reg load_n = 1;
  reg go = 1;
  wire [63:0] counter;

  unixCounter counter1 (
      .clk(clk),
      .reset_n(reset_n),
      .load_n(load_n),
      .setCounter(inputcounter),
      .go(go),
      .counter(counter)
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
    
    reg menu_state;
    localparam MENU_SWITCH=0, MENU_ENTER=1;

    always@(posedge clk)begin
        if(!reset_n)begin
            totalstate<=0;
            totalstate_enter<=0;
            button_state<=BUTTON_RELEASE;
            menu_state<=MENU_SWITCH;
        end
        if(button_state==BUTTON_RELEASE)begin
            case(menu_state)
                MENU_SWITCH:begin
                    if(enter_button==1)begin menu_state<=MENU_ENTER;button_state<=BUTTON_PRESS;totalstate_enter<=totalstate;end
                    else totalstate_enter<=5;
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
            endcase
        end
        if(left_button == 0&&right_button == 0&&enter_button==0&&return_button==0)button_state<=BUTTON_RELEASE;
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
                        led1Number_show=0;
                        led2Number_show=0;
                        led3Number_show=0;
                        led4Number_show=0;
                        led5Number_show=0;
                        led6Number_show=0;
                        led7Number_show=0;
                        led8Number_show=0;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
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
                        led1Number_show=2;
                        led2Number_show=2;
                        led3Number_show=2;
                        led4Number_show=2;
                        led5Number_show=2;
                        led6Number_show=2;
                        led7Number_show=2;
                        led8Number_show=2;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
                    end
                    3:begin
                        led1Number_show=3;
                        led2Number_show=3;
                        led3Number_show=3;
                        led4Number_show=3;
                        led5Number_show=3;
                        led6Number_show=3;
                        led7Number_show=3;
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
                        led1Number_show=0;
                        led2Number_show=0;
                        led3Number_show=0;
                        led4Number_show=0;
                        led5Number_show=0;
                        led6Number_show=0;
                        led7Number_show=0;
                        led8Number_show=0;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
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
                        led1Number_show=2;
                        led2Number_show=2;
                        led3Number_show=2;
                        led4Number_show=2;
                        led5Number_show=2;
                        led6Number_show=2;
                        led7Number_show=2;
                        led8Number_show=2;
                        point_show=8'b11111111;
                        is_shine_show=0;
                        which_shine_show=0;
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
        endcase
    end
    




endmodule
