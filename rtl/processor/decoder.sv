//------------------------------------------------------------------------------
// decoder.sv  —  Decoder for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Purely combinational
//------------------------------------------------------------------------------
module decoder import riscv_pkg::*; (
input logic [31:0] instr,
input logic branch,
output logic [4:0] rs1,
output logic [4:0] rs2,
output logic [4:0] rd,
output logic [3:0] alu_ctrl,
output logic alu_src_a,
output logic alu_src_b,
output logic reg_write,
output logic [1:0] wr_src,
output logic [2:0] imm_sel,
output logic mem_rw,
output logic [1:0] pc_src,
output logic [1:0] mem_size,
output logic sign
);

// -- signal declaration --
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;

// -- combinational logic --
always_comb begin
    // default values
    rs1 = instr[19:15];
    rs2 = instr[24:20];
    rd = instr[11:7];
    alu_ctrl = ALU_ADD;
    alu_src_a = ALUSRC1_RS;
    alu_src_b = ALUSRC2_IMM;
    reg_write = 1'b1;
    wr_src = WRSRC_ALU;
    imm_sel = IMM_I_TYPE;
    mem_rw = 1'b0;
    pc_src = PCSRC_NEXT;
    mem_size = SIZE_B;
    sign = 1'b1;
    
    // Operation Specifiers
    opcode = instr[6:0];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
    
    unique case (opcode)
        // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
        OP_I_TYPE: begin
            imm_sel = IMM_I_TYPE;
            unique case (funct3)
                F3_ADD_SUB: begin
                    // Default values sufficient
                end
                F3_SLT: begin
                    alu_ctrl = ALU_SLT;
                end
                F3_SLTU: begin
                    alu_ctrl = ALU_SLTU;
                end
                F3_XOR: begin
                    alu_ctrl = ALU_XOR;
                end
                F3_OR: begin
                    alu_ctrl = ALU_OR;
                end
                F3_AND: begin
                    alu_ctrl = ALU_AND;
                end
                F3_SL: begin
                    alu_ctrl = ALU_SLL;
                    imm_sel = IMM_SHIFT;
                end
                F3_SR: begin
                    imm_sel = IMM_SHIFT;
                    if (funct7 == F7_LOGICAL) begin
                        alu_ctrl = ALU_SRL;
                    end 
                    else begin
                        alu_ctrl = ALU_SRA;
                    end
                end
            endcase
        end
        OP_JALR: begin
            imm_sel = IMM_I_TYPE;
            pc_src = PCSRC_ALU;
            wr_src = WRSRC_PC;
        end
        OP_FENCE: begin
            imm_sel = IMM_I_TYPE;
            reg_write = 1'b0;
        end
        OP_ENVIRONMENT: begin
            imm_sel = IMM_I_TYPE;
            reg_write = 1'b0;
            // ECALL
            if (!instr[20]) begin
                // Default values sufficient
            end
            // EBREAK
            else begin
                // Default values sufficient
            end
        end
        // LB LH LW LBU LHU
        OP_LOAD: begin
            imm_sel = IMM_I_TYPE;
            wr_src = WRSRC_READ;
            case (funct3)
                F3_LB: begin
                    // Default values sufficient
                end
                F3_LH: begin
                    mem_size = SIZE_H;
                end
                F3_LW: begin
                    mem_size = SIZE_W;
                end
                F3_LBU: begin
                    sign = 1'b0;
                end
                F3_LHU: begin
                    mem_size = SIZE_H;
                    sign = 1'b0;
                end
            endcase
        end
        // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
        OP_R_TYPE: begin
            alu_src_b = ALUSRC2_RS;
            unique case (funct3)
                F3_ADD_SUB: begin
                    if (funct7 == F7_ADD) begin
                        // Default values sufficient
                    end
                    else begin
                        alu_ctrl = ALU_SUB;
                    end
                end
                F3_SL: begin
                    alu_ctrl = ALU_SLL;
                end
                F3_SLT: begin
                    alu_ctrl = ALU_SLT;
                end
                F3_SLTU: begin
                    alu_ctrl = ALU_SLTU;
                end
                F3_XOR: begin
                    alu_ctrl = ALU_XOR;
                end
                F3_SR: begin
                    if (funct7 == F7_LOGICAL) begin
                        alu_ctrl = ALU_SRL;
                    end
                    else begin
                        alu_ctrl = ALU_SRA;
                    end
                end
                F3_OR: begin
                     alu_ctrl = ALU_OR;
                end
                F3_AND: begin
                    alu_ctrl = ALU_AND;
                end
            endcase
        end
        // BEQ BNE BLT BGE BLTU BGEU
        OP_B_TYPE: begin
            alu_src_b = ALUSRC2_RS;
            imm_sel = IMM_B_TYPE;
            reg_write = 1'b0;
            pc_src = PCSRC_NEXT;
            case (funct3)
                F3_BEQ: begin
                    alu_ctrl = ALU_BEQ;
                end
                F3_BNE: begin
                    alu_ctrl = ALU_BNE;
                end
                F3_BLT: begin
                    alu_ctrl = ALU_BLT;
                end
                F3_BGE: begin
                    alu_ctrl = ALU_BGE;
                end
                F3_BLTU: begin
                    alu_ctrl = ALU_BLTU;
                end
                F3_BGEU: begin
                    alu_ctrl = ALU_BGEU;
                end
            endcase
        end
        // SB SH SW
        OP_STORE: begin
            imm_sel = IMM_S_TYPE;
            reg_write = 1'b0;
            mem_rw = 1'b1;
            case (funct3)
                F3_SB: begin
                    // Default values sufficient
                end
                F3_SH: begin
                    mem_size = SIZE_H;
                end
                F3_SW: begin
                    mem_size = SIZE_W;
                end
            endcase
        end
        OP_LUI: begin
            imm_sel = IMM_U_TYPE;
            rs1 = 5'b00000;
        end 
        OP_AUIPC: begin
            imm_sel = IMM_U_TYPE;
            alu_src_a = ALUSRC1_PC;
        end
        OP_JAL: begin
            imm_sel = IMM_J_TYPE;
            alu_src_a = ALUSRC1_PC;
            pc_src = PCSRC_BRANCH;
            wr_src = WRSRC_PC;
        end
    endcase
end

endmodule // decoder
