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


package require -exact altera_terp 1.0

source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

# Common module properties for VIP components
declare_general_component_info

# | module alt_vip_fir_alg_core
set_module_property NAME alt_vip_fir_alg_core
set_module_property DISPLAY_NAME "FIR Algorithmic Core"
set_module_property DESCRIPTION "This block filters a line of data using either a standard 2D FIR Filter or an edge adaptive sharpening filter"

set_module_property VALIDATION_CALLBACK fir_alg_core_validation_callback
set_module_property ELABORATION_CALLBACK fir_alg_core_elaboration_callback
set_module_property GENERATION_CALLBACK fir_alg_core_generation_callback

# | files

add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_alt_vip_common_mult_add_files ../../..
add_alt_vip_common_h_kernel_files ../../..
add_alt_vip_common_mirror_files ../../..
add_alt_vip_common_edge_detect_chain_files ../../..
add_file src_hdl/alt_vip_fir_tree_edge_adapt.sv $add_file_attribute
add_file src_hdl/alt_vip_fir_symmetric_adder.sv $add_file_attribute
add_file src_hdl/alt_vip_fir_round_saturation.sv $add_file_attribute
add_file src_hdl/alt_vip_fir_edge_detect.sv $add_file_attribute
add_file src_hdl/alt_vip_fir_controller.sv $add_file_attribute
add_file src_hdl/alt_vip_fir_alg_core.sv $add_file_attribute

# | parameters
add_channels_nb_parameters
add_bits_per_symbol_parameters
set_parameter_property    BITS_PER_SYMBOL   DISPLAY_NAME            "Input bits per pixel per color plane"
set_parameter_property    BITS_PER_SYMBOL   DESCRIPTION             "The number of bits used per color plane at the input"

add_parameter BITS_PER_SYMBOL_OUT int 8
set_parameter_property    BITS_PER_SYMBOL_OUT   DISPLAY_NAME            "Output bits per pixel per color plane"
set_parameter_property    BITS_PER_SYMBOL_OUT   ALLOWED_RANGES          4:20
set_parameter_property    BITS_PER_SYMBOL_OUT   DESCRIPTION             "The number of bits used per color plane at the output"
set_parameter_property    BITS_PER_SYMBOL_OUT   HDL_PARAMETER           false
set_parameter_property    BITS_PER_SYMBOL_OUT   AFFECTS_ELABORATION     true

add_parameter IS_422 int 1
set_parameter_property IS_422 DISPLAY_NAME "4:2:2 video data"
set_parameter_property IS_422 ALLOWED_RANGES 0:1
set_parameter_property IS_422 DISPLAY_HINT boolean
set_parameter_property IS_422 DESCRIPTION "Select for 4:2:2 video input/output"
set_parameter_property IS_422 HDL_PARAMETER false
set_parameter_property IS_422 AFFECTS_ELABORATION false

add_max_dim_parameters
set_parameter_property MAX_WIDTH  HDL_PARAMETER false
set_parameter_property MAX_HEIGHT VISIBLE       false
set_parameter_property MAX_HEIGHT HDL_PARAMETER false

add_parameter PARTIAL_LINE_FILTERING INTEGER 0
set_parameter_property PARTIAL_LINE_FILTERING DISPLAY_NAME "Include partial line filtering support"
set_parameter_property PARTIAL_LINE_FILTERING ALLOWED_RANGES 0:1
set_parameter_property PARTIAL_LINE_FILTERING DISPLAY_HINT boolean
set_parameter_property PARTIAL_LINE_FILTERING DESCRIPTION "Select to include hardware to allow the filtering of partial video lines"
set_parameter_property PARTIAL_LINE_FILTERING HDL_PARAMETER false
set_parameter_property PARTIAL_LINE_FILTERING AFFECTS_ELABORATION false

