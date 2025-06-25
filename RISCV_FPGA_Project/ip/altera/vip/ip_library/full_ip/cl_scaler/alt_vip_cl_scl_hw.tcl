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


# --------------------------------------------------------------------------------------------------
#--                                                                                               --
#-- _hw.tcl compose file for Component Library Scaler (Scaler 2)                                  --
#--                                                                                               --
#---------------------------------------------------------------------------------------------------

source ../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl

declare_general_module_info
set_module_property NAME alt_vip_cl_scl
set_module_property DISPLAY_NAME "Scaler II - Edge Adaptive"
set_module_property DESCRIPTION "The Scaler II up-scales or down-scales video fields using nearest neighbour, biliner, bicubic, polyphase or edge adaptive algorithms."

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Validation callback to check legality of parameter set
set_module_property VALIDATION_CALLBACK scl_validation_callback

# Callback for the composition of this component
set_module_property COMPOSE_CALLBACK scl_composition_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

set x_min 20
set x_max 4096
set y_min 20
set y_max 4096

add_device_family_parameter

add_parameter SYMBOLS_IN_SEQ int 1
set_parameter_property SYMBOLS_IN_SEQ DISPLAY_NAME "Symbols in sequence"
set_parameter_property SYMBOLS_IN_SEQ ALLOWED_RANGES 1:4
set_parameter_property SYMBOLS_IN_SEQ DESCRIPTION "Number of Avalon-ST symbols in sequence"
set_parameter_property SYMBOLS_IN_SEQ HDL_PARAMETER true
set_parameter_property SYMBOLS_IN_SEQ AFFECTS_ELABORATION true

add_parameter SYMBOLS_IN_PAR int 2
set_parameter_property SYMBOLS_IN_PAR DISPLAY_NAME "Symbols in parallel"
set_parameter_property SYMBOLS_IN_PAR ALLOWED_RANGES 1:4
set_parameter_property SYMBOLS_IN_PAR DESCRIPTION "Number of Avalon-ST symbols in parallel"
set_parameter_property SYMBOLS_IN_PAR HDL_PARAMETER true
set_parameter_property SYMBOLS_IN_PAR AFFECTS_ELABORATION true

add_parameter BITS_PER_SYMBOL int 10
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 4:20
set_parameter_property BITS_PER_SYMBOL DESCRIPTION "The number of bits per Avalon-ST symbol"
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true
set_parameter_property BITS_PER_SYMBOL AFFECTS_ELABORATION true

add_parameter EXTRA_PIPELINING int 0
set_parameter_property EXTRA_PIPELINING DISPLAY_NAME "Add extra pipelining registers"
set_parameter_property EXTRA_PIPELINING ALLOWED_RANGES 0:1
set_parameter_property EXTRA_PIPELINING DISPLAY_HINT boolean
set_parameter_property EXTRA_PIPELINING DESCRIPTION "Selecting this option adds extra pipeline stage registers to the data path. This option may be required to acheive 150MHz operation on Cyclone III/IV devices, and frequencies above 250MHz for Arria II and Stratix IV/V devices. Note that these are rough estimates for guidance only."
set_parameter_property EXTRA_PIPELINING HDL_PARAMETER true
set_parameter_property EXTRA_PIPELINING AFFECTS_ELABORATION true

add_parameter IS_422 int 1
set_parameter_property IS_422 DISPLAY_NAME "4:2:2 video data"
set_parameter_property IS_422 ALLOWED_RANGES 0:1
set_parameter_property IS_422 DISPLAY_HINT boolean
set_parameter_property IS_422 DESCRIPTION "Select for 4:2:2 video input/output"
set_parameter_property IS_422 HDL_PARAMETER true
set_parameter_property IS_422 AFFECTS_ELABORATION true

add_parameter NO_BLANKING int 0
set_parameter_property NO_BLANKING DISPLAY_NAME "No blanking in video"
set_parameter_property NO_BLANKING ALLOWED_RANGES 0:1
set_parameter_property NO_BLANKING DISPLAY_HINT boolean
set_parameter_property NO_BLANKING DESCRIPTION "Optimises the scaler for video with no blanking"
set_parameter_property NO_BLANKING HDL_PARAMETER true
set_parameter_property NO_BLANKING AFFECTS_ELABORATION true

add_max_in_dim_parameters
set_parameter_property MAX_IN_WIDTH   DEFAULT_VALUE       1920
set_parameter_property MAX_IN_WIDTH   ENABLED             true
set_parameter_property MAX_IN_WIDTH   AFFECTS_ELABORATION true
set_parameter_property MAX_IN_HEIGHT  DEFAULT_VALUE       1080
set_parameter_property MAX_IN_HEIGHT  ENABLED             true
set_parameter_property MAX_IN_HEIGHT  AFFECTS_ELABORATION true
add_max_out_dim_parameters
set_parameter_property MAX_OUT_WIDTH  DEFAULT_VALUE       1920
set_parameter_property MAX_OUT_WIDTH  ENABLED             true
set_parameter_property MAX_OUT_WIDTH  AFFECTS_ELABORATION true
set_parameter_property MAX_OUT_HEIGHT DEFAULT_VALUE       1080
set_parameter_property MAX_OUT_HEIGHT ENABLED             true
set_parameter_property MAX_OUT_HEIGHT AFFECTS_ELABORATION true

add_parameter RUNTIME_CONTROL int 1
set_parameter_property RUNTIME_CONTROL DISPLAY_NAME "Enable runtime control of output frame size and edge/blur thresholds"
set_parameter_property RUNTIME_CONTROL ALLOWED_RANGES 0:1
set_parameter_property RUNTIME_CONTROL DISPLAY_HINT boolean
set_parameter_property RUNTIME_CONTROL DESCRIPTION "Allows the output frame dimensions and edge/blur thresholds to be altered through the Control (Avalon-MM Slave) port. If this option is not selected the output dimensions are fixed to the maximum values and edge/blur values are fixed to their default values"
set_parameter_property RUNTIME_CONTROL HDL_PARAMETER true
set_parameter_property RUNTIME_CONTROL AFFECTS_ELABORATION true

add_parameter ALWAYS_DOWNSCALE int 0
set_parameter_property ALWAYS_DOWNSCALE DISPLAY_NAME "Always downscale or pass-through"
set_parameter_property ALWAYS_DOWNSCALE ALLOWED_RANGES 0:1
set_parameter_property ALWAYS_DOWNSCALE DISPLAY_HINT boolean
set_parameter_property ALWAYS_DOWNSCALE DESCRIPTION "Specifies that the input frame will never be upscaled to produce the output (downscale or pass-through only). If the user selects this option and runtime input/output resolutions result in an upscale the core will not crash but the output video will be corrupted"
set_parameter_property ALWAYS_DOWNSCALE HDL_PARAMETER true
set_parameter_property ALWAYS_DOWNSCALE AFFECTS_ELABORATION true

add_parameter ALGORITHM_NAME string POLYPHASE
set_parameter_property ALGORITHM_NAME DISPLAY_NAME "Scaling algorithm"
set_parameter_property ALGORITHM_NAME ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR BICUBIC POLYPHASE EDGE_ADAPT}
set_parameter_property ALGORITHM_NAME DISPLAY_HINT ""
set_parameter_property ALGORITHM_NAME DESCRIPTION "Selects the scaling algorithm used"
set_parameter_property ALGORITHM_NAME HDL_PARAMETER true
set_parameter_property ALGORITHM_NAME AFFECTS_ELABORATION true

add_parameter DEFAULT_EDGE_THRESH INTEGER 7
set_parameter_property DEFAULT_EDGE_THRESH DISPLAY_NAME "Default edge threshold"
set_parameter_property DEFAULT_EDGE_THRESH DESCRIPTION "Default edge threshold when comparing two pixels (per color plane) for edge adaptive scaling. Can be updated at runtime if runtime control is enabled"
set_parameter_property DEFAULT_EDGE_THRESH AFFECTS_ELABORATION true
set_parameter_property DEFAULT_EDGE_THRESH HDL_PARAMETER true

add_parameter DEFAULT_UPPER_BLUR INTEGER 15
set_parameter_property DEFAULT_UPPER_BLUR DISPLAY_NAME "Default upper blur limit (per color plane)"
set_parameter_property DEFAULT_UPPER_BLUR DESCRIPTION "Default lower blur limit (per color plane) used for edge adaptive sharpening. Can be updated at runtime if runtime control is enabled"
set_parameter_property DEFAULT_UPPER_BLUR AFFECTS_ELABORATION true
set_parameter_property DEFAULT_UPPER_BLUR HDL_PARAMETER true

