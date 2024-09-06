`timescale 1ns / 1ps

module bcd_time2alarm_time_tb;

  // �����ź�
  reg [15:0] alarm_year_bcd;
  reg [7:0] alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd;
  reg  [63:0] counter;

  // ����ź�
  wire [63:0] alarm_stamp;

  // ʵ����������ģ��
  bcd_time2alarm_time uut (
      .alarm_year_bcd(alarm_year_bcd),
      .alarm_month_bcd(alarm_month_bcd),
      .alarm_day_bcd(alarm_day_bcd),
      .alarm_hour_bcd(alarm_hour_bcd),
      .alarm_minute_bcd(alarm_minute_bcd),
      .alarm_second_bcd(alarm_second_bcd),
      .counter(counter),
      .alarm_stamp(alarm_stamp)
  );

  // ���Թ���
  initial begin
    // ��������1
    alarm_year_bcd   = 16'h2023;  // 2023��
    alarm_month_bcd  = 8'h05;  // 5��
    alarm_day_bcd    = 8'h15;  // 15��
    alarm_hour_bcd   = 8'h10;  // 10ʱ
    alarm_minute_bcd = 8'h30;  // 30��
    alarm_second_bcd = 8'h00;  // 00��
    counter          = 64'd1684130400;  // 2023-05-15 09:00:00

    #10;  // �ȴ�10��ʱ�䵥λ
    $display("��������1:");
    $display("����: ��=%h, ��=%h, ��=%h, ʱ=%h, ��=%h, ��=%h", alarm_year_bcd,
             alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd);
    $display("��ǰʱ���: %d", counter);
    $display("�������ʱ���: %d", alarm_stamp);
    $display("");

    // ��������2
    alarm_year_bcd   = 16'h2023;  // 2023��
    alarm_month_bcd  = 8'h12;  // 12��
    alarm_day_bcd    = 8'h31;  // 31��
    alarm_hour_bcd   = 8'h0;  // 0ʱ
    alarm_minute_bcd = 8'h59;  // 59��
    alarm_second_bcd = 8'h59;  // 59��
    counter          = 64'd1704067199;  // 2023-12-31 23:59:59

    #10;  // �ȴ�10��ʱ�䵥λ
    $display("��������2:");
    $display("����ʱ��: ��=%h, ��=%h, ��=%h, ʱ=%h, ��=%h, ��=%h", alarm_year_bcd,
             alarm_month_bcd, alarm_day_bcd, alarm_hour_bcd, alarm_minute_bcd, alarm_second_bcd);
    $display("��ǰʱ���: %d", counter);
    $display("�������ʱ���: %d", alarm_stamp);

    $finish;
  end

endmodule
