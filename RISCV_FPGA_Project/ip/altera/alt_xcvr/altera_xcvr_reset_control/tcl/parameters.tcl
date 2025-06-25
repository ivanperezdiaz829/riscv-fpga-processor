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


package provide altera_xcvr_reset_control::parameters 12.0

package require alt_xcvr::ip_tcl::ip_module
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::utils::common


namespace eval ::altera_xcvr_reset_control::parameters:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::ip_tcl::messages::*

  namespace export \
    declare_parameters \
    validate

  variable package_name
  variable val_prefix
  variable display_items
  variable parameters

  set package_name "altera_xcvr_reset_control::parameters"

  set display_items {\
    {NAME               GROUP             TYPE  ARGS  }\
    {"General Options"  ""                GROUP NOVAL }\
    {"TX PLL"           ""                GROUP NOVAL }\
    {"TX Channel"       ""                GROUP NOVAL }\
    {"RX Channel"       ""                GROUP NOVAL }\
  }
    
  set parameters {\
    {NAME                   DERIVED HDL_PARAMETER TYPE    DEFAULT_VALUE ALLOWED_RANGES                          ENABLED         VISIBLE DISPLAY_HINT  DISPLAY_UNITS DISPLAY_ITEM      DISPLAY_NAME                                VALIDATION_CALLBACK                                                     DESCRIPTION }\
    {CHANNELS               false   true          INTEGER 1             NOVAL                                   NOVAL           true    NOVAL         NOVAL         "General Options" "Number of transceiver channels"            NOVAL                                                                   "Specifies the number of channels that connect to the Transceiver PHY Reset Controller"}\
    {PLLS                   false   true          INTEGER 1             "1:1000"                                NOVAL           true    NOVAL         NOVAL         "General Options" "Number of TX PLLs"                         NOVAL                                                                   "Specifies the number of TX PLLs to that connect to the  Transceiver PHY Reset Controller."}\
    {SYS_CLK_IN_MHZ         false   true          INTEGER 250           "1:500"                                 NOVAL           true    NOVAL         MHz           "General Options" "Input clock frequency"                     NOVAL                                                                   "Specifies the frequency of the input clock"}\
    {SYNCHRONIZE_RESET      false   true          INTEGER 1             NOVAL                                   NOVAL           true    boolean       NOVAL         "General Options" "Synchronize reset input"                   NOVAL                                                                   "When enabled, the IP synchronizes the reset input before driving it to the internal reset logic. When disabled, the reset input is not synchronized."}\
    {REDUCED_SIM_TIME       false   true          INTEGER 1             NOVAL                                   NOVAL           true    boolean       NOVAL         "General Options" "Use fast reset for simulation"             NOVAL                                                                   "When enabled, the IP uses reduced reset timing for simulation."}\
    {gui_split_interfaces   false   false         INTEGER 0             NOVAL                                   false           false   boolean       NOVAL         "General Options" "Separate interface per channel/PLL"        NOVAL                                                                   "When enabled, the IP provides a separate reset interface for each channel and PLL."}\
    \
    {TX_PLL_ENABLE          false   true          INTEGER 1             NOVAL                                   NOVAL           true    boolean       NOVAL         "TX PLL"          "Enable TX PLL reset control"               NOVAL                                                                   "When enabled, the IP enables the control logic and reset signals for the TX PLL."}\
    {T_PLL_POWERDOWN        false   true          INTEGER 1000          NOVAL                                   TX_PLL_ENABLE   true    NOVAL         ns            "TX PLL"          "pll_powerdown duration"                    NOVAL                                                                   "Specifies the duration of the PLL powerdown period in nanoseconds. The default value is 1000 ns."}\
    {SYNCHRONIZE_PLL_RESET  false   true          INTEGER 0             NOVAL                                   TX_PLL_ENABLE   true    boolean       NOVAL         "TX PLL"          "Synchronize reset input for PLL powerdown" ::altera_xcvr_reset_control::parameters::validate_SYNCHRONIZE_PLL_RESET "When enabled, the Transceiver PHY Reset Controller synchronizes the pll_powerdown  reset input before driving it to the internal powerdown logic. When disabled, the input is not synchronized. Synchronization of the reset signal signal prevents PLL merging across multiple reset controllers. If you select this option, you must also enable the \"Synchronize reset input\" parameter."}\
    \
    {TX_ENABLE              false   true          INTEGER 1             NOVAL                                   NOVAL           true    boolean       NOVAL         "TX Channel"      "Enable TX channel reset control"           NOVAL                                                                   "When enabled, the IP enables control logic and status signals for the TX reset signals."}\
    {TX_PER_CHANNEL         false   true          INTEGER 0             NOVAL                                   TX_ENABLE       true    boolean       NOVAL         "TX Channel"      "Use separate TX reset per channel"         NOVAL                                                                   "When enabled, each TX channel has a separate reset controller."}\
    {gui_tx_auto_reset      false   false         INTEGER 1             {"0:Auto" "1:Manual" "2:Expose port"}   TX_ENABLE       true    NOVAL         NOVAL         "TX Channel"      "TX digital reset mode"                   NOVAL                                                                   "In Auto mode, the associated tx_digital_reset controller automatically resets whenever the pll_locked signal is deasserted. In Manual mode, the associated tx_digital_reset controller does not reset when the pll_locked signal is deasserted. If you select \"Expose port\" - the tx_manual signal is a top-level signal of the core."}\
    {T_TX_DIGITALRESET      false   true          INTEGER 20            NOVAL                                   TX_ENABLE       true    NOVAL         ns            "TX Channel"      "tx_digitalreset duration"                  NOVAL                                                                   "Specifies the time in ns to assert tx_digitalreset  after the reset input and all other reset conditions are removed. The value is rounded to the nearest clock cycle."}\
    {T_PLL_LOCK_HYST        false   true          INTEGER 0             NOVAL                                   TX_ENABLE       true    NOVAL         ns            "TX Channel"      "pll_locked input hysteresis"               NOVAL                                                                   "Specifies the amount of hysteresis to add to the pll_locked status input. Hysteresis filters spurious unreliable assertions of the pll_locked signal. A value of 0 adds no hysteresis."}\
    \
    {RX_ENABLE              false   true          INTEGER 1             NOVAL                                   NOVAL           true    boolean       NOVAL         "RX Channel"      "Enable RX channel reset control"           NOVAL                                                                   "When enabled, the IP enables control logic and status signals for the RX reset signals."}\
    {RX_PER_CHANNEL         false   true          INTEGER 0             NOVAL                                   RX_ENABLE       true    boolean       NOVAL         "RX Channel"      "Use separate RX reset per channel"         NOVAL                                                                   "When enabled, each RX channel has a separate reset input."}\
    {gui_rx_auto_reset      false   false         INTEGER 0             {"0:Auto" "1:Manual" "2:Expose port"}   RX_ENABLE       true    NOVAL         NOVAL         "RX Channel"      "RX digital reset mode"                   NOVAL                                                                   "In Auto mode, the associated rx_digital_reset controller automatically resets whenever the rx_is_lockedtodata signal is deasserted. In Manual mode, the associated rx_digital_reset controller does not reset when the rx_is_lockedtodata signal is deasserted. If you select Expose port - the rx_manual signal is a top-level signal of the core. If the core includes separate reset control for each RX channel, each RX channel uses its respective rx_is_lockedtodata signal for automatic reset control; otherwise, the inputs are 'AND'ed to provide internal status for the shared reset controller."}\
    {T_RX_ANALOGRESET       false   true          INTEGER 40            NOVAL                                   RX_ENABLE       true    NOVAL         ns            "RX Channel"      "rx_analogreset duration"                   NOVAL                                                                   "Specifies the time in ns to assert rx_analogreset after the reset input and all other reset conditions are removed. The value is rounded to the nearest clock cycle. The default value is 40 ns."}\
    {T_RX_DIGITALRESET      false   true          INTEGER 4000          NOVAL                                   RX_ENABLE       true    NOVAL         ns            "RX Channel"      "rx_digitalreset duration"                  NOVAL                                                                   "Specifies the time in ns to assert rx_digitalreset  after the reset input and all other reset conditions are removed. The value is rounded to the nearest clock cycle.The default value is 4000 ns."}\
    \
    {l_terminate_pll        true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_terminate_pll       NOVAL       }\
    {l_terminate_tx         true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_terminate_tx        NOVAL       }\
    {l_terminate_rx         true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_terminate_rx        NOVAL       }\
    {l_terminate_tx_manual  true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_terminate_tx_manual NOVAL       }\
    {l_terminate_rx_manual  true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_terminate_rx_manual NOVAL       }\
    {l_tx_manual_term       true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_tx_manual_term      NOVAL       }\
    {l_rx_manual_term       true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_rx_manual_term      NOVAL       }\
    {l_pll_select_split     true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_pll_select_split    NOVAL       }\
    {l_pll_select_width     true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_pll_select_width    NOVAL       }\
    {l_pll_select_base      true    false         INTEGER 0             NOVAL                                   NOVAL           false   NOVAL         NOVAL         NOVAL             NOVAL                                       ::altera_xcvr_reset_control::parameters::validate_l_pll_select_base     NOVAL       }\
  }

}

