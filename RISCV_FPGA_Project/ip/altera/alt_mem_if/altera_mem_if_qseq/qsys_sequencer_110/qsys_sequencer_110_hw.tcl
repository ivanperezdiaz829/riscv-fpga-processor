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

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini

namespace import ::alt_mem_if::util::messaging::*

set_module_property NAME qsys_sequencer_110
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencers_group_name] 
set_module_property DISPLAY_NAME "UniPHY NIOS Sequencer (11.0)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false


add_parameter SYS_INFO_DEVICE_FAMILY STRING "" 
set_parameter_property SYS_INFO_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property SYS_INFO_DEVICE_FAMILY VISIBLE FALSE

add_parameter PARSE_FRIENDLY_DEVICE_FAMILY STRING "" 
set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY DERIVED true
set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY VISIBLE FALSE

add_parameter RATE string "Half"
set_parameter_property RATE DEFAULT_VALUE "Half"
set_parameter_property RATE DISPLAY_NAME RATE
set_parameter_property RATE ALLOWED_RANGES {Quarter Half Full}

add_parameter HPS_PROTOCOL string "DDR3"
set_parameter_property HPS_PROTOCOL DISPLAY_NAME HPS_PROTOCOL
set_parameter_property HPS_PROTOCOL ALLOWED_RANGES {DDR2 DDR3 LPDDR2 LPDDR1 QDRII RLDRAMII RLDRAM3}

::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_USE_DR_CLK BOOLEAN false
set_parameter_property DLL_USE_DR_CLK VISIBLE false
set_parameter_property DLL_USE_DR_CLK DERIVED false

add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME AVL_DATA_WIDTH

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH

add_parameter MEM_IF_DQ_WIDTH INTEGER 64
set_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME MEM_IF_DQ_WIDTH

add_parameter MEM_IF_DM_WIDTH INTEGER 8
set_parameter_property MEM_IF_DM_WIDTH DISPLAY_NAME MEM_IF_DM_WIDTH

add_parameter MEM_BURST_LENGTH INTEGER 4
set_parameter_property MEM_BURST_LENGTH DISPLAY_NAME MEM_BURST_LENGTH

add_parameter DUAL_WRITE_CLOCK boolean "FALSE"
set_parameter_property DUAL_WRITE_CLOCK DISPLAY_NAME DUAL_WRITE_CLOCK

add_parameter DLL_DELAY_CHAIN_LENGTH INTEGER 6
set_parameter_property DLL_DELAY_CHAIN_LENGTH DISPLAY_NAME DLL_DELAY_CHAIN_LENGTH

add_parameter DELAY_PER_OPA_TAP INTEGER 6
set_parameter_property DELAY_PER_OPA_TAP DISPLAY_NAME DELAY_PER_OPA_TAP

add_parameter DELAY_PER_DCHAIN_TAP INTEGER 6
set_parameter_property DELAY_PER_DCHAIN_TAP DISPLAY_NAME DELAY_PER_DCHAIN_TAP

add_parameter MAX_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property MAX_LATENCY_COUNT_WIDTH DISPLAY_NAME MAX_LATENCY_COUNT_WIDTH

add_parameter AFI_DEBUG_INFO_WIDTH INTEGER 32
set_parameter_property AFI_DEBUG_INFO_WIDTH DISPLAY_NAME AFI_DEBUG_INFO_WIDTH

add_parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH DISPLAY_NAME AFI_MAX_WRITE_LATENCY_COUNT_WIDTH

add_parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH DISPLAY_NAME AFI_MAX_READ_LATENCY_COUNT_WIDTH

add_parameter CALIB_VFIFO_OFFSET INTEGER 14
set_parameter_property CALIB_VFIFO_OFFSET DISPLAY_NAME CALIB_VFIFO_OFFSET

add_parameter CALIB_LFIFO_OFFSET INTEGER 5
set_parameter_property CALIB_LFIFO_OFFSET DISPLAY_NAME CALIB_LFIFO_OFFSET

add_parameter CALIB_REG_WIDTH INTEGER 8
set_parameter_property CALIB_REG_WIDTH DISPLAY_NAME CALIB_REG_WIDTH

add_parameter READ_VALID_FIFO_SIZE INTEGER 16
set_parameter_property READ_VALID_FIFO_SIZE DISPLAY_NAME READ_VALID_FIFO_SIZE

add_parameter MEM_T_WL INTEGER 5
set_parameter_property MEM_T_WL DISPLAY_NAME MEM_T_WL

add_parameter MEM_T_RL INTEGER 7
set_parameter_property MEM_T_RL DEFAULT_VALUE 7
set_parameter_property MEM_T_RL WIDTH 1

add_parameter CTL_REGDIMM_ENABLED INTEGER 0
set_parameter_property CTL_REGDIMM_ENABLED DISPLAY_NAME CTL_REGDIMM_ENABLED

add_parameter AFI_ADDRESS_WIDTH INTEGER 64
set_parameter_property AFI_ADDRESS_WIDTH DISPLAY_NAME AFI_ADDRESS_WIDTH

add_parameter AFI_CONTROL_WIDTH INTEGER 8
set_parameter_property AFI_CONTROL_WIDTH DISPLAY_NAME AFI_CONTROL_WIDTH

add_parameter AFI_DATA_WIDTH INTEGER 64
set_parameter_property AFI_DATA_WIDTH DISPLAY_NAME AFI_DATA_WIDTH

add_parameter AFI_DATA_MASK_WIDTH INTEGER 8
set_parameter_property AFI_DATA_MASK_WIDTH DISPLAY_NAME AFI_DATA_MASK_WIDTH

add_parameter AFI_DQS_WIDTH INTEGER 4
set_parameter_property AFI_DQS_WIDTH DISPLAY_NAME AFI_DQS_WIDTH

add_parameter MEM_IF_READ_DQS_WIDTH INTEGER 8
set_parameter_property MEM_IF_READ_DQS_WIDTH DISPLAY_NAME MEM_IF_READ_DQS_WIDTH

add_parameter MEM_IF_WRITE_DQS_WIDTH INTEGER 8
set_parameter_property MEM_IF_WRITE_DQS_WIDTH DISPLAY_NAME MEM_IF_WRITE_DQS_WIDTH

add_parameter NUM_WRITE_FR_CYCLE_SHIFTS INTEGER 0
set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS DISPLAY_NAME NUM_WRITE_FR_CYCLE_SHIFTS

add_parameter MEM_NUMBER_OF_RANKS INTEGER 1
set_parameter_property MEM_NUMBER_OF_RANKS DISPLAY_NAME MEM_NUMBER_OF_RANKS

add_parameter AFI_BANK_WIDTH INTEGER 8
set_parameter_property AFI_BANK_WIDTH DISPLAY_NAME AFI_BANK_WIDTH

add_parameter AFI_CHIP_SELECT_WIDTH INTEGER 5
set_parameter_property AFI_CHIP_SELECT_WIDTH DISPLAY_NAME AFI_CHIP_SELECT_WIDTH

add_parameter AFI_CLK_EN_WIDTH INTEGER 2
set_parameter_property AFI_CLK_EN_WIDTH DISPLAY_NAME AFI_CLK_EN_WIDTH

add_parameter AFI_ODT_WIDTH INTEGER 2
set_parameter_property AFI_ODT_WIDTH DISPLAY_NAME AFI_ODT_WIDTH

add_parameter MEM_CHIP_SELECT_WIDTH INTEGER 2
set_parameter_property MEM_CHIP_SELECT_WIDTH DISPLAY_NAME MEM_CHIP_SELECT_WIDTH

add_parameter RDIMM INTEGER 1
set_parameter_property RDIMM DISPLAY_NAME RDIMM

add_parameter LRDIMM INTEGER 1
set_parameter_property LRDIMM DISPLAY_NAME LRDIMM

add_parameter RDIMM_CONFIG INTEGER 1
set_parameter_property RDIMM_CONFIG DISPLAY_NAME RDIMM_CONFIG

add_parameter SEQ_ROM string ""
set_parameter_property SEQ_ROM DISPLAY_NAME SEQ_ROM

