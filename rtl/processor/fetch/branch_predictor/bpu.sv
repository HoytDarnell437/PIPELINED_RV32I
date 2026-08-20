//------------------------------------------------------------------------------
// bpu.sv  —  Branch predictor for rv32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-18
//
// Descirption: Simple BTFNT branch predictor
//------------------------------------------------------------------------------

module bpu (
    //input logic clk,
    //input logic rst_n,
    //input logic [31:0] pc,
    input logic [31:0] instr,
    output logic is_branch,
    output logic take_branch
);

//logic valid;

always_comb begin
    take_branch = instr[31];
    is_branch = instr[6:0] == 'b1100011;
end

endmodule // bpu
