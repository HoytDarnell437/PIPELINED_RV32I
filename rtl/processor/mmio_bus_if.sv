//------------------------------------------------------------------------------
// mmio_bus_if.sv  —  Memory mapped IO interface for pipelined rv32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-08-10
//------------------------------------------------------------------------------

interface mmio_bus_if (
    input logic clk,
    input logic rst_n
);

    logic [29:0] wr_addr;
    logic [31:0] wr_data;
    logic wr;
    logic [29:0] rd_addr;
    logic [31:0] rd_data;
    logic rd;
    logic [3:0] byte_en;
    logic en;
    logic ready;

    modport master (
        output wr_addr, wr_data, wr, rd_addr, rd, byte_en, en,
        input rd_data, ready
    );

    modport slave (
        input wr_addr, wr_data, wr, rd_addr, rd, byte_en, en,
        output rd_data, ready
    );

endinterface // mmio_bus_if
