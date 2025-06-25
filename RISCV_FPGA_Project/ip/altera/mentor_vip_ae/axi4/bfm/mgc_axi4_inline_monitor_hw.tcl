# Generated TCL File
# DO NOT MODIFY

# +-----------------------------------
# |
# | mgc_axi4_inline_monitor_bfm "MGC AXI4 Inline Monitor BFM" 10.1e_1
# | Mentor Graphics 13.9
# | AXI4 Inline Monitor BFM
# |
# | ./mgc_axi4_inline_monitor.sv sim
# |
# +-----------------------------------

# +-----------------------------------
# | Request TCL Packages.
package require -exact qsys 13.1
# |
# +-----------------------------------

# +-----------------------------------
# | module mgc_axi4_inline_monitor
# |
set_module_property DESCRIPTION        "Mentor Graphics AXI4 Inline Monitor BFM (Altera Edition)"
set_module_property NAME               mgc_axi4_inline_monitor
set_module_property VERSION            10.1.5.1
set_module_property AUTHOR             "Mentor Graphics Corporation"
set_module_property ICON_PATH          "../../common/Mentor_VIP_AE_icon.png"
set_module_property DISPLAY_NAME       "Mentor Graphics AXI4 Inline Monitor BFM (Altera Edition)"
set_module_property GROUP              "Verification/Simulation"
set_module_property EDITABLE           false
set_module_property ANALYZE_HDL        false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset          sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog top_level   mgc_axi4_inline_monitor

add_fileset          sim_vhdl    SIM_VHDL    proc_sim_vhdl
set_fileset_property sim_vhdl    top_level   mgc_axi4_inline_monitor_vhd

proc proc_sim_verilog { name } {
}

proc proc_sim_vhdl { name } {
}

# |
# +-----------------------------------

# +-----------------------------------
# | Documentation links
# |
add_documentation_link "AXI4 Inline Monitor BFM Reference Guide" http://www.altera.com/literature/ug/mentor_vip_ae_usr.pdf
# |
# +-----------------------------------

# +-----------------------------------
# | Parameters
# |
add_parameter          AXI4_ADDRESS_WIDTH INTEGER 64
set_parameter_property AXI4_ADDRESS_WIDTH DISPLAY_NAME      "AXI4 Address Bus Width"
set_parameter_property AXI4_ADDRESS_WIDTH DESCRIPTION       "The width of the AWADDR and ARADDR signals (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.2)."
set_parameter_property AXI4_ADDRESS_WIDTH ALLOWED_RANGES     1:64
set_parameter_property AXI4_ADDRESS_WIDTH HDL_PARAMETER      true

add_parameter          AXI4_RDATA_WIDTH INTEGER 1024
set_parameter_property AXI4_RDATA_WIDTH DISPLAY_NAME      "AXI4 Read Data Bus Width"
set_parameter_property AXI4_RDATA_WIDTH DESCRIPTION       "The width of the RDATA signal (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.6)."
set_parameter_property AXI4_RDATA_WIDTH ALLOWED_RANGES     1:1024
set_parameter_property AXI4_RDATA_WIDTH HDL_PARAMETER      true

add_parameter          AXI4_WDATA_WIDTH INTEGER 1024
set_parameter_property AXI4_WDATA_WIDTH DISPLAY_NAME      "AXI4 Write Data Bus Width"
set_parameter_property AXI4_WDATA_WIDTH DESCRIPTION       "The width of the WDATA signal (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.3)."
set_parameter_property AXI4_WDATA_WIDTH ALLOWED_RANGES     1:1024
set_parameter_property AXI4_WDATA_WIDTH HDL_PARAMETER      true

add_parameter          AXI4_ID_WIDTH INTEGER 18
set_parameter_property AXI4_ID_WIDTH DISPLAY_NAME      "AXI4 ID Bus Width"
set_parameter_property AXI4_ID_WIDTH DESCRIPTION       "The width of the AWID, ARID, RID and BID signals (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.2)."
set_parameter_property AXI4_ID_WIDTH ALLOWED_RANGES     1:18
set_parameter_property AXI4_ID_WIDTH HDL_PARAMETER      true

add_parameter          AXI4_USER_WIDTH INTEGER 8
set_parameter_property AXI4_USER_WIDTH DISPLAY_NAME      "AXI4 User-defined Bus Width"
set_parameter_property AXI4_USER_WIDTH DESCRIPTION       "The width of the AWUSER, ARUSER, WUSER, RUSER and BUSER signals (see AMBA AXI and ACE Protocol Specification IHI0022D section A8.3)."
set_parameter_property AXI4_USER_WIDTH ALLOWED_RANGES     1:8
set_parameter_property AXI4_USER_WIDTH HDL_PARAMETER      true

add_parameter          AXI4_REGION_MAP_SIZE INTEGER 16
set_parameter_property AXI4_REGION_MAP_SIZE DISPLAY_NAME      "AXI4_REGION_MAP_SIZE"
set_parameter_property AXI4_REGION_MAP_SIZE DESCRIPTION       ""
set_parameter_property AXI4_REGION_MAP_SIZE ALLOWED_RANGES     1:16
set_parameter_property AXI4_REGION_MAP_SIZE HDL_PARAMETER      true

add_parameter          index INTEGER 0
set_parameter_property index DISPLAY_NAME       "VHDL BFM instance ID"
set_parameter_property index DESCRIPTION        "The parameter 'index' is used to uniquely indentify VHDL BFM instances. It must be set to a different value for each VHDL BFM in the system. It is ignored for Verilog BFM instances"
set_parameter_property index ALLOWED_RANGES     0:1023
set_parameter_property index HDL_PARAMETER      true

# |
# +-----------------------------------

# +-----------------------------------
# | display items
# |
# +-----------------------------------

# +-----------------------------------
# | connection point altera_axi4_master and altera_axi4_slave
# |
add_interface          altera_axi4_master axi4 start
set_interface_property altera_axi4_master associatedClock clock_sink
set_interface_property altera_axi4_master associatedReset reset_sink
set_interface_property altera_axi4_master maximumOutstandingReads        1
set_interface_property altera_axi4_master maximumOutstandingWrites       1
set_interface_property altera_axi4_master maximumOutstandingTransactions 1
set_interface_property altera_axi4_master ENABLED true

add_interface_port altera_axi4_master master_AWVALID    awvalid    Output 1
add_interface_port altera_axi4_master master_AWPROT     awprot     Output 3
add_interface_port altera_axi4_master master_AWREGION   awregion   Output 4
add_interface_port altera_axi4_master master_AWLEN      awlen      Output 8
add_interface_port altera_axi4_master master_AWSIZE     awsize     Output 3
add_interface_port altera_axi4_master master_AWBURST    awburst    Output 2
add_interface_port altera_axi4_master master_AWLOCK     awlock     Output 1
add_interface_port altera_axi4_master master_AWCACHE    awcache    Output 4
add_interface_port altera_axi4_master master_AWQOS      awqos      Output 4
add_interface_port altera_axi4_master master_AWREADY    awready    Input  1
add_interface_port altera_axi4_master master_ARVALID    arvalid    Output 1
add_interface_port altera_axi4_master master_ARPROT     arprot     Output 3
add_interface_port altera_axi4_master master_ARREGION   arregion   Output 4
add_interface_port altera_axi4_master master_ARLEN      arlen      Output 8
add_interface_port altera_axi4_master master_ARSIZE     arsize     Output 3
add_interface_port altera_axi4_master master_ARBURST    arburst    Output 2
add_interface_port altera_axi4_master master_ARLOCK     arlock     Output 1
add_interface_port altera_axi4_master master_ARCACHE    arcache    Output 4
add_interface_port altera_axi4_master master_ARQOS      arqos      Output 4
add_interface_port altera_axi4_master master_ARREADY    arready    Input  1
add_interface_port altera_axi4_master master_RVALID     rvalid     Input  1
add_interface_port altera_axi4_master master_RRESP      rresp      Input  2
add_interface_port altera_axi4_master master_RLAST      rlast      Input  1
add_interface_port altera_axi4_master master_RREADY     rready     Output 1
add_interface_port altera_axi4_master master_WVALID     wvalid     Output 1
add_interface_port altera_axi4_master master_WLAST      wlast      Output 1
add_interface_port altera_axi4_master master_WREADY     wready     Input  1
add_interface_port altera_axi4_master master_BVALID     bvalid     Input  1
add_interface_port altera_axi4_master master_BRESP      bresp      Input  2
add_interface_port altera_axi4_master master_BREADY     bready     Output 1

add_interface          altera_axi4_slave axi4 end
set_interface_property altera_axi4_slave associatedClock clock_sink
set_interface_property altera_axi4_slave associatedReset reset_sink
set_interface_property altera_axi4_slave maximumOutstandingReads        1
set_interface_property altera_axi4_slave maximumOutstandingWrites       1
set_interface_property altera_axi4_slave maximumOutstandingTransactions 1
set_interface_property altera_axi4_slave ENABLED true

