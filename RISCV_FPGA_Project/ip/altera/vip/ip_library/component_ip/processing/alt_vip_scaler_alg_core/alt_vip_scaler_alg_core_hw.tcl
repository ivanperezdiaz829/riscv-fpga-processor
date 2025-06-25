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

# | module alt_vip_scaler_alg_core
set_module_property NAME alt_vip_scaler_alg_core
set_module_property DISPLAY_NAME "Scaler Algorithmic Core"
set_module_property DESCRIPTION "This block scales a line of video data using bilinear, bicubic or polyphase algorithms according
\to a scaling ratio defined through the Avalon-ST Message Command port"

set_module_property VALIDATION_CALLBACK scl_alg_core_validation_callback
set_module_property ELABORATION_CALLBACK scl_alg_core_elaboration_callback
set_module_property GENERATION_CALLBACK scl_alg_core_generation_callback
set_module_property HELPER_JAR scl_algo_core_helper.jar

# | files

add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_alt_vip_common_mult_add_files ../../..
add_alt_vip_common_h_kernel_files ../../..
add_alt_vip_common_mirror_files ../../..
add_alt_vip_common_edge_detect_chain_files ../../..
add_file src_hdl/alt_vip_scaler_alg_core_step_coeff.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_step_line.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_realign.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_controller.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_nn_channel.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_horizontal_channel.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_vertical_channel.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_edge_detect.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_bilinear_channel.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core_bilinear_coeffs.sv $add_file_attribute
add_file src_hdl/alt_vip_scaler_alg_core.sv $add_file_attribute

# | parameters
add_channels_nb_parameters
add_bits_per_symbol_parameters

add_parameter IS_422 int 1
set_parameter_property IS_422 DISPLAY_NAME "4:2:2 video data"
set_parameter_property IS_422 ALLOWED_RANGES 0:1
set_parameter_property IS_422 DISPLAY_HINT boolean
set_parameter_property IS_422 DESCRIPTION "Select for 4:2:2 video input/output"
set_parameter_property IS_422 HDL_PARAMETER false
set_parameter_property IS_422 AFFECTS_ELABORATION false

add_max_in_dim_parameters
set_parameter_property MAX_IN_WIDTH  HDL_PARAMETER false
set_parameter_property MAX_IN_HEIGHT VISIBLE       false
set_parameter_property MAX_IN_HEIGHT HDL_PARAMETER false
add_max_out_dim_parameters
set_parameter_property MAX_OUT_WIDTH  HDL_PARAMETER false
set_parameter_property MAX_OUT_HEIGHT VISIBLE       false
set_parameter_property MAX_OUT_HEIGHT HDL_PARAMETER false

add_parameter RUNTIME_CONTROL int 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime control of output frame size"
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT boolean
set_parameter_property RUNTIME_CONTROL DESCRIPTION "Allows the output frame dimensions to be altered through the Control (Avalon-MM Slave) port"
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER false
set_parameter_property RUNTIME_CONTROL AFFECTS_ELABORATION true

add_parameter ALGORITHM_NAME string POLYPHASE
set_parameter_property ALGORITHM_NAME DISPLAY_NAME "Scaling algorithm"
set_parameter_property ALGORITHM_NAME ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR BICUBIC POLYPHASE EDGE_ADAPT}
set_parameter_property ALGORITHM_NAME DISPLAY_HINT ""
set_parameter_property ALGORITHM_NAME DESCRIPTION "Selects the scaling alogithm used"
set_parameter_property ALGORITHM_NAME HDL_PARAMETER false
set_parameter_property ALGORITHM_NAME AFFECTS_ELABORATION true

add_parameter PARTIAL_LINE_SCALING INTEGER 0
set_parameter_property PARTIAL_LINE_SCALING DISPLAY_NAME "Include partial line scaling support"
set_parameter_property PARTIAL_LINE_SCALING ALLOWED_RANGES 0:1
set_parameter_property PARTIAL_LINE_SCALING DISPLAY_HINT boolean
set_parameter_property PARTIAL_LINE_SCALING DESCRIPTION "Select to include hardware to allow the scaling of partial video lines"
set_parameter_property PARTIAL_LINE_SCALING HDL_PARAMETER false
set_parameter_property PARTIAL_LINE_SCALING AFFECTS_ELABORATION false

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
set_parameter_property H_TAPS AFFECTS_ELABORATION true

