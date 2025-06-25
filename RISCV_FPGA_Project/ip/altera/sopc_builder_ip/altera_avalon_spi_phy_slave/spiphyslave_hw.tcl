# $Id$
# $Revision$
# $Date$
#-------------------------------------------------------------------------------

set_source_file "spiphyslave.v"
set_module "SPIPhy"
set_module_description "SPI to Avalon ST Bridge"
set_module_property "className" "spislave"
set_module_property "displayName" "Avalon-ST Serial Peripheral Interface (SPI)"
set_module_property "group" "Interface Protocols/Serial"
set_module_property "instantiateInSystemModule" "true"
set_module_property "simulationModelInVHDL" "true"
set_module_property "author"  "Altera Corporation"
set_module_property "version" "13.1"
set_module_property "datasheetURL" "http://www.altera.com/literature/hb/nios2/qts_qii55009.pdf"
set_module_property "editable" "false"
add_file spiphyslave.v {SYNTHESIS SIMULATION}

# Module parameters
add_parameter "SYNC_DEPTH" "integer" "2" "Set the depth of the synchronization registers"
set_parameter_property "SYNC_DEPTH" "DISPLAY_NAME" "Depth"
set_parameter_property "SYNC_DEPTH" "ALLOWED_RANGES" {2 3 4 5}
set_parameter_property "SYNC_DEPTH" "AFFECTS_PORT_WIDTHS" "false"
set_parameter_property "SYNC_DEPTH" "GROUP" "Number of synchronizer stages"
set_parameter_property "SYNC_DEPTH" "VISIBLE" "true"

# Interface clock_sink
add_interface "clock_sink" "clock" "sink" "asynchronous"
# Ports in interface clock_sink
add_port_to_interface "clock_sink" "sysclk" "clk"
add_port_to_interface "clock_sink" "nreset" "reset_n"

# Interface export_0
add_interface "export_0" "conduit" "start" "asynchronous"
# Ports in interface export_0
add_port_to_interface "export_0" "mosi" "export"
add_port_to_interface "export_0" "nss" "export"
add_port_to_interface "export_0" "miso" "export"
add_port_to_interface "export_0" "sclk" "export"

# Interface avalon_streaming_source
add_interface "avalon_streaming_source" "avalon_streaming" "source" "clock_sink"
set_interface_property "avalon_streaming_source" "symbolsPerBeat" "1"
set_interface_property "avalon_streaming_source" "dataBitsPerSymbol" "8"
set_interface_property "avalon_streaming_source" "readyLatency" "0"
set_interface_property "avalon_streaming_source" "maxChannel" "0"
# Ports in interface avalon_streaming_source
add_port_to_interface "avalon_streaming_source" "stsourceready" "ready"
add_port_to_interface "avalon_streaming_source" "stsourcevalid" "valid"
add_port_to_interface "avalon_streaming_source" "stsourcedata" "data"

# Interface avalon_streaming_sink
add_interface "avalon_streaming_sink" "avalon_streaming" "sink" "clock_sink"
set_interface_property "avalon_streaming_sink" "symbolsPerBeat" "1"
set_interface_property "avalon_streaming_sink" "dataBitsPerSymbol" "8"
set_interface_property "avalon_streaming_sink" "readyLatency" "0"
set_interface_property "avalon_streaming_sink" "maxChannel" "0"
# Ports in interface avalon_streaming_sink
add_port_to_interface "avalon_streaming_sink" "stsinkvalid" "valid"
add_port_to_interface "avalon_streaming_sink" "stsinkdata" "data"
add_port_to_interface "avalon_streaming_sink" "stsinkready" "ready"
