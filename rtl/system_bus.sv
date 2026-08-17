//------------------------------------------------------------------------------
// system_bus.sv  —  RV32 Single-Cycle Processor System Bus
//
// Author:   Hoyt Darnell
// Created:  2026-08-02
//
// Description:
//   Connects RV32 core to peripherals including its data memory. The memory
//   peripherals are accessed using mmio.
//
// Reset: Reset is active-high at the pin, inverted internally, and synchronously deasserted in sync_reset.
//
//------------------------------------------------------------------------------
`timescale 1ns / 1ps

module system_bus import riscv_pkg::*; (
input logic clk_100,
input logic sys_rst_n,
input logic [3:0] buttons,
input logic [3:0] switches,
output logic [3:0] leds,
output logic [7:0] ja,
output logic [7:0] jb,
output logic [7:0] jc,
output logic [7:0] jd,
output logic locked
);

// -- signal declaration --
logic clk_sys;

logic rst_n;

logic mem_rd;
logic mem_wr;
logic mem_ready;
logic [31:0] mem_rd_data;

logic [1:0] rd_peripheral_sel;
logic [1:0] rd_peripheral_sel_reg;
logic [1:0] wr_peripheral_sel;

logic [3:0] led_reg;

always_comb begin
    mem_rd = '0;
    mem_wr = '0;
    bus.rd_data = '0;
    bus.ready = '0;

    leds = led_reg;

    if (rd_peripheral_sel == ACCESS_DATA_MEMORY) begin
        mem_rd = bus.rd;
    end 

    if (rd_peripheral_sel_reg == ACCESS_DATA_MEMORY) begin
        bus.rd_data = mem_rd_data;
        bus.ready = mem_ready;
    end else if (rd_peripheral_sel_reg == ACCESS_SWITCHES) begin
        bus.rd_data = { 28'b0 , switches };
        bus.ready = '1;
    end else if (rd_peripheral_sel_reg == ACCESS_BUTTONS) begin
        bus.rd_data = { 28'b0 , buttons };
        bus.ready = '1;
    end

    unique case (wr_peripheral_sel)
        ACCESS_DATA_MEMORY: begin
            mem_wr = bus.wr;
            bus.ready = '1;
        end
        ACCESS_LEDS: begin
            bus.ready = '1;
        end
    endcase
end

always_ff @(posedge clk_sys) begin
    if (!rst_n) begin
        led_reg <= '0;
        rd_peripheral_sel_reg <= '0;
    end else begin
        rd_peripheral_sel_reg <= rd_peripheral_sel;

        if (wr_peripheral_sel == ACCESS_LEDS) begin
            led_reg <= bus.wr_data[3:0];
        end
    end
end

clk_core clock_core (
    .clk_out1(clk_sys),
    .resetn(sys_rst_n),
    .locked(locked),
    .clk_in1(clk_100)
);

sync_reset sync_reset_inst (
    .clk(clk_sys),
    .invert_rst(sys_rst_n),
    .locked(locked),
    .rst_n(rst_n)
);

data_memory data_memory_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .en(bus.en),
    .wr(mem_wr),
    .rd(mem_rd),
    .byte_en(bus.byte_en),
    .wr_data(bus.wr_data),
    .wr_addr(bus.wr_addr),
    .rd_addr(bus.rd_addr),
    .rd_data(mem_rd_data),
    .ready(mem_ready)
);

address_decoder rd_address_decoder_inst (
    .address(bus.rd_addr),
    .peripheral_sel(rd_peripheral_sel)
);

address_decoder wr_address_decoder_inst (
    .address(bus.wr_addr),
    .peripheral_sel(wr_peripheral_sel)
);

processor processor_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .bus (bus.master)
);

mmio_bus_if bus (
    .clk  (clk_sys),
    .rst_n(rst_n)
);

endmodule // system_bus
