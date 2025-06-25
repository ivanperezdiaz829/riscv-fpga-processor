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
# | altera_pcie_bfm
# | 
# | $Header: //acds/rel/13.1/ip/altera_pcie/altera_pcie_avmm/altera_pcie_bfm_hw.tcl#1 $
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
# | module altera_pcie_bfm
# | 
global env
set qdir $env(QUARTUS_ROOTDIR)
set_module_property NAME altera_pcie_bfm
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "altera_pcie_bfm"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property TOP_LEVEL_HDL_FILE altera_pcie_bfm.v
set_module_property TOP_LEVEL_HDL_MODULE altera_pcie_bfm
set_module_property ELABORATION_CALLBACK my_elaboration_callback   
set_module_property ANALYZE_HDL FALSE

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
# | 
# +-----------------------------------

add_file altera_pcie_bfm.v {SYNTHESIS SIMULATION}
add_file testbench/verilog/common/altera_pcie_bfm_components.v {SYNTHESIS SIMULATION}
add_file testbench/verilog/qsys/altpcietb_bfm_driver.v {SYNTHESIS SIMULATION}
add_file $qdir/eda/sim_lib/stratixiv_hssi_atoms.v {SYNTHESIS SIMULATION}
add_file $qdir/eda/sim_lib/stratixiv_pcie_hip_atoms.v {SYNTHESIS SIMULATION}
add_file $qdir/eda/sim_lib/cycloneiv_hssi_atoms.v {SYNTHESIS SIMULATION}
add_file $qdir/eda/sim_lib/cycloneiv_pcie_hip_atoms.v {SYNTHESIS SIMULATION}

# +-----------------------------------
# | parameters
# | 

add_parameter LINK_WIDTH integer 4
add_parameter TEST_OUT_WIDTH string "64bits"

add_display_item "" "General Settings" GROUP "tab"
add_altera_pcie_bfm_parameters "General Settings"

add_interface test_out conduit end
add_interface_port test_out test_out test_out Input 64


add_interface pcie_rstn conduit end
add_interface_port pcie_rstn pcie_rstn export Output 1



add_interface refclk conduit end
add_interface_port refclk refclk export Output 1

add_interface test_in conduit end
add_interface_port test_in test_in test_in Output 40




