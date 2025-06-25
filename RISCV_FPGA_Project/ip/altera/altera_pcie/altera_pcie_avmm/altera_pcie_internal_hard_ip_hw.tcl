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



source pcie_parameters.tcl
source pcie_parameters_validation.tcl
source rx_buffer_config.tcl
# +-----------------------------------
# | module PCI Express Merlin
# |

global env
set qdir $env(QUARTUS_ROOTDIR)
set_module_property DESCRIPTION "Altera PCIe Internal Hard IP"
set_module_property NAME altera_pcie_internal_hard_ip
set_module_property VERSION 13.1
set_module_property DATASHEET_URL "http://www.altera.com/products/ip/iup/pci-express/m-alt-pcie8.html"
set_module_property "group" "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Altera PCIe Internal Hard IP"
set_module_property TOP_LEVEL_HDL_FILE "$qdir/../ip/altera/ip_compiler_for_pci_express/lib/altpcie_hip_pipen1b.v"
set_module_property TOP_LEVEL_HDL_MODULE altpcie_hip_pipen1b
set_module_property "instantiateInSystemModule" "true"
set_module_property EDITABLE false
set_module_property INTERNAL true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
set_module_property SIMULATION_MODEL_IN_VHDL "true"
set_module_property SIMULATION_MODEL_IN_VERILOG "true"
set_module_property ANALYZE_HDL FALSE

add_display_item "" "Block Diagram" GROUP
add_pcie_hip_parameters

add_file $qdir/../ip/altera/ip_compiler_for_pci_express/lib/altpcie_hip_pipen1b.v {synthesis}
add_file $qdir/../ip/altera/ip_compiler_for_pci_express/lib/pciexp_dcram.v {synthesis}
add_file $qdir/../ip/altera/ip_compiler_for_pci_express/lib/pciexp64_trans.v {synthesis}
add_file altera_pci_express.sdc {sdc}

set g_logid ""
set g_log_debug 1

# |
# +-----------------------------------

# +-----------------------------------
# | parameters


# ++++++++++++++BG++++++++++++++++++++

       # Any interface which is static should be declared outside of any callback for best performance
       # Interfaces can be modified within the callback if their default parameterization changes.

# ++++++++++++++BG++++++++++++++++++++





# ++++++++++++++HN++++++++++++++++++++

# +-----------------------------------
# | static interfaces,
add_interface npor conduit end
add_interface_port npor npor interconect Input 1

add_interface app_int_ack conduit end
add_interface_port app_int_ack app_int_ack interconect Output 1
set_port_property app_int_ack TERMINATION true

add_interface app_msi_ack conduit end
add_interface_port app_msi_ack app_msi_ack interconect Output 1
set_port_property app_msi_ack TERMINATION true

add_interface avs_pcie_reconfig_readdata conduit end
add_interface_port avs_pcie_reconfig_readdata avs_pcie_reconfig_readdata interconect Output 16
set_port_property avs_pcie_reconfig_readdata TERMINATION true

add_interface avs_pcie_reconfig_readdatavalid conduit end
add_interface_port avs_pcie_reconfig_readdatavalid avs_pcie_reconfig_readdatavalid interconect Output 1
set_port_property avs_pcie_reconfig_readdatavalid TERMINATION true

add_interface avs_pcie_reconfig_waitrequest conduit end
add_interface_port avs_pcie_reconfig_waitrequest avs_pcie_reconfig_waitrequest interconect Output 1
set_port_property avs_pcie_reconfig_waitrequest TERMINATION true

add_interface derr_cor_ext_rcv0 conduit end
add_interface_port derr_cor_ext_rcv0 derr_cor_ext_rcv0 interconect Output 1
set_port_property derr_cor_ext_rcv0 TERMINATION true

add_interface derr_cor_ext_rcv1 conduit end
add_interface_port derr_cor_ext_rcv1 derr_cor_ext_rcv1 interconect Output 1
set_port_property derr_cor_ext_rcv1 TERMINATION true

add_interface derr_cor_ext_rpl conduit end
add_interface_port derr_cor_ext_rpl derr_cor_ext_rpl interconect Output 1
set_port_property derr_cor_ext_rpl TERMINATION true

add_interface derr_rpl conduit end
add_interface_port derr_rpl derr_rpl interconect Output 1
set_port_property derr_rpl TERMINATION true

add_interface dl_ltssm_int conduit end
add_interface_port dl_ltssm_int dl_ltssm_int interconect Output 5
set_port_property dl_ltssm_int FRAGMENT_LIST {dl_ltssm(4:0)}


add_interface dlup_exit conduit end
add_interface_port dlup_exit dlup_exit interconect Output 1

add_interface ev_128ns conduit end
add_interface_port ev_128ns ev_128ns interconect Output 1
set_port_property ev_128ns TERMINATION true

add_interface ev_1us conduit end
add_interface_port ev_1us ev_1us interconect Output 1
set_port_property ev_1us TERMINATION true

add_interface hip_extraclkout conduit end
add_interface_port hip_extraclkout hip_extraclkout interconect Output 2
set_port_property hip_extraclkout TERMINATION true

add_interface hotrst_exit conduit end
add_interface_port hotrst_exit hotrst_exit interconect Output 1

add_interface int_status conduit end
add_interface_port int_status int_status interconect Output 4
set_port_property int_status TERMINATION true

add_interface l2_exit conduit end
add_interface_port l2_exit l2_exit interconect Output 1

add_interface lmi_ack conduit end
add_interface_port lmi_ack lmi_ack interconect Output 1
set_port_property lmi_ack TERMINATION true

add_interface lmi_dout conduit end
add_interface_port lmi_dout lmi_dout interconect Output 32
set_port_property lmi_dout TERMINATION true

add_interface npd_alloc_1cred_vc0 conduit end
add_interface_port npd_alloc_1cred_vc0 npd_alloc_1cred_vc0 interconect Output 1
set_port_property npd_alloc_1cred_vc0 TERMINATION true

add_interface npd_alloc_1cred_vc1 conduit end
add_interface_port npd_alloc_1cred_vc1 npd_alloc_1cred_vc1 interconect Output 1
set_port_property npd_alloc_1cred_vc1 TERMINATION true

add_interface npd_cred_vio_vc0 conduit end
add_interface_port npd_cred_vio_vc0 npd_cred_vio_vc0 interconect Output 1
set_port_property npd_cred_vio_vc0 TERMINATION true

add_interface npd_cred_vio_vc1 conduit end
add_interface_port npd_cred_vio_vc1 npd_cred_vio_vc1 interconect Output 1
set_port_property npd_cred_vio_vc1 TERMINATION true

add_interface nph_alloc_1cred_vc0 conduit end
add_interface_port nph_alloc_1cred_vc0 nph_alloc_1cred_vc0 interconect Output 1
set_port_property nph_alloc_1cred_vc0 TERMINATION true

add_interface nph_alloc_1cred_vc1 conduit end
add_interface_port nph_alloc_1cred_vc1 nph_alloc_1cred_vc1 interconect Output 1
set_port_property nph_alloc_1cred_vc1 TERMINATION true

add_interface nph_cred_vio_vc0 conduit end
add_interface_port nph_cred_vio_vc0 nph_cred_vio_vc0 interconect Output 1
set_port_property nph_cred_vio_vc0 TERMINATION true

add_interface nph_cred_vio_vc1 conduit end
add_interface_port nph_cred_vio_vc1 nph_cred_vio_vc1 interconect Output 1
set_port_property nph_cred_vio_vc1 TERMINATION true

add_interface pme_to_sr conduit end
add_interface_port pme_to_sr pme_to_sr interconect Output 1
set_port_property pme_to_sr TERMINATION true


add_interface powerdown0_ext conduit end
add_interface_port powerdown0_ext powerdown0_ext interconect Output 2

add_interface powerdown1_ext conduit end
add_interface_port powerdown1_ext powerdown1_ext interconect Output 2

add_interface powerdown2_ext conduit end
add_interface_port powerdown2_ext powerdown2_ext interconect Output 2

add_interface powerdown3_ext conduit end
add_interface_port powerdown3_ext powerdown3_ext interconect Output 2

