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




`timescale 1 ps / 1 ps


module bidir_delay
(
	inout wire mem, 			
	inout wire phy, 			
 	input wire [31:0] base_delay, 		
	input wire [31:0] delay,		
 	input wire [31:0] bad,	 		
 	input wire [31:0] bad_from_z 		
);


wire [31:0] base_delay_in;
wire [31:0] delay_in;
wire [31:0] bad_in;
wire [31:0] bad_from_z_in;

assign base_delay_in = (base_delay === 'x || base_delay === 'z) ? '0 : base_delay;
assign bad_in = (bad === 'x || bad === 'z) ? '0 : bad;
assign bad_from_z_in = (bad_from_z === 'x || bad_from_z === 'z) ? '0 : bad_from_z;
assign delay_in = (delay === 'x || delay === 'z) ? '0 : delay;

always @(base_delay_in, delay_in, bad_in, bad_from_z_in)
begin
	if (base_delay_in + delay_in < bad_in/2)
	begin
		$display("%m: ERROR: base_delay(%0d) + delay_in(%0d must be >= bad(%0d)/2", 
			 base_delay_in, delay_in, bad_in);
	end
	if (bad_from_z_in > 0 && bad_from_z_in <= 20)
	begin
		$display("%m: ERROR: bad_z must be > 20", bad_from_z_in);
	end
end
		
always @(base_delay_in, bad_in, delay_in)
begin
        $display("%0d [%m] base_delay=%0d bad=%0d bad_z=%0d delay=%0d", 
		 $time, base_delay_in, bad_in, bad_from_z_in, delay_in);
end

reg mem_dly = 1'bz;
reg phy_dly = 1'bz;
reg prev_mem = 1'bz;

always @(mem)
begin
	if (phy_dly === 1'bz || mem === 1'bz)
	begin
		if (mem !== 1'bz)
		begin
			if (bad_from_z_in > 0 && prev_mem === 1'bz)
			begin
				mem_dly <= #(base_delay_in + delay_in) mem;
                                mem_dly <= #(base_delay_in + delay_in + bad_from_z_in - 20) ~mem;
                                mem_dly <= #(base_delay_in + delay_in + bad_from_z_in) mem;
			end
			else
			begin
				if (bad_in > 0)
					mem_dly <= #(base_delay_in - bad_in/2 + delay_in) 1'bx;
				mem_dly <= #(base_delay_in + bad_in/2 + delay_in) mem;
			end
		end
		else
		begin
			mem_dly <= #(base_delay_in + delay_in) mem;
		end
	end
	prev_mem <= mem;
end

always @(phy)
begin
	if (mem_dly === 1'bz || phy === 1'bz)
	begin
		if (phy !== 1'bz)
		begin
			if (bad_in > 0)
				phy_dly <= #(base_delay_in - bad_in/2 + delay_in) 1'bx;
			phy_dly <= #(base_delay_in + bad_in/2 + delay_in) phy;
		end
		else
		begin
			phy_dly <= #(base_delay_in + delay_in) phy;
		end
	end
end

assign phy = mem_dly;
assign mem = phy_dly;

endmodule
