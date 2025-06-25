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
# | $Header: //acds/rel/13.1/ip/altera_pcie/altera_pcie_avmm/altera_pcie_internal_pipe_interface_qsys_hw.tcl#1 $
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
set_module_property NAME altera_pcie_internal_pipe_interface_qsys
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/PCI"
set_module_property DISPLAY_NAME "altera_pcie_internal_pipe_interface_qsys"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property TOP_LEVEL_HDL_FILE altpcie_pipe_interface.v
set_module_property TOP_LEVEL_HDL_MODULE altpcie_pipe_interface
set_module_property ELABORATION_CALLBACK my_elaboration_callback
set_module_property ANALYZE_HDL FALSE

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_fileset sim_verilog SIM_VERILOG proc_sim_verilog      
set_fileset_property sim_verilog TOP_LEVEL altpcie_pipe_interface    


add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl               
set_fileset_property sim_vhdl TOP_LEVEL altpcie_pipe_interface  

# | 

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
set_fileset_property synth TOP_LEVEL altpcie_pipe_interface
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

add_display_item "" "General Settings" GROUP "tab"
add_altera_pcie_internal_pipe_interface_parameters ""



add_interface pipe_interface_export conduit end
add_interface_port pipe_interface_export pipe_mode pipe_mode Input 1


add_interface_port pipe_interface_export phystatus_ext phystatus_ext Input 1


add_interface_port pipe_interface_export rate_ext rate_ext Output 1

add_interface_port pipe_interface_export powerdown_ext powerdown_ext Output 2


add_interface_port pipe_interface_export txdetectrx_ext txdetectrx_ext Output 1


add_interface powerdown_export conduit end
add_interface_port powerdown_export pll_powerdown pll_powerdown Input 1
add_interface_port powerdown_export gxb_powerdown gxb_powerdown Input 1

add_interface pll_locked_pcs conduit end
add_interface_port pll_locked_pcs pll_locked_pcs interconect Input 1


add_interface hip_tx_clkout_pcs conduit end
add_interface_port hip_tx_clkout_pcs hip_tx_clkout_pcs interconect Input 1

add_interface rate_hip conduit end
add_interface_port rate_hip rate_hip interconect Input 1

add_interface clk500_out conduit end
add_interface_port clk500_out clk500_out interconect Input 1

add_interface clk250_out conduit end
add_interface_port clk250_out clk250_out interconect Input 1

add_interface core_clk_out clock end
add_interface_port core_clk_out core_clk_out clk Input 1

add_interface rc_pll_locked conduit end
add_interface_port rc_pll_locked rc_pll_locked interconect Output 1

add_interface gxb_powerdown_pcs conduit end
add_interface_port gxb_powerdown_pcs gxb_powerdown_pcs interconect Output 1

add_interface pll_powerdown_pcs conduit end
add_interface_port pll_powerdown_pcs pll_powerdown_pcs interconect Output 1

add_interface pclk_central_hip conduit end
add_interface_port pclk_central_hip pclk_central_hip interconect Output 1

add_interface pclk_ch0_hip conduit end                               
add_interface_port pclk_ch0_hip pclk_ch0_hip interconect Output 1

add_interface rateswitch_pcs conduit end
add_interface_port rateswitch_pcs rateswitch_pcs interconect Output 1

add_interface pll_fixed_clk_hip conduit end
add_interface_port pll_fixed_clk_hip pll_fixed_clk_hip interconect Output 1

add_interface pcie_rstn conduit end
add_interface_port pcie_rstn pcie_rstn interconect Input 1

add_interface rc_areset conduit end
add_interface_port rc_areset rc_areset interconect Output 1

proc proc_sim_verilog {name} {
 add_fileset_file altpcie_pipe_interface.v             VERILOG PATH  "altpcie_pipe_interface.v"
 add_fileset_file altpcie_pcie_reconfig_bridge.v       VERILOG PATH  "common/altpcie_pcie_reconfig_bridge.v"
}

