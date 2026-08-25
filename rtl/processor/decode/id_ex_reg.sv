//------------------------------------------------------------------------------
// id_ex_reg.sv  —  Decode to Execute register
//
// Author:   Hoyt Darnell
// Created:  2026-08-06
//------------------------------------------------------------------------------

module id_ex_reg import riscv_pkg::*; (
    input logic clk,
    input logic rst_n,
    input logic stall_pc,
    input logic stall_dp,
    input logic flush_pc,
    input logic flush_dp,
    input id_ex_data_t id_ex_data_in,
    output id_ex_data_t id_ex_data_out
);

always_ff @(posedge clk) begin
    if (!rst_n || flush_pc) id_ex_data_out.pc <= '0;
    else if (!stall_pc)     id_ex_data_out.pc <= id_ex_data_in.pc;
end

always_ff @(posedge clk) begin
    if (!rst_n || flush_dp) id_ex_data_out.dp <= '0;
    else if (!stall_dp)     id_ex_data_out.dp <= id_ex_data_in.dp;
end

endmodule // id_ex_reg

/*module id_ex_reg import riscv_pkg::*; (
input logic clk,
input logic rst_n,
input logic stall_upper,
input logic stall_lower,
input logic flush_upper,
input logic flush_lower,
input id_ex_data_t id_ex_data_in,
output id_ex_data_t id_ex_data_out
);

localparam TOTAL_BITS = $bits(id_ex_data_t);
localparam HALF_BITS = TOTAL_BITS / 2;

always_ff @(posedge clk) begin
    if (!rst_n || flush_upper) begin
        id_ex_data_out[TOTAL_BITS - 1 : HALF_BITS] <= 'b0;
    end else if (!stall_upper) begin
        id_ex_data_out[TOTAL_BITS - 1 : HALF_BITS] <= id_ex_data_in[TOTAL_BITS - 1 : HALF_BITS];
    end
end


always_ff @(posedge clk) begin
    if (!rst_n || flush_lower) begin
        id_ex_data_out[HALF_BITS - 1 : 0] <= 'b0;
    end else if (!stall_lower) begin
        id_ex_data_out[HALF_BITS - 1 : 0] <= id_ex_data_in[HALF_BITS - 1 : 0];
    end
end

endmodule // id_ex_reg */
