//------------------------------------------------------------------------------
// pc.sv  —  Program counter for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: addr progresses on each rising clock edge.
//------------------------------------------------------------------------------

module pc import riscv_pkg::*; (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic [1:0]  pc_src,
    input  logic [31:0] branch_target,
    input  logic [31:0] jalr_target,
    input  logic [31:0] jal_target,
    output logic [31:0] next_addr,
    output logic [31:0] addr,
    output logic [31:0] pc_plus_4
);

always_comb begin
    pc_plus_4 = addr + 4;

    if (!rst_n) begin
        next_addr = '0;
    end else begin
        case (pc_src)
            PCSRC_BRANCH: next_addr = branch_target;
            PCSRC_JALR: next_addr = jalr_target;
            PCSRC_JAL: next_addr = jal_target;
            default: next_addr = pc_plus_4;
        endcase
    end
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        addr <= '0;
    end else if (!stall) begin
        addr <= next_addr;
    end
end

endmodule // pc
