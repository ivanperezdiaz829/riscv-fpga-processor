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
# | altera_pcie_internal_altgx
# |
# | $Header: //acds/rel/13.1/ip/altera_pcie/altera_pcie_avmm/altera_pcie_internal_altgx_hw.tcl#1 $
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
# | module altgx
# |
set_module_property NAME altera_pcie_internal_altgx
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/PCI"
set_module_property DISPLAY_NAME "altera_pcie_internal_altgx"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
# Declare the validation callback.
set_module_property VALIDATION_CALLBACK my_validation_callback
set_module_property ELABORATION_CALLBACK my_elaboration_callback
set_module_property GENERATION_CALLBACK my_generation_callback
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property SIMULATION_MODEL_IN_VERILOG true
# |
# +-----------------------------------



# +-----------------------------------
# | files
# |

# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |

add_display_item "" "General Settings" GROUP "tab"
add_altera_pcie_internal_altgx_parameters  "General Settings"

# The validation callback
proc my_validation_callback {} {

        set family [get_parameter_value deviceFamily]

        send_message info  "Family: $family"

    if { [string equal [get_parameter_value deviceFamily] "Arria II GZ"] == 1  || [string equal [get_parameter_value deviceFamily] "Stratix IV"] == 1 ||[string equal [get_parameter_value deviceFamily] "Arria II GX"] == 1 || [string equal [get_parameter_value deviceFamily] "HardCopy IV"] == 1 } {

        set mdata(module) alt4gxb
    } elseif { [string equal [get_parameter_value deviceFamily] "Stingray"] == 1 ||  [string equal [get_parameter_value deviceFamily] "Cyclone IV GX"] == 1 } {
        set mdata(module) alt_c3gxb
    } else  {
    	      send_message error  "Selected device family: $family is not supported"
    	}
    


        if {![string equal [get_parameter_value deviceFamily] "Stratix IV"] && ![string equal [get_parameter_value deviceFamily] "HardCopy IV"]  && [string equal [string range [get_parameter_value wiz_subprotocol] 0 3] "Gen2" ] } {
        send_message error  "Gen2 implementations require Stratix IV or HardCopy IV"

        }

        set mdata(INTENDED_DEVICE_FAMILY) [get_parameter_value deviceFamily]

        foreach param [get_parameters] {
                if (![string match [string range $param 0 4] "port_"]) {
                        set mdata([string toupper $param]) [get_parameter_value $param]
                }
        }

        # GUI params (needed for validation)
        set mdata(WIZ_DATA_RATE) 2000
        set mdata(WIZ_BASE_DATA_RATE) 2000
        set mdata(WIZ_ENABLE_EQUALIZER_CTRL) 0
        set mdata(WIZ_EQUALIZER_CTRL_SETTING) 0
#       set mdata(WIZ_FORCE_DEFAULT_SETTINGS) 0
        set mdata(WIZ_INCLK_FREQ) 250
        set mdata(RECONFIG_INPUT_CLOCK_FREQUENCY) "50 MHz"
        set mdata(WIZ_PROTOCOL) Basic
#       set mdata(Wiz_Subprotocol) None
        set mdata(WIZ_DPRIO_PROTOCOL) Basic
        set mdata(WIZ_PLL1_PROTOCOL) Basic
        set mdata(WIZ_PLL2_PROTOCOL) Basic
        set mdata(WIZ_PLL3_PROTOCOL) Basic
        set mdata(Wiz_PLL1_Subprotocol) None
        set mdata(Wiz_PLL2_Subprotocol) None
        set mdata(Wiz_PLL3_Subprotocol) None
        set mdata(Wiz_DPRIO_Subprotocol) None
        set mdata(WIZ_PLL1_DATA_RATE) "2500"
        set mdata(WIZ_PLL2_DATA_RATE) "2500"
        set mdata(WIZ_PLL3_DATA_RATE) "2500"
        set mdata(RECONFIG_INPUT_CLOCK_FREQUENCY) "50 MHz"
        set mdata(WIZ_DPRIO_DATA_RATE) "1000"
        set mdata(TX_PLL1_BANDWIDTH_TYPE) "auto"
        set mdata(TX_PLL2_BANDWIDTH_TYPE) "auto"
        set mdata(TX_PLL3_BANDWIDTH_TYPE) "auto"
        set mdata(TX_RECONFIG_PLL_BANDWIDTH_TYPE) auto
        set mdata(TX_PLL1_INPUT_CLOCK_FREQUENCY) "100 MHz"
        set mdata(TX_PLL2_INPUT_CLOCK_FREQUENCY) "100 MHz"
        set mdata(TX_PLL3_INPUT_CLOCK_FREQUENCY) "100 MHz"
        set mdata(TX_PLL1_BASE_DATA_RATE) "2500"
        set mdata(TX_PLL2_BASE_DATA_RATE) "2500"
        set mdata(TX_PLL3_BASE_DATA_RATE) "2500"

        set result [array get mdata]
        set validation_result "valid"
#       set validation_result [validate $result]
        if { [string equal -nocase -length 5 $validation_result "valid"] != 1 } {
                send_message error $validation_result
        }

    }
