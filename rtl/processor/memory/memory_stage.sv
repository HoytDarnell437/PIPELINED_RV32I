//------------------------------------------------------------------------------
// memory_stage.sv  —  Memory stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module memory_stage import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic stall,
    input logic flush,
    input logic [31:0] mem_rd_data,
    input logic mem_ready,
    input ex_mem_data_t ex_mem_data,
    output mem_wb_data_t mem_wb_data,
    output logic [31:0] wr_addr,
    output logic mem_wr,
    output logic mem_busy
);

mem_wb_data_t mem_wb_data_next;

always_comb begin
    wr_addr = ex_mem_data.haz.alu_res;
    mem_wr = ex_mem_data.haz.mem_wr;

    mem_wb_data_next.wr_src = ex_mem_data.dp.wr_src;
    mem_wb_data_next.alu_res = ex_mem_data.haz.alu_res;
    mem_wb_data_next.rd = ex_mem_data.haz.rd;
    mem_wb_data_next.reg_write = ex_mem_data.haz.reg_write;
    mem_wb_data_next.wb_pc = ex_mem_data.pc.mem_pc;
    mem_wb_data_next.pc_4 = ex_mem_data.dp.pc_4;
    mem_wb_data_next.rd_data = mem_rd_data;
    mem_wb_data_next.mem_wr = ex_mem_data.haz.mem_wr;

    mem_busy = (ex_mem_data.haz.mem_rd || ex_mem_data.haz.mem_wr) && !mem_ready;
end

mem_wb_reg mem_wb_reg_inst (
    .clk          (clk),
    .rst_n        (rst_n),
    .stall        (stall),
    .flush        (flush),
    .mem_wb_data_in (mem_wb_data_next),
    .mem_wb_data_out (mem_wb_data)
);

endmodule // memory_stage
