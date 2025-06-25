#
# uC/OS-II driver source file listings...
#

# uC/OS-II-specific C sources
add_sw_property c_source UCOSII/src/alt_usleep.c
add_sw_property c_source UCOSII/src/os_cpu_c.c

# uC/OS-II-specific includes
add_sw_property include_source UCOSII/inc/includes.h
add_sw_property include_source UCOSII/inc/os_cpu.h

# uC/OS-II-specific ASM sources
add_sw_property asm_source UCOSII/src/os_cpu_a.S

# End of file
