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







package provide ::ddr::pcinterface 0.1 


namespace eval ::ddr::pcinterface {
namespace export sentinel
namespace export report_msg

proc report_msg { sever str } {
global post_summary_id

::ddr::legacy::set_postcompile_summary_tags
		##nagelfar variable note_tag
		##nagelfar variable cwarning_tag
		##nagelfar variable warning_tag
		##nagelfar variable error_tag
		##nagelfar variable extrainfo_tag
switch -- $sever {
note     { set tag $note_tag }
cwarning    { set tag $cwarning_tag}
warning     { set tag $warning_tag}
error		{ set tag $error_tag } 
extrainfo   { set tag $extrainfo_tag}
default     { set tag $note_tag}
}
puts $post_summary_id "$tag $str"
}


proc sentinel { d } {
return "pcinterface$d"
}
}
