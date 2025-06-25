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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}

package require -exact qsys 12.0


source common_hps_emif.tcl



set_module_property DESCRIPTION "HPS DDRx SDRAM Controller with UniPHY"
set_module_property NAME altera_mem_if_hps_emif
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "[::alt_mem_if::util::hwtcl_utils::mem_ifs_group_name]/HPS Interfaces"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "HPS DDRx SDRAM Controller with UniPHY"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property DATASHEET_URL "http://www.altera.com/literature/lit-external-memory-interface.jsp"

add_display_item "" "Block Diagram" GROUP



create_emif_gui






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

	::alt_mem_if::util::hwtcl_utils::print_user_parameter_values

	set protocol [string tolower [get_parameter_value HPS_PROTOCOL]]
	set verification [expr [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] == 0]
	set simulation [expr [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] == 0]
	set synthesis [expr !$verification && !$simulation]


	set CLOCK pll_ref_clk
	set RESET global_reset
	
	if {$simulation} {

		set SOFT_RESET global_reset
		
		set CLOCK_PORT clk
		set RESET_PORT reset
		
		add_instance $CLOCK altera_avalon_clock_source
		set_instance_parameter $CLOCK CLOCK_RATE [get_parameter_value REF_CLK_FREQ]

		add_instance $RESET altera_avalon_reset_source
		set_instance_parameter $RESET ASSERT_HIGH_RESET 0
		set_instance_parameter $RESET INITIAL_RESET_CYCLES 5

		add_connection "${CLOCK}.clk/${RESET}.clk"
		
	} else {

		set SOFT_RESET soft_reset
		
		set CLOCK_PORT out_clk
		set RESET_PORT out_reset
		
		add_interface ${CLOCK} clock end
		add_instance ${CLOCK} altera_clock_bridge
		set_interface_property ${CLOCK} export_of ${CLOCK}.in_clk 
		set_interface_property ${CLOCK} PORT_NAME_MAP { pll_ref_clk in_clk }

		add_interface ${RESET} reset end
		add_instance ${RESET} altera_reset_bridge
		set_interface_property ${RESET} export_of ${RESET}.in_reset
		set_instance_parameter ${RESET} SYNCHRONOUS_EDGES none
		set_instance_parameter ${RESET} ACTIVE_LOW_RESET 1
		set_interface_property ${RESET} PORT_NAME_MAP { global_reset_n in_reset_n }
		
		add_interface ${SOFT_RESET} reset end
		add_instance ${SOFT_RESET} altera_reset_bridge
		set_interface_property ${SOFT_RESET} export_of ${SOFT_RESET}.in_reset
		set_instance_parameter ${SOFT_RESET} SYNCHRONOUS_EDGES none
		set_instance_parameter ${SOFT_RESET} ACTIVE_LOW_RESET 1
		set_interface_property ${SOFT_RESET} PORT_NAME_MAP { soft_reset_n in_reset_n }

	}
	
	if {$verification} {
		set num_afi_clk_outputs 1
		set num_afi_reset_outputs 1
	
		add_interface afi_clk clock start
		add_instance afi_clk altera_clock_bridge
		set_instance_parameter afi_clk NUM_CLOCK_OUTPUTS $num_afi_clk_outputs
		set_interface_property afi_clk export_of afi_clk.out_clk
		set_interface_property afi_clk PORT_NAME_MAP { afi_clk out_clk }
		

		add_interface afi_reset reset source
		add_instance afi_reset altera_reset_bridge
		set_instance_parameter afi_reset NUM_RESET_OUTPUTS $num_afi_clk_outputs
		set_interface_property afi_reset export_of afi_reset.out_reset
		set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n out_reset_n }
	}



	set PLL pll
	add_instance $PLL altera_mem_if_hps_pll
	foreach param_name [get_instance_parameters $PLL] {
		set_instance_parameter $PLL $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $PLL
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $PLL
	set_instance_parameter $PLL DISABLE_CHILD_MESSAGING true
	set_instance_parameter $PLL HARD_EMIF true

	add_connection ${CLOCK}.${CLOCK_PORT} ${PLL}.pll_ref_clk
	add_connection ${RESET}.${RESET_PORT} ${PLL}.global_reset

	if {$verification} {
		add_connection ${PLL}.afi_clk afi_clk.in_clk
	}




	set PHY p0
	add_instance $PHY altera_mem_if_${protocol}_hard_phy_core

	foreach param_name [get_instance_parameters $PHY] {
		if {[string compare -nocase $param_name "AVL_ADDR_WIDTH"] == 0 ||
		    [string compare -nocase $param_name "AVL_DATA_WIDTH"] == 0} {
			continue
		}
		set_instance_parameter $PHY $param_name [get_parameter_value $param_name]
	}

	set_instance_parameter $PHY PHY_CSR_ENABLED "false"
	set_instance_parameter $PHY USER_DEBUG_LEVEL 0
	set_instance_parameter $PHY FORCE_DQS_TRACKING ENABLED

	if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {
		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $PHY
	}

	::alt_mem_if::gui::system_info::cache_sys_info_parameters $PHY

	set_instance_parameter $PHY DISABLE_CHILD_MESSAGING true
	set_instance_parameter $PHY HARD_EMIF true

	set afi_clk_source "${PLL}.afi_clk"
	set afi_half_clk_source "${PLL}.afi_half_clk"
	set afi_reset_source "${PHY}.afi_reset"

	add_connection ${SOFT_RESET}.${RESET_PORT} ${PHY}.soft_reset
	add_connection ${RESET}.${RESET_PORT} ${PHY}.global_reset
	add_connection ${afi_clk_source} ${PHY}.afi_clk
	add_connection ${afi_half_clk_source} ${PHY}.afi_half_clk
	if {$verification} {
		add_connection ${afi_reset_source} afi_reset.in_reset
	}

	if {$verification} {
		add_interface memory conduit end
		set_interface_property memory export_of "${PHY}.memory"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY memory memory
		set_interface_assignment "memory" "qsys.ui.export_name" "memory"

		if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
			upvar 1 mem_model_param_list mem_model_param_list
		} else {
			upvar 2 mem_model_param_list mem_model_param_list
		}
		foreach param_name $mem_model_param_list {
			set_module_assignment "testbench.partner.mem_model.parameter.${param_name}" [get_parameter_value $param_name]
		}
	}




	set AFI_SPLITTER as
	add_instance $AFI_SPLITTER altera_mem_if_${protocol}_afi_splitter
	foreach param_name [get_instance_parameters $AFI_SPLITTER] {
		set_instance_parameter $AFI_SPLITTER $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $AFI_SPLITTER
	set_instance_parameter $AFI_SPLITTER DISABLE_CHILD_MESSAGING true

	set_instance_parameter $AFI_SPLITTER HARD_EMIF true
	set_instance_parameter $AFI_SPLITTER FORCE_DQS_TRACKING ENABLED

	add_connection ${AFI_SPLITTER}.mux_afi ${PHY}.afi
	add_connection ${AFI_SPLITTER}.afi_mem_clk_disable ${PHY}.afi_mem_clk_disable




	if {!$synthesis} {
		set SEQ s0
		add_instance $SEQ altera_mem_if_hhp_${protocol}_qseq
		foreach param_name [get_instance_parameters $SEQ] {
			if {[string compare -nocase $param_name "AVL_ADDR_WIDTH"] == 0 ||
			    [string compare -nocase $param_name "AVL_DATA_WIDTH"] == 0} {
				continue
			}

			set_instance_parameter $SEQ $param_name [get_parameter_value $param_name]
		}
		set_instance_parameter $SEQ HARD_EMIF true

		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $SEQ
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $SEQ
		set_instance_parameter $SEQ DISABLE_CHILD_MESSAGING true



		add_connection ${PHY}.avl_clk ${SEQ}.avl_clk
		add_connection ${PHY}.avl_reset ${SEQ}.avl_reset
		add_connection ${PHY}.scc_clk ${SEQ}.scc_clk
		add_connection ${PHY}.scc_reset ${SEQ}.scc_reset

		add_connection ${PHY}.avl_clk ${SEQ}.apb_clk
		add_connection ${PHY}.avl_reset ${SEQ}.apb_reset
	
		add_connection ${SEQ}.avl ${PHY}.avl

		add_connection ${SEQ}.scc ${PHY}.scc
		add_connection ${SEQ}.afi_init_cal_req ${AFI_SPLITTER}.afi_init_cal_req

		add_connection ${SEQ}.tracking ${AFI_SPLITTER}.tracking

		if {$verification} {
			add_instance apb_bfm seq_sim_apb_bfm

			set_instance_parameter_value apb_bfm DWIDTH    32
			set_instance_parameter_value apb_bfm AWIDTH    32

			add_connection apb_bfm.apb_master ${SEQ}.apb_slave

			add_connection ${PHY}.avl_clk     apb_bfm.pclk
			add_connection ${PHY}.avl_reset   apb_bfm.sp_reset_n
		} else {

			set MEM_BASE_ADDRESS "0x00010000"
			set APB_BASE_ADDRESS "0x00020000"  
			set SEQUENCER_MEM_SIZE 32768
		
			add_instance avl2apb altera_mem_if_avalon2apb_bridge
			set_instance_parameter_value avl2apb DWIDTH    32
			set_instance_parameter_value avl2apb AWIDTH    16

			add_instance sequencer_mem altera_mem_if_sequencer_mem
			set sequencer_mem_num_words [expr {$SEQUENCER_MEM_SIZE/(32/8)}]
			set_instance_parameter_value sequencer_mem AVL_ADDR_WIDTH [expr {ceil(log($sequencer_mem_num_words)/log(2.0))}]
			set_instance_parameter_value sequencer_mem AVL_DATA_WIDTH 32
			set_instance_parameter_value sequencer_mem AVL_SYMBOL_WIDTH 8
			set_instance_parameter_value sequencer_mem INIT_FILE "hps_sequencer_mem.hex"
			set_instance_parameter_value sequencer_mem MEM_SIZE $SEQUENCER_MEM_SIZE

			add_instance cpu_inst altera_mem_if_sequencer_cpu
			set_instance_parameter_value cpu_inst AVL_INST_ADDR_WIDTH 17
			set_instance_parameter_value cpu_inst AVL_DATA_ADDR_WIDTH 20
			set_instance_parameter_value cpu_inst DEVICE_FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
			set_instance_parameter_value cpu_inst setting_showUnpublishedSettings "false"
			set_instance_parameter_value cpu_inst setting_showInternalSettings "false"
			set_instance_parameter_value cpu_inst setting_shadowRegisterSets "0"
			set_instance_parameter_value cpu_inst setting_preciseSlaveAccessErrorException "false"
			set_instance_parameter_value cpu_inst setting_preciseIllegalMemAccessException "false"
			set_instance_parameter_value cpu_inst setting_preciseDivisionErrorException "false"
			set_instance_parameter_value cpu_inst setting_performanceCounter "false"
			set_instance_parameter_value cpu_inst setting_perfCounterWidth "_32"
			set_instance_parameter_value cpu_inst setting_interruptControllerType "Internal"
			set_instance_parameter_value cpu_inst setting_illegalMemAccessDetection "false"
			set_instance_parameter_value cpu_inst setting_illegalInstructionsTrap "false"
			set_instance_parameter_value cpu_inst setting_fullWaveformSignals "false"
			set_instance_parameter_value cpu_inst setting_extraExceptionInfo "false"
			set_instance_parameter_value cpu_inst setting_exportPCB "false"
			set_instance_parameter_value cpu_inst setting_debugSimGen "false"
			set_instance_parameter_value cpu_inst setting_clearXBitsLDNonBypass "true"
			set_instance_parameter_value cpu_inst setting_branchPredictionType "Automatic"
			set_instance_parameter_value cpu_inst setting_bit31BypassDCache "true"
			set_instance_parameter_value cpu_inst setting_bigEndian "false"
			set_instance_parameter_value cpu_inst setting_bhtPtrSz "_8"
			set_instance_parameter_value cpu_inst setting_bhtIndexPcOnly "false"
			set_instance_parameter_value cpu_inst setting_avalonDebugPortPresent "false"
			set_instance_parameter_value cpu_inst setting_alwaysEncrypt "true"
			set_instance_parameter_value cpu_inst setting_allowFullAddressRange "false"
			set_instance_parameter_value cpu_inst setting_activateTrace "true"
			set_instance_parameter_value cpu_inst setting_activateTestEndChecker "false"
			set_instance_parameter_value cpu_inst setting_activateMonitors "true"
			set_instance_parameter_value cpu_inst setting_activateModelChecker "false"
			set_instance_parameter_value cpu_inst setting_HDLSimCachesCleared "true"
			set_instance_parameter_value cpu_inst setting_HBreakTest "false"
			set_instance_parameter_value cpu_inst resetSlave "sequencer_mem.s1"
			set_instance_parameter_value cpu_inst resetOffset "0"
			set_instance_parameter_value cpu_inst muldiv_multiplierType "DSPBlock"
			set_instance_parameter_value cpu_inst muldiv_divider "false"
			set_instance_parameter_value cpu_inst mpu_useLimit "false"
			set_instance_parameter_value cpu_inst mpu_numOfInstRegion "8"
			set_instance_parameter_value cpu_inst mpu_numOfDataRegion "8"
			set_instance_parameter_value cpu_inst mpu_minInstRegionSize "_12"
			set_instance_parameter_value cpu_inst mpu_minDataRegionSize "_12"
			set_instance_parameter_value cpu_inst mpu_enabled "false"
			set_instance_parameter_value cpu_inst mmu_uitlbNumEntries "_4"
			set_instance_parameter_value cpu_inst mmu_udtlbNumEntries "_6"
			set_instance_parameter_value cpu_inst mmu_tlbPtrSz "_7"
			set_instance_parameter_value cpu_inst mmu_tlbNumWays "_16"
			set_instance_parameter_value cpu_inst mmu_processIDNumBits "_8"
			set_instance_parameter_value cpu_inst mmu_enabled "false"
			set_instance_parameter_value cpu_inst mmu_autoAssignTlbPtrSz "true"
			set_instance_parameter_value cpu_inst mmu_TLBMissExcSlave ""
			set_instance_parameter_value cpu_inst mmu_TLBMissExcOffset "0"
			set_instance_parameter_value cpu_inst manuallyAssignCpuID "false"
			set_instance_parameter_value cpu_inst impl "Tiny"
			set_instance_parameter_value cpu_inst icache_size "_4096"
			set_instance_parameter_value cpu_inst icache_ramBlockType "Automatic"
			set_instance_parameter_value cpu_inst icache_numTCIM "_0"
			set_instance_parameter_value cpu_inst icache_burstType "None"
			set_instance_parameter_value cpu_inst exceptionSlave "sequencer_mem.s1"
			set_instance_parameter_value cpu_inst exceptionOffset "32"
			set_instance_parameter_value cpu_inst debug_triggerArming "true"
			set_instance_parameter_value cpu_inst debug_jtagInstanceID "0"
			set_instance_parameter_value cpu_inst debug_embeddedPLL "true"
			set_instance_parameter_value cpu_inst debug_debugReqSignals "false"
			set_instance_parameter_value cpu_inst debug_assignJtagInstanceID "false"
			set_instance_parameter_value cpu_inst debug_OCIOnchipTrace "_128"
			set_instance_parameter_value cpu_inst dcache_size "_2048"
			set_instance_parameter_value cpu_inst dcache_ramBlockType "Automatic"
			set_instance_parameter_value cpu_inst dcache_omitDataMaster "false"
			set_instance_parameter_value cpu_inst dcache_numTCDM "_0"
			set_instance_parameter_value cpu_inst dcache_lineSize "_32"
			set_instance_parameter_value cpu_inst dcache_bursts "false"
			set_instance_parameter_value cpu_inst cpuReset "false"
			set_instance_parameter_value cpu_inst cpuID "0"
			set_instance_parameter_value cpu_inst is_hardcopy_compatible "false"
			set_instance_parameter_value cpu_inst breakSlave "sequencer_mem.s1"
			set_instance_parameter_value cpu_inst debug_level "NoDebug"
			set_instance_parameter_value cpu_inst breakOffset "32"

			add_connection ${PHY}.avl_clk   sequencer_mem.clk1
			add_connection ${PHY}.avl_reset sequencer_mem.reset1
			
			add_connection ${PHY}.avl_clk   cpu_inst.clk
			add_connection ${PHY}.avl_reset cpu_inst.reset_n

			add_connection cpu_inst.data_master sequencer_mem.s1
			set_connection_parameter cpu_inst.data_master/sequencer_mem.s1 arbitrationPriority "1"
			set_connection_parameter cpu_inst.data_master/sequencer_mem.s1 baseAddress $MEM_BASE_ADDRESS
			
			add_connection cpu_inst.instruction_master sequencer_mem.s1
			set_connection_parameter cpu_inst.instruction_master/sequencer_mem.s1 arbitrationPriority "1"
			set_connection_parameter cpu_inst.instruction_master/sequencer_mem.s1 baseAddress $MEM_BASE_ADDRESS
			
			add_connection cpu_inst.data_master avl2apb.avalon_slave
			set_connection_parameter cpu_inst.data_master/avl2apb.avalon_slave arbitrationPriority "1"
			set_connection_parameter cpu_inst.data_master/avl2apb.avalon_slave baseAddress $APB_BASE_ADDRESS

			add_connection ${PHY}.avl_clk     avl2apb.pclk
			add_connection ${PHY}.avl_reset   avl2apb.sp_reset_n
			
			add_connection avl2apb.apb_master ${SEQ}.apb_slave

		}
	} else {
		set SEQ seq
		add_instance $SEQ altera_mem_if_hhp_${protocol}_qseq
		foreach param_name [get_instance_parameters $SEQ] {
			if {[string compare -nocase $param_name "AVL_ADDR_WIDTH"] == 0 ||
			    [string compare -nocase $param_name "AVL_DATA_WIDTH"] == 0} {
				continue
			}

			set_instance_parameter $SEQ $param_name [get_parameter_value $param_name]
		}
		set_instance_parameter $SEQ HARD_EMIF true

		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $SEQ
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $SEQ
		set_instance_parameter $SEQ DISABLE_CHILD_MESSAGING true
	}
	

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {

		set CONTROLLER c0
		if {!$simulation} {
			::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller "${protocol}" $CONTROLLER $afi_clk_source $afi_half_clk_source $afi_reset_source 1 1
			foreach param_name [get_instance_parameters $CONTROLLER] {
				set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
			}
			set_instance_parameter $CONTROLLER CTL_CSR_ENABLED false
			set_instance_parameter $CONTROLLER FORCE_DQS_TRACKING ENABLED
		} else {
			add_instance $CONTROLLER altera_mem_if_hps_${protocol}_memory_controller
			foreach param_name [get_instance_parameters $CONTROLLER] {
				set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
			}
			set_instance_parameter $CONTROLLER CTL_CSR_ENABLED true
			set_instance_parameter $CONTROLLER FORCE_DQS_TRACKING ENABLED
		}

		add_connection ${CONTROLLER}.afi ${AFI_SPLITTER}.afi

		add_connection ${CONTROLLER}.hard_phy_cfg ${PHY}.hard_phy_cfg

		if {!$simulation} {

			for {set port_id 0} {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} {
				add_interface mp_cmd_clk_${port_id} clock end
				set_interface_property mp_cmd_clk_${port_id} export_of "${CONTROLLER}.mp_cmd_clk_${port_id}"

				add_interface mp_cmd_reset_n_${port_id} reset end
				set_interface_property mp_cmd_reset_n_${port_id} export_of "${CONTROLLER}.mp_cmd_reset_n_${port_id}"

			}

			for {set fifo_id 0} {$fifo_id < 4} {incr fifo_id} {
				if {[string compare -nocase [get_parameter_value ENUM_RD_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
					add_interface mp_rfifo_clk_${fifo_id} clock end
					set_interface_property mp_rfifo_clk_${fifo_id} export_of "${CONTROLLER}.mp_rfifo_clk_${fifo_id}"

					add_interface mp_rfifo_reset_n_${fifo_id} reset end
					set_interface_property mp_rfifo_reset_n_${fifo_id} export_of "${CONTROLLER}.mp_rfifo_reset_n_${fifo_id}"
				}

				if {[string compare -nocase [get_parameter_value ENUM_WR_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
					add_interface mp_wfifo_clk_${fifo_id} clock end
					set_interface_property mp_wfifo_clk_${fifo_id} export_of "${CONTROLLER}.mp_wfifo_clk_${fifo_id}"

					add_interface mp_wfifo_reset_n_${fifo_id} reset end
					set_interface_property mp_wfifo_reset_n_${fifo_id} export_of "${CONTROLLER}.mp_wfifo_reset_n_${fifo_id}"
				}
			}
		} else {
			add_interface hps_f2sdram conduit end
			set_interface_property hps_f2sdram export_of "${CONTROLLER}.hps_f2sdram"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER hps_f2sdram hps_f2sdram
		}

		if {$verification} {
			::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface $CONTROLLER status status
			::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces $CONTROLLER
		}

		if {$simulation} {
			add_connection ${PHY}.avl_clk     ${CONTROLLER}.csr_clk
			add_connection ${PHY}.avl_reset   ${CONTROLLER}.csr_reset_n
			add_connection ${SEQ}.mmr_avl     ${CONTROLLER}.csr
		} elseif ($verification) {
			add_instance mmr      altera_avalon_onchip_memory2
			set_instance_parameter_value mmr allowInSystemMemoryContentEditor "false"
			set_instance_parameter_value mmr blockType                        "AUTO"
			set_instance_parameter_value mmr dataWidth                        "32"
			set_instance_parameter_value mmr dualPort                         "false"
			set_instance_parameter_value mmr initMemContent                   "false"
			set_instance_parameter_value mmr writable                         "true"
			set_instance_parameter_value mmr instanceID                       "NONE"
			set_instance_parameter_value mmr memorySize                       "32"
			set_instance_parameter_value mmr readDuringWriteMode              "DONT_CARE"
			set_instance_parameter_value mmr simAllowMRAMContentsFile         "false"
			set_instance_parameter_value mmr slave1Latency                    "1"
			set_instance_parameter_value mmr useShallowMemBlocks              "false"
			add_connection ${PHY}.avl_clk        mmr.clk1
			add_connection ${PHY}.avl_reset      mmr.reset1
			add_connection ${SEQ}.mmr_avl        mmr.s1
		}
		
		add_connection ${PHY}.ctl_clk ${CONTROLLER}.ctl_clk
		add_connection ${PHY}.ctl_reset ${CONTROLLER}.ctl_reset
		if {!$simulation} {
			add_connection ${PHY}.io_int ${CONTROLLER}.io_int
		}
		
	} else {

		if {!$synthesis} {
			add_interface afi conduit end
			set_interface_property afi export_of "${AFI_SPLITTER}.afi"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $AFI_SPLITTER afi afi
		}
	}

	if {$simulation} {
		set MEM_MODEL "mem"
		add_instance $MEM_MODEL altera_mem_if_${protocol}_mem_model
		foreach param_name [get_instance_parameters $MEM_MODEL] {
			set_instance_parameter $MEM_MODEL $param_name [get_parameter_value $param_name]
		}
		set_instance_parameter $MEM_MODEL DISABLE_CHILD_MESSAGING true
		
		add_connection "${PHY}.memory/${MEM_MODEL}.memory"
	} elseif {$synthesis} {
		add_interface memory conduit end
		set_interface_property memory export_of "${PHY}.memory"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY memory memory
		set_interface_assignment "memory" "qsys.ui.export_name" "memory"
	}



	set OCT oct
	add_instance $OCT altera_mem_if_oct
	foreach param_name [get_instance_parameters $OCT] {
		set_instance_parameter $OCT $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $OCT
	set_instance_parameter $OCT DISABLE_CHILD_MESSAGING true

	set_instance_parameter $OCT HARD_EMIF true




	if {!$simulation} {
		add_interface oct conduit end
		set_interface_property oct export_of "${OCT}.oct"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $OCT oct oct
		set_interface_assignment "oct" "qsys.ui.export_name" "oct"

		add_connection ${OCT}.oct_sharing ${PHY}.oct_sharing
	}



	add_connection ${PLL}.pll_sharing ${PHY}.pll_sharing



	set DLL dll
	add_instance $DLL altera_mem_if_dll
	foreach param_name [get_instance_parameters $DLL] {
		set_instance_parameter $DLL $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $DLL
	set_instance_parameter $DLL DISABLE_CHILD_MESSAGING true

	set_instance_parameter $DLL HARD_EMIF true

	add_connection ${PHY}.dll_clk ${DLL}.clk



	add_connection ${DLL}.dll_sharing ${PHY}.dll_sharing
}


add_fileset example_design EXAMPLE_DESIGN generate_example

proc generate_example {name} {

	alt_mem_if::gen::uniphy_gen::generate_example_design_fileset HPS $name

}

