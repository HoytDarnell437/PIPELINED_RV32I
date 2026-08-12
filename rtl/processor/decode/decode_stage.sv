//------------------------------------------------------------------------------
// decode_stage.sv  —  Decode stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-06
//------------------------------------------------------------------------------

module decode_stage import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic stall,
    input logic flush,
    input if_id_data_t if_id_data,
    output id_ex_data_t id_ex_data,
    output logic uses_rs1,
    output logic uses_rs2
);

id_ex_data_t id_ex_data_next;

logic [2:0] imm_sel;

always_comb begin
    id_ex_data_next.pc = if_id_data.pc;
    id_ex_data_next.pc_4 = if_id_data.pc_4;
end

decoder decoder_inst (
    .instr    (if_id_data.instr),
    .rs1      (id_ex_data_next.rs1),
    .rs2      (id_ex_data_next.rs2),
    .rd       (id_ex_data_next.rd),
    .uses_rs1 (uses_rs1),
    .uses_rs2 (uses_rs2),
    .alu_ctrl (id_ex_data_next.alu_ctrl),
    .alu_src_a(id_ex_data_next.alu_src_a),
    .alu_src_b(id_ex_data_next.alu_src_b),
    .reg_write(id_ex_data_next.reg_write),
    .wr_src   (id_ex_data_next.wr_src),
    .imm_sel  (imm_sel),
    .mem_wr   (id_ex_data_next.mem_wr),
    .mem_rd   (id_ex_data_next.mem_rd),
    .pc_src   (id_ex_data_next.pc_src),
    .mem_size (id_ex_data_next.mem_size),
    .sign     (id_ex_data_next.sign)
);

imm_gen imm_gen_inst (
    .instr  (if_id_data.instr),
    .imm_sel(imm_sel),
    .imm    (id_ex_data_next.imm)
);

id_ex_reg id_ex_reg (
    .clk           (clk),
    .rst_n         (rst_n),
    .stall         (stall),
    .flush         (flush),
    .id_ex_data_in (id_ex_data_next),
    .id_ex_data_out(id_ex_data)
);

endmodule // decode_stage
