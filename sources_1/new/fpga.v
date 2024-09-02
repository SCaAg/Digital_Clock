`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 09:53:19
// Design Name: 
// Module Name: fpga
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


module fpga (
    input wire clk,
    input wire rst_n,
    input wire adjust_btn,
    input wire mode_btn,
    input wire up_btn,
    input wire down_btn,
    output [7:0] seg,
    output [7:0] an
);
  localparam TIME_DISPLAY = 'd0;
  localparam TIME_EDIT = 'd1;
  localparam DATE_DISPLAY = 'd2;
  localparam WEEKDAY_DISPLAY = 'd3;
  localparam ALARM_DISPLAY = 2'b1;
  localparam ALARM_EDIT = 2'b0;
  localparam COUNT_DOWN_TIMER_DISPLAY = 3'd4;
  localparam COUNT_DOWN_TIMER_EDIT = 1'b1;
  localparam STOPWATCH_DISPLAY = 3'd5;



  localparam SECOND_EDIT = 1'b1;
  localparam MINUTE_EDIT = 1'b1;
  localparam HOUR_EDIT = 1'b1;
  localparam DAY_EDIT = 1'b1;
  localparam MONTH_EDIT = 1'b1;
  localparam YEAR_EDIT = 1'b1;

  reg global_state = TIME_DISPLAY;
  reg edit_state = SECOND_EDIT;
  wire [63:0] counter;
  reg [63:0] counter_tmp;

  wire [5:0] second;
  reg load_n = 1'b1;
  reg change_time = 1'b0;

  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      global_state <= TIME_DISPLAY;
      edit_state <= YEAR_EDIT;
      load_n <= 1'b1;
    end else begin
      case (global_state)
        TIME_DISPLAY: begin
          if (~mode_btn) begin
            global_state <= DATE_DISPLAY;
          end else if (~adjust_btn) begin
            global_state <= TIME_EDIT;
          end
        end
        TIME_EDIT: begin

        end
        default: global_state <= 0;
      endcase
    end


  wire [3:0] led1Number;
  wire [3:0] led2Number;
  wire [3:0] led3Number;
  wire [3:0] led4Number;
  wire [3:0] led5Number;
  wire [3:0] led6Number;
  wire [3:0] led7Number;
  wire [3:0] led8Number;
  wire [7:0] point;


  reg display_year = 1'b0;



  reg go = 1'b1;


  unixCounter unixCounter1 (
      .clk(clk),
      .rst_n(rst_n),
      .go(go),
      .load_n(load_n),
      .set_counter(counter_tmp),
      .counter(counter)
  );

  wire [39:0] display_bcd;

  counter2bcd counter2bcd1 (
      .clk(clk),
      .rst_n(rst_n),
      .counter(counter),
      .display_year(display_year),
      .eight_segment(display_bcd),
      .second_out(second)
  );
  assign {led8Number,led7Number,led6Number,led5Number,led4Number,led3Number,led2Number,led1Number,point} = display_bcd;

  ledScan ledScan1 (
      .clk(clk),
      .rst_n(rst_n),
      .led1Number(led1Number),
      .led2Number(led2Number),
      .led3Number(led3Number),
      .led4Number(led4Number),
      .led5Number(led5Number),
      .led6Number(led6Number),
      .led7Number(led7Number),
      .led8Number(led8Number),
      .point(point),
      .ledCode(seg),
      .an(an)
  );
endmodule
