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


# +-----------------------------------
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 12.0
# | 
package require -exact qsys 12.0

source ../../alt_mem_if_interfaces/alt_mem_if_hps_emif/common_hps_emif.tcl

# | 
# +-----------------------------------

# +-----------------------------------

# +-----------------------------------
# | 
set_module_property DESCRIPTION "Altera HPS SDRAM External Memory Interface Example Design Simulation"
set_module_property NAME alt_mem_if_hps_tg_eds
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_designs_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera HPS SDRAM External Memory Interface Example Design Simulation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# need 1 port for simulation test
set_parameter_property NUM_OF_PORTS DEFAULT_VALUE 1
#set_parameter_property HHP_HPS_VERIFICATION DEFAULT_VALUE true
#set_parameter_property USE_SEQUENCER_BFM DEFAULT_VALUE true


# Hide the block diagram
add_display_item "" "Block Diagram" GROUP

# +-----------------------------------
# | Build the GUI
# | 

create_emif_gui

# | 
# +-----------------------------------


# KALEN HACK: For now put the number of driver loops here
add_parameter TG_NUM_DRIVER_LOOP integer 1
set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns"
set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete. A value of 0 specifies that the driver should infinitely loop."
set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}

# KALEN HACK: Put PNF here for now
::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_CLK_RESET boolean false
set_parameter_property EXPORT_AFI_CLK_RESET VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_VCDPLUS BOOLEAN false
set_parameter_property ENABLE_VCDPLUS DISPLAY_NAME "Enable VCDplus in initial block"
set_parameter_property ENABLE_VCDPLUS TYPE BOOLEAN
set_parameter_property ENABLE_VCDPLUS DESCRIPTION "Use this parameter to add vcspluson to the initial block in the simulation model"

# +-----------------------------------
# | Elaboration/validation callbacks
# | 

if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property VALIDATION_CALLBACK ip_validate
	set_module_property COMPOSITION_CALLBACK ip_compose
} else {
	set_module_property COMPOSITION_CALLBACK combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_compose
}

proc ip_validate {} {

	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	validate_emif_component
}

