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

set isInternalDevelopment "0"
set isVipRefDesign "__VIP_REF_DESIGN__"

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Declaration for the common parameters used by the VIP cores and component;                   --
# -- includes valid range and description                                                         --
# -- Convention: Use add_$explicitfuntionname_parameters even for single parameters               --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Device Parameters --
proc add_device_family_parameter {{family_name "Cyclone IV"}} {
    add_parameter          FAMILY string       $family_name
    set_parameter_property FAMILY DISPLAY_NAME "Device family"
    set_parameter_property FAMILY DESCRIPTION  "Currently selected device family"
    set_parameter_property FAMILY SYSTEM_INFO  {DEVICE_FAMILY}
    set_parameter_property FAMILY VISIBLE false
}

# add_max_dim_parameters
# MAX_WIDTH and MAX_HEIGHT parameters, (with default 32-4096 range)
proc add_max_dim_parameters {{x_min 32} {x_max 7680} {y_min 32} {y_max 7680}} {
    add_parameter             MAX_WIDTH         int                      [min $x_max [max $x_min 640]]
    set_parameter_property    MAX_WIDTH         DISPLAY_NAME             "Maximum frame width"
    set_parameter_property    MAX_WIDTH         ALLOWED_RANGES           $x_min:$x_max
    set_parameter_property    MAX_WIDTH         DESCRIPTION              "The maximum width of images / video frames"
    set_parameter_property    MAX_WIDTH         HDL_PARAMETER            true
    set_parameter_property    MAX_WIDTH         AFFECTS_ELABORATION      false

    add_parameter             MAX_HEIGHT        int                      [min $y_max [max $y_min 480]]
    set_parameter_property    MAX_HEIGHT        DISPLAY_NAME             "Maximum frame height"
    set_parameter_property    MAX_HEIGHT        ALLOWED_RANGES           $y_min:$y_max
    set_parameter_property    MAX_HEIGHT        DESCRIPTION              "The maximum height of images / video frames"
    set_parameter_property    MAX_HEIGHT        HDL_PARAMETER            true
    set_parameter_property    MAX_HEIGHT        AFFECTS_ELABORATION      false
}

proc add_max_in_dim_parameters {{x_min 32} {x_max 4096} {y_min 32} {y_max 4096}} {
    add_parameter             MAX_IN_WIDTH      int                      [min $x_max [max $x_min 640]]
    set_parameter_property    MAX_IN_WIDTH      DISPLAY_NAME             "Maximum input frame width"
    set_parameter_property    MAX_IN_WIDTH      ALLOWED_RANGES           $x_min:$x_max
    set_parameter_property    MAX_IN_WIDTH      DESCRIPTION              "The maximum width of input images / video frames"
    set_parameter_property    MAX_IN_WIDTH      HDL_PARAMETER            true
    set_parameter_property    MAX_IN_WIDTH      AFFECTS_ELABORATION      false

    add_parameter             MAX_IN_HEIGHT     int                      [min $y_max [max $y_min 480]]
    set_parameter_property    MAX_IN_HEIGHT     DISPLAY_NAME             "Maximum input frame height"
    set_parameter_property    MAX_IN_HEIGHT     ALLOWED_RANGES           $y_min:$y_max
    set_parameter_property    MAX_IN_HEIGHT     DESCRIPTION              "The maximum height of input images / video frames"
    set_parameter_property    MAX_IN_HEIGHT     HDL_PARAMETER            true
    set_parameter_property    MAX_IN_HEIGHT     AFFECTS_ELABORATION      false
}

proc add_max_out_dim_parameters {{x_min 32} {x_max 4096} {y_min 32} {y_max 4096}} {
    add_parameter             MAX_OUT_WIDTH     int                      [min $x_max [max $x_min 640]]
    set_parameter_property    MAX_OUT_WIDTH     DISPLAY_NAME             "Maximum output frame width"
    set_parameter_property    MAX_OUT_WIDTH     ALLOWED_RANGES           $x_min:$x_max
    set_parameter_property    MAX_OUT_WIDTH     DESCRIPTION              "The maximum width of output images / video frames"
    set_parameter_property    MAX_OUT_WIDTH     HDL_PARAMETER            true
    set_parameter_property    MAX_OUT_WIDTH     AFFECTS_ELABORATION      false

    add_parameter             MAX_OUT_HEIGHT    int                      [min $y_max [max $y_min 480]]
    set_parameter_property    MAX_OUT_HEIGHT    DISPLAY_NAME             "Maximum output frame height"
    set_parameter_property    MAX_OUT_HEIGHT    ALLOWED_RANGES           $y_min:$y_max
    set_parameter_property    MAX_OUT_HEIGHT    DESCRIPTION              "The maximum height of output images / video frames"
    set_parameter_property    MAX_OUT_HEIGHT    HDL_PARAMETER            true
    set_parameter_property    MAX_OUT_HEIGHT    AFFECTS_ELABORATION      false
}

