@ MOV R8, R8 is used as a NOP


  .global entry_point
  .data 
val1: .word 10
val2: .byte 2
val4: .space 4
  .text
entry_point:
  bl RaW
  bl forwarding_1
  bl forwarding_2

bl arithmetic
stop:
  b stop

@ No Forwarding due to the RaW of the register file
@ N. of cycles: .... refill pipeline
RaW:
  mov r0, #4
  mov r1, #3      @ W
  mov r3, #3      @ M
  mov r8, r8      @ E
  add r2, r0, r1  @ D <-
  mov pc, r14

@ Forwarding from MEM to EXE
@ Recognised when the data dependent instruction
@ is in DEC and the other is in EXE
@ N. of cycles: .... refill pipeline
forwarding_MEM:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  mov r8, r8
  add r3, r0, r1  @ E <-  r1 is read correctly due to the RaW
  add r4, r3, r2  @ D <-  PortA forwarding
@---------------------------
  add r3, r0, r1  @ E <-
  add r4, r2, r3  @ D <-  PortB forwarding
@---------------------------
  add r3, r0, r1  @ E <-
  add r4, r3, r3  @ D <-  PortA PortB forwarding
  mov pc, r14

@ Forwarding from MEM to EXE
@ Recognised when the data dependent instruction
@ is in DEC and the other is in EXE and the
@ instruction in EXE has the priority even
@ if the instruction in the MEM has the same
@ destination register
@ N. of cycles: .... refill pipeline
forwarding_MEM_2:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  mov r3, #5
  add r5, r1, r0  @ M     r1 read correctly due to RaW
  add r5, r2, r3  @ E <-
  add r4, r5, r2  @ D <-  PortA forwarding
@---------------------------
  add r5, r1, r0  @ M
  add r5, r2, r3  @ E <-
  add r4, r2, r5  @ D <-  PortB forwarding
@---------------------------
  add r5, r1, r0  @ M
  add r5, r2, r3  @ E <-
  add r4, r5, r5  @ D <-  PortA PortB forwarding
  mov pc, r14

@ Forwarding from WB to EXE
@ Recognised when the data dependent instruction
@ is in DEC and the other is in MEM
@ N. of cycles: .... refill pipeline
forwarding_WB:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  mov r8, r8
  add r3, r0, r1  @ M <-
  sub r5, r5, r5  @ E
  add r4, r3, r2  @ D <-  PortA forwarding
@---------------------------
  add r3, r0, r1  @ M <-
  sub r5, r5, r5  @ E
  add r4, r2, r3  @ D <-  PortB forwarding
@---------------------------
  add r3, r0, r1  @ M <-
  sub r5, r5, r5  @ E
  add r4, r3, r3  @ D <-  PortA PortB forwarding
  mov pc, r14

@ Forwarding from WB to EXE, MEM to EXE
@ Recognised when the data dependent instruction
@ is in DEC and the other is in MEM and in EXE
@ N. of cycles: .... refill pipeline
forwarding_MEM_WB:
  mov r0, #4
  mov r1, #3
  mov r2, #4
  mov r3, #5
  add r4, r0, r1  @ M <-
  add r5, r2, r3  @ E <-
  add r0, r4, r5  @ D <-  PortA forwarding from WB
                  @       PortB forwarding from MEM
@---------------------------
  add r4, r0, r1  @ M <-
  add r5, r2, r3  @ E <-
  add r0, r5, r4  @ D <-  PortA forwarding from MEM
                  @       PortB forwarding from WB
  mov pc, r14


@ Forwarding from MEM to EXE
@ Due to the fact that the shift is performed
@ with a shift value that is constant
@ N. of cycles: .... refill pipeline
forwarding_MEM_3:
  mov r0, #4
  mov r1, #5
  mov r2, #3
  mov r3, #2
  add r4, r0, r1          @ E <- 
  add r5, r4, r1, lsl #2  @ D <- PortA forwarding from MEM
  mov pc, r14

@ Forwarding from MEM to EXE
@ Due to the fact that the shift is performed
@ with a shift value that is a register
@ N. of cycles: .... refill pipeline
@ ACHTUNG!!! Remember to make the first cycle of a 
@ double cycle operation like a NOP in terms of address write
forwarding_shift_MEM:
  mov r0, #1
  mov r1, #1
  mov r2, #3
  mov r3, #2
  add r4, r0, r1          @ E <-
  add r5, r1, r1, lsl r4  @ D <-
  mov pc, r14

