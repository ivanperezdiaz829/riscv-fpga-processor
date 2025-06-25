#######################################################
##
# Compile, Elaborate, Simulate
#
# Note: -mvchome needs to be specified outside of the .do file.
#
vsim -mvchome $QUARTUS_ROOTDIR/../ip/altera/mentor_vip_ae/common -c -do example.do
