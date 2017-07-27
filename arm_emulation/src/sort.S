  .data
vector: .word 1,3,4,0,-2,-3
  .global sort_main
  .text
sort_main:
  ldr   r0, =flash_sdata
  ldr   r1, =ram_sdata
  ldr   r2, =data_size
copy:
  ldrb  r4, [r0], #1
  strb  r4, [r1], #1
  subs  r2, r2, #1
  bne   copy
  ldr r0, =vector
  mov r1, #6
  add r1, r0, r1, lsl #2
ext_loop:
  mov r2, r0
int_loop:
    ldr r3, [r2]
    ldr r4, [r2,#4]!
    cmp r3, r4
    strgt r4, [r2,#-4]
    strgt r3, [r2]
    cmp r2, r1
    blt int_loop
  sub r1, r1, #4
  cmp r0, r1
  bls ext_loop


