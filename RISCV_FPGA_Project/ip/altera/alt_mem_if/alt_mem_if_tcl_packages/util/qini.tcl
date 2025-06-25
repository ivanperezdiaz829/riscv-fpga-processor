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


package provide alt_mem_if::util::qini 0.1


namespace eval ::alt_mem_if::util::qini:: {
	namespace export qini_value
	namespace export cfg_is_on
	
	variable qini_vars
    variable commentchar \;
	
}


proc ::alt_mem_if::util::qini::qini_value {key {default {}}} {
	variable qini_vars
	
	if {[info exists qini_vars($key)]} {
		return $qini_vars($key)
	} else {
		return $default
	}
}

proc ::alt_mem_if::util::qini::cfg_is_on {key} {

	set key_value [qini_value $key 0]
	
	if {[regexp -nocase {^[\t\r\n ]*yes[\t\r\n ]*$|^[\t\r\n ]*on[\t\r\n ]*$|^[\t\r\n ]*1[\t\r\n ]*$} $key_value match] == 1} {
		return 1
	} else {
		return 0
	}
}



proc ::alt_mem_if::util::qini::_ini_open {ini {mode r}} {
	
	if { ![regexp {^(w|r)\+?$} $mode] } {
		error "$mode is not a valid access mode"
	}
	
	if {[file exists $ini]} {
		set ini_fh [::open $ini $mode]
		fconfigure $ini_fh -translation crlf
		
	
		if { [string match "r*" $mode] } {
			_loadfile $ini_fh
		}
	
		close $ini_fh
	}
	return
}


proc ::alt_mem_if::util::qini::_loadfile {channel} {
	variable commentchar
	variable qini_vars

	array set data     {}
	array set comments {}
	array set sections {}
	set cur {}
	set com {}

    seek $channel 0 start

	foreach line [split [read $channel] "\n"] {
		if { [string match "$commentchar*" $line] } {
			lappend com [string trim [string range $line [string length $commentchar] end]]
		} elseif { [string match {\[*\]} $line] } {
			set cur [string range $line 1 end-1]
			if { $cur == "" } { continue }
			set sections($cur) 1
			if { $com != "" } {
				set comments($cur) $com
				set com {}
			}
		} elseif { [string match {*=*} $line] } {
			set line [split $line =]
			set key [string trim [lindex $line 0]]
			if { $key == ""} { continue	}
			set value [string trim [join [lrange $line 1 end] =]]

			if { [regexp "^(\".*\")\s+${commentchar}(.*)$" $value -> 1 2] } {
				set value $1
				lappend com $2
			}
			set qini_vars($key) $value
		}
	}
	return
}


proc ::alt_mem_if::util::qini::_init {} {
	if {[file exists "quartus.ini"]} {
		::alt_mem_if::util::qini::_ini_open "quartus.ini"
	}
	if {[info exists ::env(QUARTUS_INI)] == 1} {
		if {[file exists [file join "$::env(QUARTUS_INI)" "quartus.ini"]]} {
			::alt_mem_if::util::qini::_ini_open [file join "$::env(QUARTUS_INI)" "quartus.ini"]
		}
	}
	if {[info exists ::env(USERPROFILE)] == 1} {
		if {[file exists [file join "$::env(USERPROFILE)" "quartus.ini"]]} {
			::alt_mem_if::util::qini::_ini_open [file join "$::env(USERPROFILE)" "quartus.ini"]
		}
	}
	if {[info exists ::env(HOME)] == 1} {
		if {[file exists [file join "$::env(HOME)" "quartus.ini"]]} {
			::alt_mem_if::util::qini::_ini_open [file join "$::env(HOME)" "quartus.ini"]
		}
	}
	if {[info exists ::env(QUARTUS_ROOTDIR)] == 1} {
		if {[file exists [file join "$::env(QUARTUS_ROOTDIR)" "bin" "quartus.ini"]]} {
			::alt_mem_if::util::qini::_ini_open [file join "$::env(QUARTUS_ROOTDIR)" "bin" "quartus.ini"]
		}
	}

	if {[info exists ::env(TMP)] == 1} {
		if {[file exists [file join "$::env(TMP)" "regtest.ini"]]} {
			::alt_mem_if::util::qini::_ini_open [file join "$::env(TMP)" "regtest.ini"]
		}
	}
	return
}


::alt_mem_if::util::qini::_init
