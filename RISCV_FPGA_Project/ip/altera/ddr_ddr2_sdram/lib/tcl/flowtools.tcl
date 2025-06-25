##Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
##use of Altera Corporation's design tools, logic functions and other
##software and tools, and its AMPP partner logic functions, and any
##output files any of the foregoing (including device programming or
##simulation files), and any associated documentation or information are
##expressly subject to the terms and conditions of the Altera Program
##License Subscription Agreement or other applicable license agreement,
##including, without limitation, that your use is for the sole purpose
##of programming logic devices manufactured by Altera and sold by Altera
##or its authorized distributors. Please refer to the applicable
##agreement for further details. 








package provide ::ddr::flowtools 0.1

package require ::quartus::flow

package require crc32

namespace eval ::ddr::flowtools { 
namespace export open_qar_cached













proc open_qar_cached { qar cachedir} {
set qarpath [file join [pwd] $qar]
if { ! [ file exists $qarpath ] } { error "qar $qar doesn't exist at $qarpath" } 
set qarcsum [::crc::crc32 -filename $qarpath]
set projdir [file join $cachedir "[file rootname [file tail $qar]]-$qarcsum" ]
if { ! [file exists $projdir] } {
file mkdir $projdir
}
if { [is_project_open ] } { 
puts "::ddr::flowtools::open_qar_cached: Closing project"
project_close
}
cd $projdir
set needscompile 0
if { ! [file exists compileok] } {
puts "compileok not present, will recompile"
set needscompile 1
if { [llength [glob -nocomplain -- *.qpf]] == 0 } {
puts "Extracting from QAR $qarpath"
project_restore $qarpath
}
} else {
set compiledat [file mtime compileok]
foreach f [glob -nocomplain -- *.v*] {
if { ! [file isfile $f] } { continue } ;
set lmd [file mtime $f]
if { [expr { $lmd > $compiledat } ] } {
puts "File $f modified after compiledat ($lmd > $compiledat), will recompile"
set needscompile 1
}
}
}
set projfiles [glob -nocomplain -- *.qpf]
if { [llength $projfiles] != 1 } { error "Must have exactly one .qpf file in [pwd] (got $projfiles)" }
project_open [lindex $projfiles 0]

if { $needscompile } {
puts "Compiling..."
execute_flow -compile
puts "Compile done"
set f [open compileok w]
puts $f "ok"
close $f
}
}
}
