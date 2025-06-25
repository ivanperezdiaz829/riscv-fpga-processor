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


// NCO Compiler Multi-Channel Example Design 
// Description: This is the toplevel of the NCO Multi-channel example design.

module multichannel_example(    
                    clk, 
                    reset_n,                     
                    // Phase increment inputs on channels 0..3
                    phi_ch0, 
                    phi_ch1,                    
                    phi_ch2,                
                    phi_ch3,         
                    // Frequency modulation inputs on channels 0..3
                    fmod_ch0,            
                    fmod_ch1,            
                    fmod_ch2,             
                    fmod_ch3,            
                    // Phase modulation inputs on channels 0..3
                    pmod_ch0,            
                    pmod_ch1,            
                    pmod_ch2,
                    pmod_ch3,
                    // Sinusoidal outputs on channels 0..3
                    sin_ch0,
                    cos_ch0,
                    sin_ch1,
                    cos_ch1,
                    sin_ch2,
                    cos_ch2,
                    sin_ch3,
                    cos_ch3,
					// Multiplexed Channel Output and Avalon-ST Signals
					cos_o,
					sin_o,
                    valid,
                    startofpacket,
                    endofpacket
    );

parameter   PHASE_INC_WIDTH=32; 	//Phase increment input width
parameter   FREQ_MOD_WIDTH=32;  	//Frequency modulation input width
parameter   PHASE_MOD_WIDTH=32;  	//Phase modulation input width
parameter   OUTPUT_WIDTH=18;  		//Sinusoid output signal width

input clk;   
input reset_n; 
// Phase increment input for each channel
input [PHASE_INC_WIDTH-1:0] phi_ch0;
input [PHASE_INC_WIDTH-1:0] phi_ch1;
input [PHASE_INC_WIDTH-1:0] phi_ch2;           
input [PHASE_INC_WIDTH-1:0] phi_ch3;         
// Frequency modulation input for each channel
input [FREQ_MOD_WIDTH-1:0] fmod_ch0;
input [FREQ_MOD_WIDTH-1:0] fmod_ch1;         
input [FREQ_MOD_WIDTH-1:0] fmod_ch2;         
input [FREQ_MOD_WIDTH-1:0] fmod_ch3;         
// Phase modulation input for each channel
input [PHASE_MOD_WIDTH-1:0] pmod_ch0;         
input [PHASE_MOD_WIDTH-1:0] pmod_ch1;         
input [PHASE_MOD_WIDTH-1:0] pmod_ch2;         
input [PHASE_MOD_WIDTH-1:0] pmod_ch3;        
// Output Sinusoids and cosins for each Channel	
output [OUTPUT_WIDTH-1:0] sin_ch0;         
output [OUTPUT_WIDTH-1:0] cos_ch0;         
output [OUTPUT_WIDTH-1:0] sin_ch1;         
output [OUTPUT_WIDTH-1:0] cos_ch1;         
output [OUTPUT_WIDTH-1:0] sin_ch2;         
output [OUTPUT_WIDTH-1:0] cos_ch2;         
output [OUTPUT_WIDTH-1:0] sin_ch3;         
output [OUTPUT_WIDTH-1:0] cos_ch3;         
// Multiplexed Channel Output and Avalon-ST Signals
output [OUTPUT_WIDTH-1:0] cos_o;
output [OUTPUT_WIDTH-1:0] sin_o;
output valid;
output startofpacket;
output endofpacket;

reg [PHASE_INC_WIDTH-1:0] phi;
reg [FREQ_MOD_WIDTH -1:0] fmod;
reg [PHASE_MOD_WIDTH-1:0] pmod;

wire [PHASE_INC_WIDTH-1:0] phi_ch0;
wire [PHASE_INC_WIDTH-1:0] phi_ch1;
wire [PHASE_INC_WIDTH-1:0] phi_ch2;
wire [PHASE_INC_WIDTH-1:0] phi_ch3;

wire [FREQ_MOD_WIDTH-1:0] fmod_ch0;
wire [FREQ_MOD_WIDTH-1:0] fmod_ch1;
wire [FREQ_MOD_WIDTH-1:0] fmod_ch2;
wire [FREQ_MOD_WIDTH-1:0] fmod_ch3;

