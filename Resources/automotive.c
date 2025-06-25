/*------------------------------------------------------------
 *  RISC-V UART
 *
 *  UART:  MMIO 0x2000_0000 (write-only para TX)
 *  Board: DE0-Nano RISC-V soft-core @ 50 MHz (para delay en loop)
 *-----------------------------------------------------------*/
#define UART_ADDR  ((volatile unsigned char *)0x20000000u)
static inline void uart_tx(char c) { *UART_ADDR = c; }

static void uart_puts(const char *s)
{
    while (*s) uart_tx(*s++);
}

static unsigned udiv(unsigned n, unsigned d)
{
    unsigned q = 0;
    while (n >= d) {
        n -= d;
        q++;
    }
    return q;
}

static unsigned umod(unsigned n, unsigned d)
{
    while (n >= d) {
        n -= d;
    }
    return n;
}

/* Transmite un entero sin signo */
static void uart_putu(unsigned v)
{
    char buf[10];
    int  i = 0;
    if (v == 0) { uart_tx('0'); return; }
    while (v) { 
        buf[i++] = '0' + umod(v, 10); 
        v = udiv(v, 10); 
    }
    while (i--) uart_tx(buf[i]);
}

static void delay_ms(unsigned ms)
{
    volatile unsigned long cycles = ms * 50000UL;
    while (cycles--) __asm__ volatile("nop");
}

void _start (void)
{
    uart_puts("\r\n*** RISC-V automotive dashboard demo ***\r\n");

    unsigned rpm   = 900;   /* idle */
    unsigned speed = 0;     /* km/h */
    unsigned temp  = 70;    /* °C */
    unsigned thr   = 2;     /* % throttle */

    for (;;)
    {
        /* -------- Actualizacion de pantalla -------- */
        uart_puts("RPM: ");   uart_putu(rpm);   uart_puts("  |  ");
        uart_puts("Speed: "); uart_putu(speed); uart_puts(" km/h  |  ");
        uart_puts("Temp: ");  uart_putu(temp);  uart_puts(" C  |  ");
        uart_puts("Throttle: "); uart_putu(thr); uart_puts(" %\r\n");

        /* -------- Dinamicas simples -------- */
        /* accelerate until 120 km/h, then decelerate back */
        if (speed < 120) { speed += 3; rpm += 120; thr = 30; }
        else             { speed -= 5; rpm -= 200; thr = 5;  }

        if (rpm < 800) rpm = 800;
        if (temp < 95) temp += 1;

        delay_ms(500);
    }
}
