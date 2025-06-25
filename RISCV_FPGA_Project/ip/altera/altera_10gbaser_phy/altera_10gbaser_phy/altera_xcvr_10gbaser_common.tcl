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


# Common files for 10GBASE-R PHY
#
# $Header: //acds/main/ip/altera_10gbaser_phy/altera_10gbaser_xcvr_common.tcl

set common_composed_mode 0

if { [lsearch $auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control ] == -1 } {
  lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
}
package require altera_xcvr_reset_control::fileset

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc decl_fileset_groups { phy_root } {

    # enable only a single warning per simulator for missing vendor encryption directories
    common_enable_summary_sim_support_warnings 1	;# 1 to suppress all but summary warning per sim vendor

    #
    # declare packages first
    #
    common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" altera_xcvr_functions.sv {ALL_HDL}
    common_fileset_group_plain ./ "$phy_root/../alt_pma/source/alt_pma/" alt_pma_functions.sv {S4}

    #
    # Common CSR blocks and reset controller
    alt_xcvr_csr_decl_fileset_groups $phy_root/../altera_xcvr_generic/

    #
    # Avalon stuff
    common_fileset_group_plain ./ "$phy_root/../avalon_st/altera_avalon_st_handshake_clock_crosser/" altera_avalon_st_handshake_clock_crosser.v {ALL_HDL}
    common_fileset_group_plain ./ "$phy_root/../avalon_st/altera_avalon_st_handshake_clock_crosser/" altera_avalon_st_clock_crosser.v {ALL_HDL}
    common_fileset_group_plain ./ "$phy_root/../avalon_st/altera_avalon_st_pipeline_stage/" altera_avalon_st_pipeline_stage.sv {ALL_HDL}
    common_fileset_group_plain ./ "$phy_root/../avalon_st/altera_avalon_st_pipeline_stage/" altera_avalon_st_pipeline_base.v {ALL_HDL}

    #
    # Soft PCS encrypted files for AV (AV specific)
    #
    common_fileset_group_encrypted ./ "$phy_root/av_soft_pcs/" {
	alt_10gbaser_pcs.v
	altera_10gbaser_phy_params.sv
	altera_10gbaser_phy_async_fifo_fpga.sv
	altera_10gbaser_phy_bitsync.v
	altera_10gbaser_phy_bitsync2.v
	altera_10gbaser_phy_clockcomp.sv
	altera_10gbaser_phy_clk_ctrl.v
	altera_10gbaser_phy_gearbox_exp.v
	altera_10gbaser_phy_gearbox_red.v
	altera_10gbaser_phy_pcs_10g.v
	altera_10gbaser_phy_pcs_10g_top.sv
	altera_10gbaser_phy_reg_map_av.sv
	altera_10gbaser_phy_rx_fifo.sv
	altera_10gbaser_phy_rx_fifo_wrap.v
	altera_10gbaser_phy_rx_top.v 
	altera_10gbaser_phy_tx_top.v
    } {A5SOFT}

    #
    # Soft PCS encrypted files for SIV
    #
    common_fileset_group_encrypted ./ "$phy_root/soft_pcs/" {
	alt_10gbaser_pcs.v
	altera_10gbaser_phy_params.sv
	altera_10gbaser_phy_1588_latency.sv
	altera_10gbaser_phy_async_fifo.sv
	altera_10gbaser_phy_ber.v
	altera_10gbaser_phy_ber_cnt_ns.v
	altera_10gbaser_phy_ber_sm.v
	altera_10gbaser_phy_bitsync.v
	altera_10gbaser_phy_blksync.v
	altera_10gbaser_phy_blksync_datapath.v
	altera_10gbaser_phy_clockcomp.sv
	altera_10gbaser_phy_clk_ctrl.v
	altera_10gbaser_phy_decode.sv
	altera_10gbaser_phy_decode_type.sv
	altera_10gbaser_phy_descramble.v
	altera_10gbaser_phy_encode.sv
	altera_10gbaser_phy_encode_type.sv
	altera_10gbaser_phy_gearbox_exp.v
	altera_10gbaser_phy_gearbox_red.v
	altera_10gbaser_phy_lock_sm.v
	altera_10gbaser_phy_nto1mux.v
	altera_10gbaser_phy_pcs_10g.v
	altera_10gbaser_phy_pcs_10g_top.sv
	altera_10gbaser_phy_prbs_gen_xg.v
	altera_10gbaser_phy_prbs_ver_xg.v
	altera_10gbaser_phy_random_err_cnt_ns.sv
	altera_10gbaser_phy_random_gen.sv
	altera_10gbaser_phy_random_ver.sv
	altera_10gbaser_phy_random_ver_10g.sv
	altera_10gbaser_phy_reg_map_av.sv
	altera_10gbaser_phy_register_with_byte_enable.v
	altera_10gbaser_phy_rx_sm_datapath.sv
	altera_10gbaser_phy_rx_sm_ns.sv
	altera_10gbaser_phy_rx_top.v
	altera_10gbaser_phy_scramble.v
	altera_10gbaser_phy_square_wave_gen.v
	altera_10gbaser_phy_tx_sm_datapath.sv
	altera_10gbaser_phy_tx_sm_ns.sv
	altera_10gbaser_phy_tx_top.v
	altera_10gbaser_phy_word_align.v
	altera_10gbaser_phy_rx_fifo_wrap.v 
	altera_10gbaser_phy_rx_fifo.v
	altera_10gbaser_phy_async_fifo_fpga.sv 
	gearbox_exp.v
	nto1mux.v
    } {SOFT}

    #
    # Soft PCS encrypted files for 1588 variants for SV
    #
    common_fileset_group_encrypted ./ "$phy_root/soft_pcs/" {
	altera_10gbaser_phy_1588_latency.sv
	altera_10gbaser_phy_async_fifo.sv
	altera_10gbaser_phy_async_fifo_fpga.sv 
	altera_10gbaser_phy_clockcomp.sv
	altera_10gbaser_phy_params.sv
	altera_10gbaser_phy_rx_fifo.v
	altera_10gbaser_phy_rx_fifo_wrap.v 
    } {S5SOFT}

    #
    # Soft PCS encrypted files for AV (reused from SIV)
    #
    common_fileset_group_encrypted ./ "$phy_root/soft_pcs/" {
	altera_10gbaser_phy_1588_latency.sv
	altera_10gbaser_phy_ber.v
	altera_10gbaser_phy_ber_cnt_ns.v
	altera_10gbaser_phy_ber_sm.v
	altera_10gbaser_phy_blksync.v
	altera_10gbaser_phy_blksync_datapath.v
	altera_10gbaser_phy_decode.sv
	altera_10gbaser_phy_decode_type.sv
	altera_10gbaser_phy_descramble.v
	altera_10gbaser_phy_encode.sv
	altera_10gbaser_phy_encode_type.sv
	altera_10gbaser_phy_lock_sm.v
	altera_10gbaser_phy_nto1mux.v
	altera_10gbaser_phy_prbs_gen_xg.v
	altera_10gbaser_phy_prbs_ver_xg.v
	altera_10gbaser_phy_random_err_cnt_ns.sv
	altera_10gbaser_phy_random_gen.sv
	altera_10gbaser_phy_random_ver.sv
	altera_10gbaser_phy_random_ver_10g.sv
	altera_10gbaser_phy_register_with_byte_enable.v
	altera_10gbaser_phy_rx_sm_datapath.sv
	altera_10gbaser_phy_rx_sm_ns.sv
	altera_10gbaser_phy_scramble.v
	altera_10gbaser_phy_square_wave_gen.v
	altera_10gbaser_phy_tx_sm_datapath.sv
	altera_10gbaser_phy_tx_sm_ns.sv
	altera_10gbaser_phy_word_align.v 
    } {A5SOFT}

    #
    # Stratix IV & derivatives
    #
    common_fileset_group_plain ./ "$phy_root/siv/" {
	pll_siv_xgmii.v
	siv_10gbaser_pcs_pma_map.v
	siv_10gbaser_xcvr.v
    } {S4}

    #
    # Stratix IV & derivatives
    #
    common_fileset_group ./ "$phy_root/siv/" VERILOG {
	alt_pma_10gbaser_tgx.sv
    } {S4} {QENCRYPT}

    #
    # Stratix IV simulation only
    #
    common_fileset_group_plain ./ "$phy_root/siv/" {
	csr_pcs10gbaser_h.sv
	csr_pcs10gbaser.sv
    } {ALL_HDL}

    common_fileset_group_plain ./ "$phy_root/../alt_pma/source/channel_controller/" {
	alt_pma_ch_controller_tgx.v
	tgx_ch_reset_ctrl.sv
    } {S4}

    common_fileset_group_plain ./ "$phy_root/../alt_pma/source/alt_pma_controller/" {
	alt_pma_controller_tgx.v
    } {S4}

    common_fileset_group ./ "$phy_root/../alt_pma/source/stratixiv/" OTHER {
	siv_xcvr_low_latency_phy_nr.sv
    }  {S4} {QENCRYPT}

    #
    # Stratix V & derivatives
    #

    #
    # sv_xcvr_native and all sub-modules
    sv_xcvr_native_decl_fileset_groups $phy_root/../altera_xcvr_generic/

    common_fileset_group_plain ./ "$phy_root/sv/" {
	sv_xcvr_10gbaser_nr.sv
	sv_xcvr_10gbaser_native.sv
    } {S5}
    #		sv_xcvr_10gbaser.sv

    #
    # Arria V & derivatives
    #

    #
    # av_xcvr_native and all sub-modules
    av_xcvr_native_decl_fileset_groups $phy_root/../altera_xcvr_generic/

    common_fileset_group_plain ./ "$phy_root/av/" {
	av_xcvr_10gbaser_nr.sv
	av_xcvr_10gbaser_native.sv
    } {A5}
    
    common_fileset_group_plain ./ "$phy_root/../alt_xcvr/altera_xcvr_native_phy/av/" {
	altera_xcvr_native_av_functions_h.sv
	altera_xcvr_native_av.sv
    } {A5}

    #
    # Common to all families
    #

    common_fileset_group_plain ./ "$phy_root/altera_10gbaser_phy/" {
	altera_xcvr_10gbaser.sv
    } {ALL_HDL}

    common_fileset_group ./ "$phy_root/soft_pcs/" OTHER {
	alt_10gbaser_phy.sdc
    } {S4} {QENCRYPT}
    
    common_fileset_group ./ "$phy_root/soft_pcs/" OTHER {
	alt_10gbaser_pcs.ocp
    } {S4} {QENCRYPT}

    common_fileset_group ./ "$phy_root/av_soft_pcs/" OTHER {
	alt_10gbaser_phy.sdc
    } {A5} {QENCRYPT}

    # Reset controller
    ::altera_xcvr_reset_control::fileset::declare_files

    #
    # Reconfiguration block
    #
    xreconf_decl_fileset_groups $phy_root/../alt_xcvr_reconfig
}

# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
    add_fileset_for_tool {PLAIN QENCRYPT}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc sim_ver {name} {
    add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]

    set dev_family [get_parameter_value device_family]
    if { $dev_family == "Stratix IV" } {
	add_fileset_file ../siv/alt_pma_10gbaser_tgx_vo.sv SYSTEMVERILOG PATH ../siv/alt_pma_10gbaser_tgx_vo.sv
    }	
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc sim_vhdl {name} {
    add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]

    set dev_family [get_parameter_value device_family]
    if { $dev_family == "Stratix IV" } {
	add_fileset_file ../siv/alt_pma_10gbaser_tgx_vo.sv SYSTEMVERILOG PATH ../siv/alt_pma_10gbaser_tgx_vo.sv {SYNOPSYS_SPECIFIC CADENCE_SPECIFIC ALDEC_SPECIFIC}
	add_fileset_file ../siv/mentor/alt_pma_10gbaser_tgx_vo.sv SYSTEMVERILOG PATH ../siv/mentor/alt_pma_10gbaser_tgx_vo.sv {MENTOR_SPECIFIC}
    }
}

# +------------------------------------------
# | Define fileset by family for given tools
# | 
proc add_fileset_for_tool {tool} {

    # S4-generation family?
    set device_family [get_parameter_value device_family]
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
	xreconf_decl_fileset_groups ../../alt_xcvr_reconfig  ;#still needed? ccpong
	common_add_fileset_files {SOFT S4 ALL_HDL ALT_XCVR_CSR} $tool
    } elseif { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
	# S5 and derivatives
	set latadj   [get_parameter_value latadj]
	if { $latadj == 1 } {
	    common_add_fileset_files {S5 S5SOFT ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
	} else {
	    common_add_fileset_files {S5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
	}
    } elseif { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
	# A5 and derivatives
	common_add_fileset_files {A5 A5SOFT ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
    } else {
	# Unknown family
	send_message error "Current device_family ($device_family) is not supported"
    }
}


# +-----------------------------------
# | define parameters
# | 

proc common_add_parameters_for_common_gui { } {
    add_parameter device_family STRING 
    set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
    set_parameter_property device_family DISPLAY_NAME "Device family"
    set_parameter_property device_family ENABLED false
    set_parameter_property device_family HDL_PARAMETER true
    set_parameter_property device_family DESCRIPTION \
	"Stratix IV GT, Stratix V or Arria V GT. Stratix IV GT and Arria V GT are implemented with a soft PCS and hard PMA. In Stratix V both the PCS and PMA are implemented in hard logic."
    add_display_item "General Options" device_family parameter
    
    set fams [::alt_xcvr::utils::device::list_s4_style_hssi10g_families]
    set fams [concat $fams [::alt_xcvr::utils::device::list_s5_style_hssi_families] ]
    set fams [concat $fams [::alt_xcvr::utils::device::list_a5_style_hssi_families] ]
    send_message info "set_parameter_property device_family ALLOWED_RANGES $fams"

    add_parameter num_channels INTEGER 1
    set_parameter_property num_channels DEFAULT_VALUE 1
    set_parameter_property num_channels DISPLAY_NAME "Number of channels"
    set_parameter_property num_channels UNITS ""
    set_parameter_property num_channels ALLOWED_RANGES {1:32}
    set_parameter_property num_channels DESCRIPTION "1-32 channels are available"
    set_parameter_property num_channels HDL_PARAMETER true
    add_display_item "General Options" num_channels PARAMETER

    add_parameter operation_mode STRING duplex
    set_parameter_property operation_mode DEFAULT_VALUE duplex
    set_parameter_property operation_mode DISPLAY_NAME "Mode of operation"
    set_parameter_property operation_mode UNITS ""
    set_parameter_property operation_mode ALLOWED_RANGES {duplex tx_only rx_only}
    set_parameter_property operation_mode DESCRIPTION "Stratix V and Arria V GT supports TX only, RX only or Duplex operation. Stratix IV GT supports Duplex mode"
    set_parameter_property operation_mode HDL_PARAMETER true
    add_display_item "General Options" operation_mode PARAMETER

    add_parameter external_pma_ctrl_config  integer 0
    set_parameter_property external_pma_ctrl_config  DEFAULT_VALUE 0
    set_parameter_property external_pma_ctrl_config ALLOWED_RANGES {0:1}
    set_parameter_property external_pma_ctrl_config  DISPLAY_NAME "Use external PMA control and reconfig"
    set_parameter_property external_pma_ctrl_config  DISPLAY_HINT "Boolean"
    set_parameter_property external_pma_ctrl_config  HDL_PARAMETER true
    set_parameter_property external_pma_ctrl_config DESCRIPTION \
	"If you turn this option on, the PMA controller and reconfiguration \
	 block are external, rather than included 10GBASE-R PHY IP core,  \
	 allowing you to use the same PMA controller and reconfiguration IP \
	  cores for other protocols in the same transceiver quad.  \
	  This option is available in Stratix IV devices"
    add_display_item "Additional Options" external_pma_ctrl_config  PARAMETER

    add_parameter control_pin_out integer 0
    set_parameter_property control_pin_out DEFAULT_VALUE 0
    set_parameter_property control_pin_out ALLOWED_RANGES {0:1}
    set_parameter_property control_pin_out DISPLAY_NAME "Enable additional control and status pins"
    set_parameter_property control_pin_out DESCRIPTION "If you turn this option on the hi_ber and block_lock signals are brought up to the  top-level to facilitate debugging."
    set_parameter_property control_pin_out DISPLAY_HINT "Boolean"
    set_parameter_property control_pin_out HDL_PARAMETER true
    add_display_item "Additional Options" control_pin_out PARAMETER

    add_parameter recovered_clk_out integer 0
    set_parameter_property recovered_clk_out DEFAULT_VALUE 0
    set_parameter_property recovered_clk_out ALLOWED_RANGES {0:1}
    set_parameter_property recovered_clk_out DISPLAY_NAME "Enable rx_recovered_clk pin"
    set_parameter_property recovered_clk_out DISPLAY_HINT "Boolean"
    set_parameter_property recovered_clk_out DESCRIPTION "Enable rx_recovered_clk that is running at 257MHz in Stratix V, or 161MHz in Arria V GT."
    set_parameter_property recovered_clk_out HDL_PARAMETER true
    add_display_item "Additional Options" recovered_clk_out PARAMETER

    add_parameter pll_locked_out integer 0
    set_parameter_property pll_locked_out DEFAULT_VALUE 0
    set_parameter_property pll_locked_out ALLOWED_RANGES {0:1}
    set_parameter_property pll_locked_out DISPLAY_NAME "Enable pll_locked status port"
    set_parameter_property pll_locked_out DISPLAY_HINT "Boolean"
    set_parameter_property pll_locked_out DESCRIPTION "Enable pll_locked port to be exposed out"
    set_parameter_property pll_locked_out HDL_PARAMETER true
    add_display_item "Additional Options" pll_locked_out PARAMETER

    # adding pll type parameter - GUI param is symbolic only
    add_parameter gui_pll_type STRING "CMU"
    set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
    set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
    set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
    set_parameter_property gui_pll_type UNITS None
    set_parameter_property gui_pll_type ENABLED true
    set_parameter_property gui_pll_type VISIBLE true
    set_parameter_property gui_pll_type DISPLAY_HINT ""
    set_parameter_property gui_pll_type HDL_PARAMETER false
    set_parameter_property gui_pll_type DESCRIPTION "Specifies the PLL type"
    add_display_item "General Options" gui_pll_type parameter

    # adding pll input clock aka pll_refclk_freq parameter - GUI param is symbolic only
    add_parameter ref_clk_freq STRING "644.53125 MHz"
    set_parameter_property ref_clk_freq DEFAULT_VALUE "644.53125 MHz"
    set_parameter_property ref_clk_freq DISPLAY_NAME "Reference clock frequency"
    set_parameter_property ref_clk_freq UNITS ""
    set_parameter_property ref_clk_freq ALLOWED_RANGES {"322.265625 MHz" "644.53125 MHz"}
    set_parameter_property ref_clk_freq DESCRIPTION "322.265626 MHz or 644.53125 MHz. Stratix V and Arria V GT supports both frequencies. Stratix IV GT only support 644.53125 MHz"
    set_parameter_property ref_clk_freq HDL_PARAMETER true
    add_display_item "General Options" ref_clk_freq PARAMETER

    add_parameter pma_mode INTEGER 0
    set_parameter_property pma_mode VISIBLE false
    set_parameter_property pma_mode DEFAULT_VALUE 40
    set_parameter_property pma_mode ALLOWED_RANGES {32 40}
    set_parameter_property pma_mode DISPLAY_NAME "PCS / PMA interface width"
    set_parameter_property pma_mode DESCRIPTION "Specifies the data interface width between the 10G PCS and the transceiver PMA. Smaller width have lower PCS latency, but higher frequency. 
                                                 For 40, rx_recovered_clock = 257.8125 MHz, gearbox ratio = 66:40. 
                                                 For 32, rx_recovered_clock = 322.265625 MHz, gearbox ratio = 66:32."
    add_display_item "General Options" pma_mode PARAMETER

    add_parameter pll_type STRING
    set_parameter_property pll_type VISIBLE false
    set_parameter_property pll_type DEFAULT_VALUE "AUTO"
    set_parameter_property pll_type HDL_PARAMETER true
    set_parameter_property pll_type ENABLED true
    set_parameter_property pll_type DERIVED true
    
    add_parameter starting_channel_number INTEGER 0
    set_parameter_property starting_channel_number DEFAULT_VALUE 0
    set_parameter_property starting_channel_number DISPLAY_NAME "Starting channel number"
    set_parameter_property starting_channel_number ALLOWED_RANGES {0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96}
    set_parameter_property starting_channel_number DESCRIPTION "Specifies the starting channel number. This option is only necessary in Stratix IV devices."
    set_parameter_property starting_channel_number HDL_PARAMETER true
    add_display_item "Additional Options" starting_channel_number PARAMETER
    
    add_parameter reconfig_interfaces  INTEGER 1
    set_parameter_property reconfig_interfaces  DEFAULT_VALUE 1
    set_parameter_property reconfig_interfaces  DISPLAY_NAME "Number of reconfig interfaces"
    set_parameter_property reconfig_interfaces  HDL_PARAMETER true
    set_parameter_property reconfig_interfaces VISIBLE false 
    set_parameter_property reconfig_interfaces DERIVED true
    add_display_item "General Options" reconfig_interfaces  PARAMETER

    add_parameter sys_clk_in_hz INTEGER 150000000
    set_parameter_property sys_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
    set_parameter_property sys_clk_in_hz VISIBLE false 
    set_parameter_property sys_clk_in_hz HDL_PARAMETER false
    add_display_item "Additional Options" sys_clk_in_hz parameter 

    add_parameter rx_use_coreclk integer 0
    set_parameter_property rx_use_coreclk DEFAULT_VALUE 0
    set_parameter_property rx_use_coreclk ALLOWED_RANGES {0:1}
    set_parameter_property rx_use_coreclk DISPLAY_NAME "Enable rx_coreclkin port"
    set_parameter_property rx_use_coreclk DISPLAY_HINT "Boolean"
    set_parameter_property rx_use_coreclk DESCRIPTION "Optional clock to drive the coreclk port of the RX PCS to drive to xgmii_rx_clk"
    set_parameter_property rx_use_coreclk HDL_PARAMETER true
    add_display_item "Additional Options" rx_use_coreclk PARAMETER

    # UI parameter for enabling / disabling embedded reset controller
    set DESCRIPTION "Enables the embedded reset controller. When disabled, the reset control ports (pll_powerdown, tx_analogreset, tx_digitalreset, rx_analogreset, and rx_digitalreset) will be exposed \
                    for manual control."
    add_parameter gui_embedded_reset INTEGER 1
    set_parameter_property gui_embedded_reset DEFAULT_VALUE 1
    set_parameter_property gui_embedded_reset VISIBLE true
    set_parameter_property gui_embedded_reset HDL_PARAMETER false
    set_parameter_property gui_embedded_reset DESCRIPTION $DESCRIPTION
    set_parameter_property gui_embedded_reset DISPLAY_NAME "Enable embedded reset controller"
    set_parameter_property gui_embedded_reset DISPLAY_HINT BOOLEAN
    add_display_item "Additional Options" gui_embedded_reset parameter

    # Derived HDL parameter for enabling / disabling embedded reset controller
    add_parameter embedded_reset INTEGER 1
    set_parameter_property embedded_reset DEFAULT_VALUE 1
    set_parameter_property embedded_reset VISIBLE false
    set_parameter_property embedded_reset HDL_PARAMETER true
    set_parameter_property embedded_reset DERIVED true
    add_display_item "Additional Options" embedded_reset parameter

    add_parameter latadj INTEGER 0
    set_parameter_property latadj VISIBLE true
    set_parameter_property latadj DEFAULT_VALUE 0
    set_parameter_property latadj ALLOWED_RANGES {0:1}
    set_parameter_property latadj DISPLAY_NAME "Enable IEEE 1588 latency adjustment ports"
    set_parameter_property latadj DISPLAY_HINT "Boolean"
    set_parameter_property latadj DESCRIPTION "Creates ports for IEEE 1588 latency adjustment."
    set_parameter_property latadj HDL_PARAMETER true
    set_parameter_property latadj ENABLED true
    set_parameter_property latadj DERIVED false
    add_display_item "Additional Options" latadj PARAMETER
    
    # hidden 1588 parameter for backward compatibility purpose
    add_parameter high_precision_latadj INTEGER 1
    set_parameter_property high_precision_latadj VISIBLE false
    set_parameter_property high_precision_latadj DEFAULT_VALUE 1
    set_parameter_property high_precision_latadj ALLOWED_RANGES {0:1}
    set_parameter_property high_precision_latadj DISPLAY_NAME "Enable High Precision IEEE 1588 latency measurement"
    set_parameter_property high_precision_latadj DISPLAY_HINT "Boolean"
    set_parameter_property high_precision_latadj DESCRIPTION "Turn this off to eliminate extra representation bits introduced for latency_adj port"
    set_parameter_property high_precision_latadj HDL_PARAMETER true
    set_parameter_property high_precision_latadj ENABLED true
    set_parameter_property high_precision_latadj DERIVED false
    #add_display_item "Additional Options" high_precision_latadj PARAMETER
}

# +-----------------------------------
# | parameter validation
# | 
proc common_parameter_validation {} {
    set device_family [get_parameter_value device_family]
	set gui_embedded_reset [get_parameter_value gui_embedded_reset]
    if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family]} {
	set num_chs [get_parameter_value num_channels]
	set op_mode [get_parameter_value operation_mode]
	if { $op_mode == "rx_only" } {
	    set num_tx_pll 0
	} else {
	    set num_tx_pll $num_chs
	}
	set num_reconfig_interfaces [expr $num_chs + $num_tx_pll]
	set_parameter_value reconfig_interfaces $num_reconfig_interfaces

	set_parameter_property operation_mode ENABLED true 
	set_parameter_property operation_mode ALLOWED_RANGES {duplex tx_only rx_only}
	set_parameter_property ref_clk_freq ENABLED true 
	set_parameter_property ref_clk_freq ALLOWED_RANGES {"322.265625 MHz" "644.53125 MHz"}
	foreach param [get_pma_parameters] {
	    set_parameter_property $param VISIBLE false
	}
	set_parameter_property starting_channel_number VISIBLE false		
	set_parameter_property external_pma_ctrl_config VISIBLE false
	set_parameter_property rx_use_coreclk VISIBLE true
	set_parameter_property pll_locked_out VISIBLE true
	if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
	    set_parameter_property pma_mode ENABLED true
	    set_parameter_property pma_mode VISIBLE true
	    set_parameter_property pma_mode HDL_PARAMETER true
	    set pma_width [get_parameter_value pma_mode]
	    if { $device_family == "Arria V GZ" && $pma_width == 32 } {
	        send_message WARNING "PCS / PMA interface width of 32 will cause fitter error in C4/I4 variant of Arria V GZ because it does not support up to 10.3125 Gbps data rate. Refer to Arria V GZ Device Datasheet for approximate maximum data rate of different widths."
	    }
	}
	set_parameter_value embedded_reset $gui_embedded_reset

    } elseif { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
	set_parameter_property operation_mode ALLOWED_RANGES {duplex}
	set_parameter_property operation_mode ENABLED false 
	set_parameter_property ref_clk_freq ALLOWED_RANGES {"644.53125 MHz"}
	set_parameter_property ref_clk_freq ENABLED false 
	foreach param [get_pma_parameters] {
	    set_parameter_property $param VISIBLE true
	}
	set_parameter_property rx_use_coreclk VISIBLE false
	set_parameter_property pll_locked_out VISIBLE false
	set_parameter_property external_pma_ctrl_config VISIBLE true
	set external_ctrl [get_parameter_value external_pma_ctrl_config]
	if { $external_ctrl == 0 } {
	    set_parameter_property starting_channel_number VISIBLE false		
	} else {
	    set_parameter_property starting_channel_number VISIBLE true		
	}
	set num_chs [get_parameter_value num_channels]
	set num_reconfig_interfaces [expr ceil ([expr $num_chs/4.0])]
	set_parameter_value reconfig_interfaces $num_reconfig_interfaces

	set_parameter_value reconfig_interfaces $num_reconfig_interfaces
	set mgmt_clk_in_hz_sys [get_parameter_value mgmt_clk_in_hz]
	set mgmt_clk_in_mhz_cal [expr ceil ([expr $mgmt_clk_in_hz_sys/1000000])]
	if {$mgmt_clk_in_mhz_cal == 150} {
	    set_parameter_value mgmt_clk_in_mhz $mgmt_clk_in_mhz_cal
	set_parameter_property gui_embedded_reset VISIBLE false
	set_parameter_value embedded_reset 1
	} 

    } else {
	set_parameter_property operation_mode ENABLED true 
	set_parameter_property operation_mode ALLOWED_RANGES {duplex tx_only rx_only}
	set_parameter_property ref_clk_freq ENABLED true 
	set_parameter_property ref_clk_freq ALLOWED_RANGES {"322.265625 MHz" "644.53125 MHz"}
	foreach param [get_pma_parameters] {
	    set_parameter_property $param VISIBLE false
	}
	set_parameter_property starting_channel_number VISIBLE false		
	set_parameter_property external_pma_ctrl_config VISIBLE false

    }
    
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
	send_message info "The tx analog setting of tx_vod_selection, tx_termination, tx_preemp_pretap, tx_preemp_tap_1 and tx_preemp_tap_2 combine may not work. Please use quartus compilation to validate"
    }

}


