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



# QSYS="pcie_de_gen1_x4_ast64.qsys
# pcie_de_gen1_x8_ast128.qsys
# pcie_de_gen2_x8_ast256.qsys
# pcie_de_gen3_x1_ast64.qsys
# pcie_de_gen3_x4_ast128.qsys
# pcie_de_gen3_x8_ast256.qsys
# pcie_de_rp_gen1_x4_ast64.qsys
# pcie_de_rp_gen1_x8_ast128.qsys"

QSYS="`ls *.qsys`"

TCLSOPC="t.tcl"
for q in $QSYS
do
   echo $q
   p4 edit $q
   echo "package require -exact qsys 12.0" > $TCLSOPC
   echo "load_system $q" >> $TCLSOPC
   echo "save_system $q" >>  $TCLSOPC
   cat $TCLSOPC
   sopc_builder --script="$TCLSOPC"

done