# add_data_width_parameters
# DATA_WIDTH parameter used for non-processing 'utility' components e.g. mux, duplicator that don't care about pixel formats
proc add_data_width_parameters {{data_width_min 4} {data_width_max 1024}} {
   add_parameter DATA_WIDTH int 8
   set_parameter_property DATA_WIDTH         ALLOWED_RANGES       $data_width_min:$data_width_max
   set_parameter_property DATA_WIDTH         DISPLAY_NAME         "Width of payload data" 
   set_parameter_property DATA_WIDTH         DESCRIPTION          "Total width of the data payload on the Avalon-ST Message interfaces"        
   set_parameter_property DATA_WIDTH         AFFECTS_ELABORATION  true         
   set_parameter_property DATA_WIDTH         HDL_PARAMETER        true 
}

# add_symbols_in_seq_parameters
# SYMBOLS_IN_SEQ parameter used to define the number of beats of avalon-st data per pixel
proc add_symbols_in_seq_parameters {{sym_in_seq_min 1} {sym_in_seq_max 4}} {
   add_parameter SYMBOLS_IN_SEQ int 1
   set_parameter_property SYMBOLS_IN_SEQ         ALLOWED_RANGES       $sym_in_seq_min:$sym_in_seq_max
   set_parameter_property SYMBOLS_IN_SEQ         DISPLAY_NAME         "Number of symbols in sequence" 
   set_parameter_property SYMBOLS_IN_SEQ         DESCRIPTION          "Number of beats of Avalon-ST data transmitted in sequence for each pixel (or data unit if not pixel data)"        
   set_parameter_property SYMBOLS_IN_SEQ         AFFECTS_ELABORATION  true         
   set_parameter_property SYMBOLS_IN_SEQ         HDL_PARAMETER        true 
}

# add_bps_parameters
# BPS parameters, (with default 4-20 range)
proc add_bps_parameters {{bps_min 4} {bps_max 20}} {
    add_parameter BPS int 8
    set_parameter_property    BPS               DISPLAY_NAME             "Bits per pixel per color plane"
    set_parameter_property    BPS               ALLOWED_RANGES           $bps_min:$bps_max
    set_parameter_property    BPS               DESCRIPTION              "The number of bits used per pixel, per color plane"
    set_parameter_property    BPS               HDL_PARAMETER            true
    set_parameter_property    BPS               AFFECTS_ELABORATION      true
}

# add_bits_per_symbol_parameters
# BITS_PER_SYMBOL parameters, (with default 4-20 range)
proc add_bits_per_symbol_parameters {{bits_per_symbol_min 4} {bits_per_symbol_max 20}} {
    add_parameter BITS_PER_SYMBOL int 8
    set_parameter_property    BITS_PER_SYMBOL   DISPLAY_NAME            "Bits per pixel per color plane"
    set_parameter_property    BITS_PER_SYMBOL   ALLOWED_RANGES          $bits_per_symbol_min:$bits_per_symbol_max
    set_parameter_property    BITS_PER_SYMBOL   DESCRIPTION             "The number of bits used per pixel, per color plane"
    set_parameter_property    BITS_PER_SYMBOL   HDL_PARAMETER           true
    set_parameter_property    BITS_PER_SYMBOL   AFFECTS_ELABORATION     true
}

#16 Pixels in parallel at 148.5MHz is 8K/60 resolution or 4k/120 :
proc add_pixels_in_parallel_parameters {{pixels_in_parallel_min 1} {pixels_in_parallel_max 16}} {
    add_parameter PIXELS_IN_PARALLEL int 8
    set_parameter_property    PIXELS_IN_PARALLEL   DISPLAY_NAME            "Number of pixels transmitted in 1 clock cycle"
    set_parameter_property    PIXELS_IN_PARALLEL   ALLOWED_RANGES          $pixels_in_parallel_min:$pixels_in_parallel_max
    set_parameter_property    PIXELS_IN_PARALLEL   DESCRIPTION             "The number of pixels transmitted every clock cycle."
    set_parameter_property    PIXELS_IN_PARALLEL   HDL_PARAMETER           true
    set_parameter_property    PIXELS_IN_PARALLEL   AFFECTS_ELABORATION     true
}

