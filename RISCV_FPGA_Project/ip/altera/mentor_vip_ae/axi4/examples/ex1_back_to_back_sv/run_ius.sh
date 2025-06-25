if [ "$MTI_VCO_MODE" == "64" ]
then
	RUN_64bit=-64bit
	QUESTA_MVC_GCC_LIB=../../../common/questa_mvc_core/linux_x86_64_gcc-4.4_ius
	export LD_LIBRARY_PATH=${QUESTA_MVC_GCC_LIB}:${LD_LIBRARY_PATH}
else
	QUESTA_MVC_GCC_LIB=../../../common/questa_mvc_core/linux_gcc-4.4_ius
	export LD_LIBRARY_PATH=${QUESTA_MVC_GCC_LIB}:${LD_LIBRARY_PATH}
fi
irun -sv -clean -nowarn CLEAN -nowarn SVLGMT -access +w -sv_root ${QUESTA_MVC_GCC_LIB} -sv_lib libaxi4_IN_SystemVerilog_IUS_full -timescale 1ns/1ns \
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
