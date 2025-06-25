# ###########################################################################
#
#    This script compiles the exmaple_instance and associated testbench
#    that matches the DDR_SDRAM MegaCore that you have just configured
#
#    It would be wise not to change this file as it will be copied back
#    next time you run the MegaWizard.
#
# ###########################################################################


# ###########################################################################
#
#   THIS SCRIPT MUST BE RUN FROM WITHIN MODELSIM !!!!
#
# ###########################################################################

# For the library mapping, we assume that the environment variable DDR_SDRAM_ROOTDIR is set properly.
# Please ensure it is pointing to the correct version of the MegaCore

#>>>>> START MEGAWIZARD INSERT VARIABLES
    set ddr_sdram_megacore_rootdir $env(DDR_SDRAM_ROOTDIR)
    set wrapper_name mw_wrapper
    set toplevel_name example_instance
    set testbench_name example_instance_tb
    set family_name stratix
    set language "VHDL"
    set tb_language "VHDL"
    set fed_back_clock_mode "0"
#>>>>> END MEGAWIZARD INSERT VARIABLES






# remember the directory were we start the script, assumming it will be the
# base directory for the modelsim simulation

    set current_dir [pwd]

    # Set onerror behaviour for batch mode
    if {[info exists auk_batch_mode]} {
        onerror {quit -f}
        onbreak resume
    }

    # TCL is case-sensitive, so set the case of the variables which are compared against strings!
    if {[info exists family_name]} {              set family_name                 [string tolower $family_name]}
    if {[info exists fed_back_clock_mode]} {      set fed_back_clock_mode         [string tolower $fed_back_clock_mode]}
    if {[info exists use_generic_memory_model]} { set use_generic_memory_model    [string toupper $use_generic_memory_model]}
    if {[info exists language]} {                 set language                    [string toupper $language]}


    # Check if we are running in Modelsim Altera Edition
    set modelsim_ae 0
    if {[vsimAuth] == "ALTERA"} {set modelsim_ae 1}


    # Set IPFS model as the default simulation model, based on whether gate has been set.
    if {![info exists use_gate_model]} {
        set use_gate_model 0
    }

    if {![info exists use_simgen_model]} {

        # default case is simgen
        if {($use_gate_model == 0)} {
            set use_simgen_model 1
        } else {
            set use_simgen_model 0
        }
    }


    if {![info exists tb_language]} {
        set tb_language [string toupper $language]
    }

    if {![info exists fed_back_clock_mode]} {
        set fed_back_clock_mode "0"
    }


    if {$use_simgen_model == 0 && $use_gate_model == 0} {
            puts "\n"
            puts "***************************************************************************"
            puts "***************************************************************************"
            puts "You must select either Simgen or Gate level Simulation.                    "
            puts "Please follow the instructions in the user guide.                          "
            puts "Run 'set use_simgen_model 1' or 'set use_gate_model 1'command, before "
            puts "re-running scipt"
            puts "***************************************************************************"
            puts "***************************************************************************"
#            abort
    }

    if {![info exists use_generic_memory_model]} {
        set use_generic_memory_model FALSE
    }

    if {![info exists memory_model]} {
        set memory_model NO_MEMORY_MODEL
    }

    if {![info exists use_waves]} {
        set use_waves 1
    }


set pll_family $family_name

# Fix Stratix GX library name
if {$family_name == "stratix gx"} { set family_name "stratixgx"; set pll_family "stratix" }
# Fix Stratix II library name
if {$family_name == "stratix ii"} { set family_name "stratixii"; set pll_family "stratixii" }
# Fix Stratix II GX library name
if {$family_name == "stratix ii gx"} { set family_name "stratixiigx"; set pll_family "stratixii" }
# Fix Hardcopy II library name
if {$family_name == "hardcopy ii"} { set family_name "hardcopyii"; set pll_family "stratixii" }
# Fix Cyclone II library name
if {$family_name == "cyclone ii"} { set family_name "cycloneii"; set pll_family "cycloneii" }

#Stratix GX uses stratix
set sim_family_name $family_name
if {$use_gate_model == 0} {
    if {$family_name == "stratixgx"} {
        set sim_family_name "stratix"
    }
    if {$family_name == "stratixiigx"} {
        set sim_family_name "stratixii"
    }
    if {$family_name == "hardcopyii"} {
        set sim_family_name "stratixii"
    }
}


# Creating and mapping the libraries
    vlib auk_ddr_user_lib
    vmap auk_ddr_user_lib auk_ddr_user_lib


#   ***** NOTE we also need to compile altera_mf if it doesn't already exist *****
    if {$modelsim_ae==0} {
        if {$language == "VHDL"} {
            vlib altera_mf
            vmap altera_mf altera_mf
            vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf_components.vhd
            vcom -93 -work altera_mf $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.vhd
        } else {
            vlib altera_mf_ver
            vmap altera_mf_ver altera_mf_ver
            vlog -work altera_mf_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v
        }
    }

