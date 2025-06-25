# Module altera_avalon_video_sync_generator
set_module_property "TOP_LEVEL_HDL_FILE" "altera_avalon_video_sync_generator.v"
set_module_property "TOP_LEVEL_HDL_MODULE" "altera_avalon_video_sync_generator"
set_module_property className "altera_avalon_video_sync_generator"
set_module_property displayName "Video Sync Generator"
set_module_property "DESCRIPTION" "Altera Video Sync Generator"
set_module_property instantiateInSystemModule "true"
set_module_property version "13.1"
set_module_property group "Peripherals/Display"
set_module_property editable "false"
set_module_property author "Altera Corporation"
set_module_property datasheetURL "http://www.altera.com/literature/hb/nios2/qts_qii55006.pdf"
set_module_property simulationModelInVHDL "true"
set_module_property simulationModelInVerilog "true"
set_module_property simulationFiles [ list "altera_avalon_video_sync_generator.v" ]
set_module_property synthesisFiles [ list "altera_avalon_video_sync_generator.v" ]

set_module_property previewElaborationCallback "elaborate"

# Module parameters
set parameter_name "DATA_STREAM_BIT_WIDTH"
add_parameter $parameter_name "integer" "8" "The width of the data stream"
set_parameter_property $parameter_name displayName "Data Stream Bit Width"
set_parameter_property $parameter_name allowedRanges [ list "1:64" ]

set parameter_name "BEATS_PER_PIXEL"
add_parameter $parameter_name "integer" "3" "The number of Avalon Streaming beats per pixel"
set_parameter_property $parameter_name displayName "Beats per Pixel"
set_parameter_property $parameter_name allowedRanges [ list "1:5" ]

set parameter_name "NUM_COLUMNS"
add_parameter $parameter_name "integer" "800" "The number of columns"
set_parameter_property $parameter_name displayName "Number of Columns"

set parameter_name "NUM_ROWS"
add_parameter $parameter_name "integer" "480" "The number of rows"
set_parameter_property $parameter_name displayName "Number of Rows"

set parameter_name "H_BLANK_PIXELS"
add_parameter $parameter_name "integer" "216" "The number of horizontal blank pixels"
set_parameter_property $parameter_name displayName "Horizontal Blank Pixels"

set parameter_name "H_FRONT_PORCH_PIXELS"
add_parameter $parameter_name "integer" "40" "The number of horizontal front porch pixels"
set_parameter_property $parameter_name displayName "Horizontal Front Porch Pixels"

set parameter_name "H_SYNC_PULSE_PIXELS"
add_parameter $parameter_name "integer" "1" "The width of horizontal sync pulse in pixels"
set_parameter_property $parameter_name displayName "Horizontal Sync Pulse Pixels"

set parameter_name "H_SYNC_PULSE_POLARITY"
add_parameter $parameter_name "integer" "0" "The polarity of horizontal sync pulse"
set_parameter_property $parameter_name displayName "Horizontal Sync Pulse Polarity"

set parameter_name "V_BLANK_LINES"
add_parameter $parameter_name "integer" "35" "The number of vertical blank lines"
set_parameter_property $parameter_name displayName "Vertical Blank Lines"

set parameter_name "V_FRONT_PORCH_LINES"
add_parameter $parameter_name "integer" "10" "The number of vertical front porch lines"
set_parameter_property $parameter_name displayName "Vertical Front Porch Lines"

set parameter_name "V_SYNC_PULSE_LINES"
add_parameter $parameter_name "integer" "1" "The width of vertical sync pulse in lines"
set_parameter_property $parameter_name displayName "Vertical Sync Pulse Lines"

set parameter_name "V_SYNC_PULSE_POLARITY"
add_parameter $parameter_name "integer" "0" "The polarity of vertical sync pulse"
set_parameter_property $parameter_name displayName "Vertical Sync Pulse Polarity"
 
set parameter_name "TOTAL_HSCAN_PIXELS"
add_parameter $parameter_name "integer" "1056" "The total number of horizontal scan pixels"
set_parameter_property $parameter_name displayName "Total Horizontal Scan Pixels"

set parameter_name "TOTAL_VSCAN_LINES"
add_parameter $parameter_name "integer" "525" "The total number of vertical scan lines"
set_parameter_property $parameter_name displayName "Total Vertical Scan Lines"

proc elaborate {} {

	# AvalonST clock interface
	add_interface "clk" "clock" "end"
	add_interface_port "clk" "clk" "clk" "input" "1"
	add_interface_port "clk" "reset_n" "reset_n" "input" "1"


        set data_stream_bit_width [ get_parameter_value "DATA_STREAM_BIT_WIDTH" ]

	# AvalonST sink interface
	add_interface "in" "avalon_streaming" "sink" "clk"
	set_interface_property "in" "symbolsPerBeat" "1"
	set_interface_property "in" "dataBitsPerSymbol" "$data_stream_bit_width"
	set_interface_property "in" "readyLatency" "0"
	set_interface_property "in" "maxChannel" "0"


	add_interface_port "in" "ready" "ready"          "output" 1
	add_interface_port "in" "valid" "valid"          "input"  1
	add_interface_port "in" "data" "data"            "input"  $data_stream_bit_width
	add_interface_port "in" "eop" "endofpacket"      "input"  1
	add_interface_port "in" "sop" "startofpacket"    "input"  1
	add_interface_port "in" "empty" "empty"          "input"  1




	
	# sync export interface
	add_interface "sync" "conduit" "output"
	add_interface_port "sync" "RGB_OUT" "export"   "output" $data_stream_bit_width
	add_interface_port "sync" "HD" "export"        "output" 1
	add_interface_port "sync" "VD" "export"        "output" 1
	add_interface_port "sync" "DEN" "export"       "output" 1



}	
	