# add_channels_nb_parameters
# NUMBER_OF_COLOR_PLANES (with default 1-4 range) and boolean COLOR_PLANES_ARE_IN_PARALLEL parameters,
proc add_channels_nb_parameters {{max_nb_channels 4}} {
    add_parameter NUMBER_OF_COLOR_PLANES int [min 3 $max_nb_channels]
    set_parameter_property   NUMBER_OF_COLOR_PLANES           DISPLAY_NAME           "Number of color planes"
    set_parameter_property   NUMBER_OF_COLOR_PLANES           ALLOWED_RANGES         1:$max_nb_channels
    set_parameter_property   NUMBER_OF_COLOR_PLANES           DESCRIPTION            "The number of color planes transmitted"
    set_parameter_property   NUMBER_OF_COLOR_PLANES           HDL_PARAMETER          true
    set_parameter_property   NUMBER_OF_COLOR_PLANES           AFFECTS_ELABORATION    true

    add_parameter COLOR_PLANES_ARE_IN_PARALLEL int 1
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    DISPLAY_NAME           "Color planes transmitted in parallel"
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    ALLOWED_RANGES         0:1
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    DISPLAY_HINT           boolean
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    DESCRIPTION            "Whether color planes are transmitted in parallel"
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    HDL_PARAMETER          true
    set_parameter_property   COLOR_PLANES_ARE_IN_PARALLEL    AFFECTS_ELABORATION    true
}

# add_rate_control_parameters
# boolean RATE_CONTROL parameter for the core that allows for user-selected frame rate conversion
proc add_rate_control_parameters {} {
    add_parameter RATE_CONTROL int 0
    set_parameter_property   RATE_CONTROL       DISPLAY_NAME           "Controlled frame rate conversion"
    set_parameter_property   RATE_CONTROL       ALLOWED_RANGES         0:1
    set_parameter_property   RATE_CONTROL       DISPLAY_HINT           boolean
    set_parameter_property   RATE_CONTROL       DESCRIPTION            "Run-time control interface to control the frame rate"
    set_parameter_property   RATE_CONTROL       HDL_PARAMETER          true
    set_parameter_property   RATE_CONTROL       AFFECTS_ELABORATION    true
}

# add_common_masters_parameters
# boolean CLOCKS_ARE_SEPARATE and MEM_PORT_WIDTH parameters shared by the multiple master of a core
proc add_common_masters_parameters {} {
    add_parameter CLOCKS_ARE_SEPARATE int 1
    set_parameter_property   CLOCKS_ARE_SEPARATE   DISPLAY_NAME           "Use separate clock for the Avalon-MM master interface(s)"
    set_parameter_property   CLOCKS_ARE_SEPARATE   ALLOWED_RANGES         0:1
    set_parameter_property   CLOCKS_ARE_SEPARATE   DISPLAY_HINT           boolean
    set_parameter_property   CLOCKS_ARE_SEPARATE   DESCRIPTION            "Use separate clock for the Avalon-MM master interface(s)"
    set_parameter_property   CLOCKS_ARE_SEPARATE   HDL_PARAMETER          true
    set_parameter_property   CLOCKS_ARE_SEPARATE   AFFECTS_ELABORATION    true

    add_parameter MEM_PORT_WIDTH int 256
    set_parameter_property   MEM_PORT_WIDTH        DISPLAY_NAME           "Avalon-MM master(s) local ports width"
    set_parameter_property   MEM_PORT_WIDTH        ALLOWED_RANGES         {16 32 64 128 256}
    set_parameter_property   MEM_PORT_WIDTH        DESCRIPTION            "The width in bits of the Avalon-MM master port(s)"
    set_parameter_property   MEM_PORT_WIDTH        HDL_PARAMETER          true
    set_parameter_property   MEM_PORT_WIDTH        AFFECTS_ELABORATION    true
}

