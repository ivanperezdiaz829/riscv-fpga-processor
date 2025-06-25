# Generated TCL File
# DO NOT MODIFY

# +-----------------------------------
# |
# | mgc_axi_slave_bfm "MGC AXI Slave BFM" 10.1e_1
# | Mentor Graphics 13.9
# | AXI Slave BFM
# |
# | ./mgc_axi_slave.sv sim
# |
# +-----------------------------------

# +-----------------------------------
# | Request TCL Packages.
package require -exact qsys 13.1
# |
# +-----------------------------------

# +-----------------------------------
# | module mgc_axi_slave
# |
set_module_property DESCRIPTION        "Mentor Graphics AXI3 Slave BFM (Altera Edition)"
set_module_property NAME               mgc_axi_slave
set_module_property VERSION            10.1.5.1
set_module_property AUTHOR             "Mentor Graphics Corporation"
set_module_property ICON_PATH          "../../common/Mentor_VIP_AE_icon.png"
set_module_property DISPLAY_NAME       "Mentor Graphics AXI3 Slave BFM (Altera Edition)"
set_module_property GROUP              "Verification/Simulation"
set_module_property EDITABLE           false
set_module_property ANALYZE_HDL        false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset          sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog top_level   mgc_axi_slave

add_fileset          sim_vhdl    SIM_VHDL    proc_sim_vhdl
set_fileset_property sim_vhdl    top_level   mgc_axi_slave_vhd

proc proc_sim_verilog { name } {
}

proc proc_sim_vhdl { name } {
}

# |
# +-----------------------------------

# +-----------------------------------
# | Documentation links
# |
add_documentation_link "AXI Slave BFM Reference Guide" http://www.altera.com/literature/ug/mentor_vip_ae_usr.pdf
# |
# +-----------------------------------

# +-----------------------------------
# | Parameters
# |
add_parameter          AXI_ADDRESS_WIDTH INTEGER 64
set_parameter_property AXI_ADDRESS_WIDTH DISPLAY_NAME      "AXI Address Bus Width"
set_parameter_property AXI_ADDRESS_WIDTH DESCRIPTION       "The width of the AWADDR and ARADDR signals (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.2)."
set_parameter_property AXI_ADDRESS_WIDTH ALLOWED_RANGES     1:64
set_parameter_property AXI_ADDRESS_WIDTH HDL_PARAMETER      true

add_parameter          AXI_RDATA_WIDTH INTEGER 1024
set_parameter_property AXI_RDATA_WIDTH DISPLAY_NAME      "AXI Read Data Bus Width"
set_parameter_property AXI_RDATA_WIDTH DESCRIPTION       "The width of the RDATA signal (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.6)."
set_parameter_property AXI_RDATA_WIDTH ALLOWED_RANGES     1:1024
set_parameter_property AXI_RDATA_WIDTH HDL_PARAMETER      true

add_parameter          AXI_WDATA_WIDTH INTEGER 1024
set_parameter_property AXI_WDATA_WIDTH DISPLAY_NAME      "AXI Write Data Bus Width"
set_parameter_property AXI_WDATA_WIDTH DESCRIPTION       "The width of the WDATA signal (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.3)."
set_parameter_property AXI_WDATA_WIDTH ALLOWED_RANGES     1:1024
set_parameter_property AXI_WDATA_WIDTH HDL_PARAMETER      true

add_parameter          AXI_ID_WIDTH INTEGER 18
set_parameter_property AXI_ID_WIDTH DISPLAY_NAME      "AXI ID Bus Width"
set_parameter_property AXI_ID_WIDTH DESCRIPTION       "The width of the AWID, ARID, WID, RID and BID signals (see AMBA AXI and ACE Protocol Specification IHI0022D section A2.2)."
set_parameter_property AXI_ID_WIDTH ALLOWED_RANGES     1:18
set_parameter_property AXI_ID_WIDTH HDL_PARAMETER      true

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
# | connection point altera_axi_slave
# |
add_interface          altera_axi_slave axi end
set_interface_property altera_axi_slave associatedClock clock_sink
set_interface_property altera_axi_slave associatedReset reset_sink
set_interface_property altera_axi_slave maximumOutstandingReads        1
set_interface_property altera_axi_slave maximumOutstandingWrites       1
set_interface_property altera_axi_slave maximumOutstandingTransactions 1
set_interface_property altera_axi_slave ENABLED true

