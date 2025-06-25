# ==============================================================================
# Altera Avalon Half Rate Bridge
# ==============================================================================
set TOP_MODULE          "altera_avalon_half_rate_bridge"
set LOCAL_HDL_FILE      "${TOP_MODULE}.v"
set_module_property     "TOP_LEVEL_HDL_FILE"        $LOCAL_HDL_FILE
set_module_property     "TOP_LEVEL_HDL_MODULE"      $TOP_MODULE
set_module_property     "NAME"                      $TOP_MODULE
set_module_property     "DESCRIPTION"               "Half Rate Bridge for DDR, DDR2 and DDR3 SDRAM High Performance Controllers"
set_module_property     "displayName"               "Avalon MM DDR Memory Half Rate Bridge"
set_module_property     "AUTHOR"                    "Altera Corporation"
set_module_property     "group"                     "Bridges and Adapters/Memory Mapped"
set_module_property     "instantiateInSystemModule" "true"
set_module_property     "version"                   "13.1"
set_module_property     "ELABORATION_CALLBACK"      "elaborate"
set_module_property     "VALIDATION_CALLBACK"       "validate"
set_module_property     "DATASHEET_URL"             "http://www.altera.com/literature/hb/qts/qts_qii54020.pdf"
set_module_property     "SIMULATION_MODEL_IN_VHDL"  "true"
set_module_property     "EDITABLE"                  "false"
add_file                $LOCAL_HDL_FILE             {SYNTHESIS SIMULATION}
add_file                "altera_avalon_half_rate_bridge_warnings.sdc"         SDC

# ==============================================================================
# PARAMETER
# ==============================================================================

#------------------------------- 
# PARAMETER GROUP
#------------------------------- 
set DERIVE_PARAM_GROUP  "Derived Parameters"
set MASTER_PARAM_GROUP  "Master Interface"

#-------------------------------
# PARAMETER NAME
#-------------------------------
set M_DATA_W_NAME   "AVM_DATA_WIDTH"
set M_ADDR_W_NAME   "AVM_ADDR_WIDTH"
set M_BYTE_W_NAME   "AVM_BYTE_WIDTH"
set S_DATA_W_NAME   "AVS_DATA_WIDTH"
set S_ADDR_W_NAME   "AVS_ADDR_WIDTH"
set S_BYTE_W_NAME   "AVS_BYTE_WIDTH"
#-------------------------------
# AVM_DATA_WIDTH
#-------------------------------
add_parameter           $M_DATA_W_NAME  "integer"           "16"    "Set master interface's data bus width"
set_parameter_property  $M_DATA_W_NAME  "DISPLAY_NAME"      "Data Width"
set_parameter_property  $M_DATA_W_NAME  "ALLOWED_RANGES"    {8 16 32 64 128 256 512}
set_parameter_property  $M_DATA_W_NAME  "GROUP"             $MASTER_PARAM_GROUP

#-------------------------------
# AVM_ADDR_WIDTH
#-------------------------------
add_parameter           $M_ADDR_W_NAME  "integer"           "24"    "Set master interface's address bus width"
set_parameter_property  $M_ADDR_W_NAME  "DISPLAY_NAME"      "Address Width"
set_parameter_property  $M_ADDR_W_NAME  "GROUP"             $MASTER_PARAM_GROUP

# ==============================================================================
# Derived Parameter
# ==============================================================================
#-------------------------------
# AVM_BYTE_WIDTH
#-------------------------------
add_parameter           $M_BYTE_W_NAME  "integer"           "2"     "Master interface's ByteEnable Width"
set_parameter_property  $M_BYTE_W_NAME  "DISPLAY_NAME"      "Master interface's ByteEnable Width"
set_parameter_property  $M_BYTE_W_NAME  "DERIVED"           "true"
set_parameter_property  $M_BYTE_W_NAME  "VISIBLE"           "true"
set_parameter_property  $M_BYTE_W_NAME  "GROUP"             $DERIVE_PARAM_GROUP

