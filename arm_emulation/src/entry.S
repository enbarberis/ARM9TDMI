.global sum_2
.text             @ Directive to say that it has to be compiled in code section
sum_2:
  mov r0,#5
  mov r1,#4
  add r2, r1, r0
stop:
  b stop          @ Infinite loop to stop execution 
