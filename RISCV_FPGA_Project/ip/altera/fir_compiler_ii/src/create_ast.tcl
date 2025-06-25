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


# High Performance FIR Avalon-ST Wrapper Generation

set module_dir [lindex $argv 0]
set outdir [lindex $argv 1]
set outname [lindex $argv 2]
set extension [lindex $argv 3]
set readfile_name ${module_dir}/ast_components/hpfir_ast_temp${extension}
set writefile_name ${outdir}${outname}_ast$extension
set entity_name [lindex $argv 4]
set InWidth [lindex $argv 5]
set PhysChanIn [lindex $argv 6].0
set Read_Write_Mode [lindex $argv 7]
set FullWidth [lindex $argv 8]
set PhysChanOut [lindex $argv 9].0
set NumChans [lindex $argv 10]
set DeviceFamily [lindex $argv 11]
set useClkEnable [lindex $argv 12]
set ChansPerPhyIn [lindex $argv 13]
set ChansPerPhyOut [lindex $argv 14]
set latency [lindex $argv 15]
set busDataWidth [lindex $argv 16]
set outputfifodepth [lindex $argv 17]
set bankcount [lindex $argv 18]
set bankInWidth [lindex $argv 19]
set OutMsbRoundType [lindex $argv 20]
set OutMsbRoundBit [lindex $argv 21]
set OutLsbRoundType [lindex $argv 22]
set OutLsbRoundBit [lindex $argv 23]

global busDataWidth_msb
set busDataWidth_msb [expr $busDataWidth - 1]

if {$ChansPerPhyOut > 1} {
    set use_packets 1
} else {
    set use_packets 0
}

# FIFO(s) will be included in the Source wrapper when backpressure is enabled
# To catch the extra cycles of data after FIR is disabled 
# The outputfifodepth value from dspba will be used to determine the Source FIFO depth
# The source wrapper is instantiating a standard Altera Avalon SC FIFO which 
# requires the FIFO_DEPTH to be power of 2 (ie. 2, 8, 16, 32, 64). 
# The FIFO will behave unexpectedly for any value other than power of 2. 
# The algorithm here is basically push the outputfifodepth value to be power of 2.
# ie. if latency=10, it will push to 16
# ie. if latency=30, it will push to 32

# Increase FIFO depth by 2 due to FIFO latency (actual FIFO size = FIFO depth - 2)
set outputfifodepth [expr $outputfifodepth + 2]

set log2_outputfifodepth [expr double(log($outputfifodepth))/log(2)]
if {$log2_outputfifodepth > 1} {
    set log2_outputfifodepth [expr int([expr ceil($log2_outputfifodepth)])]
} else {
    set log2_outputfifodepth 1
}
set antilog2_outputfifodepth [expr int([expr exp($log2_outputfifodepth * log(2))])]

set PhysChanIn [expr int($PhysChanIn)]
set PhysChanOut [expr int($PhysChanOut)]

if { [ catch { set in [ open ${readfile_name} r ] } err ] } {
    #send_message "error" "$err"
    puts "$err"
    return
}

if { [ catch { set out [ open ${writefile_name} w ] } err ] } {
    send_message "error" "$err"
    return
}

proc print_bus_port {out Read_Write_Mode} {
        
    global busDataWidth_msb
        
    if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
        puts $out "    busIn_d            : in std_logic_vector($busDataWidth_msb downto 0);"
        puts $out "    busIn_a            : in std_logic_vector(11 downto 0);"
        puts $out "    busIn_w            : in std_logic_vector(0 downto 0);"
        puts $out "    busOut_r           : out std_logic_vector($busDataWidth_msb downto 0);"
        puts $out "    busOut_v           : out std_logic_vector(0 downto 0);"
    } elseif {[string match "Write" $Read_Write_Mode]} {            
        puts $out "    busIn_d            : in std_logic_vector($busDataWidth_msb downto 0);"
        puts $out "    busIn_a            : in std_logic_vector(11 downto 0);"
        puts $out "    busIn_w            : in std_logic_vector(0 downto 0);"
    }
}

