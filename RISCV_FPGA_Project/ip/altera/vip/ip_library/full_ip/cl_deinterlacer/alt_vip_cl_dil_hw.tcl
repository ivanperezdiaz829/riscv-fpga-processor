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
# --                                                                                               --
# -- _hw.tcl compose file for Component Library Deinterlacer (Deinterlacer 2)                      --
# --                                                                                               --
# ---------------------------------------------------------------------------------------------------

source ../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../common_tcl/alt_vip_files_common_hw.tcl
source ../../common_tcl/alt_vip_parameters_common_hw.tcl

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information for the Deinterlacer II component                                        --
# -- The deinterlacer II deinterlace a video stream                                               --
# -- It is highly parameterizable and offers a wide range of features                             --
# --   * Bob, weave or Motion adaptive deinterlacing with optional motion bleed                   --
# --   * Edge dependent interpolation (two modes with different cost/quality trade-off)           --
# --   * 4:2:2 support                                                                            --
# --   * Pass-through mode for progressive inputs                                                 --
# --   * Cadence detection                                                                        --
# --   * Parameterizable master interfaces to store/retrieve data from external memory            --
# --------------------------------------------------------------------------------------------------  


declare_general_module_info
set_module_property NAME alt_vip_cl_dil
set_module_property DISPLAY_NAME "Deinterlacer II (with Sobel based HQ mode)"
set_module_property DESCRIPTION "The Deinterlacer II has been redesigned with a Sobel-based High Quality (HQ) mode."


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  

# Callback for the composition of this component
set_module_property VALIDATION_CALLBACK  dil2_validation_callback
set_module_property COMPOSE_CALLBACK dil2_composition_callback



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  



add_max_dim_parameters
set_parameter_property    MAX_WIDTH                  DEFAULT_VALUE           1920
set_parameter_property    MAX_WIDTH                  ENABLED                 true
set_parameter_property    MAX_WIDTH                  AFFECTS_ELABORATION     true
set_parameter_property    MAX_HEIGHT                 DEFAULT_VALUE           1080
set_parameter_property    MAX_HEIGHT                 ENABLED                 true
set_parameter_property    MAX_HEIGHT                 AFFECTS_ELABORATION     true

#todo reinstate for 12.0 : 
add_device_family_parameter
add_bits_per_symbol_parameters

add_is_422_parameters

#SPR387883 : Replacing "add_channels_nb_parameters" with this below :
add_parameter SYMBOLS_IN_SEQ int 1
set_parameter_property    SYMBOLS_IN_SEQ    DISPLAY_NAME           "Symbols in sequence"
set_parameter_property    SYMBOLS_IN_SEQ    ALLOWED_RANGES         1:1
set_parameter_property    SYMBOLS_IN_SEQ    DESCRIPTION            "The number of Avalon-ST symbols in sequence"
set_parameter_property    SYMBOLS_IN_SEQ    HDL_PARAMETER          true
set_parameter_property    SYMBOLS_IN_SEQ    AFFECTS_ELABORATION    true
set_parameter_property    SYMBOLS_IN_SEQ    ENABLED                false
set_parameter_property    SYMBOLS_IN_SEQ    VISIBLE                false

add_parameter SYMBOLS_IN_PAR int [min 3 4]
set_parameter_property    SYMBOLS_IN_PAR    DISPLAY_NAME           "Symbols in parallel"
set_parameter_property    SYMBOLS_IN_PAR    ALLOWED_RANGES         1:4
set_parameter_property    SYMBOLS_IN_PAR    DESCRIPTION            "The number of Avalon-ST symbols in parallel"
set_parameter_property    SYMBOLS_IN_PAR    HDL_PARAMETER          true
set_parameter_property    SYMBOLS_IN_PAR    AFFECTS_ELABORATION    true    
set_parameter_property    SYMBOLS_IN_PAR    DEFAULT_VALUE          2

# choice of deinterlace algorithm
set isBroadcast 0
add_deinterlace_algo_parameters

add_parameter MOTION_BLEED int 1
set_parameter_property    MOTION_BLEED               DISPLAY_NAME            "Motion bleed"
set_parameter_property    MOTION_BLEED               ALLOWED_RANGES          0:1
set_parameter_property    MOTION_BLEED               DISPLAY_HINT            boolean
set_parameter_property    MOTION_BLEED               DESCRIPTION             "Enable motion bleed during motion adaptive deinterlacing"
set_parameter_property    MOTION_BLEED               HDL_PARAMETER           true
set_parameter_property    MOTION_BLEED               ENABLED                 false
set_parameter_property    MOTION_BLEED               AFFECTS_ELABORATION     true
set_parameter_property    MOTION_BLEED               VISIBLE                 false

add_parameter PROGRESSIVE_PASSTHROUGH int 1
set_parameter_property    PROGRESSIVE_PASSTHROUGH    DISPLAY_NAME            "Pass-through mode for progressive input frames"
set_parameter_property    PROGRESSIVE_PASSTHROUGH    ALLOWED_RANGES          0:1
set_parameter_property    PROGRESSIVE_PASSTHROUGH    DISPLAY_HINT            boolean
set_parameter_property    PROGRESSIVE_PASSTHROUGH    DESCRIPTION             "Propagate progressive frames unchanged"
set_parameter_property    PROGRESSIVE_PASSTHROUGH    HDL_PARAMETER           true
set_parameter_property    PROGRESSIVE_PASSTHROUGH    ENABLED                 false
set_parameter_property    PROGRESSIVE_PASSTHROUGH    AFFECTS_ELABORATION     false
set_parameter_property    PROGRESSIVE_PASSTHROUGH    VISIBLE                 false

add_parameter RUNTIME_CONTROL int 0
set_parameter_property    RUNTIME_CONTROL           DISPLAY_NAME            "Run-time control"
set_parameter_property    RUNTIME_CONTROL           ALLOWED_RANGES          0:1
set_parameter_property    RUNTIME_CONTROL           DISPLAY_HINT            boolean
set_parameter_property    RUNTIME_CONTROL           DESCRIPTION             "Enable run-time control of cadence detection"
set_parameter_property    RUNTIME_CONTROL           HDL_PARAMETER           true
set_parameter_property    RUNTIME_CONTROL           ENABLED                 true
set_parameter_property    RUNTIME_CONTROL           AFFECTS_ELABORATION     true

add_parameter MOTION_BPS int 7
set_parameter_property    MOTION_BPS                DISPLAY_NAME            "Most significant bits of motion value computed"
set_parameter_property    MOTION_BPS                ALLOWED_RANGES          {5,6,7,8}
set_parameter_property    MOTION_BPS                DESCRIPTION             "Ensures the motion detect block performs more or less consistently across a range of bps values"
set_parameter_property    MOTION_BPS                HDL_PARAMETER           true
set_parameter_property    MOTION_BPS                ENABLED                 false
set_parameter_property    MOTION_BPS                AFFECTS_ELABORATION     true
set_parameter_property    MOTION_BPS                VISIBLE                 false


# cadence detection and choice of a cadence detector
add_cadence_detect_parameters
add_cadence_algo_parameters

# Parameters for the read and write masters
add_common_masters_parameters
set_parameter_property    CLOCKS_ARE_SEPARATE        ENABLED                  true
set_parameter_property    CLOCKS_ARE_SEPARATE        AFFECTS_GENERATION       true

add_bursting_master_parameters   WRITE_MASTER         "Write Master"
add_bursting_master_parameters   EDI_READ_MASTER      "EDI Read Master"
add_bursting_master_parameters   MA_READ_MASTER       "MA Read Master"
add_bursting_master_parameters   MOTION_WRITE_MASTER  "Motion Write Master"
add_bursting_master_parameters   MOTION_READ_MASTER   "Motion Read Master"

