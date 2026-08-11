//------------------------------------------------------------------------------
// id_ex_reg.sv  —  Decode to Execute register
//
// Author:   Hoyt Darnell
// Created:  2026-08-06
//------------------------------------------------------------------------------

module id_ex_reg import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic stall,
input logic flush,
input id_ex_data_t id_ex_data_in,
output id_ex_data_t id_ex_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush) begin
        id_ex_data_out <= 'b0;
    end else if (!stall) begin
        id_ex_data_out <= id_ex_data_in;
    end
end

endmodule // id_ex_reg
