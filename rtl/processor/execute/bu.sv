//------------------------------------------------------------------------------
// bu.sv  —  Branch Unit for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-16
//
// Timing: Purely combinational
//------------------------------------------------------------------------------

module bu import riscv_pkg::*; (
    input  logic [2:0]  bu_ctrl,
    input  logic [31:0] data1,
    input  logic [31:0] data2,
    output logic        branch
);

always_comb begin
    case (bu_ctrl)
        BU_BEQ: begin
            branch = data1 == data2;
        end
        BU_BNE: begin
            branch = data1 != data2;
        end
        BU_BLT: begin
            branch = $signed(data1) < $signed(data2);
        end
        BU_BGE: begin
            branch = $signed(data1) >= $signed(data2);
        end
        BU_BLTU: begin
            branch = data1 < data2;
        end
        BU_BGEU: begin
            branch = data1 >= data2;
        end
        default: begin
            branch = IGNORE_BRANCH;
        end
    endcase
end

endmodule // bu
