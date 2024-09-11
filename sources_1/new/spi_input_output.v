module spi_input_output (

  input   wire              clk,
  input   wire              rst_n,
  
  input   wire              spi_send_en,
  input   wire  [7:0]       spi_send_data,
  output  reg               spi_send_done,
  
  input   wire              spi_read_en,
  output  reg   [7:0]       spi_read_data,
  output  reg               spi_read_done,
  
  output  wire              spi_sclk,
  output  wire              spi_mosi,
  input   wire              spi_miso
);

  reg           [8:0]       send_data_buf;
  reg           [3:0]       send_cnt;
  reg                       rec_en;
  reg                       rec_en_n;
  reg           [3:0]       rec_cnt;
  reg           [7:0]       rec_data_buf;
  
  always @ (negedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      send_data_buf <= 9'd0;
    else
      if (spi_send_en == 1'b1)
        send_data_buf <= {spi_send_data, 1'b0};
      else
        send_data_buf <= send_data_buf;
  end
  
  always @ (negedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      send_cnt <= 4'd8;
    else
      if (spi_send_en == 1'b1)
        send_cnt <= 4'd0;
      else
        if (send_cnt < 4'd8)
          send_cnt <= send_cnt + 1'b1;
        else
          send_cnt <= send_cnt;
  end
  
  assign spi_mosi = send_data_buf[8 - send_cnt];
  assign spi_sclk = (send_cnt < 4'd8 || rec_en_n == 1'b1) ? clk : 1'b0;
  
  always @ (negedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      spi_send_done <= 1'b0;
    else
      if (send_cnt == 4'd7)
        spi_send_done <= 1'b1;
      else
        spi_send_done <= 1'b0;
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      rec_en <= 1'b0;
    else
      if (spi_read_en == 1'b1)
        rec_en <= 1'b1;
      else
        if (rec_cnt ==  4'd7)
          rec_en <= 1'b0;
        else
          rec_en <= rec_en;
  end
  
  always @ (negedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      rec_en_n <= 1'b0;
    else
      rec_en_n <= rec_en;
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      rec_data_buf <= 8'd0;
    else
      if (rec_en == 1'b1)
        rec_data_buf <= {rec_data_buf[6:0], spi_miso};
      else
        rec_data_buf <=rec_data_buf;
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      rec_cnt <= 4'd0;
    else
      if (rec_en == 1'b1)
        rec_cnt <= rec_cnt + 1'b1;
      else
        rec_cnt <= 4'd0;
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      spi_read_done <= 1'b0;
    else
      if (rec_cnt == 4'd8)
        spi_read_done <= 1'b1;
      else
        spi_read_done <= 1'b0;
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if (rst_n == 1'b0)
      spi_read_data <= 8'd0;
    else
      if (rec_cnt == 4'd8)
        spi_read_data <= rec_data_buf;
      else
        spi_read_data <= spi_read_data;
  end
  
endmodule