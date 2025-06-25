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


#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {tx_mac_clk_clk} -period 4.02 -waveform { 0.000 2.010 } [get_ports {*tx_mac_clk_clk}]
create_clock -name {rx_mac_clk_clk} -period 4.02 -waveform { 0.000 2.010 } [get_ports {*rx_mac_clk_clk}]

if {[catch {get_port_info -is_input_port [get_ports -nowarn {*rx_oob_in_sys_clk}]} errmsg ]} {

    puts "Info: Out-of-band flow control is not enabled"

} else {

    create_clock -name {rx_oob_in_sys_clk} -period 4.02 -waveform { 0.000 2.010 } [get_ports {*rx_oob_in_sys_clk}]
    #100 MHz 
    create_clock -name {rx_oob_in_fc_clk} -period 10.000 -waveform { 0.000 5.00 } [get_ports {*rx_oob_in_fc_clk}] 
    #200 MHz
    create_clock -name {tx_oob_in_double_fc_clk} -period 5.000 -waveform { 0.000 2.50 } [get_ports {*tx_oob_in_double_fc_clk}]

}

if {[catch {get_port_info -is_input_port [get_ports -nowarn {*cal_blk_clk}]} errmsg ]} {
    puts "Info: Transceiver is not included in the design"

} else {
    #50MHz
    create_clock -name {cal_blk_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {*cal_blk_clk}]
}

if {[catch {get_port_info -is_input_port [get_ports -nowarn {*tx_lane_clk_clk}]} errmsg ]} {
    
    puts "Info: Transceiver is included in the design"


} else {
    

    create_clock -name {tx_lane_clk_clk} -period 3.14 -waveform {0.000 1.57} [get_ports {*tx_lane_clk_clk}]

    
    create_clock -name {rx_lane_clk} -period 3.14 -waveform {0.000 1.57} [get_ports {*rx_lane_clk*_export*}]
   
    
}

#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty


#**************************************************************
# Set False Paths
#**************************************************************
set_false_path -from [get_keepers *lane_status_monitor:lsm|*error*d*]
set_false_path -from [get_keepers *lane_status_monitor:lsm|*word*locked*d*]
set_false_path -from [get_keepers *lane_status_monitor:lsm|*sync*locked*d*]

#**************************************************************
# Adjust clock to clock default transfer rules
# NOTE: You should analyze your design and adjust the clock-to-clock
#       relationships as needed.
#**************************************************************

if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
    foreach_in_collection src_clk [all_clocks] {
        foreach_in_collection dst_clk [all_clocks] {
            if {$src_clk != $dst_clk} {
		# Fitter - transfers are critical (1ns)
		set_max_delay -from [get_clock_info -name $src_clk] -to [get_clock_info -name $dst_clk] 1.000
            }
        }
    }
}


if {[catch {get_port_info -is_input_port [get_ports -nowarn {*cal_blk_clk}]} errmsg ]} {


    puts "Info:Transceiver is not included in the design"

} else {


    if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
	# Capture register SDC
	# Each 20 bit RX bus would ideally be 0 skew entering the core
	set_max_skew -from * -to [get_registers { *hsio_bank*0*rx_capture[?] *hsio_bank*0*rx_capture[1?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*0*rx_capture[3?] *hsio_bank*0*rx_capture[2?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*0|rx_capture[5?] *hsio_bank*0*rx_capture[4?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*0*rx_capture[7?] *hsio_bank*0*rx_capture[6?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*0|rx_capture[9?] *hsio_bank*0*rx_capture[8?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }

	set_max_skew -from * -to [get_registers { *hsio_bank*1*rx_capture[?] *hsio_bank*1*rx_capture[1?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock } 
	set_max_skew -from * -to [get_registers { *hsio_bank*1*rx_capture[3?] *hsio_bank*1*rx_capture[2?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*1*rx_capture[5?] *hsio_bank*1*rx_capture[4?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*1*rx_capture[7?] *hsio_bank*1*rx_capture[6?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }
	set_max_skew -from * -to [get_registers { *hsio_bank*1*rx_capture[9?] *hsio_bank*1*rx_capture[8?]}] 0.000 -exclude { clock_uncertainty from_clock to_clock }

	set_multicycle_path -setup -start -from [get_registers {*tx_launch*}] 2
	set_multicycle_path -hold -start -from [get_registers {*tx_launch*}] 0
	set_multicycle_path -setup -start -to [get_registers {*rx_capture*}] 1
	set_multicycle_path -hold -start -to [get_registers {*rx_capture*}] 0
    } else {
	set_multicycle_path -setup -start -from [get_registers {*tx_launch*}] 2
	set_multicycle_path -hold -start -from [get_registers {*tx_launch*}] 0
	set_multicycle_path -setup -start -to [get_registers {*rx_capture*}] 1
	set_multicycle_path -hold -start -to [get_registers {*rx_capture*}] 0
    }

}
