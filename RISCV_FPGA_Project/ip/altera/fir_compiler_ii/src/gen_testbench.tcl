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


# (C) 2001-2009 Altera Corporation. All rights reserved.
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


# Create VHDL testbench

#Parameters
set out_dir [lindex $argv 0]
set component_name [lindex $argv 1]
set ver [lindex $argv 2]

set PHYSCHANIN_c [lindex $argv 3]
set PHYSCHANOUT_c [lindex $argv 4]
set CHANSPERPHYIN_c  [lindex $argv 5]
set CHANSPERPHYOUT_c [lindex $argv 6]
set INWIDTH_c [lindex $argv 7] 
set OUTWIDTH_c [lindex $argv 8] 
set NUM_OF_CHANNELS_c [lindex $argv 9]
set LOG2_CHANSPERPHYOUT_c [lindex $argv 10]
set NUM_OF_TAPS_c [lindex $argv 11]
set Read_Write_Mode [lindex $argv 12]
set clockRate [lindex $argv 13]
set inRate [lindex $argv 14]
set interpN [lindex $argv 15]
set coeffReload [lindex $argv 16]
set baseAddr [lindex $argv 17]
set coeff_bit_width [lindex $argv 18]
set busDataWidth [lindex $argv 19]
set bankcount [lindex $argv 20]
set BANKINWIDTH_c [lindex $argv 21]
set symmetry_type [lindex $argv 22]
set useClkEnable [lindex $argv 23]

set TDM_FACTOR_c [expr int([expr ceil([expr double($clockRate) / $inRate])])]
set INVERSE_TDM_FACTOR_c [expr int([expr ceil([expr double($inRate) / $clockRate])])]
set INVALID_CYCLES_c [expr ($TDM_FACTOR_c > $NUM_OF_CHANNELS_c) ? [expr [expr int([expr ceil([expr double($TDM_FACTOR_c) / $PHYSCHANIN_c])])] - $CHANSPERPHYIN_c] : [expr ($TDM_FACTOR_c - $CHANSPERPHYIN_c)] ]
set INTERP_SUPER_SAMPLE_c [expr ($inRate > $clockRate) ? $interpN : 1 ]

if {$symmetry_type == "sym" || $symmetry_type == "asym"} {
    set total_eff_coeff [expr int([expr ceil ( [ expr double($NUM_OF_TAPS_c) / 2 ] )]) * $bankcount]
} else {
    set total_eff_coeff [expr $NUM_OF_TAPS_c * $bankcount]
}

set file_name "${out_dir}${component_name}_tb.vhd"

if { [ catch { set out_file [ open $file_name w ] } err ] } {
    send_message "error" "$err"
    return
}

    puts $out_file "-- ================================================================================"
    puts $out_file "-- Legal Notice: Copyright (C) 1991-2009 Altera Corporation"                        
    puts $out_file "-- Any megafunction design, and related net list (encrypted or decrypted),"         
    puts $out_file "-- support information, device programming or simulation file, and any other"       
    puts $out_file "-- associated documentation or information provided by Altera or a partner"         
    puts $out_file "-- under Altera's Megafunction Partnership Program may be used only to"             
    puts $out_file "-- program PLD devices (but not masked PLD devices) from Altera.  Any other"        
    puts $out_file "-- use of such megafunction design, net list, support information, device"          
    puts $out_file "-- programming or simulation file, or any other related documentation or"           
    puts $out_file "-- information is prohibited for any other purpose, including, but not"             
    puts $out_file "-- limited to modification, reverse engineering, de-compiling, or use with"         
    puts $out_file "-- any other silicon devices, unless such use is explicitly licensed under"         
    puts $out_file "-- a separate agreement with Altera or a megafunction partner.  Title to"           
    puts $out_file "-- the intellectual property, including patents, copyrights, trademarks,"           
    puts $out_file "-- trade secrets, or maskworks, embodied in any such megafunction design,"          
    puts $out_file "-- net list, support information, device programming or simulation file, or"        
    puts $out_file "-- any other related documentation or information provided by Altera or a"          
    puts $out_file "-- megafunction partner, remains with Altera, the megafunction partner, or"         
    puts $out_file "-- their respective licensors.  No other licenses, including any licenses"          
    puts $out_file "-- needed under any third party's intellectual property, are provided herein."      
    puts $out_file "-- ================================================================================"
    puts $out_file "--"                                                                                 
    puts $out_file ""
    
    puts $out_file "-- Generated by: FIR Compiler II $ver"
    puts $out_file "-- Generated on: [clock format [clock seconds] -format "%m/%d/%Y %H:%M:%S"]"
    puts $out_file ""
    
    puts $out_file "library ieee;"
    puts $out_file "use ieee.std_logic_1164.all;"
    puts $out_file "use ieee.numeric_std.all;"
    puts $out_file "use std.textio.all;"
    puts $out_file ""
    
    puts $out_file "entity ${component_name}_tb is"
    puts $out_file ""
    
    puts $out_file "--START MEGAWIZARD INSERT CONSTANTS"
    puts $out_file ""
    
    puts $out_file "  constant FIR_INPUT_FILE_c         : string := \"${component_name}_input.txt\";"
    puts $out_file "  constant FIR_OUTPUT_FILE_c        : string := \"${component_name}_output.txt\";"

