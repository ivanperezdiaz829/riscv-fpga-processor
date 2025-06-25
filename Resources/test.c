// =========================================================
// UART mapeada a 0x2000_0000. 8N1, 115200 Bd.
// Se asume que basta escribir un byte para transmitirlo.
// ==========================================================

#define UART_ADDR  ((volatile unsigned char *)0x20000000u)

/* Enviar un carácter */
static void uart_write_char(char c)
{
    *UART_ADDR = c;
    /* si tu UART necesita esperar a ready, aquí pondrás un bucle */
}

/* Enviar un string C */
static void uart_write_str(const char *p)
{
    while (*p) uart_write_char(*p++);
}

/* Punto de entrada que el linker usará con -Wl,-e,_start */
void _start(void)
{
    uart_write_str("\r\n*** Hola desde mi CPU RISC-V! ***\r\n");
    uart_write_str("UART OK.\r\n");
    while (1);                 /* loop infinito */
}
