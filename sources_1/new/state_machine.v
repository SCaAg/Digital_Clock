module state_machine (
    input wire clk,
    input wire rst_n,
    input wire adjust_btn,
    input wire mode_btn,
    output reg [3:0] state = 4'd0
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

  reg [1:0] mode_btn_buf = 2'b0;
  reg [1:0] adjust_btn_buf = 2'b0;
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      mode_btn_buf   <= 2'b0;
      adjust_btn_buf <= 2'b0;
    end else begin
      mode_btn_buf   <= {mode_btn_buf[0], mode_btn};
      adjust_btn_buf <= {adjust_btn_buf[0], adjust_btn};
    end
  end

  wire mode_btn_negedge = mode_btn_buf == 2'b10;
  wire adjust_btn_negedge = adjust_btn_buf == 2'b10;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      state <= TIME_DISP;
    end else if (mode_btn_negedge) begin
      case (state)
        TIME_DISP: state <= DATE_DISP;
        DATE_DISP: state <= ALARM_DISP;
        TIME_EDIT_SECOND: state <= TIME_EDIT_YEAR;
        TIME_EDIT_MINUTE: state <= TIME_EDIT_SECOND;
        TIME_EDIT_HOUR: state <= TIME_EDIT_MINUTE;
        TIME_EDIT_DAY: state <= TIME_EDIT_HOUR;
        TIME_EDIT_MONTH: state <= TIME_EDIT_DAY;
        TIME_EDIT_YEAR: state <= TIME_EDIT_MONTH;
        ALARM_DISP: state <= TIMER_DISP;
        ALARM_EDIT_SECOND: state <= ALARM_EDIT_HOUR;
        ALARM_EDIT_MINUTE: state <= ALARM_EDIT_SECOND;
        ALARM_EDIT_HOUR: state <= ALARM_EDIT_MINUTE;
        TIMER_DISP: state <= TIME_DISP;
        TIMER_EDIT_SECOND: state <= TIMER_EDIT_HOUR;
        TIMER_EDIT_MINUTE: state <= TIMER_EDIT_SECOND;
        TIMER_EDIT_HOUR: state <= TIMER_EDIT_MINUTE;
        default: state <= state;
      endcase
    end else if (adjust_btn_negedge) begin
      case (state)
        TIME_DISP: state <= TIME_EDIT_HOUR;
        DATE_DISP: state <= TIME_EDIT_YEAR;
        TIME_EDIT_SECOND: state <= TIME_DISP;
        TIME_EDIT_MINUTE: state <= TIME_DISP;
        TIME_EDIT_HOUR: state <= TIME_DISP;
        TIME_EDIT_DAY: state <= TIME_DISP;
        TIME_EDIT_MONTH: state <= TIME_DISP;
        TIME_EDIT_YEAR: state <= TIME_DISP;
        ALARM_DISP: state <= ALARM_EDIT_HOUR;
        ALARM_EDIT_SECOND: state <= ALARM_DISP;
        ALARM_EDIT_MINUTE: state <= ALARM_DISP;
        ALARM_EDIT_HOUR: state <= ALARM_DISP;
        TIMER_DISP: state <= TIMER_EDIT_HOUR;
        TIMER_EDIT_SECOND: state <= TIMER_DISP;
        TIMER_EDIT_MINUTE: state <= TIMER_DISP;
        TIMER_EDIT_HOUR: state <= TIMER_DISP;
        default: state <= state;
      endcase
    end else begin
      state <= state;
    end
  end
endmodule