proc proc_sim_vhdl {name} {
     add_fileset_file  altpcie_pipe_interface.v       VERILOG_ENCRYPT PATH "altpcie_pipe_interface.v"                      {MENTOR_SPECIFIC}
     add_fileset_file altpcie_pcie_reconfig_bridge.v  VERILOG_ENCRYPT PATH "common/altpcie_pcie_reconfig_bridge.v"         {MENTOR_SPECIFIC} 
     
     add_fileset_file  altpcie_pipe_interface.v       VERILOG_ENCRYPT PATH "altpcie_pipe_interface.v"                      {ALDEC_SPECIFIC} 
     add_fileset_file altpcie_pcie_reconfig_bridge.v  VERILOG_ENCRYPT PATH "common/altpcie_pcie_reconfig_bridge.v"         {ALDEC_SPECIFIC} 
      
      if { 0 } {
      add_fileset_file  altpcie_pipe_interface.v        VERILOG_ENCRYPT PATH "altpcie_pipe_interface.v"                    {CADENCE_SPECIFIC}
      add_fileset_file altpcie_pcie_reconfig_bridge.v   VERILOG_ENCRYPT PATH "common/altpcie_pcie_reconfig_bridge.v"       {CADENCE_SPECIFIC}
      }
      if { 0 } {
      add_fileset_file  altpcie_pipe_interface.v        VERILOG_ENCRYPT PATH "altpcie_pipe_interface.v"                    {SYNOPSYS_SPECIFIC}
      add_fileset_file altpcie_pcie_reconfig_bridge.v   VERILOG_ENCRYPT PATH "common/altpcie_pcie_reconfig_bridge.v"       {SYNOPSYS_SPECIFIC}
   }             

}



proc proc_quartus_synth {name} {
	 add_fileset_file altpcie_pipe_interface.v             VERILOG PATH  altpcie_pipe_interface.v
   add_fileset_file altpcie_pcie_reconfig_bridge.v       VERILOG PATH  common/altpcie_pcie_reconfig_bridge.v
}



