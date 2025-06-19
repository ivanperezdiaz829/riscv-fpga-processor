# Project compilation
iverilog -o cpu_testbench.out cpu_testbench.v cpu.v

# Simulate
vvp cpu_testbench.out

# Look Waves (using $dumpfile)
gtkwave waveform.vcd
