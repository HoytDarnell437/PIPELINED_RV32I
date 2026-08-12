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
input logic stall,
input logic [1:0] pc_src,
input logic [31:0] pc_imm,
input logic [31:0] alu_res,
output logic [31:0] addr,
output logic [31:0] pc_plus_4
);

// -- signal declaration --
logic [31:0] next_addr;

// -- combinational logic --
always_comb begin
    pc_plus_4 = addr + 4;
    next_addr = 0;
    case (pc_src)
        PCSRC_BRANCH: next_addr = pc_imm;
        PCSRC_ALU: next_addr = alu_res;
        default: next_addr = pc_plus_4;
    endcase
end

// -- sequential logic --
always_ff @(posedge clk) begin
    if (!rst_n) begin
        addr <= '0;
    end else if (!stall) begin
        addr <= next_addr;
    end
end

endmodule // pc
