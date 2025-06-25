#!/bin/sh

# Usage: <command> [32|64]
# 32 bit mode is run unless 64 is passed in as the first argument.

MENTOR_VIP_AE=${MENTOR_VIP_AE:-$QUARTUS_ROOTDIR/../ip/altera/mentor_vip_ae}

if [ "$1" == "64" ]
then
        export RUN_64bit=-full64
        export VCS_TARGET_ARCH=`getsimarch 64`
        export LD_LIBRARY_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_64-shared/lib64
        export QUESTA_MVC_GCC_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_64-shared
        export QUESTA_MVC_GCC_LIB=${MENTOR_VIP_AE}/common/questa_mvc_core/linux_x86_64_gcc-4.5.2_vcs
else
        export RUN_64bit=
        export LD_LIBRARY_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_32-shared/lib
        export QUESTA_MVC_GCC_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_32-shared
        export QUESTA_MVC_GCC_LIB=${MENTOR_VIP_AE}/common/questa_mvc_core/linux_gcc-4.5.2_vcs
fi

cd simulation/synopsys/vcsmx
rm -rf csrc libraries simv simv.daidir transcript ucli.key vc_hdrs.h

# Initialize workdirectories and compile DEV_COM and COM
source vcsmx_setup.sh SKIP_ELAB=1 SKIP_SIM=1;

# Compile the BFM
vlogan +v2k -sverilog \
  $MENTOR_VIP_AE/common/questa_mvc_svapi.svh \
  $MENTOR_VIP_AE/axi3/bfm/mgc_common_axi.sv \
  $MENTOR_VIP_AE/axi3/bfm/mgc_axi_monitor.sv \
  $MENTOR_VIP_AE/axi3/bfm/mgc_axi_inline_monitor.sv \
  $MENTOR_VIP_AE/axi3/bfm/mgc_axi_master.sv \
  $MENTOR_VIP_AE/axi3/bfm/mgc_axi_slave.sv

# Compile the test program
vlogan +v2k -sverilog ../../../master_test_program.sv  
vlogan +v2k -sverilog ../../../monitor_test_program.sv 
vlogan +v2k -sverilog ../../../slave_test_program.sv   

# Compile the top
vlogan +v2k -sverilog ../../../top.sv                  

# VCS accepts the -LDFLAGS flag on the command line, but the shell quoting is too difficult.
# Just set the LDFLAGS ENV variable for the compiler to pick up. Alternatively, use the VCS command 
# line option '-file' with the LDFLAGS set (this avoids shell quoting issues).
#  % vcs ... -file vcs-switches.f ...
#  vcs-switches.f: 
#     -LDFLAGS "-L ${QUESTA_MVC_GCC_LIB} -Wl,-rpath ${QUESTA_MVC_GCC_LIB} -laxi_IN_SystemVerilog_VCS_full"
export LDFLAGS="-L ${QUESTA_MVC_GCC_LIB} -Wl,-rpath ${QUESTA_MVC_GCC_LIB} -laxi_IN_SystemVerilog_VCS_full"

USER_DEFINED_ELAB_OPTIONS="\"\
  $RUN_64bit \
  -timescale=1ns/1ns \
  +vpi +acc +vcs+lic+wait \
  -cpp ${QUESTA_MVC_GCC_PATH}/xbin/g++ \"" 

# Elaborate and simulate
source vcsmx_setup.sh SKIP_DEV_COM=1 SKIP_COM=1 \
  USER_DEFINED_ELAB_OPTIONS="$USER_DEFINED_ELAB_OPTIONS" \
  USER_DEFINED_SIM_OPTIONS="'-l transcript'" \
  TOP_LEVEL_NAME="'top'"
