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


package require -exact sopc 10.1
sopc::preview_add_transform name preview_avalon_mm_transform
source pcie_parameters.tcl
source pcie_parameters_validation.tcl
source rx_buffer_config.tcl
set    NEW_RXM_ENABLE 0

if { $NEW_RXM_ENABLE == 0 } { 
	
set_module_property DESCRIPTION "IP_Compiler for PCI Express"
set_module_property NAME altera_pcie_hard_ip
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/products/ip/iup/pci-express/m-alt-pcie8.html"
set_module_property "group" "Interface Protocols/PCI"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "IP_Compiler for PCI Express"
set_module_property HIDE_FROM_SOPC "true"

set_module_property instantiateInSystemModule "true"
set_module_property EDITABLE false
set_module_property INTERNAL false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL FALSE

# ************* Utility Functions ***************

proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i <= $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

     return $val
 }

proc pow2 { num } {
    if { $num == 0 } {
        return 1
    }

    return [ expr 1 << $num ]
}

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

#Removing the tabs for now, will enable this if needed

#add_display_item "" "System Settings" GROUP "tab"
#add_display_item "System Settings" "PCIe System Parameters" GROUP

#add_display_item "" "PCI Registers" GROUP "tab"
#add_display_item "PCI Registers" "PCI Base Address Registers (Type 0 Configuration Space)" GROUP
#add_display_item "PCI Registers" "PCI Read-Only Registers" GROUP


#add_display_item "" "Capabilities" GROUP "tab"
#add_display_item "Capabilities" "Link Capabilities" GROUP
#add_display_item "Capabilities" "Error Reporting" GROUP


#add_display_item "" "Buffer setup" GROUP "tab"
#add_display_item "Buffer setup" "Buffer Configuration" GROUP

#add_display_item "" "Avalon" GROUP "tab"
#add_display_item "Avalon" "Parameters" GROUP
#add_display_item "Avalon" "Address Translation Table Size" GROUP
#add_display_item "Avalon" "Fixed Address Translation Table Contents" GROUP


#add_display_item "" "ALTGX Parameters" GROUP "tab"
#add_display_item "" "Reset Controller Parameters" GROUP "tab"

##This parameter indicates testing mode ###
add_parameter under_test integer 0
set_parameter_property under_test AFFECTS_ELABORATION true
set_parameter_property under_test VISIBLE false


add_pcie_hip_parameters



for { set i 0 } { $i < 6 } { incr i } {
    add_parameter "SLAVE_ADDRESS_MAP_$i" integer 0
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_type ADDRESS_WIDTH
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_arg "bar${i}"
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" AFFECTS_ELABORATION true
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" VISIBLE false
 
    #PCIE HIP Derived Parameters
    set_parameter_property "CB_P2A_AVALON_ADDR_B${i}" DERIVED true
    set_parameter_property "bar${i}_size_mask" DERIVED true
    set_parameter_property "bar${i}_64bit_mem_space" DERIVED true
    set_parameter_property "bar${i}_prefetchable" DERIVED true
    set_parameter_property BAR DERIVED true
    set_parameter_property "BAR Size" DERIVED true
    set_parameter_property "BAR Size" DERIVED true
    set_parameter_property "Avalon Base Address" DERIVED true

}


### Adding parameters for the 64 bit BAR cases
add_parameter "SLAVE_ADDRESS_MAP_1_0" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" system_info_arg "bar1_0"
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" VISIBLE false

add_parameter "SLAVE_ADDRESS_MAP_3_2" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" system_info_arg "bar3_2"
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" VISIBLE false

add_parameter "SLAVE_ADDRESS_MAP_5_4" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" system_info_arg "bar5_4"
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" VISIBLE false


 for { set i 0 } { $i < 16 } { incr i } {

    set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" DERIVED true
    set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" DERIVED true

}

set_parameter_property "Address Page" DERIVED true


 ##TODO seeting these derived on teh top level
 set_parameter_property vc0_rx_flow_ctrl_posted_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_posted_data DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_nonposted_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_nonposted_data DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_compl_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_compl_data DERIVED true


#add_altera_pcie_internal_altgx_parameters "ALTGX Parameters"
add_altera_pcie_internal_altgx_parameters ""
set_parameter_property wiz_subprotocol DERIVED true

#add_altera_pcie_internal_reset_controller_parameters "Reset Controller Parameters"
add_altera_pcie_internal_reset_controller_parameters ""
add_altera_pcie_internal_pipe_interface_parameters "Pipe Interface Parameters"
set_parameter_property link_width DERIVED true
set_parameter_property cyclone4 DERIVED true
set_parameter_property p_pcie_hip_type DERIVED true

set_parameter_property core_clk_divider DERIVED true
set_parameter_property enable_ch0_pclk_out DERIVED true
set_parameter_property core_clk_source DERIVED true
set_parameter_property millisecond_cycle_count DERIVED true
set_parameter_property enable_gen2_core DERIVED true
set_parameter_property lane_mask DERIVED true
set_parameter_property single_rx_detect DERIVED true
set_parameter_property retry_buffer_last_active_address DERIVED true
set_parameter_property  gen2_lane_rate_mode DERIVED true


# ***********************************************

# ************* Static Instances ****************

#add_instance "pcie_internal_hip" altera_pcie_internal_hard_ip
add_instance "pcie_internal_hip" altera_pcie_internal_hard_ip_qsys
add_instance "altgx_internal" altera_pcie_internal_altgx
add_instance "reset_controller_internal" altera_pcie_internal_reset_controller_qsys
add_instance "pipe_interface_internal" altera_pcie_internal_pipe_interface_qsys

add_instance "avalon_clk" altera_clock_bridge
add_instance "cal_blk_clk" altera_clock_bridge
#add_instance "reference_clk" altera_clock_bridge
#set_instance_parameter_value reference_clk NUM_CLOCK_OUTPUTS 2

add_instance "test_in_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value test_in_conduit CONDUIT_WIDTH 40
set_instance_parameter_value test_in_conduit NUM_OUTPUTS 2
set_instance_parameter_value test_in_conduit CONDUIT_INPUT_ROLE test_in
set_instance_parameter_value test_in_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect"

add_instance "pcie_rstn_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value pcie_rstn_conduit CONDUIT_WIDTH 1
set_instance_parameter_value pcie_rstn_conduit NUM_OUTPUTS 3
set_instance_parameter_value pcie_rstn_conduit CONDUIT_INPUT_ROLE export
set_instance_parameter_value pcie_rstn_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect,interconect"


add_instance "refclk_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value refclk_conduit CONDUIT_WIDTH 1
set_instance_parameter_value refclk_conduit NUM_OUTPUTS 10
set_instance_parameter_value refclk_conduit CONDUIT_INPUT_ROLE export
set_instance_parameter_value refclk_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect"



add_instance "avalon_reset" altera_reset_bridge
set_instance_parameter_value avalon_reset SYNCHRONOUS_EDGES both


# ***********************************************

# ************* Static Interfaces ***************


# Avalon Clock Connection
add_connection pcie_internal_hip.pcie_core_clk avalon_clk.in_clk

# core clock export and input

#Avalon Reset connection
add_connection reset_controller_internal.reset_n_out avalon_reset.in_reset



# PCIe core clock/reset out

add_interface pcie_core_clk clock start
set_interface_property pcie_core_clk ENABLED true
set_interface_property pcie_core_clk export_of pcie_internal_hip.pcie_core_clk


add_interface pcie_core_reset reset start
set_interface_property pcie_core_reset export_of reset_controller_internal.reset_n_out
add_interface cal_blk_clk clock end
set_interface_property cal_blk_clk export_of cal_blk_clk.in_clk


