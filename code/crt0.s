# Startup script for C-compiler

.section .text.start
.global _start
.extern main
.extern __stack_top
.extern __bss_start
.extern __bss_end

_start:
    .cfi_startproc

    la sp, __stack_top # set stack pointer
    andi sp, sp, -16 # RISC-V ABI stack alignment

    # Zero unitialized globals/statics
    la t0, __bss_start
    la t1, __bss_end
    li t2, 0

.Lzero_bss:
    bgeu t0, t1, .Lbss_done
    sw t2, 0(t0)
    addi t0, t0, 4
    j .Lzero_bss

.Lbss_done:
    jal ra, main # jump to main c function

_exit:
    j _exit
    .cfi_endproc