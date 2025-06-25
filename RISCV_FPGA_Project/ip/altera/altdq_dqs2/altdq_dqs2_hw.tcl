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


package require -exact sopc 11.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini

namespace import ::alt_mem_if::util::messaging::*


source "$env(QUARTUS_ROOTDIR)/../ip/altera/altdq_dqs2/generate.tcl"

set_module_property NAME altdq_dqs2
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "I/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "ALTDQ_DQS2"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_altdq_dqs2.pdf"
set_module_property ALLOW_GREYBOX_GENERATION true


add_parameter MODULE_VALID BOOLEAN TRUE
set_parameter_property MODULE_VALID VISIBLE FALSE
set_parameter_property MODULE_VALID DERIVED TRUE

add_parameter DEVICE_FAMILY STRING "" 
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY VISIBLE FALSE

add_parameter PIN_WIDTH INTEGER 9
set_parameter_property PIN_WIDTH DISPLAY_NAME "Pin width"
set_parameter_property PIN_WIDTH ALLOWED_RANGES 1:36
set_parameter_property PIN_WIDTH DESCRIPTION "Specifies number of pins to make as part of this DQS group."

add_parameter PIN_TYPE STRING bidir
set_parameter_property PIN_TYPE DISPLAY_NAME "Pin type"
set_parameter_property PIN_TYPE DESCRIPTION "Specifies the direction of the data pins."
set_parameter_property PIN_TYPE ALLOWED_RANGES {input output bidir}

add_parameter EXTRA_OUTPUT_WIDTH INTEGER 0
set_parameter_property EXTRA_OUTPUT_WIDTH DISPLAY_NAME "Extra output-only pins"
set_parameter_property EXTRA_OUTPUT_WIDTH ALLOWED_RANGES 0:36
set_parameter_property EXTRA_OUTPUT_WIDTH DESCRIPTION "Use this setting when extra output pins are needed as part of a DQS group.  A common use for this setting is to add datamask pins."

add_parameter HALF_RATE_OUTPUT boolean true
set_parameter_property HALF_RATE_OUTPUT DISPLAY_NAME "Use half-rate output path"
set_parameter_property HALF_RATE_OUTPUT DESCRIPTION "This setting doubles the width of the data bus on the FPGA side and clocks the FPGA side interface using the half-rate clock input."

add_parameter HALF_RATE_INPUT boolean false
set_parameter_property HALF_RATE_INPUT DISPLAY_NAME "Use half-rate input path"
set_parameter_property HALF_RATE_INPUT DISPLAY_HINT ""
set_parameter_property HALF_RATE_INPUT ENABLED "false"
set_parameter_property HALF_RATE_INPUT VISIBLE "false"

add_parameter USE_INPUT_PHASE_ALIGNMENT BOOLEAN false ""
set_parameter_property USE_INPUT_PHASE_ALIGNMENT DISPLAY_NAME "Use input phase alignment blocks"
set_parameter_property USE_INPUT_PHASE_ALIGNMENT DESCRIPTION ""
set_parameter_property USE_INPUT_PHASE_ALIGNMENT DISPLAY_HINT ""
set_parameter_property USE_INPUT_PHASE_ALIGNMENT ENABLED "false"
set_parameter_property USE_INPUT_PHASE_ALIGNMENT VISIBLE "false"

add_parameter USE_OUTPUT_PHASE_ALIGNMENT BOOLEAN false ""
set_parameter_property USE_OUTPUT_PHASE_ALIGNMENT DISPLAY_NAME "Use output phase alignment blocks"
set_parameter_property USE_OUTPUT_PHASE_ALIGNMENT DESCRIPTION "Using the output phase alignment blocks allows phase shifts based on DLL outputs."
set_parameter_property USE_OUTPUT_PHASE_ALIGNMENT DISPLAY_HINT ""

add_parameter CAPTURE_STROBE_TYPE string "Single" ""
set_parameter_property CAPTURE_STROBE_TYPE DISPLAY_NAME "Capture strobe type"
set_parameter_property CAPTURE_STROBE_TYPE DESCRIPTION "The capture strobe can be single, differential or complimentary."
set_parameter_property CAPTURE_STROBE_TYPE DISPLAY_HINT ""
set_parameter_property CAPTURE_STROBE_TYPE ALLOWED_RANGES {Single Differential Complimentary}

add_parameter INVERT_CAPTURE_STROBE BOOLEAN TRUE ""
set_parameter_property INVERT_CAPTURE_STROBE DISPLAY_NAME "Use inverted capture strobe"
set_parameter_property INVERT_CAPTURE_STROBE DESCRIPTION "You can capture data with the capture strobe directly, or with an inverted version."
set_parameter_property INVERT_CAPTURE_STROBE DISPLAY_HINT ""

add_parameter SWAP_CAPTURE_STROBE_POLARITY BOOLEAN false ""
set_parameter_property SWAP_CAPTURE_STROBE_POLARITY DISPLAY_NAME "Swap capture strobe polarity"
set_parameter_property SWAP_CAPTURE_STROBE_POLARITY DESCRIPTION "Advanced setting to connect the positive capture strobe to the negative terminal of the input differential buffer, and the negative capture clock to the positive terminal. Only applicable when capture strobe type is differential."
set_parameter_property SWAP_CAPTURE_STROBE_POLARITY DISPLAY_HINT ""
set_parameter_property SWAP_CAPTURE_STROBE_POLARITY VISIBLE "false"

add_parameter EXTRA_OUTPUTS_USE_SEPARATE_GROUP BOOLEAN false ""
set_parameter_property EXTRA_OUTPUTS_USE_SEPARATE_GROUP DISPLAY_NAME "Group the extra output pins in separate group than DQ pins"
set_parameter_property EXTRA_OUTPUTS_USE_SEPARATE_GROUP DESCRIPTION "Advanced setting to group the extra output pins in separate group than DQ pins. Used by RLDRAM3."
set_parameter_property EXTRA_OUTPUTS_USE_SEPARATE_GROUP DISPLAY_HINT ""
set_parameter_property EXTRA_OUTPUTS_USE_SEPARATE_GROUP VISIBLE "false"

add_parameter USE_BIDIR_STROBE BOOLEAN false ""
set_parameter_property USE_BIDIR_STROBE DISPLAY_NAME "Make capture strobe bidirectional"
set_parameter_property USE_BIDIR_STROBE DESCRIPTION "The capture strobe can be bidirectional."
set_parameter_property USE_BIDIR_STROBE DISPLAY_HINT ""

add_parameter USE_DQS_ENABLE BOOLEAN false ""
set_parameter_property USE_DQS_ENABLE DISPLAY_NAME "Use capture strobe enable block"
set_parameter_property USE_DQS_ENABLE DESCRIPTION "Using the capture strobe enable block allows for control over when the capture strobe is masked to a 0 or passed through directly.  This block is useful when you know that the capture strobe can enter a high-impedance state."
set_parameter_property USE_DQS_ENABLE DISPLAY_HINT ""

add_parameter USE_HALF_RATE_DQS_ENABLE BOOLEAN false ""
set_parameter_property USE_HALF_RATE_DQS_ENABLE DISPLAY_NAME "Treat the capture strobe enable as a half-rate signal"
set_parameter_property USE_HALF_RATE_DQS_ENABLE DESCRIPTION "This setting doubles the width of the capture strobe enable bus on the FPGA side and clocks the FPGA side interface using the half-rate clock input."

set_parameter_property USE_HALF_RATE_DQS_ENABLE DISPLAY_HINT ""



add_parameter INPUT_FREQ FLOAT 300 ""
set_parameter_property INPUT_FREQ DISPLAY_NAME "Memory frequency"
set_parameter_property INPUT_FREQ UNITS megahertz
set_parameter_property INPUT_FREQ ALLOWED_RANGES 1:1068
set_parameter_property INPUT_FREQ DESCRIPTION "Full rate clock frequency"
set_parameter_property INPUT_FREQ DISPLAY_HINT ""

add_parameter INPUT_FREQ_PS INTEGER 0 ""
set_parameter_property INPUT_FREQ_PS DERIVED true
set_parameter_property INPUT_FREQ_PS VISIBLE false


add_parameter DQS_PHASE_SETTING INTEGER 2
set_parameter_property DQS_PHASE_SETTING DISPLAY_NAME "DQS phase shift"
set_parameter_property DQS_PHASE_SETTING ALLOWED_RANGES {"0:0 degrees" "1:45 degrees" "2:90 degrees" "3:135 degrees"}
set_parameter_property DQS_PHASE_SETTING DESCRIPTION "This phase setting centers the incoming strobe within the data valid window during both reads and writes."