add_parameter DEFAULT_LOWER_BLUR INTEGER 0
set_parameter_property DEFAULT_LOWER_BLUR DISPLAY_NAME "Default lower blur limit (per color plane)"
set_parameter_property DEFAULT_LOWER_BLUR DESCRIPTION "Default lower blur limit (per color plane) used for edge adaptive sharpening. Can be updated at runtime if runtime control is enabled"
set_parameter_property DEFAULT_LOWER_BLUR AFFECTS_ELABORATION true
set_parameter_property DEFAULT_LOWER_BLUR HDL_PARAMETER true

add_parameter ENABLE_FIR int 0
set_parameter_property ENABLE_FIR DISPLAY_NAME "Enable post scaling sharpen"
set_parameter_property ENABLE_FIR ALLOWED_RANGES 0:1
set_parameter_property ENABLE_FIR DISPLAY_HINT boolean
set_parameter_property ENABLE_FIR DESCRIPTION "Select to add an edge adaptive sharpening filter"
set_parameter_property ENABLE_FIR HDL_PARAMETER true
set_parameter_property ENABLE_FIR AFFECTS_ELABORATION true

add_parameter ARE_IDENTICAL int 0
set_parameter_property ARE_IDENTICAL DISPLAY_NAME "Share horizontal and vertical coefficients"
set_parameter_property ARE_IDENTICAL ALLOWED_RANGES 0:1
set_parameter_property ARE_IDENTICAL DISPLAY_HINT boolean
set_parameter_property ARE_IDENTICAL DESCRIPTION "Forces the bicubic and polyphase algorithms to use the same horizontal and vertical scaling coefficients"
set_parameter_property ARE_IDENTICAL HDL_PARAMETER true
set_parameter_property ARE_IDENTICAL AFFECTS_ELABORATION true

add_parameter V_TAPS int 8
set_parameter_property V_TAPS DISPLAY_NAME "Vertical filter taps"
set_parameter_property V_TAPS ALLOWED_RANGES 4:64
set_parameter_property V_TAPS DESCRIPTION "Number of vertical filter taps for the bicubic and polyphase algorithms"
set_parameter_property V_TAPS HDL_PARAMETER true
set_parameter_property V_TAPS AFFECTS_ELABORATION true

add_parameter V_PHASES int 16
set_parameter_property V_PHASES DISPLAY_NAME "Vertical filter phases"
set_parameter_property V_PHASES ALLOWED_RANGES {1 2 4 8 16 32 64 128 256}
set_parameter_property V_PHASES DESCRIPTION "Number of vertical filter phases for the bicubic and polyphase algorithms"
set_parameter_property V_PHASES HDL_PARAMETER true
set_parameter_property V_PHASES AFFECTS_ELABORATION true

add_parameter H_TAPS int 8
set_parameter_property H_TAPS DISPLAY_NAME "Horizontal filter taps"
set_parameter_property H_TAPS ALLOWED_RANGES 4:64
set_parameter_property H_TAPS DESCRIPTION "Number of horizontal filter taps for the bicubic and polyphase algorithms"
set_parameter_property H_TAPS HDL_PARAMETER true
set_parameter_property H_TAPS AFFECTS_ELABORATION true

add_parameter H_PHASES int 16
set_parameter_property H_PHASES DISPLAY_NAME "Horizontal filter phases"
set_parameter_property H_PHASES ALLOWED_RANGES {1 2 4 8 16 32 64 128 256}
set_parameter_property H_PHASES DESCRIPTION "Number of horizontal filter phases for the bicubic and polyphase algorithms"
set_parameter_property H_PHASES HDL_PARAMETER true
set_parameter_property H_PHASES AFFECTS_ELABORATION true

add_parameter V_SIGNED int 1
set_parameter_property V_SIGNED DISPLAY_NAME "Vertical coefficients signed"
set_parameter_property V_SIGNED ALLOWED_RANGES 0:1
set_parameter_property V_SIGNED DISPLAY_HINT boolean
set_parameter_property V_SIGNED DESCRIPTION "Forces the algorithm to use signed coefficient data"
set_parameter_property V_SIGNED HDL_PARAMETER true
set_parameter_property V_SIGNED AFFECTS_ELABORATION true

add_parameter V_INTEGER_BITS int 1
set_parameter_property V_INTEGER_BITS DISPLAY_NAME "Vertical coefficient integer bits"
set_parameter_property V_INTEGER_BITS ALLOWED_RANGES 1:32
set_parameter_property V_INTEGER_BITS DESCRIPTION "Number of integer bits for each vertical coefficient"
set_parameter_property V_INTEGER_BITS HDL_PARAMETER true
set_parameter_property V_INTEGER_BITS AFFECTS_ELABORATION true

add_parameter V_FRACTION_BITS int 7
set_parameter_property V_FRACTION_BITS DISPLAY_NAME "Vertical coefficient fraction bits"
set_parameter_property V_FRACTION_BITS ALLOWED_RANGES 1:32
set_parameter_property V_FRACTION_BITS DESCRIPTION "Number of fraction bits for each vertical coefficient"
set_parameter_property V_FRACTION_BITS HDL_PARAMETER true
set_parameter_property V_FRACTION_BITS AFFECTS_ELABORATION true

add_parameter H_SIGNED int 1
set_parameter_property H_SIGNED DISPLAY_NAME "Horizontal coefficients signed"
set_parameter_property H_SIGNED ALLOWED_RANGES 0:1
set_parameter_property H_SIGNED DISPLAY_HINT boolean
set_parameter_property H_SIGNED DESCRIPTION "Forces the algorithm to use signed coefficient data"
set_parameter_property H_SIGNED HDL_PARAMETER true
set_parameter_property H_SIGNED AFFECTS_ELABORATION true

add_parameter H_INTEGER_BITS int 1
set_parameter_property H_INTEGER_BITS DISPLAY_NAME "Horizontal coefficient integer bits"
set_parameter_property H_INTEGER_BITS ALLOWED_RANGES 1:32
set_parameter_property H_INTEGER_BITS DESCRIPTION "Number of integer bits for each horizontal coefficient"
set_parameter_property H_INTEGER_BITS HDL_PARAMETER true
set_parameter_property H_INTEGER_BITS AFFECTS_ELABORATION true

add_parameter H_FRACTION_BITS int 7
set_parameter_property H_FRACTION_BITS DISPLAY_NAME "Horizontal coefficient fraction bits"
set_parameter_property H_FRACTION_BITS ALLOWED_RANGES 1:32
set_parameter_property H_FRACTION_BITS DESCRIPTION "Number of fraction bits for each horizontal coefficient"
set_parameter_property H_FRACTION_BITS HDL_PARAMETER true
set_parameter_property H_FRACTION_BITS AFFECTS_ELABORATION true

add_parameter PRESERVE_BITS int 0
set_parameter_property PRESERVE_BITS DISPLAY_NAME "Fractional bits preserved"
set_parameter_property PRESERVE_BITS ALLOWED_RANGES 0:32
set_parameter_property PRESERVE_BITS DESCRIPTION "Number of fractional bits to preserve between horizontal and vertical filtering (bicubic/polyphase only)"
set_parameter_property PRESERVE_BITS HDL_PARAMETER true
set_parameter_property PRESERVE_BITS AFFECTS_ELABORATION true

add_parameter LOAD_AT_RUNTIME int 0
set_parameter_property LOAD_AT_RUNTIME DISPLAY_NAME "Load scaler coefficients at runtime"
set_parameter_property LOAD_AT_RUNTIME ALLOWED_RANGES 0:1
set_parameter_property LOAD_AT_RUNTIME DISPLAY_HINT boolean
set_parameter_property LOAD_AT_RUNTIME DESCRIPTION "Allows the scaler coefficients for the polyphase algorithms to be updated at runtime"
set_parameter_property LOAD_AT_RUNTIME HDL_PARAMETER true
set_parameter_property LOAD_AT_RUNTIME AFFECTS_ELABORATION true

add_parameter V_BANKS int 1
set_parameter_property V_BANKS DISPLAY_NAME "Vertical coefficient banks"
set_parameter_property V_BANKS ALLOWED_RANGES 1:32
set_parameter_property V_BANKS DESCRIPTION "Number of banks of vertical filter coefficients for the polyphase algorithms"
set_parameter_property V_BANKS HDL_PARAMETER true
set_parameter_property V_BANKS AFFECTS_ELABORATION true

add_parameter V_SYMMETRIC int 0
set_parameter_property V_SYMMETRIC DISPLAY_NAME "Symmetrical vertical coefficients"
set_parameter_property V_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property V_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property V_SYMMETRIC DESCRIPTION "Forces the bicubic and polyphase algorithms to use the symmetrical vertical scaling coefficients"
set_parameter_property V_SYMMETRIC HDL_PARAMETER true
set_parameter_property V_SYMMETRIC AFFECTS_ELABORATION true
set_parameter_property V_SYMMETRIC VISIBLE false