# PCIE Internal HIP Exports
add_interface "txs" avalon slave
set_interface_property txs export_of pcie_internal_hip.Txs




# ALTGX Connections
add_connection  cal_blk_clk.out_clk altgx_internal.cal_blk_clk
#add_connection  pcie_internal_hip.pcie_core_clk altgx_internal.fixedclk
add_connection  pcie_internal_hip.pcie_core_clk pipe_interface_internal.core_clk_out
add_connection  pcie_internal_hip.pcie_core_clk reset_controller_internal.pld_clk
add_connection  pcie_internal_hip.pcie_core_clk pcie_internal_hip.pld_clk

# ***********************************************

# ************* Static Connections **************

#Avalon Reset Connections
add_connection avalon_reset.out_reset pcie_internal_hip.avalon_reset reset

#Avalon Clock Connections
add_connection avalon_clk.out_clk pcie_internal_hip.avalon_clk clock
add_connection avalon_clk.out_clk avalon_reset.clk



#ALTGX Internal Connections


add_connection  altgx_internal.rx_digitalreset reset_controller_internal.rx_digitalreset_serdes


add_connection altgx_internal.tx_ctrlenable pipe_interface_internal.txdatak_pcs

add_connection altgx_internal.tx_datain pipe_interface_internal.txdata_pcs


add_connection pipe_interface_internal.pclk_central_hip pcie_internal_hip.pclk_central
add_connection pipe_interface_internal.pclk_ch0_hip pcie_internal_hip.pclk_ch0

add_connection pipe_interface_internal.pll_fixed_clk_hip pcie_internal_hip.pll_fixed_clk

add_interface refclk conduit end
set_interface_property refclk export_of refclk_conduit.conduit_in
add_connection refclk_conduit.conduit_out_0 reset_controller_internal.refclk
add_connection refclk_conduit.conduit_out_1 altgx_internal.pll_inclk

# Reset Controller Connections


add_connection reset_controller_internal.l2_exit pcie_internal_hip.l2_exit
add_connection reset_controller_internal.hotrst_exit pcie_internal_hip.hotrst_exit
add_connection reset_controller_internal.dlup_exit pcie_internal_hip.dlup_exit
add_connection reset_controller_internal.ltssm pcie_internal_hip.dl_ltssm_int
add_connection reset_controller_internal.srst pcie_internal_hip.srst
add_connection reset_controller_internal.crst pcie_internal_hip.crst
add_connection reset_controller_internal.pll_locked pipe_interface_internal.rc_pll_locked

add_connection reset_controller_internal.rx_freqlocked altgx_internal.rx_freqlocked
add_connection reset_controller_internal.txdigitalreset altgx_internal.tx_digitalreset
add_connection reset_controller_internal.rxanalogreset altgx_internal.rx_analogreset






add_interface test_in conduit end
set_interface_property test_in export_of test_in_conduit.conduit_in
add_connection test_in_conduit.conduit_out_0 pcie_internal_hip.test_in
add_connection test_in_conduit.conduit_out_1 reset_controller_internal.test_in


add_interface pcie_rstn conduit end
set_interface_property pcie_rstn export_of pcie_rstn_conduit.conduit_in
add_connection pcie_rstn_conduit.conduit_out_0 pcie_internal_hip.npor
add_connection pcie_rstn_conduit.conduit_out_1 reset_controller_internal.pcie_rstn
add_connection pcie_rstn_conduit.conduit_out_2 pipe_interface_internal.pcie_rstn




add_interface clocks_sim conduit end
set_interface_property clocks_sim export_of reset_controller_internal.reset_controller_export




add_interface reconfig_busy conduit end
set_interface_property reconfig_busy export_of reset_controller_internal.reconfig_busy_export
set_interface_assignment reconfig_busy "ui.blockdiagram.direction" "output"


#pipe interface connections
add_interface pipe_ext conduit end
set_interface_property pipe_ext export_of pipe_interface_internal.pipe_interface_export

add_interface powerdown conduit end
set_interface_property powerdown export_of pipe_interface_internal.powerdown_export


add_connection pipe_interface_internal.rc_areset pcie_internal_hip.rc_areset
add_connection altgx_internal.rx_dataout pipe_interface_internal.rxdata_pcs
add_connection altgx_internal.pipephydonestatus pipe_interface_internal.phystatus_pcs
add_connection altgx_internal.pipeelecidle pipe_interface_internal.rxelecidle_pcs
add_connection altgx_internal.pipedatavalid pipe_interface_internal.rxvalid_pcs
add_connection altgx_internal.pipestatus pipe_interface_internal.rxstatus_pcs
add_connection altgx_internal.rx_ctrldetect pipe_interface_internal.rxdatak_pcs

add_connection altgx_internal.gxb_powerdown pipe_interface_internal.gxb_powerdown_pcs
add_connection altgx_internal.hip_tx_clkout_0 pipe_interface_internal.hip_tx_clkout_pcs
add_connection reset_controller_internal.clk250_out pipe_interface_internal.clk250_out
add_connection reset_controller_internal.clk500_out pipe_interface_internal.clk500_out

add_connection pcie_internal_hip.rate_ext pipe_interface_internal.rate_hip

add_connection altgx_internal.pll_locked pipe_interface_internal.pll_locked_pcs

add_connection altgx_internal.powerdn pipe_interface_internal.powerdown_pcs

add_connection altgx_internal.pipe8b10binvpolarity pipe_interface_internal.rxpolarity_pcs


add_connection altgx_internal.tx_forcedispcompliance pipe_interface_internal.txcompl_pcs

add_connection altgx_internal.tx_detectrxloop pipe_interface_internal.txdetectrx_pcs

add_connection altgx_internal.tx_forceelecidle pipe_interface_internal.txelecidle_pcs

# For testbench purpose
set pcie_bfm_name    pcie_bfm_0
set pcie_bfm_class   altera_pcie_bfm_qsys

# This is to tell the testbench generator that "this.interface" maps to "my_partner_name.interface"
set_module_assignment "testbench.partner.map.clocks_sim"          "$pcie_bfm_name.clocks_sim"
#set_module_assignment "testbench.partner.map.gxb_reconfig"        "$pcie_bfm_name.gxb_reconfig"
set_module_assignment "testbench.partner.map.pcie_rstn"           "$pcie_bfm_name.pcie_rstn"
set_module_assignment "testbench.partner.map.pipe_ext"            "$pcie_bfm_name.pipe_ext"
set_module_assignment "testbench.partner.map.powerdown"            "$pcie_bfm_name.powerdown"
set_module_assignment "testbench.partner.map.refclk"              "$pcie_bfm_name.refclk"
set_module_assignment "testbench.partner.map.test_in"             "$pcie_bfm_name.test_in"

set_module_assignment "testbench.partner.map.rx_in"             "$pcie_bfm_name.rx_in"
set_module_assignment "testbench.partner.map.tx_out"            "$pcie_bfm_name.tx_out"


# This is to tell the testbench generator "my_partner_name" is a "my_partner_type"
set_module_assignment "testbench.partner.$pcie_bfm_name.class"    "$pcie_bfm_class"
# Setting version is optional
 set_module_assignment "testbench.partner.$pcie_bfm_name.version"  "11.0"


# ***********************************************

