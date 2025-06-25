=======================================================================================================
Altera DisplayPort MegaCore Function Hardware Demonstration Readme File
=======================================================================================================

The Altera DisplayPort hardware demonstration allows you to evaluation the functionality of the 
DisplayPort MegaCore function and provides a starting point for you to create your own design. The 
hardware demonstration targets the Arria V GX FPGA development board and requires the Bitec DisplayPort 
HSMC daughter card revision 5. The design performs an SDRAM loop-through for a standard DisplayPort 
video stream.

If you change kits you must change the device assignments and the pin assignments. The following file 
is affected:

* assignments.tcl (device and pin assignments)

If you use another daughter card, you must change the pin assignments, Qsys system and software.

For detailed information on the demonstration, refer to "Chapter 5: DisplayPort MegaCore Function
Hardware Demonstration" in the DisplayPort MegaCore Function User Guide.

Setting up and running the DisplayPort demonstration involves the following steps:

1. Set up the hardware.
2. Copy the design files to your target directory.
3. Build the FPGA design.
4. Build and run the software.
5. Power-up the DisplayPort monitor and view the results.


SET UP THE HARDWARE
-----------------------------------------------------------------------------------------------------

Set up the hardware using the following steps:

1. Connect the Bitec daughter card to the Arria V GX development board.

2. Connect the development board to your PC using a USB cable.

NOTE: The Arria V GX development board has an On-Board USB-Blaster™ II
connection. If your version of the board does not have this connection, you
can use an external USB-Blaster cable. Refer to the documentation for your
board for more information.

3. Connect a DisplayPort cable from the DisplayPort TX on the Bitec HSMC daughter
   card to a DisplayPort monitor (do not power up the monitor).

4. Power-up the development board.

5. Connect one end of a DisplayPort cable to your PC (do not connect the other end
   to anything).

COPY THE DESIGN FILES TO YOUR TARGET DIRECTORY
-----------------------------------------------------------------------------------------------------

In this step, you copy the design example files to your working directory. Copy the
files using the command:

cp -r <IP root directory>\altera\altera_dp\hw_demo\av <working directory>

After copying, your working directory contains the following files:

Verilog HDL design files:
* av_dp_demo.v			Top-level
* dp_analog_mappings.v		Table translating VOD amd pre-emphasis settings
* dp_mif_mappings.v		Table of settings to reconfig XCVR with MIF mode 1
* reconfig_mgmt_hw_ctrl.v	Reconfiguration manager top-level
* reconfig_mgmt_write.v		Reconfiguration manager FSM for a single write command

MegaWizard variant files:
* av_video_pll.v
* av_xcvr_pll.v
* av_aux_buffer.v
* av_xcvr_reconfig.v

Qsys system:
* av_control.qsys

Scripts:
* runall.tcl			Script to run project setup, generate IP/QSYS, and compile
* assignments.tcl		Device, I/O and other assignments

Misc files:
* av_dp_demo.sdc		Top-level SDC file
* edid_memory.hex		Initial content for the EDID ROM

Software files:			These files are in the software directory
* batch_script.sh		Master script to program the device and build/run the software
* rerun.sh			Script to rerun the software without rebuilding
* dp_demo_src\			Directory containing example application source code
* btc_dprx_syslib\		Pre-compiled libary files for RX API				
* btc_dptx_syslib\		Pre-compiled libary files for TX API						

BUILD THE FPGA DESIGN
-----------------------------------------------------------------------------------------------------

In this step you use a Tcl script to build and compile the FPGA design. Type the command:

quartus_sh -t runall.tcl
 
This script executes the following commands:

* Generate MegaWizard IP files

* Generate the Qsys system:

* Create a Quartus II project

* Compile the Quartus II project:

  - Run Analysis & Synthesis to generate a post-map netlist for DDR assignments

  - Run the DDR TCL script to generate the pin assignments (except location)

  - Perform a full compile

BUILD, LOAD, AND RUN THE SOFTWARE
-----------------------------------------------------------------------------------------------------

In this step you will build the software, load it into the device, and run the software.

1. In a Windows Command Prompt, navigate to the design example software directory.

2. Launch a Nios II command shell. You can launch it using several methods, for
   example, from the Windows task bar or within the Qsys system. To run this
   command from a Windows Command Prompt, use the command:
   
   start "" %SOPC_KIT_NIOS2%\"Nios II Command Shell.bat"

3. From within the Nios II command shell execute the following command to build
   the software, program the device, download the Nios II program, and launch a
   debug terminal:

   ./batch_script.sh <USB cable number>

NOTE: To find <USB cable number>, use the jtagconfig command.

The script also creates the dp_demo and dp_demo_bsp subdirectories inside the software directory.

If you have already built the software, use the rerun.sh script to program the
device, download the Nios II program, and launch the terminal:

./rerun.sh

See http://www.altera.com/literature/hb/nios2/n2sw_nii52016.pdf
for description of the commands used in these scripts. 

VIEW RESULTS
-----------------------------------------------------------------------------------------------------

In this step you view the results of the design example in the Nios II command
shell and on the DisplayPort monitor.

1. Power-up the connected DisplayPort monitor. The design example displays a VIP
   test pattern (color bars).

2. Connect the free end of the Display Port cable that you connected to your PC to the
   DisplayPort RX on the Bitec HSMC daughter card. The PC now has the
   DisplayPort monitor available as a second monitor. Depending on your setup, the
   design example displays a VIP test pattern (color bars) mixed with your graphic
   card output.

NOTE: Some PC drivers and graphic card adapters do not enable the DisplayPort
hardware automatically upon hot plug detection. You may need to start the
adapter’s control utility (e.g., Catalist Control Center, nVidia Control Panel,
etc.) and manually enable the DisplayPort display

3. Open your graphic card adapter’s control utility; it should show a monitor named
   BITECDP01. Using the control panel, you can adjust the resolution of the
   BITECDP01 monitor, which typically results in link training, related AUX channel
   traffic, and a corresponding new image size on the monitor.

NOTE: If you do not see visible output on the monitor, press pushbutton 2 (USER1_PB2) to
generate a reset, causing the DisplayPort TX core to re-train the link.

Pressing pushbutton 0 (USER1_PB0) retrieves MSA statistics from the source and sink
connections. The Nios II Command Shell displays the AUX channel traffic during link
training with the monitor.

The Nios II AUX printout shows each message packet on a separate line.

* The first field is the incremental timestamp in microseconds.

* The second field indicates whether the message packet is from or to the
  DisplayPort sink IP core (SNK) or DisplayPort source IP core (SRC).

* The following two fields show the request and response headers and payloads.
  The DPCD address field on request messages are decoded into their respective
  DPCD location names.

When connected and enabled, USER1_LED_G0 on the development board illuminates
to indicate that the DisplayPort receiver has locked correctly. The Nios II terminal also
displays the AUX channel traffic related to link training between the graphics adapter
and the DisplayPort sink.


Enjoy


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