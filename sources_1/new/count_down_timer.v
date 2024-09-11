// This module has been tested in sim_1/new/tb_count_down_timer.v and it works well.
module count_down_timer (
    input wire clk,
    input wire rst_n,
    input wire set,
    input wire reset,
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
  wire clk_5M;
  assign clk_5M = clk;

  reg [1:0] set_buf = 2'b00;
  reg [1:0] reset_buf = 2'b00;
  reg [1:0] play_buf = 2'b00;
  reg [1:0] stop_buf = 2'b00;
  wire set_pulse;
  wire reset_pulse;
  wire play_pulse;
  wire stop_pulse;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      set_buf   <= 2'b00;
      reset_buf <= 2'b00;
      play_buf  <= 2'b00;
      stop_buf  <= 2'b00;
    end else begin
      set_buf   <= {set_buf[0], set};
      reset_buf <= {reset_buf[0], reset};
      play_buf  <= {play_buf[0], play};
      stop_buf  <= {stop_buf[0], stop};
    end
  end
  assign set_pulse   = (set_buf == 2'b01);
  assign reset_pulse = (reset_buf == 2'b01);
  assign play_pulse  = (play_buf == 2'b01);
  assign stop_pulse  = (stop_buf == 2'b01);
  wire [63:0] total_seconds_in;
  assign total_seconds_in = ((hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]))*5000000;



  reg [63:0] total_seconds_mem = 64'd10000000;
  reg [63:0] total_seconds_load = 64'd10000000;
  reg load = 1'b0;
  always @(posedge clk_5M or negedge rst_n) begin
    if (!rst_n) begin
      total_seconds_mem <= 64'd10000000;
      total_seconds_load <= 64'd10000000;
      load <= 1'b1;
    end else if (set_pulse) begin
      total_seconds_mem <= total_seconds_in;
      total_seconds_load <= total_seconds_in;
      load <= 1'b1;
    end else if (reset_pulse) begin
      total_seconds_mem <= total_seconds_mem;
      total_seconds_load <= total_seconds_mem;
      load <= 1'b1;
    end else begin
      total_seconds_mem <= total_seconds_mem;
      total_seconds_load <= total_seconds_load;
      load <= 1'b0;
    end
  end


  always @(posedge clk_5M or negedge rst_n) begin
    if (!rst_n) begin
      counting <= 1'b0;
    end else if (play_pulse) begin
      counting <= 1'b1;
    end else if (stop_pulse || threshold || set_pulse || reset_pulse) begin
      counting <= 1'b0;
    end else begin
      counting <= counting;
    end
  end

  wire threshold;
  wire [63:0] total_seconds_out;
  c_counter_binary_0 uut (
      .CLK(clk_5M),
      .CE(counting || load),
      .LOAD(load),
      .L(total_seconds_load),
      .THRESH0(threshold),
      .Q(total_seconds_out)
  );

  always @(posedge clk_5M or negedge rst_n) begin
    if (!rst_n) begin
      ring <= 1'b0;
    end else if (threshold) begin
      ring <= 1'b1;
    end else if (reset_pulse) begin
      ring <= 1'b0;
    end else begin
      ring <= ring;
    end
  end

  reg [7:0] hour_out = 8'b00000000;
  reg [7:0] minute_out = 8'b00000000;
  reg [7:0] second_out = 8'b00000000;
  always @(posedge clk_5M or negedge rst_n) begin
    if (!rst_n) begin
      hour_out   <= 8'b00000000;
      minute_out <= 8'b00000000;
      second_out <= 8'b00000000;
    end else begin
      hour_out   <= (total_seconds_out / 5000000) / 3600;
      minute_out <= ((total_seconds_out / 5000000) % 3600) / 60;
      second_out <= (total_seconds_out / 5000000) % 60;
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
