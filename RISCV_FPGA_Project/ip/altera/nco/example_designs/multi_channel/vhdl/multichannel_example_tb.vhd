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
-- Description: This is the testbench for the multichannel example design.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use std.textio.all;

----------------------------------------------------------------
-- Entity Declaration for testbench (Configure Generics)
----------------------------------------------------------------
entity multichannel_example_tb is   
  generic(
		PHASE_INC_WIDTH	:	INTEGER := 32;  --Phase increment input width 
		FREQ_MOD_WIDTH 	:	INTEGER := 32;  --Frequency modulation input width
		PHASE_MOD_WIDTH	:	INTEGER := 32;  --Phase modulation input width
		OUTPUT_WIDTH	:	INTEGER := 18   --output sinusoid bitwidth (fsin_o, fcos_o)		
		);
end multichannel_example_tb;        

architecture tb of multichannel_example_tb is

	----------------------------------------------------------------
	-- Convert integer to unsigned std_logicvector
	--  Inputs: 	Integer to convert, Bitwidth of output std_logic_vector
	--  Outputs:	Std_Logic_vector 
	-- This function is required by the testbench because we generated
	-- a frequency value as an integer and the core requires a std_logic_vector  
	----------------------------------------------------------------	
	function int2ustd(value : integer; width : integer) return std_logic_vector is 
	
	variable temp :   std_logic_vector(width-1 downto 0);
	begin
		if (width>0) then
			temp:=conv_std_logic_vector(conv_unsigned(value, width ), width);
		end if ;
		return temp;
	end int2ustd;


	----------------------------------------------------------------
	-- Convert absolute frequency value to a Phase Increment for the NCO core
	--  Inputs: 	Desired frequency
	--  Outputs:	Phase Increment value
	-- This function is used to simplify generation of the Phase increment value
	--  
	----------------------------------------------------------------	
	function freq2phi(value: integer)  return integer is

	variable results : integer ;
	variable temp : real;
	begin
	   -- phi = [fo/fclk*2^(PHASE_INC_WIDTH)]*n
	   -- where:
	   		-- fo = desired frequency (input)
	   		-- fclk = clock frequency (for this design = 200e6 (200 MHz)
	   		-- PHASE_INC_WIDTH = 32   (for this design)
	   		-- n = number of channels (n=4 for this design)
	   
	   -- Note that in this function we decompose the multiplication by
	   -- 2^(PHASE_INC_WIDTH) to avoid high precision fixed/floating point
	   -- arithmetic errors
	   
	   	temp:=(real(2**16)*4.0*real(value));	-- multiply by 2^16 is the first half of the multiplication decomposition (PHASE_INC_WIDTH = 32)  
		temp:= temp/200000000.0; 				-- divide by 200 MHz (fclk)                 
		temp:= temp*real(2**16); 				-- Perform second half of multiplication decomposition
		results:=integer(temp);	
		return results;
	end freq2phi;

----------------------------------------------------------------
-- Component declaration for multichannel example toplevel
----------------------------------------------------------------
component multichannel_example
  generic(
		PHASE_INC_WIDTH	:	INTEGER;  --Phase increment input width 
		FREQ_MOD_WIDTH 	:	INTEGER;  --Frequency modulation input width
		PHASE_MOD_WIDTH	:	INTEGER;  --Phase modulation input width
		OUTPUT_WIDTH	:	INTEGER   --output sinusoid bitwidth (fsin_o, fcos_o)
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
		
		-- Output Sinusoids for each Channel		
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
end component;

----------------------------------------------------------------
-- Declare signals
----------------------------------------------------------------
signal clk                 	: std_logic;
signal reset_n              : std_logic;

-- Phase increment signals for each channel
signal phi_ch0         		: std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
signal phi_ch1         		: std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
signal phi_ch2         		: std_logic_vector (PHASE_INC_WIDTH-1 downto 0);
signal phi_ch3         		: std_logic_vector (PHASE_INC_WIDTH-1 downto 0);

-- Frequency modulation signals for each channel
signal fmod_ch0      	    : std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
signal fmod_ch1      	    : std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
signal fmod_ch2      	    : std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);
signal fmod_ch3      	    : std_logic_vector (FREQ_MOD_WIDTH-1 downto 0);

-- Phase modulation signals for each channel
signal pmod_ch0      	    : std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
signal pmod_ch1      	    : std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
signal pmod_ch2      	    : std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);
signal pmod_ch3      	    : std_logic_vector (PHASE_MOD_WIDTH-1 downto 0);

-- Signals to convey the output sinusoids for each Channel		
signal sin_ch0         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal cos_ch0         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal sin_ch1         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal cos_ch1         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal sin_ch2         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal cos_ch2         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal sin_ch3         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal cos_ch3         		: std_logic_vector (OUTPUT_WIDTH-1 downto 0);

-- Multiplexed Channel signals and Avalon-ST Signals
signal valid            	: std_logic;
signal cos_o 				: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal sin_o 				: std_logic_vector (OUTPUT_WIDTH-1 downto 0);
signal startofpacket		: std_logic;
signal endofpacket    		: std_logic;		
constant clk_period_2 	  	: time := 2500 ps;

