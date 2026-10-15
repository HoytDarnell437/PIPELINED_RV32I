//------------------------------------------------------------------------------
// instruction_cache.sv  —  Instruction Cache for RV32 processor
//
// Author:   Hoyt Darnell
// Created:  2026-10-15
//
// Description: Simple Directly mapped instruction cache implementation
//
//------------------------------------------------------------------------------

module instruction_cache #(
    localparam ADDR_WIDTH = 32, // Address width in bits
    localparam BYTE_COUNT = 16384, // Number of bytes in this cache
    localparam WORD_SIZE = 4, // Word size in bytes
    localparam WORD_COUNT = BYTE_COUNT / WORD_SIZE, // Number of words in this cache
    localparam BLOCK_SIZE = 64, // Cache line size in bytes
    localparam BLOCK_WORDS = BLOCK_SIZE / WORD_SIZE, // Cache line size in words
    localparam BLOCK_BIT_WIDTH = BLOCK_SIZE * 8, // Cache line size in bits
    localparam SET_COUNT = BYTE_COUNT / BLOCK_SIZE, // Number of sets in this cache
    localparam BLOCK_ADDR_WIDTH = ADDR_WIDTH - $clog2(BLOCK_SIZE),
    localparam INDEX_WIDTH = $clog2(SET_COUNT),
    localparam OFFSET_WIDTH = $clog2(BLOCK_SIZE),
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH
)(
    // Fetch ports
    input  logic        clk_in,
    input logic         nrst_in,
    input  logic        fetch_req_in,
    input  logic [31:0] fetch_addr_in,

    output logic        fetch_ack_out,
    output logic [31:0] fetch_instr_out,

    // Arbitrator Ports
    input  logic [BLOCK_BIT_WIDTH-1:0]  ar_line_in,
    input  logic                        ar_ack_in,
    
    output logic [BLOCK_ADDR_WIDTH-1:0] ar_addr_out,
    output logic                        ar_req_out
);

logic [BLOCK_WORDS-1:0][ADDR_WIDTH-1:0] instruction_array [0:SET_COUNT-1];
logic [TAG_WIDTH-1:0]                   tag_array [0:SET_COUNT-1];
logic                                   valid_array [0:SET_COUNT-1];

logic [TAG_WIDTH-1:0]    tag;
logic [INDEX_WIDTH-1:0]  index;
logic [OFFSET_WIDTH-3:0] word_offset;

logic cache_hit;
logic wait_on_miss;

logic [TAG_WIDTH-1:0]    reg_tag;
logic [INDEX_WIDTH-1:0]  reg_index;
logic [OFFSET_WIDTH-3:0] reg_word_offset;

always_comb begin
    tag = fetch_addr_in[ADDR_WIDTH-1:ADDR_WIDTH-TAG_WIDTH];
    index = fetch_addr_in[ADDR_WIDTH-TAG_WIDTH:OFFSET_WIDTH];
    word_offset = fetch_addr_in[OFFSET_WIDTH-1:2];

    cache_hit = valid_array[index] && (tag_array[index] == tag);
end

always_ff @(posedge clk_in) begin
    if (!nrst_in) begin
        valid_array <= '{default: 1'b0};
        fetch_ack_out <= 1'b0;
        ar_req_out <= 1'b0;
        wait_on_miss <= 1'b0;
    end else if (fetch_req_in) begin
        if (cache_hit) begin
            fetch_ack_out <= 1'b1;
            fetch_instr_out <= instruction_array[index][word_offset];
        end else if (ar_ack_in) begin
            ar_req_out <= 1'b0;
            instruction_array[index] <= ar_line_in;
            valid_array[index] <= 1'b1;
            tag_array[index] <= tag;
        end else begin
            fetch_ack_out <= 1'b0;
            ar_req_out <= 1'b1;
            ar_addr_out <= fetch_addr_in[ADDR_WIDTH-1:OFFSET_WIDTH];
        end
    end else begin
        fetch_ack_out <= 1'b0;
    end
end

endmodule // instruction_cache