proc compose { } {
    global MAX_PREFETCH_MASTERS
    global ALL_PCIE_HIP_PARAMETERS
    global ALTGX_PARAMETERS
    global RESET_CONTROLLER_PARAMETERS
    global PIPE_INTERFACE_PARAMETERS

     set test_width [get_parameter_value p_pcie_test_out_width]

     if { $test_width == "64bits" || $test_width == "9bits" } {
       add_interface test_out conduit end
       set_interface_property test_out export_of pcie_internal_hip.test_out_export
       set_module_assignment "testbench.partner.map.test_out" "pcie_bfm_0.test_out"
        }

    set user_msi_enable [get_parameter_value p_user_msi_enable]
    if {$user_msi_enable == 1} {
      add_interface msi_interface conduit end                                                 
      set_interface_property msi_interface export_of pcie_internal_hip.msi_interface_export 
    }
    
    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
        set spans($i) "0 $i"
    }
    set INTENDED_DEVICE_FAMILY [get_parameter_value INTENDED_DEVICE_FAMILY]


     if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Stratix IV"] == 0} {
        set_parameter_value p_pcie_hip_type 0
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GZ"] == 0} {
        set_parameter_value p_pcie_hip_type 4
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "HardCopy IV"] == 0} {
        set_parameter_value p_pcie_hip_type 3
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GX"] == 0} {
        set_parameter_value p_pcie_hip_type 1
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] == 0} {
        set_parameter_value p_pcie_hip_type 2
     }


## new Qsys
     set bar_type_list [split [ get_parameter_value "BAR Type" ] ","]
     set value_at_index [ lindex $bar_type_list $i ]
     for { set i 0 } { $i < 6 } { incr i } {
     	set span 0
     	set value_at_index [ lindex $bar_type_list $i ]
     	set Bar64          [ expr  [ string compare -nocase $value_at_index "64 bit Prefetchable" ] == 0  ? 1 :0 ]
      if { [isBarUsed $i ] == 1 } {
      	 if { ($Bar64 == 1) } {  
      	 	 set bar_name_index "[expr $i +1]_$i"
      	   add_interface "bar${bar_name_index}" avalon master
           set_interface_property "bar${bar_name_index}" export_of "pcie_internal_hip.Rxm_BAR${i}"
        } else {
        	 set bar_name_index $i
      	   add_interface "bar${bar_name_index}" avalon master
           set_interface_property "bar${bar_name_index}" export_of "pcie_internal_hip.Rxm_BAR${i}"
              }
          set span [get_parameter_value "SLAVE_ADDRESS_MAP_${bar_name_index}"]
         send_message "info" " Rx Master BAR $bar_name_index mapped to $span -bit Avalon-MM address"
         set_parameter_value "bar${i}_size_mask" $span
                                            }
      
   }   
    
   
## END new Qsys




    set NUM_PREFETCH_MASTERS [get_parameter_value NUM_PREFETCH_MASTERS]
    set bar_name_index $i
    #Set Base Addresses
     set base_address 0

        set bar_name_index $i
        set vmiterator 0
        set fixed_address_mode  [get_parameter_value fixed_address_mode]

    set_bar_parameters
    set_system_setting_parameters

    #Set Parameters
    foreach param $ALL_PCIE_HIP_PARAMETERS {
        set_instance_parameter_value pcie_internal_hip $param [get_parameter_value $param]
    }

    ##Set values of the ALTGX and reset controller parameters
    set isGen2  [get_parameter_value gen2_lane_rate_mode]
    set subprotocol "Gen 1-x"
    if { [ string compare -nocase $isGen2 "true" ] == 0 } {
        set subprotocol "Gen 2-x"
    }
    set my_link_width [ get_parameter_value max_link_width ]
    set_parameter_value wiz_subprotocol $subprotocol$my_link_width

    foreach param $ALTGX_PARAMETERS {
        set_instance_parameter_value altgx_internal $param [get_parameter_value $param]
    }

    #set link_width to my_link_width
    set_parameter_value link_width $my_link_width

    foreach param $RESET_CONTROLLER_PARAMETERS {
        set_instance_parameter_value reset_controller_internal $param [get_parameter_value $param]
    }

    foreach param $PIPE_INTERFACE_PARAMETERS {
        set_instance_parameter_value pipe_interface_internal $param [get_parameter_value $param]
    }

    #update BARs
    update_bar_table
    set_a2p_address_map
    update_a2p_address_map_table

    #Export optional CRA interface;  Export optional RxmIrq
    set isCRA  [get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
    if { $isCRA == 1 } {
        add_interface cra avalon end
        set_interface_property cra export_of pcie_internal_hip.Cra

        add_interface cra_irq interrupt sender
        set_interface_property cra_irq export_of pcie_internal_hip.CraIrq

    }
    
     add_interface rxm_irq interrupt receiver
     set_interface_property rxm_irq export_of pcie_internal_hip.RxmIrq
    
   # Enable IRQ in Lite mode
    
      if { [ get_parameter_value CB_PCIE_MODE ] == 2} {
        add_interface rxm_irq interrupt receiver
        set_interface_property rxm_irq export_of pcie_internal_hip.RxmIrq
        } 

     # Check if completer only mode: CB_PCIE_MODE=true, if so then remove Tx Slave interface
     if { [ get_parameter_value CB_PCIE_MODE ] == 0} {
        set_interface_property txs ENABLED true
        } else {
        set_interface_property txs ENABLED false
    }



    #Get the buffer settings
        set p_pcie_target_performance_preset [ get_parameter_value p_pcie_target_performance_preset ]
        set max_payload_size [ get_parameter_value max_payload_size ]
        set max_link_width [ get_parameter_value max_link_width ]

    set_buffer_settings $p_pcie_target_performance_preset $max_payload_size  $max_link_width


    ##Avalon control
    enable_disable_controls



    for { set i 0 } { $i < $max_link_width } { incr i } {

     #Only if NOT Cyclone IV GX
    if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] != 0} {

        add_connection refclk_conduit.conduit_out_[expr $i + 2] altgx_internal.rx_cruclk_${i}
	if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
        	add_connection altgx_internal.tx_pipedeemph_${i} pcie_internal_hip.tx_deemph_${i}
        	add_connection altgx_internal.tx_pipemargin_${i} pcie_internal_hip.tx_margin_${i}
	}

    }
    add_connection pipe_interface_internal.rxdatak_hip_${i} pcie_internal_hip.rxdatak${i}_ext
    if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
    	add_connection altgx_internal.rx_elecidleinfersel_${i} pcie_internal_hip.eidle_infer_sel_${i}
    }
    add_connection pipe_interface_internal.rxdata_hip_${i} pcie_internal_hip.rxdata${i}_ext
    add_connection pipe_interface_internal.rxvalid_hip_${i} pcie_internal_hip.rxvalid${i}_ext


    add_connection pipe_interface_internal.rxelecidle_hip_${i} pcie_internal_hip.rxelecidle${i}_ext
    add_connection pipe_interface_internal.phystatus_hip_${i} pcie_internal_hip.phystatus${i}_ext
    add_connection pipe_interface_internal.rxstatus_hip_${i} pcie_internal_hip.rxstatus${i}_ext
    add_connection pcie_internal_hip.txdata${i}_ext pipe_interface_internal.txdata${i}_hip
    add_connection pcie_internal_hip.txdatak${i}_ext pipe_interface_internal.txdatak${i}_hip
    add_connection pcie_internal_hip.powerdown${i}_ext  pipe_interface_internal.powerdown${i}_hip
    add_connection pcie_internal_hip.rxpolarity${i}_ext  pipe_interface_internal.rxpolarity${i}_hip
    add_connection pcie_internal_hip.txcompl${i}_ext  pipe_interface_internal.txcompl${i}_hip
    add_connection pcie_internal_hip.txdetectrx${i}_ext  pipe_interface_internal.txdetectrx${i}_hip
    add_connection pcie_internal_hip.txelecidle${i}_ext  pipe_interface_internal.txelecidle${i}_hip

       }

    #Only if NOT Cyclone IV GX
    if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] != 0} {
          add_connection reset_controller_internal.rx_pll_locked altgx_internal.rx_pll_locked
          if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
               add_connection  altgx_internal.rx_signaldetect reset_controller_internal.rx_signaldetect
               add_connection altgx_internal.rateswitchbaseclock pipe_interface_internal.rateswitchbaseclock_pcs
               add_connection altgx_internal.rateswitch pipe_interface_internal.rateswitch_pcs
               add_connection altgx_internal.pll_powerdown pipe_interface_internal.pll_powerdown_pcs
          }
          set_parameter_value cyclone4 0
        } else {
                set_parameter_value cyclone4 1

        }
          add_interface rx_in conduit end
          set_interface_property rx_in export_of altgx_internal.rx_in_export
          set_interface_assignment rx_in "qsys.ui.export" "rx_serial_in"

          add_interface tx_out conduit end
          set_interface_property tx_out export_of altgx_internal.tx_out_export


         add_interface reconfig_togxb conduit end
         set_interface_property reconfig_togxb ENABLED true
         set_interface_property reconfig_togxb export_of altgx_internal.togxb_export
         set_interface_assignment reconfig_togxb "ui.blockdiagram.direction" "output"

         add_interface reconfig_gxbclk clock end
         set_interface_property reconfig_gxbclk export_of altgx_internal.reconfig_clk_export
         set_interface_assignment reconfig_gxbclk "ui.blockdiagram.direction" "output"

         add_interface reconfig_fromgxb_0 conduit end
         set_interface_property reconfig_fromgxb_0 export_of altgx_internal.fromgxb_export_0
         set_interface_assignment reconfig_fromgxb_0 "ui.blockdiagram.direction" "output"


     if { $max_link_width == 8 } {
         add_interface reconfig_fromgxb_1 conduit end
         set_interface_property reconfig_fromgxb_1 export_of altgx_internal.fromgxb_export_1
         set_interface_assignment reconfig_fromgxb_1 "ui.blockdiagram.direction" "output"
}

         add_interface fixedclk clock end
         set_interface_property fixedclk export_of altgx_internal.fixedclk_export