add_parameter RAM_BLOCK_TYPE string "AUTO"
set_parameter_property RAM_BLOCK_TYPE DISPLAY_NAME RAM_BLOCK_TYPE
set_parameter_property RAM_BLOCK_TYPE ALLOWED_RANGES {"AUTO:Auto" "MLAB:MLAB"}

add_parameter MEM_ADDRESS_WIDTH INTEGER 20
set_parameter_property MEM_ADDRESS_WIDTH DISPLAY_NAME MEM_ADDRESS_WIDTH

add_parameter MEM_CONTROL_WIDTH INTEGER 2
set_parameter_property MEM_CONTROL_WIDTH DISPLAY_NAME MEM_CONTROL_WIDTH

add_parameter MEM_CLK_EN_WIDTH INTEGER 2
set_parameter_property MEM_CLK_EN_WIDTH DISPLAY_NAME MEM_CLK_EN_WIDTH

add_parameter MEM_BANK_WIDTH INTEGER 3
set_parameter_property MEM_BANK_WIDTH DISPLAY_NAME MEM_BANK_WIDTH

add_parameter MEM_ODT_WIDTH INTEGER 2
set_parameter_property MEM_ODT_WIDTH DISPLAY_NAME MEM_ODT_WIDTH

add_parameter MEM_CHIP_SELECT_WIDTH INTEGER 2
set_parameter_property MEM_CHIP_SELECT_WIDTH DISPLAY_NAME MEM_CHIP_SELECT_WIDTH

add_parameter USE_DQS_TRACKING boolean "FALSE"
set_parameter_property USE_DQS_TRACKING DISPLAY_NAME USE_DQS_TRACKING
set_parameter_property USE_DQS_TRACKING AFFECTS_ELABORATION true

add_parameter USE_SHADOW_REGS boolean "FALSE"
set_parameter_property USE_SHADOW_REGS DISPLAY_NAME USE_SHADOW_REGS
set_parameter_property USE_SHADOW_REGS AFFECTS_ELABORATION true

add_parameter HCX_COMPAT_MODE boolean "FALSE"
set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME HCX_COMPAT_MODE

add_parameter SEQUENCER_VERSION integer 0
set_parameter_property SEQUENCER_VERSION DISPLAY_NAME SEQUENCER_VERSION

add_parameter AC_ROM_INIT_FILE_NAME string "AC_ROM.hex"
set_parameter_property AC_ROM_INIT_FILE_NAME DISPLAY_NAME AC_ROM_INIT_FILE_NAME

add_parameter INST_ROM_INIT_FILE_NAME string "inst_ROM.hex"
set_parameter_property INST_ROM_INIT_FILE_NAME DISPLAY_NAME INST_ROM_INIT_FILE_NAME

add_parameter ENABLE_NIOS_OCI boolean false
set_parameter_property ENABLE_NIOS_OCI DISPLAY_NAME "Enable NIOS OCI port"

add_parameter ENABLE_DEBUG_BRIDGE boolean false
set_parameter_property ENABLE_DEBUG_BRIDGE DISPLAY_NAME "Enable EMIF toolkit support via JTAG Master"

add_parameter ENABLE_NIOS_JTAG_UART boolean false
set_parameter_property ENABLE_NIOS_JTAG_UART DISPLAY_NAME "Enable JTAG UART"

add_parameter MAKE_INTERNAL_NIOS_VISIBLE boolean false
set_parameter_property MAKE_INTERNAL_NIOS_VISIBLE DISPLAY_NAME "Make internal NIOS visible"

add_parameter ENABLE_LARGE_RW_MGR_DI_BUFFER boolean false
set_parameter_property ENABLE_LARGE_RW_MGR_DI_BUFFER DISPLAY_NAME "Enable large RW Manager DI Buffer"

add_parameter HARD_PHY boolean false
set_parameter_property HARD_PHY DISPLAY_NAME "Enable hard PHY support"

add_parameter USE_SEQUENCER_BFM boolean false
set_parameter_property USE_SEQUENCER_BFM DISPLAY_NAME USE_SEQUENCER_BFM

add_parameter SEQUENCER_MEM_SIZE INTEGER 65536
set_parameter_property SEQUENCER_MEM_SIZE DISPLAY_NAME SEQUENCER_MEM_SIZE

add_parameter SEQUENCER_MEM_ADDRESS_WIDTH INTEGER 13
set_parameter_property SEQUENCER_MEM_ADDRESS_WIDTH DISPLAY_NAME SEQUENCER_MEM_ADDRESS_WIDTH

add_parameter HHP_HPS string "FALSE"
set_parameter_property HHP_HPS DISPLAY_NAME HHP_HPS

add_parameter ENABLE_INST_ROM_WRITE string "FALSE"
set_parameter_property ENABLE_INST_ROM_WRITE DISPLAY_NAME ENABLE_INST_ROM_WRITE

add_parameter HARD_VFIFO boolean false
set_parameter_property HARD_VFIFO DISPLAY_NAME "Enable hard VFIFO variant"

add_parameter IO_DQS_EN_DELAY_OFFSET INTEGER 0
set_parameter_property IO_DQS_EN_DELAY_OFFSET DISPLAY_NAME IO_DQS_EN_DELAY_OFFSET

add_parameter ENABLE_NON_DESTRUCTIVE_CALIB string "TRUE"
set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB DISPLAY_NAME ENABLE_NON_DESTRUCTIVE_CALIB

add_parameter MRS_MIRROR_PING_PONG_ATSO boolean false
set_parameter_property MRS_MIRROR_PING_PONG_ATSO DISPLAY_NAME MRS_MIRROR_PING_PONG_ATSO

add_parameter TRK_PARALLEL_SCC_LOAD boolean false
set_parameter_property TRK_PARALLEL_SCC_LOAD DISPLAY_NAME "Enable tracking manager parallel load"

add_parameter SCC_DATA_WIDTH INTEGER 8
set_parameter_property SCC_DATA_WIDTH DISPLAY_NAME SCC_DATA_WIDTH

if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property VALIDATION_CALLBACK ip_validate
	set_module_property COMPOSITION_CALLBACK do_compose
} else {
	set_module_property COMPOSITION_CALLBACK combined_callback
}

proc combined_callback {} {
	ip_validate
	do_compose
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

	set sys_info_device_family [get_parameter_value SYS_INFO_DEVICE_FAMILY]
	_dprint 1 "SYSTEM_INFO Family = $sys_info_device_family"
	
	if { [regexp  {^[ ]*$} $sys_info_device_family match] == 1 || [string compare -nocase $sys_info_device_family "Unknown"] == 0 } {
		set case_103224_fixed 0
   
		if {$case_103224_fixed} {
			_error "Device family can not be determined"
		} else {
			set sys_info_device_family "STRATIXV"
		}   
	} 
	
	regsub -all {[ ]} $sys_info_device_family "" parse_device_family

	if {[string compare -nocase $parse_device_family "arriaii"] == 0} {
		set parse_device_family "arriaiigx"
	}

	set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY [string toupper $parse_device_family]
	
}