add_base_address_parameters
   

# Storing packets in memory (useless with the pass-through mode)   
add_user_packets_mem_storage_parameters
set_parameter_property    USER_PACKETS_MAX_STORAGE   HDL_PARAMETER           false
set_parameter_property    MAX_SYMBOLS_PER_PACKET     HDL_PARAMETER           false
set_parameter_property    USER_PACKETS_MAX_STORAGE   VISIBLE                 false
set_parameter_property    MAX_SYMBOLS_PER_PACKET     VISIBLE                 false
set_parameter_property    USER_PACKETS_MAX_STORAGE   ENABLED                 false
set_parameter_property    MAX_SYMBOLS_PER_PACKET     ENABLED                 false



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Derived parameters                                                                           --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_parameter LINE_BUFFER_SIZE int 0
set_parameter_property    LINE_BUFFER_SIZE              DESCRIPTION              "The length (in bytes) of a line of pixels stored in memory"
set_parameter_property    LINE_BUFFER_SIZE              VISIBLE                  false
set_parameter_property    LINE_BUFFER_SIZE              HDL_PARAMETER            false
set_parameter_property    LINE_BUFFER_SIZE              DERIVED                  true

add_parameter FIELD_BUFFER_SIZE_IN_BYTES int 0
set_parameter_property    FIELD_BUFFER_SIZE_IN_BYTES    DESCRIPTION              "The size (in words) of a field buffer"
set_parameter_property    FIELD_BUFFER_SIZE_IN_BYTES    VISIBLE                  false
set_parameter_property    FIELD_BUFFER_SIZE_IN_BYTES    HDL_PARAMETER            false
set_parameter_property    FIELD_BUFFER_SIZE_IN_BYTES    DERIVED                  true

add_parameter MOTION_LINE_BUFFER_SIZE int 0
set_parameter_property    MOTION_LINE_BUFFER_SIZE       DESCRIPTION              "The length (in bytes) of a line of motion value stored in memory"
set_parameter_property    MOTION_LINE_BUFFER_SIZE       VISIBLE                  false
set_parameter_property    MOTION_LINE_BUFFER_SIZE       HDL_PARAMETER            false
set_parameter_property    MOTION_LINE_BUFFER_SIZE       DERIVED                  true

add_parameter MOTION_BUFFER_SIZE_IN_BYTES int 0
set_parameter_property    MOTION_BUFFER_SIZE_IN_BYTES   DESCRIPTION              "The size (in words) of the motion buffer"
set_parameter_property    MOTION_BUFFER_SIZE_IN_BYTES   VISIBLE                  false
set_parameter_property    MOTION_BUFFER_SIZE_IN_BYTES   HDL_PARAMETER            false
set_parameter_property    MOTION_BUFFER_SIZE_IN_BYTES   DERIVED                  true



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- GUI                                                                                          --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
add_display_item   "Video Data Format"     MAX_WIDTH                  parameter
add_display_item   "Video Data Format"     MAX_HEIGHT                 parameter
add_display_item   "Video Data Format"     BITS_PER_SYMBOL            parameter
add_display_item   "Video Data Format"     SYMBOLS_IN_SEQ             parameter
add_display_item   "Video Data Format"     SYMBOLS_IN_PAR             parameter
add_display_item   "Video Data Format"     IS_422                     parameter

add_display_item   "Behavior"              DEINTERLACE_ALGORITHM      parameter
add_display_item   "Behavior"              MOTION_BLEED               parameter
add_display_item   "Behavior"              PROGRESSIVE_PASSTHROUGH    parameter
add_display_item   "Behavior"              RUNTIME_CONTROL            parameter
add_display_item   "Behavior"              CADENCE_DETECTION          parameter
add_display_item   "Behavior"              CADENCE_ALGORITHM_NAME     parameter

