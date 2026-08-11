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
    input ex_mem_data_t ex_mem_data,
    output mem_wb_data_t mem_wb_data,
    mmio_bus_if.master bus
);

mem_wb_data_t mem_wb_data_next;

always_comb begin
    bus.addr = ex_mem_data.alu_res[29:0];
    mem_wb_data_next.wr_src = ex_mem_data.wr_src;
    mem_wb_data_next.alu_res = ex_mem_data.alu_res;
    mem_wb_data_next.rd = ex_mem_data.rd;
    mem_wb_data_next.reg_write = ex_mem_data.reg_write;
end

lsu lsu_inst (
    .byte_addr(ex_mem_data.alu_res[1:0]),
    .mem_size(ex_mem_data.mem_size),
    .sign(ex_mem_data.sign),
    .read_data_in(bus.rd_data),
    .read_data_out(mem_wb_data_next.rd_data),
    .write_data_in(ex_mem_data.rs2_data),
    .write_data_out(bus.wr_data),
    .byte_en(bus.byte_en)
);

mem_wb_reg mem_wb_reg_inst (
    .clk          (clk),
    .rst_n        (rst_n),
    .stall        (stall),
    .mem_wb_data_in (mem_wb_data_next),
    .mem_wb_data_out (mem_wb_data)
);

endmodule // memory_stage