add_parameter ARE_IDENTICAL int 0
set_parameter_property ARE_IDENTICAL DISPLAY_NAME "Share horizontal and vertical coefficients"
set_parameter_property ARE_IDENTICAL ALLOWED_RANGES 0:1
set_parameter_property ARE_IDENTICAL DISPLAY_HINT boolean
set_parameter_property ARE_IDENTICAL DESCRIPTION "Forces the bicubic and polyphase algorithms to use the same horizontal and vertical scaling coefficients"
set_parameter_property ARE_IDENTICAL HDL_PARAMETER false

add_parameter LOAD_AT_RUNTIME int 0
set_parameter_property LOAD_AT_RUNTIME DISPLAY_NAME "Load scaler coefficients at runtime"
set_parameter_property LOAD_AT_RUNTIME ALLOWED_RANGES 0:1
set_parameter_property LOAD_AT_RUNTIME DISPLAY_HINT boolean
set_parameter_property LOAD_AT_RUNTIME DESCRIPTION "Allows the scaler coefficients for the bicubic and polyphase algorithms to be updated at runtime"
set_parameter_property LOAD_AT_RUNTIME HDL_PARAMETER false
set_parameter_property LOAD_AT_RUNTIME AFFECTS_ELABORATION true

add_parameter V_PHASES int 16
set_parameter_property V_PHASES DISPLAY_NAME "Vertical filter phases"
set_parameter_property V_PHASES ALLOWED_RANGES 1:256
set_parameter_property V_PHASES DESCRIPTION "Number of vertical filter phases for the bicubic and polyphase algorithms"
set_parameter_property V_PHASES HDL_PARAMETER false

add_parameter H_PHASES int 16
set_parameter_property H_PHASES DISPLAY_NAME "Horizontal filter phases"
set_parameter_property H_PHASES ALLOWED_RANGES 1:256
set_parameter_property H_PHASES DESCRIPTION "Number of horizontal filter phases for the bicubic and polyphase algorithms"
set_parameter_property H_PHASES HDL_PARAMETER false

add_parameter V_SIGNED int 1
set_parameter_property V_SIGNED DISPLAY_NAME "Vertical coefficients signed"
set_parameter_property V_SIGNED ALLOWED_RANGES 0:1
set_parameter_property V_SIGNED DISPLAY_HINT boolean
set_parameter_property V_SIGNED DESCRIPTION "Forces the algorithm to use signed coefficient data"
set_parameter_property V_SIGNED HDL_PARAMETER false
set_parameter_property V_SIGNED AFFECTS_ELABORATION true

add_parameter V_INTEGER_BITS int 1
set_parameter_property V_INTEGER_BITS DISPLAY_NAME "Vertical coefficient integer bits"
set_parameter_property V_INTEGER_BITS ALLOWED_RANGES 0:32
set_parameter_property V_INTEGER_BITS DESCRIPTION "Number of integer bits for each vertical coefficient"
set_parameter_property V_INTEGER_BITS HDL_PARAMETER false
set_parameter_property V_INTEGER_BITS AFFECTS_ELABORATION true

add_parameter V_FRACTION_BITS int 7
set_parameter_property V_FRACTION_BITS DISPLAY_NAME "Vertical coefficient fraction bits"
set_parameter_property V_FRACTION_BITS ALLOWED_RANGES 1:32
set_parameter_property V_FRACTION_BITS DESCRIPTION "Number of fraction bits for each vertical coefficient"
set_parameter_property V_FRACTION_BITS HDL_PARAMETER false
set_parameter_property V_FRACTION_BITS AFFECTS_ELABORATION true

add_parameter H_SIGNED int 1
set_parameter_property H_SIGNED DISPLAY_NAME "Horizontal coefficients signed"
set_parameter_property H_SIGNED ALLOWED_RANGES 0:1
set_parameter_property H_SIGNED DISPLAY_HINT boolean
set_parameter_property H_SIGNED DESCRIPTION "Forces the algorithm to use signed coefficient data"
set_parameter_property H_SIGNED HDL_PARAMETER false

