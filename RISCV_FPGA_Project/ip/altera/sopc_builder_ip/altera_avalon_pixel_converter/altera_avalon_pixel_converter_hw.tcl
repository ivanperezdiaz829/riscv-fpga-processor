# Module altera_avalon_pixel_converter
set_module_property "TOP_LEVEL_HDL_FILE" "altera_avalon_pixel_converter.v"
set_module_property "TOP_LEVEL_HDL_MODULE" "altera_avalon_pixel_converter"
set_module_property className "altera_avalon_pixel_converter"
set_module_property displayName "Pixel Converter (BGR0 --> BGR)"
set_module_property "DESCRIPTION" "Altera Avalon-ST Pixel Converter"
set_module_property instantiateInSystemModule "true"
set_module_property version "13.1"
set_module_property group "Peripherals/Display"
set_module_property editable "false"
set_module_property author "Altera Corporation"
set_module_property datasheetURL "http://www.altera.com/literature/hb/nios2/qts_qii55006.pdf"
set_module_property simulationModelInVHDL "true"
set_module_property simulationModelInVerilog "true"
set_module_property simulationFiles [ list "altera_avalon_pixel_converter.v" ]
set_module_property synthesisFiles [ list "altera_avalon_pixel_converter.v" ]

set parameter_name "SOURCE_SYMBOLS_PER_BEAT"
add_parameter $parameter_name "integer" "3" "Source symbols per beat"
set_parameter_property $parameter_name displayName "Source symbols per beat"
set_parameter_property $parameter_name allowedRanges [ list 1 3 ]

set_module_property previewElaborationCallback "elaborate"

proc elaborate {} {
	# AvalonST clock interface
	add_interface "clk" "clock" "end"
	add_interface_port "clk" "clk" "clk" "input" "1"
	add_interface_port "clk" "reset_n" "reset_n" "input" "1"


	


	# AvalonST sink interface
	add_interface "in" "avalon_streaming" "sink" "clk"
	set_interface_property "in" "symbolsPerBeat" "4"
	set_interface_property "in" "dataBitsPerSymbol" "8"
	set_interface_property "in" "readyLatency" "0"
	set_interface_property "in" "maxChannel" "0"
	
	add_interface_port "in" "ready_out" "ready"        "output" 1
	add_interface_port "in" "valid_in" "valid"         "input"  1
	add_interface_port "in" "data_in" "data"           "input"  32
	add_interface_port "in" "eop_in" "endofpacket"     "input"  1
	add_interface_port "in" "sop_in" "startofpacket"   "input"  1
	add_interface_port "in" "empty_in" "empty"         "input"  2




	
	# AvalonST source interface
	set source_symbols_per_beat [ get_parameter_value "SOURCE_SYMBOLS_PER_BEAT" ]
	set source_bits_per_symbol [ expr { 24 / $source_symbols_per_beat } ]

	if { [ expr $source_symbols_per_beat == 1] } {
		set source_empty_width 1
	} else {
		set source_empty_width 2
	}

	add_interface "out" "avalon_streaming" "source" "clk"
	set_interface_property "out" "symbolsPerBeat" $source_symbols_per_beat
	set_interface_property "out" "dataBitsPerSymbol" $source_bits_per_symbol
	set_interface_property "out" "readyLatency" "0"
	set_interface_property "out" "maxChannel" "0"
	
	add_interface_port "out" "ready_in" "ready"           "input" 1
	add_interface_port "out" "valid_out" "valid"          "output" 1
	add_interface_port "out" "data_out" "data"            "output" 24
	add_interface_port "out" "eop_out" "endofpacket"      "output" 1
	add_interface_port "out" "sop_out" "startofpacket"    "output" 1
	add_interface_port "out" "empty_out" "empty"          "output" $source_empty_width


}
