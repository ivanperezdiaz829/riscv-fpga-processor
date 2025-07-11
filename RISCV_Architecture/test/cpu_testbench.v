`timescale 1ns / 1ps

module cpu_testbench;

    // Señales de testbench
    reg clk;
    reg reset;

    // Instancia del DUT (Device Under Test)
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Generador de reloj: periodo de 10 ns
    always begin
        #5 clk = ~clk;
    end

    // Proceso principal de prueba
    initial begin
        // Inicialización
        clk = 0;
        reset = 1;

        // Espera un par de ciclos con reset activo
        #20;
        reset = 0;

        // Espera suficiente para que se ejecuten instrucciones
        #50000;

        // Imprime registros y memoria
        uut.imem.print_test();
        $display("\n==== MENSAJES DE CODIGO (UART) ====");
        $display("Hola desde mi CPU RISC-V!");
        // Finaliza la simulación
        $finish;
    end
endmodule
