# Generated TCL File
# DO NOT MODIFY

# +-----------------------------------
# |
# | mgc_axi4_slave_bfm "MGC AXI4 Slave BFM" 10.1e_1
# | Mentor Graphics 13.9
# | AXI4 Slave BFM
# |
# | ./mgc_axi4_slave.sv sim
# |
# +-----------------------------------

# +-----------------------------------
# | Request TCL Packages.
package require -exact qsys 13.1
# |
# +-----------------------------------

# +-----------------------------------
# | module mgc_axi4_slave
# |
set_module_property DESCRIPTION        "Mentor Graphics AXI4 Slave BFM (Altera Edition)"
set_module_property NAME               mgc_axi4_slave
set_module_property VERSION            10.1.5.1
set_module_property AUTHOR             "Mentor Graphics Corporation"
set_module_property ICON_PATH          "../../common/Mentor_VIP_AE_icon.png"
set_module_property DISPLAY_NAME       "Mentor Graphics AXI4 Slave BFM (Altera Edition)"
set_module_property GROUP              "Verification/Simulation"
set_module_property EDITABLE           false
set_module_property ANALYZE_HDL        false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset          sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog top_level   mgc_axi4_slave

add_fileset          sim_vhdl    SIM_VHDL    proc_sim_vhdl
set_fileset_property sim_vhdl    top_level   mgc_axi4_slave_vhd

proc proc_sim_verilog { name } {
}

proc proc_sim_vhdl { name } {
}

# |
# +-----------------------------------

# +-----------------------------------
# | Documentation links
# |
add_documentation_link "AXI4 Slave BFM Reference Guide" http://www.altera.com/literature/ug/mentor_vip_ae_usr.pdf
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
# | connection point altera_axi4_slave
# |
add_interface          altera_axi4_slave axi4 end
set_interface_property altera_axi4_slave associatedClock clock_sink
set_interface_property altera_axi4_slave associatedReset reset_sink
set_interface_property altera_axi4_slave maximumOutstandingReads        1
set_interface_property altera_axi4_slave maximumOutstandingWrites       1
set_interface_property altera_axi4_slave maximumOutstandingTransactions 1
set_interface_property altera_axi4_slave ENABLED true

add_interface_port altera_axi4_slave AWVALID    awvalid    Input  1
add_interface_port altera_axi4_slave AWPROT     awprot     Input  3
add_interface_port altera_axi4_slave AWREGION   awregion   Input  4
add_interface_port altera_axi4_slave AWLEN      awlen      Input  8
add_interface_port altera_axi4_slave AWSIZE     awsize     Input  3
add_interface_port altera_axi4_slave AWBURST    awburst    Input  2
add_interface_port altera_axi4_slave AWLOCK     awlock     Input  1
add_interface_port altera_axi4_slave AWCACHE    awcache    Input  4
add_interface_port altera_axi4_slave AWQOS      awqos      Input  4
add_interface_port altera_axi4_slave AWREADY    awready    Output 1
add_interface_port altera_axi4_slave ARVALID    arvalid    Input  1
add_interface_port altera_axi4_slave ARPROT     arprot     Input  3
add_interface_port altera_axi4_slave ARREGION   arregion   Input  4
add_interface_port altera_axi4_slave ARLEN      arlen      Input  8
add_interface_port altera_axi4_slave ARSIZE     arsize     Input  3
add_interface_port altera_axi4_slave ARBURST    arburst    Input  2
add_interface_port altera_axi4_slave ARLOCK     arlock     Input  1
add_interface_port altera_axi4_slave ARCACHE    arcache    Input  4
add_interface_port altera_axi4_slave ARQOS      arqos      Input  4
add_interface_port altera_axi4_slave ARREADY    arready    Output 1
add_interface_port altera_axi4_slave RVALID     rvalid     Output 1
add_interface_port altera_axi4_slave RRESP      rresp      Output 2
add_interface_port altera_axi4_slave RLAST      rlast      Output 1
add_interface_port altera_axi4_slave RREADY     rready     Input  1
add_interface_port altera_axi4_slave WVALID     wvalid     Input  1
add_interface_port altera_axi4_slave WLAST      wlast      Input  1
add_interface_port altera_axi4_slave WREADY     wready     Output 1
add_interface_port altera_axi4_slave BVALID     bvalid     Output 1
add_interface_port altera_axi4_slave BRESP      bresp      Output 2
add_interface_port altera_axi4_slave BREADY     bready     Input  1
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

  add_interface_port altera_axi4_slave AWADDR     awaddr     Input  $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_slave AWID       awid       Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave AWUSER     awuser     Input  $AXI4_USER_WIDTH
  add_interface_port altera_axi4_slave ARADDR     araddr     Input  $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_slave ARID       arid       Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave ARUSER     aruser     Input  $AXI4_USER_WIDTH
  add_interface_port altera_axi4_slave RDATA      rdata      Output $AXI4_RDATA_WIDTH
  add_interface_port altera_axi4_slave RID        rid        Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_slave WDATA      wdata      Input  $AXI4_WDATA_WIDTH
  add_interface_port altera_axi4_slave WSTRB      wstrb      Input  [ expr ($AXI4_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi4_slave BID        bid        Output $AXI4_ID_WIDTH
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
