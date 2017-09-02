.global _Reset 
_Reset:
  B Reset_Handler /* Reset handler */
  B Undefined /* Undefined mode handler */
  B SWI_handler /* Software interrupt */
  B Prfetch_Abort /* Prefetch abort handler */
  B Data_Abort /* Data abort handler */
  B IRQ_Handler /* IRQ handler */
  B FIQ_Handler /* FIQ handler */

Reset_Handler:
  bl mem_init
  mov r0, #208  /*  Set USER mode but with
                    IF and FF set in order to
                    disable
                */
  msr CPSR_c, R0
  b usr_entry_point
  B .
Undefined: /* do nothing */
  B .
SWI_handler: /* do nothing */
  B .
Prfetch_Abort: /* do nothing */
  B .
Data_Abort: /* do nothing */
  B .
IRQ_Handler: /* do nothing */
  B .
FIQ_Handler: /* do nothing */
  B .
