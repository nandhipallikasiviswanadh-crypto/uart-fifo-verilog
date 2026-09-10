`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 23:59:58
// Design Name: 
// Module Name: tb_fifo
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

module tb_fifo;

    reg clk;
    reg rst;

    reg wr_en;
    reg [7:0] data_in;

    reg rd_en;
    wire [7:0] data_out;

    wire full;
    wire empty;

    // DUT
    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) uut (
        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .data_in(data_in),

        .rd_en(rd_en),
        .data_out(data_out),

        .full(full),
        .empty(empty)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    initial begin

        clk    = 0;
        rst    = 1;
        wr_en  = 0;
        rd_en  = 0;
        data_in = 8'h00;

        #20;

        rst = 0;

        // -------------------------
        // WRITE DATA
        // -------------------------

        @(posedge clk);
        wr_en = 1;
        data_in = 8'h55;

        @(posedge clk);
        data_in = 8'hAA;

        @(posedge clk);
        data_in = 8'h33;

        @(posedge clk);
        data_in = 8'hF0;

        @(posedge clk);
        wr_en = 0;

        #20;

        // -------------------------
        // READ DATA
        // -------------------------

        @(posedge clk);
        rd_en = 1;

        @(posedge clk);
        rd_en = 0;

        #20;

        @(posedge clk);
        rd_en = 1;

        @(posedge clk);
        rd_en = 0;

        #20;

        @(posedge clk);
        rd_en = 1;

        @(posedge clk);
        rd_en = 0;

        #20;

        @(posedge clk);
        rd_en = 1;

        @(posedge clk);
        rd_en = 0;

        #50;

        $finish;

    end

endmodule
