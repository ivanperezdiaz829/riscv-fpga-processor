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


package provide altera_tcl_testlib 1.0

#----------------------------Message Reporting

set fatalError false
set testFailure false
set passingTest true

set totalTests 0
set passedTests 0


#+-------------------------------------------------
#| Runs the test case with name <testname>.
#|
#| This method attempts to emulate a unit test framework.
#| It creates a brand new system first, calls the setup
#| method defined in your test script and then runs
#| your test, checking for pass or failure after
#| completion
#+-------------------------------------------------
proc run_test { testname } {
    create_system sys
    setup
    eval $testname
    endtest $testname
}

proc endtest { TestName } {
    global passingTest
    global passedTests
    global totalTests

    puts " ------------------------------------------------------------"
    if {$passingTest} { 
	puts "| Test: ${TestName} PASSED"
	set passedTests [ expr $passedTests + 1 ]
    } else {
	puts "| Test: ${TestName} FAILED"
    }
    puts " ------------------------------------------------------------"
    
    set passingTest true
    set totalTests [ expr $totalTests + 1 ]
}

proc printresults { } {
    global fatalError
    global testFailure
    global passedTests
    global totalTests

    if { $fatalError } {
	puts "Results: A fatal error occured, test results may not be valid."
    } 

    if { $testFailure || $fatalError } {
	puts "Results: ($passedTests/$totalTests) Tests Passed"
	[ exit ]
    } else {
	puts "Results: All Tests Passed."
    }
}

proc assert { Condition Message } {
    global passingTest
    global testFailure

    if { ! [ uplevel 1 expr $Condition ] } {
	puts "FAIL: ${Condition}: ${Message}"
	set testFailure true
	set passingTest false
    }
}

proc fatalerror { Condition Message } {
    global fatalError

    if { ! [ uplevel 1 expr $Condition ] } {
	puts "***********************************************************************"
	puts "******************************FATAL ERROR******************************"
	puts "***********************************************************************"
	puts ${Message}
	puts "***********************************************************************"
	puts "******************************FATAL ERROR******************************"
	puts "***********************************************************************"
	puts "****************RESULTS PASSED THIS POINT MAY NOT BE VALID*************"
	set fatalError true
    }
}

#+-------------------------------------------------
# Call this method from within your composed module
# to publish all connections and module parameters
# as debug assignments on the composed module... call within
# compose callback.
#
# Connections will have a value of true and take the form
#
#
# Instances will have a value of true and take the form
#
#
# Parameters will have a value equal to the current param value
# and take the form
#
#
# 
#  -------Assignment----------------------------------------------------  | ----Value-----
#   debug.connections.<connection_name>                                     true
#   debug.instances.<instance_name>                                         true
#   debug.instances.<instance_name>.<parameter_name>                        parameter value
#   debug.instances.<instance_name>.interfaces.<interface_name>                              true
#   debug.instances.<instance_name>.interfaces.<interface_name>.ports.<port_name>            true
#   debug.instances.<instance_name>.interfaces.<interface_name>.ports.<port_name>.width      port width
#   debug.instances.<instance_name>.interfaces.<interface_name>.ports.<port_name>.role       port role
#   debug.instances.<instance_name>.interfaces.<interface_name>.ports.<port_name>.direction  port direction

#+-------------------------------------------------
proc _publish_debug_info {} {
    _publish_connections
    _publish_module_information
}

proc _publish_connections {} {
    set con_list [get_connections]

    foreach connection $con_list {
	set_module_assignment "debug.connections.${connection}" true
    }
}

proc _publish_module_information {} {
    set inst_list [get_instances]

    foreach instance $inst_list {
	set_module_assignment "debug.instances.${instance}" true
	foreach parameter [get_instance_parameters ${instance}] {
	    set param_value  [get_instance_parameter_value ${instance} ${parameter} ]
	    set_module_assignment "debug.instances.${instance}.${parameter}" ${param_value}
	}
	foreach iface [get_instance_interfaces ${instance}] {
	    #set iface_type [get_instance_interface_property ${instance} ${iface} class_name]
	    set_module_assignment "debug.instances.${instance}.interface.${iface}" true

	    foreach port [get_instance_interface_ports ${instance} ${iface}] {
		set port_width [get_instance_port_property ${instance} ${port} WIDTH]
		set port_role  [get_instance_port_property ${instance} ${port} ROLE]
		set port_direction [get_instance_port_property ${instance} ${port} DIRECTION]
		
		set_module_assignment "debug.instances.${instance}.interfaces.${iface}.ports.${port}"
		set_module_assignment "debug.instances.${instance}.interfaces.${iface}.ports.${port}.role" ${port_role}
		set_module_assignment "debug.instances.${instance}.interfaces.${iface}.ports.${port}.width" ${port_width}
		set_module_assignment "debug.instances.${instance}.interfaces.${iface}.ports.${port}.direction" ${port_direction}
	    }
	}
    }
}

