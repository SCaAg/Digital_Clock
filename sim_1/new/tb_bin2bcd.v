`timescale 1ns / 1ps

module tb_bin2bcd;

  // 参数
  parameter W = 18;

  // 信号声明
  reg [W-1:0] bin;
  wire [W+(W-4)/3:0] bcd;

  // 实例化被测模块
  bin2bcd #(W) uut (
      .bin(bin),
      .bcd(bcd)
  );

  // 初始化
  initial begin
    // 测试用例1：二进制数 0
    bin = 18'd0;
    #10;
    $display("Binary: %d -> BCD: %d%d%d%d%d", bin, bcd[19:16], bcd[15:12], bcd[11:8], bcd[7:4],
             bcd[3:0]);

    // 测试用例2：二进制数 5
    bin = 18'd5;
    #10;
    $display("Binary: %d -> BCD: %d%d%d%d%d", bin, bcd[19:16], bcd[15:12], bcd[11:8], bcd[7:4],
             bcd[3:0]);

    // 测试用例3：二进制数 1234
    bin = 18'd1234;
    #10;
    $display("Binary: %d -> BCD: %d%d%d%d%d", bin, bcd[19:16], bcd[15:12], bcd[11:8], bcd[7:4],
             bcd[3:0]);

    // 测试用例4：二进制数 99999
    bin = 18'd99999;
    #10;
    $display("Binary: %d -> BCD: %d%d%d%d%d", bin, bcd[19:16], bcd[15:12], bcd[11:8], bcd[7:4],
             bcd[3:0]);

    // 测试用例5：二进制数 262143 (最大18位数)
    bin = 18'd262143;
    #10;
    $display("Binary: %d -> BCD: %d%d%d%d%d", bin, bcd[19:16], bcd[15:12], bcd[11:8], bcd[7:4],
             bcd[3:0]);

    // 结束仿真
    $stop;
  end

endmodule