#   ***** NOTE we also need to compile lpm & sgate if we are using simgen models *****
    if {$use_simgen_model && ($modelsim_ae==0)} {
        # At the moment we always need the VHDL version of this - CHECK LATER!!
        vlib lpm
        vmap lpm lpm
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220pack.vhd
        vcom -93 -work lpm $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.vhd


        if {$language == "VHDL"} {
            vlib sgate
            vmap sgate sgate
            vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate_pack.vhd
            vcom -93 -work sgate $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.vhd
        } else {
            vlib lpm_ver
            vmap lpm_ver lpm_ver
            vlog -work lpm_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v

            vlib sgate_ver
            vmap sgate_ver sgate_ver
            vlog -work sgate_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v
        }

    }

    if {($modelsim_ae==0)} {
        # We need these atoms for RTL simulation as well as gate for WYSIWYG models (DLL etc)
        if {$language == "VHDL"} {
            vlib ${sim_family_name}
            vmap ${sim_family_name} ${sim_family_name}
            vcom -93 -work $sim_family_name $env(QUARTUS_ROOTDIR)/eda/sim_lib/${sim_family_name}_atoms.vhd
            vcom -93 -work $sim_family_name $env(QUARTUS_ROOTDIR)/eda/sim_lib/${sim_family_name}_components.vhd
        } else {
            vlib ${sim_family_name}_ver
            vmap ${sim_family_name}_ver ${sim_family_name}_ver
            vlog -work ${sim_family_name}_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/${sim_family_name}_atoms.v
        }

    }

    if {$language == "VHDL"} {
        vlib altera
        vmap altera altera
        vcom -93 -work altera $env(QUARTUS_ROOTDIR)/libraries/vhdl/altera/altera_europa_support_lib.vhd
    }


# compiling the various files for the
    # resetting the list
    set vhdl_file_list ""
    set verilog_file_list ""

    if {$language == "VHDL"} {
        set hdl_file_ext .vhd
    } else {
        set hdl_file_ext .v
    }

    if {$language == "VHDL"} {
        # adding files located in the testbench directory
        lappend vhdl_file_list $ddr_sdram_megacore_rootdir/lib/auk_ddr_tb_functions.vhd
    }

    if {$use_generic_memory_model == "TRUE"} {
        lappend vhdl_file_list ../generic_ddr_sdram_denali.vhd
        lappend vhdl_file_list ../generic_ddr_sdram_rtl.vhd
        lappend vhdl_file_list ../generic_ddr2_sdram_denali.vhd
        lappend verilog_file_list ../generic_ddr2_sdram_rtl.v
    } else {
        if {$memory_model == "NO_MEMORY_MODEL"} {
            puts "\n"
            puts "***************************************************************************"
            puts "***************************************************************************"
            puts "No memory model selected.  Simulation will not be successful."
            puts "Please download a memory model and place in the testbench directory."
            puts "Edit the testbench/generic_ddr_sdram.vhd file as necessary"
            puts "Run 'set memory_model <memory_model_name>' command, before re-running scipt"
            puts "***************************************************************************"
            puts "***************************************************************************"
            abort
        } else {
            if {$language == "VHDL"} {
                lappend vhdl_file_list ../${memory_model}${hdl_file_ext}
            } else {
                lappend verilog_file_list ../${memory_model}${hdl_file_ext}
            }
        }
    }

    if {$tb_language == "VHDL"} {
        lappend vhdl_file_list ../generic_ddr_sdram.vhd
        lappend vhdl_file_list ../generic_ddr2_sdram.vhd
        lappend vhdl_file_list ../generic_ddr_dimm_model.vhd
    }

    if {$use_gate_model} {
        if {$language == "VHDL"} {
            if {[file exists ../../simulation/modelsim/$toplevel_name.vho]} {
                set gate_model_suffix ""
            } else {
                set gate_model_suffix "_min"
            }
            lappend vhdl_file_list ../../simulation/modelsim/${toplevel_name}${gate_model_suffix}.vho
        } else {
            if {[file exists ../../simulation/modelsim/$toplevel_name.vo]} {
                set gate_model_suffix ""
            } else {
                set gate_model_suffix "_min"
            }
           lappend verilog_file_list ../../simulation/modelsim/${toplevel_name}${gate_model_suffix}.vo
            #vlog -work auk_ddr_user_lib ../../simulation/modelsim/$toplevel_name.vo
        }
    } else {
        if {$language == "VHDL"} {
            lappend vhdl_file_list ../../${wrapper_name}_auk_ddr_dqs_group.vhd
            lappend vhdl_file_list ../../${wrapper_name}_auk_ddr_clk_gen.vhd
            lappend vhdl_file_list ../../${wrapper_name}_auk_ddr_datapath.vhd
            lappend vhdl_file_list ../../${wrapper_name}_auk_ddr_datapath_pack.vhd
            lappend vhdl_file_list ../../$wrapper_name.vho

            lappend vhdl_file_list $ddr_sdram_megacore_rootdir/lib/example_lfsr8.vhd
            lappend vhdl_file_list ../../${wrapper_name}_example_driver.vhd
            lappend vhdl_file_list ../../ddr_pll_${pll_family}.vhd
            if {$fed_back_clock_mode == "1"} {
                lappend vhdl_file_list ../../ddr_pll_fb_${pll_family}.vhd
            }
            if {($sim_family_name == "stratix") || ($sim_family_name == "stratixii")} {
                lappend vhdl_file_list ../../${wrapper_name}_auk_ddr_dll.vhd
            }
            lappend vhdl_file_list ../../$toplevel_name.vhd
        } else {
            lappend verilog_file_list ../../${wrapper_name}_auk_ddr_dqs_group.v
            lappend verilog_file_list ../../${wrapper_name}_auk_ddr_clk_gen.v
            lappend verilog_file_list ../../${wrapper_name}_auk_ddr_datapath.v
            lappend verilog_file_list ../../${wrapper_name}.vo
            lappend verilog_file_list $ddr_sdram_megacore_rootdir/lib/example_lfsr8.v
            lappend verilog_file_list ../../${wrapper_name}_example_driver.v
            lappend verilog_file_list ../../ddr_pll_${pll_family}.v
            if {$fed_back_clock_mode == "1"} {
                lappend verilog_file_list ../../ddr_pll_fb_${pll_family}.v
            }
            if {($sim_family_name == "stratix") || ($sim_family_name == "stratixii")} {
                lappend verilog_file_list ../../${wrapper_name}_auk_ddr_dll.v
            }

            lappend verilog_file_list ../../$toplevel_name.v
        }


    }

    if {$tb_language == "VHDL"} {
        lappend vhdl_file_list ../$testbench_name.vhd
    } else {
        lappend verilog_file_list ../$testbench_name.v
    }


    # compile the files, verilog first!
    foreach i $verilog_file_list {
        puts "vlog -work auk_ddr_user_lib $i"
        vlog -work auk_ddr_user_lib $i
    }
    foreach i $vhdl_file_list {
        puts "vcom -93 -work auk_ddr_user_lib $i"
        vcom -93 -work auk_ddr_user_lib $i
    }



