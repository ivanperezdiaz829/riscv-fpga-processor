=======================================================================================================
Altera DisplayPort MegaCore Function Simulation Example Readme File
=======================================================================================================

The Altera DisplayPort simulation example allows you to perform simulation on the DisplayPort simulation 
example. This example targets the ModelSim SE simulator.

Setting up and running the DisplayPort simulation example involves the following steps:

1. Copy the simulation files to your target directory.
2. Generate the IP simulation files and scripts, and compile and simulate.
3. Vew the results.

COPY THE DESIGN FILES TO YOUR TARGET DIRECTORY
-----------------------------------------------------------------------------------------------------

In this step, you copy the simulation example files to your working directory. Copy the
files using the command:

cp -r <IP root directory>\altera\altera_dp\sim_example\sv <working directory>

After copying, your working directory contains the following files:

System Verilog HDL Design Files:
* sv_dp_harness.sv			Top-level test harness

Verilog HDL design files:
* sv_dp_example.v			Design under test (DUT)
* dp_analog_mappings.v			Table translating VOD amd pre-emphasis settings
* dp_mif_mappings.v			Table of settings to reconfig XCVR with MIF mode 1
* reconfig_mgmt_hw_ctrl.v		Reconfiguration manager top-level
* reconfig_mgmt_write.v			Reconfiguration manager FSM for a single write command
* clk_gen.v				Clock generation file
* vga_driver.v				VGA driver

MegaWizard variant files:
* sv_dp.v				DisplayPort IP core
* sv_xcvr_reconfig.v			Transceiver reconfiguration core

Scripts:
* runall.sh
* msim_dp.tcl

Waveform do files:
* all.do
* reconfig.do
* rx_video_out.do
* tx_video_in.do

Miscellaneous files:
* readme.txt
* edid_memory.hex

GENERATE THE IP SIMULATION FILES AND SCRIPTS, AND COMPILE AND SIMULATE
-----------------------------------------------------------------------------------------------------

In this step you use a script to generate the IP simulation files and scripts, and compile and 
simulate them. Type the command:

sh runall.sh

This script executes the following commands:

* Generate the simulation files for the DisplayPort and transceiver reconfiguration IP cores:
  qmegawiz -silent sv_xcvr_reconfig.v
  qmegawiz -silent sv_dp.v

* Merge the two resulting msim_setup.tcl scripts to create a single mentor/msim_setup.tcl:
  ip-make-simscript --spd=./sv_xcvr_reconfig.spd --spd=./sv_dp.spd

* Compile and simulate the design in the ModelSim software:
  vsim -c -do msim_dp.tcl

The simualtion sends one frame of video after reconfiguring the DisplayPort source (TX) and sink (RX)
to use the HBR2 (5.4 G) rate. A successful result is seen by the CTS test automation logic's CRC checks.
These checks compare the CRC of the transmitted image with the result measured at the sink.

An example of a successful result is shown below:

# SINK CRC_R = 9b40, CRC_G = 9b40, CRC_B = 9b40,
# SOURCE CRC_R = 9b40, CRC_G = 9b40, CRC_B = 9b40,
# Pass: Test Completed

VIEW RESULTS
-----------------------------------------------------------------------------------------------------

You can view the results in the ModelSim GUI by loading various .do files in the Wave viewer.

1. Launch the ModelSim GUI with the vsim command.

2. In the ModelSim Tcl window, execute the dataset open command:
   
   dataset open vsim.wlf

3. Choose View > Open Wave files.

4. Load the .do files to view the waveforms:

   * reconfig.do		Shows the signals involved in reconfiguring the transceiver

   * tx_video_in.do		vsync, hsync, de, and vid_data[23:0]
				256 pixels per line, 8bpp, i
				Range of vid_data_r, vid_data_g, and vid_data_b is 00 to ff

   * rx_video_out.do		rx_video_out from the DisplayPort core mapped to CVI input expectations 

   * all.do			Combination of all waveforms


=======================================================================================================

© 2013 Altera Corporation. All rights reserved. ALTERA, ARRIA, CYCLONE, HARDCOPY, MAX, MEGACORE, NIOS, 
QUARTUS and STRATIX words and logos are trademarks of Altera Corporation and registered in the U.S. Patent 
and Trademark Office and in other countries. All other words and logos identified as trademarks or service 
marks are the property of their respective holders as described at www.altera.com/common/legal.html. Altera 
warrants performance of its semiconductor products to current specifications in accordance with Altera's 
standard warranty, but reserves the right to make changes to any products and services at any time without 
notice. Altera assumes no responsibility or liability arising out of the application or use of any information, 
product, or service described herein except as expressly agreed to in writing by Altera. Altera customers 
are advised to obtain the latest version of device specifications before relying on any published information 
and before placing orders for products or services.