add_parameter H_INTEGER_BITS int 1
set_parameter_property H_INTEGER_BITS DISPLAY_NAME "Horizontal coefficient integer bits"
set_parameter_property H_INTEGER_BITS ALLOWED_RANGES 0:32
set_parameter_property H_INTEGER_BITS DESCRIPTION "Number of integer bits for each horizontal coefficient"
set_parameter_property H_INTEGER_BITS HDL_PARAMETER false

add_parameter H_FRACTION_BITS int 7
set_parameter_property H_FRACTION_BITS DISPLAY_NAME "Horizontal coefficient fraction bits"
set_parameter_property H_FRACTION_BITS ALLOWED_RANGES 1:32
set_parameter_property H_FRACTION_BITS DESCRIPTION "Number of fraction bits for each horizontal coefficient"
set_parameter_property H_FRACTION_BITS HDL_PARAMETER false

add_parameter H_KERNEL_BITS int 12
set_parameter_property H_KERNEL_BITS DISPLAY_NAME "Number of bits to preserve between horizontal and vertical filtering"
set_parameter_property H_KERNEL_BITS ALLOWED_RANGES 1:32
set_parameter_property H_KERNEL_BITS DESCRIPTION "Number of bits to preserve between horizontal and vertical filtering"
set_parameter_property H_KERNEL_BITS HDL_PARAMETER false
set_parameter_property H_KERNEL_BITS AFFECTS_ELABORATION false

add_parameter V_FUNCTION string LANCZOS_2
set_parameter_property V_FUNCTION DISPLAY_NAME "Vertical coefficient function"
set_parameter_property V_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 CUSTOM}
set_parameter_property V_FUNCTION DISPLAY_HINT ""
set_parameter_property V_FUNCTION DESCRIPTION "Selects the function used to generate the vertical scaling coefficients"
set_parameter_property V_FUNCTION HDL_PARAMETER false
set_parameter_property V_FUNCTION AFFECTS_ELABORATION true

add_parameter V_BANKS int 1
set_parameter_property V_BANKS DISPLAY_NAME "Vertical coefficient banks"
set_parameter_property V_BANKS ALLOWED_RANGES 1:32
set_parameter_property V_BANKS DESCRIPTION "Number of banks of vertical filter coefficients for the bicubic and polyphase algorithms"
set_parameter_property V_BANKS HDL_PARAMETER false

add_parameter V_SYMMETRIC int 0
set_parameter_property V_SYMMETRIC DISPLAY_NAME "Symmetrical vertical coefficients"
set_parameter_property V_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property V_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property V_SYMMETRIC DESCRIPTION "Forces the bicubic and polyphase algorithms to use the symmetrical vertical scaling coefficients"
set_parameter_property V_SYMMETRIC HDL_PARAMETER false

add_parameter V_COEFF_FILE string "<enter file name (including full path)>"
set_parameter_property V_COEFF_FILE DISPLAY_NAME "Vertical coefficients file"
set_parameter_property V_COEFF_FILE DESCRIPTION "Selects the file containing the coefficient data"
set_parameter_property V_COEFF_FILE HDL_PARAMETER false
set_parameter_property V_COEFF_FILE AFFECTS_ELABORATION true

add_parameter H_FUNCTION string LANCZOS_2
set_parameter_property H_FUNCTION DISPLAY_NAME "Horizontal coefficient function"
set_parameter_property H_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 CUSTOM}
set_parameter_property H_FUNCTION DISPLAY_HINT ""
set_parameter_property H_FUNCTION DESCRIPTION "Selects the function used to generate the horizontal scaling coefficients"
set_parameter_property H_FUNCTION HDL_PARAMETER false
set_parameter_property H_FUNCTION AFFECTS_ELABORATION true

add_parameter H_BANKS int 1
set_parameter_property H_BANKS DISPLAY_NAME "Horizontal coefficient banks"
set_parameter_property H_BANKS ALLOWED_RANGES 1:32
set_parameter_property H_BANKS DESCRIPTION "Number of banks of horizontal filter coefficients for the bicubic and polyphase algorithms"
set_parameter_property H_BANKS HDL_PARAMETER false

add_parameter H_SYMMETRIC int 0
set_parameter_property H_SYMMETRIC DISPLAY_NAME "Symmetrical horizontal coefficients"
set_parameter_property H_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property H_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property H_SYMMETRIC DESCRIPTION "Forces the bicubic and polyphase algorithms to use the symmetrical horizontal scaling coefficients"
set_parameter_property H_SYMMETRIC HDL_PARAMETER false

