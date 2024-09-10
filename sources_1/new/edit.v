module edit (
    input wire clk,
    input wire rst_n,
    input wire [3:0] state,
    input wire down_btn,
    input wire [15:0] year_bcd_in,
    input wire [7:0] month_bcd_in,
    input wire [7:0] day_bcd_in,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,
    output reg [15:0] year_bcd_out,
    output reg [7:0] month_bcd_out,
    output reg [7:0] day_bcd_out,
    output reg [7:0] hour_bcd_out,
    output reg [7:0] minute_bcd_out,
    output reg [7:0] second_bcd_out
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


  wire [15:0] bcd_incremented;

  bcd_increment_16bit bcd_increment_inst (
      .bcd_in (year_bcd_in),
      .bcd_max(16'h9999),
      .bcd_out(bcd_incremented)
  );


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      year_bcd_out <= 16'd0;
      month_bcd_out <= 8'd0;
      day_bcd_out <= 8'd0;
      hour_bcd_out <= 8'd0;
      minute_bcd_out <= 8'd0;
      second_bcd_out <= 8'd0;
    end else begin
      if (~down_btn) begin
        case (state)
          TIME_EDIT_SECOND, ALARM_EDIT_SECOND, TIMER_EDIT_SECOND: begin
            if (second_bcd_in == 8'h59) begin
              second_bcd_out <= 8'h00;
            end else if (second_bcd_in[3:0] == 4'h9) begin
              second_bcd_out <= second_bcd_in + 4'h6 + 4'h1;
            end else begin
              second_bcd_out <= second_bcd_in + 4'h1;
            end
          end
          TIME_EDIT_MINUTE, ALARM_EDIT_MINUTE, TIMER_EDIT_MINUTE: begin
            if (minute_bcd_in == 8'h59) begin
              minute_bcd_out <= 8'h00;
            end else if (minute_bcd_in[3:0] == 4'h9) begin
              minute_bcd_out <= minute_bcd_in + 4'h6 + 4'h1;
            end else begin
              minute_bcd_out <= minute_bcd_in + 4'h1;
            end
          end
          TIME_EDIT_HOUR, ALARM_EDIT_HOUR, TIMER_EDIT_HOUR: begin
            if (hour_bcd_in == 8'h23) begin
              hour_bcd_out <= 8'h00;
            end else if (hour_bcd_in[3:0] == 4'h9) begin
              hour_bcd_out <= hour_bcd_in + 4'h6 + 4'h1;
            end else begin
              hour_bcd_out <= hour_bcd_in + 4'h1;
            end
          end
          TIME_EDIT_DAY: begin
            if (day_bcd_in == 8'h31) begin
              day_bcd_out <= 8'h01;
            end else if (day_bcd_in[3:0] == 4'h9) begin
              day_bcd_out <= day_bcd_in + 4'h6 + 4'h1;
            end else begin
              day_bcd_out <= day_bcd_in + 4'h1;
            end
          end
          TIME_EDIT_MONTH: begin
            if (month_bcd_in == 8'h12) begin
              month_bcd_out <= 8'h01;
            end else if (month_bcd_in[3:0] == 4'h9) begin
              month_bcd_out <= month_bcd_in + 4'h6 + 4'h1;
            end else begin
              month_bcd_out <= month_bcd_in + 4'h1;
            end
          end
          TIME_EDIT_YEAR begin
            if (year_bcd_in == 16'h9999) begin
              year_bcd_out <= 16'h0000;
            end else begin
              year_bcd_out <= bcd_incremented;
            end
          end
        endcase
      end
    end
  end
endmodule
