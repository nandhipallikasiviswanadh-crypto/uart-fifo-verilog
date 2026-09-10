`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 12:52:45
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input        clk,
    input        rst,
    input        rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_count;
    reg [3:0]  bit_count;
    reg [7:0]  rx_shift_reg;

    reg [1:0] state;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            clk_count    <= 0;
            bit_count    <= 0;
            rx_shift_reg <= 0;
            rx_data      <= 0;
            rx_done      <= 0;
            state        <= IDLE;
        end

        else begin

            rx_done <= 1'b0;

            case (state)

                IDLE: begin
                    clk_count <= 0;
                    bit_count <= 0;

                    if (rx == 1'b0)
                        state <= START;
                end

                START: begin

                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        clk_count <= 0;

                        if (rx == 1'b0)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end

                    else
                        clk_count <= clk_count + 1;

                end

                DATA: begin

                    if (clk_count == CLKS_PER_BIT - 1) begin

                        clk_count <= 0;

                        rx_shift_reg[bit_count] <= rx;

                        if (bit_count == 7) begin
                            bit_count <= 0;
                            state <= STOP;
                        end

                        else
                            bit_count <= bit_count + 1;

                    end

                    else
                        clk_count <= clk_count + 1;

                end

                STOP: begin

                    if (clk_count == CLKS_PER_BIT - 1) begin

                        clk_count <= 0;

                        rx_data <= rx_shift_reg;
                        rx_done <= 1'b1;

                        state <= IDLE;
                    end

                    else
                        clk_count <= clk_count + 1;

                end

                default:
                    state <= IDLE;

            endcase
        end
    end

endmodule
