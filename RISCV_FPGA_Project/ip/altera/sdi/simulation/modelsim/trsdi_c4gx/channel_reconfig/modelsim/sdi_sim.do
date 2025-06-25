# Change this next line to point to your Quartus installation directory
set QUARTUS_ROOTDIR /tools/acds/12.0sp1/228/linux32/quartus

vlib atom_lib
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/220model.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/sgate.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/stratixiigx_atoms.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_atoms.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/cycloneiv_hssi_atoms.v
vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v
#vlog -work atom_lib $QUARTUS_ROOTDIR/eda/sim_lib/nopli.v +define+NO_PLI

vlib common_lib
vmap work common_lib
vlog -work work ../testbench/pattern_gen/*.v

vlib work
vlog ../testbench/sdi_mc_build/*.vo
vlog ../testbench/*.v

vsim -voptargs="+acc" work.tb_sdi_megacore_top -L work -L atom_lib -L common_lib
do wave.do
run -all
