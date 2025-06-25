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


package provide alt_e40_e100::interfaces 13.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages

namespace eval ::alt_e40_e100::interfaces:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_interfaces \
    elaborate

  variable interfaces

  set interfaces {\
    {NAME                            DIRECTION UI_DIRECTION WIDTH_EXPR          ROLE                       TERMINATION                                                                       TERMINATION_VALUE       SPLIT                 SPLIT_COUNT SPLIT_WIDTH         IFACE_NAME                         IFACE_TYPE             IFACE_DIRECTION DYNAMIC ELABORATION_CALLBACK  }\
    {clk_ref                         input     input        1                   clk                        "MAC_ONLY_IF || en_synce_support && FULL_DUP_IF || NIGHT_FURY_IF && TX_ONLY_IF"   NOVAL                   NOVAL                 NOVAL       NOVAL               clk_ref                            conduit                end             false   NOVAL                 }\
	
	{rx_clk_ref                      input     input        1                   clk                        "MAC_ONLY_IF || !en_synce_support || !FULL_DUP_IF"                           NOVAL                   NOVAL                 NOVAL       NOVAL               rx_clk_ref                         conduit                end             false   NOVAL                 }\
	{tx_clk_ref                      input     input        1                   clk                        "MAC_ONLY_IF || !en_synce_support || !FULL_DUP_IF"                           NOVAL                   NOVAL                 NOVAL       NOVAL               tx_clk_ref                         conduit                end             false   NOVAL                 }\
	
    {pma_arst_ST                        input     input        1                   pma_arst_ST                MAC_ONLY_IF                                                                  NOVAL                   NOVAL                 NOVAL       NOVAL               pma_arst_ST                        conduit                end             false   NOVAL                 }\
	{pcs_rx_arst_ST                     input     input        1                   pcs_rx_arst_ST             "MAC_ONLY_IF || TX_ONLY_IF"                                                                 NOVAL                   NOVAL                 NOVAL       NOVAL               pcs_rx_arst_ST                     conduit                end             false   NOVAL                 }\
	{pcs_tx_arst_ST                     input     input        1                   pcs_tx_arst_ST             "MAC_ONLY_IF || RX_ONLY_IF"                                                  NOVAL                   NOVAL                 NOVAL       NOVAL               pcs_tx_arst_ST                     conduit                end             false   NOVAL                 }\
	
    {tx_serial                 	     output	  output        10	               tx_serial	              NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {rx_serial              	     input	  input        10	               rx_serial	              NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            NOVAL      	                       conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\

    {pll_locked                 	    input	  input        1	               pll_locked	              "!NIGHT_FURY_IF || MAC_ONLY_IF || RX_ONLY_IF"                  	           NOVAL                	  NOVAL	                NOVAL	    NOVAL	            pll_if	                           conduit	              end	          false	  NOVAL                 }\
    {tx_serial_clk              	    input	  input        10	               tx_serial_clk	          "!NIGHT_FURY_IF || MAC_ONLY_IF || RX_ONLY_IF"                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pll_if      	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
	

	{reconfig_from_xcvr	                output	  output       920	               reconfig_from_xcvr         "IS_CAUI4 || MAC_ONLY_IF || STRATIX_IV_IF || NIGHT_FURY_IF"	               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            reconfig_from_xcvr                 conduit	              end	          false   ::alt_e40_e100::interfaces::mac_config_delta                 }\
	{reconfig_to_xcvr                   input     input        1400                reconfig_to_xcvr           "IS_CAUI4 || MAC_ONLY_IF || STRATIX_IV_IF || NIGHT_FURY_IF"                  NOVAL                   NOVAL                 NOVAL       NOVAL               reconfig_to_xcvr                   conduit                end             false   ::alt_e40_e100::interfaces::mac_config_delta                 }\
	
	{reconfig_from_xcvr0	         output	  output       138	               reconfig_from_xcvr0  "!IS_CAUI4 || MAC_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            reconfig_from_xcvr0          conduit	              end	          false   NOVAL                 }\
	{reconfig_to_xcvr0               input     input        210                 reconfig_to_xcvr0    "!IS_CAUI4 || MAC_ONLY_IF"                                                   NOVAL                   NOVAL                 NOVAL       NOVAL               reconfig_to_xcvr0            conduit                end             false   NOVAL                 }\
    {reconfig_from_xcvr1   	         output	  output       138	               reconfig_from_xcvr1  "!IS_CAUI4 || MAC_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            reconfig_from_xcvr1          conduit	              end	          false   NOVAL                 }\
	{reconfig_to_xcvr1               input     input        210                 reconfig_to_xcvr1    "!IS_CAUI4 || MAC_ONLY_IF"                                                   NOVAL                   NOVAL                 NOVAL       NOVAL               reconfig_to_xcvr1            conduit                end             false   NOVAL                 }\
	{reconfig_from_xcvr2	         output	  output       138	               reconfig_from_xcvr2  "!IS_CAUI4 || MAC_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            reconfig_from_xcvr2          conduit	              end	          false   NOVAL                 }\
	{reconfig_to_xcvr2               input     input        210                 reconfig_to_xcvr2    "!IS_CAUI4 || MAC_ONLY_IF"                                                   NOVAL                   NOVAL                 NOVAL       NOVAL               reconfig_to_xcvr2            conduit                end             false   NOVAL                 }\
	{reconfig_from_xcvr3	         output	  output       138	               reconfig_from_xcvr3  "!IS_CAUI4 || MAC_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            reconfig_from_xcvr3          conduit	              end	          false   NOVAL                 }\
	{reconfig_to_xcvr3               input     input        210                 reconfig_to_xcvr3    "!IS_CAUI4 || MAC_ONLY_IF"                                                   NOVAL                   NOVAL                 NOVAL       NOVAL               reconfig_to_xcvr3            conduit                end             false   NOVAL                 }\
    
	{clk_status			                input	  input        1	               clk	                      NOVAL	                                                                       NOVAL                   NOVAL	                NOVAL	    NOVAL	            status                             conduit	              end             false	  NOVAL                 }\
    {status_addr	         		    input	  input        16	               address	                  NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL    	NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    {status_read	         		    input	  input        1	               read	                      NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    {status_write	        		    input	  input        1	               write	                  NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    {status_writedata	     		    input	  input        32	               writedata	              NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    {status_readdata	     		   output	  output       32	               readdata	                  NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    {status_readdata_valid			    output	  output       1	               readdatavalid	          NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            status	                           conduit	              end	          false	  NOVAL                 }\
    
	
	
	
	{rx_inc_runt		         	    output 	  output       1	               rx_inc_runt	              "PHY_ONLY_IF || TX_ONLY_IF" 	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_64              		    output 	  output       1	               rx_inc_64	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_127		            	    output 	  output       1	               rx_inc_127	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_255		            	    output 	  output       1	               rx_inc_255	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL             	NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_511	            		    output 	  output       1	               rx_inc_511	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_1023          			    output    output       1	               rx_inc_1023	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL             	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_1518         			    output    output       1	               rx_inc_1518	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_max         			    output    output       1	               rx_inc_max	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_over        			    output    output       1                   rx_inc_over	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit             	  end	          false	  NOVAL                 }\
    {rx_inc_mcast_data_err			    output    output       1	               rx_inc_mcast_data_err	  "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_mcast_data_ok			    output    output       1	               rx_inc_mcast_data_ok	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_bcast_data_err			    output    output       1	               rx_inc_bcast_data_err	  "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_bcast_data_ok			    output    output       1	               rx_inc_bcast_data_ok	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_ucast_data_err			    output    output       1	               rx_inc_ucast_data_err	  "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_ucast_data_ok			    output    output       1	               rx_inc_ucast_data_ok	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL            	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_mcast_ctrl	    		    output    output       1	               rx_inc_mcast_ctrl	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL            	rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_bcast_ctrl	    		    output    output       1	               rx_inc_bcast_ctrl	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL           	rx_inc	                           conduit	              end	          false   NOVAL                 }\
    {rx_inc_ucast_ctrl    			    output    output       1	               rx_inc_ucast_ctrl	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_pause	         		    output    output       1	               rx_inc_pause	              "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_fcs_err	         		    output    output       1	               rx_inc_fcs_err	          "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_fragment    			    output    output       1	               rx_inc_fragment	          "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_jabber	        		    output    output       1	               rx_inc_jabber	          "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {rx_inc_sizeok_fcserr			    output    output       1	               rx_inc_sizeok_fcserr	      "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            rx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_64           			    output    output       1	               tx_inc_64	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_127	            		    output    output       1	               tx_inc_127	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_255             		    output    output       1    	           tx_inc_255	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_511             		    output    output       1	               tx_inc_511	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_1023           			    output    output       1	               tx_inc_1023	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_1518        			    output    output       1	               tx_inc_1518	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_max	            		    output    output       1	               tx_inc_max	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_over        			    output    output       1	               tx_inc_over	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_mcast_data_err			    output    output       1	               tx_inc_mcast_data_err	  "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_mcast_data_ok			    output    output       1	               tx_inc_mcast_data_ok	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_bcast_data_err			    output    output       1	               tx_inc_bcast_data_err	  "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_bcast_data_ok			    output    output       1	               tx_inc_bcast_data_ok	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_ucast_data_err			    output    output       1	               tx_inc_ucast_data_err	  "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_ucast_data_ok			    output    output       1	               tx_inc_ucast_data_ok	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_mcast_ctrl   			    output    output       1	               tx_inc_mcast_ctrl	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_bcast_ctrl    			    output    output       1	               tx_inc_bcast_ctrl	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_ucast_ctrl	    		    output    output       1	               tx_inc_ucast_ctrl	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_pause	        		    output    output       1	               tx_inc_pause	              "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_fcs_err	         		    output    output       1	               tx_inc_fcs_err	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_fragment     			    output    output       1	               tx_inc_fragment	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_jabber	        		    output    output       1	               tx_inc_jabber	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {tx_inc_sizeok_fcserr			    output    output       1	               tx_inc_sizeok_fcserr	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            tx_inc	                           conduit	              end	          false	  NOVAL                 }\
    {pause_insert_tx    			    input	  input        1	               pause_insert_tx	          "PHY_ONLY_IF || RX_ONLY_IF" 	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	{pause_insert_time	    		    input	  input        16	               pause_insert_time	      "PHY_ONLY_IF || RX_ONLY_IF"                                                  NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
    {pause_insert_mcast	    		    input	  input        1	               pause_insert_mcast	      "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
    {pause_insert_dst	    		    input	  input        48	               pause_insert_dst	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
    {pause_insert_src	     		    input	  input        48	               pause_insert_src	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	
	{remote_fault_status     		    output	  output        1	               remote_fault_status        "PHY_ONLY_IF || MAC_ONLY_IF || !FULL_DUP_IF"                                 NOVAL	                  NOVAL	                NOVAL	    NOVAL	            remote_fault_status                conduit	              end	          false	  NOVAL                 }\
	{local_fault_status	     		    output	  output        1	               local_fault_status         "PHY_ONLY_IF || MAC_ONLY_IF || !FULL_DUP_IF"                                 NOVAL	                  NOVAL	                NOVAL	    NOVAL	            local_fault_status                 conduit	              end	          false	  NOVAL                 }\
	
	{pause_match_from_rx	    	    output	  output        1	               pause_match_from_rx	      "PHY_ONLY_IF || TX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	{pause_time_from_rx	    		    output	  output        16	               pause_time_from_rx	      "PHY_ONLY_IF || TX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	{remote_fault_from_rx	    	    output	  output        1	               remote_fault_from_rx	      "PHY_ONLY_IF || TX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            remote_fault_from_rx	                           conduit	              end	          false	  NOVAL                 }\
	{local_fault_from_rx	    	    output	  output        1	               local_fault_from_rx	      "PHY_ONLY_IF || TX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            local_fault_from_rx	                           conduit	              end	          false	  NOVAL                 }\
	
	{remote_fault_to_tx	    		    input	  input        1	               remote_fault_to_tx	      "PHY_ONLY_IF || RX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            remote_fault_to_tx	                           conduit	              end	          false	  NOVAL                 }\
	{local_fault_to_tx	    		    input	  input        1	               local_fault_to_tx	      "PHY_ONLY_IF || RX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            local_fault_to_tx	                           conduit	              end	          false	  NOVAL                 }\
	{pause_match_to_tx	    		    input	  input        1	               pause_match_to_tx	      "PHY_ONLY_IF || RX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	{pause_time_to_tx	    		    input	  input        16	               pause_time_to_tx  	      "PHY_ONLY_IF || RX_ONLY_IF || FULL_DUP_IF"                                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            pause	                           conduit	              end	          false	  NOVAL                 }\
	
    {clk_rxmac          			    input	  input        1	               clk_rxmac	              "TX_ONLY_IF"              	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            clk_rxmac	                       conduit	              end	          false	  NOVAL                 }\
    {clk_txmac	            		    input	  input        1	               clk_txmac	              "RX_ONLY_IF"	                                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            clk_txmac	                       conduit	              end	          false	  NOVAL                 }\
    {mac_rx_arst_ST	        		    input	  output       1	               mac_rx_arst_ST	          "PHY_ONLY_IF || TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            mac_rx_arst_ST	                   conduit	              end	          false	  NOVAL                 }\
    {mac_tx_arst_ST	        		    input	  output       1	               mac_tx_arst_ST	          "PHY_ONLY_IF || RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            mac_tx_arst_ST	                   conduit	              end	          false	  NOVAL                 }\
	
	
    {rx_mii_valid                 	    input	  input        1	               rx_mii_valid	              NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {rx_mii_d              	            input	  input        320	               rx_mii_d	                  NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            NOVAL      	                       conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {rx_mii_c                 	        input	  input       40	               rx_mii_c	                  NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {lanes_deskewed              	    input	  input        1	               lanes_deskewed	          NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            NOVAL      	                       conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\

    {tx_mii_d                 	        output	  output       320	               tx_mii_d	                  NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {tx_mii_c              	            output	  output        40	               tx_mii_c	                  NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            NOVAL      	                       conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {tx_mii_valid                 	    output	  output       1	               tx_mii_valid	              NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {tx_mii_ready              	        input	  input        1	               tx_mii_ready	              NOVAL	                                                                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            NOVAL      	                       conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {tx_lanes_stable                    input	  input       1	                   tx_lanes_stable	          NOVAL                 	                                                   NOVAL                	  NOVAL	                NOVAL	    NOVAL	            NOVAL	                           conduit	              end	          true	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
	
	{l8_rx_data	            		    output	  output       512	               l8_rx_data	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"                       NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_empty	        		    output	  output       6	               l8_rx_empty	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_startofpacket			    output	  output       1                   l8_rx_startofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_endofpacket	    		    output	  output       1	               l8_rx_endofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_error        			    output	  output       1	               l8_rx_error	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_valid	        		    output	  output       1	               l8_rx_valid	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_fcs_valid	    		    output	  output       1	               l8_rx_fcs_valid	          "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_rx_fcs_error	    		   output	  output       1	               l8_rx_fcs_error	          "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l8_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_data		            	    input	  output        512	               l8_tx_data	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_empty		        	    input	  output        6	               l8_tx_empty	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_startofpacket			    input	  output        1	               l8_tx_startofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_endofpacket	    		    input	  output        1	               l8_tx_endofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_ready	        		    output	  output       1	               l8_tx_ready	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l8_tx_valid	        		    input	  output        1	               l8_tx_valid	              "!HAS_ADAPTERS || PHY_ONLY_IF || IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l8_tx	                           conduit	              end	          false	  NOVAL                 }\
	
	{l4_rx_data	            		    output	  output       256	               l4_rx_data	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_empty	        		    output	  output       5	               l4_rx_empty	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_startofpacket			    output	  output       1                   l4_rx_startofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_endofpacket	    		    output	  output       1	               l4_rx_endofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_error        			    output	  output       1	               l4_rx_error	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_valid	        		    output	  output       1	               l4_rx_valid	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL	            l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_fcs_valid	    		    output	  output       1	               l4_rx_fcs_valid	          "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_rx_fcs_error	    		    output	  output       1	               l4_rx_fcs_error	          "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || TX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l4_rx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_data		            	    input	  output        256	               l4_tx_data	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_empty		        	    input	  output        5	               l4_tx_empty	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_startofpacket			    input	  output        1	               l4_tx_startofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_endofpacket	    		    input	  output        1	               l4_tx_endofpacket	      "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_ready	        		    output	  output       1	               l4_tx_ready	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL           	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
    {l4_tx_valid	        		    input	  output        1	               l4_tx_valid	              "!HAS_ADAPTERS || PHY_ONLY_IF || !IS_40G || RX_ONLY_IF"	                   NOVAL	                  NOVAL	                NOVAL	    NOVAL            	l4_tx	                           conduit	              end	          false	  NOVAL                 }\
	
  
	
	{din		                	    input	  input        320	               din	                      "HAS_ADAPTERS || 	RX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL             	custom_st_din	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
	{din_start	            		    input	  input        5	               din_start	              "HAS_ADAPTERS || 	RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_din	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {din_end_pos	        		    input	  input        40	               din_end_pos	              "HAS_ADAPTERS || 	RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_din	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {din_ack	            		    output	  output       1	               din_ack	                  "HAS_ADAPTERS || 	RX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_din	                   conduit	              end	          false	  NOVAL                 }\
	
	{dout_d	                		    output	  output       320                 dout_d	                  "HAS_ADAPTERS || 	TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_c	                   		    output 	  output       40	               dout_c	                  "HAS_ADAPTERS || 	TX_ONLY_IF"	                                               NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_first_data	     		    output	  output       5	               dout_first_data	          "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_last_data	         		    output	  output       40	               dout_last_data	          "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_runt_last_data			    output	  output       5	               dout_runt_last_data	      "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_payload		        	    output	  output       5	               dout_payload	              "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_fcs_error	        		    output	  output       1	               dout_fcs_error	          "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  NOVAL                 }\
    {dout_fcs_valid	        		    output	  output       1	               dout_fcs_valid	          "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  NOVAL                 }\
    {dout_dst_addr_match			    output	  output       5	               dout_dst_addr_match	      "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {dout_valid		              	    output	  output       1	               dout_valid	              "HAS_ADAPTERS || 	TX_ONLY_IF"                                                NOVAL	                  NOVAL	                NOVAL	    NOVAL	            custom_st_dout	                   conduit	              end	          false	  NOVAL                 }\
	
	{a10_reconfig_write	       		    input	  input        1	               a10_reconfig_write	      !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL           	a10_reconfig_avmm	               conduit	              end	          false	  NOVAL                 }\
    {a10_reconfig_read	     		    input	  input        1	               a10_reconfig_read	      !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL            	a10_reconfig_avmm	               conduit	              end	          false	  NOVAL                 }\
    {a10_reconfig_address			    input	  input        14	               a10_reconfig_address	      !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL           	a10_reconfig_avmm	               conduit	              end	          false	  ::alt_e40_e100::interfaces::mac_config_delta                 }\
    {a10_reconfig_writedata			    input	  input        32	               a10_reconfig_writedata	  !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL            	a10_reconfig_avmm	               conduit	              end	          false	  NOVAL                 }\
    {a10_reconfig_readdata			    output	  output       32	               a10_reconfig_readdata	  !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL            	a10_reconfig_avmm	               conduit	              end	          false	  NOVAL                 }\
    {a10_reconfig_waitrequest		    output	  output       1	               a10_reconfig_waitrequest	  !NIGHT_FURY_IF	                                                           NOVAL	                  NOVAL	                NOVAL	    NOVAL           	a10_reconfig_avmm	               conduit	              end	          false	  NOVAL                 }\

    {rc_busy                         input     input        4                   rc_busy                    "!ENA_KR4 || !SYNTH_LT && !SYNTH_SEQ"                                             NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {lt_start_rc                     output    output       4                   lt_start_rc                "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {main_rc                         output    output       "4*MAINTAPWIDTH"    main_rc                    "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {post_rc                         output    output       "4*POSTTAPWIDTH"    post_rc                    "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {pre_rc                          output    output       "4*PRETAPWIDTH"     pre_rc                     "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {tap_to_upd                      output    output       "4*3"               tap_to_upd                 "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {en_lcl_rxeq                     output    output       4                   en_lcl_rxeq                "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {rxeq_done                       input     input        4                   rxeq_done                  "!ENA_KR4 || !SYNTH_LT"                                                           NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {seq_start_rc                    output    output       4                   seq_start_rc               "!ENA_KR4 || !SYNTH_SEQ"                                                          NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {pcs_mode_rc                     output    output       6                   pcs_mode_rc                "!ENA_KR4 || !SYNTH_SEQ"                                                          NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {reco_mif_done                   input     input        1                   reco_mif_done              "!ENA_KR4 || !SYNTH_SEQ"                                                          NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\

    {upi_mode_en                     input     input        4                   upi_mode_en                "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_adj                         input     input        "4*2"               upi_adj                    "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_inc                         input     input        4                   upi_inc                    "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_dec                         input     input        4                   upi_dec                    "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_pre                         input     input        4                   upi_pre                    "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_init                        input     input        4                   upi_init                   "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_st_bert                     input     input        4                   upi_st_bert                "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_train_err                   input     input        4                   upi_train_err              "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_lock_err                    input     input        4                   upi_lock_err               "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\
    {upi_rx_trained                  input     input        4                   upi_rx_trained             "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upi             }\

    {upo_enable                      output    output       4                   upo_enable                 "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_frame_lock                  output    output       4                   upo_frame_lock             "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_cm_done                     output    output       4                   upo_cm_done                "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_bert_done                   output    output       4                   upo_bert_done              "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_ber_cnt                     output    output       "4*BERWIDTH"        upo_ber_cnt                "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_ber_max                     output    output       4                   upo_ber_max                "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {upo_coef_max                    output    output       4                   upo_coef_max               "!ENA_KR4 || !OPTIONAL_UP   || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab_upo             }\
    {dfe_start_rc                    output    output       4                   dfe_start_rc               "!ENA_KR4 || !OPTIONAL_RXEQ || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {dfe_mode                        output    output       "4*2"               dfe_mode                   "!ENA_KR4 || !OPTIONAL_RXEQ || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {ctle_start_rc                   output    output       4                   ctle_start_rc              "!ENA_KR4 || !OPTIONAL_RXEQ || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {ctle_rc                         output    output       "4*4"               ctle_rc                    "!ENA_KR4 || !OPTIONAL_RXEQ || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\
    {ctle_mode                       output    output       "4*2"               ctle_mode                  "!ENA_KR4 || !OPTIONAL_RXEQ || !SYNTH_LT"                                         NOVAL                   NOVAL                 NOVAL       NOVAL               NOVAL                              conduit                end             true    ::alt_e40_e100::interfaces::kr_port_elab                 }\

  }

}

proc ::alt_e40_e100::interfaces::term_in_port {port_name width direction} {
	add_interface $port_name conduit end
	add_interface_port $port_name $port_name $port_name $direction $width
	ip_set "port.${port_name}.TERMINATION" true
	ip_set "port.${port_name}.VHDL_TYPE" STD_LOGIC_VECTOR
}

proc ::alt_e40_e100::interfaces::create_dynamic_port {port_name width direction} {
	add_interface $port_name conduit end
	add_interface_port $port_name $port_name $port_name $direction $width
}

#using a trick to not generate KR4 ports by not setting their IFACE value. That means we have to re-create interface/port generation here.
proc ::alt_e40_e100::interfaces::kr_port_elab {PROP_NAME PROP_IFACE_TYPE PROP_IFACE_DIRECTION PROP_UI_DIRECTION PROP_TERMINATION MAC_CONFIG} {
	set iface_name $PROP_NAME
	if {$MAC_CONFIG == "40 Gbe"} {
        if {[lsearch [get_interfaces] $iface_name] == -1} {
          ip_add "interface.${iface_name}" $PROP_IFACE_TYPE $PROP_IFACE_DIRECTION
        }
		::alt_xcvr::ip_tcl::ip_module::elaborate_port $iface_name $PROP_NAME
		if { $PROP_UI_DIRECTION != "NOVAL" } {
			ip_set "interface.${iface_name}.assignment" [list "ui.blockdiagram.direction" $PROP_UI_DIRECTION]
		}
	}
}

#separate upi/upo onto their own interfaces for cleaner block diagram
proc ::alt_e40_e100::interfaces::kr_port_elab_upi {PROP_NAME PROP_IFACE_TYPE PROP_IFACE_DIRECTION PROP_UI_DIRECTION PROP_TERMINATION MAC_CONFIG} {
	set iface_name upi
	if {$MAC_CONFIG == "40 Gbe"} {
        if {[lsearch [get_interfaces] $iface_name] == -1} {
          ip_add "interface.${iface_name}" $PROP_IFACE_TYPE $PROP_IFACE_DIRECTION
        }
		::alt_xcvr::ip_tcl::ip_module::elaborate_port $iface_name $PROP_NAME
		if { $PROP_UI_DIRECTION != "NOVAL" } {
			ip_set "interface.${iface_name}.assignment" [list "ui.blockdiagram.direction" $PROP_UI_DIRECTION]
		}
	}
}
proc ::alt_e40_e100::interfaces::kr_port_elab_upo {PROP_NAME PROP_IFACE_TYPE PROP_IFACE_DIRECTION PROP_UI_DIRECTION PROP_TERMINATION MAC_CONFIG} {
	set iface_name upo
	if {$MAC_CONFIG == "40 Gbe"} {
        if {[lsearch [get_interfaces] $iface_name] == -1} {
          ip_add "interface.${iface_name}" $PROP_IFACE_TYPE $PROP_IFACE_DIRECTION
        }
		::alt_xcvr::ip_tcl::ip_module::elaborate_port $iface_name $PROP_NAME
		if { $PROP_UI_DIRECTION != "NOVAL" } {
			ip_set "interface.${iface_name}.assignment" [list "ui.blockdiagram.direction" $PROP_UI_DIRECTION]
		}
	}
}

proc ::alt_e40_e100::interfaces::mac_config_delta {PROP_NAME MAC_CONFIG IS_CAUI4 RX_ONLY_IF TX_ONLY_IF PHY_ONLY_IF MAC_ONLY_IF} {
	if {$MAC_CONFIG == "100 Gbe"} {
		switch $PROP_NAME {
			"rx_serial" {
				if {$MAC_ONLY_IF || $TX_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "rx_serial_reg" 10 input
					::alt_e40_e100::interfaces::term_in_port "rx_serial_caui4" 4 input
				} elseif {$IS_CAUI4} {
					::alt_e40_e100::interfaces::create_dynamic_port "rx_serial" 4 input
					ip_set "interface.rx_serial.assignment" [list "ui.blockdiagram.direction" input]
					set_port_property rx_serial fragment_list "rx_serial_caui4(3:0)"
					::alt_e40_e100::interfaces::term_in_port "rx_serial_reg" 10 input
				} else {
					::alt_e40_e100::interfaces::create_dynamic_port "rx_serial" 10 input
					ip_set "interface.rx_serial.assignment" [list "ui.blockdiagram.direction" input]
					set_port_property rx_serial fragment_list "rx_serial_reg(9:0)"
					::alt_e40_e100::interfaces::term_in_port "rx_serial_caui4" 4 input
				}

			}
			"tx_serial" {
				if {$MAC_ONLY_IF || $RX_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "tx_serial_reg" 10 output
					::alt_e40_e100::interfaces::term_in_port "tx_serial_caui4" 4 output
				} elseif {$IS_CAUI4} {
					::alt_e40_e100::interfaces::create_dynamic_port "tx_serial" 4 output
					ip_set "interface.tx_serial.assignment" [list "ui.blockdiagram.direction" output]
					set_port_property tx_serial fragment_list "tx_serial_caui4(3:0)"
					::alt_e40_e100::interfaces::term_in_port "tx_serial_reg" 10 output
				} else {
					::alt_e40_e100::interfaces::create_dynamic_port "tx_serial" 10 output
					ip_set "interface.tx_serial.assignment" [list "ui.blockdiagram.direction" output]
					set_port_property tx_serial fragment_list "tx_serial_reg(9:0)"
					::alt_e40_e100::interfaces::term_in_port "tx_serial_caui4" 4 output
				}
				
			}

			"rx_mii_valid" - 
			"lanes_deskewed" -
			"rx_mii_d" -
			"rx_mii_c" {
				set bus ""
				set width 1
				if {$PROP_NAME == "rx_mii_d"} {set bus "(319:0)"}
				if {$PROP_NAME == "rx_mii_d"} {set width 320}
				if {$PROP_NAME == "rx_mii_c"} {set bus "(39:0)"}
				if {$PROP_NAME == "rx_mii_c"} {set width 40}
				if {$PHY_ONLY_IF || ($PROP_NAME == "lanes_deskewed" && $PHY_ONLY_IF == 0 && $MAC_ONLY_IF == 0)} {		
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					if {$TX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					if {$TX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
				}
			}
			
			"tx_mii_d" -
			"tx_mii_c" -
			"tx_mii_valid" {
				set bus ""
				set width 1
				if {$PROP_NAME == "tx_mii_d"} {set bus "(319:0)"}
				if {$PROP_NAME == "tx_mii_d"} {set width 320}
				if {$PROP_NAME == "tx_mii_c"} {set bus "(39:0)"}
				if {$PROP_NAME == "tx_mii_c"} {set width 40}
				if {$PHY_ONLY_IF} {			
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
				}
			}
			
			"tx_mii_ready" -
			"tx_lanes_stable" {
				set bus ""
				set width 1
				if {$PHY_ONLY_IF || ($PROP_NAME == "tx_lanes_stable" && $PHY_ONLY_IF == 0 && $MAC_ONLY_IF == 0)} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
				}
			}

			"din" {ip_set "port.din.width_expr" 320}
			"din_start" {ip_set "port.din_start.width_expr" 5}
			"din_end_pos" {ip_set "port.din_end_pos.width_expr" 40}
			"dout_d" {ip_set "port.dout_d.width_expr" 320}
			"dout_c" {ip_set "port.dout_c.width_expr" 40}
			"dout_first_data" {ip_set "port.dout_first_data.width_expr" 5}
			"dout_last_data" {ip_set "port.dout_last_data.width_expr" 40}
			"dout_runt_last_data" {ip_set "port.dout_runt_last_data.width_expr" 5}
			"dout_payload" {ip_set "port.dout_payload.width_expr" 5}
			"dout_dst_addr_match" {ip_set "port.dout_dst_addr_match.width_expr" 5}	
			"tx_serial_clk" {ip_set "port.tx_serial_clk.width_expr" 10}
			"a10_reconfig_address" {ip_set "port.a10_reconfig_address.width_expr" 14}
			"reconfig_from_xcvr" {
				if {$RX_ONLY_IF} {
					ip_set "port.reconfig_from_xcvr.width_expr" 460
					ip_set "parameter.FROM_XCVR_WIDTH.value" 460
				} else {
					ip_set "port.reconfig_from_xcvr.width_expr" 920
					ip_set "parameter.FROM_XCVR_WIDTH.value" 920
				}
			}
			"reconfig_to_xcvr" {
			
				if {$RX_ONLY_IF} {
					ip_set "port.reconfig_to_xcvr.width_expr" 700
					ip_set "parameter.TO_XCVR_WIDTH.value" 700
				} else {
					ip_set "port.reconfig_to_xcvr.width_expr" 1400
					ip_set "parameter.TO_XCVR_WIDTH.value" 1400
				}
			}
		}
	} else { # "40 Gbe"
		switch $PROP_NAME {
			"rx_serial" {
				if {$MAC_ONLY_IF || $TX_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "rx_serial_reg" 4 input
				} else {
					::alt_e40_e100::interfaces::create_dynamic_port "rx_serial" 4 input
					ip_set "interface.rx_serial.assignment" [list "ui.blockdiagram.direction" input]
					set_port_property rx_serial fragment_list "rx_serial_reg(3:0)"
				}
			}
			"tx_serial" {
				if {$MAC_ONLY_IF || $RX_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "tx_serial_reg" 4 output
				} else {
					::alt_e40_e100::interfaces::create_dynamic_port "tx_serial" 4 output
					ip_set "interface.tx_serial.assignment" [list "ui.blockdiagram.direction" output]
					set_port_property tx_serial fragment_list "tx_serial_reg(3:0)"
				}
			}
			
						
			"rx_mii_valid" - 
			"lanes_deskewed" -
			"rx_mii_d" -
			"rx_mii_c" {
				set bus ""
				set width 1
				if {$PROP_NAME == "rx_mii_d"} {set bus "(127:0)"}
				if {$PROP_NAME == "rx_mii_d"} {set width 128}
				if {$PROP_NAME == "rx_mii_c"} {set bus "(15:0)"}
				if {$PROP_NAME == "rx_mii_c"} {set width 16}
				if {$PHY_ONLY_IF || ($PROP_NAME == "lanes_deskewed" && $PHY_ONLY_IF == 0 && $MAC_ONLY_IF == 0)} {		
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					if {$TX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width				
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					if {$TX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
				}
			}
			
			"tx_mii_d" -
			"tx_mii_c" -
			"tx_mii_valid" {
				set bus ""
				set width 1
				if {$PROP_NAME == "tx_mii_d"} {set bus "(127:0)"}
				if {$PROP_NAME == "tx_mii_d"} {set width 128}
				if {$PROP_NAME == "tx_mii_c"} {set bus "(15:0)"}
				if {$PROP_NAME == "tx_mii_c"} {set width 16}
				if {$PHY_ONLY_IF} {			
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width output
				}
			}
			
			"tx_mii_ready" -
			"tx_lanes_stable" {
				set bus ""
				set width 1
				if {$PHY_ONLY_IF || ($PROP_NAME == "tx_lanes_stable" && $PHY_ONLY_IF == 0 && $MAC_ONLY_IF == 0)} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    output
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" output]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_phy${bus}"
					}
				} elseif {$MAC_ONLY_IF} {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
					if {$RX_ONLY_IF} {
						::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					} else {
						::alt_e40_e100::interfaces::create_dynamic_port $PROP_NAME 1  input
						ip_set "port.${PROP_NAME}.direction"    input
						ip_set "interface.${PROP_NAME}.assignment" [list "ui.blockdiagram.direction" input]
						ip_set "port.${PROP_NAME}.width_expr" $width
						set_port_property ${PROP_NAME} fragment_list "${PROP_NAME}_mac${bus}"
					}
				} else {
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_mac" $width input
					::alt_e40_e100::interfaces::term_in_port "${PROP_NAME}_phy" $width output
				}
			}
			"din" {ip_set "port.din.width_expr" 128}
			"din_start" {ip_set "port.din_start.width_expr" 2}
			"din_end_pos" {ip_set "port.din_end_pos.width_expr" 16}
			"dout_d" {ip_set "port.dout_d.width_expr" 128}
			"dout_c" {ip_set "port.dout_c.width_expr" 16}
			"dout_first_data" {ip_set "port.dout_first_data.width_expr" 2}
			"dout_last_data" {ip_set "port.dout_last_data.width_expr" 16}
			"dout_runt_last_data" {ip_set "port.dout_runt_last_data.width_expr" 2}
			"dout_payload" {ip_set "port.dout_payload.width_expr" 2}
			"dout_dst_addr_match" {ip_set "port.dout_dst_addr_match.width_expr" 2}
			"tx_serial_clk" {ip_set "port.tx_serial_clk.width_expr" 4}
			"a10_reconfig_address" {ip_set "port.a10_reconfig_address.width_expr" 12}
			"reconfig_from_xcvr" {
				if {$RX_ONLY_IF} {
					ip_set "port.reconfig_from_xcvr.width_expr" 184
					ip_set "parameter.FROM_XCVR_WIDTH.value" 184
				} else {
					ip_set "port.reconfig_from_xcvr.width_expr" 368
					ip_set "parameter.FROM_XCVR_WIDTH.value" 368
				}
			}
			"reconfig_to_xcvr" {
				if {$RX_ONLY_IF} {
					ip_set "port.reconfig_to_xcvr.width_expr" 280
					ip_set "parameter.TO_XCVR_WIDTH.value" 280
				} else {
					ip_set "port.reconfig_to_xcvr.width_expr" 560
					ip_set "parameter.TO_XCVR_WIDTH.value" 560
				}
			}
		}
	}
}

proc ::alt_e40_e100::interfaces::declare_interfaces {} {
  variable interfaces
  ip_declare_interfaces $interfaces
}

proc ::alt_e40_e100::interfaces::elaborate {} {
  ip_elaborate_interfaces
}

proc ::alt_e40_e100::interfaces::elaborate_reset {} {
  ip_set "interface.pma_arst_ST.synchronousEdges" NONE
  ip_set "interface.pcs_rx_arst_ST.synchronousEdges" NONE
  ip_set "interface.pcs_tx_arst_ST.synchronousEdges" NONE
  ip_set "interface.mac_rx_arst_ST.synchronousEdges" NONE
  ip_set "interface.mac_tx_arst_ST.synchronousEdges" NONE
}

