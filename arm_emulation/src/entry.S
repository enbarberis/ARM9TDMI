.global usr_entry_point
.text             @ Directive to say that it has to be compiled in code section
usr_entry_point:
  bl sum_vector_main
  bl forwarding_main
  bl sort_main
  bl fibo_main
stop:
  b stop          @ Infinite loop to stop execution 
