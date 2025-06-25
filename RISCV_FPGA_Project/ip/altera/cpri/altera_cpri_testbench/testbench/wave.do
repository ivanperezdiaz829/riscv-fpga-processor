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
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider -height 40 {ALTGX_CLK_RESET}
if [regexp {/tb/altera_cpri_inst/gxb_refclk}        [find signals /tb/altera_cpri_inst/gxb_refclk       ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_refclk       }
if [regexp {/tb/altera_cpri_inst/gxb_pll_inclk}     [find signals /tb/altera_cpri_inst/gxb_pll_inclk    ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_pll_inclk    } 
if [regexp {/tb/altera_cpri_inst/gxb_cal_blk_clk}   [find signals /tb/altera_cpri_inst/gxb_cal_blk_clk  ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_cal_blk_clk  } 
if [regexp {/tb/altera_cpri_inst/gxb_powerdown}     [find signals /tb/altera_cpri_inst/gxb_powerdown    ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_powerdown    } 
if [regexp {/tb/altera_cpri_inst/gxb_pll_locked}    [find signals /tb/altera_cpri_inst/gxb_pll_locked   ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_pll_locked   } 
if [regexp {/tb/altera_cpri_inst/gxb_rx_pll_locked} [find signals /tb/altera_cpri_inst/gxb_rx_pll_locked]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_rx_pll_locked} 
if [regexp {/tb/altera_cpri_inst/gxb_rx_freqlocked} [find signals /tb/altera_cpri_inst/gxb_rx_freqlocked]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_rx_freqlocked} 
if [regexp {/tb/altera_cpri_inst/gxb_rx_errdetect}  [find signals /tb/altera_cpri_inst/gxb_rx_errdetect ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_rx_errdetect } 
if [regexp {/tb/altera_cpri_inst/gxb_rx_disperr}    [find signals /tb/altera_cpri_inst/gxb_rx_disperr   ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_rx_disperr   } 
if [regexp {/tb/altera_cpri_inst/gxb_los}           [find signals /tb/altera_cpri_inst/gxb_los          ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/gxb_los          } 
if [regexp {/tb/altera_cpri_inst/gxb_txdataout}     [find signals /tb/altera_cpri_inst/gxb_txdataout    ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/gxb_txdataout  } 
if [regexp {/tb/altera_cpri_inst/gxb_rxdatain}      [find signals /tb/altera_cpri_inst/gxb_rxdatain     ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/gxb_rxdatain   } 
if [regexp {/tb/altera_cpri_inst/usr_clk}           [find signals /tb/altera_cpri_inst/usr_clk          ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/usr_clk          } 
if [regexp {/tb/altera_cpri_inst/usr_pma_clk}       [find signals /tb/altera_cpri_inst/usr_pma_clk      ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/usr_pma_clk      }

add wave -noupdate -divider -height 40 {ALTGX_RECONFIG}                                     
if [regexp {/tb/altera_cpri_inst/reconfig_clk}          [find signals /tb/altera_cpri_inst/reconfig_clk         ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reconfig_clk           }
if [regexp {/tb/altera_cpri_inst/reconfig_busy}         [find signals /tb/altera_cpri_inst/reconfig_busy        ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reconfig_busy          }
if [regexp {/tb/altera_cpri_inst/reconfig_write}        [find signals /tb/altera_cpri_inst/reconfig_write       ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reconfig_write         }
if [regexp {/tb/altera_cpri_inst/reconfig_done}         [find signals /tb/altera_cpri_inst/reconfig_done        ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reconfig_done          }
if [regexp {/tb/altera_cpri_inst/reconfig_togxb_m}      [find signals /tb/altera_cpri_inst/reconfig_togxb_m     ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_togxb_m     }
if [regexp {/tb/altera_cpri_inst/reconfig_togxb_s_tx}   [find signals /tb/altera_cpri_inst/reconfig_togxb_s_tx  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_togxb_s_tx  }
if [regexp {/tb/altera_cpri_inst/reconfig_togxb_s_rx}   [find signals /tb/altera_cpri_inst/reconfig_togxb_s_rx  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_togxb_s_rx  }
if [regexp {/tb/altera_cpri_inst/reconfig_fromgxb_m}    [find signals /tb/altera_cpri_inst/reconfig_fromgxb_m   ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_fromgxb_m   }
if [regexp {/tb/altera_cpri_inst/reconfig_fromgxb_s_tx} [find signals /tb/altera_cpri_inst/reconfig_fromgxb_s_tx]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_fromgxb_s_tx}
if [regexp {/tb/altera_cpri_inst/reconfig_fromgxb_s_rx} [find signals /tb/altera_cpri_inst/reconfig_fromgxb_s_rx]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_fromgxb_s_rx}
if [regexp {/tb/altera_cpri_inst/reconfig_from_xcvr_s_tx} [find signals /tb/altera_cpri_inst/reconfig_from_xcvr_s_tx]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_from_xcvr_s_tx} 
if [regexp {/tb/altera_cpri_inst/reconfig_to_xcvr_s_tx}   [find signals /tb/altera_cpri_inst/reconfig_to_xcvr_s_tx  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_to_xcvr_s_tx  }
if [regexp {/tb/altera_cpri_inst/reconfig_from_xcvr_s_rx} [find signals /tb/altera_cpri_inst/reconfig_from_xcvr_s_rx]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_from_xcvr_s_rx}
if [regexp {/tb/altera_cpri_inst/reconfig_to_xcvr_s_rx}   [find signals /tb/altera_cpri_inst/reconfig_to_xcvr_s_rx  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_to_xcvr_s_rx  }
if [regexp {/tb/altera_cpri_inst/reconfig_from_xcvr}      [find signals /tb/altera_cpri_inst/reconfig_from_xcvr     ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_from_xcvr     }
if [regexp {/tb/altera_cpri_inst/reconfig_to_xcvr}        [find signals /tb/altera_cpri_inst/reconfig_to_xcvr       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/reconfig_to_xcvr       }

if [regexp {/tb/altera_cpri_inst/pll_areset}        [find signals /tb/altera_cpri_inst/pll_areset       ]] {add wave -noupdate -divider -height 40 {ALTPLL_RECONFIG}}
if [regexp {/tb/altera_cpri_inst/pll_areset}        [find signals /tb/altera_cpri_inst/pll_areset       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_areset       }
if [regexp {/tb/altera_cpri_inst/pll_configupdate}  [find signals /tb/altera_cpri_inst/pll_configupdate ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_configupdate }
if [regexp {/tb/altera_cpri_inst/pll_scanclk}       [find signals /tb/altera_cpri_inst/pll_scanclk      ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_scanclk      }
if [regexp {/tb/altera_cpri_inst/pll_scanclkena}    [find signals /tb/altera_cpri_inst/pll_scanclkena   ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_scanclkena   }
if [regexp {/tb/altera_cpri_inst/pll_scandata}      [find signals /tb/altera_cpri_inst/pll_scandata     ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_scandata     }
if [regexp {/tb/altera_cpri_inst/pll_reconfig_done} [find signals /tb/altera_cpri_inst/pll_reconfig_done]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_reconfig_done}
if [regexp {/tb/altera_cpri_inst/pll_scandataout}   [find signals /tb/altera_cpri_inst/pll_scandataout  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/pll_scandataout  }

add wave -noupdate -divider -height 40 {CLOCK_RESET} 
if [regexp {/tb/altera_cpri_inst/cpri_clkout}     [find signals /tb/altera_cpri_inst/cpri_clkout    ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/cpri_clkout    } 
if [regexp {/tb/altera_cpri_inst/pll_clkout}      [find signals /tb/altera_cpri_inst/pll_clkout     ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/pll_clkout     } 
if [regexp {/tb/altera_cpri_inst/reset}           [find signals /tb/altera_cpri_inst/reset          ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reset          } 
if [regexp {/tb/altera_cpri_inst/reset_done}      [find signals /tb/altera_cpri_inst/reset_done     ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reset_done     } 
if [regexp {/tb/altera_cpri_inst/config_reset}    [find signals /tb/altera_cpri_inst/config_reset   ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/config_reset   } 
if [regexp {/tb/altera_cpri_inst/hw_reset_assert} [find signals /tb/altera_cpri_inst/hw_reset_assert]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/hw_reset_assert} 
if [regexp {/tb/altera_cpri_inst/hw_reset_req}    [find signals /tb/altera_cpri_inst/hw_reset_req   ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/hw_reset_req   } 
if [regexp {/tb/altera_cpri_inst/clk_ex_delay}    [find signals /tb/altera_cpri_inst/clk_ex_delay   ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/clk_ex_delay   } 
if [regexp {/tb/altera_cpri_inst/reset_ex_delay}  [find signals /tb/altera_cpri_inst/reset_ex_delay ]] {add wave -noupdate -format Logic -radix hexadecimal /tb/altera_cpri_inst/reset_ex_delay }

add wave -noupdate -divider -height 40 {CPRI Status} 
if [regexp {/tb/altera_cpri_inst/extended_rx_status_data} [find signals /tb/altera_cpri_inst/extended_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/extended_rx_status_data}
if [regexp {/tb/altera_cpri_inst/datarate_en}             [find signals /tb/altera_cpri_inst/datarate_en            ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/datarate_en            }
if [regexp {/tb/altera_cpri_inst/datarate_set}            [find signals /tb/altera_cpri_inst/datarate_set           ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/datarate_set           }
           
add wave -noupdate -divider -height 40 {CPU Interface} 
if [regexp {/tb/altera_cpri_inst/cpu_clk}         [find signals /tb/altera_cpri_inst/cpu_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_clk        }
if [regexp {/tb/altera_cpri_inst/cpu_reset}       [find signals /tb/altera_cpri_inst/cpu_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_reset      }
if [regexp {/tb/altera_cpri_inst/cpu_address}     [find signals /tb/altera_cpri_inst/cpu_address    ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpu_address    }
if [regexp {/tb/altera_cpri_inst/cpu_byteenable}  [find signals /tb/altera_cpri_inst/cpu_byteenable ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpu_byteenable }
if [regexp {/tb/altera_cpri_inst/cpu_writedata}   [find signals /tb/altera_cpri_inst/cpu_writedata  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpu_writedata  }
if [regexp {/tb/altera_cpri_inst/cpu_readdata}    [find signals /tb/altera_cpri_inst/cpu_readdata   ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpu_readdata   }
if [regexp {/tb/altera_cpri_inst/cpu_read}        [find signals /tb/altera_cpri_inst/cpu_read       ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_read       }
if [regexp {/tb/altera_cpri_inst/cpu_write}       [find signals /tb/altera_cpri_inst/cpu_write      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_write      }
if [regexp {/tb/altera_cpri_inst/cpu_waitrequest} [find signals /tb/altera_cpri_inst/cpu_waitrequest]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_waitrequest}
if [regexp {/tb/altera_cpri_inst/cpu_irq}         [find signals /tb/altera_cpri_inst/cpu_irq        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_irq        }
if [regexp {/tb/altera_cpri_inst/cpu_irq_vector } [find signals /tb/altera_cpri_inst/cpu_irq_vector ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpu_irq_vector }

add wave -noupdate -divider -height 40 {Auxiliary Interface}
if [regexp {/tb/altera_cpri_inst/aux_rx_status_data} [find signals /tb/altera_cpri_inst/aux_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/aux_rx_status_data}
if [regexp {/tb/altera_cpri_inst/aux_tx_status_data} [find signals /tb/altera_cpri_inst/aux_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/aux_tx_status_data}
if [regexp {/tb/altera_cpri_inst/aux_tx_mask_data}   [find signals /tb/altera_cpri_inst/aux_tx_mask_data  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/aux_tx_mask_data  }

if [regexp {/tb/altera_cpri_inst/cpri_mii_txclk} [find signals /tb/altera_cpri_inst/cpri_mii_txclk]] {add wave -noupdate -divider -height 40 {MII Interface}}
if [regexp {/tb/altera_cpri_inst/cpri_mii_txclk} [find signals /tb/altera_cpri_inst/cpri_mii_txclk]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_txclk }
if [regexp {/tb/altera_cpri_inst/cpri_mii_txrd}  [find signals /tb/altera_cpri_inst/cpri_mii_txrd ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_txrd  }
if [regexp {/tb/altera_cpri_inst/cpri_mii_txen}  [find signals /tb/altera_cpri_inst/cpri_mii_txen ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_txen  }
if [regexp {/tb/altera_cpri_inst/cpri_mii_txer}  [find signals /tb/altera_cpri_inst/cpri_mii_txer ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_txer  }
if [regexp {/tb/altera_cpri_inst/cpri_mii_txd}   [find signals /tb/altera_cpri_inst/cpri_mii_txd  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_txd   } 
if [regexp {/tb/altera_cpri_inst/cpri_mii_rxclk} [find signals /tb/altera_cpri_inst/cpri_mii_rxclk]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_rxclk }
if [regexp {/tb/altera_cpri_inst/cpri_mii_rxwr}  [find signals /tb/altera_cpri_inst/cpri_mii_rxwr ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_rxwr  }
if [regexp {/tb/altera_cpri_inst/cpri_mii_rxdv}  [find signals /tb/altera_cpri_inst/cpri_mii_rxdv ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_rxdv  } 
if [regexp {/tb/altera_cpri_inst/cpri_mii_rxer}  [find signals /tb/altera_cpri_inst/cpri_mii_rxer ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_rxer  }
if [regexp {/tb/altera_cpri_inst/cpri_mii_rxd}   [find signals /tb/altera_cpri_inst/cpri_mii_rxd  ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/cpri_mii_rxd   }

add wave -noupdate -divider -height 10 {MAPPING Channel} 
if [regexp {/tb/altera_cpri_inst/map0_rx_data}        [find signals /tb/altera_cpri_inst/map0_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 0}}
if [regexp {/tb/altera_cpri_inst/map0_rx_clk}         [find signals /tb/altera_cpri_inst/map0_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map0_rx_reset}       [find signals /tb/altera_cpri_inst/map0_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_reset}
if [regexp {/tb/altera_cpri_inst/map0_rx_ready}       [find signals /tb/altera_cpri_inst/map0_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map0_rx_data}        [find signals /tb/altera_cpri_inst/map0_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map0_rx_data} 
if [regexp {/tb/altera_cpri_inst/map0_rx_valid}       [find signals /tb/altera_cpri_inst/map0_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map0_rx_resync}      [find signals /tb/altera_cpri_inst/map0_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map0_rx_status_data} [find signals /tb/altera_cpri_inst/map0_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map0_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map0_rx_start}       [find signals /tb/altera_cpri_inst/map0_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_rx_start} 
if [regexp {/tb/altera_cpri_inst/map0_tx_clk}         [find signals /tb/altera_cpri_inst/map0_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_tx_clk}
if [regexp {/tb/altera_cpri_inst/map0_tx_reset}       [find signals /tb/altera_cpri_inst/map0_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map0_tx_ready}       [find signals /tb/altera_cpri_inst/map0_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map0_tx_data}        [find signals /tb/altera_cpri_inst/map0_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map0_tx_data} 
if [regexp {/tb/altera_cpri_inst/map0_tx_valid}       [find signals /tb/altera_cpri_inst/map0_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map0_tx_resync}      [find signals /tb/altera_cpri_inst/map0_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map0_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map0_tx_status_data} [find signals /tb/altera_cpri_inst/map0_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map0_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map1_rx_data}        [find signals /tb/altera_cpri_inst/map1_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 1}}
if [regexp {/tb/altera_cpri_inst/map1_rx_clk}         [find signals /tb/altera_cpri_inst/map1_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map1_rx_reset}       [find signals /tb/altera_cpri_inst/map1_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_reset}
if [regexp {/tb/altera_cpri_inst/map1_rx_ready}       [find signals /tb/altera_cpri_inst/map1_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map1_rx_data}        [find signals /tb/altera_cpri_inst/map1_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map1_rx_data} 
if [regexp {/tb/altera_cpri_inst/map1_rx_valid}       [find signals /tb/altera_cpri_inst/map1_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map1_rx_resync}      [find signals /tb/altera_cpri_inst/map1_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map1_rx_status_data} [find signals /tb/altera_cpri_inst/map1_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map1_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map1_rx_start}       [find signals /tb/altera_cpri_inst/map1_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_rx_start} 
if [regexp {/tb/altera_cpri_inst/map1_tx_clk}         [find signals /tb/altera_cpri_inst/map1_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_tx_clk}
if [regexp {/tb/altera_cpri_inst/map1_tx_reset}       [find signals /tb/altera_cpri_inst/map1_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map1_tx_ready}       [find signals /tb/altera_cpri_inst/map1_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map1_tx_data}        [find signals /tb/altera_cpri_inst/map1_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map1_tx_data} 
if [regexp {/tb/altera_cpri_inst/map1_tx_valid}       [find signals /tb/altera_cpri_inst/map1_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map1_tx_resync}      [find signals /tb/altera_cpri_inst/map1_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map1_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map1_tx_status_data} [find signals /tb/altera_cpri_inst/map1_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map1_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map2_rx_data}        [find signals /tb/altera_cpri_inst/map2_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 2}}
if [regexp {/tb/altera_cpri_inst/map2_rx_clk}         [find signals /tb/altera_cpri_inst/map2_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map2_rx_reset}       [find signals /tb/altera_cpri_inst/map2_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_reset}
if [regexp {/tb/altera_cpri_inst/map2_rx_ready}       [find signals /tb/altera_cpri_inst/map2_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map2_rx_data}        [find signals /tb/altera_cpri_inst/map2_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map2_rx_data} 
if [regexp {/tb/altera_cpri_inst/map2_rx_valid}       [find signals /tb/altera_cpri_inst/map2_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map2_rx_resync}      [find signals /tb/altera_cpri_inst/map2_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map2_rx_status_data} [find signals /tb/altera_cpri_inst/map2_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map2_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map2_rx_start}       [find signals /tb/altera_cpri_inst/map2_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_rx_start} 
if [regexp {/tb/altera_cpri_inst/map2_tx_clk}         [find signals /tb/altera_cpri_inst/map2_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_tx_clk}
if [regexp {/tb/altera_cpri_inst/map2_tx_reset}       [find signals /tb/altera_cpri_inst/map2_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map2_tx_ready}       [find signals /tb/altera_cpri_inst/map2_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map2_tx_data}        [find signals /tb/altera_cpri_inst/map2_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map2_tx_data} 
if [regexp {/tb/altera_cpri_inst/map2_tx_valid}       [find signals /tb/altera_cpri_inst/map2_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map2_tx_resync}      [find signals /tb/altera_cpri_inst/map2_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map2_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map2_tx_status_data} [find signals /tb/altera_cpri_inst/map2_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map2_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map3_rx_data}        [find signals /tb/altera_cpri_inst/map3_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 3}}
if [regexp {/tb/altera_cpri_inst/map3_rx_clk}         [find signals /tb/altera_cpri_inst/map3_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map3_rx_reset}       [find signals /tb/altera_cpri_inst/map3_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_reset}
if [regexp {/tb/altera_cpri_inst/map3_rx_ready}       [find signals /tb/altera_cpri_inst/map3_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map3_rx_data}        [find signals /tb/altera_cpri_inst/map3_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map3_rx_data} 
if [regexp {/tb/altera_cpri_inst/map3_rx_valid}       [find signals /tb/altera_cpri_inst/map3_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map3_rx_resync}      [find signals /tb/altera_cpri_inst/map3_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map3_rx_status_data} [find signals /tb/altera_cpri_inst/map3_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map3_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map3_rx_start}       [find signals /tb/altera_cpri_inst/map3_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_rx_start} 
if [regexp {/tb/altera_cpri_inst/map3_tx_clk}         [find signals /tb/altera_cpri_inst/map3_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_tx_clk}
if [regexp {/tb/altera_cpri_inst/map3_tx_reset}       [find signals /tb/altera_cpri_inst/map3_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map3_tx_ready}       [find signals /tb/altera_cpri_inst/map3_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map3_tx_data}        [find signals /tb/altera_cpri_inst/map3_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map3_tx_data} 
if [regexp {/tb/altera_cpri_inst/map3_tx_valid}       [find signals /tb/altera_cpri_inst/map3_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map3_tx_resync}      [find signals /tb/altera_cpri_inst/map3_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map3_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map3_tx_status_data} [find signals /tb/altera_cpri_inst/map3_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map3_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map4_rx_data}        [find signals /tb/altera_cpri_inst/map4_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 4}}
if [regexp {/tb/altera_cpri_inst/map4_rx_clk}         [find signals /tb/altera_cpri_inst/map4_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map4_rx_reset}       [find signals /tb/altera_cpri_inst/map4_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_reset}
if [regexp {/tb/altera_cpri_inst/map4_rx_ready}       [find signals /tb/altera_cpri_inst/map4_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map4_rx_data}        [find signals /tb/altera_cpri_inst/map4_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map4_rx_data} 
if [regexp {/tb/altera_cpri_inst/map4_rx_valid}       [find signals /tb/altera_cpri_inst/map4_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map4_rx_resync}      [find signals /tb/altera_cpri_inst/map4_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map4_rx_status_data} [find signals /tb/altera_cpri_inst/map4_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map4_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map4_rx_start}       [find signals /tb/altera_cpri_inst/map4_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_rx_start} 
if [regexp {/tb/altera_cpri_inst/map4_tx_clk}         [find signals /tb/altera_cpri_inst/map4_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_tx_clk}
if [regexp {/tb/altera_cpri_inst/map4_tx_reset}       [find signals /tb/altera_cpri_inst/map4_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map4_tx_ready}       [find signals /tb/altera_cpri_inst/map4_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map4_tx_data}        [find signals /tb/altera_cpri_inst/map4_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map4_tx_data} 
if [regexp {/tb/altera_cpri_inst/map4_tx_valid}       [find signals /tb/altera_cpri_inst/map4_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map4_tx_resync}      [find signals /tb/altera_cpri_inst/map4_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map4_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map4_tx_status_data} [find signals /tb/altera_cpri_inst/map4_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map4_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map5_rx_data}        [find signals /tb/altera_cpri_inst/map5_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 5}}
if [regexp {/tb/altera_cpri_inst/map5_rx_clk}         [find signals /tb/altera_cpri_inst/map5_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map5_rx_reset}       [find signals /tb/altera_cpri_inst/map5_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_reset}
if [regexp {/tb/altera_cpri_inst/map5_rx_ready}       [find signals /tb/altera_cpri_inst/map5_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map5_rx_data}        [find signals /tb/altera_cpri_inst/map5_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map5_rx_data} 
if [regexp {/tb/altera_cpri_inst/map5_rx_valid}       [find signals /tb/altera_cpri_inst/map5_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map5_rx_resync}      [find signals /tb/altera_cpri_inst/map5_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map5_rx_status_data} [find signals /tb/altera_cpri_inst/map5_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map5_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map5_rx_start}       [find signals /tb/altera_cpri_inst/map5_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_rx_start} 
if [regexp {/tb/altera_cpri_inst/map5_tx_clk}         [find signals /tb/altera_cpri_inst/map5_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_tx_clk}
if [regexp {/tb/altera_cpri_inst/map5_tx_reset}       [find signals /tb/altera_cpri_inst/map5_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map5_tx_ready}       [find signals /tb/altera_cpri_inst/map5_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map5_tx_data}        [find signals /tb/altera_cpri_inst/map5_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map5_tx_data} 
if [regexp {/tb/altera_cpri_inst/map5_tx_valid}       [find signals /tb/altera_cpri_inst/map5_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map5_tx_resync}      [find signals /tb/altera_cpri_inst/map5_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map5_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map5_tx_status_data} [find signals /tb/altera_cpri_inst/map5_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map5_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map6_rx_data}        [find signals /tb/altera_cpri_inst/map6_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 6}}
if [regexp {/tb/altera_cpri_inst/map6_rx_clk}         [find signals /tb/altera_cpri_inst/map6_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map6_rx_reset}       [find signals /tb/altera_cpri_inst/map6_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_reset}
if [regexp {/tb/altera_cpri_inst/map6_rx_ready}       [find signals /tb/altera_cpri_inst/map6_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map6_rx_data}        [find signals /tb/altera_cpri_inst/map6_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map6_rx_data} 
if [regexp {/tb/altera_cpri_inst/map6_rx_valid}       [find signals /tb/altera_cpri_inst/map6_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map6_rx_resync}      [find signals /tb/altera_cpri_inst/map6_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map6_rx_status_data} [find signals /tb/altera_cpri_inst/map6_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map6_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map6_rx_start}       [find signals /tb/altera_cpri_inst/map6_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_rx_start} 
if [regexp {/tb/altera_cpri_inst/map6_tx_clk}         [find signals /tb/altera_cpri_inst/map6_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_tx_clk}
if [regexp {/tb/altera_cpri_inst/map6_tx_reset}       [find signals /tb/altera_cpri_inst/map6_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map6_tx_ready}       [find signals /tb/altera_cpri_inst/map6_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map6_tx_data}        [find signals /tb/altera_cpri_inst/map6_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map6_tx_data} 
if [regexp {/tb/altera_cpri_inst/map6_tx_valid}       [find signals /tb/altera_cpri_inst/map6_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map6_tx_resync}      [find signals /tb/altera_cpri_inst/map6_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map6_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map6_tx_status_data} [find signals /tb/altera_cpri_inst/map6_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map6_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map7_rx_data}        [find signals /tb/altera_cpri_inst/map7_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 7}}
if [regexp {/tb/altera_cpri_inst/map7_rx_clk}         [find signals /tb/altera_cpri_inst/map7_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map7_rx_reset}       [find signals /tb/altera_cpri_inst/map7_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_reset}
if [regexp {/tb/altera_cpri_inst/map7_rx_ready}       [find signals /tb/altera_cpri_inst/map7_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map7_rx_data}        [find signals /tb/altera_cpri_inst/map7_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map7_rx_data} 
if [regexp {/tb/altera_cpri_inst/map7_rx_valid}       [find signals /tb/altera_cpri_inst/map7_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map7_rx_resync}      [find signals /tb/altera_cpri_inst/map7_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map7_rx_status_data} [find signals /tb/altera_cpri_inst/map7_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map7_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map7_rx_start}       [find signals /tb/altera_cpri_inst/map7_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_rx_start} 
if [regexp {/tb/altera_cpri_inst/map7_tx_clk}         [find signals /tb/altera_cpri_inst/map7_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_tx_clk}
if [regexp {/tb/altera_cpri_inst/map7_tx_reset}       [find signals /tb/altera_cpri_inst/map7_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map7_tx_ready}       [find signals /tb/altera_cpri_inst/map7_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map7_tx_data}        [find signals /tb/altera_cpri_inst/map7_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map7_tx_data} 
if [regexp {/tb/altera_cpri_inst/map7_tx_valid}       [find signals /tb/altera_cpri_inst/map7_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map7_tx_resync}      [find signals /tb/altera_cpri_inst/map7_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map7_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map7_tx_status_data} [find signals /tb/altera_cpri_inst/map7_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map7_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map8_rx_data}        [find signals /tb/altera_cpri_inst/map8_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 8}}
if [regexp {/tb/altera_cpri_inst/map8_rx_clk}         [find signals /tb/altera_cpri_inst/map8_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map8_rx_reset}       [find signals /tb/altera_cpri_inst/map8_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_reset}
if [regexp {/tb/altera_cpri_inst/map8_rx_ready}       [find signals /tb/altera_cpri_inst/map8_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map8_rx_data}        [find signals /tb/altera_cpri_inst/map8_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map8_rx_data} 
if [regexp {/tb/altera_cpri_inst/map8_rx_valid}       [find signals /tb/altera_cpri_inst/map8_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map8_rx_resync}      [find signals /tb/altera_cpri_inst/map8_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map8_rx_status_data} [find signals /tb/altera_cpri_inst/map8_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map8_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map8_rx_start}       [find signals /tb/altera_cpri_inst/map8_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_rx_start} 
if [regexp {/tb/altera_cpri_inst/map8_tx_clk}         [find signals /tb/altera_cpri_inst/map8_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_tx_clk}
if [regexp {/tb/altera_cpri_inst/map8_tx_reset}       [find signals /tb/altera_cpri_inst/map8_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map8_tx_ready}       [find signals /tb/altera_cpri_inst/map8_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map8_tx_data}        [find signals /tb/altera_cpri_inst/map8_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map8_tx_data} 
if [regexp {/tb/altera_cpri_inst/map8_tx_valid}       [find signals /tb/altera_cpri_inst/map8_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map8_tx_resync}      [find signals /tb/altera_cpri_inst/map8_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map8_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map8_tx_status_data} [find signals /tb/altera_cpri_inst/map8_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map8_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map9_rx_data}        [find signals /tb/altera_cpri_inst/map9_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 9}}
if [regexp {/tb/altera_cpri_inst/map9_rx_clk}         [find signals /tb/altera_cpri_inst/map9_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map9_rx_reset}       [find signals /tb/altera_cpri_inst/map9_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_reset}
if [regexp {/tb/altera_cpri_inst/map9_rx_ready}       [find signals /tb/altera_cpri_inst/map9_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map9_rx_data}        [find signals /tb/altera_cpri_inst/map9_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map9_rx_data} 
if [regexp {/tb/altera_cpri_inst/map9_rx_valid}       [find signals /tb/altera_cpri_inst/map9_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map9_rx_resync}      [find signals /tb/altera_cpri_inst/map9_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map9_rx_status_data} [find signals /tb/altera_cpri_inst/map9_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map9_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map9_rx_start}       [find signals /tb/altera_cpri_inst/map9_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_rx_start} 
if [regexp {/tb/altera_cpri_inst/map9_tx_clk}         [find signals /tb/altera_cpri_inst/map9_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_tx_clk}
if [regexp {/tb/altera_cpri_inst/map9_tx_reset}       [find signals /tb/altera_cpri_inst/map9_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map9_tx_ready}       [find signals /tb/altera_cpri_inst/map9_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map9_tx_data}        [find signals /tb/altera_cpri_inst/map9_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map9_tx_data} 
if [regexp {/tb/altera_cpri_inst/map9_tx_valid}       [find signals /tb/altera_cpri_inst/map9_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map9_tx_resync}      [find signals /tb/altera_cpri_inst/map9_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map9_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map9_tx_status_data} [find signals /tb/altera_cpri_inst/map9_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map9_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map10_rx_data}        [find signals /tb/altera_cpri_inst/map10_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 10}}
if [regexp {/tb/altera_cpri_inst/map10_rx_clk}         [find signals /tb/altera_cpri_inst/map10_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map10_rx_reset}       [find signals /tb/altera_cpri_inst/map10_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_reset}
if [regexp {/tb/altera_cpri_inst/map10_rx_ready}       [find signals /tb/altera_cpri_inst/map10_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map10_rx_data}        [find signals /tb/altera_cpri_inst/map10_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map10_rx_data} 
if [regexp {/tb/altera_cpri_inst/map10_rx_valid}       [find signals /tb/altera_cpri_inst/map10_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map10_rx_resync}      [find signals /tb/altera_cpri_inst/map10_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map10_rx_status_data} [find signals /tb/altera_cpri_inst/map10_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map10_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map10_rx_start}       [find signals /tb/altera_cpri_inst/map10_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_rx_start} 
if [regexp {/tb/altera_cpri_inst/map10_tx_clk}         [find signals /tb/altera_cpri_inst/map10_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_tx_clk}
if [regexp {/tb/altera_cpri_inst/map10_tx_reset}       [find signals /tb/altera_cpri_inst/map10_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map10_tx_ready}       [find signals /tb/altera_cpri_inst/map10_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map10_tx_data}        [find signals /tb/altera_cpri_inst/map10_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map10_tx_data} 
if [regexp {/tb/altera_cpri_inst/map10_tx_valid}       [find signals /tb/altera_cpri_inst/map10_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map10_tx_resync}      [find signals /tb/altera_cpri_inst/map10_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map10_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map10_tx_status_data} [find signals /tb/altera_cpri_inst/map10_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map10_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map11_rx_data}        [find signals /tb/altera_cpri_inst/map11_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 11}}
if [regexp {/tb/altera_cpri_inst/map11_rx_clk}         [find signals /tb/altera_cpri_inst/map11_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map11_rx_reset}       [find signals /tb/altera_cpri_inst/map11_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_reset}
if [regexp {/tb/altera_cpri_inst/map11_rx_ready}       [find signals /tb/altera_cpri_inst/map11_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map11_rx_data}        [find signals /tb/altera_cpri_inst/map11_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map11_rx_data} 
if [regexp {/tb/altera_cpri_inst/map11_rx_valid}       [find signals /tb/altera_cpri_inst/map11_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map11_rx_resync}      [find signals /tb/altera_cpri_inst/map11_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map11_rx_status_data} [find signals /tb/altera_cpri_inst/map11_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map11_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map11_rx_start}       [find signals /tb/altera_cpri_inst/map11_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_rx_start} 
if [regexp {/tb/altera_cpri_inst/map11_tx_clk}         [find signals /tb/altera_cpri_inst/map11_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_tx_clk}
if [regexp {/tb/altera_cpri_inst/map11_tx_reset}       [find signals /tb/altera_cpri_inst/map11_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map11_tx_ready}       [find signals /tb/altera_cpri_inst/map11_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map11_tx_data}        [find signals /tb/altera_cpri_inst/map11_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map11_tx_data} 
if [regexp {/tb/altera_cpri_inst/map11_tx_valid}       [find signals /tb/altera_cpri_inst/map11_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map11_tx_resync}      [find signals /tb/altera_cpri_inst/map11_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map11_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map11_tx_status_data} [find signals /tb/altera_cpri_inst/map11_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map11_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map12_rx_data}        [find signals /tb/altera_cpri_inst/map12_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 12}}
if [regexp {/tb/altera_cpri_inst/map12_rx_clk}         [find signals /tb/altera_cpri_inst/map12_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map12_rx_reset}       [find signals /tb/altera_cpri_inst/map12_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_reset}
if [regexp {/tb/altera_cpri_inst/map12_rx_ready}       [find signals /tb/altera_cpri_inst/map12_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map12_rx_data}        [find signals /tb/altera_cpri_inst/map12_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map12_rx_data} 
if [regexp {/tb/altera_cpri_inst/map12_rx_valid}       [find signals /tb/altera_cpri_inst/map12_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map12_rx_resync}      [find signals /tb/altera_cpri_inst/map12_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map12_rx_status_data} [find signals /tb/altera_cpri_inst/map12_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map12_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map12_rx_start}       [find signals /tb/altera_cpri_inst/map12_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_rx_start} 
if [regexp {/tb/altera_cpri_inst/map12_tx_clk}         [find signals /tb/altera_cpri_inst/map12_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_tx_clk}
if [regexp {/tb/altera_cpri_inst/map12_tx_reset}       [find signals /tb/altera_cpri_inst/map12_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map12_tx_ready}       [find signals /tb/altera_cpri_inst/map12_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map12_tx_data}        [find signals /tb/altera_cpri_inst/map12_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map12_tx_data} 
if [regexp {/tb/altera_cpri_inst/map12_tx_valid}       [find signals /tb/altera_cpri_inst/map12_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map12_tx_resync}      [find signals /tb/altera_cpri_inst/map12_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map12_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map12_tx_status_data} [find signals /tb/altera_cpri_inst/map12_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map12_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map13_rx_data}        [find signals /tb/altera_cpri_inst/map13_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 13}}
if [regexp {/tb/altera_cpri_inst/map13_rx_clk}         [find signals /tb/altera_cpri_inst/map13_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map13_rx_reset}       [find signals /tb/altera_cpri_inst/map13_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_reset}
if [regexp {/tb/altera_cpri_inst/map13_rx_ready}       [find signals /tb/altera_cpri_inst/map13_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map13_rx_data}        [find signals /tb/altera_cpri_inst/map13_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map13_rx_data} 
if [regexp {/tb/altera_cpri_inst/map13_rx_valid}       [find signals /tb/altera_cpri_inst/map13_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map13_rx_resync}      [find signals /tb/altera_cpri_inst/map13_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map13_rx_status_data} [find signals /tb/altera_cpri_inst/map13_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map13_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map13_rx_start}       [find signals /tb/altera_cpri_inst/map13_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_rx_start} 
if [regexp {/tb/altera_cpri_inst/map13_tx_clk}         [find signals /tb/altera_cpri_inst/map13_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_tx_clk}
if [regexp {/tb/altera_cpri_inst/map13_tx_reset}       [find signals /tb/altera_cpri_inst/map13_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map13_tx_ready}       [find signals /tb/altera_cpri_inst/map13_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map13_tx_data}        [find signals /tb/altera_cpri_inst/map13_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map13_tx_data} 
if [regexp {/tb/altera_cpri_inst/map13_tx_valid}       [find signals /tb/altera_cpri_inst/map13_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map13_tx_resync}      [find signals /tb/altera_cpri_inst/map13_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map13_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map13_tx_status_data} [find signals /tb/altera_cpri_inst/map13_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map13_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map14_rx_data}        [find signals /tb/altera_cpri_inst/map14_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 14}}
if [regexp {/tb/altera_cpri_inst/map14_rx_clk}         [find signals /tb/altera_cpri_inst/map14_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map14_rx_reset}       [find signals /tb/altera_cpri_inst/map14_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_reset}
if [regexp {/tb/altera_cpri_inst/map14_rx_ready}       [find signals /tb/altera_cpri_inst/map14_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map14_rx_data}        [find signals /tb/altera_cpri_inst/map14_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map14_rx_data} 
if [regexp {/tb/altera_cpri_inst/map14_rx_valid}       [find signals /tb/altera_cpri_inst/map14_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map14_rx_resync}      [find signals /tb/altera_cpri_inst/map14_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map14_rx_status_data} [find signals /tb/altera_cpri_inst/map14_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map14_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map14_rx_start}       [find signals /tb/altera_cpri_inst/map14_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_rx_start} 
if [regexp {/tb/altera_cpri_inst/map14_tx_clk}         [find signals /tb/altera_cpri_inst/map14_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_tx_clk}
if [regexp {/tb/altera_cpri_inst/map14_tx_reset}       [find signals /tb/altera_cpri_inst/map14_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map14_tx_ready}       [find signals /tb/altera_cpri_inst/map14_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map14_tx_data}        [find signals /tb/altera_cpri_inst/map14_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map14_tx_data} 
if [regexp {/tb/altera_cpri_inst/map14_tx_valid}       [find signals /tb/altera_cpri_inst/map14_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map14_tx_resync}      [find signals /tb/altera_cpri_inst/map14_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map14_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map14_tx_status_data} [find signals /tb/altera_cpri_inst/map14_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map14_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map15_rx_data}        [find signals /tb/altera_cpri_inst/map15_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 15}}
if [regexp {/tb/altera_cpri_inst/map15_rx_clk}         [find signals /tb/altera_cpri_inst/map15_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map15_rx_reset}       [find signals /tb/altera_cpri_inst/map15_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_reset}
if [regexp {/tb/altera_cpri_inst/map15_rx_ready}       [find signals /tb/altera_cpri_inst/map15_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map15_rx_data}        [find signals /tb/altera_cpri_inst/map15_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map15_rx_data} 
if [regexp {/tb/altera_cpri_inst/map15_rx_valid}       [find signals /tb/altera_cpri_inst/map15_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map15_rx_resync}      [find signals /tb/altera_cpri_inst/map15_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map15_rx_status_data} [find signals /tb/altera_cpri_inst/map15_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map15_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map15_rx_start}       [find signals /tb/altera_cpri_inst/map15_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_rx_start} 
if [regexp {/tb/altera_cpri_inst/map15_tx_clk}         [find signals /tb/altera_cpri_inst/map15_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_tx_clk}
if [regexp {/tb/altera_cpri_inst/map15_tx_reset}       [find signals /tb/altera_cpri_inst/map15_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map15_tx_ready}       [find signals /tb/altera_cpri_inst/map15_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map15_tx_data}        [find signals /tb/altera_cpri_inst/map15_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map15_tx_data} 
if [regexp {/tb/altera_cpri_inst/map15_tx_valid}       [find signals /tb/altera_cpri_inst/map15_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map15_tx_resync}      [find signals /tb/altera_cpri_inst/map15_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map15_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map15_tx_status_data} [find signals /tb/altera_cpri_inst/map15_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map15_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map16_rx_data}        [find signals /tb/altera_cpri_inst/map16_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 16}}
if [regexp {/tb/altera_cpri_inst/map16_rx_clk}         [find signals /tb/altera_cpri_inst/map16_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map16_rx_reset}       [find signals /tb/altera_cpri_inst/map16_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_reset}
if [regexp {/tb/altera_cpri_inst/map16_rx_ready}       [find signals /tb/altera_cpri_inst/map16_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map16_rx_data}        [find signals /tb/altera_cpri_inst/map16_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map16_rx_data} 
if [regexp {/tb/altera_cpri_inst/map16_rx_valid}       [find signals /tb/altera_cpri_inst/map16_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map16_rx_resync}      [find signals /tb/altera_cpri_inst/map16_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map16_rx_status_data} [find signals /tb/altera_cpri_inst/map16_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map16_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map16_rx_start}       [find signals /tb/altera_cpri_inst/map16_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_rx_start} 
if [regexp {/tb/altera_cpri_inst/map16_tx_clk}         [find signals /tb/altera_cpri_inst/map16_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_tx_clk}
if [regexp {/tb/altera_cpri_inst/map16_tx_reset}       [find signals /tb/altera_cpri_inst/map16_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map16_tx_ready}       [find signals /tb/altera_cpri_inst/map16_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map16_tx_data}        [find signals /tb/altera_cpri_inst/map16_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map16_tx_data} 
if [regexp {/tb/altera_cpri_inst/map16_tx_valid}       [find signals /tb/altera_cpri_inst/map16_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map16_tx_resync}      [find signals /tb/altera_cpri_inst/map16_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map16_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map16_tx_status_data} [find signals /tb/altera_cpri_inst/map16_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map16_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map17_rx_data}        [find signals /tb/altera_cpri_inst/map17_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 17}}
if [regexp {/tb/altera_cpri_inst/map17_rx_clk}         [find signals /tb/altera_cpri_inst/map17_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map17_rx_reset}       [find signals /tb/altera_cpri_inst/map17_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_reset}
if [regexp {/tb/altera_cpri_inst/map17_rx_ready}       [find signals /tb/altera_cpri_inst/map17_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map17_rx_data}        [find signals /tb/altera_cpri_inst/map17_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map17_rx_data} 
if [regexp {/tb/altera_cpri_inst/map17_rx_valid}       [find signals /tb/altera_cpri_inst/map17_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map17_rx_resync}      [find signals /tb/altera_cpri_inst/map17_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map17_rx_status_data} [find signals /tb/altera_cpri_inst/map17_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map17_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map17_rx_start}       [find signals /tb/altera_cpri_inst/map17_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_rx_start} 
if [regexp {/tb/altera_cpri_inst/map17_tx_clk}         [find signals /tb/altera_cpri_inst/map17_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_tx_clk}
if [regexp {/tb/altera_cpri_inst/map17_tx_reset}       [find signals /tb/altera_cpri_inst/map17_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map17_tx_ready}       [find signals /tb/altera_cpri_inst/map17_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map17_tx_data}        [find signals /tb/altera_cpri_inst/map17_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map17_tx_data} 
if [regexp {/tb/altera_cpri_inst/map17_tx_valid}       [find signals /tb/altera_cpri_inst/map17_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map17_tx_resync}      [find signals /tb/altera_cpri_inst/map17_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map17_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map17_tx_status_data} [find signals /tb/altera_cpri_inst/map17_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map17_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map18_rx_data}        [find signals /tb/altera_cpri_inst/map18_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 18}}
if [regexp {/tb/altera_cpri_inst/map18_rx_clk}         [find signals /tb/altera_cpri_inst/map18_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map18_rx_reset}       [find signals /tb/altera_cpri_inst/map18_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_reset}
if [regexp {/tb/altera_cpri_inst/map18_rx_ready}       [find signals /tb/altera_cpri_inst/map18_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map18_rx_data}        [find signals /tb/altera_cpri_inst/map18_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map18_rx_data} 
if [regexp {/tb/altera_cpri_inst/map18_rx_valid}       [find signals /tb/altera_cpri_inst/map18_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map18_rx_resync}      [find signals /tb/altera_cpri_inst/map18_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map18_rx_status_data} [find signals /tb/altera_cpri_inst/map18_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map18_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map18_rx_start}       [find signals /tb/altera_cpri_inst/map18_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_rx_start} 
if [regexp {/tb/altera_cpri_inst/map18_tx_clk}         [find signals /tb/altera_cpri_inst/map18_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_tx_clk}
if [regexp {/tb/altera_cpri_inst/map18_tx_reset}       [find signals /tb/altera_cpri_inst/map18_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map18_tx_ready}       [find signals /tb/altera_cpri_inst/map18_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map18_tx_data}        [find signals /tb/altera_cpri_inst/map18_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map18_tx_data} 
if [regexp {/tb/altera_cpri_inst/map18_tx_valid}       [find signals /tb/altera_cpri_inst/map18_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map18_tx_resync}      [find signals /tb/altera_cpri_inst/map18_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map18_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map18_tx_status_data} [find signals /tb/altera_cpri_inst/map18_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map18_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map19_rx_data}        [find signals /tb/altera_cpri_inst/map19_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 19}}
if [regexp {/tb/altera_cpri_inst/map19_rx_clk}         [find signals /tb/altera_cpri_inst/map19_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map19_rx_reset}       [find signals /tb/altera_cpri_inst/map19_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_reset}
if [regexp {/tb/altera_cpri_inst/map19_rx_ready}       [find signals /tb/altera_cpri_inst/map19_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map19_rx_data}        [find signals /tb/altera_cpri_inst/map19_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map19_rx_data} 
if [regexp {/tb/altera_cpri_inst/map19_rx_valid}       [find signals /tb/altera_cpri_inst/map19_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map19_rx_resync}      [find signals /tb/altera_cpri_inst/map19_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map19_rx_status_data} [find signals /tb/altera_cpri_inst/map19_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map19_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map19_rx_start}       [find signals /tb/altera_cpri_inst/map19_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_rx_start} 
if [regexp {/tb/altera_cpri_inst/map19_tx_clk}         [find signals /tb/altera_cpri_inst/map19_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_tx_clk}
if [regexp {/tb/altera_cpri_inst/map19_tx_reset}       [find signals /tb/altera_cpri_inst/map19_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map19_tx_ready}       [find signals /tb/altera_cpri_inst/map19_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map19_tx_data}        [find signals /tb/altera_cpri_inst/map19_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map19_tx_data} 
if [regexp {/tb/altera_cpri_inst/map19_tx_valid}       [find signals /tb/altera_cpri_inst/map19_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map19_tx_resync}      [find signals /tb/altera_cpri_inst/map19_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map19_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map19_tx_status_data} [find signals /tb/altera_cpri_inst/map19_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map19_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map20_rx_data}        [find signals /tb/altera_cpri_inst/map20_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 20}}
if [regexp {/tb/altera_cpri_inst/map20_rx_clk}         [find signals /tb/altera_cpri_inst/map20_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map20_rx_reset}       [find signals /tb/altera_cpri_inst/map20_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_reset}
if [regexp {/tb/altera_cpri_inst/map20_rx_ready}       [find signals /tb/altera_cpri_inst/map20_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map20_rx_data}        [find signals /tb/altera_cpri_inst/map20_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map20_rx_data} 
if [regexp {/tb/altera_cpri_inst/map20_rx_valid}       [find signals /tb/altera_cpri_inst/map20_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map20_rx_resync}      [find signals /tb/altera_cpri_inst/map20_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map20_rx_status_data} [find signals /tb/altera_cpri_inst/map20_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map20_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map20_rx_start}       [find signals /tb/altera_cpri_inst/map20_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_rx_start} 
if [regexp {/tb/altera_cpri_inst/map20_tx_clk}         [find signals /tb/altera_cpri_inst/map20_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_tx_clk}
if [regexp {/tb/altera_cpri_inst/map20_tx_reset}       [find signals /tb/altera_cpri_inst/map20_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map20_tx_ready}       [find signals /tb/altera_cpri_inst/map20_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map20_tx_data}        [find signals /tb/altera_cpri_inst/map20_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map20_tx_data} 
if [regexp {/tb/altera_cpri_inst/map20_tx_valid}       [find signals /tb/altera_cpri_inst/map20_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map20_tx_resync}      [find signals /tb/altera_cpri_inst/map20_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map20_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map20_tx_status_data} [find signals /tb/altera_cpri_inst/map20_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map20_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map21_rx_data}        [find signals /tb/altera_cpri_inst/map21_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 21}}
if [regexp {/tb/altera_cpri_inst/map21_rx_clk}         [find signals /tb/altera_cpri_inst/map21_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map21_rx_reset}       [find signals /tb/altera_cpri_inst/map21_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_reset}
if [regexp {/tb/altera_cpri_inst/map21_rx_ready}       [find signals /tb/altera_cpri_inst/map21_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map21_rx_data}        [find signals /tb/altera_cpri_inst/map21_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map21_rx_data} 
if [regexp {/tb/altera_cpri_inst/map21_rx_valid}       [find signals /tb/altera_cpri_inst/map21_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map21_rx_resync}      [find signals /tb/altera_cpri_inst/map21_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map21_rx_status_data} [find signals /tb/altera_cpri_inst/map21_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map21_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map21_rx_start}       [find signals /tb/altera_cpri_inst/map21_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_rx_start} 
if [regexp {/tb/altera_cpri_inst/map21_tx_clk}         [find signals /tb/altera_cpri_inst/map21_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_tx_clk}
if [regexp {/tb/altera_cpri_inst/map21_tx_reset}       [find signals /tb/altera_cpri_inst/map21_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map21_tx_ready}       [find signals /tb/altera_cpri_inst/map21_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map21_tx_data}        [find signals /tb/altera_cpri_inst/map21_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map21_tx_data} 
if [regexp {/tb/altera_cpri_inst/map21_tx_valid}       [find signals /tb/altera_cpri_inst/map21_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map21_tx_resync}      [find signals /tb/altera_cpri_inst/map21_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map21_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map21_tx_status_data} [find signals /tb/altera_cpri_inst/map21_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map21_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map22_rx_data}        [find signals /tb/altera_cpri_inst/map22_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 22}}
if [regexp {/tb/altera_cpri_inst/map22_rx_clk}         [find signals /tb/altera_cpri_inst/map22_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map22_rx_reset}       [find signals /tb/altera_cpri_inst/map22_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_reset}
if [regexp {/tb/altera_cpri_inst/map22_rx_ready}       [find signals /tb/altera_cpri_inst/map22_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map22_rx_data}        [find signals /tb/altera_cpri_inst/map22_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map22_rx_data} 
if [regexp {/tb/altera_cpri_inst/map22_rx_valid}       [find signals /tb/altera_cpri_inst/map22_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map22_rx_resync}      [find signals /tb/altera_cpri_inst/map22_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map22_rx_status_data} [find signals /tb/altera_cpri_inst/map22_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map22_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map22_rx_start}       [find signals /tb/altera_cpri_inst/map22_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_rx_start} 
if [regexp {/tb/altera_cpri_inst/map22_tx_clk}         [find signals /tb/altera_cpri_inst/map22_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_tx_clk}
if [regexp {/tb/altera_cpri_inst/map22_tx_reset}       [find signals /tb/altera_cpri_inst/map22_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map22_tx_ready}       [find signals /tb/altera_cpri_inst/map22_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map22_tx_data}        [find signals /tb/altera_cpri_inst/map22_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map22_tx_data} 
if [regexp {/tb/altera_cpri_inst/map22_tx_valid}       [find signals /tb/altera_cpri_inst/map22_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map22_tx_resync}      [find signals /tb/altera_cpri_inst/map22_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map22_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map22_tx_status_data} [find signals /tb/altera_cpri_inst/map22_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map22_tx_status_data}

if [regexp {/tb/altera_cpri_inst/map23_rx_data}        [find signals /tb/altera_cpri_inst/map23_rx_data       ]] {add wave -noupdate -divider -height 40 {MAP Channel 23}}
if [regexp {/tb/altera_cpri_inst/map23_rx_clk}         [find signals /tb/altera_cpri_inst/map23_rx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_clk} 
if [regexp {/tb/altera_cpri_inst/map23_rx_reset}       [find signals /tb/altera_cpri_inst/map23_rx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_reset}
if [regexp {/tb/altera_cpri_inst/map23_rx_ready}       [find signals /tb/altera_cpri_inst/map23_rx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_ready} 
if [regexp {/tb/altera_cpri_inst/map23_rx_data}        [find signals /tb/altera_cpri_inst/map23_rx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map23_rx_data} 
if [regexp {/tb/altera_cpri_inst/map23_rx_valid}       [find signals /tb/altera_cpri_inst/map23_rx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_valid} 
if [regexp {/tb/altera_cpri_inst/map23_rx_resync}      [find signals /tb/altera_cpri_inst/map23_rx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_resync} 
if [regexp {/tb/altera_cpri_inst/map23_rx_status_data} [find signals /tb/altera_cpri_inst/map23_rx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map23_rx_status_data} 
if [regexp {/tb/altera_cpri_inst/map23_rx_start}       [find signals /tb/altera_cpri_inst/map23_rx_start      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_rx_start} 
if [regexp {/tb/altera_cpri_inst/map23_tx_clk}         [find signals /tb/altera_cpri_inst/map23_tx_clk        ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_tx_clk}
if [regexp {/tb/altera_cpri_inst/map23_tx_reset}       [find signals /tb/altera_cpri_inst/map23_tx_reset      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_tx_reset} 
if [regexp {/tb/altera_cpri_inst/map23_tx_ready}       [find signals /tb/altera_cpri_inst/map23_tx_ready      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_tx_ready} 
if [regexp {/tb/altera_cpri_inst/map23_tx_data}        [find signals /tb/altera_cpri_inst/map23_tx_data       ]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map23_tx_data} 
if [regexp {/tb/altera_cpri_inst/map23_tx_valid}       [find signals /tb/altera_cpri_inst/map23_tx_valid      ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_tx_valid} 
if [regexp {/tb/altera_cpri_inst/map23_tx_resync}      [find signals /tb/altera_cpri_inst/map23_tx_resync     ]] {add wave -noupdate -format Logic   -radix hexadecimal /tb/altera_cpri_inst/map23_tx_resync} 
if [regexp {/tb/altera_cpri_inst/map23_tx_status_data} [find signals /tb/altera_cpri_inst/map23_tx_status_data]] {add wave -noupdate -format Literal -radix hexadecimal /tb/altera_cpri_inst/map23_tx_status_data}

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
configure wave -namecolwidth 232
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {3000000001380 fs}
run -all
