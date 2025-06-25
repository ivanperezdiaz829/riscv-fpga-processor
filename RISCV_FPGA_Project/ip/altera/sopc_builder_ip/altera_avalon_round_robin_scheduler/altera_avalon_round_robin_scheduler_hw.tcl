# --------------------------------------------------------------------
#
# avalon_avalon_round_robin_scheduler component description
# @ttchong
#
# --------------------------------------------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.0
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# Parameter declaration
# --------------------------------------------------------------------
   
set MAX_CHANNELS_DEFAULT_VALUE 2
set MAX_CHANNELS_MIN_RANGE 2
set MAX_CHANNELS_MAX_RANGE 32
set USE_ALMOST_FULL_DEFAULT_VALUE 0
set USE_ALMOST_FULL_DISCRETE_VALUE(0) 0
set USE_ALMOST_FULL_DISCRETE_VALUE(1) 1

proc validate_parameter_range { parameter_name } {

   set min_range_variable_name ::${parameter_name}_MIN_RANGE
   set min_range [subst $$min_range_variable_name]
   set max_range_variable_name ::${parameter_name}_MAX_RANGE
   set max_range [subst $$max_range_variable_name]
   set parameter_value [ get_parameter_value "$parameter_name" ] 
   if { [ expr $parameter_value < $min_range ||  $parameter_value > $max_range ] } {
      send_message "error" "The value of the parameter $parameter_name is invalid. Valid values range from $min_range to $max_range"
   } 
   send_message "debug" "validate_parameter_range: parameter_name $parameter_name"
   send_message "debug" "validate_parameter_range: parameter_value $parameter_value"
   send_message "debug" "validate_parameter_range: min_range $min_range"
   send_message "debug" "validate_parameter_range: max_range $max_range"
}

proc validate_parameter_discrete_value { parameter_name } {
   
   set parameter_discrete_value_array ::${parameter_name}_DISCRETE_VALUE   
   set parameter_discrete_value_array_names [array names $parameter_discrete_value_array] 
   set parameter_discrete_value_array_names [lsort -integer $parameter_discrete_value_array_names]
   set parameter_value [ get_parameter_value "$parameter_name" ]
   send_message "debug" "validate_parameter_discrete_value: parameter_discrete_value_array $parameter_discrete_value_array"   
   send_message "debug" "validate_parameter_discrete_value: parameter_discrete_value_array_names $parameter_discrete_value_array_names"
   send_message "debug" "validate_parameter_discrete_value: parameter_value $parameter_value"
   set parameter_discrete_value_array_values ""
   set match_flag 0
   foreach parameter_discrete_value_name $parameter_discrete_value_array_names {
	  set parameter_discrete_value [subst $${parameter_discrete_value_array}(${parameter_discrete_value_name})]
      append parameter_discrete_value_array_values "${parameter_discrete_value} "
	  send_message "debug" "validate_parameter_discrete_value: parameter_discrete_value $parameter_discrete_value"
	  if { $parameter_discrete_value == $parameter_value } {
	     set match_flag 1
		 send_message "debug" "validate_parameter_discrete_value: match_flag $match_flag"
	  }
   }
   if {$match_flag != 1} {
      send_message "error" "The value of the parameter $parameter_name is invalid. Valid values are $parameter_discrete_value_array_values"
   }
}

proc validate {} {

   # Static value validation
   # -----------------------------------------------------------------
   
   validate_parameter_range "MAX_CHANNELS" 
   validate_parameter_discrete_value "USE_ALMOST_FULL"

   # dynamic value validation
   # ----------------------------------------------------------------- 
     
   set MAX_CHANNELS [ get_parameter_value "MAX_CHANNELS" ]
   set USE_ALMOST_FULL [ get_parameter_value "USE_ALMOST_FULL" ]

}

