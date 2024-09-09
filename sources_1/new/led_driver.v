module led_driver (
    input wire clk,
    input wire rst_n,
    input wire [3:0] state,
    input wire [63:0] counter,  // for time display
    output reg set_counter,
    //---interface to button---//
    input wire up_btn,
    input wire down_btn,
    //---interface to alarm---//
    output wire ring,
    //---interface to led---//
    output reg [5:0] led0,
    output reg [5:0] led1,
    output reg [5:0] led2,
    output reg [5:0] led3,
    output reg [5:0] led4,
    output reg [5:0] led5,
    output reg [5:0] led6,
    output reg [5:0] led7,
    output wire [63:0] counter_out
);
  localparam TIME_DISP = 4'd0;
  localparam DATE_DISP = 4'd1;
  localparam TIME_EDIT_SECOND = 4'd2;
  localparam TIME_EDIT_MINUTE = 4'd3;
  localparam TIME_EDIT_HOUR = 4'd4;
  localparam TIME_EDIT_DAY = 4'd5;
  localparam TIME_EDIT_MONTH = 4'd6;
  localparam TIME_EDIT_YEAR = 4'd7;
  localparam ALARM_DISP = 4'd8;
  localparam ALARM_EDIT_SECOND = 4'd9;
  localparam ALARM_EDIT_MINUTE = 4'd10;
  localparam ALARM_EDIT_HOUR = 4'd11;
  localparam TIMER_DISP = 4'd12;
  localparam TIMER_EDIT_SECOND = 4'd13;
  localparam TIMER_EDIT_MINUTE = 4'd14;
  localparam TIMER_EDIT_HOUR = 4'd15;

  reg [3:0] led_reg[7:0];



  // Time display
  wire [15:0] year_bcd;
  wire [7:0] month_bcd;
  wire [7:0] day_bcd;
  wire [7:0] hour_bcd;
  wire [7:0] minute_bcd;
  wire [7:0] second_bcd;
  // Time editing temporary registers
  reg [15:0] year_bcd_editing_tmp;
  reg [7:0] month_bcd_editing_tmp;
  reg [7:0] day_bcd_editing_tmp;
  reg [7:0] hour_bcd_editing_tmp;
  reg [7:0] minute_bcd_editing_tmp;
  reg [7:0] second_bcd_editing_tmp;

  stamp2time stamp2time_inst (
      .clk(clk),
      .rst_n(rst_n),
      .counter(counter),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd)
  );

  // Alarm display
  reg set_alarm;
  wire [7:0] alarm_hour_bcd;
  wire [7:0] alarm_minute_bcd;
  wire [7:0] alarm_second_bcd;
  reg [1:0] selected_alarm = 2'd0;
  reg cancel_alarm;
  wire alarm_ring;
  // Alarm editing temporary registers
  reg [7:0] alarm_hour_bcd_editing_tmp;
  reg [7:0] alarm_minute_bcd_editing_tmp;
  reg [7:0] alarm_second_bcd_editing_tmp;

  alarm alarm_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_alarm),
      .alarm_year_bcd_in(year_bcd),
      .alarm_month_bcd_in(month_bcd),
      .alarm_day_bcd_in(day_bcd),
      .alarm_hour_bcd_in({led_reg[5], led_reg[4]}),
      .alarm_minute_bcd_in({led_reg[3], led_reg[2]}),
      .alarm_second_bcd_in({led_reg[1], led_reg[0]}),
      .selected_alarm(selected_alarm),
      .counter(counter),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .cancel(cancel_alarm),
      .ring(alarm_ring)
  );

  // Timer display
  wire set_timer;
  reg play_timer;
  reg stop_timer;
  wire [7:0] timer_hour_bcd;
  wire [7:0] timer_minute_bcd;
  wire [7:0] timer_second_bcd;
  wire timer_ring;
  wire timer_counting;
  reg set_timer_after_stop;
  reg set_timer_after_edit;
  assign set_timer = set_timer_after_edit || set_timer_after_stop;
  // Timer editing temporary registers
  reg [7:0] timer_hour_bcd_editing_tmp;
  reg [7:0] timer_minute_bcd_editing_tmp;
  reg [7:0] timer_second_bcd_editing_tmp;

  count_down_timer count_down_timer_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_timer),
      .play(play_timer),
      .stop(stop_timer),
      .hour_bcd_in({led_reg[7], led_reg[6]}),
      .minute_bcd_in({led_reg[4], led_reg[3]}),
      .second_bcd_in({led_reg[1], led_reg[0]}),
      .hour_out_bcd(timer_hour_bcd),
      .minute_out_bcd(timer_minute_bcd),
      .second_out_bcd(timer_second_bcd),
      .ring(timer_ring),
      .counting(timer_counting)
  );

  // BCD increment
  reg  [15:0] bcd_editing;
  reg  [15:0] bcd_editing_max;
  wire [15:0] bcd_incremented;

  bcd_increment_16bit bcd_increment_inst (
      .bcd_in (bcd_editing),
      .bcd_max(bcd_editing_max),
      .bcd_out(bcd_incremented)
  );

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      bcd_editing <= 16'b0;
      bcd_editing_max <= 16'b0;
    end else begin
      case (state)
        TIME_DISP: begin
          bcd_editing <= bcd_editing;
          bcd_editing_max <= bcd_editing_max;
        end
        DATE_DISP: begin
          bcd_editing <= bcd_editing;
          bcd_editing_max <= bcd_editing_max;
        end
        TIME_EDIT_SECOND: begin
          bcd_editing <= {8'b0, second_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        TIME_EDIT_MINUTE: begin
          bcd_editing <= {8'b0, minute_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        TIME_EDIT_HOUR: begin
          bcd_editing <= {8'b0, hour_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd23};
        end
        TIME_EDIT_DAY: begin
          bcd_editing <= {8'b0, day_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd31};
        end
        TIME_EDIT_MONTH: begin
          bcd_editing <= {8'b0, month_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd12};
        end
        TIME_EDIT_YEAR: begin
          bcd_editing <= year_bcd_editing_tmp;
          bcd_editing_max <= {8'd99, 8'd99};
        end
        ALARM_DISP: begin
          bcd_editing <= bcd_editing;
          bcd_editing_max <= bcd_editing_max;
        end
        ALARM_EDIT_SECOND: begin
          bcd_editing <= {8'b0, alarm_second_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        ALARM_EDIT_MINUTE: begin
          bcd_editing <= {8'b0, alarm_minute_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        ALARM_EDIT_HOUR: begin
          bcd_editing <= {8'b0, alarm_hour_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd23};
        end
        TIMER_DISP: begin
          bcd_editing <= bcd_editing;
          bcd_editing_max <= bcd_editing_max;
        end
        TIMER_EDIT_SECOND: begin
          bcd_editing <= {8'b0, timer_second_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        TIMER_EDIT_MINUTE: begin
          bcd_editing <= {8'b0, timer_minute_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd59};
        end
        TIMER_EDIT_HOUR: begin
          bcd_editing <= {8'b0, timer_hour_bcd_editing_tmp};
          bcd_editing_max <= {8'b0, 8'd23};
        end
        default: begin
          bcd_editing <= bcd_editing;
          bcd_editing_max <= bcd_editing_max;
        end
      endcase
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      led_reg[0]   <= 4'b0;
      led_reg[1]   <= 4'b0;
      led_reg[2]   <= 4'b0;
      led_reg[3]   <= 4'b0;
      led_reg[4]   <= 4'b0;
      led_reg[5]   <= 4'b0;
      led_reg[6]   <= 4'b0;
      led_reg[7]   <= 4'b0;
      cancel_alarm <= 1'b0;
    end else if (~down_btn) begin
      cancel_alarm <= 1'b0;
      case (state)
        TIME_DISP: begin
          led_reg[7] <= hour_bcd[7:4];
          led_reg[6] <= hour_bcd[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd[7:4];
          led_reg[3] <= minute_bcd[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd[7:4];
          led_reg[0] <= second_bcd[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        DATE_DISP: begin
          led_reg[7] <= year_bcd[15:12];
          led_reg[6] <= year_bcd[11:8];
          led_reg[5] <= year_bcd[7:4];
          led_reg[4] <= year_bcd[3:0];
          led_reg[3] <= month_bcd[7:4];
          led_reg[2] <= month_bcd[3:0];
          led_reg[1] <= day_bcd[7:4];
          led_reg[0] <= day_bcd[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_SECOND: begin
          led_reg[7] <= hour_bcd_editing_tmp[7:4];
          led_reg[6] <= hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_editing_tmp[7:4];
          led_reg[3] <= minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= bcd_incremented[7:4];
          led_reg[0] <= bcd_incremented[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_MINUTE: begin
          led_reg[7] <= hour_bcd_editing_tmp[7:4];
          led_reg[6] <= hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= bcd_incremented[7:4];
          led_reg[3] <= bcd_incremented[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_editing_tmp[7:4];
          led_reg[0] <= second_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_HOUR: begin
          led_reg[7] <= bcd_incremented[7:4];
          led_reg[6] <= bcd_incremented[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_editing_tmp[7:4];
          led_reg[3] <= minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_editing_tmp[7:4];
          led_reg[0] <= second_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_DAY: begin
          led_reg[7] <= year_bcd_editing_tmp[15:12];
          led_reg[6] <= year_bcd_editing_tmp[11:8];
          led_reg[5] <= year_bcd_editing_tmp[7:4];
          led_reg[4] <= year_bcd_editing_tmp[3:0];
          led_reg[3] <= month_bcd_editing_tmp[7:4];
          led_reg[2] <= month_bcd_editing_tmp[3:0];
          led_reg[1] <= bcd_incremented[7:4];
          led_reg[0] <= bcd_incremented[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_MONTH: begin
          led_reg[7] <= year_bcd_editing_tmp[15:12];
          led_reg[6] <= year_bcd_editing_tmp[11:8];
          led_reg[5] <= year_bcd_editing_tmp[7:4];
          led_reg[4] <= year_bcd_editing_tmp[3:0];
          led_reg[3] <= bcd_incremented[7:4];
          led_reg[2] <= bcd_incremented[3:0];
          led_reg[1] <= day_bcd_editing_tmp[7:4];
          led_reg[0] <= day_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_YEAR: begin
          led_reg[7] <= bcd_incremented[15:12];
          led_reg[6] <= bcd_incremented[11:8];
          led_reg[5] <= bcd_incremented[7:4];
          led_reg[4] <= bcd_incremented[3:0];
          led_reg[3] <= month_bcd_editing_tmp[7:4];
          led_reg[2] <= month_bcd_editing_tmp[3:0];
          led_reg[1] <= day_bcd_editing_tmp[7:4];
          led_reg[0] <= day_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_DISP: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd[7:4];
          led_reg[4] <= alarm_hour_bcd[3:0];
          led_reg[3] <= alarm_minute_bcd[7:4];
          led_reg[2] <= alarm_minute_bcd[3:0];
          led_reg[1] <= alarm_second_bcd[7:4];
          led_reg[0] <= alarm_second_bcd[3:0];
          cancel_alarm <= 1'b1;
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_SECOND: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= bcd_incremented[7:4];
          led_reg[4] <= bcd_incremented[3:0];
          led_reg[3] <= alarm_minute_bcd_editing_tmp[7:4];
          led_reg[2] <= alarm_minute_bcd_editing_tmp[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_MINUTE: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd_editing_tmp[7:4];
          led_reg[4] <= alarm_hour_bcd_editing_tmp[3:0];
          led_reg[3] <= bcd_incremented[7:4];
          led_reg[2] <= bcd_incremented[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_HOUR: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= bcd_incremented[7:4];
          led_reg[4] <= bcd_incremented[3:0];
          led_reg[3] <= alarm_minute_bcd_editing_tmp[7:4];
          led_reg[2] <= alarm_minute_bcd_editing_tmp[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIMER_DISP: begin
          led_reg[7] <= timer_hour_bcd[7:4];
          led_reg[6] <= timer_hour_bcd[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd[7:4];
          led_reg[3] <= timer_minute_bcd[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd[7:4];
          led_reg[0] <= timer_second_bcd[3:0];
          case (timer_counting)
            1'b0: play_timer <= 1'b1;
            default: play_timer <= play_timer;
          endcase
          cancel_alarm <= 1'b1;
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIMER_EDIT_SECOND: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[3] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= bcd_incremented[7:4];
          led_reg[0] <= bcd_incremented[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        TIMER_EDIT_MINUTE: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= bcd_incremented[7:4];
          led_reg[3] <= bcd_incremented[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[0] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        TIMER_EDIT_HOUR: begin
          led_reg[7] <= bcd_incremented[7:4];
          led_reg[6] <= bcd_incremented[3:0];
          led_reg[5] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[4] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[3] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[2] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        default: ;
      endcase
    end else if (~up_btn) begin
      case (state)
        ALARM_DISP: begin
          selected_alarm <= selected_alarm == 2'd2 ? 2'd0 : selected_alarm + 2'd1;
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd[7:4];
          led_reg[4] <= alarm_hour_bcd[3:0];
          led_reg[3] <= alarm_minute_bcd[7:4];
          led_reg[2] <= alarm_minute_bcd[3:0];
          led_reg[1] <= alarm_second_bcd[7:4];
          led_reg[0] <= alarm_second_bcd[3:0];
          cancel_alarm <= 1'b1;
        end
        TIMER_DISP: begin
          led_reg[7] <= timer_hour_bcd[7:4];
          led_reg[6] <= timer_hour_bcd[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd[7:4];
          led_reg[3] <= timer_minute_bcd[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd[7:4];
          led_reg[0] <= timer_second_bcd[3:0];
          case (timer_counting)
            1'b0: begin
              stop_timer <= 1'b0;
              play_timer <= 1'b0;
              set_timer_after_stop <= 1'b1;
            end
            1'b1: begin
              stop_timer <= 1'b1;
              play_timer <= 1'b0;
              set_timer_after_stop <= 1'b0;
            end
            default: begin
              stop_timer <= stop_timer;
              play_timer <= play_timer;
              set_timer_after_stop <= set_timer_after_stop;
            end
          endcase
        end
        default: begin
          led_reg[7] <= led_reg[7];
          led_reg[6] <= led_reg[6];
          led_reg[5] <= led_reg[5];
          led_reg[4] <= led_reg[4];
          led_reg[3] <= led_reg[3];
          led_reg[2] <= led_reg[2];
          led_reg[1] <= led_reg[1];
          led_reg[0] <= led_reg[0];
        end
      endcase
    end else begin
      cancel_alarm <= 1'b0;
      case (state)
        TIME_DISP: begin
          led_reg[7] <= hour_bcd[7:4];
          led_reg[6] <= hour_bcd[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd[7:4];
          led_reg[3] <= minute_bcd[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd[7:4];
          led_reg[0] <= second_bcd[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        DATE_DISP: begin
          led_reg[7] <= year_bcd[15:12];
          led_reg[6] <= year_bcd[11:8];
          led_reg[5] <= year_bcd[7:4];
          led_reg[4] <= year_bcd[3:0];
          led_reg[3] <= month_bcd[7:4];
          led_reg[2] <= month_bcd[3:0];
          led_reg[1] <= day_bcd[7:4];
          led_reg[0] <= day_bcd[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_SECOND: begin
          led_reg[7] <= hour_bcd_editing_tmp[7:4];
          led_reg[6] <= hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_editing_tmp[7:4];
          led_reg[3] <= minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= hour_bcd_editing_tmp[7:4];
          led_reg[0] <= hour_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_MINUTE: begin
          led_reg[7] <= hour_bcd_editing_tmp[7:4];
          led_reg[6] <= hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_editing_tmp[7:4];
          led_reg[3] <= minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_editing_tmp[7:4];
          led_reg[0] <= second_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_HOUR: begin
          led_reg[7] <= hour_bcd_editing_tmp[7:4];
          led_reg[6] <= hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_editing_tmp[7:4];
          led_reg[3] <= minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_editing_tmp[7:4];
          led_reg[0] <= second_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_DAY: begin
          led_reg[7] <= year_bcd_editing_tmp[15:12];
          led_reg[6] <= year_bcd_editing_tmp[11:8];
          led_reg[5] <= year_bcd_editing_tmp[7:4];
          led_reg[4] <= year_bcd_editing_tmp[3:0];
          led_reg[3] <= month_bcd_editing_tmp[7:4];
          led_reg[2] <= month_bcd_editing_tmp[3:0];
          led_reg[1] <= day_bcd_editing_tmp[7:4];
          led_reg[0] <= day_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_MONTH: begin
          led_reg[7] <= year_bcd_editing_tmp[15:12];
          led_reg[6] <= year_bcd_editing_tmp[11:8];
          led_reg[5] <= year_bcd_editing_tmp[7:4];
          led_reg[4] <= year_bcd_editing_tmp[3:0];
          led_reg[3] <= month_bcd_editing_tmp[7:4];
          led_reg[2] <= month_bcd_editing_tmp[3:0];
          led_reg[1] <= day_bcd_editing_tmp[7:4];
          led_reg[0] <= day_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIME_EDIT_YEAR: begin
          led_reg[7] <= year_bcd_editing_tmp[15:12];
          led_reg[6] <= year_bcd_editing_tmp[11:8];
          led_reg[5] <= year_bcd_editing_tmp[7:4];
          led_reg[4] <= year_bcd_editing_tmp[3:0];
          led_reg[3] <= month_bcd_editing_tmp[7:4];
          led_reg[2] <= month_bcd_editing_tmp[3:0];
          led_reg[1] <= day_bcd_editing_tmp[7:4];
          led_reg[0] <= day_bcd_editing_tmp[3:0];
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_DISP: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd[7:4];
          led_reg[4] <= alarm_hour_bcd[3:0];
          led_reg[3] <= alarm_minute_bcd[7:4];
          led_reg[2] <= alarm_minute_bcd[3:0];
          led_reg[1] <= alarm_second_bcd[7:4];
          led_reg[0] <= alarm_second_bcd[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_SECOND: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd_editing_tmp[7:4];
          led_reg[4] <= alarm_hour_bcd_editing_tmp[3:0];
          led_reg[3] <= alarm_minute_bcd_editing_tmp[7:4];
          led_reg[2] <= alarm_minute_bcd_editing_tmp[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_MINUTE: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd_editing_tmp[7:4];
          led_reg[4] <= alarm_hour_bcd_editing_tmp[3:0];
          led_reg[3] <= alarm_minute_bcd_editing_tmp[7:4];
          led_reg[2] <= alarm_minute_bcd_editing_tmp[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        ALARM_EDIT_HOUR: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= alarm_hour_bcd_editing_tmp[7:4];
          led_reg[4] <= alarm_hour_bcd_editing_tmp[3:0];
          led_reg[3] <= alarm_minute_bcd_editing_tmp[7:4];
          led_reg[2] <= alarm_minute_bcd_editing_tmp[3:0];
          led_reg[1] <= alarm_second_bcd_editing_tmp[7:4];
          led_reg[0] <= alarm_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIMER_DISP: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[3] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[0] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
          timer_second_bcd_editing_tmp <= timer_second_bcd;
          timer_minute_bcd_editing_tmp <= timer_minute_bcd;
          timer_hour_bcd_editing_tmp <= timer_hour_bcd;
        end
        TIMER_EDIT_SECOND: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[3] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[0] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        TIMER_EDIT_MINUTE: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[3] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[0] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        TIMER_EDIT_HOUR: begin
          led_reg[7] <= timer_hour_bcd_editing_tmp[7:4];
          led_reg[6] <= timer_hour_bcd_editing_tmp[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= timer_minute_bcd_editing_tmp[7:4];
          led_reg[3] <= timer_minute_bcd_editing_tmp[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= timer_second_bcd_editing_tmp[7:4];
          led_reg[0] <= timer_second_bcd_editing_tmp[3:0];
          second_bcd_editing_tmp <= second_bcd;
          minute_bcd_editing_tmp <= minute_bcd;
          hour_bcd_editing_tmp <= hour_bcd;
          day_bcd_editing_tmp <= day_bcd;
          month_bcd_editing_tmp <= month_bcd;
          year_bcd_editing_tmp <= year_bcd;
          alarm_second_bcd_editing_tmp <= alarm_second_bcd;
          alarm_minute_bcd_editing_tmp <= alarm_minute_bcd;
          alarm_hour_bcd_editing_tmp <= alarm_hour_bcd;
        end
        default: begin
          led_reg[7] <= led_reg[7];
          led_reg[6] <= led_reg[6];
          led_reg[5] <= led_reg[5];
          led_reg[4] <= led_reg[4];
          led_reg[3] <= led_reg[3];
          led_reg[2] <= led_reg[2];
          led_reg[1] <= led_reg[1];
          led_reg[0] <= led_reg[0];
        end
      endcase
    end
  end



  reg [3:0] current_state;
  reg [3:0] previous_state;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      current_state  <= TIME_DISP;
      previous_state <= TIME_DISP;
    end else begin
      previous_state <= current_state;
      current_state  <= state;
    end
  end




  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      set_alarm <= 1'b0;
      set_timer_after_edit <= 1'b0;
      set_counter <= 1'b0;
    end else begin
      if((previous_state == TIME_EDIT_SECOND||previous_state == TIME_EDIT_MINUTE||previous_state == TIME_EDIT_HOUR||previous_state == TIME_EDIT_DAY||previous_state == TIME_EDIT_MONTH||previous_state == TIME_EDIT_YEAR)&&(current_state == TIME_DISP)) begin
        set_alarm <= 1'b0;
        set_timer_after_edit <= 1'b0;
        set_counter <= 1'b1;
      end
      else if((previous_state == ALARM_EDIT_SECOND||previous_state == ALARM_EDIT_MINUTE||previous_state == ALARM_EDIT_HOUR)&&(current_state == ALARM_DISP)) begin
        set_alarm <= 1'b1;
        set_timer_after_edit <= 1'b0;
        set_counter <= 1'b0;
      end
      else if((previous_state == TIMER_EDIT_SECOND||previous_state == TIMER_EDIT_MINUTE||previous_state == TIMER_EDIT_HOUR)&&(current_state == TIMER_DISP)) begin
        set_alarm <= 1'b0;
        set_timer_after_edit <= 1'b1;
        set_counter <= 1'b0;
      end else begin
        set_alarm <= 1'b0;
        set_timer_after_edit <= 1'b0;
        set_counter <= 1'b0;
      end
    end
  end

  // 实例化 time2stamp 模块
  time2stamp time2stamp_inst (
      .year_bcd({led_reg[7], led_reg[6], led_reg[5], led_reg[4]}),
      .month_bcd({led_reg[3], led_reg[2]}),
      .day_bcd({led_reg[1], led_reg[0]}),
      .hour_bcd({led_reg[7], led_reg[6]}),
      .minute_bcd({led_reg[4], led_reg[3]}),
      .second_bcd({led_reg[1], led_reg[0]}),
      .time_stamp(counter_out)
  );

  reg [7:0] dot_reg;
  reg [7:0] blink_reg;
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      dot_reg   <= 8'b11111111;
      blink_reg <= 8'b00000000;
    end else begin
      case (state)
        TIME_DISP: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00000000;
        end
        DATE_DISP: begin
          dot_reg   <= 8'b11101010;
          blink_reg <= 8'b00000000;
        end
        TIME_EDIT_SECOND: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00000011;
        end
        TIME_EDIT_MINUTE: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00011000;
        end
        TIME_EDIT_HOUR: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b11000000;
        end
        TIME_EDIT_DAY: begin
          dot_reg   <= 8'b11101010;
          blink_reg <= 8'b00000011;
        end
        TIME_EDIT_MONTH: begin
          dot_reg   <= 8'b11101010;
          blink_reg <= 8'b00001100;
        end
        TIME_EDIT_YEAR: begin
          dot_reg   <= 8'b11101010;
          blink_reg <= 8'b11110000;
        end
        ALARM_DISP: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00000000;
        end
        ALARM_EDIT_SECOND: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00000011;
        end
        ALARM_EDIT_MINUTE: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00001100;
        end
        ALARM_EDIT_HOUR: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00110000;
        end
        TIMER_DISP: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= timer_ring ? 8'b11111111 : 8'b00000000;
        end
        TIMER_EDIT_SECOND: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00000011;
        end
        TIMER_EDIT_MINUTE: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b00011000;
        end
        TIMER_EDIT_HOUR: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= 8'b11000000;
        end
        default: begin
          dot_reg   <= dot_reg;
          blink_reg <= blink_reg;
        end
      endcase
    end
  end


  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      led0 <= 6'b0;
      led1 <= 6'b0;
      led2 <= 6'b0;
      led3 <= 6'b0;
      led4 <= 6'b0;
      led5 <= 6'b0;
      led6 <= 6'b0;
      led7 <= 6'b0;
    end else begin
      led0 <= {blink_reg[0], dot_reg[0], led_reg[0]};
      led1 <= {blink_reg[1], dot_reg[1], led_reg[1]};
      led2 <= {blink_reg[2], dot_reg[2], led_reg[2]};
      led3 <= {blink_reg[3], dot_reg[3], led_reg[3]};
      led4 <= {blink_reg[4], dot_reg[4], led_reg[4]};
      led5 <= {blink_reg[5], dot_reg[5], led_reg[5]};
      led6 <= {blink_reg[6], dot_reg[6], led_reg[6]};
      led7 <= {blink_reg[7], dot_reg[7], led_reg[7]};
    end
  end


  assign ring = alarm_ring || timer_ring;

endmodule
