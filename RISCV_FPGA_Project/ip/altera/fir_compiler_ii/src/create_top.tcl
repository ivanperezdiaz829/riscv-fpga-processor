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


# Top Level Wrapper Generation

set outdir [lindex $argv 0]
set outname [lindex $argv 1]
set extension [lindex $argv 2]
set writefile_name ${outdir}${outname}$extension
set InWidth [lindex $argv 3]
set PhysChanIn [lindex $argv 4]
set Read_Write_Mode [lindex $argv 5]
set OutWidth [lindex $argv 6]
set PhysChanOut [lindex $argv 7]
set NumChans [lindex $argv 8]
set ChansPerPhyIn [lindex $argv 9]
set ChansPerPhyOut [lindex $argv 10]
set busDataWidth [lindex $argv 11]
set bankInWidth [lindex $argv 12]
set useClkEnable [lindex $argv 13]

global busDataWidth_msb
set busDataWidth_msb [expr $busDataWidth - 1]

set PhysChanIn [expr int($PhysChanIn)]
set PhysChanOut [expr int($PhysChanOut)]
set Log2_ChansPerPhyOut [expr int([expr ceil([expr log($ChansPerPhyOut)/log(2)])])]
if {$Log2_ChansPerPhyOut < 1} {
    set Log2_ChansPerPhyOut 1
}

if { [ catch { set out [ open $writefile_name w ] } err ] } {
    #send_message "error" "$err"
    puts "$err"
    return
}

proc print_bus_port_vhd {out Read_Write_Mode} {
        
    global busDataWidth_msb
        
    if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
        puts $out "    coeff_in_data : in STD_LOGIC_VECTOR($busDataWidth_msb downto 0);"
        puts $out "    coeff_in_address : in STD_LOGIC_VECTOR(11 downto 0);"
        puts $out "    coeff_in_we : in STD_LOGIC_VECTOR(0 downto 0);"
        puts $out "    coeff_in_read : in STD_LOGIC;"
        puts $out "    coeff_out_data : out STD_LOGIC_VECTOR($busDataWidth_msb downto 0);"
        puts $out "    coeff_out_valid : out STD_LOGIC_VECTOR(0 downto 0);"
    } elseif {[string match "Write" $Read_Write_Mode]} {
        puts $out "    coeff_in_data : in STD_LOGIC_VECTOR($busDataWidth_msb downto 0);"
        puts $out "    coeff_in_address : in STD_LOGIC_VECTOR(11 downto 0);"
        puts $out "    coeff_in_we : in STD_LOGIC_VECTOR(0 downto 0);"
    }
}

proc print_bus_port_verilog {out Read_Write_Mode} {
        
    global busDataWidth_msb
        
    if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
        puts $out "  input \[$busDataWidth_msb:0\] coeff_in_data,"
        puts $out "  input \[11:0\] coeff_in_address,"
        puts $out "  input coeff_in_we,"
        puts $out "  input coeff_in_read,"
        puts $out "  output \[$busDataWidth_msb:0\] coeff_out_data,"
        puts $out "  output coeff_out_valid,"
    } elseif {[string match "Write" $Read_Write_Mode]} {
        puts $out "  input \[$busDataWidth_msb:0\] coeff_in_data,"
        puts $out "  input \[11:0\] coeff_in_address,"
        puts $out "  input coeff_in_we,"
    }
}