proc my_elaboration_callback {} {

    set family [get_parameter_value deviceFamily]
    set subprotocol [get_parameter_value wiz_subprotocol]

    if { [string equal $subprotocol "Gen 1-x1"] || [string equal $subprotocol "Gen 2-x1"]  } {
        set lanes 1
    } elseif { [string equal $subprotocol "Gen 1-x2"] } {
        set lanes 2
    } elseif { [string equal $subprotocol "Gen 1-x4"] || [string equal $subprotocol "Gen 2-x4"]    } {
        set lanes 4
    } elseif { [string equal $subprotocol "Gen 1-x8"] || [string equal $subprotocol "Gen 2-x8"] } {
        set lanes 8
    } else {
        send_message error  "Unsupported Subprotocol: $subprotocol"
        return 1
    }

    send_message info  "Lanes: $lanes"

    add_interface cal_blk_clk clock end
    add_interface_port cal_blk_clk cal_blk_clk clk Input 1

   
   

    add_interface gxb_powerdown conduit end
    add_interface_port gxb_powerdown gxb_powerdown interconect Input 1

    add_interface pipe8b10binvpolarity conduit end
    add_interface_port pipe8b10binvpolarity pipe8b10binvpolarity interconect Input $lanes

    add_interface pll_inclk conduit end
    add_interface_port pll_inclk pll_inclk interconect Input 1


    add_interface powerdn conduit end
    add_interface_port powerdn powerdn interconect Input [expr 2 * $lanes]

    add_interface rx_analogreset conduit end
    add_interface_port rx_analogreset rx_analogreset interconect Input 1
    

  ## Exported collection of input
  
     add_interface fixedclk_export clock end                 
     add_interface_port fixedclk_export fixedclk clk Input 1 
    
    add_interface togxb_export conduit end
    add_interface_port togxb_export reconfig_togxb data Input 4


    add_interface fromgxb_export_0 conduit end

    add_interface reconfig_clk_export clock end
    add_interface_port reconfig_clk_export reconfig_clk clk Input 1


if { [string equal $family {Stingray}] == 0 &&  [string equal $family {Cyclone IV GX}] == 0} {  # stratix IV
       if { $lanes == 8 } {
            add_interface fromgxb_export_1 conduit end
            add_interface_port fromgxb_export_0 fromgxb_export_0 data Output 17
            set_port_property fromgxb_export_0 FRAGMENT_LIST "reconfig_fromgxb(16:0)"

            add_interface_port fromgxb_export_1 fromgxb_export_1 data Output 17
            set_port_property fromgxb_export_1 FRAGMENT_LIST "reconfig_fromgxb(33:17)"
    }  else {
           add_interface_port fromgxb_export_0 reconfig_fromgxb data Output 17
    }
      } else {
         add_interface_port fromgxb_export_0 reconfig_fromgxb data Output 5
     }

    add_interface rx_dataout conduit end
    add_interface_port rx_dataout rx_dataout interconect Output [expr 8 * $lanes]
    add_interface rx_digitalreset conduit end
    add_interface_port rx_digitalreset rx_digitalreset interconect Input 1

    for { set i 0 } { $i < $lanes } { incr i } {
        add_interface rx_elecidleinfersel_${i} conduit end
        add_interface_port rx_elecidleinfersel_${i} rx_elecidleinfersel_${i} interconect Input 3
        set_port_property rx_elecidleinfersel_${i} FRAGMENT_LIST "rx_elecidleinfersel([expr 3 * $i + 2]:[expr 3 * $i])"
    }


    add_interface tx_ctrlenable conduit end
    add_interface_port tx_ctrlenable tx_ctrlenable interconect Input $lanes

   add_interface tx_datain conduit end
   add_interface_port tx_datain tx_datain interconect Input [expr 8 * $lanes]

    add_interface tx_detectrxloop conduit end
    add_interface_port tx_detectrxloop tx_detectrxloop interconect Input $lanes

    add_interface tx_forcedispcompliance conduit end
    add_interface_port tx_forcedispcompliance tx_forcedispcompliance interconect Input $lanes

    add_interface tx_forceelecidle conduit end
    add_interface_port tx_forceelecidle tx_forceelecidle interconect Input $lanes

    if { $lanes != 1 } {
        add_interface coreclkout conduit end
        add_interface_port coreclkout coreclkout interconect Output 1
        set_port_property coreclkout TERMINATION true
    }

    add_interface hip_tx_clkout_0 conduit end
    add_interface_port hip_tx_clkout_0 hip_tx_clkout_0 interconect output 1
    set_port_property hip_tx_clkout_0 FRAGMENT_LIST {hip_tx_clkout(0)}


     add_interface pipedatavalid  conduit end
     add_interface_port pipedatavalid pipedatavalid interconect Output $lanes

    add_interface pipephydonestatus conduit end
    add_interface_port pipephydonestatus pipephydonestatus interconect Output $lanes
    add_interface pipeelecidle conduit end
    add_interface_port pipeelecidle pipeelecidle interconect Output $lanes
    add_interface pipestatus  conduit end
    add_interface_port pipestatus pipestatus interconect Output [expr 3 * $lanes]
    add_interface pll_locked conduit end
    add_interface_port pll_locked pll_locked interconect Output 1
     add_interface rx_ctrldetect conduit end
     add_interface_port rx_ctrldetect rx_ctrldetect interconect Output $lanes
    add_interface rx_freqlocked  conduit end
    add_interface_port rx_freqlocked rx_freqlocked interconect Output $lanes
    add_interface rx_patterndetect conduit end
    add_interface_port rx_patterndetect rx_patterndetect interconect Output $lanes
     set_port_property rx_patterndetect TERMINATION true
    add_interface rx_syncstatus  conduit end
    add_interface_port rx_syncstatus rx_syncstatus interconect Output $lanes
    set_port_property rx_syncstatus TERMINATION true
    add_interface tx_digitalreset conduit end
    add_interface_port tx_digitalreset tx_digitalreset interconect Input 1

    if { [string equal $family {Stingray}] == 0 &&  [string equal $family {Cyclone IV GX}] == 0} {  # stratix IV

        add_interface rateswitch conduit end
        add_interface_port rateswitch rateswitch interconect Input 1
        
         add_interface rx_pll_locked  conduit end                                  
         add_interface_port rx_pll_locked rx_pll_locked interconect Output $lanes  
        
        add_interface rateswitchbaseclock  conduit end
        if { $lanes == 8 } {
            add_interface_port rateswitchbaseclock rateswitchbaseclock interconect Output  2
        } else {
            add_interface_port rateswitchbaseclock rateswitchbaseclock interconect Output  1
        }


for { set i 0 } { $i < $lanes } { incr i } {

      add_interface rx_cruclk_${i} conduit end
      add_interface_port rx_cruclk_${i} rx_cruclk_${i} interconect Input 1
      set_port_property rx_cruclk_${i} FRAGMENT_LIST "rx_cruclk(${i})"
}

    for { set i 0 } { $i < $lanes } { incr i } {
        add_interface tx_pipedeemph_${i} conduit end
        add_interface_port tx_pipedeemph_${i} tx_pipedeemph_${i} interconect Input 1
        set_port_property tx_pipedeemph_${i} FRAGMENT_LIST "tx_pipedeemph(${i})"
    }


    for { set i 0 } { $i < $lanes } { incr i } {
        add_interface tx_pipemargin_${i} conduit end
        add_interface_port tx_pipemargin_${i} tx_pipemargin_${i} interconect Input 3
        set_port_property tx_pipemargin_${i} FRAGMENT_LIST "tx_pipemargin([expr 3 * $i + 2]:[expr 3 * $i])"
    }

        add_interface pll_powerdown conduit end
        add_interface_port pll_powerdown pll_powerdown interconect Input 1

       
       

        add_interface rx_signaldetect conduit end
        add_interface_port rx_signaldetect rx_signaldetect interconect Output $lanes
    }

     
     add_interface rx_in_export conduit end
     add_interface tx_out_export conduit end
  for { set i 0 } { $i < $lanes } { incr i } {

      add_interface_port rx_in_export rx_datain_${i} rx_datain_${i} Input 1
      set_port_property rx_datain_${i} FRAGMENT_LIST "rx_datain(${i})"


      add_interface_port tx_out_export tx_dataout_${i} tx_dataout_${i} Output 1
      set_port_property tx_dataout_${i} FRAGMENT_LIST "tx_dataout(${i})"
     }

}

