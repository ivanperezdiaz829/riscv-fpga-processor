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


// altera message_off 10034 10036 10030 10858

`timescale 1 ps / 1 ps

(* altera_attribute = "-name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12161" *)
module altdq_dqs2_arriaiigx_ddio_3reg_family_has_no_dynconf (

	dll_delayctrl_in,
	dll_offsetdelay_in,
	capture_strobe_in,
	capture_strobe_n_in,
	capture_strobe_ena,
	capture_strobe_out,
	
	output_strobe_ena,
	output_strobe_out,
	output_strobe_n_out,
	oct_ena_in,
	strobe_io,
	strobe_n_io,
	
        external_ddio_capture_clock,
        external_fifo_capture_clock,

	corerankselectwritein,
	corerankselectreadin,
	coredqsenabledelayctrlin,
	coredqsdisablendelayctrlin,
	coremultirankdelayctrlin,
	
	reset_n_core_clock_in,
	core_clock_in,
	fr_clock_in,
	fr_data_clock_in,
	fr_strobe_clock_in,
	hr_clock_in,
	dr_clock_in,
	strobe_ena_hr_clock_in,
	strobe_ena_clock_in,
	write_strobe_clock_in,
	parallelterminationcontrol_in,
	seriesterminationcontrol_in,

	read_data_in,
	write_data_out,
	read_write_data_io,
		
	write_oe_in,
	read_data_out,
	write_data_in,
	extra_write_data_in,
	extra_write_data_out,
	capture_strobe_tracking,
	
	lfifo_rden,
	vfifo_qvld,
	rfifo_reset_n,

	config_data_in,
	config_dqs_ena,
	config_io_ena,
	config_extra_io_ena,
	config_dqs_io_ena,
	config_update,
	config_clock_in

);
	
parameter PIN_WIDTH = 8;
parameter PIN_TYPE = "bidir";

parameter USE_INPUT_PHASE_ALIGNMENT = "false";
parameter USE_OUTPUT_PHASE_ALIGNMENT = "false";
parameter USE_LDC_AS_LOW_SKEW_CLOCK = "false";
parameter OUTPUT_DQ_PHASE_SETTING = 0;
parameter OUTPUT_DQS_PHASE_SETTING = 0;

parameter USE_HALF_RATE_INPUT = "false";
parameter USE_HALF_RATE_OUTPUT = "false";

parameter DIFFERENTIAL_CAPTURE_STROBE = "false";
parameter SEPARATE_CAPTURE_STROBE = "false";

parameter INPUT_FREQ = 0.0;
parameter INPUT_FREQ_PS = "0 ps";
parameter DELAY_CHAIN_BUFFER_MODE = "high";
parameter DQS_PHASE_SETTING = 3;
parameter DQS_PHASE_SHIFT = 9000;
parameter DQS_ENABLE_PHASE_SETTING = 2;
parameter USE_DYNAMIC_CONFIG = "true";
parameter INVERT_CAPTURE_STROBE = "false";
parameter SWAP_CAPTURE_STROBE_POLARITY = "false";
parameter EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "false";
parameter USE_TERMINATION_CONTROL = "false";
parameter USE_OCT_ENA_IN_FOR_OCT = "false";
parameter USE_DQS_ENABLE = "false";
parameter USE_IO_CONFIG = "false";
parameter USE_DQS_CONFIG = "false";

parameter USE_OFFSET_CTRL = "false";
parameter HR_DDIO_OUT_HAS_THREE_REGS = "true";

parameter USE_OUTPUT_STROBE = "true";
parameter DIFFERENTIAL_OUTPUT_STROBE = "false";
parameter USE_OUTPUT_STROBE_RESET = "true";
parameter USE_BIDIR_STROBE = "false";
parameter REVERSE_READ_WORDS = "false";

parameter EXTRA_OUTPUT_WIDTH = 0;
parameter PREAMBLE_TYPE = "none";
parameter USE_DATA_OE_FOR_OCT = "false";
parameter DQS_ENABLE_WIDTH = 1;
parameter EMIF_UNALIGNED_PREAMBLE_SUPPORT = "false";

parameter USE_2X_FF = "false";
parameter USE_DQS_TRACKING = "false";
parameter DUAL_WRITE_CLOCK = "false";
parameter USE_HARD_FIFOS = "false";

parameter USE_SHADOW_REGS = "false";

localparam rate_mult_in = (USE_HALF_RATE_INPUT == "true") ? 4 : 2;
localparam rate_mult_out = (USE_HALF_RATE_OUTPUT == "true") ? 4 : 2;
localparam fpga_width_in = PIN_WIDTH * rate_mult_in;
localparam fpga_width_out = PIN_WIDTH * rate_mult_out;
localparam extra_fpga_width_out = EXTRA_OUTPUT_WIDTH * rate_mult_out;
localparam OS_ENA_WIDTH =  rate_mult_out / 2;
localparam WRITE_OE_WIDTH = PIN_WIDTH * rate_mult_out / 2;
parameter  DQS_ENABLE_PHASECTRL = "true"; 

parameter DYNAMIC_MODE = "dynamic";

parameter OCT_SERIES_TERM_CONTROL_WIDTH   = 16; 
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = 16; 
parameter DLL_WIDTH = 6;
parameter DLL_USE_2X_CLK = "false";
parameter REGULAR_WRITE_BUS_ORDERING = "true";

parameter CALIBRATION_SUPPORT = "false";

parameter ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = 0;

parameter DELAY_CHAIN_WIDTH = 0;

parameter DQS_ENABLE_AFTER_T7 = "true";

parameter USE_CAPTURE_REG_EXTERNAL_CLOCKING = "false";
parameter USE_READ_FIFO_EXTERNAL_CLOCKING = "false";

localparam OUTPUT_ALIGNMENT_DELAY = "two_cycle";

localparam PINS_PER_DQS_CONFIG = 6;
localparam NUM_STROBES = (DIFFERENTIAL_CAPTURE_STROBE == "true" || SEPARATE_CAPTURE_STROBE == "true") ? 2 : 1;
localparam DQS_CONFIGS = (PIN_WIDTH + EXTRA_OUTPUT_WIDTH + NUM_STROBES) / PINS_PER_DQS_CONFIG;


input [DLL_WIDTH-1:0] dll_delayctrl_in;
input [DLL_WIDTH-1:0] dll_offsetdelay_in;

input reset_n_core_clock_in;
input core_clock_in;
input fr_clock_in;
input fr_data_clock_in;
input fr_strobe_clock_in;

input hr_clock_in;
input strobe_ena_hr_clock_in;
input strobe_ena_clock_in;
input write_strobe_clock_in;

input [PIN_WIDTH-1:0] read_data_in;
output [PIN_WIDTH-1:0] write_data_out;
inout [PIN_WIDTH-1:0] read_write_data_io;

input capture_strobe_in;
input capture_strobe_n_in;
input [DQS_ENABLE_WIDTH-1:0] capture_strobe_ena;

input [OS_ENA_WIDTH-1:0] output_strobe_ena;
output output_strobe_out;
output output_strobe_n_out;
input [1:0] oct_ena_in;
inout strobe_io;
inout strobe_n_io;

input external_ddio_capture_clock;
input external_fifo_capture_clock;

input corerankselectreadin;
input [1:0] corerankselectwritein;
input [DELAY_CHAIN_WIDTH-1:0] coredqsenabledelayctrlin;
input [DELAY_CHAIN_WIDTH-1:0] coredqsdisablendelayctrlin;
input [DELAY_CHAIN_WIDTH-1:0] coremultirankdelayctrlin;

output [fpga_width_out-1:0] read_data_out;
input [fpga_width_out-1:0] write_data_in;

input [WRITE_OE_WIDTH-1:0] write_oe_in;
output capture_strobe_out;

input [extra_fpga_width_out-1:0] extra_write_data_in;
output [EXTRA_OUTPUT_WIDTH-1:0] extra_write_data_out;

output capture_strobe_tracking;

input dr_clock_in;

input	[OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol_in;
input	[OCT_SERIES_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol_in;

input config_data_in;
input config_update;
input config_dqs_ena;
input [PIN_WIDTH-1:0] config_io_ena;
input [EXTRA_OUTPUT_WIDTH-1:0] config_extra_io_ena;
input config_dqs_io_ena;
input config_clock_in;

input lfifo_rden;
input vfifo_qvld;
input rfifo_reset_n;

wire [DLL_WIDTH-1:0] dll_delay_value;
assign dll_delay_value = dll_delayctrl_in;

wire dqsbusout;
wire dqsnbusout;

wire [3:0] dqs_inputdelaysetting;
wire [3:0] dqsn_inputdelaysetting;

wire [3:0] dqs_outputdelaysetting1;
wire [3:0] dqs_outputdelaysetting2;
wire [3:0] dqsn_outputdelaysetting1;
wire [3:0] dqsn_outputdelaysetting2;

wire [DELAY_CHAIN_WIDTH-1:0] dqs_outputdelaysetting1_dlc;
wire [DELAY_CHAIN_WIDTH-1:0] dqs_outputdelaysetting2_dlc;
wire [DELAY_CHAIN_WIDTH-1:0] dqsn_outputdelaysetting1_dlc;
wire [DELAY_CHAIN_WIDTH-1:0] dqsn_outputdelaysetting2_dlc;



wire [1:0] oct_ena;
wire fr_term;

wire [1:0] oct_source;
wire aligned_os_oct;

generate
	if (USE_DATA_OE_FOR_OCT == "true")
	begin
		assign oct_source[0] = write_oe_in [0];
		if (USE_HALF_RATE_OUTPUT == "true")
			assign oct_source [1] = write_oe_in [PIN_WIDTH];
	end
	else
	begin
		assign oct_source = output_strobe_ena;
	end
endgenerate

generate
	if (USE_HALF_RATE_OUTPUT == "true")
	begin : oct_ena_hr_gen
		if (USE_OCT_ENA_IN_FOR_OCT == "true")
		begin
			assign oct_ena = oct_ena_in;
		end
		else
		begin
			reg oct_ena_hr_reg;
			always @(posedge hr_clock_in)
				oct_ena_hr_reg <= oct_source[1];
			assign oct_ena[1] = ~oct_source[1];
			assign oct_ena[0] = ~(oct_ena_hr_reg | oct_source[1]);
		end
	end
	else
	begin : oct_ena_fr_gen
		if (USE_OCT_ENA_IN_FOR_OCT == "true")
		begin
			assign fr_term = oct_ena_in[0];
		end
		else
		begin
			reg oct_ena_fr_reg;
			initial
				oct_ena_fr_reg = 0;
			always @(posedge hr_clock_in)
				oct_ena_fr_reg <= oct_source[0];
			assign fr_term = ~(oct_source[0] | oct_ena_fr_reg);
		end
	end
endgenerate



wire dividerphasesetting [DQS_CONFIGS:0];
wire dqoutputphaseinvert [DQS_CONFIGS:0];
wire [3:0] dqoutputphasesetting [DQS_CONFIGS:0];
wire [3:0] dqsbusoutdelaysetting [DQS_CONFIGS:0];
wire [3:0] dqsoutputphasesetting [DQS_CONFIGS:0];
wire [3:0] resyncinputphasesetting [DQS_CONFIGS:0];
wire [2:0] dqsenabledelaysetting [DQS_CONFIGS:0];
wire [2:0] dqsinputphasesetting [DQS_CONFIGS:0];
wire [3:0] dqsenablectrlphasesetting [DQS_CONFIGS:0];

wire dqsbusoutfinedelaysetting [DQS_CONFIGS:0];
wire dqsenablectrlphaseinvert [DQS_CONFIGS:0];
wire dqsenablefinedelaysetting [DQS_CONFIGS:0];
wire dqsoutputphaseinvert [DQS_CONFIGS:0];
wire enadataoutbypass [DQS_CONFIGS:0];
wire enadqsenablephasetransferreg [DQS_CONFIGS:0];

wire enainputcycledelaysetting [DQS_CONFIGS:0];
wire enainputphasetransferreg [DQS_CONFIGS:0];

wire enaoctphasetransferreg [DQS_CONFIGS:0];
wire enaoutputphasetransferreg [DQS_CONFIGS:0];
wire enaoctcycledelaysetting [DQS_CONFIGS:0];
wire enaoutputcycledelaysetting [DQS_CONFIGS:0];
wire [3:0] octdelaysetting1 [DQS_CONFIGS:0];
wire [2:0] octdelaysetting2 [DQS_CONFIGS:0];

wire resyncinputphaseinvert [DQS_CONFIGS:0];

wire [DELAY_CHAIN_WIDTH-1:0] dqsbusoutdelaysetting_dlc[DQS_CONFIGS:0];
wire [DELAY_CHAIN_WIDTH-1:0] dqsenabledelaysetting_dlc[DQS_CONFIGS:0];
wire [DELAY_CHAIN_WIDTH-1:0] dqsdisabledelaysetting_dlc[DQS_CONFIGS:0];
wire [DELAY_CHAIN_WIDTH-1:0] octdelaysetting1_dlc[DQS_CONFIGS:0];
wire [DELAY_CHAIN_WIDTH-1:0] octdelaysetting2_dlc[DQS_CONFIGS:0];




generate
if (USE_BIDIR_STROBE == "true")
begin
	assign output_strobe_out = 1'b0;
	assign output_strobe_n_out = 1'b1;	
end
else
begin
	assign strobe_io = 1'b0;
	assign strobe_n_io = 1'b1;	
end
endgenerate

wire zero_phase_clock;
wire dq_dr_clock;
wire dqs_dr_clock;
wire dq_shifted_clock;
wire dm_shifted_clock;
wire write_strobe_clock;


assign zero_phase_clock = fr_clock_in;
assign dq_shifted_clock = fr_clock_in;
assign dm_shifted_clock = fr_clock_in;
assign write_strobe_clock = write_strobe_clock_in;





generate 
if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
begin

	assign capture_strobe_out = dqsbusout;
	wire dqsin;
	
	wire capture_strobe_ibuf_i;
	wire capture_strobe_ibuf_ibar;

	if (USE_BIDIR_STROBE == "true")
	begin
		if (SWAP_CAPTURE_STROBE_POLARITY == "true") begin
			assign capture_strobe_ibuf_i = strobe_n_io;
			assign capture_strobe_ibuf_ibar = strobe_io;
		end else begin
			assign capture_strobe_ibuf_i = strobe_io;
			assign capture_strobe_ibuf_ibar = strobe_n_io;
		end
	end
	else
	begin
		if (SWAP_CAPTURE_STROBE_POLARITY == "true") begin
			assign capture_strobe_ibuf_i = capture_strobe_n_in;
			assign capture_strobe_ibuf_ibar = capture_strobe_in;
		end else begin
			assign capture_strobe_ibuf_i = capture_strobe_in;
			assign capture_strobe_ibuf_ibar = capture_strobe_n_in;
		end		
	end		
	
	if (DIFFERENTIAL_CAPTURE_STROBE == "true")
	begin
		arriaii_io_ibuf
		#(
			.differential_mode(DIFFERENTIAL_CAPTURE_STROBE),
			.bus_hold("false")
		) strobe_in (
			.i(capture_strobe_ibuf_i),
			.ibar(capture_strobe_ibuf_ibar),
			.o(dqsin)
		);
	end
	else
	begin
		arriaii_io_ibuf
		#(
			.bus_hold("false")
		) strobe_in (					      
			.i(capture_strobe_ibuf_i),
			.o(dqsin)
		);
	end

	wire capture_strobe_ena_fr;
	if (DQS_ENABLE_WIDTH > 1)
	begin
			soft_hr_ddio_out hr_to_fr_ena (
					.datainhi(capture_strobe_ena[1]),
					.datainlo(capture_strobe_ena[0]),
					.dataout(capture_strobe_ena_fr),
					.clk (strobe_ena_hr_clock_in)
			);
	end	
	else
	begin
		assign capture_strobe_ena_fr = capture_strobe_ena;
	end


	wire dqsbusout_preena;
	wire dqsbusout_predelay;
	wire dqs_enable_predelay;
	wire dqs_enable;

	if (USE_DYNAMIC_CONFIG == "true")
	begin
	end
	else
	begin
		arriaii_dqs_delay_chain
		#(
			.dqs_input_frequency(INPUT_FREQ_PS),
			.delay_buffer_mode(DELAY_CHAIN_BUFFER_MODE),
			.phase_setting(DQS_PHASE_SETTING),
			.dqs_phase_shift(DQS_PHASE_SHIFT),
			.dqs_ctrl_latches_enable("false"),
			.dqs_offsetctrl_enable(USE_OFFSET_CTRL)
		) dqs_delay_chain(						      
			.dqsin(dqsin),
			.delayctrlin(dll_delay_value),
			.dqsbusout(dqsbusout_predelay),
			.dqsupdateen(1'b0)
		);
		assign dqsbusout_preena = dqsbusout_predelay;
		assign dqs_enable = dqs_enable_predelay;
	end

	if (USE_DQS_ENABLE == "true")
	begin
	end
	else
	begin
		assign dqsbusout = dqsbusout_preena;
	end
	
	if (SEPARATE_CAPTURE_STROBE == "true")
	begin
		wire dqsnin;
		wire dqsnbusout_preena;
		wire dqsnbusout_predelay;
		wire dqsn_enable_predelay;
		wire dqsn_enable;

		arriaii_io_ibuf strobe_n_in (
			.i(capture_strobe_ibuf_ibar),
			.o(dqsnin)
		);
		
		if (USE_DYNAMIC_CONFIG == "true")
		begin
		end
		else
		begin
			arriaii_dqs_delay_chain
			#(
				.dqs_input_frequency(INPUT_FREQ_PS),
				.delay_buffer_mode(DELAY_CHAIN_BUFFER_MODE),
				.phase_setting(DQS_PHASE_SETTING),
				.dqs_phase_shift(DQS_PHASE_SHIFT),
				.dqs_ctrl_latches_enable("false"),
				.dqs_offsetctrl_enable(USE_OFFSET_CTRL)
			)  dqsn_delay_chain(
				.dqsin(dqsnin),
				.delayctrlin(dll_delay_value),
				.dqsbusout(dqsnbusout_predelay)
			);

			assign dqsnbusout_preena = dqsnbusout_predelay;
			assign dqsn_enable = dqsn_enable_predelay;
		end

		if (USE_DQS_ENABLE == "true")
		begin
		end
		else
		begin
			assign dqsnbusout = dqsnbusout_preena;
		end
	end
								
end
endgenerate

generate
if (USE_OUTPUT_STROBE == "true")
begin
	wire os;
	wire os_bar;
	wire os_dtc;
	wire os_dtc_bar;
	wire os_delayed1;
	wire os_delayed2;

	wire fr_os_oe;
	wire fr_os_oct;
	wire aligned_os_oe;
	wire aligned_strobe;
	
	wire fr_os_hi;
	wire fr_os_lo;
	
	if (USE_HALF_RATE_OUTPUT == "true")
	begin
	
		if (USE_BIDIR_STROBE == "true")
		begin		
			wire clk_gate_hi;
			wire clk_gate_lo;
			
			if (PREAMBLE_TYPE == "low")
			begin
				if (EMIF_UNALIGNED_PREAMBLE_SUPPORT != "true")
				begin
					assign clk_gate_hi = output_strobe_ena[0];
					assign clk_gate_lo = output_strobe_ena[0];
				end 
				else
				begin 
					reg [1:0] os_ena_reg;
					reg [1:0] os_ena_preamble;

					always @(posedge core_clock_in)  
					begin
						os_ena_reg[1:0] <= output_strobe_ena[1:0];
					end

					always @(*)
					begin
						case ({os_ena_reg[0], os_ena_reg[1],
							   output_strobe_ena[0], output_strobe_ena[1]}) 
							4'b00_00: os_ena_preamble[1:0] <= 2'b00;
							4'b00_01: os_ena_preamble[1:0] <= 2'b00; 
							4'b00_10: os_ena_preamble[1:0] <= 2'b00; 
							4'b00_11: os_ena_preamble[1:0] <= 2'b01; 

							4'b01_00: os_ena_preamble[1:0] <= 2'b00;
							4'b01_01: os_ena_preamble[1:0] <= 2'b00; 
							4'b01_10: os_ena_preamble[1:0] <= 2'b10;
							4'b01_11: os_ena_preamble[1:0] <= 2'b11;

							4'b10_00: os_ena_preamble[1:0] <= 2'b00;
							4'b10_01: os_ena_preamble[1:0] <= 2'b00; 
							4'b10_10: os_ena_preamble[1:0] <= 2'b00; 
							4'b10_11: os_ena_preamble[1:0] <= 2'b01; 

							4'b11_00: os_ena_preamble[1:0] <= 2'b00;
							4'b11_01: os_ena_preamble[1:0] <= 2'b00; 
							4'b11_10: os_ena_preamble[1:0] <= 2'b10;
							4'b11_11: os_ena_preamble[1:0] <= 2'b11;

							default:  os_ena_preamble[1:0] <= 2'b00;
						endcase
					end

					assign clk_gate_hi = os_ena_preamble[0];
					assign clk_gate_lo = os_ena_preamble[1];
				end 
			end
			else
			begin
				assign clk_gate_hi = 1'b1;
				assign clk_gate_lo = 1'b1;
			end
			
			soft_hr_ddio_out hr_to_fr_os_hi (
					.datainhi(clk_gate_hi),
					.datainlo(clk_gate_lo),
					.dataout(fr_os_hi),
					.clk (hr_clock_in)
			);

			soft_hr_ddio_out hr_to_fr_os_lo (
					.datainhi(1'b0),
					.datainlo(1'b0),
					.dataout(fr_os_lo),
					.clk (hr_clock_in)
			);

			soft_hr_ddio_out hr_to_fr_os_oe (
					.datainhi(~output_strobe_ena [1]),
					.datainlo(~output_strobe_ena [0]),
					.dataout(fr_os_oe),
					.clk (hr_clock_in)
			);
		end
		else 
		begin
			wire clk_gate;
			assign fr_os_oe = 1'b0;			
			if (USE_OUTPUT_STROBE_RESET == "true") begin
				reg clk_h /* synthesis dont_merge */;
				always @(posedge core_clock_in or negedge reset_n_core_clock_in)
				begin
					if (~reset_n_core_clock_in)
						clk_h <= 1'b0;
					else
						clk_h <= 1'b1;
				end			
				assign clk_gate = clk_h;
			end else begin
				assign clk_gate = 1'b1;
			end
			
			if (USE_LDC_AS_LOW_SKEW_CLOCK == "true") begin
				wire hr_to_fr_os_hi_in = (OUTPUT_DQS_PHASE_SETTING == 4) ? 1'b0 : clk_gate;
				wire hr_to_fr_os_lo_in = (OUTPUT_DQS_PHASE_SETTING == 4) ? clk_gate : 1'b0;
								
				if (USE_OUTPUT_STROBE_RESET == "false") begin
					assign fr_os_hi = hr_to_fr_os_hi_in;
					assign fr_os_lo = hr_to_fr_os_lo_in;
				end else begin
					soft_hr_ddio_out hr_to_fr_os_hi (
							.datainhi(hr_to_fr_os_hi_in),
							.datainlo(hr_to_fr_os_hi_in),
							.dataout(fr_os_hi),
							.clk (hr_clock_in)
					);

					soft_hr_ddio_out hr_to_fr_os_lo (
							.datainhi(hr_to_fr_os_lo_in),
							.datainlo(hr_to_fr_os_lo_in),
							.dataout(fr_os_lo),
							.clk (hr_clock_in)
					);
				end			
			end else begin
				wire gnd_lut /* synthesis keep = 1*/;
				assign gnd_lut = 1'b0;
				assign fr_os_lo = gnd_lut;
				assign fr_os_hi = clk_gate;
			end
		end

		soft_hr_ddio_out hr_to_fr_os_oct (
			.datainhi(oct_ena[1]),
			.datainlo(oct_ena[0]),
			.dataout(fr_os_oct),
			.clk (hr_clock_in)
		);
	end
	else
	begin
		
		wire fr_os_hi_in;
		wire gnd_lut /* synthesis keep = 1*/;
		assign gnd_lut = 1'b0;
		wire fr_os_lo_in = gnd_lut;

		if (USE_BIDIR_STROBE == "true")
		begin
			assign fr_os_oe = ~output_strobe_ena[0];
			assign fr_os_oct = fr_term;

			if (PREAMBLE_TYPE == "low")
			begin
				reg os_ena_reg1;
				initial
					os_ena_reg1 = 0;
				always @(posedge core_clock_in)
					os_ena_reg1 <= output_strobe_ena[0];
	
				assign fr_os_hi_in = os_ena_reg1 & output_strobe_ena[0];
			end
			else
			begin
				wire vcc_lut /* synthesis keep = 1*/;
				assign vcc_lut = 1'b1;
				assign fr_os_hi_in = vcc_lut;
			end
		end
		else
		begin
			assign fr_os_oe = 1'b0;
			if (USE_OUTPUT_STROBE_RESET == "true") begin
				reg clk_h /* synthesis dont_merge */;
				always @(posedge core_clock_in or negedge reset_n_core_clock_in)
				begin
					if (~reset_n_core_clock_in)
						clk_h <= 1'b0;
					else
						clk_h <= 1'b1;
				end			
				assign fr_os_hi_in = clk_h;
			end else begin
				assign fr_os_hi_in = 1'b1;
			end
		end		
		
		if (USE_LDC_AS_LOW_SKEW_CLOCK == "true" && OUTPUT_DQS_PHASE_SETTING == 4) begin
			assign fr_os_hi = fr_os_lo_in;
			assign fr_os_lo = fr_os_hi_in;
		end else begin
			assign fr_os_hi = fr_os_hi_in;
			assign fr_os_lo = fr_os_lo_in;
		end		
	end

	if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
	begin
	end
	else
	begin
		reg oe_reg /* synthesis dont_merge altera_attribute="FAST_OUTPUT_ENABLE_REGISTER=on" */;
			reg oct_reg /* synthesis altera_attribute="FAST_OCT_REGISTER=on" */;
		
		initial 
		begin
			oe_reg = 0;
			oct_reg = 0;
		end
		
		always @ ( posedge write_strobe_clock)
			oe_reg <= fr_os_oe;

		assign aligned_os_oe = oe_reg;
		always @ (posedge fr_clock_in)
			oct_reg <= fr_os_oct;

		assign aligned_os_oct = oct_reg;
	
		arriaii_ddio_out
		#(
				.half_rate_mode("false"),
				.use_new_clocking_model("true"),
				.async_mode("none")
		) phase_align_os (
			.datainhi(fr_os_hi),
			.datainlo(fr_os_lo),
			.dataout(aligned_strobe),
			.clkhi (write_strobe_clock),
			.clklo (write_strobe_clock),
			.muxsel (write_strobe_clock)
		);
	end
	
	wire delayed_os_oct;
	wire delayed_os_oe;
	wire predelayed_os;
	wire predelayed_os_oe;
	
	if (USE_2X_FF == "true")
	begin
		reg dd_os;
		reg dd_os_oe;
		always @(posedge dqs_dr_clock)
		begin
			dd_os <= aligned_strobe;
			dd_os_oe <= aligned_os_oe;
		end
		assign predelayed_os = dd_os;
		assign predelayed_os_oe = dd_os_oe;
	end
	else
	begin
		assign predelayed_os = aligned_strobe;
		assign predelayed_os_oe = aligned_os_oe;
	end
	
	if (USE_DYNAMIC_CONFIG == "true")
	begin
	end
	else
	begin
		assign os_delayed2 = aligned_strobe;
		assign delayed_os_oct = aligned_os_oct;
		assign delayed_os_oe = aligned_os_oe;
	end
	wire diff_dtc;
	wire diff_dtc_bar;

	if (DIFFERENTIAL_OUTPUT_STROBE=="true")
	begin

		wire aligned_os_oe_bar;
		wire aligned_os_oct_bar;
		
		wire delayed_os_bar_oct;
		wire delayed_os_bar_oct_1;

		wire delayed_os_bar_oe;
		wire delayed_os_bar_oe_1;

		wire fr_os_oen;
		wire fr_os_octn;

		if (USE_HALF_RATE_OUTPUT == "true")
		begin
			soft_hr_ddio_out hr_to_fr_os_oe_bar (
					.datainhi(~output_strobe_ena [1]),
					.datainlo(~output_strobe_ena [0]),
					.dataout(fr_os_oen),
					.clk (hr_clock_in)
			);
	
			soft_hr_ddio_out hr_to_fr_os_oct_bar (
					.datainhi(oct_ena [1]),
					.datainlo(oct_ena [0]),
					.dataout(fr_os_octn),
					.clk (hr_clock_in)
			);
		end
		else
		begin
			assign fr_os_oen = ~output_strobe_ena;
			assign fr_os_octn = fr_term;
		end
	
		if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
		begin
		end
		else
		begin

			reg oe_bar_reg /* synthesis dont_merge altera_attribute="FAST_OUTPUT_ENABLE_REGISTER=on" */;
				reg oct_bar_reg /* synthesis altera_attribute="FAST_OCT_REGISTER=on" */;

			initial
			begin
				oe_bar_reg = 0;
				oct_bar_reg = 0;
			end
			
			always @ ( posedge write_strobe_clock)
				oe_bar_reg <= fr_os_oen;

			assign aligned_os_oe_bar = oe_bar_reg;
			
			always @ (posedge fr_clock_in)
				oct_bar_reg <= fr_os_octn;
		
			assign aligned_os_oct_bar = oct_bar_reg;
		end		
		
		if (USE_DYNAMIC_CONFIG == "true")
		begin
		end
		else
		begin
			assign delayed_os_bar_oct = aligned_os_oct_bar;
			assign delayed_os_bar_oe = aligned_os_oe_bar;
		end

		if (USE_BIDIR_STROBE == "true")
		begin
			arriaii_pseudo_diff_out   pseudo_diffa_0
			(
				.i(os_delayed2),
				.o(os),
				.obar(os_bar)
			);		
		
			arriaii_io_obuf
			#(
				.bus_hold("false"),
				.open_drain_output("false")
			) obuf_os_bar_0
			( 
				.i(os_bar),
				.o(strobe_n_io),
				.obar(),
				.oe(~delayed_os_bar_oe),
				.seriesterminationcontrol	(seriesterminationcontrol_in)
			);
		end
		else
		begin
			arriaii_pseudo_diff_out   pseudo_diffa_0
			(
				.i(os_delayed2),
				.o(os),
				.obar(os_bar)
			);
		
			arriaii_io_obuf
			#(
				.bus_hold("false"),
				.open_drain_output("false")
			) obuf_os_bar_0
			(
				.i(os_bar),
				.o(output_strobe_n_out),
				.obar(),
				.oe(1'b1)
			);
		end
	end
	else
	begin
		assign os = os_delayed2;
	end


	if (USE_BIDIR_STROBE == "true")
	begin
		arriaii_io_obuf
		#(
			.bus_hold("false"),
			.open_drain_output("false")
		) obuf_os_0
			( 
			.i(os),
			.o(strobe_io),
			.obar(),
			.oe(~delayed_os_oe),

			.seriesterminationcontrol	(seriesterminationcontrol_in)
		);
	end
	else
	begin
		arriaii_io_obuf
		#(
			.bus_hold("false"),
			.open_drain_output("false")
		) obuf_os_0			  
			(
			.i(os),
			.o(output_strobe_out),
			.obar(),
			.oe(1'b1)
			);
	
	end	
end
endgenerate


wire [PIN_WIDTH-1:0] aligned_oe ;
wire [PIN_WIDTH-1:0] aligned_data;
wire [PIN_WIDTH-1:0] ddr_data;
wire [PIN_WIDTH-1:0] aligned_oct;

generate
	if (PIN_TYPE == "output" || PIN_TYPE == "bidir")
	begin
		
			reg oct_reg /* synthesis altera_attribute="FAST_OCT_REGISTER=on" */;

		if (USE_OUTPUT_PHASE_ALIGNMENT == "false")
		begin
			wire fr_oct;
			if (USE_HALF_RATE_OUTPUT == "false")
				assign fr_oct = fr_term;
			initial
			begin
				oct_reg = 0;
			end
			always @ (posedge dq_shifted_clock)
			begin
				oct_reg <= fr_oct;
			end
		end
			
		genvar opin_num;
		for (opin_num = 0; opin_num < PIN_WIDTH; opin_num = opin_num + 1)
		begin :output_path_gen
			wire fr_data_hi;
			wire fr_data_lo;
			wire fr_oe;
			wire fr_oct;
			
			if (USE_HALF_RATE_OUTPUT == "true")
			begin
				wire hr_data_t0;
				wire hr_data_t1;
				wire hr_data_t2;
				wire hr_data_t3;

				if (REGULAR_WRITE_BUS_ORDERING == "true")
			  	begin
					assign hr_data_t0 = write_data_in [opin_num + 0*PIN_WIDTH];
			  		assign hr_data_t1 = write_data_in [opin_num + 1*PIN_WIDTH];
			  		assign hr_data_t2 = write_data_in [opin_num + 2*PIN_WIDTH];
					assign hr_data_t3 = write_data_in [opin_num + 3*PIN_WIDTH];
				end
				else
			  	begin
					assign hr_data_t0 = write_data_in [opin_num + 1*PIN_WIDTH];
					assign hr_data_t1 = write_data_in [opin_num + 0*PIN_WIDTH];
					assign hr_data_t2 = write_data_in [opin_num + 3*PIN_WIDTH];
					assign hr_data_t3 = write_data_in [opin_num + 2*PIN_WIDTH];
				end
			
				soft_hr_ddio_out hr_to_fr_hi (
					.datainhi(hr_data_t2),
					.datainlo(hr_data_t0),
					.dataout(fr_data_hi),
					.clk (hr_clock_in)
				);

				soft_hr_ddio_out hr_to_fr_lo (
					.datainhi(hr_data_t3),
					.datainlo(hr_data_t1),
					.dataout(fr_data_lo),
					.clk (hr_clock_in)
				);

				soft_hr_ddio_out hr_to_fr_oe (
					.datainhi(~write_oe_in [opin_num + PIN_WIDTH]),
					.datainlo(~write_oe_in [opin_num + 0]),
					.dataout(fr_oe),
					.clk (hr_clock_in)
				);

				soft_hr_ddio_out hr_to_fr_oct (
					.datainhi(oct_ena [1]),
					.datainlo(oct_ena [0]),
					.dataout(fr_oct),
					.clk (hr_clock_in)
				);
			end
			else
			begin
				assign fr_data_lo = write_data_in [opin_num+PIN_WIDTH];
				assign fr_data_hi = write_data_in [opin_num];
				assign fr_oe = ~write_oe_in [opin_num];
				assign fr_oct = fr_term;
			end
			
			if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
			begin
			end
			else
			begin
				reg oe_reg /* synthesis dont_merge altera_attribute="FAST_OUTPUT_ENABLE_REGISTER=on" */;
					reg oct_reg_hr /* synthesis altera_attribute="FAST_OCT_REGISTER=on" */;


			
				arriaii_ddio_out
				#(
					.async_mode("none"),
					.half_rate_mode("false"),
					.sync_mode("none"),
					.use_new_clocking_model("true")
				) ddio_out (
					.datainhi(fr_data_hi),
					.datainlo(fr_data_lo),
					.dataout(aligned_data[opin_num]),
					.clkhi (dq_shifted_clock),
					.clklo (dq_shifted_clock),
					.muxsel (dq_shifted_clock)
				);

				initial
				begin
					oe_reg = 0;
					oct_reg_hr = 0;
				end
				always @ (posedge dq_shifted_clock)
				begin
					oe_reg <= fr_oe;
					oct_reg_hr <= fr_oct; 
				end

				if (USE_HALF_RATE_OUTPUT == "true")
					assign aligned_oct [opin_num] = oct_reg_hr;
				else
					assign aligned_oct [opin_num] = oct_reg;
				assign aligned_oe [opin_num] = oe_reg;
				

			end
		end
	end
endgenerate


generate
if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
begin
	wire rden;
	wire plus2_out; 
	wire wren_clk;
	wire wren;
	wire external_read_fifo_writeclk;
	if (USE_READ_FIFO_EXTERNAL_CLOCKING == "true") begin
		wire [3:0] delayed_external_fifo_capture_clocks;
		stratixv_leveling_delay_chain
		#(
			.physical_clock_source("resync")
		) external_read_fifo_clock_ldc (
			.clkin (external_fifo_capture_clock),
			.delayctrlin (dll_delay_value),
			.clkout(delayed_external_fifo_capture_clocks)
		);

		stratixv_clk_phase_select
		#(
			.use_phasectrlin("false"),
		  	.phase_setting(0),
			.physical_clock_source("rsc_0p")
		) external_read_fifo_clock_zero_select (
			.clkin (delayed_external_fifo_capture_clocks),
			.clkout (external_read_fifo_writeclk),
			.powerdown (),
			.phasectrlin (),
			.phaseinvertctrl()
		);
	end 

	genvar ipin_num;
	for (ipin_num = 0; ipin_num < PIN_WIDTH; ipin_num = ipin_num + 1)
	begin :input_path_gen

		wire [1:0] sdr_data;
		wire [1:0] aligned_input;
		wire dqsbusout_to_ddio_in;
		wire dqsnbusout_to_ddio_in;
		
		if (USE_CAPTURE_REG_EXTERNAL_CLOCKING == "true") begin
			assign dqsbusout_to_ddio_in = external_ddio_capture_clock;
		end else begin
			if (INVERT_CAPTURE_STROBE == "true") begin
				assign dqsbusout_to_ddio_in = ~dqsbusout;
				if (SEPARATE_CAPTURE_STROBE == "true") begin
					assign dqsnbusout_to_ddio_in = ~dqsnbusout;
				end
			end else begin
				assign dqsbusout_to_ddio_in = dqsbusout;
				if (SEPARATE_CAPTURE_STROBE == "true") begin
					assign dqsnbusout_to_ddio_in = dqsnbusout;
				end
			end
		end
		
		if (SEPARATE_CAPTURE_STROBE == "true" && USE_CAPTURE_REG_EXTERNAL_CLOCKING == "false") begin
			arriaii_ddio_in
			#(
				.use_clkn("true"),
				.async_mode("none"),
				.sync_mode("none")
			) capture_reg(
				.datain(ddr_data[ipin_num]),
				.clk (dqsbusout_to_ddio_in),
				.clkn (dqsnbusout_to_ddio_in),
				.regouthi(sdr_data[1]),
				.regoutlo(sdr_data[0])
			);
		end else begin
			arriaii_ddio_in
			#(
				.use_clkn("false"),
				.async_mode("none"),
				.sync_mode("none")
			)  capture_reg(
				.datain(ddr_data[ipin_num]),
				.clk (dqsbusout_to_ddio_in),
				.regouthi(sdr_data[1]),
				.regoutlo(sdr_data[0])
			);
		end
		
		if (USE_INPUT_PHASE_ALIGNMENT == "true") 
		begin
		end
		else
		begin
			assign aligned_input = sdr_data;
		end
		
		if (USE_HARD_FIFOS == "true" && USE_HALF_RATE_OUTPUT == "true")
		begin
			
			wire writeclk;
			if (USE_READ_FIFO_EXTERNAL_CLOCKING == "true") begin
				assign writeclk = external_read_fifo_writeclk;
			end else begin
				assign writeclk = (dqsbusout_to_ddio_in === 1'b0) ? 1'b1 : 1'b0;
			end 
			
			wire [3:0] read_fifo_out;
			
			if (REVERSE_READ_WORDS == "true")
			begin
				assign read_data_out [ipin_num] = read_fifo_out [0];
				assign read_data_out [PIN_WIDTH +ipin_num] = read_fifo_out [1];
				assign read_data_out [PIN_WIDTH*2 +ipin_num] = read_fifo_out [2];
				assign read_data_out [PIN_WIDTH*3 +ipin_num] = read_fifo_out [3];
			end
			else	
			begin
				assign read_data_out [ipin_num] = read_fifo_out [2];
				assign read_data_out [PIN_WIDTH +ipin_num] = read_fifo_out [3];
				assign read_data_out [PIN_WIDTH*2 +ipin_num] = read_fifo_out [0];
				assign read_data_out [PIN_WIDTH*3 +ipin_num] = read_fifo_out [1];
			end
		end
		else 
		begin
		
			if (REVERSE_READ_WORDS == "true")
			begin
				assign read_data_out [ipin_num] = aligned_input [1];
				assign read_data_out [PIN_WIDTH +ipin_num] = aligned_input [0];
			end
			else
			begin
				assign read_data_out [ipin_num] = aligned_input [0];
				assign read_data_out [PIN_WIDTH +ipin_num] = aligned_input [1];
			end
		end
	end
end
endgenerate

generate
	genvar pin_num;
	for (pin_num = 0; pin_num < PIN_WIDTH; pin_num = pin_num + 1)
	begin :pad_gen
		if (PIN_TYPE == "bidir")
		begin
			assign write_data_out [pin_num] = 1'b0;
		end
		else
		begin
			assign read_write_data_io [pin_num] = 1'b0;
		end
	
	
		wire delayed_data_in;
		wire delayed_data_out;
		wire delayed_oe;
		wire [3:0] dq_outputdelaysetting1;
		wire [3:0] dq_outputdelaysetting2;
		wire [3:0] dq_inputdelaysetting;
		assign dq_outputdelaysetting2 [3] = 1'b0;
		
		wire [DELAY_CHAIN_WIDTH-1:0] dq_outputdelaysetting1_dlc;
		wire [DELAY_CHAIN_WIDTH-1:0] dq_outputdelaysetting2_dlc;
		wire [DELAY_CHAIN_WIDTH-1:0] dq_inputdelaysetting_dlc;
		
		
		if (USE_DYNAMIC_CONFIG == "true")
		begin
		assign dq_outputdelaysetting1_dlc = dq_outputdelaysetting1;
		assign dq_outputdelaysetting2_dlc = dq_outputdelaysetting2;
		assign dq_inputdelaysetting_dlc = dq_inputdelaysetting;
		end
	
		if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
		begin
			wire raw_input;
			wire raw_input_delay;
			if (USE_DYNAMIC_CONFIG == "true")
			begin
			end
			else
			begin
				assign ddr_data[pin_num] = raw_input;
			end	
			
			if (PIN_TYPE == "bidir")
			begin
				arriaii_io_ibuf data_in (
					.i(read_write_data_io[pin_num]),
					.o(raw_input)
				);
			end
			else
			begin
				arriaii_io_ibuf data_in (
					.i(read_data_in[pin_num]),
					.o(raw_input)
				);
			end
		end
		wire delayed_oct;
		
		if (PIN_TYPE == "output" || PIN_TYPE == "bidir")
		begin
			
			wire predelayed_data;
			wire predelayed_oe;
	
			if (USE_2X_FF == "true")
			begin
				reg dd_data;
				reg dd_oe;
				always @(posedge dq_dr_clock)
				begin
					dd_data <= aligned_data[pin_num];
					dd_oe <= aligned_oe[pin_num];
				end
				assign predelayed_data = dd_data;
				assign predelayed_oe = dd_oe;
			end
			else
			begin
				assign predelayed_data = aligned_data[pin_num];
				assign predelayed_oe = aligned_oe[pin_num];
			end

			if (USE_DYNAMIC_CONFIG == "true")
			begin
			end
			else
			begin
				assign delayed_data_out = predelayed_data;
				assign delayed_oe = predelayed_oe;
				assign delayed_oct = aligned_oct [pin_num];
			end
		
			if (PIN_TYPE == "output")
			begin
				arriaii_io_obuf data_out (
					.i (delayed_data_out),
					.o (write_data_out [pin_num]),
					.oe (~delayed_oe),
					.seriesterminationcontrol	(seriesterminationcontrol_in)					
				);
			end
			else if (PIN_TYPE == "bidir")
			begin
				arriaii_io_obuf
				data_out (
					.oe (~delayed_oe),
					.i (delayed_data_out),
					.o (read_write_data_io [pin_num]),
					.seriesterminationcontrol	(seriesterminationcontrol_in)
				);
				
				/* synthesis translate_off */
				
				if (DUAL_WRITE_CLOCK == "true")	begin
					assert property (@(posedge fr_data_clock_in or negedge fr_data_clock_in) (~delayed_oe === 1'b1) |-> (##[0:1] delayed_oct === 1'b0 || reset_n_core_clock_in === 1'b0)) 
						else $fatal(1, "OE enabled but dynamic OCT ctrl is not in write mode");
				end else begin
					assert property (@(posedge fr_clock_in or negedge fr_clock_in) (~delayed_oe === 1'b1) |-> (##[0:1] delayed_oct === 1'b0 || reset_n_core_clock_in === 1'b0)) 
						else $fatal(1, "OE enabled but dynamic OCT ctrl is not in write mode");
				end
				
`ifndef BOARD_DELAY_MODEL
				assert property (@(posedge capture_strobe_out or negedge capture_strobe_out) (~delayed_oe === 1'b0 && read_write_data_io[pin_num] !== 1'bz) |-> (delayed_oct === 1'b1 || reset_n_core_clock_in === 1'b0)) 
					else $fatal(1, "Read data comes back but dynamic OCT ctrl is not in read mode");
