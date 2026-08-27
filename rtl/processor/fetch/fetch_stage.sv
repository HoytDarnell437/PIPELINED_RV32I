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
    input logic [1:0] id_pc_src,
    input logic [1:0] mem_pc_src,
    input logic write_before_read,
    input logic [31:0] mem_pc,
    input logic mem_is_branch,
    input logic mem_take_branch,
    input logic [31:0] mem_branch_target,
    input logic [31:0] jalr_target,
    input logic [31:0] jal_target,
    output if_id_data_t if_id_data
);

if_id_data_t if_id_data_next;

logic [1:0] pc_src;
logic imem_en;
logic [31:0] next_pc;
logic [31:0] branch_target;

assign imem_en = ~pc_stall;

always_comb begin
    branch_target = '0;

    if (write_before_read) begin
        pc_src = PCSRC_BRANCH;
        branch_target = mem_pc;
    end else if (mem_pc_src == PCSRC_BRANCH) begin
        pc_src = PCSRC_BRANCH;
        branch_target = mem_branch_target;
    end else if (mem_pc_src == PCSRC_JALR) begin
        pc_src = PCSRC_JALR;
    end else if (id_pc_src == PCSRC_JAL) begin
        pc_src = PCSRC_JAL;
    end else if (if_id_data_next.is_branch && if_id_data_next.take_branch) begin
        pc_src = PCSRC_BRANCH;
        branch_target = if_id_data_next.id_pc + { {19{if_id_data_next.instr[31]}} , if_id_data_next.instr[31] , if_id_data_next.instr[7] , if_id_data_next.instr[30:25] , if_id_data_next.instr[11:8] , 1'b0 };
    end else begin
        pc_src = PCSRC_NEXT;
    end
end

pc pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .stall(pc_stall),
    .pc_src(pc_src),
    .branch_target(branch_target),
    .jalr_target(jalr_target),
    .jal_target(jal_target),
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

bpu bpu_inst (
    .clk           (clk),
    .rst_n         (rst_n),
    .if_addr       (if_id_data_next.id_pc),
    .if_instr      (if_id_data_next.instr),
    .ex_addr       (mem_pc),
    .ex_is_branch  (mem_is_branch),
    .ex_take_branch(mem_take_branch),
    .if_is_branch  (if_id_data_next.is_branch),
    .if_take_branch(if_id_data_next.take_branch)
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
