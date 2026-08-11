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
input logic [1:0] byte_addr,
input logic [1:0] mem_size,
input logic sign,
input logic [31:0] read_data_in,
input logic [31:0] write_data_in,
output logic [31:0] read_data_out,
output logic [31:0] write_data_out,
output logic [3:0] byte_en
);


always_comb begin
    case (mem_size)
        SIZE_B:
            unique case (byte_addr)
                FIRST_BYTE: byte_en = EN_FIRST_BYTE;
                SECOND_BYTE: byte_en = EN_SECOND_BYTE;
                THIRD_BYTE: byte_en = EN_THIRD_BYTE;
                FOURTH_BYTE: byte_en = EN_FOURTH_BYTE;
            endcase
        SIZE_H:
            unique case (byte_addr[1])
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
            read_data_out = { {24{sign & read_data_in[7]}} , read_data_in[7:0] };
        end
        EN_SECOND_BYTE: begin
            read_data_out = { {24{sign & read_data_in[15]}} , read_data_in[15:8] };
        end
        EN_THIRD_BYTE: begin
            read_data_out = { {24{sign & read_data_in[23]}} , read_data_in[23:16] };
        end
        EN_FOURTH_BYTE: begin
            read_data_out = { {24{sign & read_data_in[31]}} , read_data_in[31:24] };
        end
        EN_FIRST_HALF: begin
            read_data_out = { {16{sign & read_data_in[15]}} , read_data_in[15:0] };
        end
        EN_SECOND_HALF: begin
            read_data_out = { {16{sign & read_data_in[31]}} , read_data_in[31:16] };
        end
        EN_WORD: begin
            read_data_out = read_data_in;
        end
        default: begin
            read_data_out = 32'b0;
        end
    endcase
end

always_comb begin
    case (mem_size)
        SIZE_B: 
            write_data_out = { 4{write_data_in[7:0]} };
        SIZE_H:
            write_data_out = { 2{write_data_in[15:0]} };
        SIZE_W:
            write_data_out = write_data_in;
        default:
            write_data_out = 32'b0;
    endcase
end

endmodule // load_store_unit
