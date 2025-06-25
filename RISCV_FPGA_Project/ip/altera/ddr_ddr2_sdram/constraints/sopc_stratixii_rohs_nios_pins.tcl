# =====================================================
# Pin & Location Assignments for Stratix II Nios Board
# =====================================================

if {![info exists add_remove_string]}   {set  add_remove_string ""}
if {![info exists prefix_name]}         {set  prefix_name "ddr_"}
if {![info exists clock_pos_pin_name]}  {set  prefix_name "clk_to_sdram"}
if {![info exists clock_neg_pin_name]}  {set  prefix_name "clk_to_sdram_n"}

set_location_assignment PIN_C3 -to ${clock_pos_pin_name}[0] $add_remove_string
set_location_assignment PIN_C4 -to ${clock_neg_pin_name}[0] $add_remove_string

set_location_assignment PIN_B10 -to ${prefix_name}a[0] $add_remove_string
set_location_assignment PIN_B9  -to ${prefix_name}a[1] $add_remove_string
set_location_assignment PIN_B8  -to ${prefix_name}a[2] $add_remove_string
set_location_assignment PIN_B6  -to ${prefix_name}a[3] $add_remove_string
set_location_assignment PIN_C5  -to ${prefix_name}a[4] $add_remove_string
set_location_assignment PIN_E11 -to ${prefix_name}a[5] $add_remove_string
set_location_assignment PIN_E10 -to ${prefix_name}a[6] $add_remove_string
set_location_assignment PIN_E9  -to ${prefix_name}a[7] $add_remove_string
set_location_assignment PIN_E8  -to ${prefix_name}a[8] $add_remove_string
set_location_assignment PIN_E7  -to ${prefix_name}a[9] $add_remove_string
set_location_assignment PIN_F11 -to ${prefix_name}a[10] $add_remove_string
set_location_assignment PIN_F10 -to ${prefix_name}a[11] $add_remove_string
set_location_assignment PIN_F8  -to ${prefix_name}a[12] $add_remove_string
set_location_assignment PIN_G10 -to ${prefix_name}ba[0] $add_remove_string
set_location_assignment PIN_G11 -to ${prefix_name}ba[1] $add_remove_string

set_location_assignment PIN_F13 -to ${prefix_name}cke[0] $add_remove_string
set_location_assignment PIN_E12 -to ${prefix_name}cs_n[0] $add_remove_string

set_location_assignment PIN_B3  -to ${prefix_name}cas_n $add_remove_string
set_location_assignment PIN_A3  -to ${prefix_name}ras_n $add_remove_string
set_location_assignment PIN_B4  -to ${prefix_name}we_n $add_remove_string
 
