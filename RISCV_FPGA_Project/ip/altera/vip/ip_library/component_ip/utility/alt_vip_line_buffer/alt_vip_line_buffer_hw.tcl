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


source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information for the line buffer component                                            --
# -- This block receives lines of video data on its Avalon-ST Message Data sink, stores them and  --
# -- outputs kernels of lines through one or more Avalon-ST Message Data sources                  --
# -- Operations are controlled through an Avalon-ST Message Command sink                          --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Common module properties for VIP components
declare_general_component_info

set_module_property NAME alt_vip_line_buffer
set_module_property DISPLAY_NAME "Video Line Buffer"
set_module_property DESCRIPTION "This block receives lines of video data on its Avalon-ST Message Data sink,
\stores them and outputs kernels of lines through one or more Avalon-ST Message Data sources.
\Operations are controlled through an Avalon-ST Message Command sink"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_line_buffer.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_line_buffer

set_module_property ELABORATION_CALLBACK line_buffer_elaboration_callback
set_module_property VALIDATION_CALLBACK line_buffer_validation_callback
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_alt_vip_common_fifo2_files ../../..
add_file src_hdl/alt_vip_line_buffer_controller.sv $add_file_attribute
add_file src_hdl/alt_vip_line_buffer_mem_block.sv $add_file_attribute
add_file src_hdl/alt_vip_line_buffer_multicaster.sv $add_file_attribute
add_file src_hdl/alt_vip_line_buffer.sv $add_file_attribute
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_data_width_parameters
add_symbols_in_seq_parameters
add_max_line_length_parameters

add_parameter OUTPUT_PORTS INTEGER 1 "Number of data outputs"
set_parameter_property OUTPUT_PORTS ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
set_parameter_property OUTPUT_PORTS DISPLAY_NAME "Output ports"
set_parameter_property OUTPUT_PORTS AFFECTS_GENERATION false
set_parameter_property OUTPUT_PORTS HDL_PARAMETER true
set_parameter_property OUTPUT_PORTS AFFECTS_ELABORATION true
set_parameter_property OUTPUT_PORTS DERIVED false

add_parameter MODE STRING LOCKED "Mode of operation: LOCKED means write and read operations execute in lock step.
\RATE_MATCHING means the read and writes may execute at different rates, with the write able to lag the read and vice versa"
set_parameter_property MODE ALLOWED_RANGES {LOCKED RATE_MATCHING}
set_parameter_property MODE DISPLAY_NAME "Mode of operation"
set_parameter_property MODE AFFECTS_GENERATION false
set_parameter_property MODE HDL_PARAMETER true
set_parameter_property MODE AFFECTS_ELABORATION true
set_parameter_property MODE DERIVED false

add_parameter ENABLE_RECEIVE_ONLY_CMD INTEGER 0 "Enables the 'Receive Only' and 'Receive and Send' commands in LOCKED mode.
\These commands are always enabled in RATE_MATCHING mode"
set_parameter_property ENABLE_RECEIVE_ONLY_CMD ALLOWED_RANGES 0:1
set_parameter_property ENABLE_RECEIVE_ONLY_CMD DISPLAY_NAME "Enable receive without shift commands"
set_parameter_property ENABLE_RECEIVE_ONLY_CMD AFFECTS_GENERATION false
set_parameter_property ENABLE_RECEIVE_ONLY_CMD DISPLAY_HINT boolean
set_parameter_property ENABLE_RECEIVE_ONLY_CMD HDL_PARAMETER true
set_parameter_property ENABLE_RECEIVE_ONLY_CMD AFFECTS_ELABORATION false
set_parameter_property ENABLE_RECEIVE_ONLY_CMD DERIVED false

