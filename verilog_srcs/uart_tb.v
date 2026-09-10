`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 12:53:34
// Design Name: 
// Module Name: uart_tb
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

`timescale 1ns/1ps

module uart_tb;

    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 9600;

    reg clk;
    reg rst;

    reg       tx_start;
    reg [7:0] tx_data;

    wire      tx;
    wire      tx_busy;

    wire [7:0] rx_data;
    wire       rx_done;

    // UART Transmitter
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // UART Receiver
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'h00;

        #100;

        rst = 0;

        // Send 0x55
        #100;
        tx_data = 8'h55;
        tx_start = 1;

        #20;
        tx_start = 0;

        // Wait for reception
        wait(rx_done);

        #100;

        // Display received data
        $display("Received Data = %h", rx_data);

        if (rx_data == 8'h55)
            $display("UART TEST PASSED");
        else
            $display("UART TEST FAILED");

        #1000;

        $finish;

    end

endmodule
