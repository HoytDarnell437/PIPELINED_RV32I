//------------------------------------------------------------------------------
// sync_reset.sv  —  Converts asynchronous reset to synchronous
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Asserts rst_n asynchronously after invert_rst is asserted and
// deasserts rst_n synchronously with the system clock.
//------------------------------------------------------------------------------
module sync_reset (
input logic clk,
input logic invert_rst,
input logic locked,
output logic rst_n
);

logic rst_sync;
logic async_rst_n;

assign async_rst_n = invert_rst && locked;

always_ff @(posedge clk or negedge async_rst_n) begin
    if (!async_rst_n) begin
        rst_sync <= 1'b0;
        rst_n <= 1'b0;
    end else begin
        rst_sync <= 1'b1;
        rst_n <= rst_sync;
    end
end

endmodule // sync_reset