add_parameter DQS_PHASE_SHIFT INTEGER 9000
set_parameter_property DQS_PHASE_SHIFT DISPLAY_NAME "DQS phase shift"
set_parameter_property DQS_PHASE_SHIFT VISIBLE false
set_parameter_property DQS_PHASE_SHIFT DERIVED true

add_parameter FORCE_DQS_PHASE_SHIFT INTEGER -1
set_parameter_property FORCE_DQS_PHASE_SHIFT DISPLAY_NAME "Force DQS phase shift"
set_parameter_property FORCE_DQS_PHASE_SHIFT VISIBLE false

add_parameter DELAY_CHAIN_BUFFER_MODE string "HIGH" ""
set_parameter_property DELAY_CHAIN_BUFFER_MODE DISPLAY_NAME "Delay chain buffer mode"
set_parameter_property DELAY_CHAIN_BUFFER_MODE ALLOWED_RANGES {HIGH LOW}
set_parameter_property DELAY_CHAIN_BUFFER_MODE VISIBLE false

add_parameter DQS_ENABLE_PHASE_SETTING INTEGER 0
set_parameter_property DQS_ENABLE_PHASE_SETTING DISPLAY_NAME "DQS enable phase setting"
set_parameter_property DQS_ENABLE_PHASE_SETTING ALLOWED_RANGES {"0:0 degrees"  "1:45 degrees" "2:90 degree" "3:135 degrees"}
set_parameter_property DQS_ENABLE_PHASE_SETTING DESCRIPTION "This phase setting shifts the full rate clock that drives the capture strobe enable block."

add_parameter USE_DYNAMIC_CONFIG BOOLEAN false ""
set_parameter_property USE_DYNAMIC_CONFIG DISPLAY_NAME "Use dynamic configuration scan chains"
set_parameter_property USE_DYNAMIC_CONFIG DESCRIPTION "Allows for run-time configuration of many delay chains, phase shifts and transfer registers.  Requires a correctly formatted configuration bitstream."
set_parameter_property USE_DYNAMIC_CONFIG DISPLAY_HINT ""

add_parameter USE_TERMINATION_CONTROL BOOLEAN true ""
set_parameter_property USE_TERMINATION_CONTROL DISPLAY_NAME "Use dynamic termination control"
set_parameter_property USE_TERMINATION_CONTROL DESCRIPTION ""
set_parameter_property USE_TERMINATION_CONTROL DISPLAY_HINT ""
set_parameter_property USE_TERMINATION_CONTROL enabled "false"
set_parameter_property USE_TERMINATION_CONTROL visible "false"


add_parameter USE_OUTPUT_STROBE BOOLEAN true ""
set_parameter_property USE_OUTPUT_STROBE DISPLAY_NAME "Generate output strobe"
set_parameter_property USE_OUTPUT_STROBE DESCRIPTION "Based on the OE signal and the full-rate clock, an output strobe signal can be automatically generated."
set_parameter_property USE_OUTPUT_STROBE DISPLAY_HINT ""

add_parameter DIFFERENTIAL_OUTPUT_STROBE BOOLEAN false ""
set_parameter_property DIFFERENTIAL_OUTPUT_STROBE DISPLAY_NAME "Differential/complimentary output strobe"
set_parameter_property DIFFERENTIAL_OUTPUT_STROBE DESCRIPTION "Output strobe can be differential/complimentary or not."
set_parameter_property DIFFERENTIAL_OUTPUT_STROBE DISPLAY_HINT ""

add_parameter USE_OUTPUT_STROBE_RESET BOOLEAN false ""
set_parameter_property USE_OUTPUT_STROBE_RESET DISPLAY_NAME "Use reset signal to stop output strobe"
set_parameter_property USE_OUTPUT_STROBE_RESET DESCRIPTION "Allows stopping the uni-directional output strobe using a user-provided reset signal. Both the core_clock_in and the reset_n_core_clock_in signals are required."
set_parameter_property USE_OUTPUT_STROBE_RESET DISPLAY_HINT ""

add_parameter REVERSE_READ_WORDS BOOLEAN false ""
set_parameter_property REVERSE_READ_WORDS DISPLAY_NAME "Reverse words"
set_parameter_property REVERSE_READ_WORDS DESCRIPTION "Reverse the hi/lo words for easier debugging."
set_parameter_property REVERSE_READ_WORDS DISPLAY_HINT ""
set_parameter_property REVERSE_READ_WORDS VISIBLE false

add_parameter OCT_SERIES_TERM_CONTROL_WIDTH INTEGER 16
set_parameter_property OCT_SERIES_TERM_CONTROL_WIDTH DISPLAY_NAME OCT_SERIES_TERM_CONTROL_WIDTH
set_parameter_property OCT_SERIES_TERM_CONTROL_WIDTH DERIVED true
set_parameter_property OCT_SERIES_TERM_CONTROL_WIDTH VISIBLE false

add_parameter OCT_PARALLEL_TERM_CONTROL_WIDTH INTEGER 16
set_parameter_property OCT_PARALLEL_TERM_CONTROL_WIDTH DISPLAY_NAME OCT_PARALLEL_TERM_CONTROL_WIDTH
set_parameter_property OCT_PARALLEL_TERM_CONTROL_WIDTH DERIVED true
set_parameter_property OCT_PARALLEL_TERM_CONTROL_WIDTH VISIBLE false

add_parameter DLL_WIDTH INTEGER 7
set_parameter_property DLL_WIDTH DISPLAY_NAME DLL_WIDTH
set_parameter_property DLL_WIDTH DERIVED true
set_parameter_property DLL_WIDTH VISIBLE false

add_parameter DLL_USE_2X_CLK BOOLEAN false
set_parameter_property DLL_USE_2X_CLK DISPLAY_NAME DLL_USE_2X_CLK
set_parameter_property DLL_USE_2X_CLK DERIVED true
set_parameter_property DLL_USE_2X_CLK VISIBLE false

add_parameter USE_LDC_AS_LOW_SKEW_CLOCK BOOLEAN false
set_parameter_property USE_LDC_AS_LOW_SKEW_CLOCK DISPLAY_NAME USE_LDC_AS_LOW_SKEW_CLOCK
set_parameter_property USE_LDC_AS_LOW_SKEW_CLOCK DERIVED true
set_parameter_property USE_LDC_AS_LOW_SKEW_CLOCK VISIBLE false

add_parameter OUTPUT_DQS_PHASE_SETTING INTEGER 0
set_parameter_property OUTPUT_DQS_PHASE_SETTING DISPLAY_NAME OUTPUT_DQS_PHASE_SETTING
set_parameter_property OUTPUT_DQS_PHASE_SETTING DERIVED true
set_parameter_property OUTPUT_DQS_PHASE_SETTING VISIBLE false

add_parameter OUTPUT_DQ_PHASE_SETTING INTEGER 0
set_parameter_property OUTPUT_DQ_PHASE_SETTING DISPLAY_NAME OUTPUT_DQ_PHASE_SETTING
set_parameter_property OUTPUT_DQ_PHASE_SETTING DERIVED true
set_parameter_property OUTPUT_DQ_PHASE_SETTING VISIBLE false

add_parameter EXTENDED_FAMILY_SUPPORT BOOLEAN false
set_parameter_property EXTENDED_FAMILY_SUPPORT VISIBLE false

add_parameter OCT_SOURCE INTEGER 1
set_parameter_property OCT_SOURCE DISPLAY_NAME "OCT Source"
set_parameter_property OCT_SOURCE DESCRIPTION "Specifies input signal used to toggle the OCT control"
set_parameter_property OCT_SOURCE ALLOWED_RANGES {"0:Output Strobe Enable" "1:Data Write Enable" "2:Dedicated OCT Enable"}

add_parameter REGULAR_WRITE_BUS_ORDERING BOOLEAN false ""
set_parameter_property REGULAR_WRITE_BUS_ORDERING DISPLAY_NAME "Use regular wire ordering for write bus"
set_parameter_property REGULAR_WRITE_BUS_ORDERING DESCRIPTION "Use regular wire ordering for write bus"
set_parameter_property REGULAR_WRITE_BUS_ORDERING DISPLAY_HINT ""
set_parameter_property REGULAR_WRITE_BUS_ORDERING VISIBLE false

add_parameter PREAMBLE_TYPE string "low" "none"
set_parameter_property PREAMBLE_TYPE DISPLAY_NAME "Preamble type"
set_parameter_property PREAMBLE_TYPE DESCRIPTION "Specifies whether the DQS preamble should be 'high' (DDR3) or 'low' (DDR2, LPDDR2) or 'none'"
set_parameter_property PREAMBLE_TYPE ALLOWED_RANGES {high low none}

