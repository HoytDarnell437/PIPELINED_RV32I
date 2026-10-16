ENTRY(_start)

MEMORY {
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS {
  .text : { 
    *(.text.start) 
    *(.text .text.*) 
    *(.rodata .rodata.*)
  } > ROM

  .data : {
     *(.data .data.*) 
  } > RAM

  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    __bss_end = .;
  } > RAM

  __stack_top = ORIGIN(RAM) + LENGTH(RAM);

  ASSERT(__bss_end <= __stack_top,
         "RAM overflow: sections collide with stack")
}