add_parameter OUTPUT_MUX_SEL STRING VARIABLE "When doing a send combined with a receive or shift the user can either select that the kernel after the receive/shift is sent (NEW),
\the kernel before the receive/shift is sent (OLD) or this can be set at runtime using a command argument (VARIABLE)"
set_parameter_property OUTPUT_MUX_SEL ALLOWED_RANGES {VARIABLE OLD NEW}
set_parameter_property OUTPUT_MUX_SEL DISPLAY_NAME "Output data sent when exectuing a send combined with a shift and/or receive"
set_parameter_property OUTPUT_MUX_SEL AFFECTS_GENERATION false
set_parameter_property OUTPUT_MUX_SEL HDL_PARAMETER true
set_parameter_property OUTPUT_MUX_SEL AFFECTS_ELABORATION false
set_parameter_property OUTPUT_MUX_SEL DERIVED false

add_parameter OUTPUT_OPTION STRING UNPIPELINED "Selects the registering option used for every output port.
\'Unpipelined' leaves the output Avalon-ST ready signals unpipelined.
\'Pipelined' adds an extra register stage to each output so the Avalon-ST ready signal my be pipelined.
\'Add FIFOs' may be selected if the number of output ports is greater than one.
\This will add a FIFO of the specified size to each output port and also pipeline the Avalon-ST ready signals."
set_parameter_property OUTPUT_OPTION ALLOWED_RANGES {UNPIPELINED PIPELINED}
set_parameter_property OUTPUT_OPTION DISPLAY_NAME "Output register option"
set_parameter_property OUTPUT_OPTION AFFECTS_GENERATION false
set_parameter_property OUTPUT_OPTION HDL_PARAMETER false
set_parameter_property OUTPUT_OPTION AFFECTS_ELABORATION true
set_parameter_property OUTPUT_OPTION DERIVED false

add_parameter FIFO_SIZE INTEGER 3 "Size of the output data FIFOs"
set_parameter_property FIFO_SIZE ALLOWED_RANGES 1:2600
set_parameter_property FIFO_SIZE DISPLAY_NAME "Output FIFO size"
set_parameter_property FIFO_SIZE AFFECTS_GENERATION false
set_parameter_property FIFO_SIZE HDL_PARAMETER true
set_parameter_property FIFO_SIZE AFFECTS_ELABORATION false
set_parameter_property FIFO_SIZE DERIVED false
set_parameter_property FIFO_SIZE VISIBLE false

add_parameter KERNEL_SIZE_0 INTEGER 8 "Number of lines in the kernel of data output 0"
set_parameter_property KERNEL_SIZE_0 ALLOWED_RANGES 1:100
set_parameter_property KERNEL_SIZE_0 DISPLAY_NAME "Kernel size 0"
set_parameter_property KERNEL_SIZE_0 AFFECTS_GENERATION false
set_parameter_property KERNEL_SIZE_0 HDL_PARAMETER true
set_parameter_property KERNEL_SIZE_0 AFFECTS_ELABORATION true
set_parameter_property KERNEL_SIZE_0 DERIVED false

add_parameter KERNEL_CENTER_0 INTEGER 3 "Center line of the kernel for data output 0"
set_parameter_property KERNEL_CENTER_0 ALLOWED_RANGES 0:100
set_parameter_property KERNEL_CENTER_0 DISPLAY_NAME "Kernel center 0"
set_parameter_property KERNEL_CENTER_0 AFFECTS_GENERATION false
set_parameter_property KERNEL_CENTER_0 HDL_PARAMETER true
set_parameter_property KERNEL_CENTER_0 AFFECTS_ELABORATION false
set_parameter_property KERNEL_CENTER_0 DERIVED false

