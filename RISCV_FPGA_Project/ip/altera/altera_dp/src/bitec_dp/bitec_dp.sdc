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



set_false_path -to [get_keepers {*bitec_dp_clock_crossing*data_out_sync0[*]}]
set_false_path -to [get_keepers {*bitec_dp_reset_sync:*|rst_clk_reg*}]
set_false_path -to [get_keepers {*bitec_dp*bitec_dp_tx_vd2dp_fifo*}]

set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_single*|dcfifo*wraclr*}
set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_single*|dcfifo*rdaclr*}
set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_double*|dcfifo*wraclr*}
set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_double*|dcfifo*rdaclr*}
set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_quad*|dcfifo*wraclr*}
set_false_path -from [get_keepers {*bitec_dp_rx_stream_sink*|fifo_vertical_resync_reset*}] -to {*pixel_fifo_quad*|dcfifo*rdaclr*}

set_false_path -from [get_keepers {*bitec_dp_mac*fifo_reset_overflow_u*}] -to {*bitec_dp_rx_cc_fifo_mc*|dcfifo*wraclr*}
set_false_path -from [get_keepers {*bitec_dp_mac*fifo_reset_overflow_u*}] -to {*bitec_dp_rx_cc_fifo_mc*|dcfifo*rdaclr*}
