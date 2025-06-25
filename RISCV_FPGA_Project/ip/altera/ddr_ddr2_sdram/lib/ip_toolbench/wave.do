onerror {resume}
quietly WaveActivateNextPane {} 0

virtual type { LMR ARF PCH ACT WR RD BT NOP} CmdType
quietly set wcmd "virtual function -install /${testbench_name}/dut/ { (CmdType)&{/${testbench_name}/dut/${pin_prefix}ras_n, /${testbench_name}/dut/${pin_prefix}cas_n, /${testbench_name}/dut/${pin_prefix}we_n}} Command"
quietly eval $wcmd
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/clock_source
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/clk_to_sdram
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/clk_to_sdram_n
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/reset_n
add wave -noupdate -divider {Test Logic}
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/test_complete
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/pnf_per_byte
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/pnf
add wave -noupdate -divider {DDR SDRAM I/F}
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}cke
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}cs_n
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}ras_n
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}cas_n
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}we_n
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/Command
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}ba
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}a
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}dq
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}dqs
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}dm
add wave -noupdate -divider {Local I/F}
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/clk
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/write_clk
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/resynch_clk
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_addr
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_col_addr
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_cs_addr
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_wdata
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_rdata
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_be
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_read_req
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_write_req
add wave -noupdate -format Literal -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_size
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_ready
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_rdata_valid
add wave -noupdate -format Logic -radix hexadecimal /${testbench_name}/dut/${pin_prefix}local_wdata_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4032124 ps} 0}
WaveRestoreZoom {0 ps} {8985375 ps}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
