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


# +-----------------------------------
# | request TCL package from other libraries
# | 
package provide altera_xcvr_fpll_vi::interfaces 13.1
package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::ip_interfaces
package require alt_xcvr::ip_tcl::messages
package require mcgb_package_vi::mcgb

# +-----------------------------------
# | create CMU_FPLL interface
# |
namespace eval ::altera_xcvr_fpll_vi::interfaces:: {
   namespace import ::alt_xcvr::ip_tcl::ip_module::*
   namespace import ::alt_xcvr::ip_tcl::ip_interfaces::*
   namespace import ::alt_xcvr::ip_tcl::messages::*
   namespace export \
      declare_interfaces \
      elaborate
   variable interfaces
   set interfaces {\
      {NAME                 DIRECTION UI_DIRECTION  WIDTH_EXPR         ROLE              TERMINATION_VALUE  IFACE_NAME        IFACE_TYPE  		IFACE_DIRECTION  TERMINATION                                                       ELABORATION_CALLBACK } \
      {pll_refclk0          input     input         1                  clk               NOVAL              pll_refclk0       clock       		sink             "gui_refclk_cnt < 1"                                              NOVAL                }\
      {pll_refclk1          input     input         1                  clk               NOVAL              pll_refclk1       clock       		sink             "gui_refclk_cnt < 2 && !gui_refclk_switch"                        NOVAL                }\
      {pll_refclk2          input     input         1                  clk               NOVAL              pll_refclk2       clock       		sink             "gui_refclk_cnt < 3"                                              NOVAL                }\
      {pll_refclk3          input     input         1                  clk               NOVAL              pll_refclk3       clock       		sink             "gui_refclk_cnt < 4"                                              NOVAL                }\
      {pll_refclk4          input     input         1                  clk               NOVAL              pll_refclk4       clock       		sink             "gui_refclk_cnt < 5"                                              NOVAL                }\
      {pll_powerdown        input     input         1                  pll_powerdown     NOVAL              pll_powerdown     conduit     		sink             false                                     						   NOVAL                } \
      {pll_locked           output    output        1                  pll_locked        NOVAL              pll_locked        conduit     		end              false                                     						   NOVAL                } \
      {tx_serial_clk       	output    output        1                  clk     			 NOVAL              tx_serial_clk     hssi_serial_clock start            "!gui_enable_transceiver_usage"  								   NOVAL                } \
      {tx_serial_clk_n      output    output        1                  clk   			 NOVAL              tx_serial_clk_n   hssi_serial_clock start            "!gui_enable_transceiver_usage"  								   NOVAL                } \
      {outclk0       		output    output        1                  outclk0         	 NOVAL              outclk0    		  conduit     		end              "!gui_enable_core_usage || gui_number_of_output_clocks < 1"  	   NOVAL                } \
      {outclk1       		output    output        1                  outclk1         	 NOVAL              outclk1    		  conduit     		end              "!gui_enable_core_usage || gui_number_of_output_clocks < 2"  	   NOVAL                } \
      {outclk2       		output    output        1                  outclk2         	 NOVAL              outclk2    		  conduit     		end              "!gui_enable_core_usage || gui_number_of_output_clocks < 3"  	   NOVAL                } \
      {outclk3       		output    output        1                  outclk3         	 NOVAL              outclk3    		  conduit     		end              "!gui_enable_core_usage || gui_number_of_output_clocks < 4"  	   NOVAL                } \
      {pll_pcie_clk         output    output        1                  pll_pcie_clk      NOVAL              pll_pcie_clk      conduit     		end              "!gui_enable_pcie_clk"                                            NOVAL                }\
	  {pll_cascade_clk		output    output        1                  clk         	 	 NOVAL              pll_cascade_clk   conduit     		end              "!gui_enable_cascade_out"  	 								   NOVAL                } \
	  {atx_pll_cascade_clk	output    output        1                  clk         	 	 NOVAL              atx_pll_cascade_clk conduit     	end              "!gui_enable_atx_pll_cascade_out"  	 						   NOVAL                } \
      \                                                                                                                                                                                                                                           
      {reconfig_clk0         input    input         1                  clk               NOVAL              reconfig_avmm     clock       		sink             "!enable_pll_reconfig && !gui_enable_dps"                         NOVAL                } \
      {reconfig_reset0       input    input         1                  reset             NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_write0       input    input         1                  write             NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_read0        input    input         1                  read              NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_address0     input    input         10                 address           NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_writedata0   input    input         32                 writedata         NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_readdata0    output   output        32                 readdata          NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      {reconfig_waitrequest0 output   output        1                  waitrequest       NOVAL              reconfig_avmm     avalon      		slave            "!enable_pll_reconfig"                                            NOVAL                } \
      \                                                                                                                                   		                                                                                                        
      {pll_cal_busy          output    output        1                 pll_cal_busy      NOVAL              pll_cal_busy      conduit     		end              "!gui_enable_pld_cal_busy_port"                                   NOVAL                } \
      {hip_cal_done          output    output        1                 hip_cal_done      NOVAL              hip_cal_done      conduit     		end              "!gui_enable_hip_cal_done_port"                                   NOVAL                } \
      \                                                                                                                                   		                                                                                                        
      {phase_reset           input     input         1                 phase_reset       NOVAL              phase_reset       conduit     		sink             "!gui_enable_dps"                                     			   NOVAL                } \
      {phase_en        	 	 input     input        1                  phase_en     	 NOVAL              phase_en     	  conduit     		sink             "!gui_enable_dps"      		     							   NOVAL                } \
      {updn        	 	     input     input        1                  updn     	     NOVAL              updn     	      conduit     		sink             "!gui_enable_dps"      		     							   NOVAL                } \
      {cntsel        	 	 input     input        4                  cntsel     	     NOVAL              cntsel     	      conduit     		sink             "!gui_enable_dps"      		     							   NOVAL                } \
      {num_phase_shifts      input     input        3                  num_phase_shifts  NOVAL              num_phase_shifts  conduit     		sink             "!gui_enable_dps"      		     							   NOVAL                } \
      {phase_done          	 output    output       1                  phase_done      	 NOVAL              phase_done        conduit     		end              "!gui_enable_dps"                  							   NOVAL                } \
      \                                                                                                                                   		                                                                                                        
      {extswitch        	 input     input        1                  extswitch     	 NOVAL              extswitch     	  conduit     		sink             "!gui_enable_extswitch || !gui_refclk_switch"      			   NOVAL                } \
      {activeclk          	 output    output       1                  activeclk      	 NOVAL              activeclk      	  conduit     		end              "!gui_enable_active_clk || !gui_refclk_switch"                    NOVAL                } \
      {clkbad          	 	 output    output       2                  clkbad      	 	 NOVAL              clkbad      	  conduit     		end              "!gui_enable_clk_bad || !gui_refclk_switch"                       NOVAL                } \
   }
}

# +-----------------------------------
# | 
# |
proc ::altera_xcvr_fpll_vi::interfaces::declare_interfaces {} {
   variable interfaces
   ip_declare_interfaces $interfaces
   ::mcgb_package_vi::mcgb::declare_mcgb_interfaces
}
# +-----------------------------------
# | 
# |
proc ::altera_xcvr_fpll_vi::interfaces::elaborate {} {
   ip_elaborate_interfaces
}




