=======================================================================================================
Altera DisplayPort MegaCore Function Design Example Readme File
=======================================================================================================

The Altera DisplayPort design example allows you to compile the DisplayPort MegaCore Function with the 
Quartus II software to evaluate its performance and resource utilization.

Setting up and running the DisplayPort design example involves the following steps:

1. Copy the source files to your target directory.
2. Generate the project and IP synthesis files and compile.
3. View Results.

COPY THE DESIGN FILES TO YOUR TARGET DIRECTORY
-----------------------------------------------------------------------------------------------------

In this step, you copy the design example files to your working directory. Copy the
files using the command:

cp -r <IP root directory>\altera\altera_dp\example\sv <working directory>

After copying, your working directory contains the following files:

Verilog HDL design files:
* sv_dp_example.v		Top-level
* dp_analog_mappings.v		Table translating VOD amd pre-emphasis settings
* dp_mif_mappings.v		Table of settings to reconfig XCVR with MIF mode 1
* reconfig_mgmt_hw_ctrl.v	Reconfiguration manager top-level
* reconfig_mgmt_write.v		Reconfiguration manager FSM for a single write command

MegaWizard variant files:
* sv_dp.v			DisplayPort IP core
* sv_xcvr_reconfig.v		Transceiver reconfiguration core

Scripts:
* runall.tcl
* assignments.tcl

Miscellaneous files:
* sv_dp_example.sdc			top-level SDC file
* readme.txt

GENERATE THE PROJECT AND IP SYNTHESIS FILES AND COMPILE
-----------------------------------------------------------------------------------------------------

In this step you use a Tcl script to generate the project and IP synthesis files and compile them. 
Type the command:

quartus_sh -t runall.tcl

This script executes the following commands:

* Generate the synthesis files for the DisplayPort and transceiver reconfiguration IP cores

* Generate a new project and add assignments

* Compile the design in the Quartus software

The example design instantiates the DisplayPort IP core in 4 lane duplex mode and connects it to 
the Transceiver Reconfiguration MegaCore with a Finite-State-Machine (FSM) to control the 
reconfiguration operation. 

VIEW RESULTS
-----------------------------------------------------------------------------------------------------

You can view the results in the Quartus GUI by loading the project and reviewing the Compilation Report.

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