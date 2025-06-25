ENTRY(_start)

MEMORY
{
  ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K   /* tu memoria de instrucciones */
  RAM (rw) : ORIGIN = 0x00000080, LENGTH = 1K   /* dentro de data_memory */
}

SECTIONS
{
  .text : { *(.text*) *(.rodata*) } > ROM
  .data : { *(.data*) }             > RAM
  .bss  : { *(.bss*)  *(COMMON) }   > RAM
}