# add_base_address_parameters
# MEM_BASE_ADDR parameter, start address of the memory space allocated to the core
proc add_base_address_parameters {} {
    add_parameter MEM_BASE_ADDR int 0
    set_parameter_property   MEM_BASE_ADDR         DISPLAY_NAME           "Base address of storage space in memory"
    set_parameter_property   MEM_BASE_ADDR         ALLOWED_RANGES         0:'h7FFFFFFF
    set_parameter_property   MEM_BASE_ADDR         DISPLAY_HINT           hexadecimal
    set_parameter_property   MEM_BASE_ADDR         DESCRIPTION            "The base address for the storage space used in memory"
    set_parameter_property   MEM_BASE_ADDR         HDL_PARAMETER          true
    set_parameter_property   MEM_BASE_ADDR         AFFECTS_ELABORATION    true

    add_parameter MEM_TOP_ADDR int 0
    set_parameter_property   MEM_TOP_ADDR          DISPLAY_NAME           "Top of address space"
    set_parameter_property   MEM_TOP_ADDR          ALLOWED_RANGES         0:'h7FFFFFFF
    set_parameter_property   MEM_TOP_ADDR          DISPLAY_HINT           hexadecimal
    set_parameter_property   MEM_TOP_ADDR          DESCRIPTION            "Top of deinterlacer address space. Memory above this address is available for other components."
    set_parameter_property   MEM_TOP_ADDR          DERIVED                true
    set_parameter_property   MEM_TOP_ADDR          HDL_PARAMETER          false
    set_parameter_property   MEM_TOP_ADDR          ENABLED                false
    set_parameter_property   MEM_TOP_ADDR          AFFECTS_ELABORATION    false
}

# add_burst_align_parameters
# boolean BURST_ALIGNMENT parameter, used to prevent the core from bursting across defined boundaries
proc add_burst_align_parameters {} {
    add_parameter BURST_ALIGNMENT int 1
    set_parameter_property   BURST_ALIGNMENT             DISPLAY_NAME              "Align read/write bursts on read boundaries"
    set_parameter_property   BURST_ALIGNMENT             ALLOWED_RANGES            0:1
    set_parameter_property   BURST_ALIGNMENT             DISPLAY_HINT              boolean
    set_parameter_property   BURST_ALIGNMENT             DESCRIPTION               "Prevent memory transactions across memory row boundaries"
    set_parameter_property   BURST_ALIGNMENT             HDL_PARAMETER             true
    set_parameter_property   BURST_ALIGNMENT             AFFECTS_ELABORATION       false
}

# add_bursting_master_parameters
# ${master_name}_FIFO_DEPTH and ${master_name}_BURST_TARGET parameters for each bursting master of a core
proc add_bursting_master_parameters {master_name master_gui_name} {
    set FIFO_DEPTH ${master_name}_FIFO_DEPTH
    set BURST_TARGET ${master_name}_BURST_TARGET
    add_parameter $FIFO_DEPTH int 64
    set_parameter_property   $FIFO_DEPTH                 DISPLAY_NAME              "$master_gui_name FIFO depth"
    set_parameter_property   $FIFO_DEPTH                 ALLOWED_RANGES            {8 16 32 64 128 256 512}
    set_parameter_property   $FIFO_DEPTH                 DESCRIPTION               "The depth of the $master_gui_name FIFO"
    set_parameter_property   $FIFO_DEPTH                 HDL_PARAMETER             true
    set_parameter_property   $FIFO_DEPTH                 AFFECTS_ELABORATION       true

    add_parameter $BURST_TARGET int 32
    set_parameter_property   $BURST_TARGET               DISPLAY_NAME              "$master_gui_name FIFO burst target"
    set_parameter_property   $BURST_TARGET               ALLOWED_RANGES            {2 4 8 16 32 64 128 256}
    set_parameter_property   $BURST_TARGET               DESCRIPTION               "The target burst size of the $master_gui_name"
    set_parameter_property   $BURST_TARGET               HDL_PARAMETER             true
    set_parameter_property   $BURST_TARGET               AFFECTS_ELABORATION       true
}