proc do_compose {} {
	set MEM_BASE_ADDRESS "0x00010000"
	set RW_MGR_BASE_ADDRESS "0x00050000"
	set DATA_MGR_BASE_ADDRESS "0x00060000"
	set PTR_MGR_BASE_ADDRESS "0x00040000"
    if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
        set PLL_MGR_BASE_ADDRESS "0x00058000"
    } else {
        set SCC_MGR_BASE_ADDRESS "0x00058000"
    }
	set PHY_MGR_BASE_ADDRESS "0x00048000"
	set REG_FILE_BASE_ADDRESS "0x00070000"
	set TIMER_BASE_ADDRESS "0x00078000"
	set UART_BASE_ADDRESS "0x00080000"

	set CPU_HARD_PHY_BASE "0x00080000"
	set TRK_MM_MASTER_BASE "0x00040000"
	set MMR_BASE_ADDRESS "0x000C0000"

	if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {
		set SEQUENCER_TRK_PHY_MGR_BASE "0x00008000"
		set SEQUENCER_TRK_RW_MGR_BASE "0x00010000"
	} else {
		set SEQUENCER_TRK_HARD_PHY_BASE "0x00080000"
		set SEQUENCER_TRK_PHY_MGR_BASE "0x00088000"
		set SEQUENCER_TRK_RW_MGR_BASE "0x00090000"
	}
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	    set SEQUENCER_TRK_PLL_MGR_BASE "0x00018000"
	} else {
	    set SEQUENCER_TRK_SCC_MGR_BASE "0x00018000"
	}
	set SEQUENCER_TRK_REG_FILE_BASE "0x00030000"
	set SEQUENCER_TRK_TIMER_BASE "0x00038000"
	set SEQUENCER_TRK_PTR_MGR_BASE "0x00000000"
	set SEQUENCER_TRK_DATA_MGR_BASE "0x00020000"
	set TRK_MM_SLAVE_BASE "0x000D0000"
	
	set protocol [get_parameter_value HPS_PROTOCOL]
	

	add_interface avl_clk clock end
	add_instance avl_clk altera_clock_bridge
	set_interface_property avl_clk export_of avl_clk.in_clk 
	set_instance_parameter avl_clk EXPLICIT_CLOCK_RATE 50000000
	set_interface_property avl_clk PORT_NAME_MAP { avl_clk in_clk }
	
	add_interface sequencer_rst reset end
	set_interface_property sequencer_rst export_of sequencer_rst.rst
	add_instance sequencer_rst altera_mem_if_sequencer_rst
	set_instance_parameter sequencer_rst DEPTH 10
	set_instance_parameter sequencer_rst CLKEN_LAGS_RESET 0
	set_interface_property sequencer_rst PORT_NAME_MAP { avl_reset_n rst }
	add_connection avl_clk.out_clk/sequencer_rst.clk

	if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
		add_instance apb2avalon_bridge_inst    altera_hhp_apb2avalon_bridge
		set_instance_parameter_value apb2avalon_bridge_inst DWIDTH		   "32"
		set_instance_parameter_value apb2avalon_bridge_inst AWIDTH		   "32"

		add_instance cpu_inst                  altera_avalon_mm_clock_crossing_bridge
		set CPU_AVL   "m0"
		set CPU_CLK   "m0_clk"
		set CPU_RESET "m0_reset"
	} elseif {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0} {
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_nios_cpu]} {
			add_instance cpu_inst altera_nios2_qsys
		} else {
			add_instance cpu_inst altera_mem_if_sequencer_cpu
		}
		set CPU_AVL   "data_master"
		set CPU_CLK   "clk"
		set CPU_RESET "reset_n"
	} else {
		add_instance cpu_inst seq_sim_bfm
		set CPU_AVL   "data_master"
		set CPU_CLK   "clk"
		set CPU_RESET "reset_n"
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {

		add_interface apb_clk clock end
		add_instance apb_clk altera_clock_bridge
		set_interface_property apb_clk export_of apb_clk.in_clk 
		set_interface_property apb_clk PORT_NAME_MAP { apb_clk in_clk }

		add_interface apb_reset reset end
		add_instance apb_reset altera_reset_bridge
		set_interface_property apb_reset export_of apb_reset.in_reset
		set_instance_parameter apb_reset SYNCHRONOUS_EDGES none
		set_instance_parameter apb_reset ACTIVE_LOW_RESET 1
		set_interface_property apb_reset PORT_NAME_MAP { apb_reset_n in_reset_n }

			add_instance hhp_decompress_bridge     hhp_decompress_avl_mm_bridge

			set_instance_parameter hhp_decompress_bridge DATA_WIDTH 32
			set_instance_parameter hhp_decompress_bridge SYMBOL_WIDTH 8
			set_instance_parameter hhp_decompress_bridge ADDRESS_WIDTH 32
			set_instance_parameter hhp_decompress_bridge ADDRESS_UNITS "SYMBOLS"
			set_instance_parameter hhp_decompress_bridge USE_BYTEENABLE 0
			set_instance_parameter hhp_decompress_bridge USE_READDATAVALID 0

			add_connection "apb_clk.out_clk/hhp_decompress_bridge.clk"
			add_connection "apb_reset.out_reset/hhp_decompress_bridge.reset"
			
			add_connection apb2avalon_bridge_inst.avalon_master/hhp_decompress_bridge.s0
			add_connection hhp_decompress_bridge.m0/cpu_inst.s0

		add_connection apb_clk.out_clk/apb2avalon_bridge_inst.pclk
		add_connection apb_clk.out_clk/cpu_inst.s0_clk

		add_connection apb_reset.out_reset/apb2avalon_bridge_inst.sp_reset_n
		add_connection apb_reset.out_reset/cpu_inst.s0_reset

		add_interface apb_slave conduit end
		set_interface_property apb_slave ENABLED true
		set_interface_property apb_slave export_of apb2avalon_bridge_inst.apb_slave
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports  apb2avalon_bridge_inst apb_slave apb_slave 
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {

		set MMR_BRIDGE mmr_bridge
		add_instance ${MMR_BRIDGE} altera_avalon_mm_bridge

		
		set_instance_parameter_value ${MMR_BRIDGE} DATA_WIDTH                       32
		set_instance_parameter_value ${MMR_BRIDGE} ADDRESS_WIDTH                    8
		set_instance_parameter_value ${MMR_BRIDGE} ADDRESS_UNITS                    "WORDS"
		set_instance_parameter_value ${MMR_BRIDGE} MAX_BURST_SIZE                   1
		set_instance_parameter_value ${MMR_BRIDGE} MAX_PENDING_RESPONSES            4
		set_instance_parameter_value ${MMR_BRIDGE} PIPELINE_COMMAND                 1
		set_instance_parameter_value ${MMR_BRIDGE} PIPELINE_RESPONSE                1

		add_connection "avl_clk.out_clk/${MMR_BRIDGE}.clk"
		add_connection "sequencer_rst.reset_out/${MMR_BRIDGE}.reset"

		add_connection "cpu_inst.${CPU_AVL}/${MMR_BRIDGE}.s0"
		set_connection_parameter_value "cpu_inst.${CPU_AVL}/${MMR_BRIDGE}.s0" baseAddress $MMR_BASE_ADDRESS

		add_interface mmr_avl avalon start
		set_interface_property mmr_avl export_of ${MMR_BRIDGE}.m0

		set_interface_property mmr_avl PORT_NAME_MAP [list \
			mmr_avl_address m0_address \
			mmr_avl_write m0_write \
			mmr_avl_writedata m0_writedata \
			mmr_avl_read m0_read \
			mmr_avl_readdata m0_readdata \
			mmr_avl_waitrequest m0_waitrequest \
			mmr_avl_readdatavalid m0_readdatavalid \
			mmr_avl_burstcount m0_burstcount \
			mmr_avl_be m0_byteenable \
		]

	}

	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	    add_instance sequencer_pll_mgr_inst sequencer_pll_mgr_140
	    set_instance_parameter_value sequencer_pll_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
	    set_instance_parameter_value sequencer_pll_mgr_inst AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH]
	    
	    add_interface pll_reconfig conduit end
		set_interface_property pll_reconfig ENABLED true
		set_interface_property pll_reconfig export_of sequencer_pll_mgr_inst.pll_reconfig
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_pll_mgr_inst pll_reconfig pll_reconfig
	} else {
	    add_instance sequencer_scc_mgr_inst sequencer_scc_mgr_110
	    set_instance_parameter_value sequencer_scc_mgr_inst FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
	    set_instance_parameter_value sequencer_scc_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst MEM_IF_WRITE_DQS_WIDTH [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst MEM_IF_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst MEM_IF_DQ_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst MEM_IF_DM_WIDTH [get_parameter_value MEM_IF_DM_WIDTH]
	    if {[string compare -nocase $protocol "RLDRAM3"] == 0 || [string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
	    	set_instance_parameter_value sequencer_scc_mgr_inst MEM_NUMBER_OF_RANKS [get_parameter_value MEM_NUMBER_OF_RANKS]
	    }
	    if {[string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true"] == 0} {
		set_instance_parameter_value sequencer_scc_mgr_inst USE_2X_DLL "true"
	    } else {
		set_instance_parameter_value sequencer_scc_mgr_inst USE_2X_DLL "false"
	    }
	    set_instance_parameter_value sequencer_scc_mgr_inst DLL_DELAY_CHAIN_LENGTH [get_parameter_value DLL_DELAY_CHAIN_LENGTH]
	    set_instance_parameter_value sequencer_scc_mgr_inst USE_SHADOW_REGS [get_parameter_value USE_SHADOW_REGS]
	    set_instance_parameter_value sequencer_scc_mgr_inst USE_DQS_TRACKING [get_parameter_value USE_DQS_TRACKING]
	    set_instance_parameter_value sequencer_scc_mgr_inst DUAL_WRITE_CLOCK [get_parameter_value DUAL_WRITE_CLOCK]
	    set_instance_parameter_value sequencer_scc_mgr_inst TRK_PARALLEL_SCC_LOAD [get_parameter_value TRK_PARALLEL_SCC_LOAD]
	    set_instance_parameter_value sequencer_scc_mgr_inst SCC_DATA_WIDTH [get_parameter_value SCC_DATA_WIDTH]
	}
	
	add_instance sequencer_reg_file_inst sequencer_reg_file_111
	set_instance_parameter_value sequencer_reg_file_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
	set_instance_parameter_value sequencer_reg_file_inst AVL_ADDR_WIDTH [expr {ceil(log(16)/log(2.0))}]
	set_instance_parameter_value sequencer_reg_file_inst NUM_REGFILE_WORDS 16

	if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
		add_instance sequencer_timer_inst sequencer_timer_120
		set_instance_parameter_value sequencer_timer_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_timer_inst AVL_ADDR_WIDTH 1
		set_instance_parameter_value sequencer_timer_inst AVL_SYMBOL_WIDTH 8
	}
	
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		set TRK_MM_BRIDGE trk_mm_bridge
		add_instance ${TRK_MM_BRIDGE} altera_avalon_mm_bridge

		set_instance_parameter_value ${TRK_MM_BRIDGE} DATA_WIDTH                       [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value ${TRK_MM_BRIDGE} ADDRESS_WIDTH                    16
		set_instance_parameter_value ${TRK_MM_BRIDGE} ADDRESS_UNITS                    "WORDS"
		set_instance_parameter_value ${TRK_MM_BRIDGE} MAX_BURST_SIZE                   1
		set_instance_parameter_value ${TRK_MM_BRIDGE} MAX_PENDING_RESPONSES            1
		set_instance_parameter_value ${TRK_MM_BRIDGE} PIPELINE_COMMAND                 0
		set_instance_parameter_value ${TRK_MM_BRIDGE} PIPELINE_RESPONSE                0

		add_connection avl_clk.out_clk/${TRK_MM_BRIDGE}.clk
		add_connection sequencer_rst.reset_out/${TRK_MM_BRIDGE}.reset

		add_connection cpu_inst.${CPU_AVL}/${TRK_MM_BRIDGE}.s0
		set_connection_parameter_value cpu_inst.${CPU_AVL}/${TRK_MM_BRIDGE}.s0 baseAddress $TRK_MM_MASTER_BASE
	}

	if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {

		add_instance sequencer_phy_mgr_inst sequencer_phy_mgr_100

		add_connection avl_clk.out_clk/sequencer_phy_mgr_inst.avl_clk
		add_connection sequencer_rst.reset_out/sequencer_phy_mgr_inst.avl_reset
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
			add_connection ${TRK_MM_BRIDGE}.m0/sequencer_phy_mgr_inst.avl
	
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_phy_mgr_inst.avl arbitrationPriority "1"
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_phy_mgr_inst.avl baseAddress $SEQUENCER_TRK_PHY_MGR_BASE
		} else {
		add_connection cpu_inst.${CPU_AVL}/sequencer_phy_mgr_inst.avl
	
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_phy_mgr_inst.avl arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_phy_mgr_inst.avl baseAddress $PHY_MGR_BASE_ADDRESS
		}
		
		set_instance_parameter_value sequencer_phy_mgr_inst HPS_PROTOCOL [get_parameter_value HPS_PROTOCOL]
		set_instance_parameter_value sequencer_phy_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst MAX_LATENCY_COUNT_WIDTH [get_parameter_value MAX_LATENCY_COUNT_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst MEM_IF_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst MEM_IF_WRITE_DQS_WIDTH [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst NUM_WRITE_FR_CYCLE_SHIFTS [get_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS]
		set_instance_parameter_value sequencer_phy_mgr_inst AFI_DQ_WIDTH [get_parameter_value AFI_DATA_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst AFI_DEBUG_INFO_WIDTH [get_parameter_value AFI_DEBUG_INFO_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst AFI_MAX_WRITE_LATENCY_COUNT_WIDTH [get_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst AFI_MAX_READ_LATENCY_COUNT_WIDTH [get_parameter_value AFI_MAX_READ_LATENCY_COUNT_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst CALIB_VFIFO_OFFSET [get_parameter_value CALIB_VFIFO_OFFSET]
		set_instance_parameter_value sequencer_phy_mgr_inst CALIB_LFIFO_OFFSET [get_parameter_value CALIB_LFIFO_OFFSET]
		set_instance_parameter_value sequencer_phy_mgr_inst CALIB_REG_WIDTH [get_parameter_value CALIB_REG_WIDTH]
		set_instance_parameter_value sequencer_phy_mgr_inst READ_VALID_FIFO_SIZE [get_parameter_value READ_VALID_FIFO_SIZE]
		set_instance_parameter_value sequencer_phy_mgr_inst MEM_T_WL [get_parameter_value MEM_T_WL]
		set_instance_parameter_value sequencer_phy_mgr_inst MEM_T_RL [get_parameter_value MEM_T_RL]
		set_instance_parameter_value sequencer_phy_mgr_inst CTL_REGDIMM_ENABLED [get_parameter_value CTL_REGDIMM_ENABLED]
		set_instance_parameter_value sequencer_phy_mgr_inst HARD_PHY [get_parameter_value HARD_PHY]
		set_instance_parameter_value sequencer_phy_mgr_inst DEVICE_FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 } {
			if {[string compare -nocase $protocol "QDRII"] == 0 && [expr [get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]] > 9} {
				set_instance_parameter_value sequencer_phy_mgr_inst VFIFO_CONTROL_WIDTH_PER_DQS 4
			} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0 && [expr [get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]] > 9} {
				set_instance_parameter_value sequencer_phy_mgr_inst VFIFO_CONTROL_WIDTH_PER_DQS 2
			} else {
				set_instance_parameter_value sequencer_phy_mgr_inst VFIFO_CONTROL_WIDTH_PER_DQS 1
			}
			
		} else {
			set_instance_parameter_value sequencer_phy_mgr_inst VFIFO_CONTROL_WIDTH_PER_DQS 1
		}
		

		add_interface phy conduit end
		set_interface_property phy ENABLED true
		set_interface_property phy export_of sequencer_phy_mgr_inst.phy
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_phy_mgr_inst phy phy
		
		add_interface mux_sel conduit end
		set_interface_property mux_sel ENABLED true
		set_interface_property mux_sel export_of sequencer_phy_mgr_inst.mux_sel
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_phy_mgr_inst mux_sel mux_sel
		
		add_interface calib conduit end
		set_interface_property calib ENABLED true
		set_interface_property calib export_of sequencer_phy_mgr_inst.calib
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_phy_mgr_inst calib calib
	


		add_instance sequencer_data_mgr_inst sequencer_data_mgr_110

		add_connection avl_clk.out_clk/sequencer_data_mgr_inst.avl_clk
		add_connection sequencer_rst.reset_out/sequencer_data_mgr_inst.avl_reset
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
			add_connection ${TRK_MM_BRIDGE}.m0/sequencer_data_mgr_inst.avl

			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_data_mgr_inst.avl arbitrationPriority "1"
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_data_mgr_inst.avl baseAddress $SEQUENCER_TRK_DATA_MGR_BASE
		} else {
		add_connection cpu_inst.${CPU_AVL}/sequencer_data_mgr_inst.avl

		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_data_mgr_inst.avl arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_data_mgr_inst.avl baseAddress $DATA_MGR_BASE_ADDRESS
		}

		set_instance_parameter_value sequencer_data_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst MAX_LATENCY_COUNT_WIDTH [get_parameter_value MAX_LATENCY_COUNT_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst MEM_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst AFI_DEBUG_INFO_WIDTH [get_parameter_value AFI_DEBUG_INFO_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst AFI_MAX_WRITE_LATENCY_COUNT_WIDTH [get_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst AFI_MAX_READ_LATENCY_COUNT_WIDTH [get_parameter_value AFI_MAX_READ_LATENCY_COUNT_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst CALIB_VFIFO_OFFSET [get_parameter_value CALIB_VFIFO_OFFSET ]
		set_instance_parameter_value sequencer_data_mgr_inst CALIB_LFIFO_OFFSET [get_parameter_value CALIB_LFIFO_OFFSET ]
		set_instance_parameter_value sequencer_data_mgr_inst CALIB_SKIP_STEPS_WIDTH [get_parameter_value CALIB_REG_WIDTH ]
		set_instance_parameter_value sequencer_data_mgr_inst READ_VALID_FIFO_SIZE [get_parameter_value READ_VALID_FIFO_SIZE ]
		set_instance_parameter_value sequencer_data_mgr_inst MEM_T_WL [get_parameter_value MEM_T_WL ]
		set_instance_parameter_value sequencer_data_mgr_inst MEM_T_RL [get_parameter_value MEM_T_RL ]
		set_instance_parameter_value sequencer_data_mgr_inst CTL_REGDIMM_ENABLED [get_parameter_value CTL_REGDIMM_ENABLED ]
		set_instance_parameter_value sequencer_data_mgr_inst SEQUENCER_VERSION [get_parameter_value SEQUENCER_VERSION ]



		add_interface afi_clk clock end
		add_instance afi_clk altera_clock_bridge
		set_interface_property afi_clk export_of afi_clk.in_clk 
		set_interface_property afi_clk PORT_NAME_MAP { afi_clk in_clk }
			
		add_interface afi_reset reset end
		add_instance afi_reset altera_reset_bridge
		set_interface_property afi_reset export_of afi_reset.in_reset
		set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n in_reset_n }

		if {[string compare -nocase [ get_parameter_value HPS_PROTOCOL ] "DDR2" ] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_ddr2_110
		} elseif {[string compare -nocase [ get_parameter_value HPS_PROTOCOL ] "DDR3" ] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_ddr3_110
		} elseif {[string compare -nocase [ get_parameter_value HPS_PROTOCOL ] "LPDDR2"] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_lpddr2_110
		} elseif {[string compare -nocase [ get_parameter_value HPS_PROTOCOL ] "LPDDR1"] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_lpddr_111
		} elseif {[string compare -nocase [get_parameter_value HPS_PROTOCOL] "QDRII"] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_qdrii_110
		} elseif {[string compare -nocase [get_parameter_value HPS_PROTOCOL] "RLDRAMII"] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_rldram_110
		} elseif {[string compare -nocase [get_parameter_value HPS_PROTOCOL] "RLDRAM3"] == 0} {
			add_instance sequencer_rw_mgr_inst sequencer_rw_mgr_rldram3_110
		}

		add_connection avl_clk.out_clk/sequencer_rw_mgr_inst.avl_clk
		add_connection sequencer_rst.reset_out/sequencer_rw_mgr_inst.avl_reset
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
			add_connection ${TRK_MM_BRIDGE}.m0/sequencer_rw_mgr_inst.avl

			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_rw_mgr_inst.avl arbitrationPriority "1"
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_rw_mgr_inst.avl baseAddress $SEQUENCER_TRK_RW_MGR_BASE
		} else {
		add_connection cpu_inst.${CPU_AVL}/sequencer_rw_mgr_inst.avl

		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_rw_mgr_inst.avl arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_rw_mgr_inst.avl baseAddress $RW_MGR_BASE_ADDRESS
		}
		
		add_connection "afi_clk.out_clk/sequencer_rw_mgr_inst.afi_clk"
		add_connection "afi_reset.out_reset/sequencer_rw_mgr_inst.afi_reset"

		set_instance_parameter_value sequencer_rw_mgr_inst DEVICE_FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
		set_instance_parameter_value sequencer_rw_mgr_inst RATE [get_parameter_value RATE]
		set_instance_parameter_value sequencer_rw_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_ADDRESS_WIDTH [get_parameter_value MEM_ADDRESS_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_CONTROL_WIDTH [get_parameter_value MEM_CONTROL_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_DQ_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_DM_WIDTH [get_parameter_value MEM_IF_DM_WIDTH]

		if {[string compare -nocase [get_parameter_value ENABLE_INST_ROM_WRITE] "true"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst HCX_COMPAT_MODE true
		} else {
		set_instance_parameter_value sequencer_rw_mgr_inst HCX_COMPAT_MODE [get_parameter_value HCX_COMPAT_MODE]
		}
		set_instance_parameter_value sequencer_rw_mgr_inst AC_ROM_INIT_FILE_NAME [get_parameter_value AC_ROM_INIT_FILE_NAME]
		set_instance_parameter_value sequencer_rw_mgr_inst INST_ROM_INIT_FILE_NAME [get_parameter_value INST_ROM_INIT_FILE_NAME]
		
		if {[string compare -nocase [get_parameter_value ENABLE_LARGE_RW_MGR_DI_BUFFER] "true"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MAX_DI_BUFFER_WORDS 64
		} else {
			set_instance_parameter_value sequencer_rw_mgr_inst MAX_DI_BUFFER_WORDS 4
		}
		
		if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst USE_SHADOW_REGS true
		}
		
		if {[string compare -nocase $protocol "QDRII"] != 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_BANK_WIDTH [get_parameter_value MEM_BANK_WIDTH]
		}
		if {[string compare -nocase $protocol "QDRII"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_BURST_LENGTH [get_parameter_value MEM_BURST_LENGTH]
		}

		if {[get_parameter_value MRS_MIRROR_PING_PONG_ATSO]} {
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_CHIP_SELECT_WIDTH [expr {[get_parameter_value MEM_CHIP_SELECT_WIDTH] * 2}]
		} else {
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_CHIP_SELECT_WIDTH [get_parameter_value MEM_CHIP_SELECT_WIDTH]
		}
		
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
		set_instance_parameter_value sequencer_rw_mgr_inst MEM_WRITE_DQS_WIDTH [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
		if {[string compare -nocase $protocol "RLDRAM3"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_NUMBER_OF_RANKS [get_parameter_value MEM_NUMBER_OF_RANKS]
		}
		if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_NUMBER_OF_RANKS [get_parameter_value MEM_NUMBER_OF_RANKS]
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_ODT_WIDTH [get_parameter_value MEM_ODT_WIDTH]
			set_instance_parameter_value sequencer_rw_mgr_inst MEM_CLK_EN_WIDTH [get_parameter_value MEM_CLK_EN_WIDTH]
		} else {
			set_instance_parameter_value sequencer_rw_mgr_inst VIRTUAL_MEM_READ_DQS_WIDTH [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / 9}]
			set_instance_parameter_value sequencer_rw_mgr_inst VIRTUAL_MEM_WRITE_DQS_WIDTH [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / 9}]
		}

		if {[string compare -nocase $protocol "DDR3" ] == 0} {
			set_instance_parameter_value sequencer_rw_mgr_inst MRS_MIRROR_PING_PONG_ATSO [get_parameter_value MRS_MIRROR_PING_PONG_ATSO]
		}

		if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
			set afi_rate 1
		} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
			set afi_rate 2
		} else {
			set afi_rate 4
		}

		if {[string compare -nocase $protocol "DDR2" ] == 0} {
			if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 25
			} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 26
			} else {
			}
		} elseif {[string compare -nocase $protocol "DDR3" ] == 0} {
			if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 26
			} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 27
			} else {
				set ac_bus_width 29
			}
		} elseif {[string compare -nocase $protocol "LPDDR2"] == 0} {
			if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 25
			} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 26
			} else {
			}
		} elseif {[string compare -nocase $protocol "LPDDR1" ] == 0} {
			if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 25
			} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 26
			} else {
			}
		} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
			set ac_bus_width 27
		} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0} {
			if {[string first "FULL" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 30
			} elseif {[string first "HALF" [string toupper [get_parameter_value RATE]]] >= 0} {
				set ac_bus_width 29
			} else {
			}
		} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
			set ac_bus_width 30
		}
		
		set_instance_parameter_value sequencer_rw_mgr_inst AFI_RATIO $afi_rate
		set_instance_parameter_value sequencer_rw_mgr_inst AC_BUS_WIDTH $ac_bus_width
			
		add_interface afi conduit end
		set_interface_property afi ENABLED true
		set_interface_property afi export_of sequencer_rw_mgr_inst.afi
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_rw_mgr_inst afi afi
	
	} else {


		set HPHY_BRIDGE hphy_bridge
		add_instance ${HPHY_BRIDGE} altera_mem_if_simple_avalon_mm_bridge 

		set_instance_parameter ${HPHY_BRIDGE} DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter ${HPHY_BRIDGE} SYMBOL_WIDTH 8
		set_instance_parameter ${HPHY_BRIDGE} ADDRESS_WIDTH 16
		set_instance_parameter ${HPHY_BRIDGE} ADDRESS_UNITS "WORDS"
		set_instance_parameter ${HPHY_BRIDGE} USE_BYTEENABLE 0
		set_instance_parameter ${HPHY_BRIDGE} USE_READDATAVALID 0
		if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
			set_instance_parameter ${HPHY_BRIDGE} WORKAROUND_HARD_PHY_ISSUE 0
		} else {
			set_instance_parameter ${HPHY_BRIDGE} WORKAROUND_HARD_PHY_ISSUE 1
		}

		add_connection "avl_clk.out_clk/${HPHY_BRIDGE}.clk"
		add_connection "sequencer_rst.reset_out/${HPHY_BRIDGE}.reset"

		add_connection "cpu_inst.${CPU_AVL}/${HPHY_BRIDGE}.s0"
		set_connection_parameter_value "cpu_inst.${CPU_AVL}/${HPHY_BRIDGE}.s0" baseAddress $CPU_HARD_PHY_BASE

		add_interface avl avalon start
		set_interface_property avl export_of ${HPHY_BRIDGE}.m0

		set_interface_property avl PORT_NAME_MAP [list \
			avl_address m0_address \
			avl_write m0_write \
			avl_writedata m0_writedata \
			avl_read m0_read \
			avl_readdata m0_readdata \
			avl_waitrequest m0_waitrequest \
		]


	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
		if {0} {
			add_instance dummy_master altera_mem_if_simple_avalon_mm_bridge 

			set_instance_parameter dummy_master DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
			set_instance_parameter dummy_master SYMBOL_WIDTH 8
			set_instance_parameter dummy_master ADDRESS_WIDTH 32
			set_instance_parameter dummy_master ADDRESS_UNITS "WORDS"
			set_instance_parameter dummy_master USE_BYTEENABLE 0
			set_instance_parameter dummy_master USE_READDATAVALID 0
			set_instance_parameter dummy_master WORKAROUND_HARD_PHY_ISSUE 0

			add_connection "avl_clk.out_clk/dummy_master.clk"
			add_connection "sequencer_rst.reset_out/dummy_master.reset"

			add_connection "dummy_master.m0/${HPHY_BRIDGE}.s0"
		}
	}
		
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		add_instance sequencer_trk_mgr_inst sequencer_trk_mgr
	}
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		add_instance sequencer_mem altera_mem_if_sequencer_mem
	}
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		add_instance sequencer_mem_bridge_inst hcx_rom_bridge
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	    add_connection avl_clk.out_clk/sequencer_pll_mgr_inst.avl_clk
	} else {
	    add_connection avl_clk.out_clk/sequencer_scc_mgr_inst.avl_clk
	}
	add_connection avl_clk.out_clk/sequencer_reg_file_inst.avl_clk
	if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
		add_connection avl_clk.out_clk/sequencer_timer_inst.avl_clk
	}
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		add_connection avl_clk.out_clk/sequencer_trk_mgr_inst.avl_clk
	}
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	    add_connection sequencer_rst.reset_out/sequencer_pll_mgr_inst.avl_reset
	} else {
	    add_connection sequencer_rst.reset_out/sequencer_scc_mgr_inst.avl_reset
	}
	add_connection sequencer_rst.reset_out/sequencer_reg_file_inst.avl_reset
	if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
		add_connection sequencer_rst.reset_out/sequencer_timer_inst.avl_reset
	}
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		add_connection sequencer_rst.reset_out/sequencer_trk_mgr_inst.avl_reset
	}
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		add_connection avl_clk.out_clk/sequencer_mem.clk1
		add_connection sequencer_rst.clken_out/sequencer_mem.clken1
		add_connection sequencer_rst.reset_out/sequencer_mem.reset1
		
		add_connection cpu_inst.instruction_master/sequencer_mem.s1
		add_connection cpu_inst.${CPU_AVL}/sequencer_mem.s1
	}
	add_connection avl_clk.out_clk/cpu_inst.${CPU_CLK}
	add_connection sequencer_rst.reset_out/cpu_inst.${CPU_RESET}
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
	    if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	        add_connection ${TRK_MM_BRIDGE}.m0/sequencer_pll_mgr_inst.avl
	    } else {
	        add_connection ${TRK_MM_BRIDGE}.m0/sequencer_scc_mgr_inst.avl
	    }
		add_connection ${TRK_MM_BRIDGE}.m0/sequencer_reg_file_inst.avl
		if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
			add_connection ${TRK_MM_BRIDGE}.m0/sequencer_timer_inst.avl
		}
	} else {
	    if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	        add_connection cpu_inst.${CPU_AVL}/sequencer_pll_mgr_inst.avl
	    } else {
	        add_connection cpu_inst.${CPU_AVL}/sequencer_scc_mgr_inst.avl
	    }
	    add_connection cpu_inst.${CPU_AVL}/sequencer_reg_file_inst.avl
		if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
			add_connection cpu_inst.${CPU_AVL}/sequencer_timer_inst.avl
		}
	}
	
	if {[string compare -nocase [get_parameter_value ENABLE_NIOS_OCI] "TRUE"] == 0 &&
	    [string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		add_connection cpu_inst.instruction_master/cpu_inst.jtag_debug_module
		add_connection cpu_inst.${CPU_AVL}/cpu_inst.jtag_debug_module
	}
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		add_connection sequencer_trk_mgr_inst.trkm/${TRK_MM_BRIDGE}.s0
		add_connection cpu_inst.${CPU_AVL}/sequencer_trk_mgr_inst.trks
		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
			add_connection "sequencer_trk_mgr_inst.trkm/${HPHY_BRIDGE}.s0"
		}

		if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
		}
	}

	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		add_connection sequencer_mem_bridge_inst.avalon_master/sequencer_mem.s2
		add_connection sequencer_rst.reset_out/sequencer_mem.reset2
		add_connection sequencer_rst.reset_out/sequencer_mem_bridge_inst.reset_sink
	}
	
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] != 0} {
	    add_interface scc conduit end
	    set_interface_property scc ENABLED true
	    set_interface_property scc export_of sequencer_scc_mgr_inst.scc
	    alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_scc_mgr_inst scc scc
	    
	    add_interface afi_init_cal_req conduit end
	    set_interface_property afi_init_cal_req ENABLED true
	    set_interface_property afi_init_cal_req export_of sequencer_scc_mgr_inst.afi_init_cal_req
	    alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_scc_mgr_inst afi_init_cal_req afi_init_cal_req
        
	    add_interface scc_clk clock end
	    add_instance scc_clk altera_clock_bridge
	    set_interface_property scc_clk export_of scc_clk.in_clk 
	    set_interface_property scc_clk PORT_NAME_MAP { scc_clk in_clk }
	    	
	    add_interface scc_reset reset end
	    add_instance scc_reset altera_reset_bridge
	    set_interface_property scc_reset export_of scc_reset.in_reset
	    set_instance_parameter scc_reset SYNCHRONOUS_EDGES none
	    set_instance_parameter scc_reset ACTIVE_LOW_RESET 1
	    set_interface_property scc_reset PORT_NAME_MAP { reset_n_scc_clk in_reset_n }
        
	    add_connection "scc_clk.out_clk/sequencer_scc_mgr_inst.scc_clk"
	    add_connection "scc_reset.out_reset/sequencer_scc_mgr_inst.scc_reset"
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		add_interface trk_afi conduit end
		set_interface_property trk_afi ENABLED true
		set_interface_property trk_afi export_of sequencer_trk_mgr_inst.afi
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports sequencer_trk_mgr_inst afi trk_afi
	}
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		add_interface hc_rom_interface conduit end
		set_interface_property hc_rom_interface ENABLED true
		set_interface_property hc_rom_interface export_of sequencer_mem_bridge_inst.hc_rom_interface
		set_interface_property hc_rom_interface PORT_NAME_MAP { hc_rom_config_datain rom_data hc_rom_config_rom_address rom_address hc_rom_config_init_busy init_busy hc_rom_config_rom_data_ready rom_data_ready hc_rom_config_init init hc_rom_config_rom_rden rom_rden }

		add_interface hc_rom_clock  clock end
		add_instance  hc_rom_clock altera_clock_bridge
		set_interface_property hc_rom_clock export_of hc_rom_clock.in_clk 
		set_interface_property hc_rom_clock  PORT_NAME_MAP { hc_rom_config_clock in_clk }	
		
		add_connection hc_rom_clock.out_clk/sequencer_mem_bridge_inst.write_clock
		add_connection hc_rom_clock.out_clk/sequencer_mem.clk2
	}
	
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		set_connection_parameter cpu_inst.instruction_master/sequencer_mem.s1 arbitrationPriority "1"
		set_connection_parameter cpu_inst.instruction_master/sequencer_mem.s1 baseAddress $MEM_BASE_ADDRESS
	}
	
	if {[string compare -nocase [get_parameter_value ENABLE_NIOS_OCI] "TRUE"] == 0 &&
	    [string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		set_connection_parameter cpu_inst.instruction_master/cpu_inst.jtag_debug_module arbitrationPriority "1"
		set_connection_parameter cpu_inst.instruction_master/cpu_inst.jtag_debug_module baseAddress "0x00000000"
		
		set_connection_parameter cpu_inst.${CPU_AVL}/cpu_inst.jtag_debug_module arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/cpu_inst.jtag_debug_module baseAddress "0x00000000"
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
        if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
            set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_pll_mgr_inst.avl arbitrationPriority "1"
            set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_pll_mgr_inst.avl baseAddress $SEQUENCER_TRK_PLL_MGR_BASE
        } else {
            set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_scc_mgr_inst.avl arbitrationPriority "1"
            set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_scc_mgr_inst.avl baseAddress $SEQUENCER_TRK_SCC_MGR_BASE
        }

		set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_reg_file_inst.avl arbitrationPriority "1"
		set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_reg_file_inst.avl baseAddress $SEQUENCER_TRK_REG_FILE_BASE

		if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_timer_inst.avl arbitrationPriority "1"
			set_connection_parameter ${TRK_MM_BRIDGE}.m0/sequencer_timer_inst.avl baseAddress $SEQUENCER_TRK_TIMER_BASE
		}
	} else {
	    if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0} {
	        set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_pll_mgr_inst.avl arbitrationPriority "1"
	        set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_pll_mgr_inst.avl baseAddress $PLL_MGR_BASE_ADDRESS
	    } else {
	        set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_scc_mgr_inst.avl arbitrationPriority "1"
	        set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_scc_mgr_inst.avl baseAddress $SCC_MGR_BASE_ADDRESS
	    }
        
	    set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_reg_file_inst.avl arbitrationPriority "1"
	    set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_reg_file_inst.avl baseAddress $REG_FILE_BASE_ADDRESS
	
	    if {[string compare -nocase [get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB] "TRUE"] == 0} {
	    	set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_timer_inst.avl arbitrationPriority "1"
	    	set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_timer_inst.avl baseAddress $TIMER_BASE_ADDRESS
	    }
	}

	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_mem.s1 arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_mem.s1 baseAddress $MEM_BASE_ADDRESS
	}
	
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		set_connection_parameter sequencer_trk_mgr_inst.trkm/${TRK_MM_BRIDGE}.s0 baseAddress $TRK_MM_MASTER_BASE
		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
			set_connection_parameter_value "sequencer_trk_mgr_inst.trkm/${HPHY_BRIDGE}.s0" baseAddress $SEQUENCER_TRK_HARD_PHY_BASE
		}
		if {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
		}
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_trk_mgr_inst.trks arbitrationPriority "1"
		set_connection_parameter cpu_inst.${CPU_AVL}/sequencer_trk_mgr_inst.trks baseAddress $TRK_MM_SLAVE_BASE
	}
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		set_connection_parameter sequencer_mem_bridge_inst.avalon_master/sequencer_mem.s2 arbitrationPriority "1"
		set_connection_parameter sequencer_mem_bridge_inst.avalon_master/sequencer_mem.s2 baseAddress "0x00000000"
	}
	
	
	if {[string compare -nocase [get_parameter_value ENABLE_NIOS_JTAG_UART] "true"] == 0} {
		set JTAG_UART seq_jtag_uart
		add_instance ${JTAG_UART} altera_avalon_jtag_uart
		set_instance_parameter ${JTAG_UART} allowMultipleConnections "false"
		set_instance_parameter ${JTAG_UART} hubInstanceID "0"
		set_instance_parameter ${JTAG_UART} readBufferDepth "64"
		set_instance_parameter ${JTAG_UART} readIRQThreshold "8"
		set_instance_parameter ${JTAG_UART} simInputCharacterStream ""
		set_instance_parameter ${JTAG_UART} simInteractiveOptions "INTERACTIVE_ASCII_OUTPUT"
		set_instance_parameter ${JTAG_UART} useRegistersForReadBuffer "false"
		set_instance_parameter ${JTAG_UART} useRegistersForWriteBuffer "false"
		set_instance_parameter ${JTAG_UART} useRelativePathForSimFile "false"
		set_instance_parameter ${JTAG_UART} writeBufferDepth "64"
		set_instance_parameter ${JTAG_UART} writeIRQThreshold "8"
	
		add_connection "avl_clk.out_clk/${JTAG_UART}.clk"
		add_connection "sequencer_rst.reset_out/${JTAG_UART}.reset"
		add_connection "cpu_inst.${CPU_AVL}/${JTAG_UART}.avalon_jtag_slave"
		set_connection_parameter_value "cpu_inst.${CPU_AVL}/${JTAG_UART}.avalon_jtag_slave" baseAddress $UART_BASE_ADDRESS
		add_connection "cpu_inst.d_irq/${JTAG_UART}.irq"
		set_connection_parameter_value "cpu_inst.d_irq/${JTAG_UART}.irq" irqNumber 0
	}
  
	if {[string compare -nocase [get_parameter_value ENABLE_DEBUG_BRIDGE] "true"] == 0} {
		set DEBUG_BRIDGE seq_bridge
		add_instance ${DEBUG_BRIDGE} altera_avalon_mm_bridge 
	
		set_instance_parameter ${DEBUG_BRIDGE} DATA_WIDTH 32
		set_instance_parameter ${DEBUG_BRIDGE} SYMBOL_WIDTH 8
		set_instance_parameter ${DEBUG_BRIDGE} ADDRESS_UNITS "SYMBOLS"
		set_instance_parameter ${DEBUG_BRIDGE} MAX_BURST_SIZE 1
	
		set_instance_parameter ${DEBUG_BRIDGE} ADDRESS_WIDTH 32
	
		add_connection "avl_clk.out_clk/${DEBUG_BRIDGE}.clk"
		add_connection "sequencer_rst.reset_out/${DEBUG_BRIDGE}.reset"
		
		add_connection "${DEBUG_BRIDGE}.m0/sequencer_mem.s1"
		set_connection_parameter_value "${DEBUG_BRIDGE}.m0/sequencer_mem.s1" baseAddress $MEM_BASE_ADDRESS
		add_connection "${DEBUG_BRIDGE}.m0/sequencer_reg_file_inst.avl"
		set_connection_parameter "${DEBUG_BRIDGE}.m0/sequencer_reg_file_inst.avl" baseAddress $REG_FILE_BASE_ADDRESS

		add_interface seq_debug avalon slave
		set_interface_property seq_debug ENABLED true
		set_interface_property seq_debug export_of "${DEBUG_BRIDGE}.s0"

		set_interface_property seq_debug PORT_NAME_MAP [list \
			seq_waitrequest s0_waitrequest \
			seq_readdata s0_readdata \
			seq_readdatavalid s0_readdatavalid \
			seq_burstcount s0_burstcount \
			seq_writedata s0_writedata \
			seq_address s0_address \
			seq_write s0_write \
			seq_read s0_read \
			seq_byteenable s0_byteenable \
			seq_debugaccess s0_debugaccess \
		]
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "TRUE"] == 0} {
		set_instance_parameter_value sequencer_trk_mgr_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_trk_mgr_inst RATE [get_parameter_value RATE]
		set_instance_parameter_value sequencer_trk_mgr_inst MEM_CHIP_SELECT_WIDTH [get_parameter_value MEM_CHIP_SELECT_WIDTH]
		set_instance_parameter_value sequencer_trk_mgr_inst MEM_NUMBER_OF_RANKS [get_parameter_value MEM_NUMBER_OF_RANKS]
		set_instance_parameter_value sequencer_trk_mgr_inst MEM_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
		set_instance_parameter_value sequencer_trk_mgr_inst READ_VALID_FIFO_SIZE [get_parameter_value READ_VALID_FIFO_SIZE]
		set_instance_parameter_value sequencer_trk_mgr_inst PHY_MGR_BASE $SEQUENCER_TRK_PHY_MGR_BASE
		set_instance_parameter_value sequencer_trk_mgr_inst RW_MGR_BASE $SEQUENCER_TRK_RW_MGR_BASE
		set_instance_parameter_value sequencer_trk_mgr_inst SCC_MGR_BASE $SEQUENCER_TRK_SCC_MGR_BASE
		set_instance_parameter_value sequencer_trk_mgr_inst HARD_PHY [get_parameter_value HARD_PHY]
		set_instance_parameter_value sequencer_trk_mgr_inst HARD_VFIFO [get_parameter_value HARD_VFIFO]
		set_instance_parameter_value sequencer_trk_mgr_inst IO_DQS_EN_DELAY_OFFSET [get_parameter_value IO_DQS_EN_DELAY_OFFSET]
	    set_instance_parameter_value sequencer_trk_mgr_inst TRK_PARALLEL_SCC_LOAD [get_parameter_value TRK_PARALLEL_SCC_LOAD]
		if {[string compare -nocase [get_parameter_value HARD_PHY] "TRUE"] == 0} {
			set_instance_parameter_value sequencer_trk_mgr_inst MUX_SEL_SEQUENCER_VAL 3
			set_instance_parameter_value sequencer_trk_mgr_inst MUX_SEL_CONTROLLER_VAL 2
		} else {
			set_instance_parameter_value sequencer_trk_mgr_inst MUX_SEL_SEQUENCER_VAL 1
			set_instance_parameter_value sequencer_trk_mgr_inst MUX_SEL_CONTROLLER_VAL 0
		}
	}
	
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		set sequencer_mem_num_words [expr {[get_parameter_value SEQUENCER_MEM_SIZE]/([get_parameter_value AVL_DATA_WIDTH]/8.0)}]
		set_instance_parameter_value sequencer_mem AVL_ADDR_WIDTH [expr {ceil(log($sequencer_mem_num_words)/log(2.0))}]
		set_instance_parameter_value sequencer_mem AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_mem AVL_SYMBOL_WIDTH 8
		set_instance_parameter_value sequencer_mem INIT_FILE [get_parameter_value SEQ_ROM]
		set_instance_parameter_value sequencer_mem RAM_BLOCK_TYPE [get_parameter_value RAM_BLOCK_TYPE]
		set_instance_parameter_value sequencer_mem MEM_SIZE [get_parameter_value SEQUENCER_MEM_SIZE]
		if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
			set_instance_parameter_value sequencer_mem USE_DUAL_PORT "true"
		}
	}
	
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0} {
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_nios_cpu]} {
		} else {
			set_instance_parameter_value cpu_inst AVL_INST_ADDR_WIDTH 17
			set_instance_parameter_value cpu_inst AVL_DATA_ADDR_WIDTH 20
			set_instance_parameter_value cpu_inst DEVICE_FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
		}
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_make_visible_nios] ||
			[string compare -nocase [get_parameter_value MAKE_INTERNAL_NIOS_VISIBLE] "true"] == 0} {
			set_instance_parameter_value cpu_inst userDefinedSettings ""
		} else {
			set_instance_parameter_value cpu_inst userDefinedSettings "internal_nios2=1;"
		}
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
		set_instance_parameter_value cpu_inst is_hardcopy_compatible [get_parameter_value HCX_COMPAT_MODE]
		if {[string compare -nocase [get_parameter_value ENABLE_NIOS_OCI] "TRUE"] == 0} {
			set_instance_parameter_value cpu_inst breakSlave "cpu_inst.jtag_debug_module"
			set_instance_parameter_value cpu_inst debug_level "Level1"
		} else {
			set_instance_parameter_value cpu_inst breakSlave "sequencer_mem.s1"
			set_instance_parameter_value cpu_inst debug_level "NoDebug"
		}
		set_instance_parameter_value cpu_inst breakOffset "32"
	} elseif {[string compare -nocase [get_parameter_value HHP_HPS] "TRUE"] == 0} {
		set_instance_parameter_value cpu_inst ADDRESS_WIDTH		"20"
		set_instance_parameter_value cpu_inst DATA_WIDTH		"32"
	} else {
		set_instance_parameter_value cpu_inst AV_ADDRESS_W               "32"
		set_instance_parameter_value cpu_inst AV_SYMBOL_W                "8"
		set_instance_parameter_value cpu_inst AV_NUMSYMBOLS              "4"
		set_instance_parameter_value cpu_inst AV_READRESPONSE_W 	[get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value cpu_inst AV_WRITERESPONSE_W	[get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value cpu_inst ASSERT_HIGH_RESET          "1"

		set_instance_parameter_value cpu_inst AV_BURSTCOUNT_W            "1"
		set_instance_parameter_value cpu_inst USE_READ                   "1"
		set_instance_parameter_value cpu_inst USE_WRITE                  "1"
		set_instance_parameter_value cpu_inst USE_ADDRESS                "1"
		set_instance_parameter_value cpu_inst USE_BYTE_ENABLE            "0"
		set_instance_parameter_value cpu_inst USE_BURSTCOUNT             "0"
		set_instance_parameter_value cpu_inst USE_READ_DATA              "1"
		set_instance_parameter_value cpu_inst USE_READ_DATA_VALID        "0"
		set_instance_parameter_value cpu_inst USE_WRITE_DATA             "1"
		set_instance_parameter_value cpu_inst USE_BEGIN_TRANSFER         "0"
		set_instance_parameter_value cpu_inst USE_BEGIN_BURST_TRANSFER   "0"
		set_instance_parameter_value cpu_inst USE_WAIT_REQUEST           "1"
		set_instance_parameter_value cpu_inst USE_TRANSACTIONID          "0"
		set_instance_parameter_value cpu_inst USE_WRITERESPONSE          "0"
		set_instance_parameter_value cpu_inst USE_READRESPONSE           "0"
		set_instance_parameter_value cpu_inst USE_CLKEN                  "0"
		set_instance_parameter_value cpu_inst AV_BURST_LINEWRAP          "0"
		set_instance_parameter_value cpu_inst AV_BURST_BNDR_ONLY         "1"
		set_instance_parameter_value cpu_inst AV_MAX_PENDING_READS       "0"
		set_instance_parameter_value cpu_inst AV_FIX_READ_LATENCY        "0"
		set_instance_parameter_value cpu_inst AV_READ_WAIT_TIME          "1"
		set_instance_parameter_value cpu_inst AV_WRITE_WAIT_TIME         "0"
		set_instance_parameter_value cpu_inst REGISTER_WAITREQUEST       "0"
		set_instance_parameter_value cpu_inst AV_REGISTERINCOMINGSIGNALS "0"
	}
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		set_instance_parameter_value sequencer_mem_bridge_inst AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter_value sequencer_mem_bridge_inst AVL_ADDR_WIDTH [get_parameter_value SEQUENCER_MEM_ADDRESS_WIDTH]
		set_instance_parameter_value sequencer_mem_bridge_inst ROM_SIZE [get_parameter_value SEQUENCER_MEM_SIZE]
	}
}

