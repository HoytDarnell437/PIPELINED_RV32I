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
output logic locked
);

// -- signal declaration --
logic clk_sys;

logic rst_n;

logic mem_rd;
logic mem_wr;
logic [31:0] mem_rd_data;

logic [1:0] peripheral_sel;

logic [3:0] led_reg;

always_comb begin
    mem_rd = '0;
    mem_wr = '0;
    bus.rd_data = '0;

    leds = led_reg;

    unique case (peripheral_sel)
        ACCESS_DATA_MEMORY: begin
            mem_rd = bus.rd;
            mem_wr = bus.wr;
            bus.rd_data = mem_rd_data;
        end
        ACCESS_SWITCHES: begin
            bus.rd_data = { 28'b0 , switches };
        end 
        ACCESS_BUTTONS: begin
            bus.rd_data = { 28'b0 , buttons };
        end 
    endcase
end

always_ff @(posedge clk_sys) begin
    if (!rst_n) begin
        led_reg = 4'b0;
    end else begin
        if (peripheral_sel == ACCESS_LEDS) begin
            led_reg = bus.wr_data[3:0];
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
    .wr(mem_wr),
    .rd(mem_rd),
    .byte_en(bus.byte_en),
    .wr_data(bus.wr_data),
    .addr(bus.addr),
    .rd_data(mem_rd_data)
);

address_decoder address_decoder_inst (
    .address(bus.addr),
    .peripheral_sel(peripheral_sel)
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
