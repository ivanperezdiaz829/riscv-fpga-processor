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



# # YMCHIN - Open Items:  
			## TBD  - avmm_busy (to be exposed or not? )

package provide altera_xcvr_cdr_pll_vi::interfaces 13.1

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::ip_tcl::ip_interfaces

namespace eval ::altera_xcvr_cdr_pll_vi::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*
  namespace import ::alt_xcvr::ip_tcl::ip_interfaces::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME                       	DIRECTION UI_DIRECTION	WIDTH_EXPR              ROLE                      TERMINATION             TERMINATION_VALUE FRAGMENT_LIST   IFACE_NAME                IFACE_TYPE  			IFACE_DIRECTION DYNAMIC		ELABORATION_CALLBACK                                            }\
    {pll_powerdown              	input     input			1                       pll_powerdown             false                     NOVAL             NOVAL         pll_powerdown             conduit     			end             false			NOVAL															}\
    {pll_refclk0		     		input     input			1		                clk		                  "refclk_cnt<1"            NOVAL             NOVAL        	pll_refclk0               clock	      			sink            false			NOVAL													        }\
    {pll_refclk1		     		input     input			1		                clk		                  "refclk_cnt<2"            NOVAL             NOVAL        	pll_refclk1               clock	      			sink            false			NOVAL													        }\
	{pll_refclk2		     		input     input			1		                clk		                  "refclk_cnt<3"            NOVAL             NOVAL        	pll_refclk2               clock	      			sink            false			NOVAL													        }\
	{pll_refclk3		     		input     input			1		                clk		                  "refclk_cnt<4"            NOVAL             NOVAL        	pll_refclk3               clock	      			sink            false			NOVAL													        }\
	{pll_refclk4		     		input     input			1		                clk		                  "refclk_cnt<5"            NOVAL             NOVAL        	pll_refclk4               clock	      			sink            false			NOVAL													        }\
	\
    {tx_serial_clk             		output    output		1                       clk			              false                     NOVAL             NOVAL        	tx_serial_clk             hssi_serial_clock     start           false			NOVAL													        }\
    {pll_locked			           	output    output		1                       pll_locked                false                     NOVAL             NOVAL        	pll_locked                conduit     			end             false			NOVAL													        }\
    \
    {reconfig_clk0         			input     input			1						clk				          "!enable_pll_reconfig"    NOVAL             NOVAL         reconfig_avmm        	  clock       			sink            false			NOVAL														    }\
    {reconfig_reset0				input	  input			1						reset					  "!enable_pll_reconfig"    NOVAL			  NOVAL			reconfig_avmm			  reset		  			sink			false			NOVAL															}\
	{reconfig_write0				input	  input			1 					    write					  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL														    }\
    {reconfig_read0					input	  input			1						read					  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL															}\
    {reconfig_address0          	input     input			10                      address					  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL															}\
    {reconfig_writedata0			input	  input			32						writedata				  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL															}\
    {reconfig_readdata0				output	  output		32						readdata				  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL															}\
	{reconfig_waitrequest0			output	  output		1						waitrequest				  "!enable_pll_reconfig"	NOVAL			  NOVAL			reconfig_avmm			  avalon	  			slave			false			NOVAL															}\
	{pll_cal_busy					output	  output		1						pll_cal_busy			  "!enable_pll_reconfig"    NOVAL             NOVAL			reconfig_avmm			  conduit     			end			  	false			NOVAL															}\
	{hip_cal_done					output	  output		1						hip_cal_done              "!enable_pll_reconfig"    NOVAL             NOVAL			reconfig_avmm             conduit	  			end			  	false			NOVAL															}\
  }

}

proc ::altera_xcvr_cdr_pll_vi::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::altera_xcvr_cdr_pll_vi::interfaces::elaborate {} {
  ip_elaborate_interfaces
}

proc ::altera_xcvr_cdr_pll_vi::interfaces::elaborate_direction { PROP_IFACE_NAME PROP_DIRECTION } {
  ip_set "interface.${PROP_IFACE_NAME}.assignment" [list "ui.blockdiagram.direction" $PROP_DIRECTION]
}



