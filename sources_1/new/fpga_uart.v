`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/09 18:20:26
// Design Name: 
// Module Name: fpga_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//fpga 串口测试

module fpga_uart(
    input clk,
    input reset_n,
    input rx_pin,
    output tx_pin
    );
    reg[7:0]                         tx_data;
    reg                              tx_data_valid;
    wire                             tx_data_ready;

    wire[7:0]                        rx_data;
    wire                             rx_data_valid;
    wire                             rx_data_ready;

    parameter                        CLK_FRE = 50;//Mhz
    uart_rx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(115200)
    ) uart_rx_inst
    (
        .clk                        (clk                      ),
        .rst_n                      (reset_n                    ),
        .rx_data                    (rx_data                  ),
        .rx_data_valid              (rx_data_valid            ),
        .rx_data_ready              (rx_data_ready            ),
        .rx_pin                     (rx_pin                   )
    );

    uart_tx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(115200)
    ) uart_tx_inst
    (
        .clk                        (clk                      ),
        .rst_n                      (reset_n                   ),
        .tx_data                    (tx_data                  ),
        .tx_data_valid              (tx_data_valid            ),
        .tx_data_ready              (tx_data_ready            ),
        .tx_pin                     (tx_pin                  )
    );

    reg [7:0] test_text[8:0];
    reg [3:0] st;
    localparam WAIT=0,START=1,SEND=2,FINISHED=3;
    reg[7:0] cnt;
    localparam CNT_MAX=9;
    always @(posedge clk) begin
        if(!reset_n) begin
            st <= WAIT;
            tx_data_valid<=0;
            tx_data<=0;
            test_text[0]<="T";test_text[1]<="e";test_text[2]<="s";test_text[3]<="t";test_text[4]<=" ";test_text[5]<="T";test_text[6]<="e";test_text[7]<="x";test_text[8]<="t";
        end
        else begin
            case(st)
                WAIT: begin 
                    st<=START;
                end
                START:begin
                    cnt<=0;
                    st<=SEND;
                    tx_data_valid<=0;
                end
                SEND:begin
                    tx_data<=test_text[cnt];
                    if(tx_data_valid&&tx_data_ready&&cnt<CNT_MAX-1) begin
                        cnt<=cnt+1;
                    end
                    else if(tx_data_valid&&tx_data_ready) begin
                        tx_data_valid<=0;
                        st<=FINISHED;
                    end
                    else if(!tx_data_valid) begin
                        tx_data_valid<=1;
                    end
                end
                FINISHED:begin
                    st<=WAIT;
                end
            endcase
        end
    end

endmodule