add_parameter DO_MIRRORING INTEGER 1
set_parameter_property DO_MIRRORING DISPLAY_NAME "Enable edge data mirroring"
set_parameter_property DO_MIRRORING ALLOWED_RANGES 0:1
set_parameter_property DO_MIRRORING DISPLAY_HINT boolean
set_parameter_property DO_MIRRORING DESCRIPTION "Select to enable the mirroring of data in the filter at the image edges. When this feature is not enabled the edge pixel is padded to fill any empty taps"
set_parameter_property DO_MIRRORING HDL_PARAMETER false
set_parameter_property DO_MIRRORING AFFECTS_ELABORATION false

add_parameter LEFT_MIRROR INTEGER 1
set_parameter_property LEFT_MIRROR DISPLAY_NAME "Enable left edge mirroring"
set_parameter_property LEFT_MIRROR ALLOWED_RANGES 0:1
set_parameter_property LEFT_MIRROR DISPLAY_HINT boolean
set_parameter_property LEFT_MIRROR DESCRIPTION "Select to enable the mirroring of image data at the left edge of video frames"
set_parameter_property LEFT_MIRROR HDL_PARAMETER false
set_parameter_property LEFT_MIRROR AFFECTS_ELABORATION false

add_parameter RIGHT_MIRROR INTEGER 1
set_parameter_property RIGHT_MIRROR DISPLAY_NAME "Enable right edge mirroring"
set_parameter_property RIGHT_MIRROR ALLOWED_RANGES 0:1
set_parameter_property RIGHT_MIRROR DISPLAY_HINT boolean
set_parameter_property RIGHT_MIRROR DESCRIPTION "Select to enable the mirroring of image data at the right edge of video frames"
set_parameter_property RIGHT_MIRROR HDL_PARAMETER false
set_parameter_property RIGHT_MIRROR AFFECTS_ELABORATION false

add_parameter ALGORITHM_NAME string STANDARD_FIR
set_parameter_property ALGORITHM_NAME DISPLAY_NAME "Filtering Algorithm"
set_parameter_property ALGORITHM_NAME ALLOWED_RANGES {STANDARD_FIR EDGE_ADAPTIVE_SHARPEN}
set_parameter_property ALGORITHM_NAME DISPLAY_HINT ""
set_parameter_property ALGORITHM_NAME DESCRIPTION "Selects the filtering alogithm used"
set_parameter_property ALGORITHM_NAME HDL_PARAMETER false
set_parameter_property ALGORITHM_NAME AFFECTS_ELABORATION true

add_parameter V_TAPS int 8
set_parameter_property V_TAPS DISPLAY_NAME "Vertical filter taps"
set_parameter_property V_TAPS ALLOWED_RANGES 1:64
set_parameter_property V_TAPS DESCRIPTION "Number of vertical filter taps for the bicubic and polyphase algorithms"
set_parameter_property V_TAPS HDL_PARAMETER false
set_parameter_property V_TAPS AFFECTS_ELABORATION true

add_parameter H_TAPS int 8
set_parameter_property H_TAPS DISPLAY_NAME "Horizontal filter taps"
set_parameter_property H_TAPS ALLOWED_RANGES 1:64
set_parameter_property H_TAPS DESCRIPTION "Number of horizontal filter taps for the bicubic and polyphase algorithms"
set_parameter_property H_TAPS HDL_PARAMETER false
set_parameter_property H_TAPS AFFECTS_ELABORATION false

add_parameter V_SYMMETRIC int 0
set_parameter_property V_SYMMETRIC DISPLAY_NAME "Vertically symmetirc coefficients"
set_parameter_property V_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property V_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property V_SYMMETRIC DESCRIPTION "Enable if the coefficients are vertically symmetric"
set_parameter_property V_SYMMETRIC HDL_PARAMETER false
set_parameter_property V_SYMMETRIC AFFECTS_ELABORATION true

add_parameter H_SYMMETRIC int 0
set_parameter_property H_SYMMETRIC DISPLAY_NAME "Horizontally symmetirc coefficients"
set_parameter_property H_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property H_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property H_SYMMETRIC DESCRIPTION "Enable if the coefficients are horizontally symmetric"
set_parameter_property H_SYMMETRIC HDL_PARAMETER false
set_parameter_property H_SYMMETRIC AFFECTS_ELABORATION true

