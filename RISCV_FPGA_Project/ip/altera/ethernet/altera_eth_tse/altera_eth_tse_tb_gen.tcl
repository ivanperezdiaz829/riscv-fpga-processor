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


#################################################################################################
# Testbench generator using EXAMPLE_DESIGN fileset callback
# Requires altera_eth_tse_common_constants.tcl
#################################################################################################

add_fileset testbench EXAMPLE_DESIGN example_design_cb

proc example_design_cb {entityname} {
   send_message PROGRESS "entityname is $entityname"

   send_message PROGRESS "Generate Verilog testbench for $entityname"
   # Testbench top level file in Verilog language
   verilog_testbench_generator $entityname

   send_message PROGRESS "Generate VHDL testbench for $entityname"
   # Testbench top level file in VHDL language
   vhdl_testbench_generator $entityname

   send_message PROGRESS "Generate README.txt"
   add_fileset_file README.txt OTHER PATH ../tse_ucores/altera_eth_tse_testbench/README.txt

   send_message PROGRESS "Generate DUT simulation model generation scripts"

   # Generate the run script file to generate Verilog simulation model
   set dut_device_family [get_parameter_value deviceFamily]
   
   set verilog_run_script_file "../tse_ucores/altera_eth_tse_testbench/generate_sim_verilog.tcl"
   set verilog_output_run_script_file [create_temp_file generate_sim_verilog.tcl]
   set out [ open $verilog_output_run_script_file w ]
   set in [open $verilog_run_script_file r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line
         
         puts $out "set variant_name $entityname"
         puts $out "set dut_device_family \"$dut_device_family\""

         foreach {param_name} [get_parameters] {
            set is_derived_param [get_parameter_property $param_name DERIVED]
            set param_value [get_parameter_value $param_name]
            
            # Print out the DUT parameters that are not derived
            # and not AUTO_DEVICE and not deviceFamilyName
            if {[get_parameter_property $param_name DERIVED]} {
               continue
            } elseif {[expr {"$param_name" == "deviceFamilyName"}]} {
               continue
            } elseif {[expr {"$param_name" == "AUTO_DEVICE"}]} {
               continue
            } else {
               puts $out "lappend dut_parameters \"--component-param=$param_name=$param_value\""
            }
         }
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file generate_sim_verilog.tcl OTHER PATH $verilog_output_run_script_file {MENTOR_SPECIFIC}

   
   # Generate the run script file to generate VHDL simulation model
   set dut_device_family [get_parameter_value deviceFamily]
   
   set vhdl_run_script_file "../tse_ucores/altera_eth_tse_testbench/generate_sim_vhdl.tcl"
   set vhdl_output_run_script_file [create_temp_file generate_sim_vhdl.tcl]
   set out [ open $vhdl_output_run_script_file w ]
   set in [open $vhdl_run_script_file r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line
         
         puts $out "set variant_name $entityname"
         puts $out "set dut_device_family \"$dut_device_family\""

         foreach {param_name} [get_parameters] {
            set is_derived_param [get_parameter_property $param_name DERIVED]
            set param_value [get_parameter_value $param_name]
            
            # Print out the DUT parameters that are not derived
            # and not AUTO_DEVICE and not deviceFamilyName
            if {[get_parameter_property $param_name DERIVED]} {
               continue
            } elseif {[expr {"$param_name" == "deviceFamilyName"}]} {
               continue
            } elseif {[expr {"$param_name" == "AUTO_DEVICE"}]} {
               continue
            } else {
               puts $out "lappend dut_parameters \"--component-param=$param_name=$param_value\""
            }
         }
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file generate_sim_vhdl.tcl OTHER PATH $vhdl_output_run_script_file {MENTOR_SPECIFIC}

   # Generate the dummy quartus project file to source tcl file for simulation model generation
   generate_quartus_files
}

# This proc do the following tasks:
# Generate generate_sim.qpf
# Generate generate_sim.qsf
proc generate_quartus_files {} {
   set deviceFamilyName [get_parameter_value deviceFamilyName]
   set version [get_module_property VERSION]

   set qpf_file "generate_sim.qpf"
   set qsf_file "generate_sim.qsf"

   # QPF file generation
   set qpf_output_file [create_temp_file $qpf_file]
   set out [ open $qpf_output_file w ]
   puts $out "QUARTUS_VERSION = \"$version\""
   puts $out "PROJECT_REVISION = \"generate_sim\""
   close $out
   add_fileset_file $qpf_file OTHER PATH $qpf_output_file {MENTOR_SPECIFIC}

   # QSF file generation
   set qsf_output_file [create_temp_file $qsf_file]
   set out [ open $qsf_output_file w ]
   puts $out "set_global_assignment -name FAMILY \"$deviceFamilyName\""
   puts $out "set_global_assignment -name TOP_LEVEL_ENTITY generate_sim"
   puts $out "set_global_assignment -name TCL_SCRIPT_FILE generate_sim_verilog.tcl"
   puts $out "set_global_assignment -name TCL_SCRIPT_FILE generate_sim_vhdl.tcl"
   close $out
   add_fileset_file $qsf_file OTHER PATH $qsf_output_file {MENTOR_SPECIFIC}

}

#################################################################################################
# Verilog testbench generator
#################################################################################################

# This proc do the following tasks:
# - Copy necessary testbench files
# - Creates testbench run script
# - Create waveform do file that is called in testbench run script
# - Call necessary testbench top generator based on DUT variants
proc verilog_testbench_generator {entityname} {

   global testbench_verilog_files

   # Verilog testbench files
   foreach {output_file source_file} $testbench_verilog_files {
      add_fileset_file testbench_verilog/$output_file VERILOG PATH $source_file {MENTOR_SPECIFIC}
   }

   # Testbench run script
   set run_script "../tse_ucores/altera_eth_tse_testbench/testbench/run_tb.tcl"
   set run_script_output_file [create_temp_file run_$entityname\_verilog_tb.tcl]
   set out [ open $run_script_output_file w ]
   set in [open $run_script r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line
         # Patch run script with suitable parameter value
         puts $out "set QSYS_SIMDIR ../$entityname\_sim"
         puts $out "set dut_wave_do $entityname\_wave.do"
         puts $out "set testbench_model_dir ../models"

      } elseif {[string match "*TESTBENCH_COMPILE_COMMAND*" $line]} {
         puts $out "vlog -work work +incdir+\$testbench_model_dir \$testbench_model_dir/*.v"
         puts $out "vlog -work work *.v"
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file testbench_verilog/$entityname/run_$entityname\_tb.tcl OTHER PATH $run_script_output_file {MENTOR_SPECIFIC}


   # Waveform do file
   set wave_do "../tse_ucores/altera_eth_tse_testbench/testbench/wave.do"
   set wave_do_output_file [create_temp_file $entityname\_wave.do]
   set out [ open $wave_do_output_file w ]
   set in [open $wave_do r]

   while {[gets $in line] != -1} {
      puts $out $line
   }

   close $in
   close $out
   add_fileset_file testbench_verilog/$entityname/$entityname\_wave.do OTHER PATH $wave_do_output_file {MENTOR_SPECIFIC}

   # Create the testbench top level file based on different DUT variants
   verilog_tb_top_gen $entityname

}

# Verilog top level testbench generator
proc verilog_tb_top_gen {entityname} {

   global testbench_port_connection
   global testbench_port_mac_only_connection
   global testbench_port_pcs_only_connection

   set core_variation [get_parameter_value core_variation]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set enable_ena [get_parameter_value enable_ena]
   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set transceiver_type [get_parameter_value transceiver_type]
   
   set testbench_dut_port_list [get_module_ports]

   # Decide which testbench template we should be using
   # export_pwrdn options is only applicable for non phyip devices
   switch $core_variation {
      SMALL_MAC_10_100 {
         set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/verilog/testbench_gen_host_32.v"
      }
      SMALL_MAC_GIGE {
         set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/verilog/testbench_gen_host_32.v"
      }
      MAC_ONLY {
         if {$enable_use_internal_fifo} {
            if {[expr $enable_ena == 32]} {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/verilog/testbench_gen_host_32.v"
            } else {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/verilog/testbench_gen_host.v"
            } 
         } else {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/verilog/testbench_gen_host.v"
         }
      }
      PCS_ONLY {
         switch $transceiver_type {
            NONE {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/verilog/tb_pcs.v"
            }
            GXB {
               if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/verilog/tb_pcs_pma_powerdown.v"
               } else {
                  if {[is_use_nf_phyip]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/verilog/tb_pcs_pma_nf_phyip.v"
                  } else {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/verilog/tb_pcs_pma.v"
                  }
               }
            }
            LVDS_IO {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/verilog/tb_pcs_pma.v"
            }
         }
      }
      MAC_PCS {
         if {[expr {"$enable_use_internal_fifo" == "true"}] && [expr {$enable_ena == 32}]} {
            switch $transceiver_type {
               NONE {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac32_pcs.v"
               }
               GXB {
                  if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac32_pcs_pma_powerdown.v"
                  } else {
                     if {[is_use_nf_phyip]} {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac32_pcs_pma_nf_phyip.v"
                     } else {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac32_pcs_pma.v"
                     }
                  }
               }
               LVDS_IO {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac32_pcs_pma.v"
               }
            }
         } else {
            switch $transceiver_type {
               NONE {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac8_pcs.v"
               }
               GXB {
                  if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac8_pcs_pma_powerdown.v"
                  } else {
                     if {[is_use_nf_phyip]} {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac8_pcs_pma_nf_phyip.v"
                     } else {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac8_pcs_pma.v"
                     }
                  }
               }
               LVDS_IO {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/verilog/testbench_mac8_pcs_pma.v"
               }
            }
         }
      }
   }

   set output_file     [ create_temp_file  $entityname\_tb.v]
   set out   [ open $output_file w ]
   set in  [open $tb_filename r]

   # Testbench generation
   while {[gets $in line] != -1} {

      # Testbench parameters
      if [ string match "*RTL_PARAMETERS*" $line ] {

         puts $out $line

         if {$isUseMAC} {
            verilog_tb_param_mac $out
         }

         if {$isUsePCS} {
            verilog_tb_param_pcs $out
            
            if {[string match "NONE" $transceiver_type]} {
               # Do nothing as we are not instantiating PMA
            } else {
               verilog_tb_param_pma $out
            }
         }

         puts $out "// END_OF_RTL_PARAMETERS\n";

      } elseif [ string match "*RTL_CORE_INSTANCE*" $line ] {

         # DUT instantiation
         puts $out $line
         puts $out "$entityname dut"
         puts $out "("
         
         set dut_port_count [llength $testbench_dut_port_list]
         set port_count 1
         foreach {dut_port} $testbench_dut_port_list {
            
            set tb_port $dut_port

            set dut_port_width [get_port_property $dut_port WIDTH_VALUE]

            # Check if we need to connect dut port to tb port that is different name
            foreach {tb_dut_port tb_port_name} $testbench_port_connection {
               if {[string match $dut_port $tb_dut_port]} {

                  if [regexp -all {[0-9]+} $tb_port_name] {
                     # Terminate with constant
                     # Specific with constant with in order to support VHDL DUT with Verilog testbench
                     set tb_port "$dut_port_width'b $tb_port_name"
                  } else {
                     # Connect with different signal name
                     set tb_port $tb_port_name
                  }

                  break
               }
            }

            # MAC only testbench port connection
            if {[expr {"$isUseMAC" == "true"}] && [expr {"$isUsePCS" == "false"}]} {
               foreach {tb_dut_port tb_port_name} $testbench_port_mac_only_connection {
                  if {[string match $dut_port $tb_dut_port]} {
                     if [regexp -all {[0-9]+} $tb_port_name] {
                        # Terminate with constant
                        # Specific with constant with in order to support VHDL DUT with Verilog testbench
                        set tb_port "$dut_port_width'b $tb_port_name"
                     } else {
                        # Connect with different signal name
                        set tb_port $tb_port_name
                     }
                     break
                  }
               }
            }

            # PCS only testbench port connection
            if {[expr {"$isUseMAC" == "false"}] && [expr {"$isUsePCS" == "true"}]} {
               foreach {tb_dut_port tb_port_name} $testbench_port_pcs_only_connection {
                  if {[string match $dut_port $tb_dut_port]} {
                     if [regexp -all {[0-9]+} $tb_port_name] {
                        # Terminate with constant
                        # Specific with constant with in order to support VHDL DUT with Verilog testbench
                        set tb_port "$dut_port_width'b $tb_port_name"
                     } else {
                        # Connect with different signal name
                        set tb_port $tb_port_name
                     }
                     break
                  }
               }
            }

            # Now connect the DUT port to testbench port
            if {$port_count < $dut_port_count} {
               puts $out "   .$dut_port ($tb_port),"
            } else {
               puts $out "   .$dut_port ($tb_port)"
            }

            incr port_count
         }

         puts $out ");"
      } else {
         puts $out $line
      }
   }

   close $in
   close $out

   add_fileset_file testbench_verilog/$entityname/$entityname\_tb.v VERILOG PATH $output_file {MENTOR_SPECIFIC}
}

