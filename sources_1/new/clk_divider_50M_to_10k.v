
// 此模块已在 sim_1/new/tb_clk_divider_50M_to_10k.v 中测试，运行良好。
module clk_divider_50M_to_10k (
    input  wire clk_in_50M,   // 50 MHz 输入时钟
    input  wire rst_n,        // 低电平有效复位
    output reg  clk_out_10k,  // 10 kHz 输出时钟
    output reg  clk_out_1k    // 1 kHz 输出时钟
);
  reg [15:0] counter_1k;  // 16位计数器，可计数到50000

  always @(posedge clk_in_50M or negedge rst_n) begin
    if (!rst_n) begin
      counter_1k <= 16'd0;
      clk_out_1k <= 1'b0;
    end else begin
      if (counter_1k == 16'd24999) begin
        counter_1k <= 16'd0;
        clk_out_1k <= ~clk_out_1k;  // 切换输出时钟
      end else begin
        counter_1k <= counter_1k + 1;
      end
    end
  end

  reg [12:0] counter;  // 13-bit counter (can count up to 8191, sufficient for 5000)

  always @(posedge clk_in_50M or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 13'd0;
      clk_out_10k <= 1'b0;
    end else begin
      if (counter == 13'd2499) begin
        counter <= 13'd0;
        clk_out_10k <= ~clk_out_10k;  // Toggle output clock
      end else begin
        counter <= counter + 1;
      end
    end
  end

endmodule
