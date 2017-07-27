.global fibo_main
.data 
result: .word
.text
fibo_main:
  mov r0, #5
  bl fibo
  ldr r1, =result
  str r0, [r1]
  b .

@ on r0 the parameter
fibo:
  cmp r0, #1
  moveq r0, #1
  moveq pc, r14
  cmp r0, #2
  moveq r0, #1
  moveq pc, r14
  stmia r13!, {r0,r14}
  sub r0, r0, #1
  bl fibo
  mov r1, r0 
  ldmdb r13!, {r0,r14}
  sub r0, r0, #2
  stmia r13!, {r0,r1,r14}
  bl fibo
  mov r2, r0
  ldmdb r13!, {r0,r1,r14}
  add r0, r1, r2
  mov pc, r14