proc verilog_tb_param_mac {out} {

   set core_variation [get_parameter_value core_variation]
   set stat_cnt_ena [get_parameter_value stat_cnt_ena]
   set ext_stat_cnt_ena [get_parameter_value ext_stat_cnt_ena]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set enable_ena [get_parameter_value enable_ena]
   set enable_shift16 [get_parameter_value enable_shift16]
   set max_channels [get_parameter_value max_channels]

   set tb_param {
      ENABLE_MAGIC_DETECT     enable_magic_detect
      ENABLE_MDIO             useMDIO
      ENABLE_SUP_ADDR         enable_sup_addr
      CORE_VERSION            core_version
      MDIO_CLK_DIV            mdio_clk_div
      ENA_HASH                ena_hash
      STAT_CNT_ENA            stat_cnt_ena
      ENABLE_HD_LOGIC         enable_hd_logic
      REDUCED_INTERFACE_ENA   reduced_interface_ena
      ENABLE_GMII_LOOPBACK    enable_gmii_loopback
      ENABLE_MAC_FLOW_CTRL    enable_mac_flow_ctrl
      ENABLE_MAC_RX_VLAN      enable_mac_vlan
      ENABLE_MAC_TX_VLAN      enable_mac_vlan
      SYNCHRONIZER_DEPTH      synchronizer_depth
   }
   
   # Testbench parameters that we can get from core parameters
   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "parameter $tb_param = 1;"
         } else {
            puts $out "parameter $tb_param = 0;"
         }
      } else {
         puts $out "parameter $tb_param = $param_value;"
      }
   }

   # Extended statistic register can only be enabled if we have statistic counter
   if {$stat_cnt_ena} {
      if {$ext_stat_cnt_ena} {
         puts $out "parameter ENABLE_EXTENDED_STAT_REG = 1;"
      } else {
         puts $out "parameter ENABLE_EXTENDED_STAT_REG = 0;"
      }
   } else {
      puts $out "parameter ENABLE_EXTENDED_STAT_REG = 0;"
   }

   # Testbench parameters that are always constants
   puts $out "parameter ENABLE_MAC_TXADDR_SET = 1;"
   puts $out "parameter CRC32GENDELAY = 6;"
   puts $out "parameter CRC32S1L2_EXTERN = 0;"
   puts $out "parameter CRC32DWIDTH = 8;"
   puts $out "parameter CRC32CHECK16BIT = 0;"
   puts $out "parameter CUST_VERSION = 0;"
   puts $out "parameter RESET_LEVEL = 1;"
   puts $out "parameter USE_SYNC_RESET = 1;"
   
   # 1588 parameter
   puts $out "parameter TSTAMP_FP_WIDTH = [get_parameter_value tstamp_fp_width];"

   # Testbench parameters that are different for FIFO and FIFOless MAC
   if {$enable_use_internal_fifo} {
      puts $out "parameter EG_ADDR = [get_parameter_value eg_addr];"
      puts $out "parameter ING_ADDR = [get_parameter_value ing_addr];"
      puts $out "parameter ENABLE_ENA = $enable_ena;"

      switch $core_variation {
         SMALL_MAC_10_100 {
            puts $out "parameter ENABLE_MACLITE = 1;"
            puts $out "parameter MACLITE_GIGE = 0;"
            
            # Small MAC 10/100 is always with FIFO 32 bit
            if {$enable_shift16} {
               puts $out "parameter ENABLE_SHIFT16 = 1;"
            } else {
               puts $out "parameter ENABLE_SHIFT16 = 0;"
            }
         }
         SMALL_MAC_GIGE {
            puts $out "parameter ENABLE_MACLITE = 1;"
            puts $out "parameter MACLITE_GIGE = 1;"

            # Small MAC GIGE is always with FIFO 32 bit
            if {$enable_shift16} {
               puts $out "parameter ENABLE_SHIFT16 = 1;"
            } else {
               puts $out "parameter ENABLE_SHIFT16 = 0;"
            }

         }
         default {
            puts $out "parameter ENABLE_MACLITE = 0;"
            puts $out "parameter MACLITE_GIGE = 0;"

            # Check to see if the FIFO is 32 bit, then only we enable shift16
            # accordingly
            if {[expr $enable_ena == 32]} {
               if {$enable_shift16} {
                  puts $out "parameter ENABLE_SHIFT16 = 1;"
               } else {
                  puts $out "parameter ENABLE_SHIFT16 = 0;"
               }
            } else {
               puts $out "parameter ENABLE_SHIFT16 = 0;"
            }
         }
      }

      puts $out "parameter RAM_TYPE = \"AUTO\";"
      puts $out "parameter INSERT_TA = 0;"
      puts $out "parameter MAX_CHANNELS = 0;"

      # Testbench reg_addr_port_width
      puts $out "parameter REG_ADDR_WIDTH = 8;"

      # Testbench rx_afull_channel port width
      puts $out "parameter RX_AFULL_CHANNEL_WIDTH = 1;"

   } else {
      puts $out "parameter MAX_CHANNELS = $max_channels;"
      #puts $out "parameter CHANNEL_WIDTH = [get_parameter_value channel_width];"
      #puts $out "parameter ENABLE_REG_SHARING = [get_parameter_value enable_reg_sharing];"
      #puts $out "parameter ENABLE_PKT_CLASS = [get_parameter_value enable_pkt_class];"
      if {[get_parameter_value enable_clk_sharing]} {
         puts $out "parameter ENABLE_CLK_SHARING = 1;"
      } else {
         puts $out "parameter ENABLE_CLK_SHARING = 0;"
      }
      
      if {$enable_shift16} {
         puts $out "parameter ENABLE_SHIFT16 = 1;"
      } else {
         puts $out "parameter ENABLE_SHIFT16 = 0;"
      }

      puts $out "parameter ENABLE_MACLITE = 0;"
      puts $out "parameter MACLITE_GIGE = 0;"
      puts $out "parameter ENABLE_ENA = 0;"
      puts $out "parameter EG_ADDR = 8;"
      puts $out "parameter ING_ADDR = 8;"

      # Testbench reg_addr port width
      set extra_addr_bits [log2_in_int ($max_channels)]
      set reg_addr_width [expr $extra_addr_bits + 8]
      if {[expr $max_channels == 1]} {
         puts $out "parameter REG_ADDR_WIDTH = 8;"
      } else {
         puts $out "parameter REG_ADDR_WIDTH = $reg_addr_width;"
      }

      # Testbench rx_afull_channel port width
      set rx_afull_channel_width [expr [log2_in_int ($max_channels)]]
      puts $out "parameter RX_AFULL_CHANNEL_WIDTH = $rx_afull_channel_width;"

   }
}

