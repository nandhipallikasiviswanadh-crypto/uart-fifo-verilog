`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 23:58:25
// Design Name: 
// Module Name: fifo
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


module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] data_in,

    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] data_out,

    output wire                  full,
    output wire                  empty
);

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write and read pointers
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    // Number of stored data items
    reg [4:0] count;

    // FIFO status
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            wr_ptr    <= 0;
            rd_ptr    <= 0;
            count     <= 0;
            data_out  <= 0;
        end

        else begin

            // WRITE
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end

            // READ
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end

            // COUNT
            case ({wr_en && !full, rd_en && !empty})

                2'b10: count <= count + 1; // write only

                2'b01: count <= count - 1; // read only

                2'b11: count <= count;     // write + read

                default: count <= count;   // nothing

            endcase

        end
    end

endmodule
