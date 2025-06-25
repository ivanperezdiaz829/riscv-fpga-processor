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


# export_credit_info is our main data array
# export_credit_info(names) : list of all keys 
# export_credit_info($name,credits) : credits of the specified Key

global export_credit_info
set export_credit_info(names) ""

proc add_record {name creditslist} {
global export_credit_info
lappend export_credit_info(names) $name
set export_credit_info($name,creditslist) $creditslist
}

proc print_records {} {
global export_credit_info
foreach name $export_credit_info(names) {
puts "Name : $name"
puts "creditslist: $export_credit_info($name,creditslist)"

}
}


# Get get_creditslist for given key
proc get_creditslist { thename  } {
  
   set preemption ""
   global export_credit_info
   foreach name $export_credit_info(names) {
   if { $name == $thename } {
   	
   	 set preemption $export_credit_info($name,creditslist)
      }
   }
    return $preemption
}




#### The key is a composition of target_performance="Low" initiator_performance="High" max_payload_size="0" lanes="1"
####"Low_High_0_1"
#### The value is all the credits
#### rx_buf=1028 vc0_rx_flow_ctrl_nonposted_header=4 vc0_rx_flow_ctrl_posted_header=6 vc0_rx_flow_ctrl_posted_data=54 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256

add_record "Low_High_0_1" "rx_buf=1028 vc0_rx_flow_ctrl_nonposted_header=4 vc0_rx_flow_ctrl_posted_header=6 vc0_rx_flow_ctrl_posted_data=54 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Low_High_0_2" "rx_buf=1028 vc0_rx_flow_ctrl_nonposted_header=4 vc0_rx_flow_ctrl_posted_header=6 vc0_rx_flow_ctrl_posted_data=54 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Low_High_0_4" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Low_High_1_1" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Low_High_1_2" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Low_High_1_4" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"

add_record "Medium_High_0_1" "rx_buf=1028 vc0_rx_flow_ctrl_nonposted_header=4 vc0_rx_flow_ctrl_posted_header=6 vc0_rx_flow_ctrl_posted_data=54 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Medium_High_0_2" "rx_buf=1028 vc0_rx_flow_ctrl_nonposted_header=4 vc0_rx_flow_ctrl_posted_header=6 vc0_rx_flow_ctrl_posted_data=54 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Medium_High_0_4" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Medium_High_1_1" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Medium_High_1_2" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Medium_High_1_4" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=8 vc0_rx_flow_ctrl_posted_header=13 vc0_rx_flow_ctrl_posted_data=107 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"

add_record "High_High_0_1" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=20 vc0_rx_flow_ctrl_posted_header=17 vc0_rx_flow_ctrl_posted_data=91 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "High_High_0_2" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=20 vc0_rx_flow_ctrl_posted_header=17 vc0_rx_flow_ctrl_posted_data=91 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "High_High_0_4" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=20 vc0_rx_flow_ctrl_posted_header=17 vc0_rx_flow_ctrl_posted_data=91 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "High_High_1_1" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=20 vc0_rx_flow_ctrl_posted_header=17 vc0_rx_flow_ctrl_posted_data=91 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "High_High_1_2" "rx_buf=2048 vc0_rx_flow_ctrl_nonposted_header=20 vc0_rx_flow_ctrl_posted_header=17 vc0_rx_flow_ctrl_posted_data=91 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "High_High_1_4" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"

add_record "Maximum_High_0_1" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_0_2" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_0_4" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_1_1" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_1_2" "rx_buf=4096 vc0_rx_flow_ctrl_nonposted_header=30 vc0_rx_flow_ctrl_posted_header=28 vc0_rx_flow_ctrl_posted_data=198 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_1_4" "rx_buf=8192 vc0_rx_flow_ctrl_nonposted_header=54 vc0_rx_flow_ctrl_posted_header=55 vc0_rx_flow_ctrl_posted_data=403 vc0_rx_flow_ctrl_compl_header=48 vc0_rx_flow_ctrl_compl_data=256"
add_record "Maximum_High_0_8" "rx_buf=16384 vc0_rx_flow_ctrl_nonposted_header=54 vc0_rx_flow_ctrl_posted_header=50 vc0_rx_flow_ctrl_posted_data=360 vc0_rx_flow_ctrl_compl_header=112 vc0_rx_flow_ctrl_compl_data=448"
add_record "Maximum_High_1_8" "rx_buf=16384 vc0_rx_flow_ctrl_nonposted_header=54 vc0_rx_flow_ctrl_posted_header=50 vc0_rx_flow_ctrl_posted_data=360 vc0_rx_flow_ctrl_compl_header=112 vc0_rx_flow_ctrl_compl_data=448"


#add_record "1SerialStratix II GXSIP" "output=clk125_out input=pcie_rstn input1=vc0_rx_flow_ctrl_posted_headerystatus_ext output2=powerdown_ext\[1..0\] input2=refclk input3=rxdata0_ext\[15..0\] input4=rxdatak0_ext\[1..0\] input5=rxelecidle0_ext output3=rxpolarity0_ext input6=rxstatus0_ext\[2..0\] input7=rxvalid0_ext input8=test_in\[31..0\] output4=test_out\[511..0\] output5=txcompl0_ext output6=txdata0_ext\[15..0\] output7=txdatak0_ext\[1..0\] output8=txdetectrx_ext output9=txelecidle0_ext input9=pipe_mode input10=rx_in0 output11=tx_out0 input30=reconfig_clk input31=reconfig_togxb\[2..0\] input32=gxb_powerdown output30=reconfig_fromgxb"
#add_record "1SerialStratix IV GXSIP" "output=clk125_out input=pcie_rstn input1=vc0_rx_flow_ctrl_posted_headerystatus_ext output2=powerdown_ext\[1..0\] input2=refclk input3=rxdata0_ext\[15..0\] input4=rxdatak0_ext\[1..0\] input5=rxelecidle0_ext output3=rxpolarity0_ext input6=rxstatus0_ext\[2..0\] input7=rxvalid0_ext input8=test_in\[31..0\] output4=test_out\[511..0\] output5=txcompl0_ext output6=txdata0_ext\[15..0\] output7=txdatak0_ext\[1..0\] output8=txdetectrx_ext output9=txelecidle0_ext input9=pipe_mode input10=rx_in0 output11=tx_out0 input30=reconfig_clk input31=reconfig_togxb\[3..0\] input32=gxb_powerdown output30=reconfig_fromgxb\[16..0\]"

