// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// ******************************************************************************************************************************** 
// File name: crcerror_verify_core.v
// 
//
//  The ccrcerror_verify_core module checks for false
//  failure conditions before passing on the error to the pin
//   

`include "crcerror_verify_define.iv"

// Turn off verilog processor initialization warning for no_shift_frame*
// altera message_off 10030 


// Prevents redundant modile from being synthesis-out by Quartus  
(* altera_attribute = {"-name PRESERVE_REGISTER ON -to *"} *) 
module crcerror_verify_core (
  inclk,
  reset,
  emr_in,
  emr_done,
  emr_reg_en,
  crcerror_in,
  crcerror_out
);

input inclk;
input reset;
input emr_in;
input emr_done;
input emr_reg_en;
input crcerror_in;
output crcerror_out;

parameter CRC_DIVISOR = -1;
parameter INCLK_FREQ = -1;
parameter INTENDED_DEVICE = `CRCERROR_VERIFY_DEVICE;

// Ceil of the log base 2
function integer CLogB2;
    input [31:0] Depth;
    integer i;
    begin
        i = Depth;        
        for(CLogB2 = 0; i > 0; CLogB2 = CLogB2 + 1)
            i = i >> 1;
    end
endfunction
// rev4.3 update: register to indicate if false failure is detected within the no shift frames
reg no_shift_error; 
// rev4.3 update: The no shift frame addresses for all the Stratix IV devices////
reg [13:0] no_shift_frame1;
reg [13:0] no_shift_frame2;
reg [13:0] no_shift_frame3;
reg [13:0] no_shift_frame4;
reg [13:0] no_shift_frame5;
reg [13:0] no_shift_frame6;
reg [13:0] no_shift_frame7;
reg [13:0] no_shift_frame8;
reg [13:0] no_shift_frame9;
reg [13:0] no_shift_frame10;
reg [13:0] no_shift_frame11;
reg [13:0] no_shift_frame12;
reg [13:0] no_shift_frame13;
reg [13:0] no_shift_frame14;
reg [13:0] no_shift_frame15;
reg [13:0] no_shift_frame16;
reg [13:0] no_shift_frame17;
reg [13:0] no_shift_frame18;
reg [13:0] no_shift_frame19;
reg [13:0] no_shift_frame20;
reg [13:0] no_shift_frame21;
reg [13:0] no_shift_frame22; 
reg [13:0] no_shift_frame23;
reg [13:0] no_shift_frame24; 
reg [13:0] no_shift_frame25;

