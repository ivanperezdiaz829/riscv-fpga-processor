# =====================================================
# Pin & Location Assignments for Cyclone II PCI Board
#
# This board uses the following byte groups 
# DQS0 = 2T, DQS1 = 4T, DQS2 = 3T, DQS3 = 5T,
#
# =====================================================

if {![info exists add_remove_string]}   {set  add_remove_string ""}
if {![info exists prefix_name]}         {set  prefix_name "${prefix_name}"}
if {![info exists clock_pos_pin_name]}  {set  prefix_name "clk_to_sdram"}
if {![info exists clock_neg_pin_name]}  {set  prefix_name "clk_to_sdram_n"}

set_location_assignment PIN_A19 -to ${prefix_name}a[0] $add_remove_string
set_location_assignment PIN_A20 -to ${prefix_name}a[1] $add_remove_string
set_location_assignment PIN_A21 -to ${prefix_name}a[2] $add_remove_string
set_location_assignment PIN_B19 -to ${prefix_name}a[3] $add_remove_string
set_location_assignment PIN_B21 -to ${prefix_name}a[4] $add_remove_string
set_location_assignment PIN_B22 -to ${prefix_name}a[5] $add_remove_string
set_location_assignment PIN_C19 -to ${prefix_name}a[6] $add_remove_string
set_location_assignment PIN_D18 -to ${prefix_name}a[7] $add_remove_string
set_location_assignment PIN_D19 -to ${prefix_name}a[8] $add_remove_string
set_location_assignment PIN_D20 -to ${prefix_name}a[9] $add_remove_string
set_location_assignment PIN_A4  -to ${prefix_name}a[10] $add_remove_string
set_location_assignment PIN_A5  -to ${prefix_name}a[11] $add_remove_string
set_location_assignment PIN_B4  -to ${prefix_name}a[12] $add_remove_string
set_location_assignment PIN_B5  -to ${prefix_name}a[13] $add_remove_string
set_location_assignment PIN_B6  -to ${prefix_name}a[14] $add_remove_string
set_location_assignment PIN_C4  -to ${prefix_name}a[15] $add_remove_string
set_location_assignment PIN_C22 -to ${prefix_name}ba[0] $add_remove_string
set_location_assignment PIN_C21 -to ${prefix_name}ba[1] $add_remove_string
set_location_assignment PIN_C11 -to ${prefix_name}ba[2] $add_remove_string
set_location_assignment PIN_F9  -to ${prefix_name}cas_n $add_remove_string
set_location_assignment PIN_D7  -to ${prefix_name}ras_n $add_remove_string
set_location_assignment PIN_C7  -to ${prefix_name}we_n $add_remove_string
set_location_assignment PIN_D21 -to ${prefix_name}cke[0] $add_remove_string
set_location_assignment PIN_C23 -to ${prefix_name}cs_n[0] $add_remove_string
set_location_assignment PIN_G9  -to ${prefix_name}odt[0] $add_remove_string

set_location_assignment PIN_A23 -to ${clock_neg_pin_name}[0]
set_location_assignment PIN_A8  -to ${clock_neg_pin_name}[1]
set_location_assignment PIN_A22 -to ${clock_neg_pin_name}[0]
set_location_assignment PIN_A9  -to ${clock_neg_pin_name}[1]
#set_location_assignment PIN_AF14 -to ${prefix_name}fedback_clk
#set_location_assignment PIN_B7  -to ${prefix_name}fedback_clk_out