proc my_elaboration_callback {} {
    set link_width [ get_parameter_value link_width ]
    for { set i 0 } { $i < $link_width } { incr i } {
    	add_interface_port pipe_interface_export rxelecidle${i}_ext rxelecidle${i}_ext Input 1    
    	add_interface_port pipe_interface_export rxdata${i}_ext rxdata${i}_ext Input 8   
    	add_interface_port pipe_interface_export rxstatus${i}_ext rxstatus${i}_ext Input 3 
    	add_interface_port pipe_interface_export rxvalid${i}_ext rxvalid${i}_ext Input 1  
        add_interface_port pipe_interface_export rxdatak${i}_ext rxdatak${i}_ext Input 1 	
    	add_interface_port pipe_interface_export txdata${i}_ext txdata${i}_ext Output 8
    	add_interface_port pipe_interface_export txdatak${i}_ext txdatak${i}_ext Output 1 
    	add_interface_port pipe_interface_export rxpolarity${i}_ext rxpolarity${i}_ext Output 1 
    	add_interface_port pipe_interface_export txcompl${i}_ext txcompl${i}_ext Output 1 
    	add_interface_port pipe_interface_export txelecidle${i}_ext txelecidle${i}_ext Output 1   
    	
    	add_interface txdata${i}_hip conduit end                          
    	add_interface_port txdata${i}_hip txdata${i}_hip interconect Input 8 
    	
    	add_interface txdatak${i}_hip conduit end                           
        add_interface_port txdatak${i}_hip txdatak${i}_hip interconect Input 1    
        
        add_interface powerdown${i}_hip conduit end                            
        add_interface_port powerdown${i}_hip powerdown${i}_hip interconect Input 2
        
        add_interface rxpolarity${i}_hip conduit end                             
        add_interface_port rxpolarity${i}_hip rxpolarity${i}_hip interconect Input 1
        
        add_interface txcompl${i}_hip conduit end                          
        add_interface_port txcompl${i}_hip txcompl${i}_hip interconect Input 1
        
        add_interface txdetectrx${i}_hip conduit end                             
        add_interface_port txdetectrx${i}_hip txdetectrx${i}_hip interconect Input 1
        
        add_interface txelecidle${i}_hip conduit end                             
        add_interface_port txelecidle${i}_hip txelecidle${i}_hip interconect Input 1
        
        add_interface rxdata_hip_${i} conduit end                           
        add_interface_port rxdata_hip_${i} rxdata_hip_${i} interconect output 8
        set_port_property rxdata_hip_${i} FRAGMENT_LIST "rxdata_hip([expr 8 * $i + 7]:[expr 8 * $i])"  

       add_interface rxdatak_hip_${i} conduit end                                                      
       add_interface_port rxdatak_hip_${i} rxdatak_hip_${i} interconect output 1                        
       set_port_property rxdatak_hip_${i} FRAGMENT_LIST "rxdatak_hip(${i})"  
       
        add_interface rxstatus_hip_${i} conduit end                                                        
        add_interface_port rxstatus_hip_${i} rxstatus_hip_${i} interconect output 3                          
        set_port_property rxstatus_hip_${i} FRAGMENT_LIST "rxstatus_hip([expr 3 * $i + 2]:[expr 3 * $i])"    
        
        add_interface powerdown_pcs conduit end                            
        add_interface_port powerdown_pcs powerdown_pcs interconect Output [expr 2 * $link_width]
        
        
                                                                                                         
       add_interface rxdata_pcs conduit end                         
       add_interface_port rxdata_pcs rxdata_pcs interconect Input [expr 8 * $link_width]    
       
       add_interface phystatus_pcs conduit end                           
       add_interface_port phystatus_pcs phystatus_pcs interconect Input $link_width
       
       add_interface rxelecidle_pcs conduit end                            
       add_interface_port rxelecidle_pcs rxelecidle_pcs interconect Input $link_width 
        
       add_interface rxvalid_pcs conduit end                           
       add_interface_port rxvalid_pcs rxvalid_pcs interconect Input $link_width  
        
       add_interface rxdatak_pcs conduit end                          
       add_interface_port rxdatak_pcs rxdatak_pcs interconect Input $link_width   
        
       add_interface rxstatus_pcs conduit end                            
       add_interface_port rxstatus_pcs rxstatus_pcs interconect Input [expr 3 * $link_width]  
        
       add_interface txdata_pcs conduit end                           
       add_interface_port txdata_pcs txdata_pcs interconect Output [expr 8 * $link_width] 
       
       add_interface rxpolarity_pcs conduit end                              
       add_interface_port rxpolarity_pcs rxpolarity_pcs interconect Output $link_width 
                                                                             
       add_interface txcompl_pcs conduit end                                 
       add_interface_port txcompl_pcs txcompl_pcs interconect Output $link_width       
                                                                             
       add_interface txdatak_pcs conduit end                                 
       add_interface_port txdatak_pcs txdatak_pcs interconect Output $link_width       
                                                                             
                                                                             
       add_interface txdetectrx_pcs conduit end                              
       add_interface_port txdetectrx_pcs txdetectrx_pcs interconect Output $link_width  
                                                                              
       add_interface txelecidle_pcs conduit end                               
       add_interface_port txelecidle_pcs txelecidle_pcs interconect Output $link_width  
                    
       add_interface phystatus_hip_${i} conduit end                                                                                          
       add_interface_port phystatus_hip_${i} phystatus_hip_${i} interconect output 1  
       set_port_property phystatus_hip_${i} FRAGMENT_LIST "phystatus_hip(${i})"      
       
        add_interface rxelecidle_hip_${i} conduit end                                  
        add_interface_port rxelecidle_hip_${i} rxelecidle_hip_${i} interconect output 1 
        set_port_property rxelecidle_hip_${i} FRAGMENT_LIST "rxelecidle_hip(${i})"     
        
         add_interface rxvalid_hip_${i} conduit end                                       
         add_interface_port rxvalid_hip_${i} rxvalid_hip_${i} interconect output 1   
         set_port_property rxvalid_hip_${i} FRAGMENT_LIST "rxvalid_hip(${i})"    
         
}

add_interface rateswitchbaseclock_pcs conduit end
if { $link_width == 8 } {
     add_interface_port rateswitchbaseclock_pcs rateswitchbaseclock_pcs interconect Input 2
   } else {
     add_interface_port rateswitchbaseclock_pcs rateswitchbaseclock_pcs interconect Input 1
}
        
  }
  
