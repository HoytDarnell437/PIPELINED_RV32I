//------------------------------------------------------------------------------
// hazard_unit.sv  —  Hazard unit for pipelined rv32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-11
//------------------------------------------------------------------------------

module hazard_unit import riscv_pkg::*; (
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,
    input logic [4:0] ex_rd,
    input logic [4:0] mem_rd,
    input logic [4:0] wb_rd,
    input logic id_uses_rs1,
    input logic id_uses_rs2,
    input logic ex_uses_rs1,
    input logic ex_uses_rs2,
    input logic ex_is_load,
    input logic mem_is_store,
    input logic [29:0] ex_addr,
    input logic [29:0] mem_addr,
    input logic mem_reg_write,
    input logic wb_reg_write,
    input logic mem_busy,
    input logic [1:0] id_pc_src,
    input logic [1:0] ex_pc_src,
    output logic pc_stall,
    output logic if_id_stall,
    output logic id_ex_stall_pc,
    output logic id_ex_stall_dp,
    output logic ex_mem_stall_lsu,
    output logic ex_mem_stall_haz,
    output logic ex_mem_stall_dp,
    output logic mem_wb_stall,
    output logic if_id_flush,
    output logic id_ex_flush_pc,
    output logic id_ex_flush_dp,
    output logic ex_mem_flush_lsu,
    output logic ex_mem_flush_haz,
    output logic ex_mem_flush_dp,
    output logic mem_wb_flush,
    output logic [1:0] rs1_fw_sel, rs2_fw_sel
);

logic load_use_hazard;
logic write_before_read;
logic ex_branch_jalr;
logic id_jal;

assign rs1_fw_sel = (!ex_uses_rs1 || (ex_rs1 == '0))      ? FWSEL_REG :
                    (mem_reg_write  && (mem_rd  == ex_rs1)) ? FWSEL_MEM  :
                    (wb_reg_write && (wb_rd == ex_rs1)) ? FWSEL_WB :
                                                            FWSEL_REG;

assign rs2_fw_sel = (!ex_uses_rs2 || (ex_rs2 == '0))      ? FWSEL_REG :
                    (mem_reg_write  && (mem_rd  == ex_rs2)) ? FWSEL_MEM  :
                    (wb_reg_write && (wb_rd == ex_rs2)) ? FWSEL_WB :
                                                            FWSEL_REG;

assign load_use_hazard = ex_is_load && ex_rd != '0 && (
    (id_uses_rs1 && id_rs1 == ex_rd) ||
    (id_uses_rs2 && id_rs2 == ex_rd)
);

assign write_before_read = ex_is_load && mem_is_store && (ex_addr == mem_addr);

assign ex_branch_jalr = ex_pc_src == PCSRC_JALR || ex_pc_src == PCSRC_BRANCH;
assign id_jal = id_pc_src == PCSRC_JAL;

assign pc_stall = mem_busy || (!ex_branch_jalr && !id_jal && (write_before_read || load_use_hazard));
assign if_id_stall = mem_busy || (!ex_branch_jalr && !id_jal && (write_before_read || load_use_hazard));
assign id_ex_stall_pc = mem_busy || (!ex_branch_jalr && !id_jal && write_before_read);
assign id_ex_stall_dp = mem_busy || (!ex_branch_jalr && !id_jal && write_before_read);
assign ex_mem_stall_lsu = mem_busy;
assign ex_mem_stall_haz = mem_busy;
assign ex_mem_stall_dp = mem_busy;
assign mem_wb_stall = mem_busy;

assign if_id_flush = !mem_busy && (ex_branch_jalr || id_jal);
assign id_ex_flush_pc = !mem_busy && (ex_branch_jalr || (!id_jal && !write_before_read && load_use_hazard));
assign id_ex_flush_dp = !mem_busy && (ex_branch_jalr || (!id_jal && !write_before_read && load_use_hazard));
assign ex_mem_flush_lsu = !mem_busy && !ex_branch_jalr && !id_jal && write_before_read;
assign ex_mem_flush_haz = !mem_busy && !ex_branch_jalr && !id_jal && write_before_read;
assign ex_mem_flush_dp = !mem_busy && !ex_branch_jalr && !id_jal && write_before_read;
assign mem_wb_flush = '0;

endmodule // hazard_unit