add_interface_port altera_axi_slave AWVALID    awvalid    Input  1
add_interface_port altera_axi_slave AWLEN      awlen      Input  4
add_interface_port altera_axi_slave AWSIZE     awsize     Input  3
add_interface_port altera_axi_slave AWBURST    awburst    Input  2
add_interface_port altera_axi_slave AWLOCK     awlock     Input  2
add_interface_port altera_axi_slave AWCACHE    awcache    Input  4
add_interface_port altera_axi_slave AWPROT     awprot     Input  3
add_interface_port altera_axi_slave AWREADY    awready    Output 1
add_interface_port altera_axi_slave AWUSER     awuser     Input  8
add_interface_port altera_axi_slave ARVALID    arvalid    Input  1
add_interface_port altera_axi_slave ARLEN      arlen      Input  4
add_interface_port altera_axi_slave ARSIZE     arsize     Input  3
add_interface_port altera_axi_slave ARBURST    arburst    Input  2
add_interface_port altera_axi_slave ARLOCK     arlock     Input  2
add_interface_port altera_axi_slave ARCACHE    arcache    Input  4
add_interface_port altera_axi_slave ARPROT     arprot     Input  3
add_interface_port altera_axi_slave ARREADY    arready    Output 1
add_interface_port altera_axi_slave ARUSER     aruser     Input  8
add_interface_port altera_axi_slave RVALID     rvalid     Output 1
add_interface_port altera_axi_slave RLAST      rlast      Output 1
add_interface_port altera_axi_slave RRESP      rresp      Output 2
add_interface_port altera_axi_slave RREADY     rready     Input  1
add_interface_port altera_axi_slave WVALID     wvalid     Input  1
add_interface_port altera_axi_slave WLAST      wlast      Input  1
add_interface_port altera_axi_slave WREADY     wready     Output 1
add_interface_port altera_axi_slave BVALID     bvalid     Output 1
add_interface_port altera_axi_slave BRESP      bresp      Output 2
add_interface_port altera_axi_slave BREADY     bready     Input  1
# |
# +-----------------------------------

set_module_property ELABORATION_CALLBACK my_elaborate

proc my_elaborate {} {
  set AXI_ADDRESS_WIDTH    [get_parameter_value AXI_ADDRESS_WIDTH]
  set AXI_RDATA_WIDTH      [get_parameter_value AXI_RDATA_WIDTH]
  set AXI_WDATA_WIDTH      [get_parameter_value AXI_WDATA_WIDTH]
  set AXI_ID_WIDTH         [get_parameter_value AXI_ID_WIDTH]

  add_interface_port altera_axi_slave AWADDR     awaddr     Input  $AXI_ADDRESS_WIDTH
  add_interface_port altera_axi_slave AWID       awid       Input  $AXI_ID_WIDTH
  add_interface_port altera_axi_slave ARADDR     araddr     Input  $AXI_ADDRESS_WIDTH
  add_interface_port altera_axi_slave ARID       arid       Input  $AXI_ID_WIDTH
  add_interface_port altera_axi_slave RDATA      rdata      Output $AXI_RDATA_WIDTH
  add_interface_port altera_axi_slave RID        rid        Output $AXI_ID_WIDTH
  add_interface_port altera_axi_slave WDATA      wdata      Input  $AXI_WDATA_WIDTH
  add_interface_port altera_axi_slave WSTRB      wstrb      Input  [ expr ($AXI_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi_slave WID        wid        Input  $AXI_ID_WIDTH
  add_interface_port altera_axi_slave BID        bid        Output $AXI_ID_WIDTH
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
