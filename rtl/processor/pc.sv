//------------------------------------------------------------------------------
// pc.sv  —  Program counter for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: addr progresses on each rising clock edge.
//------------------------------------------------------------------------------
module pc import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic [1:0] pc_src,
input logic [31:0] imm,
input logic [31:0] alu_res,
output logic [31:0] addr,
output logic [31:0] pc_plus_4
);

// -- signal declaration --
logic [31:0] pc_plus_imm;
logic [31:0] next_addr;

// -- combinational logic --
always_comb begin
    pc_plus_4 = addr + 4;
    pc_plus_imm = addr + imm;
    next_addr = 0;
    unique case (pc_src)
        PCSRC_NEXT: next_addr = pc_plus_4;
        PCSRC_BRANCH: next_addr = pc_plus_imm;
        PCSRC_ALU: next_addr = alu_res;
    endcase
end

// -- sequential logic --
always_ff @(posedge clk) begin
    if (!rst_n) begin
        addr <= 32'b0;
    end else begin
        addr <= next_addr;
    end
end

endmodule // pc