add_interface powerdown4_ext conduit end
add_interface_port powerdown4_ext powerdown4_ext interconect Output 2

add_interface powerdown5_ext conduit end
add_interface_port powerdown5_ext powerdown5_ext interconect Output 2

add_interface powerdown6_ext conduit end
add_interface_port powerdown6_ext powerdown6_ext interconect Output 2

add_interface powerdown7_ext conduit end
add_interface_port powerdown7_ext powerdown7_ext interconect Output 2

add_interface r2c_err0 conduit end
add_interface_port r2c_err0 r2c_err0 interconect Output 1
set_port_property r2c_err0 TERMINATION true

add_interface r2c_err1 conduit end
add_interface_port r2c_err1 r2c_err1 interconect Output 1
set_port_property r2c_err1 TERMINATION true

add_interface rate_ext conduit end
add_interface_port rate_ext rate_ext interconect Output 1

add_interface rc_gxb_powerdown conduit end
add_interface_port rc_gxb_powerdown rc_gxb_powerdown interconect Output 1
set_port_property rc_gxb_powerdown TERMINATION true


add_interface rc_rx_analogreset conduit end
add_interface_port rc_rx_analogreset rc_rx_analogreset interconect Output 1

add_interface rc_rx_digitalreset conduit end
add_interface_port rc_rx_digitalreset rc_rx_digitalreset interconect Output 1

add_interface rc_tx_digitalreset conduit end
add_interface_port rc_tx_digitalreset rc_tx_digitalreset interconect Output 1
set_port_property rc_tx_digitalreset TERMINATION true

add_interface reset_status conduit end
add_interface_port reset_status reset_status interconect Output 1
set_port_property reset_status TERMINATION true

add_interface rx_fifo_empty0 conduit end
add_interface_port rx_fifo_empty0 rx_fifo_empty0 interconect Output 1
set_port_property rx_fifo_empty0 TERMINATION true

add_interface rx_fifo_empty1 conduit end
add_interface_port rx_fifo_empty1 rx_fifo_empty1 interconect Output 1
set_port_property rx_fifo_empty1 TERMINATION true

add_interface rx_fifo_full0 conduit end
add_interface_port rx_fifo_full0 rx_fifo_full0 interconect Output 1
set_port_property rx_fifo_full0 TERMINATION true

add_interface rx_fifo_full1 conduit end
add_interface_port rx_fifo_full1 rx_fifo_full1 interconect Output 1
set_port_property rx_fifo_full1 TERMINATION true

add_interface rx_st_bardec0 conduit end
add_interface_port rx_st_bardec0 rx_st_bardec0 interconect Output 8
set_port_property rx_st_bardec0 TERMINATION true

add_interface rx_st_bardec1 conduit end
add_interface_port rx_st_bardec1 rx_st_bardec1 interconect Output 8
set_port_property rx_st_bardec1 TERMINATION true


add_interface rx_st_be0 conduit end
add_interface_port rx_st_be0 rx_st_be0 interconect Output 8
set_port_property rx_st_be0 TERMINATION true

add_interface rx_st_be0_p1 conduit end
add_interface_port rx_st_be0_p1 rx_st_be0_p1 interconect Output 8
set_port_property rx_st_be0_p1 TERMINATION true

add_interface rx_st_be1 conduit end
add_interface_port rx_st_be1 rx_st_be1 interconect Output 8
set_port_property rx_st_be1 TERMINATION true

add_interface rx_st_be1_p1 conduit end
add_interface_port rx_st_be1_p1 rx_st_be1_p1 interconect Output 8
set_port_property rx_st_be1_p1 TERMINATION true

add_interface rx_st_data0 conduit end
add_interface_port rx_st_data0 rx_st_data0 interconect Output 64
set_port_property rx_st_data0 TERMINATION true

add_interface rx_st_data0_p1 conduit end
add_interface_port rx_st_data0_p1 rx_st_data0_p1 interconect Output 64
set_port_property rx_st_data0_p1 TERMINATION true


add_interface rx_st_data1 conduit end
add_interface_port rx_st_data1 rx_st_data1 interconect Output 64
set_port_property rx_st_data1 TERMINATION true

add_interface rx_st_data1_p1 conduit end
add_interface_port rx_st_data1_p1 rx_st_data1_p1 interconect Output 64
set_port_property rx_st_data1_p1 TERMINATION true

add_interface rx_st_eop0 conduit end
add_interface_port rx_st_eop0 rx_st_eop0 interconect Output 1
set_port_property rx_st_eop0 TERMINATION true

add_interface rx_st_eop0_p1 conduit end
add_interface_port rx_st_eop0_p1 rx_st_eop0_p1 interconect Output 1
set_port_property rx_st_eop0_p1 TERMINATION true

add_interface rx_st_eop1 conduit end
add_interface_port rx_st_eop1 rx_st_eop1 interconect Output 1
set_port_property rx_st_eop1 TERMINATION true

add_interface rx_st_eop1_p1 conduit end
add_interface_port rx_st_eop1_p1 rx_st_eop1_p1 interconect Output 1
set_port_property rx_st_eop1_p1 TERMINATION true

add_interface rx_st_err0 conduit end
add_interface_port rx_st_err0 rx_st_err0 interconect Output 1
set_port_property rx_st_err0 TERMINATION true

add_interface rx_st_err1 conduit end
add_interface_port rx_st_err1 rx_st_err1 interconect Output 1
set_port_property rx_st_err1 TERMINATION true

add_interface rx_st_sop0 conduit end
add_interface_port rx_st_sop0 rx_st_sop0 interconect Output 1
set_port_property rx_st_sop0 TERMINATION true

add_interface rx_st_sop0_p1 conduit end
add_interface_port rx_st_sop0_p1 rx_st_sop0_p1 interconect Output 1
set_port_property rx_st_sop0_p1 TERMINATION true

add_interface rx_st_sop1 conduit end
add_interface_port rx_st_sop1 rx_st_sop1 interconect Output 1
set_port_property rx_st_sop1 TERMINATION true

add_interface rx_st_sop1_p1 conduit end
add_interface_port rx_st_sop1_p1 rx_st_sop1_p1 interconect Output 1
set_port_property rx_st_sop1_p1 TERMINATION true

add_interface rx_st_valid0 conduit end
add_interface_port rx_st_valid0 rx_st_valid0 interconect Output 1
set_port_property rx_st_valid0 TERMINATION true

add_interface rx_st_valid1 conduit end
add_interface_port rx_st_valid1 rx_st_valid1 interconect Output 1
set_port_property rx_st_valid1 TERMINATION true

add_interface rxpolarity0_ext conduit end
add_interface_port rxpolarity0_ext rxpolarity0_ext interconect Output 1

add_interface rxpolarity1_ext conduit end
add_interface_port rxpolarity1_ext rxpolarity1_ext interconect Output 1

add_interface rxpolarity2_ext conduit end
add_interface_port rxpolarity2_ext rxpolarity2_ext interconect Output 1

add_interface rxpolarity3_ext conduit end
add_interface_port rxpolarity3_ext rxpolarity3_ext interconect Output 1

add_interface rxpolarity4_ext conduit end
add_interface_port rxpolarity4_ext rxpolarity4_ext interconect Output 1

add_interface rxpolarity5_ext conduit end
add_interface_port rxpolarity5_ext rxpolarity5_ext interconect Output 1

add_interface rxpolarity6_ext conduit end
add_interface_port rxpolarity6_ext rxpolarity6_ext interconect Output 1

add_interface rxpolarity7_ext conduit end
add_interface_port rxpolarity7_ext rxpolarity7_ext interconect Output 1

add_interface serr_out conduit end
add_interface_port serr_out serr_out interconect Output 1
set_port_property serr_out TERMINATION true

add_interface suc_spd_neg conduit end
add_interface_port suc_spd_neg suc_spd_neg interconect Output 1
set_port_property suc_spd_neg TERMINATION true

add_interface swdn_wake conduit end
add_interface_port swdn_wake swdn_wake interconect Output 1
set_port_property swdn_wake TERMINATION true