proc print_vhd_port {out InWidth PhysChanIn OutWidth PhysChanOut Log2_ChansPerPhyOut ChansPerPhyIn ChansPerPhyOut}  {
        
    global busDataWidth_msb
        
    puts $out "  port ("
    puts $out "    clk : in STD_LOGIC;"    
    puts $out "    reset_n : in STD_LOGIC;"
    puts $out "    ast_sink_data : in STD_LOGIC_VECTOR( ($bankInWidth + $InWidth) * $PhysChanIn - 1 downto 0);"
    puts $out "    ast_sink_valid : in STD_LOGIC;"
    if {$useClkEnable == "true"} {
        puts $out "    ast_sink_ready : out STD_LOGIC;"
    }
    if {$ChansPerPhyIn > 1} {
        puts $out "    ast_sink_sop : in STD_LOGIC;"
        puts $out "    ast_sink_eop : in STD_LOGIC;"
    }
    puts $out "    ast_sink_error : in STD_LOGIC_VECTOR(1 downto 0);"
    puts $out "    ast_source_data : out STD_LOGIC_VECTOR($OutWidth * $PhysChanOut - 1 downto 0);"
    puts $out "    ast_source_valid : out STD_LOGIC;"
    if {$useClkEnable == "true"} {
        puts $out "    ast_source_ready : in STD_LOGIC;"
    }
    if {$ChansPerPhyOut > 1} {
        puts $out "    ast_source_sop : out STD_LOGIC;"
        puts $out "    ast_source_eop : out STD_LOGIC;"
        puts $out "    ast_source_channel : out STD_LOGIC_VECTOR($Log2_ChansPerPhyOut - 1 downto 0);"
    }
    puts $out "    ast_source_error : out STD_LOGIC_VECTOR(1 downto 0)"
    puts $out "  );"
}