add_parameter DIAG_SYMMETRIC int 0
set_parameter_property DIAG_SYMMETRIC DISPLAY_NAME "Diagonally symmetirc coefficients"
set_parameter_property DIAG_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property DIAG_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property DIAG_SYMMETRIC DESCRIPTION "Enable if the coefficients are diagonally symmetric"
set_parameter_property DIAG_SYMMETRIC HDL_PARAMETER false
set_parameter_property DIAG_SYMMETRIC AFFECTS_ELABORATION true

add_parameter COEFF_SIGNED int 1
set_parameter_property COEFF_SIGNED DISPLAY_NAME "Use signed coefficients"
set_parameter_property COEFF_SIGNED ALLOWED_RANGES 0:1
set_parameter_property COEFF_SIGNED DISPLAY_HINT boolean
set_parameter_property COEFF_SIGNED DESCRIPTION "Forces the algorithm to use signed coefficient data"
set_parameter_property COEFF_SIGNED HDL_PARAMETER false
set_parameter_property COEFF_SIGNED AFFECTS_ELABORATION true

add_parameter COEFF_INTEGER_BITS int 1
set_parameter_property COEFF_INTEGER_BITS DISPLAY_NAME "Coefficient integer bits"
set_parameter_property COEFF_INTEGER_BITS ALLOWED_RANGES 0:32
set_parameter_property COEFF_INTEGER_BITS DESCRIPTION "Number of integer bits for each coefficient"
set_parameter_property COEFF_INTEGER_BITS HDL_PARAMETER false
set_parameter_property COEFF_INTEGER_BITS AFFECTS_ELABORATION true

add_parameter COEFF_FRACTION_BITS int 7
set_parameter_property COEFF_FRACTION_BITS DISPLAY_NAME "Vertical coefficient fraction bits"
set_parameter_property COEFF_FRACTION_BITS ALLOWED_RANGES 1:32
set_parameter_property COEFF_FRACTION_BITS DESCRIPTION "Number of fraction bits for each vertical coefficient"
set_parameter_property COEFF_FRACTION_BITS HDL_PARAMETER false
set_parameter_property COEFF_FRACTION_BITS AFFECTS_ELABORATION true

add_parameter MOVE_BINARY_POINT_RIGHT int 0
set_parameter_property MOVE_BINARY_POINT_RIGHT DISPLAY_NAME "Move binary point right"
set_parameter_property MOVE_BINARY_POINT_RIGHT DESCRIPTION "Number of digits to move the binary point to the right after filtering (negative number indicates move to the left)"
set_parameter_property MOVE_BINARY_POINT_RIGHT HDL_PARAMETER false
set_parameter_property MOVE_BINARY_POINT_RIGHT AFFECTS_ELABORATION false

add_parameter ROUNDING_METHOD string ROUND_HALF_UP
set_parameter_property ROUNDING_METHOD DISPLAY_NAME "Rounding method"
set_parameter_property ROUNDING_METHOD ALLOWED_RANGES {TRUNCATE ROUND_HALF_UP ROUND_HALF_EVEN}
set_parameter_property ROUNDING_METHOD DISPLAY_HINT ""
set_parameter_property ROUNDING_METHOD DESCRIPTION "Selects the method used to round the filter output to the final precision"
set_parameter_property ROUNDING_METHOD HDL_PARAMETER false
set_parameter_property ROUNDING_METHOD AFFECTS_ELABORATION false

add_parameter ENABLE_CONSTANT_OUTPUT_OFFSET int 1
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET DISPLAY_NAME "Enable constant output offset"
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET ALLOWED_RANGES 0:1
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET DISPLAY_HINT boolean
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET DESCRIPTION "Enable to add a constant offset to the filter output"
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET HDL_PARAMETER false
set_parameter_property ENABLE_CONSTANT_OUTPUT_OFFSET AFFECTS_ELABORATION false

