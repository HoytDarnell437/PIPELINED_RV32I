//------------------------------------------------------------------------------
// mem_wb_reg.sv  —  Memory to Writeback register
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module mem_wb_reg import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic stall,
input logic flush,
input mem_wb_data_t mem_wb_data_in,
output mem_wb_data_t mem_wb_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush) begin
        mem_wb_data_out <= 'b0;
    end else if (!stall) begin
        mem_wb_data_out <= mem_wb_data_in;
    end
end

endmodule // mem_wb_reg
