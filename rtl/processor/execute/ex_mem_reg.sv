//------------------------------------------------------------------------------
// ex_mem_reg.sv  —  Execute to Memory register
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module ex_mem_reg import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic stall_lsu,
input logic stall_haz,
input logic stall_dp,
input logic flush_lsu,
input logic flush_haz,
input logic flush_dp,
input ex_mem_data_t ex_mem_data_in,
output ex_mem_data_t ex_mem_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush_lsu) begin
        ex_mem_data_out.lsu <= 'b0;
    end else if (!stall_lsu) begin
        ex_mem_data_out.lsu <= ex_mem_data_in.lsu;
    end
end

always_ff @(posedge clk) begin
    if (!rst_n || flush_haz) begin
        ex_mem_data_out.haz <= 'b0;
    end else if (!stall_haz) begin
        ex_mem_data_out.haz <= ex_mem_data_in.haz;
    end
end

always_ff @(posedge clk) begin
    if (!rst_n || flush_dp) begin
        ex_mem_data_out.dp <= 'b0;
    end else if (!stall_dp) begin
        ex_mem_data_out.dp <= ex_mem_data_in.dp;
    end
end

endmodule // ex_mem_reg
