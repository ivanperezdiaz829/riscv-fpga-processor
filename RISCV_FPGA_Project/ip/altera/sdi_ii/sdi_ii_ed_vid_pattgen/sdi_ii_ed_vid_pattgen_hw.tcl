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


# +-------------------------------------
# | 
# | SDI II Video Pattern Generator v12.0
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +-------------------------------------

package require -exact qsys 12.0

source ../sdi_ii/sdi_ii_interface.tcl
source ../sdi_ii/sdi_ii_params.tcl

# +--------------------------------------
# | module SDI II Video Pattern Generator
# | 
set_module_property DESCRIPTION "SDI II Video Pattern Generator"
set_module_property NAME sdi_ii_ed_vid_pattgen
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II Video Pattern Generator"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II Video Pattern Generator"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_ed_vid_pattgen.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_ed_vid_pattgen
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property SIMULATION_MODEL_IN_VERILOG true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ELABORATION_CALLBACK elaboration_callback

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 

add_fileset simulation_verilog SIM_VERILOG   generate_files
add_fileset simulation_vhdl    SIM_VHDL      generate_files
add_fileset synthesis_fileset  QUARTUS_SYNTH generate_files

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_ed_vid_pattgen
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_ed_vid_pattgen
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_ed_vid_pattgen

proc generate_files {name} {
   add_fileset_file sdi_ii_ed_vid_pattgen.v   VERILOG PATH src_hdl/sdi_ii_ed_vid_pattgen.v
   add_fileset_file sdi_ii_makeframe.v        VERILOG PATH src_hdl/sdi_ii_makeframe.v
   add_fileset_file sdi_ii_colorbar_gen.v     VERILOG PATH src_hdl/sdi_ii_colorbar_gen.v 
   add_fileset_file sdi_ii_patho_gen.v        VERILOG PATH src_hdl/sdi_ii_patho_gen.v 
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_ed_vid_pattgen.v   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_makeframe.v        {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_colorbar_gen.v     {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_patho_gen.v        {SYNTHESIS}


# | 
# +-----------------------------------
sdi_ii_common_params
set_parameter_property FAMILY HDL_PARAMETER false
set_parameter_property VIDEO_STANDARD HDL_PARAMETER false
set_parameter_property DIRECTION HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL HDL_PARAMETER false
set_parameter_property RX_INC_ERR_TOLERANCE HDL_PARAMETER false
set_parameter_property RX_CRC_ERROR_OUTPUT HDL_PARAMETER false
set_parameter_property RX_EN_VPID_EXTRACT HDL_PARAMETER false
set_parameter_property RX_EN_A2B_CONV HDL_PARAMETER false
set_parameter_property RX_EN_B2A_CONV HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT HDL_PARAMETER false
set_parameter_property XCVR_TX_PLL_SEL HDL_PARAMETER false
set_parameter_property HD_FREQ HDL_PARAMETER false

sdi_ii_test_pattgen_params
sdi_ii_test_params

set_parameter_property TEST_VPID_OVERWRITE HDL_PARAMETER true
set_parameter_property IS_RTL_SIM          HDL_PARAMETER true

set common_composed_mode 0

proc elaboration_callback {} {
  set insert_vpid [get_parameter_value TX_EN_VPID_INSERT]
  set video_std   [get_parameter_value VIDEO_STANDARD]

  common_add_clock            clk              input   true
  common_add_reset            rst              input   clk
  common_add_optional_conduit bar_100_75n      export  input  1  true
  common_add_optional_conduit enable           export  input  1  true
  common_add_optional_conduit patho            export  input  1  true
  common_add_optional_conduit blank            export  input  1  true
  common_add_optional_conduit no_color         export  input  1  true  
  common_add_optional_conduit sgmt_frame       export  input  1  true  
  common_add_optional_conduit tx_std           export  input  2  true
  common_add_optional_conduit tx_format        export  input  4  true
  common_add_optional_conduit dl_mapping       export  input  1  true
  common_add_optional_conduit ntsc_paln        export  input  1  true
  common_add_optional_conduit dout             export  output 20 true
  common_add_optional_conduit dout_valid       export  output 1  true
  common_add_optional_conduit trs              export  output 1  true
  
  if { $video_std == "dl" } {
    common_add_optional_conduit dout_b         export  output 20 true
    common_add_optional_conduit dout_valid_b   export  output 1  true
    common_add_optional_conduit trs_b          export  output 1  true
  }

  if { $video_std != "sd" || $insert_vpid } {
    common_add_optional_conduit ln             export  output 11 true
    if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
      common_add_optional_conduit ln_b         export  output 11 true
    }
  }

  if {$insert_vpid} {
    common_add_optional_conduit line_f0        export  output 11 true
    common_add_optional_conduit line_f1        export  output 11 true
    common_add_optional_conduit vpid_byte1     export  output 8  true
    common_add_optional_conduit vpid_byte2     export  output 8  true
    common_add_optional_conduit vpid_byte3     export  output 8  true
    common_add_optional_conduit vpid_byte4     export  output 8  true

    if { $video_std == "dl" | $video_std == "threeg" | $video_std == "tr"} {
      common_add_optional_conduit vpid_byte1_b   export  output 8  true
      common_add_optional_conduit vpid_byte2_b   export  output 8  true
      common_add_optional_conduit vpid_byte3_b   export  output 8  true
      common_add_optional_conduit vpid_byte4_b   export  output 8  true
    }
  }
}