@ Forwarding from WB to EXE
@ Due to the fact that the shift is performed
@ with a shift value that is a register the
@ instruction takes 2 cycles and so when the
@ second addition is actually performed by the ALU
@ the first is in the WB.
@ N. of cycles: .... refill pipeline
@ ACHTUNG!!! Remember to make the first cycle of a 
@ double cycle operation like a NOP in terms of address write
forwarding_shift_MEM_2:
  mov r0, #1
  mov r1, #1
  mov r2, #3
  mov r3, #2
  add r4, r0, r1          @ E <-
  add r5, r4, r1, lsl r2  @ D <- PortA forwarding from WB
  mov pc, r14

@ Forwarding from WB to EXE
@ Due to the fact that the shift is performed
@ with a shift value that is a register the
@ instruction takes 2 cycles and so when the
@ second addition is actually performed by the ALU
@ the first is in the WB.
@ N. of cycles: .... refill pipeline
@ ACHTUNG!!! Remember to make the first cycle of a 
@ double cycle operation like a NOP in terms of address write
@ HERE IS PARTICULAR IMPORTANT!!! NOTICE THE DESTINATION REGISTER
@ OF THE OPERATION WITH THE SHIFT!!!
forwarding_shift_MEM_3:
  mov r0, #1
  mov r1, #1
  mov r2, #3
  mov r3, #2
  add r4, r0, r1          @ E <-
  add r4, r4, r1, lsl r4  @ D <- PortA forwarding from MEM for the
                          @      shift operand
                          @      but from WB for the addition operand
  mov pc, r14

@ Forwarding from MEM to EXE
@ N. of cycles: .... refill pipeline
forwarding_LDR:
  adr r0, val1  @ E <-
  ldr r0, [r0]  @ D <- PortA forwarding from MEM
  mov pc, r14


@ Forwarding from WB to EXE
@ Here the add after the ldr is blocked in the
@ decode stage because 1 additional cycle is needed in
@ order to retrieve from memory the data. So the
@ forwarding path is the one from the WB of LDR (violet path)
@ N. of cycles: .... refill pipeline
forwarding_LDR_2:
  adr r0, val1
  mov r1, #2
  ldr r0, [r0]    @ E
  add r2, r1, r0  @ D
  mov pc, r14

@ Forwarding from WB to EXE
@ Here the add after the ldr occupy only 1 cycle in the
@ decode stage because when it is in the decode stage the
@ LDR is in the MEM stage and so when the ADD will be in the
@ EXE stage the LDR will be in the Write back so again
@ forwarding path is the one from the WB of LDR (violet path)
@ N. of cycles: .... refill pipeline
forwarding_LDR_3:
  adr r0, val1
  mov r1, #2
  ldr r0, [r0]    @ M
  mov r8, r8      @ E
  add r2, r1, r0  @ D
  mov pc, r14

@ Here the add after the ldr is blocked in the
@ decode stage for 2 additional cycle because no
@ forwarding is allowed due to the loaded byte!!!
@ N. of cycles: .... refill pipeline
@ ACTHUNG!!! Include this condition in the forwarding 
@ logic, just block in the decode until no dependency on
@ a instruction actually in the EXE or in the MEM can be
@ resolved!!!
forwarding_LDR_4:
  adr r0, val2
  mov r1, #2
  ldrb r0, [r0]   @ E
  add r2, r1, r0  @ D
  mov pc, r14

@ Here the add after the ldr is blocked in the
@ decode stage for 1 additional cycle because no
@ forwarding is allowed due to the loaded byte!!!
@ N. of cycles: .... refill pipeline
@ ACTHUNG!!! Include this condition in the forwarding 
@ logic, just block in the decode until no dependency on
@ a instruction actually in the EXE or in the MEM can be
@ resolved!!!
forwarding_LDR_5:
  adr r0, val2
  mov r1, #2
  ldrb r0, [r0]   @ M
  mov r8, r8      @ E
  add r2, r1, r0  @ D
  mov pc, r14

@ In case of a data dependency with the register which value
@ has to be saved into the memory: NO PROBLEM!!! because
@ the register is read during the MEM stage of the STR then
@ unavoidably the previous instruction is in the WB and being
@ the Register file implemented with a policy RaW -> NO PROBLEM.
forwarding_STR:
  adr r0, val2
  adr r1, val3
  ldr r2, [r0]
  str r2, [r1]
  mov pc, r14

@ In case of a data dependency with the register(s) used as 
@ base register / offset to compute the address for the store
@ is equivalent to a data dependancy for a data processing 
@ operation because compute the address is actually a simple
@ arithmetic operation.
forwarding_STR_2:
  adr r0, val2
  ldr r1, [r0]
  str r2, [r1]
  mov pc, r14


arithmetic:
  mov r0, #4
  mov r1, #3
  add r2, r0, r1
  sub r2, r0, r1
  mov r1, #1
  and r2, r0, r1
  orr r2, r0, r1
  eor r2, r0, r1
  bic r2, r0, r1
  bic r2, r0, r1, lsl #2
  mov pc, r14