initial
	begin
		if		(  INTENDED_DEVICE == "EP4SGX70"
				|| INTENDED_DEVICE == "EP4SGX110"
				)
			begin
			no_shift_frame1 = 14'h272;
			no_shift_frame2 = 14'h271;
			no_shift_frame3 = 14'h270;
			no_shift_frame4 = 14'h37e;
			no_shift_frame5 = 14'h47f;
			no_shift_frame6 = 14'ha61;
			no_shift_frame7 = 14'ha60;
			no_shift_frame8 = 14'ha5f;
			no_shift_frame9 = 14'h1400;
			no_shift_frame10 = 14'h13ff;
			no_shift_frame11 = 14'h13fe;
			no_shift_frame12 = 14'h19ca;
			no_shift_frame13 = 14'h1acb;
			no_shift_frame14 = 14'h1bef;
			no_shift_frame15 = 14'h1bee;
			no_shift_frame16 = 14'h1bed;
			no_shift_frame17 = 14'h1bed;
			no_shift_frame18 = 14'h1bed;
			no_shift_frame19 = 14'h1bed;
			no_shift_frame20 = 14'h1bed;
			no_shift_frame21 = 14'h1bed;
			no_shift_frame22 = 14'h1bed;
			no_shift_frame23 = 14'h1bed;
			no_shift_frame24 = 14'h1bed;
			no_shift_frame25 = 14'h1bed;
			end
		else if (  INTENDED_DEVICE == "EP4SGX180"
				|| INTENDED_DEVICE == "EP4SGX230"
				|| INTENDED_DEVICE == "EP4SE230"
				|| INTENDED_DEVICE == "EP4S40G2"
				|| INTENDED_DEVICE == "EP4S100G2"
				|| INTENDED_DEVICE == "EP2AGZ225"
				)
			begin
			no_shift_frame1 = 14'h272;
			no_shift_frame2 = 14'h271;
			no_shift_frame3 = 14'h270;
			no_shift_frame4 = 14'h2236;
			no_shift_frame5 = 14'h2235;
			no_shift_frame6 = 14'h2234;
			no_shift_frame7 = 14'h1d9a;
			no_shift_frame8 = 14'h1d99;
			no_shift_frame9 = 14'h1d98;
			no_shift_frame10 = 14'h17bd;
			no_shift_frame11 = 14'h17bc;
			no_shift_frame12 = 14'h17bb;
			no_shift_frame13 = 14'h1350;
			no_shift_frame14 = 14'h134f;
			no_shift_frame15 = 14'h134e;
			no_shift_frame16 = 14'h279a;
			no_shift_frame17 = 14'h2799;
			no_shift_frame18 = 14'h2798;
			no_shift_frame19 = 14'hdec;
			no_shift_frame20 = 14'hdeb;
			no_shift_frame21 = 14'hdea;
			no_shift_frame22 = 14'h2112; 
			no_shift_frame23 = 14'h2011;
			no_shift_frame24 = 14'h80f; 
			no_shift_frame25 = 14'h70e; 			
			end
		else if (  INTENDED_DEVICE == "EP4SGX290" 
				|| INTENDED_DEVICE == "EP4SGX360" 
				|| INTENDED_DEVICE == "EP4SE360"
				|| INTENDED_DEVICE == "EP2AGZ300"
				|| INTENDED_DEVICE == "EP2AGZ350"
				)
			begin
			no_shift_frame1 = 14'h272;
			no_shift_frame2 = 14'h271;
			no_shift_frame3 = 14'h270;
			no_shift_frame4 = 14'h23EF;
			no_shift_frame5 = 14'h23EE;
			no_shift_frame6 = 14'h23ED;
			no_shift_frame7 = 14'h31C6;
			no_shift_frame8 = 14'h31C5;
			no_shift_frame9 = 14'h31C4;
			no_shift_frame10 = 14'h192A;
			no_shift_frame11 = 14'h1929;
			no_shift_frame12 = 14'h1928;
			no_shift_frame13 = 14'h125B;
			no_shift_frame14 = 14'h125A;
			no_shift_frame15 = 14'h1259;
			no_shift_frame16 = 14'hA80;
			no_shift_frame17 = 14'h96B;
			no_shift_frame18 = 14'h2B2E;
			no_shift_frame19 = 14'h2A2D;
			no_shift_frame20 = 14'h1BB0;
			no_shift_frame21 = 14'h1AAF;
			no_shift_frame22 = 14'hF17; 
			no_shift_frame23 = 14'hE16;
			no_shift_frame24 = 14'hE16;	
			no_shift_frame25 = 14'hE16;	
			end
		else if (  INTENDED_DEVICE == "EP4SGX290N" 
				|| INTENDED_DEVICE == "EP4SGX360N" 
				|| INTENDED_DEVICE == "EP4S100G5"
				|| INTENDED_DEVICE == "EP4S100G4"
				|| INTENDED_DEVICE == "EP4S100G3"
				|| INTENDED_DEVICE == "EP4S40G5"
				|| INTENDED_DEVICE == "EP4SE530"
				|| INTENDED_DEVICE == "EP4SGX530"
				)
			begin 
			no_shift_frame1 = 14'h272;
			no_shift_frame2 = 14'h271;
			no_shift_frame3 = 14'h270;
			no_shift_frame4 = 14'h7c4;
			no_shift_frame5 = 14'h8c5;
			no_shift_frame6 = 14'h126a;
			no_shift_frame7 = 14'h1269;
			no_shift_frame8 = 14'h1268;
			no_shift_frame9 = 14'h18ea;
			no_shift_frame10 = 14'h19eb;
			no_shift_frame11 = 14'h1ed6;
			no_shift_frame12 = 14'h1ed5;
			no_shift_frame13 = 14'h1ed4;
			no_shift_frame14 = 14'h273a;
			no_shift_frame15 = 14'h283b;
			no_shift_frame16 = 14'h3062;
			no_shift_frame17 = 14'h3163;
			no_shift_frame18 = 14'h3654;
			no_shift_frame19 = 14'h3653;
			no_shift_frame20 = 14'h3652;
			no_shift_frame21 = 14'h3652;
			no_shift_frame22 = 14'h3652;
			no_shift_frame23 = 14'h3652;
			no_shift_frame24 = 14'h3652;
			no_shift_frame25 = 14'h3652;
			end
		else if (  INTENDED_DEVICE == "EP4SE820"  )
			begin
			no_shift_frame1 = 14'h456;
			no_shift_frame2 = 14'h455;
			no_shift_frame3 = 14'h454;
			no_shift_frame4 = 14'h8b6;
			no_shift_frame5 = 14'h9b7;
			no_shift_frame6 = 14'h161f;
			no_shift_frame7 = 14'h1720;
			no_shift_frame8 = 14'h23c9;
			no_shift_frame9 = 14'h24ca;
			no_shift_frame10 = 14'h2dbf;
			no_shift_frame11 = 14'h2dbe;
			no_shift_frame12 = 14'h2dbd;
			no_shift_frame13 = 14'h3ba5;
			no_shift_frame14 = 14'h3ba4;
			no_shift_frame15 = 14'h3ba3;
			no_shift_frame16 = 14'h3ba3;
			no_shift_frame17 = 14'h3ba3;
			no_shift_frame18 = 14'h3ba3;
			no_shift_frame19 = 14'h3ba3;
			no_shift_frame20 = 14'h3ba3;
			no_shift_frame21 = 14'h3ba3;
			no_shift_frame22 = 14'h3ba3;
			no_shift_frame23 = 14'h3ba3;
			no_shift_frame24 = 14'h3ba3;
			no_shift_frame25 = 14'h3ba3;
			end
		else if (  INTENDED_DEVICE == "EP2AGX45" 
				|| INTENDED_DEVICE == "EP2AGX65"
				)
			begin 
			no_shift_frame1 = 14'd745;
			no_shift_frame2 = 14'd746;
			no_shift_frame3 = 14'd747;
			no_shift_frame4 = 14'd4180;
			no_shift_frame5 = 14'd4181;
			no_shift_frame6 = 14'd4182;
			no_shift_frame7 = 14'd5016;
			no_shift_frame8 = 14'd5017;
			no_shift_frame9 = 14'd5018;
			no_shift_frame10 = 14'd5018;
			no_shift_frame11 = 14'd5018;
			no_shift_frame12 = 14'd5018;
			no_shift_frame13 = 14'd5018;
			no_shift_frame14 = 14'd5018;
			no_shift_frame15 = 14'd5018;
			no_shift_frame16 = 14'd5018;
			no_shift_frame17 = 14'd5018;
			no_shift_frame18 = 14'd5018;
			no_shift_frame19 = 14'd5018;
			no_shift_frame20 = 14'd5018;
			no_shift_frame21 = 14'd5018;
			no_shift_frame22 = 14'd5018;
			no_shift_frame23 = 14'd5018;
			no_shift_frame24 = 14'd5018;
			no_shift_frame25 = 14'd5018;
			end
		else if (  INTENDED_DEVICE == "EP2AGX95" 
				|| INTENDED_DEVICE == "EP2AGX125"
				)
			begin 
			no_shift_frame1 = 14'd987;
			no_shift_frame2 = 14'd988;
			no_shift_frame3 = 14'd989;
			no_shift_frame4 = 14'd2911;
			no_shift_frame5 = 14'd2912;
			no_shift_frame6 = 14'd2913;
			no_shift_frame7 = 14'd4528;
			no_shift_frame8 = 14'd4529;
			no_shift_frame9 = 14'd4530;
			no_shift_frame10 = 14'd6452;
			no_shift_frame11 = 14'd6453;
			no_shift_frame12 = 14'd6454;
			no_shift_frame13 = 14'd6454;
			no_shift_frame14 = 14'd6454;
			no_shift_frame15 = 14'd6454;
			no_shift_frame16 = 14'd6454;
			no_shift_frame17 = 14'd6454;
			no_shift_frame18 = 14'd6454;
			no_shift_frame19 = 14'd6454;
			no_shift_frame20 = 14'd6454;
			no_shift_frame21 = 14'd6454;
			no_shift_frame22 = 14'd6454;
			no_shift_frame23 = 14'd6454;
			no_shift_frame24 = 14'd6454;
			no_shift_frame25 = 14'd6454;
			end
		else if (  INTENDED_DEVICE == "EP2AGX190" 
				|| INTENDED_DEVICE == "EP2AGX260"
				)
			begin 
			no_shift_frame1 = 14'd987;
			no_shift_frame2 = 14'd988;
			no_shift_frame3 = 14'd989;
			no_shift_frame4 = 14'd4005;
			no_shift_frame5 = 14'd4006;
			no_shift_frame6 = 14'd4007;
			no_shift_frame7 = 14'd5864;
			no_shift_frame8 = 14'd5865;
			no_shift_frame9 = 14'd5866;
			no_shift_frame10 = 14'd8882;
			no_shift_frame11 = 14'd8883;
			no_shift_frame12 = 14'd8884;
			no_shift_frame13 = 14'd8884;
			no_shift_frame14 = 14'd8884;
			no_shift_frame15 = 14'd8884;
			no_shift_frame16 = 14'd8884;
			no_shift_frame17 = 14'd8884;
			no_shift_frame18 = 14'd8884;
			no_shift_frame19 = 14'd8884;
			no_shift_frame20 = 14'd8884;
			no_shift_frame21 = 14'd8884;
			no_shift_frame22 = 14'd8884;
			no_shift_frame23 = 14'd8884;
			no_shift_frame24 = 14'd8884;
			no_shift_frame25 = 14'd8884;
			end
	end	


