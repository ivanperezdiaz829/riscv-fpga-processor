onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {PCI SYSTEM SIGNALS}
add wave -noupdate -format Logic /altera_tb/clk
add wave -noupdate -format Logic /altera_tb/rstn
add wave -noupdate -divider {PCI ADDRESS/DATA SIGNALS}
add wave -noupdate -format Logic /altera_tb/par
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/ad
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/cben
add wave -noupdate -divider {PCI CONTROL SIGNALS}
add wave -noupdate -format Logic /altera_tb/framen
add wave -noupdate -format Logic /altera_tb/irdyn
add wave -noupdate -format Logic /altera_tb/devseln
add wave -noupdate -color Cyan -format Logic /altera_tb/trdyn
add wave -noupdate -format Logic /altera_tb/stopn
add wave -noupdate -divider {PCI PARITY ERROR}
add wave -noupdate -format Logic /altera_tb/perrn
add wave -noupdate -format Logic /altera_tb/serrn
add wave -noupdate -divider {LOCAL SIGNALS}
add wave -noupdate -divider {LOCAL ADDRESS/DATA}
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_adi
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_dato
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_adro
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_beno
add wave -noupdate -format Literal -radix binary /altera_tb/l_cmdo
add wave -noupdate -divider {LOCAL data/control}
add wave -noupdate -divider {LOCAL MASTER control}
add wave -noupdate -divider {LOCAL TARGET Control}
add wave -noupdate -format Logic /altera_tb/lt_abortn
add wave -noupdate -format Logic /altera_tb/lt_ackn
add wave -noupdate -format Logic /altera_tb/lt_discn
add wave -noupdate -format Logic /altera_tb/lt_dxfrn
add wave -noupdate -format Logic /altera_tb/lt_framen
add wave -noupdate -format Logic /altera_tb/lt_rdyn
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/lt_tsr
add wave -noupdate -divider {config outputs}
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/cmd_reg
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/stat_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6551 ns} 0}
WaveRestoreZoom {6306 ns} {8165 ns}
configure wave -namecolwidth 294
configure wave -valuecolwidth 152
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
