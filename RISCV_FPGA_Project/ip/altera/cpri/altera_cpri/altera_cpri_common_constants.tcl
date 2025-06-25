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


set testbench_api_files {
   models/cpri_api/aux_api.sv            ../altera_cpri_testbench/cpri_api/aux_api.sv
   models/cpri_api/aux_data.txt          ../altera_cpri_testbench/cpri_api/aux_data.txt
   models/cpri_api/map_api.sv            ../altera_cpri_testbench/cpri_api/map_api.sv
   models/cpri_api/mii_api.sv            ../altera_cpri_testbench/cpri_api/mii_api.sv
   models/cpri_api/mii_data.txt          ../altera_cpri_testbench/cpri_api/mii_data.txt
   models/cpri_api/cpu_api.sv            ../altera_cpri_testbench/cpri_api/cpu_api.sv
   models/cpri_api/hdlc_data.txt         ../altera_cpri_testbench/cpri_api/hdlc_data.txt
   models/cpri_api/common_api.sv         ../altera_cpri_testbench/cpri_api/common_api.sv  
   models/cpri_pkg/reg_pkg.sv            ../altera_cpri_testbench/cpri_pkg/reg_pkg.sv
   models/cpri_pkg/timescale.sv          ../altera_cpri_testbench/cpri_pkg/timescale.sv 
}
