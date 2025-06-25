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


package require -exact sopc 10.0

# +------------------------------------------------------------------
# | module ALTERA FIR COMPILER II
# +------------------------------------------------------------------
set_module_property DESCRIPTION "ALTERA FIR Compiler II"
set_module_property NAME altera_fir_compiler_ii
set_module_property VERSION 13.1
set_module_property GROUP "DSP/Filters"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "FIR Compiler II"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_fir_compiler_ii.pdf"

# this hw.tcl file is custom, so it's not EDITABLE by ComponentEditor.
# set HELPER_JAR to be the MegaWizardII GUI jar file.
# use ELABORATION_CALLBACK to set ports per parameter values.
#set_module_property EDITABLE true
set_module_property HELPER_JAR high_performance_fir.jar
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validation
set_module_property GENERATION_CALLBACK gen_synth_files
set_module_property preview_generate_vhdl_simulation_callback gen_sim_files
set_module_property preview_generate_verilog_simulation_callback gen_sim_files
#set_module_property ANALYZE_HDL FALSE

# add Avalon-ST components files
set module_dir [get_module_property MODULE_DIRECTORY]
add_file ${module_dir}/../../sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_math_pkg_hpfir.vhd {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_lib_pkg_hpfir.vhd {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_avalon_streaming_controller_hpfir.vhd {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_avalon_streaming_sink_hpfir.vhd {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_avalon_streaming_source_hpfir.vhd {SYNTHESIS SIMULATION}
add_file ${module_dir}/ast_components/auk_dspip_roundsat_hpfir.vhd {SYNTHESIS SIMULATION}

# DSPBA library files, now in the platform specific directory under 'backend'
if { [regexp -nocase win $::tcl_platform(os) match] } {
    set PLATFORM "windows"
} else {
    set PLATFORM "linux"
}
# Only the native tcl interpreter has 'tcl_platform(wordSize)'
# In Jacl however 'tcl_platform(machine)' is set to the JVM bitness, not the OS bitness
if { [catch {set WORDSIZE $::tcl_platform(wordSize)} errmsg] } {
    if {[string match "*64" $::tcl_platform(machine)]} {
        set WORDSIZE 8
    } else {
        set WORDSIZE 4
    }
}
if { $WORDSIZE == 8 } {
    set PLATFORM "${PLATFORM}64"
} else {
    set PLATFORM "${PLATFORM}32"
}        

set DSPBA_BACKEND_DIR "${env(QUARTUS_ROOTDIR)}/dspba/backend"
set DSPBA_BACKEND_BIN_DIR "$DSPBA_BACKEND_DIR/$PLATFORM"

add_file ${DSPBA_BACKEND_DIR}/Libraries/vhdl/base/dspba_library_package.vhd {SYNTHESIS SIMULATION}
add_file ${DSPBA_BACKEND_DIR}/Libraries/vhdl/base/dspba_library.vhd {SYNTHESIS SIMULATION}

# +------------------------------------------------------------------
# | Parameters 
# +------------------------------------------------------------------

# | Device family
# +------------------------------------------------------------------
add_parameter "deviceFamily" string "Stratix III"
#set_parameter_property "deviceFamily" DERIVED true
set_parameter_property "deviceFamily" DISPLAY_NAME "Device Family"
set_parameter_property "deviceFamily" system_info {DEVICE_FAMILY}
set_parameter_property "deviceFamily" ALLOWED_RANGES {"Stratix III" "Stratix IV" "Stratix V" "Cyclone III" "Cyclone III LS" "Cyclone IV E" "Cyclone IV GX" "Cyclone V" "Arria II GX" "Arria II GZ" "Arria V" "Arria V GZ" "Arria 10"}
set_parameter_property "deviceFamily" ENABLED 0

# | Filter type
# +------------------------------------------------------------------
add_parameter "filterType" string "Single Rate"
set_parameter_property "filterType" DISPLAY_NAME "Filter Type"
set_parameter_property "filterType" ALLOWED_RANGES {"Single Rate" "Decimation" "Interpolation" "Fractional Rate"}

# | Interpolation rate
# +------------------------------------------------------------------
add_parameter "interpFactor" int 1
set_parameter_property "interpFactor" DISPLAY_NAME "Interpolation Factor"
set_parameter_property "interpFactor" ALLOWED_RANGES {1:128}

# | Decimation rate
# +------------------------------------------------------------------
add_parameter "decimFactor" int 1
set_parameter_property "decimFactor" DISPLAY_NAME "Decimation Factor"
set_parameter_property "decimFactor" ALLOWED_RANGES {1:128}

# | Number of bands
# | 1 = normal, 2 = halfband, 3 = 3rd band, etc.
# +------------------------------------------------------------------
set list_L_band_num {}
set L_band_supported 5
for {set i 1} {$i <= $L_band_supported} {incr i 1} {
   lappend list_L_band_num $i
}

set list_L_band {}
foreach value $list_L_band_num {
    if { $value == 1 } {
      set list_L_band [lappend list_L_band "All taps"]
    } elseif { $value == 2 } {
      set list_L_band [lappend list_L_band "Half band"]
    } else {
      set temp [expr $value % 10]
      switch -exact -- $temp {
        1 { lappend list_L_band "$value st" }
        2 { lappend list_L_band "$value nd" }
        3 { lappend list_L_band "$value rd" }
        default { lappend list_L_band "$value th"}
      }
    }
}

add_parameter "L_bandsFilter" string "All taps"
set_parameter_property "L_bandsFilter" DISPLAY_NAME "Using L_Bands Filter"
set_parameter_property "L_bandsFilter" ALLOWED_RANGES $list_L_band

# | System clock rate (MHz)
# +------------------------------------------------------------------
add_parameter "clockRate" string 100
set_parameter_property "clockRate" DISPLAY_NAME "Clock Rate"

# | Extra slack for margin (MHz)
# +------------------------------------------------------------------
add_parameter "clockSlack" int 0
set_parameter_property "clockSlack" DISPLAY_NAME "Clock Slack"

# | Speed grade for device
# +------------------------------------------------------------------
add_parameter "speedGrade" string "Medium"
set_parameter_property "speedGrade" DISPLAY_NAME "Speed Grade"
set_parameter_property "speedGrade" ALLOWED_RANGES {"Fast" "Medium" "Slow"}

# | Enable Coefficient Reloading
# +------------------------------------------------------------------
add_parameter "coeffReload" boolean 0
set_parameter_property "coeffReload" DISPLAY_NAME "Coefficients Reload"
set_parameter_property "coeffReload" ENABLED 1

# | Base address for coefficient interface
# +------------------------------------------------------------------
add_parameter "baseAddress" int 0
set_parameter_property "baseAddress" DISPLAY_NAME "Base Address"
set_parameter_property "baseAddress" ENABLED 0

# | Are coefficients readable? writeable? 
# +------------------------------------------------------------------
add_parameter "readWriteMode" string "Read/Write"
set_parameter_property "readWriteMode" DISPLAY_NAME "Read/Write Mode"
set_parameter_property "readWriteMode" ALLOWED_RANGES {"Read" "Write" "Read/Write"}
set_parameter_property "readWriteMode" ENABLED 0

# | Global clock enable (TBD)
# +------------------------------------------------------------------
# add_parameter "globalClock" boolean 0
# set_parameter_property "globalClock" DISPLAY_NAME "Global Clock Enable"
# Not needed as enabling global clock enable in turn enable the backpressure support

# | Back Pressure support
# +------------------------------------------------------------------
add_parameter "backPressure" boolean 0
set_parameter_property "backPressure" DISPLAY_NAME "Back Pressure Support"
#set_parameter_property "backPressure" ENABLED 0

# | Type of symmetry
# +------------------------------------------------------------------
add_parameter "symmetryMode" string "Non Symmetry"
set_parameter_property "symmetryMode" DISPLAY_NAME "Symmetry"
set_parameter_property "symmetryMode" ALLOWED_RANGES {"Non Symmetry" "Symmetrical" "Anti-Symmetrical"}

# Refer DSP Advance Block Set user guide for more details about the resource optimization

# | If bits in delay is greater than this number then use a RAM (TBD)
# +------------------------------------------------------------------   
add_parameter "delayRAMBlockThreshold" int 20
set_parameter_property "delayRAMBlockThreshold" DISPLAY_NAME "CDelay RAM Block Threshold"
#set_parameter_property "delayRAMBlockThreshold" ALLOWED_RANGES {0:30000}

# | Number of bits before MLAB gets converted to M9K
# +------------------------------------------------------------------ 
add_parameter "dualMemDistRAMThreshold" int 1280
set_parameter_property "dualMemDistRAMThreshold" DISPLAY_NAME "CDual Mem Dist RAM Threshold"
#set_parameter_property "dualMemDistRAMThreshold" ALLOWED_RANGES {0:30000}

# | If bits  > this, use MRAM or M144K
# +------------------------------------------------------------------ 
add_parameter "mRAMThreshold" int 1000000
set_parameter_property "mRAMThreshold" DISPLAY_NAME "M-RAM Threshold"
#set_parameter_property "mRAMThreshold" ALLOWED_RANGES {0:30000}

# | Number of LUTs below which a mult with be made from LUTs
# +------------------------------------------------------------------ 
add_parameter "hardMultiplierThreshold" int -1
set_parameter_property "hardMultiplierThreshold" DISPLAY_NAME "Hard Multiplier Threshold"
#set_parameter_property "hardMultiplierThreshold" ALLOWED_RANGES {0:30000}

# | Sample rate per channel (MSPS)
# +------------------------------------------------------------------ 
add_parameter "inputRate" string 100
set_parameter_property "inputRate" DISPLAY_NAME "Input Sample Rate (MSPS)"

# | Number of channels
# +------------------------------------------------------------------
add_parameter "inputChannelNum" int 1
set_parameter_property "inputChannelNum" DISPLAY_NAME "Input Channel Number"
#set_parameter_property "inputChannelNum" ALLOWED_RANGES {1:128}

# | Input Data Type
# +------------------------------------------------------------------
add_parameter "inputType" string "Signed Binary"
set_parameter_property "inputType" DISPLAY_NAME "Input Type"
set_parameter_property "inputType" ALLOWED_RANGES {"Signed Binary" "Signed Fractional Binary"}

# | Sample data width in bits
# +------------------------------------------------------------------
add_parameter "inputBitWidth" int 8
set_parameter_property "inputBitWidth" DISPLAY_NAME "Input Bit Width"
set_parameter_property "inputBitWidth" ALLOWED_RANGES {1:32}

# | Sample data fraction width in bits
# +------------------------------------------------------------------
add_parameter "inputFracBitWidth" int 0
set_parameter_property "inputFracBitWidth" DISPLAY_NAME "Input Fractional Bit Width"
set_parameter_property "inputFracBitWidth" ALLOWED_RANGES {0:32}

# | Reset coefficients for the FIR (Original Value)
# +------------------------------------------------------------------
add_parameter "coeffSetRealValue" string "0.0176663, 0.013227, 0.0, -0.0149911, -0.0227152, -0.0172976, 0.0, 0.0204448, 0.0318046, 0.0249882, 0.0, -0.0321283, -0.0530093, -0.04498, 0.0, 0.0749693, 0.159034, 0.224907, 0.249809, 0.224907, 0.159034, 0.0749693, 0.0, -0.04498, -0.0530093, -0.0321283, 0.0, 0.0249882, 0.0318046, 0.0204448, 0.0, -0.0172976, -0.0227152, -0.0149911, 0.0, 0.013227, 0.0176663"
#set_parameter_property "coeffSetRealValue" DERIVED true

add_parameter "coeffNum" int 8
set_parameter_property "coeffNum" DERIVED true

# | Reset coefficients (Scaled Value calculated by JAVA)
# +------------------------------------------------------------------
add_parameter "coeffSetScaleValue" string "0.125,0.125,0.125,0.125,0.125,0.125,0.125,0.125"
set_parameter_property "coeffSetScaleValue" DERIVED true

# | Reset coefficients (Fixed Point Value calculated by JAVA)
# +------------------------------------------------------------------
add_parameter "coeffSetFixedValue" string "127,127,127,127,127,127,127,127"
set_parameter_property "coeffSetFixedValue" DERIVED true

# | Coefficient Data Type
# +------------------------------------------------------------------
add_parameter "coeffType" string "Signed Binary"
set_parameter_property "coeffType" DISPLAY_NAME "Coefficient Data Type"
set_parameter_property "coeffType" ALLOWED_RANGES {"Signed Binary" "Signed Fractional Binary"}

# | Coefficient Scaling
# +------------------------------------------------------------------
add_parameter "coeffScaling" string "Auto"
set_parameter_property "coeffScaling" DISPLAY_NAME "Coefficient Scaling"
set_parameter_property "coeffScaling" ALLOWED_RANGES {"Auto" "None"}

# | Coefficient width in bits
# +------------------------------------------------------------------
add_parameter "coeffBitWidth" int 8
set_parameter_property "coeffBitWidth" DISPLAY_NAME "Coefficient Bit Width"
set_parameter_property "coeffBitWidth" ALLOWED_RANGES {2:32}

# | Coefficient fraction width in bits
# +------------------------------------------------------------------
add_parameter "coeffFracBitWidth" int 0
set_parameter_property "coeffFracBitWidth" DISPLAY_NAME "Coefficient Fractional Bit Width"
set_parameter_property "coeffFracBitWidth" ALLOWED_RANGES {0:32}

# | Coefficient derived width in bits
# +------------------------------------------------------------------
add_parameter "coeffBitWidth_derived" int 8
set_parameter_property "coeffBitWidth_derived" DERIVED true

# | Output Data Type 
# +------------------------------------------------------------------
add_parameter "outType" string "Signed Binary"
set_parameter_property "outType" DISPLAY_NAME "Output Type"
set_parameter_property "outType" ALLOWED_RANGES {"Signed Binary" "Signed Fractional Binary"}
set_parameter_property "outType" ENABLED 1

# | Output width in bits
# +------------------------------------------------------------------
add_parameter "outBitWidth" int 19
set_parameter_property "outBitWidth" DISPLAY_NAME "Output Bit Width"
set_parameter_property "outBitWidth" ENABLED 0
set_parameter_property "outBitWidth" DERIVED true

# | Output fraction width in bits 
# +------------------------------------------------------------------
add_parameter "outFracBitWidth" int 0
set_parameter_property "outFracBitWidth" DISPLAY_NAME "Output Fractional Bit Width"
set_parameter_property "outFracBitWidth" ENABLED 0
set_parameter_property "outFracBitWidth" DERIVED true

# | Output MSB rounding type
# +------------------------------------------------------------------
add_parameter "outMSBRound" string "Truncation"
set_parameter_property "outMSBRound" DISPLAY_NAME "MSB Rounding"
set_parameter_property "outMSBRound" ALLOWED_RANGES {"Truncation" "Saturating"}
set_parameter_property "outMSBRound" ENABLED 1

# | Output MSB bits to remove
# +------------------------------------------------------------------
add_parameter "outMsbBitRem" int 0
set_parameter_property "outMsbBitRem" DISPLAY_NAME "MSB Bits to Remove"
set_parameter_property "outMsbBitRem" ALLOWED_RANGES {0:32}
set_parameter_property "outMsbBitRem" ENABLED 1

# | Output LSB rounding type
# +------------------------------------------------------------------
add_parameter "outLSBRound" string "Truncation"
set_parameter_property "outLSBRound" DISPLAY_NAME "LSB Rounding"
set_parameter_property "outLSBRound" ALLOWED_RANGES {"Truncation" "Rounding"}
set_parameter_property "outLSBRound" ENABLED 1

# | Output MSB bits to remove
# +------------------------------------------------------------------
add_parameter "outLsbBitRem" int 0
set_parameter_property "outLsbBitRem" DISPLAY_NAME "LSB Bits to Remove"
set_parameter_property "outLsbBitRem" ALLOWED_RANGES {0:32}
set_parameter_property "outLsbBitRem" ENABLED 1

# | Get the output width of result (bits) 
# +------------------------------------------------------------------
add_parameter "outFullBitWidth" int 19
set_parameter_property "outFullBitWidth" DISPLAY_NAME "Output Full Bit Width"
set_parameter_property "outFullBitWidth" ENABLED 0
set_parameter_property "outFullBitWidth" DERIVED true

# | Get the output fraction width of result (bits) 
# +------------------------------------------------------------------
add_parameter "outFullFracBitWidth" int 5
set_parameter_property "outFullFracBitWidth" DISPLAY_NAME "Output Full Fractional Bit Width"
set_parameter_property "outFullFracBitWidth" ENABLED 0
set_parameter_property "outFullFracBitWidth" DERIVED true

# | Get the number of input data ports (xIn_0 ... xIn_{n-1})
# +------------------------------------------------------------------
add_parameter "inputInterfaceNum" int 1
set_parameter_property "inputInterfaceNum" DERIVED true

# | Get the number of output data ports (xOut_0 ... xOut_{n-1})
# +------------------------------------------------------------------
add_parameter "outputInterfaceNum" int 1
set_parameter_property "outputInterfaceNum" DERIVED true

# | Get the number of channels per input data ports 
# +------------------------------------------------------------------
add_parameter "chanPerInputInterface" int 1
set_parameter_property "chanPerInputInterface" DERIVED true

# | Get the number of channels per output data ports 
# +------------------------------------------------------------------
add_parameter "chanPerOutputInterface" int 1
set_parameter_property "chanPerOutputInterface" DERIVED true

# | Get the resource estimation (TBD)
# +------------------------------------------------------------------
add_parameter "resoureEstimation" string "1000,1200,10"
set_parameter_property "resoureEstimation" DISPLAY_NAME "Resource Estimationss"

# | Get the number of bankcount 
# +------------------------------------------------------------------
add_parameter "bankCount" int 1
#set_parameter_property "bankCount" ALLOWED_RANGES {1:128}
set_parameter_property "bankCount" DISPLAY_NAME "Number of Coefficient Banks"

# | Display coefficient bank 
# +------------------------------------------------------------------
add_parameter "bankDisplay" int 0
set_parameter_property "bankDisplay" ALLOWED_RANGES 0
set_parameter_property "bankDisplay" DISPLAY_NAME "Show Coefficient Bank"

# | This parameter check for error 
# +------------------------------------------------------------------
add_parameter errorList int 0
set_parameter_property errorList DERIVED true

proc set_config {conf} {

    upvar $conf config
    
    if [array exists config] {
        array unset config
    } else {
        if [info exists config] {
            unset config
        }
    }
    
    # Check for error status
    set errorList [get_parameter_value errorList]
     
    # If there isn't any error, get value of output bit width, number of input/output wire
    if { $errorList == 0 } {
      set config(InWidth) [get_parameter_value inputBitWidth]
      set config(FullWidth) [get_parameter_value outFullBitWidth]
      set config(PhysChanIn) [get_parameter_value inputInterfaceNum]
      set config(PhysChanOut) [get_parameter_value outputInterfaceNum]   
      set config(ChansPerPhyIn) [get_parameter_value chanPerInputInterface]
      set config(ChansPerPhyOut) [get_parameter_value chanPerOutputInterface]
    } else {
      set config(InWidth) 2
      set config(FullWidth) 2
      set config(PhysChanIn) 1
      set config(PhysChanOut) 1
      set config(ChansPerPhyIn) 1
      set config(ChansPerPhyOut) 1
    }

    # Top-level file extension, will be wrapped by v/vhd wrapper
    set config(extension) ".vhd"

    set config(coeffReload) [get_parameter_value coeffReload]

    set config(out_msb_bit_rem) [get_parameter_value "outMsbBitRem"]
    set config(out_lsb_bit_rem) [get_parameter_value "outLsbBitRem"]

    set config(OutWidth) [expr int($config(FullWidth) - $config(out_msb_bit_rem) - $config(out_lsb_bit_rem))]
    set config(PhysChanIn) [expr int($config(PhysChanIn))]
    set config(PhysChanOut) [expr int($config(PhysChanOut))]
    set config(Log2_ChansPerPhyOut) [expr log($config(ChansPerPhyOut))/log(2)]
    if {$config(Log2_ChansPerPhyOut) > 1} {
        set config(Log2_ChansPerPhyOut) [expr int([expr ceil($config(Log2_ChansPerPhyOut))])]
    } else {
        set config(Log2_ChansPerPhyOut) 1
    }

    set config(bankcount) [get_parameter_value "bankCount"]

    if {$config(bankcount) == 1} {
        set config(bankInWidth) 0
    } else {
        set log2_bankInWidth [expr log($config(bankcount))/log(2)]
        if {$log2_bankInWidth > 1} {
            set config(bankInWidth) [expr int([expr ceil($log2_bankInWidth)])]
        } else {
            set config(bankInWidth) 1
        }
    }
      
    set config(useClkEnable) [get_parameter_value "backPressure"]

    set config(module_dir) [get_module_property MODULE_DIRECTORY]
    
    set config(filter_type) [get_parameter_value "filterType"]
    set config(coeffReload) [get_parameter_value "coeffReload"]

    set config(input_type) [get_parameter_value "inputType"]
    set config(out_lsb_rnd_typ) [get_parameter_value "outLSBRound"]
    set config(devicefamily) [get_parameter_value "deviceFamily"]
    
    if { $config(coeffReload) == "true" } {
        set config(readWriteMode) [get_parameter_value "readWriteMode"]
        if { [string compare $config(readWriteMode) "Read"] == 0 } {
            set config(coefficientReadback) "true"
            set config(coefficientWriteable) "false"
        } elseif { [string compare $config(readWriteMode) "Write"] == 0 } {
            set config(coefficientReadback) "false"
            set config(coefficientWriteable) "true"
        } elseif { [string compare $config(readWriteMode) "Read/Write"] == 0 } {
            set config(coefficientReadback) "true"
            set config(coefficientWriteable) "true"
        } else {
            set config(coefficientReadback) "false"
            set config(coefficientWriteable) "false"
        }
    } else {
        set config(readWriteMode) "none"
        set config(coefficientReadback) "false"
        # set coefficients to be writeable until SPR 311201 is fixed 
        set config(coefficientWriteable) "false" 
    }

    ## Coefficient parameters
    set config(coeff_type) [get_parameter_value "coeffType"]
    set config(coefFracWidth) [get_parameter_value "coeffFracBitWidth"]
    set config(coeffScaling) [get_parameter_value "coeffScaling"]
    
    set config(coeffSetFullList) [split [get_parameter_value "coeffSetRealValue"] ","]
    set maxCoeff_full [expr int ( [lindex [lsort -real -decreasing $config(coeffSetFullList)] 0] ) ]
    set minCoeff_full [expr int ( [lindex [lsort -real -increasing $config(coeffSetFullList)] 0] ) ]

    set abs_maxCoeff_full [expr abs($maxCoeff_full)]
    set abs_minCoeff_full [expr abs($minCoeff_full)]

    if { $abs_maxCoeff_full >= $abs_minCoeff_full } {
        if { $maxCoeff_full > 0 } {
            set log2_coefWidth_derived [expr log([expr $abs_maxCoeff_full+1])/log(2)]
        } else {
            set log2_coefWidth_derived 0
        }
    } else {
        if { $minCoeff_full > 0 } {
            set log2_coefWidth_derived [expr log([expr $abs_minCoeff_full])/log(2)]
        } else {
            set log2_coefWidth_derived 0
        }
    }

    set config(coefWidth_derived) [expr int([expr ceil($log2_coefWidth_derived)]) + 1]
    
    if { $config(coeff_type) == "Signed Fractional Binary" && $config(coeffReload) == "false" } {    
        set config(coefWidth) [expr $config(coefWidth_derived) + $config(coefFracWidth)]
    } elseif { $config(coeff_type) == "Signed Fractional Binary" && $config(coeffReload) == "true" } {
        #coefWidth specified by user is passed to fir_ip_api_interface, may be different from the width used to calculate fixed-point coefficient
        set config(coefWidth)  [get_parameter_value "coeffBitWidth"]
    } else {
        set config(coefWidth)  [get_parameter_value "coeffBitWidth"]
    }

    if { $config(coeffScaling) != "None" } {
        if { $config(coeff_type) == "Signed Binary" } {
            set config(coefFracWidth) 0
        }
    }
    
    if { $config(coeff_type) == "Signed Binary" } {
      set config(coefFullWidth) $config(coefWidth)
    } else {
      set config(coefFullWidth) [expr $config(coefWidth_derived) + $config(coefFracWidth)]
    }

    # In the future, busDataWidth and busAddressWidth parameters must be able to be select by the customer. 
    if { $config(coefWidth) <= 16 } {
        set config(busDataWidth) 16
    } else {
        set config(busDataWidth) 32
    }
}

# +------------------------------------------------------------------
# | Elaboration 
# +------------------------------------------------------------------
# With Avalon-ST wrapper
proc elaborate {} {
    set_config config
    
    set_parameter_property "bankDisplay" ALLOWED_RANGES "0:[expr $config(bankcount) - 1]"
    
    # connection point clock
    add_interface clk clock end
    set_interface_property clk ENABLED true
    add_interface_port clk clk clk Input 1

    # connection point reset
    add_interface rst reset end
    set_interface_property rst ENABLED true
    set_interface_property rst associatedClock clk
    add_interface_port rst reset_n reset_n Input 1

    # connection point avalon_streaming_sink
    add_interface avalon_streaming_sink avalon_streaming end
    set_interface_property avalon_streaming_sink ENABLED true    
    set_interface_property avalon_streaming_sink associatedClock clk
    set_interface_property avalon_streaming_sink associatedReset rst
    add_interface_port avalon_streaming_sink ast_sink_data data input [expr {($config(bankInWidth) + $config(InWidth)) * $config(PhysChanIn)}]
    add_interface_port avalon_streaming_sink ast_sink_valid valid input 1
    add_interface_port avalon_streaming_sink ast_sink_error error Input 2
    set_interface_property avalon_streaming_sink dataBitsPerSymbol [expr {($config(bankInWidth) + $config(InWidth)) * $config(PhysChanIn)}]

    if {$config(ChansPerPhyIn) > 1} {
        add_interface_port avalon_streaming_sink ast_sink_sop startofpacket input 1
        add_interface_port avalon_streaming_sink ast_sink_eop endofpacket input 1
    }

    # connection point avalon_streaming_source
    add_interface avalon_streaming_source avalon_streaming start
    set_interface_property avalon_streaming_source ENABLED true    
    set_interface_property avalon_streaming_source associatedClock clk
    set_interface_property avalon_streaming_source associatedReset rst
    add_interface_port avalon_streaming_source ast_source_data data output [expr {$config(OutWidth) * $config(PhysChanOut)}]
    add_interface_port avalon_streaming_source ast_source_valid valid output 1
    add_interface_port avalon_streaming_source ast_source_error error output 2
    set_interface_property avalon_streaming_source dataBitsPerSymbol [expr {$config(OutWidth) * $config(PhysChanOut)}]

    # Backpressure signals
    if {$config(useClkEnable) == "true"} {
        add_interface_port avalon_streaming_sink ast_sink_ready ready output 1
        add_interface_port avalon_streaming_source ast_source_ready ready input 1
    }

    if {$config(ChansPerPhyOut) > 1} {
        add_interface_port avalon_streaming_source ast_source_sop startofpacket output 1
        add_interface_port avalon_streaming_source ast_source_eop endofpacket output 1
        add_interface_port avalon_streaming_source ast_source_channel channel output $config(Log2_ChansPerPhyOut)
        set_port_property ast_source_channel vhdl_type std_logic_vector
    }

    if { $config(coeffReload) == "true" } {

        # connection point coefficient clock
        add_interface coeff_clock clock end
        set_interface_property coeff_clock ENABLED true
        add_interface_port coeff_clock coeff_in_clk clk input 1
        
        # connection point coefficient reset
        add_interface coeff_reset reset end
        set_interface_property coeff_reset ENABLED true
        set_interface_property coeff_reset associatedClock clk
        add_interface_port coeff_reset coeff_in_areset reset_n Input 1

        # connection point avalon_mm_slave
        add_interface avalon_mm_slave avalon slave
        set_interface_property avalon_mm_slave associatedClock coeff_clock
        set_interface_property avalon_mm_slave associatedReset coeff_reset

        set readWriteMode [get_parameter_value readWriteMode]
        if {[string match "Read/Write" $readWriteMode] || [string match "Read" $readWriteMode]} {
            set_interface_property avalon_mm_slave maximumPendingReadTransactions 1
            add_interface_port avalon_mm_slave coeff_in_address address input 12
            add_interface_port avalon_mm_slave coeff_in_we write input 1
            add_interface_port avalon_mm_slave coeff_in_read read input 1
            set_port_property coeff_in_we vhdl_type std_logic_vector
            add_interface_port avalon_mm_slave coeff_in_data writedata input $config(busDataWidth)
            add_interface_port avalon_mm_slave coeff_out_valid readdatavalid output 1
            set_port_property coeff_out_valid vhdl_type std_logic_vector
            add_interface_port avalon_mm_slave coeff_out_data readdata output $config(busDataWidth)
        } elseif {[string match "Write" $readWriteMode]} {
            add_interface_port avalon_mm_slave coeff_in_address address input 12
            add_interface_port avalon_mm_slave coeff_in_we write input 1
            set_port_property coeff_in_we vhdl_type std_logic_vector
            add_interface_port avalon_mm_slave coeff_in_data writedata input $config(busDataWidth)
        }
    }

}

proc set_input_params {conf inParams outParams} {
    upvar $conf config
    upvar $inParams inputParams;
    upvar $outParams outputParams;
    
    if [array exists inputParams] {
        array unset inputParams
    } else {
        if [info exists inputParams] {
            unset inputParams
        }
    }

    if [array exists outputParams] {
        array unset outputParams
    } else {
        if [info exists outputParams] {
            unset outputParams
        }
    }

    set inputParams(clockRate) [get_parameter_value "clockRate"]

    ## Update filter type and filter factor
    set inputParams(interpN) [get_parameter_value "interpFactor"]
    set inputParams(decimN) [get_parameter_value "decimFactor"]
    
    ## Input parameters
    set inputParams(inFracWidth) [get_parameter_value "inputFracBitWidth"]

    if { $config(input_type) == "Signed Binary" } {
        set inputParams(inFracWidth) 0
    }

    #family parameter will be passed to fir_ip_api_interface, e.g. Stratix III -> STRATIXIII
    regsub -all " +" $config(devicefamily) "" inputParams(family)
    set inputParams(family) [string toupper $inputParams(family)]

    set inputParams(speedGrade) [string tolower [get_parameter_value "speedGrade"]]
        
    set inputParams(clockSlack) [get_parameter_value "clockSlack"]
    set inputParams(nChans) [get_parameter_value "inputChannelNum"]

    set inputParams(inRate) [get_parameter_value "inputRate"]
    set inputParams(baseAddr) [get_parameter_value "baseAddress"]
    set symmetry_mode [get_parameter_value "symmetryMode"]
    
    if { $symmetry_mode == "Non Symmetry" } {
        set inputParams(symmetry) "1"
        set inputParams(symmetry_type) "nsym"
    } elseif { $symmetry_mode == "Symmetrical" } {
        set inputParams(symmetry) "2"
        set inputParams(symmetry_type) "sym"
    } elseif { $symmetry_mode == "Anti-Symmetrical" } {
        set inputParams(symmetry) "2"
        set inputParams(symmetry_type) "asym"
    } else {
        set inputParams(symmetry) "1"
        set inputParams(symmetry_type) "nsym"
    }

    set bandList [get_parameter_value "L_bandsFilter"]
    set temp [lindex [split $bandList] 0]
    if { $temp == "All" } {
        set inputParams(nband) "1"
    } elseif { $temp == "Half" } {
        set inputParams(nband) "2"
    } else {
        set inputParams(nband) "$temp"
    }
    
    set inputParams(coeffSet) [get_parameter_value "coeffSetFixedValue"]
    
    set inputParams(busAddressWidth) 12

    # Need advice from DSPBA team regarding the legal range of these parameters
    set inputParams(delayRAMBlockThreshold) [get_parameter_value "delayRAMBlockThreshold"]
    set inputParams(dualMemDistRAMThreshold) [get_parameter_value "dualMemDistRAMThreshold"]
    set inputParams(mRAMThreshold) [get_parameter_value "mRAMThreshold"]
    set inputParams(hardMultiplierThreshold) [get_parameter_value "hardMultiplierThreshold"]

    set outputParams(fullOutFracBitWidth) [get_parameter_value "outFullFracBitWidth"]
    set outputParams(outFracBitWidth) [get_parameter_value "outFracBitWidth"]    
    set outputParams(out_msb_rnd_typ) [get_parameter_value "outMSBRound"]
}

proc setup_params_if_no_error {mode conf inParams outParams} {
    upvar $conf config
    upvar $inParams inputParams
    upvar $outParams outputParams
    
    set errorList 0
    
    # Calculate fixed point and scale coefficient set, same calculation is done in GUI but based on the java method in jar file
    set num_of_coefs [expr [llength $config(coeffSetFullList)] / $config(bankcount)]
    set coeffSetFixedValue ""
    set coeffSetScaleValue ""

    # Separate coefficients into banks for scaling
    for {set bank 0} { $bank < $config(bankcount)} {incr bank} {
        set coeffSetList ""
        for {set coef 0} { $coef < $num_of_coefs} {incr coef} {
            lappend coeffSetList [lindex $config(coeffSetFullList) [expr $num_of_coefs * $bank+$coef]]
        }
        set coeffSetScaleValuePerBank $coeffSetList
        set coeffSetFixedValuePerBank $coeffSetList
        set maxCoeff [lindex [lsort -real -decreasing $coeffSetList] 0]
        set minCoeff [lindex [lsort -real -increasing $coeffSetList] 0]
        set abs_maxCoeff [expr abs($maxCoeff)]
        set abs_minCoeff [expr abs($minCoeff)]

        if { $abs_maxCoeff == 0 && $abs_minCoeff == 0 } {
            send_message "error" "Invalid coefficient on bank $bank, make sure they are not all zeros."
            return
        }


        if { $config(coeffScaling) == "Auto" } {
            if { $abs_maxCoeff >= $abs_minCoeff } {
                set factor [expr [expr [expr pow(2,[expr $config(coefFullWidth) - 1]) ] - 1] / $abs_maxCoeff ]
            } else {
                set factor [expr [expr pow(2,[expr $config(coefFullWidth) - 1]) ] / $abs_minCoeff ]
            }
        } else {
            set factor 1
        }

        for {set i 0} { $i < [llength $coeffSetList]} {incr i} {

            if { [lindex $coeffSetList $i] >= 0 } {
                #set coeffSetFixedValuePerBank [lreplace $coeffSetFixedValuePerBank $i $i [expr int( ( [expr [lindex $coeffSetList $i] * $factor + 0.5 ] ) ) ]]
                set coeffSetFixedValuePerBank [lreplace $coeffSetFixedValuePerBank $i $i [expr int ( [expr floor ( [expr [lindex $coeffSetList $i] * $factor ] ) ] ) ]]
            } else {
                #set coeffSetFixedValuePerBank [lreplace $coeffSetFixedValuePerBank $i $i [expr int( ( [expr [lindex $coeffSetList $i] * $factor - 0.5 ] ) ) ]]
                set coeffSetFixedValuePerBank [lreplace $coeffSetFixedValuePerBank $i $i [expr int ( [expr ceil ( [expr [lindex $coeffSetList $i] * $factor ] ) ] ) ]]
            }

            #send_message "info" "coeffSetFixedValuePerBank $i = [expr [lindex $coeffSetList $i] * $factor] )]"
            set coeffSetScaleValuePerBank [lreplace $coeffSetScaleValuePerBank $i $i [expr [lindex $coeffSetFixedValuePerBank $i] / $factor]]
        }

        set coeffSetFixedValue [concat $coeffSetFixedValue $coeffSetFixedValuePerBank]
        set coeffSetScaleValue [concat $coeffSetScaleValue $coeffSetScaleValuePerBank]
    }

    #Check if all fixed-point coefficients are zero.
    set coef_all_zero 1
    foreach coeff $coeffSetFixedValue {
        if { $coeff != 0 } {
            set coef_all_zero 0
            break
        }
    }

    if { $coef_all_zero == 1 } {
        send_message "error" "All of the filter coefficients are zero. You should either change the coefficient scaling or import non-zero coefficients."
        return
    }

    set coeffSetFixedValue [join $coeffSetFixedValue ","]
    set coeffSetScaleValue [join $coeffSetScaleValue ","]

    if { $mode == "validate" } {
        set_parameter_value coeffSetFixedValue $coeffSetFixedValue
        set_parameter_value coeffSetScaleValue $coeffSetScaleValue
        set_parameter_value coeffNum $num_of_coefs
    }

    set inputParams(nTaps) $num_of_coefs

    set inputParams(coeffSet) $coeffSetFixedValue

    # End fixed point and scale coefficient calculation

    # name and destination not important in this validation callback as we don't generate files here
    set inputParams(entity_name) "dummy"
    set inputParams(outdir) $config(module_dir)

    #Call fir_ip_api_interface without generating rtl files
    call_fir_ip_api_interface false config inputParams outputParams

    if {[info exists outputParams(funcResult)]} {
        set funcResultList [split $outputParams(funcResult) "|"]
        set funcResultListLength [llength $funcResultList]
        if {$funcResultListLength == 2} {
            send_message "error" "Error when creating FIR core"
        } elseif { $funcResultListLength == 13} {
            if { [string compare [lindex $funcResultList 1] "{}"] != 0 } {
                set errorMessage [lindex $funcResultList 1]
                regsub {^\{(.*)\}$} $errorMessage {\1} errorMessage
                send_message "error" "$errorMessage"
                set_parameter_value errorList 1
            } else {
                set outputParams(inputdataportcount) [lindex $funcResultList 2]
                set outputParams(outputdataportcount) [lindex $funcResultList 3]
                set outputParams(channelsperinputdataport) [lindex $funcResultList 4]
                set outputParams(channelsperoutputdataport) [lindex $funcResultList 5]
                set outputParams(fullOutBitWidth) [lindex $funcResultList 6]
                set outputParams(fullOutFracBitWidth) [lindex $funcResultList 7]
                set outputParams(latency) [lindex $funcResultList 8]
                set outputParams(outputfifodepth) [lindex $funcResultList 9]

                if { $mode == "validate" } {
                    set_parameter_value "outFullBitWidth" "$outputParams(fullOutBitWidth)"
                    set_parameter_value "outFullFracBitWidth" "$outputParams(fullOutFracBitWidth)"
                    set_parameter_value "inputInterfaceNum" "$outputParams(inputdataportcount)"
                    set_parameter_value "outputInterfaceNum" "$outputParams(outputdataportcount)"
                    set_parameter_value "chanPerInputInterface" "$outputParams(channelsperinputdataport)"
                    set_parameter_value "chanPerOutputInterface" "$outputParams(channelsperoutputdataport)"     
                    set_parameter_value "outBitWidth" [expr $outputParams(fullOutBitWidth) - $config(out_msb_bit_rem) - $config(out_lsb_bit_rem)]  
                    set_parameter_value "outFracBitWidth" [expr $outputParams(fullOutFracBitWidth) - $config(out_lsb_bit_rem)]
                    set outputParams(outFracBitWidth) [get_parameter_value "outFracBitWidth"]
                    set outputParams(resourceUsage) [lindex $funcResultList 11]

                    if { [string compare [lindex $funcResultList 10] "true"] == 0  } {
                        set_parameter_value errorList 0
                    } elseif { [string compare [lindex $funcResultList 10] "false"] == 0 } {
                        send_message "error" "There is an error when performing VHD code generation"
                        set_parameter_value errorList 1
                    } elseif { [string compare [lindex $funcResultList 10] "noCode"] == 0 } {
                        #send_message "info" "VHD Code is not generated by this validation function"
                        set_parameter_value errorList 0
                    } else {
                        send_message "error" "There is an unknown error"
                        set_parameter_value errorList 1
                    }
                    send_message "info" "PhysChanIn $outputParams(inputdataportcount), PhysChanOut $outputParams(outputdataportcount), ChansPerPhyIn $outputParams(channelsperinputdataport), ChansPerPhyOut $outputParams(channelsperoutputdataport), OutputFullBitWidth $outputParams(fullOutBitWidth), Bankcount $config(bankcount), CoefBitWidth $config(coefWidth)"
                    send_message "info" "Resource usage: $outputParams(resourceUsage)"
                }
            }
        } else {
            send_message "error" "Got $funcResultListLength return values when expecting 12 from fir_ip_api executable"
        }
    }
}

# +------------------------------------------------------------------
# | Validation
# +------------------------------------------------------------------
proc validation {} {

    set_config config
    
    set_input_params config inputParams outputParams
    
    set errorList 0
    
    if { [expr "($inputParams(clockRate) > 600) | ($inputParams(clockRate) <= 0)"] == 1}  {
      send_message "error" "Clock Frequency must be greater than 0 MHz and less than or equal to 600 MHz"
      set errorList 1
    }
    
    if { $config(filter_type) == "Single Rate" } {
      if {[expr ($inputParams(interpN) != 1) | ($inputParams(decimN) != 1)]==1} {
        send_message "error" "When Filter Type is Single Rate, Interpolation Factor and Decimation Factor must be 1"
        set errorList 1
      }
    } elseif { $config(filter_type) == "Decimation" } {
      if { [expr ($inputParams(decimN) == 1) | ($inputParams(interpN) != 1)] == 1 } {
        send_message "error" "When Filter Type is Decimation, Decimation Factor must be greater than 1 and Interpolation Factor must be 1"
        set errorList 1
      }
    } elseif { $config(filter_type) == "Interpolation" } {
      if { [expr ($inputParams(decimN) != 1) | ($inputParams(interpN) == 1)] == 1 } {
        send_message "error" "When Filter Type is Interpolation, Decimation Factor must be 1 and Interpolation Factor must be greater than 1"
        set errorList 1
      }
    } else {
      if { [expr ($inputParams(decimN) == 1) | ($inputParams(interpN) == 1)] == 1 } {
        send_message "error" "When Filter Type is Fractional Rate, Decimation Factor must be greater than 1 and Interpolation Factor must be greater than 1"
        set errorList 1
      }
    }   
        
    ## Update Coeff reload mode
    if { $config(coeffReload) == "false" } {
      set_parameter_property "baseAddress" ENABLED 0
      set_parameter_property "readWriteMode" ENABLED 0
    } else {
      set_parameter_property "baseAddress" ENABLED 1
      set_parameter_property "readWriteMode" ENABLED 1
    }   
    
    if { $config(input_type) == "Signed Binary" } {
      set_parameter_property "inputFracBitWidth" ENABLED 0
    } else {
      set_parameter_property "inputFracBitWidth" ENABLED 1
    }
    
    #send_message "info" "inputType: $config(input_type)"
    if { $config(input_type) == "Signed Binary" } {
      if { [expr ($config(InWidth) == 0) | ($inputParams(inFracWidth) != 0)] == 1} {
          send_message "error" "When Input Data Type is Signed Binary, Input Bit Width must be greater than 0 and Input Fractional Bit Width must be 0"
          set errorList 1
      }
    } else {
      set max_frac_width [expr $config(InWidth) - 1]
      if { [expr $inputParams(inFracWidth) > $max_frac_width] == 1 } {
          send_message "error" "Input Fractional Bit Width must be less than Input Bit Width minus the sign bit"
          set errorList 1
      }
    }   

    set_parameter_value coeffBitWidth_derived $config(coefWidth_derived)
    
    #Disable coefficient data type selection if coefficient scaling is disabled
    if { $config(coeffScaling) == "None" } {
      set_parameter_property "coeffFracBitWidth" ENABLED 0
      set_parameter_property "coeffBitWidth" ENABLED 1
      set_parameter_property "coeffType" ENABLED 0
    } else {
      set_parameter_property "coeffType" ENABLED 1    
      if { $config(coeff_type) == "Signed Binary" } {
        set_parameter_property "coeffFracBitWidth" ENABLED 0
        set_parameter_property "coeffBitWidth" ENABLED 1
        if { [expr ($config(coefWidth) == 0) | ($config(coefFracWidth) != 0)] == 1} {
            send_message "error" "When Coefficient Data Type is Signed Binary, Coefficient Bit Width must be greater than 0 and Coefficient Fractional Bit Width must be 0"
            set errorList 1
        }   
      } else {
        set_parameter_property "coeffFracBitWidth" ENABLED 1
        if { $config(coeffReload) == "false" } {
          set_parameter_property "coeffBitWidth" ENABLED 0
        } else {
          set_parameter_property "coeffBitWidth" ENABLED 1
          if { [get_parameter_value "coeffBitWidth"] < [expr $config(coefWidth_derived) + $config(coefFracWidth)] } {
            send_message "error" "Coefficient Bit Width must not be less than [expr $config(coefWidth_derived) + $config(coefFracWidth)] bits"
            set errorList 1
          }
          
        }
        if { [expr ($config(coefWidth) == 0) | ($config(coefFracWidth) == 0)] == 1} {
            send_message "error" "When Coefficient Data Type is Signed Fractional Binary, Coefficient Fractional Bit Width must be greater than 0"
            set errorList 1
        }
      }
    }
    
    ## Update output Bit Width
    set out_type [get_parameter_value "outType"]
    set out_full_bit_width [get_parameter_value "outFullBitWidth"]
    set out_bit_width [get_parameter_value "outBitWidth"]

    if { $out_type == "Signed Fractional Binary" } {
      if { $config(coeff_type) != "Signed Fractional Binary" || $config(input_type) != "Signed Fractional Binary"} {
        send_message "error" "When Output Data Type is Signed Fractional Binary, both Coefficient Data Type and Input Data Type must also be set to Signed Fractional Binary"
        set errorList 1
      }    
    }
    
    if { [expr "$out_bit_width > $out_full_bit_width"] == 1 } {
      send_message "error" "Output Full Bit Width should be greater than Output bit width"
      set errorList 1
    }
    
    if { [expr $outputParams(outFracBitWidth) > $outputParams(fullOutFracBitWidth)] == 1 } {
      send_message "error" "Output Fractional Full Bit Width should greater than Output Fractional bit width"   
      set errorList 1
    }

    if { $inputParams(nChans) < 1 || $inputParams(nChans) > 1024 } {
      send_message "error" "Number of Channels range from 1-1024"
      set errorList 1
    }
    
    if { $inputParams(inRate) <= 0 || $inputParams(inRate) > 10000 } {
      send_message "error" "Input Sample Rate must be greater than 0 and less than or equal to 10000"
      set errorList 1
    }

    if { $inputParams(clockRate) > 0 } {
      if { [expr $inputParams(inRate) / $inputParams(clockRate)] > 100 } {
        send_message "error" "Input Sample Rate/Clock Frequency should be less than 100"
        set errorList 1
      }
    }

    if { $config(coefFullWidth) > 32 } {
      send_message "error" "Total coefficient bit width must be less than 32 bits."
      set errorList 1
    }


    if {$errorList == 0} {
      setup_params_if_no_error "validate" config inputParams outputParams
    }


    ## post-processing validation
    # have to re-read these values as they may have changed above
    set outputParams(fullOutBitWidth) [get_parameter_value "outFullBitWidth"]
    # Output Type = Signed Fractional Binary format    
    if { $out_type == "Signed Fractional Binary" } {
      if { [expr $config(out_lsb_bit_rem) > $outputParams(fullOutFracBitWidth)] == 1 } {
        send_message "error" "When Output Type is Signed Fractional Binary, the LSB Bits to Remove must be less than Output Full Fractional Bit Width"
        set errorList 1
      }
      set decimal_bit [expr $outputParams(fullOutBitWidth) - $outputParams(fullOutFracBitWidth)]
      if { [expr $config(out_msb_bit_rem) >= $decimal_bit] == 1 } {
        send_message "error" "When Output Type is Signed Fractional Binary, the MSB Bits to Remove must be less than $decimal_bit (Output Full Bit Width - Output Full Fractional Bit Width)"
        set errorList 1
      }
    # Output Type = Signed Binary format
    }  else {
      set_parameter_value "outFullFracBitWidth" 0
      set_parameter_value "outFracBitWidth" 0
    }
    
    set total_removed_bit [expr $config(out_msb_bit_rem) + $config(out_lsb_bit_rem) + 2]
    if { [expr "$total_removed_bit > $outputParams(fullOutBitWidth)"] == 1 } {
      send_message "error" "Output Bit Width should be greater than 1"
      set errorList 1
    }
    
}

# +-----------------------------------------------------------------------------
# | Synthesis Files Generation
# +-----------------------------------------------------------------------------
proc gen_synth_files {} {

    set_config config

    set_input_params config inputParams outputParams
    
    setup_params_if_no_error "generate" config inputParams outputParams
    
    #Call fir_ip_api_interface to generate rtl files
    call_fir_ip_api_interface true config inputParams outputParams

    send_message "info" "PhysChanIn $outputParams(inputdataportcount), PhysChanOut $outputParams(outputdataportcount), ChansPerPhyIn $outputParams(channelsperinputdataport), ChansPerPhyOut $outputParams(channelsperoutputdataport), OutputFullBitWidth $outputParams(fullOutBitWidth), Bankcount $config(bankcount), Latency $outputParams(latency), CoefBitWidth $config(coefWidth) "

    # Generate toplevel file and then add toplevel file into project    
    set TCLdir [get_module_property MODULE_DIRECTORY]
    #send_message "info" "MODULE_DIRECTORY -- $TCLdir" 
    cd $TCLdir

    # Create Avalon-ST wrapper
    src create_ast.tcl $config(module_dir) $inputParams(outdir) $inputParams(outname) .vhd $inputParams(entity_name) $config(InWidth) $outputParams(inputdataportcount) $config(readWriteMode) $config(FullWidth) $outputParams(outputdataportcount) $inputParams(nChans) $config(devicefamily) $config(useClkEnable) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $outputParams(latency) $config(busDataWidth) $outputParams(outputfifodepth) $config(bankcount) $config(bankInWidth) $outputParams(out_msb_rnd_typ) $config(out_msb_bit_rem) $config(out_lsb_rnd_typ) $config(out_lsb_bit_rem)
    add_file ${inputParams(outdir)}${inputParams(outname)}_ast.vhd {SYNTHESIS}
    
    src create_top.tcl $inputParams(outdir) $inputParams(outname) $config(extension) $config(InWidth) $outputParams(inputdataportcount) $config(readWriteMode) $config(OutWidth) $outputParams(outputdataportcount) $inputParams(nChans) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $config(busDataWidth) $config(bankInWidth) $config(useClkEnable)
    add_file ${inputParams(outdir)}${inputParams(outname)}$config(extension) {SYNTHESIS}
    
    # Generate sdc file
    src gen_sdc.tcl $inputParams(outdir) $inputParams(outname) $inputParams(clockRate)
    add_file ${inputParams(outdir)}${inputParams(outname)}.sdc {SDC}

}

# +-----------------------------------------------------------------------------
# | Simulation Files Generation
# +-----------------------------------------------------------------------------
proc gen_sim_files {} {

    global env

    set_config config

    set_input_params config inputParams outputParams
    
    setup_params_if_no_error "generate" config inputParams outputParams
    
    #Call fir_ip_api_interface to generate rtl files
    call_fir_ip_api_interface true config inputParams outputParams

    # Create Avalon-ST wrapper
    src create_ast.tcl $config(module_dir) $inputParams(outdir) $inputParams(outname) .vhd $inputParams(entity_name) $config(InWidth) $outputParams(inputdataportcount) $config(readWriteMode) $config(FullWidth) $outputParams(outputdataportcount) $inputParams(nChans) $config(devicefamily) $config(useClkEnable) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $outputParams(latency) $config(busDataWidth) $outputParams(outputfifodepth) $config(bankcount) $config(bankInWidth) $outputParams(out_msb_rnd_typ) $config(out_msb_bit_rem) $config(out_lsb_rnd_typ) $config(out_lsb_bit_rem)
    add_file ${inputParams(outdir)}${inputParams(outname)}_ast.vhd {SIMULATION}
    
    src create_top.tcl $inputParams(outdir) $inputParams(outname) $config(extension) $config(InWidth) $outputParams(inputdataportcount) $config(readWriteMode) $config(OutWidth) $outputParams(outputdataportcount) $inputParams(nChans) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $config(busDataWidth) $config(bankInWidth) $config(useClkEnable)
    add_file ${inputParams(outdir)}${inputParams(outname)}$config(extension) {SIMULATION}

    # Generate nativelink script
    set hdl_type [get_generation_property HDL_LANGUAGE]
    src gen_nativelink.tcl $inputParams(outdir) $inputParams(outname) $hdl_type
    add_file ${inputParams(outdir)}${inputParams(outname)}_nativelink.tcl {SIMULATION}

    # Generate msim script
    set ver [get_module_property VERSION]
    src gen_msim.tcl $inputParams(outdir) $inputParams(outname) $ver $inputParams(family) $env(QUARTUS_ROOTDIR)
    add_file ${inputParams(outdir)}${inputParams(outname)}_msim.tcl {SIMULATION}

    # Generate testbench
    src gen_testbench.tcl $inputParams(outdir) $inputParams(outname) $ver $config(PhysChanIn) $config(PhysChanOut) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $config(InWidth) $config(OutWidth) $inputParams(nChans) $config(Log2_ChansPerPhyOut) $inputParams(nTaps) $config(readWriteMode) $inputParams(clockRate) $inputParams(inRate) $inputParams(interpN) $config(coeffReload) $inputParams(baseAddr) $config(coefWidth) $config(busDataWidth) $config(bankcount) $config(bankInWidth) $inputParams(symmetry_type) $config(useClkEnable)
    add_file ${inputParams(outdir)}${inputParams(outname)}_tb.vhd {SIMULATION}
    
    
    # Generate matlab files
    set out_msb_removed_bits $config(out_msb_bit_rem)
    if {$outputParams(out_msb_rnd_typ) == "Truncation"} {
       set out_msb_remove_type "Truncate"
    } elseif {$outputParams(out_msb_rnd_typ) == "Saturating"} {
       set out_msb_remove_type "Saturate"
    } else {
      send_message "error" "Error in setting MSB rounding type"
    }
    set out_lsb_removed_bits $config(out_lsb_bit_rem)
    if {$config(out_lsb_rnd_typ) == "Truncation"} {
       set out_lsb_remove_type "Truncate"
    } elseif {$config(out_lsb_rnd_typ) == "Rounding"} {
       set out_lsb_remove_type "Round"
    } else {
      send_message "error" "Error in setting LSB rounding type"
    }
    set bpfc_exists true
    
    src gen_matlab.tcl $inputParams(outdir) $inputParams(outname) $ver $config(coeffReload) $inputParams(nTaps) $config(InWidth) $config(filter_type) $inputParams(interpN) $inputParams(decimN) $config(OutWidth) $inputParams(coeffSet) $out_msb_removed_bits $out_msb_remove_type $out_lsb_removed_bits $out_lsb_remove_type $config(input_type) $inputParams(nChans) $config(PhysChanIn) $config(coefWidth) $config(coefficientWriteable) $bpfc_exists $inputParams(symmetry_type) $config(bankcount)
    add_file ${inputParams(outdir)}${inputParams(outname)}_mlab.m {SIMULATION}
    add_file ${inputParams(outdir)}${inputParams(outname)}_model.m {SIMULATION}
    add_file ${inputParams(outdir)}${inputParams(outname)}_coef_int.txt {SIMULATION}
    
    if {$config(coeffReload) == "true" && $config(coefficientWriteable) == "true"} {
      add_file ${inputParams(outdir)}${inputParams(outname)}_coef_reload.txt {SIMULATION}  
      add_file ${inputParams(outdir)}${inputParams(outname)}_coef_reload_rtl.txt {SIMULATION}  
    }

    # Generate input data file
    src gen_input.tcl $inputParams(outdir) $inputParams(outname) $config(InWidth) $config(filter_type) $inputParams(interpN) $inputParams(decimN) $config(input_type) $inputParams(nChans) $inputParams(nTaps) $bpfc_exists $inputParams(clockRate) $inputParams(inRate) $config(bankcount)
    add_file ${inputParams(outdir)}${inputParams(outname)}_input.txt {SIMULATION}
    
    # Generate parameter file
    src gen_param.tcl $inputParams(outdir) $inputParams(outname) $config(PhysChanIn) $config(PhysChanOut) $config(ChansPerPhyIn) $config(ChansPerPhyOut) $config(InWidth) $inputParams(inFracWidth) $config(OutWidth) $outputParams(fullOutBitWidth) $outputParams(outFracBitWidth) $outputParams(fullOutFracBitWidth) $inputParams(nChans) $inputParams(nTaps) $inputParams(clockRate) $inputParams(inRate) $inputParams(interpN) $inputParams(decimN) $config(busDataWidth) $config(bankInWidth)
    add_file ${inputParams(outdir)}${inputParams(outname)}_param.txt {SIMULATION}
}

# +-----------------------------------------------------------------------------
# | call_fir_ip_api_interface
# +-----------------------------------------------------------------------------
proc call_fir_ip_api_interface {generateCode conf inParams outParams} {

    global env
    global DSPBA_BACKEND_BIN_DIR
    upvar $conf config
    upvar $inParams inputParams
    upvar $outParams outputParams

    # Files generated by fir_ip_api must be in <outdir> directory, all files name must be prefixed by <inputParams(outname)>    
    # Different OUTPUT_DIRECTORY and OUTPUT_NAME for different callback
    if { $generateCode == "true" } {
      set inputParams(outdir) [get_generation_property OUTPUT_DIRECTORY]
      set inputParams(outname) [get_generation_property OUTPUT_NAME]
      set inputParams(entity_name) ${inputParams(outname)}_rtl
    }

    # Run executable to call back-end fir_ip_api to generate real VHDL code and files with the specified parameters value above
    # On linux the location is a shell wrapper which sets up its own environment, so we don't need to worry about it
    set fir_ip_api_interface "${DSPBA_BACKEND_BIN_DIR}/fir_ip_api_interface"

    if { [ catch { set outputParams(funcResult) [exec $fir_ip_api_interface $inputParams(entity_name) $inputParams(outdir) $inputParams(family) $inputParams(speedGrade) $inputParams(clockRate) $inputParams(clockSlack) $inputParams(nChans) $inputParams(inRate) $inputParams(nTaps) $inputParams(interpN) $inputParams(decimN) $inputParams(symmetry) $inputParams(symmetry_type) $inputParams(nband) $config(InWidth) $inputParams(inFracWidth) $config(coefWidth) $config(coefFracWidth) $inputParams(baseAddr) $config(coefficientReadback) $config(coefficientWriteable) $inputParams(coeffSet) $config(busDataWidth) $inputParams(busAddressWidth) $inputParams(delayRAMBlockThreshold) $inputParams(dualMemDistRAMThreshold) $inputParams(mRAMThreshold) $inputParams(hardMultiplierThreshold) $generateCode $config(useClkEnable) $config(bankcount)] } err ] } {
       send_message "error" "$err"
       return
    }
    
    if { $generateCode == "true" } {
      # Get number input/output data wire, number of latency
      set funcResultList [split $outputParams(funcResult) "|"]
      set funcResultListLength [llength $funcResultList]
      set outputParams(inputdataportcount) [lindex $funcResultList 2]
      set outputParams(outputdataportcount) [lindex $funcResultList 3]
      set outputParams(channelsperinputdataport) [lindex $funcResultList 4]
      set outputParams(channelsperoutputdataport) [lindex $funcResultList 5]
      set outputParams(fullOutBitWidth) [lindex $funcResultList 6]
      set outputParams(fullOutFracBitWidth) [lindex $funcResultList 7]
      set outputParams(latency) [lindex $funcResultList 8]
      set outputParams(outputfifodepth) [lindex $funcResultList 9]
      set generate_pass [lindex $funcResultList 10]
      
      if { $generate_pass == "false" } {
        send_message "error" "Filter wasn't successfully created"
        return
      }

      # Get DSPBA file list and run add_file on it
      for {set m 13} {$m < $funcResultListLength-1} {incr m} {
        set dspba_files [lindex $funcResultList $m]
        #Ignore if it is a file path starts with $ instead of a file name for now
        if {![regexp {^\$} $dspba_files match]} {
            add_file ${inputParams(outdir)}/$dspba_files {SYNTHESIS SIMULATION}
        }
      }
      
      #Add DSPBA FIR rtl file
      add_file ${inputParams(outdir)}/[lindex $funcResultList 12] {SYNTHESIS SIMULATION}
    }   
}

# +-----------------------------------------------------------------------------
# | Source tcl files with parameters
# +-----------------------------------------------------------------------------
proc src { filename args } {
  global argv
  set argv $args
  source $filename
}
