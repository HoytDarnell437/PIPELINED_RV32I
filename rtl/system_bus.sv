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
inout logic [7:0] ja,
inout logic [7:0] jb,
inout logic [7:0] jc,
inout logic [7:0] jd,
output logic locked
);

// -- signal declaration --
logic clk_sys;

logic rst_n;

logic [3:0] pmod_wr_en;
logic [7:0] pmod_wr_data;
logic [1:0] pmod_reg_addr;
logic [31:0] pmod_rd_data;
logic [1:0] pmod_reg_addr_rd;

logic mem_rd;
logic mem_wr;
logic mem_ready;
logic [31:0] mem_rd_data;

logic [2:0] rd_peripheral_sel;
logic [2:0] rd_peripheral_sel_reg;
logic [2:0] wr_peripheral_sel;

logic [3:0] led_reg;

always_comb begin
    mem_rd = '0;
    mem_wr = '0;
    bus.rd_data = '0;
    bus.ready = '0;
    pmod_wr_en = '0;

    leds = led_reg;
    pmod_wr_data = bus.wr_data[7:0];

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
    end else if (rd_peripheral_sel_reg == ACCESS_JA) begin
        bus.rd_data = { 24'b0 , pmod_rd_data[7:0] };
        bus.ready = '1;
    end else if (rd_peripheral_sel_reg == ACCESS_JB) begin
        bus.rd_data = { 24'b0 , pmod_rd_data[15:8] };
        bus.ready = '1;
    end else if (rd_peripheral_sel_reg == ACCESS_JC) begin
        bus.rd_data = { 24'b0 , pmod_rd_data[23:16] };
        bus.ready = '1;
    end else if (rd_peripheral_sel_reg == ACCESS_JD) begin
        bus.rd_data = { 24'b0 , pmod_rd_data[31:24] };
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
        ACCESS_JA: begin
            pmod_wr_en = 4'b0001;
            bus.ready = '1;
        end
        ACCESS_JB: begin
            pmod_wr_en = 4'b0010;
            bus.ready = '1;
        end
        ACCESS_JC: begin
            pmod_wr_en = 4'b0100;
            bus.ready = '1;
        end
        ACCESS_JD: begin
            pmod_wr_en = 4'b1000;
            bus.ready = '1;
        end
    endcase

    if (pmod_wr_en != '0) begin
        pmod_reg_addr = bus.wr_addr[1:0];
    end else begin
        pmod_reg_addr = pmod_reg_addr_rd;
    end
end

always_ff @(posedge clk_sys) begin
    if (!rst_n) begin
        led_reg <= '0;
        rd_peripheral_sel_reg <= '0;
        pmod_reg_addr_rd <= '0;
    end else begin
        rd_peripheral_sel_reg <= rd_peripheral_sel;
        pmod_reg_addr_rd <= bus.rd_addr[1:0];

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

pmod_gpio_controller pmod_gpio_controller_inst[3:0] (
    .clk     (clk_sys),
    .rst_n   (rst_n),
    .wr_en   (pmod_wr_en),
    .pmod_io ({jd, jc, jb, ja}),
    .wr_data (pmod_wr_data),
    .reg_addr(pmod_reg_addr),
    .rd_data (pmod_rd_data)
);

data_memory data_memory_inst (
    .clk(clk_sys),
    .rst_n(rst_n),
    .en(bus.en),
    .wr(mem_wr),
    .rd(mem_rd),
    .byte_en(bus.byte_en),
    .wr_data(bus.wr_data),
    .wr_addr(bus.wr_addr[31:2]),
    .rd_addr(bus.rd_addr[31:2]),
    .rd_data(mem_rd_data),
    .ready(mem_ready)
);

address_decoder rd_address_decoder_inst (
    .address(bus.rd_addr[31:2]),
    .peripheral_sel(rd_peripheral_sel)
);

address_decoder wr_address_decoder_inst (
    .address(bus.wr_addr[31:2]),
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