proc ::altera_xcvr_reset_control::parameters::declare_parameters {} {
  variable display_items
  variable parameters
  ip_declare_display_items $display_items
  ip_declare_parameters $parameters

}

proc ::altera_xcvr_reset_control::parameters::validate {} {
  ip_validate_parameters
}

##########################################################################
####################### Validation Callbacks #############################

###
# Validation for SYNCHRONIZE_PLL_RESET
proc ::altera_xcvr_reset_control::parameters::validate_SYNCHRONIZE_PLL_RESET { SYNCHRONIZE_PLL_RESET TX_PLL_ENABLE SYNCHRONIZE_RESET } {
  if { $TX_PLL_ENABLE } {
    if { $SYNCHRONIZE_PLL_RESET && !$SYNCHRONIZE_RESET } {
      ip_message error "\"[ip_get "parameter.SYNCHRONIZE_PLL_RESET.display_name"]\" requires \"[ip_get "parameter.SYNCHRONIZE_RESET.display_name"]\" to be enabled."
    }
  }
}

###
# Validation for l_terminate_pll
proc ::altera_xcvr_reset_control::parameters::validate_l_terminate_pll { TX_PLL_ENABLE } {
  ip_set "parameter.l_terminate_pll.value" [expr !$TX_PLL_ENABLE]
}


