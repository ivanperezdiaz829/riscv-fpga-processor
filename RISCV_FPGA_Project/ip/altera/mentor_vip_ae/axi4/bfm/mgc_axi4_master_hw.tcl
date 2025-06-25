# Generated TCL File
# DO NOT MODIFY

# +-----------------------------------
# |
# | mgc_axi4_master_bfm "MGC AXI4 Master BFM" 10.1e_1
# | Mentor Graphics 13.9
# | AXI4 Master BFM
# |
# | ./mgc_axi4_master.sv sim
# |
# +-----------------------------------

# +-----------------------------------
# | Request TCL Packages.
package require -exact qsys 13.1
# |
# +-----------------------------------

# +-----------------------------------
# | module mgc_axi4_master
# |
set_module_property DESCRIPTION        "Mentor Graphics AXI4 Master BFM (Altera Edition)"
set_module_property NAME               mgc_axi4_master
set_module_property VERSION            10.1.5.1
set_module_property AUTHOR             "Mentor Graphics Corporation"
set_module_property ICON_PATH          "../../common/Mentor_VIP_AE_icon.png"
set_module_property DISPLAY_NAME       "Mentor Graphics AXI4 Master BFM (Altera Edition)"
set_module_property GROUP              "Verification/Simulation"
set_module_property EDITABLE           false
set_module_property ANALYZE_HDL        false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset          sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog top_level   mgc_axi4_master

add_fileset          sim_vhdl    SIM_VHDL    proc_sim_vhdl
set_fileset_property sim_vhdl    top_level   mgc_axi4_master_vhd

proc proc_sim_verilog { name } {
}

proc proc_sim_vhdl { name } {
}

# |
# +-----------------------------------

# +-----------------------------------
# | Documentation links
# |
add_documentation_link "AXI4 Master BFM Reference Guide" http://www.altera.com/literature/ug/mentor_vip_ae_usr.pdf
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
# | connection point altera_axi4_master
# |
add_interface          altera_axi4_master axi4 start
set_interface_property altera_axi4_master associatedClock clock_sink
set_interface_property altera_axi4_master associatedReset reset_sink
set_interface_property altera_axi4_master maximumOutstandingReads        1
set_interface_property altera_axi4_master maximumOutstandingWrites       1
set_interface_property altera_axi4_master maximumOutstandingTransactions 1
set_interface_property altera_axi4_master ENABLED true

add_interface_port altera_axi4_master AWVALID    awvalid    Output 1
add_interface_port altera_axi4_master AWPROT     awprot     Output 3
add_interface_port altera_axi4_master AWREGION   awregion   Output 4
add_interface_port altera_axi4_master AWLEN      awlen      Output 8
add_interface_port altera_axi4_master AWSIZE     awsize     Output 3
add_interface_port altera_axi4_master AWBURST    awburst    Output 2
add_interface_port altera_axi4_master AWLOCK     awlock     Output 1
add_interface_port altera_axi4_master AWCACHE    awcache    Output 4
add_interface_port altera_axi4_master AWQOS      awqos      Output 4
add_interface_port altera_axi4_master AWREADY    awready    Input  1
add_interface_port altera_axi4_master ARVALID    arvalid    Output 1
add_interface_port altera_axi4_master ARPROT     arprot     Output 3
add_interface_port altera_axi4_master ARREGION   arregion   Output 4
add_interface_port altera_axi4_master ARLEN      arlen      Output 8
add_interface_port altera_axi4_master ARSIZE     arsize     Output 3
add_interface_port altera_axi4_master ARBURST    arburst    Output 2
add_interface_port altera_axi4_master ARLOCK     arlock     Output 1
add_interface_port altera_axi4_master ARCACHE    arcache    Output 4
add_interface_port altera_axi4_master ARQOS      arqos      Output 4
add_interface_port altera_axi4_master ARREADY    arready    Input  1
add_interface_port altera_axi4_master RVALID     rvalid     Input  1
add_interface_port altera_axi4_master RRESP      rresp      Input  2
add_interface_port altera_axi4_master RLAST      rlast      Input  1
add_interface_port altera_axi4_master RREADY     rready     Output 1
add_interface_port altera_axi4_master WVALID     wvalid     Output 1
add_interface_port altera_axi4_master WLAST      wlast      Output 1
add_interface_port altera_axi4_master WREADY     wready     Input  1
add_interface_port altera_axi4_master BVALID     bvalid     Input  1
add_interface_port altera_axi4_master BRESP      bresp      Input  2
add_interface_port altera_axi4_master BREADY     bready     Output 1
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

  add_interface_port altera_axi4_master AWADDR     awaddr     Output $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_master AWID       awid       Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master AWUSER     awuser     Output $AXI4_USER_WIDTH
  add_interface_port altera_axi4_master ARADDR     araddr     Output $AXI4_ADDRESS_WIDTH
  add_interface_port altera_axi4_master ARID       arid       Output $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master ARUSER     aruser     Output $AXI4_USER_WIDTH
  add_interface_port altera_axi4_master RDATA      rdata      Input  $AXI4_RDATA_WIDTH
  add_interface_port altera_axi4_master RID        rid        Input  $AXI4_ID_WIDTH
  add_interface_port altera_axi4_master WDATA      wdata      Output $AXI4_WDATA_WIDTH
  add_interface_port altera_axi4_master WSTRB      wstrb      Output [ expr ($AXI4_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi4_master BID        bid        Input  $AXI4_ID_WIDTH
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