# This is to set parameter of the partner testbench module
 set_module_assignment "testbench.partner.pcie_bfm_0.parameter.LINK_WIDTH" [ get_parameter_value max_link_width ]
 set_module_assignment "testbench.partner.pcie_bfm_0.parameter.TEST_OUT_WIDTH" [ get_parameter_value p_pcie_test_out_width ]


}

proc access_span { list } {
    return [lindex $list 1]
}

proc access_vm { list } {
    return [lindex $list 0]
}

proc update_spans { vm span spans_list } {
    array set spans $spans_list

    global MAX_PREFETCH_MASTERS

    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {


        if { [ access_span $spans($i) ] <= $span }  {
            set temp $spans($i)
            set spans($i) "$vm $span"

            for { set j [expr $i + 1] } { $j < $MAX_PREFETCH_MASTERS } { incr j } {
                set temp2 $spans($j)
                set spans($j) $temp

                set temp $temp2
            }


            #send_message "error" "From update_spans [ array get spans ]"
            return [ array get spans ]
        }
    }




}
	
	
} else {  
	
# +----OLD RX---------
# | module PCI Express
# |
set_module_property DESCRIPTION "IP_Compiler for PCI Express"
set_module_property NAME altera_pcie_hard_ip
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/products/ip/iup/pci-express/m-alt-pcie8.html"
set_module_property "group" "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "IP_Compiler for PCI Express"
set_module_property HIDE_FROM_SOPC "true"

set_module_property instantiateInSystemModule "true"
set_module_property EDITABLE false
set_module_property INTERNAL false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL FALSE

# ************* Utility Functions ***************

proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i <= $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

     return $val
 }

proc pow2 { num } {
    if { $num == 0 } {
        return 1
    }

    return [ expr 1 << $num ]
}

# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

#Removing the tabs for now, will enable this if needed

#add_display_item "" "System Settings" GROUP "tab"
#add_display_item "System Settings" "PCIe System Parameters" GROUP

#add_display_item "" "PCI Registers" GROUP "tab"
#add_display_item "PCI Registers" "PCI Base Address Registers (Type 0 Configuration Space)" GROUP
#add_display_item "PCI Registers" "PCI Read-Only Registers" GROUP


#add_display_item "" "Capabilities" GROUP "tab"
#add_display_item "Capabilities" "Link Capabilities" GROUP
#add_display_item "Capabilities" "Error Reporting" GROUP


#add_display_item "" "Buffer setup" GROUP "tab"
#add_display_item "Buffer setup" "Buffer Configuration" GROUP

#add_display_item "" "Avalon" GROUP "tab"
#add_display_item "Avalon" "Parameters" GROUP
#add_display_item "Avalon" "Address Translation Table Size" GROUP
#add_display_item "Avalon" "Fixed Address Translation Table Contents" GROUP


#add_display_item "" "ALTGX Parameters" GROUP "tab"
#add_display_item "" "Reset Controller Parameters" GROUP "tab"

##This parameter indicates testing mode ###
add_parameter under_test integer 0
set_parameter_property under_test AFFECTS_ELABORATION true
set_parameter_property under_test VISIBLE false

# +AF
# new experimental parameter to control the component used to export barX
# interfaces.
add_parameter USE_PIPELINE_BRIDGE integer 1
set_parameter_property USE_PIPELINE_BRIDGE DISPLAY_NAME {Pipeline bar interfaces}
set_parameter_property USE_PIPELINE_BRIDGE DISPLAY_HINT boolean
set_parameter_property USE_PIPELINE_BRIDGE VISIBLE false

add_parameter PIPELINE_COMMAND integer 1
set_parameter_property PIPELINE_COMMAND DISPLAY_NAME {Pipeline bar interfaces - commands}
set_parameter_property PIPELINE_COMMAND DISPLAY_HINT boolean
set_parameter_property PIPELINE_COMMAND VISIBLE false

add_parameter PIPELINE_RESPONSE integer 1
set_parameter_property PIPELINE_RESPONSE DISPLAY_NAME {Pipeline bar interfaces - responses}
set_parameter_property PIPELINE_RESPONSE DISPLAY_HINT boolean
set_parameter_property PIPELINE_RESPONSE VISIBLE false

# -AF



add_pcie_hip_parameters

for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
    add_parameter "SLAVE_ADDRESS_MAP_$i" integer 0
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_type ADDRESS_WIDTH
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_arg "bar${i}"
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" AFFECTS_ELABORATION true
    set_parameter_property "SLAVE_ADDRESS_MAP_$i" VISIBLE false

    #PCIE HIP Derived Parameters
    set_parameter_property "CB_P2A_AVALON_ADDR_B${i}" DERIVED true
    set_parameter_property "bar${i}_size_mask" DERIVED true
    set_parameter_property "bar${i}_64bit_mem_space" DERIVED true
    set_parameter_property "bar${i}_prefetchable" DERIVED true
    set_parameter_property BAR DERIVED true
    set_parameter_property "BAR Size" DERIVED true
    set_parameter_property "BAR Size" DERIVED true
    set_parameter_property "Avalon Base Address" DERIVED true

}

 for { set i 0 } { $i < 16 } { incr i } {

    set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" DERIVED true
    set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" DERIVED true

}

