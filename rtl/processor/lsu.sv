//------------------------------------------------------------------------------
// load_store_unit.sv
//
// Author:   Hoyt Darnell
// Created:  2026-08-03
//
// Description:
//   Takes in the lower two bits of the address and the size of the memory
//   transaction to produce a byte enable signal. This unit is also reponsible
//   for extending half and byte writes.
//
//------------------------------------------------------------------------------

module lsu import riscv_pkg::*; (
input logic ex_mem_stall,
input logic [31:0] ex_addr,
input logic [31:0] mem_addr,
input logic rd,
input logic wr,
input logic [1:0] mem_size,
input logic [31:0] wr_data_in,
input logic sign,
output logic [31:0] rd_data_out,
mmio_bus_if.master bus,
output logic mem_ready
);

logic [3:0] byte_en;

always_comb begin
    bus.en = ~ex_mem_stall;
    bus.wr_addr = mem_addr;
    bus.wr = wr;
    bus.byte_en = byte_en;
    bus.rd_addr = ex_addr;
    bus.rd = rd;
    mem_ready = bus.ready;
end

// Read
always_comb begin
    case (mem_size)
        SIZE_B:
            unique case (mem_addr[1:0])
                FIRST_BYTE: byte_en = EN_FIRST_BYTE;
                SECOND_BYTE: byte_en = EN_SECOND_BYTE;
                THIRD_BYTE: byte_en = EN_THIRD_BYTE;
                FOURTH_BYTE: byte_en = EN_FOURTH_BYTE;
            endcase
        SIZE_H:
            unique case (mem_addr[1])
                FIRST_HALF: byte_en = EN_FIRST_HALF;
                SECOND_HALF: byte_en = EN_SECOND_HALF;
            endcase
        SIZE_W:
            byte_en = EN_WORD;
        default:
            byte_en = 4'b0000;
    endcase
end

always_comb begin
    case (byte_en)
        EN_FIRST_BYTE: begin
            rd_data_out = { {24{sign & bus.rd_data[7]}} , bus.rd_data[7:0] };
        end
        EN_SECOND_BYTE: begin
            rd_data_out = { {24{sign & bus.rd_data[15]}} , bus.rd_data[15:8] };
        end
        EN_THIRD_BYTE: begin
            rd_data_out = { {24{sign & bus.rd_data[23]}} , bus.rd_data[23:16] };
        end
        EN_FOURTH_BYTE: begin
            rd_data_out = { {24{sign & bus.rd_data[31]}} , bus.rd_data[31:24] };
        end
        EN_FIRST_HALF: begin
            rd_data_out = { {16{sign & bus.rd_data[15]}} , bus.rd_data[15:0] };
        end
        EN_SECOND_HALF: begin
            rd_data_out = { {16{sign & bus.rd_data[31]}} , bus.rd_data[31:16] };
        end
        EN_WORD: begin
            rd_data_out = bus.rd_data;
        end
        default: begin
            rd_data_out = 32'b0;
        end
    endcase
end

// Write
always_comb begin
    case (mem_size)
        SIZE_B: 
            bus.wr_data = { 4{wr_data_in[7:0]} };
        SIZE_H:
            bus.wr_data = { 2{wr_data_in[15:0]} };
        SIZE_W:
            bus.wr_data = wr_data_in;
        default:
            bus.wr_data = 32'b0;
    endcase
end

endmodule // load_store_unit