wire [PHASE_MOD_WIDTH-1:0] pmod_ch0;
wire [PHASE_MOD_WIDTH-1:0] pmod_ch1;
wire [PHASE_MOD_WIDTH-1:0] pmod_ch2;
wire [PHASE_MOD_WIDTH-1:0] pmod_ch3;

reg [1:0] sel_phi;
reg [1:0] sel_output;

wire [OUTPUT_WIDTH-1:0] sin_value;         
wire [OUTPUT_WIDTH-1:0] cos_value;         

reg [OUTPUT_WIDTH-1:0] sin_value_ch0;         
reg [OUTPUT_WIDTH-1:0] cos_value_ch0;         
reg [OUTPUT_WIDTH-1:0] sin_value_ch1;         
reg [OUTPUT_WIDTH-1:0] cos_value_ch1;         
reg [OUTPUT_WIDTH-1:0] sin_value_ch2;         
reg [OUTPUT_WIDTH-1:0] cos_value_ch2;         
reg [OUTPUT_WIDTH-1:0] sin_value_ch3;         
reg [OUTPUT_WIDTH-1:0] cos_value_ch3;   
reg [OUTPUT_WIDTH-1:0] sin_ch0;         
reg [OUTPUT_WIDTH-1:0] cos_ch0;         
reg [OUTPUT_WIDTH-1:0] sin_ch1;         
reg [OUTPUT_WIDTH-1:0] cos_ch1;         
reg [OUTPUT_WIDTH-1:0] sin_ch2;         
reg [OUTPUT_WIDTH-1:0] cos_ch2;         
reg [OUTPUT_WIDTH-1:0] sin_ch3;         
reg [OUTPUT_WIDTH-1:0] cos_ch3;         

reg valid;
wire out_valid;

reg [OUTPUT_WIDTH-1:0] cos_o;
reg [OUTPUT_WIDTH-1:0] sin_o;
reg startofpacket;
reg endofpacket;
reg out_valid_aligned;
reg output_enable;

