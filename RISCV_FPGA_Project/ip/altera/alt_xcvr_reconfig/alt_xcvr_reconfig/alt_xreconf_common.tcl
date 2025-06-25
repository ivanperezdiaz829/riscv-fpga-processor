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


#
# Common functions for dynamic transceiver reconfiguration components
#
if { [lsearch $auto_path $::env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages ] == -1 } {
  lappend auto_path $::env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
}
package require alt_xcvr::utils::ipgen
package require alt_xcvr::utils::fileset

proc xreconf_decl_fileset_groups { xreconf_root } {

	# common packages from altera_xcvr_generic library
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/" {
		altera_xcvr_functions.sv
	} {ALL_HDL}
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/sv/" {
		sv_xcvr_h.sv
	} {S5_RECONF}
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/av/" {
		av_xcvr_h.sv
	} {A5_RECONF C5_RECONF}
  common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/ctrl/" {
		alt_xcvr_resync.sv
	} {S5_RECONF A5_RECONF C5_RECONF}
	common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" {
		alt_xcvr_reconfig_h.sv
	} {S4 ALL_RECONF}
        common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dfe/" {
		sv_xcvr_dfe_cal_sweep_h.sv
	} {S5_RECONF}

	# reconfig top component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xcvr_reconfig.sv {S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xcvr_reconfig_sv.sv {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xcvr_reconfig_cal_seq.sv {S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xcvr_reconfig_siv.sv {S4}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xcvr_reconfig_civ.sv {C4}

    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xreconf_cif.sv {S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xreconf_uif.sv {S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig/" alt_xreconf_basic_acq.sv {S5_RECONF A5_RECONF C5_RECONF}

	# reconfig analog component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xcvr_reconfig_analog.sv {S4 S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xcvr_reconfig_analog_sv.sv {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xcvr_reconfig_analog_av.sv {A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xreconf_analog_datactrl.sv {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xreconf_analog_datactrl_av.sv {A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xreconf_analog_rmw.sv {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xreconf_analog_rmw_av.sv {A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xreconf_analog_ctrlsm.sv {S5_RECONF A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_analog/" alt_xcvr_reconfig_analog_tgx.v {S4}

	# reconfig offset cancellation component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation.sv {S4 ALL_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation_sv.sv {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation_av.sv {A5_RECONF C5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation_tgx.v {S4}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation_civ.v {C4}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_offset_cancellation/" alt_xcvr_reconfig_offset_cancellation_tgx_civ.v {C4}

	
	# reconfig eyemon component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_eyemon/" {
    	alt_xcvr_reconfig_eyemon.sv
    } {ALL_RECONF}

	# reconfig eyemon component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_eyemon/" {
    	alt_xcvr_reconfig_eyemon_tgx.sv
    } {S4}

        # reconfig eyemon component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_eyemon/" {
    	alt_xcvr_reconfig_eyemon_sv.sv
        alt_xcvr_reconfig_eyemon_ctrl_sv.sv
        alt_xcvr_reconfig_eyemon_ber_sv.sv
        ber_reader_dcfifo.v
        step_to_mon_sv.sv
        mon_to_step_sv.sv
    } {S5_RECONF}

        # Synchronizer for the BER counter
    common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/ctrl/" {
        alt_xcvr_resync.sv
    } {S5_RECONF}


        # reconfig dfe component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dfe/" {
    	alt_xcvr_reconfig_dfe.sv
    } {ALL_RECONF}

	# reconfig dfe component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dfe/" {
    	alt_xcvr_reconfig_dfe_tgx.sv
    } {S4}

        # reconfig dfe component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dfe/" {
        alt_xcvr_reconfig_dfe.sv 
    	alt_xcvr_reconfig_dfe_sv.sv
        alt_xcvr_reconfig_dfe_reg_sv.sv
        alt_xcvr_reconfig_dfe_cal_sv.sv
        alt_xcvr_reconfig_dfe_reg_sv.sv 
        alt_xcvr_reconfig_dfe_cal_sv.sv 
        alt_xcvr_reconfig_dfe_cal_sweep_sv.sv 
        alt_xcvr_reconfig_dfe_cal_sweep_datapath_sv.sv 
        alt_xcvr_reconfig_dfe_oc_cal_sv.sv
        alt_xcvr_reconfig_dfe_pi_phase_sv.sv 
        alt_xcvr_reconfig_dfe_step_to_mon_en_sv.sv
        alt_xcvr_reconfig_dfe_adapt_tap_sv.sv  
        alt_xcvr_reconfig_dfe_ctrl_mux_sv.sv 
        alt_xcvr_reconfig_dfe_local_reset_sv.sv
        alt_xcvr_reconfig_dfe_cal_sim_sv.sv
        alt_xcvr_reconfig_dfe_adapt_tap_sim_sv.sv  
    } {S5_RECONF}


	# reconfig adce component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_adce/" {
    	alt_xcvr_reconfig_adce.sv
    } {ALL_RECONF}

        # reconfig adce component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_adce/" {
    	alt_xcvr_reconfig_adce_sv.sv
	alt_xcvr_reconfig_adce_datactrl_sv.sv
    } {S5_RECONF}

        # reconfig dcd component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dcd/" {
    	alt_xcvr_reconfig_dcd.sv
    } {ALL_RECONF}

        # reconfig dcd component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dcd/" {
    	alt_xcvr_reconfig_dcd.sv
        alt_xcvr_reconfig_dcd_sv.sv
        alt_xcvr_reconfig_dcd_cal.sv
        alt_xcvr_reconfig_dcd_control.sv
        alt_xcvr_reconfig_dcd_datapath.sv
        alt_xcvr_reconfig_dcd_pll_reset.sv
        alt_xcvr_reconfig_dcd_eye_width.sv
        alt_xcvr_reconfig_dcd_align_clk.sv
        alt_xcvr_reconfig_dcd_get_sum.sv
        alt_xcvr_reconfig_dcd_cal_sim_model.sv
    } {S5_RECONF}
	
	    # reconfig dcd component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_dcd/" {
    	alt_xcvr_reconfig_dcd.sv
        alt_xcvr_reconfig_dcd_av.sv
        alt_xcvr_reconfig_dcd_cal_av.sv
        alt_xcvr_reconfig_dcd_control_av.sv
    } {A5_RECONF C5_RECONF}

    # reconfig MIF component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_mif/" {
        alt_xcvr_reconfig_mif.sv
    } {ALL_RECONF}

    # reconfig MIF component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_mif/" {
      sv_xcvr_reconfig_mif.sv
      sv_xcvr_reconfig_mif_ctrl.sv
      sv_xcvr_reconfig_mif_avmm.sv
    } {S5_RECONF}
    
    # reconfig MIF component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_mif/" {
      av_xcvr_reconfig_mif.sv
      av_xcvr_reconfig_mif_ctrl.sv
      av_xcvr_reconfig_mif_avmm.sv
    } {A5_RECONF C5_RECONF}

    # reconfig PLL component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_pll/" {
        alt_xcvr_reconfig_pll.sv
    } {ALL_RECONF}

    # reconfig PLL component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_pll/" {
      sv_xcvr_reconfig_pll.sv
      sv_xcvr_reconfig_pll_ctrl.sv
    } {S5_RECONF}
    
    # reconfig PLL component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_pll/" {
      av_xcvr_reconfig_pll.sv
      av_xcvr_reconfig_pll_ctrl.sv
    } {A5_RECONF C5_RECONF}

    # reconfig soc component (CPU)
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_soc/" {
      alt_xcvr_reconfig_soc.sv
      alt_xcvr_reconfig_cpu_ram.sv
    } {S5_RECONF_SOC A5_RECONF_SOC C5_RECONF_SOC}

    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_soc/software/alt_xcvr_reconfig/mem_init/" {
      alt_xcvr_reconfig_cpu_ram.hex
    } {S5_RECONF_SOC}

    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_soc/software/alt_xcvr_reconfig_av/mem_init/" {
      alt_xcvr_reconfig_cpu_ram.hex
    } {A5_RECONF_SOC C5_RECONF_SOC}

	# direct-access (a.k.a. 'raw')
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_direct/" {
    	alt_xcvr_reconfig_direct.sv
    } {S5_RECONF A5_RECONF C5_RECONF}

	# reconfig basic component
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_basic/" {
    	alt_xcvr_reconfig_basic_tgx.v
    	alt_mutex_acq.v
    	alt_dprio.v
    } {S4 C4}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_basic/" {
		sv_xrbasic_l2p_addr.sv
		sv_xrbasic_l2p_ch.sv
        sv_xrbasic_l2p_rom.sv
		sv_xrbasic_lif_csr.sv
		sv_xrbasic_lif.sv
		sv_xcvr_reconfig_basic.sv
		alt_arbiter_acq.sv
		alt_xcvr_reconfig_basic.sv
    } {S5_RECONF}
    common_fileset_group_plain ./ "$xreconf_root/alt_xcvr_reconfig_basic/" {
		av_xrbasic_l2p_addr.sv
		av_xrbasic_l2p_ch.sv
        av_xrbasic_l2p_rom.sv
		av_xrbasic_lif_csr.sv
		av_xrbasic_lif.sv
		av_xcvr_reconfig_basic.sv
		alt_arbiter_acq.sv
		alt_xcvr_reconfig_basic.sv
    } {A5_RECONF C5_RECONF}

	# SDC file
	common_fileset_group ./ "$xreconf_root/alt_xcvr_reconfig/" OTHER {
		alt_xcvr_reconfig.sdc
        } {S5_RECONF} {QIP}

	common_fileset_group ./ "$xreconf_root/alt_xcvr_reconfig/" OTHER {
		av_xcvr_reconfig.sdc
        } {A5_RECONF C5_RECONF} {QIP}


	# common files from altera_xcvr_generic/ctrl library
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/ctrl/" {
		alt_xcvr_arbiter.sv
		alt_xcvr_m2s.sv
		altera_wait_generate.v
		alt_xcvr_csr_selector.sv
	} {ALL_HDL}

	# common files from altera_xcvr_generic/sv library
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/sv/" {
		sv_reconfig_bundle_to_basic.sv
	} {S5_RECONF A5_RECONF C5_RECONF}
	
	# common files from altera_xcvr_generic/av library
	common_fileset_group_plain ./ "$xreconf_root/../altera_xcvr_generic/av/" {
		av_reconfig_bundle_to_basic.sv
		av_reconfig_bundle_to_xcvr.sv
	} {A5_RECONF C5_RECONF}
}

