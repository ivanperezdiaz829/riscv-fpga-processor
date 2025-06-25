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


module config_controller
(
	padtoinputregisterdelaysetting,
	padtoinputregisterrisefalldelaysetting,
	outputdelaysetting1,
	outputdelaysetting2,
	inputclkndelaysetting,
	inputclkdelaysetting,
	dutycycledelaymode,
	dutycycledelaysetting,
	
	dqsbusoutdelaysetting,
	dqsbusoutdelaysetting2,
	octdelaysetting1,
	octdelaysetting2,
	addrphasesetting,
	addrpowerdown,
	addrphaseinvert,
	dqsoutputphasesetting,
	dqsoutputpowerdown,
	dqsoutputphaseinvert,
	dqoutputphasesetting,
	dqoutputpowerdown,
	dqoutputphaseinvert,
	resyncinputphasesetting,
	resyncinputpowerdown,
	resyncinputphaseinvert,
	postamblephasesetting,
	postamblepowerdown,
	postamblephaseinvert,
	dqs2xoutputphasesetting,
	dqs2xoutputpowerdown,
	dqs2xoutputphaseinvert,
	dq2xoutputphasesetting,
	dq2xoutputpowerdown,
	dq2xoutputphaseinvert,
	ck2xoutputphasesetting,
	ck2xoutputpowerdown,
	ck2xoutputphaseinvert,
	dqoutputzerophasesetting,
	postamblezerophasesetting,
	postamblezeropowerdown,
	dividerioehratephaseinvert,
	dividerphaseinvert,
	enaoctcycledelaysetting,
	enaoctphasetransferreg,
	dqsdisablendelaysetting,
	dqsenabledelaysetting,
	enadqsenablephasetransferreg,
	dqsinputphasesetting,
	enadqsphasetransferreg,
	enaoutputphasetransferreg,
	enadqscycledelaysetting,
	enaoutputcycledelaysetting,
	enainputcycledelaysetting,
	enainputphasetransferreg,

	clk,
	reset_n,
	beginscan,
	
	config_data,
	config_dqs_ena,
	config_io_ena,
	config_dqs_io_ena,
	config_update,
	
	scandone
);

parameter NUM_IO = 4;
parameter NUM_DQS = 1;

localparam NUM_IO_CONFIG = NUM_IO + NUM_DQS; 
localparam NUM_DQS_CONFIG = NUM_DQS;
localparam DELAY_CHAIN_WIDTH = 5;


input [NUM_IO_CONFIG * 6 - 1 : 0] padtoinputregisterdelaysetting;
input [NUM_IO_CONFIG * 6 - 1 : 0] padtoinputregisterrisefalldelaysetting;
input [NUM_IO_CONFIG * 6 - 1 : 0] outputdelaysetting1;
input [NUM_IO_CONFIG * 6 - 1 : 0] outputdelaysetting2;
input [NUM_IO_CONFIG * 2 - 1 : 0] inputclkndelaysetting;
input [NUM_IO_CONFIG * 2 - 1 : 0] inputclkdelaysetting;
input [NUM_IO_CONFIG * 1 - 1 : 0] dutycycledelaymode;
input [NUM_IO_CONFIG * 4 - 1 : 0] dutycycledelaysetting;

input [NUM_DQS_CONFIG * 6 - 1 : 0] dqsbusoutdelaysetting;
input [NUM_DQS_CONFIG * 6 - 1 : 0] dqsbusoutdelaysetting2;
input [NUM_DQS_CONFIG * 6 - 1 : 0] octdelaysetting1;
input [NUM_DQS_CONFIG * 6 - 1 : 0] octdelaysetting2;
input [NUM_DQS_CONFIG * 2 - 1 : 0] addrphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] addrpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] addrphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dqsoutputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqsoutputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqsoutputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dqoutputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqoutputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqoutputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] resyncinputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] resyncinputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] resyncinputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] postamblephasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] postamblepowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] postamblephaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dqs2xoutputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqs2xoutputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqs2xoutputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dq2xoutputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dq2xoutputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dq2xoutputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] ck2xoutputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] ck2xoutputpowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] ck2xoutputphaseinvert;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dqoutputzerophasesetting;
input [NUM_DQS_CONFIG * 2 - 1 : 0] postamblezerophasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] postamblezeropowerdown;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dividerioehratephaseinvert;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dividerphaseinvert;
input [NUM_DQS_CONFIG * 3 - 1 : 0] enaoctcycledelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enaoctphasetransferreg;
input [NUM_DQS_CONFIG * 8 - 1 : 0] dqsdisablendelaysetting;
input [NUM_DQS_CONFIG * 8 - 1 : 0] dqsenabledelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enadqsenablephasetransferreg;
input [NUM_DQS_CONFIG * 2 - 1 : 0] dqsinputphasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enadqsphasetransferreg;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enaoutputphasetransferreg;
input [NUM_DQS_CONFIG * 3 - 1 : 0] enadqscycledelaysetting;
input [NUM_DQS_CONFIG * 3 - 1 : 0] enaoutputcycledelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enainputcycledelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enainputphasetransferreg;

