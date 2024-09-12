`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 21:29:05
// Design Name: 
// Module Name: clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/30 15:07:53
// Design Name: 
// Module Name: fpga_matrixKeyboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//锟斤拷锟斤拷fpga锟斤拷锟斤拷
module clock (
    input clk,
    input reset_n,
    input key1,
    input key2,
    input key3,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg,
    output [7:0] an,
    output led,
    output beep,
    input rx_pin,
    output tx_pin,
    output sck,
    output mosi,
    output dc_out,
    output cs,
    output reset_oled

);
  wire [ 4:0] hour;
  wire [ 5:0] minute;
  wire [ 5:0] second;
  wire [13:0] year;
  wire [ 3:0] month;
  wire [ 4:0] day;
  wire [15:0] year_bcd;
  wire [ 7:0] month_bcd;
  wire [ 7:0] day_bcd;
  wire [ 7:0] hour_bcd;
  wire [ 7:0] minute_bcd;
  wire [ 7:0] second_bcd;
  assign year = year_bcd[15:12] * 1000 + year_bcd[11:8] * 100 + year_bcd[7:4] * 10 + year_bcd[3:0];
  assign month = month_bcd[7:4] * 10 + month_bcd[3:0];
  assign day = day_bcd[7:4] * 10 + day_bcd[3:0];
  assign hour = hour_bcd[7:4] * 10 + hour_bcd[3:0];
  assign minute = minute_bcd[7:4] * 10 + minute_bcd[3:0];
  assign second = second_bcd[7:4] * 10 + second_bcd[3:0];
  /*
  oledInterface oledInterface1 (
      .clk(clk),
      .reset_n(reset_n),
      .hour(hour),
      .minute(minute),
      .second(second),
      .sck(sck),
      .mosi(mosi),
      .dc_out(dc_out),
      .cs(cs),
      .reset_oled(reset_oled),
      .year(year),
      .month(month),
      .day(day)
  );*/

  wire [3:0] key_code;
  wire key_vaild;
  matrixKeyboard matrixKeyboard1 (
      .clk(clk),
      .reset_n(reset_n),
      .row(row),
      .col(col),
      .key_code(key_code),
      .key_vaild(key_vaild)
  );

  wire [3:0] key0_state;
  wire [3:0] key1_state;
  wire [3:0] key2_state;
  wire [3:0] key3_state;
  wire [3:0] key4_state;
  wire [3:0] key5_state;

  keyState keyState1 (
      .clk(clk),
      .reset_n(reset_n),
      .key_code(key_code),
      .key_vaild(key_vaild),
      .key0_state(key0_state),
      .key1_state(key1_state),
      .key2_state(key2_state),
      .key3_state(key3_state),
      .key4_state(key4_state),
      .key5_state(key5_state)
  );

  reg en;
  wire finished;
  wire [31:0] timeout;
  internetTimeSet uut (
      .clk(clk),
      .reset_n(reset_n),
      .en(en),
      .finished(finished),
      .tx_pin(tx_pin),
      .rx_pin(rx_pin),
      .timeout(timeout)
  );

  wire mode_btn;
  assign mode_btn = key5_state[0];
  wire adjust_btn;
  assign adjust_btn = key4_state[0];
  wire left_button;
  assign left_button = key0_state[0];
  wire right_button;
  assign right_button = key1_state[0];
  wire up_btn;
  assign up_btn = key2_state[0];
  wire down_btn;
  assign down_btn = key3_state[0];

  reg issetintertime;
  reg [63:0] intertime;
  wire ring;
  clock_interface clock_interface_inst (
      .clk(clk),
      .up_btn(down_btn),
      .down_btn(up_btn),
      .mode_btn(mode_btn),
      .adjust_btn(adjust_btn),
      .seg(seg),
      .an(an),
      .year_bcd(year_bcd),
      .month_bcd(month_bcd),
      .day_bcd(day_bcd),
      .hour_bcd(hour_bcd),
      .minute_bcd(minute_bcd),
      .second_bcd(second_bcd),
      .issetintertime(issetintertime),
      .intertime(intertime),
      .ring(ring),
      .rst_n(reset_n)
  );

  assign beep = ring ? (clk_out_4Hz ? clk_out_500Hz : 1'b0) : 1'b0;
  assign led  = ring ? clk_out_4Hz : 1'b0;
  wire clk_out_500Hz;
  wire clk_out_4Hz;
  wire clk_out_1Hz;
  ring_divider ring_divider_inst (
      .clk_in_50M(clk),
      .rst_n(reset_n),
      .clk_out_500Hz(clk_out_500Hz),
      .clk_out_4Hz(clk_out_4Hz),
      .clk_out_1Hz(clk_out_1Hz)
  );
  reg [1:0] gettime_st;
  localparam START = 2'd0;
  localparam WAITTIME = 2'd1;
  localparam SETTIME = 2'd2;
  localparam FINISHED = 2'd3;

  reg button_state;
  localparam BUTTON_PRESS = 0, BUTTON_RELEASE = 1;
  always @(posedge clk) begin
    if (!reset_n) begin
      gettime_st <= START;
      en <= 0;
      issetintertime <= 0;
      intertime <= 0;
      button_state <= BUTTON_RELEASE;
    end else begin
      if (right_button == 0) button_state <= BUTTON_RELEASE;
      case (gettime_st)
        START: begin
          if (button_state == BUTTON_RELEASE) begin
            if (right_button == 1) begin
              gettime_st <= WAITTIME;
              en <= 1;
              button_state <= BUTTON_PRESS;
            end
          end
        end
        WAITTIME: begin
          en <= 0;
          if (finished) begin
            gettime_st <= SETTIME;
            intertime <= {32'b0, timeout};
            issetintertime <= 1;
          end else if (button_state == BUTTON_RELEASE) begin
            if (right_button == 1) begin
              gettime_st   <= SETTIME;
              button_state <= BUTTON_PRESS;
            end
          end
        end
        SETTIME: begin
          issetintertime <= 0;
          gettime_st <= FINISHED;
        end
        FINISHED: begin
          gettime_st <= START;
        end
      endcase
    end
  end
endmodule

