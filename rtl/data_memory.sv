//------------------------------------------------------------------------------
// data_memory.sv  —  Data memory for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Description: Dual port read and write bram module.
//
// Timing: Read and write are synchonous
//------------------------------------------------------------------------------

module data_memory #(
    localparam MEM_SIZE = 128,
    localparam ADDR_WIDTH = $clog2(MEM_SIZE)
)(
    input  logic        clk,
    input  logic        en,
    input  logic        wr,
    input  logic        rd,
    input  logic [3:0]  byte_en,
    input  logic [31:0] wr_data,
    input  logic [29:0] rd_addr,
    input  logic [29:0] wr_addr,
    output logic [31:0] rd_data,
    output logic        ready
);

logic [31:0]               ram [0 : MEM_SIZE - 1];
logic [ADDR_WIDTH - 1 : 0] masked_rd_addr;
logic [ADDR_WIDTH - 1 : 0] masked_wr_addr;

initial begin
    $readmemh("data.hex", ram);
end

assign masked_rd_addr = rd_addr[ADDR_WIDTH - 1 : 0];
assign masked_wr_addr = wr_addr[ADDR_WIDTH - 1 : 0];

always_ff @(posedge clk) begin
    if (en && rd) begin
        ready <= 1'b1;
        rd_data <= ram[masked_rd_addr];
    end
end

always_ff @(posedge clk) begin
    if (en && wr) begin
        if (byte_en[0]) ram[masked_wr_addr][7:0] <= wr_data[7:0];
        if (byte_en[1]) ram[masked_wr_addr][15:8] <= wr_data[15:8];
        if (byte_en[2]) ram[masked_wr_addr][23:16] <= wr_data[23:16];
        if (byte_en[3]) ram[masked_wr_addr][31:24] <= wr_data[31:24];
    end
end

endmodule // data_memory