add_parameter V_FUNCTION string LANCZOS_2
set_parameter_property V_FUNCTION DISPLAY_NAME "Vertical coefficient function"
set_parameter_property V_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 CUSTOM}
set_parameter_property V_FUNCTION DISPLAY_HINT ""
set_parameter_property V_FUNCTION DESCRIPTION "Selects the function used to generate the vertical scaling coefficients"
set_parameter_property V_FUNCTION HDL_PARAMETER true
set_parameter_property V_FUNCTION AFFECTS_ELABORATION true

add_parameter V_COEFF_FILE string "<enter file name (including full path)>"
set_parameter_property V_COEFF_FILE DISPLAY_NAME "Vertical coefficients file"
set_parameter_property V_COEFF_FILE DESCRIPTION "Selects the file containing the vertical coefficient data"
set_parameter_property V_COEFF_FILE HDL_PARAMETER true
set_parameter_property V_COEFF_FILE AFFECTS_ELABORATION true

add_parameter H_BANKS int 1
set_parameter_property H_BANKS DISPLAY_NAME "Horizontal coefficient banks"
set_parameter_property H_BANKS ALLOWED_RANGES 1:32
set_parameter_property H_BANKS DESCRIPTION "Number of banks of horizontal filter coefficients for the polyphase algorithms"
set_parameter_property H_BANKS HDL_PARAMETER true
set_parameter_property H_BANKS AFFECTS_ELABORATION true

add_parameter H_SYMMETRIC int 0
set_parameter_property H_SYMMETRIC DISPLAY_NAME "Symmetrical horizontal coefficients"
set_parameter_property H_SYMMETRIC ALLOWED_RANGES 0:1
set_parameter_property H_SYMMETRIC DISPLAY_HINT boolean
set_parameter_property H_SYMMETRIC DESCRIPTION "Forces the bicubic and polyphase algorithms to use the symmetrical horizontal scaling coefficients"
set_parameter_property H_SYMMETRIC HDL_PARAMETER true
set_parameter_property H_SYMMETRIC AFFECTS_ELABORATION true
set_parameter_property H_SYMMETRIC VISIBLE false

add_parameter H_FUNCTION string LANCZOS_2
set_parameter_property H_FUNCTION DISPLAY_NAME "Horizontal coefficient function"
set_parameter_property H_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 CUSTOM}
set_parameter_property H_FUNCTION DISPLAY_HINT ""
set_parameter_property H_FUNCTION DESCRIPTION "Selects the function used to generate the horizontal scaling coefficients"
set_parameter_property H_FUNCTION HDL_PARAMETER true
set_parameter_property H_FUNCTION AFFECTS_ELABORATION true

add_parameter H_COEFF_FILE string "<enter file name (including full path)>"
set_parameter_property H_COEFF_FILE DISPLAY_NAME "Horizontal coefficients file"
set_parameter_property H_COEFF_FILE DESCRIPTION "Selects the file containing the horizontal coefficient data"
set_parameter_property H_COEFF_FILE HDL_PARAMETER true
set_parameter_property H_COEFF_FILE AFFECTS_ELABORATION true

#just here for software model purposes. No hardware support
add_parameter IS_420 int 0
set_parameter_property IS_420 ALLOWED_RANGES 0:1
set_parameter_property IS_420 HDL_PARAMETER true
set_parameter_property IS_420 AFFECTS_ELABORATION false
set_parameter_property IS_420 VISIBLE false

add_display_item "Video Data Format" BITS_PER_SYMBOL parameter
add_display_item "Video Data Format" SYMBOLS_IN_PAR parameter
add_display_item "Video Data Format" SYMBOLS_IN_SEQ parameter
add_display_item "Video Data Format" RUNTIME_CONTROL parameter
add_display_item "Video Data Format" MAX_IN_WIDTH parameter
add_display_item "Video Data Format" MAX_IN_HEIGHT parameter
add_display_item "Video Data Format" MAX_OUT_WIDTH parameter
add_display_item "Video Data Format" MAX_OUT_HEIGHT parameter
add_display_item "Video Data Format" IS_422 parameter
add_display_item "Video Data Format" NO_BLANKING parameter

add_display_item "Algorithm Settings" ALGORITHM_NAME parameter
add_display_item "Algorithm Settings" ENABLE_FIR parameter
add_display_item "Algorithm Settings" ALWAYS_DOWNSCALE parameter
add_display_item "Algorithm Settings" ARE_IDENTICAL parameter
add_display_item "Algorithm Settings" V_TAPS parameter
add_display_item "Algorithm Settings" V_PHASES parameter
add_display_item "Algorithm Settings" H_TAPS parameter
add_display_item "Algorithm Settings" H_PHASES parameter
add_display_item "Algorithm Settings" DEFAULT_EDGE_THRESH parameter
add_display_item "Algorithm Settings" DEFAULT_UPPER_BLUR parameter
add_display_item "Algorithm Settings" DEFAULT_LOWER_BLUR parameter

add_display_item "Precision Settings" V_SIGNED parameter
add_display_item "Precision Settings" V_INTEGER_BITS parameter
add_display_item "Precision Settings" V_FRACTION_BITS parameter
add_display_item "Precision Settings" H_SIGNED parameter
add_display_item "Precision Settings" H_INTEGER_BITS parameter
add_display_item "Precision Settings" H_FRACTION_BITS parameter
add_display_item "Precision Settings" PRESERVE_BITS parameter

add_display_item "Coefficient Settings" LOAD_AT_RUNTIME parameter
add_display_item "Coefficient Settings" V_BANKS parameter
add_display_item "Coefficient Settings" V_SYMMETRIC parameter
add_display_item "Coefficient Settings" V_FUNCTION parameter
add_display_item "Coefficient Settings" V_COEFF_FILE parameter
add_display_item "Coefficient Settings" H_BANKS parameter
add_display_item "Coefficient Settings" H_SYMMETRIC parameter
add_display_item "Coefficient Settings" H_FUNCTION parameter
add_display_item "Coefficient Settings" H_COEFF_FILE parameter

add_display_item "Pipelining" EXTRA_PIPELINING parameter



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static components                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# The chain of components to compose :
add_instance   video_in             alt_vip_video_input_bridge     $isVersion
add_instance   user_packet_demux    alt_vip_packet_demux           $isVersion
add_instance   line_buffer          alt_vip_line_buffer            $isVersion
add_instance   scaler_core          alt_vip_scaler_alg_core        $isVersion
add_instance   user_packet_mux      alt_vip_packet_mux             $isVersion
add_instance   video_out            alt_vip_video_output_bridge    $isVersion
add_instance   scheduler            alt_vip_scaler_scheduler       $isVersion
add_instance   kernel_creator       alt_vip_scaler_kernel_creator  $isVersion
add_instance   av_st_clk_bridge     altera_clock_bridge            $acdsVersion
add_instance   av_st_reset_bridge   altera_reset_bridge            $acdsVersion

# Top level interfaces :
add_interface   main_clock   clock              end
add_interface   main_reset   reset              end
add_interface   din          avalon_streaming   sink
add_interface   dout         avalon_streaming   source

set_interface_property   main_clock   export_of   av_st_clk_bridge.in_clk
set_interface_property   main_reset   export_of   av_st_reset_bridge.in_reset
set_interface_property   din          export_of   video_in.av_st_vid_din
set_interface_property   dout         export_of   video_out.av_st_vid_dout

set_interface_property main_clock PORT_NAME_MAP {main_clock in_clk}
set_interface_property main_reset PORT_NAME_MAP {main_reset in_reset}

#parameter settings that don't change for input video bridge
set_instance_parameter_value   video_in   NUMBER_OF_PIXELS_IN_PARALLEL   1
set_instance_parameter_value   video_in   VIDEO_PROTOCOL_NO              1
set_instance_parameter_value   video_in   SRC_WIDTH                      8
set_instance_parameter_value   video_in   DST_WIDTH                      8
set_instance_parameter_value   video_in   CONTEXT_WIDTH                  8
set_instance_parameter_value   video_in   TASK_WIDTH                     8
set_instance_parameter_value   video_in   RESP_SRC_ADDRESS               0
set_instance_parameter_value   video_in   RESP_DST_ADDRESS               0
set_instance_parameter_value   video_in   DATA_SRC_ADDRESS               0

#parameter settings that don't change for demux
set_instance_parameter_value   user_packet_demux   SRC_WIDTH                     8
set_instance_parameter_value   user_packet_demux   DST_WIDTH                     8
set_instance_parameter_value   user_packet_demux   CONTEXT_WIDTH                 8
set_instance_parameter_value   user_packet_demux   TASK_WIDTH                    8
set_instance_parameter_value   user_packet_demux   USER_WIDTH                    0
set_instance_parameter_value   user_packet_demux   NUM_OUTPUTS                   2
set_instance_parameter_value   user_packet_demux   CLIP_ADDRESS_BITS             0
set_instance_parameter_value   user_packet_demux   REGISTER_OUTPUT               1