add_parameter H_COEFF_FILE string "<enter file name (including full path)>"
set_parameter_property H_COEFF_FILE DISPLAY_NAME "Horizontal coefficients file"
set_parameter_property H_COEFF_FILE DESCRIPTION "Selects the file containing the coefficient data"
set_parameter_property H_COEFF_FILE HDL_PARAMETER false
set_parameter_property H_COEFF_FILE AFFECTS_ELABORATION true

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

#SOPCB can't see global add_file_attribute inside the generation callback so use a parameter to get around this
add_parameter DUMMY_ADD_FILE_ATTRIBUTE string $add_file_attribute
set_parameter_property DUMMY_ADD_FILE_ATTRIBUTE HDL_PARAMETER false
set_parameter_property DUMMY_ADD_FILE_ATTRIBUTE VISIBLE false
set_parameter_property DUMMY_ADD_FILE_ATTRIBUTE DERIVED true

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
proc scl_alg_core_elaboration_callback {} {

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
        if { [string compare $use_coeff POLYPHASE] == 0 || [string compare $use_coeff EDGE_ADAPT] == 0 } {
            set use_coeff 1
        } else {
            set use_coeff 0
        }
    }

    if { $use_coeff > 0 } {
        #working out the max coefficient width
        if { [get_parameter_value ARE_IDENTICAL] > 0 } {
            set coeff_width [ expr [get_parameter_value V_SIGNED] + [get_parameter_value V_INTEGER_BITS] + [get_parameter_value V_FRACTION_BITS] ]
        } else {
            set coeff_width_v [ expr [get_parameter_value V_SIGNED] + [get_parameter_value V_INTEGER_BITS] + [get_parameter_value V_FRACTION_BITS] ]
            set coeff_width_h [ expr [get_parameter_value H_SIGNED] + [get_parameter_value H_INTEGER_BITS] + [get_parameter_value H_FRACTION_BITS] ]
            if { $coeff_width_v > $coeff_width_h } {
               set coeff_width $coeff_width_v
            } else {
               set coeff_width $coeff_width_h
            }
        }

        #setting up the coefficient input port
        add_av_st_data_sink_port   av_st_coeff   $coeff_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id
    }
}