###
# Validation for l_terminate_tx
proc ::altera_xcvr_reset_control::parameters::validate_l_terminate_tx { TX_ENABLE } {
  ip_set "parameter.l_terminate_tx.value" [expr !$TX_ENABLE]
}

###
# Validation for l_terminate_rx
proc ::altera_xcvr_reset_control::parameters::validate_l_terminate_rx { RX_ENABLE } {
  ip_set "parameter.l_terminate_rx.value" [expr !$RX_ENABLE]
}

###
# Validation for l_pll_select_split
proc ::altera_xcvr_reset_control::parameters::validate_l_pll_select_split { TX_ENABLE TX_PER_CHANNEL gui_split_interfaces } {
  set do_split 0
  if { $TX_ENABLE == 1 && $gui_split_interfaces == 1 && $TX_PER_CHANNEL == 1 } {
    set do_split 1
  }
  ip_set "parameter.l_pll_select_split.value" $do_split
}

###
# Validation for l_pll_select_width
proc ::altera_xcvr_reset_control::parameters::validate_l_pll_select_width { CHANNELS TX_PER_CHANNEL l_pll_select_base } {
  if { $TX_PER_CHANNEL } {
    set l_pll_select_base [expr $l_pll_select_base * $CHANNELS]
  }
  ip_set "parameter.l_pll_select_width.value" $l_pll_select_base
}

###
# Validation for l_pll_select_base
proc ::altera_xcvr_reset_control::parameters::validate_l_pll_select_base { PLLS } {
  ip_set "parameter.l_pll_select_base.value" [::alt_xcvr::utils::common::clogb2 [expr {$PLLS-1}]]
}

###
# Validation for l_terminate_tx_manual
proc ::altera_xcvr_reset_control::parameters::validate_l_terminate_tx_manual { l_terminate_tx gui_tx_auto_reset } {
  set terminate 0
  if {$l_terminate_tx == 1 || $gui_tx_auto_reset == 0 || $gui_tx_auto_reset == 1} {
    set terminate 1
  }
  ip_set "parameter.l_terminate_tx_manual.value" $terminate
}

###
# Validation for l_terminate_rx_manual
proc ::altera_xcvr_reset_control::parameters::validate_l_terminate_rx_manual { l_terminate_rx gui_rx_auto_reset } {
  set terminate 0
  if {$gui_rx_auto_reset == 0 || $gui_rx_auto_reset == 1} {
    set terminate 1
  }
  ip_set "parameter.l_terminate_rx_manual.value" $terminate
}

###
# Validation for l_tx_manual_term
proc ::altera_xcvr_reset_control::parameters::validate_l_tx_manual_term { CHANNELS gui_tx_auto_reset gui_split_interfaces } {
  if {$gui_split_interfaces == 1} {
    set termval $gui_tx_auto_reset
  } else {
    set termval [expr pow(2,$CHANNELS) - 1]
    set termval [expr $termval * $gui_tx_auto_reset]
  }
  ip_set "parameter.l_tx_manual_term.value" $termval
}

###
# Validation for l_rx_manual_term
proc ::altera_xcvr_reset_control::parameters::validate_l_rx_manual_term { CHANNELS gui_rx_auto_reset gui_split_interfaces } {
  if {$gui_split_interfaces == 1} {
    set termval $gui_rx_auto_reset
  } else {
    set termval [expr pow(2,$CHANNELS) - 1]
    set termval [expr $termval * $gui_rx_auto_reset]
  }
  ip_set "parameter.l_rx_manual_term.value" $termval
}

####################### Validation Callbacks #############################
##########################################################################