#parameter settings that don't change for the line buffer
set_instance_parameter_value   line_buffer   OUTPUT_PORTS            1
set_instance_parameter_value   line_buffer   MODE                    LOCKED
set_instance_parameter_value   line_buffer   ENABLE_RECEIVE_ONLY_CMD 0
set_instance_parameter_value   line_buffer   FIFO_SIZE               1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_1           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_2           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_3           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_4           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_5           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_6           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_7           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_8           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_9           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_A           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_B           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_C           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_D           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_E           1
set_instance_parameter_value   line_buffer   KERNEL_SIZE_F           1
set_instance_parameter_value   line_buffer   KERNEL_START_1          0
set_instance_parameter_value   line_buffer   KERNEL_START_2          0
set_instance_parameter_value   line_buffer   KERNEL_START_3          0
set_instance_parameter_value   line_buffer   KERNEL_START_4          0
set_instance_parameter_value   line_buffer   KERNEL_START_5          0
set_instance_parameter_value   line_buffer   KERNEL_START_6          0
set_instance_parameter_value   line_buffer   KERNEL_START_7          0
set_instance_parameter_value   line_buffer   KERNEL_START_8          0
set_instance_parameter_value   line_buffer   KERNEL_START_9          0
set_instance_parameter_value   line_buffer   KERNEL_START_A          0
set_instance_parameter_value   line_buffer   KERNEL_START_B          0
set_instance_parameter_value   line_buffer   KERNEL_START_C          0
set_instance_parameter_value   line_buffer   KERNEL_START_D          0
set_instance_parameter_value   line_buffer   KERNEL_START_E          0
set_instance_parameter_value   line_buffer   KERNEL_START_F          0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_1         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_2         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_3         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_4         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_5         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_6         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_7         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_8         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_9         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_A         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_B         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_C         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_D         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_E         0
set_instance_parameter_value   line_buffer   KERNEL_CENTER_F         0
set_instance_parameter_value   line_buffer   SRC_WIDTH               8
set_instance_parameter_value   line_buffer   DST_WIDTH               8
set_instance_parameter_value   line_buffer   CONTEXT_WIDTH           8
set_instance_parameter_value   line_buffer   TASK_WIDTH              8
set_instance_parameter_value   line_buffer   SOURCE_ADDRESS          0

#parameter settings that don't change for the scaler core
set_instance_parameter_value   scaler_core   SRC_WIDTH              8
set_instance_parameter_value   scaler_core   DST_WIDTH              8
set_instance_parameter_value   scaler_core   CONTEXT_WIDTH          8
set_instance_parameter_value   scaler_core   TASK_WIDTH             8
set_instance_parameter_value   scaler_core   EXTRA_PIPELINE_REG     1
set_instance_parameter_value   scaler_core   PARTIAL_LINE_SCALING   0
set_instance_parameter_value   scaler_core   LEFT_MIRROR            1
set_instance_parameter_value   scaler_core   RIGHT_MIRROR           1

#parameter settings that don't change for the user_packet_mux
set_instance_parameter_value   user_packet_mux   SRC_WIDTH              8
set_instance_parameter_value   user_packet_mux   DST_WIDTH              8
set_instance_parameter_value   user_packet_mux   CONTEXT_WIDTH          8
set_instance_parameter_value   user_packet_mux   TASK_WIDTH             8
set_instance_parameter_value   user_packet_mux   USER_WIDTH             0
set_instance_parameter_value   user_packet_mux   NUM_INPUTS             2

#parameter settings that don't for output video bridge
set_instance_parameter_value   video_out   NUMBER_OF_PIXELS_IN_PARALLEL   1
set_instance_parameter_value   video_out   VIDEO_PROTOCOL_NO              1
set_instance_parameter_value   video_out   SRC_WIDTH                      8
set_instance_parameter_value   video_out   DST_WIDTH                      8
set_instance_parameter_value   video_out   CONTEXT_WIDTH                  8
set_instance_parameter_value   video_out   TASK_WIDTH                     8

#parameter settings that don't change for the kernel_creator
set_instance_parameter_value   kernel_creator   NUMBER_OF_FRAMES       1
set_instance_parameter_value   kernel_creator   SRC_WIDTH              8
set_instance_parameter_value   kernel_creator   DST_WIDTH              8
set_instance_parameter_value   kernel_creator   CONTEXT_WIDTH          8
set_instance_parameter_value   kernel_creator   TASK_WIDTH             8
set_instance_parameter_value   kernel_creator   EXTRA_PIPELINE_REG     0

# Av-ST Clock connections :
add_connection   av_st_clk_bridge.out_clk   av_st_reset_bridge.clk
add_connection   av_st_clk_bridge.out_clk   video_in.main_clock
add_connection   av_st_clk_bridge.out_clk   user_packet_demux.main_clock
add_connection   av_st_clk_bridge.out_clk   line_buffer.main_clock
add_connection   av_st_clk_bridge.out_clk   scaler_core.main_clock
add_connection   av_st_clk_bridge.out_clk   user_packet_mux.main_clock
add_connection   av_st_clk_bridge.out_clk   video_out.main_clock
add_connection   av_st_clk_bridge.out_clk   scheduler.main_clock
add_connection   av_st_clk_bridge.out_clk   kernel_creator.main_clock

# Av-ST Reset connections :
add_connection   av_st_reset_bridge.out_reset   video_in.main_reset
add_connection   av_st_reset_bridge.out_reset   user_packet_demux.main_reset
add_connection   av_st_reset_bridge.out_reset   line_buffer.main_reset
add_connection   av_st_reset_bridge.out_reset   scaler_core.main_reset
add_connection   av_st_reset_bridge.out_reset   user_packet_mux.main_reset
add_connection   av_st_reset_bridge.out_reset   video_out.main_reset
add_connection   av_st_reset_bridge.out_reset   scheduler.main_reset
add_connection   av_st_reset_bridge.out_reset   kernel_creator.main_reset

# Datapath connections
add_connection   video_in.av_st_dout              user_packet_demux.av_st_din
add_connection   user_packet_demux.av_st_dout_1   user_packet_mux.av_st_din_1
add_connection   user_packet_demux.av_st_dout_0   line_buffer.av_st_din
add_connection   line_buffer.av_st_dout_0         scaler_core.av_st_din
add_connection   user_packet_mux.av_st_dout       video_out.av_st_din

