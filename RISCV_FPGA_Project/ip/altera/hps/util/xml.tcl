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


namespace eval xml {
    namespace eval writer {
	# import funset
	source [file join $env(QUARTUS_ROOTDIR) .. ip altera hps util procedures.tcl]
	
	variable element_count 0
	variable element_names
	variable element_attributes
	variable element_attribute_values
	variable element_children
	variable element_value
	proc create_element {name} {
	    variable element_count
	    variable element_names
	    variable element_attributes
	    variable element_children
	    variable element_value
	    
	    set inst $element_count
	    incr element_count
	    
	    set element_names($inst) $name
	    set element_attributes($inst) [list]
	    set element_children($inst) [list]
	    set element_value($inst) ""
	    
	    return $inst	    
	}
	
	# Does not overwrite existing children. Appends even if there's a duplicate
	proc add_child {parent child} {
	    variable element_children
	    
	    lappend element_children($parent) $child
	}
	
	proc element_attribute_key {element attr} {
	    return "${element}_${attr}"
	}
	# Does not overwrite existing attributes. Appends even if there's a duplicate
	proc set_attribute {element attr value} {
	    variable element_attributes
	    variable element_attribute_values
	    
	    lappend element_attributes($element) $attr
	    set element_attribute_key [element_attribute_key $element $attr]
	    set element_attribute_values($element_attribute_key) $value	    
	}
	proc set_value {element value} {
	    variable element_value
	    set element_value($element) $value
	}

	# TODO
	proc xml_escape {value} {
	    return $value 
	}
	proc render_xml_contents {element {indent 0}} {
	    variable element_names
	    variable element_attributes
	    variable element_attribute_values
	    variable element_children
	    variable element_value
	    
	    set name $element_names($element)
	    
	    set spacer [string repeat " " [expr {$indent * 2}]]
	    
	    set contents "${spacer}<${name}"
	    
	    foreach attr $element_attributes($element) {
		set key [element_attribute_key $element $attr]
		set value $element_attribute_values($key)
		set escaped_value [xml_escape $value]
		set contents "${contents} $attr='$escaped_value'"
	    }
	    
	    # Priority: children, value, none
	    if {[llength $element_children($element)] > 0} {
		set contents "${contents}>\n"
		set child_indent [expr {$indent + 1}]
		foreach child $element_children($element) {
		    set child_contents [render_xml_contents $child $child_indent]
		    set contents "${contents}$child_contents"
		}
		set contents "${contents}${spacer}</${name}>\n"
	    } elseif {$element_value($element) != ""} {
		set value $element_value($element)
		set contents "${contents}>$value</${name}>\n"
	    } else {
		set contents "${contents} />\n"
	    }
	    return $contents
	}
	proc cleanup {} {
	    variable element_count 0
	    variable element_names
	    funset   element_names
	    variable element_attributes
	    funset   element_attributes
	    variable element_attribute_values
	    funset   element_attribute_values
	    variable element_children
	    funset   element_children
	    variable element_value
	    funset   element_value
	}
    }
}
