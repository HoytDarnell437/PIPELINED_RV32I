//------------------------------------------------------------------------------
// execute_stage.sv  —  Execute stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module execute_stage import riscv_pkg::*; (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         stall_lsu,
    input  logic         stall_haz,
    input  logic         stall_pc,
    input  logic         stall_dp,
    input  logic         flush_lsu,
    input  logic         flush_haz,
    input  logic         flush_pc,
    input  logic         flush_dp,
    input  logic [1:0]   rs1_fw_sel, rs2_fw_sel,
    input  logic [31:0]  mem_rd_fw, wb_rd_fw,
    input  logic [31:0]  reg_rs1,
    input  logic [31:0]  reg_rs2,
    input  id_ex_data_t  id_ex_data,
    output ex_mem_data_t ex_mem_data,
    output logic         mem_rd,
    output logic [31:0]  alu_res
);

ex_mem_data_t ex_mem_data_next;

logic [31:0] reg_rs1_fw, reg_rs2_fw;
logic [31:0] data1, data2;
logic        branch;

always_comb begin
    unique case (id_ex_data.pc.is_branch)
        0: branch = '0;
        1: branch = ex_mem_data_next.pc.take_branch;
    endcase

    if (id_ex_data.pc.is_branch && (branch != id_ex_data.pc.take_branch)) begin
        ex_mem_data_next.pc.pc_src = PCSRC_BRANCH;
    end else begin
        ex_mem_data_next.pc.pc_src = id_ex_data.pc.pc_src;
    end

    unique case (branch)
        IGNORE_BRANCH: ex_mem_data_next.pc.branch_target = id_ex_data.pc.pc_4;
        TAKE_BRANCH: ex_mem_data_next.pc.branch_target = id_ex_data.pc.pc_imm;
    endcase

    case (rs1_fw_sel)
        FWSEL_MEM: reg_rs1_fw = mem_rd_fw;
        FWSEL_WB: reg_rs1_fw = wb_rd_fw;
        default: reg_rs1_fw = reg_rs1;
    endcase

    case (rs2_fw_sel)
        FWSEL_MEM: reg_rs2_fw = mem_rd_fw;
        FWSEL_WB: reg_rs2_fw = wb_rd_fw;
        default: reg_rs2_fw = reg_rs2;
    endcase

    unique case (id_ex_data.dp.alu_src_a)
        ALUSRC1_PC: data1 = id_ex_data.pc.ex_pc;
        ALUSRC1_RS: data1 = reg_rs1_fw;
    endcase
    
    unique case (id_ex_data.dp.alu_src_b)
        ALUSRC2_RS: data2 = reg_rs2_fw;
        ALUSRC2_IMM: data2 = id_ex_data.dp.imm;
    endcase

    ex_mem_data_next.dp.wr_src = id_ex_data.dp.wr_src;
    ex_mem_data_next.haz.rd = id_ex_data.dp.rd;
    ex_mem_data_next.haz.reg_write = id_ex_data.dp.reg_write;
    ex_mem_data_next.pc.is_branch = id_ex_data.pc.is_branch;
    ex_mem_data_next.pc.mem_pc = id_ex_data.pc.ex_pc;
    ex_mem_data_next.dp.pc_4 = id_ex_data.pc.pc_4;
    ex_mem_data_next.haz.alu_res = alu_res;

    ex_mem_data_next.haz.mem_wr = id_ex_data.dp.mem_wr;
    ex_mem_data_next.haz.mem_rd = id_ex_data.dp.mem_rd;
    ex_mem_data_next.lsu.mem_size = id_ex_data.dp.mem_size;
    ex_mem_data_next.lsu.sign = id_ex_data.dp.sign;
    ex_mem_data_next.lsu.rs2_data = reg_rs2_fw;

    mem_rd = id_ex_data.dp.mem_rd;
end

alu alu_inst (
    .alu_ctrl(id_ex_data.dp.alu_ctrl),
    .data1   (data1),
    .data2   (data2),
    .alu_res (alu_res)
);

bu bu_inst (
    .bu_ctrl(id_ex_data.pc.bu_ctrl),
    .data1  (reg_rs1_fw),
    .data2  (reg_rs2_fw),
    .branch (ex_mem_data_next.pc.take_branch)
);

ex_mem_reg ex_mem_reg_inst (
    .clk             (clk),
    .rst_n           (rst_n),
    .stall_lsu       (stall_lsu),
    .stall_haz       (stall_haz),
    .stall_pc        (stall_pc),
    .stall_dp        (stall_dp),
    .flush_lsu       (flush_lsu),
    .flush_haz       (flush_haz),
    .flush_pc        (flush_pc),
    .flush_dp        (flush_dp),
    .ex_mem_data_in  (ex_mem_data_next),
    .ex_mem_data_out (ex_mem_data)
);

endmodule // execute_stage