add_parameter CONSTANT_OUTPUT_OFFSET int 0
set_parameter_property CONSTANT_OUTPUT_OFFSET DISPLAY_NAME "Default output offset"
set_parameter_property CONSTANT_OUTPUT_OFFSET DESCRIPTION "Default output offset. Can be overwritten in runtime update of coefficients is enabled"
set_parameter_property CONSTANT_OUTPUT_OFFSET HDL_PARAMETER false
set_parameter_property CONSTANT_OUTPUT_OFFSET AFFECTS_ELABORATION false

add_parameter OUTPUT_GUARD_BANDS_ENABLE int 1
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE DISPLAY_NAME "Enable output guard bands"
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE ALLOWED_RANGES 0:1
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE DISPLAY_HINT boolean
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE DESCRIPTION "Enable to limit the output values to the specified range"
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE HDL_PARAMETER false
set_parameter_property OUTPUT_GUARD_BANDS_ENABLE AFFECTS_ELABORATION false

add_parameter OUTPUT_GUARD_BAND_LOWER int 0
set_parameter_property OUTPUT_GUARD_BAND_LOWER DISPLAY_NAME "Lower output guard band"
set_parameter_property OUTPUT_GUARD_BAND_LOWER DESCRIPTION "Lower output guard band"
set_parameter_property OUTPUT_GUARD_BAND_LOWER HDL_PARAMETER false
set_parameter_property OUTPUT_GUARD_BAND_LOWER AFFECTS_ELABORATION false

add_parameter OUTPUT_GUARD_BAND_UPPER int 15
set_parameter_property OUTPUT_GUARD_BAND_UPPER DISPLAY_NAME "Upper output guard band"
set_parameter_property OUTPUT_GUARD_BAND_UPPER DESCRIPTION "Upper output guard band"
set_parameter_property OUTPUT_GUARD_BAND_UPPER HDL_PARAMETER false
set_parameter_property OUTPUT_GUARD_BAND_UPPER AFFECTS_ELABORATION false

add_parameter LOAD_AT_RUNTIME int 0
set_parameter_property LOAD_AT_RUNTIME DISPLAY_NAME "Load scaler coefficients at runtime"
set_parameter_property LOAD_AT_RUNTIME ALLOWED_RANGES 0:1
set_parameter_property LOAD_AT_RUNTIME DISPLAY_HINT boolean
set_parameter_property LOAD_AT_RUNTIME DESCRIPTION "Allows the scaler coefficients for the bicubic and polyphase algorithms to be updated at runtime"
set_parameter_property LOAD_AT_RUNTIME HDL_PARAMETER false
set_parameter_property LOAD_AT_RUNTIME AFFECTS_ELABORATION true

add_parameter ENABLE_WIDE_BLUR_SHARPEN int 1
set_parameter_property ENABLE_WIDE_BLUR_SHARPEN DISPLAY_NAME "Blur search range"
set_parameter_property ENABLE_WIDE_BLUR_SHARPEN ALLOWED_RANGES {1 2 3}
set_parameter_property ENABLE_WIDE_BLUR_SHARPEN DESCRIPTION "Range of the blur edge detection (in pixels)"
set_parameter_property ENABLE_WIDE_BLUR_SHARPEN HDL_PARAMETER false
set_parameter_property ENABLE_WIDE_BLUR_SHARPEN AFFECTS_ELABORATION false

add_parameter RUNTIME_BLUR_THRESHOLD_CONTROL int 1
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL DISPLAY_NAME "Enable runtime control of blur thresholds"
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL DISPLAY_HINT boolean
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL DESCRIPTION "Allows the blur thresholds to be altered through the Control (Avalon-MM Slave) port"
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL HDL_PARAMETER false
set_parameter_property RUNTIME_BLUR_THRESHOLD_CONTROL AFFECTS_ELABORATION true

