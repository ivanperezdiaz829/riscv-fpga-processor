`timescale 1ns/1ps // 1ns time unit, 1ps time precision

module cpu_testbench {
    reg clk = 0;        // Reloj inicializado a 0
    reg reset = 1;      // Reset activado inicialmente
};

    // Instancia del procesador
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Generador del reloj: periodo de 10 ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Configuración para la simulación
        $dumpfile("sim/waveform.vcd");      // Archivo de volcado de señales
        $dumpvars(0, cpu_testbench);        // Dump de todas las señales del módulo

        // Secuencia de simulación
        #10 reset = 0;        // Desactivar reset después de 10 ns
        #100 finish;          // Terminar la simulación tras 100 ns
    end
endmodule