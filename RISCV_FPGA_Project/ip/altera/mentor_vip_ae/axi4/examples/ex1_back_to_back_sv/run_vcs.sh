PWD=`pwd`
if [ "$MTI_VCO_MODE" == "64" ]
then
	RUN_64bit=-full64
	LD_LIBRARY_PATH=${PWD}/../../../common/questa_mvc_core/linux_x86_64_gcc-4.5.2_vcs:${VCS_HOME}/gnu/linux/gcc-4.5.2_64-shared/lib64
        QUESTA_MVC_GCC_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_64-shared
        QUESTA_MVC_GCC_LIB=${PWD}/../../../common/questa_mvc_core/linux_x86_64_gcc-4.5.2_vcs
else
	LD_LIBRARY_PATH=${PWD}/../../../common/questa_mvc_core/linux_gcc-4.5.2_vcs:${VCS_HOME}/gnu/linux/gcc-4.5.2_32-shared/lib
	QUESTA_MVC_GCC_PATH=${VCS_HOME}/gnu/linux/gcc-4.5.2_32-shared
	QUESTA_MVC_GCC_LIB=${PWD}/../../../common/questa_mvc_core/linux_gcc-4.5.2_vcs
fi
export LD_LIBRARY_PATH
vcs -sverilog +warn=noACC_CLI_ON +warn=noUII +vpi +acc +vcs+lic+wait -cpp ${QUESTA_MVC_GCC_PATH}/xbin/g++ \
    -LDFLAGS "-L ${QUESTA_MVC_GCC_LIB} -Wl,-rpath ${QUESTA_MVC_GCC_LIB}" \
    -laxi4_IN_SystemVerilog_VCS_full \
    -timescale=1ns/1ns \
    ../../../common/questa_mvc_svapi.svh \
    ../../bfm/mgc_common_axi4.sv  \
    ../../bfm/mgc_axi4_master.sv  \
    ../../bfm/mgc_axi4_monitor.sv \
    ../../bfm/mgc_axi4_slave.sv   \
    master_test_program.sv       \
    monitor_test_program.sv      \
    slave_test_program.sv        \
    top.sv \
    ${RUN_64bit}

./simv -l transcript