add_parameter LOWER_BLUR_LIM int 0
set_parameter_property LOWER_BLUR_LIM DISPLAY_NAME "Lower blur threshold"
set_parameter_property LOWER_BLUR_LIM DESCRIPTION "Lower limit on the difference between two pixels to class as a blurred edge (value per color plane)"
set_parameter_property LOWER_BLUR_LIM HDL_PARAMETER false
set_parameter_property LOWER_BLUR_LIM AFFECTS_ELABORATION true

add_parameter UPPER_BLUR_LIM int 15
set_parameter_property UPPER_BLUR_LIM DISPLAY_NAME "Upper blur threshold"
set_parameter_property UPPER_BLUR_LIM DESCRIPTION "Upper limit on the difference between two pixels to class as a blurred edge (value per color plane)"
set_parameter_property UPPER_BLUR_LIM HDL_PARAMETER false
set_parameter_property UPPER_BLUR_LIM AFFECTS_ELABORATION true

add_parameter EXTRA_PIPELINE_REG int 0
set_parameter_property EXTRA_PIPELINE_REG DISPLAY_NAME "Pipeline Data output"
set_parameter_property EXTRA_PIPELINE_REG ALLOWED_RANGES 0:1
set_parameter_property EXTRA_PIPELINE_REG DISPLAY_HINT boolean
set_parameter_property EXTRA_PIPELINE_REG DESCRIPTION "Adds an extra register stage to the Data output interface"
set_parameter_property EXTRA_PIPELINE_REG HDL_PARAMETER false

add_av_st_event_parameters

add_parameter DOUT_SRC_ADDRESS INTEGER 0
set_parameter_property DOUT_SRC_ADDRESS DISPLAY_NAME "Source address for Data output interface"
set_parameter_property DOUT_SRC_ADDRESS HDL_PARAMETER false

add_device_family_parameter
set_parameter_property FAMILY HDL_PARAMETER false

#need to set the HDL_PARAMETER property to false for parameters added by common functions
set_parameter_property NUMBER_OF_COLOR_PLANES HDL_PARAMETER false
set_parameter_property COLOR_PLANES_ARE_IN_PARALLEL HDL_PARAMETER false
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER false
set_parameter_property SRC_WIDTH HDL_PARAMETER false
set_parameter_property DST_WIDTH HDL_PARAMETER false
set_parameter_property CONTEXT_WIDTH HDL_PARAMETER false
set_parameter_property TASK_WIDTH HDL_PARAMETER false

# | connection point clock_reset

add_main_clock_port