add_display_item   "Memory"                MEM_PORT_WIDTH                   parameter
add_display_item   "Memory"                CLOCKS_ARE_SEPARATE              parameter
add_display_item   "Memory"                MEM_BASE_ADDR                    parameter
add_display_item   "Memory"                MEM_TOP_ADDR                     parameter
add_display_item   "Memory"                WRITE_MASTER_FIFO_DEPTH          parameter
add_display_item   "Memory"                WRITE_MASTER_BURST_TARGET        parameter
add_display_item   "Memory"                EDI_READ_MASTER_FIFO_DEPTH       parameter
add_display_item   "Memory"                EDI_READ_MASTER_BURST_TARGET     parameter
add_display_item   "Memory"                MA_READ_MASTER_FIFO_DEPTH        parameter
add_display_item   "Memory"                MA_READ_MASTER_BURST_TARGET      parameter
add_display_item   "Memory"                MOTION_WRITE_MASTER_FIFO_DEPTH   parameter
add_display_item   "Memory"                MOTION_WRITE_MASTER_BURST_TARGET parameter
add_display_item   "Memory"                MOTION_READ_MASTER_FIFO_DEPTH    parameter
add_display_item   "Memory"                MOTION_READ_MASTER_BURST_TARGET  parameter
#add_display_item   "Memory"               USER_PACKETS_MAX_STORAGE   parameter
#add_display_item   "Memory"               MAX_SYMBOLS_PER_PACKET     parameter



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The validation callback                                                                      --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
proc dil2_validation_callback {} {
   
   set family                       [get_parameter_value FAMILY]
   set bits_per_symbol              [get_parameter_value BITS_PER_SYMBOL]
   set is_422                       [get_parameter_value IS_422]
   #set are_in_par                   [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
   #set number_of_color_planes       [get_parameter_value NUMBER_OF_COLOR_PLANES]
   #set symbols_in_seq               [expr $are_in_par == 0 ? $number_of_color_planes : 1]
   #set symbols_in_par               [expr $are_in_par == 1 ? $number_of_color_planes : 1]

   #SPR:387773 - Re-instating 11.0 style parameters to allow an upgrade path :
   set symbols_in_seq               [get_parameter_value SYMBOLS_IN_SEQ] 
   set symbols_in_par               [get_parameter_value SYMBOLS_IN_PAR]
   set number_of_color_planes       [expr { [get_parameter_value SYMBOLS_IN_SEQ] * [get_parameter_value SYMBOLS_IN_PAR] } ]   
   if { [get_parameter_value SYMBOLS_IN_SEQ] > 1 } {
      set are_in_par 0
   } else {
      set are_in_par 1
   }
   
   set max_width                    [get_parameter_value MAX_WIDTH]
   set max_height                   [get_parameter_value MAX_HEIGHT]
   set max_field_height             [expr ($max_height+1)/2]
      
   if { [expr $max_height % 2] != 0 } {
       send_message error "The frame height must be an even number"
   }
   
   set deinterlace_algorithm        [get_parameter_value DEINTERLACE_ALGORITHM]
   set comp [string compare $deinterlace_algorithm "MOTION_ADAPTIVE_HQ"]
   
   if { $comp == 0 } {
       send_message info "Motion Adaptive High Quality deinterlacing algorithm enables high quality Sobel-based deinterlacing"
   }
         
   if { $is_422 > 0 } {
     if { $are_in_par==1 && $number_of_color_planes != 2 } {
       send_message error "There must be 2 color planes in parallel for the 4:2:2 data configuration"
     }
     if { $are_in_par == 0 } {
       send_message error "Symbols in sequence is not yet supported for 4:2:2 data"
     }
   }


   set mem_port_width               [get_parameter_value MEM_PORT_WIDTH]

   # Compute the space reserved for an input line in memory, this is max_line_word_size rounded up to the next multiple of burst
   # target to prevent line starting at an address that would not be a nice starting point for a burst.
   # Deduce the size of a field buffer.
   set bytes_per_word               [expr $mem_port_width / 8]
   set samples_per_word             [expr $mem_port_width / ($symbols_in_par * $bits_per_symbol)]
   if { $samples_per_word < 1 } {
      set samples_per_word 1
   }
   set max_line_sample_size         [expr $max_width * $symbols_in_seq]
   set max_line_word_size           [expr ($max_line_sample_size + $samples_per_word - 1) / $samples_per_word]
   
   set write_master_burst           [get_parameter_value WRITE_MASTER_BURST_TARGET]    
   set edi_read_master_burst        [get_parameter_value EDI_READ_MASTER_BURST_TARGET]    
   set ma_read_master_burst         [get_parameter_value MA_READ_MASTER_BURST_TARGET]    
   set max_burst                    [max $write_master_burst [max $edi_read_master_burst $ma_read_master_burst]]
   
   set line_burst_size              [expr ($max_line_word_size + $max_burst-1)/$max_burst]
   set line_length_in_words         [expr $line_burst_size * $max_burst]
   set line_buffer_size             [expr $line_length_in_words * $bytes_per_word]
   set field_buffer_size            [expr $line_length_in_words * $max_field_height * $bytes_per_word]

   
   # Similar stuff for the motion masters (with $samples_per_words == $bytes_per_word since motion value are fixed to 8-bit)
   # Compute the space reserved for an motion line in memory, this is max_line_word_size rounded up to the next multiple of burst
   # target to prevent line starting at an address that would not be a nice starting point for a burst.
   # Deduce the size of a motion buffer.
   set max_motion_line_word_size    [expr ($max_width + $bytes_per_word - 1) / $bytes_per_word]

   set motion_write_burst           [get_parameter_value MOTION_WRITE_MASTER_BURST_TARGET]    
   set motion_read_burst            [get_parameter_value MOTION_READ_MASTER_BURST_TARGET]    
   set max_burst                    [max $motion_write_burst $motion_read_burst]
   
   set motion_line_burst_size       [expr ($max_motion_line_word_size + $max_burst-1)/$max_burst]
   set motion_line_length_in_words  [expr $motion_line_burst_size * $max_burst]
   set motion_line_buffer_size      [expr $motion_line_length_in_words * $bytes_per_word]
   set motion_field_size            [expr $motion_line_length_in_words * $max_field_height * $bytes_per_word]

   # Checking that the burst target is smaller that the number of words in the largest possible
   # packet in each packet reader/writer. Otherwise the bursting_master_fifo will say no
   if { $max_line_word_size < $write_master_burst } {
      send_message error "The burst target for the write master is set to a value higher than achievable for the current parameterization. It should be reduced"
   }
   if { $max_line_word_size < $edi_read_master_burst } {
      send_message error "The burst target for the edi read master is set to a value higher than achievable for the current parameterization. It should be reduced"
   }
   if { $max_line_word_size < $ma_read_master_burst } {
      send_message error "The burst target for the ma read master is set to a value higher than achievable for the current parameterization. It should be reduced"
   }
   if { $max_motion_line_word_size < $motion_write_burst } {
      send_message error "The burst target for the motion write master is set to a value higher than achievable for the current parameterization. It should be reduced"
   }
   if { $max_motion_line_word_size < $motion_read_burst } {
      send_message error "The burst target for the motion read master is set to a value higher than achievable for the current parameterization. It should be reduced"
   }


   # Setting the derived parameters
   set_parameter_value            LINE_BUFFER_SIZE                       $line_buffer_size
   set_parameter_value            FIELD_BUFFER_SIZE_IN_BYTES             $field_buffer_size          
   set_parameter_value            MOTION_LINE_BUFFER_SIZE                $motion_line_buffer_size
   set_parameter_value            MOTION_BUFFER_SIZE_IN_BYTES            $motion_field_size
    
   # Set the derived parameter for the top of the memory base address
   set mem_base_addr     [get_parameter_value MEM_BASE_ADDR]
   set mem_top_addr      [expr $mem_base_addr + 4*$field_buffer_size + $motion_field_size]


   set_parameter_value   MEM_TOP_ADDR      $mem_top_addr
}



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The composition callback                                                                     --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------  
proc dil2_composition_callback {} {
    dil2_composition_callback_instantiation
    dil2_composition_callback_connections
}


