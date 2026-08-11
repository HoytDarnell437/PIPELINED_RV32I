//------------------------------------------------------------------------------
// writeback_stage.sv  —  Writeback stage top level module for RV32 pipelined Processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-07
//------------------------------------------------------------------------------

module writeback_stage import riscv_pkg::*; (
    input mem_wb_data_t mem_wb_data,
    output logic [31:0] wr_data
);

always_comb begin
    case (mem_wb_data.wr_src)
        WRSRC_ALU: wr_data = mem_wb_data.alu_res;
        WRSRC_READ: wr_data = mem_wb_data.rd_data;
        WRSRC_PC: wr_data = mem_wb_data.pc_4;
        default: wr_data = 32'b0;
    endcase
end

endmodule // writeback_stage
