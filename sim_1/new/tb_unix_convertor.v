`timescale 1ns / 1ps

module tb_unix64_to_UTC;

  // �������������ź�
  reg clk;
  reg rst_n;
  reg [63:0] unix_time;
  wire [13:0] year;
  wire [3:0] month;
  wire [4:0] day;
  wire [2:0] weekday;
  wire [4:0] hour;
  wire [5:0] minute;
  wire [5:0] second;

  // ʵ����������ģ��
  unix64_to_UTC uut (
      .clk(clk),
      .rst_n(rst_n),
      .unix_time(unix_time),
      .year(year),
      .month(month),
      .day(day),
      .weekday(weekday),
      .hour(hour),
      .minute(minute),
      .second(second)
  );

  // ʱ������
  always #1 clk = ~clk;

  // ���Թ���
  initial begin
    // ��ʼ���ź�
    clk = 0;
    rst_n = 0;
    unix_time = 0;

    // ��λ
    #10 rst_n = 1;

    // ��������1: 2023��5��1�� 12:34:56 (UTC)
    #10 unix_time = 64'd1682944496;
    #5000;
    display_result();

    // ��������2: 2000��1��1�� 00:00:00 (UTC)
    #10 unix_time = 64'd946684800;
    #5000;
    display_result();

    // ��������3: 2038��1��19�� 03:14:07 (UTC) - 32λunixʱ��������ֵ
    #10 unix_time = 64'd2147483647;
    #5000;
    display_result();

    // ��������4: 1970��1��1�� 00:00:00 (UTC) - unixʱ��������
    #10 unix_time = 64'd0;
    #5000;
    display_result();

    // ��������5: 2100��12��31�� 23:59:59 (UTC)
    #10 unix_time = 64'd4133980799;
    #5000;
    display_result();

    // �����Ĳ�������
    // ��������6: 2050��6��15�� 08:30:00 (UTC)
    #10 unix_time = 64'd2540803800;
    #5000;
    display_result();

    // ��������7: 1999��12��31�� 23:59:59 (UTC) - ǧ�������ǰϦ
    #10 unix_time = 64'd946684799;
    #5000;
    display_result();

    // ��������8: 2023��10��31�� 12:00:00 (UTC) - ��ʥ��
    #10 unix_time = 64'd1698753600;
    #5000;
    display_result();

    // ��������9: 2024��2��29�� 15:45:30 (UTC) - ����
    #10 unix_time = 64'd1709220330;
    #5000;
    display_result();

    // ��������10: 2077��7��7�� 07:07:07 (UTC) - �������� cyberpunk2077 :)
    #10 unix_time = 64'd3392631227;
    #5000;
    display_result();

    $finish;
  end

  // ��ʾ���������
  task display_result;
    begin
      $display("Unix Time Stamp: %d", unix_time);
      $display("UTC Time: %d%d%d %d:%02d:%02d (%d)", year, month, day, hour, minute, second,
               weekday);
      $display("------------------------");
    end
  endtask

endmodule