# +-----------------------------------
# | top-PHY extra parameters
# |     
proc add_extra_parameters_for_top_phy { } {
    
    add_parameter mgmt_clk_in_hz LONG 150000000
    set_parameter_property mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
    set_parameter_property mgmt_clk_in_hz VISIBLE false
    set_parameter_property mgmt_clk_in_hz HDL_PARAMETER false

    add_parameter mgmt_clk_in_mhz INTEGER 150 
    set_parameter_property mgmt_clk_in_mhz DERIVED true
    set_parameter_property mgmt_clk_in_mhz VISIBLE false
    set_parameter_property reconfig_interfaces DERIVED true
    set_parameter_property mgmt_clk_in_mhz HDL_PARAMETER true
}

# +-----------------------------------
# | interfaces and ports common to all 10GBASE-R PHY 
# | 
proc common_clock_interfaces { } {
    global common_composed_mode

    common_add_clock	pll_ref_clk		input
    common_add_clock	xgmii_rx_clk		output
    set_interface_property xgmii_rx_clk clockRateKnown true
    set_interface_property xgmii_rx_clk clockRate "156250000"
}


# +-----------------------------------
# | Common PHY ports
# | 
proc common_10gbaser_phy_interface_ports { } {
    set device_family [get_parameter_value device_family]
    set num_chs [get_parameter_value num_channels]
    set op_mode [get_parameter_value operation_mode]
    set ctrl_out [get_parameter_value control_pin_out]
    set rcvr_out [get_parameter_value recovered_clk_out]
    set rx_coreclk [get_parameter_value rx_use_coreclk]
    set ext_ctrl [get_parameter_value external_pma_ctrl_config ]
    set pll_locked [get_parameter_value pll_locked_out ]
    set latadj   [get_parameter_value latadj ]
    set high_precision_latadj   [get_parameter_value high_precision_latadj ]
    set embedded_reset_port [get_parameter_value embedded_reset]
	
    if { $op_mode == "rx_only" } {
	set tx_sup 0
    } else {
	set tx_sup 1
    }
    if { $op_mode == "tx_only" } {
	set rx_sup 0
    } else {
	set rx_sup 1
    }
    set sys_clk_tmp [get_parameter_value sys_clk_in_hz]
    set sys_clk_freq [expr $sys_clk_tmp / 1000000]
    set num_reconfig_interfaces [get_parameter_value reconfig_interfaces]

    set sv_sup 0
    set siv_sup 0

    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
	set siv_sup 1
    } else {
	set sv_sup 1
    }

    set hdl_module altera_xcvr_10gbaser
    if { $ctrl_out } {
	common_add_optional_conduit rx_block_lock output $num_chs  true
	common_add_optional_conduit rx_hi_ber output $num_chs  true
	set_port_property rx_block_lock VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_hi_ber VHDL_TYPE STD_LOGIC_VECTOR
    } else {
	my_terminate_port rx_block_lock 0 output $num_chs
	my_terminate_port rx_hi_ber 0 output $num_chs
	set_port_property rx_block_lock VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_hi_ber VHDL_TYPE STD_LOGIC_VECTOR
    }

    if { $rcvr_out } {
  	common_add_clock_bus	rx_recovered_clk  output $num_chs
	set_port_property rx_recovered_clk VHDL_TYPE STD_LOGIC_VECTOR
  	set_interface_property rx_recovered_clk clockRateKnown true
	set_interface_property rx_recovered_clk clockRate "257812500"
    } else {
	my_terminate_port rx_recovered_clk 0 output $num_chs
	set_port_property rx_recovered_clk VHDL_TYPE STD_LOGIC_VECTOR
    }

	if { $rx_coreclk } {
  		common_add_optional_conduit	rx_coreclkin  input 1 true
	 } else {
	  	my_terminate_port rx_coreclkin 0 input 1
	 }
    
    if { !$rx_sup && $ctrl_out} {
	    send_message error "rx_block_lock and rx_hi_ber cannot be enabled in tx_only operation mode"
    }

    if { !$rx_sup && $rcvr_out} {
	    send_message error "rx_recovered_clk cannot be enabled in tx_only operation mode"
    }
    
    if { $sv_sup && !$rx_sup && $rx_coreclk} {
	    send_message error "rx_coreclkin cannot be enabled in tx_only operation mode"
    }

    if { $sv_sup && !$tx_sup && $pll_locked} {
	    send_message error "pll_locked cannot be enabled in rx_only operation mode"
    }

  if {($ext_ctrl && $siv_sup) || ($pll_locked && $sv_sup)} {
		 	common_add_optional_conduit pll_locked output 1 true
	 } else {
	  	my_terminate_port pll_locked 0 output 1
	 }

    if {$ext_ctrl && $siv_sup } {
	common_add_optional_conduit gxb_pdn input 1 true
	common_add_optional_conduit pll_pdn input 1 true
	common_add_optional_conduit cal_blk_pdn input 1 true
	common_add_clock	cal_blk_clk		input

	common_add_optional_conduit reconfig_to_xcvr input 4 true
	common_add_optional_conduit reconfig_from_xcvr output [expr $num_reconfig_interfaces * 17] true
    } else {
	my_terminate_port gxb_pdn 0 input 1
	my_terminate_port pll_pdn 0 input 1
	my_terminate_port cal_blk_pdn 0 input 1
	my_terminate_port cal_blk_clk 0 input 1

	my_terminate_port reconfig_to_xcvr 0 input 4
	my_terminate_port reconfig_from_xcvr 0 output [expr $num_reconfig_interfaces * 17]
    }

	# Reset ports
	if {$tx_sup == 0 || $embedded_reset_port == 1} {
	my_terminate_port pll_powerdown 0 input $num_chs
	my_terminate_port tx_digitalreset 0 input $num_chs
	my_terminate_port tx_analogreset 0 input $num_chs
	my_terminate_port tx_cal_busy 0 output $num_chs
	
	set_port_property pll_powerdown VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_digitalreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_analogreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_cal_busy VHDL_TYPE STD_LOGIC_VECTOR
	} else {
	common_add_optional_conduit pll_powerdown input $num_chs true
	common_add_optional_conduit tx_digitalreset input $num_chs true
	common_add_optional_conduit tx_analogreset input $num_chs true
	common_add_optional_conduit tx_cal_busy output $num_chs true
	
	set_port_property pll_powerdown VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_digitalreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_analogreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property tx_cal_busy VHDL_TYPE STD_LOGIC_VECTOR
	}
	if {$rx_sup == 0 || $embedded_reset_port == 1} {
	my_terminate_port pll_powerdown 0 input $num_chs
	my_terminate_port rx_digitalreset 0 input $num_chs
	my_terminate_port rx_analogreset 0 input $num_chs
	my_terminate_port rx_cal_busy 0 output $num_chs
	my_terminate_port rx_is_lockedtodata 0 output $num_chs
	
	set_port_property pll_powerdown VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_digitalreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_analogreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_cal_busy VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_is_lockedtodata VHDL_TYPE STD_LOGIC_VECTOR
	} else {
	common_add_optional_conduit pll_powerdown input $num_chs true
	common_add_optional_conduit rx_digitalreset input $num_chs true
	common_add_optional_conduit rx_analogreset input $num_chs true
	common_add_optional_conduit rx_cal_busy output $num_chs true
	common_add_optional_conduit rx_is_lockedtodata output $num_chs true
	
	set_port_property pll_powerdown VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_digitalreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_analogreset VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_cal_busy VHDL_TYPE STD_LOGIC_VECTOR
	set_port_property rx_is_lockedtodata VHDL_TYPE STD_LOGIC_VECTOR
	}

    if { $tx_sup } {
	if {$embedded_reset_port} {
	# declare calibration tx interface and port
	common_add_optional_conduit tx_ready output  1 true
	} else {
	my_terminate_port tx_ready 0 output 1
	}
	add_interface xgmii_tx_clk clock end
	set_interface_property xgmii_tx_clk ENABLED true
	add_interface_port xgmii_tx_clk xgmii_tx_clk clk Input 1
    } else {
	# terminate calibration ports inside the wrapper
	my_terminate_port tx_ready 0 output 1
	my_terminate_port xgmii_tx_clk 0 input 1
    }

    if { $rx_sup } {
        if {$embedded_reset_port} {
        # declare calibration rx interface and port
        common_add_optional_conduit rx_ready output  1 true
        } else {
        my_terminate_port rx_ready 0 output 1
        }
        common_add_optional_conduit rx_data_ready output $num_chs  true
        set_port_property rx_data_ready VHDL_TYPE STD_LOGIC_VECTOR
    } else {
        # terminate calibration ports inside the wrapper
        my_terminate_port rx_ready 0 output 1
        my_terminate_port rx_data_ready 0 output $num_chs
        set_port_property rx_data_ready VHDL_TYPE STD_LOGIC_VECTOR
    }

    if { $latadj == 0 } {
        if { $high_precision_latadj == 0 } {
            my_terminate_port rx_latency_adj 0 output [expr $num_chs * 12]
            my_terminate_port tx_latency_adj 0 output [expr $num_chs * 12]
        } else {
            my_terminate_port rx_latency_adj 0 output [expr $num_chs * 16]
            my_terminate_port tx_latency_adj 0 output [expr $num_chs * 16]
        }
    }

    if { $rx_sup } {
	for { set i 0 } { $i < $num_chs } {incr i} {
	    #xgmii_rx_dc
	    my_add_st_optional_interface xgmii_rx_dc_$i start xgmii_rx_clk 72 true
	    
	    #rx_serial_data
	    add_interface rx_serial_data_$i conduit end
	    set_interface_assignment rx_serial_data_$i "ui.blockdiagram.direction" INPUT
	    set_interface_property rx_serial_data_$i ENABLED true
	    set_interface_property rx_serial_data_$i EXPORT_OF true
	    # the HDL-to-interface mapping
	    add_interface_port rx_serial_data_$i rx_serial_data_$i export Input 1
	    set_port_property rx_serial_data_$i FRAGMENT_LIST [list rx_serial_data@$i ]

	    add_interface_port xgmii_rx_dc_$i xgmii_rx_dc_$i data Output 72
	    set_port_property xgmii_rx_dc_$i FRAGMENT_LIST [list xgmii_rx_dc@[expr [expr $i + 1] * 72 - 1]:[expr $i * 72] ]

	    if { $latadj } {
            if { $high_precision_latadj == 0 } {
                add_interface rx_latency_adj_$i conduit start
                set_interface_assignment rx_latency_adj_$i "ui.blockdiagram.direction" OUTPUT
                set_interface_property rx_latency_adj_$i ENABLED true
                add_interface_port rx_latency_adj_$i rx_latency_adj_$i data Output 12
                set_port_property rx_latency_adj_$i FRAGMENT_LIST [list rx_latency_adj@[expr [expr $i + 1] * 12 - 1]:[expr $i * 12] ]
            } else {
                add_interface rx_latency_adj_$i conduit start
                set_interface_assignment rx_latency_adj_$i "ui.blockdiagram.direction" OUTPUT
                set_interface_property rx_latency_adj_$i ENABLED true
                add_interface_port rx_latency_adj_$i rx_latency_adj_$i data Output 16
                set_port_property rx_latency_adj_$i FRAGMENT_LIST [list rx_latency_adj@[expr [expr $i + 1] * 16 - 1]:[expr $i * 16] ]
            }
	    }
	}
    } else {
	my_terminate_port rx_serial_data 0 input  $num_chs
	set_port_property rx_serial_data VHDL_TYPE STD_LOGIC_VECTOR
	my_terminate_port xgmii_rx_dc 0 output [expr $num_chs * 72]
	if { $latadj } {
        if { $high_precision_latadj == 0 } {
            my_terminate_port rx_latency_adj 0 output [expr $num_chs * 12]
        } else {
            my_terminate_port rx_latency_adj 0 output [expr $num_chs * 16]
        }
	}
    }


    if { $tx_sup } {
	for { set i 0 } { $i < $num_chs } {incr i} {
	    #xgmii_tx_dc
	    my_add_st_optional_interface xgmii_tx_dc_$i end xgmii_tx_clk 72 true
	    
	    #tx_serial_data
	    add_interface tx_serial_data_$i conduit start
	    set_interface_assignment tx_serial_data_$i "ui.blockdiagram.direction" OUTPUT
	    set_interface_property tx_serial_data_$i ENABLED true
	    set_interface_property tx_serial_data_$i EXPORT_OF true
	    
	    # the HDL-to-interface mapping
	    add_interface_port tx_serial_data_$i tx_serial_data_$i export Output 1
	    set_port_property tx_serial_data_$i FRAGMENT_LIST [list tx_serial_data@$i ]
	    set_port_property tx_serial_data_$i VHDL_TYPE STD_LOGIC_VECTOR
	    add_interface_port xgmii_tx_dc_$i xgmii_tx_dc_$i data Input 72
	    set_port_property xgmii_tx_dc_$i FRAGMENT_LIST [list xgmii_tx_dc@[expr [expr $i + 1] * 72 - 1]:[expr $i * 72] ]
	    if { $latadj } {
            if { $high_precision_latadj == 0 } {
                add_interface tx_latency_adj_$i conduit start
                set_interface_assignment tx_latency_adj_$i "ui.blockdiagram.direction" OUTPUT
                set_interface_property tx_latency_adj_$i ENABLED true
                add_interface_port tx_latency_adj_$i tx_latency_adj_$i data Output 12
                set_port_property tx_latency_adj_$i FRAGMENT_LIST [list tx_latency_adj@[expr [expr $i + 1] * 12 - 1]:[expr $i * 12] ]
            } else {
                add_interface tx_latency_adj_$i conduit start
                set_interface_assignment tx_latency_adj_$i "ui.blockdiagram.direction" OUTPUT
                set_interface_property tx_latency_adj_$i ENABLED true
                add_interface_port tx_latency_adj_$i tx_latency_adj_$i data Output 16
                set_port_property tx_latency_adj_$i FRAGMENT_LIST [list tx_latency_adj@[expr [expr $i + 1] * 16 - 1]:[expr $i * 16] ]
            }
	    }
	}
    } else {
	my_terminate_port tx_serial_data 0 output $num_chs
	set_port_property tx_serial_data VHDL_TYPE STD_LOGIC_VECTOR
	my_terminate_port xgmii_tx_dc 0 input [expr $num_chs * 72]
	if { $latadj } {
        if { $high_precision_latadj == 0 } {
            my_terminate_port tx_latency_adj 0 input [expr $num_chs * 12]
        } else {
            my_terminate_port tx_latency_adj 0 input [expr $num_chs * 16]
        }
	}
    }

    if { $op_mode == "rx_only" } {
	set tx_plls 0
    } else {
	set tx_plls $num_chs
    }

    set reconfig_interfaces [::alt_xcvr::utils::device::get_reconfig_interface_count $device_family $num_chs $tx_plls]
    
    #conduit for dynamic reconfiguration
    # TODO - rename ports to from_xcvr and to_xcvr
    if { $sv_sup } {
  	common_add_optional_conduit reconfig_from_xcvr output [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_from_xcvr
  	common_add_optional_conduit reconfig_to_xcvr input [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_to_xcvr
    } 
}

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc common_mgmt_interface { addr_width {readLatency 1} } {
    global common_composed_mode
    
    
    # +-----------------------------------
    # | connection point mgmt_clk
    # | 
    common_add_clock  phy_mgmt_clk  input
    add_interface phy_mgmt_clk_reset reset end
    set_interface_property phy_mgmt_clk_reset ASSOCIATED_CLOCK phy_mgmt_clk
    add_interface_port phy_mgmt_clk_reset phy_mgmt_clk_reset reset Input 1
    #	if {$common_composed_mode == 0} {
    #		add_interface_port phy_mgmt_clk phy_reset reset Input 1
    #	} else {
    #		add_interface phy_mgmt_clk_rst reset end
    #		set_interface_property phy_mgmt_clk_rst export_of phy_mgmt_clk.clk_in_reset
    #	}

    # +-----------------------------------
    # | connection point phy_mgmt
    # | 
    add_interface phy_mgmt avalon end
    if {$common_composed_mode == 0} {
	set_interface_property phy_mgmt addressAlignment DYNAMIC
	set_interface_property phy_mgmt burstOnBurstBoundariesOnly false
	set_interface_property phy_mgmt explicitAddressSpan 0
	set_interface_property phy_mgmt holdTime 0
	set_interface_property phy_mgmt isMemoryDevice false
	set_interface_property phy_mgmt isNonVolatileStorage false
	set_interface_property phy_mgmt linewrapBursts false
	set_interface_property phy_mgmt maximumPendingReadTransactions 0
	set_interface_property phy_mgmt printableDevice false
	set_interface_property phy_mgmt readLatency 0
	set_interface_property phy_mgmt readWaitStates 0
	set_interface_property phy_mgmt readWaitTime 0
	set_interface_property phy_mgmt setupTime 0
	set_interface_property phy_mgmt timingUnits Cycles
	set_interface_property phy_mgmt writeWaitTime 0
	set_interface_property phy_mgmt ASSOCIATED_CLOCK phy_mgmt_clk
	set_interface_property phy_mgmt ENABLED true
	
	add_interface_port phy_mgmt phy_mgmt_address address Input $addr_width
	add_interface_port phy_mgmt phy_mgmt_read read Input 1
	add_interface_port phy_mgmt phy_mgmt_readdata readdata Output 32
	add_interface_port phy_mgmt phy_mgmt_write write Input 1
	add_interface_port phy_mgmt phy_mgmt_writedata writedata Input 32
	add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest Output 1
    }
}

# +-----------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_optional_conduit { port_name port_dir width used {port_role "export"} } {

    global common_composed_mode
    array set in_out [list {output} {start} {input} {end} ]
    add_interface $port_name conduit $in_out($port_dir)
    set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
    if {$common_composed_mode == 0} {
	set_interface_property $port_name ENABLED $used
	add_interface_port $port_name $port_name $port_role $port_dir $width
    }
}

# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with pipe_pclk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_stream { port_name port_dir width used } {

    global common_composed_mode
    array set in_out [list {output} {start} {input} {end} ]
    # create interface details
    add_interface $port_name avalon_streaming $in_out($port_dir)
    if {$common_composed_mode == 0} {
	set_interface_property $port_name dataBitsPerSymbol $width
	set_interface_property $port_name maxChannel 0
	set_interface_property $port_name readyLatency 0
	set_interface_property $port_name symbolsPerBeat 1
	set_interface_property $port_name ENABLED $used
	set_interface_property $port_name ASSOCIATED_CLOCK pipe_pclk
	add_interface_port $port_name $port_name data $port_dir $width
    }
}


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock { port_name port_dir } {

    global common_composed_mode
    array set in_out [list {output} {start} {input} {end} ]
    add_interface $port_name clock $in_out($port_dir)
    if {$common_composed_mode == 0} {
	set_interface_property $port_name ENABLED true
	add_interface_port $port_name $port_name clk $port_dir 1
    } else {
	# create clock source instance for composed mode
	add_instance $port_name clock_source
	set_interface_property $port_name export_of $port_name.clk_in
    }
    
}

# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock_bus { port_name port_dir port_width} {

    global common_composed_mode
    array set in_out [list {output} {start} {input} {end} ]
    add_interface $port_name clock $in_out($port_dir) 
    if {$common_composed_mode == 0} {
	set_interface_property $port_name ENABLED true
	add_interface_port $port_name $port_name clk $port_dir $port_width
    } else {
	# create clock source instance for composed mode
	add_instance $port_name clock_source
	set_interface_property $port_name export_of $port_name.clk_in
    }
}

proc my_add_st_optional_interface { if_name if_dir if_clock width used } {
    add_interface $if_name avalon_streaming $if_dir
    set_interface_property $if_name dataBitsPerSymbol $width
    set_interface_property $if_name maxChannel 0
    set_interface_property $if_name readyLatency 0
    set_interface_property $if_name symbolsPerBeat 1
    if { $used } {
	set_interface_property $if_name ENABLED true
	set_interface_property $if_name ASSOCIATED_CLOCK $if_clock
    } else {
	set_interface_property $if_name ENABLED false
    }
}

proc my_terminate_port { port_name termination_value direction width} {
    
    if { $direction == "input" || $direction == "Input" || $direction == "INPUT" } {
    	add_interface $port_name conduit end
	set_interface_assignment $port_name "ui.blockdiagram.direction" INPUT
    	add_interface_port $port_name $port_name export Input $width
    	set_port_property $port_name termination 1
        set_port_property $port_name termination_value $termination_value
    } else {
        add_interface $port_name conduit start
        set_interface_assignment $port_name "ui.blockdiagram.direction" OUTPUT
        add_interface_port $port_name $port_name export Output $width
        set_port_property $port_name termination 1
    }
}

proc validate_reconfiguration_parameters { device_family } {
    #|----------------
    #| Reconfiguration
    #|----------------
    # reconfig_interfaces parameter
    set num_channels   [get_parameter_value num_channels]
    set op_mode        [get_parameter_value operation_mode]
    
    if { $op_mode == "rx_only" } {
	set tx_plls 0
    } else {
	set tx_plls $num_channels
    }

    if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
	::alt_xcvr::gui::messages::reconfig_interface_message $device_family $num_channels $tx_plls
    }
}

proc validate_pll_type { device_family } {
    set user_ref_clk_freq  [get_parameter_value ref_clk_freq]
    set op_mode [get_parameter_value operation_mode]
    set sup_rx         [expr {$op_mode == "rx_only" || $op_mode == "duplex" }]
    set sup_tx         [expr {$op_mode == "tx_only" || $op_mode == "duplex" }]

    if {$op_mode == "rx_only"} {
  	set txpll_num 0
    } else {
  	set txpll_num 1
    }
    
    ::alt_xcvr::utils::common::map_allowed_range gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
    set pll_type [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]

    set gui_pll_type [get_parameter_value gui_pll_type]
    set_parameter_value pll_type $gui_pll_type

}
