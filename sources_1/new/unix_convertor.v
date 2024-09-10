
// This module has been tested in sim_1/new/tb_unix_convertor.v and it works well.

module unix64_to_UTC (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] unix_time,
    output reg  [13:0] year,       // 输出范围 0~16383
    output reg  [ 3:0] month,      // 输出范围 1~12
    output reg  [ 4:0] day,        // 输出范围 1~31
    output reg  [ 2:0] weekday,    // 输出范围 0~6 (代表星期天~星期六)
    output reg  [ 4:0] hour,       // 输出范围 0~23
    output reg  [ 5:0] minute,     // 输出范围 0~59
    output reg  [ 5:0] second      // 输出范围 0~59
);

  // 常量定义
  localparam DAY_SECONDS = 64'd86400;
  localparam NON_LEAP_YEAR_SECONDS = 64'd31536000;
  localparam FOUR_HUNDRED_YEARS_SECONDS = 64'd12622780800;
  localparam GENERAL_FOUR_YEARS_SECONDS = 64'd126230400;
  localparam GENERAL_HUNDRED_YEARS_SECONDS = 64'd3155673600;

  reg [4:0] days_in_month[0:11];
  // 初始化月天数
  initial begin
    days_in_month[0]  = 5'd31;
    days_in_month[1]  = 5'd28;
    days_in_month[2]  = 5'd31;
    days_in_month[3]  = 5'd30;
    days_in_month[4]  = 5'd31;
    days_in_month[5]  = 5'd30;
    days_in_month[6]  = 5'd31;
    days_in_month[7]  = 5'd31;
    days_in_month[8]  = 5'd30;
    days_in_month[9]  = 5'd31;
    days_in_month[10] = 5'd30;
    days_in_month[11] = 5'd31;
  end


  reg [13:0] temp_year = 14'd1;
  reg [ 3:0] temp_month = 4'd0;
  reg [ 4:0] temp_day = 5'd0;
  reg [ 2:0] temp_weekday = 3'd0;
  reg [ 4:0] temp_hour = 5'd0;
  reg [ 5:0] temp_minute = 6'd0;
  reg [ 5:0] temp_second = 6'd0;
  reg [63:0] adjusted_time = 64'd0;
  reg [ 5:0] term_400 = 6'd0;
  reg [ 1:0] term_100 = 2'd0;
  reg [ 4:0] term_4 = 5'd0;
  reg [ 1:0] term_1 = 2'd0;

  reg [ 3:0] convertor_state = 4'd0;


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // 转换unix时间戳为以公元1年开始的时刻的计时
      convertor_state <= 4'd0;
      temp_year <= 14'd1;
      temp_month <= 4'd0;
      temp_day <= 5'd0;
      temp_weekday <= 3'd0;
      temp_hour <= 5'd0;
      temp_minute <= 6'd0;
      temp_second <= 6'd0;
      adjusted_time <= unix_time + 64'd62135596800;
      term_400 <= 6'd0;
      term_100 <= 2'd0;
      term_4 <= 5'd0;
      term_1 <= 2'd0;
    end else begin
      case (convertor_state)
        4'd0: begin
          convertor_state <= 4'd1;
          temp_year <= 14'd1;
          temp_month <= 4'd0;
          temp_day <= 5'd0;
          temp_weekday <= 3'd0;
          temp_hour <= 5'd0;
          temp_minute <= 6'd0;
          temp_second <= 6'd0;
          adjusted_time <= unix_time + 64'd62135596800;
          term_400 <= 6'd0;
          term_100 <= 2'd0;
          term_4 <= 5'd0;
          term_1 <= 2'd0;
        end
        4'd1: begin
          if (adjusted_time >= FOUR_HUNDRED_YEARS_SECONDS) begin
            adjusted_time <= adjusted_time - FOUR_HUNDRED_YEARS_SECONDS;
            temp_year <= temp_year + 14'd400;
            term_400 <= term_400 + 6'd1;
          end else begin
            convertor_state <= 4'd2;
          end
        end
        4'd2: begin
          if (term_100 == 2'd3) begin
            convertor_state <= 4'd3;
          end else if (adjusted_time >= GENERAL_HUNDRED_YEARS_SECONDS) begin
            adjusted_time <= adjusted_time - GENERAL_HUNDRED_YEARS_SECONDS;
            term_100 <= term_100 + 2'd1;
            temp_year <= temp_year + 14'd100;
          end else begin
            convertor_state <= 4'd3;
          end
        end
        4'd3: begin
          if (adjusted_time >= GENERAL_FOUR_YEARS_SECONDS) begin
            adjusted_time <= adjusted_time - GENERAL_FOUR_YEARS_SECONDS;
            term_4 <= term_4 + 5'd1;
            temp_year <= temp_year + 14'd4;
          end else begin
            convertor_state <= 4'd4;
          end
        end
        4'd4: begin
          if (term_1 == 2'd3) begin
            convertor_state <= 4'd5;
          end else if (adjusted_time >= NON_LEAP_YEAR_SECONDS) begin
            adjusted_time <= adjusted_time - NON_LEAP_YEAR_SECONDS;
            temp_year <= temp_year + 14'd1;
            term_1 <= term_1 + 2'd1;
          end else begin
            convertor_state <= 4'd5;
          end
        end
        4'd5: begin
          if ((term_1 == 2'd3) && ((~(term_4 == 5'd24)) || ((term_100 == 2'd3) && (term_4 == 5'd24)))) begin
            days_in_month[1] <= 5'd29;
            convertor_state  <= 4'd6;
          end else begin
            days_in_month[1] <= 5'd28;
            convertor_state  <= 4'd6;
          end
        end
        4'd6: begin
          if (adjusted_time >= DAY_SECONDS) begin
            adjusted_time <= adjusted_time - DAY_SECONDS;
            if (temp_day + 5'd1 >= days_in_month[temp_month]) begin
              temp_day   <= 5'd0;
              temp_month <= temp_month + 4'd1;
            end else begin
              temp_day <= temp_day + 5'd1;
            end
          end else begin
            temp_day <= temp_day + 5'd1;
            temp_month <= temp_month + 5'd1;
            convertor_state <= 4'd7;
          end
        end
        4'd7: begin
          if (adjusted_time >= 64'd3600) begin
            adjusted_time <= adjusted_time - 64'd3600;
            temp_hour <= temp_hour + 5'd1;
          end else begin
            convertor_state <= 4'd8;
          end
        end
        4'd8: begin
          if (adjusted_time >= 64'd60) begin
            adjusted_time <= adjusted_time - 64'd60;
            temp_minute   <= temp_minute + 6'd1;
          end else begin
            convertor_state <= 4'd9;
          end
        end
        4'd9: begin
          year <= temp_year;
          month <= temp_month;
          day <= temp_day;
          weekday <= 'b0;  //TODO
          hour <= temp_hour;
          minute <= temp_minute;
          second <= adjusted_time;
          convertor_state <= 4'd0;
        end
        default: convertor_state <= 4'd0;
      endcase
    end
  end

endmodule
