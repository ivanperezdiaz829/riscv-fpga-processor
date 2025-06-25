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
# DATE:         10/26/2012
# DESCRIPTION:  A script that programs a device, download the code, open a terminal.
#               Pass in a cable number if you have multiple programming cables.
# Usage:        ./batch_script <optional cable number>
#               ex:  ./batch_script 2
#               If you are not sure of your cable number type
#               'jtagconfig' to list all the cables connected to the host (or remote cables)

# Names of the sof and elf files
SOF_NAME=cv_dp_demo.sof
ELF_NAME=dp_demo.elf

# SOPC_DIR is used for the sof file location as well
SOPC_DIR=..

# These are the two folders were all the files are dumped
APP_DIR=./dp_demo


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