# add_packet_transfer_master_parameters
# ${master_name}_BUFFER_RATIO and ${master_name}_BURST_TARGET parameters for each bursting master of a core
proc add_packet_transfer_master_parameters {master_name master_gui_name} {
    set BUFFER_RATIO CONTEXT_BUFFER_RATIO_${master_name}
    set BURST_TARGET BURST_TARGET_${master_name}
    add_parameter $BUFFER_RATIO int 4
    set_parameter_property   $BUFFER_RATIO               DISPLAY_NAME              "$master_gui_name Buffer depth (in number of burst word)"
    set_parameter_property   $BUFFER_RATIO               ALLOWED_RANGES            {2 4 8 16 32 64 128 256}
    set_parameter_property   $BUFFER_RATIO               DESCRIPTION               "Buffer depth of $master_gui_name in number of burst word"
    set_parameter_property   $BUFFER_RATIO               HDL_PARAMETER             true
    set_parameter_property   $BUFFER_RATIO               AFFECTS_ELABORATION       true

    add_parameter $BURST_TARGET int 8
    set_parameter_property   $BURST_TARGET               DISPLAY_NAME              "$master_gui_name FIFO burst target"
    set_parameter_property   $BURST_TARGET               ALLOWED_RANGES            {2 4 8 16 32 64 128 256 512}
    set_parameter_property   $BURST_TARGET               DESCRIPTION               "The target burst size of the $master_gui_name"
    set_parameter_property   $BURST_TARGET               HDL_PARAMETER             true
    set_parameter_property   $BURST_TARGET               AFFECTS_ELABORATION       true
}


# add_user_packets_mem_storage_parameters
# USER_PACKETS_MAX_STORAGE and MAX_SYMBOLS_PER_PACKET paramers to reserve space for buffering user packets in memory
proc add_user_packets_mem_storage_parameters {} {
    add_parameter USER_PACKETS_MAX_STORAGE int 0
    set_parameter_property   USER_PACKETS_MAX_STORAGE    DISPLAY_NAME              "Storage space for user packets"
    set_parameter_property   USER_PACKETS_MAX_STORAGE    ALLOWED_RANGES            0:32
    set_parameter_property   USER_PACKETS_MAX_STORAGE    DESCRIPTION               "The number of packets that can be buffered before being overwritten"
    set_parameter_property   USER_PACKETS_MAX_STORAGE    HDL_PARAMETER             true
    set_parameter_property   USER_PACKETS_MAX_STORAGE    AFFECTS_ELABORATION       false

    add_parameter MAX_SYMBOLS_PER_PACKET int 10
    set_parameter_property   MAX_SYMBOLS_PER_PACKET      DISPLAY_NAME              "Maximum packet length"
    set_parameter_property   MAX_SYMBOLS_PER_PACKET      ALLOWED_RANGES            1:16384
    set_parameter_property   MAX_SYMBOLS_PER_PACKET      DESCRIPTION               "The maximum allowed length in symbols for user-defined packets (header included)"
    set_parameter_property   MAX_SYMBOLS_PER_PACKET      HDL_PARAMETER             true
    set_parameter_property   MAX_SYMBOLS_PER_PACKET      AFFECTS_ELABORATION       false
}

# add_is_422_parameters
# IS_422 parameter for the cases when the algorithm needs to be tweaked to work with subsampled data
proc add_is_422_parameters {} {
    add_parameter IS_422 int 1  
    set_parameter_property   IS_422                      DISPLAY_NAME              "4:2:2 support"
    set_parameter_property   IS_422                      ALLOWED_RANGES            0:1
    set_parameter_property   IS_422                      DISPLAY_HINT              boolean
    set_parameter_property   IS_422                      DESCRIPTION               "Adapt the processing algorithm for 4:2:2 subsampled data"
    set_parameter_property   IS_422                      HDL_PARAMETER             true
    set_parameter_property   IS_422                      AFFECTS_ELABORATION       true
}


# add_cadence_detect_parameters
# CADENCE_DETECTION parameter to indicate whether cadence detion is enabled
proc add_cadence_detect_parameters {} {
    add_parameter CADENCE_DETECTION int 1
    set_parameter_property    CADENCE_DETECTION          DISPLAY_NAME             "Cadence detection and reverse pulldown"
    set_parameter_property    CADENCE_DETECTION          ALLOWED_RANGES           0:1
    set_parameter_property    CADENCE_DETECTION          DISPLAY_HINT             boolean
    set_parameter_property    CADENCE_DETECTION          DESCRIPTION              "Enable automatic cadence detection and reverse pulldown."
    set_parameter_property    CADENCE_DETECTION          HDL_PARAMETER            true
    set_parameter_property    CADENCE_DETECTION          ENABLED                  true
    set_parameter_property    CADENCE_DETECTION          AFFECTS_ELABORATION      true
}

