module clk_divider (
    input  wire clk_in_50M,  // 输入时钟 50 MHz
    input  wire rst_n,       // 复位信号，低电平复位
    output reg  clk_out_5M   // 输出时钟 5 MHz
);
  reg [3:0] counter;  // 4位计数器

  always @(posedge clk_in_50M or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 4'd0;
      clk_out_5M <= 1'b0;
    end else begin
      if (counter == 4'd4) begin
        counter <= 4'd0;
        clk_out_5M <= ~clk_out_5M;  // 翻转输出时钟
      end else begin
        counter <= counter + 1;
      end
    end
  end
endmodule
