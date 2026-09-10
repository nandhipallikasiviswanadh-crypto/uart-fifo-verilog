`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 09:15:53
// Design Name: 
// Module Name: uart_fifo
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

module uart_fifo #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600,
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,

    // FIFO write interface
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] data_in,

    // UART outputs
    output wire                  tx,
    output wire                  tx_busy,

    // UART receiver outputs
    output wire [DATA_WIDTH-1:0] rx_data,
    output wire                  rx_done,

    // FIFO status
    output wire                  full,
    output wire                  empty,

    // Useful signals for waveform
    output reg                   fifo_rd_en,
    output wire [DATA_WIDTH-1:0] fifo_data_out,
    output reg                   tx_start
);


    // =========================================================
    // FIFO
    // =========================================================

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) fifo_inst (

        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .data_in(data_in),

        .rd_en(fifo_rd_en),
        .data_out(fifo_data_out),

        .full(full),
        .empty(empty)
    );


    // =========================================================
    // UART TX
    // =========================================================

    reg [DATA_WIDTH-1:0] tx_data;


    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_tx_inst (

        .clk(clk),
        .rst(rst),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy)
    );


    // =========================================================
    // UART RX
    // =========================================================

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_rx_inst (

        .clk(clk),
        .rst(rst),

        .rx(tx),

        .rx_data(rx_data),
        .rx_done(rx_done)
    );


    // =========================================================
    // CONTROL STATES
    // =========================================================

    localparam IDLE  = 3'd0;
    localparam READ  = 3'd1;
    localparam LOAD  = 3'd2;
    localparam START = 3'd3;
    localparam WAIT  = 3'd4;

    reg [2:0] state;


    // =========================================================
    // FIFO TO UART CONTROL
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state      <= IDLE;
            fifo_rd_en <= 1'b0;
            tx_start   <= 1'b0;
            tx_data    <= 0;

        end

        else begin

            // Default values
            fifo_rd_en <= 1'b0;
            tx_start   <= 1'b0;


            case (state)


                // -------------------------------------------------
                // IDLE
                // -------------------------------------------------

                IDLE: begin

                    if (!empty && !tx_busy) begin

                        // Read one byte from FIFO
                        fifo_rd_en <= 1'b1;

                        state <= READ;

                    end

                end


                // -------------------------------------------------
                // READ
                // -------------------------------------------------

                READ: begin

                    // Stop FIFO read enable
                    fifo_rd_en <= 1'b0;

                    // Wait one clock for FIFO data_out
                    state <= LOAD;

                end


                // -------------------------------------------------
                // LOAD
                // -------------------------------------------------

                LOAD: begin

                    // Copy FIFO data to UART TX
                    tx_data <= fifo_data_out;

                    state <= START;

                end


                // -------------------------------------------------
                // START UART
                // -------------------------------------------------

                START: begin

                    // Start UART transmission
                    tx_start <= 1'b1;

                    state <= WAIT;

                end


                // -------------------------------------------------
                // WAIT FOR UART
                // -------------------------------------------------

                WAIT: begin

                    // UART start pulse is only one clock
                    tx_start <= 1'b0;

                    // Wait until UART transmission finishes
                    if (!tx_busy) begin

                        state <= IDLE;

                    end

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule
