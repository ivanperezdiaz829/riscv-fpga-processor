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


onerror {resume}

add wave -noupdate -divider CLOCK_RESET
add wave -noupdate -format Logic /tb/reset_wire
add wave -noupdate -format Logic /tb/reset_ex_delay_wire
add wave -noupdate -format Logic /tb/reset_done_wire
add wave -noupdate -format Logic /tb/reset
add wave -noupdate -format Logic /tb/gxb_refclk_wire
add wave -noupdate -divider GXB_STATUS
add wave -noupdate -format Literal /tb/reconfig_togxb_wire
add wave -noupdate -format Literal /tb/reconfig_fromgxb_wire
add wave -noupdate -format Logic /tb/pll_clkout_wire
add wave -noupdate -format Logic /tb/gxb_rx_pll_locked_wire
add wave -noupdate -format Logic /tb/gxb_rx_freqlocked_wire
add wave -noupdate -format Literal /tb/gxb_rx_errdetect_wire
add wave -noupdate -format Literal /tb/gxb_rx_disperr_wire
add wave -noupdate -format Logic /tb/gxb_pll_locked_wire
add wave -noupdate -format Literal /tb/op_cnt
add wave -noupdate -format Logic /tb/hw_reset_req_wire
add wave -noupdate -format Literal /tb/extended_rx_status_data_wire
add wave -noupdate -divider SET_CPU
add wave -noupdate -format Literal /tb/cpu_writedata_wire
add wave -noupdate -format Logic /tb/cpu_write_wire
add wave -noupdate -format Logic /tb/cpu_waitrequest_wire
add wave -noupdate -format Logic /tb/cpu_running
add wave -noupdate -format Logic /tb/cpu_reset_wire
add wave -noupdate -format Literal /tb/cpu_readdata_wire
add wave -noupdate -format Logic /tb/cpu_read_wire
add wave -noupdate -format Logic /tb/cpu_irq_wire
add wave -noupdate -format Literal /tb/cpu_irq_vector_wire
add wave -noupdate -format Logic /tb/cpu_done_compare
add wave -noupdate -format Literal /tb/cpu_address_wire
add wave -noupdate -format Literal /tb/cpri_tx_seq
add wave -noupdate -format Logic /tb/cpri_rx_sync_state
add wave -noupdate -format Logic /tb/cpri_rx_sync
add wave -noupdate -format Literal /tb/cpri_rx_seq
add wave -noupdate -format Literal /tb/cpri_rx_aux_data
add wave -noupdate -format Logic /tb/cpri_rec_loopback_wire
add wave -noupdate -format Logic /tb/cpri_clkout_wire
add wave -noupdate -format Logic /tb/config_reset_wire
add wave -noupdate -format Logic /tb/clk_ex_delay_wire
add wave -noupdate -divider AUX 
add wave -noupdate -format Literal /tb/aux_tx_status_data_wire
add wave -noupdate -format Literal /tb/aux_tx_mask_data_wire
add wave -noupdate -format Literal /tb/aux_rx_status_data_wire
add wave -noupdate -divider RECONFIG
add wave -noupdate -format Logic /tb/gxb_cal_blk_clk_wire
add wave -noupdate -format Logic /tb/reconfig_clk_wire   
add wave -noupdate -format Logic /tb/reconfig_write_all_wire	    
add wave -noupdate -format Logic /tb/reconfig_done_wire          
add wave -noupdate -format Logic /tb/reconfig_busy_wire 	 	   
add wave -noupdate -format Logic /tb/reconfig_addr_en_wire       
add wave -noupdate -format Logic /tb/reconfig_addr_out_wire	           
add wave -noupdate -format Logic /tb/start_configure  		   
add wave -noupdate -format Logic /tb/done_configure  	        
add wave -noupdate -format Logic /tb/cpri_rx_sync_state2	       
add wave -noupdate -format Logic /tb/clk_15_36				     	        
add wave -noupdate -format Logic /tb/clk_30_72				   
add wave -noupdate -format Logic /tb/reset_freq_check_wire	     		   
add wave -noupdate -format Logic /tb/freq_alarm_wire	   		     	        
add wave -noupdate -format Logic /tb/start_configure_hold	       	       
add wave -noupdate -format Logic /tb/freq_alarm_hold	           				     	        
add wave -noupdate -format Logic /tb/alarm_detected	    
add wave -noupdate -format Logic /tb/start_freq_checking	       	           				     	      
add wave -noupdate -format Logic /tb/completed_configure	       	             
add wave -noupdate -format Literal /tb/reconfig_data_wire    	   
add wave -noupdate -format Literal /tb/rom_stratix4gx_1g_data
add wave -noupdate -format Literal /tb/rom_stratix4gx_614m_data	    
add wave -noupdate -format Literal /tb/rom_addr				
add wave -noupdate -format Literal /tb/busy_cnt	
add wave -noupdate -format Literal /tb/num_configure	
add wave -noupdate -format Literal /tb/clk_check_configure	  
add wave -noupdate -format Logic /tb/clk_compare     
add wave -noupdate -format Logic /tb/alarm_detected_edge	   	   	
run -all
