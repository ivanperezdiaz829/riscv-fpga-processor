# Generated TCL File
# DO NOT MODIFY

# +-----------------------------------
# |
# | mgc_axi_master_bfm "MGC AXI Master BFM" 10.1e_1
# | Mentor Graphics 13.9
# | AXI Master BFM
# |
# | ./mgc_axi_master.sv sim
# |
# +-----------------------------------

# +-----------------------------------
# | Request TCL Packages.
package require -exact qsys 13.1
# |
# +-----------------------------------

# +-----------------------------------
# | module mgc_axi_master
# |
set_module_property DESCRIPTION        "Mentor Graphics AXI3 Master BFM (Altera Edition)"
set_module_property NAME               mgc_axi_master
set_module_property VERSION            10.1.5.1
set_module_property AUTHOR             "Mentor Graphics Corporation"
set_module_property ICON_PATH          "../../common/Mentor_VIP_AE_icon.png"
set_module_property DISPLAY_NAME       "Mentor Graphics AXI3 Master BFM (Altera Edition)"
set_module_property GROUP              "Verification/Simulation"
set_module_property EDITABLE           false
set_module_property ANALYZE_HDL        false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset          sim_verilog SIM_VERILOG proc_sim_verilog
set_fileset_property sim_verilog top_level   mgc_axi_master

add_fileset          sim_vhdl    SIM_VHDL    proc_sim_vhdl
set_fileset_property sim_vhdl    top_level   mgc_axi_master_vhd

proc proc_sim_verilog { name } {
}

proc proc_sim_vhdl { name } {
}

# |
# +-----------------------------------

# +-----------------------------------
# | Documentation links
# |
add_documentation_link "AXI Master BFM Reference Guide" http://www.altera.com/literature/ug/mentor_vip_ae_usr.pdf
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
# | connection point altera_axi_master
# |
add_interface          altera_axi_master axi start
set_interface_property altera_axi_master associatedClock clock_sink
set_interface_property altera_axi_master associatedReset reset_sink
set_interface_property altera_axi_master maximumOutstandingReads        1
set_interface_property altera_axi_master maximumOutstandingWrites       1
set_interface_property altera_axi_master maximumOutstandingTransactions 1
set_interface_property altera_axi_master ENABLED true

add_interface_port altera_axi_master AWVALID    awvalid    Output 1
add_interface_port altera_axi_master AWLEN      awlen      Output 4
add_interface_port altera_axi_master AWSIZE     awsize     Output 3
add_interface_port altera_axi_master AWBURST    awburst    Output 2
add_interface_port altera_axi_master AWLOCK     awlock     Output 2
add_interface_port altera_axi_master AWCACHE    awcache    Output 4
add_interface_port altera_axi_master AWPROT     awprot     Output 3
add_interface_port altera_axi_master AWREADY    awready    Input  1
add_interface_port altera_axi_master AWUSER     awuser     Output 8
add_interface_port altera_axi_master ARVALID    arvalid    Output 1
add_interface_port altera_axi_master ARLEN      arlen      Output 4
add_interface_port altera_axi_master ARSIZE     arsize     Output 3
add_interface_port altera_axi_master ARBURST    arburst    Output 2
add_interface_port altera_axi_master ARLOCK     arlock     Output 2
add_interface_port altera_axi_master ARCACHE    arcache    Output 4
add_interface_port altera_axi_master ARPROT     arprot     Output 3
add_interface_port altera_axi_master ARREADY    arready    Input  1
add_interface_port altera_axi_master ARUSER     aruser     Output 8
add_interface_port altera_axi_master RVALID     rvalid     Input  1
add_interface_port altera_axi_master RLAST      rlast      Input  1
add_interface_port altera_axi_master RRESP      rresp      Input  2
add_interface_port altera_axi_master RREADY     rready     Output 1
add_interface_port altera_axi_master WVALID     wvalid     Output 1
add_interface_port altera_axi_master WLAST      wlast      Output 1
add_interface_port altera_axi_master WREADY     wready     Input  1
add_interface_port altera_axi_master BVALID     bvalid     Input  1
add_interface_port altera_axi_master BRESP      bresp      Input  2
add_interface_port altera_axi_master BREADY     bready     Output 1
# |
# +-----------------------------------

set_module_property ELABORATION_CALLBACK my_elaborate

proc my_elaborate {} {
  set AXI_ADDRESS_WIDTH    [get_parameter_value AXI_ADDRESS_WIDTH]
  set AXI_RDATA_WIDTH      [get_parameter_value AXI_RDATA_WIDTH]
  set AXI_WDATA_WIDTH      [get_parameter_value AXI_WDATA_WIDTH]
  set AXI_ID_WIDTH         [get_parameter_value AXI_ID_WIDTH]

  add_interface_port altera_axi_master AWADDR     awaddr     Output $AXI_ADDRESS_WIDTH
  add_interface_port altera_axi_master AWID       awid       Output $AXI_ID_WIDTH
  add_interface_port altera_axi_master ARADDR     araddr     Output $AXI_ADDRESS_WIDTH
  add_interface_port altera_axi_master ARID       arid       Output $AXI_ID_WIDTH
  add_interface_port altera_axi_master RDATA      rdata      Input  $AXI_RDATA_WIDTH
  add_interface_port altera_axi_master RID        rid        Input  $AXI_ID_WIDTH
  add_interface_port altera_axi_master WDATA      wdata      Output $AXI_WDATA_WIDTH
  add_interface_port altera_axi_master WSTRB      wstrb      Output [ expr ($AXI_WDATA_WIDTH / 8) ]
  add_interface_port altera_axi_master WID        wid        Output $AXI_ID_WIDTH
  add_interface_port altera_axi_master BID        bid        Input  $AXI_ID_WIDTH
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
