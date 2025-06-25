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


# +--------------------------------------------------------------------------------------------------------------------
# |
# | Name:        altera_pe_message_format.tcl
# |
# | Description: This package provides construction and validation procedures which should be used when constructing
# |              interfaces conforming to the Avalon-ST Message specification.
# |
# | Notes:       Interface assignments are used to transfer information between each of the proceedures in this
# |              package. They are also used to save information to the sopcinfo file for use by downstream tools.
# |
# | Author:      Mark Lewis
# |
# +--------------------------------------------------------------------------------------------------------------------
package provide altera_pe_message_format 1.0

set package_version ""
catch {set package_version [package present sopc]}

# This package has been verified against the versions of the SOPC package given below
if {($package_version != "10.0") && ($package_version != "10.1")} {
    package require -exact sopc 10.1
}



# +--------------------------------------------------------------------------------------------------------------------
# | Define a namespace for this package, including a list of proceedures to export.
# |
# | Define any constant values used in the package.
# +--------------------------------------------------------------------------------------------------------------------
namespace eval ::altera_pe_message_format {
    namespace export set_message_property get_message_property set_message_subfield_property get_message_subfield_property set_message_subfield_hdl_port validate_and_create


    # Message property values and defaults
    variable valid_message_properties {PEID ZERO_OUTPUT_PORT UNUSED_INPUT_PORT UNUSED_INPUT_WIDTH_PARAM }
    variable message_property_defaults
    array set message_property_defaults {
        PEID                        -1
        ZERO_OUTPUT_PORT            ""
        UNUSED_INPUT_PORT           ""
        UNUSED_INPUT_WIDTH_PARAM    ""
    }

    # Message subfield property values and defaults
    variable valid_message_control_fields {destination source taskid context user flags}
    variable valid_message_subfield_properties {SYMBOL_WIDTH SYMBOLS_PER_BEAT BASE DEFAULT}
    variable message_subfield_property_defaults
    array set message_subfield_property_defaults {
        SYMBOL_WIDTH            0
        SYMBOLS_PER_BEAT        1
        BASE                    -1
        DEFAULT                 0
    }

    # Default value of dataBitsPerSymbol provided by SOPC Builder. Used to verify that the user has not
    # tried to set this themselves.
    variable defaultBitsPerSymbol 8

    # Debug capabilites. If doDebugOutput is true, the contents of the validate_and_create proceedure's
    # internal data structure is dumped as an info message. If debugSubfieldOutputList is empty, the entire
    # data structure is dumped, otherwise the output is filtered to contain information about the subfields
    # in the list.
    variable doDebugOutput false
    variable debugSubfieldOutputList {}
}



# +--------------------------------------------------------------------------------------------------------------------
# | Private helper functions for marking an interface as validated. This allows us to check that the user does not
# | make any calls to this package for an interface after create_and_validate is called for that interface.
# |
# | The interface assignment altera_pe_message_format.version is used for this job.
# +--------------------------------------------------------------------------------------------------------------------

# Mark an interface as validated
proc ::altera_pe_message_format::_mark_as_validated {interfaceName} {
    set_interface_assignment $interfaceName altera_pe_message_format.version 1.0
}

# Check whether an interface is validated
proc ::altera_pe_message_format::_is_already_validated {interfaceName} {
    set x [get_interface_assignment $interfaceName altera_pe_message_format.version]
    if {$x == ""} {
        return false
    }
    return true
}



# +--------------------------------------------------------------------------------------------------------------------
# | set_message_property - this proceedure allows you to configure the top level properties of a message interface.
# |
# | interfaceName   The name of the interface to configure
# | propertyName    The name of the property to set
# | value           The value of the property
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::set_message_property {interfaceName propertyName value} {
    variable valid_message_properties

    # Check that the property name is valid
    if {[lsearch -exact $valid_message_properties $propertyName] == -1} {
        error "set_message_property: The property $propertyName is not allowed. Permitted values are $valid_message_properties"
    }

    # Check that this interface has not been validated already
    if { [_is_already_validated $interfaceName] } {
        error "set_message_property: illegally called after validate_and_create on interface $interfaceName"
    }

    # Store the property
    set_interface_assignment $interfaceName "altera_pe_message_format.$propertyName" $value
}