# -- Dynamic Ports (elaboration callback) --
proc fir_alg_core_elaboration_callback {} {

    set src_id                      [get_parameter_value DOUT_SRC_ADDRESS]

    #setting up the command port
    set src_width                   [get_parameter_value SRC_WIDTH]
    set dst_width                   [get_parameter_value DST_WIDTH]
    set context_width               [get_parameter_value CONTEXT_WIDTH]
    set task_width                  [get_parameter_value TASK_WIDTH]
    add_av_st_cmd_sink_port   av_st_cmd   1   $dst_width   $src_width   $task_width   $context_width   main_clock   $src_id

    #setting up the data input port
    set bits_per_symbol             [get_parameter_value BITS_PER_SYMBOL]
    set symbols_per_pixel           [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set are_in_par                  [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    if {$are_in_par > 0} {
      set data_width [expr $bits_per_symbol * $symbols_per_pixel]
    } else {
      set data_width $bits_per_symbol
    }
    set din_width                   [expr $data_width * [get_parameter_value V_TAPS] ]
    add_av_st_data_sink_port   av_st_din   $din_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id


    #setting up the data output port
    add_av_st_data_source_port   av_st_dout   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id

    set use_coeff [get_parameter_value LOAD_AT_RUNTIME]
    if { $use_coeff > 0 } {
        set use_coeff [get_parameter_value ALGORITHM_NAME]
        if { [string compare $use_coeff STANDARD_FIR] == 0 } {
            set use_coeff 1
        } else {
            set use_coeff 0
        }
    }

    if { $use_coeff > 0 } {
        #working out the coefficient width
        set coeff_width [ expr [get_parameter_value COEFF_SIGNED] + [get_parameter_value COEFF_INTEGER_BITS] + [get_parameter_value COEFF_FRACTION_BITS] ]

        #setting up the coefficient input port
        add_av_st_data_sink_port   av_st_coeff   $coeff_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id
    }
}

# -- Generation callback --
proc fir_alg_core_generation_callback {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]

    set template_file [ file join $this_dir "alt_vip_fir_alg_core.v.terp" ]

    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    set alg_name [ get_parameter_value ALGORITHM_NAME ]
    set comp [string compare $alg_name "STANDARD_FIR"]
    if { $comp != 0 } {
        set load_at_runtime 0
        set edge_adapt_sharpen 1
        set runtime_blur_control [get_parameter_value RUNTIME_BLUR_THRESHOLD_CONTROL]
    } else {
        set load_at_runtime [get_parameter_value LOAD_AT_RUNTIME]
        set edge_adapt_sharpen 0
        set runtime_blur_control 0
    }


    #working out local parameters that define port widths in generated top level
    if { [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL] > 0 } {
      set din_width [expr [get_parameter_value BITS_PER_SYMBOL] * [get_parameter_value NUMBER_OF_COLOR_PLANES] ]
      set dout_width [expr [get_parameter_value BITS_PER_SYMBOL_OUT] * [get_parameter_value NUMBER_OF_COLOR_PLANES] ]
    } else {
      set din_width [get_parameter_value BITS_PER_SYMBOL]
      set dout_width [get_parameter_value BITS_PER_SYMBOL_OUT]
    }
    set din_width [expr $din_width * [get_parameter_value V_TAPS] ]

    set cmd_data_width [expr 32 + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]
    set din_data_width [expr $din_width + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]
    set dout_data_width [expr $dout_width + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]

    set coeff_width [expr [get_parameter_value COEFF_SIGNED] + [get_parameter_value COEFF_INTEGER_BITS] + [get_parameter_value COEFF_FRACTION_BITS] ]
    if { $load_at_runtime < 1 } {
        set coeff_data_width 1
    } else {
      set coeff_data_width [expr $coeff_width + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]
    }

    set family [get_parameter_value FAMILY]
    set cyclone_style 0
    set check [string match "*Cyclone*" $family]
    if { $check == 1 } {
      set check [string match "*Cyclone V*" $family]
      if { $check == 0 } {
         set cyclone_style 1
      }
    }

    set raw_round_name [ get_parameter_value ROUNDING_METHOD ]
    set round_name [format "%s%s%s" "\"" $raw_round_name "\""]

    #Collect parameter values for Terp
    set params(output_name)            $output_name
    set params(num_colours)            [ get_parameter_value NUMBER_OF_COLOR_PLANES ]
    set params(colours_are_in_par)     [ get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL ]
    set params(bits_per_symbol)        [ get_parameter_value BITS_PER_SYMBOL ]
    set params(is_422)                 [ get_parameter_value IS_422 ]
    set params(bits_per_symbol_out)    [ get_parameter_value BITS_PER_SYMBOL_OUT ]
    set params(move_binary_point_right) [ get_parameter_value MOVE_BINARY_POINT_RIGHT ]
    set params(enable_constant_offset) [ get_parameter_value ENABLE_CONSTANT_OUTPUT_OFFSET ]
    set params(contant_offset)         [ get_parameter_value CONSTANT_OUTPUT_OFFSET ]
    set params(round_name)             $round_name
    set params(max_width)              [ get_parameter_value MAX_WIDTH ]
    set params(edge_adapt_sharpen)     $edge_adapt_sharpen
    set params(partial_lines)          [ get_parameter_value PARTIAL_LINE_FILTERING ]
    set params(do_mirroring)           [ get_parameter_value DO_MIRRORING ]
    set params(left_mirror)            [ get_parameter_value LEFT_MIRROR ]
    set params(right_mirror)           [ get_parameter_value RIGHT_MIRROR ]
    set params(wide_blur_sharpen)      [ get_parameter_value ENABLE_WIDE_BLUR_SHARPEN ]
    set params(runtime_blur_control)   $runtime_blur_control
    set params(upper_blur_lim)         [ get_parameter_value UPPER_BLUR_LIM ]
    set params(lower_blur_lim)         [ get_parameter_value LOWER_BLUR_LIM ]
    set params(output_gaurd_bands)     [ get_parameter_value OUTPUT_GUARD_BANDS_ENABLE ]
    set params(guard_upper)            [ get_parameter_value OUTPUT_GUARD_BAND_UPPER ]
    set params(guard_lower)            [ get_parameter_value OUTPUT_GUARD_BAND_LOWER ]
    set params(h_taps)                 [ get_parameter_value H_TAPS ]
    set params(v_taps)                 [ get_parameter_value V_TAPS ]
    set params(coeff_signed)           [ get_parameter_value COEFF_SIGNED ]
    set params(coeff_int_bits)         [ get_parameter_value COEFF_INTEGER_BITS ]
    set params(coeff_frac_bits)        [ get_parameter_value COEFF_FRACTION_BITS ]
    set params(load_at_runtime)        [ get_parameter_value LOAD_AT_RUNTIME ]
    set params(v_symm)                 [ get_parameter_value V_SYMMETRIC ]
    set params(h_symm)                 [ get_parameter_value H_SYMMETRIC ]
    set params(d_symm)                 [ get_parameter_value DIAG_SYMMETRIC ]
    set params(cmd_src_width)          [ get_parameter_value SRC_WIDTH ]
    set params(cmd_dst_width)          [ get_parameter_value DST_WIDTH ]
    set params(cmd_pid_width)          [ get_parameter_value CONTEXT_WIDTH ]
    set params(cmd_eid_width)          [ get_parameter_value TASK_WIDTH ]
    set params(dout_src_addr)          [ get_parameter_value DOUT_SRC_ADDRESS ]
    set params(cyclone_style)          $cyclone_style
    set params(pipeline)               [ get_parameter_value EXTRA_PIPELINE_REG ]
    set params(cmd_data_width)         $cmd_data_width
    set params(din_data_width)         $din_data_width
    set params(dout_data_width)        $dout_data_width
    set params(coeff_data_width)       $coeff_data_width

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.v ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}

}

