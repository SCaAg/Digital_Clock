`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/09 15:37:45
// Design Name: 
// Module Name: internetTimeSet
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
//en 使能
//finished 1表示完成
//timeout 输出时间

module internetTimeSet(
    input clk,
    input reset_n,
    input en,
    output reg finished,
    output reg [31:0] timeout,
    output tx_pin,
    input rx_pin
    );

    reg[7:0]                         tx_data;
    reg                              tx_data_valid;
    wire                             tx_data_ready;

    wire[7:0]                        rx_data;
    wire                             rx_data_valid;
    wire                             rx_data_ready;

    parameter                        CLK_FRE = 50;//Mhz
    assign rx_data_ready = 1'b1;
    uart_rx#
    (
        .CLK_FRE(CLK_FRE),
        .BAUD_RATE(115200)
    ) uart_rx_inst
    (
        .clk                        (clk                      ),
        .rst_n                      (reset_n                   ),
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

    reg[7:0] SETWIFIMODE[12:0];
    reg[7:0] CONNECTWIFI[30:0];
    reg[7:0] CONNECTUDP[46:0];
    reg[7:0] SETSENDMODE[13:0];
    reg[7:0] STARTSEND[11:0];
    reg[7:0] NTPPACK[47:0];
    reg[7:0] STOPSEND[2:0];
    reg[7:0] CLOSECONNECT[12:0];
    reg [7:0] NTPRECEIVE[47:0];

    reg [3:0] st;
    localparam WAIT=0,START=1,SENDBEFORE=2,RECEIVE=3,COUTRESULT=4,FINISHED=5;
    reg [7:0] cnt;
    reg [7:0] cnt_max;
    reg [7:0] command_bytes_number[7:0];
    reg [7:0] command_cnt;

    reg [32:0] wait_cnt;
    reg [32:0] wait_cnt_max;
    reg [7:0] receive_cnt;

    reg[7:0] temp_cnt;
    always @(posedge clk)begin
        if(!reset_n)begin
            command_bytes_number[0] <= 13;
            command_bytes_number[1] <= 31;
            command_bytes_number[2] <= 47;
            command_bytes_number[3] <= 14;
            command_bytes_number[4] <= 12;
            command_bytes_number[5] <= 48;
            command_bytes_number[6] <= 3;
            command_bytes_number[7] <= 13;

            SETWIFIMODE[0]<="A";SETWIFIMODE[1]<="T";SETWIFIMODE[2]<="+";SETWIFIMODE[3]<="C";SETWIFIMODE[4]<="W";SETWIFIMODE[5]<="M";SETWIFIMODE[6]<="O";SETWIFIMODE[7]<="D";SETWIFIMODE[8]<="E";SETWIFIMODE[9]<="=";SETWIFIMODE[10]<="1";SETWIFIMODE[11]<=13;SETWIFIMODE[12]<=10;

            CONNECTWIFI[0]<="A";CONNECTWIFI[1]<="T";CONNECTWIFI[2]<="+";CONNECTWIFI[3]<="C";CONNECTWIFI[4]<="W";CONNECTWIFI[5]<="J";CONNECTWIFI[6]<="A";CONNECTWIFI[7]<="P";CONNECTWIFI[8]<="=";CONNECTWIFI[9]<="\"";CONNECTWIFI[10]<="m";CONNECTWIFI[11]<="y";CONNECTWIFI[12]<="p";
            CONNECTWIFI[13]<="h";CONNECTWIFI[14]<="o";CONNECTWIFI[15]<="n";CONNECTWIFI[16]<="e";CONNECTWIFI[17]<="\"";CONNECTWIFI[18]<=",";CONNECTWIFI[19]<="\"";CONNECTWIFI[20]<="1";CONNECTWIFI[21]<="2";CONNECTWIFI[22]<="6";CONNECTWIFI[23]<="6";CONNECTWIFI[24]<="9";
            CONNECTWIFI[25]<="8";CONNECTWIFI[26]<="8";CONNECTWIFI[27]<="8";CONNECTWIFI[28]<="\"";CONNECTWIFI[29]<=13;CONNECTWIFI[30]<=10;

            CONNECTUDP[0]<="A";CONNECTUDP[1]<="T";CONNECTUDP[2]<="+";CONNECTUDP[3]<="C";CONNECTUDP[4]<="I";CONNECTUDP[5]<="P";CONNECTUDP[6]<="S";CONNECTUDP[7]<="T";CONNECTUDP[8]<="A";CONNECTUDP[9]<="R";CONNECTUDP[10]<="T";CONNECTUDP[11]<="=";CONNECTUDP[12]<="\"";
            CONNECTUDP[13]<="U";CONNECTUDP[14]<="D";CONNECTUDP[15]<="P";CONNECTUDP[16]<="\"";CONNECTUDP[17]<=",";CONNECTUDP[18]<="\"";CONNECTUDP[19]<="1";CONNECTUDP[20]<="1";CONNECTUDP[21]<="9";CONNECTUDP[22]<=".";CONNECTUDP[23]<="2";CONNECTUDP[24]<="8";
            CONNECTUDP[25]<=".";CONNECTUDP[26]<="1";CONNECTUDP[27]<="8";CONNECTUDP[28]<="3";CONNECTUDP[29]<=".";CONNECTUDP[30]<="1";CONNECTUDP[31]<="8";CONNECTUDP[32]<="4";CONNECTUDP[33]<="\"";CONNECTUDP[34]<=",";CONNECTUDP[35]<="1";CONNECTUDP[36]<="2";
            CONNECTUDP[37]<="3";CONNECTUDP[38]<=",";CONNECTUDP[39]<="1";CONNECTUDP[40]<="0";CONNECTUDP[41]<="0";CONNECTUDP[42]<="2";CONNECTUDP[43]<=",";CONNECTUDP[44]<="0";CONNECTUDP[45]<=13;CONNECTUDP[46]<=10;

            SETSENDMODE[0]<="A";SETSENDMODE[1]<="T";SETSENDMODE[2]<="+";SETSENDMODE[3]<="C";SETSENDMODE[4]<="I";SETSENDMODE[5]<="P";SETSENDMODE[6]<="M";SETSENDMODE[7]<="O";SETSENDMODE[8]<="D";SETSENDMODE[9]<="E";SETSENDMODE[10]<="=";SETSENDMODE[11]<="1";SETSENDMODE[12]<=13;SETSENDMODE[13]<=10;

            STARTSEND[0]<="A";STARTSEND[1]<="T";STARTSEND[2]<="+";STARTSEND[3]<="C";STARTSEND[4]<="I";STARTSEND[5]<="P";STARTSEND[6]<="S";STARTSEND[7]<="E";STARTSEND[8]<="N";STARTSEND[9]<="D";STARTSEND[10]<=13;STARTSEND[11]<=10;

            NTPPACK[0]<=8'hdb;NTPPACK[1]<=0;NTPPACK[2]<=0;NTPPACK[3]<=0;NTPPACK[4]<=0;NTPPACK[5]<=0;NTPPACK[6]<=0;NTPPACK[7]<=0;NTPPACK[8]<=0;NTPPACK[9]<=0;NTPPACK[10]<=0;NTPPACK[11]<=0;NTPPACK[12]<=0;NTPPACK[13]<=0;NTPPACK[14]<=0;NTPPACK[15]<=0;NTPPACK[16]<=0;
            NTPPACK[17]<=0;NTPPACK[18]<=0;NTPPACK[19]<=0;NTPPACK[20]<=0;NTPPACK[21]<=0;NTPPACK[22]<=0;NTPPACK[23]<=0;NTPPACK[24]<=0;NTPPACK[25]<=0;NTPPACK[26]<=0;NTPPACK[27]<=0;NTPPACK[28]<=0;NTPPACK[29]<=0;NTPPACK[30]<=0;NTPPACK[31]<=0;NTPPACK[32]<=0;
            NTPPACK[33]<=0;NTPPACK[34]<=0;NTPPACK[35]<=0;NTPPACK[36]<=0;NTPPACK[37]<=0;NTPPACK[38]<=0;NTPPACK[39]<=0;NTPPACK[40]<=0;NTPPACK[41]<=0;NTPPACK[42]<=0;NTPPACK[43]<=0;NTPPACK[44]<=0;NTPPACK[45]<=0;NTPPACK[46]<=0;NTPPACK[47]<=0;
            
            STOPSEND[0]<="+";STOPSEND[1]<="+";STOPSEND[2]<="+";

            CLOSECONNECT[0]<="A";CLOSECONNECT[1]<="T";CLOSECONNECT[2]<="+";CLOSECONNECT[3]<="C";CLOSECONNECT[4]<="I";CLOSECONNECT[5]<="P";CLOSECONNECT[6]<="C";CLOSECONNECT[7]<="L";CLOSECONNECT[8]<="O";CLOSECONNECT[9]<="S";CLOSECONNECT[10]<="E";CLOSECONNECT[11]<=13;CLOSECONNECT[12]<=10;
        
            st<=WAIT;
            tx_data_valid<=0;
            tx_data<=0;
        end
        else begin
            case(st)
                WAIT: begin
                    finished<=0;
                    if(en)begin
                        st<=START;
                        command_cnt<=0;
                    end
                end
                START: begin
                    cnt<=0;
                    cnt_max<=command_bytes_number[command_cnt];
                    st<=SENDBEFORE;
                    tx_data_valid<=0;
                    wait_cnt<=0;
                    case(command_cnt)
                        2:wait_cnt_max<=500000000;
                        default:wait_cnt_max<=25000000;
                    endcase
                end
                SENDBEFORE: begin
                    if(wait_cnt<wait_cnt_max) begin
                        wait_cnt<=wait_cnt+1;
                    end
                    else begin
                        case(command_cnt)
                            0:tx_data<=SETWIFIMODE[cnt];
                            1:tx_data<=CONNECTWIFI[cnt];
                            2:tx_data<=CONNECTUDP[cnt];
                            3:tx_data<=SETSENDMODE[cnt];
                            4:tx_data<=STARTSEND[cnt];
                            5:tx_data<=NTPPACK[cnt];
                            6:tx_data<=STOPSEND[cnt];
                            7:tx_data<=CLOSECONNECT[cnt];
                        endcase
                        if(tx_data_valid&&tx_data_ready&&cnt<(cnt_max-1)) begin
                            cnt<=cnt+1;
                        end
                        else if(tx_data_valid&&tx_data_ready) begin
                            tx_data_valid<=0;
                            if(command_cnt==5)begin
                                st<=RECEIVE;
                                wait_cnt<=0;
                                receive_cnt<=0;
                            end
                            else if(command_cnt==7)begin
                                tx_data_valid<=0;
                                st<=COUTRESULT;
                                temp_cnt<=0;
                            end
                            else begin
                                st<=START;
                                command_cnt<=command_cnt+1;
                            end
                        end
                        else if(!tx_data_valid) begin
                            tx_data_valid<=1;
                        end
                    end
                end
                RECEIVE: begin
                        if(receive_cnt>=48)begin
                            st<=START;
                            timeout<={NTPRECEIVE[32],NTPRECEIVE[33],NTPRECEIVE[34],NTPRECEIVE[35]};
                            command_cnt<=6;
                        end
                        else if(rx_data_valid) begin
                            receive_cnt<=receive_cnt+1;
                            NTPRECEIVE[receive_cnt]<=rx_data;
                        end
                end
                COUTRESULT: begin
                    case(temp_cnt)
                        0:tx_data<=timeout[31:24];
                        1:tx_data<=timeout[23:16];
                        2:tx_data<=timeout[15:8];
                        3:tx_data<=timeout[7:0];
                    endcase
                    if(tx_data_valid&&tx_data_ready&&temp_cnt<3) begin
                        temp_cnt<=temp_cnt+1;
                    end
                    else if(tx_data_valid&&tx_data_ready) begin
                        tx_data_valid<=0;
                        st<=FINISHED;
                    end
                    else if(!tx_data_valid) begin
                        tx_data_valid<=1;
                    end
                end
                FINISHED: begin
                    timeout<=timeout-2208988800+8*60*60;
                    st<=WAIT;
                    finished<=1;
                end
            endcase
        end
    end

endmodule
