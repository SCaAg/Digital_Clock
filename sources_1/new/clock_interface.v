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

  localparam TIME_DISP = 2'd0;
  localparam DATE_DISP = 2'd1;
  localparam ALARM_DISP = 2'd2;
  localparam TIMER_DISP = 2'd3;
  reg [1:0] disp_state = TIME_DISP;

  localparam EDIT_IDLE = 2'd0;
  localparam EDIT_TIME = 2'd1;
  localparam EDIT_ALARM = 2'd2;
  localparam EDIT_TIMER = 2'd3;
  reg [1:0] edit_state = EDIT_IDLE;

  localparam EDIT_SECOND = 3'd0;
  localparam EDIT_MINUTE = 3'd1;
  localparam EDIT_HOUR = 3'd2;
  localparam EDIT_DAY = 3'd3;
  localparam EDIT_MONTH = 3'd4;
  localparam EDIT_YEAR = 3'd5;
  reg [2:0] edit_opt = EDIT_HOUR;



  // 实例化 unixCounter 模块
  wire [63:0] counter_out;
  wire go = 1'b1;  // 假设计数器始终运行
  reg load_n = 1'b1;  // 假设不需要加载初始值
  reg [63:0] setCounter = 64'd0;  // 初始计数值，可根据需要调整

  unixCounter #(
      .N(64),  // 计数器位数
      .M(26)   // 分频计数器位数
  ) unixCounter_inst (
      .clk(clk),
      .reset_n(rst_n),
      .load_n(load_n),
      .go(go),
      .setCounter(setCounter),
      .counter(counter_out)
  );
  // 实例化 time2stamp 模块
  wire [63:0] time_stamp;
  time2stamp time2stamp_inst (
      .year(bin_year),
      .month(bin_month),
      .day(bin_day),
      .hour(bin_hour),
      .minute(bin_minute),
      .second(bin_second),
      .time_stamp(time_stamp)
  );
  wire [13:0] bin_year = {
    led7_year_edit * 1000 + led6_year_edit * 100 + led5_year_edit * 10 + led4_year_edit
  };
  wire [3:0] bin_month = {led3_month_edit * 10 + led4_month_edit};
  wire [4:0] bin_day = {led1_day_edit * 10 + led0_day_edit};
  wire [4:0] bin_hour = {led7_hour_edit * 10 + led6_hour_edit};
  wire [5:0] bin_minute = {led4_minute_edit * 10 + led3_minute_edit};
  wire [5:0] bin_second = {led1_second_edit * 10 + led0_second_edit};

  reg [3:0] led7_year_edit = 4'd0;
  reg [3:0] led6_year_edit = 4'd0;
  reg [3:0] led5_year_edit = 4'd0;
  reg [3:0] led4_year_edit = 4'd0;
  reg [3:0] led3_month_edit = 4'd0;
  reg [3:0] led2_month_edit = 4'd0;
  reg [3:0] led1_day_edit = 4'd0;
  reg [3:0] led0_day_edit = 4'd0;

  reg [3:0] led7_hour_edit = 4'd0;
  reg [3:0] led6_hour_edit = 4'd0;
  reg [3:0] led4_minute_edit = 4'd0;
  reg [3:0] led3_minute_edit = 4'd0;
  reg [3:0] led1_second_edit = 4'd0;
  reg [3:0] led0_second_edit = 4'd0;

  reg set_alarm = 1'b0;
  reg set_timer = 1'b0;



  // presse down_btn
  reg [15:0] bcd_editing = 16'd0;
  reg [15:0] bcd_editing_tmp = 16'd0;
  reg [15:0] bcd_editing_max = 16'd9999;
  wire [15:0] bcd_editing_incresed;



  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      bcd_editing <= 16'b0;
      bcd_editing_tmp <= 16'b0;
    end else if (~down_btn) begin
      bcd_editing_tmp <= bcd_editing_incresed;
      bcd_editing <= bcd_editing_tmp;
    end else begin
      case (edit_state)
        EDIT_TIME: begin
          case (edit_opt)
            EDIT_YEAR: bcd_editing <= year_bcd;
            EDIT_MONTH: bcd_editing <= {8'b0, month_bcd};
            EDIT_DAY: bcd_editing <= {8'b0, day_bcd};
            EDIT_HOUR: bcd_editing <= {8'b0, hour_bcd};
            EDIT_MINUTE: bcd_editing <= {8'b0, minute_bcd};
            EDIT_SECOND: bcd_editing <= {8'b0, second_bcd};
            default: bcd_editing <= 16'b0;
          endcase
        end
        EDIT_ALARM: begin
          case (edit_opt)
            EDIT_YEAR: bcd_editing <= alarm_year_bcd_in;
            EDIT_MONTH: bcd_editing <= alarm_month_bcd_in;
            EDIT_DAY: bcd_editing <= alarm_day_bcd_in;
            EDIT_HOUR: bcd_editing <= alarm_hour_bcd_in;
            EDIT_MINUTE: bcd_editing <= alarm_minute_bcd_in;
            EDIT_SECOND: bcd_editing <= alarm_second_bcd_in;
            default: bcd_editing <= 16'b0;
          endcase
        end
        EDIT_TIMER: begin
          case (edit_opt)
            EDIT_HOUR: bcd_editing <= timer_hour_bcd_in;
            EDIT_MINUTE: bcd_editing <= timer_minute_bcd_in;
            EDIT_SECOND: bcd_editing <= timer_second_bcd_in;
            default: bcd_editing <= 16'b0;
          endcase
        end
        default: bcd_editing <= 16'b0;
      endcase
    end
  end



  reg [5:0] led0;  //5:blink,4:dot,[3:0]:bcd
  reg [5:0] led1;
  reg [5:0] led2;
  reg [5:0] led3;
  reg [5:0] led4;
  reg [5:0] led5;
  reg [5:0] led6;
  reg [5:0] led7;

  reg [5:0] led0_tmp;  //5:blink,4:dot,[3:0]:bcd
  reg [5:0] led1_tmp;
  reg [5:0] led2_tmp;
  reg [5:0] led3_tmp;
  reg [5:0] led4_tmp;
  reg [5:0] led5_tmp;
  reg [5:0] led6_tmp;
  reg [5:0] led7_tmp;


  reg set;
  wire [15:0] alarm_year_bcd_in;
  wire [7:0] alarm_month_bcd_in;
  wire [7:0] alarm_day_bcd_in;
  wire [7:0] alarm_hour_bcd_in;
  wire [7:0] alarm_minute_bcd_in;
  wire [7:0] alarm_second_bcd_in;
  wire [7:0] alarm_hour_bcd;
  wire [7:0] alarm_minute_bcd;
  wire [7:0] alarm_second_bcd;
  reg cancel;
  wire ring;

  alarm alarm_instance (
      .clk(clk),
      .rst_n(rst_n),
      .set(set),
      .alarm_year_bcd_in(alarm_year_bcd_in),
      .alarm_month_bcd_in(alarm_month_bcd_in),
      .alarm_day_bcd_in(alarm_day_bcd_in),
      .alarm_hour_bcd_in(alarm_hour_bcd_in),
      .alarm_minute_bcd_in(alarm_minute_bcd_in),
      .alarm_second_bcd_in(alarm_second_bcd_in),
      .selected_alarm(selected_alarm),
      .counter(counter),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .cancel(cancel),
      .ring(ring)
  );
  // 计时器相关的寄存器和线
  reg load;
  reg clock_en;
  reg [7:0] timer_hour_bcd_in;
  reg [7:0] timer_minute_bcd_in;
  reg [7:0] timer_second_bcd_in;
  wire [7:0] timer_hour_out_bcd;
  wire [7:0] timer_minute_out_bcd;
  wire [7:0] timer_second_out_bcd;
  wire timer_ring;

  // 实例化计时器模块
  count_down_timer timer_instance (
      .clk(clk),
      .rst_n(rst_n),
      .load(load),
      .clock_en(clock_en),
      .hour_bcd_in(timer_hour_bcd_in),
      .minute_bcd_in(timer_minute_bcd_in),
      .second_bcd_in(timer_second_bcd_in),
      .hour_out_bcd(timer_hour_out_bcd),
      .minute_out_bcd(timer_minute_out_bcd),
      .second_out_bcd(timer_second_out_bcd),
      .ring(timer_ring)
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
          led7_tmp <= {2'b01, 2'd0, selected_alarm};
          led6_tmp <= {2'b01, 4'd10};
          led5_tmp <= {2'b01, alarm_hour_bcd[7:4]};
          led4_tmp <= {2'b01, alarm_hour_bcd[3:0]};
          led3_tmp <= {2'b01, alarm_minute_bcd[7:4]};
          led2_tmp <= {2'b01, alarm_minute_bcd[3:0]};
          led1_tmp <= {2'b01, alarm_second_bcd[7:4]};
          led0_tmp <= {2'b01, alarm_second_bcd[3:0]};
        end
        TIMER_DISP: begin
          led7_tmp <= {2'b01, timer_hour_out_bcd[7:4]};
          led6_tmp <= {2'b01, timer_hour_out_bcd[3:0]};
          led5_tmp <= {2'b01, 4'd10};
          led4_tmp <= {2'b01, timer_minute_out_bcd[7:4]};
          led3_tmp <= {2'b01, timer_minute_out_bcd[3:0]};
          led2_tmp <= {2'b01, 4'd10};
          led1_tmp <= {2'b01, timer_second_out_bcd[7:4]};
          led0_tmp <= {2'b01, timer_second_out_bcd[3:0]};
        end
        default: edit_state <= EDIT_IDLE;
      endcase
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