if {$coeffReload == "true" && ([string match "Read/Write" $Read_Write_Mode] || [string match "Write" $Read_Write_Mode]) } {
    puts $out_file "  constant COEF_RELOAD_FILE_c       : string := \"${component_name}_coef_reload_rtl.txt\";"
    puts $out_file "  constant BASE_ADDRESS_c           : natural := $baseAddr;"
}

    puts $out_file "  constant PHYSCHANIN_c             : natural := $PHYSCHANIN_c;"
    puts $out_file "  constant PHYSCHANOUT_c            : natural := $PHYSCHANOUT_c;"
    puts $out_file "  constant INWIDTH_c                : natural := $INWIDTH_c;"
    puts $out_file "  constant OUTWIDTH_c               : natural := $OUTWIDTH_c;"
    puts $out_file "  constant BANKINWIDTH_c            : natural := $BANKINWIDTH_c;"
    puts $out_file "  constant BANKCOUNT_c              : natural := $bankcount;"
    puts $out_file "  constant DATA_WIDTH_c             : natural := (INWIDTH_c+BANKINWIDTH_c) * PHYSCHANIN_c;"
    puts $out_file "  constant OUT_WIDTH_c              : natural := OUTWIDTH_c * PHYSCHANOUT_c;"
    puts $out_file "  constant NUM_OF_CHANNELS_c        : natural := $NUM_OF_CHANNELS_c;"
    puts $out_file "  constant CHANSPERPHYIN_c          : natural := $CHANSPERPHYIN_c;"
    puts $out_file "  constant CHANSPERPHYOUT_c         : natural := $CHANSPERPHYOUT_c;"    
    puts $out_file "  constant LOG2_CHANSPERPHYOUT_c    : natural := $LOG2_CHANSPERPHYOUT_c;"
    puts $out_file "  constant TDM_FACTOR_c             : natural := $TDM_FACTOR_c;"
    puts $out_file "  constant INVERSE_TDM_FACTOR_c     : natural := $INVERSE_TDM_FACTOR_c;"
    puts $out_file "  constant INVALID_CYCLES_c         : natural := $INVALID_CYCLES_c;"
    puts $out_file "  constant INTERP_FACTOR_c          : natural := $interpN;"
    puts $out_file "  constant TOTAL_INCHANS_ALLOWED    : natural := PHYSCHANIN_c * CHANSPERPHYIN_c;"
    puts $out_file "  constant TOTAL_OUTCHANS_ALLOWED   : natural := PHYSCHANOUT_c * CHANSPERPHYOUT_c;"
    puts $out_file "  constant NUM_OF_TAPS_c            : natural := $NUM_OF_TAPS_c;"
    puts $out_file "  constant TOTAL_EFF_COEF_c         : natural := $total_eff_coeff;"
    puts $out_file "  constant COEFF_BIT_WIDTH_c        : natural := $coeff_bit_width;"
    puts $out_file "  constant COEFF_BUS_DATA_WIDTH_c   : natural := $busDataWidth;"
    puts $out_file ""
    
    puts $out_file "--END MEGAWIZARD INSERT CONSTANTS"
    puts $out_file "end entity ${component_name}_tb;"
    puts $out_file ""
    
    puts $out_file "--library work;"
    puts $out_file "--library auk_dspip_lib;"


    puts $out_file "-------------------------------------------------------------------------------"
    puts $out_file ""
    
    puts $out_file "architecture rtl of ${component_name}_tb is"
    puts $out_file ""

    puts $out_file "  signal ast_sink_data      : std_logic_vector (DATA_WIDTH_c-1 downto 0) := (others => '0');"
    puts $out_file "  signal ast_source_data    : std_logic_vector (OUT_WIDTH_c-1 downto 0);"
    puts $out_file "  signal ast_sink_error     : std_logic_vector (1 downto 0)              := (others => '0');"
    puts $out_file "  signal ast_source_error   : std_logic_vector (1 downto 0);"
    puts $out_file "  signal ast_sink_valid     : std_logic := '0';"
    puts $out_file "  signal ast_source_valid   : std_logic;"
    puts $out_file "  signal ast_source_ready   : std_logic := '0';"
    puts $out_file "  signal clk                : std_logic := '0';"
    puts $out_file "  signal reset_testbench    : std_logic := '1';"
    puts $out_file "  signal reset_design       : std_logic;"
    puts $out_file "  signal eof                : std_logic;"
    puts $out_file "  signal sink_completed     : std_logic := '0';"    
    puts $out_file "  signal ast_sink_ready     : std_logic;"
