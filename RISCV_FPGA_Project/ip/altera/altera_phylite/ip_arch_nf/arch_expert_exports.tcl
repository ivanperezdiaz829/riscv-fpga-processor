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


package provide altera_phylite::ip_arch_nf::arch_expert_exports 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::enums
package require altera_phylite::ip_arch_nf::pll
package require altera_phylite::ip_arch_nf::main

namespace eval ::altera_phylite::ip_arch_nf::arch_expert_exports:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*

   
}


proc ::altera_phylite::ip_arch_nf::arch_expert_exports::get_legal_pll_ref_clk_freqs_mhz {mem_clk_freq_mhz clk_ratios max_entries} {
   return [altera_phylite::ip_arch_nf::pll::get_legal_pll_ref_clk_freqs_mhz $mem_clk_freq_mhz $clk_ratios $max_entries]
}

proc ::altera_phylite::ip_arch_nf::arch_expert_exports::get_legal_read_latencies {} {
   return [altera_phylite::ip_arch_nf::main::get_legal_read_latencies]
}



proc ::altera_phylite::ip_arch_nf::arch_expert_exports::_init {} {
}

::altera_phylite::ip_arch_nf::arch_expert_exports::_init