// Circuitry full cycle time table
function integer get_ed_cycle_time_div256;

   input dummy;
	begin
		if		(  INTENDED_DEVICE == "EP4SGX70"
				|| INTENDED_DEVICE == "EP4SGX110"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_1;
		else if (  INTENDED_DEVICE == "EP4SGX180"
				|| INTENDED_DEVICE == "EP4SGX230"
				|| INTENDED_DEVICE == "EP4SE230"
				|| INTENDED_DEVICE == "EP4S40G2"
				|| INTENDED_DEVICE == "EP4S100G2"
				|| INTENDED_DEVICE == "EP2AGZ225"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_2;
		else if (  INTENDED_DEVICE == "EP4SGX290" 
				|| INTENDED_DEVICE == "EP4SGX360" 
				|| INTENDED_DEVICE == "EP4SE360"
				|| INTENDED_DEVICE == "EP2AGZ300"
				|| INTENDED_DEVICE == "EP2AGZ350"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_3;
		else if (  INTENDED_DEVICE == "EP4SGX290N" 
				|| INTENDED_DEVICE == "EP4SGX360N" 
				|| INTENDED_DEVICE == "EP4S100G5"
				|| INTENDED_DEVICE == "EP4S100G4"
				|| INTENDED_DEVICE == "EP4S100G3"
				|| INTENDED_DEVICE == "EP4S40G5"
				|| INTENDED_DEVICE == "EP4SE530"
				|| INTENDED_DEVICE == "EP4SGX530"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_4;
		else if (  INTENDED_DEVICE == "EP4SE820" )
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_5;
		else if (  INTENDED_DEVICE == "EP2AGX45" 
				|| INTENDED_DEVICE == "EP2AGX65"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_6;
		else if (  INTENDED_DEVICE == "EP2AGX95" 
				|| INTENDED_DEVICE == "EP2AGX125"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_7;
		else if (  INTENDED_DEVICE == "EP2AGX190" 
				|| INTENDED_DEVICE == "EP2AGX260"
				)
			get_ed_cycle_time_div256 = `ACEV_CYCLE_TIME_DIV256_8;
	end	
endfunction

localparam ED_CYCLE_TIME_DIV256 = get_ed_cycle_time_div256(1'b0);


parameter MAX_COUNT = ((ED_CYCLE_TIME_DIV256*CRC_DIVISOR*INCLK_FREQ)/256)+(((ED_CYCLE_TIME_DIV256*CRC_DIVISOR*INCLK_FREQ)%256)==0?0:1);
parameter COUNT_1M = 1000000;
parameter MAX_COUNT_WIDTH = CLogB2(MAX_COUNT);
parameter COUNT_1M_WIDTH = CLogB2(COUNT_1M);
parameter FRAMES_MIN = 6;
parameter FRAMES_MAX = 2000;
parameter FAIL_COUNT_MAX = 5;

parameter 
// Idle state
     state_idle = 3'b000,
// False intermittent errors
    state_falseerror = 3'b001,
// Consistent multiple bit single data line failure
    state_single_dl = 3'b010,
// Real SEU error
    state_realerror = 3'b011;
    
reg [MAX_COUNT_WIDTH-1:0] cycle_count;
reg [3:0] fail_count;
reg [COUNT_1M_WIDTH-1:0] counter_1m;
reg false_error;
reg [45:0] emr_reg;
reg [2:0]    cs,ns;
reg single_dl;
reg single_dl_monitor;
reg force_real_error;
reg first_loc_updated;
reg [13:0] min_frame;
reg [13:0] max_frame;
reg [10:0] prev_byte;
reg [2:0] prev_bit;
reg wait_for_second_loc;// rev4.4 update: added new register to track the second EMR comparison after the first ERMA is captured
reg reset_prev_error; //rev4.6 update: register to trigger reset of previous EMR info


reg crcerror_gate;
reg crcerror_release_gate;

wire [13:0] error_frame;
wire [10:0] error_byte;
wire [2:0] error_bit;
wire [1:0] error_type;

wire crc_cycle_done;

always @(posedge reset or posedge inclk) begin
    if(reset) begin
        emr_reg <= 46'b0;
    end
    else if (emr_done == 1'b0 && emr_reg_en == 1'b1) begin
        emr_reg[45:0] <= {emr_in, emr_reg[45:1]};
    end
	else if (reset_prev_error & ns == state_idle) emr_reg <= 46'b0;	
	
end

assign error_frame[13:0] = emr_reg[29:16];
assign error_byte[10:0] = emr_reg[15:5];
assign error_bit[2:0] = emr_reg[4:2];
assign error_type[1:0] = emr_reg[1:0];

always @(posedge reset or posedge inclk)
begin
    if (reset)
    begin
        single_dl <= 1'b0;
		  single_dl_monitor <= 1'b0;
	     force_real_error <= 1'b0;
        first_loc_updated <= 1'b0;
		  wait_for_second_loc <= 1'b0; // rev4.4 update: initialize register per reset signal
        min_frame <= 14'b0;
        max_frame <= 14'b0;
        prev_byte <= 11'b0;
        prev_bit <= 3'b0;
// rev4.3 update: initialize register per reset signal
        no_shift_error <= 1'b0;
    end
	else if (reset_prev_error)	
	begin
		first_loc_updated <= 1'b0;
		wait_for_second_loc <= 1'b0;
	end
    else if (emr_done && error_type != 2'b00)
    begin
// rev4.3 update:new 'if' statement to check the frame address in the EMR, if the frame address matches with anyone of the no shift frame address, set the 'no_shift_error' register
          if (error_frame == no_shift_frame1 
	  				|| error_frame == no_shift_frame2 
					|| error_frame == no_shift_frame3 
					|| error_frame == no_shift_frame4 
					|| error_frame == no_shift_frame5 
					|| error_frame == no_shift_frame6 
					|| error_frame == no_shift_frame7 
					|| error_frame == no_shift_frame8 
					|| error_frame == no_shift_frame9 
					||error_frame == no_shift_frame10 
					||error_frame == no_shift_frame11 
					||error_frame == no_shift_frame12 
					||error_frame == no_shift_frame13 
					||error_frame == no_shift_frame14 
					||error_frame == no_shift_frame15 
					||error_frame == no_shift_frame16 
					||error_frame == no_shift_frame17 
					||error_frame == no_shift_frame18 
					||error_frame == no_shift_frame19 
					||error_frame == no_shift_frame20 
					||error_frame == no_shift_frame21 
					||error_frame == no_shift_frame22 
					||error_frame == no_shift_frame23 
					||error_frame == no_shift_frame24 
					||error_frame == no_shift_frame25)
				   begin
					  single_dl <= single_dl;
					  single_dl_monitor <= single_dl_monitor;
					  no_shift_error <= 1'b1;
					  wait_for_second_loc <= wait_for_second_loc; 
					end
// rev4.3 update: if the EMR frame address does not match with the no shift frame address, continue to check for single data line error.
				else if (error_type == 2'b01 && first_loc_updated == 1'b0)
				  begin
						first_loc_updated <= 1'b1;
						min_frame <= error_frame;
						max_frame <= error_frame;
						prev_byte <= error_byte;
						prev_bit <= error_bit;
						no_shift_error <= 1'b0;
						wait_for_second_loc <= wait_for_second_loc;
				  end
        
        else if (error_type == 2'b01 && first_loc_updated == 1'b1)
        begin
            first_loc_updated <= 1'b1;
				  if (error_byte ==  prev_byte && error_bit == prev_bit && error_frame < min_frame && max_frame - error_frame < FRAMES_MAX) min_frame = error_frame;
              if (error_byte ==  prev_byte && error_bit == prev_bit && error_frame > max_frame && error_frame - min_frame < FRAMES_MAX) max_frame = error_frame;
              if (error_byte ==  prev_byte && error_bit == prev_bit && error_frame-min_frame < FRAMES_MAX && max_frame-min_frame >= FRAMES_MIN)
              begin
                single_dl <= 1'b1;
                single_dl_monitor <= 1'b1;
                no_shift_error <= 1'b0;
					 wait_for_second_loc <= 1'b0;
              end
				  // rev4.4 update: added new condition to flag real SEU if the next set of EMR checking shows non single dl error
              else if ((error_byte ==  prev_byte && error_bit == prev_bit && error_frame-min_frame >= FRAMES_MAX)||((error_byte !=  prev_byte || error_bit != prev_bit)&& wait_for_second_loc == 1'b1))
              begin
                single_dl_monitor <= 1'b0;
                force_real_error <= 1'b1;
                no_shift_error <= 1'b0;
					 wait_for_second_loc <= 1'b0;
              end
				   // rev4.4 update: added new condition to check multiple single data line error
				  else if ((error_byte !=  prev_byte || error_bit != prev_bit)&& wait_for_second_loc == 1'b0)
                begin
                  first_loc_updated <= 1'b0;
                  wait_for_second_loc <= 1'b1;
                end   
			end
        
       
        else 
        begin
            force_real_error <= 1'b1;
            single_dl_monitor <= 1'b0;
            no_shift_error <= 1'b0;
       end
    end
end

always @(posedge reset or posedge inclk)                                     
begin                                                                        
    if (reset)                                                               
    begin                                                                    
        crcerror_gate <= 1'b0;                                               
        crcerror_release_gate <= 1'b0;                                       
    end                                                                      
    else if ( crcerror_in == 1'b0 )                                          
    begin                                                                    
        crcerror_gate <= 1'b1;                                               
        crcerror_release_gate <= 1'b0;                                       
    end                                                                      
    else if ( emr_done == 2'b0 )                                             
    begin                                                                    
        crcerror_gate <= 1'b1;                                               
        crcerror_release_gate <= 1'b1;                                       
    end                                                                      
    else if ( emr_done == 1'b1 && crcerror_release_gate == 1'b1)             
    begin                                                                    
        crcerror_gate <= 1'b0;                                               
        crcerror_release_gate <= 1'b0;                                       
    end                                                                      
end   
     
assign crcerror_out     = (crcerror_in && (cs == state_realerror) && !single_dl_monitor && (~crcerror_gate));
assign crc_cycle_done   = (cycle_count>=MAX_COUNT && counter_1m>=COUNT_1M-1);

// Check for intermittent errors:
//  Initialize fail_count, false_error and real_error to 0
//  Initialize counter C to 0
//  Whenever CRCERROR occurs, 
//  Whenever C reaches Max ED cycle time
//  Reset counter C to 0
//  If false_error == 1, increment fail_count 
//  If false_error == 0, reset fail_count to 0
//  If fail_count > 5 (FAIL_COUNT_MAX), set real_error to 1

always @(posedge reset or posedge inclk)                                     
begin
    if (reset)
    begin
        fail_count <= 4'b0;
        false_error <= 1'b0;
        cycle_count <= 0;
        counter_1m <= 0;
		reset_prev_error <= 1'b0;	
    end
//  rev4.3 update: add '!no_shift_error' in this condition to make sure the no shift frame error will not be counted in the fail count
    else if (crc_cycle_done && !no_shift_error) 
    begin
        cycle_count <= 0;
        counter_1m <= 0;
        false_error <= 1'b0;
        if (cs == state_falseerror)
            fail_count <= fail_count+4'b1;
        else 
		begin
            fail_count <= 4'b0;
			reset_prev_error <= 1'b1;	
		end
    end
    else if (counter_1m>=COUNT_1M-1)
    begin
        if (crcerror_in == 1'b1) false_error <= 1'b1;
        cycle_count <= cycle_count + 1'b1;
        counter_1m <= 0;
    end
    else 
    begin
        if (crcerror_in == 1'b1) false_error <= 1'b1;
        counter_1m <= counter_1m + 1'b1;
		if (first_loc_updated == 1'b0 && wait_for_second_loc == 1'b0) reset_prev_error <= 1'b0;
    end
end

always @(cs or crcerror_in or fail_count or single_dl or force_real_error or crc_cycle_done or false_error)
    begin
     ns = cs;
      casex (cs)
      
        state_idle:
            if(crcerror_in)
                ns = state_falseerror;
              else
                ns = state_idle;

        state_falseerror:
         if (force_real_error == 1'b1)
             ns = state_realerror;
         else if (fail_count >= FAIL_COUNT_MAX && single_dl)
             ns = state_single_dl;
         else if (fail_count >= FAIL_COUNT_MAX)
             ns = state_realerror;
		 else if (crc_cycle_done == 1'b1)
             ns = state_idle;
         else
             ns = state_falseerror;
        
        state_single_dl:
            if(force_real_error == 1'b1)
                ns = state_realerror;
            else
                ns = state_single_dl;

        state_realerror:
            ns = state_realerror;
                        
        default:
            ns =  state_idle;
      
    endcase 
end 


always @(posedge inclk or posedge reset)
begin
        if(reset)
         begin
            cs <= state_idle;
         end
        else
         begin
            cs <= ns;
         end
end

endmodule
