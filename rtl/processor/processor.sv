//------------------------------------------------------------------------------
// processor.sv  —  RV32 Single-Cycle Processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Description:
//   Single cycle RV32I processor. Instantiates: PC, instruction memory,
//   register file, decoder, immediate generator, ALU, clock
//   wizard, and synchronous reset generator.
//
// Clocking: 100 MHz board clock (clk_100) => MMCM (clk_core) => 75 MHz system clock (clk_sys).
//
// Reset: Reset is active-high at the pin, inverted internally, and synchronously deasserted in sync_reset.
//
//------------------------------------------------------------------------------
`timescale 1ns / 1ps

module processor import riscv_pkg::*; (
    input logic        clk,
    input logic        rst_n,
    mmio_bus_if.master bus
);

logic pc_stall;
logic if_id_stall;
logic id_ex_stall_pc;
logic id_ex_stall_dp;
logic ex_mem_stall_lsu;
logic ex_mem_stall_haz;
logic ex_mem_stall_pc;
logic ex_mem_stall_dp;
logic mem_wb_stall;

logic if_id_flush;
logic id_ex_flush_pc;
logic id_ex_flush_dp;
logic ex_mem_flush_lsu;
logic ex_mem_flush_haz;
logic ex_mem_flush_pc;
logic ex_mem_flush_dp;
logic mem_wb_flush;

logic [1:0] rs1_fw_sel, rs2_fw_sel;
logic       write_before_read;

logic id_uses_rs1, id_uses_rs2;

logic [1:0]  id_pc_src;
logic [31:0] jal_target;
logic [31:0] alu_res;

logic [31:0] mem_wr_addr;
logic        mem_rd;
logic        mem_wr;
logic [31:0] mem_rd_data;
logic        mem_ready;

logic [31:0] reg_rs1, reg_rs2;
logic [31:0] wb_wr_data;
logic        mem_busy;

if_id_data_t  if_id_data;
id_ex_data_t  id_ex_data;
ex_mem_data_t ex_mem_data;
mem_wb_data_t mem_wb_data;

fetch_stage fetch_stage_inst (
    .clk              (clk),
    .rst_n            (rst_n),
    .pc_stall         (pc_stall),
    .if_id_stall      (if_id_stall),
    .flush            (if_id_flush),
    .id_pc_src        (id_pc_src),
    .mem_pc_src       (ex_mem_data.pc.pc_src),
    .write_before_read(write_before_read),
    .mem_pc           (ex_mem_data.pc.mem_pc),
    .mem_is_branch    (ex_mem_data.pc.is_branch),
    .mem_take_branch  (ex_mem_data.pc.take_branch),
    .mem_branch_target(ex_mem_data.pc.branch_target),
    .jalr_target      (ex_mem_data.haz.alu_res),
    .jal_target       (jal_target),
    .if_id_data       (if_id_data)
);

decode_stage decode_stage_inst (
    .clk       (clk),
    .rst_n     (rst_n),
    .stall_pc  (id_ex_stall_pc),
    .stall_dp  (id_ex_stall_dp),
    .flush_pc  (id_ex_flush_pc),
    .flush_dp  (id_ex_flush_dp),
    .if_id_data(if_id_data),
    .id_ex_data(id_ex_data),
    .uses_rs1  (id_uses_rs1),
    .uses_rs2  (id_uses_rs2),
    .pc_src    (id_pc_src),
    .pc_imm    (jal_target)
);

execute_stage execute_stage_inst (
    .clk          (clk),
    .rst_n        (rst_n),
    .stall_lsu    (ex_mem_stall_lsu),
    .stall_haz    (ex_mem_stall_haz),
    .stall_pc     (ex_mem_stall_pc),
    .stall_dp     (ex_mem_stall_dp),
    .flush_lsu    (ex_mem_flush_lsu),
    .flush_haz    (ex_mem_flush_haz),
    .flush_pc     (ex_mem_flush_pc),
    .flush_dp     (ex_mem_flush_dp),
    .rs1_fw_sel   (rs1_fw_sel),
    .rs2_fw_sel   (rs2_fw_sel),
    .mem_rd_fw    (ex_mem_data.haz.alu_res),
    .wb_rd_fw     (wb_wr_data),
    .reg_rs1      (reg_rs1),
    .reg_rs2      (reg_rs2),
    .id_ex_data   (id_ex_data),
    .ex_mem_data  (ex_mem_data),
    .mem_rd       (mem_rd),
    .alu_res      (alu_res)
);

memory_stage memory_stage_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .stall      (mem_wb_stall),
    .flush      (mem_wb_flush),
    .mem_rd_data(mem_rd_data),
    .mem_ready  (mem_ready),
    .ex_mem_data(ex_mem_data),
    .mem_wb_data(mem_wb_data),
    .wr_addr    (mem_wr_addr),
    .mem_wr     (mem_wr),
    .mem_busy   (mem_busy)
);

lsu lsu_inst (
    .ex_mem_stall(ex_mem_stall_lsu),
    .ex_addr     (alu_res),
    .mem_addr    (mem_wr_addr),
    .rd          (mem_rd),
    .wr          (mem_wr),
    .mem_size    (ex_mem_data.lsu.mem_size),
    .wr_data_in  (ex_mem_data.lsu.rs2_data),
    .sign        (ex_mem_data.lsu.sign),
    .rd_data_out (mem_rd_data),
    .bus         (bus),
    .mem_ready   (mem_ready)
);

writeback_stage writeback_stage_inst (
    .mem_wb_data(mem_wb_data),
    .wr_data    (wb_wr_data)
);

register_file register_file_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    .rs1      (id_ex_data.dp.rs1),
    .rs2      (id_ex_data.dp.rs2),
    .rd       (mem_wb_data.rd),
    .wr_data  (wb_wr_data),
    .reg_write(mem_wb_data.reg_write),
    .data1    (reg_rs1),
    .data2    (reg_rs2)
);

hazard_unit hazard_unit_inst (
    .id_rs1           (if_id_data.instr[19:15]),
    .id_rs2           (if_id_data.instr[24:20]),
    .ex_rs1           (id_ex_data.dp.rs1),
    .ex_rs2           (id_ex_data.dp.rs2),
    .ex_rd            (id_ex_data.dp.rd),
    .mem_rd           (ex_mem_data.haz.rd),
    .wb_rd            (mem_wb_data.rd),
    .ex_is_load       (id_ex_data.dp.mem_rd),
    .mem_is_load      (ex_mem_data.haz.mem_rd),
    .wb_is_store      (mem_wb_data.mem_wr),
    .mem_addr         (ex_mem_data.haz.alu_res[31:2]),
    .wb_addr          (mem_wb_data.alu_res[31:2]),
    .id_uses_rs1      (id_uses_rs1),
    .id_uses_rs2      (id_uses_rs2),
    .ex_uses_rs1      (id_ex_data.dp.uses_rs1),
    .ex_uses_rs2      (id_ex_data.dp.uses_rs2),
    .mem_reg_write    (ex_mem_data.haz.reg_write),
    .wb_reg_write     (mem_wb_data.reg_write),
    .mem_busy         (mem_busy),
    .id_pc_src        (id_pc_src),
    .mem_pc_src       (ex_mem_data.pc.pc_src),
    .pc_stall         (pc_stall),
    .if_id_stall      (if_id_stall),
    .id_ex_stall_pc   (id_ex_stall_pc),
    .id_ex_stall_dp   (id_ex_stall_dp),
    .ex_mem_stall_lsu (ex_mem_stall_lsu),
    .ex_mem_stall_haz (ex_mem_stall_haz),
    .ex_mem_stall_pc  (ex_mem_stall_pc),
    .ex_mem_stall_dp  (ex_mem_stall_dp),
    .mem_wb_stall     (mem_wb_stall),
    .if_id_flush      (if_id_flush),
    .id_ex_flush_pc   (id_ex_flush_pc),
    .id_ex_flush_dp   (id_ex_flush_dp),
    .ex_mem_flush_lsu (ex_mem_flush_lsu),
    .ex_mem_flush_haz (ex_mem_flush_haz),
    .ex_mem_flush_pc  (ex_mem_flush_pc),
    .ex_mem_flush_dp  (ex_mem_flush_dp),
    .mem_wb_flush     (mem_wb_flush),
    .rs1_fw_sel       (rs1_fw_sel),
    .rs2_fw_sel       (rs2_fw_sel),
    .write_before_read(write_before_read)
);

endmodule // processor