proc verilog_tb_param_pcs {out} {
   set tb_param {
      PHY_IDENTIFIER phy_identifier
      DEV_VERSION    dev_version
      ENABLE_SGMII   enable_sgmii
   }

   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "parameter $tb_param = 1;"
         } else {
            puts $out "parameter $tb_param = 0;"
         }
      } else {
         puts $out "parameter $tb_param = $param_value;"
      }
   }

}

proc verilog_tb_param_pma {out} {

   #TRANSCEIVER_OPTION

   set deviceFamily [get_parameter_value deviceFamily]

   set tb_param {
      EXPORT_PWRDN   export_pwrdn
      ENABLE_ALT_RECONFIG  enable_alt_reconfig
      STARTING_CHANNEL_NUMBER starting_channel_number
   }

   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "parameter $tb_param = 1;"
         } else {
            puts $out "parameter $tb_param = 0;"
         }
      } else {
         puts $out "parameter $tb_param = $param_value;"
      }
   }

   # For ARRIAGX device family, the RTL is expecting the device name to be ARRIAGX, not STRATIXIIGXLITE
   # For SINGRAY, it is CYCLONEIVGX
   if [expr {"$deviceFamily" == "STRATIXIIGXLITE"}] {
      puts $out "parameter DEVICE_FAMILY = \"ARRIAGX\";"
   } elseif [expr {"$deviceFamily" == "STINGRAY"}] {
      puts $out "parameter DEVICE_FAMILY = \"CYCLONEIVGX\";"
   } else {
      puts $out "parameter DEVICE_FAMILY = \"$deviceFamily\";"
   }

   # Testbench reconfig_togxb and reconfig_fromgxb port width
   if {[is_use_phyip]} {
      set reconfig_togxb_width 140
      set reconfig_fromgxb_width 92
   } elseif {[expr {"$deviceFamily" == "STRATIXIIGX"} || {"$deviceFamily" == "STRATIXIIGXLITE"}]} {
      # alt2gxb
      set reconfig_togxb_width 3
      set reconfig_fromgxb_width 1
   } elseif { [expr {"$deviceFamily" == "STRATIXIV"}] ||
      [expr {"$deviceFamily" == "ARRIAII"}] ||
	   [expr {"$deviceFamily" == "HARDCOPYIV"}] ||
	   [expr {"$deviceFamily" == "ARRIAIIGZ"}] } {
      # alt4gxb
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 17
   } elseif {[expr {"$deviceFamily" == "STINGRAY"}]} {
      # alt4gxb for STINGRAY family
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 5
	} else {
      # we should not be here
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 17
   }
   puts $out "parameter RECONFIG_TOGXB_WIDTH = $reconfig_togxb_width;"
   puts $out "parameter RECONFIG_FROMGXB_WIDTH = $reconfig_fromgxb_width;"

}

