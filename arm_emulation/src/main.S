.global _Reset
_Reset:
mov sp, #65536
stop:
  b stop          @ Infinite loop to stop execution 
