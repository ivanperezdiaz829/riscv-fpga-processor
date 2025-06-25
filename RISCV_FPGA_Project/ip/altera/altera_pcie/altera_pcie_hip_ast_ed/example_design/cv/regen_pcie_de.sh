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



QSYS="pcie_de_gen1_x1_ast64.qsys
pcie_de_gen1_x4_ast64.qsys
pcie_de_rp_gen1_x4_ast64.qsys"


TCLSOPC="t.tcl"
for q in $QSYS
do
   echo $q
   p4 edit $q
   echo "package require -exact sopc 10.1" > $TCLSOPC
   echo "load_system $q" >> $TCLSOPC
   echo "set_instance_parameter_value DUT rxbuffer_rxreq_hwtcl Low" >> $TCLSOPC
   echo "set_instance_parameter_value DUT bypass_clkswitch_hwtcl disable" >> $TCLSOPC
   echo "set_instance_parameter_value DUT no_command_completed_hwtcl false" >> $TCLSOPC
   echo "set_instance_parameter_value DUT register_pipe_signals_hwtcl true" >> $TCLSOPC
   echo "set_instance_parameter_value DUT use_rx_st_be_hwtcl 1" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_0_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_1_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_2_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_3_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_4_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_5_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_6_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT flr_capability_7_hwtcl 0" >> $TCLSOPC
   echo "set_instance_parameter_value DUT use_tl_cfg_sync_hwtcl 1" >> $TCLSOPC
   echo "set_instance_parameter_value APPS bypass_xcvrreconfig 0" >> $TCLSOPC

   for i in {0..7}
   do
      if [ `echo $q | grep -c rp_gen` == 0 ]
      then
         echo "set_instance_parameter_value DUT bar2_type_${i}_hwtcl 2" >> $TCLSOPC
         echo "set_instance_parameter_value DUT bar2_size_mask_${i}_hwtcl 10" >> $TCLSOPC
      else
         echo "set_instance_parameter_value DUT bar2_type_${i}_hwtcl 0" >> $TCLSOPC
         echo "set_instance_parameter_value DUT bar2_size_mask_${i}_hwtcl 0" >> $TCLSOPC
      fi
   done
   echo "save_system $q" >>  $TCLSOPC
   sopc_builder --script="$TCLSOPC"

done
