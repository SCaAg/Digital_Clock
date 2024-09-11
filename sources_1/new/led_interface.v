module led_interface (
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
    output reg [3:0] led0,
    output reg [3:0] led1,
    output reg [3:0] led2,
    output reg [3:0] led3,
    output reg [3:0] led4,
    output reg [3:0] led5,
    output reg [3:0] led6,
    output reg [3:0] led7,
    output wire [63:0] counter_out,
    output reg [7:0] dot_reg,
    output reg [7:0] blink_reg,
    output wire [15:0] year_bcd,
    output wire [7:0] month_bcd,
    output wire [7:0] day_bcd,
    output wire [7:0] hour_bcd,
    output wire [7:0] minute_bcd,
    output wire [7:0] second_bcd
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

  wire down_btn_negedge;
  wire up_btn_negedge;
  reg [1:0] down_btn_buf;
  reg [1:0] up_btn_buf;
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      down_btn_buf <= 2'b11;
      up_btn_buf   <= 2'b11;
    end else begin
      down_btn_buf <= {down_btn_buf[0], down_btn};
      up_btn_buf   <= {up_btn_buf[0], up_btn};
    end
  end
  assign down_btn_negedge = down_btn_buf == 2'b10;
  assign up_btn_negedge   = up_btn_buf == 2'b10;

  // Time display

  // Time editing temporary registers
  reg [15:0] year_bcd_edit;
  reg [ 7:0] month_bcd_edit;
  reg [ 7:0] day_bcd_edit;
  reg [ 7:0] hour_bcd_edit;
  reg [ 7:0] minute_bcd_edit;
  reg [ 7:0] second_bcd_edit;

  reg [79:0] year_bcd_edit_buf;
  reg [39:0] month_bcd_edit_buf;
  reg [39:0] day_bcd_edit_buf;
  reg [39:0] hour_bcd_edit_buf;
  reg [39:0] minute_bcd_edit_buf;
  reg [39:0] second_bcd_edit_buf;
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      year_bcd_edit_buf <= 80'b0;
      month_bcd_edit_buf <= 40'b0;
      day_bcd_edit_buf <= 40'b0;
      hour_bcd_edit_buf <= 40'b0;
      minute_bcd_edit_buf <= 40'b0;
      second_bcd_edit_buf <= 40'b0;
    end else begin
      year_bcd_edit_buf <= {year_bcd_edit_buf[63:0], year_bcd_edit[15:0]};
      month_bcd_edit_buf <= {month_bcd_edit_buf[31:0], month_bcd_edit[7:0]};
      day_bcd_edit_buf <= {day_bcd_edit_buf[31:0], day_bcd_edit[7:0]};
      hour_bcd_edit_buf <= {hour_bcd_edit_buf[31:0], hour_bcd_edit[7:0]};
      minute_bcd_edit_buf <= {minute_bcd_edit_buf[31:0], minute_bcd_edit[7:0]};
      second_bcd_edit_buf <= {second_bcd_edit_buf[31:0], second_bcd_edit[7:0]};
    end
  end

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

  alarm alarm_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_alarm),
      .alarm_year_bcd_in(year_bcd),
      .alarm_month_bcd_in(month_bcd),
      .alarm_day_bcd_in(day_bcd),
      .alarm_hour_bcd_in(hour_bcd_edit_buf[39:32]),
      .alarm_minute_bcd_in(minute_bcd_edit_buf[39:32]),
      .alarm_second_bcd_in(second_bcd_edit_buf[39:32]),
      .selected_alarm(selected_alarm),
      .counter(counter),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .cancel(cancel_alarm),
      .ring(alarm_ring)
  );

  // Timer display
  reg play_timer;
  reg stop_timer;
  wire [7:0] timer_hour_bcd;
  wire [7:0] timer_minute_bcd;
  wire [7:0] timer_second_bcd;
  wire timer_ring;
  wire timer_counting;
  reg set_timer = 1'b0;
  reg reset_timer = 1'b0;

  count_down_timer count_down_timer_inst (
      .clk(clk),
      .rst_n(rst_n),
      .reset(reset_timer),
      .set(set_timer),
      .play(play_timer),
      .stop(stop_timer),
      .hour_bcd_in(hour_bcd_edit_buf[39:32]),
      .minute_bcd_in(minute_bcd_edit_buf[39:32]),
      .second_bcd_in(second_bcd_edit_buf[39:32]),
      .hour_out_bcd(timer_hour_bcd),
      .minute_out_bcd(timer_minute_bcd),
      .second_out_bcd(timer_second_bcd),
      .ring(timer_ring),
      .counting(timer_counting)
  );




  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      second_bcd_edit <= second_bcd;
      minute_bcd_edit <= minute_bcd;
      hour_bcd_edit   <= hour_bcd;
      day_bcd_edit    <= day_bcd;
      month_bcd_edit  <= month_bcd;
      year_bcd_edit   <= year_bcd;
    end else if (down_btn_negedge) begin
      case (state)
        TIME_DISP, DATE_DISP: begin
          second_bcd_edit <= second_bcd;
          minute_bcd_edit <= minute_bcd;
          hour_bcd_edit   <= hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        ALARM_DISP: begin
          second_bcd_edit <= alarm_second_bcd;
          minute_bcd_edit <= alarm_minute_bcd;
          hour_bcd_edit   <= alarm_hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        TIMER_DISP: begin
          second_bcd_edit <= timer_second_bcd;
          minute_bcd_edit <= timer_minute_bcd;
          hour_bcd_edit   <= timer_hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        TIME_EDIT_SECOND, ALARM_EDIT_SECOND, TIMER_EDIT_SECOND: begin
          if (second_bcd_edit == 8'h59) begin
            second_bcd_edit <= 8'h0;
          end else if (second_bcd_edit[3:0] == 4'd9) begin
            second_bcd_edit[3:0] <= 4'd0;
            second_bcd_edit[7:4] <= second_bcd_edit[7:4] + 1;
          end else begin
            second_bcd_edit <= second_bcd_edit + 1;
          end
          minute_bcd_edit <= minute_bcd_edit;
          hour_bcd_edit   <= hour_bcd_edit;
          day_bcd_edit    <= day_bcd_edit;
          month_bcd_edit  <= month_bcd_edit;
          year_bcd_edit   <= year_bcd_edit;
        end
        TIME_EDIT_MINUTE, ALARM_EDIT_MINUTE, TIMER_EDIT_MINUTE: begin
          second_bcd_edit <= second_bcd_edit;
          if (minute_bcd_edit == 8'h59) begin
            minute_bcd_edit <= 8'h0;
          end else if (minute_bcd_edit[3:0] == 4'd9) begin
            minute_bcd_edit[3:0] <= 4'd0;
            minute_bcd_edit[7:4] <= minute_bcd_edit[7:4] + 1;
          end else begin
            minute_bcd_edit <= minute_bcd_edit + 1;
          end
          hour_bcd_edit  <= hour_bcd_edit;
          day_bcd_edit   <= day_bcd_edit;
          month_bcd_edit <= month_bcd_edit;
          year_bcd_edit  <= year_bcd_edit;
        end
        TIME_EDIT_HOUR, ALARM_EDIT_HOUR, TIMER_EDIT_HOUR: begin
          second_bcd_edit <= second_bcd_edit;
          minute_bcd_edit <= minute_bcd_edit;
          if (hour_bcd_edit == 8'h23) begin
            hour_bcd_edit <= 8'h0;
          end else if (hour_bcd_edit[3:0] == 4'd9) begin
            hour_bcd_edit[3:0] <= 4'd0;
            hour_bcd_edit[7:4] <= hour_bcd_edit[7:4] + 1;
          end else begin
            hour_bcd_edit <= hour_bcd_edit + 1;
          end
          day_bcd_edit   <= day_bcd_edit;
          month_bcd_edit <= month_bcd_edit;
          year_bcd_edit  <= year_bcd_edit;
        end
        TIME_EDIT_DAY: begin
          second_bcd_edit <= second_bcd_edit;
          minute_bcd_edit <= minute_bcd_edit;
          hour_bcd_edit   <= hour_bcd_edit;
          if (day_bcd_edit == 8'h31) begin
            day_bcd_edit <= 8'h1;
          end else if (day_bcd_edit[3:0] == 4'd9) begin
            day_bcd_edit[3:0] <= 4'd0;
            day_bcd_edit[7:4] <= day_bcd_edit[7:4] + 1;
          end else begin
            day_bcd_edit <= day_bcd_edit + 1;
          end
          month_bcd_edit <= month_bcd_edit;
          year_bcd_edit  <= year_bcd_edit;
        end
        TIME_EDIT_MONTH: begin
          second_bcd_edit <= second_bcd_edit;
          minute_bcd_edit <= minute_bcd_edit;
          hour_bcd_edit   <= hour_bcd_edit;
          if (month_bcd_edit == 8'h12) begin
            month_bcd_edit <= 8'h1;
          end else if (month_bcd_edit[3:0] == 4'd9) begin
            month_bcd_edit[3:0] <= 4'd0;
            month_bcd_edit[7:4] <= month_bcd_edit[7:4] + 1;
          end else begin
            month_bcd_edit <= month_bcd_edit + 1;
          end
          day_bcd_edit  <= day_bcd_edit;
          year_bcd_edit <= year_bcd_edit;
        end
        TIME_EDIT_YEAR: begin
          second_bcd_edit <= second_bcd_edit;
          minute_bcd_edit <= minute_bcd_edit;
          hour_bcd_edit   <= hour_bcd_edit;
          day_bcd_edit    <= day_bcd_edit;
          month_bcd_edit  <= month_bcd_edit;
          if (year_bcd_edit == 16'h9999) begin
            year_bcd_edit <= 16'h1970;
          end else if (year_bcd_edit[3:0] == 4'h9) begin
            if (year_bcd_edit[7:4] == 4'h9) begin
              if (year_bcd_edit[11:8] == 4'h9) begin
                if (year_bcd_edit[15:12] == 4'h9) begin
                  year_bcd_edit <= 16'h0;
                end else begin
                  year_bcd_edit[15:12] <= year_bcd_edit[15:12] + 1;
                  year_bcd_edit[11:8]  <= 4'h0;
                  year_bcd_edit[7:4]   <= 4'h0;
                  year_bcd_edit[3:0]   <= 4'h0;
                end
              end else begin
                year_bcd_edit[11:8] <= year_bcd_edit[11:8] + 1;
                year_bcd_edit[7:4]  <= 4'h0;
                year_bcd_edit[3:0]  <= 4'h0;
              end
            end else begin
              year_bcd_edit[7:4] <= year_bcd_edit[7:4] + 1;
              year_bcd_edit[3:0] <= 4'h0;
            end
          end else begin
            year_bcd_edit <= year_bcd_edit + 1;
          end
        end
      endcase
    end else if (up_btn_negedge) begin
      if (state == TIME_EDIT_YEAR) begin
        if (year_bcd_edit == 16'h1970) begin
          year_bcd_edit <= 16'h9999;
        end else if (year_bcd_edit[3:0] == 4'h0) begin
          if (year_bcd_edit[7:4] == 4'h0) begin
            if (year_bcd_edit[11:8] == 4'h0) begin
              if (year_bcd_edit[15:12] == 4'h0) begin
                year_bcd_edit <= 16'h9999;
              end else begin
                year_bcd_edit[15:12] <= year_bcd_edit[15:12] - 1;
                year_bcd_edit[11:8]  <= 4'h9;
                year_bcd_edit[7:4]   <= 4'h9;
                year_bcd_edit[3:0]   <= 4'h9;
              end
            end else begin
              year_bcd_edit[11:8] <= year_bcd_edit[11:8] - 1;
              year_bcd_edit[7:4]  <= 4'h9;
              year_bcd_edit[3:0]  <= 4'h9;
            end
          end else begin
            year_bcd_edit[7:4] <= year_bcd_edit[7:4] - 1;
            year_bcd_edit[3:0] <= 4'h9;
          end
        end else begin
          year_bcd_edit[3:0] <= year_bcd_edit[3:0] - 1;
        end

      end

    end else begin
      case (state)
        TIME_DISP, DATE_DISP: begin
          second_bcd_edit <= second_bcd;
          minute_bcd_edit <= minute_bcd;
          hour_bcd_edit   <= hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        ALARM_DISP: begin
          second_bcd_edit <= alarm_second_bcd;
          minute_bcd_edit <= alarm_minute_bcd;
          hour_bcd_edit   <= alarm_hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        TIMER_DISP: begin
          second_bcd_edit <= timer_second_bcd;
          minute_bcd_edit <= timer_minute_bcd;
          hour_bcd_edit   <= timer_hour_bcd;
          day_bcd_edit    <= day_bcd;
          month_bcd_edit  <= month_bcd;
          year_bcd_edit   <= year_bcd;
        end
        default: begin
          second_bcd_edit <= second_bcd_edit;
          minute_bcd_edit <= minute_bcd_edit;
          hour_bcd_edit   <= hour_bcd_edit;
          day_bcd_edit    <= day_bcd_edit;
          month_bcd_edit  <= month_bcd_edit;
          year_bcd_edit   <= year_bcd_edit;
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
      stop_timer   <= 1'b1;
      play_timer   <= 1'b0;
      reset_timer  <= 1'b0;
    end else if (down_btn_negedge) begin
      cancel_alarm <= 1'b1;
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
              if (~timer_ring) begin
                play_timer <= 1'b1;
              end else begin
                play_timer  <= 1'b0;
                reset_timer <= 1'b1;
              end
            end
            default: play_timer <= play_timer;
          endcase
        end
        TIME_EDIT_SECOND,TIME_EDIT_MINUTE,TIME_EDIT_HOUR,TIMER_EDIT_SECOND,TIMER_EDIT_MINUTE,TIMER_EDIT_HOUR: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIME_EDIT_DAY, TIME_EDIT_MONTH, TIME_EDIT_YEAR: begin
          led_reg[7] <= year_bcd_edit[15:12];
          led_reg[6] <= year_bcd_edit[11:8];
          led_reg[5] <= year_bcd_edit[7:4];
          led_reg[4] <= year_bcd_edit[3:0];
          led_reg[3] <= month_bcd_edit[7:4];
          led_reg[2] <= month_bcd_edit[3:0];
          led_reg[1] <= day_bcd_edit[7:4];
          led_reg[0] <= day_bcd_edit[3:0];
        end
        ALARM_EDIT_SECOND, ALARM_EDIT_MINUTE, ALARM_EDIT_HOUR: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= hour_bcd_edit[7:4];
          led_reg[4] <= hour_bcd_edit[3:0];
          led_reg[3] <= minute_bcd_edit[7:4];
          led_reg[2] <= minute_bcd_edit[3:0];
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
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
    end else if (up_btn_negedge) begin
      cancel_alarm <= 1'b1;
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
              stop_timer  <= 1'b0;
              play_timer  <= 1'b0;
              reset_timer <= 1'b1;
            end
            1'b1: begin
              stop_timer  <= 1'b1;
              play_timer  <= 1'b0;
              reset_timer <= 1'b0;
            end
            default: begin
              stop_timer  <= stop_timer;
              play_timer  <= play_timer;
              reset_timer <= reset_timer;
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
      reset_timer  <= 1'b0;
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
        end
        TIME_EDIT_SECOND: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIME_EDIT_MINUTE: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIME_EDIT_HOUR: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIME_EDIT_DAY: begin
          led_reg[7] <= year_bcd_edit[15:12];
          led_reg[6] <= year_bcd_edit[11:8];
          led_reg[5] <= year_bcd_edit[7:4];
          led_reg[4] <= year_bcd_edit[3:0];
          led_reg[3] <= month_bcd_edit[7:4];
          led_reg[2] <= month_bcd_edit[3:0];
          led_reg[1] <= day_bcd_edit[7:4];
          led_reg[0] <= day_bcd_edit[3:0];
        end
        TIME_EDIT_MONTH: begin
          led_reg[7] <= year_bcd_edit[15:12];
          led_reg[6] <= year_bcd_edit[11:8];
          led_reg[5] <= year_bcd_edit[7:4];
          led_reg[4] <= year_bcd_edit[3:0];
          led_reg[3] <= month_bcd_edit[7:4];
          led_reg[2] <= month_bcd_edit[3:0];
          led_reg[1] <= day_bcd_edit[7:4];
          led_reg[0] <= day_bcd_edit[3:0];
        end
        TIME_EDIT_YEAR: begin
          led_reg[7] <= year_bcd_edit[15:12];
          led_reg[6] <= year_bcd_edit[11:8];
          led_reg[5] <= year_bcd_edit[7:4];
          led_reg[4] <= year_bcd_edit[3:0];
          led_reg[3] <= month_bcd_edit[7:4];
          led_reg[2] <= month_bcd_edit[3:0];
          led_reg[1] <= day_bcd_edit[7:4];
          led_reg[0] <= day_bcd_edit[3:0];
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
        end
        ALARM_EDIT_SECOND: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= hour_bcd_edit[7:4];
          led_reg[4] <= hour_bcd_edit[3:0];
          led_reg[3] <= minute_bcd_edit[7:4];
          led_reg[2] <= minute_bcd_edit[3:0];
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        ALARM_EDIT_MINUTE: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= hour_bcd_edit[7:4];
          led_reg[4] <= hour_bcd_edit[3:0];
          led_reg[3] <= minute_bcd_edit[7:4];
          led_reg[2] <= minute_bcd_edit[3:0];
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        ALARM_EDIT_HOUR: begin
          led_reg[7] <= {2'b0, selected_alarm};
          led_reg[6] <= 4'd11;  //turn off led6
          led_reg[5] <= hour_bcd_edit[7:4];
          led_reg[4] <= hour_bcd_edit[3:0];
          led_reg[3] <= minute_bcd_edit[7:4];
          led_reg[2] <= minute_bcd_edit[3:0];
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIMER_DISP: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIMER_EDIT_SECOND: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIMER_EDIT_MINUTE: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
        end
        TIMER_EDIT_HOUR: begin
          led_reg[7] <= hour_bcd_edit[7:4];
          led_reg[6] <= hour_bcd_edit[3:0];
          led_reg[5] <= 4'd10;  // separator
          led_reg[4] <= minute_bcd_edit[7:4];
          led_reg[3] <= minute_bcd_edit[3:0];
          led_reg[2] <= 4'd10;  // separator
          led_reg[1] <= second_bcd_edit[7:4];
          led_reg[0] <= second_bcd_edit[3:0];
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
      set_alarm   <= 1'b0;
      set_timer   <= 1'b0;
      set_counter <= 1'b0;
    end else begin
      if((previous_state == TIME_EDIT_SECOND||previous_state == TIME_EDIT_MINUTE||previous_state == TIME_EDIT_HOUR||previous_state == TIME_EDIT_DAY||previous_state == TIME_EDIT_MONTH||previous_state == TIME_EDIT_YEAR)&&(current_state == TIME_DISP)) begin
        set_alarm   <= 1'b0;
        set_timer   <= 1'b0;
        set_counter <= 1'b1;
      end
      else if((previous_state == ALARM_EDIT_SECOND||previous_state == ALARM_EDIT_MINUTE||previous_state == ALARM_EDIT_HOUR)&&(current_state == ALARM_DISP)) begin
        set_alarm   <= 1'b1;
        set_timer   <= 1'b0;
        set_counter <= 1'b0;
      end
      else if((previous_state == TIMER_EDIT_SECOND||previous_state == TIMER_EDIT_MINUTE||previous_state == TIMER_EDIT_HOUR)&&(current_state == TIMER_DISP)) begin
        set_alarm   <= 1'b0;
        set_timer   <= 1'b1;
        set_counter <= 1'b0;
      end else begin
        set_alarm   <= 1'b0;
        set_timer   <= 1'b0;
        set_counter <= 1'b0;
      end
    end
  end

  // 实例化 time2stamp 模块

  time2stamp time2stamp_inst (
      .year_bcd(year_bcd_edit_buf[79:64]),
      .month_bcd(month_bcd_edit_buf[39:32]),
      .day_bcd(day_bcd_edit_buf[39:32]),
      .hour_bcd(hour_bcd_edit_buf[39:32]),
      .minute_bcd(minute_bcd_edit_buf[39:32]),
      .second_bcd(second_bcd_edit_buf[39:32]),
      .time_stamp(counter_out)
  );


  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      dot_reg   <= 8'b11111111;
      blink_reg <= 8'b00000000;
    end else begin
      case (state)
        TIME_DISP: begin
          dot_reg   <= 8'b11111111;
          blink_reg <= ring ? 8'b11111111 : 8'b00000000;
        end
        DATE_DISP: begin
          dot_reg   <= 8'b11101010;
          blink_reg <= ring ? 8'b11111111 : 8'b00000000;
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
          blink_reg <= ring ? 8'b11111111 : 8'b00000000;
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
          blink_reg <= ring ? 8'b11111111 : 8'b00000000;
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
      led0 <= 4'b0;
      led1 <= 4'b0;
      led2 <= 4'b0;
      led3 <= 4'b0;
      led4 <= 4'b0;
      led5 <= 4'b0;
      led6 <= 4'b0;
      led7 <= 4'b0;
    end else begin
      led0 <= led_reg[0];
      led1 <= led_reg[1];
      led2 <= led_reg[2];
      led3 <= led_reg[3];
      led4 <= led_reg[4];
      led5 <= led_reg[5];
      led6 <= led_reg[6];
      led7 <= led_reg[7];
    end
  end


  assign ring = alarm_ring || timer_ring;

endmodule
