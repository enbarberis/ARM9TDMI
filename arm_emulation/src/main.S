.global _Reset
_Reset:
  mov r0, #1
  mov sp, r0, lsl #16
  bl forwarding_main 
stop:
  b stop          @ Infinite loop to stop execution 
