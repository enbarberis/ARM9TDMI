.global mem_init
.text             @ Directive to say that it has to be compiled in code section
mem_init:
  ldr r0, =flash_sdata
  ldr r1, =ram_sdata
  ldr r2, =data_size
  cmp r2, #0
loop:
  moveq pc, r14
  ldrb r4, [r0], #1
  strb r4, [r1], #1
  subs r2, r2, #1 
  b loop
stop:
  b stop          @ Infinite loop to stop execution 