add_interface swup_hotrst conduit end
add_interface_port swup_hotrst swup_hotrst interconect Output 1
set_port_property swup_hotrst TERMINATION true

#add_interface test_out conduit end
#add_interface_port test_out test_out export Output 64
#
#add_interface test_out9 conduit end
#add_interface_port test_out9 test_out9 interconect output
#set_port_property test_out9 FRAGMENT_LIST {dl_ltssm, lane_act}


add_interface tl_cfg_add conduit end
add_interface_port tl_cfg_add tl_cfg_add interconect Output 4
set_port_property tl_cfg_add TERMINATION true

add_interface tl_cfg_ctl conduit end
add_interface_port tl_cfg_ctl tl_cfg_ctl interconect Output 32
set_port_property tl_cfg_ctl TERMINATION true

add_interface tl_cfg_ctl_wr conduit end
add_interface_port tl_cfg_ctl_wr tl_cfg_ctl_wr interconect Output 1
set_port_property tl_cfg_ctl_wr TERMINATION true

add_interface tl_cfg_sts conduit end
add_interface_port tl_cfg_sts tl_cfg_sts interconect Output 53
set_port_property tl_cfg_sts TERMINATION true

add_interface tl_cfg_sts_wr conduit end
add_interface_port tl_cfg_sts_wr tl_cfg_sts_wr interconect Output 1
set_port_property tl_cfg_sts_wr TERMINATION true

add_interface tlbp_dl_ack_phypm conduit end
add_interface_port tlbp_dl_ack_phypm tlbp_dl_ack_phypm interconect Output 2
set_port_property tlbp_dl_ack_phypm TERMINATION true

add_interface tlbp_dl_ack_requpfc conduit end
add_interface_port tlbp_dl_ack_requpfc tlbp_dl_ack_requpfc interconect Output 1
set_port_property tlbp_dl_ack_requpfc TERMINATION true

add_interface tlbp_dl_ack_sndupfc conduit end
add_interface_port tlbp_dl_ack_sndupfc tlbp_dl_ack_sndupfc interconect Output 1
set_port_property tlbp_dl_ack_sndupfc TERMINATION true

add_interface tlbp_dl_current_deemp conduit end
add_interface_port tlbp_dl_current_deemp tlbp_dl_current_deemp interconect Output 1
set_port_property tlbp_dl_current_deemp TERMINATION true

add_interface tlbp_dl_currentspeed conduit end
add_interface_port tlbp_dl_currentspeed tlbp_dl_currentspeed interconect Output 2
set_port_property tlbp_dl_currentspeed TERMINATION true

add_interface tlbp_dl_dll_req conduit end
add_interface_port tlbp_dl_dll_req tlbp_dl_dll_req interconect Output 1
set_port_property tlbp_dl_dll_req TERMINATION true

add_interface tlbp_dl_err_dll conduit end
add_interface_port tlbp_dl_err_dll tlbp_dl_err_dll interconect Output 5
set_port_property tlbp_dl_err_dll TERMINATION true

add_interface tlbp_dl_errphy conduit end
add_interface_port tlbp_dl_errphy tlbp_dl_errphy interconect Output 1
set_port_property tlbp_dl_errphy TERMINATION true

add_interface tlbp_dl_link_autobdw_status conduit end
add_interface_port tlbp_dl_link_autobdw_status tlbp_dl_link_autobdw_status interconect Output 1
set_port_property tlbp_dl_link_autobdw_status TERMINATION true

add_interface tlbp_dl_link_bdwmng_status conduit end
add_interface_port tlbp_dl_link_bdwmng_status tlbp_dl_link_bdwmng_status interconect Output 1
set_port_property tlbp_dl_link_bdwmng_status TERMINATION true

add_interface tlbp_dl_rpbuf_emp conduit end
add_interface_port tlbp_dl_rpbuf_emp tlbp_dl_rpbuf_emp interconect Output 1
set_port_property tlbp_dl_rpbuf_emp TERMINATION true

add_interface tlbp_dl_rst_enter_comp_bit conduit end
add_interface_port tlbp_dl_rst_enter_comp_bit tlbp_dl_rst_enter_comp_bit interconect Output 1
set_port_property tlbp_dl_rst_enter_comp_bit TERMINATION true

add_interface tlbp_dl_rst_tx_margin_field conduit end
add_interface_port tlbp_dl_rst_tx_margin_field tlbp_dl_rst_tx_margin_field interconect Output 1
set_port_property tlbp_dl_rst_tx_margin_field TERMINATION true

add_interface tlbp_dl_rx_typ_pm conduit end
add_interface_port tlbp_dl_rx_typ_pm tlbp_dl_rx_typ_pm interconect Output 3
set_port_property tlbp_dl_rx_typ_pm TERMINATION true

add_interface tlbp_dl_rx_valpm conduit end
add_interface_port tlbp_dl_rx_valpm tlbp_dl_rx_valpm interconect Output 1
set_port_property tlbp_dl_rx_valpm TERMINATION true

add_interface tlbp_dl_tx_ackpm conduit end
add_interface_port tlbp_dl_tx_ackpm tlbp_dl_tx_ackpm interconect Output 1
set_port_property tlbp_dl_tx_ackpm TERMINATION true

add_interface tlbp_dl_up conduit end
add_interface_port tlbp_dl_up tlbp_dl_up interconect Output 1
set_port_property tlbp_dl_up TERMINATION true

add_interface tlbp_dl_vc_status conduit end
add_interface_port tlbp_dl_vc_status tlbp_dl_vc_status interconect Output 8
set_port_property tlbp_dl_vc_status TERMINATION true

add_interface tlbp_link_up conduit end
add_interface_port tlbp_link_up tlbp_link_up interconect Output 1
set_port_property tlbp_link_up TERMINATION true

add_interface tx_cred0 conduit end
add_interface_port tx_cred0 tx_cred0 interconect Output 36
set_port_property tx_cred0 TERMINATION true

add_interface tx_cred1 conduit end
add_interface_port tx_cred1 tx_cred1 interconect Output 36
set_port_property tx_cred1 TERMINATION true

add_interface tx_fifo_empty0 conduit end
add_interface_port tx_fifo_empty0 tx_fifo_empty0 interconect Output 1
set_port_property tx_fifo_empty0 TERMINATION true

add_interface tx_fifo_empty1 conduit end
add_interface_port tx_fifo_empty1 tx_fifo_empty1 interconect Output 1
set_port_property tx_fifo_empty1 TERMINATION true

add_interface tx_fifo_full0 conduit end
add_interface_port tx_fifo_full0 tx_fifo_full0 interconect Output 1
set_port_property tx_fifo_full0 TERMINATION true

add_interface tx_fifo_full1 conduit end
add_interface_port tx_fifo_full1 tx_fifo_full1 interconect Output 1
set_port_property tx_fifo_full1 TERMINATION true

add_interface tx_fifo_rdptr0 conduit end
add_interface_port tx_fifo_rdptr0 tx_fifo_rdptr0 interconect Output 4
set_port_property tx_fifo_rdptr0 TERMINATION true

add_interface tx_fifo_rdptr1 conduit end
add_interface_port tx_fifo_rdptr1 tx_fifo_rdptr1 interconect Output 4
set_port_property tx_fifo_rdptr1 TERMINATION true

add_interface tx_fifo_wrptr0 conduit end
add_interface_port tx_fifo_wrptr0 tx_fifo_wrptr0 interconect Output 4
set_port_property tx_fifo_wrptr0 TERMINATION true

add_interface tx_fifo_wrptr1 conduit end
add_interface_port tx_fifo_wrptr1 tx_fifo_wrptr1 interconect Output 4
set_port_property tx_fifo_wrptr1 TERMINATION true

add_interface tx_st_ready0 conduit end
add_interface_port tx_st_ready0 tx_st_ready0 interconect Output 1
set_port_property tx_st_ready0 TERMINATION true

add_interface tx_st_ready1 conduit end
add_interface_port tx_st_ready1 tx_st_ready1 interconect Output 1
set_port_property tx_st_ready1 TERMINATION true

add_interface txcompl0_ext conduit end
add_interface_port txcompl0_ext txcompl0_ext interconect Output 1

add_interface txcompl1_ext conduit end
add_interface_port txcompl1_ext txcompl1_ext interconect Output 1

add_interface txcompl2_ext conduit end
add_interface_port txcompl2_ext txcompl2_ext interconect Output 1

add_interface txcompl3_ext conduit end
add_interface_port txcompl3_ext txcompl3_ext interconect Output 1

add_interface txcompl4_ext conduit end
add_interface_port txcompl4_ext txcompl4_ext interconect Output 1

add_interface txcompl5_ext conduit end
add_interface_port txcompl5_ext txcompl5_ext interconect Output 1

add_interface txcompl6_ext conduit end
add_interface_port txcompl6_ext txcompl6_ext interconect Output 1

add_interface txcompl7_ext conduit end
add_interface_port txcompl7_ext txcompl7_ext interconect Output 1

add_interface txdata0_ext conduit end
add_interface_port txdata0_ext txdata0_ext interconect Output 8

add_interface txdata1_ext conduit end
add_interface_port txdata1_ext txdata1_ext interconect Output 8

add_interface txdata2_ext conduit end
add_interface_port txdata2_ext txdata2_ext interconect Output 8

add_interface txdata3_ext conduit end
add_interface_port txdata3_ext txdata3_ext interconect Output 8

add_interface txdata4_ext conduit end
add_interface_port txdata4_ext txdata4_ext interconect Output 8

add_interface txdata5_ext conduit end
add_interface_port txdata5_ext txdata5_ext interconect Output 8

add_interface txdata6_ext conduit end
add_interface_port txdata6_ext txdata6_ext interconect Output 8

add_interface txdata7_ext conduit end
add_interface_port txdata7_ext txdata7_ext interconect Output 8

add_interface txdatak0_ext conduit end
add_interface_port txdatak0_ext txdatak0_ext interconect Output 1

add_interface txdatak1_ext conduit end
add_interface_port txdatak1_ext txdatak1_ext interconect Output 1

add_interface txdatak2_ext conduit end
add_interface_port txdatak2_ext txdatak2_ext interconect Output 1

add_interface txdatak3_ext conduit end
add_interface_port txdatak3_ext txdatak3_ext interconect Output 1

add_interface txdatak4_ext conduit end
add_interface_port txdatak4_ext txdatak4_ext interconect Output 1

add_interface txdatak5_ext conduit end
add_interface_port txdatak5_ext txdatak5_ext interconect Output 1

add_interface txdatak6_ext conduit end
add_interface_port txdatak6_ext txdatak6_ext interconect Output 1

add_interface txdatak7_ext conduit end
add_interface_port txdatak7_ext txdatak7_ext interconect Output 1

add_interface txdetectrx0_ext conduit end
add_interface_port txdetectrx0_ext txdetectrx0_ext interconect Output 1

add_interface txdetectrx1_ext conduit end
add_interface_port txdetectrx1_ext txdetectrx1_ext interconect Output 1

add_interface txdetectrx2_ext conduit end
add_interface_port txdetectrx2_ext txdetectrx2_ext interconect Output 1

add_interface txdetectrx3_ext conduit end
add_interface_port txdetectrx3_ext txdetectrx3_ext interconect Output 1

add_interface txdetectrx4_ext conduit end
add_interface_port txdetectrx4_ext txdetectrx4_ext interconect Output 1

add_interface txdetectrx5_ext conduit end
add_interface_port txdetectrx5_ext txdetectrx5_ext interconect Output 1

add_interface txdetectrx6_ext conduit end
add_interface_port txdetectrx6_ext txdetectrx6_ext interconect Output 1

add_interface txdetectrx7_ext conduit end
add_interface_port txdetectrx7_ext txdetectrx7_ext interconect Output 1

add_interface txelecidle0_ext conduit end
add_interface_port txelecidle0_ext txelecidle0_ext interconect Output 1

add_interface txelecidle1_ext conduit end
add_interface_port txelecidle1_ext txelecidle1_ext interconect Output 1

add_interface txelecidle2_ext conduit end
add_interface_port txelecidle2_ext txelecidle2_ext interconect Output 1

add_interface txelecidle3_ext conduit end
add_interface_port txelecidle3_ext txelecidle3_ext interconect Output 1

add_interface txelecidle4_ext conduit end
add_interface_port txelecidle4_ext txelecidle4_ext interconect Output 1

add_interface txelecidle5_ext conduit end
add_interface_port txelecidle5_ext txelecidle5_ext interconect Output 1

add_interface txelecidle6_ext conduit end
add_interface_port txelecidle6_ext txelecidle6_ext interconect Output 1

add_interface txelecidle7_ext conduit end
add_interface_port txelecidle7_ext txelecidle7_ext interconect Output 1

add_interface use_pcie_reconfig conduit end
add_interface_port use_pcie_reconfig use_pcie_reconfig interconect Output 1
set_port_property use_pcie_reconfig TERMINATION true

add_interface wake_oen conduit end
add_interface_port wake_oen wake_oen interconect Output 1
set_port_property wake_oen TERMINATION true




add_interface aer_msi_num conduit end
add_interface_port aer_msi_num aer_msi_num interconect input 5
set_port_property aer_msi_num TERMINATION true
set_port_property aer_msi_num TERMINATION_VALUE 0

add_interface app_int_sts conduit end
add_interface_port app_int_sts app_int_sts interconect input 1
set_port_property app_int_sts TERMINATION true
set_port_property app_int_sts TERMINATION_VALUE 0

add_interface app_msi_num conduit end
add_interface_port app_msi_num app_msi_num interconect input 5
set_port_property app_msi_num TERMINATION true
set_port_property app_msi_num TERMINATION_VALUE 0

add_interface app_msi_req conduit end
add_interface_port app_msi_req app_msi_req interconect input 1
set_port_property app_msi_req TERMINATION true
set_port_property app_msi_req TERMINATION_VALUE 0

add_interface app_msi_tc conduit end
add_interface_port app_msi_tc app_msi_tc interconect input 3
set_port_property app_msi_tc TERMINATION true
set_port_property app_msi_tc TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_address conduit end
add_interface_port avs_pcie_reconfig_address avs_pcie_reconfig_address interconect input 8
set_port_property avs_pcie_reconfig_address TERMINATION true
set_port_property avs_pcie_reconfig_address TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_chipselect conduit end
add_interface_port avs_pcie_reconfig_chipselect avs_pcie_reconfig_chipselect interconect input 1
set_port_property avs_pcie_reconfig_chipselect TERMINATION true
set_port_property avs_pcie_reconfig_chipselect TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_clk conduit end
add_interface_port avs_pcie_reconfig_clk avs_pcie_reconfig_clk interconect input 1
set_port_property avs_pcie_reconfig_clk TERMINATION true
set_port_property avs_pcie_reconfig_clk TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_read conduit end
add_interface_port avs_pcie_reconfig_read avs_pcie_reconfig_read interconect input 1
set_port_property avs_pcie_reconfig_read TERMINATION true
set_port_property avs_pcie_reconfig_read TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_rstn conduit end
add_interface_port avs_pcie_reconfig_rstn avs_pcie_reconfig_rstn interconect input 1
set_port_property avs_pcie_reconfig_rstn TERMINATION true
set_port_property avs_pcie_reconfig_rstn TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_write conduit end
add_interface_port avs_pcie_reconfig_write avs_pcie_reconfig_write interconect input 1
set_port_property avs_pcie_reconfig_write TERMINATION true
set_port_property avs_pcie_reconfig_write TERMINATION_VALUE 0

add_interface avs_pcie_reconfig_writedata conduit end
add_interface_port avs_pcie_reconfig_writedata avs_pcie_reconfig_writedata interconect input 16
set_port_property avs_pcie_reconfig_writedata TERMINATION true
set_port_property avs_pcie_reconfig_writedata TERMINATION_VALUE 0

add_interface core_clk_in conduit end
add_interface_port core_clk_in core_clk_in interconect input 1
set_port_property core_clk_in TERMINATION true
set_port_property core_clk_in TERMINATION_VALUE 0