for { set i 1 } { $i < 16} { incr i } {
	if { $i == 10 } {
		set end_char A
	} else {
		if { $i == 11} {
 			set end_char B
		} else {
			if { $i == 12} {
				set end_char C
			} else {
				if { $i == 13} {
					set end_char D
				} else {
					if { $i == 14} {
						set end_char E
					} else {
						if { $i == 15} {
							set end_char F
						} else {
							set end_char $i
						}
					}
				}
			}
		}
	}

	add_parameter KERNEL_SIZE_$end_char INTEGER 8 "Number of lines in the kernel of data output $i"
	set_parameter_property KERNEL_SIZE_$end_char ALLOWED_RANGES 1:100
	set_parameter_property KERNEL_SIZE_$end_char DISPLAY_NAME "Kernel size $i"
	set_parameter_property KERNEL_SIZE_$end_char AFFECTS_GENERATION false
	set_parameter_property KERNEL_SIZE_$end_char HDL_PARAMETER true
	set_parameter_property KERNEL_SIZE_$end_char AFFECTS_ELABORATION true
	set_parameter_property KERNEL_SIZE_$end_char DERIVED false
	set_parameter_property KERNEL_SIZE_$end_char VISIBLE false

	add_parameter KERNEL_START_$end_char INTEGER 0 "Start line of the kernel for data output $i"
	set_parameter_property KERNEL_START_$end_char ALLOWED_RANGES 0:100
	set_parameter_property KERNEL_START_$end_char DISPLAY_NAME "Kernel start $i"
	set_parameter_property KERNEL_START_$end_char AFFECTS_GENERATION false
	set_parameter_property KERNEL_START_$end_char HDL_PARAMETER true
	set_parameter_property KERNEL_START_$end_char AFFECTS_ELABORATION false
	set_parameter_property KERNEL_START_$end_char DERIVED false
	set_parameter_property KERNEL_START_$end_char VISIBLE false

	add_parameter KERNEL_CENTER_$end_char INTEGER 3 "Center line of the kernel for data output $i"
	set_parameter_property KERNEL_CENTER_$end_char ALLOWED_RANGES 0:100
	set_parameter_property KERNEL_CENTER_$end_char DISPLAY_NAME "Kernel center $i"
	set_parameter_property KERNEL_CENTER_$end_char AFFECTS_GENERATION false
	set_parameter_property KERNEL_CENTER_$end_char HDL_PARAMETER true
	set_parameter_property KERNEL_CENTER_$end_char AFFECTS_ELABORATION false
	set_parameter_property KERNEL_CENTER_$end_char DERIVED false
	set_parameter_property KERNEL_CENTER_$end_char VISIBLE false

}

add_av_st_event_parameters

add_parameter SOURCE_ADDRESS INTEGER 0 "Source ID of line buffer on dout interface(s)"
set_parameter_property SOURCE_ADDRESS DISPLAY_NAME "Line buffer ID"
set_parameter_property SOURCE_ADDRESS AFFECTS_GENERATION false
set_parameter_property SOURCE_ADDRESS HDL_PARAMETER true
set_parameter_property SOURCE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property SOURCE_ADDRESS DERIVED false

add_parameter ENABLE_FIFOS INTEGER 0
set_parameter_property ENABLE_FIFOS ALLOWED_RANGES 0:1
set_parameter_property ENABLE_FIFOS AFFECTS_GENERATION false
set_parameter_property ENABLE_FIFOS HDL_PARAMETER true
set_parameter_property ENABLE_FIFOS AFFECTS_ELABORATION false
set_parameter_property ENABLE_FIFOS DERIVED true
set_parameter_property ENABLE_FIFOS VISIBLE false

add_parameter ENABLE_PIPELINE_REG INTEGER 0
set_parameter_property ENABLE_PIPELINE_REG ALLOWED_RANGES 0:1
set_parameter_property ENABLE_PIPELINE_REG AFFECTS_GENERATION false
set_parameter_property ENABLE_PIPELINE_REG HDL_PARAMETER true
set_parameter_property ENABLE_PIPELINE_REG AFFECTS_ELABORATION false
set_parameter_property ENABLE_PIPELINE_REG DERIVED true
set_parameter_property ENABLE_PIPELINE_REG VISIBLE false

# | connection point clock_reset

add_main_clock_port

