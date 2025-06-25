#!/bin/sh

# Usage: <command> [32|64]
# 32 bit mode is run unless 64 is passed in as the first argument.

MENTOR_VIP_AE=${MENTOR_VIP_AE:-$QUARTUS_ROOTDIR/../ip/altera/mentor_vip_ae}

if [ "$1" == "64" ]
then
        export QUESTA_MVC_GCC_LIB=$MENTOR_VIP_AE/common/questa_mvc_core/linux_x86_64_gcc-4.4_ius
        export INCA_64BIT=1
else
        export QUESTA_MVC_GCC_LIB=$MENTOR_VIP_AE/common/questa_mvc_core/linux_gcc-4.4_ius
fi
export LD_LIBRARY_PATH=$QUESTA_MVC_GCC_LIB:$LD_LIBRARY_PATH

cd simulation/cadence
# Run once, just to execute the 'mkdir' for the libraries.
source ncsim_setup.sh SKIP_DEV_COM=1 SKIP_COM=1 SKIP_ELAB=1 SKIP_SIM=1

  # Compile VIP
  ncvhdl -v93  \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_bfm_pkg.vhd" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_monitor.vhd" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_inline_monitor.vhd" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_slave.vhd" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_master.vhd"

  ncvlog +define+_MGC_VIP_VHDL_INTERFACE -sv \
    "$MENTOR_VIP_AE/common/questa_mvc_svapi.svh" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_common_axi4.sv"  \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_monitor.sv"  \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_inline_monitor.sv"  \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_master.sv" \
    "$MENTOR_VIP_AE/axi4/bfm/mgc_axi4_slave.sv"


ncvhdl -v93 ../../master_test_program.vhd
ncvhdl -v93 ../../monitor_test_program.vhd
ncvhdl -v93 ../../slave_test_program.vhd

ncvhdl -v93 ../../top.vhd

source ncsim_setup.sh \
  USER_DEFINED_ELAB_OPTIONS="\"-timescale 1ns/1ns\"" \
  USER_DEFINED_SIM_OPTIONS="\"-sv_lib $QUESTA_MVC_GCC_LIB/libaxi4_IN_SystemVerilog_IUS_full -input '@run 3000 ns' -exit\""\
  TOP_LEVEL_NAME=top