add_interface cpl_err conduit end
add_interface_port cpl_err cpl_err interconect input 7
set_port_property cpl_err TERMINATION true
set_port_property cpl_err TERMINATION_VALUE 0

add_interface cpl_pending conduit end
add_interface_port cpl_pending cpl_pending interconect input 1
set_port_property cpl_pending TERMINATION true
set_port_property cpl_pending TERMINATION_VALUE 0

add_interface crst conduit end
add_interface_port crst crst interconect input 1

add_interface dbg_pipex1_rx conduit end
add_interface_port dbg_pipex1_rx dbg_pipex1_rx interconect input 15
set_port_property dbg_pipex1_rx TERMINATION true
set_port_property dbg_pipex1_rx TERMINATION_VALUE 0

add_interface hpg_ctrler conduit end
add_interface_port hpg_ctrler hpg_ctrler interconect input 5
set_port_property hpg_ctrler TERMINATION true
set_port_property hpg_ctrler TERMINATION_VALUE 0

add_interface lmi_addr conduit end
add_interface_port lmi_addr lmi_addr interconect input 12
set_port_property lmi_addr TERMINATION true
set_port_property lmi_addr TERMINATION_VALUE 0

add_interface lmi_din conduit end
add_interface_port lmi_din lmi_din interconect input 32
set_port_property lmi_din TERMINATION true
set_port_property lmi_din TERMINATION_VALUE 0

add_interface lmi_rden conduit end
add_interface_port lmi_rden lmi_rden interconect input 1
set_port_property lmi_rden TERMINATION true
set_port_property lmi_rden TERMINATION_VALUE 0

add_interface lmi_wren conduit end
add_interface_port lmi_wren lmi_wren interconect input 1
set_port_property lmi_wren TERMINATION true
set_port_property lmi_wren TERMINATION_VALUE 0

add_interface mode conduit end
add_interface_port mode mode interconect input 2
set_port_property mode TERMINATION true
set_port_property mode TERMINATION_VALUE 0

add_interface pclk_central conduit end
add_interface_port pclk_central pclk_central interconect input 1

add_interface pclk_ch0 conduit end
add_interface_port pclk_ch0 pclk_ch0 interconect input 1

add_interface pex_msi_num conduit end
add_interface_port pex_msi_num pex_msi_num interconect input 5
set_port_property pex_msi_num TERMINATION true
set_port_property pex_msi_num TERMINATION_VALUE 0

add_interface pld_clk clock end
add_interface_port pld_clk pld_clk clk input 1

add_interface pll_fixed_clk conduit end
add_interface_port pll_fixed_clk pll_fixed_clk interconect input 1

add_interface pm_auxpwr conduit end
add_interface_port pm_auxpwr pm_auxpwr interconect input 1
set_port_property pm_auxpwr TERMINATION true
set_port_property pm_auxpwr TERMINATION_VALUE 0

add_interface pm_data conduit end
add_interface_port pm_data pm_data interconect input 10
set_port_property pm_data TERMINATION true
set_port_property pm_data TERMINATION_VALUE 0

add_interface pm_event conduit end
add_interface_port pm_event pm_event interconect input 1
set_port_property pm_event TERMINATION true
set_port_property pm_event TERMINATION_VALUE 0

add_interface pme_to_cr conduit end
add_interface_port pme_to_cr pme_to_cr interconect input 1
set_port_property pme_to_cr TERMINATION true
set_port_property pme_to_cr TERMINATION_VALUE 0

add_interface rc_areset conduit end
add_interface_port rc_areset rc_areset interconect input 1

add_interface rc_inclk_eq_125mhz conduit end
add_interface_port rc_inclk_eq_125mhz rc_inclk_eq_125mhz interconect input 1
set_port_property rc_inclk_eq_125mhz TERMINATION true
set_port_property rc_inclk_eq_125mhz TERMINATION_VALUE 0

add_interface rc_pll_locked conduit end
add_interface_port rc_pll_locked rc_pll_locked interconect input 1   
set_port_property rc_pll_locked TERMINATION true   
set_port_property rc_pll_locked TERMINATION_VALUE 1

add_interface rc_rx_pll_locked_one conduit end
add_interface_port rc_rx_pll_locked_one rc_rx_pll_locked_one interconect input 1
set_port_property rc_rx_pll_locked_one TERMINATION true
set_port_property rc_rx_pll_locked_one TERMINATION_VALUE 1

add_interface rx_st_mask0 conduit end
add_interface_port rx_st_mask0 rx_st_mask0 interconect input 1
set_port_property rx_st_mask0 TERMINATION true
set_port_property rx_st_mask0 TERMINATION_VALUE 0

add_interface rx_st_mask1 conduit end
add_interface_port rx_st_mask1 rx_st_mask1 interconect input 1
set_port_property rx_st_mask1 TERMINATION true
set_port_property rx_st_mask1 TERMINATION_VALUE 0

add_interface rx_st_ready0 conduit end
add_interface_port rx_st_ready0 rx_st_ready0 interconect input 1
set_port_property rx_st_ready0 TERMINATION true
set_port_property rx_st_ready0 TERMINATION_VALUE 0

add_interface rx_st_ready1 conduit end
add_interface_port rx_st_ready1 rx_st_ready1 interconect input 1
set_port_property rx_st_ready1 TERMINATION true
set_port_property rx_st_ready1 TERMINATION_VALUE 0

add_interface srst conduit end
add_interface_port srst srst interconect input 1

add_interface swdn_in conduit end
add_interface_port swdn_in swdn_in interconect input 3
set_port_property swdn_in TERMINATION true
set_port_property swdn_in TERMINATION_VALUE 0

add_interface swup_in conduit end
add_interface_port swup_in swup_in interconect input 7
set_port_property swup_in TERMINATION true
set_port_property swup_in TERMINATION_VALUE 0

add_interface test_in conduit end
add_interface_port test_in test_in interconect input 40

add_interface tl_slotclk_cfg conduit end
add_interface_port tl_slotclk_cfg tl_slotclk_cfg interconect input 1
set_port_property tl_slotclk_cfg TERMINATION true
set_port_property tl_slotclk_cfg TERMINATION_VALUE 0

add_interface tlbp_dl_aspm_cr0 conduit end
add_interface_port tlbp_dl_aspm_cr0 tlbp_dl_aspm_cr0 interconect input 1
set_port_property tlbp_dl_aspm_cr0 TERMINATION true
set_port_property tlbp_dl_aspm_cr0 TERMINATION_VALUE 0

add_interface tlbp_dl_comclk_reg conduit end
add_interface_port tlbp_dl_comclk_reg tlbp_dl_comclk_reg interconect input 1
set_port_property tlbp_dl_comclk_reg TERMINATION true
set_port_property tlbp_dl_comclk_reg TERMINATION_VALUE 0

add_interface tlbp_dl_ctrl_link2 conduit end
add_interface_port tlbp_dl_ctrl_link2 tlbp_dl_ctrl_link2 interconect input 13
set_port_property tlbp_dl_ctrl_link2 TERMINATION true
set_port_property tlbp_dl_ctrl_link2 TERMINATION_VALUE 0

add_interface tlbp_dl_data_upfc conduit end
add_interface_port tlbp_dl_data_upfc tlbp_dl_data_upfc interconect input 12
set_port_property tlbp_dl_data_upfc TERMINATION true
set_port_property tlbp_dl_data_upfc TERMINATION_VALUE 0

add_interface tlbp_dl_hdr_upfc conduit end
add_interface_port tlbp_dl_hdr_upfc tlbp_dl_hdr_upfc interconect input 8
set_port_property tlbp_dl_hdr_upfc TERMINATION true
set_port_property tlbp_dl_hdr_upfc TERMINATION_VALUE 0

add_interface tlbp_dl_inh_dllp conduit end
add_interface_port tlbp_dl_inh_dllp tlbp_dl_inh_dllp interconect input 1
set_port_property tlbp_dl_inh_dllp TERMINATION true
set_port_property tlbp_dl_inh_dllp TERMINATION_VALUE 0

