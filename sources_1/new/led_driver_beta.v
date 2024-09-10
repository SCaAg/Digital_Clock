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
  reg [15:0] year_bcd_editing;
  reg [7:0] month_bcd_editing;
  reg [7:0] day_bcd_editing;
  reg [7:0] hour_bcd_editing;
  reg [7:0] minute_bcd_editing;
  reg [7:0] second_bcd_editing;

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
  reg [7:0] alarm_second_bcd_editing;

  alarm alarm_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_alarm),
      .alarm_year_bcd_in(year_bcd),
      .alarm_month_bcd_in(month_bcd),
      .alarm_day_bcd_in(day_bcd),
      .alarm_hour_bcd_in(alarm_hour_bcd_editing_tmp),
      .alarm_minute_bcd_in(alarm_minute_bcd_editing_tmp),
      .alarm_second_bcd_in(alarm_second_bcd_editing),
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
  reg [7:0] timer_second_bcd_editing;

  count_down_timer count_down_timer_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_timer),
      .play(play_timer),
      .stop(stop_timer),
      .hour_bcd_in(timer_hour_bcd_editing_tmp),
      .minute_bcd_in(timer_minute_bcd_editing_tmp),
      .second_bcd_in(timer_second_bcd_editing),
      .hour_out_bcd(timer_hour_bcd),
      .minute_out_bcd(timer_minute_bcd),
      .second_out_bcd(timer_second_bcd),
      .ring(timer_ring),
      .counting(timer_counting)
  );

  reg [15:0] year_bcd_editing;
  reg [ 7:0] month_bcd_editing;
  reg [ 7:0] day_bcd_editing;
  reg [ 7:0] hour_bcd_editing;
  reg [ 7:0] minute_bcd_editing;
  reg [ 7:0] second_bcd_editing;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      year_bcd_editing   <= 16'd0;
      month_bcd_editing  <= 8'd0;
      day_bcd_editing    <= 8'd0;
      hour_bcd_editing   <= 8'd0;
      minute_bcd_editing <= 8'd0;
      second_bcd_editing <= 8'd0;
    end else begin
      case (state)
        TIME_DISP: begin
          year_bcd_editing   <= year_bcd;
          month_bcd_editing  <= month_bcd;
          day_bcd_editing    <= day_bcd;
          hour_bcd_editing   <= hour_bcd;
          minute_bcd_editing <= minute_bcd;
          second_bcd_editing <= second_bcd;
        end
        DATE_DISP: begin
          year_bcd_editing   <= year_bcd;
          month_bcd_editing  <= month_bcd;
          day_bcd_editing    <= day_bcd;
          hour_bcd_editing   <= hour_bcd;
          minute_bcd_editing <= minute_bcd;
          second_bcd_editing <= second_bcd;
        end
        ALARM_DISP: begin
          hour_bcd_editing   <= alarm_hour_bcd;
          minute_bcd_editing <= alarm_minute_bcd;
          second_bcd_editing <= alarm_second_bcd;
        end
        TIMER_DISP: begin
          hour_bcd_editing   <= timer_hour_bcd;
          minute_bcd_editing <= timer_minute_bcd;
          second_bcd_editing <= timer_second_bcd;
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