# add_cadence_algo_parameters
# CADENCE_ALGORITHM_NAME parameter to select and parameterize a cadence detection algorithm
proc add_cadence_algo_parameters {} {
    global isInternalDevelopment
    global isVipRefDesign
    global isBroadcast
    add_parameter CADENCE_ALGORITHM_NAME string CADENCE_32_22
    set_parameter_property   CADENCE_ALGORITHM_NAME      DISPLAY_NAME              "Cadence detection algorithm"
    if {$isInternalDevelopment == 0} {
	     set_parameter_property   CADENCE_ALGORITHM_NAME      ALLOWED_RANGES            {"CADENCE_32:3:2 detector" "CADENCE_22:2:2 detector" "CADENCE_32_22:3:2 & 2:2 detector"}
    } else {
        if {$isVipRefDesign == 0} {
            set_parameter_property   CADENCE_ALGORITHM_NAME      ALLOWED_RANGES            {"CADENCE_32:3:2 detector" "CADENCE_22:2:2 detector" "CADENCE_32_22:3:2 & 2:2 detector"}
        } else {
	         set_parameter_property   CADENCE_ALGORITHM_NAME      ALLOWED_RANGES            {CADENCE_NULL CADENCE_32 CADENCE_22 CADENCE_32_22 CADENCE_MULTI}
        }
    }
    set_parameter_property   CADENCE_ALGORITHM_NAME      DISPLAY_HINT              ""
    set_parameter_property   CADENCE_ALGORITHM_NAME      DESCRIPTION               "Selects the cadence detection algorithm used"
    set_parameter_property   CADENCE_ALGORITHM_NAME      HDL_PARAMETER             true
    set_parameter_property   CADENCE_ALGORITHM_NAME      AFFECTS_ELABORATION       true
}

# add_deinterlace_algo_parameters
# DEINTERLACE_ALGORITHM parameter to select and parameterize a deinterlace algorithm
proc add_deinterlace_algo_parameters {} {
    global isInternalDevelopment
    global isVipRefDesign
    global isBroadcast
    add_parameter DEINTERLACE_ALGORITHM string MOTION_ADAPTIVE_HQ
    set_parameter_property   DEINTERLACE_ALGORITHM      DISPLAY_NAME              "Deinterlace algorithm"
    if {$isBroadcast == 1} {
 	  set_parameter_property   DEINTERLACE_ALGORITHM  ALLOWED_RANGES {MOTION_ADAPTIVE_HQ}   
    } else {
	    
	    if {$isInternalDevelopment == 0} {
		     set_parameter_property   DEINTERLACE_ALGORITHM      ALLOWED_RANGES            {"MOTION_ADAPTIVE:Motion Adaptive" "MOTION_ADAPTIVE_HQ:Motion Adaptive High Quality"}
	    } else {
		if {$isVipRefDesign == 0} {
		    set_parameter_property   DEINTERLACE_ALGORITHM      ALLOWED_RANGES            {"MOTION_ADAPTIVE:Motion Adaptive" "MOTION_ADAPTIVE_HQ:Motion Adaptive High Quality"}
		} else {
			 set_parameter_property   DEINTERLACE_ALGORITHM      ALLOWED_RANGES            {MOTION_ADAPTIVE MOTION_ADAPTIVE_HQ}
		}
	    }
    
    }
    set_parameter_property   DEINTERLACE_ALGORITHM      DISPLAY_HINT              ""
    set_parameter_property   DEINTERLACE_ALGORITHM      DESCRIPTION               "Selects the deinterlace algorithm"
    set_parameter_property   DEINTERLACE_ALGORITHM      HDL_PARAMETER             true
    set_parameter_property   DEINTERLACE_ALGORITHM      AFFECTS_ELABORATION       true
}