set_parameter_property "Address Page" DERIVED true

### Adding parameters for the 64 bit BAR cases
add_parameter "SLAVE_ADDRESS_MAP_1_0" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" system_info_arg "bar1_0"
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_1_0" VISIBLE false

add_parameter "SLAVE_ADDRESS_MAP_3_2" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" system_info_arg "bar3_2"
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_3_2" VISIBLE false

add_parameter "SLAVE_ADDRESS_MAP_5_4" integer 0
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" system_info_type ADDRESS_WIDTH
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" system_info_arg "bar5_4"
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" AFFECTS_ELABORATION true
set_parameter_property "SLAVE_ADDRESS_MAP_5_4" VISIBLE false


 ##TODO seeting these derived on teh top level
 set_parameter_property vc0_rx_flow_ctrl_posted_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_posted_data DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_nonposted_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_nonposted_data DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_compl_header DERIVED true
 set_parameter_property vc0_rx_flow_ctrl_compl_data DERIVED true


#add_altera_pcie_internal_altgx_parameters "ALTGX Parameters"
add_altera_pcie_internal_altgx_parameters ""
set_parameter_property wiz_subprotocol DERIVED true

#add_altera_pcie_internal_reset_controller_parameters "Reset Controller Parameters"
add_altera_pcie_internal_reset_controller_parameters ""
add_altera_pcie_internal_pipe_interface_parameters "Pipe Interface Parameters"
set_parameter_property link_width DERIVED true
set_parameter_property cyclone4 DERIVED true
set_parameter_property p_pcie_hip_type DERIVED true

set_parameter_property core_clk_divider DERIVED true
set_parameter_property enable_ch0_pclk_out DERIVED true
set_parameter_property core_clk_source DERIVED true
set_parameter_property millisecond_cycle_count DERIVED true
set_parameter_property enable_gen2_core DERIVED true
set_parameter_property lane_mask DERIVED true
set_parameter_property single_rx_detect DERIVED true
set_parameter_property retry_buffer_last_active_address DERIVED true
set_parameter_property  gen2_lane_rate_mode DERIVED true


# ***********************************************

# ************* Static Instances ****************

add_instance "pcie_internal_hip" altera_pcie_internal_hard_ip
add_instance "altgx_internal" altera_pcie_internal_altgx
add_instance "reset_controller_internal" altera_pcie_internal_reset_controller
add_instance "pipe_interface_internal" altera_pcie_internal_pipe_interface

add_instance "avalon_clk" altera_clock_bridge
add_instance "cal_blk_clk" altera_clock_bridge
#add_instance "reference_clk" altera_clock_bridge
#set_instance_parameter_value reference_clk NUM_CLOCK_OUTPUTS 2

add_instance "test_in_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value test_in_conduit CONDUIT_WIDTH 40
set_instance_parameter_value test_in_conduit NUM_OUTPUTS 2
set_instance_parameter_value test_in_conduit CONDUIT_INPUT_ROLE test_in
set_instance_parameter_value test_in_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect"

add_instance "pcie_rstn_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value pcie_rstn_conduit CONDUIT_WIDTH 1
set_instance_parameter_value pcie_rstn_conduit NUM_OUTPUTS 3
set_instance_parameter_value pcie_rstn_conduit CONDUIT_INPUT_ROLE export
set_instance_parameter_value pcie_rstn_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect,interconect"


add_instance "refclk_conduit" altera_merlin_conduit_fanout
set_instance_parameter_value refclk_conduit CONDUIT_WIDTH 1
set_instance_parameter_value refclk_conduit NUM_OUTPUTS 10
set_instance_parameter_value refclk_conduit CONDUIT_INPUT_ROLE export
set_instance_parameter_value refclk_conduit CONDUIT_OUTPUT_ROLES "interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect,interconect"



add_instance "avalon_reset" altera_reset_bridge
set_instance_parameter_value avalon_reset SYNCHRONOUS_EDGES both


# ***********************************************

# ************* Static Interfaces ***************


# Avalon Clock Connection
add_connection pcie_internal_hip.pcie_core_clk avalon_clk.in_clk

# core clock export and input

#Avalon Reset connection
add_connection reset_controller_internal.reset_n_out avalon_reset.in_reset



# PCIe core clock/reset out

add_interface pcie_core_clk clock start
set_interface_property pcie_core_clk ENABLED true
set_interface_property pcie_core_clk export_of pcie_internal_hip.pcie_core_clk


add_interface pcie_core_reset reset start
set_interface_property pcie_core_reset export_of reset_controller_internal.reset_n_out
add_interface cal_blk_clk clock end
set_interface_property cal_blk_clk export_of cal_blk_clk.in_clk


# PCIE Internal HIP Exports
add_interface "txs" avalon slave
set_interface_property txs export_of pcie_internal_hip.Txs




# ALTGX Connections
add_connection  cal_blk_clk.out_clk altgx_internal.cal_blk_clk
#add_connection  pcie_internal_hip.pcie_core_clk altgx_internal.fixedclk
add_connection  pcie_internal_hip.pcie_core_clk pipe_interface_internal.core_clk_out
add_connection  pcie_internal_hip.pcie_core_clk reset_controller_internal.pld_clk
add_connection  pcie_internal_hip.pcie_core_clk pcie_internal_hip.pld_clk

# ***********************************************

# ************* Static Connections **************

#Avalon Reset Connections
add_connection avalon_reset.out_reset pcie_internal_hip.avalon_reset reset

#Avalon Clock Connections
add_connection avalon_clk.out_clk pcie_internal_hip.avalon_clk clock
add_connection avalon_clk.out_clk avalon_reset.clk



#ALTGX Internal Connections


add_connection  altgx_internal.rx_digitalreset reset_controller_internal.rx_digitalreset_serdes


add_connection altgx_internal.tx_ctrlenable pipe_interface_internal.txdatak_pcs

add_connection altgx_internal.tx_datain pipe_interface_internal.txdata_pcs


add_connection pipe_interface_internal.pclk_central_hip pcie_internal_hip.pclk_central
add_connection pipe_interface_internal.pclk_ch0_hip pcie_internal_hip.pclk_ch0

add_connection pipe_interface_internal.pll_fixed_clk_hip pcie_internal_hip.pll_fixed_clk

add_interface refclk conduit end
set_interface_property refclk export_of refclk_conduit.conduit_in
add_connection refclk_conduit.conduit_out_0 reset_controller_internal.refclk
add_connection refclk_conduit.conduit_out_1 altgx_internal.pll_inclk

# Reset Controller Connections


add_connection reset_controller_internal.l2_exit pcie_internal_hip.l2_exit
add_connection reset_controller_internal.hotrst_exit pcie_internal_hip.hotrst_exit
add_connection reset_controller_internal.dlup_exit pcie_internal_hip.dlup_exit
add_connection reset_controller_internal.ltssm pcie_internal_hip.dl_ltssm_int
add_connection reset_controller_internal.srst pcie_internal_hip.srst
add_connection reset_controller_internal.crst pcie_internal_hip.crst
add_connection reset_controller_internal.pll_locked pipe_interface_internal.rc_pll_locked

add_connection reset_controller_internal.rx_freqlocked altgx_internal.rx_freqlocked
add_connection reset_controller_internal.txdigitalreset altgx_internal.tx_digitalreset
add_connection reset_controller_internal.rxanalogreset altgx_internal.rx_analogreset






add_interface test_in conduit end
set_interface_property test_in export_of test_in_conduit.conduit_in
add_connection test_in_conduit.conduit_out_0 pcie_internal_hip.test_in
add_connection test_in_conduit.conduit_out_1 reset_controller_internal.test_in