# +--------------------------------------------------------------------------------------------------------------------
# | get_message_property - this proceedure allows you to retrieve the top level properties of a message interface.
# |
# | interfaceName     The name of the interface to interogate
# | propertyName      The name of the property to retrieve
# |
# | Returns the value of the property
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::get_message_property {interfaceName propertyName} {
    variable valid_message_properties
    variable message_property_defaults

    # Check that the property name is valid
    if {[lsearch -exact $valid_message_properties $propertyName] == -1} {
        error "get_message_property: The property $propertyName is not allowed. Permitted values are $valid_message_properties"
    }

    set value [get_interface_assignment $interfaceName "altera_pe_message_format.$propertyName"]
    if {$value == ""} {
        return $message_property_defaults($propertyName)
    } else {
        return $value
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | Private helper function which check that the subfield name is valid. Valid subfield names are represented by a
# | concatenation of the valid_message_control_fields variable and argument.
# |
# | If the subfield name is provided by set_message_subfield_hdl_port for the purpose of binding an HDL signal to each
# | subfield, the subfieldName argumentEmpty is also valid.
# |
# | subfieldName    The subfieldName to verify
# | hdlPort         Set to 1 when called from set_message_subfield_hdl_port
# |
# | Returns 1 if the subfield name is valid, 0 otherwise
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_is_valid_subfield {subfieldName {hdlPort 0}} {
    variable valid_message_control_fields

    set valid_fields [concat argument $valid_message_control_fields]
    if {$hdlPort} {
        lappend valid_fields argumentEmpty
    }

    if {[lsearch -exact $valid_fields $subfieldName] == -1} {
        return 0
    }

    return 1
}



# +--------------------------------------------------------------------------------------------------------------------
# | set_message_subfield_property - allows you to set the properties of a message subfield.
# |
# | interfaceName     The name of the interface to configure
# | subfieldName      The name of the subfield to configure
# | propertyName      The name of the property to set
# | value             The value of the property
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::set_message_subfield_property {interfaceName subfieldName propertyName value} {
    variable valid_message_control_fields
    variable valid_message_subfield_properties

    # Check that the subfield name is valid
    if {![_is_valid_subfield $subfieldName]} {
        error "set_message_subfield_property: The subfield $subfieldName is not allowed. Permitted values are argument $valid_message_control_fields"
    }

    # Check that the property name is valid
    if {[lsearch -exact $valid_message_subfield_properties $propertyName] == -1} {
        error "set_message_subfield_property: The property $propertyName is not allowed. Permitted values are $valid_message_subfield_properties"
    }

    # Check that this interface has not been validated already
    if { [_is_already_validated $interfaceName] } {
        error "set_message_subfield_property: illegally called after validate_and_create on interface $interfaceName"
    }

    # Store the property
    set_interface_assignment $interfaceName "altera_pe_message_format.$subfieldName.$propertyName" $value
}



# +--------------------------------------------------------------------------------------------------------------------
# | This command returns a single message subfield interface property.
# |
# | interfaceName     The name of the interface to interogate
# | subfieldName      The name of the subfield to interogate
# | propertyName      The name of the property to retrieve
# |
# | Returns the value of the property
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::get_message_subfield_property {interfaceName subfieldName propertyName} {
    variable valid_message_control_fields
    variable valid_message_subfield_properties
    variable message_subfield_property_defaults

    # Check that the subfield name is valid
    if {![_is_valid_subfield $subfieldName]} {
        error "get_message_subfield_property: The subfield $subfieldName is not allowed. Permitted values are argument $valid_message_control_fields"
    }

    # Check that the property name is valid
    if {[lsearch -exact $valid_message_subfield_properties $propertyName] == -1} {
        error "get_message_subfield_property: The property $propertyName is not allowed. Permitted values are $valid_message_subfield_properties"
    }

    set value [get_interface_assignment $interfaceName "altera_pe_message_format.$subfieldName.$propertyName"]
    if {$value == ""} {
        return $message_subfield_property_defaults($propertyName)
    } else {
        return $value
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | set_message_subfield_hdl_port -This command allows you to bind a port on your HDL module to a subfield within the
# | data signal of a message interface.
# |
# | The use of this command is optional and will result in the data signal for the given interface to be constructed
# | from HDL signals using the FRAGMENT_LIST port property. This command may not be combined with manual use of the
# | FRAGMENT_LIST port property on the associated data signal.
# |
# | The mapping of the data signal to HDL ports takes place when the validate_and_create command is executed.
# |
# | interfaceName     The name of the interface to configure
# | subfieldName      The name of the subfield to configure
# | portString        String describing the HDL port name and bit range to bind to the given subfield.
# |
# | The portString has the following syntax:
# |
# |     <hdl_port_name>[@<lsb>:<msb>]
# |
# | Where <hdl_port_name> is the name of the HDL port. <lsb> is the least significant bit of the HDL port to use.
# | <msb> is the most significant bit of the HDL port to use.
# |
# | If this string just contains the HDL port name, then the width of the HDL port must match the width of the
# | subfield. If this string contains a bit range, then the width of this range must match the width of the
# | subfield. For example:
# |
# |    "avs_msgout_taskid"
# |    "avs_msgout_taskid@0:7"
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::set_message_subfield_hdl_port {interfaceName subfieldName portString} {
    variable valid_message_control_fields
    variable valid_message_subfield_properties

    # Check that the subfield name is valid
    if {![_is_valid_subfield $subfieldName 1]} {
        error "set_message_subfield_hdl_port: The subfield $subfieldName is not allowed. Permitted values are argument $valid_message_control_fields argumentEmpty"
    }

    # Check that this interface has not been validated already
    if { [_is_already_validated $interfaceName] } {
        error "set_message_subfield_hdl_port: illegally called after validate_and_create on interface $interfaceName"
    }

    # Store the property
    set_interface_assignment $interfaceName "altera_pe_message_format.$subfieldName.HDL_PORT" $portString
}



# Private helper function that retrieves the HDL port string
proc ::altera_pe_message_format::_get_message_subfield_hdl_port {interfaceName subfieldName} {
    return [get_interface_assignment $interfaceName "altera_pe_message_format.$subfieldName.HDL_PORT"]
}



# +--------------------------------------------------------------------------------------------------------------------
# | Check that the specified interface has the correct ports, carries one symbol per beat and has ready latency zero
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_validate_interface_ports {interfaceName parentDataPort parentDataPortWidth} {
    upvar 1 $parentDataPort dataPort
    upvar 1 $parentDataPortWidth dataPortWidth
    variable defaultBitsPerSymbol

    # Note that SOPC Builder does not provide the ability to check the type of an interface
    # (e.g Avalon ST source/sink). Instead we have to rely on the port roles

    # Check that the interface has the correct ports
    foreach port [get_interface_ports $interfaceName] {
        set role [get_port_property $port ROLE]
        set roles($role) true

        if {$role == "data"} {
            set dataPort $port
        }
    }

    set requiredRoles {data endofpacket ready startofpacket valid}
    foreach requiredRole $requiredRoles {
        if { ![info exists roles($requiredRole)] } {
            error "Interface $interfaceName does not have a port with the role $requiredRole"
        }
    }

    # Check that the dataBitsPerSymbol has not been set for this interface, and set it to match the data signal width
    set dataBitsPerSymbol [get_interface_property $interfaceName dataBitsPerSymbol]
    set dataPortWidth [get_port_property $dataPort WIDTH]
    if { $dataBitsPerSymbol != $defaultBitsPerSymbol} {
        send_message warning "The dataBitsPerSymbol property of the $interfaceName interface has been set to $dataBitsPerSymbol. This will be overriden to match the data port width of $dataPortWidth."
    }

    set_interface_property $interfaceName dataBitsPerSymbol $dataPortWidth
}


# +--------------------------------------------------------------------------------------------------------------------
# | Extract the data signal parameterisation into an array for faster access and to deal with default values
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_get_data_params {interfaceName parentSubfieldArray} {
    variable valid_message_control_fields
    variable valid_message_subfield_properties
    variable message_subfield_property_defaults
    upvar 1 $parentSubfieldArray subfieldArray

    # Create a two dimensional array, keyed by subfield,property, to the default values
    foreach subfield [concat argument $valid_message_control_fields argumentEmpty] {
        foreach property $valid_message_subfield_properties {
            set subfieldArray($subfield,$property) $message_subfield_property_defaults($property)
        }

        set subfieldArray($subfield,HDL_PORT) ""
        set subfieldArray($subfield,RIGHT)    -1
        set subfieldArray($subfield,LEFT)     -1
        set subfieldArray($subfield,UNUSED)   false
        set subfieldArray($subfield,ZEROED)   false
    }


    # Go through each interface assignment and copy the value into the array
    foreach assignment [get_interface_assignments $interfaceName] {
        if { [regexp {altera_pe_message_format\.([0-9a-zA-Z_]+)\.([0-9a-zA-Z_]+)} $assignment dummy matchedSubfield matchedProperty] } {
            set value [get_interface_assignment $interfaceName $assignment]
            set subfieldArray($matchedSubfield,$matchedProperty) $value
        }
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | Private helper function which prints the contents of the subfield array as info messages. This function only
# | produces output if the doDebugOutput variable is set to true. If debugSubfieldOutputList is not empty, then the
# | function only prints information about the subfields that are listed.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_dump_subfield_array {parentSubfieldArray } {
    variable doDebugOutput
    variable debugSubfieldOutputList
    upvar 1 $parentSubfieldArray subfieldArray

    if {$doDebugOutput} {
        set nameList [array names subfieldArray]

        foreach name [lsort $nameList] {
            if {[llength $debugSubfieldOutputList] != 0} {
                regexp {([a-zA-Z0-9]+),} $name dummy subfield

                if { [lsearch -exact $debugSubfieldOutputList $subfield] == -1 } {
                    continue
                }
            }

            send_message info "subfieldArray($name) $subfieldArray($name)"
        }
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | Find the number of bits in a value
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_log2ceil {num} {
    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }
    return $val;
}


# +--------------------------------------------------------------------------------------------------------------------
# | Determine the data port bit range occupied by each subfield and store this in the array under the property names
# | LEFT and RIGHT.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_set_data_bit_ranges {interfaceName parentSubfieldArray parentDataPortWidth} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentDataPortWidth dataPortWidth
    variable valid_message_control_fields


    # Verify the construction of the argument subfield
    set argSymbolsPerBeat $subfieldArray(argument,SYMBOLS_PER_BEAT)

    if {$subfieldArray(argument,BASE) == -1} {
        set subfieldArray(argument,BASE) 0
    }

    if {$subfieldArray(argument,BASE) != 0} {
        error "Message argument subfield base on interface $interfaceName, expected 0, got $subfieldArray(argument,BASE)"
    }

    if {$argSymbolsPerBeat < 1} {
        error "Interface $interfaceName must carry at least one argument per beat"
    }

    set argTotalWidth [expr $argSymbolsPerBeat * $subfieldArray(argument,SYMBOL_WIDTH)]

    if {$argTotalWidth < 0} {
        send_message error "Interface $interfaceName: negative symbol width for argument subfield"
    }


    # Determine the size and location of the argumentEmpty subfield, and thus the base of the control fields
    if {$argTotalWidth > 0} {
        set subfieldArray(argument,RIGHT) 0
        set subfieldArray(argument,LEFT) [expr $argTotalWidth - 1]
    }

    set argEmptyWidth [_log2ceil $argSymbolsPerBeat]

    if {$argEmptyWidth > 0} {
        set subfieldArray(argumentEmpty,SYMBOL_WIDTH) $argEmptyWidth
        set subfieldArray(argumentEmpty,RIGHT) $argTotalWidth
        set subfieldArray(argumentEmpty,LEFT)  [expr $argTotalWidth + $argEmptyWidth - 1]
    }

    set controlFieldBase [expr $argTotalWidth + $argEmptyWidth]


    # Verify the contruction of each control field, and determine its LEFT and RIGHT bit positions.
    foreach subfield $valid_message_control_fields {
        set subfieldBase $subfieldArray($subfield,BASE)
        set subfieldWidth $subfieldArray($subfield,SYMBOL_WIDTH)
        set subfieldSymbolsPerBeat $subfieldArray($subfield,SYMBOLS_PER_BEAT)

        if {$subfieldWidth < 0} {
            send_message error "Interface $interfaceName: negative symbol width for $subfield subfield"
        }

        if {$subfieldSymbolsPerBeat != 1} {
            error "Interface $interfaceName: Symbols per beat value $subfieldSymbolsPerBeat not supported for subfield $subfield - should be 1"
        }

        if {($subfieldWidth > 0) && ($subfieldBase >= 0)} {
            set right [expr $controlFieldBase + $subfieldBase]
            set left  [expr $right + $subfieldWidth - 1]

            if {$left >= $dataPortWidth} {
                send_message error "Interface $interfaceName: Data signal is too narrow to carry subfield $subfield (data is $dataPortWidth bits wide, $subfield resides in bits \[$left:$right\]"
            }

            set subfieldArray($subfield,RIGHT) $right
            set subfieldArray($subfield,LEFT)  $left
        }
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | Check that the subfields do not overlap. Insert unused fields between subfields such that data signal is fully
# | populated.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_check_for_overlap {interfaceName parentSubfieldArray parentDataPortWidth parentUnusedList} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentDataPortWidth dataPortWidth
    upvar 1 $parentUnusedList unusedList
    variable valid_message_control_fields

    # Create an array whose key is the base bit of the subfield and whose data is the subfield name
    # Don't add argument to this list - we know it sits at the bottom of the data signal
    set max 0
    foreach subfield [concat $valid_message_control_fields argumentEmpty] {
        set right $subfieldArray($subfield,RIGHT)

        if { $right != -1} {
            # Check that the base bit doesn't already exist in the array - if it does then we have overlap
            if {[info exists baseBitMapping($right)]} {
                send_message Error "Interface $interfaceName: Subfields $subfield and $baseBitMapping($right) overlap."
            } else {
                set baseBitMapping($right) $subfield
                if {$right > $max} {
                    set max $right
                }
            }
        }
    }

    set baseBitList [lsort -integer [array names baseBitMapping] ]

    if {$max < [expr $dataPortWidth - 1] } {
        lappend baseBitList $dataPortWidth
        set baseBitMapping($dataPortWidth) end
    }

    # We know argument is at the bottom of the list, so preinitialise the data structures to reflect this.
    # If argument is not present, this should still work as argument LEFT is preinitialised to -1.
    set lastMSB $subfieldArray(argument,LEFT)
    set lastSubfield argument

    set unusedFieldNum 0
    set unusedList {}
    foreach baseBit $baseBitList {
        set subfield $baseBitMapping($baseBit)

        if {$baseBit <= $lastMSB} {
            if {$subfield != "end"} {   # This check is needed to prevent the "end" subfield from being displayed if the data port is too narrow
                send_message Error "Interface $interfaceName: Subfields $subfield and $lastSubfield overlap."
            }
        } elseif {$baseBit != [expr $lastMSB + 1]} {
            set subfieldArray(unused$unusedFieldNum,RIGHT) [expr $lastMSB + 1]
            set subfieldArray(unused$unusedFieldNum,LEFT)  [expr $baseBit - 1]
            set subfieldArray(unused$unusedFieldNum,SYMBOL_WIDTH)  [expr $baseBit - $lastMSB - 1]
            set subfieldArray(unused$unusedFieldNum,SYMBOLS_PER_BEAT)  1
            set subfieldArray(unused$unusedFieldNum,HDL_PORT)  ""
            set subfieldArray(unused$unusedFieldNum,DEFAULT) 0
            set subfieldArray(unused$unusedFieldNum,UNUSED) true
            set subfieldArray(unused$unusedFieldNum,ZEROED) false
            lappend unusedList unused$unusedFieldNum
            incr unusedFieldNum
        }

        if {$subfield != "end"} {
            set lastMSB $subfieldArray($subfield,LEFT)
            set lastSubfield $subfield
        }
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | Determines whether or not to create a fragment list port property for this interface. A fragment list is required
# | if all subfields have an HDL port defined. It is not required if all subfields do not have an HDL port defined.
# | It is an error for some subfields have an HDL port when others do not.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_requires_fragment_list {interfaceName parentSubfieldArray parentUnusedList} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentUnusedList unusedList
    variable valid_message_control_fields

    foreach subfield [concat $valid_message_control_fields argument argumentEmpty] {
        set hdlPort $subfieldArray($subfield,HDL_PORT)

        if {$hdlPort != ""} {
            # This TCL package cannot terminate the argument HDL port if the arguemnt width is zero.
            # This is because there is no way to indicate the width of the HDL port.
            # All other subfields can be disabled by setting there BASE to -1, and always set their
            # width to that of the HDL port.
            set argumentWidth $subfieldArray(argument,SYMBOL_WIDTH)
            set argumentHDL   $subfieldArray(argument,HDL_PORT)
            if {($argumentWidth == 0) && ($argumentHDL != "")} {
                send_message warning "Interface $interfaceName: Unable to terminate argument HDL port $argumentHDL as argument symbol width is zero. This port will not be driven."
            }

            return 1
        }
    }

    return 0
}



# +--------------------------------------------------------------------------------------------------------------------
# | Set the fragment list port property on the data port
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_set_fragment_list {interfaceName parentSubfieldArray parentDataPort parentUnusedList} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentDataPort dataPort
    upvar 1 $parentUnusedList unusedList
    variable valid_message_control_fields

    # Create an array whose key is the base bit of the subfield and whose data is the subfield name
    foreach subfield [concat $unusedList $valid_message_control_fields argument argumentEmpty] {
        set right $subfieldArray($subfield,RIGHT)
        if { $right != -1} {
            set baseBitMapping($right) $subfield
        }
    }


    # Walk through each subfield in decreasing order of base bit, such that we process the most significant first,
    # and append the hdl port to the fragment list string
    set baseBitList [lsort -integer -decreasing [array names baseBitMapping] ]
    set fragmentListString ""
    foreach baseBit $baseBitList {
        set subfield $baseBitMapping($baseBit)
        set hdlPort $subfieldArray($subfield,HDL_PORT)
        set zeroed $subfieldArray($subfield,ZEROED)

        if { $hdlPort == "" } {
            error "Interface $interfaceName unexpected error - no port name found for subfield $subfield"
        }

        if {$zeroed == "false"} {
            set width $subfieldArray($subfield,SYMBOL_WIDTH)

            # If the HDL port does not include the bit range syntax @msb:lsb, then it must be added
            if {[string match "*@*" $hdlPort] == 0} {
                if {$subfield == "argument"} {
                    set symbolsPerBeat $subfieldArray(argument,SYMBOLS_PER_BEAT)
                    set width [expr $width * $symbolsPerBeat]
                }
                set msb [expr $width - 1]

                set hdlPort "$hdlPort@$msb:0"
            } else {
                # Check that the HDL port string is of the form name@msb:lsb, and that the bit range matches the subfield width
                if { [regexp {^[0-9a-zA-Z_]+@([0-9]+):([0-9]+)$} $hdlPort dummy msb lsb] == 0} {
                    error "Interface $interfaceName: Syntax error in HDL port for subfield $subfield: $hdlPort"
                }

                set sliceWidth [expr $msb - $lsb + 1]
                if {$width != $sliceWidth} {
                    send_message error "Interface $interfaceName: HDL port slice $hdlPort has different width to associated subfield $subfield ($width)"
                }
            }
        }


        append fragmentListString "$hdlPort "
    }

    set_port_property $dataPort FRAGMENT_LIST $fragmentListString
}



# +--------------------------------------------------------------------------------------------------------------------
# | For message sources that use fragment list to construct their data port, any unused or unbound fields in the data
# | port must be driven to zero. Unused fields are not specified by the user and have the UNUSED subfield property set.
# | Unbound subfields exist in the data but have no HDL ports assigned.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_drive_unused_and_unbound_fragments {interfaceName parentSubfieldArray parentUnusedList} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentUnusedList unusedList
    variable valid_message_control_fields

    set zeroPort [get_message_property $interfaceName ZERO_OUTPUT_PORT]

    set usedZeroPort 0
    foreach subfield [concat $unusedList $valid_message_control_fields argument argumentEmpty] {
        set right   $subfieldArray($subfield,RIGHT)

        if { $right != -1 } {
            set hdlPort $subfieldArray($subfield,HDL_PORT)
            if {$hdlPort == ""} {
                set left $subfieldArray($subfield,LEFT)
                set width [expr $left - $right + 1]

                # At present, there is no way to drive zero into a fragment list appart from
                # by taking an output from the HDL. We require an output that drives zero to be
                # present on the HDL module for message sources.
                if {$zeroPort == ""} {
                    error "Interface $interfaceName requires subfield $subfield which is not provided by the HDL. The ZERO_OUTPUT_PORT property should be set to allow unused fields to be driven."
                }

                set frag ""
                for {set i 0} {$i < $width} {incr i} {
                    append frag "$zeroPort@0:0 "
                }

                set subfieldArray($subfield,ZEROED) true
                set subfieldArray($subfield,HDL_PORT) $frag
                set usedZeroPort 1
            }
        }
    }

    if {$zeroPort == ""} {
        send_message Warning "Interface $interfaceName: HDL ports have been bound to subfields but the ZERO_OUTPUT_PORT property is not set. This interface will not work if unused subfields are present."
    } elseif {$usedZeroPort == 0} {
        add_interface_port $interfaceName $zeroPort data Output 1
        set_port_property $zeroPort TERMINATION TRUE
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | For message sources that use fragment list to construct their data port, any HDL ports that drive subfields which
# | are not present in the data signal must be terminated.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_terminate_unconnected_ports {interfaceName parentSubfieldArray} {
    upvar 1 $parentSubfieldArray subfieldArray
    variable valid_message_control_fields

    foreach subfield [concat $valid_message_control_fields argument argumentEmpty] {
        set right   $subfieldArray($subfield,RIGHT)
        set width   $subfieldArray($subfield,SYMBOL_WIDTH)

        if { ($right == -1) && ($width != 0) } {
            set hdlPort $subfieldArray($subfield,HDL_PORT)

            if {$hdlPort != ""} {
                if {$subfield == "argument"} {
                    set symbolsPerBeat $subfieldArray(argument,SYMBOLS_PER_BEAT)
                    set width [expr $width * $symbolsPerBeat]
                }

                # Should not terminate ports that consist of bit slices, as the remainder of the port may be used.
                if {[string match "*@*" $hdlPort] == 0} {
                    add_interface_port $interfaceName $hdlPort data Output $width
                    set_port_property $hdlPort TERMINATION TRUE
                }
            }
        }
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | For message sinks that use fragment list to construct their data port, any unused or unbound fields in the data
# | port must be left unconnected. Unused fields are not specified by the user and have the UNUSED subfield property set.
# | Unbound subfields exist in the data but have no HDL ports assigned.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_terminate_unused_and_unbound_fragments {interfaceName parentSubfieldArray parentUnusedList} {
    upvar 1 $parentSubfieldArray subfieldArray
    upvar 1 $parentUnusedList unusedList
    variable valid_message_control_fields

    set unusedPort [get_message_property $interfaceName UNUSED_INPUT_PORT]
    set unusedPortWidthParam [get_message_property $interfaceName UNUSED_INPUT_WIDTH_PARAM]
    set unusedPortWidth 0

    foreach subfield [concat $unusedList $valid_message_control_fields argument argumentEmpty] {
        set right   $subfieldArray($subfield,RIGHT)

        if { $right != -1 } {
            set hdlPort $subfieldArray($subfield,HDL_PORT)
            if {$hdlPort == ""} {
                set left $subfieldArray($subfield,LEFT)
                set width [expr $left - $right + 1]

                # At present, there is no way to terminate unused fields in the fragment list appart from
                # by wiring to an unused input on the HDL module. We require an unused input with
                # parameterisable width to be present on the HDL module for message sinks.
                if {($unusedPort == "") || ($unusedPortWidthParam == "")} {
                    error "Interface $interfaceName requires subfield $subfield which is not provided by the HDL. The UNUSED_INPUT_PORT and UNUSED_INPUT_WIDTH_PARAM property should be set to allow unused fields to be terminated."
                }

                set subfieldArray($subfield,HDL_PORT) "$unusedPort@[expr $unusedPortWidth + $width - 1]:$unusedPortWidth"
                set unusedPortWidth [expr $unusedPortWidth + $width]
            }
        }
    }

    if {($unusedPort == "") || ($unusedPortWidthParam == "")} {
        send_message Warning "Interface $interfaceName: HDL ports have been bound to subfields but the UNUSED_INPUT_PORT property is not set. This interface will not work if unused subfields are present."
    } else {
        if {[lsearch -exact [get_parameters] $unusedPortWidthParam] == -1} {
            error "Interface $interfaceName: UNUSED_INPUT_WIDTH_PARAM $unusedPortWidthParam - parameter does not exist."
        }

        set derived [get_parameter_property $unusedPortWidthParam DERIVED]
        if {!$derived} {
            error "Interface $interfaceName: UNUSED_INPUT_WIDTH_PARAM $unusedPortWidthParam - parameter is not marked as DERIVED."
        }

        set affectsElab [get_parameter_property $unusedPortWidthParam AFFECTS_ELABORATION]
        if {!$affectsElab} {
            error "Interface $interfaceName: UNUSED_INPUT_WIDTH_PARAM $unusedPortWidthParam - parameter is not marked as AFFECTS_ELABORATION."
        }

        set hdlParam [get_parameter_property $unusedPortWidthParam HDL_PARAMETER]
        if {!$hdlParam} {
            error "Interface $interfaceName: UNUSED_INPUT_WIDTH_PARAM $unusedPortWidthParam - parameter is not marked as HDL_PARAMETER."
        }


        if {$unusedPortWidth == 0} {
            set unusedPortWidth 1
            add_interface_port $interfaceName $unusedPort data Input 1
            set_port_property $unusedPort TERMINATION TRUE
            set_port_property $unusedPort TERMINATION_VALUE 0
        }

        set_parameter_value $unusedPortWidthParam $unusedPortWidth

    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | For message sinks that use fragment list to construct their data port, any HDL ports that are driven by subfields
# | which are not present in the data signal must be driven by default values.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::_drive_unconnected_ports {interfaceName parentSubfieldArray} {
    upvar 1 $parentSubfieldArray subfieldArray
    variable valid_message_control_fields

    foreach subfield [concat $valid_message_control_fields argument argumentEmpty] {
        set right   $subfieldArray($subfield,RIGHT)
        set width   $subfieldArray($subfield,SYMBOL_WIDTH)

        if { ($right == -1) && ($width != 0) } {
            set hdlPort $subfieldArray($subfield,HDL_PORT)

            if {$hdlPort != ""} {
                if {$subfield == "argument"} {
                    set symbolsPerBeat $subfieldArray(argument,SYMBOLS_PER_BEAT)
                    set width [expr $width * $symbolsPerBeat]
                }

                # Should not terminate ports that consist of bit slices, as the remainder of the port may be used.
                if {[string match "*@*" $hdlPort] == 0} {
                    set value $subfieldArray($subfield,DEFAULT)

                    add_interface_port $interfaceName $hdlPort data Input $width
                    set_port_property $hdlPort TERMINATION TRUE
                    set_port_property $hdlPort TERMINATION_VALUE $value
                }
            }
        }
    }
}



# +--------------------------------------------------------------------------------------------------------------------
# | This proceedure is used to actually validate the construction of the specified interface and to perform any
# | construction actions which need to be performed, such as the generation of the FRAGMENT_LIST. This proceedure
# | should be called after all calls to set_message_property, set_message_subfield_property and
# | set_message_subfield_hdl_port for the specified interface.
# +--------------------------------------------------------------------------------------------------------------------
proc ::altera_pe_message_format::validate_and_create {interfaceName} {
    _validate_interface_ports $interfaceName dataPort dataPortWidth
    _get_data_params $interfaceName subfieldArray
    _set_data_bit_ranges $interfaceName subfieldArray dataPortWidth
    _check_for_overlap $interfaceName subfieldArray dataPortWidth unusedList

    if {[_requires_fragment_list $interfaceName subfieldArray unusedList]} {
        set dataPortDirection [get_port_property $dataPort DIRECTION]
        if {$dataPortDirection == "Output"} {
            _drive_unused_and_unbound_fragments $interfaceName subfieldArray unusedList
            _terminate_unconnected_ports $interfaceName subfieldArray
        } else {
            _terminate_unused_and_unbound_fragments $interfaceName subfieldArray unusedList
            _drive_unconnected_ports $interfaceName subfieldArray
        }

        _set_fragment_list $interfaceName subfieldArray dataPort unusedList
    }

    _dump_subfield_array subfieldArray

    _mark_as_validated $interfaceName
}
