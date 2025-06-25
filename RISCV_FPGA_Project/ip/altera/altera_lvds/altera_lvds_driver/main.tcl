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


package provide altera_lvds::driver::main 0.1

package require altera_lvds::top::export
package require altera_lvds::core_20::pll
package require altera_lvds::util::hwtcl_utils  

namespace eval ::altera_lvds::driver::main:: {
   
   namespace import ::altera_lvds::top::export::*
   namespace import ::altera_lvds::core_20::pll::*
   namespace import ::altera_lvds::util::hwtcl_utils::*

}



proc ::altera_lvds::driver::main::create_parameters {} {
     
    ::altera_lvds::top::export::inherit_top_level_parameter_defs
    
	set driver_param_list [list MODE \
								J_FACTOR \
								DATA_RATE \
								TX_OUTCLOCK_DIVISION \
								TX_OUTCLOCK_PHASE_SHIFT \
								pll_inclock_frequency \
								NUM_CHANNELS \
								pll_fclk_frequency \
								pll_sclk_frequency \
								pll_loaden_frequency \
								pll_sclk_phase_shift \
								pll_fclk_phase_shift\
								pll_loaden_phase_shift \
								pll_loaden_duty_cycle]
	
    foreach param $driver_param_list {
    set param_type [get_parameter_property $param type] 
        if {[get_parameter_property $param DERIVED] == 0 && [regexp -lineanchor {^GUI} $param] == 0 } {
            set_parameter_property $param HDL_PARAMETER true
        }
    }
    
    return 1
}

proc ::altera_lvds::driver::main::add_if_short {\
   name \
   type \
   qsys_dir \
   dir \
   {width 0} \
   {term "none"}
} {
   set if_name $name

   add_interface $if_name $type $qsys_dir
   set_interface_property $if_name ENABLED false 
   
   set_interface_assignment $if_name "ui.blockdiagram.direction" $dir

   if { $width == 0 } {
         set width 1
		 set port_vhdl_type STD_LOGIC
   } else {
         set port_vhdl_type STD_LOGIC_VECTOR
   }
   
   if { $type == "clock" } {
        add_interface_port $if_name $name clk $dir $width
   } else {
        add_interface_port $if_name $name export $dir $width
   }

   set_port_property $name VHDL_TYPE $port_vhdl_type

   if { [string_compare $term "none"] == 0 } {
        set_port_property $name TERMINATION true
        set_port_property $name TERMINATION_VALUE $term
   }     
}

proc ::altera_lvds::driver::main::elaboration_callback {} {

	set data_width [get_parameter_value J_FACTOR]
	
	add_if_short pll_areset conduit end Output
	add_if_short pll_locked conduit end Input
	add_if_short dzoutx conduit end Input
	add_if_short dpahold conduit end Output
	add_if_short dparst conduit end Output 1
	add_if_short dpaswitch conduit end Output
	add_if_short fiforst conduit end Output
	add_if_short core_in conduit end Output
	add_if_short par_in conduit end Output $data_width
	add_if_short bslipcntl conduit end Output 1
	add_if_short bsliprst conduit end Output 1
	add_if_short lock conduit end Input
	add_if_short bslipmax conduit end Input
	add_if_short par_out conduit end Input $data_width
	add_if_short lvdsin conduit end Output 1
	add_if_short lvdsout conduit end Input
	add_if_short loopback2_data conduit end Output
	add_if_short data_lback_adj conduit end Output
	add_if_short loaden conduit end Input
	add_if_short data_lback2 conduit end Input
	add_if_short data_lback13 conduit end Input
	add_if_short pclk conduit end Input
	add_if_short pclkdpa conduit end Output
	add_if_short tx_outclock conduit end Input
	add_if_short coreclock conduit end Input
	add_if_short refclk conduit end Output

	set_interface_property refclk ENABLED true
	if {[param_string_compare PLL_USE_RESET "true"]} {
		set_interface_property pll_areset ENABLED true
	}

	if {[param_string_compare MODE "TX"]} {
		set_interface_property par_in ENABLED true
		set_interface_property lvdsout ENABLED true
		if { [param_string_compare TX_USE_OUTCLOCK "true"] } {
			set_interface_property tx_outclock ENABLED true
		}
	} else {
		set_interface_property lvdsin ENABLED true
		set_interface_property par_out ENABLED true
		
		set use_bitslip [param_string_compare RX_USE_BITSLIP "true"]
		
		if { $use_bitslip } {
			set_interface_property bslipcntl ENABLED true
		}
		
		if { $use_bitslip && [param_string_compare RX_BITSLIP_ASSERT_MAX "true"] } {
			set_interface_property bslipmax ENABLED true
		}
		
		if { [param_string_compare RX_BITSLIP_USE_RESET "true"] && $use_bitslip } {
			set_interface_property bsliprst ENABLED true
		}
		if {[param_string_compare MODE "RX_DPA-FIFO"] || [param_string_compare MODE "RX_Soft-CDR"]} {   
			set_interface_property dparst ENABLED true
			set_interface_property lock ENABLED true
		}
		if {[param_string_compare MODE "RX_Soft-CDR"]} {  
			set_interface_property pclk ENABLED true
		} else {
			set_interface_property coreclock ENABLED true
		}
	}

	if {[param_string_compare PLL_EXPORT_LOCK "true"] 
		&& [param_string_compare USE_EXTERNAL_PLL "false"] 
		&& [param_string_compare USE_CLOCK_PIN "false"] } {
		
		set_interface_property pll_locked ENABLED true
	}

    return 1
}

proc ::altera_lvds::driver::main::sim_vhdl_fileset_callback {top_level} {
   	::altera_lvds::util::hwtcl_utils::generate_vhdl_sim [list altera_lvds_driver.sv]
}

proc ::altera_lvds::driver::main::sim_verilog_fileset_callback {top_level} {
    add_fileset_file altera_lvds_driver.sv SYSTEM_VERILOG PATH altera_lvds_driver.sv
}


proc ::altera_lvds::driver::main::quartus_synth_fileset_callback {top_level} {
	add_fileset_file altera_lvds_driver.sv SYSTEM_VERILOG PATH altera_lvds_driver.sv
}


proc ::altera_lvds::driver::main::_init {} {
}

::altera_lvds::driver::main::_init
