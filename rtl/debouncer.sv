//------------------------------------------------------------------------------
// debouncer.sv  —  Debouncer for RV32 processor button peripherals
//
// Author:   Hoyt Darnell
// Created:  2026-10-16
//
//------------------------------------------------------------------------------

module debouncer #(
    localparam int SAMPLE_PERIOD_CYCLES = 100_000,
    localparam int ENABLE_COUNT_WIDTH   = $clog2(SAMPLE_PERIOD_CYCLES),
    localparam int STABLE_SAMPLES       = 16,
    localparam int COUNT_WIDTH          = $clog2(STABLE_SAMPLES)
) (
    input  logic       clk_i,
    input  logic       nrst_i,
    input  logic [3:0] buttons_i,
    output logic [3:0] debounced_buttons_o
);

logic [COUNT_WIDTH-1:0] counter_array [3:0];
logic [3:0]             prev_buttons;
logic                   sample_enable;

logic [ENABLE_COUNT_WIDTH-1:0] enable_counter;

always_ff @(posedge clk_i) begin
    if (!nrst_i) begin
        enable_counter <= 'b0;
        sample_enable <= 'b0;
    end else begin
        if (enable_counter == SAMPLE_PERIOD_CYCLES - 1) begin
            enable_counter <= 'b0;
            sample_enable <= 'b1;
        end else begin
            enable_counter <= enable_counter + 1'b1;
            sample_enable <= 'b0;
        end
    end
end

always_ff @(posedge clk_i) begin
    if (!nrst_i) begin
        counter_array <= '{default: 'b0};
        prev_buttons <= 'b0;
        debounced_buttons_o <= 'b0;
    end else if (sample_enable) begin
        for (int i = 0; i < 4; i++) begin
            if ((buttons_i[i] == prev_buttons[i]) && (buttons_i[i] != debounced_buttons_o[i])) begin
                counter_array[i] <= counter_array[i] + 1'b1;
            end else begin
                counter_array[i] <= 'b0;
            end
            debounced_buttons_o[i] <= (counter_array[i] == STABLE_SAMPLES - 1) ? buttons_i[i] : debounced_buttons_o[i];
        end
        prev_buttons <= buttons_i;
    end
end

endmodule // debouncer