#-------------------------------
# AVS_DATA_WIDTH
#-------------------------------
add_parameter           $S_DATA_W_NAME  "integer"           "32"    "Slave interface's Data Width"
set_parameter_property  $S_DATA_W_NAME  "DISPLAY_NAME"      "Slave interface's Data Width"
set_parameter_property  $S_DATA_W_NAME  "DERIVED"           "true"
set_parameter_property  $S_DATA_W_NAME  "VISIBLE"           "true"
set_parameter_property  $S_DATA_W_NAME  "GROUP"             $DERIVE_PARAM_GROUP

#-------------------------------
# AVS_ADDR_WIDTH
#-------------------------------
add_parameter           $S_ADDR_W_NAME  "integer"           "22"    "Slave interface's Address Width"
set_parameter_property  $S_ADDR_W_NAME  "DISPLAY_NAME"      "Slave interface's Address Width"
set_parameter_property  $S_ADDR_W_NAME  "DERIVED"           "true"
set_parameter_property  $S_ADDR_W_NAME  "VISIBLE"           "true"
set_parameter_property  $S_ADDR_W_NAME  "GROUP"             $DERIVE_PARAM_GROUP

#-------------------------------
# AVS_BYTE_WIDTH
#-------------------------------
add_parameter           $S_BYTE_W_NAME  "integer"           "4"     "Slave interface's ByteEnable Width"
set_parameter_property  $S_BYTE_W_NAME  "DISPLAY_NAME"      "Slave interface's ByteEnable Width"
set_parameter_property  $S_BYTE_W_NAME  "DERIVED"           "true"
set_parameter_property  $S_BYTE_W_NAME  "VISIBLE"           "true"
set_parameter_property  $S_BYTE_W_NAME  "GROUP"             $DERIVE_PARAM_GROUP

# ==============================================================================
# End of Module Declaration, the rest only function,
#   validate  {}   --> validation callback
#   elaborate {}   --> elaborate  callback
#   log2ceil  {}   --> my own function to calculate log2ceil(x), log 2, ceil it
# ==============================================================================

# ==============================================================================
# validate
# ==============================================================================
proc validate {} {
    # ------------------------------------------------------------------
    # Get Parameter Name
    # ------------------------------------------------------------------
    global  M_DATA_W_NAME
    global  M_ADDR_W_NAME
    global  M_BYTE_W_NAME
    global  S_DATA_W_NAME
    global  S_ADDR_W_NAME
    global  S_BYTE_W_NAME
    # ------------------------------------------------------------------
    # Get the main Parameter value
    # ------------------------------------------------------------------
    set     M_DATA_W_VALUE  [ get_parameter_value $M_DATA_W_NAME ]
    set     M_ADDR_W_VALUE  [ get_parameter_value $M_ADDR_W_NAME ]
    # ------------------------------------------------------------------
    # Calculate derived value
    # all derived Parameter are resolved,
    # so that only depends non-derived Parameter
    # ------------------------------------------------------------------
    #
    #   AVM_BYTE_WIDTH  = Master's Byte Enable Width
    #                   = AVM_DATA_WIDTH / 8
    #
    #   AVS_DATA_WIDTH  = always 2X of Master DATA Width
    #                   = AVM_DATA_WIDTH * 2
    #
    #   AVS_BYTE_WIDTH  = Slave's Byte Enable Width
    #                   = {   AVS_DATA_WIDTH   } / 8  --> resolve AVS_DATA_WIDTH
    #                   = { AVM_DATA_WIDTH * 2 } / 8  --> simplify
    #                   = AVM_DATA_WIDTH / 4
    #
    # AVS_ADDR_WIDTH = AVM_ADDR_WIDTH - log2ceil(AVM_DATA_WIDTH / 4 )
    #
    #      Equation is base on Equation / math below:-
    #           Total addressable bytes in Master = total addressable byte in Slave
    #           (2^AVM_ADDR_WIDTH) = (2^AVS_ADDR_WIDTH) * (AVS_DATA_WIDTH / 8)  --> log2ceil to both side
    #           AVM_ADDR_WIDTH = AVS_ADDR_WIDTH + log2ceil(AVS_DATA_WIDTH / 8)      --> move log2ceil() over
    #           AVS_ADDR_WIDTH = AVM_ADDR_WIDTH - log2ceil(AVS_DATA_WIDTH / 8)      --> resolve AVS_DATA_WIDTH
    #           AVS_ADDR_WIDTH = AVM_ADDR_WIDTH - log2ceil(AVM_DATA_WIDTH * 2 / 8)  --> simplify, Then we get
    #           AVS_ADDR_WIDTH = AVM_ADDR_WIDTH - log2ceil(AVM_DATA_WIDTH / 4 )
    #
    # ------------------------------------------------------------------
    set     M_BYTE_W_VALUE  [ expr { $M_DATA_W_VALUE / 8 } ]
    set     S_DATA_W_VALUE  [ expr { $M_DATA_W_VALUE * 2 } ]
    set     S_BYTE_W_VALUE  [ expr { $M_DATA_W_VALUE / 4 } ]
    set     S_ADDR_W_VALUE  [ expr { $M_ADDR_W_VALUE - [ log2ceil [ expr { $M_DATA_W_VALUE / 4 } ] ] } ]
    # ------------------------------------------------------------------
    # set derived parameter
    # ------------------------------------------------------------------
    set_parameter_value     $M_BYTE_W_NAME        $M_BYTE_W_VALUE
    set_parameter_value     $S_DATA_W_NAME        $S_DATA_W_VALUE
    set_parameter_value     $S_ADDR_W_NAME        $S_ADDR_W_VALUE
    set_parameter_value     $S_BYTE_W_NAME        $S_BYTE_W_VALUE
}