# Scheduler/command connections
add_connection   scheduler.av_st_cmd_0          video_in.av_st_cmd
add_connection   scheduler.av_st_cmd_1          line_buffer.av_st_cmd
add_connection   scheduler.av_st_cmd_3          scaler_core.av_st_cmd
add_connection   scheduler.av_st_cmd_2          kernel_creator.av_st_cmd
add_connection   video_in.av_st_resp            scheduler.av_st_resp_0
add_connection   kernel_creator.av_st_resp      scheduler.av_st_resp_1


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Validation callback                                                                          --
# -- Checking the legality of the parameter set chosen by the user                                --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc scl_validation_callback {} {
      set symbols_in_seq [get_parameter_value SYMBOLS_IN_SEQ]
      set symbols_in_par [get_parameter_value SYMBOLS_IN_PAR]
      set is_422 [get_parameter_value IS_422]
      set family [get_parameter_value FAMILY]


      if { $is_422 > 0 } {
         if { $symbols_in_par == 1 } {
            send_message error "There must be at least 2 color planes in parallel for the 4:2:2 data configuration"
         }
         if { $symbols_in_seq > 1 } {
            send_message error "Symbols in sequence is not yet supported for 4:2:2 data"
         }
      }

      if { $symbols_in_seq > 1 } {
         if { $symbols_in_par > 1 } {
            send_message error "The symbols for each pixel must be transmitted either entirely in sequence or entirely in parallel"
         }
      }

      if { [get_parameter_value ARE_IDENTICAL] > 0 } {
         send_message info "Vertical coefficient parameters (number of phases, precison parameters, etc.) will be used for the shared coefficients"
         set algorithm_name [get_parameter_value ALGORITHM_NAME ]
         set comp [string compare $algorithm_name "POLYPHASE"]
         if { $comp == 0 } {
            if { [get_parameter_value LOAD_AT_RUNTIME] > 0 } {
               set coeff_width [expr [get_parameter_value V_FRACTION_BITS] + [get_parameter_value V_INTEGER_BITS] + [get_parameter_value V_SIGNED] ]
               if { $coeff_width > 32 } {
                  send_message error "Total vertical coefficient width (fraction bits + integer bits + optional sign bit) must not exceed 32 bits with runtime loaded coefficients"
               }
            }
         }
      } else {
         set algorithm_name [get_parameter_value ALGORITHM_NAME ]
         set comp [string compare $algorithm_name "POLYPHASE"]
         if { $comp == 0 } {
            if { [get_parameter_value LOAD_AT_RUNTIME] > 0 } {
               set v_coeff_width [expr [get_parameter_value V_FRACTION_BITS] + [get_parameter_value V_INTEGER_BITS] + [get_parameter_value V_SIGNED] ]
               if { $v_coeff_width > 32 } {
                  send_message error "Total vertical coefficient width (fraction bits + integer bits + optional sign bit) must not exceed 32 bits with runtime loaded coefficients"
               }
               set h_coeff_width [expr [get_parameter_value H_FRACTION_BITS] + [get_parameter_value H_INTEGER_BITS] + [get_parameter_value H_SIGNED] ]
               if { $h_coeff_width > 32 } {
                  send_message error "Total horizontal coefficient width (fraction bits + integer bits + optional sign bit) must not exceed 32 bits with runtime loaded coefficients"
               }
            }
         }
      }

      set comp [string compare $algorithm_name "EDGE_ADAPT"]
      if { $comp == 0 } {
         if { [get_parameter_value LOAD_AT_RUNTIME] == 0 } {
            send_message error "Only runtime loading of coefficients is currently supported for Edge Adaptive mode"
         }
      }

      set limit [get_parameter_value BITS_PER_SYMBOL]
      set limit [expr {pow(2, $limit)}]
      set limit [expr {$limit - 1}]
      set value [get_parameter_value DEFAULT_EDGE_THRESH]
      if { $value > $limit } {
             send_message Warning "Default edge threshold is outside the range supported by the specified bits per symbol"
      }
      if { $value < 0 } {
             send_message Warning "Default edge threshold must be a positive integer"
      }
      set value [get_parameter_value DEFAULT_LOWER_BLUR]
      if { $value > $limit } {
             send_message Warning "Default lower blur limit is outside the range supported by the specified bits per symbol"
      }
      if { $value < 0 } {
             send_message Warning "Default lower blur limit must be a positive integer"
      }
      set value [get_parameter_value DEFAULT_UPPER_BLUR]
      if { $value > $limit } {
             send_message Warning "Default upper blur limit is outside the range supported by the specified bits per symbol"
      }
      if { $value < 0 } {
             send_message Warning "Default upper blur limit must be a positive integer"
      }

}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Composition callback                                                                        --
# -- Chaining the components, wiring up the clocks and exposing external interfaces               --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc scl_composition_callback {} {
   global isVersion

   if { [get_parameter_value SYMBOLS_IN_SEQ] > 1 } {
      set colours_in_par 0
   } else {
      set colours_in_par 1
   }

   set number_of_colours [expr { [get_parameter_value SYMBOLS_IN_SEQ] * [get_parameter_value SYMBOLS_IN_PAR] } ]

   set_parameter_property H_TAPS ENABLED false
   set_parameter_property V_TAPS ENABLED false
   set_parameter_property H_PHASES ENABLED false
   set_parameter_property V_PHASES ENABLED false
   set_parameter_property ARE_IDENTICAL ENABLED false
   set_parameter_property V_SIGNED ENABLED false
   set_parameter_property V_INTEGER_BITS ENABLED false
   set_parameter_property V_FRACTION_BITS ENABLED false
   set_parameter_property H_SIGNED ENABLED false
   set_parameter_property H_INTEGER_BITS ENABLED false
   set_parameter_property H_FRACTION_BITS ENABLED false
   set_parameter_property PRESERVE_BITS ENABLED false
   set_parameter_property LOAD_AT_RUNTIME ENABLED false
   set_parameter_property V_BANKS ENABLED false
   set_parameter_property V_SYMMETRIC ENABLED false
   set_parameter_property V_FUNCTION ENABLED false
   set_parameter_property V_COEFF_FILE ENABLED false
   set_parameter_property H_BANKS ENABLED false
   set_parameter_property H_SYMMETRIC ENABLED false
   set_parameter_property H_FUNCTION ENABLED false
   set_parameter_property H_COEFF_FILE ENABLED false
   set_parameter_property DEFAULT_EDGE_THRESH ENABLED false
   set_parameter_property DEFAULT_LOWER_BLUR ENABLED false
   set_parameter_property DEFAULT_UPPER_BLUR ENABLED false
   set v_signed 0
   set h_signed 0
   set v_integer_bits 0
   set h_integer_bits 0
   set h_frac_bits 1
   set runtime_load 0
   set h_banks 1
   set v_banks 1
   set v_taps 1
   set h_taps 1
   set h_phases 1
   set frac_bits_h 1
   set frac_bits_w 1
   set algorithm_name [get_parameter_value ALGORITHM_NAME ]
   set comp [string compare $algorithm_name "NEAREST_NEIGHBOUR"]
   if { $comp != 0 } {
      set_parameter_property V_FRACTION_BITS ENABLED true
      set comp [string compare $algorithm_name "BILINEAR"]
      if { $comp == 0 } {
         set_parameter_property H_FRACTION_BITS ENABLED true
         set h_frac_bits [get_parameter_value H_FRACTION_BITS ]
         set v_taps 2
         set h_taps 2
         set frac_bits_h [get_parameter_value V_FRACTION_BITS]
         set frac_bits_w [get_parameter_value H_FRACTION_BITS]
      } else {
         set_parameter_property ARE_IDENTICAL ENABLED true
         set_parameter_property V_PHASES ENABLED true
         set_parameter_property PRESERVE_BITS ENABLED true
         if { [get_parameter_value ARE_IDENTICAL] > 0 } {
            set frac_bits_w [clogb2_pure [get_parameter_value V_PHASES] ]
            set h_phases [get_parameter_value V_PHASES]
            set h_frac_bits [get_parameter_value V_FRACTION_BITS ]
         } else {
            set_parameter_property H_PHASES ENABLED true
            set_parameter_property H_FRACTION_BITS ENABLED true
            set h_frac_bits [get_parameter_value H_FRACTION_BITS ]
            set frac_bits_w [clogb2_pure [get_parameter_value H_PHASES] ]
            set h_phases [get_parameter_value H_PHASES]
         }
         set v_signed 1
         set h_signed 1
         set v_integer_bits 1
         set h_integer_bits 1
         set frac_bits_h [clogb2_pure [get_parameter_value V_PHASES] ]
         set comp [string compare $algorithm_name "BICUBIC"]
         if { $comp == 0 } {
            set v_taps 4
            set h_taps 4
         } else {
            set comp [string compare $algorithm_name "EDGE_ADAPT"]
            if { $comp == 0 } {
               set_parameter_property DEFAULT_EDGE_THRESH ENABLED true
            }
            set_parameter_property LOAD_AT_RUNTIME ENABLED true
            set_parameter_property V_TAPS ENABLED true
            set v_taps [get_parameter_value V_TAPS]
            set h_taps $v_taps
            if { [get_parameter_value LOAD_AT_RUNTIME] > 0 } {
               set_parameter_property V_SIGNED ENABLED true
               set_parameter_property V_INTEGER_BITS ENABLED true
               set v_signed [get_parameter_value V_SIGNED]
               set v_integer_bits [get_parameter_value V_INTEGER_BITS]
               set h_signed $v_signed
               set h_integer_bits $v_integer_bits
               set_parameter_property V_BANKS ENABLED true
               set_parameter_property V_SYMMETRIC ENABLED true
               set runtime_load 1
               set v_banks [get_parameter_value V_BANKS]
               if { [get_parameter_value ARE_IDENTICAL] > 0 } {
                  set h_banks $v_banks
               }
            } else {
               set_parameter_property V_FUNCTION ENABLED true
               set match [string compare [get_parameter_value V_FUNCTION] CUSTOM]
               if { $match == 0 } {
                  set_parameter_property V_COEFF_FILE ENABLED true
                  set_parameter_property V_SYMMETRIC ENABLED true
                  set_parameter_property V_SIGNED ENABLED true
                  set_parameter_property V_INTEGER_BITS ENABLED true
                  set v_signed [get_parameter_value V_SIGNED]
                  set v_integer_bits [get_parameter_value V_INTEGER_BITS]
                  set h_signed $v_signed
                  set h_integer_bits $v_integer_bits
               }
            }
            if { [get_parameter_value ARE_IDENTICAL] == 0 } {
               set_parameter_property H_TAPS ENABLED true
               set h_taps [get_parameter_value H_TAPS]
               if { [get_parameter_value LOAD_AT_RUNTIME] > 0 } {
                  set_parameter_property H_BANKS ENABLED true
                  set_parameter_property H_SYMMETRIC ENABLED true
                  set h_banks [get_parameter_value H_BANKS]
                  set_parameter_property H_SIGNED ENABLED true
                  set_parameter_property H_INTEGER_BITS ENABLED true
                  set h_signed [get_parameter_value H_SIGNED]
                  set h_integer_bits [get_parameter_value H_INTEGER_BITS]
               } else {
                  set_parameter_property H_FUNCTION ENABLED true
                  set match [string compare [get_parameter_value H_FUNCTION] CUSTOM]
                  if { $match == 0 } {
                     set_parameter_property H_COEFF_FILE ENABLED true
                     set_parameter_property H_SYMMETRIC ENABLED true
                     set_parameter_property H_SIGNED ENABLED true
                     set_parameter_property H_INTEGER_BITS ENABLED true
                     set h_signed [get_parameter_value H_SIGNED]
                     set h_integer_bits [get_parameter_value H_INTEGER_BITS]
                  }
               }
            }
         }
      }
   }

   if { [get_parameter_value ENABLE_FIR] > 0 } {
      set_parameter_property DEFAULT_LOWER_BLUR ENABLED true
      set_parameter_property DEFAULT_UPPER_BLUR ENABLED true
   }

   set always_down_pass 0
   if { [get_parameter_value ALWAYS_DOWNSCALE] > 0 } {
      set output_mux_sel NEW
      set always_down_pass 1
   } else {
      set output_mux_sel VARIABLE
   }
   set fixed_size 0

   set bits_per_symbol [get_parameter_value BITS_PER_SYMBOL]
   set preserve_bits [get_parameter_value PRESERVE_BITS]
   if { $preserve_bits > [get_parameter_value V_FRACTION_BITS] } {
      set preserve_bits [get_parameter_value V_FRACTION_BITS]
   }
   set kernel_bits [ expr {$bits_per_symbol + $v_signed + $v_integer_bits + $preserve_bits} ]
   set num_par_symbols [get_parameter_value SYMBOLS_IN_PAR]
   set video_data_width [ expr $bits_per_symbol * $num_par_symbols ]

   #parameterise the input video bridge
   set_instance_parameter_value   video_in   BITS_PER_SYMBOL               [get_parameter_value BITS_PER_SYMBOL]
   set_instance_parameter_value   video_in   NUMBER_OF_COLOR_PLANES        $number_of_colours
   set_instance_parameter_value   video_in   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par
   set_instance_parameter_value   video_in   DEFAULT_LINE_LENGTH           [get_parameter_value MAX_IN_WIDTH]

   #parameterise the user_packet_demux
   set_instance_parameter_value   user_packet_demux   DATA_WIDTH                    $video_data_width
   set_instance_parameter_value   user_packet_demux   PIPELINE_READY                [get_parameter_value EXTRA_PIPELINING]

   #parameterise the line buffer
   set_instance_parameter_value   line_buffer   DATA_WIDTH                    $video_data_width
   set_instance_parameter_value   line_buffer   SYMBOLS_IN_SEQ                [get_parameter_value SYMBOLS_IN_SEQ]
   set_instance_parameter_value   line_buffer   KERNEL_SIZE_0                 $v_taps
   set_instance_parameter_value   line_buffer   KERNEL_CENTER_0               [expr int(floor(($v_taps-1) / 2))]
   set_instance_parameter_value   line_buffer   MAX_LINE_LENGTH               [get_parameter_value MAX_IN_WIDTH]
   set_instance_parameter_value   line_buffer   OUTPUT_MUX_SEL                $output_mux_sel
   if {[get_parameter_value EXTRA_PIPELINING] > 0} {
      set_instance_parameter_value   line_buffer   OUTPUT_OPTION     PIPELINED
   } else {
      set_instance_parameter_value   line_buffer   OUTPUT_OPTION     UNPIPELINED
   }

   #parameterise the scaler core
   set_instance_parameter_value   scaler_core   NUMBER_OF_COLOR_PLANES        $number_of_colours
   set_instance_parameter_value   scaler_core   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par
   set_instance_parameter_value   scaler_core   BITS_PER_SYMBOL       [get_parameter_value BITS_PER_SYMBOL]
   set_instance_parameter_value   scaler_core   IS_422                [get_parameter_value IS_422]
   set_instance_parameter_value   scaler_core   MAX_IN_WIDTH          [get_parameter_value MAX_IN_WIDTH]
   set_instance_parameter_value   scaler_core   MAX_OUT_WIDTH         [get_parameter_value MAX_OUT_WIDTH]
   set_instance_parameter_value   scaler_core   ALGORITHM_NAME        [get_parameter_value ALGORITHM_NAME]
   set_instance_parameter_value   scaler_core   H_PHASES              [get_parameter_value H_PHASES]
   set_instance_parameter_value   scaler_core   V_PHASES              [get_parameter_value V_PHASES]
   set_instance_parameter_value   scaler_core   H_FRACTION_BITS       $h_frac_bits
   set_instance_parameter_value   scaler_core   V_FRACTION_BITS       [get_parameter_value V_FRACTION_BITS]
   set_instance_parameter_value   scaler_core   RUNTIME_CONTROL       [get_parameter_value RUNTIME_CONTROL]
   set_instance_parameter_value   scaler_core   ARE_IDENTICAL         [get_parameter_value ARE_IDENTICAL]
   set_instance_parameter_value   scaler_core   H_SYMMETRIC           [get_parameter_value H_SYMMETRIC]
   set_instance_parameter_value   scaler_core   V_SYMMETRIC           [get_parameter_value V_SYMMETRIC]
   set_instance_parameter_value   scaler_core   H_TAPS                $h_taps
   set_instance_parameter_value   scaler_core   V_TAPS                $v_taps
   set_instance_parameter_value   scaler_core   H_SIGNED              $h_signed
   set_instance_parameter_value   scaler_core   V_SIGNED              $v_signed
   set_instance_parameter_value   scaler_core   H_INTEGER_BITS        $h_integer_bits
   set_instance_parameter_value   scaler_core   V_INTEGER_BITS        $v_integer_bits
   set_instance_parameter_value   scaler_core   H_KERNEL_BITS         $kernel_bits
   set_instance_parameter_value   scaler_core   LOAD_AT_RUNTIME       $runtime_load
   set_instance_parameter_value   scaler_core   H_BANKS               $h_banks
   set_instance_parameter_value   scaler_core   V_BANKS               $v_banks
   set_instance_parameter_value   scaler_core   H_COEFF_FILE          [get_parameter_value H_COEFF_FILE]
   set_instance_parameter_value   scaler_core   V_COEFF_FILE          [get_parameter_value V_COEFF_FILE]
   set_instance_parameter_value   scaler_core   H_FUNCTION            [get_parameter_value H_FUNCTION]
   set_instance_parameter_value   scaler_core   V_FUNCTION            [get_parameter_value V_FUNCTION]

   #parameterise the user_packet_mux
   set_instance_parameter_value   user_packet_mux   DATA_WIDTH                    $video_data_width
   set_instance_parameter_value   user_packet_mux   REGISTER_OUTPUT               [get_parameter_value EXTRA_PIPELINING]
   set_instance_parameter_value   user_packet_mux   PIPELINE_READY                [get_parameter_value EXTRA_PIPELINING]

   #parameterise the output video bridge
   set_instance_parameter_value   video_out   BITS_PER_SYMBOL               [get_parameter_value BITS_PER_SYMBOL]
   set_instance_parameter_value   video_out   NUMBER_OF_COLOR_PLANES        $number_of_colours
   set_instance_parameter_value   video_out   COLOR_PLANES_ARE_IN_PARALLEL  $colours_in_par

   #parameterise the kernel_creator
   set_instance_parameter_value   kernel_creator   ALGORITHM        [get_parameter_value ALGORITHM_NAME]
   set_instance_parameter_value   kernel_creator   FRAC_BITS_H      $frac_bits_h
   set_instance_parameter_value   kernel_creator   FRAC_BITS_W      $frac_bits_w
   set_instance_parameter_value   kernel_creator   FIXED_SIZE       $fixed_size
   set_instance_parameter_value   kernel_creator   MAX_IN_HEIGHT    [get_parameter_value MAX_IN_HEIGHT]
   set_instance_parameter_value   kernel_creator   MAX_OUT_HEIGHT   [get_parameter_value MAX_OUT_HEIGHT]
   set_instance_parameter_value   kernel_creator   MAX_IN_WIDTH     [get_parameter_value MAX_IN_WIDTH]
   set_instance_parameter_value   kernel_creator   MAX_OUT_WIDTH    [get_parameter_value MAX_OUT_WIDTH]

   set algorithm_name [get_parameter_value ALGORITHM_NAME ]
   set comp [string compare $algorithm_name "EDGE_ADAPT"]
   if { $comp == 0 } {
      set edge_adapt 1
   } else {
      set edge_adapt 0
   }

   #parameterise the scheduler
   set_instance_parameter_value   scheduler   ALGORITHM                 [get_parameter_value ALGORITHM_NAME]
   set_instance_parameter_value   scheduler   ENABLE_FIR                [get_parameter_value ENABLE_FIR]
   set_instance_parameter_value   scheduler   ENABLE_EDGE_ADAPT_COEFFS  $edge_adapt
   set_instance_parameter_value   scheduler   DEFAULT_EDGE_THRESH       [get_parameter_value DEFAULT_EDGE_THRESH]
   set_instance_parameter_value   scheduler   MAX_IN_HEIGHT             [get_parameter_value MAX_IN_HEIGHT]
   set_instance_parameter_value   scheduler   MAX_OUT_HEIGHT            [get_parameter_value MAX_OUT_HEIGHT]
   set_instance_parameter_value   scheduler   MAX_IN_WIDTH              [get_parameter_value MAX_IN_WIDTH]
   set_instance_parameter_value   scheduler   MAX_OUT_WIDTH             [get_parameter_value MAX_OUT_WIDTH]
   set_instance_parameter_value   scheduler   RUNTIME_CONTROL           [get_parameter_value RUNTIME_CONTROL]
   set_instance_parameter_value   scheduler   LOAD_AT_RUNTIME           $runtime_load
   set_instance_parameter_value   scheduler   H_BANKS                   $h_banks
   set_instance_parameter_value   scheduler   V_BANKS                   $v_banks
   set_instance_parameter_value   scheduler   H_PHASE_WIDTH             $frac_bits_w
   set_instance_parameter_value   scheduler   V_PHASE_WIDTH             $frac_bits_h
   set_instance_parameter_value   scheduler   V_TAPS                    $v_taps
   set_instance_parameter_value   scheduler   H_TAPS                    $h_taps
   set_instance_parameter_value   scheduler   NO_BLANKING               [get_parameter_value NO_BLANKING]
   set_instance_parameter_value   scheduler   ENCODER_PIPELINE_STAGE    [get_parameter_value EXTRA_PIPELINING]

   #add the control slave if required
   set slave_needed 0
   if  { [get_parameter_value RUNTIME_CONTROL] > 0 } {
      set slave_needed 1
   }
   if { $runtime_load > 0 } {
      set slave_needed 1
   }
   if { $slave_needed > 0 } {
      add_instance   control_slave   alt_vip_control_slave $isVersion
      add_connection   av_st_clk_bridge.out_clk       control_slave.main_clock
      add_connection   av_st_reset_bridge.out_reset   control_slave.main_reset
      add_connection   scheduler.av_st_cmd_5          control_slave.av_st_cmd
      add_connection   control_slave.av_st_resp       scheduler.av_st_resp_2

      add_interface   control    avalon   slave
      set_interface_property   control   export_of   control_slave.av_mm_control

      set v_tap_width [expr {$v_integer_bits + [get_parameter_value V_FRACTION_BITS] + $v_signed}]
      set h_tap_width [expr {$h_integer_bits + $h_frac_bits + $h_signed}]
      if { $v_tap_width > $h_tap_width } {
         set max_tap_width $v_tap_width
      } else {
         set max_tap_width $h_tap_width
      }
      set cs_reg_bytes 1
      set control_reg   5
      set command_reg   0
      set max_taps		0
      if { $runtime_load > 0 } {
         set control_reg   9
         set command_reg   2
         if { $max_tap_width > 8 } {
            if { $max_tap_width > 16 } {
               if { $max_tap_width > 24 } {
                  set cs_reg_bytes 4
               } else {
                  set cs_reg_bytes 3
               }
            } else {
               set cs_reg_bytes 2
            }
         }
         if { $h_taps > $v_taps } {
	         set max_taps   $h_taps
	      } else {
	         set max_taps   $v_taps
	      }
      }

      #set parameters
      set_instance_parameter_value   control_slave   NUM_READ_REGISTERS            0
      set_instance_parameter_value   control_slave   NUM_TRIGGER_REGISTERS         $control_reg
      set_instance_parameter_value   control_slave   NUM_BLOCKING_TRIGGER_REGISTERS    $command_reg
      set_instance_parameter_value   control_slave   NUM_RW_REGISTERS              $max_taps
      set_instance_parameter_value   control_slave   NUM_INTERRUPTS                0
      set_instance_parameter_value   control_slave   MM_CONTROL_REG_BYTES          1
      set_instance_parameter_value   control_slave   MM_READ_REG_BYTES             1
      set_instance_parameter_value   control_slave   MM_TRIGGER_REG_BYTES          2
      set_instance_parameter_value   control_slave   MM_RW_REG_BYTES               $cs_reg_bytes
      set_instance_parameter_value   control_slave   MM_ADDR_WIDTH                 7
      set_instance_parameter_value   control_slave   SRC_WIDTH                     8
      set_instance_parameter_value   control_slave   DST_WIDTH                     8
      set_instance_parameter_value   control_slave   TASK_WIDTH                    8
      set_instance_parameter_value   control_slave   CONTEXT_WIDTH                 8
      set_instance_parameter_value   control_slave   RESP_SOURCE                   0
      set_instance_parameter_value   control_slave   RESP_DEST                     0
      set_instance_parameter_value   control_slave   RESP_CONTEXT                  0
      set_instance_parameter_value   control_slave   DOUT_SOURCE                   0
      set_instance_parameter_value   control_slave   USE_MEMORY                    1
      set_instance_parameter_value   control_slave   PIPELINE_READ                 1
      set_instance_parameter_value   control_slave   PIPELINE_RESPONSE             0
      set_instance_parameter_value   control_slave   PIPELINE_DATA                 0
      set_instance_parameter_value   control_slave   DATA_INPUT                    0
      set_instance_parameter_value   control_slave   DATA_OUTPUT                   $runtime_load
      set_instance_parameter_value   control_slave   FAST_REGISTER_UPDATES         0

      if { $runtime_load > 0 } {
         #we need a width adapter to drop from 32 bit default output of the control slave dout to whatever the actual coefficient width is
         set cs_dout_width [expr 8 * $cs_reg_bytes]
         add_instance   coeff_width_adapt alt_vip_message_width_adapt $isVersion
         set_instance_parameter_value   coeff_width_adapt         IS_CMD_RESP             0
         set_instance_parameter_value   coeff_width_adapt         ELEMENTS_IN_PAR         1
         set_instance_parameter_value   coeff_width_adapt         ELEMENT_WIDTH_IN        $cs_dout_width
         set_instance_parameter_value   coeff_width_adapt         ELEMENT_WIDTH_OUT       $max_tap_width
         set_instance_parameter_value   coeff_width_adapt         IN_SRC_WIDTH            8
         set_instance_parameter_value   coeff_width_adapt         IN_DST_WIDTH            8
         set_instance_parameter_value   coeff_width_adapt         IN_CONTEXT_WIDTH        8
         set_instance_parameter_value   coeff_width_adapt         IN_TASK_WIDTH           8
         set_instance_parameter_value   coeff_width_adapt         OUT_SRC_WIDTH           8
         set_instance_parameter_value   coeff_width_adapt         OUT_DST_WIDTH           8
         set_instance_parameter_value   coeff_width_adapt         OUT_CONTEXT_WIDTH       8
         set_instance_parameter_value   coeff_width_adapt         OUT_TASK_WIDTH          8

         add_connection   av_st_clk_bridge.out_clk       coeff_width_adapt.main_clock
         add_connection   av_st_reset_bridge.out_reset   coeff_width_adapt.main_reset
		   add_connection   control_slave.av_st_dout       coeff_width_adapt.av_st_din
         add_connection   coeff_width_adapt.av_st_dout   scaler_core.av_st_coeff
      }

   }

   if { [get_parameter_value ENABLE_FIR] > 0 } {

      if { $always_down_pass > 0 } {
         set v_taps_fir 5
         set search_range 1
      } else {
         set v_taps_fir 7
         set search_range 3
      }

      add_instance   line_buffer_2          alt_vip_line_buffer            $isVersion
      add_instance   fir_filter             alt_vip_fir_alg_core           $isVersion
      add_instance   fir_scheduler          alt_vip_fir_scheduler          $isVersion

      #parameter settings for the second line buffer
      set_instance_parameter_value   line_buffer_2   DATA_WIDTH                    $video_data_width
      set_instance_parameter_value   line_buffer_2   SYMBOLS_IN_SEQ                [get_parameter_value SYMBOLS_IN_SEQ]
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_0                 $v_taps_fir
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_0               [expr int(floor(($v_taps_fir-1) / 2))]
      set_instance_parameter_value   line_buffer_2   MAX_LINE_LENGTH               [get_parameter_value MAX_OUT_WIDTH]
      set_instance_parameter_value   line_buffer_2   OUTPUT_MUX_SEL                NEW
      if { [get_parameter_value EXTRA_PIPELINING] > 0 } {
         set_instance_parameter_value   line_buffer_2   OUTPUT_OPTION     PIPELINED
      } else {
         set_instance_parameter_value   line_buffer_2   OUTPUT_OPTION     UNPIPELINED
      }
      set_instance_parameter_value   line_buffer_2   OUTPUT_PORTS            1
      set_instance_parameter_value   line_buffer_2   MODE                    LOCKED
      set_instance_parameter_value   line_buffer_2   ENABLE_RECEIVE_ONLY_CMD 0
      set_instance_parameter_value   line_buffer_2   FIFO_SIZE               1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_1           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_2           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_3           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_4           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_5           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_6           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_7           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_8           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_9           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_A           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_B           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_C           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_D           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_E           1
      set_instance_parameter_value   line_buffer_2   KERNEL_SIZE_F           1
      set_instance_parameter_value   line_buffer_2   KERNEL_START_1          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_2          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_3          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_4          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_5          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_6          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_7          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_8          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_9          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_A          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_B          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_C          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_D          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_E          0
      set_instance_parameter_value   line_buffer_2   KERNEL_START_F          0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_1         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_2         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_3         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_4         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_5         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_6         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_7         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_8         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_9         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_A         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_B         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_C         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_D         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_E         0
      set_instance_parameter_value   line_buffer_2   KERNEL_CENTER_F         0
      set_instance_parameter_value   line_buffer_2   SRC_WIDTH               8
      set_instance_parameter_value   line_buffer_2   DST_WIDTH               8
      set_instance_parameter_value   line_buffer_2   CONTEXT_WIDTH           8
      set_instance_parameter_value   line_buffer_2   TASK_WIDTH              8
      set_instance_parameter_value   line_buffer_2   SOURCE_ADDRESS          0

      #parameter settings for the fir filter
      set_instance_parameter_value   fir_filter   NUMBER_OF_COLOR_PLANES            $number_of_colours
      set_instance_parameter_value   fir_filter   COLOR_PLANES_ARE_IN_PARALLEL      $colours_in_par
      set_instance_parameter_value   fir_filter   BITS_PER_SYMBOL                   [get_parameter_value BITS_PER_SYMBOL]
      set_instance_parameter_value   fir_filter   BITS_PER_SYMBOL_OUT               [get_parameter_value BITS_PER_SYMBOL]
      set_instance_parameter_value   fir_filter   IS_422                            [get_parameter_value IS_422]
      set_instance_parameter_value   fir_filter   MAX_WIDTH                         [get_parameter_value MAX_OUT_WIDTH]
      set_instance_parameter_value   fir_filter   PARTIAL_LINE_FILTERING            0
      set_instance_parameter_value   fir_filter   DO_MIRRORING                      0
      set_instance_parameter_value   fir_filter   LEFT_MIRROR                       1
      set_instance_parameter_value   fir_filter   RIGHT_MIRROR                      1
      set_instance_parameter_value   fir_filter   ALGORITHM_NAME                    EDGE_ADAPTIVE_SHARPEN
      set_instance_parameter_value   fir_filter   V_TAPS                            $v_taps_fir
      set_instance_parameter_value   fir_filter   H_TAPS                            3
      set_instance_parameter_value   fir_filter   V_SYMMETRIC                       0
      set_instance_parameter_value   fir_filter   H_SYMMETRIC                       0
      set_instance_parameter_value   fir_filter   DIAG_SYMMETRIC                    0
      set_instance_parameter_value   fir_filter   COEFF_SIGNED                      1
      set_instance_parameter_value   fir_filter   COEFF_INTEGER_BITS                1
      set_instance_parameter_value   fir_filter   COEFF_FRACTION_BITS               7
      set_instance_parameter_value   fir_filter   MOVE_BINARY_POINT_RIGHT           0
      set_instance_parameter_value   fir_filter   ROUNDING_METHOD                   ROUND_HALF_UP
      set_instance_parameter_value   fir_filter   ENABLE_CONSTANT_OUTPUT_OFFSET     0
      set_instance_parameter_value   fir_filter   CONSTANT_OUTPUT_OFFSET            0
      set_instance_parameter_value   fir_filter   OUTPUT_GUARD_BANDS_ENABLE         0
      set_instance_parameter_value   fir_filter   OUTPUT_GUARD_BAND_LOWER           0
      set_instance_parameter_value   fir_filter   OUTPUT_GUARD_BAND_UPPER           15
      set_instance_parameter_value   fir_filter   LOAD_AT_RUNTIME                   0
      set_instance_parameter_value   fir_filter   ENABLE_WIDE_BLUR_SHARPEN          $search_range
      set_instance_parameter_value   fir_filter   RUNTIME_BLUR_THRESHOLD_CONTROL    [get_parameter_value RUNTIME_CONTROL]
      set_instance_parameter_value   fir_filter   LOWER_BLUR_LIM                    [get_parameter_value DEFAULT_LOWER_BLUR]
      set_instance_parameter_value   fir_filter   UPPER_BLUR_LIM                    [get_parameter_value DEFAULT_UPPER_BLUR]
      set_instance_parameter_value   fir_filter   EXTRA_PIPELINE_REG                1
      set_instance_parameter_value   fir_filter   DOUT_SRC_ADDRESS                  0
      set_instance_parameter_value   fir_filter   SRC_WIDTH                         8
      set_instance_parameter_value   fir_filter   DST_WIDTH                         8
      set_instance_parameter_value   fir_filter   CONTEXT_WIDTH                     8
      set_instance_parameter_value   fir_filter   TASK_WIDTH                        8

      #parameter settings for the fir scheduler
      set_instance_parameter_value   fir_scheduler  MAX_WIDTH                        [get_parameter_value MAX_OUT_WIDTH]
      set_instance_parameter_value   fir_scheduler  MAX_HEIGHT                       [get_parameter_value MAX_OUT_HEIGHT]
      set_instance_parameter_value   fir_scheduler  BITS_PER_SYMBOL                  [get_parameter_value BITS_PER_SYMBOL]
      set_instance_parameter_value   fir_scheduler  EDGE_ADAPTIVE_SHARPEN            1
      set_instance_parameter_value   fir_scheduler  RUNTIME_CONTROL                  [get_parameter_value RUNTIME_CONTROL]
      set_instance_parameter_value   fir_scheduler  LOAD_AT_RUNTIME                  0
      set_instance_parameter_value   fir_scheduler  DEFAULT_SEARCH_RANGE             15
      set_instance_parameter_value   fir_scheduler  DEFAULT_UPPER_BLUR               [get_parameter_value DEFAULT_UPPER_BLUR]
      set_instance_parameter_value   fir_scheduler  DEFAULT_LOWER_BLUR               [get_parameter_value DEFAULT_LOWER_BLUR]
      set_instance_parameter_value   fir_scheduler  V_TAPS                           $v_taps_fir
      set_instance_parameter_value   fir_scheduler  UPDATE_TAPS                      $v_taps_fir
      set_instance_parameter_value   fir_scheduler  NO_BLANKING                      [get_parameter_value NO_BLANKING]
      set_instance_parameter_value   fir_scheduler  INSIDE_SCALER                    1
      set_instance_parameter_value   fir_scheduler  INSIDE_NOISE_REDUCTION           0
      set_instance_parameter_value   fir_scheduler  ENCODER_PIPELINE_STAGE           [get_parameter_value EXTRA_PIPELINING]


      #connections when there is a fir filter
      add_connection   av_st_clk_bridge.out_clk       line_buffer_2.main_clock
      add_connection   av_st_clk_bridge.out_clk       fir_filter.main_clock
      add_connection   av_st_clk_bridge.out_clk       fir_scheduler.main_clock

      add_connection   av_st_reset_bridge.out_reset   line_buffer_2.main_reset
      add_connection   av_st_reset_bridge.out_reset   fir_filter.main_reset
      add_connection   av_st_reset_bridge.out_reset   fir_scheduler.main_reset

      add_connection   scaler_core.av_st_dout         line_buffer_2.av_st_din
      add_connection   line_buffer_2.av_st_dout_0     fir_filter.av_st_din
      add_connection   fir_filter.av_st_dout          user_packet_mux.av_st_din_0

      add_connection   fir_scheduler.av_st_cmd_0      scheduler.av_st_resp_3
      add_connection   fir_scheduler.av_st_cmd_1      line_buffer_2.av_st_cmd
      add_connection   fir_scheduler.av_st_cmd_3      fir_filter.av_st_cmd
      add_connection   fir_scheduler.av_st_cmd_4      video_out.av_st_cmd
      add_connection   fir_scheduler.av_st_cmd_7      user_packet_mux.av_st_cmd
      
      add_connection   scheduler.av_st_cmd_4          fir_scheduler.av_st_resp_0
      if { [get_parameter_value RUNTIME_CONTROL] > 0 } {
         add_connection   scheduler.av_st_cmd_6          fir_scheduler.av_st_resp_2
         add_connection   fir_scheduler.av_st_cmd_5      scheduler.av_st_resp_4
      }

   } else {

      #connections when there is no fir filter
      add_connection   scaler_core.av_st_dout         user_packet_mux.av_st_din_0
      add_connection   scheduler.av_st_cmd_4          video_out.av_st_cmd
      add_connection   scheduler.av_st_cmd_7          user_packet_mux.av_st_cmd

   }
 	
}
