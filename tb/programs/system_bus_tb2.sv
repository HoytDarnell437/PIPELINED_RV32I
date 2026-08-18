//------------------------------------------------------------------------------
// system_bus_tb.sv  —  Testbench for RV32 processor with peripherals
//
// Author:   Hoyt Darnell
// Created:  2026-08-02
//
// Clocking: Generates a system clock at 100 MHz
//
// Reset: Asserts rst for first 50 ns of testbench
//------------------------------------------------------------------------------
`timescale 1ns/1ps 

module system_bus_tb;

    logic clk, rst_n, locked;
    logic [3:0] buttons;
    logic [3:0] switches;
    logic [3:0] leds;
    wire [7:0] ja,jb,jc,jd;
    
    system_bus system_bus_inst (
        .clk_100(clk),
        .sys_rst_n(rst_n),
        .buttons(buttons),
        .switches(switches),
        .leds(leds),
        .ja(ja),
        .jb(jb),
        .jc(jc),
        .jd(jd),
        .locked(locked)
    );

    always #5 clk = !clk;

    initial begin
        clk = 0;
        rst_n = 0;
        switches = 4'b0101;
        buttons = 4'b0000;

        #50;

        rst_n = 1;
        
        @(posedge locked);

        repeat (4000) @(posedge clk);

        $finish;
    end

endmodule // processor_tb