//------------------------------------------------------
// NCO component instantiation
//------------------------------------------------------
nco nco_inst  (   		.clk(clk),
                        .reset_n(reset_n),
                        .clken(1'b1),
                        .phi_inc_i(phi),
                        .freq_mod_i(fmod),
                        .phase_mod_i(pmod),
                        .fsin_o(sin_value),
                        .fcos_o(cos_value),
                        .out_valid(out_valid)
    );

//------------------------------------------------------
// Input Channel Selector                   
//------------------------------------------------------
always @(posedge clk or negedge reset_n)                   
    begin                                 
        if(reset_n==1'b0)                     
            begin                             
                sel_phi <= 0;                 
            end                               
        else                  
			sel_phi<=sel_phi+2'b1;             
    end

//------------------------------------------------------
// Channelized Input Phase Increment, Frequency Modulation and Phase Modulation multiplexer                   
//------------------------------------------------------
always @(phi_ch0 or phi_ch1 or phi_ch2 or phi_ch3 or fmod_ch0 or fmod_ch1 or fmod_ch2 or fmod_ch3 or pmod_ch0 or pmod_ch1 or pmod_ch2 or pmod_ch3 or sel_phi)                   
    begin                                 
        case (sel_phi[1:0])
          0: 
            begin 
                phi =phi_ch0;                 
                fmod = fmod_ch0;                 
                pmod = pmod_ch0;                 
            end 
          1: 
            begin 
                phi =  phi_ch1;                 
                fmod = fmod_ch1;                 
                pmod = pmod_ch1;                 
            end 
          2: 
            begin 
                phi = phi_ch2;                 
                fmod = fmod_ch2;                 
                pmod = pmod_ch2;                 
            end 
          3: 
            begin 
                phi = phi_ch3;                 
                fmod = fmod_ch3;                 
                pmod = pmod_ch3;                 
            end 
          default: 
            begin 
                phi = phi_ch0;                 
                fmod = fmod_ch0;                 
                pmod = pmod_ch0;                 
          end 
        endcase        
  end                            

//------------------------------------------------------
// Output Channel Selector                   
//------------------------------------------------------
always @(posedge clk or negedge reset_n)                   
    begin                                 
        if(reset_n==1'b0)                     
            begin                             
                sel_output <= 0;
            end 
        else if(out_valid==1'b1)
            begin
                sel_output<=sel_output+2'b1;
            end
    end

//------------------------------------------------------
// Avalon-ST startofpacket and endofpacket generation
//------------------------------------------------------
always @(posedge clk or negedge reset_n)                   
  begin                                 
    if(reset_n==1'b0)                     
        begin                             
            startofpacket <= 0;   
            endofpacket <= 0;   
        end
    else if(out_valid)
        begin
            startofpacket <= (sel_output == 2'b00);   
            endofpacket   <= (sel_output == 2'b11);   
        end
  end

//------------------------------------------------------
// output sinusoid demultiplexor
//------------------------------------------------------
always @(posedge clk or negedge reset_n)                   
  begin                                 
    if(reset_n==1'b0)                     
      begin                             
        sin_value_ch0 <= 0;               
        cos_value_ch0 <= 0;               
        sin_value_ch1 <= 0;               
        cos_value_ch1 <= 0;               
        sin_value_ch2 <= 0;               
        cos_value_ch2 <= 0;               
        sin_value_ch3 <= 0;               
        cos_value_ch3 <= 0;  
      end
    else if(out_valid)
        begin
            case (sel_output[1:0])        
              0:         
                  begin         
                    sin_value_ch0 <= sin_value;               
                    cos_value_ch0 <= cos_value;               
                  end         
              1:         
                  begin         
                    sin_value_ch1 <= sin_value;               
                    cos_value_ch1 <= cos_value;               
                  end         
              2:         
                  begin         
                    sin_value_ch2 <= sin_value;               
                    cos_value_ch2 <= cos_value;               
                  end         
              3:         
                  begin         
                    sin_value_ch3 <= sin_value;               
                    cos_value_ch3 <= cos_value;               
                  end         
                 default:         
                   begin         
                     sin_value_ch0 <= sin_value;               
                     cos_value_ch0 <= cos_value;    
                   end         
            endcase         
        end
    end

//------------------------------------------------------
// align valid indicator with de-channelized output
//------------------------------------------------------
always @(posedge clk or negedge reset_n)
  begin                                 
    if(reset_n==1'b0)                     
        out_valid_aligned <= 1'b0;
    else if(out_valid == 1'b1 && sel_output == 2'b11)       
        out_valid_aligned <= 1'b1;
    end

//------------------------------------------------------
// Generate enable signal to align demultiplexed output signals
//------------------------------------------------------
always @(posedge clk or negedge reset_n)                   
  begin                                 
    if(reset_n==1'b0)                     
        begin                             
            output_enable <= 1'b0;
        end                               
    else if(out_valid_aligned == 1'b1 && sel_output == 2'b11)       
        begin
            output_enable <= 1'b1;
        end
    else
        begin
            output_enable <= 1'b0;
        end
    end

// Demultiplexed output signal synchronizer

always @(posedge clk or negedge reset_n)                   
  begin                                 
    if(reset_n==1'b0)
        begin                             
            sin_ch0 <= 0;               
            cos_ch0 <= 0;               
            sin_ch1 <= 0;               
            cos_ch1 <= 0;               
            sin_ch2 <= 0;               
            cos_ch2 <= 0;               
            sin_ch3 <= 0;               
            cos_ch3 <= 0;  
      end                               
    else if(output_enable)      
        begin
            sin_ch0 <= sin_value_ch0;               
            cos_ch0 <= cos_value_ch0;               
            sin_ch1 <= sin_value_ch1;               
            cos_ch1 <= cos_value_ch1;               
            sin_ch2 <= sin_value_ch2;               
            cos_ch2 <= cos_value_ch2;               
            sin_ch3 <= sin_value_ch3;               
            cos_ch3 <= cos_value_ch3;               
        end
    end

// Apply single cycle of latency to NCO output signals to align with start and end of packet

always @(posedge clk or negedge reset_n)              
  begin                                 
    if(reset_n==1'b0)
		begin
            valid <= 1'b0;	
            cos_o <= 0;
            sin_o <= 0;		
        end
    else
		begin
            valid <= out_valid;
			cos_o <= cos_value; 
			sin_o <= sin_value; 
		end	
  end
endmodule
