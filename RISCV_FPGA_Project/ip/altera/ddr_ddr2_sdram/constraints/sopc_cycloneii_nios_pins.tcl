# =====================================================
# Pin & Location Assignments for Cyclone II Nios Board
#
# NB The ras_n and cas_n pins are swapped on the schematic.
# =====================================================

if {![info exists add_remove_string]}   {set  add_remove_string ""}
if {![info exists prefix_name]}         {set  prefix_name "ddr_"}
if {![info exists clock_pos_pin_name]}  {set  prefix_name "clk_to_sdram"}
if {![info exists clock_neg_pin_name]}  {set  prefix_name "clk_to_sdram_n"}

set_location_assignment PIN_T6 -to ${prefix_name}a[0] $add_remove_string
set_location_assignment PIN_V2 -to ${prefix_name}a[1] $add_remove_string
set_location_assignment PIN_R8 -to ${prefix_name}a[2] $add_remove_string
set_location_assignment PIN_W3 -to ${prefix_name}a[3] $add_remove_string
set_location_assignment PIN_R5 -to ${prefix_name}a[4] $add_remove_string
set_location_assignment PIN_U10 -to ${prefix_name}a[5] $add_remove_string
set_location_assignment PIN_P4 -to ${prefix_name}a[6] $add_remove_string
set_location_assignment PIN_V1 -to ${prefix_name}a[7] $add_remove_string
set_location_assignment PIN_T9 -to ${prefix_name}a[8] $add_remove_string
set_location_assignment PIN_T8 -to ${prefix_name}a[9] $add_remove_string
set_location_assignment PIN_AA2 -to ${prefix_name}a[10] $add_remove_string
set_location_assignment PIN_T10 -to ${prefix_name}a[11] $add_remove_string
set_location_assignment PIN_U3 -to ${prefix_name}a[12] $add_remove_string
set_location_assignment PIN_U9 -to ${prefix_name}ba[0] $add_remove_string
set_location_assignment PIN_Y4 -to ${prefix_name}ba[1] $add_remove_string
set_location_assignment PIN_Y3 -to ${prefix_name}cs_n[0] $add_remove_string
set_location_assignment PIN_R7 -to ${prefix_name}cke[0] $add_remove_string
set_location_assignment PIN_U1 -to ${prefix_name}cas_n $add_remove_string
set_location_assignment PIN_V4 -to ${prefix_name}ras_n $add_remove_string

set_location_assignment PIN_U4 -to ${prefix_name}we_n $add_remove_string
set_location_assignment PIN_AA7 -to ${clock_pos_pin_name}[0] $add_remove_string
set_location_assignment PIN_AA6 -to ${clock_neg_pin_name}[0] $add_remove_string
