##Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
##use of Altera Corporation's design tools, logic functions and other
##software and tools, and its AMPP partner logic functions, and any
##output files any of the foregoing (including device programming or
##simulation files), and any associated documentation or information are
##expressly subject to the terms and conditions of the Altera Program
##License Subscription Agreement or other applicable license agreement,
##including, without limitation, that your use is for the sole purpose
##of programming logic devices manufactured by Altera and sold by Altera
##or its authorized distributors. Please refer to the applicable
##agreement for further details. 







package provide ::ddr::data 0.1 
namespace eval ::ddr::data {
namespace export get_micro_params





proc get_micro_params {speedgrade pvt}  {
switch -glob -- "$speedgrade-$pvt" {
c*-fast { return [list utco_le  62 usu_le  47 uhold_le  75 utco_ioe 106 usu_ioe  68 uhold_ioe  37] } 
i*-fast { return [list utco_le  59 usu_le  45 uhold_le  75 utco_ioe  97 usu_ioe  65 uhold_ioe  36] } 
*3-slow { return [list utco_le  94 usu_le  90 uhold_le 149 utco_ioe 179 usu_ioe 122 uhold_ioe  72] } 
*4-slow { return [list utco_le 109 usu_le 104 uhold_le 172 utco_ioe 101 usu_ioe 140 uhold_ioe  82] } 
*5-slow { return [list utco_le 127 usu_le 121 uhold_le 200 utco_ioe 226 usu_ioe 163 uhold_ioe  96] } 
default { error "speedgrade-pvt value \"$speedgrade-$pvt\" unrecognised" }
} 	
}
}
