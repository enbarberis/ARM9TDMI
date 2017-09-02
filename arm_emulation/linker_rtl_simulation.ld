ENTRY(_Reset)
SECTIONS
{
   . = 0x00000;
  .text : { obj/startup.o(_Reset) *(.text) }
  flash_sdata = .;
  . = 0xA0000000;
  ram_sdata = .;
  .data : AT(flash_sdata) { *(.data) }
  ram_edata = .;
  data_size = ram_edata - ram_sdata;
  .bss : { *(.bss) }
  . = . + 0x1000; /* move by 4kbyte (our stack memory) */
  stack_top = .;
}
