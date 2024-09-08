// This module has been tested in sim_1/new/tb_count_down_timer.v and it works well.
module count_down_timer (
    input wire clk,  //in 1kHz
    input wire rst_n,
    input wire load,
    input wire clock_en,
    input wire [7:0] hour_bcd_in,
    input wire [7:0] minute_bcd_in,
    input wire [7:0] second_bcd_in,
    output wire [7:0] hour_out_bcd,
    output wire [7:0] minute_out_bcd,
    output wire [7:0] second_out_bcd,
    output reg ring = 1'b0
);

  wire [31:0] total_seconds_in;
  assign total_seconds_in = ((hour_bcd_in[7:4] * 10 + hour_bcd_in[3:0]) * 3600 + (minute_bcd_in[7:4] * 10 + minute_bcd_in[3:0]) * 60 + (second_bcd_in[7:4] * 10 + second_bcd_in[3:0]))*1000;

  wire time_up;
  wire [31:0] total_seconds;
  wire enable;
  assign enable = clock_en| load;

  reg [3:0] st;
  localparam WAIT=0,COUNT=1,FINISH=2;

  c_counter_binary_0 uut (
      .CLK(clk),
      .CE(enable),
      .LOAD(load),
      .L(total_seconds_in),
      .THRESH0(time_up),
      .Q(total_seconds)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ring <= 1'b0;
    end else if (time_up) begin
      ring <= 1'b1;
    end else if (load) begin
      ring <= 1'b0;
    end else begin
      ring <= ring;
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
      st<=WAIT;
    end 
    else if(total_seconds==32'h00000000) begin
      hour_out   <= 8'b00000000;
      minute_out <= 8'b00000000;
      second_out <= 8'b00000000;
    end
    else begin
      hour_out   <= (total_seconds / 1000) / 3600;
      minute_out <= ((total_seconds / 1000) % 3600) / 60;
      second_out <= (total_seconds / 1000) % 60;
    end
  end

  always@(posedge clk)begin
    case(st)
      WAIT:
        st<=clock_en?COUNT:WAIT;
      COUNT:
        if(total_seconds==32'h00000000)
          st<=FINISH;
    endcase
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
