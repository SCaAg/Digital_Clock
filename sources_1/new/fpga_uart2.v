`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 01:14:52
// Design Name: 
// Module Name: fpga_uart2
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


module fpga_uart2(
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

    reg load_n;
    reg go;
    wire [63:0] counter;
    reg [63:0] setCounter;
    unixCounter counter1 (
        .clk(clk),
        .reset_n(reset_n),
        .load_n(load_n),
        .go(go),
        .counter(counter),
        .setCounter(setCounter)
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

    always@(posedge clk) begin
        point_show<=8'b11101011;
        is_shine_show=0;
        which_shine_show=0;
        led1Number_show<=day%10;
        led2Number_show<=day/10;
        led3Number_show<=month%10;
        led4Number_show<=month/10;
        led5Number_show<=year%10;
        led6Number_show<=(year/10)%10;
        led7Number_show<=(year/100)%10;
        led8Number_show<=year/1000;
    end



    reg[3:0] st;
    localparam START=0,WAITTIME=1,SETTIME=2,FINISHED=3;
    always @(posedge clk) begin
        if(!reset_n) begin
            st<=START;
            load_n<=1;
            go<=1;
            en<=0;
        end
        else begin
            case (st)
                START: begin
                    st<=WAITTIME;
                    en<=1;
                end
                WAITTIME: begin
                    en<=0;
                    if(finished) begin
                        st<=SETTIME;
                        load_n<=0;
                        setCounter<=timeout;
                    end
                end
                SETTIME: begin
                    st<=FINISHED;
                    load_n<=1;
                end
            endcase
        end
    end
endmodule