if {$coeffReload == "true"} {
    puts $out_file "  signal coeff_in_clk       : std_logic;"  
    puts $out_file "  signal coeff_in_areset    : std_logic;"
}
    
if {$CHANSPERPHYIN_c > 1} {        
    puts $out_file "  signal ast_sink_sop       : std_logic := '0';"
    puts $out_file "  signal ast_sink_eop       : std_logic := '0';"
    puts $out_file "  signal ast_sink_sop_tmp   : std_logic := '0';"
    puts $out_file "  signal ast_sink_eop_tmp   : std_logic := '0';"
}

##coef reload ports
if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {
    puts $out_file "  signal coeff_in_data      : std_logic_vector(COEFF_BUS_DATA_WIDTH_c-1 downto 0);"
    puts $out_file "  signal coeff_in_address   : std_logic_vector(11 downto 0);"
    puts $out_file "  signal coeff_in_we        : std_logic_vector(0 downto 0);"
    puts $out_file "  signal coeff_out_data     : std_logic_vector(COEFF_BUS_DATA_WIDTH_c-1 downto 0);"
    puts $out_file "  signal coeff_out_valid    : std_logic_vector(0 downto 0);"
} elseif {[string match "Write" $Read_Write_Mode]} {        
    puts $out_file "  signal coeff_in_data      : std_logic_vector(COEFF_BUS_DATA_WIDTH_c-1 downto 0);"
    puts $out_file "  signal coeff_in_address   : std_logic_vector(11 downto 0);"
    puts $out_file "  signal coeff_in_we        : std_logic_vector(0 downto 0);"
}    


if {$CHANSPERPHYOUT_c > 1} {
    puts $out_file "  signal ast_source_channel : std_logic_vector (LOG2_CHANSPERPHYOUT_c-1 downto 0);"
    puts $out_file "  signal ast_source_eop     : std_logic;"
    puts $out_file "  signal ast_source_sop     : std_logic;"
}

    puts $out_file "  signal cnt                : natural range 0 to CHANSPERPHYIN_c;"
    puts $out_file "  signal push_counter       : natural range 0 to CHANSPERPHYIN_c :=0;"
    puts $out_file "  constant tclk             : time := 10 ns;"
    puts $out_file "  constant time_lapse_max   : time := 60 us;"
    puts $out_file "  signal time_lapse         : time;"
    puts $out_file "  signal valid_cycles       : std_logic := '1';"
    
if {$coeffReload == "true" && ([string match "Read/Write" $Read_Write_Mode] || [string match "Write" $Read_Write_Mode]) } {
##--  type integer_array is array (natural range<>) of integer;
##--  constant num_of_coefs_c : natural := $NUM_OF_TAPS_c;
    puts $out_file "  signal coeff_reload_start : std_logic;"
    puts $out_file "  signal coeff_reload_end   : std_logic := '0';"
    puts $out_file "  signal new_coef_in        : std_logic_vector(31 downto 0) := (others => '0');"
}

    puts $out_file ""
    puts $out_file "  function div_ceil(a : natural; b : natural) return natural is"
    puts $out_file "    variable res : natural := a/b;"
    puts $out_file "  begin"
    puts $out_file "    if res*b /= a then"
    puts $out_file "      res := res +1;"
    puts $out_file "    end if;"
    puts $out_file "    return res;"
    puts $out_file "  end div_ceil;"
    
