.global forwarding_2
.text
forwarding_2:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  add r3, r0, r1
  sub r5, r5, r5
  add r0, r3, r2
stop:
  b stop