#TODO Set source addresses..

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Instantiation of sub-components                                                              --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc dil2_composition_callback_instantiation {} {
   global isVersion acdsVersion

   set bits_per_symbol              [get_parameter_value BITS_PER_SYMBOL]
   set is_422                       [get_parameter_value IS_422]
   #set are_in_par                   [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
   #set number_of_color_planes       [get_parameter_value NUMBER_OF_COLOR_PLANES]
   #set symbols_in_seq               [expr $are_in_par == 0 ? $number_of_color_planes : 1]
   #set symbols_in_par               [expr $are_in_par == 1 ? $number_of_color_planes : 1]

   #SPR:387773 - Re-instating 11.0 style parameters to allow an upgrade path :
   set symbols_in_seq               [get_parameter_value SYMBOLS_IN_SEQ] 
   set symbols_in_par               [get_parameter_value SYMBOLS_IN_PAR]
   set number_of_color_planes       [expr { [get_parameter_value SYMBOLS_IN_SEQ] * [get_parameter_value SYMBOLS_IN_PAR] } ]   
   if { [get_parameter_value SYMBOLS_IN_SEQ] > 1 } {
      set video_data_width          $bits_per_symbol
      set are_in_par 0
   } else {
      set video_data_width         [expr $bits_per_symbol * $symbols_in_par]
      set are_in_par 1
   }
   
   set base                         [get_parameter_value MEM_BASE_ADDR]
   
   set max_width                    [get_parameter_value MAX_WIDTH]
   set max_height                   [get_parameter_value MAX_HEIGHT]
   
   set base_addr                    [get_parameter_value MEM_BASE_ADDR]
   set field_buffer_size            [get_parameter_value FIELD_BUFFER_SIZE_IN_BYTES]
   set motion_field_buffer_size     [get_parameter_value MOTION_BUFFER_SIZE_IN_BYTES]  
   set line_buffer_size             [get_parameter_value LINE_BUFFER_SIZE] 
   set motion_line_buffer_size      [get_parameter_value MOTION_LINE_BUFFER_SIZE]
   set motion_bps                   [get_parameter_value MOTION_BPS]

   set write_master_fifo_depth      [get_parameter_value WRITE_MASTER_FIFO_DEPTH]    
   set write_master_burst_target    [get_parameter_value WRITE_MASTER_BURST_TARGET]    
   set edi_read_master_fifo_depth   [get_parameter_value EDI_READ_MASTER_FIFO_DEPTH]    
   set edi_read_master_burst_target [get_parameter_value EDI_READ_MASTER_BURST_TARGET]    
   set ma_read_master_fifo_depth    [get_parameter_value MA_READ_MASTER_FIFO_DEPTH]    
   set ma_read_master_burst_target  [get_parameter_value MA_READ_MASTER_BURST_TARGET]    
   set motion_write_fifo_depth      [get_parameter_value MOTION_WRITE_MASTER_FIFO_DEPTH]    
   set motion_write_burst_target    [get_parameter_value MOTION_WRITE_MASTER_BURST_TARGET]    
   set motion_read_fifo_depth       [get_parameter_value MOTION_READ_MASTER_FIFO_DEPTH]    
   set motion_read_burst_target     [get_parameter_value MOTION_READ_MASTER_BURST_TARGET]
   set mem_port_width               [get_parameter_value MEM_PORT_WIDTH]    
   set deinterlace_algorithm        [get_parameter_value DEINTERLACE_ALGORITHM]
   set comp [string compare $deinterlace_algorithm "MOTION_ADAPTIVE_HQ"]
   if { $comp == 0 } {
     set selected_algorithm   alt_vip_dil_low_angle_algorithm
     set selected_scheduler   alt_vip_dil_sobel_scheduler
     set high_quality_line_multiplier 2
   } else {
     set selected_algorithm   alt_vip_dil_algorithm
     set selected_scheduler   alt_vip_dil_scheduler
     set high_quality_line_multiplier 1
   }   

   set runtime_control              [get_parameter_value RUNTIME_CONTROL]
   set cadence_detect               [get_parameter_value CADENCE_DETECTION]
   set cadence_algo                 [get_parameter_value CADENCE_ALGORITHM_NAME]
   set clocks_are_separate          [get_parameter_value CLOCKS_ARE_SEPARATE]
 
   set max_line_sample_size         [expr $max_width * ($are_in_par ? 1 : $number_of_color_planes)]
   set max_field_height             [expr ($max_height+1)/2]

   
   # --------------------------------------------------------------------------------------------------
   # -- Clocks/reset                                                                                 --
   # --------------------------------------------------------------------------------------------------
   add_instance              av_st_clk_bridge                   altera_clock_bridge $acdsVersion
   add_instance              av_st_reset_bridge                 altera_reset_bridge $acdsVersion
   
   if {$clocks_are_separate} {
     add_instance            av_mm_clk_bridge                   altera_clock_bridge $acdsVersion
     add_instance            av_mm_reset_bridge                 altera_reset_bridge $acdsVersion
   }


   # --------------------------------------------------------------------------------------------------
   # -- Main components                                                                              --
   # --------------------------------------------------------------------------------------------------

   # The video input bridge
   add_instance                   video_in                      alt_vip_video_input_bridge   $isVersion
   set_instance_parameter_value   video_in                      BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   video_in                      COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   video_in                      NUMBER_OF_COLOR_PLANES       $number_of_color_planes
   set_instance_parameter_value   video_in                      DEFAULT_LINE_LENGTH          $max_width

   # The MA algorithm
   add_instance                   dil_algo                      $selected_algorithm   $isVersion
   set_instance_parameter_value   dil_algo                      BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   dil_algo                      COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   dil_algo                      NUMBER_OF_COLOR_PLANES       $number_of_color_planes   
   set_instance_parameter_value   dil_algo                      IS_422                       $is_422

   # The motion detection/motion bleed block, used by the MA algorithm
   add_instance                   motion_detect                 alt_vip_motion_detect        $isVersion
   set_instance_parameter_value   motion_detect                 BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   motion_detect                 COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   motion_detect                 NUMBER_OF_COLOR_PLANES       $number_of_color_planes   
   set_instance_parameter_value   motion_detect                 KERNEL_SIZE_0                [expr 2*$high_quality_line_multiplier]
   set_instance_parameter_value   motion_detect                 KERNEL_SIZE_1                1
   set_instance_parameter_value   motion_detect                 KERNEL_SIZE_2                2
   set_instance_parameter_value   motion_detect                 KERNEL_SIZE_3                1
   set_instance_parameter_value   motion_detect                 MAX_LINE_LENGTH              $max_line_sample_size
   set_instance_parameter_value   motion_detect                 MOTION_BPS                   $motion_bps   

   # Video output bridge   
   add_instance                   video_out                     alt_vip_video_output_bridge  $isVersion
   set_instance_parameter_value   video_out                     BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   video_out                     COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   video_out                     NUMBER_OF_COLOR_PLANES       $number_of_color_planes

   # The scheduler
   add_instance                   scheduler                     $selected_scheduler        $isVersion
   set_instance_parameter_value   scheduler                     BUFFER0_BASE                 $base_addr
   set_instance_parameter_value   scheduler                     BUFFER1_BASE                 [expr $base_addr + $field_buffer_size]
   set_instance_parameter_value   scheduler                     BUFFER2_BASE                 [expr $base_addr + 2*$field_buffer_size]
   set_instance_parameter_value   scheduler                     BUFFER3_BASE                 [expr $base_addr + 3*$field_buffer_size]
   set_instance_parameter_value   scheduler                     MOTION_BUFFER_BASE           [expr $base_addr + 4*$field_buffer_size]
   set_instance_parameter_value   scheduler                     CADENCE_DETECTION            $cadence_detect
   set_instance_parameter_value   scheduler                     RUNTIME_CONTROL              $runtime_control
   set_instance_parameter_value   scheduler                     LINE_OFFSET_BYTES            $line_buffer_size
   set_instance_parameter_value   scheduler                     MOTION_LINE_OFFSET_BYTES     $motion_line_buffer_size
   set_instance_parameter_value   scheduler                     MAX_LINE_LENGTH              $max_line_sample_size
   set_instance_parameter_value   scheduler                     MAX_FIELD_HEIGHT             $max_field_height

   # Cadence detector
   # NB. The cadence detector ignores half the lines from the EDI line buffer...
   if {$cadence_detect} {
      add_instance                   cadence                    alt_vip_cadence_detect       $isVersion
      set_instance_parameter_value   cadence                    BITS_PER_SYMBOL              $bits_per_symbol   
      set_instance_parameter_value   cadence                    COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
      set_instance_parameter_value   cadence                    NUMBER_OF_COLOR_PLANES       $number_of_color_planes   
      set_instance_parameter_value   cadence                    KERNEL_SIZE_0                [expr 2*$high_quality_line_multiplier]
      set_instance_parameter_value   cadence                    KERNEL_SIZE_1                1
      set_instance_parameter_value   cadence                    KERNEL_SIZE_2                2
      set_instance_parameter_value   cadence                    CADENCE_ALGORITHM_NAME       $cadence_algo
      set_instance_parameter_value   cadence                    MAX_LINE_LENGTH              $max_line_sample_size
      set_instance_parameter_value   cadence                    MAX_FIELD_HEIGHT             $max_height
   }

   if {$runtime_control} {
   
      add_instance                   control             	    alt_vip_control_slave          $isVersion
      set_instance_parameter_value   control                    NUM_READ_REGISTERS             0
      set_instance_parameter_value   control             	    NUM_TRIGGER_REGISTERS          9
	  #9 here was 1 in 11.1 :
      set_instance_parameter_value   control             	    NUM_RW_REGISTERS               1 
      set_instance_parameter_value   control             	    NUM_INTERRUPTS                 0
      set_instance_parameter_value   control             	    MM_CONTROL_REG_BYTES           1
      set_instance_parameter_value   control             	    MM_READ_REG_BYTES              4            
      set_instance_parameter_value   control             	    DATA_INPUT                     0
      set_instance_parameter_value   control             	    DATA_OUTPUT                    0 
      set_instance_parameter_value   control             	    FAST_REGISTER_UPDATES          0
      set_instance_parameter_value   control             	    USE_MEMORY                     0
      set_instance_parameter_value   control             	    PIPELINE_READ                  0
      set_instance_parameter_value   control             	    PIPELINE_RESPONSE              0
      set_instance_parameter_value   control             	    PIPELINE_DATA                  0
      set_instance_parameter_value   control             	    SRC_WIDTH                      8 
      set_instance_parameter_value   control             	    DST_WIDTH                      8
      set_instance_parameter_value   control             	    CONTEXT_WIDTH                  8
      set_instance_parameter_value   control             	    TASK_WIDTH                     8
      set_instance_parameter_value   control             	    RESP_SOURCE                    1
      set_instance_parameter_value   control             	    RESP_DEST                      1
      set_instance_parameter_value   control             	    RESP_CONTEXT                   1
      set_instance_parameter_value   control             	    DOUT_SOURCE                    1
      set_instance_parameter_value   control             	    NUM_BLOCKING_TRIGGER_REGISTERS 0     
      set_instance_parameter_value   control             	    MM_TRIGGER_REG_BYTES           4
      set_instance_parameter_value   control             	    MM_RW_REG_BYTES                4
      set_instance_parameter_value   control             	    MM_ADDR_WIDTH                  4
 
      add_connection   av_st_reset_bridge.out_reset             control.main_reset
      add_connection   av_st_clk_bridge.out_clk                 control.main_clock
   }

   # --------------------------------------------------------------------------------------------------
   # -- Line buffers                                                                                 --
   # --------------------------------------------------------------------------------------------------   
   
   # The EDI line buffer
   
   # ENABLE_RECEIVE_ONLY_CMD setting is irrelevant as not in "LOCKED" mode
   # NB. Center params here are irrelvant as the line buffer only sends when it is full :
   add_instance                   edi_line_buffer               alt_vip_line_buffer          $isVersion
   set_instance_parameter_value   edi_line_buffer               DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   edi_line_buffer               SYMBOLS_IN_SEQ               $symbols_in_seq
   set_instance_parameter_value   edi_line_buffer               MAX_LINE_LENGTH              $max_line_sample_size
   set_instance_parameter_value   edi_line_buffer               OUTPUT_PORTS                 2
   set_instance_parameter_value   edi_line_buffer               MODE                         "RATE_MATCHING"
   set_instance_parameter_value   edi_line_buffer               OUTPUT_MUX_SEL               "VARIABLE"
   set_instance_parameter_value   edi_line_buffer               ENABLE_RECEIVE_ONLY_CMD      1
   set_instance_parameter_value   edi_line_buffer               FIFO_SIZE                    16
   set_instance_parameter_value   edi_line_buffer               KERNEL_SIZE_0                [expr 2*$high_quality_line_multiplier]
   set_instance_parameter_value   edi_line_buffer               KERNEL_CENTER_0              [expr $high_quality_line_multiplier]
   set_instance_parameter_value   edi_line_buffer               KERNEL_SIZE_1                1
   set_instance_parameter_value   edi_line_buffer               KERNEL_START_1               [expr $high_quality_line_multiplier]
   set_instance_parameter_value   edi_line_buffer               KERNEL_CENTER_1              [expr $high_quality_line_multiplier]
   set_instance_parameter_value   edi_line_buffer               SRC_WIDTH                    8 
   set_instance_parameter_value   edi_line_buffer               DST_WIDTH                    8
   set_instance_parameter_value   edi_line_buffer               CONTEXT_WIDTH                8
   set_instance_parameter_value   edi_line_buffer               TASK_WIDTH                   8
 

   # The MA line buffer
   add_instance                   ma_line_buffer                alt_vip_line_buffer          $isVersion
   set_instance_parameter_value   ma_line_buffer                DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   ma_line_buffer                SYMBOLS_IN_SEQ               $symbols_in_seq 
   set_instance_parameter_value   ma_line_buffer                MAX_LINE_LENGTH              $max_line_sample_size
   set_instance_parameter_value   ma_line_buffer                OUTPUT_PORTS                 2           
   set_instance_parameter_value   ma_line_buffer                MODE                         "LOCKED"
   set_instance_parameter_value   ma_line_buffer                OUTPUT_MUX_SEL               "OLD"
   set_instance_parameter_value   ma_line_buffer                ENABLE_RECEIVE_ONLY_CMD      1
   set_instance_parameter_value   ma_line_buffer                FIFO_SIZE                    16
   set_instance_parameter_value   ma_line_buffer                KERNEL_SIZE_0                2
   set_instance_parameter_value   ma_line_buffer                KERNEL_CENTER_0              1
   set_instance_parameter_value   ma_line_buffer                KERNEL_SIZE_1                1
   set_instance_parameter_value   ma_line_buffer                KERNEL_START_1               1
   set_instance_parameter_value   ma_line_buffer                KERNEL_CENTER_1              1
   set_instance_parameter_value   ma_line_buffer                SRC_WIDTH                    8 
   set_instance_parameter_value   ma_line_buffer                DST_WIDTH                    8
   set_instance_parameter_value   ma_line_buffer                CONTEXT_WIDTH                8
   set_instance_parameter_value   ma_line_buffer                TASK_WIDTH                   8
     

   # --------------------------------------------------------------------------------------------------
   # -- Packet writers and packet readers                                                            --
   # --------------------------------------------------------------------------------------------------

   # The packet writer - writes incoming video to memory
   add_instance                   packet_writer                 alt_vip_packet_writer        $isVersion
   set_instance_parameter_value   packet_writer                 BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   packet_writer                 COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   packet_writer                 NUMBER_OF_COLOR_PLANES       $number_of_color_planes
   set_instance_parameter_value   packet_writer                 FIFO_DEPTH                   $write_master_fifo_depth
   set_instance_parameter_value   packet_writer                 BURST_TARGET                 $write_master_burst_target
   set_instance_parameter_value   packet_writer                 MAX_PACKET_SIZE              $max_line_sample_size
   set_instance_parameter_value   packet_writer                 SEPARATE_CLOCKS              $clocks_are_separate
   set_instance_parameter_value   packet_writer                 MM_DWIDTH                    $mem_port_width
   set_instance_parameter_value   packet_writer                 SRC_WIDTH                    8
   set_instance_parameter_value   packet_writer                 DST_WIDTH                    8
   set_instance_parameter_value   packet_writer                 CONTEXT_WIDTH                8
   set_instance_parameter_value   packet_writer                 TASK_WIDTH                   8


   # The first packet reader - recovers the past "weave" field from memory, and sometimes the current field
   add_instance                   edi_packet_reader             alt_vip_packet_reader        $isVersion
   set_instance_parameter_value   edi_packet_reader             BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   edi_packet_reader             COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   edi_packet_reader             NUMBER_OF_COLOR_PLANES       $number_of_color_planes
   set_instance_parameter_value   edi_packet_reader             FIFO_DEPTH                   $edi_read_master_fifo_depth
   set_instance_parameter_value   edi_packet_reader             BURST_TARGET                 $edi_read_master_burst_target
   set_instance_parameter_value   edi_packet_reader             MAX_PACKET_SIZE              $max_line_sample_size
   set_instance_parameter_value   edi_packet_reader             SEPARATE_CLOCKS              $clocks_are_separate
   set_instance_parameter_value   edi_packet_reader             MM_DWIDTH                    $mem_port_width
   set_instance_parameter_value   edi_packet_reader             SRC_WIDTH                    8
   set_instance_parameter_value   edi_packet_reader             DST_WIDTH                    8
   set_instance_parameter_value   edi_packet_reader             CONTEXT_WIDTH                8
   set_instance_parameter_value   edi_packet_reader             TASK_WIDTH                   8
   
   # The second packet reader - recovers the previous frame (field3 and field4) from memory, and sometimes the current field
   add_instance                   ma_packet_reader              alt_vip_packet_reader        $isVersion
   set_instance_parameter_value   ma_packet_reader              BITS_PER_SYMBOL              $bits_per_symbol   
   set_instance_parameter_value   ma_packet_reader              COLOR_PLANES_ARE_IN_PARALLEL $are_in_par
   set_instance_parameter_value   ma_packet_reader              NUMBER_OF_COLOR_PLANES       $number_of_color_planes
   set_instance_parameter_value   ma_packet_reader              FIFO_DEPTH                   $ma_read_master_fifo_depth
   set_instance_parameter_value   ma_packet_reader              BURST_TARGET                 $ma_read_master_burst_target
   set_instance_parameter_value   ma_packet_reader              MAX_PACKET_SIZE              $max_line_sample_size
   set_instance_parameter_value   ma_packet_reader              SEPARATE_CLOCKS              $clocks_are_separate
   set_instance_parameter_value   ma_packet_reader              MM_DWIDTH                    $mem_port_width
   set_instance_parameter_value   ma_packet_reader              SRC_WIDTH                    8
   set_instance_parameter_value   ma_packet_reader              DST_WIDTH                    8
   set_instance_parameter_value   ma_packet_reader              CONTEXT_WIDTH                8
   set_instance_parameter_value   ma_packet_reader              TASK_WIDTH                   8
   
   # The motion writer used by the motion detect block when motion bleed is on
   add_instance                   motion_writer                 alt_vip_packet_writer        $isVersion
   # Motion values stored in memory are 8-bit per pixel:
   set_instance_parameter_value   motion_writer                 BITS_PER_SYMBOL              8   
   set_instance_parameter_value   motion_writer                 COLOR_PLANES_ARE_IN_PARALLEL 1
   set_instance_parameter_value   motion_writer                 NUMBER_OF_COLOR_PLANES       1
   set_instance_parameter_value   motion_writer                 FIFO_DEPTH                   $motion_write_fifo_depth
   set_instance_parameter_value   motion_writer                 BURST_TARGET                 $motion_write_burst_target
   set_instance_parameter_value   motion_writer                 MAX_PACKET_SIZE              $max_width
   set_instance_parameter_value   motion_writer                 SEPARATE_CLOCKS              $clocks_are_separate
   set_instance_parameter_value   motion_writer                 MM_DWIDTH                    $mem_port_width
   set_instance_parameter_value   motion_writer                 SRC_WIDTH                    8
   set_instance_parameter_value   motion_writer                 DST_WIDTH                    8
   set_instance_parameter_value   motion_writer                 CONTEXT_WIDTH                8
   set_instance_parameter_value   motion_writer                 TASK_WIDTH                   8
   
   # The motion reader used by the motion detect block when motion bleed is on
   add_instance                   motion_reader                 alt_vip_packet_reader        $isVersion
   # Motion values stored in memory are 8-bit per pixel:
   set_instance_parameter_value   motion_reader                 BITS_PER_SYMBOL              8   
   set_instance_parameter_value   motion_reader                 COLOR_PLANES_ARE_IN_PARALLEL 1
   set_instance_parameter_value   motion_reader                 NUMBER_OF_COLOR_PLANES       1
   set_instance_parameter_value   motion_reader                 FIFO_DEPTH                   $motion_read_fifo_depth
   set_instance_parameter_value   motion_reader                 BURST_TARGET                 $motion_read_burst_target
   set_instance_parameter_value   motion_reader                 MAX_PACKET_SIZE              $max_width
   set_instance_parameter_value   motion_reader                 SEPARATE_CLOCKS              $clocks_are_separate
   set_instance_parameter_value   motion_reader                 MM_DWIDTH                    $mem_port_width
   set_instance_parameter_value   motion_reader                 SRC_WIDTH                    8
   set_instance_parameter_value   motion_reader                 DST_WIDTH                    8
   set_instance_parameter_value   motion_reader                 CONTEXT_WIDTH                8
   set_instance_parameter_value   motion_reader                 TASK_WIDTH                   8


   # --------------------------------------------------------------------------------------------------
   # -- Routing, duplicator and muxes                                                                --
   # --------------------------------------------------------------------------------------------------

   # The video input duplicator (-> packet writer and -> dil algorithm)
   add_instance                   video_in_duplicator           alt_vip_duplicator           $isVersion 
   set_instance_parameter_value   video_in_duplicator           DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   video_in_duplicator           USE_COMMAND                  0
   set_instance_parameter_value   video_in_duplicator           DEPTH                        4
   set_instance_parameter_value   video_in_duplicator           DUPLICATOR_FANOUT            3
   set_instance_parameter_value   video_in_duplicator           REGISTER_OUTPUT              1
   set_instance_parameter_value   video_in_duplicator           PIPELINE_READY               1
   set_instance_parameter_value   video_in_duplicator           SRC_WIDTH                    8
   set_instance_parameter_value   video_in_duplicator           DST_WIDTH                    8
   set_instance_parameter_value   video_in_duplicator           CONTEXT_WIDTH                8
   set_instance_parameter_value   video_in_duplicator           TASK_WIDTH                   8
   set_instance_parameter_value   video_in_duplicator           USER_WIDTH                   0

   # Duplicator for the "current" field - routed both to the motion detection and the main algorithmic blocks
   # and optionally the cadence detection block
   add_instance                   edi_line_buffer_duplicator    alt_vip_duplicator           $isVersion
   set_instance_parameter_value   edi_line_buffer_duplicator    DATA_WIDTH                   [expr $video_data_width*2*$high_quality_line_multiplier]
   set_instance_parameter_value   edi_line_buffer_duplicator    USE_COMMAND                  0
   set_instance_parameter_value   edi_line_buffer_duplicator    DEPTH                        16
   set_instance_parameter_value   edi_line_buffer_duplicator    DUPLICATOR_FANOUT            [expr $cadence_detect ? 3 : 2]
   set_instance_parameter_value   edi_line_buffer_duplicator    REGISTER_OUTPUT              1
   set_instance_parameter_value   edi_line_buffer_duplicator    PIPELINE_READY               1
   set_instance_parameter_value   edi_line_buffer_duplicator    SRC_WIDTH                    8
   set_instance_parameter_value   edi_line_buffer_duplicator    DST_WIDTH                    8
   set_instance_parameter_value   edi_line_buffer_duplicator    CONTEXT_WIDTH                8
   set_instance_parameter_value   edi_line_buffer_duplicator    TASK_WIDTH                   8
   set_instance_parameter_value   edi_line_buffer_duplicator    USER_WIDTH                   0

   # Duplicator/router for the first frame
   # weave field is routed both to the motion detection and the main algorithmic blocks (and optionally cadence detector)
   # current field may be routed the the edi line buffer in the future
   add_instance                   edi_packet_reader_duplicator  alt_vip_duplicator           $isVersion
   set_instance_parameter_value   edi_packet_reader_duplicator  DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   edi_packet_reader_duplicator  DEPTH                        16
   set_instance_parameter_value   edi_packet_reader_duplicator  USE_COMMAND                  0
   set_instance_parameter_value   edi_packet_reader_duplicator  DUPLICATOR_FANOUT            [expr $cadence_detect ? 3 : 2]
   set_instance_parameter_value   edi_packet_reader_duplicator  REGISTER_OUTPUT              1
   set_instance_parameter_value   edi_packet_reader_duplicator  PIPELINE_READY               1
   set_instance_parameter_value   edi_packet_reader_duplicator  SRC_WIDTH                    8
   set_instance_parameter_value   edi_packet_reader_duplicator  DST_WIDTH                    8
   set_instance_parameter_value   edi_packet_reader_duplicator  CONTEXT_WIDTH                8
   set_instance_parameter_value   edi_packet_reader_duplicator  TASK_WIDTH                   8
   set_instance_parameter_value   edi_packet_reader_duplicator  USER_WIDTH                   0

   # Router for the second frame
   # field3 (same as current field) is routed to a line buffer since the motion detection need two lines from it
   # field4 is sent straight to the motion detector 
   add_instance                   ma_packet_reader_duplicator   alt_vip_duplicator           $isVersion
   set_instance_parameter_value   ma_packet_reader_duplicator   DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   ma_packet_reader_duplicator   DEPTH                        4
   set_instance_parameter_value   ma_packet_reader_duplicator   USE_COMMAND                  0
   set_instance_parameter_value   ma_packet_reader_duplicator   DUPLICATOR_FANOUT            2
   set_instance_parameter_value   ma_packet_reader_duplicator   REGISTER_OUTPUT              1
   set_instance_parameter_value   ma_packet_reader_duplicator   PIPELINE_READY               1
   set_instance_parameter_value   ma_packet_reader_duplicator   SRC_WIDTH                    8
   set_instance_parameter_value   ma_packet_reader_duplicator   DST_WIDTH                    8
   set_instance_parameter_value   ma_packet_reader_duplicator   CONTEXT_WIDTH                8
   set_instance_parameter_value   ma_packet_reader_duplicator   TASK_WIDTH                   8
   set_instance_parameter_value   ma_packet_reader_duplicator   USER_WIDTH                   0

   # Optional duplicator for the ma_line_buffer (->motion detector and ->cadence detector)
   if {$cadence_detect} {
      add_instance                   ma_line_buffer_duplicator     alt_vip_duplicator           $isVersion
      set_instance_parameter_value   ma_line_buffer_duplicator     DATA_WIDTH                   [expr $video_data_width* 2]
      set_instance_parameter_value   ma_line_buffer_duplicator     DEPTH                        4
      set_instance_parameter_value   ma_line_buffer_duplicator     USE_COMMAND                  0
      set_instance_parameter_value   ma_line_buffer_duplicator     DUPLICATOR_FANOUT            2
      set_instance_parameter_value   ma_line_buffer_duplicator     REGISTER_OUTPUT              1
      set_instance_parameter_value   ma_line_buffer_duplicator     PIPELINE_READY               1
      set_instance_parameter_value   ma_line_buffer_duplicator     SRC_WIDTH                    8
      set_instance_parameter_value   ma_line_buffer_duplicator     DST_WIDTH                    8
      set_instance_parameter_value   ma_line_buffer_duplicator     CONTEXT_WIDTH                8
      set_instance_parameter_value   ma_line_buffer_duplicator     TASK_WIDTH                   8
      set_instance_parameter_value   ma_line_buffer_duplicator     USER_WIDTH                   0
   }
   
   # Ouput mux - used to merge user packets/progressive passthrough and the video output from the dil algorithm 
   add_instance                   output_mux                    alt_vip_packet_mux           $isVersion
   set_instance_parameter_value   output_mux                    DATA_WIDTH                   $video_data_width
   set_instance_parameter_value   output_mux                    NUM_INPUTS                   4
   set_instance_parameter_value   output_mux                    REGISTER_OUTPUT              1
   set_instance_parameter_value   output_mux                    PIPELINE_READY               1
   set_instance_parameter_value   output_mux                    SRC_WIDTH                    8
   set_instance_parameter_value   output_mux                    DST_WIDTH                    8
   set_instance_parameter_value   output_mux                    CONTEXT_WIDTH                8
   set_instance_parameter_value   output_mux                    TASK_WIDTH                   8
   set_instance_parameter_value   output_mux                    USER_WIDTH                   0
}



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Connection of sub-components                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc dil2_composition_callback_connections {} {

   set cadence_detect               [get_parameter_value CADENCE_DETECTION]
   set runtime_control              [get_parameter_value RUNTIME_CONTROL]
   set clocks_are_separate          [get_parameter_value CLOCKS_ARE_SEPARATE]

   # --------------------------------------------------------------------------------------------------
   # -- Top-level interfaces                                                                         --
   # --------------------------------------------------------------------------------------------------
   add_interface             av_st_clock                   clock             end
   add_interface             av_st_reset                   reset             end
   
   if {$clocks_are_separate} {
     add_interface           av_mm_clock                   clock             end
     add_interface           av_mm_reset                   reset             end
   }

   add_interface             edi_read_master               avalon            master
   add_interface             ma_read_master                avalon            master
   add_interface             motion_read_master            avalon            master
   add_interface             write_master                  avalon            master
   add_interface             motion_write_master           avalon            master
   
   if {$runtime_control} {
      add_interface          control                       avalon            slave
      set_interface_property control                       export_of         control.av_mm_control
   }

   add_interface             din                           avalon_streaming  sink 
   add_interface             dout                          avalon_streaming  source

   set_interface_property    av_st_clock                   export_of         av_st_clk_bridge.in_clk
   set_interface_property    av_st_reset                   export_of         av_st_reset_bridge.in_reset
   set_interface_property    av_st_clock                   PORT_NAME_MAP     {av_st_clock in_clk}
   set_interface_property    av_st_reset                   PORT_NAME_MAP     {av_st_reset in_reset}

   if {$clocks_are_separate} {
     set_interface_property  av_mm_clock                   export_of         av_mm_clk_bridge.in_clk
     set_interface_property  av_mm_reset                   export_of         av_mm_reset_bridge.in_reset
     set_interface_property  av_mm_clock                   PORT_NAME_MAP     {av_mm_clock in_clk}
     set_interface_property  av_mm_reset                   PORT_NAME_MAP     {av_mm_reset in_reset}
   }

   set_interface_property    dout                          export_of         video_out.av_st_vid_dout
   set_interface_property    din                           export_of         video_in.av_st_vid_din
 
   set_interface_property    write_master                  export_of         packet_writer.av_mm_write_master
   set_interface_property    edi_read_master               export_of         edi_packet_reader.av_mm_read_master   
   set_interface_property    ma_read_master                export_of         ma_packet_reader.av_mm_read_master   
   set_interface_property    motion_write_master           export_of         motion_writer.av_mm_write_master
   set_interface_property    motion_read_master            export_of         motion_reader.av_mm_read_master   


   # --------------------------------------------------------------------------------------------------
   # -- Connecting clocks and resets                                                                 --
   # --------------------------------------------------------------------------------------------------
   add_connection            av_st_clk_bridge.out_clk            av_st_reset_bridge.clk
   
   if {$clocks_are_separate} {
     add_connection          av_mm_clk_bridge.out_clk            av_mm_reset_bridge.clk
   }

   add_connection            av_st_clk_bridge.out_clk            video_in.main_clock
   add_connection            av_st_reset_bridge.out_reset        video_in.main_reset
   add_connection            av_st_clk_bridge.out_clk            dil_algo.main_clock
   add_connection            av_st_reset_bridge.out_reset        dil_algo.main_reset
   add_connection            av_st_clk_bridge.out_clk            motion_detect.main_clock
   add_connection            av_st_reset_bridge.out_reset        motion_detect.main_reset
   add_connection            av_st_clk_bridge.out_clk            video_out.main_clock
   add_connection            av_st_reset_bridge.out_reset        video_out.main_reset
   add_connection            av_st_clk_bridge.out_clk            scheduler.main_clock
   add_connection            av_st_reset_bridge.out_reset        scheduler.main_reset
   if {$cadence_detect} {
      add_connection            av_st_clk_bridge.out_clk            ma_line_buffer_duplicator.main_clock
      add_connection            av_st_reset_bridge.out_reset        ma_line_buffer_duplicator.main_reset
      add_connection            av_st_clk_bridge.out_clk            cadence.main_clock
      add_connection            av_st_reset_bridge.out_reset        cadence.main_reset
   }

   add_connection            av_st_clk_bridge.out_clk            edi_line_buffer.main_clock
   add_connection            av_st_reset_bridge.out_reset        edi_line_buffer.main_reset
   add_connection            av_st_clk_bridge.out_clk            ma_line_buffer.main_clock
   add_connection            av_st_reset_bridge.out_reset        ma_line_buffer.main_reset

   add_connection            av_st_clk_bridge.out_clk            packet_writer.main_clock
   add_connection            av_st_reset_bridge.out_reset        packet_writer.main_reset
   add_connection            av_st_clk_bridge.out_clk            edi_packet_reader.main_clock
   add_connection            av_st_reset_bridge.out_reset        edi_packet_reader.main_reset
   add_connection            av_st_clk_bridge.out_clk            ma_packet_reader.main_clock
   add_connection            av_st_reset_bridge.out_reset        ma_packet_reader.main_reset
   add_connection            av_st_clk_bridge.out_clk            motion_writer.main_clock
   add_connection            av_st_reset_bridge.out_reset        motion_writer.main_reset
   add_connection            av_st_clk_bridge.out_clk            motion_reader.main_clock
   add_connection            av_st_reset_bridge.out_reset        motion_reader.main_reset

   add_connection            av_st_clk_bridge.out_clk            video_in_duplicator.main_clock
   add_connection            av_st_reset_bridge.out_reset        video_in_duplicator.main_reset
   add_connection            av_st_clk_bridge.out_clk            edi_packet_reader_duplicator.main_clock
   add_connection            av_st_reset_bridge.out_reset        edi_packet_reader_duplicator.main_reset
   add_connection            av_st_clk_bridge.out_clk            edi_line_buffer_duplicator.main_clock
   add_connection            av_st_reset_bridge.out_reset        edi_line_buffer_duplicator.main_reset
   add_connection            av_st_clk_bridge.out_clk            ma_packet_reader_duplicator.main_clock
   add_connection            av_st_reset_bridge.out_reset        ma_packet_reader_duplicator.main_reset
   add_connection            av_st_clk_bridge.out_clk            output_mux.main_clock
   add_connection            av_st_reset_bridge.out_reset        output_mux.main_reset
   
   if ($clocks_are_separate) {
     add_connection          av_mm_clk_bridge.out_clk            edi_packet_reader.av_mm_clock
     add_connection          av_mm_reset_bridge.out_reset        edi_packet_reader.av_mm_reset
     add_connection          av_mm_clk_bridge.out_clk            ma_packet_reader.av_mm_clock
     add_connection          av_mm_reset_bridge.out_reset        ma_packet_reader.av_mm_reset
     add_connection          av_mm_clk_bridge.out_clk            motion_reader.av_mm_clock
     add_connection          av_mm_reset_bridge.out_reset        motion_reader.av_mm_reset
     add_connection          av_mm_clk_bridge.out_clk            packet_writer.av_mm_clock
     add_connection          av_mm_reset_bridge.out_reset        packet_writer.av_mm_reset
     add_connection          av_mm_clk_bridge.out_clk            motion_writer.av_mm_clock
     add_connection          av_mm_reset_bridge.out_reset        motion_writer.av_mm_reset
   } 

   # --------------------------------------------------------------------------------------------------
   # -- Interblocks connections                                                                      --
   # --------------------------------------------------------------------------------------------------
   add_connection            video_in.av_st_dout                         video_in_duplicator.av_st_din         
   add_connection            video_in_duplicator.av_st_dout_0            packet_writer.av_st_din               
   add_connection            video_in_duplicator.av_st_dout_1            edi_line_buffer.av_st_din
   # user packet route
   add_connection            video_in_duplicator.av_st_dout_2            output_mux.av_st_din_0

   add_connection            edi_packet_reader.av_st_dout                edi_packet_reader_duplicator.av_st_din
   add_connection            edi_packet_reader_duplicator.av_st_dout_0   dil_algo.din_weave         
   add_connection            edi_packet_reader_duplicator.av_st_dout_1   motion_detect.av_st_field1         

   add_connection            edi_line_buffer.av_st_dout_0                edi_line_buffer_duplicator.av_st_din                              
   add_connection            edi_line_buffer.av_st_dout_1                output_mux.av_st_din_1              
                             
   add_connection            edi_line_buffer_duplicator.av_st_dout_0     dil_algo.din_bob
   add_connection            edi_line_buffer_duplicator.av_st_dout_1     motion_detect.av_st_field0  
   
   add_connection            ma_packet_reader.av_st_dout                 ma_packet_reader_duplicator.av_st_din   
   add_connection            ma_packet_reader_duplicator.av_st_dout_0    ma_line_buffer.av_st_din            
   add_connection            ma_packet_reader_duplicator.av_st_dout_1    motion_detect.av_st_field3            

   if {$cadence_detect} {
      add_connection         ma_line_buffer.av_st_dout_0                 ma_line_buffer_duplicator.av_st_din                           
      add_connection         ma_line_buffer_duplicator.av_st_dout_0      motion_detect.av_st_field2
   } else {
      add_connection         ma_line_buffer.av_st_dout_0                 motion_detect.av_st_field2
   }
   add_connection            ma_line_buffer.av_st_dout_1                 output_mux.av_st_din_2

   add_connection            motion_reader.av_st_dout                    motion_detect.av_st_mem_motion_in
   add_connection            motion_detect.av_st_algo_motion_out         dil_algo.din_motion
   add_connection            motion_detect.av_st_mem_motion_out          motion_writer.av_st_din       

   add_connection            dil_algo.dout                               output_mux.av_st_din_3
   add_connection            output_mux.av_st_dout                       video_out.av_st_din                   

   if {$cadence_detect} {
      add_connection            edi_line_buffer_duplicator.av_st_dout_2     cadence.av_st_field0         
      add_connection            edi_packet_reader_duplicator.av_st_dout_2   cadence.av_st_field1         
      add_connection            ma_line_buffer_duplicator.av_st_dout_1      cadence.av_st_field2         
   }
   

   # --------------------------------------------------------------------------------------------------
   # -- Scheduler connections                                                                        --
   # --------------------------------------------------------------------------------------------------
   add_connection            scheduler.cmd0                      video_in.av_st_cmd 
   add_connection            scheduler.cmd1                      video_out.av_st_cmd 
   add_connection            scheduler.cmd2                      edi_line_buffer.av_st_cmd 
   add_connection            scheduler.cmd3                      packet_writer.av_st_cmd 
   add_connection            scheduler.cmd4                      edi_packet_reader.av_st_cmd 
   add_connection            scheduler.cmd5                      dil_algo.cmd 
   add_connection            scheduler.cmd6                      ma_line_buffer.av_st_cmd 
   add_connection            scheduler.cmd7                      motion_writer.av_st_cmd 
   add_connection            scheduler.cmd8                      ma_packet_reader.av_st_cmd 
   add_connection            scheduler.cmd9                      motion_reader.av_st_cmd 
   add_connection            scheduler.cmd11                     motion_detect.av_st_cmd
   add_connection            scheduler.cmd13                     output_mux.av_st_cmd

   add_connection            video_in.av_st_resp                 scheduler.resp0 

   if {$cadence_detect} {
      add_connection         cadence.resp                        scheduler.resp1
      add_connection         scheduler.cmd10                     cadence.cmd
   } 

   if {$runtime_control} {
      add_connection         scheduler.cmd12                     control.av_st_cmd
      add_connection         control.av_st_resp                  scheduler.resp2    
   } 

}