add_interface tlbp_dl_maxpload_dcr conduit end
add_interface_port tlbp_dl_maxpload_dcr tlbp_dl_maxpload_dcr interconect input 3
set_port_property tlbp_dl_maxpload_dcr TERMINATION true
set_port_property tlbp_dl_maxpload_dcr TERMINATION_VALUE 0

add_interface tlbp_dl_req_phycfg conduit end
add_interface_port tlbp_dl_req_phycfg tlbp_dl_req_phycfg interconect input 4
set_port_property tlbp_dl_req_phycfg TERMINATION true
set_port_property tlbp_dl_req_phycfg TERMINATION_VALUE 0

add_interface tlbp_dl_req_phypm conduit end
add_interface_port tlbp_dl_req_phypm tlbp_dl_req_phypm interconect input 4
set_port_property tlbp_dl_req_phypm TERMINATION true
set_port_property tlbp_dl_req_phypm TERMINATION_VALUE 0

add_interface tlbp_dl_req_upfc conduit end
add_interface_port tlbp_dl_req_upfc tlbp_dl_req_upfc interconect input 1
set_port_property tlbp_dl_req_upfc TERMINATION true
set_port_property tlbp_dl_req_upfc TERMINATION_VALUE 0

add_interface tlbp_dl_req_wake conduit end
add_interface_port tlbp_dl_req_wake tlbp_dl_req_wake interconect input 1
set_port_property tlbp_dl_req_wake TERMINATION true
set_port_property tlbp_dl_req_wake TERMINATION_VALUE 0

add_interface tlbp_dl_rx_ecrcchk conduit end
add_interface_port tlbp_dl_rx_ecrcchk tlbp_dl_rx_ecrcchk interconect input 1
set_port_property tlbp_dl_rx_ecrcchk TERMINATION true
set_port_property tlbp_dl_rx_ecrcchk TERMINATION_VALUE 0

add_interface tlbp_dl_snd_upfc conduit end
add_interface_port tlbp_dl_snd_upfc tlbp_dl_snd_upfc interconect input 1
set_port_property tlbp_dl_snd_upfc TERMINATION true
set_port_property tlbp_dl_snd_upfc TERMINATION_VALUE 0

add_interface tlbp_dl_tx_reqpm conduit end
add_interface_port tlbp_dl_tx_reqpm tlbp_dl_tx_reqpm interconect input 1
set_port_property tlbp_dl_tx_reqpm TERMINATION true
set_port_property tlbp_dl_tx_reqpm TERMINATION_VALUE 0

add_interface tlbp_dl_tx_typpm conduit end
add_interface_port tlbp_dl_tx_typpm tlbp_dl_tx_typpm interconect input 3
set_port_property tlbp_dl_tx_typpm TERMINATION true
set_port_property tlbp_dl_tx_typpm TERMINATION_VALUE 0

add_interface tlbp_dl_txcfg_extsy conduit end
add_interface_port tlbp_dl_txcfg_extsy tlbp_dl_txcfg_extsy interconect input 1
set_port_property tlbp_dl_txcfg_extsy TERMINATION true
set_port_property tlbp_dl_txcfg_extsy TERMINATION_VALUE 0

add_interface tlbp_dl_typ_upfc conduit end
add_interface_port tlbp_dl_typ_upfc tlbp_dl_typ_upfc interconect input 2
set_port_property tlbp_dl_typ_upfc TERMINATION true
set_port_property tlbp_dl_typ_upfc TERMINATION_VALUE 0

add_interface tlbp_dl_vc_ctrl conduit end
add_interface_port tlbp_dl_vc_ctrl tlbp_dl_vc_ctrl interconect input 8
set_port_property tlbp_dl_vc_ctrl TERMINATION true
set_port_property tlbp_dl_vc_ctrl TERMINATION_VALUE 0

add_interface tlbp_dl_vcid_map conduit end
add_interface_port tlbp_dl_vcid_map tlbp_dl_vcid_map interconect input 24
set_port_property tlbp_dl_vcid_map TERMINATION true
set_port_property tlbp_dl_vcid_map TERMINATION_VALUE 0

add_interface tlbp_dl_vcid_upfc conduit end
add_interface_port tlbp_dl_vcid_upfc tlbp_dl_vcid_upfc interconect input 3
set_port_property tlbp_dl_vcid_upfc TERMINATION true
set_port_property tlbp_dl_vcid_upfc TERMINATION_VALUE 0

add_interface tx_st_data0 conduit end
add_interface_port tx_st_data0 tx_st_data0 interconect input 64
set_port_property tx_st_data0 TERMINATION true
set_port_property tx_st_data0 TERMINATION_VALUE 0

add_interface tx_st_data0_p1 conduit end
add_interface_port tx_st_data0_p1 tx_st_data0_p1 interconect input 64
set_port_property tx_st_data0_p1 TERMINATION true
set_port_property tx_st_data0_p1 TERMINATION_VALUE 0

add_interface tx_st_data1 conduit end
add_interface_port tx_st_data1 tx_st_data1 interconect input 64
set_port_property tx_st_data1 TERMINATION true
set_port_property tx_st_data1 TERMINATION_VALUE 0

add_interface tx_st_data1_p1 conduit end
add_interface_port tx_st_data1_p1 tx_st_data1_p1 interconect input 64
set_port_property tx_st_data1_p1 TERMINATION true
set_port_property tx_st_data1_p1 TERMINATION_VALUE 0

add_interface tx_st_eop0 conduit end
add_interface_port tx_st_eop0 tx_st_eop0 interconect input 1
set_port_property tx_st_eop0 TERMINATION true
set_port_property tx_st_eop0 TERMINATION_VALUE 0

add_interface tx_st_eop0_p1 conduit end
add_interface_port tx_st_eop0_p1 tx_st_eop0_p1 interconect input 1
set_port_property tx_st_eop0_p1 TERMINATION true
set_port_property tx_st_eop0_p1 TERMINATION_VALUE 0

add_interface tx_st_eop1 conduit end
add_interface_port tx_st_eop1 tx_st_eop1 interconect input 1
set_port_property tx_st_eop1 TERMINATION true
set_port_property tx_st_eop1 TERMINATION_VALUE 0

add_interface tx_st_eop1_p1 conduit end
add_interface_port tx_st_eop1_p1 tx_st_eop1_p1 interconect input 1
set_port_property tx_st_eop1_p1 TERMINATION true
set_port_property tx_st_eop1_p1 TERMINATION_VALUE 0

add_interface tx_st_err0 conduit end
add_interface_port tx_st_err0 tx_st_err0 interconect input 1
set_port_property tx_st_err0 TERMINATION true
set_port_property tx_st_err0 TERMINATION_VALUE 0

add_interface tx_st_err1 conduit end
add_interface_port tx_st_err1 tx_st_err1 interconect input 1
set_port_property tx_st_err1 TERMINATION true
set_port_property tx_st_err1 TERMINATION_VALUE 0

add_interface tx_st_sop0 conduit end
add_interface_port tx_st_sop0 tx_st_sop0 interconect input 1
set_port_property tx_st_sop0 TERMINATION true
set_port_property tx_st_sop0 TERMINATION_VALUE 0

add_interface tx_st_sop0_p1 conduit end
add_interface_port tx_st_sop0_p1 tx_st_sop0_p1 interconect input 1
set_port_property tx_st_sop0_p1 TERMINATION true
set_port_property tx_st_sop0_p1 TERMINATION_VALUE 0

add_interface tx_st_sop1 conduit end
add_interface_port tx_st_sop1 tx_st_sop1 interconect input 1
set_port_property tx_st_sop1 TERMINATION true
set_port_property tx_st_sop1 TERMINATION_VALUE 0

add_interface tx_st_sop1_p1 conduit end
add_interface_port tx_st_sop1_p1 tx_st_sop1_p1 interconect input 1
set_port_property tx_st_sop1_p1 TERMINATION true
set_port_property tx_st_sop1_p1 TERMINATION_VALUE 0

add_interface tx_st_valid0 conduit end
add_interface_port tx_st_valid0 tx_st_valid0 interconect input 1
set_port_property tx_st_valid0 TERMINATION true
set_port_property tx_st_valid0 TERMINATION_VALUE 0

