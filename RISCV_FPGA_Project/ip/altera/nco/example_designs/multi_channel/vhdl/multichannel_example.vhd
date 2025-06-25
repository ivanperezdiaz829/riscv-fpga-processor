-- ================================================================================
-- Legal Notice: Copyright (C) 1991-2009 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.
-- ================================================================================
-- NCO Compiler Multi-Channel Example Design 
-- Description: This is the toplevel of the NCO Multi-channel example design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use std.textio.all;

----------------------------------------------------------------
-- Declare main entity
----------------------------------------------------------------
entity multichannel_example is   
  generic(
		PHASE_INC_WIDTH	:	INTEGER:=32;  --Phase increment input width 
		FREQ_MOD_WIDTH 	:	INTEGER:=32;  --Frequency modulation input width
		PHASE_MOD_WIDTH	:	INTEGER:=32;  --Phase modulation input width
		OUTPUT_WIDTH	:	INTEGER:=18   --output sinusoid bitwidth (fsin_o, fcos_o)
        );
  port(
		clk                 	: IN std_logic;
		reset_n               	: IN std_logic;
		
		-- Phase increment input for each channel
		phi_ch0         		: IN std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
		phi_ch1         		: IN std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
		phi_ch2         		: IN std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
		phi_ch3         		: IN std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
		
		-- Frequency modulation input for each channel
		fmod_ch0      	      	: IN std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
		fmod_ch1      	      	: IN std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
		fmod_ch2      	      	: IN std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
		fmod_ch3      	      	: IN std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
		
		-- Phase modulation input for each channel
		pmod_ch0      	      	: IN std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
		pmod_ch1      	      	: IN std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
		pmod_ch2      	      	: IN std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
		pmod_ch3      	      	: IN std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
		
		-- Output Sinusoids and cosins for each Channel		
		sin_ch0         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		cos_ch0         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		sin_ch1         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		cos_ch1         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		sin_ch2         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		cos_ch2         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		sin_ch3         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		cos_ch3         		: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		
		-- Multiplexed Channel Output and Avalon-ST Signals
		sin_o					: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		cos_o 					: OUT std_logic_vector (OUTPUT_WIDTH-1 downto 0);
		valid             		: OUT std_logic;
		startofpacket			: OUT std_logic;
		endofpacket    			: OUT std_logic		
	);
end multichannel_example;
 
