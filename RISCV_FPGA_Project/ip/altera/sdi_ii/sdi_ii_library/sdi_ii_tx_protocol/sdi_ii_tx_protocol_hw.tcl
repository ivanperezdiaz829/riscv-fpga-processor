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


# +----------------------------------
# | 
# | SDI II TX Protocol v12.0
# | Altera Corporation 2011.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact qsys 12.0

source ../../sdi_ii/sdi_ii_interface.tcl
source ../../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II TX Protocol
# | 
set_module_property DESCRIPTION "SDI II TX Protocol"
set_module_property NAME sdi_ii_tx_protocol
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II/SDI II TX Protocol"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II TX Protocol"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_tx_protocol.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_tx_protocol
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ELABORATION_CALLBACK elaboration_callback

# | 
# +-----------------------------------

# +-----------------------------------
# | IEEE Encryption
# | 

add_fileset          simulation_verilog SIM_VERILOG   generate_files
add_fileset          simulation_vhdl    SIM_VHDL      generate_files
add_fileset          synthesis_fileset  QUARTUS_SYNTH generate_ed_files

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_tx_protocol
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_tx_protocol
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_tx_protocol

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/src_hdl/sdi_ii_tx_protocol.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_tx_protocol.v"                       {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_hd_crc.v          VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_crc.v"                            {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_hd_insert_ln.v    VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_insert_ln.v"                      {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_scrambler.v       VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_scrambler.v"                         {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_transmit.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_transmit.v"                          {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_vpid_insert.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_vpid_insert.v"                       {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_trsmatch.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_trsmatch.v"                          {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_sd_bits_conv.v    VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_sd_bits_conv.v"                      {MENTOR_SPECIFIC}
  }
  if {1} {
    add_fileset_file aldec/src_hdl/sdi_ii_tx_protocol.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_tx_protocol.v"                        {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_hd_crc.v           VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_hd_crc.v"                             {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_hd_insert_ln.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_hd_insert_ln.v"                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_scrambler.v        VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_scrambler.v"                          {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_transmit.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_transmit.v"                           {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_vpid_insert.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_vpid_insert.v"                        {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_trsmatch.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_trsmatch.v"                           {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_sd_bits_conv.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_sd_bits_conv.v"                       {ALDEC_SPECIFIC} 
  }
  #if {0} {
  #  add_fileset_file cadence/src_hdl/sdi_ii_tx_protocol.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_tx_protocol.v"   {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_hd_crc.v         VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_hd_crc.v"        {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_hd_insert_ln.v   VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_hd_insert_ln.v"  {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_scrambler.v      VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_scrambler.v"     {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_transmit.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_transmit.v"      {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_vpid_insert.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_vpid_insert.v"   {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_trsmatch.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_trsmatch.v"      {CADENCE_SPECIFIC}
  #}
  if {0} {
    add_fileset_file synopsys/src_hdl/sdi_ii_tx_protocol.v     VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_tx_protocol.v"                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_hd_crc.v          VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_hd_crc.v"                            {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_hd_insert_ln.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_hd_insert_ln.v"                      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_scrambler.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_scrambler.v"                         {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_transmit.v        VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_transmit.v"                          {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_vpid_insert.v     VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_vpid_insert.v"                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_trsmatch.v        VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_trsmatch.v"                          {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_sd_bits_conv.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_sd_bits_conv.v"                      {SYNOPSYS_SPECIFIC}
  }
}

#proc sim_vhd {name} {
#  if {1} {
#    add_fileset_file mentor/src_hdl/sdi_ii_tx_protocol.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_tx_protocol.v"  {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_hd_crc.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_crc.v"       {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_hd_insert_ln.v  VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_insert_ln.v" {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_scrambler.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_scrambler.v"    {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_transmit.v      VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_transmit.v"     {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_vpid_insert.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_vpid_insert.v"  {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_trsmatch.v      VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_trsmatch.v"     {MENTOR_SPECIFIC}
#  }
  #if {1} {
  #  add_fileset_file aldec/src_hdl/sdi_ii_tx_protocol.v    VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_tx_protocol.v"    {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/hdsdi_crc.v             VERILOG_ENCRYPT PATH "aldec/src_hdl/hdsdi_crc.v"             {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/hdsdi_insert_ln.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/hdsdi_insert_ln.v"       {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_scrambler.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_scrambler.v"         {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_transmit.v          VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_transmit.v"          {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_vpid_insert.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_vpid_insert.v"       {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_trsmatch.v          VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_trsmatch.v"          {ALDEC_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file cadence/src_hdl/sdi_ii_tx_protocol.v  VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_tx_protocol.v"  {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/hdsdi_crc.v           VERILOG_ENCRYPT PATH "cadence/src_hdl/hdsdi_crc.v"           {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/hdsdi_insert_ln.v     VERILOG_ENCRYPT PATH "cadence/src_hdl/hdsdi_insert_ln.v"     {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_scrambler.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_scrambler.v"       {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_transmit.v        VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_transmit.v"        {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_vpid_insert.v     VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_vpid_insert.v"     {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_trsmatch.v        VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_trsmatch.v"        {CADENCE_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file synopsys/src_hdl/sdi_ii_tx_protocol.v VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_tx_protocol.v" {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/hdsdi_crc.v          VERILOG_ENCRYPT PATH "synopsys/src_hdl/hdsdi_crc.v"          {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/hdsdi_insert_ln.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/hdsdi_insert_ln.v"    {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_scrambler.v      VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_scrambler.v"      {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_transmit.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_transmit.v"       {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_vpid_insert.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_vpid_insert.v"    {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_trsmatch.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_trsmatch.v"       {SYNOPSYS_SPECIFIC}
  #}
#}

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
proc generate_ed_files {name} {
   add_fileset_file sdi_ii_tx_protocol.v       VERILOG PATH src_hdl/sdi_ii_tx_protocol.v
   add_fileset_file sdi_ii_hd_crc.v            VERILOG PATH src_hdl/sdi_ii_hd_crc.v
   add_fileset_file sdi_ii_hd_insert_ln.v      VERILOG PATH src_hdl/sdi_ii_hd_insert_ln.v 
   add_fileset_file sdi_ii_scrambler.v         VERILOG PATH src_hdl/sdi_ii_scrambler.v
   add_fileset_file sdi_ii_transmit.v          VERILOG PATH src_hdl/sdi_ii_transmit.v
   add_fileset_file sdi_ii_vpid_insert.v       VERILOG PATH src_hdl/sdi_ii_vpid_insert.v 
   add_fileset_file sdi_ii_trsmatch.v          VERILOG PATH src_hdl/sdi_ii_trsmatch.v
   add_fileset_file sdi_ii_sd_bits_conv.v      VERILOG PATH src_hdl/sdi_ii_sd_bits_conv.v
   add_fileset_file sdi_ii_tx_protocol.ocp     OTHER   PATH src_hdl/sdi_ii_tx_protocol.ocp
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_tx_protocol.v   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_tx_protocol.ocp {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_hd_crc.v        {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_hd_insert_ln.v  {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_scrambler.v     {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_transmit.v      {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_vpid_insert.v   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_trsmatch.v      {SYNTHESIS}

# | 
# +-----------------------------------

sdi_ii_common_params
set_parameter_property FAMILY               HDL_PARAMETER false
set_parameter_property DIRECTION            HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL HDL_PARAMETER false
set_parameter_property RX_EN_A2B_CONV       HDL_PARAMETER false
set_parameter_property RX_EN_B2A_CONV       HDL_PARAMETER false
set_parameter_property RX_INC_ERR_TOLERANCE HDL_PARAMETER false
# set_parameter_property RX_EN_TRS_MISC       HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT   HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT  HDL_PARAMETER false
set_parameter_property XCVR_TX_PLL_SEL      HDL_PARAMETER false
set_parameter_property HD_FREQ              HDL_PARAMETER false

set common_composed_mode 0

proc elaboration_callback {} {
  set insert_vpid [get_parameter_value TX_EN_VPID_INSERT]
  set video_std   [get_parameter_value VIDEO_STANDARD]

  common_add_clock              tx_pclk              input   true
  common_add_reset              tx_rst               input   tx_pclk

  common_add_optional_conduit   tx_datain            export  input  20 true
  common_add_optional_conduit   tx_datain_valid      export  input  1  true
  common_add_optional_conduit   tx_trs               export  input  1  true

  if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    common_add_optional_conduit tx_std               export  input  2  true
    common_add_optional_conduit tx_std_out           export  output 2  true
  }

  if { $video_std != "sd" } {
    common_add_optional_conduit tx_enable_ln         export  input  1  true
    common_add_optional_conduit tx_enable_crc        export  input  1  true  
  }

  if { $video_std != "sd" || $insert_vpid } {
    common_add_optional_conduit tx_ln                export  input  11 true

    if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
      common_add_optional_conduit tx_ln_b            export  input  11 true
    }
  }

  if {$insert_vpid} {
    # if { $video_std == "hd" | $video_std == "dl" | $video_std == "ds" | $video_std == "tr"} {
    # An option to insert vpid in the chroma for HD stream
    # common_add_optional_conduit tx_enable_vpid_c input  1  true
    common_add_optional_conduit tx_vpid_overwrite    export  input  1  true
    # }
    common_add_optional_conduit tx_vpid_byte1        export  input  8  true
    common_add_optional_conduit tx_vpid_byte2        export  input  8  true
    common_add_optional_conduit tx_vpid_byte3        export  input  8  true
    common_add_optional_conduit tx_vpid_byte4        export  input  8  true
    if { $video_std == "dl" | $video_std == "threeg" | $video_std == "tr"} {
      common_add_optional_conduit tx_vpid_byte1_b    export  input  8  true
      common_add_optional_conduit tx_vpid_byte2_b    export  input  8  true
      common_add_optional_conduit tx_vpid_byte3_b    export  input  8  true
      common_add_optional_conduit tx_vpid_byte4_b    export  input  8  true
    }
    common_add_optional_conduit tx_line_f0           export  input  11 true
    common_add_optional_conduit tx_line_f1           export  input  11 true
  }

  #common_add_clock            tx_pclk_out output true
  #common_add_reset            rst_out     output tx_pclk_out
  common_add_optional_conduit   tx_dataout           export  output 20 true
  common_add_optional_conduit   tx_dataout_valid     export  output 1  true

  if {$video_std == "dl"} {
    common_add_optional_conduit tx_datain_b          export  input  20 true
    common_add_optional_conduit tx_datain_valid_b    export  input  1  true
    common_add_optional_conduit tx_trs_b             export  input  1  true 
    common_add_optional_conduit tx_dataout_b         export  output 20 true
    common_add_optional_conduit tx_dataout_valid_b   export  output 1  true
  }
}
