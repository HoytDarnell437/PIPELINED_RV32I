//------------------------------------------------------------------------------
// hazard_unit.sv  —  Hazard unit for pipelined rv32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-11
//------------------------------------------------------------------------------

module hazard_unit import riscv_pkg::*; (
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] ex_rd,
    input logic [4:0] mem_rd,
    input logic id_uses_rs1,
    input logic id_uses_rs2,
    input logic ex_reg_write,
    input logic mem_reg_write,
    input logic mem_busy,
    input logic [1:0] pc_src,
    output logic pc_stall,
    output logic if_id_stall,
    output logic id_ex_stall,
    output logic ex_mem_stall,
    output logic mem_wb_stall,
    output logic if_id_flush,
    output logic id_ex_flush
);

logic hazard_rs1, hazard_rs2;

assign hazard_rs1 = id_uses_rs1 && (id_rs1 != '0) && (
    (ex_reg_write && (ex_rd == id_rs1)) ||
    (mem_reg_write && (mem_rd == id_rs1))
);

assign hazard_rs2 = id_uses_rs2 && (id_rs2 != '0) && (
    (ex_reg_write && (ex_rd == id_rs2)) ||
    (mem_reg_write && (mem_rd == id_rs2))
);

always_comb begin
    pc_stall = '0;
    if_id_stall = '0;
    id_ex_stall = '0;
    ex_mem_stall = '0;
    mem_wb_stall = '0;

    if_id_flush = '0;
    id_ex_flush = '0;

    if (mem_busy) begin
        pc_stall = '1;
        if_id_stall = '1;
        id_ex_stall = '1;
        ex_mem_stall = '1;
        mem_wb_stall = '1;
    end else if (pc_src != PCSRC_NEXT) begin
        if_id_flush = '1;
        id_ex_flush = '1;
    end else begin
        if (hazard_rs1 || hazard_rs2) begin
            pc_stall = '1;
            if_id_stall = '1;
            id_ex_flush = '1;
        end
    end
end

endmodule // hazard_unit
