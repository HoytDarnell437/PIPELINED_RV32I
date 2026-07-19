# Description: Program designed for custom RV32 cpu.

.equ PERIPHERALS, 0x80000000 # MMIO Base Address
.equ SWITCHES, 0x80000000
.equ BUTTONS, 0x80000004
.equ LEDS, 0x80000008

.text

    li t0, PERIPHERALS

loop:

    lw t1, 4(t0) # t1 = buttons
    andi t2, t1, 0x001 # t1 &= 0001
    beq t2, x0, skip_save # if (buttons[0] == 0) => skip_save
    lw t2, 0(t0) # t1 = switches
    sw t2, 0(x0) # address[0] = switches

skip_save:

    andi t2, t1, 0x002 # t1 &= 0010
    beq t2, x0, skip_load # if (buttons[1] == 0) => skip_load
    lw t2, 0(x0) # t2 = address[0]
    sw t2, 8(t0) # LEDS = address[0]

skip_load:

    andi t2, t1, 0x004 # t1 &= 0100
    beq t2, x0, skip_set # if (buttons[2] == 0) => skip_set
    lw t2, 0(t0) # t1 = switches
    sw t2, 8(t0) # LEDS = switches

skip_set:

    j loop
