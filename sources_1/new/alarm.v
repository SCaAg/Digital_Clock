`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 16:42:29
// Design Name: 
// Module Name: alarm
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


module alarm (
    input wire clk,
    input wire rst_n,
    input wire up_btn,
    input wire down_btn,
    input wire [2:0] edit_state,
    input wire [2:0] edit_opt,
    input wire [63:0] counter,
    output reg [7:0] alarm_hour_bcd,
    output reg [7:0] alarm_minute_bcd,
    output reg [7:0] alarm_second_bcd,
    output reg [7:0] alarm_state_bcd,
    output reg ring
);
  localparam EDIT_IDLE = 3'd0;
  localparam EDIT_TIME = 3'd1;
  localparam EDIT_ALARM = 3'd2;
  localparam EDIT_TIMER = 3'd3;

  localparam EDIT_ALARM_NUM = 3'd0;
  localparam EDIT_SECOND = 3'd1;
  localparam EDIT_MINUTE = 3'd2;
  localparam EDIT_HOUR = 3'd3;
  localparam EDIT_DAY = 3'd4;
  localparam EDIT_MONTH = 3'd5;
  localparam EDIT_YEAR = 3'd6;

  reg [63:0] alarm1_stamp;
  reg [63:0] alarm2_stamp;
  reg [63:0] alarm3_stamp;

  reg [ 1:0] selected_alarm = 2'b0;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      ;
    end else begin
      if ((~up_btn) && (edit_state == EDIT_ALARM))
        selected_alarm <= selected_alarm == 2'd2 ? 2'd0 : selected_alarm + 2'd1;
      else if ((~down_btn) && (edit_state == EDIT_ALARM)) begin
        case (edit_opt)
          EDIT_YEAR: begin

          end
          EDIT_MONTH: ;
          EDIT_DAY: ;
          EDIT_HOUR: ;
          EDIT_MINUTE: ;
          EDIT_SECOND: ;
          default: ;
        endcase
      end
    end
  end

endmodule

module bcd_time2alarm_time (
    input  wire [15:0] alarm_year_bcd,
    input  wire [ 7:0] alarm_month_bcd,
    input  wire [ 7:0] alarm_day_bcd,
    input  wire [ 7:0] alarm_hour_bcd,
    input  wire [ 7:0] alarm_minute_bcd,
    input  wire [ 7:0] alarm_second_bcd,
    input  wire [63:0] counter,
    output wire [63:0] alarm_stamp
);
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;
  assign year=1000*alarm_year_bcd[15:12]+100*alarm_year_bcd[11:8]+10*alarm_year_bcd[7:4]+alarm_year_bcd[3:0];
  assign month = 10 * alarm_month_bcd[7:4] + alarm_month_bcd[3:0];
  assign day = 10 * alarm_day_bcd[7:4] + alarm_day_bcd[3:0];
  assign hour = 10 * alarm_hour_bcd[7:4] + alarm_hour_bcd[3:0];
  assign minute = 10 * alarm_minute_bcd[7:4] + alarm_minute_bcd[3:0];
  assign second = 10 * alarm_second_bcd[7:4] + alarm_second_bcd[3:0];


  wire [63:0] alarm_stamp_tmp;

  time2stamp time2stamp0 (
      .year(year),
      .month(month),
      .day(day),
      .hour(hour),
      .minute(minute),
      .second(second),
      .time_stamp(time_stamp_tmp)
  );
  assign alarm_stamp = alarm_stamp_tmp > counter ? alarm_stamp_tmp : alarm_stamp_tmp + 64'd86400;

endmodule
