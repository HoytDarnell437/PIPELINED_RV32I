//------------------------------------------------------------------------------
// alu.sv  —  ALU for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Purely combinational
//------------------------------------------------------------------------------

module alu import riscv_pkg::*; (
    input  logic [3:0]  alu_ctrl,
    input  logic [31:0] data1,
    input  logic [31:0] data2,
    output logic [31:0] alu_res
);

always_comb begin
    case (alu_ctrl)
        ALU_ADD: begin
            alu_res = data1 + data2;
        end
        ALU_SLT: begin
            alu_res = {31'b0, $signed(data1) < $signed(data2)};
        end
        ALU_SLTU: begin
            alu_res = {31'b0, data1 < data2};
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
        default: begin
            alu_res = 32'b0;
        end
    endcase
end

endmodule // alu