#################################################################################################
# VHDL testbench generator
#################################################################################################

# This proc do the following tasks:
# - Copy necessary testbench files
# - Creates testbench run script
# - Create waveform do file that is called in testbench run script
# - Call necessary testbench top generator based on DUT variants
proc vhdl_testbench_generator {entityname} {

   global testbench_vhdl_files

   # Verilog testbench files
   foreach {output_file source_file} $testbench_vhdl_files {
      add_fileset_file testbench_vhdl/$output_file VHDL PATH $source_file {MENTOR_SPECIFIC}
   }

   # Testbench run script
   set run_script "../tse_ucores/altera_eth_tse_testbench/testbench/run_tb.tcl"
   set run_script_output_file [create_temp_file run_$entityname\_vhdl_tb.tcl]
   set out [ open $run_script_output_file w ]
   set in [open $run_script r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line
         # Patch run script with suitable parameter value
         puts $out "set QSYS_SIMDIR ../$entityname\_sim"
         puts $out "set dut_wave_do $entityname\_wave.do"
         puts $out "set testbench_model_dir ../models"

      } elseif {[string match "*TESTBENCH_COMPILE_COMMAND*" $line]} {
         puts $out "vcom -work work -93 \$testbench_model_dir/*.vhd"
         puts $out "vcom -work work -93 *.vhd"
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file testbench_vhdl/$entityname/run_$entityname\_tb.tcl OTHER PATH $run_script_output_file {MENTOR_SPECIFIC}


   # Waveform do file
   set wave_do "../tse_ucores/altera_eth_tse_testbench/testbench/wave.do"
   set wave_do_output_file [create_temp_file $entityname\_wave.do]
   set out [ open $wave_do_output_file w ]
   set in [open $wave_do r]

   while {[gets $in line] != -1} {
      puts $out $line
   }

   close $in
   close $out
   add_fileset_file testbench_vhdl/$entityname/$entityname\_wave.do OTHER PATH $wave_do_output_file {MENTOR_SPECIFIC}

   # Create the testbench top level file based on different DUT variants
   vhdl_tb_top_gen $entityname

}

# VHDL top level testbench generator
proc vhdl_tb_top_gen {entityname} {

   global testbench_port_connection
   global testbench_port_mac_only_connection
   global testbench_port_pcs_only_connection

   set core_variation [get_parameter_value core_variation]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set enable_ena [get_parameter_value enable_ena]
   set isUseMAC [get_parameter_value isUseMAC]
   set isUsePCS [get_parameter_value isUsePCS]
   set transceiver_type [get_parameter_value transceiver_type]
   
   set testbench_dut_port_list [get_module_ports]

   # Decide which testbench template we should be using
   # export_pwrdn options is only applicable for non phyip devices
   switch $core_variation {
      SMALL_MAC_10_100 {
         set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/vhdl/testbench_gen_host_32.vhd"
      }
      SMALL_MAC_GIGE {
         set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/vhdl/testbench_gen_host_32.vhd"
      }
      MAC_ONLY {
         if {$enable_use_internal_fifo} {
            if {[expr $enable_ena == 32]} {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/vhdl/testbench_gen_host_32.vhd"
            } else {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/vhdl/testbench_gen_host.vhd"
            } 
         } else {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC/vhdl/testbench_gen_host.vhd"
         }
      }
      PCS_ONLY {
         switch $transceiver_type {
            NONE {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/vhdl/tb_pcs.vhd"
            }
            GXB {
               if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/vhdl/tb_pcs_pma_powerdown.vhd"
               } else {
                  if {[is_use_nf_phyip]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/vhdl/tb_pcs_pma_nf_phyip.vhd"
                  } else {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/vhdl/tb_pcs_pma.vhd"
                  }
               }
            }
            LVDS_IO {
               set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/PCS/vhdl/tb_pcs_pma.vhd"
            }
         }
      }
      MAC_PCS {
         if {[expr {"$enable_use_internal_fifo" == "true"}] && [expr {$enable_ena == 32}]} {
            switch $transceiver_type {
               NONE {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac32_pcs.vhd"
               }
               GXB {
                  if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac32_pcs_pma_powerdown.vhd"
                  } else {
                     if {[is_use_nf_phyip]} {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac32_pcs_pma_nf_phyip.vhd"
                     } else {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac32_pcs_pma.vhd"
                     }
                  }
               }
               LVDS_IO {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac32_pcs_pma.vhd"
               }
            }
         } else {
            switch $transceiver_type {
               NONE {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac8_pcs.vhd"
               }
               GXB {
                  if {[expr {[is_use_phyip] == 0}] && [expr {[is_use_nf_phyip] == 0}] && [get_parameter_value export_pwrdn]} {
                     set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac8_pcs_pma_powerdown.vhd"
                  } else {
                     if {[is_use_nf_phyip]} {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac8_pcs_pma_nf_phyip.vhd"
                     } else {
                        set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac8_pcs_pma.vhd"
                     }
                  }
               }
               LVDS_IO {
                  set tb_filename "../tse_ucores/altera_eth_tse_testbench/testbench/MAC_PCS/vhdl/testbench_mac8_pcs_pma.vhd"
               }
            }
         }
      }
   }

   set output_file     [ create_temp_file  $entityname\_tb.vhd]
   set out   [ open $output_file w ]
   set in  [open $tb_filename r]

   # Testbench generation
   while {[gets $in line] != -1} {

      # Testbench parameters
      if [ string match "*RTL_PARAMETERS*" $line ] {

         puts $out $line

         if {$isUseMAC} {
            vhdl_tb_param_mac $out
         }

         if {$isUsePCS} {
            vhdl_tb_param_pcs $out
            
            if {[string match "NONE" $transceiver_type]} {
               # Do nothing as we are not instantiating PMA
            } else {
               vhdl_tb_param_pma $out
            }
         }

         puts $out "-- END_OF_RTL_PARAMETERS\n";

      } elseif [ string match "*RTL_CORE_INSTANCE_COMPONENT*" $line] {
         puts $out $line
         set dut_port_count [llength $testbench_dut_port_list]

         # DUT component declaration
         puts $out "component $entityname"
         puts $out "port ("
         set port_count 1

         foreach {dut_port} $testbench_dut_port_list {
            set dut_port_dir [get_port_property $dut_port DIRECTION]
            set dut_port_vhdl_type [get_port_property $dut_port VHDL_TYPE]
            set dut_port_width [get_port_property $dut_port WIDTH_VALUE]

            if [string match -nocase "Input" $dut_port_dir] {
               set dut_port_vhdl_dir "IN"
            } else {
               set dut_port_vhdl_dir "OUT"
            }

            # If this is the last port in the component declaration, don't put a comma at the end of line
            if {$port_count < $dut_port_count} {
               set component_declare_comma ";"
            } else {
               set component_declare_comma ""
            }
            
            if [string match -nocase "std_logic" $dut_port_vhdl_type] {
               puts $out "   $dut_port : $dut_port_vhdl_dir $dut_port_vhdl_type$component_declare_comma"
            } else {
               puts $out "   $dut_port : $dut_port_vhdl_dir $dut_port_vhdl_type\([expr $dut_port_width -1] downto 0\)$component_declare_comma"
            }

            incr port_count
         }

         puts $out ");"
         puts $out "end component;"
         puts $out ""
      } elseif [ string match "*RTL_CORE_INSTANCE*" $line ] {

         puts $out $line
         set dut_port_count [llength $testbench_dut_port_list]

         # DUT instantiation
         puts $out "dut: $entityname"
         puts $out "port map ("
         
         set port_count 1
         foreach {dut_port} $testbench_dut_port_list {
            
            # DUT port information that we need use later
            set dut_port_vhdl_type [get_port_property $dut_port VHDL_TYPE]
            set dut_port_width [get_port_property $dut_port WIDTH_VALUE]

            set tb_port $dut_port
            # Check if we need to connect dut port to tb port that is different name
            foreach {tb_dut_port tb_port_name} $testbench_port_connection {
               if {[string match $dut_port $tb_dut_port]} {

                  if [expr {$tb_port_name == ""}] {
                     # Left open
                     set tb_port "OPEN"
                  } elseif [regexp -all {[0-9]+} $tb_port_name] {
                     # Terminate with constant
                     set tb_port "\'$tb_port_name\'"
                  } else {
                     # Connect with different signal name
                     if [string match -nocase "std_logic" $dut_port_vhdl_type] {
                        set tb_port $tb_port_name
                     } else {
                        set tb_port "$tb_port_name\([expr $dut_port_width -1] downto 0\)"
                     }
                  }
                  break
               }
            }

            # MAC only testbench port connection
            if {[expr {"$isUseMAC" == "true"}] && [expr {"$isUsePCS" == "false"}]} {
               foreach {tb_dut_port tb_port_name} $testbench_port_mac_only_connection {
                  if {[string match $dut_port $tb_dut_port]} {

                     if [expr {$tb_port_name == ""}] {
                        # Left open
                        set tb_port "OPEN"
                     } elseif [regexp -all {[0-9]+} $tb_port_name] {
                        # Terminate with constant
                        set tb_port "\'$tb_port_name\'"
                     } else {
                        # Connect with different signal name
                        if [string match -nocase "std_logic" $dut_port_vhdl_type] {
                           set tb_port $tb_port_name
                        } else {
                           set tb_port "$tb_port_name\([expr $dut_port_width -1] downto 0\)"
                        }
                     }

                     break
                  }
               }
            }

            # PCS only testbench port connection
            if {[expr {"$isUseMAC" == "false"}] && [expr {"$isUsePCS" == "true"}]} {
               foreach {tb_dut_port tb_port_name} $testbench_port_pcs_only_connection {
                  if {[string match $dut_port $tb_dut_port]} {

                     if [expr {$tb_port_name == ""}] {
                        # Left open
                        set tb_port "OPEN"
                     } elseif [regexp -all {[0-9]+} $tb_port_name] {
                        # Terminate with constant
                        set tb_port "\'$tb_port_name\'"
                     } else {
                        # Connect with different signal name
                        if [string match -nocase "std_logic" $dut_port_vhdl_type] {
                           set tb_port $tb_port_name
                        } else {
                           set tb_port "$tb_port_name\([expr $dut_port_width -1] downto 0\)"
                        }
                     }

                     break
                  }
               }
            }

            # Now connect the DUT port to testbench port
            if {$port_count < $dut_port_count} {
               puts $out "   $dut_port => $tb_port,"
            } else {
               puts $out "   $dut_port => $tb_port"
            }

            incr port_count
         }

         puts $out ");"
      } else {
         puts $out $line
      }
   }

   close $in
   close $out

   add_fileset_file testbench_vhdl/$entityname/$entityname\_tb.vhd VHDL PATH $output_file {MENTOR_SPECIFIC}
}

