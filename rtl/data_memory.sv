//------------------------------------------------------------------------------
// data_memory.sv  —  Data memory for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Read is combinational and write is synchonous
//------------------------------------------------------------------------------

module data_memory #(
localparam MEM_SIZE = 128,
localparam ADDR_WIDTH = $clog2(MEM_SIZE)
)(
input logic clk,
input logic wr,
input logic rd,
input logic [3:0] byte_en,
input logic [31:0] wr_data,
input logic [29:0] addr,
output logic [31:0] rd_data
);

// -- signal declaration --
logic [31:0] ram [0 : MEM_SIZE - 1];
logic [ADDR_WIDTH - 1 : 0] masked_addr;

// -- initialize memory --
initial begin
    $readmemh("data.hex", ram);
end

assign masked_addr = addr[ADDR_WIDTH - 1 : 0];

// -- read logic --
always_ff @(posedge clk) begin
    if (rd) begin
        rd_data <= ram[masked_addr];
    end
end

// -- write logic --
always_ff @(posedge clk) begin
    if (wr) begin
        if (byte_en[0]) ram[masked_addr][7:0] <= wr_data[7:0];
        if (byte_en[1]) ram[masked_addr][15:8] <= wr_data[15:8];
        if (byte_en[2]) ram[masked_addr][23:16] <= wr_data[23:16];
        if (byte_en[3]) ram[masked_addr][31:24] <= wr_data[31:24];
    end
end

endmodule // data_memory
