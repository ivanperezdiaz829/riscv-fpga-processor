#######################################################
##
# Compile, Elaborate, Simulate
#
setenv CDS_ROOT        `cds_root ncvlog` 

# For 32 bit simulation
sh example-ius.sh 32

# For 64 bit simulation
sh example-ius.sh 64

