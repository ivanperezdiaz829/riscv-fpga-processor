REM Change this next line to point to your ModelSim SE installation directory
set MODELSIM_DIR=c:\Modeltech_eval_6.0c

REM Change this next line to point to your Quartus installation directory
set QUARTUS_ROOTDIR=c:\altera\81\quartus

set PATH=%MODELSIM_DIR%\win32

vlib work
vmap work work

vlog %QUARTUS_ROOTDIR%\eda\sim_lib\220model.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\sgate.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\stratixgx_atoms.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\stratixiigx_hssi_atoms.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\stratixiigx_atoms.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\stratixgx_mf.v 
vlog %QUARTUS_ROOTDIR%\libraries\megafunctions\alt2gxb.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\altera_mf.v 
vlog %QUARTUS_ROOTDIR%\eda\sim_lib\nopli.v +define+NO_PLI


vlog ../testbench/ts_packet_gen/*.v
vlog ../testbench/asi_mc_build/asi_rx_sim.vo
vlog ../testbench/asi_mc_build/asi_tx_sim.vo
vlog ../testbench/tb_asi_mc.v




vsim work.tb_asi_mc -L work -do "do wave.do; run -all"

pause
