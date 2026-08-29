//------------------------------------------------------------------------------
// btfnt.sv  —  Simple backwards taken forward not taken branch predictor
//
// Author:   Hoyt Darnell
// Created:  2026-08-20
//
// Description: Simple BTFNT branch predictor
//------------------------------------------------------------------------------

module btfnt (
    input  logic [31:0] instr,
    output logic        take_branch
);

assign take_branch = instr[31];

endmodule // btfnt
