//------------------------------------------------------------------------------
// if_id_reg.sv  —  Fetch to Decode register
//
// Author:   Hoyt Darnell
// Created:  2026-08-05
//------------------------------------------------------------------------------

module if_id_reg import riscv_pkg::*; (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    input  if_id_data_t if_id_data_in,
    output if_id_data_t if_id_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush) begin
        if_id_data_out <= 'b0;
    end else if (!stall) begin
        if_id_data_out <= if_id_data_in;
    end
end

endmodule // if_id_reg
