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


# +-----------------------------------
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
# +-----------------------------------

package require -exact sopc 9.1

# +-----------------------------------
# | module altera_jtag_avalon_master
# |
set_module_property NAME alt_mem_if_jtag_master
set_module_property VERSION "__VERSION_SHORT__"
set_module_property INTERNAL true
set_module_property GROUP "Bridges and Adapters/Memory Mapped"
set_module_property AUTHOR  "Altera Corporation"
set_module_property DISPLAY_NAME "alt_mem_if JTAG to Avalon Master Bridge"
set_module_property DATASHEET_URL "http://www.altera.com/literature/hb/nios2/qts_qii55011.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property VALIDATION_CALLBACK validate
set_module_property COMPOSE_CALLBACK compose

set_module_assignment debug.hostConnection {type jtag id 110:132}
# |
# +-----------------------------------

# +-----------------------------------
# | simulation libraries 
# | 
if { [file exists "../altera_avalon_jtag_phy/bytestream_pli.dll"] == 1 } {
    add_file ../altera_avalon_jtag_phy/bytestream_pli.dll SIMULATION
    set_file_property bytestream_pli.dll PLUGIN_API "win32 pli"
}
if { [file exists "../altera_avalon_jtag_phy/libbytestream_pli.so"] == 1 } {
    add_file ../altera_avalon_jtag_phy/libbytestream_pli.so SIMULATION
    set_file_property libbytestream_pli.so PLUGIN_API "linux pli"
}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter USE_PLI INTEGER 0
set_parameter_property USE_PLI DISPLAY_NAME "Use PLI Simulation Mode"
set_parameter_property USE_PLI DISPLAY_HINT boolean
set_parameter_property USE_PLI UNITS None
set_parameter_property USE_PLI HDL_PARAMETER true

add_parameter PLI_PORT INTEGER 50000
set_parameter_property PLI_PORT DISPLAY_NAME "PLI Simulation Port"
set_parameter_property PLI_PORT UNITS None
set_parameter_property PLI_PORT VISIBLE true
set_parameter_property PLI_PORT ENABLED false
set_parameter_property PLI_PORT HDL_PARAMETER true

add_parameter COMPONENT_CLOCK INTEGER 0
set_parameter_property COMPONENT_CLOCK SYSTEM_INFO { CLOCK_RATE clock }
set_parameter_property COMPONENT_CLOCK VISIBLE false

add_parameter           FAST_VER              "INTEGER" "0" ""
set_parameter_property  FAST_VER              "VISIBLE" true
set_parameter_property  FAST_VER              "DISPLAY_NAME" "Enhanced transaction master"
set_parameter_property  FAST_VER              "DESCRIPTION"  "Increase transaction master throughput"
set_parameter_property  FAST_VER              "DISPLAY_HINT" "boolean"
set_parameter_property  FAST_VER              "STATUS" experimental

