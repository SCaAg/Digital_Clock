module test1 (
    input wire clk,
    input wire rst_n,
    input wire [15:0] year_bcd_in,
    input wire [7:0] month_bcd_in,
    input wire [7:0] day_bcd_in,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,
    output wire [15:0] year_bcd_out,
    output wire [7:0] month_bcd_out,
    output wire [7:0] day_bcd_out,
    output wire [7:0] hour_bcd_out,
    output wire [7:0] minute_bcd_out,
    output wire [7:0] second_bcd_out,
    input wire [3:0] up_btn,
    input wire [3:0] down_btn,
    input wire [3:0] left_btn,
    input wire [3:0] right_btn,
    input wire [3:0] enter_btn,
    input wire [3:0] return_btn,
    input wire [3:0] gobal_state,
    output reg [3:0] led0,
    output reg [3:0] led1,
    output reg [3:0] led2,
    output reg [3:0] led3,
    output reg [3:0] led4,
    output reg [3:0] led5,
    output reg [3:0] led6,
    output reg [3:0] led7,
    output reg [7:0] blink,
    output reg [7:0] dot,
    output wire is_blink
);
  assign is_blink = 1'b1;
  localparam DISP_MODE = 1'b0;
  localparam EDIT_MODE = 1'b1;
  reg local_mode;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      local_mode <= DISP_MODE;
    end else begin
      //长按进入编辑模式
      if (enter_btn == 4'd2) begin
        local_mode <= EDIT_MODE;
      end  //短按退出编辑模式
      else if (enter_btn == 4'd1) begin
        local_mode <= DISP_MODE;
      end else begin
        local_mode <= local_mode;
      end
    end
  end

  localparam EDIT_SECOND = 4'b0000;
  localparam EDIT_MINUTE = 4'b0001;
  localparam EDIT_HOUR = 4'b0010;
  localparam EDIT_DAY = 4'b0011;
  localparam EDIT_MONTH = 4'b0100;
  localparam EDIT_YEAR_0 = 4'b0101;
  localparam EDIT_YEAR_1 = 4'b0110;
  localparam EDIT_YEAR_2 = 4'b0111;
  localparam EDIT_YEAR_3 = 4'b1000;
  reg [3:0] edit_mode;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      edit_mode <= EDIT_SECOND;
    end else if (local_mode == EDIT_MODE) begin
      if (left_btn == 4'd1) begin
        edit_mode <= edit_mode == EDIT_YEAR_3 ? EDIT_SECOND : edit_mode + 1;
      end else if (right_btn == 4'd1) begin
        edit_mode <= edit_mode == EDIT_SECOND ? EDIT_YEAR_3 : edit_mode - 1;
      end
    end else begin
      edit_mode <= EDIT_SECOND;
    end
  end


  reg [15:0] year_bcd_tmp;
  reg [ 7:0] month_bcd_tmp;
  reg [ 7:0] day_bcd_tmp;
  reg [ 7:0] hour_bcd_tmp;
  reg [ 7:0] minute_bcd_tmp;
  reg [ 7:0] second_bcd_tmp;
  assign year_bcd_out = year_bcd_tmp;
  assign month_bcd_out = month_bcd_tmp;
  assign day_bcd_out = day_bcd_tmp;
  assign hour_bcd_out = hour_bcd_tmp;
  assign minute_bcd_out = minute_bcd_tmp;
  assign second_bcd_out = second_bcd_tmp;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      year_bcd_tmp <= year_bcd_in;
      month_bcd_tmp <= month_bcd_in;
      day_bcd_tmp <= day_bcd_in;
      hour_bcd_tmp <= hour_bcd_in;
      minute_bcd_tmp <= minute_bcd_in;
      second_bcd_tmp <= second_bcd_in;
    end else begin
      if (local_mode == DISP_MODE) begin
        year_bcd_tmp <= year_bcd_in;
        month_bcd_tmp <= month_bcd_in;
        day_bcd_tmp <= day_bcd_in;
        hour_bcd_tmp <= hour_bcd_in;
        minute_bcd_tmp <= minute_bcd_in;
        second_bcd_tmp <= second_bcd_in;
      end else if (up_btn == 4'd1) begin
        case (edit_mode)
          EDIT_SECOND: begin
            if (second_bcd_tmp == 8'h59) begin
              second_bcd_tmp <= 8'h00;
            end else if (second_bcd_tmp[3:0] == 4'h9) begin
              second_bcd_tmp <= second_bcd_tmp + 4'h6 + 4'h1;
            end else begin
              second_bcd_tmp <= second_bcd_tmp + 4'h1;
            end
          end
          EDIT_MINUTE: begin
            if (minute_bcd_tmp == 8'h59) begin
              minute_bcd_tmp <= 8'h00;
            end else if (minute_bcd_tmp[3:0] == 4'h9) begin
              minute_bcd_tmp <= minute_bcd_tmp + 4'h6 + 4'h1;
            end else begin
              minute_bcd_tmp <= minute_bcd_tmp + 4'h1;
            end
          end
          EDIT_HOUR: begin
            if (hour_bcd_tmp == 8'h23) begin
              hour_bcd_tmp <= 8'h00;
            end else if (hour_bcd_tmp[3:0] == 4'h9) begin
              hour_bcd_tmp <= hour_bcd_tmp + 4'h6 + 4'h1;
            end else begin
              hour_bcd_tmp <= hour_bcd_tmp + 4'h1;
            end
          end
          EDIT_DAY: begin
            if (day_bcd_tmp == 8'h31) begin
              day_bcd_tmp <= 8'h01;
            end else if (day_bcd_tmp[3:0] == 4'h9) begin
              day_bcd_tmp <= day_bcd_tmp + 4'h6 + 4'h1;
            end else begin
              day_bcd_tmp <= day_bcd_tmp + 4'h1;
            end
          end
          EDIT_MONTH: begin
            if (month_bcd_tmp == 8'h12) begin
              month_bcd_tmp <= 8'h01;
            end else if (month_bcd_tmp[3:0] == 4'h9) begin
              month_bcd_tmp <= month_bcd_tmp + 4'h6 + 4'h1;
            end else begin
              month_bcd_tmp <= month_bcd_tmp + 4'h1;
            end
          end
          EDIT_YEAR_0: begin
            if (year_bcd_tmp[15:12] == 4'h9) begin
              year_bcd_tmp[15:12] <= 4'h0;
            end else begin
              year_bcd_tmp[15:12] <= year_bcd_tmp[15:12] + 4'h1;
            end
          end
          EDIT_YEAR_1: begin
            if (year_bcd_tmp[11:8] == 4'h9) begin
              year_bcd_tmp[11:8] <= 4'h0;
            end else begin
              year_bcd_tmp[11:8] <= year_bcd_tmp[11:8] + 4'h1;
            end
          end
          EDIT_YEAR_2: begin
            if (year_bcd_tmp[7:4] == 4'h9) begin
              year_bcd_tmp[7:4] <= 4'h0;
            end else begin
              year_bcd_tmp[7:4] <= year_bcd_tmp[7:4] + 4'h1;
            end
          end
          EDIT_YEAR_3: begin
            if (year_bcd_tmp[3:0] == 4'h9) begin
              year_bcd_tmp[3:0] <= 4'h0;
            end else begin
              year_bcd_tmp[3:0] <= year_bcd_tmp[3:0] + 4'h1;
            end
          end
        endcase
      end else if (down_btn == 4'd1) begin
        case (edit_mode)
          EDIT_SECOND: begin
            if (second_bcd_tmp == 8'h00) begin
              second_bcd_tmp <= 8'h59;
            end else if (second_bcd_tmp[3:0] == 4'h0) begin
              second_bcd_tmp <= second_bcd_tmp - 4'h1 - 4'h6;
            end else begin
              second_bcd_tmp <= second_bcd_tmp - 4'h1;
            end
          end
          EDIT_MINUTE: begin
            if (minute_bcd_tmp == 8'h00) begin
              minute_bcd_tmp <= 8'h59;
            end else if (minute_bcd_tmp[3:0] == 4'h0) begin
              minute_bcd_tmp <= minute_bcd_tmp - 4'h1 - 4'h6;
            end else begin
              minute_bcd_tmp <= minute_bcd_tmp - 4'h1;
            end
          end
          EDIT_HOUR: begin
            if (hour_bcd_tmp == 8'h00) begin
              hour_bcd_tmp <= 8'h23;
            end else if (hour_bcd_tmp[3:0] == 4'h0) begin
              hour_bcd_tmp <= hour_bcd_tmp - 4'h1 - 4'h6;
            end else begin
              hour_bcd_tmp <= hour_bcd_tmp - 4'h1;
            end
          end
          EDIT_DAY: begin
            if (day_bcd_tmp == 8'h01) begin
              day_bcd_tmp <= 8'h31;
            end else if (day_bcd_tmp[3:0] == 4'h0) begin
              day_bcd_tmp <= day_bcd_tmp - 4'h1 - 4'h6;
            end else begin
              day_bcd_tmp <= day_bcd_tmp - 4'h1;
            end
          end
          EDIT_MONTH: begin
            if (month_bcd_tmp == 8'h01) begin
              month_bcd_tmp <= 8'h12;
            end else if (month_bcd_tmp[3:0] == 4'h0) begin
              month_bcd_tmp <= month_bcd_tmp - 4'h1 - 4'h6;
            end else begin
              month_bcd_tmp <= month_bcd_tmp - 4'h1;
            end
          end
          EDIT_YEAR_0: begin
            if (year_bcd_tmp[15:12] == 4'h0) begin
              year_bcd_tmp[15:12] <= 4'h9;
            end else begin
              year_bcd_tmp[15:12] <= year_bcd_tmp[15:12] - 4'h1;
            end
          end
          EDIT_YEAR_1: begin
            if (year_bcd_tmp[11:8] == 4'h0) begin
              year_bcd_tmp[11:8] <= 4'h9;
            end else begin
              year_bcd_tmp[11:8] <= year_bcd_tmp[11:8] - 4'h1;
            end
          end
          EDIT_YEAR_2: begin
            if (year_bcd_tmp[7:4] == 4'h0) begin
              year_bcd_tmp[7:4] <= 4'h9;
            end else begin
              year_bcd_tmp[7:4] <= year_bcd_tmp[7:4] - 4'h1;
            end
          end
          EDIT_YEAR_3: begin
            if (year_bcd_tmp[3:0] == 4'h0) begin
              year_bcd_tmp[3:0] <= 4'h9;
            end else begin
              year_bcd_tmp[3:0] <= year_bcd_tmp[3:0] - 4'h1;
            end
          end
        endcase
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      led0 <= 4'b0000;
      led1 <= 4'b0000;
      led2 <= 4'b0000;
      led3 <= 4'b0000;
      led4 <= 4'b0000;
      led5 <= 4'b0000;
      led6 <= 4'b0000;
      led7 <= 4'b0000;
    end else begin
      if (local_mode == DISP_MODE) begin
        led0 <= second_bcd_in[3:0];
        led1 <= second_bcd_in[7:4];
        led2 <= 4'd10;
        led3 <= minute_bcd_in[3:0];
        led4 <= minute_bcd_in[7:4];
        led5 <= 4'd10;
        led6 <= hour_bcd_in[3:0];
        led7 <= hour_bcd_in[7:4];
      end else begin
        case (edit_mode)
          EDIT_SECOND, EDIT_MINUTE, EDIT_HOUR: begin
            led0 <= second_bcd_tmp[3:0];
            led1 <= second_bcd_tmp[7:4];
            led2 <= 4'd10;
            led3 <= minute_bcd_tmp[3:0];
            led4 <= minute_bcd_tmp[7:4];
            led5 <= 4'd10;
            led6 <= hour_bcd_tmp[3:0];
            led7 <= hour_bcd_tmp[7:4];
          end
          EDIT_DAY, EDIT_MONTH, EDIT_YEAR_0, EDIT_YEAR_1, EDIT_YEAR_2, EDIT_YEAR_3: begin
            led0 <= day_bcd_tmp[3:0];
            led1 <= day_bcd_tmp[7:4];
            led2 <= month_bcd_tmp[3:0];
            led3 <= month_bcd_tmp[7:4];
            led4 <= year_bcd_tmp[3:0];
            led5 <= year_bcd_tmp[7:4];
            led6 <= year_bcd_tmp[11:8];
            led7 <= year_bcd_tmp[15:12];
          end
          default: begin
            led0 <= led0;
            led1 <= led1;
            led2 <= led2;
            led3 <= led3;
            led4 <= led4;
            led5 <= led5;
            led6 <= led6;
            led7 <= led7;
          end
        endcase
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      blink <= 8'b00000000;
    end else if (gobal_state == EDIT_MODE) begin
      case (edit_mode)
        EDIT_SECOND: blink <= 8'b00000011;
        EDIT_MINUTE: blink <= 8'b00011000;
        EDIT_HOUR:   blink <= 8'b11000000;
        EDIT_DAY:    blink <= 8'b00000011;
        EDIT_MONTH:  blink <= 8'b00001100;
        EDIT_YEAR_0: blink <= 8'b00010000;
        EDIT_YEAR_1: blink <= 8'b00100000;
        EDIT_YEAR_2: blink <= 8'b01000000;
        EDIT_YEAR_3: blink <= 8'b10000000;
        default: blink <= blink;
      endcase
    end else begin
      blink <= 8'b00000000;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dot <= 8'b11111111;
    end else begin
      if (local_mode == EDIT_MODE) begin
        case (edit_mode)
          EDIT_DAY, EDIT_MONTH, EDIT_YEAR_0, EDIT_YEAR_1, EDIT_YEAR_2, EDIT_YEAR_3:
          dot <= 8'b11101010;
          default: dot <= 8'b11111111;
        endcase
      end else begin
        dot <= 8'b11111111;
      end
    end
  end

endmodule
