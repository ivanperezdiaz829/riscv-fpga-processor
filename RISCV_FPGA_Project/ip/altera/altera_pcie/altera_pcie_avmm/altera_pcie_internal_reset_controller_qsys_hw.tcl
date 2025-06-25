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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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
# |
# | altera_pcie_internal_reset_controller
# |
# | $Header: //acds/rel/13.1/ip/altera_pcie/altera_pcie_avmm/altera_pcie_internal_reset_controller_qsys_hw.tcl#1 $
# |
# |
# |
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# |
source pcie_parameters.tcl
package require -exact sopc 9.1
package require altera_hwtcl_xml_validator
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_pcie_internal_reset_controller
# |
global env
set qdir $env(QUARTUS_ROOTDIR)
set_module_property NAME altera_pcie_internal_reset_controller_qsys
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/PCI"
set_module_property DISPLAY_NAME "altera_pcie_internal_reset_controller_qsys"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property TOP_LEVEL_HDL_FILE altera_pcie_hard_ip_reset_controller.v
set_module_property TOP_LEVEL_HDL_MODULE altera_pcie_hard_ip_reset_controller
set_module_property ELABORATION_CALLBACK my_elaboration_callback
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE


add_fileset sim_verilog SIM_VERILOG proc_sim_verilog      
set_fileset_property sim_verilog TOP_LEVEL altera_pcie_hard_ip_reset_controller      

add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl                         
set_fileset_property sim_vhdl TOP_LEVEL altera_pcie_hard_ip_reset_controller
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altera_pcie_hard_ip_reset_controller
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |

add_display_item "" "General Settings" GROUP "tab"
add_altera_pcie_internal_reset_controller_parameters "General Settings"

add_interface reset_controller_export conduit end
add_interface_port reset_controller_export clk250_export clk250_export Output 1
add_interface_port reset_controller_export clk500_export clk500_export Output 1
add_interface_port reset_controller_export clk125_export clk125_export Output 1

add_interface reconfig_busy_export conduit end
add_interface_port reconfig_busy_export busy_altgxb_reconfig busy_altgxb_reconfig Input 1


add_interface pld_clk clock end
add_interface_port pld_clk pld_clk clk Input 1


# to work around (remove associated clk pld_clk, add back latter)
add_interface reset_n_out reset start
add_interface_port reset_n_out reset_n_out reset_n Output 1
set_interface_property reset_n_out synchronousEdges NONE

add_interface pcie_rstn conduit end
add_interface_port pcie_rstn pcie_rstn interconect Input 1

add_interface refclk conduit end
add_interface_port refclk refclk interconect Input 1

add_interface l2_exit conduit start
add_interface_port l2_exit l2_exit interconect Input 1

add_interface hotrst_exit conduit end
add_interface_port hotrst_exit hotrst_exit interconect Input 1

add_interface dlup_exit conduit end
add_interface_port dlup_exit dlup_exit interconect Input 1

add_interface ltssm conduit end
add_interface_port ltssm ltssm interconect Input 5

add_interface pll_locked conduit end
add_interface_port pll_locked pll_locked interconect Input 1

add_interface rc_inclk_eq_125mhz conduit end
add_interface_port rc_inclk_eq_125mhz rc_inclk_eq_125mhz interconect Input 1



add_interface rx_signaldetect conduit end
add_interface rx_pll_locked conduit end
add_interface rx_freqlocked conduit end

add_interface test_in conduit end
add_interface_port test_in test_in interconect Input 40

add_interface srst conduit end
add_interface_port srst srst interconect Output 1

add_interface crst conduit end
add_interface_port crst crst interconect Output 1

add_interface rx_digitalreset_serdes conduit end
add_interface_port rx_digitalreset_serdes rx_digitalreset_serdes interconect Output 1

add_interface txdigitalreset conduit end
add_interface_port txdigitalreset txdigitalreset interconect Output 1

add_interface rxanalogreset conduit end
add_interface_port rxanalogreset rxanalogreset interconect Output 1


add_interface clk250_out conduit end
add_interface_port clk250_out clk250_out interconect Output 1

add_interface clk500_out conduit end
add_interface_port clk500_out clk500_out interconect Output 1

proc proc_sim_verilog {name} {
 add_fileset_file altera_pcie_hard_ip_reset_controller.v       VERILOG PATH  altera_pcie_hard_ip_reset_controller.v
 add_fileset_file altpcie_rs_serdes.v                          VERILOG PATH  common/altpcie_rs_serdes.v
 add_fileset_file altpcie_pll_100_250.v                        VERILOG PATH  common/altpcie_pll_100_250.v
 add_fileset_file altpcie_pll_125_250.v                        VERILOG PATH  common/altpcie_pll_125_250.v
}
    
