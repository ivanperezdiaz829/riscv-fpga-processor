`timescale 1ns/1ns

module uart_perceptron_sim;

    integer x1, x2, sum, out;
    integer v, digit, i;
    integer digits [0:9];
    integer ndigits;

    // Tarea para imprimir un entero positivo sin signo
    task uart_putu(input integer val);
        begin
            if (val == 0) begin
                $write("0");
            end else begin
                // Extraemos dígitos, guardándolos en el arreglo digits
                ndigits = 0;
                v = val;
                while (v > 0) begin
                    digits[ndigits] = v % 10;
                    v = v / 10;
                    ndigits = ndigits + 1;
                end
                // Imprimir dígitos en orden inverso
                for (i = ndigits - 1; i >= 0; i = i - 1) begin
                    $write("%0d", digits[i]);
                end
            end
        end
    endtask

    task uart_puts_1; begin $write("\n*** RISC-V simple perceptron demo ***\n"); end endtask
    task uart_puts_2; begin $write("x1 x2 | weighted_sum | output\n"); end endtask

    task uart_puts_space(input integer n);
        integer j;
        begin
            for (j = 0; j < n; j = j + 1) $write(" ");
        end
    endtask

    // Delay aproximado (en simulación puede ser sólo un # delay)
    task delay_ms(input integer ms);
        integer j;
        begin
            for (j = 0; j < ms*50000; j = j + 1) #20;
        end
    endtask

    function integer perceptron(input integer in_x1, in_x2);
        integer s;
        begin
            s = 2*in_x1 + (-3)*in_x2 + 1;
            perceptron = (s > 0) ? 1 : 0;
        end
    endfunction

    initial begin
        uart_puts_1();
        uart_puts_2();

        for (x1 = 0; x1 <= 1; x1 = x1 + 1) begin
            for (x2 = 0; x2 <= 1; x2 = x2 + 1) begin
                sum = 2 * x1 + (-3) * x2 + 1;
                out = perceptron(x1, x2);

                uart_putu(x1);
                uart_puts_space(2);
                uart_putu(x2);
                uart_puts_space(2);
                $write("|      ");
                uart_putu((sum < 0) ? 0 : sum);
                uart_puts_space(7);
                $write("|   ");
                uart_putu(out);
                $write("\n");

                delay_ms(3);
            end
        end
        $finish;
    end
endmodule
