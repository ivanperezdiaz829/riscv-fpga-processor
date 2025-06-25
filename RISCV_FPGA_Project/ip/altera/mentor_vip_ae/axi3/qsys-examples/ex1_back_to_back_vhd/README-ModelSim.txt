#######################################################
##
# Compile, Elaborate, Simulate
#
# Note: -mvchome needs to be specified outside of the .do file.
#
vsim -mvchome $QUARTUS_ROOTDIR/../ip/altera/mentor_vip_ae/common -c -do "source example_vhdl.do; run 3000ns; quit -f" 