add_interface tx_st_valid1 conduit end
add_interface_port tx_st_valid1 tx_st_valid1 interconect input 1
set_port_property tx_st_valid1 TERMINATION true
set_port_property tx_st_valid1 TERMINATION_VALUE 0


# +-----------------------------------
# | connection point avalon_clk
# |

add_interface avalon_clk clock end
add_interface_port avalon_clk AvlClk_i clk Input 1

add_interface avalon_reset reset end avalon_clk
add_interface_port avalon_reset Rstn_i reset_n Input 1
set_interface_property avalon_reset synchronousEdges both



# +-----------------------------------
# | connection point Txs Slave
# |
# Interface Txs Slave

add_interface "Txs" "avalon" "slave" "avalon_clk"
set_interface_property "Txs" "addressAlignment" "DYNAMIC"
set_interface_property "Txs" "interleaveBursts" "false"
set_interface_property "Txs" "readLatency" "0"
set_interface_property "Txs" "writeWaitTime" "1"
set_interface_property "Txs" "readWaitTime" "1"
set_interface_property "Txs" "addressUnits" "SYMBOLS"
 set_interface_property "Txs" "maximumPendingReadTransactions" 8

add_interface_port "Txs" "TxsAddress_i" "address" "input" 28
add_interface_port "Txs" "TxsChipSelect_i" "chipselect" "input" 1
add_interface_port "Txs" "TxsByteEnable_i" "byteenable" "input" 8
add_interface_port "Txs" "TxsReadData_o" "readdata" "output" 64
add_interface_port "Txs" "TxsWriteData_i" "writedata" "input" 64
add_interface_port "Txs" "TxsRead_i" "read" "input" 1
add_interface_port "Txs" "TxsWrite_i" "write" "input" 1
add_interface_port "Txs" "TxsBurstCount_i" "burstcount" "input" 7
add_interface_port "Txs" "TxsReadDataValid_o" "readdatavalid" "output" 1
add_interface_port "Txs" "TxsWaitRequest_o" "waitrequest" "output" 1

add_interface "Cra" "avalon" "slave" "avalon_clk"
#set_interface_property "Cra" "isNonVolatileStorage" "false"
#set_interface_property "Cra" "burstOnBurstBoundariesOnly" "false"
set_interface_property "Cra" "readLatency" "0"
set_interface_property "Cra" "addressAlignment" "DYNAMIC"
set_interface_property "Cra" "writeWaitTime" "1"
set_interface_property "Cra" "readWaitTime" "1"



# Ports in interface Cra
add_interface_port "Cra" "CraChipSelect_i" "chipselect" "input" 1
### TODO: Need to set setLowerBound(2)
add_interface_port "Cra" "CraAddress_i" "address" "input" 12
add_interface_port "Cra" "CraByteEnable_i" "byteenable" "input" 4
add_interface_port "Cra" "CraRead" "read" "input" 1
add_interface_port "Cra" "CraReadData_o" "readdata" "output" 32
add_interface_port "Cra" "CraWrite" "write" "input" 1
add_interface_port "Cra" "CraWriteData_i" "writedata" "input" 32
add_interface_port "Cra" "CraWaitRequest_o" "waitrequest" "output" 1

add_interface CraIrq interrupt sender
add_interface_port CraIrq CraIrq_o irq output 1
set_interface_property CraIrq associatedAddressablePoint Cra

# +-----------------------------------
# | connection point Prefetchable Avalon Master
# |
# Interface Prefetchable Master
proc add_master { master_name  rxm_data_width } {

        add_interface $master_name "avalon" "master" "avalon_clk"
        set_interface_property $master_name "interleaveBursts" "false"
        set_interface_property $master_name "doStreamReads" "false"
        set_interface_property $master_name "doStreamWrites" "false"
        set_interface_property $master_name "maxAddressWidth" 32
        set_interface_property $master_name "addressGroup" 1
        # Ports in interface $master_name
        add_interface_port $master_name "RxmAddress_o" "address" "output" 32
        add_interface_port $master_name "RxmRead_o" "read" "output" 1


        add_interface_port $master_name "RxmWaitRequest_i" "waitrequest" "input" 1
        add_interface_port $master_name "RxmWrite_o" "write" "output" 1


        add_interface_port $master_name "RxmReadDataValid_i" "readdatavalid" "input" 1
        if { $rxm_data_width == 32 } {

            add_interface_port $master_name "RxmReadData_i" "readdata" "input" 32
            add_interface_port $master_name "RxmWriteData_o" "writedata" "output" 32
            add_interface_port $master_name "RxmByteEnable_o" "byteenable" "output" 4

           } else {
             add_interface_port $master_name "RxmReadData_i" "readdata" "input" 64
             add_interface_port $master_name "RxmWriteData_o" "writedata" "output" 64
             add_interface_port $master_name "RxmBurstCount_o" "burstcount" "output" 7
             add_interface_port $master_name "RxmByteEnable_o" "byteenable" "output" 8
               }

}