add_parameter EMIF_UNALIGNED_PREAMBLE_SUPPORT BOOLEAN false ""
set_parameter_property EMIF_UNALIGNED_PREAMBLE_SUPPORT DISPLAY_NAME "EMIF-only: Enable unaligned write preamble correction"
set_parameter_property EMIF_UNALIGNED_PREAMBLE_SUPPORT DESCRIPTION "EMIF-only parameter: Enables preamble correction circuitry for unaligned AFI writes"
set_parameter_property EMIF_UNALIGNED_PREAMBLE_SUPPORT DISPLAY_HINT ""
set_parameter_property EMIF_UNALIGNED_PREAMBLE_SUPPORT VISIBLE false

add_parameter USE_OFFSET_CTRL BOOLEAN false ""
set_parameter_property USE_OFFSET_CTRL DISPLAY_NAME "Use DLL Offset Control"
set_parameter_property USE_OFFSET_CTRL DESCRIPTION "Allows for dynamic control of the DLL offset"
set_parameter_property USE_OFFSET_CTRL DISPLAY_HINT ""

add_parameter USE_ABSTRACT_RTL BOOLEAN false ""
set_parameter_property USE_ABSTRACT_RTL DISPLAY_NAME "Request generation of abstract RTL"
set_parameter_property USE_ABSTRACT_RTL DESCRIPTION ""
set_parameter_property USE_ABSTRACT_RTL DISPLAY_HINT ""
set_parameter_property USE_ABSTRACT_RTL ENABLED "false"
set_parameter_property USE_ABSTRACT_RTL VISIBLE "false"

add_parameter CALIBRATION_SUPPORT BOOLEAN false ""
set_parameter_property CALIBRATION_SUPPORT DISPLAY_NAME "Enable calibration support in Abstract RTL"
set_parameter_property CALIBRATION_SUPPORT DESCRIPTION ""
set_parameter_property CALIBRATION_SUPPORT DISPLAY_HINT ""
set_parameter_property CALIBRATION_SUPPORT ENABLED "false"
set_parameter_property CALIBRATION_SUPPORT VISIBLE "false"

add_parameter USE_REAL_RTL BOOLEAN true ""
set_parameter_property USE_REAL_RTL DISPLAY_NAME "Request generation of real RTL"
set_parameter_property USE_REAL_RTL DESCRIPTION ""
set_parameter_property USE_REAL_RTL DISPLAY_HINT ""
set_parameter_property USE_REAL_RTL ENABLED "true"
set_parameter_property USE_REAL_RTL VISIBLE "false"

add_parameter USE_DQS_TRACKING BOOLEAN false ""
set_parameter_property USE_DQS_TRACKING DISPLAY_NAME "Enable DQS Post-amble tracking"
set_parameter_property USE_DQS_TRACKING DESCRIPTION "Enables tracking of the DQS Enable/DQS Post-amble timing "
set_parameter_property USE_DQS_TRACKING DISPLAY_HINT ""
set_parameter_property USE_DQS_TRACKING VISIBLE false

add_parameter USE_2X_FF BOOLEAN false ""
set_parameter_property USE_2X_FF DISPLAY_NAME "Enable 2X FF on output path"
set_parameter_property USE_2X_FF DESCRIPTION "Adds a 2X FF on the output path of the strobe and data pins to reduce DCD.  Requires a 2X clock."
set_parameter_property USE_2X_FF DISPLAY_HINT ""
set_parameter_property USE_2X_FF VISIBLE false 

add_parameter DUAL_WRITE_CLOCK BOOLEAN false ""
set_parameter_property DUAL_WRITE_CLOCK DISPLAY_NAME "Enable dual write clocks"
set_parameter_property DUAL_WRITE_CLOCK DESCRIPTION "Enables the use of seperate output clocks for data and strobe."
set_parameter_property DUAL_WRITE_CLOCK DISPLAY_HINT ""

add_parameter USE_HARD_FIFOS BOOLEAN false ""
set_parameter_property USE_HARD_FIFOS DISPLAY_NAME "Enable hard FIFOs"
set_parameter_property USE_HARD_FIFOS DESCRIPTION "Enables the hard RFIFO, LFIFO, and VFIFOs as part of ALTDQDQS2"
set_parameter_property USE_HARD_FIFOS DISPLAY_HINT ""

add_parameter USE_HARD_FIFOS_INTERNAL BOOLEAN false ""
set_parameter_property USE_HARD_FIFOS_INTERNAL VISIBLE false
set_parameter_property USE_HARD_FIFOS_INTERNAL DERIVED true

add_parameter USE_DQSIN_FOR_VFIFO_READ BOOLEAN false ""
set_parameter_property USE_DQSIN_FOR_VFIFO_READ DISPLAY_NAME "Use Capture Clock to clock the read Side of the Hard VFIFO"
set_parameter_property USE_DQSIN_FOR_VFIFO_READ DESCRIPTION "This must be checked whenever the Hard VFIFO is used and the capture clock is NOT gated"
set_parameter_property USE_DQSIN_FOR_VFIFO_READ DISPLAY_HINT ""

add_parameter CONNECT_TO_HARD_PHY BOOLEAN false ""
set_parameter_property CONNECT_TO_HARD_PHY enabled "false"
set_parameter_property CONNECT_TO_HARD_PHY visible "false"

add_parameter QUARTER_RATE_MODE BOOLEAN false ""
set_parameter_property QUARTER_RATE_MODE enabled "false"
set_parameter_property QUARTER_RATE_MODE visible "false"

add_parameter NATURAL_ALIGNMENT BOOLEAN false ""
set_parameter_property NATURAL_ALIGNMENT DISPLAY_NAME "Natural alignment for connection to the HCTL"
set_parameter_property NATURAL_ALIGNMENT DESCRIPTION "Don't split up bits from each pin to make it AFI-compatible. In AV/CV, the HCTL does this for us."
set_parameter_property NATURAL_ALIGNMENT DISPLAY_HINT ""
set_parameter_property NATURAL_ALIGNMENT VISIBLE false

add_parameter SEPERATE_LDC_FOR_WRITE_STROBE BOOLEAN false ""
set_parameter_property SEPERATE_LDC_FOR_WRITE_STROBE DISPLAY_NAME "Instantiate a seperate LDC for the output strobe"
set_parameter_property SEPERATE_LDC_FOR_WRITE_STROBE DESCRIPTION "Used in x9 and x18 RLDRAM for AV/CV to allow fitter to place DK pins in their own DQ group."
set_parameter_property SEPERATE_LDC_FOR_WRITE_STROBE DISPLAY_HINT ""
set_parameter_property SEPERATE_LDC_FOR_WRITE_STROBE VISIBLE false

add_parameter USE_SHADOW_REGS BOOLEAN false ""
set_parameter_property USE_SHADOW_REGS DISPLAY_NAME "Use shadow registers"
set_parameter_property USE_SHADOW_REGS DESCRIPTION "Use shadow registers for multi-rank interfaces"
set_parameter_property USE_SHADOW_REGS DISPLAY_HINT ""
set_parameter_property USE_SHADOW_REGS VISIBLE FALSE

add_parameter DELAY_CHAIN_WIDTH INTEGER 4
set_parameter_property DELAY_CHAIN_WIDTH DISPLAY_NAME DELAY_CHAIN_WIDTH
set_parameter_property DELAY_CHAIN_WIDTH DERIVED true
set_parameter_property DELAY_CHAIN_WIDTH VISIBLE false
set_parameter_property DLL_WIDTH VISIBLE false

add_parameter LPDDR2 BOOLEAN false ""
set_parameter_property LPDDR2 enabled "true"
set_parameter_property LPDDR2 visible "false"

add_parameter GENERATE_EXAMPLE_DESIGN BOOLEAN false ""
set_parameter_property GENERATE_EXAMPLE_DESIGN enabled "true"
set_parameter_property GENERATE_EXAMPLE_DESIGN DISPLAY_NAME "Generate example design"
set_parameter_property GENERATE_EXAMPLE_DESIGN DESCRIPTION "Generates an example design"
set_parameter_property GENERATE_EXAMPLE_DESIGN visible false

add_parameter HHP_HPS BOOLEAN FALSE
set_parameter_property HHP_HPS ENABLED TRUE
set_parameter_property HHP_HPS VISIBLE FALSE
set_parameter_property HHP_HPS DERIVED FALSE