proc vhdl_tb_param_mac {out} {

   set core_variation [get_parameter_value core_variation]
   set stat_cnt_ena [get_parameter_value stat_cnt_ena]
   set ext_stat_cnt_ena [get_parameter_value ext_stat_cnt_ena]
   set enable_use_internal_fifo [get_parameter_value enable_use_internal_fifo]
   set enable_ena [get_parameter_value enable_ena]
   set enable_shift16 [get_parameter_value enable_shift16]
   set max_channels [get_parameter_value max_channels]

   set tb_param {
      ENABLE_MAGIC_DETECT     enable_magic_detect
      ENABLE_MDIO             useMDIO
      ENABLE_SUP_ADDR         enable_sup_addr
      CORE_VERSION            core_version
      MDIO_CLK_DIV            mdio_clk_div
      ENA_HASH                ena_hash
      STAT_CNT_ENA            stat_cnt_ena
      ENABLE_HD_LOGIC         enable_hd_logic
      REDUCED_INTERFACE_ENA   reduced_interface_ena
      ENABLE_GMII_LOOPBACK    enable_gmii_loopback
      ENABLE_MAC_FLOW_CTRL    enable_mac_flow_ctrl
      ENABLE_MAC_RX_VLAN      enable_mac_vlan
      ENABLE_MAC_TX_VLAN      enable_mac_vlan
      SYNCHRONIZER_DEPTH      synchronizer_depth
   }
   
   # Testbench parameters that we can get from core parameters
   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "constant $tb_param : INTEGER := 1;"
         } else {
            puts $out "constant $tb_param : INTEGER := 0;"
         }
      } else {
         puts $out "constant $tb_param : INTEGER := $param_value;"
      }
   }

   # Extended statistic register can only be enabled if we have statistic counter
   if {$stat_cnt_ena} {
      if {$ext_stat_cnt_ena} {
         puts $out "constant ENABLE_EXTENDED_STAT_REG : INTEGER := 1;"
      } else {
         puts $out "constant ENABLE_EXTENDED_STAT_REG : INTEGER := 0;"
      }
   } else {
      puts $out "constant ENABLE_EXTENDED_STAT_REG : INTEGER := 0;"
   }

   # Testbench parameters that are always constants
   puts $out "constant ENABLE_MAC_TXADDR_SET : INTEGER := 1;"
   puts $out "constant CRC32GENDELAY : INTEGER := 6;"
   puts $out "constant CRC32S1L2_EXTERN : INTEGER := 0;"
   puts $out "constant CRC32DWIDTH : INTEGER := 8;"
   puts $out "constant CRC32CHECK16BIT : INTEGER := 0;"
   puts $out "constant CUST_VERSION : INTEGER := 0;"
   puts $out "constant RESET_LEVEL : INTEGER := 1;"
   puts $out "constant USE_SYNC_RESET : INTEGER := 1;"
   
   # 1588 parameter
   puts $out "constant TSTAMP_FP_WIDTH : INTEGER := [get_parameter_value tstamp_fp_width];"

   # Testbench parameters that are different for FIFO and FIFOless MAC
   if {$enable_use_internal_fifo} {
      puts $out "constant EG_ADDR : INTEGER := [get_parameter_value eg_addr];"
      puts $out "constant ING_ADDR : INTEGER := [get_parameter_value ing_addr];"
      puts $out "constant ENABLE_ENA : INTEGER := $enable_ena;"

      switch $core_variation {
         SMALL_MAC_10_100 {
            puts $out "constant ENABLE_MACLITE : INTEGER := 1;"
            puts $out "constant MACLITE_GIGE : INTEGER := 0;"
            
            # Small MAC 10/100 is always with FIFO 32 bit
            if {$enable_shift16} {
               puts $out "constant ENABLE_SHIFT16 : INTEGER := 1;"
            } else {
               puts $out "constant ENABLE_SHIFT16 : INTEGER := 0;"
            }
         }
         SMALL_MAC_GIGE {
            puts $out "constant ENABLE_MACLITE : INTEGER := 1;"
            puts $out "constant MACLITE_GIGE : INTEGER := 1;"

            # Small MAC GIGE is always with FIFO 32 bit
            if {$enable_shift16} {
               puts $out "constant ENABLE_SHIFT16 : INTEGER := 1;"
            } else {
               puts $out "constant ENABLE_SHIFT16 : INTEGER := 0;"
            }

         }
         default {
            puts $out "constant ENABLE_MACLITE : INTEGER := 0;"
            puts $out "constant MACLITE_GIGE : INTEGER := 0;"

            # Check to see if the FIFO is 32 bit, then only we enable shift16
            # accordingly
            if {[expr $enable_ena == 32]} {
               if {$enable_shift16} {
                  puts $out "constant ENABLE_SHIFT16 : INTEGER := 1;"
               } else {
                  puts $out "constant ENABLE_SHIFT16 : INTEGER := 0;"
               }
            } else {
               puts $out "constant ENABLE_SHIFT16 : INTEGER := 0;"
            }
         }
      }

      puts $out "constant RAM_TYPE : STRING:= \"AUTO\";"
      puts $out "constant INSERT_TA : INTEGER := 0;"
      puts $out "constant MAX_CHANNELS : INTEGER := 0;"

      # Testbench reg_addr_port_width
      puts $out "constant REG_ADDR_WIDTH : INTEGER := 8;"

      # Testbench rx_afull_channel port width
      puts $out "constant RX_AFULL_CHANNEL_WIDTH : INTEGER := 1;"

   } else {
      puts $out "constant MAX_CHANNELS : INTEGER := $max_channels;"
      #puts $out "constant CHANNEL_WIDTH : INTEGER := [get_parameter_value channel_width];"
      #puts $out "constant ENABLE_REG_SHARING : INTEGER := [get_parameter_value enable_reg_sharing];"
      #puts $out "constant ENABLE_PKT_CLASS : INTEGER := [get_parameter_value enable_pkt_class];"
      if {[get_parameter_value enable_clk_sharing]} {
         puts $out "constant ENABLE_CLK_SHARING : INTEGER := 1;"
      } else {
         puts $out "constant ENABLE_CLK_SHARING : INTEGER := 0;"
      }
      
      if {$enable_shift16} {
         puts $out "constant ENABLE_SHIFT16 : INTEGER := 1;"
      } else {
         puts $out "constant ENABLE_SHIFT16 : INTEGER := 0;"
      }

      puts $out "constant ENABLE_MACLITE : INTEGER := 0;"
      puts $out "constant MACLITE_GIGE : INTEGER := 0;"
      puts $out "constant ENABLE_ENA : INTEGER := 0;"
      puts $out "constant EG_ADDR : INTEGER := 8;"
      puts $out "constant ING_ADDR : INTEGER := 8;"

      # Testbench reg_addr port width
      set extra_addr_bits [log2_in_int ($max_channels)]
      set reg_addr_width [expr $extra_addr_bits + 8]
      if {[expr $max_channels == 1]} {
         puts $out "constant REG_ADDR_WIDTH : INTEGER := 8;"
      } else {
         puts $out "constant REG_ADDR_WIDTH : INTEGER := $reg_addr_width;"
      }

      # Testbench rx_afull_channel port width
      set rx_afull_channel_width [expr [log2_in_int ($max_channels)]]
      puts $out "constant RX_AFULL_CHANNEL_WIDTH : INTEGER := $rx_afull_channel_width;"

   }
}

