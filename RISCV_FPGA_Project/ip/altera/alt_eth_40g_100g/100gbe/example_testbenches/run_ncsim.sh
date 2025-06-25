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



QSYS_SIMDIR="../../../ENET_ENTITY_QMEGA_06072013_sim"
QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
SKIP_ELAB=1
SKIP_SIM=1

cp -r $QSYS_SIMDIR/cadence/* .

sh ./ncsim_setup.sh QSYS_SIMDIR=$QSYS_SIMDIR QUARTUS_INSTALL_DIR=$QUARTUS_INSTALL_DIR SKIP_ELAB=$SKIP_ELAB SKIP_SIM=$SKIP_SIM

ncvlog ./alt_100gbe_tb.v

ncelab -timescale '1 ps / 1 ps' -access +rwc alt_100gbe_tb
ncsim  -run -exit -extassertmsg alt_100gbe_tb
