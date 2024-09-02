`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/02 15:31:49
// Design Name: 
// Module Name: spiMaster
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
//spiÖ÷»ú
//

module spiMaster(
    output reg sck,
    output reg mosi,
    output cs,
    output dc,

    input dc_in,
    input [7:0] spi_data_out,
    input spi_send,

    output reg spi_send_done,
    );
endmodule
