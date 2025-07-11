`timescale 1ns/1ns

module uart_automotive;

    integer rpm, speed, temp, thr;
    integer i;

    // Simula delay usando #delay
    task delay_ms(input integer ms);
        integer j;
        begin
            for (j = 0; j < ms * 50000; j = j + 1)
                #20;
        end
    endtask

    initial begin
        $display("\n*** RISC-V automotive dashboard demo ***\n");
        $display(" RPM  |  Speed (km/h)  |  Temp (C)  |  Throttle (%%)");
        $display("---------------------------------------------------");

        rpm   = 900;
        speed = 0;
        temp  = 70;
        thr   = 2;

        for (i = 0; i < 70; i = i + 1) begin
            $display("%4d  |     %3d        |    %3d     |     %3d", rpm, speed, temp, thr);

            if (speed < 120) begin
                rpm   = rpm + 120;
                speed = speed + 3;
                thr   = 30;
                temp  = (temp < 95) ? temp + 1 : temp;
            end else begin
                rpm   = rpm - 200;
                speed = speed - 5;
                thr   = 5;
                temp  = 95;
            end

            if (rpm < 800) rpm = 800;
            if (speed < 0) speed = 0;

            delay_ms(25);  // delay simulado (equivale a 5 ms)
        end
        $finish;
    end
endmodule
