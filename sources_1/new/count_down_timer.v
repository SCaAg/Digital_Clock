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
    output reg ring
);

  wire [15:0] total_seconds_in;
  assign total_seconds_in = (hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]);

  reg [15:0] total_seconds;
  reg [15:0] total_seconds_backup;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      total_seconds <= 0;
      ring <= 0;
    end else if (set_timer) begin
      total_seconds <= total_seconds_in;
      total_seconds_backup <= total_seconds_in;
      ring <= 0;
    end else if (reset_timer) begin
      total_seconds <= total_seconds_backup;
      ring <= 0;
    end else if (pause) begin
      // keep the current state and do nothing
    end else if (total_seconds > 0) begin
      total_seconds <= total_seconds - 1;
      ring <= 0;
    end else begin
      ring <= 1;
    end
  end

  reg [7:0] hour_out;
  reg [7:0] minute_out;
  reg [7:0] second_out;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hour_out   <= 0;
      minute_out <= 0;
      second_out <= 0;
    end else begin
      hour_out   <= total_seconds / 3600;
      minute_out <= (total_seconds % 3600) / 60;
      second_out <= total_seconds % 60;
    end
  end


  bin2bcd #(5) bin2bcd_hour (
      .bin(hour_out),
      .bcd(hour_out_bcd)
  );

  bin2bcd #(6) bin2bcd_minute (
      .bin(minute_out),
      .bcd(minute_out_bcd)
  );

  bin2bcd #(6) bin2bcd_second (
      .bin(second_out),
      .bcd(second_out_bcd)
  );

endmodule