#VHDL
if { [string match ".vhd" $extension] } {
    puts $out "library IEEE;"
    puts $out "use IEEE.std_logic_1164.all;"
    puts $out ""
    puts $out "entity ${outname} is"
    puts $out "  port ("
    puts $out "    clk : in STD_LOGIC;"    
    puts $out "    reset_n : in STD_LOGIC;"
    if { $Read_Write_Mode != "none" } {
        puts $out "    coeff_in_clk : in STD_LOGIC;"
        puts $out "    coeff_in_areset : in STD_LOGIC;"
        print_bus_port_vhd $out $Read_Write_Mode
    }
    puts $out "    ast_sink_data : in STD_LOGIC_VECTOR(($bankInWidth + $InWidth) * $PhysChanIn - 1 downto 0);"
    puts $out "    ast_sink_valid : in STD_LOGIC;"
    if {$useClkEnable == "true"} {
        puts $out "    ast_sink_ready : out STD_LOGIC;"
    }
    if {$ChansPerPhyIn > 1} {
        puts $out "    ast_sink_sop : in STD_LOGIC;"
        puts $out "    ast_sink_eop : in STD_LOGIC;"
    }
    puts $out "    ast_sink_error : in STD_LOGIC_VECTOR(1 downto 0);"
    puts $out "    ast_source_data : out STD_LOGIC_VECTOR($OutWidth * $PhysChanOut - 1 downto 0);"
    puts $out "    ast_source_valid : out STD_LOGIC;"
    if {$useClkEnable == "true"} {
        puts $out "    ast_source_ready : in STD_LOGIC;"
    }
    if {$ChansPerPhyOut > 1} {
        puts $out "    ast_source_sop : out STD_LOGIC;"
        puts $out "    ast_source_eop : out STD_LOGIC;"
        puts $out "    ast_source_channel : out STD_LOGIC_VECTOR($Log2_ChansPerPhyOut - 1 downto 0);"
    }
    puts $out "    ast_source_error : out STD_LOGIC_VECTOR(1 downto 0)"
    puts $out "  );"
    puts $out "end ${outname};"
    puts $out ""

    # Architecture
    puts $out "architecture syn of ${outname} is"
    puts $out "  component ${outname}_ast"
    puts $out "  port ("
    puts $out "    clk : in STD_LOGIC;"    
    puts $out "    reset_n : in STD_LOGIC;"
    if { $Read_Write_Mode != "none" } {
        puts $out "    bus_clk : in std_logic;"
        puts $out "    h_areset :  in std_logic;"
        #print_bus_port_vhd $out $Read_Write_Mode
        if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
            puts $out "    busIn_d          : in std_logic_vector($busDataWidth_msb downto 0);"
            puts $out "    busIn_a          : in std_logic_vector(11 downto 0);"
            puts $out "    busIn_w          : in std_logic_vector(0 downto 0);"
            puts $out "    busOut_r         : out std_logic_vector($busDataWidth_msb downto 0);"
            puts $out "    busOut_v         : out std_logic_vector(0 downto 0);"
        } elseif {[string match "Write" $Read_Write_Mode]} {
            puts $out "    busIn_d          : in std_logic_vector($busDataWidth_msb downto 0);"
            puts $out "    busIn_a          : in std_logic_vector(11 downto 0);"
            puts $out "    busIn_w          : in std_logic_vector(0 downto 0);"
        }
    }
    puts $out "    ast_sink_data : in STD_LOGIC_VECTOR(($bankInWidth + $InWidth) * $PhysChanIn - 1 downto 0);"
    puts $out "    ast_sink_valid : in STD_LOGIC;"
    puts $out "    ast_sink_ready : out STD_LOGIC;"
    puts $out "    ast_sink_sop : in STD_LOGIC;"
    puts $out "    ast_sink_eop : in STD_LOGIC;"
    puts $out "    ast_sink_error : in STD_LOGIC_VECTOR(1 downto 0);"
    puts $out "    ast_source_data : out STD_LOGIC_VECTOR($OutWidth * $PhysChanOut - 1 downto 0);"
    puts $out "    ast_source_ready : in STD_LOGIC;"
    puts $out "    ast_source_valid : out STD_LOGIC;"
    puts $out "    ast_source_sop : out STD_LOGIC;"
    puts $out "    ast_source_eop : out STD_LOGIC;"
    puts $out "    ast_source_channel : out STD_LOGIC_VECTOR($Log2_ChansPerPhyOut - 1 downto 0);"
    puts $out "    ast_source_error : out STD_LOGIC_VECTOR(1 downto 0)"
    puts $out "  );"
    puts $out "end component;"
    puts $out ""
    
    puts $out "begin"
    puts $out "  ${outname}_ast_inst : ${outname}_ast"
    puts $out "  port map ("
    puts $out "    clk => clk,"
    puts $out "    reset_n => reset_n,"
    if { $Read_Write_Mode != "none" } {
        puts $out "    bus_clk => coeff_in_clk,"
        puts $out "    h_areset => coeff_in_areset,"
        if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
            puts $out "    busIn_d   => coeff_in_data,"
            puts $out "    busIn_a   => coeff_in_address,"
            puts $out "    busIn_w   => coeff_in_we,"
            puts $out "    busOut_r  => coeff_out_data,"
            puts $out "    busOut_v  => coeff_out_valid,"        
        } elseif {[string match "Write" $Read_Write_Mode]} {
            puts $out "     busIn_d   => coeff_in_data,"
            puts $out "     busIn_a   => coeff_in_address,"
            puts $out "     busIn_w   => coeff_in_we,"
        }
    }
    puts $out "    ast_sink_data => ast_sink_data,"
    puts $out "    ast_source_data => ast_source_data,"
    puts $out "    ast_sink_valid => ast_sink_valid,"
    if {$useClkEnable == "true"} {
        puts $out "    ast_sink_ready => ast_sink_ready,"
        puts $out "    ast_source_ready => ast_source_ready,"
    } else {
        puts $out "    ast_sink_ready => open,"
        puts $out "    ast_source_ready => '1',"
    }
    puts $out "    ast_source_valid => ast_source_valid,"
    if {$ChansPerPhyIn > 1} {
        puts $out "    ast_sink_sop => ast_sink_sop,"
        puts $out "    ast_sink_eop => ast_sink_eop,"
    } else {
        puts $out "    ast_sink_sop => '0',"
        puts $out "    ast_sink_eop => '0',"
    }
    puts $out "    ast_sink_error => ast_sink_error,"
    if {$ChansPerPhyOut > 1} {
        puts $out "    ast_source_sop => ast_source_sop,"
        puts $out "    ast_source_eop => ast_source_eop,"
        puts $out "    ast_source_channel => ast_source_channel,"
    } else {
        puts $out "    ast_source_sop => open,"
        puts $out "    ast_source_eop => open,"
        puts $out "    ast_source_channel => open,"
    }
    puts $out "    ast_source_error => ast_source_error"
    puts $out "  );"
    puts $out "end syn;"
    close $out
} else {
# Verilog
    puts $out "module $outname ("
    puts $out "  input clk,"
    puts $out "  input reset_n,"
    if { $Read_Write_Mode != "none" } {
        puts $out "  input coeff_in_clk,"
        puts $out "  input coeff_in_areset,"
        print_bus_port_verilog $out $Read_Write_Mode
    }
    puts $out "  input \[($bankInWidth + $InWidth) * $PhysChanIn - 1 : 0\] ast_sink_data,"
    puts $out "  input ast_sink_valid,"
    if {$useClkEnable == "true"} {
        puts $out "  output ast_sink_ready,"
    }
    if {$ChansPerPhyIn > 1} {
        puts $out "  input ast_sink_sop,"
        puts $out "  input ast_sink_eop,"
    }
    puts $out "  input \[1 : 0\] ast_sink_error,"
    puts $out "  output \[$OutWidth * $PhysChanOut - 1 : 0\] ast_source_data,"
    if {$useClkEnable == "true"} {
        puts $out "  input ast_source_ready,"
    }
    puts $out "  output ast_source_valid,"
    if {$ChansPerPhyOut > 1} {
        puts $out "  output ast_source_sop,"
        puts $out "  output ast_source_eop,"
        puts $out "  output \[$Log2_ChansPerPhyOut - 1 : 0\] ast_source_channel,"
    }
    puts $out "  output \[1 : 0\] ast_source_error"
    puts $out ");"
    puts $out ""

    puts $out "${outname}_ast ${outname}_ast_inst ("
    puts $out "    .clk (clk),"
    puts $out "    .reset_n (reset_n),"
    if { $Read_Write_Mode != "none" } {
        puts $out "    .bus_clk (coeff_in_clk),"
        puts $out "    .h_areset (coeff_in_areset),"
        if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
            puts $out "    .busIn_d (coeff_in_data),"
            puts $out "    .busIn_a (coeff_in_address),"
            puts $out "    .busIn_w (coeff_in_we),"
            puts $out "    .busOut_r (coeff_out_data),"
            puts $out "    .busOut_v (coeff_out_valid),"        
        } elseif {[string match "Write" $Read_Write_Mode]} {
            puts $out "    .busIn_d (coeff_in_data),"
            puts $out "    .busIn_a (coeff_in_address),"
            puts $out "    .busIn_w (coeff_in_we),"
        }
    }
    puts $out "    .ast_sink_data (ast_sink_data),"
    puts $out "    .ast_source_data (ast_source_data),"
    puts $out "    .ast_sink_valid (ast_sink_valid),"
    if {$useClkEnable == "true"} {
        puts $out "    .ast_sink_ready (ast_sink_ready),"
        puts $out "    .ast_source_ready (ast_source_ready),"
    } else {
        puts $out "    .ast_sink_ready (),"
        puts $out "    .ast_source_ready (),"
    }    
    puts $out "    .ast_source_valid (ast_source_valid),"
    if {$ChansPerPhyIn > 1} {
        puts $out "    .ast_sink_sop (ast_sink_sop),"
        puts $out "    .ast_sink_eop (ast_sink_eop),"
    } else {
        puts $out "    .ast_sink_sop (),"
        puts $out "    .ast_sink_eop (),"
    }
    puts $out "    .ast_sink_error (ast_sink_error),"
    if {$ChansPerPhyOut > 1} {
        puts $out "    .ast_source_sop (ast_source_sop),"
        puts $out "    .ast_source_eop (ast_source_eop),"
        puts $out "    .ast_source_channel (ast_source_channel),"
    } else {
        puts $out "    .ast_source_sop (),"
        puts $out "    .ast_source_eop (),"
        puts $out "    .ast_source_channel (),"
    }
    puts $out "    .ast_source_error (ast_source_error)"
    puts $out "  );"
    puts $out "endmodule"
}