add_parameter           FIFO_DEPTHS           "INTEGER" "2" ""
set_parameter_property  FIFO_DEPTHS           "VISIBLE" true
set_parameter_property  FIFO_DEPTHS           "HDL_PARAMETER" true
set_parameter_property  FIFO_DEPTHS           "ALLOWED_RANGES" "2:8192"
set_parameter_property  FIFO_DEPTHS           "DISPLAY_NAME" "FIFO depth"
set_parameter_property  FIFO_DEPTHS           "DESCRIPTION"  "User need to tweak this to find the sweet spot"
set_parameter_property  FIFO_DEPTHS           "STATUS" experimental
# |
# +-----------------------------------
# +-----------------------------------
# | Validate
# |
proc validate {} {
    set use_pli [ get_parameter_value USE_PLI ]
    set use_fast [ get_parameter_value FAST_VER ]
    if {$use_pli == ""} {
        set_parameter_value USE_PLI 0
        set use_pli 0
    }
    if {$use_fast == ""} {
        set_parameter_value FAST_VER 0
        set use_fast 0
    }
    if {$use_pli == 0} {
      set_parameter_property PLI_PORT ENABLED false
    } else {
      set_parameter_property PLI_PORT ENABLED true
    }
    if {$use_fast == 0} {
        set_parameter_property FIFO_DEPTHS ENABLED false
    } else {
        set_parameter_property FIFO_DEPTHS ENABLED true
    }
}
# |
# +-----------------------------------
# +-----------------------------------
# | Compose
# |
proc compose {} {

    # +-----------------------------------
    # | submodule instantiation
    # |
    #add_instance clk_src     clock_source
    add_instance  clk_src    altera_clock_bridge
    add_instance  clk_rst    altera_reset_bridge
    add_instance jtag_phy_embedded_in_jtag_master altera_jtag_dc_streaming
    add_instance timing_adt  timing_adapter
    add_instance fifo        altera_avalon_sc_fifo
    add_instance b2p         altera_avalon_st_bytes_to_packets
    add_instance p2b         altera_avalon_st_packets_to_bytes
    add_instance transacto   altera_avalon_packets_to_master
    add_instance b2p_adapter channel_adapter
    add_instance p2b_adapter channel_adapter
    
    set_instance_parameter clk_rst SYNCHRONOUS_EDGES none

    # altera_jtag_dc_streaming parameters
    set_instance_parameter jtag_phy_embedded_in_jtag_master PURPOSE 1
    set_instance_parameter jtag_phy_embedded_in_jtag_master DOWNSTREAM_FIFO_SIZE 64
    set_instance_parameter jtag_phy_embedded_in_jtag_master USE_PLI  [ get_parameter_value USE_PLI ]
    set_instance_parameter jtag_phy_embedded_in_jtag_master PLI_PORT [ get_parameter_value PLI_PORT ]
    # timing adapter parameters
    set_instance_parameter timing_adt inBitsPerSymbol   8
    set_instance_parameter timing_adt inChannelWidth    0
    set_instance_parameter timing_adt inErrorWidth      0
    set_instance_parameter timing_adt inMaxChannel      0
    set_instance_parameter timing_adt inReadyLatency    0
    set_instance_parameter timing_adt inSymbolsPerBeat  1
    set_instance_parameter timing_adt inUseEmpty        false
    set_instance_parameter timing_adt inUseEmptyPort    NO
    set_instance_parameter timing_adt inUsePackets      false
    set_instance_parameter timing_adt inUseReady        [ get_parameter_value USE_PLI ]
    set_instance_parameter timing_adt inUseValid        true
    set_instance_parameter timing_adt outReadyLatency   0
    set_instance_parameter timing_adt outUseReady       true
    set_instance_parameter timing_adt outUseValid       true
    # b2p channel adapter parameters
    set_instance_parameter b2p_adapter inBitsPerSymbol   8
    set_instance_parameter b2p_adapter inChannelWidth    8
    set_instance_parameter b2p_adapter inErrorWidth      0
    set_instance_parameter b2p_adapter inMaxChannel      255
    set_instance_parameter b2p_adapter inReadyLatency    0
    set_instance_parameter b2p_adapter inSymbolsPerBeat  1
    set_instance_parameter b2p_adapter inUseEmpty        false
    set_instance_parameter b2p_adapter inUseEmptyPort    AUTO
    set_instance_parameter b2p_adapter inUsePackets      true
    set_instance_parameter b2p_adapter inUseReady        true
    set_instance_parameter b2p_adapter outChannelWidth   0
    set_instance_parameter b2p_adapter outMaxChannel     0
    # p2b channel adapter parameters
    set_instance_parameter p2b_adapter inBitsPerSymbol   8
    set_instance_parameter p2b_adapter inChannelWidth    0
    set_instance_parameter p2b_adapter inErrorWidth      0
    set_instance_parameter p2b_adapter inMaxChannel      0
    set_instance_parameter p2b_adapter inReadyLatency    0
    set_instance_parameter p2b_adapter inSymbolsPerBeat  1
    set_instance_parameter p2b_adapter inUseEmpty        false
    set_instance_parameter p2b_adapter inUseEmptyPort    AUTO
    set_instance_parameter p2b_adapter inUsePackets      true
    set_instance_parameter p2b_adapter inUseReady        true
    set_instance_parameter p2b_adapter outChannelWidth   8
    set_instance_parameter p2b_adapter outMaxChannel     255
    # sc fifo parameters
    set_instance_parameter fifo SYMBOLS_PER_BEAT    1
    set_instance_parameter fifo BITS_PER_SYMBOL     8
    set_instance_parameter fifo FIFO_DEPTH          64
    set_instance_parameter fifo CHANNEL_WIDTH       0
    set_instance_parameter fifo ERROR_WIDTH         0
    set_instance_parameter fifo USE_PACKETS         0
    set_instance_parameter fifo USE_FILL_LEVEL      0
    set_instance_parameter fifo USE_STORE_FORWARD   0
    set_instance_parameter fifo USE_ALMOST_FULL_IF  0
    set_instance_parameter fifo USE_ALMOST_EMPTY_IF 0
    # transacto parameters
    set_instance_parameter transacto EXPORT_MASTER_SIGNALS  0
    set_instance_parameter transacto FAST_VER               [ get_parameter_value FAST_VER ]
    set_instance_parameter transacto FIFO_DEPTHS            [ get_parameter_value FIFO_DEPTHS ]
    # |
    # +-----------------------------------
    
    # +-----------------------------------
    # | connection point clk
    # |
    add_interface           clk clock end
    set_interface_property  clk export_of clk_src.in_clk
    # |
    # +-----------------------------------
    # +-----------------------------------
    # | connection point clk_reset
    # |
    add_interface           clk_reset reset end
    set_interface_property  clk_reset export_of clk_rst.in_reset
    # |
    # +-----------------------------------
    # +-----------------------------------
    # | connection point master
    # |
    add_interface           master avalon start
    set_interface_property  master export_of transacto.avalon_master
    set_interface_assignment master debug.providesServices master
	set_interface_assignment master debug.visible true
	set_interface_assignment master debug.typeName altera_jtag_avalon_master.master
    # |
    # +-----------------------------------
    # +-----------------------------------
    # | connection point master_reset
    # |
    add_interface           master_reset reset start
    set_interface_property  master_reset export_of jtag_phy_embedded_in_jtag_master.resetrequest
    # |
    # +-----------------------------------
    # +-----------------------------------
    # | submodule interface connections
    # |
    add_connection clk_src.out_clk jtag_phy_embedded_in_jtag_master.clock
    add_connection clk_src.out_clk timing_adt.clk
    add_connection clk_src.out_clk fifo.clk
    add_connection clk_src.out_clk b2p.clk
    add_connection clk_src.out_clk p2b.clk
    add_connection clk_src.out_clk transacto.clk
    add_connection clk_src.out_clk b2p_adapter.clk
    add_connection clk_src.out_clk p2b_adapter.clk
    
    add_connection clk_rst.out_reset jtag_phy_embedded_in_jtag_master.clock_reset
    add_connection clk_rst.out_reset timing_adt.reset
    add_connection clk_rst.out_reset fifo.clk_reset
    add_connection clk_rst.out_reset b2p.clk_reset
    add_connection clk_rst.out_reset p2b.clk_reset
    add_connection clk_rst.out_reset transacto.clk_reset
    add_connection clk_rst.out_reset b2p_adapter.reset
    add_connection clk_rst.out_reset p2b_adapter.reset
    
    add_connection jtag_phy_embedded_in_jtag_master.src                timing_adt.in
    add_connection timing_adt.out         fifo.in
    add_connection fifo.out               b2p.in_bytes_stream
    add_connection b2p.out_packets_stream b2p_adapter.in
    add_connection b2p_adapter.out        transacto.in_stream
    add_connection transacto.out_stream   p2b_adapter.in
    add_connection p2b_adapter.out        p2b.in_packets_stream
    add_connection p2b.out_bytes_stream   jtag_phy_embedded_in_jtag_master.sink
    # |
    # +-----------------------------------
}
# |
# +-----------------------------------