# +-----------------------------------
# | Elaboration Callback
# +-----------------------------------
proc elaborate {} {
# ++++++++++++++BG++++++++++++++++++++

        # You should grab all the parameters which are always used in the elaborate loop at the beginning
        # with the ultimate aim to reduce the number of calls to get_parameter_value
set my_link_common_clock [get_parameter_value link_common_clock]
set_port_property tl_slotclk_cfg TERMINATION_VALUE ${my_link_common_clock}
# ++++++++++++++BG++++++++++++++++++++

    # Grab Parameter Values
    set i_Cg_Avalon_S_Addr_Width [ get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS ]
    set CB_A2P_ADDR_MAP_PASS_THRU_BITS [get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS]
    set CB_A2P_ADDR_MAP_NUM_ENTRIES [get_parameter_value CB_A2P_ADDR_MAP_NUM_ENTRIES]
    set max_link_width [get_parameter_value max_link_width]
    set test_out_width [get_parameter_value p_pcie_test_out_width]


# +-----------------------------------
# | connection point pcie_core_clk
# |

set core_clk_freq [get_parameter_value core_clk_freq]
#send_message "info"  "core_clk_freq  is $core_clk_freq"
#send_message "info"  "core_clk_freq  is [expr ${core_clk_freq} * 100000 ]"

add_interface pcie_core_clk clock start
set_interface_property pcie_core_clk ENABLED false
set_interface_property pcie_core_clk clockRate [expr $core_clk_freq*100000]
set_interface_property pcie_core_clk clockRateKnown "true"
add_interface_port pcie_core_clk core_clk_out clk Output 1




for { set i $max_link_width } { $i < 8 } { incr i } {
        set_port_property rxpolarity${i}_ext TERMINATION true
        set_port_property txcompl${i}_ext TERMINATION true
        set_port_property powerdown${i}_ext TERMINATION true
        set_port_property txdetectrx${i}_ext TERMINATION true
        set_port_property txelecidle${i}_ext TERMINATION true
        set_port_property txdatak${i}_ext TERMINATION true
        set_port_property txdata${i}_ext TERMINATION true
        add_interface phystatus${i}_ext conduit end
        add_interface_port phystatus${i}_ext phystatus${i}_ext interconect input 1
        set_port_property phystatus${i}_ext TERMINATION true
        set_port_property phystatus${i}_ext TERMINATION_VALUE 0
        add_interface rxdata${i}_ext conduit end
        add_interface_port rxdata${i}_ext rxdata${i}_ext interconect input 8
        set_port_property rxdata${i}_ext TERMINATION true
        set_port_property rxdata${i}_ext TERMINATION_VALUE 0
        add_interface rxdatak${i}_ext conduit end
        add_interface_port rxdatak${i}_ext rxdatak${i}_ext interconect input 1
        set_port_property rxdatak${i}_ext TERMINATION true
        set_port_property rxdatak${i}_ext TERMINATION_VALUE 0
        add_interface rxelecidle${i}_ext conduit end
        add_interface_port rxelecidle${i}_ext rxelecidle${i}_ext interconect input 1
        set_port_property rxelecidle${i}_ext TERMINATION true
        set_port_property rxelecidle${i}_ext TERMINATION_VALUE 0
        add_interface rxstatus${i}_ext conduit end
        add_interface_port rxstatus${i}_ext rxstatus${i}_ext interconect input 3
        set_port_property rxstatus${i}_ext TERMINATION true
        set_port_property rxstatus${i}_ext TERMINATION_VALUE 0
        add_interface rxvalid${i}_ext conduit end
        add_interface_port rxvalid${i}_ext rxvalid${i}_ext interconect input 1
        set_port_property rxvalid${i}_ext TERMINATION true
        set_port_property rxvalid${i}_ext TERMINATION_VALUE 0

    }


 for { set i 0 } { $i < $max_link_width } { incr i } {
      add_interface eidle_infer_sel_${i} conduit end
      add_interface_port eidle_infer_sel_${i} eidle_infer_sel_${i} interconect output 3
      set_port_property eidle_infer_sel_${i} FRAGMENT_LIST "eidle_infer_sel([expr 3 * $i + 2]:[expr 3 * $i])"

      add_interface tx_deemph_${i} conduit end
      add_interface_port tx_deemph_${i} tx_deemph_${i} interconect output 1
      set_port_property tx_deemph_${i} FRAGMENT_LIST "tx_deemph(${i})"

      add_interface tx_margin_${i} conduit end
      add_interface_port tx_margin_${i} tx_margin_${i} interconect output 3
      set_port_property tx_margin_${i} FRAGMENT_LIST "tx_margin([expr 3 * $i + 2]:[expr 3 * $i])"

      add_interface phystatus${i}_ext conduit end
      add_interface_port phystatus${i}_ext phystatus${i}_ext interconect input 1

      add_interface rxdata${i}_ext conduit end
      add_interface_port rxdata${i}_ext rxdata${i}_ext interconect input 8

      add_interface rxdatak${i}_ext conduit end
      add_interface_port rxdatak${i}_ext rxdatak${i}_ext interconect input 1

      add_interface rxelecidle${i}_ext conduit end
      add_interface_port rxelecidle${i}_ext rxelecidle${i}_ext interconect input 1

      add_interface rxstatus${i}_ext conduit end
      add_interface_port rxstatus${i}_ext rxstatus${i}_ext interconect input 3

      add_interface rxvalid${i}_ext conduit end
      add_interface_port rxvalid${i}_ext rxvalid${i}_ext interconect input 1


}

    add_interface test_out_export conduit end


    if { $test_out_width == "64bits" } {
          add_interface_port test_out_export test_out test_out Output 64
        } elseif { $test_out_width == "9bits" } {
           add_interface_port test_out_export test_out test_out output 9
           set_port_property test_out FRAGMENT_LIST "lane_act(3:0) dl_ltssm(4:0)"
    }




### HN

 #   set usePcieCoreClock  [ get_parameter_value CG_COMMON_CLOCK_MODE ]
 #   if { $usePcieCoreClock == 0 } {
           set_interface_property pcie_core_clk ENABLED true
  #  } else {
  #     set_interface_property pcie_core_clk ENABLED false
  #  }

# ++++++++++++++BG++++++++++++++++++++

        # Is the CRA interface really transient within the HDL?  If it is always present within the HDL
        # And really only needs to be terminated if not used, this interface can be declared in the main
        # section as well

# ++++++++++++++BG++++++++++++++++++++

    # +-----------------------------------
    # | connection point CRA
    # |
    # Interface CRA_Access
    #Export optional CRA interface
    set isCRA  [get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
    if { $isCRA == 1 } {
        set_interface_property Cra ENABLED true
        set_interface_property CraIrq ENABLED true
    } else {
        set_interface_property Cra ENABLED false
        set_interface_property CraIrq ENABLED false
    }


    # +-----------------------------------
    # | connection point Txs Slave
    # |
    # Interface Txs Slave


# ++++++++++++++BG++++++++++++++++++++

        # Explicit address span does not usually need to be set.  Qsys will determine the address span based off the number of address bits on the
        # Address signal in the interface.  If you wish to override this calculation then set explicitAddressSpan

# ++++++++++++++BG++++++++++++++++++++

    #set_interface_property "Txs" "explicitAddressSpan" [ expr pow(2, $CB_A2P_ADDR_MAP_PASS_THRU_BITS) * $CB_A2P_ADDR_MAP_NUM_ENTRIES ]
    ##TODO Fix :set_interface_property "Txs" "maximumPendingReadTransactions" [ get_parameter_value p_pcie_tag_supported ]



    set i_Cg_Avalon_S_Addr_Width [ calculate_avalon_s_address_width $CB_A2P_ADDR_MAP_NUM_ENTRIES $i_Cg_Avalon_S_Addr_Width]



    # Ports in interface Txs

    # Used to be : set_port_property Txs TxsAddress_i width [expr $i_Cg_Avalon_S_Addr_Width - 3 ]
    set_port_property TxsAddress_i width [expr $i_Cg_Avalon_S_Addr_Width]
    set_port_property TxsBurstCount_i width [ get_parameter_value CB_TXS_ADDRESS_WIDTH ]

    #set_port_property TxsAddress_i width [expr $i_Cg_Avalon_S_Addr_Width + 0 ]

    # Check if completer only mode: CB_PCIE_MODE=true, if so then remove Tx Slave interface
    if { [ get_parameter_value CB_PCIE_MODE ] == 0} {
        set_interface_property Txs ENABLED true
    } else {
        set_interface_property Txs ENABLED false
    }



set CB_PCIE_MODE [ get_parameter_value CB_PCIE_MODE ]
        if { $CB_PCIE_MODE == 2 } {
                set rxm_width 32

        } else {
                set rxm_width 64
        }

        add_master "Rxm" $rxm_width



        if { $CB_PCIE_MODE == 2 } {
                add_interface "RxmIrq" "interrupt" "receiver" "avalon_clk"
                set_interface_property "RxmIrq" "associatedAddressablePoint" "Rxm"
                add_interface_port "RxmIrq" "RxmIrq_i" "irq" "input" 1

        }


    ## Interrupts
    if { $isCRA == 1 } {

        # Interface interrupt_receiver
        add_interface "RxmIrq" "interrupt" "receiver" "avalon_clk"
        set_interface_property "RxmIrq" "irqScheme" "individualRequests"
        set_interface_property "RxmIrq" "associatedAddressablePoint" "Rxm"

        # Ports in interface interrupt_receiver
       # add_interface_port "RxmIrq" "RxmIrqNum_i" "irqnumber" "input" 6
        add_interface_port "RxmIrq" "RxmIrq_i" "irq" "input" [ get_parameter_value CG_RXM_IRQ_NUM ]
    }

}


proc validate {} {

         validate_pcie_hip

}


proc write_to_log { line_output } {
   global g_logid
        global g_log_debug
        set space " "

        if { $g_log_debug == 1 } {
                #send_message "info" "we are in g_log_debug"
                #send_message "info" "g_logid is $g_logid"
                if { $g_logid == "" } {
                        #send_message "info" "we are in g_logid"
                        if { [ catch {open "debug_log_file" w+ } g_logid ] } {
                                send_message error "Couldn't open debug_log_file"
                        } else {
                                #puts $g_logid "STARTED"
                                flush $g_logid
                        }
                }  else {
                set output [clock format [clock seconds] -format {%b. %d, %Y %I:%M:%S %p}]$space$line_output
                puts $g_logid $output
                flush $g_logid
                }
        }
}

proc calculate_avalon_s_address_width {i_CB_A2P_ADDR_MAP_NUM_ENTRIES i_Cg_Avalon_S_Addr_Width } {

set my_Cg_Avalon_S_Addr_Width $i_Cg_Avalon_S_Addr_Width
switch $i_CB_A2P_ADDR_MAP_NUM_ENTRIES {
        1 {}
        2 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 1]}
        4 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 2]}
        8 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 3]}
        16 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 4]}
        32 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 5]}
        64 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 6]}
        128 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 7]}
        256 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 8]}
        512 {set my_Cg_Avalon_S_Addr_Width [expr $i_Cg_Avalon_S_Addr_Width + 9]}
        default { }
    }

        return $my_Cg_Avalon_S_Addr_Width
}