`endif
					
				/* synthesis translate_on */					
			end 

		end
	end
endgenerate

generate
	genvar epin_num;
	for (epin_num = 0; epin_num < EXTRA_OUTPUT_WIDTH; epin_num = epin_num + 1)
	begin :extra_output_pad_gen
		wire fr_data_hi;
		wire fr_data_lo;
		wire aligned_data;
		
		if (USE_HALF_RATE_OUTPUT == "true")
		begin
			wire hr_data_t0;
			wire hr_data_t1;
			wire hr_data_t2;
			wire hr_data_t3;
			
			if (REGULAR_WRITE_BUS_ORDERING == "true")
		  	begin
				assign hr_data_t0 = extra_write_data_in [epin_num + 0*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t1 = extra_write_data_in [epin_num + 1*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t2 = extra_write_data_in [epin_num + 2*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t3 = extra_write_data_in [epin_num + 3*EXTRA_OUTPUT_WIDTH];
			end
			else
		  	begin
				assign hr_data_t0 = extra_write_data_in [epin_num + 2*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t1 = extra_write_data_in [epin_num + 0*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t2 = extra_write_data_in [epin_num + 3*EXTRA_OUTPUT_WIDTH];
				assign hr_data_t3 = extra_write_data_in [epin_num + 1*EXTRA_OUTPUT_WIDTH];
			end
		
			soft_hr_ddio_out hr_to_fr_hi (
				.datainhi(hr_data_t2),
				.datainlo(hr_data_t0),
				.dataout(fr_data_hi),
				.clk (hr_clock_in)
			);		

			soft_hr_ddio_out hr_to_fr_lo (
				.datainhi(hr_data_t3),
				.datainlo(hr_data_t1),
				.dataout(fr_data_lo),
				.clk (hr_clock_in)
			);
		end
		else
		begin
			assign fr_data_lo = extra_write_data_in [epin_num+EXTRA_OUTPUT_WIDTH];
			assign fr_data_hi = extra_write_data_in [epin_num];	
		end
		
		if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
		begin
		end
		else
		begin

			arriaii_ddio_out
			#(
				.async_mode("none"),
				.half_rate_mode("false"),
				.sync_mode("none"),
				.use_new_clocking_model("true")
			) ddio_out (
				.datainhi(fr_data_hi),
				.datainlo(fr_data_lo),
				.dataout(aligned_data),
				.clkhi (dm_shifted_clock),
				.clklo (dm_shifted_clock),
				.muxsel (dm_shifted_clock)
			);
		end
		
		wire delayed_data_out;
		
		wire [3:0] dq_outputdelaysetting1;
		wire [3:0] dq_outputdelaysetting2;
		wire [3:0] dq_inputdelaysetting;
		
		assign dq_outputdelaysetting2 [3] = 1'b0;
		wire [DELAY_CHAIN_WIDTH-1:0] dq_outputdelaysetting1_dlc;
		wire [DELAY_CHAIN_WIDTH-1:0] dq_outputdelaysetting2_dlc;
		wire [DELAY_CHAIN_WIDTH-1:0] dq_inputdelaysetting_dlc;


		wire predelayed_data;
	
		if (USE_2X_FF == "true")
		begin
			reg dd_data;
			always @(posedge dq_dr_clock)
			begin
				dd_data <= aligned_data;
			end
			assign predelayed_data = dd_data;
		end
		else
		begin
			assign predelayed_data = aligned_data;
		end
	
		if (USE_DYNAMIC_CONFIG == "true")
		begin	
		end
		else
		begin
			assign delayed_data_out = predelayed_data;
		end
		arriaii_io_obuf obuf_1 (
			.i (delayed_data_out),
			.o (extra_write_data_out[epin_num]),
			.seriesterminationcontrol(seriesterminationcontrol_in),
			.oe (1'b1)
		);
	end
endgenerate
endmodule
