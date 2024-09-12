module ring_divider (
    input  wire clk_in_50M,     // 输入时钟 50 MHz
    input  wire rst_n,          // 复位信号，低电平复位
    output reg  clk_out_500Hz,  // 输出时钟 500 Hz
    output reg  clk_out_4Hz,    // 输出时钟 4 Hz
    output reg  clk_out_1Hz     // 输出时钟 1 Hz
);
  reg [16:0] counter_500Hz;  // 17位计数器，用于500Hz
  reg [22:0] counter_4Hz;  // 23位计数器，用于4Hz
  reg [24:0] counter_1Hz;  // 25位计数器，用于1Hz

  always @(posedge clk_in_50M or negedge rst_n) begin
    if (!rst_n) begin
      counter_500Hz <= 17'd0;
      counter_4Hz   <= 23'd0;
      counter_1Hz   <= 25'd0;
      clk_out_500Hz <= 1'b0;
      clk_out_4Hz   <= 1'b0;
      clk_out_1Hz   <= 1'b0;
    end else begin
      // 500Hz时钟生成
      if (counter_500Hz == 17'd49999) begin
        counter_500Hz <= 17'd0;
        clk_out_500Hz <= ~clk_out_500Hz;
      end else begin
        counter_500Hz <= counter_500Hz + 1;
      end

      // 4Hz时钟生成
      if (counter_4Hz == 23'd6249999) begin
        counter_4Hz <= 23'd0;
        clk_out_4Hz <= ~clk_out_4Hz;
      end else begin
        counter_4Hz <= counter_4Hz + 1;
      end

      // 1Hz时钟生成
      if (counter_1Hz == 25'd24999999) begin
        counter_1Hz <= 25'd0;
        clk_out_1Hz <= ~clk_out_1Hz;
      end else begin
        counter_1Hz <= counter_1Hz + 1;
      end
    end
  end
endmodule