begin
----------------------------------------------------------------
-- Toplevel Example design instantiation
----------------------------------------------------------------
multichannel_example_toplevel: multichannel_example
generic map(
		PHASE_INC_WIDTH	=> PHASE_INC_WIDTH,
		FREQ_MOD_WIDTH 	=> FREQ_MOD_WIDTH,
		PHASE_MOD_WIDTH	=> PHASE_MOD_WIDTH,
		OUTPUT_WIDTH	=> OUTPUT_WIDTH
	)

port map( 	clk				=>clk,
			reset_n			=>reset_n,
			
			phi_ch0			=>phi_ch0,
			phi_ch1			=>phi_ch1,
			phi_ch2			=>phi_ch2,         
			phi_ch3			=>phi_ch3,        
			
			fmod_ch0		=>fmod_ch0,      
			fmod_ch1		=>fmod_ch1, 
			fmod_ch2		=>fmod_ch2, 
			fmod_ch3		=>fmod_ch3,   	      
					
			pmod_ch0		=>pmod_ch0,   
			pmod_ch1		=>pmod_ch1, 
			pmod_ch2		=>pmod_ch2, 
			pmod_ch3		=>pmod_ch3,    	     
			   	      
			sin_ch0			=>sin_ch0,
			cos_ch0			=>cos_ch0,        
			sin_ch1			=>sin_ch1,       
			cos_ch1			=>cos_ch1,        
			sin_ch2			=>sin_ch2,       
			cos_ch2			=>cos_ch2,        
			sin_ch3			=>sin_ch3,      
			cos_ch3			=>cos_ch3,        
			
			valid			=>valid,  
			sin_o			=>sin_o,
			cos_o			=>cos_o,
			startofpacket	=>startofpacket,
		    endofpacket		=>endofpacket    		          
	);
	
--create reset signal
reset_n <= '0',
         '1' after 14*clk_period_2 ;

-----------------------------------------------------------------------
-- Generate input stimulus for simulation
-----------------------------------------------------------------------
-- In order to get the desired frequency and phase, we must derive
-- the values for phi, fmod and pmod.  These values may be calculated using
-- the following formulae.
--
--phi=[fo/fck*2^PHASE_INC_WIDTH]*n
--fmod=[fo/fck*2^FREQ_MOD_WIDTH]*n
--pmod=[2^PHASE_MOD_WIDTH/(2pi) * phase]
--
-- where:
--  	fo 				= desired output frequency
--  	fclk 			= clock frequency (200 MHz for this design)
--  	PHASE_INC_WIDTH = Phase increment bit width 
--  	n 				= number of channels (4 for this design)
--  	FREQ_MOD_WIDTH 	= Frequency modulator bitwidth
--  	PHASE_MOD_WIDTH = Phase modulator bitwidth
--  	phase 			= desired output phase
-----------------------------------------------------------------------
-- Channel 1 Specifications:
-----------------------------------------------------------------------
--output frequency     =	5 MHz 		phi =[5000/200000*2^32]*4=429496730;					
--frequency modulation =	0 MHz       fmod=0                        
--phase modulation     =	0 radians   pmod=0    
----------------------------------------------------------------------- 
phi_ch0<= int2ustd(freq2phi(5000000),32);
fmod_ch0<= int2ustd(0,32);
pmod_ch0<= int2ustd(0,32);
-----------------------------------------------------------------------
-- Channel 2 Specifications:
-----------------------------------------------------------------------
--fo=	    500KHz 	phi =[500/200000  *2^32]*4=42949673	  
--fmod=   1500KHz   fmod=[1500/200000*2^32]*4=128849019           
--pmod=   pi/4             pmod=2^29 = 536870912
-----------------------------------------------------------------------
phi_ch1 <= int2ustd(freq2phi( 500000),32);
fmod_ch1<= int2ustd(freq2phi(1500000),32);
pmod_ch1<= int2ustd((2**29),32);
-----------------------------------------------------------------------
--fo=	  100KHz 	phi =[100/200000 *2^32]*4=8589935	  
--fmod=   900KHz    fmod=[900/200000 *2^32]*4=77309411          
--pmod=   pi/2             pmod=2^30=1073741824
-----------------------------------------------------------------------
phi_ch2 <= int2ustd(freq2phi(100000),32);
fmod_ch2<= int2ustd(freq2phi(900000),32);
pmod_ch2<= int2ustd((2**30),32);
-----------------------------------------------------------------------
--fo=	   10KHz 	phi =[10/200000  *2^32]*4=858993		  
--fmod=   490KHz    fmod=[490/200000 *2^32]*4=42090680             
--pmod=   pi            pmod=2^31=2147483648
-----------------------------------------------------------------------
phi_ch3 <= int2ustd(freq2phi( 10000),32);
fmod_ch3<= int2ustd(freq2phi(490000),32);
pmod_ch3<= int2ustd((2**30)+(2**30),32);	-- 2^31 expressed as (2^30)+(2^30) in order to avoid Modelsim integer overflow
	
-----------------------------------------------------------------------
-- Testbench Clock Generation
-----------------------------------------------------------------------
clk_gen : process
begin
	loop
		clk<='0' , '1'  after clk_period_2;
     		wait for clk_period_2*2;
        end loop;
end process clk_gen;

end tb;	
	
