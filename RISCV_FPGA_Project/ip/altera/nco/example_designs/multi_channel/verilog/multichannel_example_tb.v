//  Copyright (C) 1988-2009 Altera Corporation

//  Any megafunction design, and related net list (encrypted or decrypted),
//  support information, device programming or simulation file, and any other
//  associated documentation or information provided by Altera or a partner
//  under Altera's Megafunction Partnership Program may be used only to
//  program PLD devices (but not masked PLD devices) from Altera.  Any other
//  use of such megafunction design, net list, support information, device
//  programming or simulation file, or any other related documentation or
//  information is prohibited for any other purpose, including, but not
//  limited to modification, reverse engineering, de-compiling, or use with
//  any other silicon devices, unless such use is explicitly licensed under
//  a separate agreement with Altera or a megafunction partner.  Title to
//  the intellectual property, including patents, copyrights, trademarks,
//  trade secrets, or maskworks, embodied in any such megafunction design,
//  net list, support information, device programming or simulation file, or
//  any other related documentation or information provided by Altera or a
//  megafunction partner, remains with Altera, the megafunction partner, or
//  their respective licensors.  No other licenses, including any licenses
//  needed under any third party's intellectual property, are provided herein.


// NCO Compiler Multi-Channel Example Design Verilog HDL Testbench
// Description: This is the testbench for the multichannel example design.

module multichannel_example_tb;

parameter PHASE_INC_WIDTH = 32;
parameter PHASE_MOD_WIDTH = 32;
parameter FREQ_MOD_WIDTH = 32;
parameter OUTPUT_WIDTH = 18;

reg clk     ;
reg reset_n ;

// Phase increment input for each channel
reg [PHASE_INC_WIDTH-1:0] phi_ch0 ;
reg [PHASE_INC_WIDTH-1:0] phi_ch1 ;
reg [PHASE_INC_WIDTH-1:0] phi_ch2 ;
reg [PHASE_INC_WIDTH-1:0] phi_ch3 ;

// Frequency modulation input for each channel
reg [FREQ_MOD_WIDTH-1:0] fmod_ch0;
reg [FREQ_MOD_WIDTH-1:0] fmod_ch1;
reg [FREQ_MOD_WIDTH-1:0] fmod_ch2;
reg [FREQ_MOD_WIDTH-1:0] fmod_ch3;

// Phase modulation input for each channel
reg [PHASE_MOD_WIDTH-1:0] pmod_ch0;
reg [PHASE_MOD_WIDTH-1:0] pmod_ch1;
reg [PHASE_MOD_WIDTH-1:0] pmod_ch2;
reg [PHASE_MOD_WIDTH-1:0] pmod_ch3;

// Output Sinusoids for each Channel
wire [OUTPUT_WIDTH-1:0] sin_ch0 ;
wire [OUTPUT_WIDTH-1:0] cos_ch0 ;
wire [OUTPUT_WIDTH-1:0] sin_ch1 ;
wire [OUTPUT_WIDTH-1:0] cos_ch1 ;
wire [OUTPUT_WIDTH-1:0] sin_ch2 ;
wire [OUTPUT_WIDTH-1:0] cos_ch2 ;
wire [OUTPUT_WIDTH-1:0] sin_ch3 ;
wire [OUTPUT_WIDTH-1:0] cos_ch3 ;

// Multiplexed Channel Output and Avalon-ST Signals
wire [OUTPUT_WIDTH-1:0] cos_o;
wire [OUTPUT_WIDTH-1:0] sin_o;
wire valid ;
wire startofpacket;
wire endofpacket;      
 
integer clk_period_2 = 2500;

//--------------------------------------------
//Multi-channel NCO  instantiation
//--------------------------------------------
multichannel_example multichannel_example_inst( 
	        .clk(clk),
            .reset_n(reset_n),
                  
            .phi_ch0(phi_ch0),
            .phi_ch1(phi_ch1),
            .phi_ch2(phi_ch2),         
            .phi_ch3(phi_ch3),        
            
            .fmod_ch0(fmod_ch0),      
            .fmod_ch1(fmod_ch1), 
            .fmod_ch2(fmod_ch2), 
            .fmod_ch3(fmod_ch3),          
                    
            .pmod_ch0(pmod_ch0),   
            .pmod_ch1(pmod_ch1), 
            .pmod_ch2(pmod_ch2), 
            .pmod_ch3(pmod_ch3),             
                      
            .sin_ch0(sin_ch0),
            .cos_ch0(cos_ch0),        
            .sin_ch1(sin_ch1),       
            .cos_ch1(cos_ch1),        
            .sin_ch2(sin_ch2),       
            .cos_ch2(cos_ch2),        
            .sin_ch3(sin_ch3),      
            .cos_ch3(cos_ch3),        
            
			.cos_o(cos_o),
			.sin_o(sin_o),
            .valid(valid),  
            .startofpacket(startofpacket),
            .endofpacket(endofpacket)                     
    );
    defparam multichannel_example_inst.OUTPUT_WIDTH = OUTPUT_WIDTH;
    defparam multichannel_example_inst.PHASE_INC_WIDTH = PHASE_INC_WIDTH;
    defparam multichannel_example_inst.FREQ_MOD_WIDTH = FREQ_MOD_WIDTH;
    defparam multichannel_example_inst.PHASE_MOD_WIDTH = PHASE_MOD_WIDTH;
	
