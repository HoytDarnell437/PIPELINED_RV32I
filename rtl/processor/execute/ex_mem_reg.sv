//------------------------------------------------------------------------------
// ex_mem_reg.sv  —  Execute to Memory register
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module ex_mem_reg import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic stall,
input ex_mem_data_t ex_mem_data_in,
output ex_mem_data_t ex_mem_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n) begin
        ex_mem_data_out <= 'b0;
    end else if (!stall) begin
        ex_mem_data_out <= ex_mem_data_in;
    end
end

endmodule // ex_mem_reg
