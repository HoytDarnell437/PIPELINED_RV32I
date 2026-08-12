//------------------------------------------------------------------------------
// data_memory.sv  —  Data memory for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-07-30
//
// Timing: Read and write are synchonous
//------------------------------------------------------------------------------

module data_memory #(
localparam MEM_SIZE = 128,
localparam ADDR_WIDTH = $clog2(MEM_SIZE)
)(
input logic clk,
input logic rst_n,
input logic wr,
input logic rd,
input logic [3:0] byte_en,
input logic [31:0] wr_data,
input logic [29:0] addr,
output logic [31:0] rd_data,
output logic ready
);

// -- signal declaration --
logic [31:0] ram [0 : MEM_SIZE - 1];
logic [ADDR_WIDTH - 1 : 0] masked_addr;

typedef enum logic {
    IDLE,
    ACK
} state_t;

state_t state;

// -- initialize memory --
initial begin
    $readmemh("data.hex", ram);
end

assign masked_addr = addr[ADDR_WIDTH - 1 : 0];

always_ff @(posedge clk) begin
    if (rd) begin
        rd_data <= ram[masked_addr];
    end else if (wr) begin
        if (byte_en[0]) ram[masked_addr][7:0] <= wr_data[7:0];
        if (byte_en[1]) ram[masked_addr][15:8] <= wr_data[15:8];
        if (byte_en[2]) ram[masked_addr][23:16] <= wr_data[23:16];
        if (byte_en[3]) ram[masked_addr][31:24] <= wr_data[31:24];
    end
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        ready <= '0;
    end else begin
        unique case (state)
            IDLE: begin
                if (rd || wr) begin
                    state <= ACK;
                    ready <= 1'b1;
                end else begin
                    ready <= 1'b0;
                end
            end

            ACK: begin
                ready <= 1'b0;
                state <= IDLE;
            end
        endcase
    end
end

endmodule // data_memory
