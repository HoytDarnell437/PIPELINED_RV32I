//------------------------------------------------------------------------------
// imm_gen.sv  —  Immediate parser and sign extender
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Purely combinational
//------------------------------------------------------------------------------
module imm_gen import riscv_pkg::*; (
input logic [31:0] instr,
input logic [2:0] imm_sel,
output logic [31:0] imm
);

always_comb begin
    case (imm_sel)
        IMM_I_TYPE: imm = { {20{instr[31]}} , instr[31:20] };
        IMM_S_TYPE: imm = { {20{instr[31]}} , instr[31:25] , instr[11:7] };
        IMM_B_TYPE: imm = { {19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0 };
        IMM_U_TYPE: imm = { instr[31:12] , 12'b0 };
        IMM_J_TYPE: imm = { {12{instr[31]}} , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };
        IMM_SHIFT: imm = { 17'b0 , instr[24:20] };
        default: imm = 32'b0;
    endcase
end

endmodule // imm_gen
