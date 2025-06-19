`timescale 1ns/1ps // 1ns time unit, 1ps time precision

module cpu_testbench;

    reg clk;       // Señal de reloj
    reg reset;     // Señal de reset

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
        $readmemh("program.mem", uut.imem.memory); // instrucciones
        $readmemh("data.mem", uut.dmem.memory);     // datos iniciales

        reset = 1;
        #20;
        reset = 0;

        // Simular durante cierto tiempo
        #500;

        // Mostrar contenido de registros
        $display("===== REGISTROS ====");
        for (int i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d", i, uut.rf.registers[i]);
        end

        // Mostrar contenido de memoria
        $display("===== MEMORIA DE DATOS ====");
        for (int i = 0; i < 16; i = i + 1) begin
            $display("mem[%0d] = %0d", i*4, uut.dmem.memory[i]);
        end

        $finish;
    end
endmodule
