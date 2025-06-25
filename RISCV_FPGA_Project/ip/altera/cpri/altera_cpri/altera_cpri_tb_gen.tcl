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


# Package declaration
package require altera_tcl_testlib 1.0
package require -exact altera_terp 1.0

add_fileset testbench EXAMPLE_DESIGN testbench_proc

# +-------------------------------------------------------------------
# | 1) Create all the necessary simulation file - do files and tb 
# | 2) Create the tcl file with ip-generate command
# | 3) Create the qsf/qpf 
# +-------------------------------------------------------------------

proc testbench_proc { name } {
	 set linerate               [get_parameter_value LINERATE]
    set mac__off               [get_parameter_value MACOFF]
    set autorate               [get_parameter_value AUTORATE]
    set N_MAP                  [get_parameter_value N_MAP]
    set sync_mode              [get_parameter_value SYNC_MODE]
    set device                 [get_parameter_value DEVICEFAMILY]
    set entityname             "altera_cpri"

   send_message info "EntityName is $entityname"
   send_message info "Generating customer testbench.."

   # Autorate example design files generation
   autoratefile_generator

   # Testbench do file generation
   dofile_generator $entityname $device
   
   # IPFS verilog model generation
   set verilog_run_script_file "../altera_cpri_testbench/generate_sim_verilog.tcl"
   set verilog_output_run_script_file [create_temp_file generate_sim_verilog.tcl]
   set out [open $verilog_output_run_script_file w]
   set in [open $verilog_run_script_file r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line

         puts $out "set variant_name $entityname"
         puts $out "set dut_device_family \"$device\""

         foreach {param_name} [get_parameters] {
            set is_derived_param [get_parameter_property $param_name DERIVED]
            set param_value [get_parameter_value $param_name]
            # Exceptional case
            # Obtain the non-derived type of parameter
            # Skip the device name
            if {[get_parameter_property $param_name DERIVED]} {
               continue
            } elseif {[expr {"$param_name" == "DEVICEFAMILY"}]} {
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

 # IPFS vhdl model generation
   set vhdl_run_script_file "../altera_cpri_testbench/generate_sim_vhdl.tcl"
   set vhdl_output_run_script_file [create_temp_file generate_sim_vhdl.tcl]
   set out [open $vhdl_output_run_script_file w]
   set in [open $vhdl_run_script_file r]

   while {[gets $in line] != -1} {
      if {[string match "*RUN_SCRIPT_PARAMETERS*" $line]} {
         puts $out $line

         puts $out "set variant_name $entityname"
         puts $out "set dut_device_family \"$device\""

         foreach {param_name} [get_parameters] {
            set is_derived_param [get_parameter_property $param_name DERIVED]
            set param_value [get_parameter_value $param_name]
            # Exceptional case
            # Obtain the non-derived type of parameter
            # Skip the device name
            if {[get_parameter_property $param_name DERIVED]} {
               continue
            } elseif {[expr {"$param_name" == "DEVICEFAMILY"}]} {
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

# ------------------------------------
# This proc do the following tasks:
# 1) Generate generate_sim.qpf
# 2) Generate generate_sim.qsf
# -----------------------------------
proc generate_quartus_files {} {
   set deviceFamilyName [get_parameter_value DEVICEFAMILY]
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

# ------------------------------------------------------------------
# This proc do the following tasks:
# - 1) Create testbench run script
# - 2) Create waveform file
# - 3) Create testbench using terp
# -----------------------------------------------------------------
proc dofile_generator { entityname device } {

   global testbench_api_files

   #send_message info "$device"

   # Verilog testbench files
   foreach {output_file source_file} $testbench_api_files {
      add_fileset_file cpri_testbench/$output_file SYSTEM_VERILOG PATH $source_file {MENTOR_SPECIFIC}
   }

   # - ---------------------------------------------------
   # - Step 1: Creates testbench run script
   # - Supported simulator - aldec,mentor,synopsys,cadence 
   # ------------------------------------------------------
   set supported_simulators {"mentor" "synopsys" "aldec" "cadence"} 
   foreach simulator $supported_simulators {
      # mentor & aldec support
   if {$simulator == "mentor" || $simulator == "aldec"} {
   # ----------------
   # Aldec and Mentor
   # ----------------
   set run_script "../altera_cpri_testbench/testbench/$simulator\_compile.tcl"
   set run_script_output_file [create_temp_file compile.tcl]
   set out [ open $run_script_output_file w ]
   set in [open $run_script r]

   while {[gets $in line] != -1} {
      if {[string match "*VARIABLE_DECLARATION*" $line]} {
         puts $out $line
         if {[string match $device "Cyclone IV GX"]} {
            puts $out "set sim \$1" 
         }
         puts $out "set QSYS_SIMDIR ../$entityname\_sim"
         puts $out "set dut_wave_do wave.do"
         puts $out "set testbench_model_dir ../models/cpri_api"
      } elseif {[string match "*TESTBENCH_COMPILE*" $line]} {
         puts $out "# Compile the api and tb files"
         puts $out "vlog -work work +incdir+\$testbench_model_dir \$testbench_model_dir/*.sv"
         puts $out "vlog -work work ../tb.sv"
         puts $out " "
         puts $out "# Elaborate the testbench"
         puts $out "elab_debug -t fs"
      } else {
         puts $out $line
      }
   }

   close $in
   close $out
   
   add_fileset_file cpri_testbench/$simulator\_sim/compile.tcl OTHER PATH $run_script_output_file

 } elseif { $simulator == "synopsys" } { 
   # -----------
   #  Synopsys
   # -----------
   set compile_sh "../altera_cpri_testbench/testbench/$simulator\_compile.sh"
   set compile_sh_output_file [create_temp_file compile.sh]
   set out [open $compile_sh_output_file w]
   set in [open $compile_sh r]
   
   while {[gets $in line] != -1} {
      if {[string match "*VARIABLE_DECLARATION*" $line]} {
         puts $out $line
         puts $out "CPRI_DIR=\"../$entityname\_sim/synopsys/vcsmx/vcsmx_setup.sh\""
         puts $out "TB_DIR=\"../models/cpri_api\""
      } elseif {[string match "*SOURCE_SCRIPTS*" $line]} {
         puts $out "cp ../altera_cpri_sim/synopsys/vcsmx/synopsys_sim.setup ."
         puts $out ". \$CPRI_DIR QSYS_SIMDIR=\"../$entityname\_sim/\" SKIP_ELAB=1 SKIP_SIM=1"
      } elseif {[string match "*TESTBENCH_COMPILE*" $line]} {
         puts $out "vlogan -sverilog -work work \$TB_DIR/*.sv"
         puts $out "vlogan -sverilog -work work ../tb.sv"
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   add_fileset_file cpri_testbench/synopsys_sim/compile.sh OTHER PATH $compile_sh_output_file {SYNOPSYS_SPECIFIC}
    
 } elseif { $simulator == "cadence" } {
   # ---------
   #  Cadence
   # ---------
   set compile_cadence_sh "../altera_cpri_testbench/testbench/$simulator\_compile.sh"
   set compile_cadence_sh_output_file [create_temp_file compile_cadence.sh]
   set out [open $compile_cadence_sh_output_file w]
   set in [open $compile_cadence_sh r]
   
   while {[gets $in line] != -1} {
      if {[string match "*VARIABLE_DECLARATION*" $line]} {
         puts $out $line
         puts $out "CPRI_DIR=\"../$entityname\_sim/cadence/ncsim_setup.sh\""
         puts $out "TB_DIR=\"../models/cpri_api\"" 
      } elseif {[string match "*SOURCE_SCRIPTS*" $line]} {
         puts $out "cp -rf ../altera_cpri_sim/$simulator/hdl.var ."
         puts $out "cp -rf ../altera_cpri_sim/$simulator/cds.lib ."
         puts $out ". \$CPRI_DIR QSYS_SIMDIR=\"../$entityname\_sim/\" SKIP_ELAB=1 SKIP_SIM=1"
      } elseif {[string match "*TESTBENCH_COMPILE*" $line]} {
         puts $out "ncvlog -sv -work work \$TB_DIR/*.sv"
         puts $out "ncvlog -sv -work work ../tb.sv"
      } else {
         puts $out $line
      }
   }
   close $in
   close $out
   
   add_fileset_file cpri_testbench/cadence_sim/compile.sh OTHER PATH $compile_cadence_sh_output_file {CADENCE_SPECIFIC}
}
}
     
   # --------------------------------
   # Step 2 : Create Waveform file
   # --------------------------------
   set wave_do "../altera_cpri_testbench/testbench/wave.do"
   set wave_do_output_file [create_temp_file $entityname\_wave.do]
   set out [open $wave_do_output_file w]
   set in  [open $wave_do r]

   while {[gets $in line] != -1} {
      puts $out $line
   }

   close $in
   close $out

   set wave_tcl "../altera_cpri_testbench/testbench/wave.tcl"
   set ucli_do  "../altera_cpri_testbench/testbench/ucli.do" 

   # Support for different simulator
   add_fileset_file cpri_testbench/mentor_sim/wave.do OTHER PATH $wave_do_output_file {MENTOR_SPECIFIC}
   add_fileset_file cpri_testbench/aldec_sim/wave.do OTHER PATH $wave_do_output_file {ALDEC_SPECIFIC}
   add_fileset_file cpri_testbench/cadence_sim/wave.tcl OTHER PATH $wave_tcl {CADENCE_SPECIFIC}
   add_fileset_file cpri_testbench/synopsys_sim/ucli.do OTHER PATH $ucli_do {SYNOPSYS_SPECIFIC}

  # ----------------------------
  # Step 3: Testbench generation
  # ----------------------------
  testbench_top $entityname

}

proc testbench_top { entityname } {
  
  global env
  set qdir $env(QUARTUS_ROOTDIR)
  set topdir "${qdir}/../ip/altera/cpri/altera_cpri_testbench/testbench"
  set clkdir "${qdir}/../ip/altera/cpri/altera_cpri_testbench/cpri_api" 
  set linerate               [get_parameter_value LINERATE]
  set mac_off                [get_parameter_value MAC_OFF]
  set autorate               [get_parameter_value AUTORATE]
  set n_map                  [get_parameter_value N_MAP]
  set sync_mode              [get_parameter_value SYNC_MODE]
  set map_mode               [get_parameter_value MAP_MODE]
  set sync_map               [get_parameter_value SYNC_MAP]
  set vss_off                [get_parameter_value VSS_OFF]
  set device                 [get_parameter_value DEVICE]
  set xcvr_freq              [get_parameter_value XCVR_FREQ]
  set hdlc                   [get_parameter_value HDLC_OFF]

# Collect and store user input into an array
set params(linerate) $linerate
set params(mac_off) $mac_off
set params(autorate) $autorate
set params(n_map) $n_map
set params(sync_mode) $sync_mode
set params(map_mode) $map_mode
set params(sync_map) $sync_map
set params(vss_off) $vss_off
set params(device) $device
set params(xcvr_freq) $xcvr_freq
set params(hdlc) $hdlc

# Pass in the user parameters into testbench in terp
set template_file [file join $topdir "tb.sv.terp"]
set template [ read [ open $template_file r ] ]
set result  [ altera_terp $template params ]

set clk_template_file [file join $clkdir "cpri_clk_gen.sv.terp"]
set clk_template [ read [ open $clk_template_file r ] ]
set clk_result [ altera_terp $clk_template params ]

# Add newly generated testbench file into simulation folder
add_fileset_file cpri_testbench/tb.sv SYSTEM_VERILOG TEXT $result {MENTOR_SPECIFIC}
add_fileset_file cpri_testbench/models/cpri_api/cpri_clk_gen.sv SYSTEM_VERILOG TEXT $clk_result {MENTOR_SPECIFIC}
}

proc autoratefile_generator { } {
   
   set linerate               [get_parameter_value LINERATE]
   set mac__off               [get_parameter_value MACOFF]
   set autorate               [get_parameter_value AUTORATE]
   set N_MAP                  [get_parameter_value N_MAP]
   set sync_mode              [get_parameter_value SYNC_MODE]
   set device                 [get_parameter_value DEVICE]

if {$sync_mode ==0} {
   if {$autorate == 1} {
      # Mentor support
      add_fileset_file ./autorate_design/mentor/compile.tcl OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/compile_autorate.tcl
                  
      # Aldec support
      add_fileset_file ./autorate_design/aldec/compile.tcl OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/compile_autorate.tcl
                   
      # Cadence support
      add_fileset_file ./autorate_design/cadence/compile.sh  OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/compile_autorate_cadence.sh
      add_fileset_file ./autorate_design/cadence/wave.tcl    OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave.tcl

      # Synopsys support
      add_fileset_file ./autorate_design/synopsys/compile.sh OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/compile_autorate.sh
      add_fileset_file ./autorate_design/synopsys/ucli.do    OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/ucli.do
         
      if {$N_MAP ==0 && $mac__off == "true"} {
         if {$device < 3} { 
            send_message info "Generating tb_altera_cpri_autorate...."
            add_fileset_file ./autorate_design/tb.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/tb_altera_cpri_autorate.vhd
            add_fileset_file ./autorate_design/altgx_reconfig_cpri.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/altgx_reconfig_cpri.vhd
            add_fileset_file ./autorate_design/rom.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix4gx.vhd
                  
            add_fileset_file ./autorate_design/altgx_reconfig_cpri.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/altgx_reconfig_cpri.v
            add_fileset_file ./autorate_design/rom.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix4gx.v
                  
            # Mentor support
            add_fileset_file ./autorate_design/mentor/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_autorate.do
                  
            # Aldec support
            add_fileset_file ./autorate_design/aldec/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_autorate.do
         
         } elseif {$device == 3 } {
            send_message info "Generating tb_altera_cpri_c4gx_autorate...."
            add_fileset_file ./autorate_design/tb.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/tb_altera_cpri_c4gx_autorate.vhd
            add_fileset_file ./autorate_design/altgx_c4gx_reconfig_cpri.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/altgx_c4gx_reconfig_cpri.vhd
            add_fileset_file ./autorate_design/altpll_c4gx_reconfig_cpri.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/altpll_c4gx_reconfig_cpri.vhd
            add_fileset_file ./autorate_design/rom_pll.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/rom_cyclone4gx_pll.vhd
            add_fileset_file ./autorate_design/rom.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/rom_cyclone4gx.vhd
                  
            add_fileset_file ./autorate_design/altgx_c4gx_reconfig_cpri.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/altgx_c4gx_reconfig_cpri.v
            add_fileset_file ./autorate_design/altpll_c4gx_reconfig_cpri.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/altpll_c4gx_reconfig_cpri.v
            add_fileset_file ./autorate_design/rom_pll.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/rom_cyclone4gx_pll.v
            add_fileset_file ./autorate_design/rom.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/rom_cyclone4gx.v
                  
            # Mentor support
            add_fileset_file ./autorate_design/mentor/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_c4gx_autorate.do

            # Aldec support
            add_fileset_file ./autorate_design/aldec/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_c4gx_autorate.do
         
         } else {
            if {$device == 5 && $linerate == 5 } {
               # AVGT support for 9.8304G auto-negotiation
               send_message info "Generating tb_altera_cpri_autorate_98G_phy...."
               add_fileset_file ./autorate_design/tb.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/tb_altera_cpri_autorate_98G_phy.vhd                     
               add_fileset_file ./autorate_design/cpri_reconfig_controller.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/cpri_reconfig_controller.vhd
               add_fileset_file ./autorate_design/clock_switch.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/clock_switch.vhd
               add_fileset_file ./autorate_design/rom.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix5.vhd
               add_fileset_file ./autorate_design/rom.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix5.v

               # Mentor support
               add_fileset_file ./autorate_design/mentor/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_98G_phy_autorate.do
                     
               # Aldec support
               add_fileset_file ./autorate_design/aldec/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_98G_phy_autorate.do
            } else {
               send_message info "Generating tb_altera_cpri_autorate_phy...."
               add_fileset_file ./autorate_design/tb.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/tb_altera_cpri_autorate_phy.vhd                     
               add_fileset_file ./autorate_design/cpri_reconfig_controller.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/cpri_reconfig_controller.vhd
               add_fileset_file ./autorate_design/rom.vhd VHDL PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix5.vhd
               add_fileset_file ./autorate_design/rom.v VERILOG PATH ../altera_cpri_testbench/autorate_example_testbench/rom_stratix5.v
                     
               # Mentor support
               add_fileset_file ./autorate_design/mentor/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_phy_autorate.do
                     
               # Aldec support
               add_fileset_file ./autorate_design/aldec/wave.do OTHER PATH ../altera_cpri_testbench/autorate_example_testbench/wave_phy_autorate.do
            }
         }
      } else {
         send_message info "Autorate-negotiation customer testbench will only be generated if the number of antenna carrier is 0 and MAC block is enabled."
      }
   }   
} else {
   send_message info "No customer demo testbench will be generated if it is in slave mode."
}
}