proc xreconf_generate_qsys_soc { fileset } {
  #create fileset
  set filename [create_temp_file "ip_gen_script_${fileset}.tcl"]
  set filepath [file dirname $filename]

  set qsys_file $::env(QUARTUS_ROOTDIR)
  set qsys_file "${qsys_file}/../ip/altera/alt_xcvr_reconfig/alt_xcvr_reconfig_soc/alt_xcvr_reconfig_cpu.qsys"
  set arglist [list "--component-file=${qsys_file}" "--fileset=${fileset}"]
  # Call ip-generate
  set filelist [::alt_xcvr::utils::ipgen::ipgenerate $filepath $filename $fileset $arglist]

  # Set tags according to fileset
  if { $fileset == "QUARTUS_SYNTH" } {
    set toolFlowTags {QENCRYPT}
  } else {
    #set toolFlowTags [::alt_xcvr::utils::fileset::common_fileset_tags_all_simulators]
    set toolFlowTags PLAIN
  } 

  foreach item $filelist {
    set srcDir [file dirname $item]
    set filename [file tail $item]
    ::alt_xcvr::utils::fileset::common_fileset_group "./" $srcDir AUTOTYPE [list $filename] {S5_RECONF_SOC A5_RECONF_SOC C5_RECONF_SOC} $toolFlowTags
    #send_message info "SOC_FILE:$item"
  }
}

