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


#!/bin/sh

# AUTHOR:       JGS (from JCJB)
# DATE:         1/11/2013
# DESCRIPTION:  This script builds a BSP and application based on the
#		DisplayPort pre-compiled libraries. It then programs
#		the device, downloads the ELF and launches a terminal
#               Pass in a cable number if you have multiple programming cables.
# Usage:        ./batch_script <optional cable number>
#               ex:  ./batch_script 2
#               If you are not sure of your cable number type
#               'jtagconfig' to list all the cables connected to the host (or remote cables)

# Names of the sof and elf files
SOF_NAME=cv_dp_demo.sof
ELF_NAME=dp_demo.elf

# SOPC_DIR is used for the sof file location as well
SOPC_SYSTEM_NAME=cv_control
SOPC_DIR=..

# Name of the memory to populate code in
CODE_MEMORY_NAME="onchip_mem"

# These are the two folders were all the files are dumped
APP_DIR=./dp_demo
BSP_DIR=./dp_demo_bsp

# This is the location containing all the application source files
APP_SRC_DIR=./dp_demo_src

# This is the name and location of the pre-compiled libraries
RX_LIB_NAME="btc_dprx_syslib"
TX_LIB_NAME="btc_dptx_syslib"

# IP_ROOTDIR should be setup by your Quartus installation to
# point at the location of the IP directory in the ACDS install

# ::WARNING:: If you used spaces in your ACDS install location
# this script will not work. You will need to copy the software
# directory to another location and update this script appropriately
SW_ROOTDIR=$IP_ROOTDIR/altera/altera_dp/software

RX_LIB_DIR=$SW_ROOTDIR/btc_dprx_syslib
TX_LIB_DIR=$SW_ROOTDIR/btc_dptx_syslib

# Various other application and BSP flags
OPTIMIZATION_LEVEL="-O2"
SIMULATION_OPTIMIZED_SUPPORT="false"
BSP_TYPE=hal
BSP_FLAGS="--set hal.max_file_descriptors 4 \
--set hal.sys_clk_timer none \
--set hal.timestamp_timer sys_clock_timer \
--set hal.enable_exit false \
--set hal.enable_c_plus_plus false \
--set hal.enable_clean_exit false \
--set hal.enable_reduced_device_drivers true \
--set hal.enable_lightweight_device_driver_api true \
--set hal.enable_small_c_library true \
--set hal.enable_sim_optimize $SIMULATION_OPTIMIZED_SUPPORT \
--set hal.make.bsp_cflags_optimization $OPTIMIZATION_LEVEL \
--default_sections_mapping $CODE_MEMORY_NAME"

APP_FLAGS="--set APP_CFLAGS_OPTIMIZATION $OPTIMIZATION_LEVEL"


# *********************** DON'T NEED TO MODIFY ANYTHING BELOW THIS LINE **************************************


# Check the number of arguments passed into the script
if [ $# -ne 1 ]
then
#  	echo ""
#  	echo "You have not specified a programming cable number"
#  	echo ""
#  	echo "eg: './batch_script.sh <cable number>'"
#  	echo ""
#	echo "If you are unsure which cable number to use type 'jtagconfig' to see all programming cables connected"
#	echo ""
#  	exit 1
    CABLE_NUMBER=""
else
    CABLE_NUMBER="-c $1"
fi


# make sure the application and bsp directories are blown away first before attempting to regenerate new projects
rm -rf $APP_DIR
rm -rf $BSP_DIR

# generate the BSP in the $BSP_DIR
cmd="nios2-bsp $BSP_TYPE $BSP_DIR $SOPC_DIR $BSP_FLAGS"
$cmd || {
  echo "nios2-bsp failed"
  exit 1
}

# generate the application in the $APP_DIR
cmd="nios2-app-generate-makefile --app-dir $APP_DIR --bsp-dir $BSP_DIR --elf-name $ELF_NAME --src-rdir $APP_SRC_DIR --use-lib-dir $RX_LIB_DIR --use-lib-dir $TX_LIB_DIR $APP_FLAGS"
$cmd || {
  echo "nios2-app-generate-makefile failed"
  exit 1
}


# Running make (for application and the bsp due to dependencies)
cmd="make --directory=$APP_DIR"
$cmd || {
    echo "make failed"
    exit 1
}


# Downloading the sof file
cmd="nios2-configure-sof $CABLE_NUMBER $SOPC_DIR/$SOF_NAME"
$cmd || {
    echo "failed to download the .sof file"
    exit 1
}


# Downloading the code
cmd="nios2-download -g -r $CABLE_NUMBER $APP_DIR/$ELF_NAME"
$cmd || {
    echo "failed to download the software .elf file"
    exit 1
}



# Opening terminal connection
cmd="nios2-terminal $CABLE_NUMBER"
$cmd || {
    echo "failed to open the Nios II terminal"
    exit 1
}
