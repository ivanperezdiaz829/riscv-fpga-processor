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


# +-----------------------------------
# | display items
# |
add_display_item "" "AXI Parameters" GROUP tab
add_display_item "AXI Parameters" M0_AXI_VERSION PARAMETER ""
add_display_item "AXI Parameters" DATA_WIDTH PARAMETER ""
add_display_item "AXI Parameters" S0_ADDR_WIDTH PARAMETER ""
add_display_item "AXI Parameters" READ_DATA_REORDERING_DEPTH PARAMETER ""
add_display_item "AXI Parameters" M0_WRITE_ADDR_USER_WIDTH PARAMETER ""
add_display_item "AXI Parameters" M0_WRITE_DATA_USER_WIDTH PARAMETER ""
add_display_item "AXI Parameters" USE_PIPELINE PARAMETER ""
add_display_item "" "Slave Side Interface" GROUP tab
add_display_item "Slave Side Interface" "Slave Main" GROUP
add_display_item "Slave Side Interface" "Slave AW Channel" GROUP
add_display_item "Slave Side Interface" "Slave W Channel" GROUP
add_display_item "Slave Side Interface" "Slave B Channel" GROUP
add_display_item "Slave Side Interface" "Slave AR Channel" GROUP
add_display_item "Slave Side Interface" "Slave R Channel" GROUP
add_display_item "Slave Main" S0_ID_WIDTH PARAMETER ""
add_display_item "Slave Main" WRITE_ACCEPTANCE_CAPABILITY PARAMETER ""
add_display_item "Slave Main" READ_ACCEPTANCE_CAPABILITY PARAMETER ""
add_display_item "Slave Main" COMBINED_ACCEPTANCE_CAPABILITY PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWREGION PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWLOCK PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWCACHE PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWQOS PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWPROT PARAMETER ""
add_display_item "Slave AW Channel" USE_S0_AWUSER PARAMETER ""
add_display_item "Slave W Channel" USE_S0_WLAST PARAMETER ""
add_display_item "Slave W Channel" USE_S0_WUSER PARAMETER ""
add_display_item "Slave B Channel" USE_S0_BRESP PARAMETER ""
add_display_item "Slave B Channel" USE_S0_BUSER PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARREGION PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARLOCK PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARCACHE PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARQOS PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARPROT PARAMETER ""
add_display_item "Slave AR Channel" USE_S0_ARUSER PARAMETER ""  
add_display_item "Slave R Channel" USE_S0_RRESP PARAMETER ""
add_display_item "Slave R Channel" USE_S0_RUSER PARAMETER ""
add_display_item "" "Master Side Interface" GROUP tab
add_display_item "Master Side Interface" "Master Main" GROUP
add_display_item "Master Side Interface" "Master AW Channel" GROUP
add_display_item "Master Side Interface" "Master W Channel" GROUP
add_display_item "Master Side Interface" "Master B Channel" GROUP
add_display_item "Master Side Interface" "Master AR Channel" GROUP
add_display_item "Master Side Interface" "Master R Channel" GROUP
add_display_item "Master Main" M0_ID_WIDTH PARAMETER ""
add_display_item "Master Main" WRITE_ISSUING_CAPABILITY PARAMETER ""
add_display_item "Master Main" READ_ISSUING_CAPABILITY PARAMETER ""
add_display_item "Master Main" COMBINED_ISSUING_CAPABILITY PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWID     PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWREGION PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWLEN    PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWSIZE   PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWBURST  PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWLOCK   PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWCACHE  PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWQOS    PARAMETER ""
add_display_item "Master AW Channel" USE_M0_AWUSER   PARAMETER ""
add_display_item "Master W Channel"  USE_M0_WSTRB    PARAMETER ""
add_display_item "Master W Channel"  USE_M0_WUSER    PARAMETER ""
add_display_item "Master B Channel"  USE_M0_BID      PARAMETER ""
add_display_item "Master B Channel"  USE_M0_BRESP    PARAMETER ""
add_display_item "Master B Channel"  USE_M0_BUSER    PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARID     PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARREGION PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARLEN    PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARSIZE   PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARBURST  PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARLOCK   PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARCACHE  PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARQOS    PARAMETER ""
add_display_item "Master AR Channel" USE_M0_ARUSER   PARAMETER ""
add_display_item "Master R Channel"  USE_M0_RID      PARAMETER ""
add_display_item "Master R Channel"  USE_M0_RRESP    PARAMETER ""
add_display_item "Master R Channel"  USE_M0_RLAST    PARAMETER ""
add_display_item "Master R Channel"  USE_M0_RUSER    PARAMETER ""

