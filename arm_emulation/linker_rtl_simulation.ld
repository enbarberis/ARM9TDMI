ENTRY(_Reset)
SECTIONS
{
   . = 0x00000;
  .text : { obj/main.o(_Reset) *(.text) }
}
