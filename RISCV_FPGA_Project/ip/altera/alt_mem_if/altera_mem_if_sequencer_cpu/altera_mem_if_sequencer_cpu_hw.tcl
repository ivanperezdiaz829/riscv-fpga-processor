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

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# | 
# +-----------------------------------

# +-----------------------------------

# +-----------------------------------
# | 
set_module_property DESCRIPTION "UniPHY Sequencer CPU"
set_module_property NAME altera_mem_if_sequencer_cpu
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Sequencer CPU"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true
# | 
# +-----------------------------------

# Hide the block diagram
add_display_item "" "Block Diagram" GROUP

# +-----------------------------------
# | Fileset Callbacks
# | 
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc solve_core_params {} {

	# This is the list of all supported IFdefs in the RTL that should be
	# considered for stripping
	set supported_ifdefs_list [list \
		CYCLONEV \
		DEBUG4 \
	]

	# Initialize the parameters list
	set core_params_list [list]

	# Create the IFDEF list based on the parameters chosen
	
	if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] "CYCLONEV"] == 0} {
		lappend core_params_list "CV"
	}
	
	if {[string compare -nocase [get_parameter_value debug_level] "Level1"] == 0} {
		lappend core_params_list "D4"
	}

	return $core_params_list
	
}


proc module_list {fileset {synth_files {0}} } {
	set file_list [list]
	lappend file_list cpu_inst.v
	lappend file_list cpu_inst_test_bench.v
	if {[string compare -nocase [get_parameter_value debug_level] "Level1"] == 0} {
		lappend file_list cpu_inst_jtag_debug_module_sysclk.v
		lappend file_list cpu_inst_jtag_debug_module_tck.v
		lappend file_list cpu_inst_jtag_debug_module_wrapper.v
		lappend file_list cpu_inst_oci_test_bench.v
		if {$synth_files} {
			lappend file_list cpu_inst.sdc
		}
	}
	return $file_list
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	set base_file_name "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_sim"

	set file_list [list]
	foreach module [module_list "sim"] {
		lappend file_list "${base_file_name}_${module}"
	}

	# Only the RTL is mentor encrypted
	foreach file_name $file_list {
		_dprint 1 "Preparing to add $file_name"

		# Return the mentor tagged files
		add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join mentor $file_name] {MENTOR_SPECIFIC}
	}

	foreach file_name $file_list {
		_dprint 1 "Preparing to add $file_name"

		# Return the normal verilog file for dual language simulators
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name $non_encryp_simulators
	}

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set base_file_name "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_sim"

	set file_list [list]
	foreach module [module_list "sim"] {
		lappend file_list "${base_file_name}_${module}"
	}

	foreach file_name $file_list {
	_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set base_file_name "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_synth"

	set file_list [list]
	foreach module [module_list "synth" 1] {
		lappend file_list "${base_file_name}_${module}"
	}

	foreach file_name $file_list {
	_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

	set CLOCK_INTF      "clk"
	set I_MASTER_INTF   "instruction_master"
	set D_MASTER_INTF   "data_master"
	set CI_MASTER_INTF  "custom_instruction_master"
	set D_IRQ_INTF      "d_irq"
	set DEBUG_INTF      "jtag_debug_module"


# TODO: description as arg
# TODO: do we need "affects_elaboration" often?
# TODO: add description
proc proc_add_parameter {NAME TYPE DEFAULT args} {
    set DESCRIPTION         "set \[$NAME\] value"
    add_parameter           $NAME $TYPE $DEFAULT $DESCRIPTION
    if {$args != ""} then {
        set_parameter_property  $NAME "ALLOWED_RANGES" $args
    }
    set_parameter_property  $NAME "VISIBLE" false
}

proc proc_add_derived_parameter {NAME TYPE DEFAULT args} {
    proc_add_parameter      $NAME $TYPE    $DEFAULT
    set_parameter_property  $NAME "DERIVED" true
    set_parameter_property  $NAME "VISIBLE" true
}

proc proc_add_system_info_parameter {NAME TYPE DEFAULT SYSTEM_INFO_ARG} {
    proc_add_parameter      $NAME   $TYPE           $DEFAULT
    set_parameter_property  $NAME   system_info     "$SYSTEM_INFO_ARG"
}

# TODO: appropriate use of quotation marks?
# TODO: proper use of status=experimentatl for debug mode?
proc proc_set_display_group {NAME GROUP EXPERIMENTAL DISPLAY_NAME args} {
    add_display_item        $GROUP  $NAME               parameter
    set_parameter_property  $NAME   "DISPLAY_NAME"      "$DISPLAY_NAME"
    if { [ expr { "DES_$args" != "DES_" } ] } {
        set_parameter_property  $NAME   "DESCRIPTION"       "[ join $args ]"
    }
    # only show those settings in debug mode
    if { "$EXPERIMENTAL" == "1" } {
        set_parameter_property  $NAME   "STATUS"       "EXPERIMENTAL"
        set_parameter_property  $NAME   "VISIBLE"           false
    } else {
        set_parameter_property  $NAME   "VISIBLE"           true
    }
}


proc proc_set_interface_embeddedsw_configuration_assignment {interface name value} {
    set embeddedsw_name "embeddedsw.configuration.${name}"
    set_interface_assignment $interface $embeddedsw_name "$value"
}


proc_add_parameter      setting_showUnpublishedSettings             BOOLEAN     false
proc_add_parameter      setting_showInternalSettings                BOOLEAN     false
proc_add_parameter      setting_preciseSlaveAccessErrorException    BOOLEAN     false
proc_add_parameter      setting_preciseIllegalMemAccessException    BOOLEAN     false
proc_add_parameter      setting_preciseDivisionErrorException       BOOLEAN     false
proc_add_parameter      setting_performanceCounter                  BOOLEAN     false
proc_add_parameter      setting_illegalMemAccessDetection           BOOLEAN     false
proc_add_parameter      setting_illegalInstructionsTrap             BOOLEAN     false
proc_add_parameter      setting_fullWaveformSignals                 BOOLEAN     false
proc_add_parameter      setting_extraExceptionInfo                  BOOLEAN     false
proc_add_parameter      setting_exportPCB                           BOOLEAN     false
proc_add_parameter      setting_debugSimGen                         BOOLEAN     false
proc_add_parameter      setting_clearXBitsLDNonBypass               BOOLEAN     true
proc_add_parameter      setting_bit31BypassDCache                   BOOLEAN     true
proc_add_parameter      setting_bigEndian                           BOOLEAN     false
proc_add_parameter      setting_bhtIndexPcOnly                      BOOLEAN     false
proc_add_parameter      setting_avalonDebugPortPresent              BOOLEAN     false
proc_add_parameter      setting_alwaysEncrypt                       BOOLEAN     true
proc_add_parameter      setting_allowFullAddressRange               BOOLEAN     false
proc_add_parameter      setting_activateTrace                       BOOLEAN     true
proc_add_parameter      setting_activateTestEndChecker              BOOLEAN     false
proc_add_parameter      setting_activateMonitors                    BOOLEAN     true
proc_add_parameter      setting_activateModelChecker                BOOLEAN     false
proc_add_parameter      setting_HDLSimCachesCleared                 BOOLEAN     true
proc_add_parameter      setting_HBreakTest                          BOOLEAN     false
proc_add_parameter      muldiv_divider                              BOOLEAN     false
proc_add_parameter      mpu_useLimit                                BOOLEAN     false
proc_add_parameter      mpu_enabled                                 BOOLEAN     false
proc_add_parameter      mmu_enabled                                 BOOLEAN     false
proc_add_parameter      mmu_autoAssignTlbPtrSz                      BOOLEAN     true
proc_add_parameter      manuallyAssignCpuID                         BOOLEAN     true
proc_add_parameter      debug_triggerArming                         BOOLEAN     true
proc_add_parameter      debug_embeddedPLL                           BOOLEAN     true
proc_add_parameter      debug_debugReqSignals                       BOOLEAN     false
proc_add_parameter      debug_assignJtagInstanceID                  BOOLEAN     false
proc_add_parameter      dcache_omitDataMaster                       BOOLEAN     false
proc_add_parameter      cpuReset                                    BOOLEAN     false
proc_add_parameter      is_hardcopy_compatible                      BOOLEAN     false
proc_add_parameter      setting_shadowRegisterSets                  INTEGER     0       "0:63"
proc_add_parameter      mpu_numOfInstRegion                         INTEGER     8       "2"  "3"   "4"   "5"   "6"   "7"   "8"   "9"  "10"  "11"  "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "20"  "21"  "22"  "23"  "24"  "25"  "26"  "27"  "28"  "29"  "30"  "31"  "32"
proc_add_parameter      mpu_numOfDataRegion                         INTEGER     8       "2"  "3"   "4"   "5"   "6"   "7"   "8"   "9"  "10"  "11"  "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "20"  "21"  "22"  "23"  "24"  "25"  "26"  "27"  "28"  "29"  "30"  "31"  "32"
proc_add_parameter      mmu_TLBMissExcOffset                        INTEGER     0
proc_add_parameter      debug_jtagInstanceID                        INTEGER     0       "0:255"
proc_add_parameter      resetOffset                                 INTEGER     0
proc_add_parameter      exceptionOffset                             INTEGER     32
proc_add_parameter      cpuID                                       INTEGER     0
proc_add_parameter      cpuID_stored                                INTEGER     0
proc_add_parameter      breakOffset                                 INTEGER     32
proc_add_parameter      userDefinedSettings                         STRING      ""
proc_add_parameter      resetSlave                                  STRING      "None"
proc_add_parameter      mmu_TLBMissExcSlave                         STRING      ""
proc_add_parameter      exceptionSlave                              STRING      "None"
proc_add_parameter      breakSlave                                  STRING      "None"
# [SH] Change all Integer type with "_8" back to string since "string:Display name" is allowed
proc_add_parameter      setting_perfCounterWidth                    INTEGER     32          "16:16 Bits"  "24:24 Bits"  "32:32 Bits"
proc_add_parameter      setting_interruptControllerType             STRING      "Internal"  "Internal"  "External"
proc_add_parameter      setting_branchPredictionType                STRING      "Automatic" "Automatic"  "Static"  "Dynamic"
proc_add_parameter      setting_bhtPtrSz                            INTEGER     8           "8:256 Entries"  "9:512 Entries"  "10:1024 Entries"  "11:2048 Entries"
proc_add_parameter      muldiv_multiplierType                       STRING      "DSPBlock"  "DSPBlock:DSP Block"  "EmbeddedMulFast:Embedded Multipliers"  "LogicElementsFast:Logic Elements"  "NoneSmall:None"
proc_add_parameter      mpu_minInstRegionSize                       INTEGER     12          "6:64 Bytes"  "7:128 Bytes"  "8:256 Bytes"  "9:512 Bytes"  "10:1 Kbyte"  "11:2 Kbytes"  "12:4 Kbytes"  "13:8 Kbytes"  "14:16 Kbytes"  "15:32 Kbytes"  "16:64 Kbytes"  "17:128 Kbytes"  "18:256 Kbytes"  "19:512 Kbytes"  "20:1 Mbyte"
proc_add_parameter      mpu_minDataRegionSize                       INTEGER     12          "6:64 Bytes"  "7:128 Bytes"  "8:256 Bytes"  "9:512 Bytes"  "10:1 Kbyte"  "11:2 Kbytes"  "12:4 Kbytes"  "13:8 Kbytes"  "14:16 Kbytes"  "15:32 Kbytes"  "16:64 Kbytes"  "17:128 Kbytes"  "18:256 Kbytes"  "19:512 Kbytes"  "20:1 Mbyte"
proc_add_parameter      mmu_uitlbNumEntries                         INTEGER     4           "2:2 Entries"  "4:4 Entries"  "6:6 Entries"  "8:8 Entries"
proc_add_parameter      mmu_udtlbNumEntries                         INTEGER     6           "2:2 Entries"  "4:4 Entries"  "6:6 Entries"  "8:8 Entries"
proc_add_parameter      mmu_tlbPtrSz                                INTEGER     7           "7:128 Entries"  "8:256 Entries"  "9:512 Entries"  "10:1024 Entries"
proc_add_parameter      mmu_tlbNumWays                              INTEGER     16          "8:8 Ways"  "16:16 Ways"
proc_add_parameter      mmu_processIDNumBits                        INTEGER     8           "8:8 Bits"  "9:9 Bits"  "10:10 Bits"  "11:11 Bits"  "12:12 Bits"  "13:13 Bits"  "14:14 Bits"
proc_add_parameter      impl                                        STRING      "Fast"      "Tiny:Nios II/e"  "Small:Nios II/s"  "Fast:Nios II/f"
proc_add_parameter      icache_size                                 INTEGER     4096        "0:None"  "512:512 Bytes"  "1024:1 Kbyte"  "2048:2 Kbytes"  "4096:4 Kbytes"  "8192:8 Kbytes"  "16384:16 Kbytes"  "32768:32 Kbytes"  "65536:64 Kbytes"
proc_add_parameter      icache_ramBlockType                         STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      icache_numTCIM                              INTEGER     0           "0:None"  "1:1"  "2:2"  "3:3"  "4:4"
proc_add_parameter      icache_burstType                            STRING      "None"      "None:Disable"  "Sequential:Enable"
proc_add_parameter      dcache_bursts                               STRING      "false"     "false:Disable" "true:Enable"
proc_add_parameter      debug_level                                 STRING      "Level1"    "NoDebug:No Debugger"  "Level1:Level 1"  "Level2:Level 2"  "Level3:Level 3"  "Level4:Level 4"
proc_add_parameter      debug_OCIOnchipTrace                        STRING      "_128"      "_128:128 Frames"  "_256:256 Frames"  "_512:512 Frames"  "_1k:1k Frames"  "_2k:2k Frames"  "_4k:4k Frames"  "_8k:8k Frames"  "_16k:16k Frames"  "_32k:32k Frames"  "_64k:64k Frames"
proc_add_parameter      dcache_size                                 INTEGER     2048        "0:None"  "512:512 Bytes"  "1024:1 Kbyte"  "2048:2 Kbytes"  "4096:4 Kbytes"  "8192:8 Kbytes"  "16384:16 Kbytes"  "32768:32 Kbytes"  "65536:64 Kbytes"
proc_add_parameter      dcache_ramBlockType                         STRING      "Automatic" "Automatic"  "M4K"  "MRam"  "MLAB"  "M9K" "M10K" "M20K" "M144K"
proc_add_parameter      dcache_numTCDM                              INTEGER     0           "0:None"  "1:1"  "2:2"  "3:3"  "4:4"
proc_add_parameter      dcache_lineSize                             INTEGER     32          "4:4 Bytes"  "16:16 Bytes"  "32:32 Bytes"




proc_add_derived_parameter  resetAbsoluteAddr       INTEGER     0
proc_add_derived_parameter  exceptionAbsoluteAddr   INTEGER     0
proc_add_derived_parameter  breakAbsoluteAddr       INTEGER     0
proc_add_derived_parameter  mmu_TLBMissExcAbsAddr   INTEGER     0




#------------------------------
# [4.3] SYSTEM_INFO Parameter
#------------------------------
proc_add_system_info_parameter          instAddrWidth                                       INTEGER         "1"                     "ADDRESS_WIDTH $I_MASTER_INTF"
proc_add_system_info_parameter          dataAddrWidth                                       INTEGER         "1"                     "ADDRESS_WIDTH $D_MASTER_INTF"
proc_add_system_info_parameter          tightlyCoupledDataMaster0AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_0"
proc_add_system_info_parameter          tightlyCoupledDataMaster1AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_1"
proc_add_system_info_parameter          tightlyCoupledDataMaster2AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_2"
proc_add_system_info_parameter          tightlyCoupledDataMaster3AddrWidth                  INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_data_master_3"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster0AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_0"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster1AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_1"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster2AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_2"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster3AddrWidth           INTEGER         "1"             		"ADDRESS_WIDTH tightly_coupled_instruction_master_3"
proc_add_system_info_parameter          instSlaveMapParam                                   STRING          ""                      "ADDRESS_MAP $I_MASTER_INTF"
proc_add_system_info_parameter          dataSlaveMapParam                                   STRING          ""                      "ADDRESS_MAP $D_MASTER_INTF"

proc_add_system_info_parameter          clockFrequency                                      LONG            "50000000"              "CLOCK_RATE $CLOCK_INTF"
proc_add_system_info_parameter          deviceFamilyName                                    STRING          "STRATIXIV"             "DEVICE_FAMILY"
proc_add_system_info_parameter          internalIrqMaskSystemInfo                           LONG            "0x0"                   "INTERRUPTS_USED $D_IRQ_INTF"


proc_add_system_info_parameter          customInstSlavesSystemInfo                           STRING          ""                      "CUSTOM_INSTRUCTION_SLAVES $CI_MASTER_INTF"
proc_add_system_info_parameter          deviceFeaturesSystemInfo                             STRING          ""                      "DEVICE_FEATURES"

proc_add_system_info_parameter          tightlyCoupledDataMaster0MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_0"
proc_add_system_info_parameter          tightlyCoupledDataMaster1MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_1"
proc_add_system_info_parameter          tightlyCoupledDataMaster2MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_2"
proc_add_system_info_parameter          tightlyCoupledDataMaster3MapParam                    STRING          ""          		     "ADDRESS_MAP tightly_coupled_data_master_3"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster0MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_0"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster1MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_1"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster2MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_2"
proc_add_system_info_parameter          tightlyCoupledInstructionMaster3MapParam             STRING          ""          		     "ADDRESS_MAP tightly_coupled_instruction_master_3"

proc_set_display_group debug_level                                 "Select a Debugging Level"      0   "Debug level"
set_parameter_property debug_level   "DISPLAY_HINT"      "radio"
set_parameter_property debug_level AFFECTS_ELABORATION true

add_parameter DEVICE_FAMILY STRING "STRATIXIV"
set_parameter_property DEVICE_FAMILY DISPLAY_NAME DEVICE_FAMILY
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"STRATIXIII" "STRATIXIV" "STRATIXV" "ARRIAIIGX" "ARRIAIIGZ" "ARRIAV" "CYCLONEV" "ARRIAVGZ" "MAX10FPGA"}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

add_parameter AVL_INST_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_INST_ADDR_WIDTH DISPLAY_NAME AVL_INST_ADDR_WIDTH
set_parameter_property AVL_INST_ADDR_WIDTH AFFECTS_ELABORATION true

add_parameter AVL_DATA_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_DATA_ADDR_WIDTH DISPLAY_NAME AVL_DATA_ADDR_WIDTH
set_parameter_property AVL_DATA_ADDR_WIDTH AFFECTS_ELABORATION true


# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration/validation callbacks
# | 
if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

    set debug_level    [ get_parameter_value debug_level ]

	set_module_assignment embeddedsw.CMacro.BIG_ENDIAN 0
	set_module_assignment embeddedsw.CMacro.CPU_FREQ 50000000u
	set_module_assignment embeddedsw.CMacro.CPU_ID_SIZE 1
	set_module_assignment embeddedsw.CMacro.CPU_ID_VALUE 0x00000000
	set_module_assignment embeddedsw.CMacro.CPU_IMPLEMENTATION "\"tiny\""
	set_module_assignment embeddedsw.CMacro.DATA_ADDR_WIDTH [get_parameter_value AVL_DATA_ADDR_WIDTH]
	set_module_assignment embeddedsw.CMacro.DCACHE_LINE_SIZE 0
	set_module_assignment embeddedsw.CMacro.DCACHE_LINE_SIZE_LOG2 0
	set_module_assignment embeddedsw.CMacro.DCACHE_SIZE 0
	set_module_assignment embeddedsw.CMacro.EXCEPTION_ADDR 0x00010020
	set_module_assignment embeddedsw.CMacro.FLUSHDA_SUPPORTED ""
	set_module_assignment embeddedsw.CMacro.HARDWARE_DIVIDE_PRESENT 0
	set_module_assignment embeddedsw.CMacro.HARDWARE_MULTIPLY_PRESENT 0
	set_module_assignment embeddedsw.CMacro.HARDWARE_MULX_PRESENT 0
	set_module_assignment embeddedsw.CMacro.HAS_DEBUG_STUB ""
	set_module_assignment embeddedsw.CMacro.HAS_JMPI_INSTRUCTION ""
	set_module_assignment embeddedsw.CMacro.ICACHE_LINE_SIZE 0
	set_module_assignment embeddedsw.CMacro.ICACHE_LINE_SIZE_LOG2 0
	set_module_assignment embeddedsw.CMacro.ICACHE_SIZE 0
	set_module_assignment embeddedsw.CMacro.INITDA_SUPPORTED ""
	set_module_assignment embeddedsw.CMacro.INST_ADDR_WIDTH [get_parameter_value AVL_INST_ADDR_WIDTH]
	set_module_assignment embeddedsw.CMacro.NUM_OF_SHADOW_REG_SETS 0
	set_module_assignment embeddedsw.CMacro.RESET_ADDR 0x00010000
    # If debug level not NoDebug, then oci core is included
    set_module_assignment embeddedsw.CMacro.HAS_DEBUG_CORE [ expr { "$debug_level" != "NoDebug" } ]
    if { "$debug_level" != "NoDebug" } {
		set_module_assignment embeddedsw.CMacro.BREAK_ADDR 0x00000020
	} else {
		set_module_assignment embeddedsw.CMacro.BREAK_ADDR 0x00010020
	}

	set_module_assignment embeddedsw.configuration.HDLSimCachesCleared 1
	set_module_assignment embeddedsw.configuration.breakOffset 32
	set_module_assignment embeddedsw.configuration.cpuArchitecture "Nios II"
	set_module_assignment embeddedsw.configuration.exceptionOffset 32
	set_module_assignment embeddedsw.configuration.exceptionSlave "sequencer_mem.s1"
	set_module_assignment embeddedsw.configuration.resetOffset 0
	set_module_assignment embeddedsw.configuration.resetSlave "sequencer_mem.s1"
	
	# The base address 0x0010000 of the instruction memory is 65536 in decimal
	set_parameter_value resetAbsoluteAddr 65536
	set_parameter_value exceptionAbsoluteAddr [expr {65536 + 32}]
    if { "$debug_level" != "NoDebug" } {
		set_parameter_value breakAbsoluteAddr 32
	} else {
		set_parameter_value breakAbsoluteAddr [expr {65536 + 32}]
	}

    # Automatically select the JTAG debug module if debugger is enabled
    if { "$debug_level" != "NoDebug" } {
		set_module_assignment embeddedsw.configuration.breakSlave "cpu_inst.jtag_debug_module"
    } else {
		set_module_assignment embeddedsw.configuration.breakSlave "sequencer_mem.s1"
	}
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

    global CLOCK_INTF
    global D_MASTER_INTF
    global I_MASTER_INTF
    global CI_MASTER_INTF
    global D_IRQ_INTF
    global DEBUG_INTF

	#------------------------------
	# Clock Interface
	#------------------------------
	add_interface           $CLOCK_INTF     "clock"     "sink"
	add_interface_port      $CLOCK_INTF     "clk"       "clk"       "input"     1

	#------------------------------
	# Reset Interface
	#------------------------------
	add_interface           reset_n     "reset"     "sink"      $CLOCK_INTF      
	add_interface_port      reset_n     "reset_n"   "reset_n"   "input"     1


	#------------------------------
	# Data Master Interface
	#------------------------------
	add_interface           $D_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
	set_interface_property  $D_MASTER_INTF   "burstOnBurstBoundariesOnly"           "true"
	set_interface_property  $D_MASTER_INTF   "linewrapBursts"                       "false"
	set_interface_property  $D_MASTER_INTF   "alwaysBurstMaxBurst"                  "false"
	set_interface_property  $D_MASTER_INTF   "doStreamReads"                        "false"
	set_interface_property  $D_MASTER_INTF   "doStreamWrites"                       "false"
	set_interface_property  $D_MASTER_INTF   "addressGroup"                         "1"
	set_interface_property	$D_MASTER_INTF	 "registerIncomingSignals"		        "true"
	set_interface_property  $D_MASTER_INTF   "associatedReset"                      "reset_n"
	add_interface_port      $D_MASTER_INTF   "d_address"         "address"           "output"    32
	add_interface_port      $D_MASTER_INTF   "d_byteenable"      "byteenable"        "output"    4
	add_interface_port      $D_MASTER_INTF   "d_read"            "read"              "output"    1
	add_interface_port      $D_MASTER_INTF   "d_readdata"        "readdata"          "input"     32
	add_interface_port      $D_MASTER_INTF   "d_waitrequest"     "waitrequest"       "input"     1
	add_interface_port      $D_MASTER_INTF   "d_write"           "write"             "output"    1
	add_interface_port      $D_MASTER_INTF   "d_writedata"       "writedata"         "output"    32
	# jtag_debug_module_debugaccess_to_roms only exist when debug there is jtag debug module
    set debug_level [ get_parameter_value debug_level ]
    if { [ expr { "$debug_level" != "NoDebug" } ] } {
        add_interface_port      $D_MASTER_INTF  "jtag_debug_module_debugaccess_to_roms"   "debugaccess"   "output"        1
    }


	set_port_property d_address WIDTH_EXPR  [get_parameter_value AVL_DATA_ADDR_WIDTH]

	#------------------------------
	# Instruction Master Interface
	#------------------------------
	add_interface           $I_MASTER_INTF   "avalon"            "master"            $CLOCK_INTF
	set_interface_property  $I_MASTER_INTF   "burstOnBurstBoundariesOnly"           "false"
	set_interface_property  $I_MASTER_INTF   "linewrapBursts"                       "true"
	set_interface_property  $I_MASTER_INTF   "alwaysBurstMaxBurst"                  "true"
	set_interface_property  $I_MASTER_INTF   "doStreamReads"                        "false"
	set_interface_property  $I_MASTER_INTF   "doStreamWrites"                       "false"
	set_interface_property  $I_MASTER_INTF   "addressGroup"                         "1"
	set_interface_property  $I_MASTER_INTF   "associatedReset"                      "reset_n"
	# this was commented in the original Nios hw.tcl
	#set_interface_property	$I_MASTER_INTF	 "registerIncomingSignals"		"true"
	add_interface_port      $I_MASTER_INTF  "i_address"         "address"           "output"    1
	add_interface_port      $I_MASTER_INTF  "i_read"            "read"              "output"    1
	add_interface_port      $I_MASTER_INTF  "i_readdata"        "readdata"          "input"     32
	add_interface_port      $I_MASTER_INTF  "i_waitrequest"     "waitrequest"       "input"     1
	# this was commented in the original Nios hw.tcl
	#add_interface_port      $I_MASTER_INTF  "i_readdatavalid"     "readdatavalid"       "input"     1

	set_port_property i_address WIDTH_EXPR  [get_parameter_value AVL_INST_ADDR_WIDTH]

	#------------------------------
	# Interrupt Interfaces
	#------------------------------
	# Internal IRQ Controller
	add_interface           $D_IRQ_INTF     "interrupt"                         "receiver"              $CLOCK_INTF
	add_interface_port      $D_IRQ_INTF     "d_irq"                             "irq"                   "input"     32
	set_interface_property  $D_IRQ_INTF     "irqScheme"                         "individualRequests"
	set_interface_property  $D_IRQ_INTF     "associatedAddressablePoint"        $D_MASTER_INTF
	set_interface_property  $D_IRQ_INTF     "ENABLED"                           "true"
	set_interface_property  $D_IRQ_INTF     "associatedReset"                   "reset_n"

	#------------------------------
	# [6.8] Custom Instruction
	#------------------------------
	add_interface       $CI_MASTER_INTF     "nios_custom_instruction"       "master"
	# No CI Slave, just put any thing here for termination
	add_interface_port $CI_MASTER_INTF   "no_ci_readra"         "readra"        "output"        1


    set local_debug_level [ get_parameter_value debug_level ]
    if { "${local_debug_level}" != "NoDebug" } {
        # SPR:350621 resetrequest no longer valid in avalon interface
        add_interface           jtag_debug_module_reset      "reset"                "output"        $CLOCK_INTF
        add_interface_port      jtag_debug_module_reset     "jtag_debug_module_resetrequest"        "reset"     "output"        1
        # SPR:355400 to break reset loop when global reset is on
        set_interface_property  jtag_debug_module_reset     "associatedResetSinks"  "none"
        
        add_interface           $DEBUG_INTF     "avalon"                            "slave"                 $CLOCK_INTF

        add_interface_port      $DEBUG_INTF     "jtag_debug_module_address"         "address"               "input"        9
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_begintransfer"   "begintransfer"         "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_byteenable"      "byteenable"            "input"        4
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_debugaccess"     "debugaccess"           "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_readdata"        "readdata"              "output"       32
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_select"          "chipselect"            "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_write"           "write"                 "input"        1
        add_interface_port      $DEBUG_INTF     "jtag_debug_module_writedata"       "writedata"             "input"        32
        set_interface_property  $DEBUG_INTF     "maximumPendingReadTransactions"    "0"
        set_interface_property  $DEBUG_INTF     "associatedClock"                   "$CLOCK_INTF"
        set_interface_property  $DEBUG_INTF     "alwaysBurstMaxBurst"               "false"
        set_interface_property  $DEBUG_INTF     "isMemoryDevice"                    "true"
        set_interface_property  $DEBUG_INTF     "registerIncomingSignals"           "true"
        set_interface_property  $DEBUG_INTF     "associatedReset"                   "reset_n"
        set_interface_property  $DEBUG_INTF     "ENABLED"                           "true"
        set_interface_assignment $DEBUG_INTF    "qsys.ui.connect"                   "${I_MASTER_INTF},${D_MASTER_INTF}"
        
        proc_set_interface_embeddedsw_configuration_assignment $DEBUG_INTF     "hideDevice" 1

        # TODO: finish proper interface property settings
            #    Address_Alignment = "dynamic";
            #    Well_Behaved_Waitrequest = "0";
            #    Minimum_Uninterrupted_Run_Length = "1";
            #    Accepts_Internal_Connections = "1";
            #    Write_Latency = "0";
            #    Register_Incoming_Signals = "0";
            #    Register_Outgoing_Signals = "0";
            #    Always_Burst_Max_Burst = "0";
            #    Is_Big_Endian = "0";
            #    Is_Enabled = "1";
            #    Accepts_External_Connections = "1";
            #    Requires_Internal_Connections = "";
    }


	# Set the toplevel fileset name for all filesets. This must be done
	# in the elaboration callback
	set_fileset_property quartus_synth TOP_LEVEL "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_synth_cpu_inst"
	set_fileset_property sim_verilog TOP_LEVEL "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_sim_cpu_inst"
	set_fileset_property sim_vhdl TOP_LEVEL "[alt_mem_if::util::iptclgen::generate_outfile_name altera_mem_if_sequencer_cpu.v [solve_core_params] 1]_sim_cpu_inst"

}
