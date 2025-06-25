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


package require -exact qsys 12.0
source ../device_tree_generation/hps_utils.tcl
#
# arm_gic_0
#
proc hps_instantiate_arm_gic_0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 arm_gic_0 arm_gic

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master arm_gic_0.axi_slave0 {0xfffed000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master arm_gic_0.axi_slave0 {0xfffed000}
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master arm_gic_0.axi_slave1 {0xfffec100}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master arm_gic_0.axi_slave1 {0xfffec100}
    }

}

#
# L2
#
proc hps_instantiate_L2 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 L2 L2

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection L2.interrupt_sender h2f_L2_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master L2.axi_slave0 {0xfffef000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master L2.axi_slave0 {0xfffef000}
    }



    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_32 L2.interrupt_sender 6

}

#
# dma
#
proc hps_instantiate_dma {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 dma dma

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection dma.interrupt_sender h2f_dma_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master dma.axi_slave0 {0xffe01000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master dma.axi_slave0 {0xffe01000}
    }



    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_104 dma.interrupt_sender 0

}

#
# sysmgr
#
proc hps_instantiate_sysmgr {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 sysmgr sysmgr

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master sysmgr.axi_slave0 {0xffd08000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master sysmgr.axi_slave0 {0xffd08000}
    }
    


}

#
# clkmgr
#
proc hps_instantiate_clkmgr {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 clkmgr clkmgr

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master clkmgr.axi_slave0 {0xffd04000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master clkmgr.axi_slave0 {0xffd04000}
    }


}

#
# rstmgr
#
proc hps_instantiate_rstmgr {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 rstmgr rstmgr

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master rstmgr.axi_slave0 {0xffd05000}

    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master rstmgr.axi_slave0 {0xffd05000}
    }


}

