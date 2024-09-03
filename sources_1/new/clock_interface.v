`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/03 01:29:18
// Design Name: 
// Module Name: clock_interface
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

module clock_interface (
    input  wire clk,
    input  wire rst_n,
    input  wire mode_btn,
    input  wire adjust_btn,
    input  wire down_btn,
    output wire test
);

  localparam TIME_DISP = 3'd0;
  localparam DATE_DISP = 3'd1;
  localparam ALARM_DISP = 3'd2;
  localparam TIMER_DISP = 3'd3;
  localparam STOP_WATCH_DISP = 3'd4;
  reg [2:0] disp_state = TIME_DISP;

  localparam EDIT_IDLE = 3'd0;
  localparam EDIT_TIME = 3'd1;
  localparam EDIT_ALARM = 3'd2;
  localparam EDIT_TIMER = 3'd3;
  reg [2:0] edit_state = EDIT_IDLE;

  localparam EDIT_ALARM_NUM = 3'd0;
  localparam EDIT_SECOND = 3'd1;
  localparam EDIT_MINUTE = 3'd2;
  localparam EDIT_HOUR = 3'd3;
  localparam EDIT_DAY = 3'd4;
  localparam EDIT_MONTH = 3'd5;
  localparam EDIT_YEAR = 3'd6;

  reg [2:0] edit_opt = EDIT_HOUR;

  // pressed mode_btn
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      disp_state <= TIME_DISP;
      edit_opt   <= EDIT_HOUR;
    end else if (~mode_btn) begin
      // not in the edit state
      if (edit_state == EDIT_IDLE) begin
        disp_state <= disp_state == 3'd4 ? 3'd0 : disp_state + 1;
      end  // in edit state
      else begin
        case (edit_state)
          EDIT_TIME: edit_opt <= edit_opt == 3'd1 ? 3'd6 : edit_opt - 1;
          EDIT_ALARM: edit_opt <= edit_opt == 3'd0 ? 3'd3 : edit_opt - 1;
          EDIT_TIMER: edit_opt <= edit_opt == 3'd1 ? 3'd3 : edit_opt - 1;
          default: edit_opt <= EDIT_HOUR;
        endcase
      end
    end
  end

  // pressed adjust_btn
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      edit_state <= EDIT_IDLE;
    end else if (~adjust_btn) begin
      // not in the edit state
      if (edit_state == EDIT_IDLE) begin
        case (disp_state)
          TIME_DISP: edit_state <= EDIT_TIME;
          DATE_DISP: edit_state <= EDIT_TIME;
          ALARM_DISP: edit_state <= EDIT_ALARM;
          TIMER_DISP: edit_state <= EDIT_TIMER;
          default: edit_state <= EDIT_IDLE;
        endcase
      end  // TODO already in edit mode, need to save and exit
      else begin
        edit_state <= EDIT_IDLE;
      end
    end
  end

  // pressed down_btn
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin

    end else begin

    end
  end
endmodule