proc vhdl_tb_param_pcs {out} {
   set tb_param {
      PHY_IDENTIFIER phy_identifier
      DEV_VERSION    dev_version
      ENABLE_SGMII   enable_sgmii
   }

   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "constant $tb_param : INTEGER := 1;"
         } else {
            puts $out "constant $tb_param : INTEGER := 0;"
         }
      } else {
         puts $out "constant $tb_param : INTEGER := $param_value;"
      }
   }

}

proc vhdl_tb_param_pma {out} {

   #TRANSCEIVER_OPTION

   set deviceFamily [get_parameter_value deviceFamily]

   set tb_param {
      EXPORT_PWRDN   export_pwrdn
      ENABLE_ALT_RECONFIG  enable_alt_reconfig
      STARTING_CHANNEL_NUMBER starting_channel_number
   }

   foreach {tb_param module_param} $tb_param {
      set param_value [get_parameter_value $module_param]

      if { [string match -nocase "BOOLEAN" [get_parameter_property $module_param TYPE]] } {
         # Convert boolean parameter to 0/1 value
         if {[get_parameter_value $module_param]} {
            puts $out "constant $tb_param : INTEGER := 1;"
         } else {
            puts $out "constant $tb_param : INTEGER := 0;"
         }
      } else {
         puts $out "constant $tb_param : INTEGER := $param_value;"
      }
   }

   # For ARRIAGX device family, the RTL is expecting the device name to be ARRIAGX, not STRATIXIIGXLITE
   # For SINGRAY, it is CYCLONEIVGX
   if [expr {"$deviceFamily" == "STRATIXIIGXLITE"}] {
      puts $out "constant DEVICE_FAMILY : STRING := \"ARRIAGX\";"
   } elseif [expr {"$deviceFamily" == "STINGRAY"}] {
      puts $out "constant DEVICE_FAMILY : STRING := \"CYCLONEIVGX\";"
   } else {
      puts $out "constant DEVICE_FAMILY : STRING := \"$deviceFamily\";"
   }

   # Testbench reconfig_togxb and reconfig_fromgxb port width
   if {[is_use_phyip]} {
      set reconfig_togxb_width 140
      set reconfig_fromgxb_width 92
   } elseif {[expr {"$deviceFamily" == "STRATIXIIGX"} || {"$deviceFamily" == "STRATIXIIGXLITE"}]} {
      # alt2gxb
      set reconfig_togxb_width 3
      set reconfig_fromgxb_width 1
   } elseif { [expr {"$deviceFamily" == "STRATIXIV"}] ||
      [expr {"$deviceFamily" == "ARRIAII"}] ||
	   [expr {"$deviceFamily" == "HARDCOPYIV"}] ||
	   [expr {"$deviceFamily" == "ARRIAIIGZ"}] } {
      # alt4gxb
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 17
   } elseif {[expr {"$deviceFamily" == "STINGRAY"}]} {
      # alt4gxb for STINGRAY family
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 5
	} else {
      # we should not be here
      set reconfig_togxb_width 4
      set reconfig_fromgxb_width 17
   }
   puts $out "constant RECONFIG_TOGXB_WIDTH : INTEGER:= $reconfig_togxb_width;"
   puts $out "constant RECONFIG_FROMGXB_WIDTH : INTEGER:= $reconfig_fromgxb_width;"

}
