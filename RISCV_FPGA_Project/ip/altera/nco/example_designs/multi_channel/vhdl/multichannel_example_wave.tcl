## ================================================================================
## Legal Notice: Copyright (C) 1991-2009 Altera Corporation
## Any megafunction design, and related net list (encrypted or decrypted),
## support information, device programming or simulation file, and any other
## associated documentation or information provided by Altera or a partner
## under Altera's Megafunction Partnership Program may be used only to
## program PLD devices (but not masked PLD devices) from Altera.  Any other
## use of such megafunction design, net list, support information, device
## programming or simulation file, or any other related documentation or
## information is prohibited for any other purpose, including, but not
## limited to modification, reverse engineering, de-compiling, or use with
## any other silicon devices, unless such use is explicitly licensed under
## a separate agreement with Altera or a megafunction partner.  Title to
## the intellectual property, including patents, copyrights, trademarks,
## trade secrets, or maskworks, embodied in any such megafunction design,
## net list, support information, device programming or simulation file, or
## any other related documentation or information provided by Altera or a
## megafunction partner, remains with Altera, the megafunction partner, or
## their respective licensors.  No other licenses, including any licenses
## needed under any third party's intellectual property, are provided herein.
## ================================================================================
# NCO Compiler Multi-Channel Example Design 
# Description: This script is used for adding relevant signals to the wave window

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider -height 50 {Input}
add wave -noupdate -format Logic /multichannel_example_tb/clk
add wave -noupdate -format Logic /multichannel_example_tb/reset_n
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/phi_ch0
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/phi_ch1
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/phi_ch2
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/phi_ch3
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/fmod_ch0
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/fmod_ch1
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/fmod_ch2
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/fmod_ch3
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/pmod_ch0
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/pmod_ch1
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/pmod_ch2
add wave -noupdate -format Literal -radix unsigned /multichannel_example_tb/pmod_ch3

add wave -noupdate -divider -height 50 {Output}
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/sin_ch0
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/sin_ch1
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/sin_ch2
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/sin_ch3
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/cos_ch0
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/cos_ch1
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/cos_ch2
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/cos_ch3

add wave -noupdate -divider -height 50 {Avalon Streaming Signals}
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/sin_o
add wave -noupdate -format Literal -radix decimal /multichannel_example_tb/cos_o
add wave -noupdate -format Logic /multichannel_example_tb/valid
add wave -noupdate -format Logic /multichannel_example_tb/startofpacket
add wave -noupdate -format Logic /multichannel_example_tb/endofpacket
add wave -noupdate -divider -height 80 {sin_channel_0}
add wave -noupdate -color Yellow -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/sin_ch0
add wave -noupdate -divider -height 80 {cos_channel_0}
add wave -noupdate -color Cyan -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/cos_ch0
add wave -noupdate -divider -height 150 {sin_channel_1}
add wave -noupdate -color Yellow -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/sin_ch1
add wave -noupdate -divider -height 80 {cos_channel_1}
add wave -noupdate -color Cyan -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/cos_ch1
add wave -noupdate -divider -height 150 {sin_channel_2}
add wave -noupdate -color Yellow -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/sin_ch2
add wave -noupdate -divider -height 80 {cos_channel_2}
add wave -noupdate -color Cyan -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/cos_ch2
add wave -noupdate -divider -height 150 {sin_channel_3}
add wave -noupdate -color Yellow -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/sin_ch3
add wave -noupdate -divider -height 80 {cos_channel_3}
add wave -noupdate -color Cyan -format Analog-Step -radix decimal -scale 6.25E-5 /multichannel_example_tb/cos_ch3

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {356 ns}
WaveRestoreZoom {0 ns} {2132 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
