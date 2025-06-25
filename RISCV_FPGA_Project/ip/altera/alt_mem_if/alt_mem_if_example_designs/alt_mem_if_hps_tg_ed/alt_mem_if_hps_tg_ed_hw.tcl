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
set_module_property DESCRIPTION "Altera HPS SDRAM External Memory Interface Example Design"
set_module_property NAME alt_mem_if_hps_tg_ed
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_designs_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera HPS SDRAM External Memory Interface Example Design"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# Hide the block diagram
add_display_item "" "Block Diagram" GROUP

# +-----------------------------------
# | Build the GUI
# | 

create_emif_gui

# | 
# +-----------------------------------


# KALEN HACK: For now put the number of driver loops here
add_parameter TG_NUM_DRIVER_LOOP integer 1000
set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns"
set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete. A value of 0 specifies that the driver should infinitely loop."
set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}

# KALEN HACK: Put PNF here for now
::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

# By default don't export the AFI clocks and reset. Otherwise the example timing design will have top-level ports which will be assigned to
# pins in the regtest flow and can cause no-fits. However, the simulation example design will need to set these as it requires the clock and reset.
::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_CLK_RESET boolean false
set_parameter_property EXPORT_AFI_CLK_RESET VISIBLE false

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
	set verification [expr [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] == 0]
	set simulation [expr [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] == 0]
	set synthesis [expr !$verification && !$simulation]

    #  Create the PLL clock reference and export it
	add_interface pll_ref_clk clock end
	add_instance pll_ref_clk altera_clock_bridge
	set_interface_property pll_ref_clk export_of pll_ref_clk.in_clk 
	# Make the exported port name to the desired name
	set_interface_property pll_ref_clk PORT_NAME_MAP { pll_ref_clk in_clk }

	# Create the global_reset_n interface
	add_interface global_reset reset end
	add_instance global_reset altera_reset_bridge
	set_interface_property global_reset export_of global_reset.in_reset
	set_instance_parameter global_reset SYNCHRONOUS_EDGES none
	set_instance_parameter global_reset ACTIVE_LOW_RESET 1
	# Make the exported port name to the desired name
	set_interface_property global_reset PORT_NAME_MAP { global_reset_n in_reset_n }

	# Create the soft_reset_n interface
	add_interface soft_reset reset end
	add_instance soft_reset altera_reset_bridge
	set_interface_property soft_reset export_of soft_reset.in_reset
	set_instance_parameter soft_reset SYNCHRONOUS_EDGES none
	set_instance_parameter soft_reset ACTIVE_LOW_RESET 1
	# Make the exported port name to the desired name
	set_interface_property soft_reset PORT_NAME_MAP { soft_reset_n in_reset_n }

	#  Create the AFI clock reference and export it
	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_interface afi_clk clock start
		add_instance afi_clk altera_clock_bridge
		set_interface_property afi_clk export_of afi_clk.out_clk
		# Make the exported port name to the desired name
		set_interface_property afi_clk PORT_NAME_MAP { afi_clk out_clk }
	}

	#  Create the AFI reset reference and export it
	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_interface afi_reset reset source
		add_instance afi_reset altera_reset_bridge
		set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset export_of afi_reset.out_reset
		# Make the exported port name to the desired name
		set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n out_reset_n }
	}

	set mpfe_suffixes [list {}]
	
	set num_mpfe_ports [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]

	if {$num_mpfe_ports > 1} {
		set mpfe_suffixes [list {_mp0}]
	}
	for {set i 1} {$i < $num_mpfe_ports} {incr i} {
		lappend mpfe_suffixes "_mp${i}"
	}

	set EMIF "if0"
	set CONTROLLER "c0"

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the memory interface
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	instantiate_hps_emif_component $EMIF

	add_connection "pll_ref_clk.out_clk/${EMIF}.pll_ref_clk"

	add_connection "soft_reset.out_reset/${EMIF}.soft_reset"
	add_connection "global_reset.out_reset/${EMIF}.global_reset"

	# Create and export the memory interface
	add_interface "memory" conduit end
	set_interface_property "memory" export_of "${EMIF}.memory"

	::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "memory" "memory"

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Connect the AFI clocks and resets
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_connection "${EMIF}.afi_clk/afi_clk.in_clk"
		add_connection "${EMIF}.afi_reset/afi_reset.in_reset"
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the controller for PHY-only flow
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	if {$synthesis} {

		# if not doing simulation/verification, we don't need any of the following
	} elseif {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {

		::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller $protocol "${CONTROLLER}" "${EMIF}.afi_clk" "${EMIF}.afi_half_clk" "${EMIF}.afi_reset"

		add_connection "${CONTROLLER}.afi/${EMIF}.afi"

		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${CONTROLLER}" "status" "emif_status"
		# case:93951, export sideband signals because it's causing simulation failures if these ports are left dangling
		::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${EMIF}" {} {}

	} else {

		# If not using the PHY-only flow, then export the controller-related interfaces from the EMIF
		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${EMIF}" "status" "emif_status"
		::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${EMIF}" {} {}

		set pll_master_instance "${EMIF}"

		# Connect multi port command clk and reset
		for {set port_id 0} {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} {
			add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_cmd_clk_${port_id}"
			add_connection "global_reset.out_reset/${EMIF}.mp_cmd_reset_n_${port_id}"
			add_connection "soft_reset.out_reset/${EMIF}.mp_cmd_reset_n_${port_id}"
		}
                        
		# Connect multi port fifo clk and reset
		for {set fifo_id 0} {$fifo_id < 4} {incr fifo_id} {
			if {[string compare -nocase [get_parameter_value ENUM_RD_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
				add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_rfifo_clk_${fifo_id}"
				add_connection "global_reset.out_reset/${EMIF}.mp_rfifo_reset_n_${fifo_id}"
				add_connection "soft_reset.out_reset/${EMIF}.mp_rfifo_reset_n_${fifo_id}"
			}

			if {[string compare -nocase [get_parameter_value ENUM_WR_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
				add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_wfifo_clk_${fifo_id}"
				add_connection "global_reset.out_reset/${EMIF}.mp_wfifo_reset_n_${fifo_id}"
				add_connection "soft_reset.out_reset/${EMIF}.mp_wfifo_reset_n_${fifo_id}"
			}
		}
                        
		# Connect csr clk and reset
		if {!$simulation &&
		    [string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
			add_connection "${pll_master_instance}.afi_clk/${EMIF}.csr_clk"
			add_connection "global_reset.out_reset/${EMIF}.csr_reset_n"
			add_connection "soft_reset.out_reset/${EMIF}.csr_reset_n"
		}
	}

	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the OCT rzqin interface
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	add_interface "oct" conduit end
	set_interface_property "oct" export_of "${EMIF}.oct"
	::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "oct" "oct"
	set_interface_assignment "oct" "qsys.ui.export_name" "oct"
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#    Create the Traffic Generator
	#
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        set unix_id 0

	for {set jj 0} {$jj < $num_mpfe_ports} {incr jj} {

		set mpfe_suffix [lindex $mpfe_suffixes $jj]
		set TRAFFIC_GEN "d0${mpfe_suffix}"

		add_instance $TRAFFIC_GEN altera_avalon_mm_traffic_generator

		# Set the traffic generator parameters
		set_instance_parameter $TRAFFIC_GEN TG_POWER_OF_TWO_BUS [get_parameter_value POWER_OF_TWO_BUS]
		if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
			set_instance_parameter $TRAFFIC_GEN TG_AVL_DATA_WIDTH_IN [get_parameter_value AVL_DATA_WIDTH_PORT_${jj}]
                        set_instance_parameter $TRAFFIC_GEN TG_AVL_ADDR_WIDTH_IN [get_parameter_value AVL_ADDR_WIDTH_PORT_${jj}]
		} else {
			set_instance_parameter $TRAFFIC_GEN TG_AVL_DATA_WIDTH_IN [get_parameter_value AVL_DATA_WIDTH]
                        set_instance_parameter $TRAFFIC_GEN TG_AVL_ADDR_WIDTH_IN [get_parameter_value AVL_ADDR_WIDTH]
		}
		set_instance_parameter $TRAFFIC_GEN TG_AVL_SYMBOL_WIDTH [get_parameter_value AVL_SYMBOL_WIDTH]

		# Byte addressing is always enabled
		# Modify the avalon interface to be a conduit if requested
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			set_instance_parameter $TRAFFIC_GEN TG_GEN_BYTE_ADDR "true"
		} else {
			set_instance_parameter $TRAFFIC_GEN TG_GEN_BYTE_ADDR "false"
		}

		set_instance_parameter $TRAFFIC_GEN TG_AVL_MAX_SIZE [get_parameter_value AVL_MAX_SIZE]
		set_instance_parameter $TRAFFIC_GEN TG_TWO_AVL_INTERFACES "false"

		# Enable the controller Avalon byte enable
		if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0} {
			set_instance_parameter $TRAFFIC_GEN TG_BYTE_ENABLE "true"
			if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
				set_instance_parameter $TRAFFIC_GEN TG_RANDOM_BYTE_ENABLE "false"
			} else {
				set_instance_parameter $TRAFFIC_GEN TG_RANDOM_BYTE_ENABLE "true"
			}
		} else {
			set_instance_parameter $TRAFFIC_GEN TG_BYTE_ENABLE "false"
		}

		set_instance_parameter $TRAFFIC_GEN TG_BURST_BEGIN "true"
		set_instance_parameter $TRAFFIC_GEN TG_NUM_DRIVER_LOOP [get_parameter_value TG_NUM_DRIVER_LOOP]

		# Set the avalon mode
		set_instance_parameter $TRAFFIC_GEN ENABLE_CTRL_AVALON_INTERFACE [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]

		set_instance_parameter $TRAFFIC_GEN TG_PNF_ENABLE [get_parameter_value TG_PNF_ENABLE]

		# Ctrl only allow memory burst aligned commands for no dm case
		if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "false"] == 0} {
			# Set traffic generator to generate burst aligned commands in no DM case
			set_instance_parameter $TRAFFIC_GEN TG_BURST_ON_BURST_BOUNDARY "true"
			
			# Set traffic generator to no enable template test
			# because commands from template test are no burst aligned, will cause test to fail
			set_instance_parameter $TRAFFIC_GEN TG_TEMPLATE_STAGE_COUNT 0
			
			# Set traffic generator to send power of two burst only
			set_instance_parameter $TRAFFIC_GEN TG_POWER_OF_TWO_BURSTS_ONLY "true"
			
			# Set minimum burst to memory burst / DWIDTH_RATIO
			if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
				# Only NextGenDDRx controller always issues BC if neccesary in DDR3 while DDRx controller only issues BC at certain times, not always
				set minimum_size [expr ([get_parameter_value MEM_BURST_LENGTH] / [get_parameter_value DWIDTH_RATIO]) / 2]
			} else {
				set minimum_size [expr ([get_parameter_value MEM_BURST_LENGTH] / [get_parameter_value DWIDTH_RATIO])]
			}
			
			if {$minimum_size > 0} {
				set_instance_parameter $TRAFFIC_GEN TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT      $minimum_size
				set_instance_parameter $TRAFFIC_GEN TG_RAND_ADDR_GEN_MIN_BURSTCOUNT     $minimum_size
				set_instance_parameter $TRAFFIC_GEN TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT $minimum_size
			} else {
				set_instance_parameter $TRAFFIC_GEN TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT      1
				set_instance_parameter $TRAFFIC_GEN TG_RAND_ADDR_GEN_MIN_BURSTCOUNT     1
				set_instance_parameter $TRAFFIC_GEN TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT 1
			}
		}

		# Make traffic gen generate address with unix id for each driver
		if {$num_mpfe_ports > 1} {
			set_instance_parameter $TRAFFIC_GEN TG_ENABLE_UNIX_ID "true"
			set_instance_parameter $TRAFFIC_GEN TG_USE_UNIX_ID ${unix_id}
			incr unix_id
		}

		# Cache all system info parameters from this component to the child
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $TRAFFIC_GEN

		# Make the traffic generator connections

		if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
			add_connection "${EMIF}.afi_half_clk/${TRAFFIC_GEN}.avl_clock"
		} else {
			add_connection "${EMIF}.afi_clk/${TRAFFIC_GEN}.avl_clock"
		}

		add_connection "global_reset.out_reset/${TRAFFIC_GEN}.avl_reset"
		if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
			add_connection "${TRAFFIC_GEN}.avl/${CONTROLLER}.avl_${jj}"
		} else {
			add_connection "${TRAFFIC_GEN}.avl/${EMIF}.avl_${jj}"
		}

		# Export the traffic generator status interface
		add_interface "drv_status${mpfe_suffix}" conduit end
		set_interface_property "drv_status${mpfe_suffix}" export_of "${TRAFFIC_GEN}.status"

		# Export the PNF interface if appropriate
		if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "true"] == 0} {
			add_interface "drv_pnf${mpfe_suffix}" conduit end
			set_interface_property "drv_pnf${mpfe_suffix}" export_of "${TRAFFIC_GEN}.pnf"

			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${TRAFFIC_GEN}" "pnf" "drv_pnf${mpfe_suffix}"
		}

	}

	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		_dprint 1 "Exporting core debug bridge"
		set conn_type [get_parameter_value CORE_DEBUG_CONNECTION]
		if {[string compare -nocase $conn_type "SHARED"] == 0 || [string compare -nocase $conn_type "EXPORT"] == 0} {
			#----------------------------------------------
			# 
			# Create the external Nios for sequencer access
			# Only do this for EMIF 0
			# If we do this, don't export the seq_debug interface
			#
			#----------------------------------------------
			if {[string compare -nocase [get_parameter_value ADD_EXTERNAL_SEQ_DEBUG_NIOS] "true"] == 0} {
				::alt_mem_if::gen::uniphy_interfaces::add_external_seq_debug_nios "${EMIF}"
			} else {
				# If the core debug port is available, export it
				set debug_port "seq_debug"
				add_interface "${debug_port}" avalon end
				set_interface_property "${debug_port}" export_of "${EMIF}.${debug_port}"
			}
		}
	}

}