while {-1 != [gets $in line]} {
    if {[regexp -nocase "update generic here" $line]} {
        puts $out "  INWIDTH             : integer := $InWidth;"
        puts $out "  FULL_WIDTH          : integer := $FullWidth;"
        puts $out "  BANKINWIDTH         : integer := $bankInWidth;"
        puts $out "  REM_LSB_BIT_g       : integer := $OutLsbRoundBit;"
        puts $out "  REM_LSB_TYPE_g      : string := \"$OutLsbRoundType\";"
        puts $out "  REM_MSB_BIT_g       : integer := $OutMsbRoundBit;"
        puts $out "  REM_MSB_TYPE_g      : string := \"$OutMsbRoundType\";"
        puts $out "  PHYSCHANIN          : integer := $PhysChanIn;"
        puts $out "  PHYSCHANOUT         : integer := $PhysChanOut;"
        puts $out "  CHANSPERPHYIN       : natural := $ChansPerPhyIn;"
        puts $out "  CHANSPERPHYOUT      : natural := $ChansPerPhyOut;"
        puts $out "  OUTPUTFIFODEPTH     : integer := $antilog2_outputfifodepth;"
        puts $out "  USE_PACKETS         : integer := $use_packets;"
        puts $out "  ENABLE_BACKPRESSURE : boolean := $useClkEnable;"
        puts $out "  LOG2_CHANSPERPHYOUT : natural := log2_ceil_one($ChansPerPhyOut);"
        puts $out "  NUMCHANS            : integer := $NumChans;"
        puts $out "  DEVICE_FAMILY       : string := \"$DeviceFamily\""
    } elseif {[regexp -nocase "update bus port here" $line]} {
        if {$Read_Write_Mode != "none"} {
            puts $out "    bus_clk            : in std_logic;"
            puts $out "    h_areset           : in std_logic;"
            print_bus_port $out $Read_Write_Mode
        }
    } elseif {[regexp -nocase "update component here" $line]} {
        puts $out "component ${entity_name} is"
        puts $out "  port ("
        puts $out "    xIn_v              : in std_logic_vector(0 downto 0);"
        puts $out "    xIn_c              : in std_logic_vector(7 downto 0);"
        for {set i 0} {$i < $PhysChanIn} {incr i} {
            puts $out "    xIn_$i              : in std_logic_vector($InWidth - 1 downto 0);"
        }
        if {$bankcount > 1} {
          for {set i 0} {$i < $PhysChanIn} {incr i} {
            puts $out "    bankIn_$i           : in std_logic_vector($bankInWidth - 1 downto 0);"
          }
        }
        print_bus_port $out $Read_Write_Mode
        if {$useClkEnable == "true"} {
            puts $out "    enable_i           : in std_logic_vector(0 downto 0);"    
        }
        puts $out "    xOut_v             : out std_logic_vector(0 downto 0);"
        puts $out "    xOut_c             : out std_logic_vector(7 downto 0);"
        for {set j 0} {$j < $PhysChanOut} {incr j} {
            puts $out "    xOut_$j             : out std_logic_vector($FullWidth - 1 downto 0);"
        }
        if {$Read_Write_Mode != "none"} {
            puts $out "    bus_clk            : in std_logic;"
            puts $out "    h_areset           : in std_logic;"
        }
        puts $out "    clk                : in std_logic;"
        puts $out "    areset             : in std_logic"
        puts $out ");"
        puts $out "end component ${entity_name};"
    } elseif {[regexp -nocase "update instantiation here" $line]} {
        puts $out "hpfircore: ${entity_name}"
        puts $out "   port map ("
        puts $out "     xIn_v     => data_valid,"
        puts $out "     xIn_c     => \"00000000\","
        for {set i 0} {$i < $PhysChanIn} {incr i} {
            puts $out "     xIn_$i     => data_in(($bankInWidth + $InWidth) * $i + $InWidth - 1 downto ($bankInWidth + $InWidth) * $i),"
        }
        if {$bankcount > 1} {
          for {set i 0} {$i < $PhysChanIn} {incr i} {
            puts $out "     bankIn_$i  => data_in(($bankInWidth + $InWidth) * $i + ($bankInWidth + $InWidth) - 1 downto ($bankInWidth + $InWidth) * $i + $InWidth),"
          }
        }
        puts $out "     xOut_v    => core_out_valid,"
        puts $out "     xOut_c    => core_out_channel,"
        for {set j 0} {$j < $PhysChanOut} {incr j} {
            puts $out "     xOut_$j   => core_out($FullWidth * $j + $FullWidth - 1 downto $FullWidth * $j),"
        }
        if {$useClkEnable == "true"} {
            puts $out "     enable_i  => enable_in,"
        }
        if {$Read_Write_Mode != "none"} {
            if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
                puts $out "     busIn_d   => busIn_d,"
                puts $out "     busIn_a   => busIn_a,"
                puts $out "     busIn_w   => busIn_w,"
                puts $out "     busOut_r  => busOut_r,"
                puts $out "     busOut_v  => busOut_v,"
            } elseif {[string match "Write" $Read_Write_Mode]} {
                puts $out "     busIn_d   => busIn_d,"
                puts $out "     busIn_a   => busIn_a,"
                puts $out "     busIn_w   => busIn_w,"
            }
            puts $out "     bus_clk   => bus_clk,"
            puts $out "     h_areset  => h_areset,"
        }
        puts $out "     clk       => clk,"
        puts $out "     areset    => reset_fir"
        puts $out "   );"
    } else {
        if {[regexp -nocase "hpfir_ast" $line]} {
            regsub -nocase "hpfir_ast" $line "${outname}_ast" line
        } 
        puts $out $line
    }
}
close $out
close $in