# -- Generation callback --
proc scl_alg_core_generation_callback {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]

    set template_file [ file join $this_dir "alt_vip_scaler_alg_core.v.terp" ]

    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    set coeff_file_name "${output_name}_coeff.mif"
    set coeff_file_full_path [ file join $output_dir ${coeff_file_name} ]
    set coeff_file_formatted [format "%s%s%s" "\"" ${coeff_file_name} "\""]

    set alg_name [ get_parameter_value ALGORITHM_NAME ]
    if { [string compare $alg_name POLYPHASE] != 0 && [string compare $alg_name EDGE_ADAPT] != 0 } {
        set load_at_runtime 0
    } else {
        set load_at_runtime [get_parameter_value LOAD_AT_RUNTIME]
    }
    set raw_alg_name $alg_name
    set alg_name [format "%s%s%s" "\"" $alg_name "\""]


    #working out local parameters that define port widths in generated top level
    if { [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL] > 0 } {
      set data_width [expr [get_parameter_value BITS_PER_SYMBOL] * [get_parameter_value NUMBER_OF_COLOR_PLANES] ]
    } else {
      set data_width [get_parameter_value BITS_PER_SYMBOL]
    }
    set din_width [expr $data_width * [get_parameter_value V_TAPS] ]

    set cmd_data_width [expr 32 + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]
    set din_data_width [expr $din_width + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]
    set dout_data_width [expr $data_width + [get_parameter_value SRC_WIDTH] + [get_parameter_value DST_WIDTH] + [get_parameter_value CONTEXT_WIDTH] + [get_parameter_value TASK_WIDTH] ]

    set h_coeff_width [expr [get_parameter_value H_SIGNED] + [get_parameter_value H_INTEGER_BITS] + [get_parameter_value H_FRACTION_BITS] ]
    set v_coeff_width [expr [get_parameter_value V_SIGNED] + [get_parameter_value V_INTEGER_BITS] + [get_parameter_value V_FRACTION_BITS] ]
    if { [get_parameter_value ARE_IDENTICAL] > 0 } {
        set coeff_width $v_coeff_width
    } else {
        if { $v_coeff_width > $h_coeff_width } {
            set coeff_width $v_coeff_width
        } else {
            set coeff_width $h_coeff_width
        }
    }
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

    #Collect parameter values for Terp
    set params(output_name)         $output_name
    set params(num_colours)         [ get_parameter_value NUMBER_OF_COLOR_PLANES ]
    set params(colours_are_in_par)  [ get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL ]
    set params(bits_per_symbol)     [ get_parameter_value BITS_PER_SYMBOL ]
    set params(is_422)              [ get_parameter_value IS_422 ]
    set params(max_in_width)        [ get_parameter_value MAX_IN_WIDTH ]
    set params(max_out_width)       [ get_parameter_value MAX_OUT_WIDTH ]
    set params(algorithm)           $alg_name
    set params(partial_lines)       [ get_parameter_value PARTIAL_LINE_SCALING ]
    set params(left_mirror)         [ get_parameter_value LEFT_MIRROR ]
    set params(right_mirror)        [ get_parameter_value RIGHT_MIRROR ]
    set params(raw_algorithm_name)  $raw_alg_name
    set params(h_taps)              [ get_parameter_value H_TAPS ]
    set params(v_taps)              [ get_parameter_value V_TAPS ]
    set params(h_phases)            [ get_parameter_value H_PHASES ]
    set params(v_phases)            [ get_parameter_value V_PHASES ]
    set params(v_signed)            [ get_parameter_value V_SIGNED ]
    set params(v_int_bits)          [ get_parameter_value V_INTEGER_BITS ]
    set params(v_frac_bits)         [ get_parameter_value V_FRACTION_BITS ]
    set params(h_signed)            [ get_parameter_value H_SIGNED ]
    set params(h_int_bits)          [ get_parameter_value H_INTEGER_BITS ]
    set params(h_frac_bits)         [ get_parameter_value H_FRACTION_BITS ]
    set params(h_kernel_bits)       [ get_parameter_value H_KERNEL_BITS ]
    set params(load_at_runtime)     $load_at_runtime
    set params(runtime_control)     [ get_parameter_value RUNTIME_CONTROL ]
    set params(coeffs_shared)       [ get_parameter_value ARE_IDENTICAL ]
    set params(v_banks)             [ get_parameter_value V_BANKS ]
    set params(v_symmetric)         [ get_parameter_value V_SYMMETRIC ]
    set params(h_banks)             [ get_parameter_value H_BANKS ]
    set params(h_symmetric)         [ get_parameter_value H_SYMMETRIC ]
    set params(cmd_src_width)       [ get_parameter_value SRC_WIDTH ]
    set params(cmd_dst_width)       [ get_parameter_value DST_WIDTH ]
    set params(cmd_pid_width)       [ get_parameter_value CONTEXT_WIDTH ]
    set params(cmd_eid_width)       [ get_parameter_value TASK_WIDTH ]
    set params(dout_src_addr)       [ get_parameter_value DOUT_SRC_ADDRESS ]
    set params(coeff_file)          $coeff_file_formatted
    set params(cyclone_style)       $cyclone_style
    set params(pipeline)            [ get_parameter_value EXTRA_PIPELINE_REG ]
    set params(cmd_data_width)      $cmd_data_width
    set params(din_data_width)      $din_data_width
    set params(dout_data_width)     $dout_data_width
    set params(coeff_data_width)    $coeff_data_width

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.v ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    #SOPCB can't see global add_file_attribute inside the generation callback so use a parameter to get around this
    set file_attrib [get_parameter_value DUMMY_ADD_FILE_ATTRIBUTE]

    add_file ${output_file} {SYNTHESIS SIMULATION}

    #need to add java helper to generate MIF file for coefficients

    set algo_name [get_parameter_value ALGORITHM_NAME]
    set runtime_load [get_parameter_value LOAD_AT_RUNTIME]

    # compile time loading
    if { $runtime_load == 0 } {
        if { [string compare $algo_name POLYPHASE] == 0 || [string compare $algo_name BICUBIC] == 0 } {

            set gen_log "${output_name}_coeff_generation.log"
            set log_file_full_path [ file join $output_dir ${gen_log} ]

            set jar_arg "COEFF_FILE_NAME=${coeff_file_name}"
            append jar_arg ",OUTPUT_DIR=${output_dir}"
            append jar_arg ",ALGO_NAME=${algo_name}"
            append jar_arg ",V_FUNCTION=[get_parameter_value V_FUNCTION]"
            append jar_arg ",V_BANKS=[get_parameter_value V_BANKS]"
            append jar_arg ",V_SYMMETRIC=[get_parameter_value V_SYMMETRIC]"
            append jar_arg ",V_PHASES=[get_parameter_value V_PHASES]"
            append jar_arg ",V_FRACTION_BITS=[get_parameter_value V_FRACTION_BITS]"
            append jar_arg ",V_INTEGER_BITS=[get_parameter_value V_INTEGER_BITS]"
            append jar_arg ",V_TAPS=[get_parameter_value V_TAPS]"
            append jar_arg ",V_SIGNED=[get_parameter_value V_SIGNED]"
            append jar_arg ",V_COEFF_FILE=[get_parameter_value V_COEFF_FILE]"
            append jar_arg ",H_FUNCTION=[get_parameter_value H_FUNCTION]"
            append jar_arg ",H_BANKS=[get_parameter_value H_BANKS]"
            append jar_arg ",H_SYMMETRIC=[get_parameter_value H_SYMMETRIC]"
            append jar_arg ",H_PHASES=[get_parameter_value H_PHASES]"
            append jar_arg ",H_FRACTION_BITS=[get_parameter_value H_FRACTION_BITS]"
            append jar_arg ",H_INTEGER_BITS=[get_parameter_value H_INTEGER_BITS]"
            append jar_arg ",H_KERNEL_BITS=[get_parameter_value H_KERNEL_BITS]"
            append jar_arg ",H_TAPS=[get_parameter_value H_TAPS]"
            append jar_arg ",H_SIGNED=[get_parameter_value H_SIGNED]"
            append jar_arg ",H_COEFF_FILE=[get_parameter_value H_COEFF_FILE]"
            append jar_arg ",ARE_IDENTICAL=[get_parameter_value ARE_IDENTICAL]"
            append jar_arg ",LOG_FILE_NAME=${gen_log}"

            call_helper generateCoeff $jar_arg

            if {[file exists $coeff_file_full_path]} {
                add_file $coeff_file_full_path {SYNTHESIS SIMULATION}
            } else {
                send_message Warning "Coefficient MIF file (${coeff_file_name}) for ${output_name} is not generated."
            }

            if {[file exists $log_file_full_path]} {
                add_file $log_file_full_path {SYNTHESIS SIMULATION}
            }
        }
    }
}