if {$OUTWIDTH_c > 32} {
  
    puts $out_file {    

  function to_hex (value : in signed) return string is
    constant ne     : integer        := (value'length+3)/4;
    constant NUS    : string(2 to 1) := (others => ' ');  
    variable pad    : std_logic_vector(0 to (ne*4 - value'length) - 1);
    variable ivalue : std_logic_vector(0 to ne*4 - 1);
    variable result : string(1 to ne);
    variable quad   : std_logic_vector(0 to 3);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => value(value'high));             
      end if;
      ivalue := pad & std_logic_vector (value);
      for i in 0 to ne-1 loop
        quad := To_X01Z(ivalue(4*i to 4*i+3));
        case quad is
          when x"0"   => result(i+1) := '0';
          when x"1"   => result(i+1) := '1';
          when x"2"   => result(i+1) := '2';
          when x"3"   => result(i+1) := '3';
          when x"4"   => result(i+1) := '4';
          when x"5"   => result(i+1) := '5';
          when x"6"   => result(i+1) := '6';
          when x"7"   => result(i+1) := '7';
          when x"8"   => result(i+1) := '8';
          when x"9"   => result(i+1) := '9';
          when x"A"   => result(i+1) := 'A';
          when x"B"   => result(i+1) := 'B';
          when x"C"   => result(i+1) := 'C';
          when x"D"   => result(i+1) := 'D';
          when x"E"   => result(i+1) := 'E';
          when x"F"   => result(i+1) := 'F';
          when "ZZZZ" => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_hex;  
    }
}

    puts $out_file ""    
    
    puts $out_file "begin"
    puts $out_file ""
      
    puts $out_file "  DUT : entity work.$component_name"
    puts $out_file "    port map ("
    puts $out_file "      clk                => clk,"
    puts $out_file "      reset_n            => reset_design,"

if {$useClkEnable == "true"} {
    puts $out_file "      ast_sink_ready     => ast_sink_ready,"
}
    puts $out_file "      ast_sink_data      => ast_sink_data,"
    puts $out_file "      ast_source_data    => ast_source_data,"
    puts $out_file "      ast_sink_valid     => ast_sink_valid,"
    puts $out_file "      ast_source_valid   => ast_source_valid,"
if {$useClkEnable == "true"} {
    puts $out_file "      ast_source_ready   => ast_source_ready,"
}

if {$CHANSPERPHYIN_c > 1} {
    puts $out_file "      ast_sink_sop       => ast_sink_sop,"
    puts $out_file "      ast_sink_eop       => ast_sink_eop,"
}

if {$CHANSPERPHYOUT_c > 1} {
    puts $out_file "      ast_source_sop     => ast_source_sop,"
    puts $out_file "      ast_source_eop     => ast_source_eop,"
    puts $out_file "      ast_source_channel => ast_source_channel,"
}

if {$coeffReload == "true"} {
    puts $out_file "      coeff_in_clk       => clk,"
    puts $out_file "      coeff_in_areset    => coeff_in_areset,"
}

if {[string match "Read/Write" $Read_Write_Mode] || [string match "Read" $Read_Write_Mode]} {    
    puts $out_file "      coeff_in_data      => coeff_in_data,"
    puts $out_file "      coeff_in_read      => '0',"
    puts $out_file "      coeff_in_address   => coeff_in_address,"
    puts $out_file "      coeff_in_we        => coeff_in_we,"
    puts $out_file "      coeff_out_data     => coeff_out_data,"
    puts $out_file "      coeff_out_valid    => coeff_out_valid,"
} elseif {[string match "Write" $Read_Write_Mode]} {
    puts $out_file "      coeff_in_data      => coeff_in_data,"
    puts $out_file "      coeff_in_address   => coeff_in_address,"
    puts $out_file "      coeff_in_we        => coeff_in_we,"
}


    puts $out_file "      ast_sink_error     => ast_sink_error,"
    puts $out_file "      ast_source_error   => ast_source_error);"
    puts $out_file ""
    
    puts $out_file "  -- for example purposes, the ready signal is always asserted."
    puts $out_file "  ast_source_ready <= '1';"
if {$useClkEnable == "false"} {
    puts $out_file "  ast_sink_ready <= '1';"
}
    puts $out_file ""
if {$coeffReload == "true"} {
    puts $out_file "  coeff_in_areset  <= NOT reset_design;"
    puts $out_file "  coeff_in_clk     <= clk;"
    
    if {[string match "Read" $Read_Write_Mode]} {    
        puts $out_file "    coeff_in_address <= (others => '0');"
        puts $out_file "    coeff_in_we(0)   <= '0';"
        puts $out_file "    coeff_in_data    <= (others => '0');"
    }
}

    puts $out_file ""    
    puts $out_file "  -- no input error"
    puts $out_file "  ast_sink_error <= (others => '0');"
    puts $out_file ""
    
if {$CHANSPERPHYIN_c > 1 } {
    puts $out_file "  -- sop and eop asserted in first and last sample of data"
    puts $out_file "  cnt_p : process (clk, reset_testbench)"
    puts $out_file "  begin"
    puts $out_file "    if reset_testbench = '0' then"
    puts $out_file "      cnt <= 0;"
    puts $out_file "    elsif rising_edge(clk) then"
    puts $out_file "      if ast_sink_valid = '1' and ast_sink_ready = '1' then"
    puts $out_file "        if cnt = CHANSPERPHYIN_c - 1 then"
    puts $out_file "          cnt <= 0;"
    puts $out_file "        else"
    puts $out_file "          cnt <= cnt + 1;"
    puts $out_file "        end if;"
    puts $out_file "      end if;"
    puts $out_file "    end if;"
    puts $out_file "  end process cnt_p;"
    puts $out_file ""

    puts $out_file "  ast_sink_sop_tmp <= '1' when cnt = 0 else"
    puts $out_file "                      '0';"
    puts $out_file ""
    
    puts $out_file "  ast_sink_eop_tmp <= '1' when cnt = CHANSPERPHYIN_c - 1 else"
    puts $out_file "                      '0';"
    puts $out_file ""
    
    puts $out_file "  ast_sink_sop <= ast_sink_sop_tmp after tclk/4;"   
    puts $out_file "  ast_sink_eop <= ast_sink_eop_tmp after tclk/4;"   
    puts $out_file ""
}

puts $out_file {
  -----------------------------------------------------------------------------------------------
  -- Read input data from file
  -----------------------------------------------------------------------------------------------
  source_model : process(clk) is

    file in_file     : text open read_mode is FIR_INPUT_FILE_c;
    variable data_in : integer;
    variable bank_in : integer;
    variable indata  : line;
    variable read_data_completed: integer;
    variable q, j, j_temp       : integer := 0 ;
    variable realInChansCount   : integer ;       
    variable totalInChansCount  : integer ;
    variable idle_cyles         : integer := 0 ;    

    type In_2D is array (PHYSCHANIN_c-1 downto 0, CHANSPERPHYIN_c-1 downto 0) of integer;
    variable arrayIn : In_2D;
    variable arrayBank : In_2D;
    
    --Debug
    variable my_line : line;
       
  begin
    if rising_edge(clk) then
}

if {$coeffReload == "true" && ([string match "Read/Write" $Read_Write_Mode] || [string match "Write" $Read_Write_Mode]) } {
    puts $out_file "      if(reset_testbench = '0' or coeff_reload_end = '0') then"
} else {
    puts $out_file "      if(reset_testbench = '0') then"
}

puts $out_file {
        ast_sink_data  <= std_logic_vector(to_signed(0, DATA_WIDTH_c)) after tclk/4;
        ast_sink_valid <= '0' after tclk/4;
        eof            <= '0';
    
        realInChansCount := NUM_OF_CHANNELS_c * INVERSE_TDM_FACTOR_c;
        totalInChansCount := TOTAL_INCHANS_ALLOWED;        
        
      else
        if (sink_completed='0' or eof='0') then
          eof <= '0';
          if( valid_cycles = '1' and ast_sink_ready = '1') then

            if not endfile(in_file) then 
              if (push_counter=0) then
                q := 0;      

                for k in 0 to PHYSCHANIN_c-1 loop
                
                  -- Super-Sample Rate
                  if (k /= 0) then
                    j := j + INVERSE_TDM_FACTOR_c;
                    if (j > PHYSCHANIN_c - 1) then
                      j_temp := j_temp + 1;
                      j := j_temp; 
                    end if;
                  else
                    j := k;  
                  end if;
                  
                  for i in 0 to CHANSPERPHYIN_c-1 loop
                    totalInChansCount := totalInChansCount - 1;
        
                    if (realInChansCount > 0) then
                      realInChansCount := realInChansCount - 1;
                      readline(in_file, indata);
                      read(indata, data_in);
                      arrayIn(j,i) := data_in;
                        if (BANKINWIDTH_c > 0) then
                          read(indata, bank_in);
                          arrayBank(j,i) := bank_in;
                        end if;
                      ast_sink_valid <= '1' after tclk/4;         

                      --Debug
                      write(my_line, string'(" j = "));
                      write(my_line, j);
                      write(my_line, string'(" i = "));
                      write(my_line, i);
                      write(my_line, string'(" Array content = "));
                      write(my_line, arrayIn(j,i));               
                      writeline(output, my_line);        
                    end if;
                  end loop;

                  if (totalInChansCount = 0) then
                    realInChansCount := NUM_OF_CHANNELS_c * INVERSE_TDM_FACTOR_c;
                    totalInChansCount := TOTAL_INCHANS_ALLOWED;
                  end if;

                end loop;
                j_temp := 0;
                sink_completed <= '0';
                read_data_completed := 1;

              end if;

            else
              eof <='1';
            end if;

            -- Reorder the input format 
            -- Expected input format by FIR Compiler II
            -- ..., <C2>, <C1>, <C0>, -->
            -- ..., <C5>, <C4>, <C3>, -->
            -- ..., <C8>, <C7>, <C6>, -->
                           
            if (read_data_completed = 1) then

              for p in 0 to PHYSCHANIN_c-1 loop
                --Debug
                write(my_line, string'(" Push input = "));
                write(my_line,arrayIn(p,q));               
                writeline(output, my_line);              -- write to display                 
                ast_sink_data(p*(INWIDTH_c+BANKINWIDTH_c)+INWIDTH_c-1 downto (INWIDTH_c+BANKINWIDTH_c)*p) <= std_logic_vector(to_signed(arrayIn(p,q), INWIDTH_c)) after tclk/4;
                if (BANKINWIDTH_c > 0) then
                  ast_sink_data(p*(INWIDTH_c+BANKINWIDTH_c)+(INWIDTH_c+BANKINWIDTH_c)-1 downto (INWIDTH_c+BANKINWIDTH_c)*p+INWIDTH_c) <= std_logic_vector(to_signed(arrayBank(p,q), BANKINWIDTH_c)) after tclk/4;
                end if;
              end loop;        

              if ( q < CHANSPERPHYIN_c ) then
                q := q + 1;
              else           
                q := 0;
              end if;                                    
              
              if ( push_counter < CHANSPERPHYIN_c-1 ) then
                push_counter <= push_counter + 1;
              else           
                push_counter <= 0;
                read_data_completed := 0;
                sink_completed <= '1';
               
                --start invalid cycles if needed
                if ( idle_cyles < INVALID_CYCLES_c ) then
                  valid_cycles <= '0' ;
                end if;                          

              end if;       
             
            end if;
          
          -- End Reordering and sinking data
          
          else
            
            if ( idle_cyles < INVALID_CYCLES_c ) then
              ast_sink_valid <= '0' after tclk/4;
              idle_cyles := idle_cyles + 1;
              if ( idle_cyles = INVALID_CYCLES_c ) then
                valid_cycles <= '1' ;            
                idle_cyles := 0;
              end if;
            end if;        

            ast_sink_data  <= ast_sink_data after tclk/4;

          end if;
        else
          eof            <= '1';
          ast_sink_valid <= '0' after tclk/4;
          ast_sink_data  <= std_logic_vector(to_signed(0, DATA_WIDTH_c)) after tclk/4;
        end if;
      end if;
    end if;
  end process source_model;
  
  ---------------------------------------------------------------------------------------------
  -- Write FIR output to file
  ---------------------------------------------------------------------------------------------
 
  sink_model : process(clk) is
    file ro_file   : text open write_mode is FIR_OUTPUT_FILE_c;
    variable rdata : line;
    variable y,z,z_temp         : integer :=0;    
    variable realOutChansCount  : natural := NUM_OF_CHANNELS_c * INVERSE_TDM_FACTOR_c;
    variable totalOutChansCount : natural := TOTAL_OUTCHANS_ALLOWED;
}
if {$OUTWIDTH_c > 32} {
    puts $out_file "    type Out_2D is array (CHANSPERPHYOUT_c-1 downto 0, PHYSCHANOUT_c-1 downto 0) of string(div_ceil(OUTWIDTH_c,4) downto 1);"
} else {
    puts $out_file "    type Out_2D is array (CHANSPERPHYOUT_c-1 downto 0, PHYSCHANOUT_c-1 downto 0) of integer;"
}
    puts $out_file "    variable arrayOut : Out_2D;"
    puts $out_file ""
    puts $out_file "  begin"
    puts $out_file "    if rising_edge(clk) then"
    puts $out_file "      if(ast_source_valid = '1' and ast_source_ready = '1') then"
    puts $out_file ""
    puts $out_file "        -- Expected output format from FIR Compiler II"
    puts $out_file "        --> <C0>, <C1>, <C2>, ..."
    puts $out_file "        --> <C3>, <C4>, <C5>, ..."
    puts $out_file "        --> <C6>, <C7>, <C8>, ..."
    puts $out_file ""        
    puts $out_file "        for x in 0 to PHYSCHANOUT_c-1 loop"
    puts $out_file "          -- Super-Sample Rate or Interpolation with TDM = 1"
    puts $out_file "          -- only interpolation factor is  needed for super-sample rate test"
    puts $out_file "          if ( PHYSCHANOUT_c > NUM_OF_CHANNELS_c ) then"
    puts $out_file "            if (x /= 0) then"
    puts $out_file "              z := z + INVERSE_TDM_FACTOR_c * div_ceil(INTERP_FACTOR_c,TDM_FACTOR_c);"
    puts $out_file "              if (z > PHYSCHANOUT_c-1) then"
    puts $out_file "                z_temp := z_temp + 1;"
    puts $out_file "                z := z_temp;"
    puts $out_file "              end if;"
    puts $out_file "            end if;"
    puts $out_file "          else"
    puts $out_file "            z := x;"
    puts $out_file "          end if;"
    puts $out_file ""

if {$OUTWIDTH_c > 32} {
    puts $out_file "          -- report as hex representation of integer."
    puts $out_file "          arrayOut(y,x) := to_hex(signed(ast_source_data(z*OUTWIDTH_c+OUTWIDTH_c-1 downto OUTWIDTH_c*z)));"
} else {
    puts $out_file "          arrayOut(y,x) := to_integer(signed(ast_source_data(z*OUTWIDTH_c+OUTWIDTH_c-1 downto OUTWIDTH_c*z)));"
}
    puts $out_file "        end loop;"
    puts $out_file ""                           
    puts $out_file "        if (y < CHANSPERPHYOUT_c - 1) then"
    puts $out_file "          y := y + 1;"
    puts $out_file "        else"
    puts $out_file "          y := 0;"
    puts $out_file "          z := 0;"
    puts $out_file "          z_temp := 0;"
    puts $out_file ""          
    puts $out_file "          for n in 0 to PHYSCHANOUT_c-1 loop"          
    puts $out_file "            for m in 0 to CHANSPERPHYOUT_c-1 loop"
    puts $out_file "              totalOutChansCount := totalOutChansCount - 1;"
    puts $out_file "              if (realOutChansCount > 0) then"
    puts $out_file "                if (NUM_OF_CHANNELS_c > PHYSCHANOUT_c) then"
    puts $out_file "                  realOutChansCount := realOutChansCount - 1;"
    puts $out_file "                end if;"
    puts $out_file ""                
    puts $out_file "                write(rdata, arrayOut(m,n));"
    puts $out_file "                writeline(ro_file, rdata);"
    puts $out_file ""
    puts $out_file "              end if;"
    puts $out_file "            end loop;"
    puts $out_file "          end loop;"
    puts $out_file "        end if;"
    puts $out_file ""                
    puts $out_file "        if (totalOutChansCount = 0) then"
    puts $out_file "          realOutChansCount := NUM_OF_CHANNELS_c * INVERSE_TDM_FACTOR_c;"
    puts $out_file "          totalOutChansCount := TOTAL_OUTCHANS_ALLOWED;"
    puts $out_file "        end if;"
    puts $out_file "      end if;"
    puts $out_file "  end if;"
    puts $out_file "end process sink_model;"

    puts $out_file {
    
-------------------------------------------------------------------------------
-- clock generator
-------------------------------------------------------------------------------      
  clkgen : process
  begin  -- process clkgen
    if eof = '1' and sink_completed = '1' and ast_source_valid = '0' then
      clk <= '0';
      assert FALSE
        report "NOTE: Stimuli ended" severity note;
      wait;
    elsif time_lapse >= time_lapse_max then
      clk <= '0';
      assert FALSE
        report "ERROR: Reached time_lapse_max without activity, probably simulation is stuck!" severity Error;
      wait;      
    else
      clk <= '0';
      wait for tclk/2;
      clk <= '1';
      wait for tclk/2;
    end if;
  end process clkgen;

  monitor_toggling_activity : process(clk, reset_testbench,
                                      ast_source_data, ast_source_valid)
  begin
    if reset_testbench = '0' then
      time_lapse <= 0 ns;
    elsif ast_source_data'event or ast_source_valid'event then
      time_lapse <= 0 ns;
    elsif rising_edge(clk) then
      if time_lapse < time_lapse_max then
        time_lapse <= time_lapse + tclk;
      end if;
    end if;
  end process monitor_toggling_activity;

}    

    puts $out_file ""
    puts $out_file "-------------------------------------------------------------------------------"
    puts $out_file "-- reset generator"
    puts $out_file "-------------------------------------------------------------------------------"
    puts $out_file "  reset_testbench_gen : process"
    puts $out_file "  begin  -- process resetgen"
    puts $out_file "    reset_testbench <= '1';"
    puts $out_file "    wait for tclk/4;"
    puts $out_file "    reset_testbench <= '0';"
    puts $out_file "    wait for tclk*2;"
    puts $out_file "    reset_testbench <= '1';"
    puts $out_file "    wait;"
    puts $out_file "  end process reset_testbench_gen;"
    puts $out_file "  reset_design_gen : process"
    puts $out_file "  begin  -- process resetgen"
    puts $out_file "    reset_design <= '1';"
    puts $out_file "    wait for tclk/4;"
    puts $out_file "    reset_design <= '0';"
    puts $out_file "    wait for tclk*2;"
    puts $out_file "    reset_design <= '1';"
    puts $out_file "    wait for tclk*80;"
    puts $out_file "    reset_design <= '1';"
    puts $out_file ""
    
    puts $out_file "    wait for tclk*$NUM_OF_TAPS_c*2;"
    puts $out_file "    reset_design <= '1';"
    puts $out_file "    wait;"
    puts $out_file "  end process reset_design_gen;"
    puts $out_file ""

##coef reload ports
if {$coeffReload == "true" && ([string match "Read/Write" $Read_Write_Mode] || [string match "Write" $Read_Write_Mode]) } {

    puts $out_file {

-------------------------------------------------------------------------------
-- control signals
-------------------------------------------------------------------------------

  coeff_reload_start_gen : process
  begin  -- process resetgen
    coeff_reload_start <= '0';
    wait for tclk*82;
    coeff_reload_start <= '1'; --new coef set loaded during filter run
    wait for tclk*2;
    coeff_reload_start <= '0';
    wait;
  end process coeff_reload_start_gen;


  coeff_write_control : process (coeff_in_clk)
    file coef_file             : text open read_mode is COEF_RELOAD_FILE_c;
    variable new_coef_data     : integer := 0;
    variable write_cnt         : integer := 0;
    variable coeff_addr        : integer;
    variable coeff_read_file   : boolean:=true;
    variable wx                : integer := 2;
    variable coefline          : line;    

  begin  -- process coeff_write_control
  
  if (COEFF_BIT_WIDTH_c > COEFF_BUS_DATA_WIDTH_c ) then
    coeff_addr := TOTAL_EFF_COEF_c * 2 + 1;
  else
    coeff_addr := TOTAL_EFF_COEF_c;
  end if;
  
  
    if rising_edge(coeff_in_clk) then
      if coeff_reload_start = '0' and coeff_in_we(0) = '0' then
      
        coeff_in_we(0) <= '0';
        coeff_in_address   <= std_logic_vector(to_signed(BASE_ADDRESS_c - 1,12));
        coeff_in_data      <= std_logic_vector(to_signed(-1,coeff_in_data'HIGH+1));
      
      elsif ( coeff_reload_start = '1' or coeff_in_we(0) = '1' ) and ( write_cnt < coeff_addr ) then  
        
        if (COEFF_BIT_WIDTH_c > COEFF_BUS_DATA_WIDTH_c) then
          if ( coeff_read_file = true ) then
            readline(coef_file, coefline);
            read(coefline, new_coef_data);
            new_coef_in     <= std_logic_vector(to_signed(new_coef_data,32));
            coeff_read_file := false;
          end if;
          
          if ( wx /= 2) then
          -- Write MSB of new coefficient data first, followed by LSB
          coeff_in_address   <= std_logic_vector(unsigned(coeff_in_address) + 1);
          coeff_in_we(0)     <= '1';
          coeff_in_data      <= new_coef_in(wx*COEFF_BUS_DATA_WIDTH_c+COEFF_BUS_DATA_WIDTH_c-1 downto COEFF_BUS_DATA_WIDTH_c*wx);
          end if;
          
          wx := wx - 1;
        
          if ( wx = 0 and not endfile(coef_file)) then
            coeff_read_file  := true;
          elsif (wx = -1) then
            wx := 1;
          end if;
        else
          if ( not endfile(coef_file)) then        
            readline(coef_file, coefline);
            read(coefline, new_coef_data);
            coeff_in_data      <= std_logic_vector(to_signed(new_coef_data,coeff_in_data'HIGH+1));
            coeff_in_we(0)     <= '1';
            coeff_in_address   <= std_logic_vector(unsigned(coeff_in_address) + 1);
          end if;
        end if;
        coeff_reload_end <= '0';
        write_cnt := write_cnt + 1;
      elsif coeff_in_we(0) = '1' and (write_cnt = coeff_addr ) then
        coeff_in_we(0) <= '0';
        coeff_in_address   <= std_logic_vector(to_signed(BASE_ADDRESS_c - 1,12));
        coeff_in_data      <= std_logic_vector(to_signed(-1,coeff_in_data'HIGH+1));
        coeff_reload_end <= '1';
      else
        coeff_in_we(0) <= '0';
        coeff_in_address   <= std_logic_vector(to_signed(BASE_ADDRESS_c - 1,12));
        coeff_in_data      <= std_logic_vector(to_signed(-1,coeff_in_data'HIGH+1));
      end if;
    end if;
  end process coeff_write_control;
  }
}
    puts $out_file "end architecture rtl;"
    
close $out_file