# ==============================================================================
# elaborate
# ==============================================================================
proc elaborate {} {
    # ------------------------------------------------------------------
    # Get Parameter Name & Value
    # ------------------------------------------------------------------
    global  M_DATA_W_NAME
    global  M_ADDR_W_NAME
    global  M_BYTE_W_NAME
    global  S_DATA_W_NAME
    global  S_ADDR_W_NAME
    global  S_BYTE_W_NAME
    set     M_DATA_W_VALUE  [ get_parameter_value $M_DATA_W_NAME ]
    set     M_ADDR_W_VALUE  [ get_parameter_value $M_ADDR_W_NAME ]
    set     M_BYTE_W_VALUE  [ get_parameter_value $M_BYTE_W_NAME ]
    set     S_DATA_W_VALUE  [ get_parameter_value $S_DATA_W_NAME ]
    set     S_ADDR_W_VALUE  [ get_parameter_value $S_ADDR_W_NAME ]
    set     S_BYTE_W_VALUE  [ get_parameter_value $S_BYTE_W_NAME ]

    # ------------------------------------------------------------------
    # Interface Name
    set     S1_CLK_INTERFACE_NAME     "clk_s1"
    set     M1_CLK_INTERFACE_NAME     "clk_m1"
    set     SLAVE_INTERFACE_NAME      "s1"
    set     MASTER_INTERFACE_NAME     "m1"
    # ------------------------------------------------------------------
    
    # ==================================================================
    # Interface clk_s1
    # ==================================================================
    add_interface           $S1_CLK_INTERFACE_NAME      "clock"              "end"
    # ----------------------------------------------------------
    # Ports in interface clk_s1
    # ----------------------------------------------------------
    add_interface_port      $S1_CLK_INTERFACE_NAME      "avs_clk"            "clk"           "input"     1
    add_interface_port      $S1_CLK_INTERFACE_NAME      "avs_reset_n"        "reset_n"       "input"     1

    # ==================================================================
    # Interface clk_m1
    # ==================================================================
    add_interface           $M1_CLK_INTERFACE_NAME      "clock"             "end"
    # ----------------------------------------------------------
    # Ports in interface clk_m1
    # ----------------------------------------------------------
    add_interface_port      $M1_CLK_INTERFACE_NAME      "avm_clk"           "clk"           "input"     1
    add_interface_port      $M1_CLK_INTERFACE_NAME      "avm_reset_n"       "reset_n"       "input"     1

    # ==================================================================
    # Interface s1
    # ==================================================================
    add_interface           $SLAVE_INTERFACE_NAME        "avalon"        "slave"             $S1_CLK_INTERFACE_NAME
    set_interface_property  $SLAVE_INTERFACE_NAME        "isNonVolatileStorage"              "false"
    set_interface_property  $SLAVE_INTERFACE_NAME        "burstOnBurstBoundariesOnly"        "false"
    set_interface_property  $SLAVE_INTERFACE_NAME        "readLatency"                       "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "readWaitStates"                    "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "holdTime"                          "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "printableDevice"                   "false"
    set_interface_property  $SLAVE_INTERFACE_NAME        "readWaitTime"                      "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "setupTime"                         "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "addressAlignment"                  "DYNAMIC"
    set_interface_property  $SLAVE_INTERFACE_NAME        "writeWaitTime"                     "0"
    set_interface_property  $SLAVE_INTERFACE_NAME        "timingUnits"                       "Cycles"
    set_interface_property  $SLAVE_INTERFACE_NAME        "minimumUninterruptedRunLength"     "1"
    set_interface_property  $SLAVE_INTERFACE_NAME        "isMemoryDevice"                    "false"
    set_interface_property  $SLAVE_INTERFACE_NAME        "linewrapBursts"                    "false"
    set_interface_property  $SLAVE_INTERFACE_NAME        "bridgesToMaster"                   $MASTER_INTERFACE_NAME
    set_interface_property  $SLAVE_INTERFACE_NAME        "maximumPendingReadTransactions"    "36"
    # ----------------------------------------------------------
    # Ports in interface s1
    # ----------------------------------------------------------
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_chipselect"    "chipselect"    "input"     1
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_address"       "address"       "input"     $S_ADDR_W_VALUE
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_write"         "write"         "input"     1
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_read"          "read"          "input"     1
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_byteenable"    "byteenable"    "input"     $S_BYTE_W_VALUE
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_writedata"     "writedata"     "input"     $S_DATA_W_VALUE
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_readdata"      "readdata"      "output"    $S_DATA_W_VALUE
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_waitrequest"   "waitrequest"   "output"    1
    add_interface_port      $SLAVE_INTERFACE_NAME        "avs_readdatavalid" "readdatavalid" "output"    1

    # ==================================================================
    # Interface avalon_master_0
    # ==================================================================
    add_interface           $MASTER_INTERFACE_NAME       "avalon"            "master"        $M1_CLK_INTERFACE_NAME
    set_interface_property  $MASTER_INTERFACE_NAME       "burstOnBurstBoundariesOnly"        "true"
    set_interface_property  $MASTER_INTERFACE_NAME       "doStreamReads"                     "true"
    set_interface_property  $MASTER_INTERFACE_NAME       "linewrapBursts"                    "false"
    set_interface_property  $MASTER_INTERFACE_NAME       "doStreamWrites"                    "false"
    # ----------------------------------------------------------
    # Ports in interface avalon_master_0
    # ----------------------------------------------------------
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_burstcount"    "burstcount"    "output"    2
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_address"       "address"       "output"    $M_ADDR_W_VALUE
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_write"         "write"         "output"    1
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_read"          "read"          "output"    1
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_byteenable"    "byteenable"    "output"    $M_BYTE_W_VALUE
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_writedata"     "writedata"     "output"    $M_DATA_W_VALUE
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_readdata"      "readdata"      "input"     $M_DATA_W_VALUE
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_waitrequest"   "waitrequest"   "input"     1
    add_interface_port      $MASTER_INTERFACE_NAME       "avm_readdatavalid" "readdatavalid" "input"     1
}

# ==============================================================================
# My own function - log2 and ceil
# ==============================================================================
proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val
}