# simulate the system
    if {$use_gate_model} {
        if {$language == "VHDL"} {
#           vsim -t ps -gUSE_GENERIC_MEMORY_MODEL=$use_generic_memory_model -gRTL_DELAYS=0 -gRTL_ROUNDTRIP_CLOCKS=0.0 -sdftyp /${testbench_name}/dut=../../simulation/modelsim/${toplevel_name}_vhd.sdo auk_ddr_user_lib.${testbench_name}
            vsim -t ps -gUSE_GENERIC_MEMORY_MODEL=$use_generic_memory_model -gRTL_DELAYS=0 -sdftyp /${testbench_name}/dut=../../simulation/modelsim/${toplevel_name}_vhd${gate_model_suffix}.sdo auk_ddr_user_lib.${testbench_name}
        } else {
            file copy -force ../../simulation/modelsim/${toplevel_name}_v${gate_model_suffix}.sdo ${toplevel_name}_v${gate_model_suffix}.sdo
#           vsim -t ps +transport_path_delays +transport_int_delays -gUSE_GENERIC_MEMORY_MODEL=$use_generic_memory_model -gRTL_DQSDELAY=0 -gRTL_ROUNDTRIP_CLOCKS=0.0 -L ${sim_family_name}_ver auk_ddr_user_lib.${testbench_name}
            vsim -t ps +transport_path_delays +transport_int_delays -gRTL_DELAYS=0 -L ${sim_family_name}_ver auk_ddr_user_lib.${testbench_name}
        }

        # Turn off IEEE library warnings
        set NumericStdNoWarnings 1
        set StdArithNoWarnings 1
        if {$use_waves} {do wave.do}
        run -all
    } else {
        if {$language == "VHDL"} {
            vsim -t ps -gUSE_GENERIC_MEMORY_MODEL=$use_generic_memory_model -gRTL_DELAYS=1 auk_ddr_user_lib.${testbench_name}
        } else {
            vsim -t ps -gRTL_DELAYS=1 -L sgate_ver -L lpm_ver -L altera_mf_ver -L ${sim_family_name}_ver auk_ddr_user_lib.${testbench_name}
        }

        # Turn off IEEE library warnings
        set NumericStdNoWarnings 1
        set StdArithNoWarnings 1
        if {$use_waves} {do wave.do}
        run -all
    }