input clk;
input beginscan;
input reset_n;

output reg config_data;
output reg [NUM_DQS - 1 : 0] config_dqs_ena;
output reg [NUM_IO - 1 : 0] config_io_ena;
output reg [NUM_DQS - 1 : 0] config_dqs_io_ena;
output reg config_update;
	
output reg scandone;

reg scanning;
always @(posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		scanning <= 1'b0;
	end
	else
	begin
		scanning <= ~scandone & (beginscan | scanning);
	end
end

localparam IO_CONFIG_SC_LENGTH = 40;
localparam DQS_CONFIG_SC_LENGTH = 101;
localparam SCANCHAIN_LENGTH = NUM_IO_CONFIG * IO_CONFIG_SC_LENGTH + NUM_DQS_CONFIG * DQS_CONFIG_SC_LENGTH;
reg [NUM_IO_CONFIG * IO_CONFIG_SC_LENGTH - 1 : 0] io_config_scanchain;
reg [NUM_DQS_CONFIG * DQS_CONFIG_SC_LENGTH - 1 : 0] dqs_config_scanchain;
reg [SCANCHAIN_LENGTH - 1 : 0] scanchain;

genvar io_config;
genvar dqs_config;
generate
begin
	for (io_config = 0; io_config < NUM_IO_CONFIG; io_config = io_config + 1)
	begin : IO_CONFIG_SC_GEN
		always @(posedge clk)
		begin
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 5 : io_config * IO_CONFIG_SC_LENGTH + 0] <= padtoinputregisterdelaysetting[(io_config + 1) * 6 - 1 : io_config * 6];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 11 : io_config * IO_CONFIG_SC_LENGTH + 6] <= padtoinputregisterrisefalldelaysetting[(io_config + 1) * 6 - 1 : io_config * 6];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 17 : io_config * IO_CONFIG_SC_LENGTH + 12] <= outputdelaysetting1[(io_config + 1) * 6 - 1 : io_config * 6];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 23 : io_config * IO_CONFIG_SC_LENGTH + 18] <= outputdelaysetting2[(io_config + 1) * 6 - 1 : io_config * 6];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 25 : io_config * IO_CONFIG_SC_LENGTH + 24] <= inputclkndelaysetting[(io_config + 1) * 2 - 1 : io_config * 2];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 27 : io_config * IO_CONFIG_SC_LENGTH + 26] <= inputclkdelaysetting[(io_config + 1) * 2 - 1 : io_config * 2];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 32 : io_config * IO_CONFIG_SC_LENGTH + 28] <= 5'b00000;
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 33 : io_config * IO_CONFIG_SC_LENGTH + 33] <= dutycycledelaymode[(io_config + 1) * 1 - 1 : io_config * 1];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 34 : io_config * IO_CONFIG_SC_LENGTH + 34] <= 1'b0;
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 38 : io_config * IO_CONFIG_SC_LENGTH + 35] <= dutycycledelaysetting[(io_config + 1) * 4 - 1 : io_config * 4];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 39 : io_config * IO_CONFIG_SC_LENGTH + 39] <= 1'b0;
		end
	end
	
	for (dqs_config = 0; dqs_config < NUM_DQS_CONFIG; dqs_config = dqs_config + 1)
	begin : DQS_CONFIG_SC_GEN
		always @(posedge clk)
		begin
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 5 : dqs_config * DQS_CONFIG_SC_LENGTH + 0] <= dqsbusoutdelaysetting[(dqs_config + 1) * 6 - 1 : dqs_config * 6];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 11 : dqs_config * DQS_CONFIG_SC_LENGTH + 6] <= dqsbusoutdelaysetting2[(dqs_config + 1) * 6 - 1 : dqs_config * 6];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 17 : dqs_config * DQS_CONFIG_SC_LENGTH + 12] <= octdelaysetting1[(dqs_config + 1) * 6 - 1 : dqs_config * 6];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 23 : dqs_config * DQS_CONFIG_SC_LENGTH + 18] <= octdelaysetting2[(dqs_config + 1) * 6 - 1 : dqs_config * 6];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 25 : dqs_config * DQS_CONFIG_SC_LENGTH + 24] <= addrphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 26 : dqs_config * DQS_CONFIG_SC_LENGTH + 26] <= addrpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 27 : dqs_config * DQS_CONFIG_SC_LENGTH + 27] <= addrphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 29 : dqs_config * DQS_CONFIG_SC_LENGTH + 28] <= dqsoutputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 30 : dqs_config * DQS_CONFIG_SC_LENGTH + 30] <= dqsoutputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 31 : dqs_config * DQS_CONFIG_SC_LENGTH + 31] <= dqsoutputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 33 : dqs_config * DQS_CONFIG_SC_LENGTH + 32] <= dqoutputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 34 : dqs_config * DQS_CONFIG_SC_LENGTH + 34] <= 1'b0;
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 35 : dqs_config * DQS_CONFIG_SC_LENGTH + 35] <= dqoutputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 36 : dqs_config * DQS_CONFIG_SC_LENGTH + 36] <= dqoutputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 38 : dqs_config * DQS_CONFIG_SC_LENGTH + 37] <= resyncinputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 39 : dqs_config * DQS_CONFIG_SC_LENGTH + 39] <= resyncinputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 40 : dqs_config * DQS_CONFIG_SC_LENGTH + 40] <= resyncinputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 42 : dqs_config * DQS_CONFIG_SC_LENGTH + 41] <= postamblephasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 43 : dqs_config * DQS_CONFIG_SC_LENGTH + 43] <= 1'b0;
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 44 : dqs_config * DQS_CONFIG_SC_LENGTH + 44] <= postamblepowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 45 : dqs_config * DQS_CONFIG_SC_LENGTH + 45] <= postamblephaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 47 : dqs_config * DQS_CONFIG_SC_LENGTH + 46] <= dqs2xoutputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 48 : dqs_config * DQS_CONFIG_SC_LENGTH + 48] <= dqs2xoutputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 49 : dqs_config * DQS_CONFIG_SC_LENGTH + 49] <= dqs2xoutputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 51 : dqs_config * DQS_CONFIG_SC_LENGTH + 50] <= dq2xoutputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 52 : dqs_config * DQS_CONFIG_SC_LENGTH + 52] <= 1'b0;
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 53 : dqs_config * DQS_CONFIG_SC_LENGTH + 53] <= dq2xoutputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 54 : dqs_config * DQS_CONFIG_SC_LENGTH + 54] <= dq2xoutputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 56 : dqs_config * DQS_CONFIG_SC_LENGTH + 55] <= ck2xoutputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 57 : dqs_config * DQS_CONFIG_SC_LENGTH + 57] <= ck2xoutputpowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 58 : dqs_config * DQS_CONFIG_SC_LENGTH + 58] <= ck2xoutputphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 60 : dqs_config * DQS_CONFIG_SC_LENGTH + 59] <= dqoutputzerophasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 62 : dqs_config * DQS_CONFIG_SC_LENGTH + 61] <= postamblezerophasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 63 : dqs_config * DQS_CONFIG_SC_LENGTH + 63] <= postamblezeropowerdown[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 64 : dqs_config * DQS_CONFIG_SC_LENGTH + 64] <= dividerioehratephaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 65 : dqs_config * DQS_CONFIG_SC_LENGTH + 65] <= dividerphaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 68 : dqs_config * DQS_CONFIG_SC_LENGTH + 66] <= enaoctcycledelaysetting[(dqs_config + 1) * 3 - 1 : dqs_config * 3];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 69 : dqs_config * DQS_CONFIG_SC_LENGTH + 69] <= enaoctphasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 77 : dqs_config * DQS_CONFIG_SC_LENGTH + 70] <= dqsdisablendelaysetting[(dqs_config + 1) * 8 - 1 : dqs_config * 8];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 85 : dqs_config * DQS_CONFIG_SC_LENGTH + 78] <= dqsenabledelaysetting[(dqs_config + 1) * 8 - 1 : dqs_config * 8];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 86 : dqs_config * DQS_CONFIG_SC_LENGTH + 86] <= enadqsenablephasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 88 : dqs_config * DQS_CONFIG_SC_LENGTH + 87] <= dqsinputphasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 89 : dqs_config * DQS_CONFIG_SC_LENGTH + 89] <= enadqsphasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 90 : dqs_config * DQS_CONFIG_SC_LENGTH + 90] <= enaoutputphasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 93 : dqs_config * DQS_CONFIG_SC_LENGTH + 91] <= enadqscycledelaysetting[(dqs_config + 1) * 3 - 1 : dqs_config * 3];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 96 : dqs_config * DQS_CONFIG_SC_LENGTH + 94] <= enaoutputcycledelaysetting[(dqs_config + 1) * 3 - 1 : dqs_config * 3];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 97 : dqs_config * DQS_CONFIG_SC_LENGTH + 97] <= enainputcycledelaysetting[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 98 : dqs_config * DQS_CONFIG_SC_LENGTH + 98] <= enainputphasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 100 : dqs_config * DQS_CONFIG_SC_LENGTH + 99] <= 2'b00;
		end
	end
