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


# initialize variables
FAMILY=$1 
TYPE=$2 #0=VHDL, 1=VLG
SIM_DIR="../"

case $FAMILY in
   0) echo "INFO: Stratix IV is chosen." ;;
   1) echo "INFO: Arria II GX is chosen." ;;
   2) echo "INFO: Arria II GZ is chosen." ;;
   3) echo "INFO: Cyclone IV GX is chosen." ;;
   4) echo "INFO: Stratix V is chosen." ;;
   5) echo "INFO: Arria V is chosen." ;;
   6) echo "INFO: Cyclone V is chosen.";;
   7) echo "INFO: Arria V GZ is chosen.";;
   8) echo "INFO: Arria V GT is chosen.";; 
   *) echo "INVALID FAMILY!" ;;
esac


if [ "$1" -lt 3 ]; then

# CPRI
CPRI_DIR="../../../../cpri_top_level_sim/cadence/ncsim_setup.sh"
. $CPRI_DIR QSYS_SIMDIR="../../../../cpri_top_level_sim/" SKIP_ELAB=1 SKIP_SIM=1

   if [ "$TYPE" -eq 1 ]; then
      #VLG
      ncvlog -work work $SIM_DIR/altgx_reconfig_cpri.v
      ncvlog -work work $SIM_DIR/rom.v
   else
      #VHDL
      ncvhdl -v93 -work work $SIM_DIR/altgx_reconfig_cpri.vhd
      ncvhdl -v93 -work work $SIM_DIR/rom.vhd
   fi
elif [ "$FAMILY" -eq 3 ]; then 

# CPRI
CPRI_DIR="../../../../cpri_top_level_sim/cadence/ncsim_setup.sh"
. $CPRI_DIR QSYS_SIMDIR="../../../../cpri_top_level_sim/" SKIP_ELAB=1 SKIP_SIM=1

   if [ "$TYPE" -eq 1 ]; then
      #VLG
      ncvlog -work work $SIM_DIR/altgx_c4gx_reconfig_cpri.v
      ncvlog -work work $SIM_DIR/altpll_c4gx_reconfig_cpri.v 
      ncvlog -work work $SIM_DIR/rom.v     
      ncvlog -work work $SIM_DIR/rom_pll.v
   else
      #VHDL
      ncvhdl -v93 -work work $SIM_DIR/altgx_c4gx_reconfig_cpri.vhd
      ncvhdl -v93 -work work $SIM_DIR/altpll_c4gx_reconfig_cpri.vhd 
      ncvhdl -v93 -work work $SIM_DIR/rom.vhd     
      ncvhdl -v93 -work work $SIM_DIR/rom_pll.vhd
   fi

else

# XCVR Reconfig Controller
XCVR_RECONFIG_DIR="../xcvr_reconfig_cpri_sim/cadence/ncsim_setup.sh"
. $XCVR_RECONFIG_DIR QSYS_SIMDIR="../xcvr_reconfig_cpri_sim/" SKIP_ELAB=1 SKIP_SIM=1

# CPRI
CPRI_DIR="../../../../cpri_top_level_sim/cadence/ncsim_setup.sh"
. $CPRI_DIR QSYS_SIMDIR="../../../../cpri_top_level_sim/" SKIP_ELAB=1 SKIP_SIM=1

   if [ "$TYPE" -eq 1 ] ; then
      #VLG
      ncvlog -work work $SIM_DIR/rom.v
   else
      #VHDL
      ncvhdl -v93 -work work $SIM_DIR/rom.vhd
   fi

  # For AVGT 9.8G only
   if [ "$FAMILY" -eq 8 ]; then 
      ncvhdl -v93 -work work $SIM_DIR/clock_switch.vhd 
   fi

   ncvhdl -v93 -work work $SIM_DIR/cpri_reconfig_controller.vhd
fi

# compile the testbench file
ncvhdl -v93 -work work $SIM_DIR/tb.vhd  

# run the elaboration
ncelab -access +w+r+c -namemap_mixgen -relax tb

# run the simulation
ncsim -tcl -input wave.tcl tb
