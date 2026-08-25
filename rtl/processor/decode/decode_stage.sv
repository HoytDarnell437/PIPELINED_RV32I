//------------------------------------------------------------------------------
// decode_stage.sv  —  Decode stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-06
//------------------------------------------------------------------------------

module decode_stage import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic stall_pc,
    input logic stall_dp,
    input logic flush_pc,
    input logic flush_dp,
    input if_id_data_t if_id_data,
    output id_ex_data_t id_ex_data,
    output logic uses_rs1, uses_rs2,
    output logic [1:0] pc_src,
    output logic [31:0] pc_imm
);

id_ex_data_t id_ex_data_next;

logic [2:0] imm_sel;

always_comb begin
    id_ex_data_next.pc.ex_pc = if_id_data.id_pc;
    id_ex_data_next.pc.pc_4 = if_id_data.pc_4;
    id_ex_data_next.pc.is_branch = if_id_data.is_branch;
    id_ex_data_next.pc.take_branch = if_id_data.take_branch;
    id_ex_data_next.dp.uses_rs1 = uses_rs1;
    id_ex_data_next.dp.uses_rs2 = uses_rs2;
    id_ex_data_next.pc.pc_imm = id_ex_data_next.pc.ex_pc + id_ex_data_next.dp.imm;

    pc_imm = id_ex_data_next.pc.pc_imm;
    pc_src = id_ex_data_next.pc.pc_src;
end

decoder decoder_inst (
    .instr    (if_id_data.instr),
    .rs1      (id_ex_data_next.dp.rs1),
    .rs2      (id_ex_data_next.dp.rs2),
    .rd       (id_ex_data_next.dp.rd),
    .uses_rs1 (uses_rs1),
    .uses_rs2 (uses_rs2),
    .alu_ctrl (id_ex_data_next.dp.alu_ctrl),
    .bu_ctrl (id_ex_data_next.pc.bu_ctrl),
    .alu_src_a(id_ex_data_next.dp.alu_src_a),
    .alu_src_b(id_ex_data_next.dp.alu_src_b),
    .reg_write(id_ex_data_next.dp.reg_write),
    .wr_src   (id_ex_data_next.dp.wr_src),
    .imm_sel  (imm_sel),
    .mem_wr   (id_ex_data_next.dp.mem_wr),
    .mem_rd   (id_ex_data_next.dp.mem_rd),
    .pc_src   (id_ex_data_next.pc.pc_src),
    .mem_size (id_ex_data_next.dp.mem_size),
    .sign     (id_ex_data_next.dp.sign)
);

imm_gen imm_gen_inst (
    .instr  (if_id_data.instr),
    .imm_sel(imm_sel),
    .imm    (id_ex_data_next.dp.imm)
);

id_ex_reg id_ex_reg (
    .clk           (clk),
    .rst_n         (rst_n),
    .stall_pc         (stall_pc),
    .stall_dp         (stall_dp),
    .flush_pc         (flush_pc),
    .flush_dp         (flush_dp),
    .id_ex_data_in (id_ex_data_next),
    .id_ex_data_out(id_ex_data)
);

endmodule // decode_stage