proc elaborate {} {

   # non-derived parameters
   # -----------------------------------------------------------------
   
   set MAX_CHANNELS [ get_parameter_value "MAX_CHANNELS" ]
   set USE_ALMOST_FULL [ get_parameter_value "USE_ALMOST_FULL" ]

   # derived parameters
   # -----------------------------------------------------------------
   
   set CHANNEL_WIDTH [ expr int(ceil(log($MAX_CHANNELS) / log(2))) ]

   if {$CHANNEL_WIDTH > 0} {
      #set_parameter_value "CHANNEL_WIDTH" $CHANNEL_WIDTH
   } else {
      set CHANNEL_WIDTH 1
      #set_parameter_value "CHANNEL_WIDTH" 1
   }

   # interface creation
   # -----------------------------------------------------------------

   # Interface clock
   add_interface "clock" "clock" "sink" "asynchronous"
   # Ports in interface clock
   add_interface_port "clock" "clk" "clk" "input" 1
   add_interface_port "clock" "reset_n" "reset_n" "input" 1

   # Interface almost_full
   if { [expr $USE_ALMOST_FULL == 1] } {
     add_interface "almost_full" "avalon_streaming" "sink" "clock"
     set_interface_property "almost_full" "symbolsPerBeat" 1
     set_interface_property "almost_full" "dataBitsPerSymbol" 1
     set_interface_property "almost_full" "readyLatency" "0"
     set_interface_property "almost_full" "maxChannel" [ expr $MAX_CHANNELS - 1 ]
   # Ports in interface almost_full
     add_interface_port "almost_full" "almost_full_channel" "channel" "input" $CHANNEL_WIDTH
     add_interface_port "almost_full" "almost_full_data" "data" "input" 1
     add_interface_port "almost_full" "almost_full_valid" "valid" "input" 1
   }

   # Interface request
   add_interface "request" "avalon" "master" "clock"  
   set_interface_property "request" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "request" "doStreamReads" "false"
   set_interface_property "request" "linewrapBursts" "false"
   set_interface_property "request" "doStreamWrites" "false"   
   # Ports in interface request
   add_interface_port "request" "request_address" "address" "output" [ expr $CHANNEL_WIDTH + 2 ]
   add_interface_port "request" "request_write" "write" "output" 1
   add_interface_port "request" "request_writedata" "writedata" "output" 32
   add_interface_port "request" "request_waitrequest" "waitrequest" "input" 1
} 

# general module definition
# -----------------------------------------------------------------
set_module_property NAME altera_avalon_round_robin_scheduler
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Memories and Memory Controllers/On-Chip"
set_module_property DISPLAY_NAME "Avalon-ST Round Robin Scheduler"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_round_robin_scheduler.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_round_robin_scheduler
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property previewValidationCallback "validate"
set_module_property previewElaborationCallback "elaborate"
set_module_property datasheetURL "http://www.altera.com/literature/hb/nios2/qts_qii55016.pdf"
set_module_property ANALYZE_HDL false

# +-----------------------------------
# | files
# | 
add_file altera_avalon_round_robin_scheduler.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# module parameters declaration
# -----------------------------------------------------------------

   # non-derived parameters
   # -----------------------------------------------------------------

   add_parameter "MAX_CHANNELS" "integer" "$MAX_CHANNELS_DEFAULT_VALUE" ""
   set_parameter_property "MAX_CHANNELS" "visible" "true"
   set_parameter_property "MAX_CHANNELS" "displayName" "Number of channels"
   set_parameter_property "MAX_CHANNELS" "derived" "false"
   #set_parameter_property "MAX_CHANNELS" "allowedRanges" "$MAX_CHANNELS_MIN_RANGE:$MAX_CHANNELS_MAX_RANGE"

   add_parameter "USE_ALMOST_FULL" "integer" "$USE_ALMOST_FULL_DEFAULT_VALUE" ""
   set_parameter_property "USE_ALMOST_FULL" "visible" "true"
   set_parameter_property "USE_ALMOST_FULL" "displayName" "Use almost-full status"
   set_parameter_property "USE_ALMOST_FULL" "derived" "false"
   set_parameter_property "USE_ALMOST_FULL" "DISPLAY_HINT" "boolean"

   # derived parameters
   # -----------------------------------------------------------------
   
   #add_parameter "CHANNEL_WIDTH" "integer" "0" ""
   #set_parameter_property "CHANNEL_WIDTH" "visible" "true"
   #set_parameter_property "CHANNEL_WIDTH" "derived" "true"

   send_message "debug" "done general module/parameter settings"



