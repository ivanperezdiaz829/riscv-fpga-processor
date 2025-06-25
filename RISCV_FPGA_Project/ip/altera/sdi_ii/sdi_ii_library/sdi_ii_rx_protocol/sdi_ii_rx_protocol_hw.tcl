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
# | SDI II RX Protocol v12.0
# | Altera Corporation 2011.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact qsys 12.0

source ../../sdi_ii/sdi_ii_interface.tcl
source ../../sdi_ii/sdi_ii_params.tcl

# +-----------------------------------
# | module SDI II RX Protocol
# | 
set_module_property DESCRIPTION "SDI II RX Protocol"
set_module_property NAME sdi_ii_rx_protocol
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/SDI II/SDI II RX Protocol"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II RX Protocol"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
# set_module_property TOP_LEVEL_HDL_FILE src_hdl/sdi_ii_rx_protocol.v
# set_module_property TOP_LEVEL_HDL_MODULE sdi_ii_rx_protocol
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

set_fileset_property simulation_verilog TOP_LEVEL   sdi_ii_rx_protocol
set_fileset_property simulation_vhdl    TOP_LEVEL   sdi_ii_rx_protocol
set_fileset_property synthesis_fileset  TOP_LEVEL   sdi_ii_rx_protocol

proc generate_files {name} {
  if {1} {
    add_fileset_file mentor/src_hdl/sdi_ii_rx_protocol.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_protocol.v"                      {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_hd_crc.v          VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/mentor/src_hdl/sdi_ii_hd_crc.v"     {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_hd_extract_ln.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_extract_ln.v"                    {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_3gb_demux.v       VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_3gb_demux.v"                        {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_trs_aligner.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_trs_aligner.v"                      {MENTOR_SPECIFIC}
   #add_fileset_file mentor/src_hdl/sdi_anctrack.v           VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_anctrack.v"                         {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_descrambler.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_descrambler.v"                      {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_format.v          VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_format.v"                           {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_receive.v         VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_receive.v"                          {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_vpid_extract.v    VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_vpid_extract.v"                     {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_trsmatch.v        VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/mentor/src_hdl/sdi_ii_trsmatch.v"   {MENTOR_SPECIFIC} 
    add_fileset_file mentor/src_hdl/sdi_ii_hd_dual_link.v    VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_dual_link.v"                     {MENTOR_SPECIFIC}
    add_fileset_file mentor/src_hdl/sdi_ii_fifo_retime.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_fifo_retime.v"                      {MENTOR_SPECIFIC}
  }
  if {1} {
    add_fileset_file aldec/src_hdl/sdi_ii_rx_protocol.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_protocol.v"                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_hd_crc.v           VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/aldec/src_hdl/sdi_ii_hd_crc.v"      {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_hd_extract_ln.v    VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_hd_extract_ln.v"                     {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_3gb_demux.v        VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_3gb_demux.v"                         {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_trs_aligner.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_trs_aligner.v"                       {ALDEC_SPECIFIC}
   #add_fileset_file aldec/src_hdl/sdi_anctrack.v            VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_anctrack.v"                          {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_descrambler.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_descrambler.v"                       {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_format.v           VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_format.v"                            {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_receive.v          VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_receive.v"                           {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_vpid_extract.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_vpid_extract.v"                      {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_trsmatch.v         VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/aldec/src_hdl/sdi_ii_trsmatch.v"    {ALDEC_SPECIFIC} 
    add_fileset_file aldec/src_hdl/sdi_ii_hd_dual_link.v     VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_hd_dual_link.v"                      {ALDEC_SPECIFIC}
    add_fileset_file aldec/src_hdl/sdi_ii_fifo_retime.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_fifo_retime.v"                       {ALDEC_SPECIFIC}
  }
  #if {0} {
  #  add_fileset_file cadence/src_hdl/sdi_ii_rx_protocol.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_protocol.v"                     {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_hd_crc.v         VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/cadence/src_hdl/sdi_ii_hd_crc.v"    {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_hd_extract_ln.v  VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_hd_extract_ln.v"                   {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_3gb_demux.v      VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_3gb_demux.v"                       {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_trs_aligner.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_trs_aligner.v"                     {CADENCE_SPECIFIC}
   #add_fileset_file cadence/src_hdl/sdi_anctrack.v          VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_anctrack.v"                        {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_descrambler.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_descrambler.v"                     {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_format.v         VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_format.v"                          {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_receive.v        VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_receive.v"                         {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_vpid_extract.v   VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_vpid_extract.v"                    {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_trsmatch.v       VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/cadence/src_hdl/sdi_ii_trsmatch.v"  {CADENCE_SPECIFIC} 
  #  add_fileset_file cadence/src_hdl/sdi_ii_hd_dual_link.v   VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_hd_dual_link.v"                    {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_ii_fifo_retime.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_fifo_retime.v"                     {CADENCE_SPECIFIC}
  #}
  if {0} {
    add_fileset_file synopsys/src_hdl/sdi_ii_rx_protocol.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_protocol.v"                    {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_hd_crc.v        VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/synopsys/src_hdl/sdi_ii_hd_crc.v"   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_hd_extract_ln.v VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_hd_extract_ln.v"                  {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_3gb_demux.v     VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_3gb_demux.v"                      {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_trs_aligner.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_trs_aligner.v"                    {SYNOPSYS_SPECIFIC}
   #add_fileset_file synopsys/src_hdl/sdi_anctrack.v         VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_anctrack.v"                       {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_descrambler.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_descrambler.v"                    {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_format.v        VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_format.v"                         {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_receive.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_receive.v"                        {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_vpid_extract.v  VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_vpid_extract.v"                   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_trsmatch.v      VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/synopsys/src_hdl/sdi_ii_trsmatch.v" {SYNOPSYS_SPECIFIC} 
    add_fileset_file synopsys/src_hdl/sdi_ii_hd_dual_link.v  VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_hd_dual_link.v"                   {SYNOPSYS_SPECIFIC}
    add_fileset_file synopsys/src_hdl/sdi_ii_fifo_retime.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_fifo_retime.v"                    {SYNOPSYS_SPECIFIC}                          {SYNOPSYS_SPECIFIC}
  }
}

#proc sim_vhd {name} {
#  if {1} {
#    add_fileset_file mentor/src_hdl/sdi_ii_rx_protocol.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_rx_protocol.v"       {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_hd_crc.v        VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/mentor/src_hdl/sdi_ii_hd_crc.v" {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_hd_extract_ln.v VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_extract_ln.v"     {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_3gb_demux.v     VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_3gb_demux.v"         {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_trs_aligner.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_trs_aligner.v"       {MENTOR_SPECIFIC}
    #add_fileset_file mentor/src_hdl/sdi_anctrack.v         VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_anctrack.v"          {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_descrambler.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_descrambler.v"       {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_format.v        VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_format.v"            {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_receive.v       VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_receive.v"           {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_vpid_extract.v  VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_vpid_extract.v"      {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_trsmatch.v      VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/mentor/src_hdl/sdi_ii_trsmatch.v" {MENTOR_SPECIFIC} 
#    add_fileset_file mentor/src_hdl/sdi_ii_hd_dual_link.v  VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_hd_dual_link.v"      {MENTOR_SPECIFIC}
#    add_fileset_file mentor/src_hdl/sdi_ii_fifo_retime.v   VERILOG_ENCRYPT PATH "mentor/src_hdl/sdi_ii_fifo_retime.v"       {MENTOR_SPECIFIC}
#  }
  #if {1} {
  #  add_fileset_file aldec/src_hdl/sdi_ii_rx_protocol.v    VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_ii_rx_protocol.v"       {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/hdsdi_crc.v             VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/aldec/src_hdl/hdsdi_crc.v" {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/hdsdi_extract_ln.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/hdsdi_extract_ln.v"         {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_3gb_demux.v         VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_3gb_demux.v"            {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_aligner_fsm.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_aligner_fsm.v"          {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_anctrack.v          VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_anctrack.v"             {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_descrambler.v       VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_descrambler.v"          {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_format.v            VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_format.v"               {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_receive.v           VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_receive.v"              {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_vpid_extract.v      VERILOG_ENCRYPT PATH "aldec/src_hdl/sdi_vpid_extract.v"         {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/sdi_trsmatch.v          VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/aldec/src_hdl/sdi_trsmatch.v" {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/hd_dual_link.v          VERILOG_ENCRYPT PATH "aldec/src_hdl/hd_dual_link.v"             {ALDEC_SPECIFIC}
  #  add_fileset_file aldec/src_hdl/fifo_retime.v           VERILOG_ENCRYPT PATH "aldec/src_hdl/fifo_retime.v"              {ALDEC_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file cadence/src_hdl/sdi_ii_rx_protocol.v  VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_ii_rx_protocol.v"       {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/hdsdi_crc.v           VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/cadence/src_hdl/hdsdi_crc.v" {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/hdsdi_extract_ln.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/hdsdi_extract_ln.v"         {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_3gb_demux.v       VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_3gb_demux.v             {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_aligner_fsm.v     VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_aligner_fsm.v"          {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_anctrack.v        VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_anctrack.v"             {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_descrambler.v     VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_descrambler.v"          {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_format.v          VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_format.v"               {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_receive.v         VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_receive.v"              {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_vpid_extract.v    VERILOG_ENCRYPT PATH "cadence/src_hdl/sdi_vpid_extract.v"         {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/sdi_trsmatch.v        VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/cadence/src_hdl/sdi_trsmatch.v" {CADENCE_SPECIFIC} 
  #  add_fileset_file cadence/src_hdl/hd_dual_link.v        VERILOG_ENCRYPT PATH "cadence/src_hdl/hd_dual_link.v"             {CADENCE_SPECIFIC}
  #  add_fileset_file cadence/src_hdl/fifo_retime.v         VERILOG_ENCRYPT PATH "cadence/src_hdl/fifo_retime.v"              {CADENCE_SPECIFIC}
  #}
  #if {0} {
  #  add_fileset_file synopsys/src_hdl/sdi_ii_rx_protocol.v VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_ii_rx_protocol.v"       {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/hdsdi_crc.v          VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/synopsys/src_hdl/hdsdi_crc.v" {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/hdsdi_extract_ln.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/hdsdi_extract_ln.v"         {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_3gb_demux.v      VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_3gb_demux.v             {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_aligner_fsm.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_aligner_fsm.v"          {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_anctrack.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_anctrack.v"             {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_descrambler.v    VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_descrambler.v"          {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_format.v         VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_format.v"               {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_receive.v        VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_receive.v"              {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_vpid_extract.v   VERILOG_ENCRYPT PATH "synopsys/src_hdl/sdi_vpid_extract.v"         {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/sdi_trsmatch.v       VERILOG_ENCRYPT PATH "../sdi_ii_tx_protocol/synopsys/src_hdl/sdi_trsmatch.v" {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/hd_dual_link.v       VERILOG_ENCRYPT PATH "synopsys/src_hdl/hd_dual_link.v"             {SYNOPSYS_SPECIFIC}
  #  add_fileset_file synopsys/src_hdl/fifo_retime.v        VERILOG_ENCRYPT PATH "synopsys/src_hdl/fifo_retime.v"              {SYNOPSYS_SPECIFIC}
  #}
#}

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
proc generate_ed_files {name} {
   add_fileset_file sdi_ii_rx_protocol.v        VERILOG PATH src_hdl/sdi_ii_rx_protocol.v
   add_fileset_file sdi_ii_hd_crc.v   		VERILOG PATH ../sdi_ii_tx_protocol/src_hdl/sdi_ii_hd_crc.v
   add_fileset_file sdi_ii_hd_extract_ln.v      VERILOG PATH src_hdl/sdi_ii_hd_extract_ln.v 
   add_fileset_file sdi_ii_3gb_demux.v          VERILOG PATH src_hdl/sdi_ii_3gb_demux.v
   add_fileset_file sdi_ii_trs_aligner.v      	VERILOG PATH src_hdl/sdi_ii_trs_aligner.v
   add_fileset_file sdi_ii_descrambler.v        VERILOG PATH src_hdl/sdi_ii_descrambler.v
   add_fileset_file sdi_ii_format.v     	VERILOG PATH src_hdl/sdi_ii_format.v
   add_fileset_file sdi_ii_receive.v       	VERILOG PATH src_hdl/sdi_ii_receive.v
   add_fileset_file sdi_ii_vpid_extract.v      	VERILOG PATH src_hdl/sdi_ii_vpid_extract.v
   add_fileset_file sdi_ii_trsmatch.v    	VERILOG PATH ../sdi_ii_tx_protocol/src_hdl/sdi_ii_trsmatch.v
   add_fileset_file sdi_ii_hd_dual_link.v      	VERILOG PATH src_hdl/sdi_ii_hd_dual_link.v
   add_fileset_file sdi_ii_fifo_retime.v      	VERILOG PATH src_hdl/sdi_ii_fifo_retime.v
   add_fileset_file sdi_ii_rx_protocol.ocp      OTHER   PATH src_hdl/sdi_ii_rx_protocol.ocp 
   add_fileset_file sdi_ii_rx_protocol.sdc      SDC     PATH src_hdl/sdi_ii_rx_protocol.sdc
}

#set module_dir [get_module_property MODULE_DIRECTORY]
#add_file ${module_dir}/src_hdl/sdi_ii_rx_protocol.v                    {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_rx_protocol.ocp                  {SYNTHESIS}
#add_file ${module_dir}/../sdi_ii_tx_protocol/src_hdl/sdi_ii_hd_crc.v   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_hd_extract_ln.v                  {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_3gb_demux.v                      {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_trs_aligner.v                    {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_anctrack.v                      {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_descrambler.v                    {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_format.v                         {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_receive.v                        {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_vpid_extract.v                   {SYNTHESIS}
#add_file ${module_dir}/../sdi_ii_tx_protocol/src_hdl/sdi_ii_trsmatch.v {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_hd_dual_link.v                   {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_fifo_retime.v                    {SYNTHESIS}
#add_file ${module_dir}/src_hdl/sdi_ii_rx_protocol.sdc                  {SDC}
# | 
# +-----------------------------------

sdi_ii_common_params
sdi_ii_test_params
#set_parameter_property FAMILY                 HDL_PARAMETER false
set_parameter_property DIRECTION               HDL_PARAMETER false
set_parameter_property TRANSCEIVER_PROTOCOL    HDL_PARAMETER false
set_parameter_property TX_HD_2X_OVERSAMPLING   HDL_PARAMETER false
set_parameter_property TX_EN_VPID_INSERT       HDL_PARAMETER false
set_parameter_property IS_RTL_SIM              HDL_PARAMETER true
set_parameter_property XCVR_TX_PLL_SEL         HDL_PARAMETER false
set_parameter_property HD_FREQ                 HDL_PARAMETER false

set common_composed_mode 0

proc elaboration_callback {} {
  set extract_vpid [get_parameter_value RX_EN_VPID_EXTRACT]
  set video_std    [get_parameter_value VIDEO_STANDARD]
  set crc_err      [get_parameter_value RX_CRC_ERROR_OUTPUT]
  # set trs_misc     [get_parameter_value RX_EN_TRS_MISC]
  set a2b          [get_parameter_value RX_EN_A2B_CONV]
  set b2a          [get_parameter_value RX_EN_B2A_CONV]

  common_add_clock            rx_clkin                      input  true

  if { ($video_std == "dl" & $a2b) | (($video_std == "tr" | $video_std == "threeg") & $b2a) } {
    common_add_clock          rx_clkin_smpte372             input  true 
  }

  common_add_optional_conduit rx_rst_proto_in               export  input  1  true
  common_add_optional_conduit rx_datain                     export  input  20 true
  common_add_optional_conduit rx_datain_valid               export  input  1 true
  common_add_optional_conduit rx_dataout                    export  output 20 true  
  common_add_optional_conduit rx_dataout_valid              export  output 1 true
  common_add_optional_conduit rx_f                          export  output 1 true
  common_add_optional_conduit rx_v                          export  output 1 true
  common_add_optional_conduit rx_h                          export  output 1 true
  common_add_optional_conduit rx_ap                         export  output 1 true
  common_add_optional_conduit rx_format                     export  output 4 true

  if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    common_add_optional_conduit rx_std_in                   export  input  2  true
    common_add_optional_conduit rx_std                      export  output 2 true  
  }

  common_add_optional_conduit rx_align_locked                export  output 1 true
  common_add_optional_conduit rx_trs_locked                  export  output 1 true
  common_add_optional_conduit rx_frame_locked                export  output 1 true
  
  if { $crc_err } {
    common_add_optional_conduit rx_crc_error_c               export  output 1 true
    common_add_optional_conduit rx_crc_error_y               export  output 1 true

    if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
      common_add_optional_conduit rx_crc_error_c_b           export  output 1 true
      common_add_optional_conduit rx_crc_error_y_b           export  output 1 true
    }
  }

  if { $video_std != "sd" } {
    common_add_optional_conduit rx_ln                        export  output 11 true
  }
  if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
    common_add_optional_conduit rx_ln_b                      export  output 11 true
  }

  # if { $trs_misc } {
    # common_add_optional_conduit rx_xyz            output 1 true
    # common_add_optional_conduit rx_xyz_valid      output 1 true
  # }
  common_add_optional_conduit  rx_eav                        export  output 1 true
  common_add_optional_conduit  rx_trs                        export  output 1 true

  common_add_optional_conduit  rx_trs_loose_lock_out         export  output 1 true
  #common_add_optional_conduit rx_anc_dataout    output 20 true
  #common_add_optional_conduit rx_anc_valid      output 4 true
  #common_add_optional_conduit rx_anc_error      output 4 true
  common_add_clock             rx_clkout                     output   true
  
  if { $video_std == "sd" } {
    set clock_rate "67500000"
  } elseif { $video_std == "hd" | $video_std == "dl" } {
    set clock_rate "74250000"
  } elseif { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    set clock_rate "148500000"
  }

  set_interface_property        rx_clkout                    clockRateKnown  true
  set_interface_property        rx_clkout                    clockRate       $clock_rate

  if { $extract_vpid } {
    common_add_optional_conduit rx_vpid_byte1                export  output 8 true
    common_add_optional_conduit rx_vpid_byte2                export  output 8 true
    common_add_optional_conduit rx_vpid_byte3                export  output 8 true
    common_add_optional_conduit rx_vpid_byte4                export  output 8 true
    common_add_optional_conduit rx_vpid_valid                export  output 1 true
    common_add_optional_conduit rx_vpid_checksum_error       export  output 1 true
    common_add_optional_conduit rx_line_f0                   export  output 11 true
    common_add_optional_conduit rx_line_f1                   export  output 11 true
    if { $video_std == "dl" | $video_std == "threeg" | $video_std == "tr"} {
      common_add_optional_conduit rx_vpid_byte1_b            export  output 8 true
      common_add_optional_conduit rx_vpid_byte2_b            export  output 8 true
      common_add_optional_conduit rx_vpid_byte3_b            export  output 8 true
      common_add_optional_conduit rx_vpid_byte4_b            export  output 8 true
      common_add_optional_conduit rx_vpid_valid_b            export  output 1 true
      common_add_optional_conduit rx_vpid_checksum_error_b   export  output 1 true
    }
  }

  if { $video_std == "dl" } {
    common_add_clock            rx_clkin_b                   input   true
    common_add_optional_conduit rx_rst_proto_in_b            export  input  1  true
    common_add_optional_conduit rx_datain_b                  export  input  20 true
    common_add_optional_conduit rx_datain_valid_b            export  input  1 true 
    common_add_optional_conduit rx_align_locked_b            export  output 1 true
    common_add_optional_conduit rx_trs_locked_b              export  output 1 true
    common_add_optional_conduit rx_frame_locked_b            export  output 1 true
    common_add_optional_conduit rx_trs_loose_lock_out_b      export  output 1 true
    common_add_optional_conduit rx_dl_locked                 export  output 1 true
    common_add_clock            rx_clkout_b                  output  true
  
    if { $video_std == "sd" } {
      set clock_rate "67500000"
    } elseif { $video_std == "hd" | $video_std == "dl" } {
      set clock_rate "74250000"
    } elseif { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
      set clock_rate "148500000"
    }

    set_interface_property      rx_clkout_b                  clockRateKnown  true
    set_interface_property      rx_clkout_b                  clockRate       $clock_rate
  }

  if { $video_std == "dl" | (($video_std == "threeg" | $video_std == "tr") & $b2a) } {
    common_add_optional_conduit rx_dataout_b                 export  output 20 true  
    common_add_optional_conduit rx_dataout_valid_b           export  output 1 true
  }
}
