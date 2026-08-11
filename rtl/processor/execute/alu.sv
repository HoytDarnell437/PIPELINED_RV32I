//------------------------------------------------------------------------------
// alu.sv  —  ALU for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Purely combinational
//------------------------------------------------------------------------------

module alu import riscv_pkg::*; (
input logic [3:0] alu_ctrl,
input logic [31:0] data1,
input logic [31:0] data2,
output logic [31:0] alu_res,
output logic branch
);

// -- combinational logic --
always_comb begin
    // default values
    alu_res = 32'b0;
    branch = IGNORE_BRANCH;
    
    // case logic
    unique case (alu_ctrl)
        ALU_ADD: begin
            alu_res = data1 + data2;
        end
        ALU_SLT: begin
            alu_res = { 31'b0, $signed(data1) < $signed(data2) };
        end
        ALU_SLTU: begin
            alu_res = { 31'b0, data1 < data2 };
        end
        ALU_XOR: begin
            alu_res = data1 ^ data2;
        end
        ALU_OR: begin
            alu_res = data1 | data2;
        end
        ALU_AND: begin
            alu_res = data1 & data2;
        end
        ALU_SLL: begin
            alu_res = data1 << data2[4:0];
        end
        ALU_SRL: begin
            alu_res = data1 >> data2[4:0];
        end
        ALU_SRA: begin
            alu_res = $signed(data1) >>> data2[4:0];
        end
        ALU_SUB: begin
            alu_res = data1 - data2;
        end
        ALU_BEQ: begin
            branch = (data1 == data2) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
        ALU_BNE: begin
            branch = (data1 != data2) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
        ALU_BLT: begin
            branch = ($signed(data1) < $signed(data2)) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
        ALU_BGE: begin
            branch = ($signed(data1) >= $signed(data2)) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
        ALU_BLTU: begin
            branch = (data1 < data2) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
        ALU_BGEU: begin
            branch = (data1 >= data2) ? TAKE_BRANCH : IGNORE_BRANCH;
        end
    endcase
end

endmodule // alu
