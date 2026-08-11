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

    logic [29:0] addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic rd;
    logic wr;
    logic [3:0] byte_en;
    logic ready;

    modport master (
        output addr, wr_data, rd, wr, byte_en,
        input rd_data, ready
    );

    modport slave (
        input addr, wr_data, rd, wr, byte_en,
        output rd_data, ready
    );

endinterface // mmio_bus_if
