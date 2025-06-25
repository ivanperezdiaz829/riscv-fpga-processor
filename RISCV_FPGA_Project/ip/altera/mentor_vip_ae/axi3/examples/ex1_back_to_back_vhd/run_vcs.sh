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

vhdlan  ../../bfm/mgc_axi_bfm_pkg.vhd \
        ../../bfm/mgc_axi_master.vhd  \
        ../../bfm/mgc_axi_slave.vhd   \
        ../../bfm/mgc_axi_monitor.vhd \
        master_test_program.vhd       \
        monitor_test_program.vhd      \
        slave_test_program.vhd        \
        top.vhd \
	${RUN_64bit}

vlogan -sverilog +define+_MGC_VIP_VHDL_INTERFACE -q ${RUN_64bit} \
    ../../../common/questa_mvc_svapi.svh \
    ../../bfm/mgc_common_axi.sv   \
    ../../bfm/mgc_axi_master.sv   \
    ../../bfm/mgc_axi_monitor.sv  \
    ../../bfm/mgc_axi_slave.sv

vcs -q +warn=noACC_CLI_ON +warn=noUII +vpi +acc +vcs+lic+wait -cpp ${QUESTA_MVC_GCC_PATH}/xbin/g++ -timescale=1ns/1ns \
    -LDFLAGS "-L ${QUESTA_MVC_GCC_LIB} -Wl,-rpath ${QUESTA_MVC_GCC_LIB}" \
    -laxi_IN_SystemVerilog_VCS_full \
    top \
    ${RUN_64bit}

./simv -l transcript -q +vcs+finish+3000
