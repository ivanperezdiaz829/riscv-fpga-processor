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



module	vga_driver	(
		r,g,b,
		current_x,current_y,request,
		vga_r,vga_g,vga_b,vga_hs,vga_vs,vga_blank,vga_clock,
		clk27,rst27,
		h_front, h_sync, h_back, h_act,
		v_front, v_sync, v_back, v_act);

input [15:0]	r,g,b;
output [15:0] current_x;
output [15:0] current_y;
output request;

output [15:0] vga_r, vga_g, vga_b;
output vga_hs, vga_vs, vga_blank, vga_clock;

input clk27, rst27;

input [15:0] h_front, h_sync, h_back, h_act;
input [15:0] v_front, v_sync, v_back, v_act;
//	Horizontal	Timing
parameter	H_FRONT	=	16;
parameter	H_SYNC	=	96;
parameter	H_BACK	=	48;
parameter	H_ACT	=	640;
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;

//	Vertical Timing
parameter	V_FRONT	=	11;
parameter	V_SYNC	=	2;
parameter	V_BACK	=	31;
parameter	V_ACT	=	480;
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;

reg [15:0] h_front_i=0, h_sync_i=0, h_back_i=0, h_act_i=0, h_blank_i=0, h_total_i=0;
reg [15:0] v_front_i=0, v_sync_i=0, v_back_i=0, v_act_i=0, v_blank_i=0, v_total_i=0;

////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////

reg [15:0] h_cntr, v_cntr, current_x, current_y;
reg h_active, v_active, vga_hs, vga_vs;

//1002 assign	vga_blank = h_active & v_active;
assign	vga_blank = ~(h_active & v_active);
assign	vga_clock = ~clk27;
assign	vga_r = r;
assign	vga_g = g;
assign	vga_b = b;
assign	request	= ((h_cntr>=h_blank_i && h_cntr<h_total_i)	&&
						 (v_cntr>=v_blank_i && v_cntr<v_total_i));

always @(posedge clk27 or posedge rst27) begin
	if(rst27) begin
		h_cntr <= 0;
		v_cntr <= 0;
		vga_hs <= 1'b1;
		vga_vs <= 1'b1;
		current_x <= 0;
		current_y <= 0;
		h_active <= 1'b0;
		v_active <= 1'b0;
	end
	else begin
		if(h_cntr != h_total_i) begin
			h_cntr <= h_cntr + 1'b1;
			if (h_active) current_x <= current_x + 1'b1;
			if (h_cntr == h_blank_i-1) h_active <= 1'b1;
		end
		else begin
			h_cntr	<= 0;
			h_active <= 1'b0;
			current_x <= 0;
		end
		
		if(h_cntr == h_front_i-1) begin
			vga_hs <= 1'b0;
		end		
		
		if (h_cntr == h_front_i+h_sync_i-1) begin
			vga_hs <= 1'b1;
			
			if(v_cntr != v_total_i) begin
				v_cntr <= v_cntr + 1'b1;
				if (v_active) current_y <= current_y + 1'b1;
				if (v_cntr == v_blank_i-1) v_active <= 1'b1;
			end
			else begin
				v_cntr <= 0;
				current_y <= 0;
				v_active <= 1'b0;
			end
			if(v_cntr == v_front_i-1) vga_vs <= 1'b0;
			if(v_cntr == v_front_i+v_sync_i-1) vga_vs <= 1'b1;
		end
	end
end

// Change resolutions at begingin of vertical blanking period
always @(posedge clk27 or posedge rst27) 
	if(rst27) begin
	{h_front_i, h_sync_i, h_back_i, h_act_i, h_blank_i, h_total_i} <=
	{H_FRONT, H_SYNC, H_BACK, H_ACT, H_FRONT+H_SYNC+H_BACK, H_FRONT+H_SYNC+H_BACK+H_ACT};
    {v_front_i, v_sync_i, v_back_i, v_act_i, v_blank_i, v_total_i} <= 
	{V_FRONT, V_SYNC, V_BACK, V_ACT, V_FRONT+V_SYNC+V_BACK, V_FRONT+V_SYNC+V_BACK+V_ACT};
	end
else if(v_cntr == v_front_i+v_sync_i-1)	begin
	{h_front_i, h_sync_i, h_back_i, h_act_i, h_blank_i, h_total_i} <=
	{h_front, h_sync, h_back, h_act, h_front+h_sync+h_back, h_front+h_sync+h_back+h_act};
    {v_front_i, v_sync_i, v_back_i, v_act_i, v_blank_i, v_total_i} <= 
	{v_front, v_sync, v_back, v_act, v_front+v_sync+v_back, v_front+v_sync+v_back+v_act};
	end

parameter FRAME_TOTAL = 32;
reg vga_vs_1d;
always @(posedge clk27 or posedge rst27)
	if(rst27) begin
		vga_vs_1d <= 0;
	end
	else begin
		vga_vs_1d <= vga_vs;
	end

reg [5:0] frame_cnt;
wire vsync_1p = ~vga_vs & vga_vs_1d;
always @(posedge clk27 or posedge rst27)
	if(rst27) begin
		frame_cnt <= 0;
    end
	else if(vsync_1p) begin
		frame_cnt <= frame_cnt + 1'b1;
	end

wire frame_overflow =(frame_cnt >= FRAME_TOTAL);

always @ (posedge frame_overflow)
begin
	$display("Simulation Hang");
	$stop();
end

always @ (posedge vsync_1p)
 $display("Testing Video Input Frame Number = %h", frame_cnt);

	
endmodule