# The validation callback
proc my_generation_callback {} {

        set cbx_params ""
        set used_ports ""

        global env
        set qdir $env(QUARTUS_ROOTDIR)

        set moduledir [get_module_property MODULE_DIRECTORY]
        set outdir [get_generation_property OUTPUT_DIRECTORY]
        set outputname [get_generation_property OUTPUT_NAME]
        set output_file "${outputname}.v"
        set params_file "${outdir}/params.txt"
        set family [get_parameter_value deviceFamily]
        set subprotocol [get_parameter_value wiz_subprotocol]

        send_message info  "Family: $family"
        send_message info  "Subprotocol: $subprotocol"

        if { [string equal $family {Stratix IV}] == 1 || [string equal $family {Arria II GZ}] == 1 || [string equal $family {HardCopy IV}] == 1} {
            set modulename "alt4gxb"
            set device_suffix "4sgx"
            set family_params "LOCKDOWN_EXCL=PCIE IP_MODE=PCIE_HIP_8 gxb_analog_power=AUTO tx_analog_power=AUTO elec_idle_infer_enable=false tx_allow_polarity_inversion=false rx_cdrctrl_enable=true hip_tx_clkout rx_elecidleinfersel fixedclk rx_signaldetect rateswitchbaseclock tx_pipemargin tx_pipedeemph rateswitch reconfig_dprio_mode=1 reconfig_clk reconfig_fromgxb reconfig_togxb enable_0ppm=false pll_powerdown intended_device_family=stratixiv starting_channel_number=0"
        } elseif { [string equal $family {Arria II GX}] == 1} {
            set modulename "alt4gxb"
            set device_suffix "2agx"
            set family_params " LOCKDOWN_EXCL=PCIE IP_MODE=PCIE_HIP_8 gxb_analog_power=AUTO tx_analog_power=AUTO elec_idle_infer_enable=false tx_allow_polarity_inversion=false rx_cdrctrl_enable=true reconfig_togxb_port_width=4 reconfig_fromgxb_port_width=17 hip_tx_clkout rx_elecidleinfersel fixedclk rx_signaldetect rateswitchbaseclock tx_pipemargin tx_pipedeemph rateswitch reconfig_dprio_mode=1 reconfig_clk reconfig_fromgxb reconfig_togxb enable_0ppm=false pll_powerdown intended_device_family=arriaii starting_channel_number=0"
        } elseif { [string equal $family {Stingray}] == 1 ||  [string equal $family {Cyclone IV GX}] == 1} {
            set modulename "alt_c3gxb"
            set device_suffix "3cgx"
            set family_params "LOCKDOWN_EXCL=PCIE IP_MODE=PCIE_HIP_8 gxb_analog_power=AUTO tx_analog_power=AUTO elec_idle_infer_enable=false tx_allow_polarity_inversion=false rx_cdrctrl_enable=true hip_tx_clkout rx_elecidleinfersel fixedclk enable_0ppm=false pll_powerdown intended_device_family=cycloneiv starting_channel_number=84"
        } else {
            send_message error  "Unsupported Family: $family"
            return 1
        }

        if { [string equal $subprotocol "Gen 1-x1"]  } {
            set protocol_suffix "x1d_gen1"
        } elseif { [string equal $subprotocol "Gen 1-x2"]  } {
            set protocol_suffix "x2d_gen1"
        } elseif { [string equal $subprotocol "Gen 1-x4"]  } {
            set protocol_suffix "x4d_gen1"
        } elseif { [string equal $subprotocol "Gen 1-x8"]  } {
            set protocol_suffix "x8d_gen1"
        } elseif { [string equal $subprotocol "Gen 2-x1"]  } {
            set protocol_suffix "x1d_gen2"
        } elseif { [string equal $subprotocol "Gen 2-x4"]  } {
            set protocol_suffix "x4d_gen2"
        } elseif { [string equal $subprotocol "Gen 2-x8"]  } {
            set protocol_suffix "x8d_gen2"
        } else {
            send_message error  "Unsupported Subprotocol: $subprotocol"
            return 1
        }

        set source_file "$qdir/../ip/altera/ip_compiler_for_pci_express/lib/altpcie_serdes_${device_suffix}_${protocol_suffix}_08p.v"

        foreach param [get_parameters] {
                if ([string match [string range $param 0 4] "port_"]) {
                        append used_ports " [string range $param 5 end]"
                } else {
                        if { [string match $param "channel_width"] } {
                                append cbx_params "tx_channel_width=[get_parameter_value $param] rx_channel_width=[get_parameter_value $param] "
                        } elseif { [string match [get_parameter_property $param "type"] "STRING"] || [string match [get_parameter_property $param "type"] "BOOLEAN"]} {
                                append cbx_params " $param=\"[get_parameter_value $param]\" "
                        } else {
                                append cbx_params " $param=[get_parameter_value $param] "
                        }
                }
        }


        file copy -force $source_file $outdir/$output_file

        cd ${outdir}
        set command "qmegawiz -silent module=$modulename $family_params  $cbx_params OPTIONAL_FILES=NONE $output_file"

        send_message info $command
        if { [catch { exec qmegawiz -silent module=$modulename $family_params  $cbx_params OPTIONAL_FILES=NONE $output_file }  msg] } {
            send_message error "Stderr: $::errorInfo"
        } else {
            add_file $outdir/$output_file {synthesis simulation}
        }


}
