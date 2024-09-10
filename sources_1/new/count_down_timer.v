// This module has been tested in sim_1/new/tb_count_down_timer.v and it works well.
module count_down_timer (
    input wire clk,
    input wire rst_n,
    input wire set,
    input wire play,
    input wire stop,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,
    output wire [7:0] hour_out_bcd,
    output wire [7:0] minute_out_bcd,
    output wire [7:0] second_out_bcd,
    output reg ring = 1'b0,
    output reg counting = 1'b0
);

  wire [63:0] total_seconds_in;
  assign total_seconds_in = ((hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]))*50000000;

  wire clk_50M;
  assign clk_50M = clk;
  wire clk_1k;

  clk_divider_50M_to_10k clk_divider_inst (
      .clk_in_50M(clk_50M),
      .rst_n(rst_n),
      .clk_out_10k(),
      .clk_out_1k(clk_1k)
  );

  wire threshold;
  reg  enable = 1'b0;
  always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
      enable <= 1'b0;
    end else if (play) begin
      enable <= 1'b1;
    end else if (stop) begin
      enable <= 1'b0;
    end else if (threshold) begin
      enable <= 1'b0;
    end else if (set) begin
      enable <= 1'b0;
    end else begin
      enable <= enable;
    end
  end

  wire [63:0] total_seconds;
  c_counter_binary_0 uut (
      .CLK(clk_50M),
      .CE(enable || set),
      .LOAD(set),
      .L(total_seconds_in),
      .THRESH0(threshold),
      .Q(total_seconds)
  );

  always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
      ring <= 1'b0;
    end else if (threshold) begin
      ring <= 1'b1;
    end else if (set) begin
      ring <= 1'b0;
    end else begin
      ring <= ring;
    end
  end

  reg [7:0] hour_out = 8'b00000000;
  reg [7:0] minute_out = 8'b00000000;
  reg [7:0] second_out = 8'b00000000;
  always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
      hour_out   <= 8'b00000000;
      minute_out <= 8'b00000000;
      second_out <= 8'b00000000;
    end else begin
      hour_out   <= (total_seconds / 50000000) / 3600;
      minute_out <= ((total_seconds / 50000000) % 3600) / 60;
      second_out <= (total_seconds / 50000000) % 60;
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

  always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
      counting <= 1'b0;
    end else if (set) begin
      counting <= 1'b0;
    end else if (play) begin
      counting <= 1'b1;
    end else if (stop) begin
      counting <= 1'b0;
    end else if (threshold) begin
      counting <= 1'b0;
    end else begin
      counting <= counting;
    end
  end
endmodule