# | Dynamic ports (elaboration callback)
proc line_buffer_elaboration_callback {} {

	set output_ports [get_parameter_value OUTPUT_PORTS]
	if { $output_ports > 1 } {
		set_parameter_property OUTPUT_OPTION ALLOWED_RANGES {UNPIPELINED PIPELINED ADD_FIFOS}
	} else {
		set_parameter_property OUTPUT_OPTION ALLOWED_RANGES {UNPIPELINED PIPELINED}
	}

	#only show the FIFO size parameter if FIFOs are enabled
	set_parameter_property FIFO_SIZE VISIBLE false
	#OUTPUT_OPTION sets two derived paramters
	set output_option               [get_parameter_value OUTPUT_OPTION]
	set_parameter_value ENABLE_FIFOS 0
	set_parameter_value ENABLE_PIPELINE_REG 0
	if { [string compare $output_option ADD_FIFOS] == 0 } {
		set_parameter_property FIFO_SIZE VISIBLE true
		set_parameter_value ENABLE_FIFOS 1
	} else {
		if { [string compare $output_option PIPELINED] == 0 } {
			set_parameter_value ENABLE_PIPELINE_REG 1
		}
	}

	#setting up the command port
   set src_width                   [get_parameter_value SRC_WIDTH]
 	set dst_width                   [get_parameter_value DST_WIDTH]
 	set context_width               [get_parameter_value CONTEXT_WIDTH]
 	set task_width                  [get_parameter_value TASK_WIDTH]
   set src_id                      [get_parameter_value SOURCE_ADDRESS]
   add_av_st_cmd_sink_port   av_st_cmd   1   $dst_width   $src_width   $task_width   $context_width   main_clock   $src_id

	#setting up the data input port
   set data_width [get_parameter_value DATA_WIDTH]
   add_av_st_data_sink_port   av_st_din   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id

	for { set i 1 } { $i < 10 } { incr i } {
		set_parameter_property KERNEL_CENTER_$i VISIBLE false
		set_parameter_property KERNEL_START_$i VISIBLE false
		set_parameter_property KERNEL_SIZE_$i VISIBLE false
	}
	set_parameter_property KERNEL_CENTER_A VISIBLE false
	set_parameter_property KERNEL_START_A VISIBLE false
	set_parameter_property KERNEL_SIZE_A VISIBLE false
	set_parameter_property KERNEL_CENTER_B VISIBLE false
	set_parameter_property KERNEL_START_B VISIBLE false
	set_parameter_property KERNEL_SIZE_B VISIBLE false
	set_parameter_property KERNEL_CENTER_C VISIBLE false
	set_parameter_property KERNEL_START_C VISIBLE false
	set_parameter_property KERNEL_SIZE_C VISIBLE false
	set_parameter_property KERNEL_CENTER_D VISIBLE false
	set_parameter_property KERNEL_START_D VISIBLE false
	set_parameter_property KERNEL_SIZE_D VISIBLE false
	set_parameter_property KERNEL_CENTER_E VISIBLE false
	set_parameter_property KERNEL_START_E VISIBLE false
	set_parameter_property KERNEL_SIZE_E VISIBLE false
	set_parameter_property KERNEL_CENTER_F VISIBLE false
	set_parameter_property KERNEL_START_F VISIBLE false
	set_parameter_property KERNEL_SIZE_F VISIBLE false


      #setting up the data output port(s)
      set data_start 0
      for { set i 0 } { $i < $output_ports } { incr i } {

   		if { $i == 10 } {
   			set end_char A
   		} else {
   			if { $i == 11} {
    				set end_char B
   			} else {
   				if { $i == 12} {
   					set end_char C
   				} else {
   					if { $i == 13} {
   						set end_char D
   					} else {
   						if { $i == 14} {
   							set end_char E
   						} else {
   							if { $i == 15} {
   								set end_char F
   							} else {
   								set end_char $i
   							}
   						}
   					}
   				}
   			}
   		}
		
   		if { $i > 0 } {
   			set_parameter_property KERNEL_CENTER_$end_char VISIBLE true
   			set_parameter_property KERNEL_START_$end_char VISIBLE true
   			set_parameter_property KERNEL_SIZE_$end_char VISIBLE true
   		}

         set data_width_out [expr {[get_parameter_value KERNEL_SIZE_$end_char] * $data_width}]
         set control_width [expr $dst_width + $src_width + $task_width + $context_width]
         add_interface av_st_dout_$i avalon_streaming start
	      set_interface_property av_st_dout_$i readyLatency 0
	      set_interface_property av_st_dout_$i ASSOCIATED_CLOCK main_clock
	      set_interface_property av_st_dout_$i ENABLED true

         add_interface_port av_st_dout_$i av_st_dout_valid_$i valid Output 1
         add_interface_port av_st_dout_$i av_st_dout_ready_$i ready Input 1
         add_interface_port av_st_dout_$i av_st_dout_startofpacket_$i startofpacket Output 1
         add_interface_port av_st_dout_$i av_st_dout_endofpacket_$i endofpacket Output 1
         set_port_property av_st_dout_ready_$i FRAGMENT_LIST "av_st_dout_ready@$i"
         set_port_property av_st_dout_valid_$i FRAGMENT_LIST "av_st_dout_valid@$i"
         set_port_property av_st_dout_startofpacket_$i FRAGMENT_LIST "av_st_dout_startofpacket@$i"
         set_port_property av_st_dout_endofpacket_$i FRAGMENT_LIST "av_st_dout_endofpacket@$i"

         add_interface_port av_st_dout_$i av_st_dout_data_$i data Output [expr $data_width_out + $control_width]
         set data_end [expr $data_start + $data_width_out + $control_width]
         set_port_property av_st_dout_data_$i FRAGMENT_LIST "av_st_dout_data@[expr $data_end-1]:$data_start"
         set data_start $data_end

         altera_pe_message_format::set_message_property          av_st_dout_$i                  PEID             $src_id
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i argument         SYMBOLS_PER_BEAT 1
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i argument         SYMBOL_WIDTH     $data_width_out
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i destination      BASE            0
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i destination      SYMBOL_WIDTH    $dst_width
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i source           BASE            $dst_width
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i source           SYMBOL_WIDTH    $src_width
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i taskid           BASE            [expr $dst_width + $src_width]
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i taskid           SYMBOL_WIDTH    $task_width
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i context          BASE            [expr $dst_width + $src_width + $task_width]
         altera_pe_message_format::set_message_subfield_property av_st_dout_$i context          SYMBOL_WIDTH    $context_width
         altera_pe_message_format::validate_and_create av_st_dout_$i

      }

}

