  .data
vector: .word 1,2,3,4,5,6
result: .word
  .global sum_vector_main
  .text
@ N. of cycles: .... refill pipeline
sum_vector_main:
  eor r1, r1, r1  @ init accumulator to 0
  ldr r0, =vector @ start address vector
  mov r2, #6
  add r2, r0, r2, lsl #2
start:
  ldr r3, [r0], #4
  ldr r4, [r0], #4
  add r1, r3, r1
  add r1, r4, r1
  cmp r0, r2
  bne start
  ldr r0, =result
  str r1, [r0]
  mov pc, r14
stop:
  b stop


