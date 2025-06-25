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


module config_controller_acv
(
	outputhalfratebypass,
	readfiforeadclockselect,
	readfifomode,
	outputregdelaysetting,
	outputenabledelaysetting,
	padtoinputregisterdelaysetting,
	
	postamblephasesetting,
	postamblephaseinvert,
	dqsbusoutdelaysetting,
	dqshalfratebypass,
	octdelaysetting,
	enadqsenablephasetransferreg,
	dqsenablegatingdelaysetting,
	dqsenableungatingdelaysetting,
	
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
localparam RFIFO_READ_CLOCK_SELECT_WIDTH = 2;
localparam RFIFO_MODE_WIDTH = 3;
localparam DELAY_CHAIN_WIDTH = 5;


input [NUM_IO_CONFIG * 1 - 1 : 0] outputhalfratebypass;
input [NUM_IO_CONFIG * 2 - 1 : 0] readfiforeadclockselect;
input [NUM_IO_CONFIG * 3 - 1 : 0] readfifomode;
input [NUM_IO_CONFIG * 5 - 1 : 0] outputregdelaysetting;
input [NUM_IO_CONFIG * 5 - 1 : 0] outputenabledelaysetting;
input [NUM_IO_CONFIG * 5 - 1 : 0] padtoinputregisterdelaysetting;

input [NUM_DQS_CONFIG * 2 - 1 : 0] postamblephasesetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] postamblephaseinvert;
input [NUM_DQS_CONFIG * 5 - 1 : 0] dqsbusoutdelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] dqshalfratebypass;
input [NUM_DQS_CONFIG * 5 - 1 : 0] octdelaysetting;
input [NUM_DQS_CONFIG * 1 - 1 : 0] enadqsenablephasetransferreg;
input [NUM_DQS_CONFIG * 5 - 1 : 0] dqsenablegatingdelaysetting;
input [NUM_DQS_CONFIG * 5 - 1 : 0] dqsenableungatingdelaysetting;

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

localparam IO_CONFIG_SC_LENGTH = 21;
localparam DQS_CONFIG_SC_LENGTH = 25;
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
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 4 : io_config * IO_CONFIG_SC_LENGTH + 0] <= padtoinputregisterdelaysetting[(io_config + 1) * 5 - 1 : io_config * 5];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 9 : io_config * IO_CONFIG_SC_LENGTH + 5] <= outputenabledelaysetting[(io_config + 1) * 5 - 1 : io_config * 5];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 14 : io_config * IO_CONFIG_SC_LENGTH + 10] <= outputregdelaysetting[(io_config + 1) * 5 - 1 : io_config * 5];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 17 : io_config * IO_CONFIG_SC_LENGTH + 15] <= readfifomode[(io_config + 1) * 3 - 1 : io_config * 3];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 19 : io_config * IO_CONFIG_SC_LENGTH + 18] <= readfiforeadclockselect[(io_config + 1) * 2 - 1 : io_config * 2];
			io_config_scanchain[io_config * IO_CONFIG_SC_LENGTH + 20 : io_config * IO_CONFIG_SC_LENGTH + 20] <= outputhalfratebypass[(io_config + 1) * 1 - 1 : io_config * 1];
		end
	end
	
	for (dqs_config = 0; dqs_config < NUM_DQS_CONFIG; dqs_config = dqs_config + 1)
	begin : DQS_CONFIG_SC_GEN
		always @(posedge clk)
		begin
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 4 : dqs_config * DQS_CONFIG_SC_LENGTH + 0] <= dqsenableungatingdelaysetting[(dqs_config + 1) * 5 - 1 : dqs_config * 5];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 9 : dqs_config * DQS_CONFIG_SC_LENGTH + 5] <= dqsenablegatingdelaysetting[(dqs_config + 1) * 5 - 1 : dqs_config * 5];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 10 : dqs_config * DQS_CONFIG_SC_LENGTH + 10] <= enadqsenablephasetransferreg[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 15 : dqs_config * DQS_CONFIG_SC_LENGTH + 11] <= octdelaysetting[(dqs_config + 1) * 5 - 1 : dqs_config * 5];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 16 : dqs_config * DQS_CONFIG_SC_LENGTH + 16] <= dqshalfratebypass[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 21 : dqs_config * DQS_CONFIG_SC_LENGTH + 17] <= dqsbusoutdelaysetting[(dqs_config + 1) * 5 - 1 : dqs_config * 5];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 22 : dqs_config * DQS_CONFIG_SC_LENGTH + 22] <= postamblephaseinvert[(dqs_config + 1) * 1 - 1 : dqs_config * 1];
			dqs_config_scanchain[dqs_config * DQS_CONFIG_SC_LENGTH + 24 : dqs_config * DQS_CONFIG_SC_LENGTH + 23] <= postamblephasesetting[(dqs_config + 1) * 2 - 1 : dqs_config * 2];
		end
	end
end
endgenerate

always @(posedge clk)
begin
	if (~scanning) begin
		scanchain <= {io_config_scanchain, dqs_config_scanchain};
	end
	else
	begin
		scanchain <= {scanchain[SCANCHAIN_LENGTH-2:0], 1'b0};
	end
	config_data <= scanchain[SCANCHAIN_LENGTH-1];
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