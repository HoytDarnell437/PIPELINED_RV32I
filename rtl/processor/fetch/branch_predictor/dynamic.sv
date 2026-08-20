//------------------------------------------------------------------------------
// dynamic.sv  —  2 bit saturation counter branch predictor
//
// Author:   Hoyt Darnell
// Created:  2026-08-20
//------------------------------------------------------------------------------

module dynamic import riscv_pkg::*; #(
    localparam num_entries = 512,
    localparam addr_width = $clog2(num_entries)
    )(
    input logic clk,
    input logic rst_n,
    input logic [31:0] if_addr,
    input logic [31:0] ex_addr,
    input logic ex_is_branch,
    input logic ex_take_branch,
    output logic take_branch,
    output logic valid
);

logic [1:0] saturation_counters [num_entries - 1 : 0];
logic [num_entries - 1 : 0] valid_arr;
logic [addr_width - 1 : 0] if_addr_masked;
logic [addr_width - 1 : 0] ex_addr_masked;

always_comb begin
    if_addr_masked = if_addr[addr_width + 1 : 2];
    ex_addr_masked = ex_addr[addr_width + 1 : 2];

    take_branch = saturation_counters[if_addr_masked][1];
    valid = valid_arr[if_addr_masked];
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        valid_arr <= '0;
    end else if (ex_is_branch) begin
        valid_arr[ex_addr_masked] <= '1;
        if (ex_take_branch) begin
            if (!valid_arr[ex_addr_masked]) begin
                saturation_counters[ex_addr_masked] <= TAKEN;
            end else
                unique case (saturation_counters[ex_addr_masked])
                    STRONGLY_NOT_TAKEN: saturation_counters[ex_addr_masked] <= NOT_TAKEN;
                    NOT_TAKEN: saturation_counters[ex_addr_masked] <= TAKEN;
                    TAKEN: saturation_counters[ex_addr_masked] <= STRONGLY_TAKEN;
                    STRONGLY_TAKEN: ;
                endcase
        end else begin
            if (!valid_arr[ex_addr_masked]) begin
                saturation_counters[ex_addr_masked] <= NOT_TAKEN;
            end else
                unique case (saturation_counters[ex_addr_masked])
                    STRONGLY_NOT_TAKEN: ;
                    NOT_TAKEN: saturation_counters[ex_addr_masked] <= STRONGLY_NOT_TAKEN;
                    TAKEN: saturation_counters[ex_addr_masked] <= NOT_TAKEN;
                    STRONGLY_TAKEN: saturation_counters[ex_addr_masked] <= TAKEN;
                endcase
        end
    end
end

endmodule // dynamic
