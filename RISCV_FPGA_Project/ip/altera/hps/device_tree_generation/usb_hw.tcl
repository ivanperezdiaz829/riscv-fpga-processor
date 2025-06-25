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
source hps_utils.tcl

#
# module usb
#
hps_utils_add_component_boiler_plate usb {Synopsys USB}
#
# file sets
#
#
# parameters
#

set_module_assignment embeddedsw.dts.params.host_rx_fifo-size 512
set_module_assignment embeddedsw.dts.params.dev-tx-fifo-size {<512 512 512 512 512 512 512 512 512 512 512 512 512 512 512>}
set_module_assignment embeddedsw.dts.compatible {snps,dwc-otg}
set_module_assignment embeddedsw.dts.params.dev-perio-tx-fifo-size {<512 512 512 512 512 512 512 512 512 512 512 512 512 512 512>}
set_module_assignment embeddedsw.dts.params.voltage-switch 0
set_module_assignment embeddedsw.dts.name dwc-otg
set_module_assignment embeddedsw.dts.params.dev-nperio-tx-fifo-size 4096
set_module_assignment embeddedsw.dts.params.dma-mask 268435455
set_module_assignment embeddedsw.dts.group usb
set_module_assignment embeddedsw.dts.params.ulpi-ddr 0
set_module_assignment embeddedsw.dts.vendor snps
set_module_assignment embeddedsw.dts.params.dev_rx_fifo-size 512
# 
# display items
# 


hps_utils_add_clock_reset

#
# Interrupt sender
#
hps_utils_add_irq_sender interrupt_sender

# 
# connection point altera_axi_slave
# 
hps_utils_add_axi_slave axi_slave0 axi_sig0 12
