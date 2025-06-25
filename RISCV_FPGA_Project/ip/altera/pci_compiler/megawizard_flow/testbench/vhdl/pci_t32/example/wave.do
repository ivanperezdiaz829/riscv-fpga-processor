onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {PCI SYSTEM SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/clk
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/rstn
add wave -noupdate -divider {PCI ADDRESS/DATA SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/par
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/ad
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/cben
add wave -noupdate -divider {PCI CONTROL SIGNALS}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/framen
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/irdyn
add wave -noupdate -color Cyan -format Logic -radix hexadecimal /altera_tb/trdyn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/devseln
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/stopn
add wave -noupdate -divider {PCI PARITY ERROR}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/perrn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/serrn
add wave -noupdate -divider {LOCAL SIGNALS}
add wave -noupdate -divider {LOCAL ADDRESS/DATA}
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_adi
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_dato
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_adro
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_beno
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/l_cmdo
add wave -noupdate -divider {LOCAL TARGET Control}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_abortn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_ackn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_discn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_dxfrn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_framen
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/lt_rdyn
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/lt_tsr
add wave -noupdate -divider {config outputs}
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/cmd_reg
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/stat_reg
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/clk
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/rstn
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pcil_dat_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pcil_adr_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pcil_ben_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pcil_cmd_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_abort_n_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_disc_n_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_rdy_n_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_frame_n_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_ack_n_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilt_dxfr_n_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pcilt_tsr_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/pcilirq_n_o
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/pciad_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgtdatatx_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgtprftchon_o
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/prftchreg_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgtdone_o
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgtiowren_o
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/sramdw_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/sramwren_o
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/sramaddr_o
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/iodat_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/state
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/nxt_state
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/sram_addr
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/prftch_on
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/prftch_reg
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/ad_temp
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/io_rd
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/io_wr
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/mem_rd
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/mem_wr
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/sx_data_tx
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgt_done
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgt_rd_tx
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgt_wr_tx
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u1/trgt_demo
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u1/trgt_term_demo_reg
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u5/clk
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u5/rstn
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u5/prftch_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u5/sx_data_tx_i
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u5/trgt_done_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u5/sram_data_i
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u5/prftch_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u2/address
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u2/clock
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u2/data
add wave -noupdate -format Logic -radix hexadecimal /altera_tb/u2/u2/wren
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u2/q
add wave -noupdate -format Literal -radix hexadecimal /altera_tb/u2/u2/sub_wire0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {2657 ns}
WaveRestoreZoom {0 ns} {7544 ns}
configure wave -namecolwidth 294
configure wave -valuecolwidth 180
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
