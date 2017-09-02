.global forwarding_1
.text
forwarding_1:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  add r3, r0, r1
  add r0, r3, r2
stop:
  b stop
