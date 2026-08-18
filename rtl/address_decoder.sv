//------------------------------------------------------------------------------
// address_decoder.sv
//
// Author:   Hoyt Darnell
// Created:  2026-08-02
//
// Description:
//   Using a provided address routes read or write to proper peripheral.
//
//------------------------------------------------------------------------------

module address_decoder import riscv_pkg::*; (
input logic [29:0] address,
output logic [2:0] peripheral_sel
);

always_comb begin
    peripheral_sel = 2'b0;

    // requirement for non-memory access bit 31 must be 1
    if (!address[29]) begin
        peripheral_sel = ACCESS_DATA_MEMORY;
    end else
        unique case (address[2:0])
            SEL_SWITCHES: peripheral_sel = ACCESS_SWITCHES;
            SEL_BUTTONS: peripheral_sel = ACCESS_BUTTONS;
            SEL_LEDS: peripheral_sel = ACCESS_LEDS;
            SEL_JA: peripheral_sel = ACCESS_JA;
            SEL_JB: peripheral_sel = ACCESS_JB;
            SEL_JC: peripheral_sel = ACCESS_JC;
            SEL_JD: peripheral_sel = ACCESS_JD;
        endcase

end

endmodule // address_decoder
