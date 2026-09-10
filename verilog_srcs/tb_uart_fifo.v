`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 09:17:09
// Design Name: 
// Module Name: tb_uart_fifo
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

module tb_uart_fifo;

    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 9600;


    // Clock and reset
    reg clk;
    reg rst;


    // FIFO input
    reg       wr_en;
    reg [7:0] data_in;


    // UART outputs
    wire       tx;
    wire       tx_busy;

    wire [7:0] rx_data;
    wire       rx_done;


    // FIFO status
    wire full;
    wire empty;


    // Useful signals for waveform
    wire       fifo_rd_en;
    wire [7:0] fifo_data_out;
    wire       tx_start;


    // =========================================================
    // DUT
    // =========================================================

    uart_fifo #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) uut (

        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .data_in(data_in),

        .tx(tx),
        .tx_busy(tx_busy),

        .rx_data(rx_data),
        .rx_done(rx_done),

        .full(full),
        .empty(empty),

        .fifo_rd_en(fifo_rd_en),
        .fifo_data_out(fifo_data_out),

        .tx_start(tx_start)
    );


    // =========================================================
    // CLOCK
    // 50 MHz
    // =========================================================

    always #10 clk = ~clk;


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        clk     = 0;
        rst     = 1;

        wr_en   = 0;
        data_in = 8'h00;


        // Reset
        #100;

        rst = 0;


        // =====================================================
        // WRITE DATA INTO FIFO
        // =====================================================

        // Write 55
        @(negedge clk);
        wr_en   = 1;
        data_in = 8'h55;

        // Write AA
        @(negedge clk);
        data_in = 8'hAA;

        // Write 33
        @(negedge clk);
        data_in = 8'h33;

        // Write F0
        @(negedge clk);
        data_in = 8'hF0;


        // Stop writing
        @(negedge clk);
        wr_en = 0;


        // =====================================================
        // WAIT FOR FIRST BYTE
        // =====================================================

        @(posedge rx_done);

        #10;

        $display("Received Data 1 = %h", rx_data);

        if (rx_data == 8'h55)
            $display("BYTE 1 PASSED");
        else
            $display("BYTE 1 FAILED");


        // =====================================================
        // WAIT FOR SECOND BYTE
        // =====================================================

        @(posedge rx_done);

        #10;

        $display("Received Data 2 = %h", rx_data);

        if (rx_data == 8'hAA)
            $display("BYTE 2 PASSED");
        else
            $display("BYTE 2 FAILED");


        // =====================================================
        // WAIT FOR THIRD BYTE
        // =====================================================

        @(posedge rx_done);

        #10;

        $display("Received Data 3 = %h", rx_data);

        if (rx_data == 8'h33)
            $display("BYTE 3 PASSED");
        else
            $display("BYTE 3 FAILED");


        // =====================================================
        // WAIT FOR FOURTH BYTE
        // =====================================================

        @(posedge rx_done);

        #10;

        $display("Received Data 4 = %h", rx_data);

        if (rx_data == 8'hF0)
            $display("BYTE 4 PASSED");
        else
            $display("BYTE 4 FAILED");


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("--------------------------------");
        $display("UART FIFO TEST COMPLETED");
        $display("--------------------------------");


        #1000;

        $finish;

    end

endmodule
