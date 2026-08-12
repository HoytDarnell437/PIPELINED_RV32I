//------------------------------------------------------------------------------
// execute_stage.sv  —  Execute stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module execute_stage import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic stall,
    input logic [31:0] reg_rs1,
    input logic [31:0] reg_rs2,
    input id_ex_data_t id_ex_data,
    output ex_mem_data_t ex_mem_data,
    output logic [31:0] alu_res,
    output logic [31:0] pc_imm,
    output logic [1:0] pc_src
);

ex_mem_data_t ex_mem_data_next;

logic [31:0] data1, data2;
logic branch;

always_comb begin
    ex_mem_data_next.wr_src = id_ex_data.wr_src;
    ex_mem_data_next.rd = id_ex_data.rd;
    ex_mem_data_next.reg_write = id_ex_data.reg_write;
    ex_mem_data_next.pc_4 = id_ex_data.pc_4;
    ex_mem_data_next.alu_res = alu_res;

    ex_mem_data_next.mem_wr = id_ex_data.mem_wr;
    ex_mem_data_next.mem_rd = id_ex_data.mem_rd;
    ex_mem_data_next.mem_size = id_ex_data.mem_size;
    ex_mem_data_next.sign = id_ex_data.sign;
    ex_mem_data_next.rs2_data = reg_rs2;

    pc_imm = id_ex_data.pc + id_ex_data.imm;

    unique case (branch)
        TAKE_BRANCH: pc_src = PCSRC_BRANCH;
        IGNORE_BRANCH: pc_src = id_ex_data.pc_src;
    endcase

    unique case (id_ex_data.alu_src_a)
        ALUSRC1_PC: data1 = id_ex_data.pc;
        ALUSRC1_RS: data1 = reg_rs1;
    endcase
    
    unique case (id_ex_data.alu_src_b)
        ALUSRC2_RS: data2 = reg_rs2;
        ALUSRC2_IMM: data2 = id_ex_data.imm;
    endcase
end

alu alu (
    .alu_ctrl(id_ex_data.alu_ctrl),
    .data1   (data1),
    .data2   (data2),
    .alu_res (alu_res),
    .branch  (branch)
);

ex_mem_reg ex_mem_reg_inst (
    .clk             (clk),
    .rst_n           (rst_n),
    .stall           (stall),
    .ex_mem_data_in  (ex_mem_data_next),
    .ex_mem_data_out (ex_mem_data)
);

endmodule // execute_stage
