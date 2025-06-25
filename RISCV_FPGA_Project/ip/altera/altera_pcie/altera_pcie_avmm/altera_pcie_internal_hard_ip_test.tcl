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


package require -exact sopc 9.1
package require -exact altera_tcl_testlib 1.0
#+-----------------------------------------------------
#| Define the module name as a global var
#+-----------------------------------------------------
set dut "myhip"

proc setup {} {
    global dut
    create_dut altera_pcie_internal_hard_ip $dut
}

proc listcomp {a b} {
    set diff {}
    foreach i $a {
        if {[lsearch -exact $b $i]==-1} {
            lappend diff $i
        }
    }
    foreach i $b {
        if {[lsearch -exact $a $i]==-1} {
            lappend diff $i
        }
    }
    return $diff
}

proc test_default_interfaces { } {
    global dut


}

proc test_parameters_vs_interfaces { } {
    global dut

    foreach dw { 3 8 16 32 } {
        set_instance_parameter $dut port_link_number $dw
       
        assert { [ get_instance_parameter_value $dut port_link_number ] == $dw} "The port_link_number doesn't have the expected value."
        }

        
}    

#+--------------------------------------
#| Main
#+--------------------------------------
run_test { test_default_interfaces }
run_test { test_parameters_vs_interfaces }

printresults