architecture nco_multi_channels of multichannel_example is

	----------------------------------------------------------------
	-- Component Declaration for NCO IP Core
	----------------------------------------------------------------
	component nco

	port(
			clk					: IN STD_LOGIC ;
			clken				: IN STD_LOGIC ;
			reset_n				: IN STD_LOGIC ;

			phi_inc_i			: IN STD_LOGIC_VECTOR (PHASE_INC_WIDTH-1 DOWNTO 0);
			freq_mod_i			: IN STD_LOGIC_VECTOR (FREQ_MOD_WIDTH-1 DOWNTO 0);
			phase_mod_i			: IN STD_LOGIC_VECTOR (PHASE_MOD_WIDTH-1 DOWNTO 0);
			
			fsin_o				: OUT STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 DOWNTO 0);
			fcos_o				: OUT STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 DOWNTO 0);
			out_valid			: OUT STD_LOGIC
			);
	end component;

	----------------------------------------------------------------
	-- Declare Signals
	----------------------------------------------------------------
	signal sin_value	      		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal cos_value      	  		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	
	-- Phase increment.  This value controls the output frequency of the NCO
	signal phi      	        	: std_logic_vector (PHASE_INC_WIDTH-1 downto 0);	

	-- Frequency Modulation.  Using this value it is possible to modulate the output frequency 
	signal fmod      				: std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);

	-- Phase Modulation.  Using this value it is possible to modulate the output phase
	signal pmod      				: std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
	
	-- This signal controls the input multiplexer to ensure that each channel has the correct Phase increment (frequency)	
	signal sel_phi            		: std_logic_vector(1 downto 0);

	-- This signal controls the output demultiplexor.  The demultiplexor is used to display each channel in parallel.
	signal sel_output         		: std_logic_vector(1 downto 0);
	signal out_valid          		: std_logic; 
	
	-- These signals each convey a sinusoid associated with a single channel
	signal sin_value_ch0			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal cos_value_ch0			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal sin_value_ch1			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal cos_value_ch1			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal sin_value_ch2			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal cos_value_ch2			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal sin_value_ch3			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	signal cos_value_ch3			: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
	
	-- out_en is used to align the parallel output data
	signal out_en					: std_logic;

	begin
	----------------------------------------------------------------
	-- NCO component instantiation
	----------------------------------------------------------------
	nco_instantiation: nco

	port map(  clk			=>clk,
			   reset_n		=>reset_n,
			   clken		=>'1',
			   phi_inc_i	=>phi,
			   freq_mod_i	=>fmod,
			   phase_mod_i	=>pmod,
			   fsin_o		=>sin_value,
			   fcos_o		=>cos_value,
			   out_valid	=>out_valid
		);

	-----------------------------------------------------------------------------------------------
	-- Input Phase Increment Channel Selector          
	-----------------------------------------------------------------------------------------------
	input_counter : process(clk,reset_n) is
	  begin
	    if(reset_n='0') then
			sel_phi <= (others=>'0');
		elsif rising_edge(clk)then               
			sel_phi <= sel_phi + "01";
		end if;
	end process input_counter;
	
	-----------------------------------------------------------------------------------------------
	-- Time Multiplex the Phase Increment, Frequency Modulation and Phase Modulation for each channel         
	-----------------------------------------------------------------------------------------------
	input_select: process(sel_phi,phi_ch0,fmod_ch0,pmod_ch0,phi_ch1,fmod_ch1,pmod_ch1,phi_ch2,fmod_ch2,pmod_ch2,phi_ch3,fmod_ch3,pmod_ch3) is 
        begin
     		case sel_phi is
			  when "00" =>                             
				phi 	<= phi_ch0;                        
				fmod 	<= fmod_ch0;                      
				pmod 	<= pmod_ch0;                      
			  when "01" =>                             
				phi 	<= phi_ch1;                        
				fmod 	<= fmod_ch1;                      
				pmod 	<= pmod_ch1;                      
			  when "10" =>                             
				phi 	<= phi_ch2;                        
				fmod 	<= fmod_ch2;                      
				pmod 	<= pmod_ch2;                      
			  when "11" =>                             
				phi 	<= phi_ch3;                        
				fmod 	<= fmod_ch3;                      
				pmod 	<= pmod_ch3;                      
			  when others =>                           
				phi 	<= phi_ch0;                        
				fmod 	<= fmod_ch0;                      
				pmod 	<= pmod_ch0;                      
			end case;
	end process input_select;		

	-----------------------------------------------------------------------------------------------
	-- Demultiplex multiple Channels                   
	-----------------------------------------------------------------------------------------------
	output_select: process(clk,reset_n) is                    
	  begin   
	    if(reset_n='0') then
    		sel_output  	<= (others=>'0'); 
			out_en 			<= '0';			--out_en signal uses for aligning output data
			sin_value_ch0 	<= (others=>'0');
			cos_value_ch0 	<= (others=>'0');
			sin_value_ch1 	<= (others=>'0');
			cos_value_ch1 	<= (others=>'0');
			sin_value_ch2 	<= (others=>'0');
			cos_value_ch2 	<= (others=>'0');
			sin_value_ch3 	<= (others=>'0');
			cos_value_ch3 	<= (others=>'0');
    	elsif(rising_edge(clk)) then
			if (out_valid='1') then                    
				sel_output <= sel_output + "01";
				
				case sel_output is           
				  when "00" =>		
					out_en <='0';                        
					sin_value_ch0 <= sin_value;
					cos_value_ch0 <= cos_value;          
				  when "01" =>							
					out_en <= '0';
					sin_value_ch1 <= sin_value; 
					cos_value_ch1 <= cos_value;                
				  when "10" => 		
					out_en <= '0';								
					sin_value_ch2 <= sin_value;
					cos_value_ch2 <= cos_value; 
				  when "11" =>	
					out_en <= '1';             
					sin_value_ch3 <= sin_value;                
					cos_value_ch3 <= cos_value;                
				  when others =>
					out_en <= '0';							
					sin_value_ch0 <= sin_value;                
					cos_value_ch0 <= cos_value;                
				end case; 			

			end if;

		end if;
    
	end process output_select;

	-----------------------------------------------------------------------------------------------
	-- Generate Avalon-ST Signals                   
	-----------------------------------------------------------------------------------------------
	avalon_st: process(clk,reset_n) is                    
	  begin   
	    if(reset_n='0') then
    		startofpacket 	<= '0';
			endofpacket 	<= '0';
    		cos_o 			<= (others=>'0');
    		sin_o 			<= (others=>'0');
    		valid			<= '0';
    	elsif(rising_edge(clk)) then
			if (out_valid='1') then                    
				
				case sel_output is  -- Use the same multiplexor control signal as previous process         
				  when "00" =>		
					startofpacket <= '1';   
					endofpacket <= '0';                         
				  when "01" =>							
					startofpacket <= '0';
					endofpacket <= '0';
				  when "10" => 		
					startofpacket <= '0';   
					endofpacket <= '0';								
				  when "11" =>	
					startofpacket <= '0';   			     				
					endofpacket <= '1';             
				  when others =>
					startofpacket <= '0';   
					endofpacket <= '0';							
				end case; 			

			end if;
			
			-- Add single cycle of latency to compensate for start and end of packet signals
			valid 	<= out_valid;
			cos_o 	<= cos_value;
			sin_o 	<= sin_value;
		end if;
    
	end process avalon_st;
	
	-----------------------------------------------------------------------------------------------
	-- Sychronize multiple channels in parallel                   
	-----------------------------------------------------------------------------------------------
	align_output: process (clk,reset_n) is
	  begin
		if (reset_n='0') then 
			sin_ch0 <= (others=>'0');
			sin_ch1 <= (others=>'0');
			sin_ch2 <= (others=>'0');
			sin_ch3 <= (others=>'0');
			cos_ch0 <= (others=>'0');
			cos_ch1 <= (others=>'0');
			cos_ch2 <= (others=>'0');
			cos_ch3 <= (others=>'0');
		elsif (rising_edge(clk)) then
			if (out_en='1') then 
				sin_ch0 <= sin_value_ch0;
				sin_ch1 <= sin_value_ch1;
				sin_ch2 <= sin_value_ch2;
				sin_ch3 <= sin_value_ch3;
				cos_ch0 <= cos_value_ch0;
				cos_ch1 <= cos_value_ch1;
				cos_ch2 <= cos_value_ch2;
				cos_ch3 <= cos_value_ch3;
			end if;	
		end if;
	end process align_output;

end nco_multi_channels;