#
# fpgamgr
#
proc hps_instantiate_fpgamgr {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 fpgamgr fpgamgr

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection fpgamgr.interrupt_sender h2f_fpgamgr_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master fpgamgr.axi_slave0 {0xff706000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master fpgamgr.axi_slave0 {0xff706000}
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master fpgamgr.axi_slave1 {0xffb90000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master fpgamgr.axi_slave1 {0xffb90000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 fpgamgr.interrupt_sender 9

}

#
# uart0
#
proc hps_instantiate_uart0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 uart0 snps_uart

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection uart0.interrupt_sender h2f_uart0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master uart0.axi_slave0 {0xffc02000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master uart0.axi_slave0 {0xffc02000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 uart0.interrupt_sender 26

}

#
# uart1
#
proc hps_instantiate_uart1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 uart1 snps_uart

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection uart1.interrupt_sender h2f_uart1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master uart1.axi_slave0 {0xffc03000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master uart1.axi_slave0 {0xffc03000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 uart1.interrupt_sender 27

}

#
# timer0
#
proc hps_instantiate_timer0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 timer0 dw-apb-timer-sp

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection timer0.interrupt_sender h2f_timer0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master timer0.axi_slave0 {0xffc08000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master timer0.axi_slave0 {0xffc08000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 timer0.interrupt_sender 1

}

#
# timer1
#
proc hps_instantiate_timer1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 timer1 dw-apb-timer-sp

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection timer1.interrupt_sender h2f_timer1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master timer1.axi_slave0 {0xffc09000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master timer1.axi_slave0 {0xffc09000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 timer1.interrupt_sender 2

}

#
# timer2
#
proc hps_instantiate_timer2 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 timer2 dw-apb-timer-osc

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection timer2.interrupt_sender h2f_timer2_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master timer2.axi_slave0 {0xffd00000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master timer2.axi_slave0 {0xffd00000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 timer2.interrupt_sender 3

}

#
# timer3
#
proc hps_instantiate_timer3 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 timer3 dw-apb-timer-osc

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection timer3.interrupt_sender h2f_timer3_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master timer3.axi_slave0 {0xffd01000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master timer3.axi_slave0 {0xffd01000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 timer3.interrupt_sender 4

}

#
# gpio0
#
proc hps_instantiate_gpio0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 gpio0 dw-gpio

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection gpio0.interrupt_sender h2f_gpio0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master gpio0.axi_slave0 {0xff708000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master gpio0.axi_slave0 {0xff708000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 gpio0.interrupt_sender 28

}

#
# gpio1
#
proc hps_instantiate_gpio1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 gpio1 dw-gpio

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection gpio1.interrupt_sender h2f_gpio1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master gpio1.axi_slave0 {0xff709000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master gpio1.axi_slave0 {0xff709000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 gpio1.interrupt_sender 29

}

#
# gpio2
#
proc hps_instantiate_gpio2 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 gpio2 dw-gpio

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection gpio2.interrupt_sender h2f_gpio2_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master gpio2.axi_slave0 {0xff70a000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master gpio2.axi_slave0 {0xff70a000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_166 gpio2.interrupt_sender 0

}

#
# i2c0
#
proc hps_instantiate_i2c0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 i2c0 designware-i2c

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection i2c0.interrupt_sender h2f_i2c0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master i2c0.axi_slave0 {0xffc04000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master i2c0.axi_slave0 {0xffc04000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 i2c0.interrupt_sender 22

}

#
# i2c1
#
proc hps_instantiate_i2c1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 i2c1 designware-i2c

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection i2c1.interrupt_sender h2f_i2c1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master i2c1.axi_slave0 {0xffc05000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master i2c1.axi_slave0 {0xffc05000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 i2c1.interrupt_sender 23

}

#
# i2c2
#
proc hps_instantiate_i2c2 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 i2c2 designware-i2c

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection i2c2.interrupt_sender h2f_i2c2_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master i2c2.axi_slave0 {0xffc06000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master i2c2.axi_slave0 {0xffc06000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 i2c2.interrupt_sender 24

}

#
# i2c3
#
proc hps_instantiate_i2c3 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 i2c3 designware-i2c

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection i2c3.interrupt_sender h2f_i2c3_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master i2c3.axi_slave0 {0xffc07000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master i2c3.axi_slave0 {0xffc07000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 i2c3.interrupt_sender 25

}

#
# nand0
#
proc hps_instantiate_nand0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 nand0 denali_nand

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection nand0.interrupt_sender h2f_nand0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master nand0.axi_slave0 {0xff900000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master nand0.axi_slave0 {0xff900000}
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master nand0.axi_slave1 {0xffb80000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master nand0.axi_slave1 {0xffb80000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 nand0.interrupt_sender 8

}

#
# spi0
#
proc hps_instantiate_spi0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 spi0 spi

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection spi0.interrupt_sender h2f_spi0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master spi0.axi_slave0 {0xffe02000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master spi0.axi_slave0 {0xffe02000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 spi0.interrupt_sender 18

}

#
# spi1
#
proc hps_instantiate_spi1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 spi1 spi

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection spi1.interrupt_sender h2f_spi1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master spi1.axi_slave0 {0xffe03000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master spi1.axi_slave0 {0xffe03000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 spi1.interrupt_sender 19

}

#
# qspi
#
proc hps_instantiate_qspi {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 qspi qspi

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection qspi.interrupt_sender h2f_qspi_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master qspi.axi_slave0 {0xff705000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master qspi.axi_slave0 {0xff705000}
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master qspi.axi_slave1 {0xffa00000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master qspi.axi_slave1 {0xffa00000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 qspi.interrupt_sender 15

}

#
# sdmmc
#
proc hps_instantiate_sdmmc {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 sdmmc sdmmc

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection sdmmc.interrupt_sender h2f_sdmmc_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master sdmmc.axi_slave0 {0xff704000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master sdmmc.axi_slave0 {0xff704000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_136 sdmmc.interrupt_sender 3

}

#
# usb0
#
proc hps_instantiate_usb0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 usb0 usb

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection usb0.interrupt_sender h2f_usb0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master usb0.axi_slave0 {0xffb00000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master usb0.axi_slave0 {0xffb00000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_104 usb0.interrupt_sender 21

}

#
# usb1
#
proc hps_instantiate_usb1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 usb1 usb

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection usb1.interrupt_sender h2f_usb1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master usb1.axi_slave0 {0xffb40000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master usb1.axi_slave0 {0xffb40000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_104 usb1.interrupt_sender 24

}

#
# gmac0
#
proc hps_instantiate_gmac0 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 gmac0 stmmac

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection gmac0.interrupt_sender h2f_gmac0_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master gmac0.axi_slave0 {0xff700000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master gmac0.axi_slave0 {0xff700000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_104 gmac0.interrupt_sender 11

}

#
# gmac1
#
proc hps_instantiate_gmac1 {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 gmac1 stmmac

    if {$num_a9s == 0} {
        hps_utils_add_fpga_irq_connection gmac1.interrupt_sender h2f_gmac1_interrupt
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master gmac1.axi_slave0 {0xff702000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master gmac1.axi_slave0 {0xff702000}
    }

    hps_utils_add_gic_irq_connection arm_gic_0.irq_rx_offset_104 gmac1.interrupt_sender 16

}

#
# h2f
#
proc hps_instantiate_h2f {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 h2f hps_h2f_bridge_avalon

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master h2f.axi_slave0 {0xc0000000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master h2f.axi_slave0 {0xc0000000}
    }

}

#
# h2f_lw
#
proc hps_instantiate_h2f_lw {num_a9s} {

    #hps_utils_add_instance_clk_reset clk_0 h2f_lw hps_h2flw_bridge_avalon

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master h2f_lw.axi_slave0 {0xff200000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master h2f_lw.axi_slave0 {0xff200000}
    }

}

#
# axi_ocram
#
proc hps_instantiate_axi_ocram {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 axi_ocram axi_ocram

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master axi_ocram.axi_slave0 {0xffff0000}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master axi_ocram.axi_slave0 {0xffff0000}
    }

}

#
# timer
#
proc hps_instantiate_timer {num_a9s} {

    hps_utils_add_instance_clk_reset clk_0 timer timer

    if {$num_a9s == 0} {
        return
    }

    hps_utils_add_slave_interface arm_a9_0.altera_axi_master timer.axi_slave0 {0xfffec600}


    if {$num_a9s > 1} {
        hps_utils_add_slave_interface arm_a9_1.altera_axi_master timer.axi_slave0 {0xfffec600}
    }

}

