//------------------------------------------------------------------------------
// processor_tb.sv  —  Testbench for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Clocking: Generates a system clock at 100 MHz
//
// Reset: Asserts rst for first 50 ns of testbench
//------------------------------------------------------------------------------
`timescale 1ns/1ps 

module processor_tb;

    logic clk, rst, out;    

    processor processor_inst (
        .clk_100(clk),
        .rst(rst),
        .locked(locked),
        .out_check(out)
    );

    always #5 clk = !clk;

    initial begin
        clk = 0;
        rst = 1;

        #50;

        rst = 0;
        
        // Wait for PLL to lock (with timeout)
        fork : wait_for_lock
            begin
                @(posedge locked);
                $display("PLL locked at %t", $time);
            end
            begin
                #100000;  // 100 us timeout
                $display("ERROR: PLL failed to lock!");
                $finish;
            end
        join_any
        disable fork;

        repeat (400) @(posedge clk);

        $finish;
    end

endmodule // processor_tb
