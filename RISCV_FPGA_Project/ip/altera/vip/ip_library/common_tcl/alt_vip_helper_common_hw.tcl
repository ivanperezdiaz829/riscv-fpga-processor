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


package require -exact sopc 10.0


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information shared by all VIP cores and components                                   --
# -- the NAME, DISPLAY_NAME and DESCRIPTION module properties have to be declared independently   --
# -- by each component                                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

set isInternalDevelopment "0"
set isVipRefDesign "__VIP_REF_DESIGN__"

if {$isInternalDevelopment == 0} {
    set acdsVersion  13.1
    set isVersion    13.1
    set isInternalComponent true
    set isEncryptedComponent true
} else {
    set isInternalComponent false
    if {$isVipRefDesign == 0} {
        set isEncryptedComponent true
        set acdsVersion  __VIP_REF_DESIGN_VERSION__
        set isVersion    __VIP_REF_DESIGN_VERSION__
    } else {
        set isEncryptedComponent false
        set acdsVersion  13.0
        set isVersion    99.0
    }
}

proc declare_general_module_info {} {
    global isVersion

    set_module_property     GROUP                            "DSP/Video and Image Processing"
    set_module_property     VERSION                          $isVersion
    set_module_property     AUTHOR                           "Altera Corporation"
    set_module_property     DATASHEET_URL                    http://www.altera.com/literature/ug/ug_vip.pdf
    set_module_property     ANALYZE_HDL                      false
    set_module_property     SIMULATION_MODEL_IN_VHDL         true
    set_module_property     SIMULATION_MODEL_IN_VERILOG      true
    set_module_property     FIX_110_VIP_PATH                 true
}

proc declare_general_component_info {} {
    global isVersion isInternalComponent isEncryptedComponent

    set_module_property     GROUP                            "DSP/Video and Image Processing/Component Library"
    set_module_property     VERSION                          $isVersion
    set_module_property     AUTHOR                           "Altera Corporation"
    set_module_property     INTERNAL                         $isInternalComponent
    set_module_property     INSTANTIATE_IN_SYSTEM_MODULE     true
    set_module_property     ANALYZE_HDL                      false
    set_module_property     SIMULATION_MODEL_IN_VHDL         true
    set_module_property     SIMULATION_MODEL_IN_VERILOG      $isEncryptedComponent
    set_module_property     FIX_110_VIP_PATH                 true
}

proc declare_general_non_released_module_info {} {
    set_module_property     GROUP                            "DSP/Video and Image Processing/Non-released"
    set_module_property     VERSION                          0.1
    set_module_property     AUTHOR                           Altera
    set_module_property     ANALYZE_HDL                      false
    set_module_property     SIMULATION_MODEL_IN_VHDL         true
    set_module_property     SIMULATION_MODEL_IN_VERILOG      true
}

proc declare_general_non_released_component_info {} {
    set_module_property     GROUP                            "DSP/Video and Image Processing/Non-released/Component Library"
    set_module_property     VERSION                          0.1
    set_module_property     AUTHOR                           "Altera Corporation"
    set_module_property     INTERNAL                         true
    set_module_property     INSTANTIATE_IN_SYSTEM_MODULE     true
    set_module_property     ANALYZE_HDL                      false
    set_module_property     SIMULATION_MODEL_IN_VHDL         true
    set_module_property     SIMULATION_MODEL_IN_VERILOG      true
}



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General helper functions                                                                     --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# clogb2_pure: ceil(log2(x))
# ceil(log2(4)) = 2 wires are required to address a memory of depth 4
proc clogb2_pure {max_value} {
   set l2 [expr int(ceil(log($max_value)/(log(2))))]
   if { $l2 == 0 } {
      set l2 1
   }
   return $l2
}

# clogb2: ceil(log2(x+1))
# ceil(log2(4)) = 3 wires are required to represent the number 4 in binary format
proc clogb2 {max_value} {
    set l2g [clogb2_pure [expr $max_value+1]]
    return $l2g
}

# power: num**p
proc power {num p} {
    set result 1
    while {$p > 0} {
        set result [expr $result * $num]
        set p [expr $p - 1]
    }
    return $result
}

# min(a,b) function
proc min {in_1 in_2} {
    if { $in_1 < $in_2 } {
        set temp $in_1
    } else {
        set temp $in_2
    }
    return $temp
}

# max(a,b) function
proc max {in_1 in_2} {
    if { $in_1 > $in_2 } {
        set temp $in_1
    } else {
        set temp $in_2
    }
    return $temp
}
