// ==========================================================
// RISC-V UART
// UART:  MMIO 0x2000_0000 (write-only para TX)
// Board: DE0-Nano RISC-V soft-core @ 50 MHz (para delay en loop)
// ==========================================================
#define UART_ADDR  ((volatile unsigned char *)0x20000000u)
static inline void uart_tx(char c) { *UART_ADDR = c; }

static void uart_puts(const char *s) {
    while (*s) uart_tx(*s++);
}

static unsigned udiv(unsigned n, unsigned d) {
    unsigned q = 0;
    while (n >= d) {
        n -= d;
        q++;
    }
    return q;
}

static unsigned umod(unsigned n, unsigned d) {
    while (n >= d) {
        n -= d;
    }
    return n;
}

// Transmite un entero sin signo
static void uart_putu(unsigned v) {
    char buf[10];
    int  i = 0;
    if (v == 0) { uart_tx('0'); return; }
    while (v) { 
        buf[i++] = '0' + umod(v, 10); 
        v = udiv(v, 10); 
    }
    while (i--) uart_tx(buf[i]);
}

static void delay_ms(unsigned ms) {
    volatile unsigned long cycles = ms * 50000UL;
    while (cycles--) __asm__ volatile("nop");
}

// Perceptrón (neurona) simple con 2 entradas binarias y pesos fijos
static int perceptron(int x1, int x2) {
    // pesos (w1=2, w2=-3), bias=1
    int sum = 2 * x1 + (-3) * x2 + 1;
    return (sum > 0) ? 1 : 0;
}

void _start (void) {
    uart_puts("\r\n*** RISC-V simple perceptron demo ***\r\n");
    uart_puts("x1 x2 | weighted_sum | output\r\n");

    for (int x1 = 0; x1 <= 1; x1++) {
        for (int x2 = 0; x2 <= 1; x2++) {
            int sum = 2 * x1 + (-3) * x2 + 1;
            int out = perceptron(x1, x2);

            // Mostrar valores
            uart_putu(x1); uart_puts("  ");
            uart_putu(x2); uart_puts("  |      ");
            uart_putu(sum < 0 ? 0 : sum); uart_puts("       |   ");
            uart_putu(out);
            uart_puts("\r\n");
            delay_ms(500);
        }
    }
    while(1) __asm__ volatile("wfi");  // Wait for interrupt (sleep)
}
