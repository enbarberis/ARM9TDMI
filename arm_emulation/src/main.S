.global main
.text             @ Directive to say that it has to be compiled in code section
mov sp, #65536
stop:
  b stop          @ Infinite loop to stop execution 
