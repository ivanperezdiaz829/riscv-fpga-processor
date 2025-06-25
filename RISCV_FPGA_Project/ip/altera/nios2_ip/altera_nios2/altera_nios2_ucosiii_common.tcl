
#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/alt_busy_sleep.c
add_sw_property c_source HAL/src/alt_irq_vars.c
add_sw_property c_source HAL/src/alt_icache_flush.c
add_sw_property c_source HAL/src/alt_icache_flush_all.c
add_sw_property c_source HAL/src/alt_dcache_flush.c
add_sw_property c_source HAL/src/alt_dcache_flush_all.c
add_sw_property c_source HAL/src/alt_dcache_flush_no_writeback.c
add_sw_property c_source HAL/src/alt_ecc_fatal_exception.c
add_sw_property c_source HAL/src/alt_instruction_exception_entry.c
add_sw_property c_source HAL/src/alt_irq_register.c
add_sw_property c_source HAL/src/alt_iic.c
add_sw_property c_source HAL/src/alt_remap_cached.c
add_sw_property c_source HAL/src/alt_remap_uncached.c
add_sw_property c_source HAL/src/alt_uncached_free.c
add_sw_property c_source HAL/src/alt_uncached_malloc.c
add_sw_property c_source HAL/src/alt_do_ctors.c
add_sw_property c_source HAL/src/alt_do_dtors.c
add_sw_property c_source HAL/src/alt_gmon.c
add_sw_property c_source HAL/src/altera_nios2_qsys_irq.c

# uC/OS-III-specific C sources
add_sw_property c_source UCOSIII/src/alt_usleep.c
add_sw_property c_source UCOSIII/src/os_cpu_c.c

# Include files
add_sw_property include_source HAL/inc/alt_types.h
add_sw_property include_source HAL/inc/altera_nios2_qsys_irq.h
add_sw_property include_source HAL/inc/io.h
add_sw_property include_source HAL/inc/nios2.h
add_sw_property include_source HAL/inc/priv/alt_busy_sleep.h
add_sw_property include_source HAL/inc/priv/alt_legacy_irq.h
add_sw_property include_source HAL/inc/priv/nios2_gmon_data.h
add_sw_property include_source HAL/inc/sys/alt_debug.h
add_sw_property include_source HAL/inc/sys/alt_exceptions.h
add_sw_property include_source HAL/inc/sys/alt_irq_entry.h
add_sw_property include_source HAL/inc/sys/alt_irq.h
add_sw_property include_source HAL/inc/sys/alt_sim.h
add_sw_property include_source HAL/inc/sys/alt_stack.h
add_sw_property include_source HAL/inc/sys/alt_warning.h

# uC/OS-III-specific includes
add_sw_property include_source UCOSIII/inc/includes.h
add_sw_property include_source UCOSIII/inc/app_cfg.h
add_sw_property include_source UCOSIII/inc/os_cpu.h

# Assembly source files
add_sw_property asm_source HAL/src/alt_ecc_fatal_entry.S
add_sw_property asm_source HAL/src/alt_exception_entry.S
add_sw_property asm_source HAL/src/alt_exception_trap.S
add_sw_property asm_source HAL/src/alt_exception_muldiv.S
add_sw_property asm_source HAL/src/alt_irq_entry.S
add_sw_property asm_source HAL/src/alt_software_exception.S
add_sw_property asm_source HAL/src/alt_mcount.S
add_sw_property asm_source HAL/src/alt_log_macro.S
add_sw_property asm_source HAL/src/crt0.S

# uC/OS-II-specific ASM sources
add_sw_property asm_source UCOSIII/src/os_cpu_a.S

# End of file

