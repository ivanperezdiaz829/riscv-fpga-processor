# =====================================================
# Pin & Location Assignments for Cyclone II DSP Board
#
# This board uses the following byte groups 
# DQS0 = 2B, DQS1 = 4B, DQS2 = 5B, DQS3 = 3B,
# DQS4 = 3T, DQS5 = 5T, DQS6 = 4T, DQS7 = 2T,
# DQS8 = 1T
#
# =====================================================

if {![info exists add_remove_string]}   {set  add_remove_string ""}
if {![info exists prefix_name]}         {set  prefix_name "ddr2_"}
if {![info exists clock_pos_pin_name]}  {set  prefix_name "clk_to_sdram"}
if {![info exists clock_neg_pin_name]}  {set  prefix_name "clk_to_sdram_n"}


set_location_assignment PIN_AE4 -to ${prefix_name}a[0] $add_remove_string
set_location_assignment PIN_AC8 -to ${prefix_name}a[1] $add_remove_string
set_location_assignment PIN_AD6 -to ${prefix_name}a[2] $add_remove_string
set_location_assignment PIN_Y10 -to ${prefix_name}a[3] $add_remove_string
set_location_assignment PIN_AF5 -to ${prefix_name}a[4] $add_remove_string
set_location_assignment PIN_AD7 -to ${prefix_name}a[5] $add_remove_string
set_location_assignment PIN_AC6 -to ${prefix_name}a[6] $add_remove_string
set_location_assignment PIN_AB8 -to ${prefix_name}a[7] $add_remove_string
set_location_assignment PIN_AD5 -to ${prefix_name}a[8] $add_remove_string
set_location_assignment PIN_AE11 -to ${prefix_name}a[9] $add_remove_string
set_location_assignment PIN_AE5 -to ${prefix_name}a[10] $add_remove_string
set_location_assignment PIN_AD4 -to ${prefix_name}a[11] $add_remove_string
set_location_assignment PIN_Y12 -to ${prefix_name}a[12] $add_remove_string
set_location_assignment PIN_AF7 -to ${prefix_name}a[13] $add_remove_string
set_location_assignment PIN_AC5 -to ${prefix_name}a[14] $add_remove_string
set_location_assignment PIN_AF13 -to ${prefix_name}a[15] $add_remove_string
set_location_assignment PIN_Y18 -to ${prefix_name}ba[0] $add_remove_string
set_location_assignment PIN_AF23 -to ${prefix_name}ba[1] $add_remove_string
set_location_assignment PIN_AB15 -to ${prefix_name}ba[2] $add_remove_string
set_location_assignment PIN_AE20 -to ${prefix_name}ras_n $add_remove_string
set_location_assignment PIN_AA17 -to ${prefix_name}we_n $add_remove_string
set_location_assignment PIN_AC22 -to ${prefix_name}cas_n $add_remove_string
set_location_assignment PIN_AE21 -to ${prefix_name}cke[0] $add_remove_string
set_location_assignment PIN_AC19 -to ${prefix_name}cke[1] $add_remove_string
set_location_assignment PIN_AF22 -to ${prefix_name}cs_n[0] $add_remove_string
set_location_assignment PIN_AB18 -to ${prefix_name}cs_n[1] $add_remove_string
set_location_assignment PIN_AF21 -to ${prefix_name}odt[0] $add_remove_string
set_location_assignment PIN_AE23 -to ${prefix_name}odt[1] $add_remove_string

set_location_assignment PIN_AD19 -to ${clock_neg_pin_name}[0] $add_remove_string
set_location_assignment PIN_AD21 -to ${clock_neg_pin_name}[1] $add_remove_string
set_location_assignment PIN_AA20 -to ${clock_neg_pin_name}[2] $add_remove_string
set_location_assignment PIN_AC21 -to ${clock_pos_pin_name}[0] $add_remove_string
set_location_assignment PIN_AB20 -to ${clock_pos_pin_name}[1] $add_remove_string
set_location_assignment PIN_AD22 -to ${clock_pos_pin_name}[2] $add_remove_string
