//------------------------------------------------------------------------------
// dynamic.sv  —  2 bit saturation counter branch predictor
//
// Author:   Hoyt Darnell
// Created:  2026-08-20
//------------------------------------------------------------------------------

module dynamic import riscv_pkg::*; #(
    localparam NUM_ENTRIES = 512,
    localparam ADDR_WIDTH = $clog2(NUM_ENTRIES)
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] if_addr,
    input  logic [31:0] ex_addr,
    input  logic        ex_is_branch,
    input  logic        ex_take_branch,
    output logic        take_branch,
    output logic        valid
);

logic [1:0]                 saturation_counters [NUM_ENTRIES - 1 : 0];
logic [NUM_ENTRIES - 1 : 0] valid_arr;
logic [ADDR_WIDTH - 1 : 0]  if_addr_masked;
logic [ADDR_WIDTH - 1 : 0]  ex_addr_masked;

assign if_addr_masked = if_addr[ADDR_WIDTH + 1 : 2];
assign ex_addr_masked = ex_addr[ADDR_WIDTH + 1 : 2];
assign take_branch = saturation_counters[if_addr_masked][1];
assign valid = valid_arr[if_addr_masked];

always_ff @(posedge clk) begin
    if (!rst_n) begin
        valid_arr <= '0;
    end else if (ex_is_branch) begin
        valid_arr[ex_addr_masked] <= '1;
        if (ex_take_branch) begin
            if (!valid_arr[ex_addr_masked]) begin
                saturation_counters[ex_addr_masked] <= TAKEN;
            end else begin
                unique case (saturation_counters[ex_addr_masked])
                    STRONGLY_NOT_TAKEN: saturation_counters[ex_addr_masked] <= NOT_TAKEN;
                    NOT_TAKEN: saturation_counters[ex_addr_masked] <= TAKEN;
                    TAKEN: saturation_counters[ex_addr_masked] <= STRONGLY_TAKEN;
                    STRONGLY_TAKEN:;
                endcase
            end
        end else begin
            if (!valid_arr[ex_addr_masked]) begin
                saturation_counters[ex_addr_masked] <= NOT_TAKEN;
            end else begin
                unique case (saturation_counters[ex_addr_masked])
                    STRONGLY_NOT_TAKEN:;
                    NOT_TAKEN: saturation_counters[ex_addr_masked] <= STRONGLY_NOT_TAKEN;
                    TAKEN: saturation_counters[ex_addr_masked] <= NOT_TAKEN;
                    STRONGLY_TAKEN: saturation_counters[ex_addr_masked] <= TAKEN;
                endcase
            end
        end
    end
end

endmodule // dynamic
