`timescale 1ns/1ps // 1ns time unit, 1ps time precision

module cpu_testbench;

    reg clk;       // Señal de reloj
    reg reset;     // Señal de reset

    integer i;     // Contador para bucles

    // Instancia de la CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Generar el reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Reloj con periodo de 10ns
    end

    // Inicialización de señales y estímulo
    initial begin
        $display("Inicio de simulación");

        // Inicializar memoria con instrucciones de prueba
        $readmemh("test/program.mem", uut.imem.memory); // instrucciones
        $readmemh("test/data.mem", uut.dmem.memory);    // datos iniciales

        reset = 1;
        #20;
        reset = 0;

        // Simular durante cierto tiempo
        #500;

        // Mostrar contenido de registros
        $display("===== REGISTROS ====");
        uut.rf.print_registers();

        // Mostrar contenido de memoria
        $display("===== MEMORIA DE DATOS ====");
        uut.dmem.print_memory();

        $finish;
    end
endmodule