proc line_buffer_validation_callback {} {

   set task_width [get_parameter_value TASK_WIDTH]
   if {$task_width < 4} {
      send_message Error "Task ID Width for the command interface must be at least 4 bits"
   }	

   set limit [get_parameter_value SRC_WIDTH]
   set limit [expr {pow(2, $limit)}]
   set limit [expr {$limit - 1}]
   set value [get_parameter_value SOURCE_ADDRESS]
   if { $value > $limit } {
         send_message Warning "Source ID is outside the range supported by the specified dout Source ID width"
   }
   if { $value < 0 } {
         send_message Warning "Source ID is outside the range supported by the specified dout Source ID width"
   }
	
	set output_ports [get_parameter_value OUTPUT_PORTS]
	for { set i 0 } { $i < $output_ports } { incr i } {

		if { $i == 10 } {
			set end_char A
		} else {
			if { $i == 11} {
 				set end_char B
			} else {
				if { $i == 12} {
					set end_char C
				} else {
					if { $i == 13} {
						set end_char D
					} else {
						if { $i == 14} {
							set end_char E
						} else {
							if { $i == 15} {
								set end_char F
							} else {
								set end_char $i
							}
						}
					}
				}
			}
		}
		
		if { $i > 0 } {
			set start [get_parameter_value KERNEL_START_$end_char]
			set end [expr $start + [get_parameter_value KERNEL_SIZE_$end_char] - 1]
			set center [get_parameter_value KERNEL_CENTER_$end_char]
			if { $center > $end } {
				send_message Error "The center line for the kernel of output port $i must be between 'Kernel $i start' and ('Kernel $i start' + 'Kernel $i size')"
			}
			if { $center < $start } {
				send_message Error "The center line for the kernel of output port $i must be between 'Kernel $i start' and ('Kernel $i start' + 'Kernel $i size')"
			}
		}
	}


}
