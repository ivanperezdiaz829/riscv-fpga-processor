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


package ifneeded altera_lvds::util::hwtcl_utils                   0.1 [list source [file join $dir .. util hwtcl_utils.tcl]]

package ifneeded altera_lvds::top::export                         0.1 [list source [file join $dir .. top export.tcl]]
package ifneeded altera_lvds::top::main                           0.1 [list source [file join $dir .. top main.tcl]]
package ifneeded altera_lvds::top::pll                            0.1 [list source [file join $dir .. top pll.tcl]]
package ifneeded altera_lvds::top::ex_design                      0.1 [list source [file join $dir .. top ex_design.tcl]]

package ifneeded altera_lvds::core_20::main                       0.1 [list source [file join $dir .. altera_lvds_core20 main.tcl]]
package ifneeded altera_lvds::core_20::pll                        0.1 [list source [file join $dir .. altera_lvds_core20 pll.tcl]]

package ifneeded altera_lvds::driver::main                       0.1 [list source [file join $dir .. altera_lvds_driver main.tcl]]