add_parameter USE_EXTERNAL_WRITE_STROBE_PORTS BOOLEAN false ""
set_parameter_property USE_EXTERNAL_WRITE_STROBE_PORTS enabled "true"
set_parameter_property USE_EXTERNAL_WRITE_STROBE_PORTS DISPLAY_NAME "Use external write_strobe ports"
set_parameter_property USE_EXTERNAL_WRITE_STROBE_PORTS DESCRIPTION "Bring datain_hi and datain_lo ports of ddio_out to altdq_dqs2 ports"
set_parameter_property USE_EXTERNAL_WRITE_STROBE_PORTS visible false

add_parameter USE_CAPTURE_REG_EXTERNAL_CLOCKING BOOLEAN false ""
set_parameter_property USE_CAPTURE_REG_EXTERNAL_CLOCKING enabled "true"
set_parameter_property USE_CAPTURE_REG_EXTERNAL_CLOCKING DISPLAY_NAME "Use external clocking for DQ capture DDIO"
set_parameter_property USE_CAPTURE_REG_EXTERNAL_CLOCKING DESCRIPTION "When an input path exists, the external_ddio_capture_clock is used to capture data on the DDIO. The capture strobe type must be set to single."
set_parameter_property USE_CAPTURE_REG_EXTERNAL_CLOCKING visible false

add_parameter USE_READ_FIFO_EXTERNAL_CLOCKING BOOLEAN false ""
set_parameter_property USE_READ_FIFO_EXTERNAL_CLOCKING enabled "true"
set_parameter_property USE_READ_FIFO_EXTERNAL_CLOCKING DISPLAY_NAME "Use external clocking for DQ capture hard read FIFO"
set_parameter_property USE_READ_FIFO_EXTERNAL_CLOCKING DESCRIPTION "When an input path exists, the external_read_fifo_capture_clock is used to capture data on the hard read FIFO."
set_parameter_property USE_READ_FIFO_EXTERNAL_CLOCKING visible false



add_display_item "" "General Settings" GROUP
add_display_item "" "Output Path" GROUP
add_display_item "" "Capture Strobe" GROUP
add_display_item "" "Output Strobe" GROUP
add_display_item "" "Block Diagram" GROUP

add_display_item "General Settings" PIN_WIDTH PARAMETER
add_display_item "General Settings" PIN_TYPE PARAMETER
add_display_item "General Settings" EXTRA_OUTPUT_WIDTH PARAMETER
add_display_item "General Settings" INPUT_FREQ PARAMETER
add_display_item "General Settings" USE_OFFSET_CTRL PARAMETER
add_display_item "General Settings" USE_2X_FF PARAMETER
add_display_item "General Settings" USE_HARD_FIFOS PARAMETER
add_display_item "General Settings" USE_DQSIN_FOR_VFIFO_READ PARAMETER
add_display_item "General Settings" USE_SHADOW_REGS PARAMETER
add_display_item "General Settings" DUAL_WRITE_CLOCK PARAMETER
add_display_item "General Settings" USE_DYNAMIC_CONFIG PARAMETER
add_display_item "General Settings" GENERATE_EXAMPLE_DESIGN PARAMETER

add_display_item "Output Path" HALF_RATE_OUTPUT PARAMETER
add_display_item "Output Path" USE_OUTPUT_PHASE_ALIGNMENT PARAMETER
add_display_item "Capture Strobe" CAPTURE_STROBE_TYPE PARAMETER
add_display_item "Capture Strobe" INVERT_CAPTURE_STROBE PARAMETER
add_display_item "Capture Strobe" SWAP_CAPTURE_STROBE_POLARITY PARAMETER
add_display_item "Capture Strobe" DQS_PHASE_SETTING PARAMETER
add_display_item "Capture Strobe" USE_DQS_ENABLE PARAMETER
add_display_item "Capture Strobe" USE_HALF_RATE_DQS_ENABLE PARAMETER
add_display_item "Capture Strobe" DQS_ENABLE_PHASE_SETTING PARAMETER
add_display_item "Capture Strobe" USE_DQS_TRACKING PARAMETER
add_display_item "Capture Strobe" USE_CAPTURE_REG_EXTERNAL_CLOCKING PARAMETER
add_display_item "Capture Strobe" USE_READ_FIFO_EXTERNAL_CLOCKING PARAMETER

add_display_item "Output Path" USE_TERMINATION_CONTROL PARAMETER
add_display_item "Output Strobe" USE_OUTPUT_STROBE PARAMETER
add_display_item "Output Strobe" USE_BIDIR_STROBE PARAMETER
add_display_item "Output Strobe" DIFFERENTIAL_OUTPUT_STROBE PARAMETER
add_display_item "Output Strobe" USE_OUTPUT_STROBE_RESET PARAMETER
add_display_item "Output Strobe" OCT_SOURCE PARAMETER
add_display_item "Output Strobe" PREAMBLE_TYPE PARAMETER

add_display_item "Output Path" USE_EXTERNAL_WRITE_STROBE_PORTS PARAMETER


proc rate_mult {rate} {
	if {$rate} {
		return 2;
	} else {
		return 1;
	}
}


add_interface memory_interface conduit end
set_interface_property memory_interface ENABLED true



add_interface data_interface conduit end


add_interface Misc conduit end

set_interface_property Misc ENABLED true

add_interface_port Misc parallelterminationcontrol_in export Input 0
add_interface_port Misc seriesterminationcontrol_in export Input 0
add_interface_port Misc dll_delayctrl_in export Input 0

set_port_property parallelterminationcontrol_in WIDTH_EXPR OCT_PARALLEL_TERM_CONTROL_WIDTH
set_port_property seriesterminationcontrol_in WIDTH_EXPR OCT_SERIES_TERM_CONTROL_WIDTH
set_port_property dll_delayctrl_in WIDTH_EXPR dll_width


add_interface "Capture clock" clock start

set_interface_property "Capture clock" ENABLED true


add_fileset quartus_synth_fileset QUARTUS_SYNTH my_quartus_synth {quartus_synth_callback_display_name}
add_fileset sim_verilog_fileset SIM_VERILOG my_sim_verilog {sim_verilog_callback_display_name}
add_fileset sim_vhdl_fileset SIM_VHDL my_sim_vhdl {sim_vhdl_callback_display_name}

proc my_quartus_synth { outputname } {
	set ::is_sopc 0
	generate_fileset $outputname QUARTUS_SYNTH
}

proc my_sim_verilog { outputname } {
	set ::is_sopc 0
	generate_fileset $outputname SIM_VERILOG
}

proc my_sim_vhdl { outputname } {
	set ::is_sopc 0
	generate_fileset $outputname SIM_VHDL
}


set_module_property Validation_Callback my_validate
set_module_property elaboration_Callback my_elaborate
set_module_property generation_Callback my_generate

