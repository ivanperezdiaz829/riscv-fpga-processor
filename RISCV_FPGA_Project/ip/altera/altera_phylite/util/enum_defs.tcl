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


# package: altera_phylite::util::enum_defs
#
# The package contains enum definitions.
#
package provide altera_phylite::util::enum_defs 0.1

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################
package require altera_emif::util::enums

# Load all required properties files
load_strings common_gui.properties

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::altera_phylite::util::enum_defs:: {
   # Import functions into namespace
   namespace import ::altera_emif::util::enums::*

   # Export functions

   # Package variables
}

################################################################################
###                          TCL PROCEDURES                                  ###
################################################################################

# proc: def_enums
#
# Define enums
#
# parameters:
#
# returns:
#
proc ::altera_phylite::util::enum_defs::def_enums {} {


   #############################
   # Families
   #############################
   def_enum_type PHYLITE_FAMILY                                        {     UI_NAME         ARCH_COMPONENT            BASE_FAMILY_ENUM     QSYS_NAMES         MEGAFUNC_NAME    DEFAULT_PART_FOR_ED  }
   def_enum      PHYLITE_FAMILY      PHYLITE_FAMILY_INVALID                   [list ""              ""                        FAMILY_INVALID       [list ]            ""               ""                   ]
   def_enum      PHYLITE_FAMILY      PHYLITE_FAMILY_ARRIAVI                   [list "Arria 10"      "altera_phylite_arch_nf"  FAMILY_ARRIAVI       [list ARRIA10]     "ARRIA 10"       "NIGHTFURY5_F1932BC2"]
   
   #############################
   # Core Rate
   #############################
   def_enum_type RATE_IN                                                   {     UI_NAME    AFI_RATIO}
   def_enum      RATE_IN                  RATE_IN_INVALID                     [list ""         0        ]   
   def_enum      RATE_IN                  RATE_IN_FULL                        [list "Full"     1        ]
   def_enum      RATE_IN                  RATE_IN_HALF                        [list "Half"     2        ]
   def_enum      RATE_IN                  RATE_IN_QUARTER                     [list "Quarter"  4        ] 

   #############################
   # EMIF Configurations
   #############################
   def_enum_type PIN_TYPE                             {     UI_NAME                       }
   def_enum      PIN_TYPE               INPUT         [list "input"                       ]
   def_enum      PIN_TYPE               OUTPUT        [list "output"                      ]
   def_enum      PIN_TYPE               BIDIR         [list "bidirectional"               ]
      
   #############################
   # Sim calibration mode
   #############################
   def_enum_type DDR_SDR_MODE                         {     UI_NAME           }
   def_enum      DDR_SDR_MODE           DDR           [list "DDR"]
   def_enum      DDR_SDR_MODE           SDR           [list "SDR"]
      
}

################################################################################
###                       PRIVATE FUNCTIONS                                  ###
################################################################################

# proc: _init
#
# Private function to initialize internal constants
#
# parameters:
#
# returns:
#
proc ::altera_phylite::util::enum_defs::_init {} {
   ::altera_phylite::util::enum_defs::def_enums
}

################################################################################
###                   AUTO RUN CODE AT STARTUP                               ###
################################################################################
# Run the initialization
::altera_phylite::util::enum_defs::_init



