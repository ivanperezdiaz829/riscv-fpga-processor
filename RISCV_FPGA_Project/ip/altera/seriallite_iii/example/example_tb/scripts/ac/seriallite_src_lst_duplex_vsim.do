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


#// Infrastructure components 
vlog -sv ../../demo/src/dp_sync.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv ../../demo/src/dp_hs_req.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv ../../demo/src/dp_hs_resp.v +access +w +define+ALTERA +define+SIMULATION

#// Source Components 
vlog -sv +incdir+$env(SIM_LOCATION)/seriallite_iii/ $env(SIM_LOCATION)/seriallite_iii/seriallite_iii_streaming.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING +define+DUPLEX
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/source_application.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING 
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/source_adaptation.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING 
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/dv_gen.v
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/reset_delay.v
vlog -sv $env(SIM_LOCATION)/seriallite_iii/*.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING 
#vlog -sv $env(SIM_LOCATION)/seriallite_iii/source_absorber.v +access +w +define+ALTERA +define+SIMULATION
#vlog -sv $env(SIM_LOCATION)/seriallite_iii/control_word_decoder.v +access +w +define+ALTERA +define+SIMULATION +define+DUPLEX_MODE

#// Sink Components
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/sink_application.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/sink_adaptation.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING 
vlog -sv $env(SIM_LOCATION)/seriallite_iii/mentor/sink_alignment.v +access +w +define+ALTERA +define+SIMULATION

#// Demo Components 
vlog -sv +incdir+../../src+../ ../../demo/src/traffic_gen.sv +access +w +define+ALTERA +define+SIMULATION 
vlog -sv +incdir+../../src ../../demo/src/prbs_generator.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv +incdir+../../src ../../demo/src/prbs_poly.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv +incdir+../../src+../ ../../demo/src/traffic_check.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv +incdir+../../src ../../demo/src/source_reconfig.v +access +w +define+ALTERA +define+SIMULATION
vlog -sv +incdir+../../src ../../demo/src/sink_reconfig.v +access +w +define+ALTERA +define+SIMULATION

#// Testbench Components 
vlog -sv ../skew_insertion.v +access +w +define+ALTERA +define+SIMULATION +define+DUPLEX_MODE
vlog -sv +incdir+../../src+../ ../testbench.sv +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING +define+DUPLEX_MODE
vlog -sv +incdir+../../src+../ ../test_env.v +access +w +define+ALTERA +define+SIMULATION +define+ADVANCED_CLOCKING +define+DUPLEX_MODE