end
endgenerate

always @(posedge clk)
begin
	if (~scanning) begin
		scanchain <= {dqs_config_scanchain, io_config_scanchain};
	end
	else
	begin
		scanchain <= {1'b0, scanchain[SCANCHAIN_LENGTH-1:1]};
	end
	config_data <= scanchain[0];
end
		
typedef enum integer {
	IDLE,
	IO_CONFIG_SCAN,
	DQS_IO_CONFIG_SCAN,
	DQS_CONFIG_SCAN,
	CONFIG_UPDATE,
	CONFIG_DONE
} state_t;

state_t state;
reg [5:0] current_io_config;
reg [5:0] current_dqs_io_config;
reg [5:0] current_dqs_config;
reg [7:0] scan_chain_counter;

always @(posedge clk or negedge reset_n)
begin
	if (~reset_n)
	begin
		state <= IDLE;
		scandone <= 1'b0;
	end else begin
		config_io_ena <= {NUM_IO{1'b0}};
		config_dqs_io_ena <= {NUM_DQS{1'b0}};
		config_dqs_ena <= {NUM_DQS{1'b0}};
		config_update <= 1'b0;
		scandone <= 1'b0;
		case (state)
			IDLE:
			begin
				if (beginscan)
				begin
					state <= IO_CONFIG_SCAN;
					current_io_config <= 'b0;
					scan_chain_counter <= 'b0;
				end
			end
			
			IO_CONFIG_SCAN:
			begin
				config_io_ena <= (1'b1 << current_io_config);
				if (current_io_config == NUM_IO - 1 && scan_chain_counter == IO_CONFIG_SC_LENGTH - 1) begin
					state <= DQS_IO_CONFIG_SCAN;
					current_dqs_io_config <= 'b0;
					scan_chain_counter <= 'b0;
				end else if (scan_chain_counter == IO_CONFIG_SC_LENGTH - 1) begin
					current_io_config <= current_io_config + 1'b1;
					scan_chain_counter <= 'b0;
				end else begin
					scan_chain_counter <= scan_chain_counter + 1'b1;
				end
			end
			
			DQS_IO_CONFIG_SCAN:
			begin
				config_dqs_io_ena <= (1'b1 << current_dqs_io_config);
				if (current_dqs_io_config == NUM_DQS - 1 && scan_chain_counter == IO_CONFIG_SC_LENGTH - 1) begin
					state <= DQS_CONFIG_SCAN;
					current_dqs_config <= 'b0;
					scan_chain_counter <= 'b0;
				end else if (scan_chain_counter == IO_CONFIG_SC_LENGTH - 1) begin
					current_dqs_io_config <= current_dqs_io_config + 1'b1;
					scan_chain_counter <= 'b0;
				end else begin
					scan_chain_counter <= scan_chain_counter + 1'b1;
				end
			end
			
			DQS_CONFIG_SCAN:
			begin
				config_dqs_ena <= (1'b1 << current_dqs_config);
				if (current_dqs_config == NUM_DQS_CONFIG - 1 && scan_chain_counter == DQS_CONFIG_SC_LENGTH - 1) begin
					state <= CONFIG_UPDATE;
				end else if (scan_chain_counter == DQS_CONFIG_SC_LENGTH - 1) begin
					current_dqs_config <= current_dqs_config + 1'b1;
					scan_chain_counter <= 'b0;
				end else begin
					scan_chain_counter <= scan_chain_counter + 1'b1;
				end
			end
			
			CONFIG_UPDATE:
			begin
				state <= CONFIG_DONE;
				config_update <= 1'b1;
			end
			
			CONFIG_DONE:
			begin
				state <= IDLE;
				scandone <= 1'b1;
			end
				
		endcase
	end
end
endmodule