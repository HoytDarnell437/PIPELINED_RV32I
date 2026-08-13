//------------------------------------------------------------------------------
// fetch_stage.sv  —  Fetch stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-05
//------------------------------------------------------------------------------

module fetch_stage import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic pc_stall,
    input logic if_id_stall,
    input logic flush,
    input logic [1:0] pc_src,
    input logic [31:0] pc_imm,
    input logic [31:0] alu_res,
    output if_id_data_t if_id_data
);

if_id_data_t if_id_data_next;

logic imem_en;
logic [31:0] next_pc;

assign imem_en = ~pc_stall;

pc pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .stall(pc_stall),
    .pc_src(pc_src),
    .pc_imm(pc_imm),
    .alu_res(alu_res),
    .next_addr(next_pc),
    .addr(if_id_data_next.id_pc),
    .pc_plus_4(if_id_data_next.pc_4)
);

instruction_memory instruction_memory_inst (
    .clk(clk),
    .en(imem_en),
    .addr(next_pc),
    .instr(if_id_data_next.instr)
);

if_id_reg if_id_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .stall(if_id_stall),
    .flush(flush),
    .if_id_data_in(if_id_data_next),
    .if_id_data_out(if_id_data)
);

endmodule // fetch_stage
