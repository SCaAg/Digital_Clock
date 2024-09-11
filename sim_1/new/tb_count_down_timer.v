`timescale 1ns / 1ps
//This is a testbench for count_down_timer
module count_down_timer_tb ();

  // �������������ź�
  reg clk_5M;
  reg rst_n;
  reg set;
  reg play;
  reg stop;
  reg reset;
  reg [7:0] hour_bcd_in;
  reg [7:0] minute_bcd_in;
  reg [7:0] second_bcd_in;
  wire [7:0] hour_out_bcd;
  wire [7:0] minute_out_bcd;
  wire [7:0] second_out_bcd;
  wire ring;
  wire counting;

  // ʵ����������ģ��
  count_down_timer uut (
      .clk(clk_5M),
      .rst_n(rst_n),
      .set(set),
      .reset(reset),
      .play(play),
      .stop(stop),
      .hour_bcd_in(hour_bcd_in),
      .minute_bcd_in(minute_bcd_in),
      .second_bcd_in(second_bcd_in),
      .hour_out_bcd(hour_out_bcd),
      .minute_out_bcd(minute_out_bcd),
      .second_out_bcd(second_out_bcd),
      .ring(ring),
      .counting(counting)
  );

  // ����ʱ���ź�
  always #100 clk_5M = ~clk_5M;  // 50MHzʱ��

  task press_set_btn;
    begin
      set = 1;
      #300;
      set = 0;
    end
  endtask

  task press_play_btn;
    begin
      play = 1;
      #300;
      play = 0;
    end
  endtask

  task press_stop_btn;
    begin
      stop = 1;
      #300;
      stop = 0;
    end
  endtask

  task press_reset_btn;
    begin
      reset = 1;
      #300;
      reset = 0;
    end
  endtask

  // ���Թ���
  initial begin
    // ��ʼ���ź�
    clk_5M = 0;
    rst_n = 0;
    reset = 0;
    set = 0;
    play = 0;
    stop = 0;
    hour_bcd_in = 0;
    minute_bcd_in = 0;
    second_bcd_in = 0;

    // ��λ
    #200 rst_n = 1;
    #2000

    //��ʾ��ʱ��ʱ��
    $display(
        "��ʱ��ʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd
    );
    press_play_btn();
    #2000000000;
    $display("��ʱ��ʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);


    // �������ü�ʱ��
    #1000000;
    hour_bcd_in = 8'h00;  // 0Сʱ
    minute_bcd_in = 8'h00;  // 0����
    second_bcd_in = 8'h3;  // 3��
    set = 1;
    // �ȴ�50ms
    #1000000 set = 0;


    $display("���õ���ʱʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);

    // ��ʼ��ʱ

    $display("��ʼ����ʱʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // �ȴ�1000ms
    #1000000000;
    stop = 1;
    //�ȴ�50ms
    #1000000 stop = 0;
    $display("��ͣ��ʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // �ȴ�1000ms
    #1000000000;
    play = 1;
    //�ȴ�50ms
    #1000000 play = 0;
    $display("��������ʱʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    // �ȴ�1000ms

    // �������ù���
    #1000000000;
    set = 1;
    #1000000 set = 0;
    $display("���ú�ʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);


    // �������ù���
    play = 1;
    #1000000;
    play = 0;

    $display("����ʱ����ʱ��: %h:%h:%h", hour_out_bcd, minute_out_bcd, second_out_bcd);
    $display("����״̬: %b", ring);
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    #1000000000;
    set = 1;
    #1000000 set = 0;
    // ��������
    $finish;
  end

endmodule