#validation callback
proc scl_alg_core_validation_callback {} {

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

    if { [get_parameter_value TASK_WIDTH] < 1 } {
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

    # Check if the CSV file specified exists

    set runtime_load [get_parameter_value LOAD_AT_RUNTIME]
    set algo_name [get_parameter_value ALGORITHM_NAME]
    set v_function [get_parameter_value V_FUNCTION]
    set h_function [get_parameter_value H_FUNCTION]

    if { $runtime_load == 0 && [string compare $algo_name POLYPHASE] == 0 } {
        if {[string compare $v_function CUSTOM] == 0} {
            #check for csv file
            set csv_file_path [get_parameter_value V_COEFF_FILE]

            if {[string compare $csv_file_path ""] == 0 || [string compare $csv_file_path "<enter file name (including full path)>"] == 0} {
                send_message ERROR "Please specify a valid vertical coefficients file (including full path)."
            } else {
                if {![file exists $csv_file_path]} {
                    send_message WARNING "${csv_file_path} could not be opened for reading. No such file."
                }
            }
        }
        if {[string compare $h_function CUSTOM] == 0} {
            #check for csv file
            set csv_file_path [get_parameter_value H_COEFF_FILE]

             if {[string compare $csv_file_path ""] == 0 || [string compare $csv_file_path "<enter file name (including full path)>"] == 0} {
                send_message ERROR "Please specify a valid horizontal coefficients file (including full path)."
            } else {
                if {![file exists $csv_file_path]} {
                    send_message WARNING "${csv_file_path} could not be opened for reading. No such file."
                }
            }
        }
    }
}
