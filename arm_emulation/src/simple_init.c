volatile unsigned int* const UART0 = (unsigned int*)0x0101F1000;

static void uart_print(const char *s)
{
  while(*s != '\0') {
    *UART0 = (unsigned int)(*s); /* send to UART */
    s++;
  }
}

/* Main entry point */
void simple_init()
{
  uart_print("Welcome to Simple bare-metal program\n\0");
  uart_print("If you're running in QEMU, press Ctrl+a\n\0");
  uart_print("and then x to stop me...\n\0");
}
