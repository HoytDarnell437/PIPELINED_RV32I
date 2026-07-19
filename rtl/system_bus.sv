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

logic [31:0] read_data;

logic [31:0] mem_read_data;
logic mem_write_nread;

logic [1:0] peripheral_sel;

logic write_nread;
logic [3:0] byte_en;
logic [31:0] write_data;
logic [29:0] address;

logic [3:0] led_reg;

// -- combinational logic --
always_comb begin
    // default values
    mem_write_nread = 1'b0;

    // Assign
    leds = led_reg;

    // peripheral mux
    unique case (peripheral_sel)
        ACCESS_DATA_MEMORY: begin
            read_data = mem_read_data;
            mem_write_nread = write_nread;
        end
        ACCESS_SWITCHES: begin
            read_data = { 28'b0 , switches };
        end 
        ACCESS_BUTTONS: begin
            read_data = { 28'b0 , buttons };
        end 
    endcase
end

// -- sequential logic --
always_ff @(posedge clk_sys) begin
    if (!rst_n) begin
        led_reg = 4'b0;
    end else begin
        if (peripheral_sel == ACCESS_LEDS) begin
            led_reg = write_data[3:0];
        end
    end
end

// -- module instances -- 

clk_core clock_core (
    .clk(clk_sys),
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
    .wr(mem_write_nread),
    .byte_en(byte_en),
    .write_data(write_data),
    .addr(address),
    .read_data(mem_read_data)
);

address_decoder address_decoder_inst (
    .address(address),
    .peripheral_sel(peripheral_sel)
);

processor processor_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .read_data_in(read_data),
    .write_nread(write_nread),
    .byte_en(byte_en),
    .write_data_out(write_data),
    .address(address)
);

endmodule // system_bus
