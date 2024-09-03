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
    input wire clk,
    input wire rst_n,
    input wire mode_btn,
    input wire adjust_btn,
    input wire down_btn,
    input wire [63:0] counter,
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

  localparam EDIT_ALARM_NUM = 3'd0;  //depracated
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

  reg need_to_save = 1'b0;
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
      end else begin
        // already in edit mode, need to save and exit
        edit_state   <= EDIT_IDLE;
        need_to_save <= 1'b1;
      end
    end
  end





  reg  [15:0] bcd_editing = 16'd0;
  reg  [15:0] bcd_editing_tmp = 16'd0;
  reg  [15:0] bcd_editing_max = 16'd9999;
  wire [15:0] bcd_editing_incresed;

  bcd_increment_16bit bcd_increment (
      .bcd_in (bcd_editing),
      .bcd_max(bcd_editing_max),
      .bcd_out(bcd_editing_incresed)
  );

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      bcd_editing <= 16'b0;
      bcd_editing_tmp <= 16'b0;
    end else if (~down_btn) begin
      bcd_editing_tmp <= bcd_editing_incresed;
      bcd_editing <= bcd_editing_tmp;
    end
  end






  reg  [ 5:0] led0;  //5:blink,4:dot,[3:0]:bcd
  reg  [ 5:0] led1;
  reg  [ 5:0] led2;
  reg  [ 5:0] led3;
  reg  [ 5:0] led4;
  reg  [ 5:0] led5;
  reg  [ 5:0] led6;
  reg  [ 5:0] led7;

  reg  [ 5:0] led0_tmp;  //5:blink,4:dot,[3:0]:bcd
  reg  [ 5:0] led1_tmp;
  reg  [ 5:0] led2_tmp;
  reg  [ 5:0] led3_tmp;
  reg  [ 5:0] led4_tmp;
  reg  [ 5:0] led5_tmp;
  reg  [ 5:0] led6_tmp;
  reg  [ 5:0] led7_tmp;

  wire [15:0] year_bcd;
  wire [ 7:0] month_bcd;
  wire [ 7:0] day_bcd;
  wire [ 7:0] hour_bcd;
  wire [ 7:0] minute_bcd;
  wire [ 7:0] second_bcd;
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [ 2:0] weekday;
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;

  stamp2time stamp2time0 (
      .clk(clk),
      .rst_n(rst_n),
      .counter(counter),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second)
  );

  always @(posedge clk or negedge rst_n) begin
    //显示状态
    if (edit_state == EDIT_IDLE) begin
      case (disp_state)
        TIME_DISP: begin
          led7_tmp <= {2'b01, hour_bcd[7:4]};
          led6_tmp <= {2'b01, hour_bcd[3:0]};
          led5_tmp <= {2'b01, 4'd10};
          led4_tmp <= {2'b01, minute_bcd[7:4]};
          led3_tmp <= {2'b01, minute_bcd[3:0]};
          led2_tmp <= {2'b01, 4'd10};
          led1_tmp <= {2'b01, second_bcd[7:4]};
          led0_tmp <= {2'b01, second_bcd[3:0]};
        end
        DATE_DISP: begin
          led7_tmp <= {2'b01, year_bcd[15:12]};
          led6_tmp <= {2'b01, year_bcd[11:8]};
          led5_tmp <= {2'b01, year_bcd[7:4]};
          led4_tmp <= {2'b00, year_bcd[3:0]};
          led3_tmp <= {2'b01, month_bcd[7:4]};
          led2_tmp <= {2'b00, month_bcd[3:0]};
          led1_tmp <= {2'b01, day_bcd[7:4]};
          led0_tmp <= {2'b00, day_bcd[3:0]};
        end
        ALARM_DISP: begin

        end
        TIMER_DISP: edit_state <= EDIT_TIMER;
        default: edit_state <= EDIT_IDLE;
      endcase
    end else begin

    end

  end



  // led drive block
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      led0 <= 6'b010000;
      led1 <= 6'b010000;
      led2 <= 6'b010000;
      led3 <= 6'b010000;
      led4 <= 6'b010000;
      led5 <= 6'b010000;
      led6 <= 6'b010000;
      led7 <= 6'b010000;
    end else begin
      led0 <= led0_tmp;
      led1 <= led1_tmp;
      led2 <= led2_tmp;
      led3 <= led3_tmp;
      led4 <= led4_tmp;
      led5 <= led5_tmp;
      led6 <= led6_tmp;
      led7 <= led7_tmp;
    end
  end
endmodule
