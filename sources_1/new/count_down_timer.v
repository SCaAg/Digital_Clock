module count_down_timer (
    input wire clk,
    input wire rst_n,
    input wire set_timer,
    input wire reset_timer,
    input wire pause,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,
    output wire [7:0] hour_out_bcd,
    output wire [7:0] minute_out_bcd,
    output wire [7:0] second_out_bcd,
    output reg ring = 1'b0
);

  wire [15:0] total_seconds_in;
  assign total_seconds_in = (hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]);

  reg [15:0] total_seconds = 16'b0000000000000000;
  reg [15:0] total_seconds_backup = 16'b0000000000000000;

  reg count_down_timer_en = 1'b0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      total_seconds <= 16'b0000000000000000;
      total_seconds_backup <= 16'b0000000000000000;
      count_down_timer_en <= 1'b0;
      ring <= 1'b0;
    end else if (set_timer) begin
      total_seconds <= total_seconds_in;
      total_seconds_backup <= total_seconds_in;
      ring <= 1'b0;
      count_down_timer_en <= 1'b0;
    end else if (reset_timer) begin
      total_seconds <= total_seconds_backup;
      ring <= 1'b0;
      count_down_timer_en <= 1'b0;
    end else if (pause) begin
      total_seconds <= total_seconds;
      ring <= 1'b0;
      count_down_timer_en <= ~count_down_timer_en;
    end else if (total_seconds > 0 && count_down_timer_en) begin
      total_seconds <= total_seconds - 1;
      ring <= 1'b0;
      count_down_timer_en <= 1'b1;
    end else begin
      total_seconds <= total_seconds;
      ring <= 1'b1;
      count_down_timer_en <= 1'b0;
    end
  end

  reg [7:0] hour_out = 8'b00000000;
  reg [7:0] minute_out = 8'b00000000;
  reg [7:0] second_out = 8'b00000000;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hour_out   <= 8'b00000000;
      minute_out <= 8'b00000000;
      second_out <= 8'b00000000;
    end else begin
      hour_out   <= total_seconds / 3600;
      minute_out <= (total_seconds % 3600) / 60;
      second_out <= total_seconds % 60;
    end
  end

  assign hour_out_bcd[7:6] = 2'b00;
  bin2bcd #(5) bin2bcd_hour (
      .bin(hour_out),
      .bcd(hour_out_bcd[5:0])
  );
  assign minute_out_bcd[7] = 1'b0;
  bin2bcd #(6) bin2bcd_minute (
      .bin(minute_out),
      .bcd(minute_out_bcd[6:0])
  );
  assign second_out_bcd[7] = 1'b0;
  bin2bcd #(6) bin2bcd_second (
      .bin(second_out),
      .bcd(second_out_bcd[6:0])
  );

endmodule