proc my_elaboration_callback {} {
 global PCIE_BFM_PARAMETERS
 #   add_interface_port rx_signaldetect rx_signaldetect interconect Input [get_parameter_value link_width]
 set my_link_width [ get_parameter_value LINK_WIDTH ]
 set my_test_width [ get_parameter_value TEST_OUT_WIDTH ]
 
 
 
 if { $my_test_width == "64bits" } {
      add_interface test_out conduit end
      add_interface_port test_out test_out test_out Input 64
   } elseif { $my_test_width == "9bits" } {
      add_interface test_out conduit end
      add_interface_port test_out test_out test_out Input 9
      set_port_property test_out FRAGMENT_LIST "test_out(8:0)"
}
 
add_interface rx_in  conduit end
add_interface tx_out conduit end
add_interface pipe_ext conduit end
#add_interface gxb_reconfig conduit end
add_interface clocks_sim conduit end      
                     
add_interface_port clocks_sim clk500_out clk500_export Input 1        
add_interface_port clocks_sim clk250_out clk250_export Input 1 
add_interface_port clocks_sim clk125_out clk125_export Input 1
add_interface_port pipe_ext gxb_powerdown gxb_powerdown Output 1
add_interface_port pipe_ext pll_powerdown pll_powerdown Output 1
add_interface_port pipe_ext phystatus_ext phystatus_ext Output 1
add_interface_port pipe_ext txdetectrx_ext txdetectrx_ext Input 1
add_interface_port pipe_ext rate_ext rate_ext Input 1
add_interface_port pipe_ext powerdown_ext powerdown_ext Input 2
add_interface_port pipe_ext pipe_mode pipe_mode Output 1
#add_interface_port gxb_reconfig reconfig_togxb reconfig_togxb Output 4
#add_interface_port gxb_reconfig reconfig_clk reconfig_clk Output 1


for { set i 0 } { $i < $my_link_width } { incr i } {  
   
   add_interface_port tx_out tx_out${i} tx_dataout_${i} Input 1
   add_interface_port rx_in rx_in${i} rx_datain_${i} Output 1
   
   add_interface_port pipe_ext rxpolarity${i}_ext rxpolarity${i}_ext Input 1
   
   add_interface_port pipe_ext txcompl${i}_ext txcompl${i}_ext Input 1
   
   add_interface_port pipe_ext txdata${i}_ext txdata${i}_ext Input 8
   
   add_interface_port pipe_ext txdatak${i}_ext txdatak${i}_ext Input 1
   
   add_interface_port pipe_ext txelecidle${i}_ext txelecidle${i}_ext Input 1
   
   add_interface_port pipe_ext rxdata${i}_ext rxdata${i}_ext Output 8
   
   add_interface_port pipe_ext rxdatak${i}_ext rxdatak${i}_ext Output 1
   
   add_interface_port pipe_ext rxelecidle${i}_ext rxelecidle${i}_ext Output 1
   
   add_interface_port pipe_ext rxstatus${i}_ext rxstatus${i}_ext Output 3
   
   add_interface_port pipe_ext rxvalid${i}_ext rxvalid${i}_ext Output 1
   
   add_interface_port pipe_ext phystatus_ext phystatus_ext Output 1
   
                }
                
for { set i $my_link_width } { $i < 8 } { incr i } {  
   add_interface rxpolarity${i}_ext conduit end	
   add_interface_port rxpolarity${i}_ext rxpolarity${i}_ext interconect input 1   
   set_port_property rxpolarity${i}_ext TERMINATION true                      
   set_port_property rxpolarity${i}_ext TERMINATION_VALUE 0  
   
   add_interface txcompl${i}_ext conduit end	
   add_interface_port txcompl${i}_ext txcompl${i}_ext interconect input 1   
   set_port_property txcompl${i}_ext TERMINATION true                      
   set_port_property txcompl${i}_ext TERMINATION_VALUE 0  
   
   add_interface txdata${i}_ext conduit end	
   add_interface_port txdata${i}_ext txdata${i}_ext interconect input 8  
   set_port_property txdata${i}_ext TERMINATION true                      
   set_port_property txdata${i}_ext TERMINATION_VALUE 0  
   
   add_interface txdatak${i}_ext conduit end	
   add_interface_port txdatak${i}_ext txdatak${i}_ext interconect input 1
   set_port_property txdatak${i}_ext TERMINATION true                      
   set_port_property txdatak${i}_ext TERMINATION_VALUE 0 
   
   add_interface txelecidle${i}_ext conduit end	
   add_interface_port txelecidle${i}_ext txelecidle${i}_ext interconect input 1
   set_port_property txelecidle${i}_ext TERMINATION true                      
   set_port_property txelecidle${i}_ext TERMINATION_VALUE 1 
   
   add_interface tx_out${i} conduit end	
   add_interface_port tx_out${i} tx_out${i} interconect input 1
   set_port_property tx_out${i} TERMINATION true                      
   set_port_property tx_out${i} TERMINATION_VALUE 0  
   
   add_interface rx_in${i} conduit end	
   add_interface_port rx_in${i} rx_in${i} interconect Output 1
   set_port_property rx_in${i} TERMINATION true                      
   set_port_property rx_in${i} TERMINATION_VALUE 0 
   
   
   add_interface rxdata${i}_ext conduit end	
   add_interface_port rxdata${i}_ext rxdata${i}_ext interconect Output 8
   set_port_property rxdata${i}_ext TERMINATION true                      
   set_port_property rxdata${i}_ext TERMINATION_VALUE 0 
   
   add_interface rxdatak${i}_ext conduit end	
   add_interface_port rxdatak${i}_ext rxdatak${i}_ext interconect Output 1
   set_port_property rxdatak${i}_ext TERMINATION true                      
   set_port_property rxdatak${i}_ext TERMINATION_VALUE 0
   
   add_interface rxelecidle${i}_ext conduit end	
   add_interface_port rxelecidle${i}_ext rxelecidle${i}_ext interconect Output 1
   set_port_property rxelecidle${i}_ext TERMINATION true                      
   set_port_property rxelecidle${i}_ext TERMINATION_VALUE 0
   
   add_interface rxstatus${i}_ext conduit end	
   add_interface_port rxstatus${i}_ext rxstatus${i}_ext interconect Output 3
   set_port_property rxstatus${i}_ext TERMINATION true                      
   set_port_property rxstatus${i}_ext TERMINATION_VALUE 0
   
   add_interface rxvalid${i}_ext conduit end	
   add_interface_port rxvalid${i}_ext rxvalid${i}_ext interconect Output 1
   set_port_property rxvalid${i}_ext TERMINATION true                      
   set_port_property rxvalid${i}_ext TERMINATION_VALUE 0
   
                }         
                
#if { $link_width == 8 } {
#    add_interface_port gxb_reconfig reconfig_fromgxb reconfig_fromgxb Input 34
#     } else {
#     	
#     	
#    add_interface_port gxb_reconfig reconfig_fromgxb reconfig_fromgxb Input 17
#    set_port_property reconfig_fromgxb FRAGMENT_LIST "reconfig_fromgxb(16:0)"
#    
#    add_interface reconfig_fromgxb_33_17 conduit end
#    add_interface_port reconfig_fromgxb_33_17 reconfig_fromgxb_33_17 interconect Input 17
#    set_port_property reconfig_fromgxb_33_17 FRAGMENT_LIST "reconfig_fromgxb(33:17)"
#    set_port_property reconfig_fromgxb_33_17 TERMINATION true                      
#    set_port_property reconfig_fromgxb_33_17 TERMINATION_VALUE 0  
#        }
     


}
