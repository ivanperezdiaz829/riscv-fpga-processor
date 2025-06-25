# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


###############################################################################
## altera_phylite::util
###############################################################################
package ifneeded altera_phylite::util::enum_defs   0.1 [list source [file join $dir .. util enum_defs.tcl]]
package ifneeded altera_phylite::util::arch_expert 0.1 [list source [file join $dir .. util arch_expert.tcl]]

###############################################################################
## altera_phylite::ip_top
###############################################################################
package ifneeded altera_phylite::ip_top::main      0.1 [list source [file join $dir .. ip_top main.tcl]]
package ifneeded altera_phylite::ip_top::general   0.1 [list source [file join $dir .. ip_top general.tcl]]
package ifneeded altera_phylite::ip_top::group     0.1 [list source [file join $dir .. ip_top group.tcl]]
package ifneeded altera_phylite::ip_top::exports   0.1 [list source [file join $dir .. ip_top exports.tcl]]
package ifneeded altera_phylite::ip_top::ex_design 0.1 [list source [file join $dir .. ip_top ex_design.tcl]]

###############################################################################
## altera_phylite::ip_arch_nf
###############################################################################
package ifneeded altera_phylite::ip_arch_nf::main                0.1 [list source [file join $dir .. ip_arch_nf main.tcl]]
package ifneeded altera_phylite::ip_arch_nf::pll                 0.1 [list source [file join $dir .. ip_arch_nf pll.tcl]]
package ifneeded altera_phylite::ip_arch_nf::arch_expert_exports 0.1 [list source [file join $dir .. ip_arch_nf arch_expert_exports.tcl]]

###############################################################################
## altera_phylite::ip_driver
###############################################################################
package ifneeded altera_phylite::ip_driver::main    0.1 [list source [file join $dir .. ip_driver main.tcl]]

###############################################################################
## altera_phylite::ip_agent
###############################################################################
package ifneeded altera_phylite::ip_agent::main    0.1 [list source [file join $dir .. ip_agent main.tcl]]

###############################################################################
## altera_phylite::ip_agent
###############################################################################
package ifneeded altera_phylite::ip_sim_ctrl::main    0.1 [list source [file join $dir .. ip_sim_ctrl main.tcl]]