proc proc_sim_vhdl {name} {
     add_fileset_file  altera_pcie_hard_ip_reset_controller.v       VERILOG_ENCRYPT PATH "altera_pcie_hard_ip_reset_controller.v"   {MENTOR_SPECIFIC}
     add_fileset_file  altpcie_rs_serdes.v                          VERILOG_ENCRYPT PATH "common/altpcie_rs_serdes.v"               {MENTOR_SPECIFIC}
     add_fileset_file  altpcie_pll_100_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_100_250.v"             {MENTOR_SPECIFIC}
     add_fileset_file  altpcie_pll_125_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_125_250.v"             {MENTOR_SPECIFIC} 
     
       add_fileset_file  altera_pcie_hard_ip_reset_controller.v       VERILOG_ENCRYPT PATH "altera_pcie_hard_ip_reset_controller.v"   {ALDEC_SPECIFIC}
       add_fileset_file  altpcie_rs_serdes.v                          VERILOG_ENCRYPT PATH "common/altpcie_rs_serdes.v"               {ALDEC_SPECIFIC}
       add_fileset_file  altpcie_pll_100_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_100_250.v"             {ALDEC_SPECIFIC}
       add_fileset_file  altpcie_pll_125_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_125_250.v"             {ALDEC_SPECIFIC}
      
      if { 0 } {
      add_fileset_file  altera_pcie_hard_ip_reset_controller.v      VERILOG_ENCRYPT PATH "altera_pcie_hard_ip_reset_controller.v"    {CADENCE_SPECIFIC}
      add_fileset_file  altpcie_rs_serdes.v                         VERILOG_ENCRYPT PATH "common/altpcie_rs_serdes.v"                {CADENCE_SPECIFIC}
      add_fileset_file  altpcie_pll_100_250.v                       VERILOG_ENCRYPT PATH "common/altpcie_pll_100_250.v"              {CADENCE_SPECIFIC}
      add_fileset_file  altpcie_pll_125_250.v                       VERILOG_ENCRYPT PATH "common/altpcie_pll_125_250.v"              {CADENCE_SPECIFIC}
      }
      if { 0 } {
      add_fileset_file  altera_pcie_hard_ip_reset_controller.v      VERILOG_ENCRYPT PATH "altera_pcie_hard_ip_reset_controller.v"      {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_rs_serdes.v                          VERILOG_ENCRYPT PATH "common/altpcie_rs_serdes.v"                  {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_pll_100_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_100_250.v"                {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_pll_125_250.v                        VERILOG_ENCRYPT PATH "common/altpcie_pll_125_250.v"                {SYNOPSYS_SPECIFIC}
 
}

}
    

proc proc_quartus_synth {name} {
 add_fileset_file altera_pcie_hard_ip_reset_controller.v       VERILOG PATH  altera_pcie_hard_ip_reset_controller.v
 add_fileset_file altpcie_rs_serdes.v                          VERILOG PATH  common/altpcie_rs_serdes.v
 add_fileset_file altpcie_pll_100_250.v                        VERILOG PATH  common/altpcie_pll_100_250.v
 add_fileset_file altpcie_pll_125_250.v                        VERILOG PATH  common/altpcie_pll_125_250.v
}



proc my_elaboration_callback {} {
	set isGen2     [ get_parameter_value enable_gen2_core ]
	set link_width [ get_parameter_value link_width ]
        set family [get_parameter_value INTENDED_DEVICE_FAMILY]
	
	 if { [ string compare -nocase $isGen2 "true" ] == 0 && $link_width == 4 || $link_width == 8 } {
	       set_port_property rc_inclk_eq_125mhz TERMINATION true	
	       set_port_property rc_inclk_eq_125mhz TERMINATION_VALUE 0
	} else {
	 	set_port_property rc_inclk_eq_125mhz TERMINATION true	    
	 	set_port_property rc_inclk_eq_125mhz TERMINATION_VALUE 1  
	}
	
     add_interface_port rx_pll_locked rx_pll_locked interconect Input $link_width
     add_interface_port rx_signaldetect rx_signaldetect interconect Input $link_width
     add_interface_port rx_freqlocked rx_freqlocked interconect Input $link_width
     
     if {[string compare -nocase $family "Cyclone IV GX"] == 0} {
        set_port_property rx_pll_locked TERMINATION true	
        set_port_property rx_pll_locked TERMINATION_VALUE 0
        
        set_port_property rx_signaldetect TERMINATION true	
        set_port_property rx_signaldetect TERMINATION_VALUE 0
     	 
     	} 
     
}
