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
input logic [31:0] read_data_in,
output logic write_nread,
output logic [3:0] byte_en,
output logic [31:0] write_data_out,
output logic [29:0] address
);

// -- signal declaration --
logic [31:0] data1_in;
logic [31:0] data2_in;
logic [31:0] wr_data;
logic [1:0] pc_src;

logic [31:0] addr;
logic [31:0] pc_plus_4;
logic [31:0] instr;

logic [31:0] data1;
logic [31:0] data2;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;

logic [3:0] alu_ctrl;
logic alu_src_a;
logic alu_src_b;
logic reg_write;
logic [1:0] wr_src;
logic [2:0] imm_sel;
logic [1:0] pc_src_sel;
logic [1:0] mem_size;
logic sign;

logic [31:0] alu_res;
logic branch;
logic [31:0] imm;

logic [31:0] read_data;
logic [31:0] write_data;

// -- combinational logic --
always_comb begin
    // port aliases
    write_data = data2;
    address = alu_res[31:2];

    // muxes 
    unique case (branch)
        IGNORE_BRANCH: pc_src = pc_src_sel;
        TAKE_BRANCH: pc_src = PCSRC_BRANCH;
    endcase
    
    unique case (wr_src)
        WRSRC_ALU: wr_data = alu_res;
        WRSRC_READ: wr_data = read_data;
        WRSRC_PC: wr_data = pc_plus_4;
    endcase
    
    unique case (alu_src_a)
        ALUSRC1_PC: data1_in = addr;
        ALUSRC1_RS: data1_in = data1;
    endcase
    
    unique case (alu_src_b)
        ALUSRC2_RS: data2_in = data2;
        ALUSRC2_IMM: data2_in = imm;
    endcase
end

// -- module instances -- 

pc pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_src(pc_src),
    .imm(imm),
    .alu_res(alu_res),
    .addr(addr),
    .pc_plus_4(pc_plus_4)
);

instruction_memory instruction_memory_inst (
    .addr(addr),
    .instr(instr)
);

register_file register_file_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wr_data(wr_data),
    .reg_write(reg_write),
    .data1(data1),
    .data2(data2)
);

decoder decoder_inst (
    .instr(instr),
    .branch(branch),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .alu_ctrl(alu_ctrl),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b),
    .reg_write(reg_write),
    .wr_src(wr_src),
    .imm_sel(imm_sel),
    .mem_rw(write_nread),
    .pc_src(pc_src_sel),
    .mem_size(mem_size),
    .sign(sign)
);

alu alu_inst (
    .alu_ctrl(alu_ctrl),
    .data1(data1_in),
    .data2(data2_in),
    .alu_res(alu_res),
    .branch(branch)
);

lsu lsu_inst (
    .byte_addr(alu_res[1:0]),
    .mem_size(mem_size),
    .sign(sign),
    .read_data_in(read_data_in),
    .read_data_out(read_data),
    .write_data_in(write_data),
    .write_data_out(write_data_out),
    .byte_en(byte_en)
);

imm_gen imm_gen_inst (
    .instr(instr),
    .imm_sel(imm_sel),
    .imm(imm)
);

endmodule // processor