#validation callback
proc fir_alg_core_validation_callback {} {

    set limit [get_parameter_value SRC_WIDTH]
    set limit [expr {pow(2, $limit)}]
    set limit [expr {$limit - 1}]
    set value [get_parameter_value DOUT_SRC_ADDRESS]
    if { $value > $limit } {
          send_message Warning "Source address is outside the range supported by the specified dout source address width"
    }
    if { $value < 0 } {
          send_message Warning "Source address is outside the range supported by the specified dout source address width"
    }

    if { [get_parameter_value TASK_WIDTH] < 2 } {
          send_message Error "The Task ID width for the command port must be at least 1 bit"
    }

    if { [get_parameter_value IS_422] > 0 } {
        if { [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL] > 0 } {
           set symbols_in_seq 1
           set symbols_in_par [get_parameter_value NUMBER_OF_COLOR_PLANES]
        } else {
           set symbols_in_seq [get_parameter_value NUMBER_OF_COLOR_PLANES]
           set symbols_in_par 1
        }
        if { $symbols_in_seq > 1 } {
            send_message Error "4:2:2 data with more than one symbol in sequence is not currently supported"
        }
        if { $symbols_in_par < 2 } {
            send_message Error "4:2:2 data with fewer than 2 symbols in parallel is not supported"
        }
    }

    #there is lots of other validation that needs to be done

}
