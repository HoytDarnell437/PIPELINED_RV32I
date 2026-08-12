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
input logic clk,
input logic rst_n,
mmio_bus_if.master bus
);

logic pc_stall;
logic if_id_stall;
logic id_ex_stall;
logic ex_mem_stall;
logic mem_wb_stall;

logic if_id_flush;
logic id_ex_flush;
logic mem_wb_flush;

logic [1:0] rs1_fw_sel, rs2_fw_sel;

logic id_uses_rs1, id_uses_rs2;

logic [1:0] pc_src;
logic [31:0] alu_res;
logic [31:0] pc_imm;

logic [31:0] reg_rs1, reg_rs2;
logic [31:0] wr_data;
logic mem_busy;

if_id_data_t if_id_data;
id_ex_data_t id_ex_data;
ex_mem_data_t ex_mem_data;
mem_wb_data_t mem_wb_data;

fetch_stage fetch_stage_inst (
    .clk         (clk),
    .rst_n       (rst_n),
    .pc_stall    (pc_stall),
    .if_id_stall (if_id_stall),
    .flush       (if_id_flush),
    .pc_src      (pc_src),
    .pc_imm      (pc_imm),
    .alu_res     (alu_res),
    .if_id_data  (if_id_data)
);

decode_stage decode_stage_inst (
    .clk       (clk),
    .rst_n     (rst_n),
    .stall     (id_ex_stall),
    .flush     (id_ex_flush),
    .if_id_data(if_id_data),
    .id_ex_data(id_ex_data),
    .uses_rs1(id_uses_rs1),
    .uses_rs2(id_uses_rs2)
);

execute_stage execute_stage_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .stall      (ex_mem_stall),
    .rs1_fw_sel (rs1_fw_sel),
    .rs2_fw_sel (rs2_fw_sel),
    .mem_rd_fw   (ex_mem_data.alu_res),
    .wb_rd_fw  (wr_data),
    .reg_rs1    (reg_rs1),
    .reg_rs2    (reg_rs2),
    .id_ex_data (id_ex_data),
    .ex_mem_data(ex_mem_data),
    .alu_res    (alu_res),
    .pc_imm     (pc_imm),
    .pc_src     (pc_src)
);

memory_stage memory_stage_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .stall      (mem_wb_stall),
    .flush      (mem_wb_flush),
    .ex_mem_data(ex_mem_data),
    .mem_wb_data(mem_wb_data),
    .bus        (bus),
    .mem_busy   (mem_busy)
);

writeback_stage writeback_stage_inst (
    .mem_wb_data(mem_wb_data),
    .wr_data    (wr_data)
);

register_file register_file_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    .rs1      (id_ex_data.rs1),
    .rs2      (id_ex_data.rs2),
    .rd       (mem_wb_data.rd),
    .wr_data  (wr_data),
    .reg_write(mem_wb_data.reg_write),
    .data1    (reg_rs1),
    .data2    (reg_rs2)
);

hazard_unit hazard_unit_inst (
    .id_rs1        (if_id_data.instr[19:15]),
    .id_rs2        (if_id_data.instr[24:20]),
    .ex_rs1        (id_ex_data.rs1),
    .ex_rs2        (id_ex_data.rs2),
    .ex_rd         (id_ex_data.rd),
    .mem_rd         (ex_mem_data.rd),
    .wb_rd        (mem_wb_data.rd),
    .ex_is_load    (id_ex_data.mem_rd),
    .id_uses_rs1   (id_uses_rs1),
    .id_uses_rs2   (id_uses_rs2),
    .ex_uses_rs1   (id_ex_data.uses_rs1),
    .ex_uses_rs2   (id_ex_data.uses_rs2),
    .mem_reg_write  (ex_mem_data.reg_write),
    .wb_reg_write (mem_wb_data.reg_write),
    .mem_busy      (mem_busy),
    .pc_src        (pc_src),
    .pc_stall      (pc_stall),
    .if_id_stall   (if_id_stall),
    .id_ex_stall   (id_ex_stall),
    .ex_mem_stall  (ex_mem_stall),
    .mem_wb_stall  (mem_wb_stall),
    .if_id_flush   (if_id_flush),
    .id_ex_flush   (id_ex_flush),
    .mem_wb_flush  (mem_wb_flush),
    .rs1_fw_sel    (rs1_fw_sel),
    .rs2_fw_sel    (rs2_fw_sel)
);

endmodule // processor
