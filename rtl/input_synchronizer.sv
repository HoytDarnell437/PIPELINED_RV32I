//------------------------------------------------------------------------------
// input_synchronizer.sv  —  Two Flop input synchronizer for RV32 processor peripherals
//
// Author:   Hoyt Darnell
// Created:  2026-10-18
//
//------------------------------------------------------------------------------

module input_synchronizer (
    input  logic       clk_i,
    input  logic       nrst_i,
    input  logic [3:0] buttons_i,
    input  logic [3:0] switches_i,
    (* ASYNC_REG = "TRUE" *) output logic [3:0] synchronized_buttons_o,
    (* ASYNC_REG = "TRUE" *) output logic [3:0] synchronized_switches_o
);

(* ASYNC_REG = "TRUE" *) logic [3:0] r_mid_buttons;
(* ASYNC_REG = "TRUE" *) logic [3:0] r_mid_switches;

always_ff @(posedge clk_i) begin
    if (!nrst_i) begin
        r_mid_buttons <= 'b0;
        r_mid_switches <= 'b0;
        synchronized_buttons_o <= 'b0;
        synchronized_switches_o <= 'b0;
    end else begin
        r_mid_buttons <= buttons_i;
        r_mid_switches <= switches_i;
        synchronized_buttons_o <= r_mid_buttons;
        synchronized_switches_o <= r_mid_switches;
    end
end
endmodule // input_synchronizer