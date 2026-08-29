//------------------------------------------------------------------------------
// id_ex_reg.sv  —  Decode to Execute register
//
// Author:   Hoyt Darnell
// Created:  2026-08-06
//------------------------------------------------------------------------------

module id_ex_reg import riscv_pkg::*; (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall_pc,
    input  logic        stall_dp,
    input  logic        flush_pc,
    input  logic        flush_dp,
    input  id_ex_data_t id_ex_data_in,
    output id_ex_data_t id_ex_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush_pc) begin
        id_ex_data_out.pc <= '0;
    end else if (!stall_pc) begin
        id_ex_data_out.pc <= id_ex_data_in.pc;
    end
end

always_ff @(posedge clk) begin
    if (!rst_n || flush_dp) begin
        id_ex_data_out.dp <= '0;
    end else if (!stall_dp) begin
        id_ex_data_out.dp <= id_ex_data_in.dp;
    end
end

endmodule // id_ex_reg