add_interface pcie_rstn conduit end
set_interface_property pcie_rstn export_of pcie_rstn_conduit.conduit_in
add_connection pcie_rstn_conduit.conduit_out_0 pcie_internal_hip.npor
add_connection pcie_rstn_conduit.conduit_out_1 reset_controller_internal.pcie_rstn
add_connection pcie_rstn_conduit.conduit_out_2 pipe_interface_internal.pcie_rstn




add_interface clocks_sim conduit end
set_interface_property clocks_sim export_of reset_controller_internal.reset_controller_export




add_interface reconfig_busy conduit end
set_interface_property reconfig_busy export_of reset_controller_internal.reconfig_busy_export
set_interface_assignment reconfig_busy "ui.blockdiagram.direction" "output"


#pipe interface connections
add_interface pipe_ext conduit end
set_interface_property pipe_ext export_of pipe_interface_internal.pipe_interface_export


add_connection pipe_interface_internal.rc_areset pcie_internal_hip.rc_areset
add_connection altgx_internal.rx_dataout pipe_interface_internal.rxdata_pcs
add_connection altgx_internal.pipephydonestatus pipe_interface_internal.phystatus_pcs
add_connection altgx_internal.pipeelecidle pipe_interface_internal.rxelecidle_pcs
add_connection altgx_internal.pipedatavalid pipe_interface_internal.rxvalid_pcs
add_connection altgx_internal.pipestatus pipe_interface_internal.rxstatus_pcs
add_connection altgx_internal.rx_ctrldetect pipe_interface_internal.rxdatak_pcs

add_connection altgx_internal.gxb_powerdown pipe_interface_internal.gxb_powerdown_pcs
add_connection altgx_internal.hip_tx_clkout_0 pipe_interface_internal.hip_tx_clkout_pcs
add_connection reset_controller_internal.clk250_out pipe_interface_internal.clk250_out
add_connection reset_controller_internal.clk500_out pipe_interface_internal.clk500_out

add_connection pcie_internal_hip.rate_ext pipe_interface_internal.rate_hip

add_connection altgx_internal.pll_locked pipe_interface_internal.pll_locked_pcs

add_connection altgx_internal.powerdn pipe_interface_internal.powerdown_pcs

add_connection altgx_internal.pipe8b10binvpolarity pipe_interface_internal.rxpolarity_pcs


add_connection altgx_internal.tx_forcedispcompliance pipe_interface_internal.txcompl_pcs

add_connection altgx_internal.tx_detectrxloop pipe_interface_internal.txdetectrx_pcs

add_connection altgx_internal.tx_forceelecidle pipe_interface_internal.txelecidle_pcs

# For testbench purpose
set pcie_bfm_name    pcie_bfm_0
set pcie_bfm_class   altera_pcie_bfm

# This is to tell the testbench generator that "this.interface" maps to "my_partner_name.interface"
set_module_assignment "testbench.partner.map.clocks_sim"          "$pcie_bfm_name.clocks_sim"
#set_module_assignment "testbench.partner.map.gxb_reconfig"        "$pcie_bfm_name.gxb_reconfig"
set_module_assignment "testbench.partner.map.pcie_rstn"           "$pcie_bfm_name.pcie_rstn"
set_module_assignment "testbench.partner.map.pipe_ext"            "$pcie_bfm_name.pipe_ext"
set_module_assignment "testbench.partner.map.refclk"              "$pcie_bfm_name.refclk"
set_module_assignment "testbench.partner.map.test_in"             "$pcie_bfm_name.test_in"

set_module_assignment "testbench.partner.map.rx_in"             "$pcie_bfm_name.rx_in"
set_module_assignment "testbench.partner.map.tx_out"            "$pcie_bfm_name.tx_out"


# This is to tell the testbench generator "my_partner_name" is a "my_partner_type"
set_module_assignment "testbench.partner.$pcie_bfm_name.class"    "$pcie_bfm_class"
# Setting version is optional
 set_module_assignment "testbench.partner.$pcie_bfm_name.version"  "11.0"


# ***********************************************