# Verify the instance version against the tool-version passed in via the
# Makefile.
proc verify_version { dut } {
  global TOOL_VERSION

  set version [ get_instance_property $dut VERSION ]

  assert {$version == $TOOL_VERSION} "Expected version $TOOL_VERSION (is: $version)"

  endtest {verify_version}
}


#+----------------------------------------------------------
#| Returns the full interface name as expected by the tcl
#| scripting API, i.e. interface clk on module foo is "foo.clk"
#+----------------------------------------------------------
proc get_full_iface_name { module_name iface_name } {
    set full_interface_name "$module_name.$iface_name"
    return $full_interface_name
}

#+----------------------------------------------------------
#| Ensures the given port has the correct role, width and
#| direction.
#+----------------------------------------------------------
proc check_port { module_name iface_name port_name \
             exp_role exp_direction exp_width } {

    set role [ get_instance_interface_port_property $module_name $iface_name $port_name ROLE ]
    assert { { $role == $exp_role } } \
         "should have port $port_name of role $exp_role"

    set width [ get_instance_interface_port_property $module_name $iface_name $port_name WIDTH ]
    assert { [ expr $exp_width == $width ] } \
        "incorrect width: expected $exp_width but was $width"

    set direction [ get_instance_interface_port_property $module_name $iface_name $port_name DIRECTION ]
    assert { { $exp_direction == $direction } } \
        "incorrect direction: expected $exp_direction but was $direction"
}

# create_dut
# 
# Make a named instance and return it.
#
# Example:
# 
# set dut [ create_dut altera_merlin_burst_adapter inst_name ]
#
proc create_dut {class_name instance_name} {
  add_instance $instance_name $class_name
  set module_list [ get_instances ]

  assert {[ llength $module_list ] == 1} "failed to create module of type $class_name, instance_name $instance_name"

  set dut [ lindex $module_list 0 ]
  set the_class_name [ get_instance_property $dut {class_name} ]
  assert { [ string compare $the_class_name $class_name ] == 0 } "module class_name is $the_class_name, expected $class_name"

  endtest {create_dut}
  return $dut
}

# verify_interfaces
# Verifies a module's interface
#
# verify_interfaces $dut $exp
# dut is a module
# exp is a list of <interface_name, interface_type> pairs.
#
# Example
#  set dut [ create_dut altera_merlin_burst_adapter inst_name ]
#  set exp [ list cr0 clock_sink sink0 avalon_streaming_sink ]
#  verify_interfaces $dut $exp
#
proc verify_interfaces { dut exp } {

  # Create a hash from the list of <interface name>, <interface type> pairs.
  array set expect $exp
  
  # Create another hash from the actual interface names and their types.
  set actual_list [ list ]
  set interfaces [ get_instance_interfaces $dut ]
  foreach interface $interfaces {
    lappend actual_list $interface
    set actual_type [ get_instance_interface_property $dut $interface class_name ]
    lappend actual_list $actual_type
  }
  array set actual $actual_list

  # Print the expected and actual data, to assist debugging.
  puts "expected interfaces:"
  foreach interface [ array names expect ] {
    puts "  $interface (type: $expect($interface))"
  }
  puts "actual interfaces:"
  foreach interface [ array names actual ] {
    puts "  $interface (type: $actual($interface))"
  }

  # Check actual vs. expected interface types.
  foreach interface [ array names actual ] {
    assert { [ info exists expect($interface) ] } "can't find actual interface '$interface' in expect array"

    set expect_type $expect($interface)
    set actual_type $actual($interface)
    assert {0 == [ string compare $actual_type $expect_type ] } "Interface mismatch; expected: $expect_type; actual: $actual_type"
  }

  # Now compare the number of actual and expected interfaces, to catch cases
  # where an "actual" interface simply doesn't exist.
  set actual_interface_count [ llength [ array names actual ]]
  set expect_interface_count [ llength [ array names expect ]]
  assert { $expect_interface_count == $actual_interface_count } "mismatch: expected number of interfaces: $expect_interface_count; actual number of interfaces: $actual_interface_count"

  endtest {verify_interfaces}
}


