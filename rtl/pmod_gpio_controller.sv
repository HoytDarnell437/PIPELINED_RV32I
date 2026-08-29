//------------------------------------------------------------------------------
// pmod_gpio_controller.sv  —  Allows the user to change between input and
// output on pins of the pmod
//
// Author:   Hoyt Darnell
// Created:  2026-08-17
//------------------------------------------------------------------------------

module pmod_gpio_controller import riscv_pkg::*; (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       wr_en,
    inout  logic [7:0] pmod_io,
    input  logic [7:0] wr_data,
    input  logic [1:0] reg_addr,
    output logic [7:0] rd_data
);

logic [7:0] reg_out;
logic [7:0] reg_dir;

genvar i;
generate
    for (i = 0; i < $bits(reg_out); i++) begin : g_pmod_io
        assign pmod_io[i] = reg_dir[i] ? reg_out[i] : 1'bz;
    end
endgenerate

always_comb begin
    case (reg_addr)
        REGADDR_IN: rd_data = pmod_io;
        REGADDR_OUT: rd_data = reg_out;
        REGADDR_DIR: rd_data = reg_dir;
        default: rd_data = '0;
    endcase
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        reg_out <= '0;
        reg_dir <= '0;
    end else if (wr_en) begin
        if (reg_addr == REGADDR_OUT) reg_out <= wr_data;
        else if (reg_addr == REGADDR_DIR) reg_dir <= wr_data;
    end
end

endmodule // pmod_gpio_controller
