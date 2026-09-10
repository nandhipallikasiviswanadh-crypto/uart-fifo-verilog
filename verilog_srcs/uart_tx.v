`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 12:51:24
// Design Name: 
// Module Name: uart_tx
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

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    output reg   tx,
    output reg   tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [15:0] clk_count;
    reg [3:0]  bit_count;
    reg [9:0]  tx_shift_reg;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            tx          <= 1'b1;
            tx_busy     <= 1'b0;
            clk_count   <= 0;
            bit_count   <= 0;
            tx_shift_reg <= 0;
        end

        else begin

            if (tx_start && !tx_busy) begin

                // Start bit + 8 data bits + stop bit
                tx_shift_reg <= {1'b1, tx_data, 1'b0};

                tx_busy   <= 1'b1;
                clk_count <= 0;
                bit_count <= 0;

                tx <= 1'b0;
            end

            else if (tx_busy) begin

                if (clk_count == CLKS_PER_BIT - 1) begin

                    clk_count <= 0;
                    bit_count <= bit_count + 1;

                    if (bit_count == 9) begin
                        tx      <= 1'b1;
                        tx_busy <= 1'b0;
                    end

                    else begin
                        tx_shift_reg <= tx_shift_reg >> 1;
                        tx <= tx_shift_reg[1];
                    end
                end

                else begin
                    clk_count <= clk_count + 1;
                end
            end
        end
    end

endmodule