add_interface_port altera_axi4_slave slave_AWVALID    awvalid    Input  1
add_interface_port altera_axi4_slave slave_AWPROT     awprot     Input  3
add_interface_port altera_axi4_slave slave_AWREGION   awregion   Input  4
add_interface_port altera_axi4_slave slave_AWLEN      awlen      Input  8
add_interface_port altera_axi4_slave slave_AWSIZE     awsize     Input  3
add_interface_port altera_axi4_slave slave_AWBURST    awburst    Input  2
add_interface_port altera_axi4_slave slave_AWLOCK     awlock     Input  1
add_interface_port altera_axi4_slave slave_AWCACHE    awcache    Input  4
add_interface_port altera_axi4_slave slave_AWQOS      awqos      Input  4
add_interface_port altera_axi4_slave slave_AWREADY    awready    Output 1
add_interface_port altera_axi4_slave slave_ARVALID    arvalid    Input  1
add_interface_port altera_axi4_slave slave_ARPROT     arprot     Input  3
add_interface_port altera_axi4_slave slave_ARREGION   arregion   Input  4
add_interface_port altera_axi4_slave slave_ARLEN      arlen      Input  8
add_interface_port altera_axi4_slave slave_ARSIZE     arsize     Input  3
add_interface_port altera_axi4_slave slave_ARBURST    arburst    Input  2
add_interface_port altera_axi4_slave slave_ARLOCK     arlock     Input  1
add_interface_port altera_axi4_slave slave_ARCACHE    arcache    Input  4
add_interface_port altera_axi4_slave slave_ARQOS      arqos      Input  4
add_interface_port altera_axi4_slave slave_ARREADY    arready    Output 1
add_interface_port altera_axi4_slave slave_RVALID     rvalid     Output 1
add_interface_port altera_axi4_slave slave_RRESP      rresp      Output 2
add_interface_port altera_axi4_slave slave_RLAST      rlast      Output 1
add_interface_port altera_axi4_slave slave_RREADY     rready     Input  1
add_interface_port altera_axi4_slave slave_WVALID     wvalid     Input  1
add_interface_port altera_axi4_slave slave_WLAST      wlast      Input  1
add_interface_port altera_axi4_slave slave_WREADY     wready     Output 1
add_interface_port altera_axi4_slave slave_BVALID     bvalid     Output 1
add_interface_port altera_axi4_slave slave_BRESP      bresp      Output 2
add_interface_port altera_axi4_slave slave_BREADY     bready     Input  1
# |
# +-----------------------------------

set_module_property ELABORATION_CALLBACK my_elaborate

proc my_elaborate {} {
  set AXI4_ADDRESS_WIDTH   [get_parameter_value AXI4_ADDRESS_WIDTH]
  set AXI4_RDATA_WIDTH     [get_parameter_value AXI4_RDATA_WIDTH]
  set AXI4_WDATA_WIDTH     [get_parameter_value AXI4_WDATA_WIDTH]
  set AXI4_ID_WIDTH        [get_parameter_value AXI4_ID_WIDTH]
  set AXI4_USER_WIDTH      [get_parameter_value AXI4_USER_WIDTH]
  set AXI4_REGION_MAP_SIZE [get_parameter_value AXI4_REGION_MAP_SIZE]

  add_interface_port altera_axi4_master master_AWADDR     awaddr     Output $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_master master_AWID       awid       Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master master_AWUSER     awuser     Output $AXI4_USER_WIDTH
  add_interface_port altera_axi4_master master_ARADDR     araddr     Output $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_master master_ARID       arid       Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master master_ARUSER     aruser     Output $AXI4_USER_WIDTH
  add_interface_port altera_axi4_master master_RDATA      rdata      Input  $AXI4_RDATA_WIDTH
  add_interface_port altera_axi4_master master_RID        rid        Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master master_WDATA      wdata      Output $AXI4_WDATA_WIDTH
  add_interface_port altera_axi4_master master_WSTRB      wstrb      Output [ expr ($AXI4_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi4_master master_BID        bid        Input  $AXI4_ID_WIDTH

  add_interface_port altera_axi4_slave slave_AWADDR     awaddr     Input  $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_slave slave_AWID       awid       Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave slave_AWUSER     awuser     Input  $AXI4_USER_WIDTH
  add_interface_port altera_axi4_slave slave_ARADDR     araddr     Input  $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_slave slave_ARID       arid       Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave slave_ARUSER     aruser     Input  $AXI4_USER_WIDTH
  add_interface_port altera_axi4_slave slave_RDATA      rdata      Output $AXI4_RDATA_WIDTH
  add_interface_port altera_axi4_slave slave_RID        rid        Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave slave_WDATA      wdata      Input  $AXI4_WDATA_WIDTH
  add_interface_port altera_axi4_slave slave_WSTRB      wstrb      Input  [ expr ($AXI4_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi4_slave slave_BID        bid        Output $AXI4_ID_WIDTH
}

# +-----------------------------------
# | connection point clock_sink
# |
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0

set_interface_property clock_sink ENABLED true

add_interface_port clock_sink ACLK clk Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point reset_sink
# |
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT

set_interface_property reset_sink ENABLED true

add_interface_port reset_sink ARESETn reset_n Input 1
# |
# +-----------------------------------
