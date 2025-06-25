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


////////////////////////////////////////////////////////////////////////////////
////This is user input address register.
////Read from user input file and shifted per each clock cycle
////////////////////////////////////////////////////////////////////////////////

module user_addr_gen(
	clk,
	reset_n,
	enable,
	ready,
	addr,
	burstcount
);

////////////////////////////////////////////////////////////////////////////////
////BEGIN PARAMETER SECTION

////Avalon signal widths
parameter ADDR_WIDTH		= "";
parameter BURSTCOUNT_WIDTH	= "";
parameter USER_ADDR_ENABLED = 0;
parameter USER_ADDR_BINARY  = 1;
parameter USER_ADDR_DEPTH   = 300;
parameter USER_ADDR_FILE    = "user_input_addr.hex";

////END PARAMETER SECTION
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
////BEGIN PORT SECTION

////Clock and reset
input							clk;
input							reset_n;

////Control and status
input							enable;

////Address generator outputs
output							ready;
output 	[ADDR_WIDTH-1:0]		addr;
output	[BURSTCOUNT_WIDTH-1:0]	burstcount;

////END PORT SECTION
////////////////////////////////////////////////////////////////////////////////

generate
if (USER_ADDR_ENABLED == 1)
begin : addr_gen

    user_input user_input_addr_inst (
    	.clk		(clk),
    	.reset_n	(reset_n),
    	.enable		(enable),
        .ready      	(ready),
    	.data		({addr,burstcount}));
    defparam user_input_addr_inst.DATA_WIDTH            = ADDR_WIDTH + BURSTCOUNT_WIDTH;
    defparam user_input_addr_inst.USER_INPUT_ENABLED    = USER_ADDR_ENABLED;
    defparam user_input_addr_inst.USER_INPUT_BINARY     = USER_ADDR_BINARY;
    defparam user_input_addr_inst.USER_INPUT_DEPTH      = USER_ADDR_DEPTH;
    defparam user_input_addr_inst.USER_INPUT_FILE       = USER_ADDR_FILE;
    defparam user_input_addr_inst.SHOW_AHEAD            = 1;
end
else
begin
    assign addr = '0;
    assign burstcount = '0;
end
endgenerate

endmodule