proc validate_parameters {} {
    set axi3_version          [ get_parameter_value M0_AXI_VERSION ]

    set_enable USE_S0_AWREGION
    set_enable USE_S0_AWLOCK
    set_enable USE_S0_AWCACHE
    set_enable USE_S0_AWQOS
    set_enable USE_S0_AWPROT
    set_enable USE_S0_WLAST
    set_enable USE_S0_BRESP
    set_enable USE_S0_ARREGION
    set_enable USE_S0_ARLOCK
    set_enable USE_S0_ARCACHE
    set_enable USE_S0_ARQOS
    set_enable USE_S0_ARPROT  
    set_enable USE_S0_RRESP

    set_enable USE_M0_AWID    
    set_enable USE_M0_AWREGION
    set_enable USE_M0_AWLEN   
    set_enable USE_M0_AWSIZE  
    set_enable USE_M0_AWBURST 
    set_enable USE_M0_AWLOCK  
    set_enable USE_M0_AWCACHE 
    set_enable USE_M0_AWQOS   
    set_enable USE_M0_WSTRB   
    set_enable USE_M0_BID     
    set_enable USE_M0_BRESP   
    set_enable USE_M0_ARID    
    set_enable USE_M0_ARREGION
    set_enable USE_M0_ARLEN   
    set_enable USE_M0_ARSIZE  
    set_enable USE_M0_ARBURST 
    set_enable USE_M0_ARLOCK  
    set_enable USE_M0_ARCACHE 
    set_enable USE_M0_ARQOS   
    set_enable USE_M0_RID     
    set_enable USE_M0_RRESP   
    set_enable USE_M0_RLAST   

    if { [expr {$axi3_version == "AXI3"}] } {
        set_disable USE_S0_AWREGION
        set_disable USE_S0_AWLOCK
        set_disable USE_S0_AWCACHE
        set_disable USE_S0_AWQOS
        set_disable USE_S0_AWPROT
        set_disable USE_S0_WLAST
        set_disable USE_S0_WUSER
        set_disable USE_S0_BRESP
        set_disable USE_S0_BUSER
        set_disable USE_S0_ARREGION
        set_disable USE_S0_ARLOCK
        set_disable USE_S0_ARCACHE
        set_disable USE_S0_ARQOS
        set_disable USE_S0_ARPROT
        set_disable USE_S0_RRESP
        set_disable USE_S0_RUSER

        set_disable USE_M0_AWID
        set_disable USE_M0_AWREGION
        set_disable USE_M0_AWLEN
        set_disable USE_M0_AWSIZE
        set_disable USE_M0_AWBURST
        set_disable USE_M0_AWLOCK
        set_disable USE_M0_AWCACHE
        set_disable USE_M0_AWQOS
        set_disable USE_M0_WSTRB
        set_disable USE_M0_WUSER
        set_disable USE_M0_BID
        set_disable USE_M0_BUSER
        set_disable USE_M0_BRESP
        set_disable USE_M0_ARID
        set_disable USE_M0_ARREGION
        set_disable USE_M0_ARLEN
        set_disable USE_M0_ARSIZE
        set_disable USE_M0_ARBURST
        set_disable USE_M0_ARLOCK
        set_disable USE_M0_ARCACHE
        set_disable USE_M0_ARQOS
        set_disable USE_M0_RID
        set_disable USE_M0_RRESP
        set_disable USE_M0_RLAST
        set_disable USE_M0_RUSER   
    }
}   