proc my_validate {} {
	set device_is_legal  0
	set dev_fam [string map {" " ""} [get_parameter_value DEVICE_FAMILY]] 
	set_parameter_value MODULE_VALID true
	
	if { [string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
		set device_is_legal 1
	} else {
		if {[string compare -nocase [get_parameter_value EXTENDED_FAMILY_SUPPORT] "true"] == 0} {
			if { [string compare -nocase $dev_fam "stratixiii"] == 0 || [string compare -nocase $dev_fam "stratixiv"] == 0 || [string compare -nocase $dev_fam "arriaiigx"] == 0 || [string compare -nocase $dev_fam "arriaiigz"] == 0 } {
				set device_is_legal 1
			}
		} 		
	}
	
	if {$device_is_legal == 0} {
		_error "Family [get_parameter_value DEVICE_FAMILY] is not supported"
		set_parameter_value MODULE_VALID false
	}


	if {[string compare -nocase [get_parameter_value PIN_TYPE] "input"] == 0} {
		set_parameter_property USE_OUTPUT_STROBE ENABLED "false"
		set_parameter_property OCT_SOURCE ALLOWED_RANGES {"1:Data Write Enable" "2:Dedicated OCT Enable"}
	} else {
		set_parameter_property USE_OUTPUT_STROBE ENABLED "true"
		if  {[string compare -nocase [get_parameter_value USE_BIDIR_STROBE] "true"] == 0} {
			set_parameter_property OCT_SOURCE ALLOWED_RANGES {"0:Output Strobe Enable" "1:Data Write Enable" "2:Dedicated OCT Enable"}
		} else {
			set_parameter_property OCT_SOURCE ALLOWED_RANGES {"1:Data Write Enable" "2:Dedicated OCT Enable"}
		}		
	}
	

	if {[string compare -nocase [get_parameter_value USE_OUTPUT_STROBE] "true"] == 0  && [string compare -nocase [get_parameter_value PIN_TYPE] "input"] != 0} {
		set_parameter_property USE_BIDIR_STROBE ENABLED "true"
		set_parameter_property DIFFERENTIAL_OUTPUT_STROBE ENABLED "true"
		if {[string compare -nocase [get_parameter_value USE_BIDIR_STROBE] "true"] == 0} {
			set_parameter_property USE_OUTPUT_STROBE_RESET ENABLED "false"
		} else {
			set_parameter_property USE_OUTPUT_STROBE_RESET ENABLED "true"
		}
	} else {
		set_parameter_property USE_BIDIR_STROBE ENABLED "false"
		set_parameter_property DIFFERENTIAL_OUTPUT_STROBE ENABLED "false"
		set_parameter_property USE_OUTPUT_STROBE_RESET ENABLED "false"
	}
	
	set output_path_enabled "false"
	if {[string compare -nocase [get_parameter_value PIN_TYPE] "output"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0 || [get_parameter_value EXTRA_OUTPUT_WIDTH] > 0 } {
		set output_path_enabled "true"
	}
	if {[string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0} {
		set_parameter_property USE_OUTPUT_PHASE_ALIGNMENT ENABLED "false"
	} else {
		set_parameter_property USE_OUTPUT_PHASE_ALIGNMENT ENABLED  $output_path_enabled
	}
	set_parameter_property USE_TERMINATION_CONTROL ENABLED  $output_path_enabled

	set input_path_enabled "false"
	if {[string compare -nocase [get_parameter_value PIN_TYPE] "input"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0} {
		set input_path_enabled "true"
	}
	set_parameter_property CAPTURE_STROBE_TYPE ENABLED $input_path_enabled
	
	if {[string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0} {
		set_parameter_property DQS_PHASE_SETTING ENABLED  "false"
	} else {
		set_parameter_property DQS_PHASE_SETTING ENABLED  $input_path_enabled
	}

	if {[string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0 || [string compare -nocase [get_parameter_value USE_OUTPUT_PHASE_ALIGNMENT] "false"] == 0} {
		set_parameter_property DUAL_WRITE_CLOCK ENABLED "false"
	} else {
		set_parameter_property DUAL_WRITE_CLOCK ENABLED "true"
	}

	set force_dqs_phase_shift [ get_parameter_value FORCE_DQS_PHASE_SHIFT ]

	if { $force_dqs_phase_shift >= 0 } {
		set_parameter_value DQS_PHASE_SHIFT $force_dqs_phase_shift
	} else {
		if {[string compare -nocase [get_parameter_value DQS_PHASE_SETTING] "0"] == 0} {
			set_parameter_value DQS_PHASE_SHIFT 0
		} elseif {[string compare -nocase [get_parameter_value DQS_PHASE_SETTING] "1"] == 0} {
			set_parameter_value DQS_PHASE_SHIFT 4500
		} elseif {[string compare -nocase [get_parameter_value DQS_PHASE_SETTING] "2"] == 0} {
			set_parameter_value DQS_PHASE_SHIFT 9000
		} elseif {[string compare -nocase [get_parameter_value DQS_PHASE_SETTING] "3"] == 0} {
			set_parameter_value DQS_PHASE_SHIFT 13500
		} else {	
			_error "Phase Setting [get_parameter_value DQS_PHASE_SETTING] is not supported"
			set_parameter_value MODULE_VALID false
		}
	}

	set_parameter_property INVERT_CAPTURE_STROBE ENABLED  $input_path_enabled
	set_parameter_property DQS_ENABLE_PHASE_SETTING ENABLED  $input_path_enabled
	if { [string compare -nocase $dev_fam "arriav" ] == 0 || [string compare -nocase $dev_fam "cyclonev" ] == 0} {
		set_parameter_property USE_DQS_ENABLE ENABLED "false"
	} else {
		set_parameter_property USE_DQS_ENABLE ENABLED $input_path_enabled
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_ENABLE] "true"] == 0} {
		set_parameter_property DQS_ENABLE_PHASE_SETTING ENABLED $input_path_enabled
		set_parameter_property USE_HALF_RATE_DQS_ENABLE ENABLED $input_path_enabled
		if { [string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
			set_parameter_property USE_DQS_TRACKING ENABLED true
		} else {
			set_parameter_property USE_DQS_TRACKING ENABLED false
		}
	} else {
		set_parameter_property DQS_ENABLE_PHASE_SETTING ENABLED "false"
		set_parameter_property USE_HALF_RATE_DQS_ENABLE ENABLED "false"
		set_parameter_property USE_DQS_TRACKING ENABLED false
	}

	if { [string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriav" ] == 0 || [string compare -nocase $dev_fam "cyclonev" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
		set_parameter_property USE_2X_FF ENABLED $output_path_enabled
	} else {
		set_parameter_property USE_2X_FF ENABLED false
	}
	
	if {[string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0} {
		set_parameter_property USE_OFFSET_CTRL VISIBLE "false"
		set_parameter_property USE_OFFSET_CTRL ENABLED "false"
	} else {
		set_parameter_property USE_OFFSET_CTRL VISIBLE "true"
		set_parameter_property USE_OFFSET_CTRL ENABLED "true"
	}

	if { [string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
			set_parameter_property USE_SHADOW_REGS ENABLED "true"
	} else {
			set_parameter_property USE_SHADOW_REGS ENABLED "false"
	}
	
	if {([string equal -nocase $dev_fam "arriav"] || [string equal -nocase $dev_fam "cyclonev"])} {
		set_parameter_value USE_HARD_FIFOS_INTERNAL "true"
		set_parameter_property USE_HARD_FIFOS ENABLED "false"
		_iprint "Hard FIFOs are forced on for ArriaV and CycloneV families."
	} else {
		set_parameter_value USE_HARD_FIFOS_INTERNAL [get_parameter_value USE_HARD_FIFOS]
		set_parameter_property USE_HARD_FIFOS ENABLED "true"
	}
	
	if {[string equal -nocase [get_parameter_value PIN_TYPE] "output"] && [string equal -nocase [get_parameter_value USE_BIDIR_STROBE] "true"]} {
		_error "Output-only ALTDQDQS2 with bidirectional strobe is not supported."
	}
	if {([string equal -nocase $dev_fam "arriav"] || [string equal -nocase $dev_fam "cyclonev"]) &&
		[string equal -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "false"]} {
		_wprint "Hard FIFOs should be enabled if family is Arria V or Cyclone V"
	}
	if {([string equal -nocase $dev_fam "stratixv"] || [string equal -nocase $dev_fam "arriavgz"]) &&
		[string equal -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "false"] &&
		[string equal -nocase [get_parameter_value HALF_RATE_OUTPUT] "true"]} {
		_wprint "Hard FIFOs should be enabled when generating ALTDQ_DQS2 outside of UniPHY in half-rate mode"
	}

	if {[::alt_mem_if::util::qini::cfg_is_on "ip_altdqdqs2_enable_example_design"]} {
		set_parameter_property GENERATE_EXAMPLE_DESIGN visible true
	} 
	if {[::alt_mem_if::util::qini::cfg_is_on "ip_altdqdqs2_enable_dqs_tracking"]} {
		set_parameter_property USE_DQS_TRACKING visible true
	} 

	if {[::alt_mem_if::util::qini::cfg_is_on "ip_altdqdqs2_enable_external_write_strobe_ports"] && [string compare -nocase $dev_fam "stratixv" ] == 0} {
		set_parameter_property USE_EXTERNAL_WRITE_STROBE_PORTS visible true
	}

        if {[string compare -nocase [get_parameter_value USE_EXTERNAL_WRITE_STROBE_PORTS] "true"] == 0} {
		set_parameter_property USE_OFFSET_CTRL ENABLED "false"
                set_parameter_property USE_SHADOW_REGS ENABLED "false"
        }

        if {(([string compare -nocase [get_parameter_value USE_DQS_ENABLE] "true"] == 0) || ((([string compare -nocase $dev_fam "arriav" ] == 0) || ([string compare -nocase $dev_fam "cyclonev" ] == 0)) && ([string compare -nocase [get_parameter_value USE_BIDIR_STROBE] "true"]==0)))} {
		_wprint "The timing of the capture strobe enable block requires knowledge of the arrival time of the capture strobe which typically requires round-trip delay information.  The use of this block thus usually requires run-time calibration which is not included as part of ALTDQ_DQS2."
        }

	if { [::alt_mem_if::util::qini::cfg_is_on "ip_altdqdqs2_enable_external_capture_clocks"] && [string compare -nocase $dev_fam "stratixv" ] == 0 } {
		set_parameter_property USE_CAPTURE_REG_EXTERNAL_CLOCKING visible true
		set_parameter_property USE_READ_FIFO_EXTERNAL_CLOCKING visible true
	}
	if {([string equal -nocase [get_parameter_value USE_CAPTURE_REG_EXTERNAL_CLOCKING] "true"] || [string equal -nocase [get_parameter_value USE_READ_FIFO_EXTERNAL_CLOCKING] "true"]) && ([string equal -nocase [get_parameter_value USE_HARD_FIFOS] "false"] || [string equal -nocase [get_parameter_value HALF_RATE_OUTPUT] "false"] || [string equal -nocase [get_parameter_value PIN_TYPE] "output"] )} {
		_error "External clocking of the capture interface requires an input or bidirectional pin type with half-rate output through the hard read fifo."
	}

	set interface_freq [ get_parameter_value INPUT_FREQ ]

	if {[string equal -nocase $dev_fam "stratixv"] && $interface_freq < 300} {
		_wprint "The specified interface frequency is below the minimum DLL frequency of 300 MHz for Stratix V devices. Refer to chapter 7 of the Stratix V handbook for proper clocking of the DLL to ensure expected DQS phase-shift settings in the design. The parameters DQS_PHASE_SHIFT and DQS_PHASE_SETTING will have to be manually updated based on the DLL frequency."
	} elseif {[string equal -nocase $dev_fam "arriav"] && $interface_freq < 200} {
		_wprint "The specified interface frequency is below the minimum DLL frequency of 200 MHz for Arria V devices. Refer to chapter 7 of the Arria V handbook for proper clocking of the DLL to ensure expected DQS phase-shift settings in the design. The parameters DQS_PHASE_SHIFT and DQS_PHASE_SETTING will have to be manually updated based on the DLL frequency."
	} elseif {[string equal -nocase $dev_fam "cyclonev"] && $interface_freq < 167} {
		_wprint "The specified interface frequency is below the minimum DLL frequency of 167 MHz for Cyclone V devices. Refer to chapter 6 of the Cyclone V handbook for proper clocking of the DLL to ensure expected DQS phase-shift settings in the design. The parameters DQS_PHASE_SHIFT and DQS_PHASE_SETTING will have to be manually updated based on the DLL frequency."
	}
}

proc my_elaborate {} {
	set dev_fam [string map {" " ""} [get_parameter_value DEVICE_FAMILY]] 

	if {[string compare -nocase [get_parameter_value PIN_TYPE] "input"] != 0} {

		if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {

			add_interface fr_data_clock clock end
			set_interface_property fr_data_clock ENABLED true
			add_interface_port fr_data_clock fr_data_clock_in clk Input 1

			add_interface fr_strobe_clock clock end
			set_interface_property fr_strobe_clock ENABLED true
			add_interface_port fr_strobe_clock fr_strobe_clock_in clk Input 1


		} else {
			add_interface fr_clock clock end
			set_interface_property fr_clock ENABLED true
			add_interface_port fr_clock fr_clock_in clk Input 1
		}
	
		add_interface core_clock clock end
		set_interface_property core_clock ENABLED true
		add_interface_port core_clock core_clock_in clk Input 1
		
		add_interface_port memory_interface reset_n_core_clock_in export Input 1

		
		add_interface_port data_interface write_data_in export Input 0
		set_port_property write_data_in WIDTH [expr [get_parameter_value PIN_WIDTH] * 2 * [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]]
	}

	add_interface hr_clock clock end
	set_interface_property hr_clock ENABLED true
	add_interface_port hr_clock hr_clock_in clk Input 1


	if {[get_parameter_value EXTRA_OUTPUT_WIDTH] > 0} {
		add_interface_port memory_interface extra_write_data_out export Output [get_parameter_value EXTRA_OUTPUT_WIDTH]
		add_interface_port data_interface extra_write_data_in export Input [expr [get_parameter_value EXTRA_OUTPUT_WIDTH] * 2 * [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]]
	}

	if {[string compare -nocase [get_parameter_value USE_DYNAMIC_CONFIG] "true"]==0} {
		add_interface "Dynamic Configuration" conduit end
		add_interface_port "Dynamic Configuration" config_dqs_ena export Input 1
		add_interface_port "Dynamic Configuration" config_io_ena export Input  [get_parameter_value PIN_WIDTH] 
		add_interface_port "Dynamic Configuration" config_dqs_io_ena export Input 1
		add_interface_port "Dynamic Configuration" config_update export Input 1
		add_interface_port "Dynamic Configuration" config_data_in export Input 1

		add_interface config_clock clock end

		set_interface_property config_clock ENABLED true

		add_interface_port config_clock config_clock_in clk Input 1

		if {[get_parameter_value EXTRA_OUTPUT_WIDTH] > 0} {
			add_interface_port "Dynamic Configuration" config_extra_io_ena export Input [get_parameter_value EXTRA_OUTPUT_WIDTH]
		}
	}
	
	if {[string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "output"] == 0} {
		add_interface_port data_interface write_oe_in export Input [expr [rate_mult [get_parameter_value HALF_RATE_OUTPUT]] * [get_parameter_value PIN_WIDTH]]
        }

	if {[string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0} {
		add_interface_port memory_interface read_write_data_io export Bidir [get_parameter_value PIN_WIDTH]
	} elseif {[string compare -nocase [get_parameter_value PIN_TYPE] "output"] == 0} {
		add_interface_port memory_interface write_data_out export Output [get_parameter_value PIN_WIDTH]
	} else { 
		add_interface_port memory_interface read_data_in export Input [get_parameter_value PIN_WIDTH]
	}
	
	if {[string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "input"] == 0} {
		add_interface_port data_interface read_data_out export Output 0
		set_port_property read_data_out WIDTH [expr [get_parameter_value PIN_WIDTH] * 2 * [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]]
		add_interface_port "Capture clock" capture_strobe_out clk Output 1
	}
	
	if {[string compare -nocase [get_parameter_value USE_BIDIR_STROBE] "true"]==0} {
		add_interface_port memory_interface strobe_io export Bidir 1
		add_interface_port data_interface output_strobe_ena export Input [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]
		add_interface_port memory_interface write_strobe_clock_in export Input 1

		if {[string compare -nocase [get_parameter_value CAPTURE_STROBE_TYPE] "single"] != 0} {
			add_interface_port memory_interface strobe_n_io export Bidir 1
		}
	} else {

		if {[string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "input"] == 0} {
			add_interface_port memory_interface capture_strobe_in export Input 1
			if {[string compare -nocase [get_parameter_value CAPTURE_STROBE_TYPE] "single"] != 0} {
				add_interface_port memory_interface capture_strobe_n_in export Input 1
			}
		}
	
		if {[string compare -nocase [get_parameter_value USE_OUTPUT_STROBE] "true"]==0} {
			add_interface_port memory_interface output_strobe_out export Output 1
			add_interface_port memory_interface write_strobe_clock_in export Input 1

			if {[string compare -nocase [get_parameter_value DIFFERENTIAL_OUTPUT_STROBE] "true"] == 0} {
				add_interface_port memory_interface output_strobe_n_out export Output 1
			}
		}
	}
	
	if {[string compare -nocase [get_parameter_value USE_DQS_ENABLE] "true"]==0} {
		set dqs_ena_width 1 
		if {[string compare -nocase [get_parameter_value USE_HALF_RATE_DQS_ENABLE] "true"]==0} {
			set dqs_ena_width 2
		}

		if {[string compare -nocase $dev_fam "arriav"] != 0 && [string compare -nocase $dev_fam "cyclonev"] != 0} {
			add_interface strobe_ena_clock clock end
			set_interface_property strobe_ena_clock ENABLED true
			add_interface_port strobe_ena_clock strobe_ena_clock_in clk Input 1
		}

		add_interface strobe_ena_hr_clock clock end
		set_interface_property strobe_ena_hr_clock ENABLED true
		add_interface_port strobe_ena_hr_clock strobe_ena_hr_clock_in clk Input 1
		
		if {[string compare -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "true"] != 0} {
			add_interface_port data_interface capture_strobe_ena export Input $dqs_ena_width
		}
	
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"]==0} {
			add_interface_port data_interface capture_strobe_tracking export Output 1
		}	
	}

	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"]==0} {
		add_interface dr_clock clock end
		set_interface_property dr_clock ENABLED true
		add_interface_port dr_clock dr_clock_in clk Input 1
	}
	
	if {[string compare -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "true"] == 0 && [ expr [string compare -nocase [get_parameter_value PIN_TYPE] "bidir"] == 0 || [string compare -nocase [get_parameter_value PIN_TYPE] "input"] == 0] } {
		if { [string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0} {	
			add_interface hard_fifo_control conduit end
			set_interface_property hard_fifo_control ENABLED true
			add_interface_port hard_fifo_control lfifo_rdata_en_full export Input [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]
			add_interface_port hard_fifo_control lfifo_rd_latency export Input 5
			add_interface_port hard_fifo_control lfifo_reset_n export Input 1
			add_interface_port hard_fifo_control vfifo_qvld export Input [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]
			add_interface_port hard_fifo_control vfifo_inc_wr_ptr export Input [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]
			add_interface_port hard_fifo_control vfifo_reset_n export Input 1
			add_interface_port hard_fifo_control rfifo_reset_n export Input 1
		} elseif { [string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
			add_interface hard_fifo_control conduit end
			add_interface_port hard_fifo_control lfifo_rden export Input 1
			add_interface_port hard_fifo_control vfifo_qvld export Input 1
			add_interface_port hard_fifo_control rfifo_reset_n export Input 1
		}
	}

	if {[string compare -nocase $dev_fam "arriav"] == 0 || [string compare -nocase $dev_fam "cyclonev"] == 0} {
		set_parameter_property USE_DQSIN_FOR_VFIFO_READ visible true
		if {[string compare -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "true"] == 0} {
			set_parameter_property USE_DQSIN_FOR_VFIFO_READ enabled true
		} else {
			set_parameter_property USE_DQSIN_FOR_VFIFO_READ enabled false
		}
	} else {
		set_parameter_property USE_DQSIN_FOR_VFIFO_READ visible false
	}

	if {[string compare -nocase [get_parameter_value CONNECT_TO_HARD_PHY] "true"] == 0} {
		add_interface hard_phy_control conduit end
		set_interface_property hard_phy_control ENABLED true
		add_interface_port hard_phy_control write_strobe export Input 4
	}

	if {[string compare -nocase $dev_fam "stratixv"] != 0 && [string compare -nocase $dev_fam "arriav"] != 0 && [string compare -nocase $dev_fam "cyclonev"] != 0 && [string compare -nocase $dev_fam "arriavgz"] != 0} {
		set_parameter_value DLL_WIDTH 6
		
		if {[string compare -nocase $dev_fam "arriaiigx"] != 0} {
			set_parameter_value OCT_PARALLEL_TERM_CONTROL_WIDTH 14
			set_parameter_value OCT_SERIES_TERM_CONTROL_WIDTH 14
		}
	}

	if {[get_parameter_value OCT_SOURCE] == 2} {
		add_interface_port data_interface oct_ena_in export Input [rate_mult [get_parameter_value HALF_RATE_OUTPUT]]	
	}
	if {[string compare -nocase [get_parameter_value USE_OFFSET_CTRL] "true"]==0} {
		add_interface_port Misc dll_offsetdelay_in export Input [get_parameter_value DLL_WIDTH]
	}
	
	if {[get_parameter_value INPUT_FREQ] > 0} {
		set_parameter_value INPUT_FREQ_PS [ expr round(1000000.0 / [get_parameter_value INPUT_FREQ]) ]
	}

	if {[string equal -nocase [get_parameter_value USE_CAPTURE_REG_EXTERNAL_CLOCKING] "true"]} {
		add_interface external_ddio_capture_clocks clock end
		add_interface_port external_ddio_capture_clocks external_ddio_capture_clock export Input 1
	}
	if {[string equal -nocase [get_parameter_value USE_READ_FIFO_EXTERNAL_CLOCKING] "true"]} {
		add_interface external_read_fifo_capture_clocks clock end
		add_interface_port external_read_fifo_capture_clocks external_fifo_capture_clock export Input 1
	}
	
}

proc my_generate {} {
	set ::is_sopc 1
	generate_fileset [get_generation_property OUTPUT_NAME] OLD_STYLE
}


proc generate_fileset { outputname fileset_type } {
	if {[string compare -nocase [get_parameter_value MODULE_VALID] false] == 0} {
		_error "Current parameterization is not valid.  Cannot generate HDL"
	} else {
		set dev_fam [string map {" " ""} [get_parameter_value DEVICE_FAMILY]]

		set param_str "DEVICE_FAMILY=$dev_fam"
		append param_str ",PIN_WIDTH=[get_parameter_value PIN_WIDTH]"
		append param_str ",EXTRA_OUTPUT_WIDTH=[get_parameter_value EXTRA_OUTPUT_WIDTH]"
		append param_str ",USE_HALF_RATE_OUTPUT=[get_parameter_value HALF_RATE_OUTPUT]"
		append param_str ",USE_HALF_RATE_INPUT=[get_parameter_value HALF_RATE_INPUT]"
		append param_str ",USE_INPUT_PHASE_ALIGNMENT=[get_parameter_value USE_INPUT_PHASE_ALIGNMENT]"
		append param_str ",USE_OUTPUT_PHASE_ALIGNMENT=[get_parameter_value USE_OUTPUT_PHASE_ALIGNMENT]"
		append param_str ",INVERT_CAPTURE_STROBE=[get_parameter_value INVERT_CAPTURE_STROBE]"
		append param_str ",SWAP_CAPTURE_STROBE_POLARITY=[get_parameter_value SWAP_CAPTURE_STROBE_POLARITY]"
		append param_str ",EXTRA_OUTPUTS_USE_SEPARATE_GROUP=[get_parameter_value EXTRA_OUTPUTS_USE_SEPARATE_GROUP]"
		append param_str ",USE_BIDIR_STROBE=[get_parameter_value USE_BIDIR_STROBE]"
		append param_str ",USE_DQS_ENABLE=[get_parameter_value USE_DQS_ENABLE]"
		append param_str ",USE_HALF_RATE_DQS_ENABLE=[get_parameter_value USE_HALF_RATE_DQS_ENABLE]"
		append param_str ",USE_DYNAMIC_CONFIG=[get_parameter_value USE_DYNAMIC_CONFIG]"
		append param_str ",USE_TERMINATION_CONTROL=[get_parameter_value USE_TERMINATION_CONTROL]"
		append param_str ",USE_OUTPUT_STROBE=[get_parameter_value USE_OUTPUT_STROBE]"
		append param_str ",USE_OUTPUT_STROBE_RESET=[get_parameter_value USE_OUTPUT_STROBE_RESET]"
		append param_str ",DIFFERENTIAL_OUTPUT_STROBE=[get_parameter_value DIFFERENTIAL_OUTPUT_STROBE]"
		append param_str ",REVERSE_READ_WORDS=[get_parameter_value REVERSE_READ_WORDS]"
		append param_str ",REGULAR_WRITE_BUS_ORDERING=[get_parameter_value REGULAR_WRITE_BUS_ORDERING]"
		
		append param_str ",INPUT_FREQ=[get_parameter_value INPUT_FREQ]"
		append param_str ",INPUT_FREQ_PS=[get_parameter_value INPUT_FREQ_PS]"
		append param_str ",DQS_PHASE_SETTING=[get_parameter_value DQS_PHASE_SETTING]"
		append param_str ",DQS_PHASE_SHIFT=[get_parameter_value DQS_PHASE_SHIFT]"
			
		append param_str ",DQS_ENABLE_PHASE_SETTING=[get_parameter_value DQS_ENABLE_PHASE_SETTING]"
		append param_str ",OCT_SERIES_TERM_CONTROL_WIDTH=[get_parameter_value OCT_SERIES_TERM_CONTROL_WIDTH]"
		append param_str ",OCT_PARALLEL_TERM_CONTROL_WIDTH=[get_parameter_value OCT_PARALLEL_TERM_CONTROL_WIDTH]"
		append param_str ",PIN_TYPE=[get_parameter_value PIN_TYPE]"
		append param_str ",PREAMBLE_TYPE=[get_parameter_value PREAMBLE_TYPE]"
		append param_str ",EMIF_UNALIGNED_PREAMBLE_SUPPORT=[get_parameter_value EMIF_UNALIGNED_PREAMBLE_SUPPORT]"
		append param_str ",USE_OFFSET_CTRL=[get_parameter_value USE_OFFSET_CTRL]"

		append param_str ",USE_ABSTRACT_RTL=[get_parameter_value USE_ABSTRACT_RTL]"
		append param_str ",USE_REAL_RTL=[get_parameter_value USE_REAL_RTL]"
		append param_str ",CALIBRATION_SUPPORT=[get_parameter_value CALIBRATION_SUPPORT]"



		set SEPARATE_CAPTURE_STROBE false
		set DIFFERENTIAL_CAPTURE_STROBE false
		set BUFFER_MODE high
		set DYNAMIC_MODE false
		set DQS_ENABLE_PHASECTRL true
		
		if {[string compare -nocase [get_parameter_value CAPTURE_STROBE_TYPE] "differential"] == 0} {
			set DIFFERENTIAL_CAPTURE_STROBE true
			append param_str ",USE_STROBE_N"
		} else {

			if {[string compare -nocase [get_parameter_value CAPTURE_STROBE_TYPE] "complimentary"] == 0} {
				set SEPARATE_CAPTURE_STROBE true
				append param_str ",USE_STROBE_N"
			} else {
				if {[string compare -nocase [get_parameter_value DIFFERENTIAL_OUTPUT_STROBE] "true"] == 0} {
					append param_str ",USE_STROBE_N"
				}
			}
		}

	
		if {[get_parameter_value INPUT_FREQ] < 251} {
			set BUFFER_MODE low
			append param_str ",DQS_ENABLE_PHASECTRL=false"
		} else {
			append param_str ",DQS_ENABLE_PHASECTRL=[get_parameter_value USE_DYNAMIC_CONFIG]"
		}

		if {[string compare -nocase [get_parameter_value USE_DYNAMIC_CONFIG] "true"] == 0} {
			set DYNAMIC_MODE dynamic
		}
		
		if {[string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriav" ] == 0 || [string compare -nocase $dev_fam "cyclonev" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
			append param_str ",DELAY_CHAIN_BUFFER_MODE=$BUFFER_MODE"
		} else {
			append param_str ",DELAY_CHAIN_BUFFER_MODE=[get_parameter_value DELAY_CHAIN_BUFFER_MODE]"
		}
				
		append param_str ",DYNAMIC_MODE=$DYNAMIC_MODE"
		append param_str ",SEPARATE_CAPTURE_STROBE=$SEPARATE_CAPTURE_STROBE"
		append param_str ",DIFFERENTIAL_CAPTURE_STROBE=$DIFFERENTIAL_CAPTURE_STROBE"

		append param_str ",OUTPUT_MULT=[rate_mult [get_parameter_value HALF_RATE_OUTPUT]]"
		append param_str ",INPUT_MULT=[rate_mult [get_parameter_value HALF_RATE_INPUT]]"

		append param_str ",DLL_WIDTH=[get_parameter_value DLL_WIDTH]"
		
		append param_str ",DLL_USE_2X_CLK=[get_parameter_value DLL_USE_2X_CLK]"
		append param_str ",USE_LDC_AS_LOW_SKEW_CLOCK=[get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK]"
		append param_str ",OUTPUT_DQS_PHASE_SETTING=[get_parameter_value OUTPUT_DQS_PHASE_SETTING]"
		append param_str ",OUTPUT_DQ_PHASE_SETTING=[get_parameter_value OUTPUT_DQ_PHASE_SETTING]"
				
		if {[string compare -nocase [get_parameter_value PIN_TYPE] "bidir"]==0} {
			append param_str ",PIN_TYPE_BIDIR"
			append param_str ",PIN_HAS_INPUT"
			append param_str ",PIN_HAS_OUTPUT"
		} elseif {[string compare -nocase [get_parameter_value PIN_TYPE] "input"]==0} {
			append param_str ",PIN_TYPE_INPUT"
			append param_str ",PIN_HAS_INPUT"
		} elseif {[string compare -nocase [get_parameter_value PIN_TYPE] "output"]==0} {
			append param_str ",PIN_TYPE_OUTPUT"
			append param_str ",PIN_HAS_OUTPUT"
		}

		if {[get_parameter_value EXTRA_OUTPUT_WIDTH] > 0} {
			append param_str ",HAS_EXTRA_OUTPUT_IOS"
		}

		if {[get_parameter_value OCT_SOURCE] == 1} {
			append param_str ",USE_DATA_OE_FOR_OCT=true"
			append param_str ",USE_OCT_ENA_IN_FOR_OCT=false"
		} else {
			append param_str ",USE_DATA_OE_FOR_OCT=false"

			if {[get_parameter_value OCT_SOURCE] == 2} {
				append param_str ",USE_OCT_ENA_IN_FOR_OCT=true"
				append param_str ",USE_OCT_ENA_IN"
			} else {
				append param_str ",USE_OCT_ENA_IN_FOR_OCT=false"
			}
		}

		if {[string compare -nocase [get_parameter_value USE_HALF_RATE_DQS_ENABLE] "true"] == 0} {
			append param_str ",STROBE_ENA_WIDTH=2"
		} else {
			append param_str ",STROBE_ENA_WIDTH=1"
		}

		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
			append param_str ",USE_DQS_TRACKING=true"
		} else {
			append param_str ",USE_DQS_TRACKING=false"
		}
		
		
		if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
			append param_str ",USE_2X_FF=true"
		} else {
			append param_str ",USE_2X_FF=false"
		}

		
		if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
			append param_str ",DUAL_WRITE_CLOCK=true"
		} else {
			append param_str ",DUAL_WRITE_CLOCK=false"
		}
		
		if {[string compare -nocase [get_parameter_value USE_HARD_FIFOS_INTERNAL] "true"] == 0} {
			append param_str ",USE_HARD_FIFOS=true"
		} else {
			append param_str ",USE_HARD_FIFOS=false"
		}
		
		if {[string compare -nocase [get_parameter_value USE_DQSIN_FOR_VFIFO_READ] "true"] == 0} {
			append param_str ",USE_DQSIN_FOR_VFIFO_READ=true"
		} else {
			append param_str ",USE_DQSIN_FOR_VFIFO_READ=false"
		}
		
		if {[string compare -nocase [get_parameter_value CONNECT_TO_HARD_PHY] "true"] == 0} {
			append param_str ",CONNECT_TO_HARD_PHY=true"
		} else {
			append param_str ",CONNECT_TO_HARD_PHY=false"
		}

		if {[string compare -nocase [get_parameter_value QUARTER_RATE_MODE] "true"] == 0} {
			append param_str ",QUARTER_RATE_MODE=true"
		} else {
			append param_str ",QUARTER_RATE_MODE=false"
		}
		
		if {[string compare -nocase [get_parameter_value NATURAL_ALIGNMENT] "true"] == 0} {
			append param_str ",NATURAL_ALIGNMENT=true"
		} else {
			append param_str ",NATURAL_ALIGNMENT=false"
		}
		
		if {[string compare -nocase [get_parameter_value SEPERATE_LDC_FOR_WRITE_STROBE] "true"] == 0} {
			append param_str ",SEPERATE_LDC_FOR_WRITE_STROBE=true"
		} else {
			append param_str ",SEPERATE_LDC_FOR_WRITE_STROBE=false"
		}

		if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
			append param_str ",USE_SHADOW_REGS=true"
		} else {
			append param_str ",USE_SHADOW_REGS=false"
		}

		if {[string compare -nocase $dev_fam "stratixv" ] == 0 || [string compare -nocase $dev_fam "arriavgz"] == 0} {
				append param_str ",DELAY_CHAIN_WIDTH=8"
		} else {
				append param_str ",DELAY_CHAIN_WIDTH=4"
		}
		
		if {[string compare -nocase [get_parameter_value LPDDR2] "true"] == 0} {
			append param_str ",LPDDR2=true"
		} else {
			append param_str ",LPDDR2=false"
		}
		
		append param_str ",HHP_HPS=[get_parameter_value HHP_HPS]"
		append param_str ",GENERATE_EXAMPLE_DESIGN=[get_parameter_value GENERATE_EXAMPLE_DESIGN]"

		append param_str ",USE_EXTERNAL_WRITE_STROBE_PORTS=[get_parameter_value USE_EXTERNAL_WRITE_STROBE_PORTS]"

		if {[string equal -nocase [get_parameter_value USE_CAPTURE_REG_EXTERNAL_CLOCKING] "true"]} {
			append param_str ",USE_CAPTURE_REG_EXTERNAL_CLOCKING"
		}
		if {[string equal -nocase [get_parameter_value USE_READ_FIFO_EXTERNAL_CLOCKING] "true"]} {
			append param_str ",USE_READ_FIFO_EXTERNAL_CLOCKING"
		}

		if {[string compare -nocase $fileset_type "OLD_STYLE"] == 0} {
			set outdir [get_generation_property OUTPUT_DIRECTORY]
		} else {
			set outdir [add_fileset_file {} OTHER TEMP {}]
		}
		
		_dprint 1 "Temporary directory is $outdir"

		run_generate $outputname $outdir $param_str $fileset_type

		_iprint ""
		_iprint "$outputname variant of ALTDQ_DQS2 generation is complete!"
	}
}