//--------------------------------------------------------------
// Convert absolute frequency value to a Phase Increment for the NCO core
//  Inputs: 	Desired frequency
//  Outputs:	Phase Increment value
// This function is used to simplify generation of the Phase increment value
//  
//--------------------------------------------------------------	
function [31:0] freq2phi (input [31:0] value);
	real temp;
	begin
		// phi = [fo/fclk*2^(PHASE_INC_WIDTH)]*n
	    //where:
	   		// fo = desired frequency (input)
	   		// fclk = clock frequency (for this design = 200e6 (200 MHz)
	   		// PHASE_INC_WIDTH = 32   (for this design)
	   		// n = number of channels (n=4 for this design)
	   
		// Note that in this function we decompose the multiplication by
		// 2^(PHASE_INC_WIDTH) to avoid high precision fixed/floating point
		// arithmetic errors
	  	temp=($itor(2**16)*4.0*$itor(value));	// multiply by 2^16 is the first half of the multiplication decomposition (PHASE_INC_WIDTH = 32)  
		temp= temp/200000000.0; 				// divide by 200 MHz (fclk)                 
		temp= temp*$itor(2**16)+0.5;			// Perform second half of multiplication decomposition
		freq2phi=$rtoi(temp);		
	end
endfunction	

initial
  begin
    #0 clk = 1'b0;    
	//	-----------------------------------------------------------------------
	// Generate input stimulus for simulation
	//---------------------------------------------------------------------
	// In order to get the desired frequency and phase, we must derive
	// the values for phi, fmod and pmod.  These values may be calculated using
	// the following formulae.
	//
	//phi=[fo/fck*2^PHASE_INC_WIDTH]*n
	//fmod=[fo/fck*2^FREQ_MOD_WIDTH]*n
	//pmod=[2^PHASE_MOD_WIDTH/(2pi) * phase]
	//
	// where:
	//  	fo 				= desired output frequency
	//  	fclk 			= clock frequency (200 MHz for this design)
	//  	PHASE_INC_WIDTH = Phase increment bit width 
	//  	n 				= number of channels (4 for this design)
	//  	FREQ_MOD_WIDTH 	= Frequency modulator bitwidth
	//  	PHASE_MOD_WIDTH = Phase modulator bitwidth
	//  	phase 			= desired output phase
	//---------------------------------------------------------------------
	// Channel 1 Specifications:
	//---------------------------------------------------------------------
	//output frequency     =	5 MHz 		phi =[5000/200000*2^32]*4=429496730;					
	//frequency modulation =	0 MHz       fmod=0                        
	//phase modulation     =	0 radians   pmod=0    
	//--------------------------------------------------------------------- 
	#0 phi_ch0 = freq2phi(32'd5000000);
	#0 fmod_ch0 = freq2phi(32'd0);
	#0 pmod_ch0 = 0;        
	//---------------------------------------------------------------------
	// Channel 2 Specifications:
	//---------------------------------------------------------------------
	//fo=	    500KHz 	phi =[500/200000  *2^32]*4=42949673	  
	//fmod=   1500KHz   fmod=[1500/200000*2^32]*4=128849019           
	//pmod=   pi/4             pmod=2^29=536870912
	//---------------------------------------------------------------------
	#0 phi_ch1 = freq2phi(32'd500000);
	#0 fmod_ch1 = freq2phi(32'd1500000);
	#0 pmod_ch1 = 32'd1<<29;
	//--------------------------------------------------------------------
	//fo=	  100KHz 	phi =[100/200000 *2^32]*4=8589935	  
	//fmod=   900KHz    fmod=[900/200000 *2^32]*4=77309411          
	//pmod=   pi/2             pmod=2^30=1073741824
	//---------------------------------------------------------------------
	#0 phi_ch2 = freq2phi(32'd100000);
	#0 fmod_ch2 = freq2phi(32'd900000);
	#0 pmod_ch2 = 32'd1<<30;
	//---------------------------------------------------------------------
	//fo=	   10KHz 	phi =[10/200000  *2^32]*4=858993		  
	//fmod=   490KHz    fmod=[490/200000 *2^32]*4=42090680             
	//pmod=   pi            pmod=2^31 = 2147483648
	//---------------------------------------------------------------------
	#0 phi_ch3 = freq2phi(32'd10000);
	#0 fmod_ch3 = freq2phi(32'd490000);
	#0 pmod_ch3 = 32'd1<<31;
	//create reset signal
	#0 reset_n = 1'b0;
    #34999 reset_n = 1'b1;
  end

//---------------------------------------------------------------------
// Testbench Clock Generation
//---------------------------------------------------------------------
always
  begin
    #clk_period_2 clk = 1;
    #clk_period_2 clk = 0;
  end

endmodule
