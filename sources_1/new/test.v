module test (
    ports
);
  // 实例化 alarm 模块
  alarm alarm_inst (
      .clk(clk),
      .rst_n(rst_n),
      .set(set_alarm),
      .alarm_year_bcd_in(alarm_year_bcd),
      .alarm_month_bcd_in(alarm_month_bcd),
      .alarm_day_bcd_in(alarm_day_bcd),
      .alarm_hour_bcd_in(alarm_hour_bcd),
      .alarm_minute_bcd_in(alarm_minute_bcd),
      .alarm_second_bcd_in(alarm_second_bcd),
      .selected_alarm(selected_alarm),
      .counter(counter),
      .alarm_hour_bcd(alarm_hour_bcd_out),
      .alarm_minute_bcd(alarm_minute_bcd_out),
      .alarm_second_bcd(alarm_second_bcd_out),
      .cancel(cancel_alarm),
      .ring(alarm_ring)
  );

  // 实例化 unixCounter 模块
  unixCounter #(
      .N(64),
      .M(26)
  ) unixCounter_inst (
      .clk(clk),
      .reset_n(rst_n),
      .load_n(load_counter),
      .go(counter_go),
      .setCounter(set_counter_value),
      .counter(counter)
  );

  // 实例化 count_down_timer 模块
  count_down_timer count_down_timer_inst (
      .clk(clk),
      .rst_n(rst_n),
      .load(load_timer),
      .clock_en(timer_clock_en),
      .hour_bcd_in(timer_hour_bcd_in),
      .minute_bcd_in(timer_minute_bcd_in),
      .second_bcd_in(timer_second_bcd_in),
      .hour_out_bcd(timer_hour_bcd_out),
      .minute_out_bcd(timer_minute_bcd_out),
      .second_out_bcd(timer_second_bcd_out),
      .ring(timer_ring)
  );
endmodule