proc ip_compose {} {

	_dprint 1 "Running IP Compose for [get_module_property NAME]"

	set protocol [string tolower [get_parameter_value HPS_PROTOCOL]]

	set CLOCK pll_ref_clk
	add_instance $CLOCK altera_avalon_clock_source
	set_instance_parameter $CLOCK CLOCK_RATE [expr {round([get_parameter_value REF_CLK_FREQ] * 1000000.0)}]
	set_instance_parameter $CLOCK CLOCK_UNIT 1

	set RESET global_reset
	add_instance $RESET altera_avalon_reset_source
	set_instance_parameter $RESET ASSERT_HIGH_RESET 0
	set_instance_parameter $RESET INITIAL_RESET_CYCLES 5


	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the memory interface example design
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	set ED e0
	add_instance $ED alt_mem_if_hps_tg_ed
	# Apply all the parameters
	foreach param_name [get_instance_parameters $ED] {
		set_instance_parameter $ED $param_name [get_parameter_value $param_name]
	}
	# Instruct ED to export the afi clock and reset so it can be connected to the status checker
	set_instance_parameter $ED EXPORT_AFI_CLK_RESET true
	# Cache all PLL parameters from this component to the child
	::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $ED
	# Cache all system info parameters from this component to the child
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $ED
	# Suppress messages from this child component; only the parent needs to display messages
	set_instance_parameter $ED DISABLE_CHILD_MESSAGING true

	add_connection "${CLOCK}.clk/${ED}.pll_ref_clk"
	add_connection "${CLOCK}.clk/${RESET}.clk"
	add_connection "${RESET}.reset/${ED}.global_reset"
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 &&
	    [string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		# don't connect soft reset now; it will be driven by the ROM reconfig block
	} else {
		add_connection "${RESET}.reset/${ED}.soft_reset"
	}

	set num_emif 1
	set interface_suffixes [list {}]

	set num_mpfe_ports 1
	set mpfe_suffixes [list {}]
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set num_mpfe_ports [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]
                if {$num_mpfe_ports > 1} {
                        set mpfe_suffixes [list {_mp0}]
                }
		for {set ii 1} {$ii < $num_mpfe_ports} {incr ii} {
			lappend mpfe_suffixes "_mp${ii}"
		}
	}

	set num_checker_ports [expr {$num_mpfe_ports * $num_emif}]
	set checker_suffixes [list {}]
	for {set ii 1} {$ii < $num_checker_ports} {incr ii} {
		lappend checker_suffixes "_${ii}"
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create and export the PNF interface
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "true"] == 0} {
		foreach ii $interface_suffixes {
			foreach jj $mpfe_suffixes {
				add_interface "drv_pnf${ii}${jj}" conduit end
				set_interface_property "drv_pnf${ii}${jj}" ENABLED true
				set_interface_property "drv_pnf${ii}${jj}" export_of "${ED}.drv_pnf${ii}${jj}"
				::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${ED}" "drv_pnf${ii}${jj}" "drv_pnf${ii}${jj}"
			}
		}
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create and export the seq debug interface
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		set conn_type [get_parameter_value CORE_DEBUG_CONNECTION]
		if {[string compare -nocase $conn_type "SHARED"] == 0 || [string compare -nocase $conn_type "EXPORT"] == 0} {
			# If the core debug port is available, export it
			for {set i 0} {$i < $num_emif} {incr i} {
				
				set suffix [lindex $interface_suffixes $i]
				
				set debug_port "seq_debug${suffix}"
				add_interface "${debug_port}" avalon end
				set_interface_property "${debug_port}" export_of "${ED}.${debug_port}"
					
			}

			# Export afi_clk (avl_clk) and reset
			add_interface avl_clk clock start
			add_instance avl_clk altera_clock_bridge
			add_connection "${ED}.afi_clk/avl_clk.in_clk"
			set_interface_property avl_clk export_of "avl_clk.out_clk"
			
			add_interface avl_reset reset start
			add_instance avl_reset altera_reset_bridge
			set_instance_parameter avl_reset SYNCHRONOUS_EDGES none
			set_instance_parameter avl_reset ACTIVE_LOW_RESET 1
			add_connection "${ED}.afi_reset/avl_reset.in_reset"
			set_interface_property avl_reset export_of "avl_reset.out_reset"

		}
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the status checker
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	set TRAFFIC_GEN_CHECKER t0
	add_instance $TRAFFIC_GEN_CHECKER altera_mem_if_checker
	
	# Enable VCDPLUSon if requested
	set_instance_parameter $TRAFFIC_GEN_CHECKER ENABLE_VCDPLUS [get_parameter_value ENABLE_VCDPLUS]
	set_instance_parameter $TRAFFIC_GEN_CHECKER NUM_STATUS_INTERFACES_TGEN $num_checker_ports
        set_instance_parameter $TRAFFIC_GEN_CHECKER NUM_STATUS_INTERFACES $num_emif

	# Make the traffic generator connections
	add_connection "${ED}.afi_clk/${TRAFFIC_GEN_CHECKER}.avl_clock"
	add_connection "${ED}.afi_reset/${TRAFFIC_GEN_CHECKER}.avl_reset"

	set count 0
        set count_emif 0
	foreach ii $interface_suffixes {
		foreach jj $mpfe_suffixes {
			set checker_suffix [lindex $checker_suffixes $count]
			add_connection "${ED}.drv_status${ii}${jj}/${TRAFFIC_GEN_CHECKER}.drv_status${checker_suffix}"
			incr count
		}

                if {$count_emif == 0} {
                        add_connection "${ED}.emif_status${ii}/${TRAFFIC_GEN_CHECKER}.emif_status"
                } else {
                        add_connection "${ED}.emif_status${ii}/${TRAFFIC_GEN_CHECKER}.emif_status_${count_emif}"
                }
                incr count_emif
	}


	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the memory model
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	for {set i 0} {$i < $num_emif} {incr i} {
		set MEM_MODEL "m${i}"
		add_instance $MEM_MODEL altera_mem_if_${protocol}_mem_model
		# Apply all the parameters
		foreach param_name [get_instance_parameters $MEM_MODEL] {
			set_instance_parameter $MEM_MODEL $param_name [get_parameter_value $param_name]
		}
		# Suppress messages from this child component; only the parent needs to display messages
		set_instance_parameter $MEM_MODEL DISABLE_CHILD_MESSAGING true
		
		set suffix [lindex $interface_suffixes $i]

		if {[string compare -nocase [get_parameter_value INCLUDE_BOARD_DELAY_MODEL] "true"] == 0} {


			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			#
			#    Create the board delay model
			#
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


			set BOARD_DELAY_MODEL "dly${i}"
			add_instance $BOARD_DELAY_MODEL altera_${protocol}_board_delay_model
			# Apply all the parameters
			foreach param_name [get_instance_parameters $BOARD_DELAY_MODEL] {
                                if {[string compare -nocase $param_name "SHADOW_REG_IDX"] != 0} {
					set_instance_parameter $BOARD_DELAY_MODEL $param_name [get_parameter_value $param_name]
				}
			}

			# make the connection between the phy and the delay model
			add_connection "${ED}.memory${suffix}/${BOARD_DELAY_MODEL}.board_to_phy"

			# now make the connection between the delay model and the memory model 
			add_connection "${BOARD_DELAY_MODEL}.board_to_mem/${MEM_MODEL}.memory"
			
		} else {

			# Make the connections to the memory model
			add_connection "${ED}.memory${suffix}/${MEM_MODEL}.memory"

		}
	}


	set count 0
	foreach ii $interface_suffixes {


		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#
		#    Terminate the controller sideband interfaces
		#
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		# case:93951, export sideband signals because it's causing simulation failures if these ports are left dangling
		
		#if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
		#	# Don't bother exporting the sideband signals since they shouldn't be desired in the PHY-only case
		#} else {

			if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0 ||
			    [string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0 ||
			    [string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0 ||
			    [string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0 ||
			    [string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
				set SBTERM "sbt${count}"
				add_instance $SBTERM altera_mem_if_sideband_terminator
				set_instance_parameter $SBTERM CTL_CS_WIDTH [get_parameter_value CTL_CS_WIDTH]
				set_instance_parameter $SBTERM MULTICAST_EN [get_parameter_value MULTICAST_EN]
				if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
					add_connection "${SBTERM}.avl_multicast_write/${ED}.avl_multicast_write${ii}"
				}
                                if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
                                        # local_autopch_req port not exist and not exported for Hard EMIF
                                        set_instance_parameter $SBTERM CTL_AUTOPCH_EN "false"
                                } else {
                                        set_instance_parameter $SBTERM CTL_AUTOPCH_EN [get_parameter_value CTL_AUTOPCH_EN]
                                        if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
                                                add_connection "${SBTERM}.autoprecharge_req/${ED}.autoprecharge_req${ii}"
                                        }
                                }
				set_instance_parameter $SBTERM CTL_USR_REFRESH_EN [get_parameter_value CTL_USR_REFRESH_EN]
				if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
					add_connection "${SBTERM}.user_refresh/${ED}.user_refresh${ii}"
				}
				set_instance_parameter $SBTERM CTL_SELF_REFRESH_EN [get_parameter_value CTL_SELF_REFRESH_EN]
				if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
					add_connection "${SBTERM}.self_refresh/${ED}.self_refresh${ii}"
				}
				set_instance_parameter $SBTERM CTL_DEEP_POWERDN_EN [get_parameter_value CTL_DEEP_POWERDN_EN]
				if {[string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
					add_connection "${SBTERM}.deep_powerdn/${ED}.deep_powerdn${ii}"
				}
			}
			incr count
		#}

	}

}