proc compose { } {
    global MAX_PREFETCH_MASTERS
    global ALL_PCIE_HIP_PARAMETERS
    global ALTGX_PARAMETERS
    global RESET_CONTROLLER_PARAMETERS
    global PIPE_INTERFACE_PARAMETERS

     set test_width [get_parameter_value p_pcie_test_out_width]
     set use_pipeline_bridge [get_parameter_value USE_PIPELINE_BRIDGE]

     if { $test_width == "64bits" || $test_width == "9bits" } {
       add_interface test_out conduit end
       set_interface_property test_out export_of pcie_internal_hip.test_out_export
       set_module_assignment "testbench.partner.map.test_out" "pcie_bfm_0.test_out"
        }

    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
        set spans($i) "0 $i"
    }
    set INTENDED_DEVICE_FAMILY [get_parameter_value INTENDED_DEVICE_FAMILY]


     if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Stratix IV"] == 0} {
        set_parameter_value p_pcie_hip_type 0
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GZ"] == 0} {
        set_parameter_value p_pcie_hip_type 4
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "HardCopy IV"] == 0} {
        set_parameter_value p_pcie_hip_type 3
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Arria II GX"] == 0} {
        set_parameter_value p_pcie_hip_type 1
      } elseif {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] == 0} {
        set_parameter_value p_pcie_hip_type 2
     }

    set NUM_PREFETCH_MASTERS [get_parameter_value NUM_PREFETCH_MASTERS]
    set bar_name_index $i
    #Set Base Addresses
     set base_address 0

        for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
            if { ( $i==1 ||$i==3 || $i ==5) && ([is64bitBar [expr $i-1] ] == 1) } {
                #send_message "info" "inside  $i==1 ||$i==3 || $i ==5"

            } else {
                set bar_name_index $i
                if { ($i==0 || $i==2 || $i ==4) && ([is64bitBar $i] == 1) } {
                    set bar_name_index "[expr $i +1]_$i"
                    #send_message "info" "INSIDE........ bar_name_index  is $bar_name_index "

                }

                if { [isBarUsed $i ] == 1 } {

                 # +AF
                    if { $use_pipeline_bridge } {
                        # Use a pipeline bridge instead of a master translator
                        add_instance "bar${i}_translator" altera_avalon_mm_bridge

                        # Set both command and response pipeline options.  It
                        # might be interesting to export these assignments as
                        # PCIe parameters, so the system designer can choose
                        # the pipelining.
                        set pipeline_command [get_parameter_value PIPELINE_COMMAND ]
                        set_instance_parameter "bar${i}_translator" PIPELINE_COMMAND $pipeline_command
                        set pipeline_response [get_parameter_value PIPELINE_RESPONSE ]
                        set_instance_parameter "bar${i}_translator" PIPELINE_RESPONSE $pipeline_response

                        #CB_PCIE_MODE 2 is "Avalon MM" lite mode
                        if { [ get_parameter_value CB_PCIE_MODE ] == 2} {
                            set_instance_parameter "bar${i}_translator" "DATA_WIDTH" 32
                            set_instance_parameter "bar${i}_translator" "SYMBOL_WIDTH" 8
                            set_instance_parameter "bar${i}_translator" "MAX_BURST_SIZE" 1
                            set_instance_parameter "bar${i}_translator" "MAX_PENDING_RESPONSES" 2
                        } else {
                            set_instance_parameter "bar${i}_translator" "DATA_WIDTH" 64
                            set_instance_parameter "bar${i}_translator" "SYMBOL_WIDTH" 8
                            set_instance_parameter "bar${i}_translator" "MAX_BURST_SIZE" 64
                            set_instance_parameter "bar${i}_translator" "MAX_PENDING_RESPONSES" 2
                        }

                        set_instance_parameter "bar${i}_translator" "ADDRESS_WIDTH" 28

                        set_instance_parameter "bar${i}_translator" "ADDRESS_UNITS" "SYMBOLS"

                        add_interface "bar${bar_name_index}" avalon master
                        set_interface_property "bar${bar_name_index}" export_of "bar${i}_translator.m0"

                        add_connection "pcie_internal_hip.Rxm" "bar${i}_translator.s0" avalon
                        set span [get_parameter_value "SLAVE_ADDRESS_MAP_${bar_name_index}"]

                        if { $span != 0 } {
                            set_instance_parameter "bar${i}_translator" ADDRESS_WIDTH $span
                            if { $span < 10 } {
                                set_instance_parameter "bar${i}_translator" "MAX_BURST_SIZE" [expr [pow2 $span]/8]
                            }
                        }

                        add_connection avalon_clk.out_clk "bar${i}_translator.clk"
                        add_connection avalon_reset.out_reset "bar${i}_translator.reset"

                        array set spans [ update_spans $i $span [array get spans] ]

                        #send_message info "The bar_name_index is $bar_name_index : i is $i AND  span is    $span"


                    # -AF
                    } else {


                    add_instance "bar${i}_translator" altera_merlin_master_translator

                    #CB_PCIE_MODE 2 is "Avalon MM" lite mode
                    if { [ get_parameter_value CB_PCIE_MODE ] == 2} {
                        set_instance_parameter "bar${i}_translator" "AV_DATA_W" 32
                        set_instance_parameter "bar${i}_translator" "AV_BYTEENABLE_W" 4
                        set_instance_parameter "bar${i}_translator" "AV_SYMBOLS_PER_WORD" 4
                        set_instance_parameter "bar${i}_translator" "AV_BURSTCOUNT_W" 3
                        set_instance_parameter "bar${i}_translator" "AV_MAX_PENDING_READ_TRANSACTIONS" 2
                        set_instance_parameter "bar${i}_translator" "UAV_BURSTCOUNT_W" 3
                    } else {
                    set_instance_parameter "bar${i}_translator" "AV_DATA_W" 64
                    set_instance_parameter "bar${i}_translator" "AV_BYTEENABLE_W" 8
                    set_instance_parameter "bar${i}_translator" "AV_SYMBOLS_PER_WORD" 8
                    set_instance_parameter "bar${i}_translator" "AV_BURSTCOUNT_W" 10
                    set_instance_parameter "bar${i}_translator" "AV_MAX_PENDING_READ_TRANSACTIONS" 2
                    set_instance_parameter "bar${i}_translator" "UAV_BURSTCOUNT_W" 10
                    }

                    set_instance_parameter "bar${i}_translator" "AV_ADDRESS_W" 28
                    set_instance_parameter "bar${i}_translator" "UAV_ADDRESS_W" 28

                    set_instance_parameter "bar${i}_translator" "AV_ADDRESS_SYMBOLS" 1
                    set_instance_parameter "bar${i}_translator" "AV_BURSTCOUNT_SYMBOLS" 1

                    add_interface "bar${bar_name_index}" avalon master
                    set_interface_property "bar${bar_name_index}" export_of "bar${i}_translator.avalon_universal_master_0"

                    add_connection "pcie_internal_hip.Rxm" "bar${i}_translator.avalon_anti_master_0" avalon
                    set span [get_parameter_value "SLAVE_ADDRESS_MAP_${bar_name_index}"]

                    if { $span != 0 } {
                        set_instance_parameter "bar${i}_translator" AV_ADDRESS_W $span
                        set_instance_parameter "bar${i}_translator" UAV_ADDRESS_W $span
                        if { $span < 10 } {
                            set_instance_parameter "bar${i}_translator" "AV_BURSTCOUNT_W" [expr $span + 1]
                            set_instance_parameter "bar${i}_translator" "UAV_BURSTCOUNT_W" [expr $span + 1]
                        }
                    }

                    add_connection avalon_clk.out_clk "bar${i}_translator.clk"
                    add_connection avalon_reset.out_reset "bar${i}_translator.reset"

                    array set spans [ update_spans $i $span [array get spans] ]

                    #send_message info "The bar_name_index is $bar_name_index : i is $i AND  span is    $span"

                }
            }
          }

        }

        set vmiterator 0
        set fixed_address_mode  [get_parameter_value fixed_address_mode]
        for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {

            if { ( $i==1 ||$i==3 || $i ==5) && ([is64bitBar [expr $i-1] ] == 1) } {
                #These bars cannot be used

            } else {

                if { [isBarUsed $i ] == 1 } {

                    set vm [ access_vm $spans($vmiterator) ]
                    #send_message "info" "vmiterator is $vmiterator"
                    #send_message "info" "vm is $vm"

                    ##if FIXED_ADDRESS_MODE then we use the CB_P2A_FIXED_AVALON_ADDR_B${i}
                    if { [ string compare -nocase $fixed_address_mode "1" ] == 0 } {
                        set base_address [get_parameter_value CB_P2A_FIXED_AVALON_ADDR_B${vm}]
                   }

                    set bar_name_index $vm
                    if { ($vm==0 || $vm==2 || $vm ==4) && ([is64bitBar $vm] == 1) } {
                        set bar_name_index "[expr $vm +1]_$vm"
                        #send_message "info" "INSIDE........ bar_name_index  is $bar_name_index "

                    }

                    send_message info [format "bar $bar_name_index: PCI BAR Size: %s , Avalon Base Address Start: 0x%#08x, Avalon Base Address End: 0x%#08x"  [bitstoSizestring [access_span $spans($vmiterator)]] $base_address [expr $base_address + [pow2 [access_span $spans($vmiterator)]] -1 ] ]

                    if { $use_pipeline_bridge } {
                     # +AF
                     set_connection_parameter "pcie_internal_hip.Rxm/bar${vm}_translator.s0" baseaddress $base_address
                     # -AF
                     } else {
                    set_connection_parameter "pcie_internal_hip.Rxm/bar${vm}_translator.avalon_anti_master_0" baseaddress $base_address
                            }

                   set_parameter_value "CB_P2A_AVALON_ADDR_B${vm}" $base_address
                   #send_message "info" "CB_P2A_AVALON_ADDR_B${vm} is [get_parameter_value CB_P2A_AVALON_ADDR_B${vm}]"



                   set_parameter_value "bar${vm}_size_mask" [access_span $spans($vmiterator)]
                   #send_message "info" "bar${vm}_size_mask is [get_parameter_value bar${vm}_size_mask]"


                   if { [ string compare -nocase $fixed_address_mode "0" ] == 0 } {
                   set base_address [expr $base_address + [pow2 [access_span $spans($vmiterator)] ] ]
                   }
                   set vmiterator [expr $vmiterator + 1]

                }

            }

        }


    set_bar_parameters
    set_system_setting_parameters

    #Set Parameters
    foreach param $ALL_PCIE_HIP_PARAMETERS {
        set_instance_parameter_value pcie_internal_hip $param [get_parameter_value $param]
    }

    ##Set values of the ALTGX and reset controller parameters
    set isGen2  [get_parameter_value gen2_lane_rate_mode]
    set subprotocol "Gen 1-x"
    if { [ string compare -nocase $isGen2 "true" ] == 0 } {
        set subprotocol "Gen 2-x"
    }
    set my_link_width [ get_parameter_value max_link_width ]
    set_parameter_value wiz_subprotocol $subprotocol$my_link_width

    foreach param $ALTGX_PARAMETERS {
        set_instance_parameter_value altgx_internal $param [get_parameter_value $param]
    }

    #set link_width to my_link_width
    set_parameter_value link_width $my_link_width

    foreach param $RESET_CONTROLLER_PARAMETERS {
        set_instance_parameter_value reset_controller_internal $param [get_parameter_value $param]
    }

    foreach param $PIPE_INTERFACE_PARAMETERS {
        set_instance_parameter_value pipe_interface_internal $param [get_parameter_value $param]
    }

    #update BARs
    update_bar_table
    set_a2p_address_map
    update_a2p_address_map_table

    #Export optional CRA interface;  Export optional RxmIrq
    set isCRA  [get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
    if { $isCRA == 1 } {
        add_interface cra avalon end
        set_interface_property cra export_of pcie_internal_hip.Cra

        add_interface cra_irq interrupt sender
        set_interface_property cra_irq export_of pcie_internal_hip.CraIrq

    }
    
      add_interface rxm_irq interrupt receiver
        set_interface_property rxm_irq export_of pcie_internal_hip.RxmIrq
    
    

     # Check if completer only mode: CB_PCIE_MODE=true, if so then remove Tx Slave interface
     if { [ get_parameter_value CB_PCIE_MODE ] == 0} {
        set_interface_property txs ENABLED true
        } else {
        set_interface_property txs ENABLED false
    }



    #Get the buffer settings
        set p_pcie_target_performance_preset [ get_parameter_value p_pcie_target_performance_preset ]
        set max_payload_size [ get_parameter_value max_payload_size ]
        set max_link_width [ get_parameter_value max_link_width ]

    set_buffer_settings $p_pcie_target_performance_preset $max_payload_size  $max_link_width


    ##Avalon control
    enable_disable_controls



    for { set i 0 } { $i < $max_link_width } { incr i } {

     #Only if NOT Cyclone IV GX
    if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] != 0} {

        add_connection refclk_conduit.conduit_out_[expr $i + 2] altgx_internal.rx_cruclk_${i}
	if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
        	add_connection altgx_internal.tx_pipedeemph_${i} pcie_internal_hip.tx_deemph_${i}
        	add_connection altgx_internal.tx_pipemargin_${i} pcie_internal_hip.tx_margin_${i}
	}

    }
    add_connection pipe_interface_internal.rxdatak_hip_${i} pcie_internal_hip.rxdatak${i}_ext
    if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
    	add_connection altgx_internal.rx_elecidleinfersel_${i} pcie_internal_hip.eidle_infer_sel_${i}
    }
    add_connection pipe_interface_internal.rxdata_hip_${i} pcie_internal_hip.rxdata${i}_ext
    add_connection pipe_interface_internal.rxvalid_hip_${i} pcie_internal_hip.rxvalid${i}_ext


    add_connection pipe_interface_internal.rxelecidle_hip_${i} pcie_internal_hip.rxelecidle${i}_ext
    add_connection pipe_interface_internal.phystatus_hip_${i} pcie_internal_hip.phystatus${i}_ext
    add_connection pipe_interface_internal.rxstatus_hip_${i} pcie_internal_hip.rxstatus${i}_ext
    add_connection pcie_internal_hip.txdata${i}_ext pipe_interface_internal.txdata${i}_hip
    add_connection pcie_internal_hip.txdatak${i}_ext pipe_interface_internal.txdatak${i}_hip
    add_connection pcie_internal_hip.powerdown${i}_ext  pipe_interface_internal.powerdown${i}_hip
    add_connection pcie_internal_hip.rxpolarity${i}_ext  pipe_interface_internal.rxpolarity${i}_hip
    add_connection pcie_internal_hip.txcompl${i}_ext  pipe_interface_internal.txcompl${i}_hip
    add_connection pcie_internal_hip.txdetectrx${i}_ext  pipe_interface_internal.txdetectrx${i}_hip
    add_connection pcie_internal_hip.txelecidle${i}_ext  pipe_interface_internal.txelecidle${i}_hip

       }

    #Only if NOT Cyclone IV GX
    if {[string compare -nocase $INTENDED_DEVICE_FAMILY "Cyclone IV GX"] != 0} {
          add_connection reset_controller_internal.rx_pll_locked altgx_internal.rx_pll_locked
          if { !(([string compare -nocase $isGen2 "true"] == 0) && ([string compare -nocase $max_link_width "2"] == 0)) } {
               add_connection  altgx_internal.rx_signaldetect reset_controller_internal.rx_signaldetect
               add_connection altgx_internal.rateswitchbaseclock pipe_interface_internal.rateswitchbaseclock_pcs
               add_connection altgx_internal.rateswitch pipe_interface_internal.rateswitch_pcs
               add_connection altgx_internal.pll_powerdown pipe_interface_internal.pll_powerdown_pcs
          }
          set_parameter_value cyclone4 0
        } else {
                set_parameter_value cyclone4 1

        }
          add_interface rx_in conduit end
          set_interface_property rx_in export_of altgx_internal.rx_in_export
          set_interface_assignment rx_in "qsys.ui.export" "rx_serial_in"

          add_interface tx_out conduit end
          set_interface_property tx_out export_of altgx_internal.tx_out_export


         add_interface reconfig_togxb conduit end
         set_interface_property reconfig_togxb ENABLED true
         set_interface_property reconfig_togxb export_of altgx_internal.togxb_export
         set_interface_assignment reconfig_togxb "ui.blockdiagram.direction" "output"

         add_interface reconfig_gxbclk clock end
         set_interface_property reconfig_gxbclk export_of altgx_internal.reconfig_clk_export
         set_interface_assignment reconfig_gxbclk "ui.blockdiagram.direction" "output"

         add_interface reconfig_fromgxb_0 conduit end
         set_interface_property reconfig_fromgxb_0 export_of altgx_internal.fromgxb_export_0
         set_interface_assignment reconfig_fromgxb_0 "ui.blockdiagram.direction" "output"


     if { $max_link_width == 8 } {
         add_interface reconfig_fromgxb_1 conduit end
         set_interface_property reconfig_fromgxb_1 export_of altgx_internal.fromgxb_export_1
         set_interface_assignment reconfig_fromgxb_1 "ui.blockdiagram.direction" "output"
}

         add_interface fixedclk clock end
         set_interface_property fixedclk export_of altgx_internal.fixedclk_export
# This is to set parameter of the partner testbench module
 set_module_assignment "testbench.partner.pcie_bfm_0.parameter.LINK_WIDTH" [ get_parameter_value max_link_width ]
 set_module_assignment "testbench.partner.pcie_bfm_0.parameter.TEST_OUT_WIDTH" [ get_parameter_value p_pcie_test_out_width ]


}

proc access_span { list } {
    return [lindex $list 1]
}

proc access_vm { list } {
    return [lindex $list 0]
}

proc update_spans { vm span spans_list } {
    array set spans $spans_list

    global MAX_PREFETCH_MASTERS

    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {


        if { [ access_span $spans($i) ] <= $span }  {
            set temp $spans($i)
            set spans($i) "$vm $span"

            for { set j [expr $i + 1] } { $j < $MAX_PREFETCH_MASTERS } { incr j } {
                set temp2 $spans($j)
                set spans($j) $temp

                set temp $temp2
            }


            #send_message "error" "From update_spans [ array get spans ]"
            return [ array get spans ]
        }
    }


}


}