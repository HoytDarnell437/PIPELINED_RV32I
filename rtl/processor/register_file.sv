//------------------------------------------------------------------------------
// register_file.sv  —  Register file for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Combinational read and sequential write.
//------------------------------------------------------------------------------

module register_file #(
    localparam REGISTER_COUNT = 32
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wr_data,
    input  logic        reg_write,
    output logic [31:0] data1,
    output logic [31:0] data2
);

logic [31:0] registers [REGISTER_COUNT - 1 : 0];

assign data1 = registers[rs1];
assign data2 = registers[rs2];

always_ff @(posedge clk) begin
    if (!rst_n) begin
        for (int i = 0; i < REGISTER_COUNT; i++) begin
            registers[i] <= 32'b0;
        end
    end else if (reg_write && rd != 0) begin
        registers[rd] <= wr_data;
    end
end

endmodule // register_file
