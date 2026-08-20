//------------------------------------------------------------------------------
// bpu.sv  —  Branch predictor for rv32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-18
//
// Description: Simple BTFNT branch predictor
//------------------------------------------------------------------------------

module bpu (
    input logic clk,
    input logic rst_n,
    input logic [31:0] if_addr,
    input logic [31:0] if_instr,
    input logic [31:0] ex_addr,
    input logic ex_is_branch,
    input logic ex_take_branch,
    output logic if_is_branch,
    output logic if_take_branch
);

logic btfnt_branch;
logic dynamic_branch;
logic valid;

always_comb begin
    if_is_branch = if_instr[6:0] == 'b1100011;

    unique case (valid)
        0: if_take_branch = btfnt_branch;
        1: if_take_branch = dynamic_branch;
    endcase
end

btfnt btfnt_inst (
    .instr      (if_instr),
    .take_branch(btfnt_branch)
);

dynamic dynamic_inst (
    .clk           (clk),
    .rst_n         (rst_n),
    .if_addr       (if_addr),
    .ex_addr       (ex_addr),
    .ex_is_branch  (ex_is_branch),
    .ex_take_branch(ex_take_branch),
    .take_branch   (dynamic_branch),
    .valid         (valid)
);

endmodule // bpu