proc add_avalon_st_connection_parameters {{max_bps 256}  {max_spb 16}  {with_packet_transfer 1}  {with_ready_latency 1}} {
    add_parameter BITS_PER_SYMBOL int 8
    set_parameter_property   BITS_PER_SYMBOL             DISPLAY_NAME              "Number of bits per symbol"
    set_parameter_property   BITS_PER_SYMBOL             ALLOWED_RANGES            1:$max_bps
    set_parameter_property   BITS_PER_SYMBOL             DESCRIPTION               "The number of bits per symbol"
    set_parameter_property   BITS_PER_SYMBOL             HDL_PARAMETER             true
    set_parameter_property   BITS_PER_SYMBOL             AFFECTS_ELABORATION       true

    add_parameter SYMBOLS_PER_BEAT int 3
    set_parameter_property   SYMBOLS_PER_BEAT            DISPLAY_NAME              "Number symbols per beat"
    set_parameter_property   SYMBOLS_PER_BEAT            ALLOWED_RANGES            1:$max_spb
    set_parameter_property   SYMBOLS_PER_BEAT            DESCRIPTION               "The number of symbols transmitted in parallel"
    set_parameter_property   SYMBOLS_PER_BEAT            HDL_PARAMETER             true
    set_parameter_property   SYMBOLS_PER_BEAT            AFFECTS_ELABORATION       true

    if { ($with_packet_transfer) } {
        add_parameter PACKET_TRANSFER int 1
        set_parameter_property   PACKET_TRANSFER         DISPLAY_NAME             "Add support for packet transfer"
        set_parameter_property   PACKET_TRANSFER         ALLOWED_RANGES           0:1
        set_parameter_property   PACKET_TRANSFER         DISPLAY_HINT             boolean
        set_parameter_property   PACKET_TRANSFER         DESCRIPTION              "Whether support for packet transfer is required"
        set_parameter_property   PACKET_TRANSFER         HDL_PARAMETER            true
        set_parameter_property   PACKET_TRANSFER         AFFECTS_ELABORATION      true
    }


    if { ($with_ready_latency) } {
        add_parameter READY_LATENCY int 1
        set_parameter_property   READY_LATENCY           DISPLAY_NAME             "Ready latency"
        set_parameter_property   READY_LATENCY           ALLOWED_RANGES           0:2
        set_parameter_property   READY_LATENCY           DESCRIPTION              "The ready latency"
        set_parameter_property   READY_LATENCY           AFFECTS_GENERATION       false
        set_parameter_property   READY_LATENCY           IS_HDL_PARAMETER         true
        set_parameter_property   READY_LATENCY           AFFECTS_ELABORATION      true
    }
}


proc add_max_line_length_parameters {{min_length 20} {max_length 4096} } {
    add_parameter            MAX_LINE_LENGTH    int                               [min $max_length [max $min_length 1920]]
    set_parameter_property   MAX_LINE_LENGTH    ALLOWED_RANGES                    $min_length:$max_length
    set_parameter_property   MAX_LINE_LENGTH    DISPLAY_NAME                      "Maximum line length"
    set_parameter_property   MAX_LINE_LENGTH    IS_HDL_PARAMETER                  true
    set_parameter_property   MAX_LINE_LENGTH    AFFECTS_GENERATION                false
    set_parameter_property   MAX_LINE_LENGTH    AFFECTS_ELABORATION               false
}

proc add_max_field_height_parameters {{min_length 10} {max_length 4096} } {
    add_parameter            MAX_FIELD_HEIGHT    int                               [min $max_length [max $min_length 540]]
    set_parameter_property   MAX_FIELD_HEIGHT    ALLOWED_RANGES                    $min_length:$max_length
    set_parameter_property   MAX_FIELD_HEIGHT    DISPLAY_NAME                      "Maximum field height"
    set_parameter_property   MAX_FIELD_HEIGHT    IS_HDL_PARAMETER                  true
    set_parameter_property   MAX_FIELD_HEIGHT    AFFECTS_GENERATION                false
    set_parameter_property   MAX_FIELD_HEIGHT    AFFECTS_ELABORATION               false
}


