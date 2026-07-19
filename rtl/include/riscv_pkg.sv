//------------------------------------------------------------------------------
// riscv_pkg.sv  —  RISC-V 32I Instruction Encoding Constants
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Description:
//   Shared constants for the RV32I single-cycle processor.  Covers opcodes,
//   funct3, funct7, alu control, write source, pc source, immediate select, and size
//
// Import into every module with `import riscv_pkg::*;`.
//------------------------------------------------------------------------------
package riscv_pkg;
    // Opcodes
    localparam OP_LUI         = 7'b0110111;
    localparam OP_AUIPC       = 7'b0010111;
    localparam OP_JAL         = 7'b1101111;
    localparam OP_JALR        = 7'b1100111;
    localparam OP_B_TYPE      = 7'b1100011;
    localparam OP_LOAD        = 7'b0000011;
    localparam OP_STORE       = 7'b0100011;
    localparam OP_I_TYPE      = 7'b0010011;
    localparam OP_R_TYPE      = 7'b0110011;
    localparam OP_FENCE       = 7'b0001111;
    localparam OP_ENVIRONMENT = 7'b1110011;

    // Branch Funct3
    localparam F3_BEQ  = 3'b000;
    localparam F3_BNE  = 3'b001;
    localparam F3_BLT  = 3'b100;
    localparam F3_BGE  = 3'b101;
    localparam F3_BLTU = 3'b110;
    localparam F3_BGEU = 3'b111;

    // Load Funct3
    localparam F3_LB  = 3'b000;
    localparam F3_LH  = 3'b001;
    localparam F3_LW  = 3'b010;
    localparam F3_LBU = 3'b100;
    localparam F3_LHU = 3'b101;
 
    // Store Funct3
    localparam F3_SB = 3'b000;
    localparam F3_SH = 3'b001;
    localparam F3_SW = 3'b010;

    // Arithmetic Funct3
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLT     = 3'b010;
    localparam F3_SLTU    = 3'b011;
    localparam F3_XOR     = 3'b100;
    localparam F3_OR      = 3'b110;
    localparam F3_AND     = 3'b111;
    localparam F3_SL      = 3'b001;
    localparam F3_SR      = 3'b101;

    // Environment Funct3
    localparam F3_FENCE   = 3'b000; // Not fully implemented yet
    localparam F3_FENCEI  = 3'b001;

    // Funct7
    localparam F7_ADD        = 7'b0000000;
    localparam F7_SUB        = 7'b0100000;
    localparam F7_LOGICAL    = 7'b0000000;
    localparam F7_ARITHMETIC = 7'b0100000;
    
    // ALU Control
    localparam ALU_ADD  = 4'b0000; // Covers addx, lx, ex, jalx, fence, sx, lui, auipc, 
    localparam ALU_SLT  = 4'b0001;
    localparam ALU_SLTU = 4'b0010;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_OR   = 4'b0100;
    localparam ALU_AND  = 4'b0101;
    localparam ALU_SLL  = 4'b0110;
    localparam ALU_SRL  = 4'b0111;
    localparam ALU_SRA  = 4'b1000;
    localparam ALU_SUB  = 4'b1001;
    localparam ALU_BEQ  = 4'b1010;
    localparam ALU_BNE  = 4'b1011;
    localparam ALU_BLT  = 4'b1100;
    localparam ALU_BGE  = 4'b1101;
    localparam ALU_BLTU = 4'b1110;
    localparam ALU_BGEU = 4'b1111;

    // WR_SRC
    localparam WRSRC_ALU  = 2'b00;
    localparam WRSRC_READ = 2'b01;
    localparam WRSRC_PC   = 2'b10;

    // PC_SRC
    localparam PCSRC_NEXT   = 2'b00;
    localparam PCSRC_BRANCH = 2'b01;
    localparam PCSRC_ALU    = 2'b10;

    // IMM_SEL
    localparam IMM_I_TYPE = 3'b000;
    localparam IMM_S_TYPE = 3'b001;
    localparam IMM_B_TYPE = 3'b010;
    localparam IMM_U_TYPE = 3'b011;
    localparam IMM_J_TYPE = 3'b100;
    localparam IMM_SHIFT  = 3'b101;

    // SIZE
    localparam SIZE_B = 2'b00;
    localparam SIZE_H = 2'b01;
    localparam SIZE_W = 2'b10;

    // BRANCH
    localparam IGNORE_BRANCH = 1'b0;
    localparam TAKE_BRANCH   = 1'b1;

    // ALU SOURCES
    localparam ALUSRC1_PC  = 1'b0;
    localparam ALUSRC1_RS  = 1'b1;
    localparam ALUSRC2_RS  = 1'b0;
    localparam ALUSRC2_IMM = 1'b1;

    // BYTE ADDRESS
    localparam FIRST_BYTE  = 2'b00;
    localparam SECOND_BYTE = 2'b01;
    localparam THIRD_BYTE  = 2'b10;
    localparam FOURTH_BYTE = 2'b11;

    // HALF SELECT
    localparam FIRST_HALF  = 1'b0;
    localparam SECOND_HALF = 1'b1;

    // BYTE ENABLE
    localparam EN_FIRST_BYTE = 4'b0001;
    localparam EN_SECOND_BYTE = 4'b0010;
    localparam EN_THIRD_BYTE = 4'b0100;
    localparam EN_FOURTH_BYTE = 4'b1000;
    localparam EN_FIRST_HALF = 4'b0011;
    localparam EN_SECOND_HALF = 4'b1100;
    localparam EN_WORD = 4'b1111;

    // PERIPHERAL SELECT
    localparam ACCESS_DATA_MEMORY = 2'b00;
    localparam ACCESS_SWITCHES    = 2'b01;
    localparam ACCESS_BUTTONS     = 2'b10;
    localparam ACCESS_LEDS        = 2'b11;

    localparam SEL_SWITCHES = 2'b00;
    localparam SEL_BUTTONS  = 2'b01;
    localparam SEL_LEDS     = 2'b10;

endpackage // riscv_pkg