proc add_av_st_event_parameters {{connection_name ""}} {

    if {$connection_name != ""} {
        set SRC_WIDTH         ${connection_name}_SRC_WIDTH
        set DST_WIDTH         ${connection_name}_DST_WIDTH
        set CONTEXT_WIDTH     ${connection_name}_CONTEXT_WIDTH
        set TASK_WIDTH        ${connection_name}_TASK_WIDTH
    } else {
        set SRC_WIDTH         SRC_WIDTH
        set DST_WIDTH         DST_WIDTH
        set CONTEXT_WIDTH     CONTEXT_WIDTH
        set TASK_WIDTH        TASK_WIDTH
    }

    add_parameter $SRC_WIDTH int 8
    set_parameter_property    $SRC_WIDTH        ALLOWED_RANGES        0:32
    set_parameter_property    $SRC_WIDTH        AFFECTS_ELABORATION   true
    set_parameter_property    $SRC_WIDTH        AFFECTS_GENERATION    true
    set_parameter_property    $SRC_WIDTH        HDL_PARAMETER         true

    add_parameter $DST_WIDTH int 8
    set_parameter_property    $DST_WIDTH        ALLOWED_RANGES        0:32
    set_parameter_property    $DST_WIDTH        AFFECTS_ELABORATION   true
    set_parameter_property    $DST_WIDTH        AFFECTS_GENERATION    true
    set_parameter_property    $DST_WIDTH        HDL_PARAMETER         true

    add_parameter $CONTEXT_WIDTH int 8
    set_parameter_property    $CONTEXT_WIDTH        ALLOWED_RANGES        0:32
    set_parameter_property    $CONTEXT_WIDTH        AFFECTS_ELABORATION   true
    set_parameter_property    $CONTEXT_WIDTH        AFFECTS_GENERATION    true
    set_parameter_property    $CONTEXT_WIDTH        HDL_PARAMETER         true

    add_parameter $TASK_WIDTH int 8
    set_parameter_property    $TASK_WIDTH    ALLOWED_RANGES        0:32
    set_parameter_property    $TASK_WIDTH    AFFECTS_ELABORATION   true
    set_parameter_property    $TASK_WIDTH    AFFECTS_GENERATION    true
    set_parameter_property    $TASK_WIDTH    HDL_PARAMETER         true

    if {$connection_name != ""} {
       set_parameter_property    $SRC_WIDTH        DISPLAY_NAME          "$connection_name Source ID width"
       set_parameter_property    $SRC_WIDTH        DESCRIPTION           "Width of the Source ID signal in $connection_name interface"
       set_parameter_property    $DST_WIDTH        DISPLAY_NAME          "$connection_name Destination ID width"
       set_parameter_property    $DST_WIDTH        DESCRIPTION           "Width of the Destination ID signal in $connection_name interface"
       set_parameter_property    $CONTEXT_WIDTH    DISPLAY_NAME          "$connection_name Context ID width"
       set_parameter_property    $CONTEXT_WIDTH    DESCRIPTION           "Width of the Context ID signal in $connection_name interface"
       set_parameter_property    $TASK_WIDTH       DISPLAY_NAME          "$connection_name Task ID width"
       set_parameter_property    $TASK_WIDTH       DESCRIPTION           "Width of the Task ID signal in $connection_name interface"
    } else {
       set_parameter_property    $SRC_WIDTH        DISPLAY_NAME          "Source address width"
       set_parameter_property    $SRC_WIDTH        DESCRIPTION           "Width of the Source ID signal"
       set_parameter_property    $DST_WIDTH        DISPLAY_NAME          "Destination address width"
       set_parameter_property    $DST_WIDTH        DESCRIPTION           "Width of the Destination ID signal"
       set_parameter_property    $CONTEXT_WIDTH    DISPLAY_NAME          "Context ID width"
       set_parameter_property    $CONTEXT_WIDTH    DESCRIPTION           "Width of the Context ID signal"
       set_parameter_property    $TASK_WIDTH       DISPLAY_NAME          "Task ID width"
       set_parameter_property    $TASK_WIDTH       DESCRIPTION           "Width of the Task ID signal"
    }
}

proc add_av_st_event_user_width_parameter {{connection_name ""} {default_width 0}} {

    if {$connection_name != ""} {
        set USER_WIDTH        ${connection_name}_USER_WIDTH
    } else {
        set USER_WIDTH        USER_WIDTH
    }

    add_parameter $USER_WIDTH int $default_width
    set_parameter_property    $USER_WIDTH       ALLOWED_RANGES        0:32
    set_parameter_property    $USER_WIDTH       AFFECTS_ELABORATION   true
    set_parameter_property    $USER_WIDTH       AFFECTS_GENERATION    true
    set_parameter_property    $USER_WIDTH       HDL_PARAMETER         true
    if {$connection_name != ""} {
       set_parameter_property    $USER_WIDTH       DISPLAY_NAME          "$connection_name User width"
       set_parameter_property    $USER_WIDTH       DESCRIPTION           "Width of the User signal in $connection_name interface"
    } else {
       set_parameter_property    $USER_WIDTH       DISPLAY_NAME          "User width"
       set_parameter_property    $USER_WIDTH       DESCRIPTION           "Width of the User signal"
    }
}
