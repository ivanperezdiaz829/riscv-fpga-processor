-- (C) 2001-2013 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License Subscription 
-- Agreement, Altera MegaCore Function License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


library ieee;
    use ieee.std_logic_1164.all;

entity IPTCL_WRAPPER_NAME is
	generic (
		ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL: integer := 1
	);

        port (
`ifdef PIN_HAS_OUTPUT
		core_clock_in: in std_logic;
		reset_n_core_clock_in: in std_logic;
`endif
		fr_clock_in: in std_logic;
		hr_clock_in: in std_logic;
`ifdef USE_2X_FF
		dr_clock_in: in std_logic;
`endif
		write_strobe_clock_in: in std_logic;
`ifdef CONNECT_TO_HARD_PHY
		write_strobe: in std_logic_vector (3 downto 0);
`endif
`ifdef USE_DQS_ENABLE
		strobe_ena_hr_clock_in: in std_logic;
	`ifndef USE_HARD_FIFOS
		capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0);
	`endif
`endif
`ifdef USE_DQS_TRACKING
		capture_strobe_tracking: out std_logic;
`endif
`ifdef PIN_TYPE_BIDIR
		read_write_data_io: inout std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
`endif
`ifdef PIN_HAS_OUTPUT
		write_oe_in: in std_logic_vector (IPTCL_OUTPUT_MULT*IPTCL_PIN_WIDTH-1 downto 0);
`endif
`ifdef PIN_TYPE_INPUT
		read_data_in: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
`endif
`ifdef PIN_TYPE_OUTPUT
		write_data_out: out std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
`endif
`ifdef USE_BIDIR_STROBE
		strobe_io: inout std_logic;
		output_strobe_ena: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
	`ifdef USE_STROBE_N
		strobe_n_io: inout std_logic;
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
		output_strobe_out: out std_logic;
		`ifdef USE_STROBE_N
		output_strobe_n_out: out std_logic;
		`endif
	`endif
	
	`ifdef PIN_HAS_INPUT
		capture_strobe_in: in std_logic;
		`ifdef USE_STROBE_N
		capture_strobe_n_in: in std_logic;
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
		oct_ena_in: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
`endif
`ifdef PIN_HAS_INPUT
		read_data_out: out std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0);
		capture_strobe_out: out std_logic;
`endif
`ifdef PIN_HAS_OUTPUT
		write_data_in: in std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0);
`endif	
`ifdef HAS_EXTRA_OUTPUT_IOS
		extra_write_data_in: in std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_EXTRA_OUTPUT_WIDTH-1 downto 0);
		extra_write_data_out: out std_logic_vector (IPTCL_EXTRA_OUTPUT_WIDTH-1 downto 0);
`endif
`ifdef USE_TERMINATION_CONTROL
		parallelterminationcontrol_in: in std_logic_vector (IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1 downto 0);
		seriesterminationcontrol_in: in std_logic_vector (IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1 downto 0);
`endif
`ifdef USE_DYNAMIC_CONFIG
		config_data_in: in std_logic;
		config_update: in std_logic;
		config_dqs_ena: in std_logic;
		config_io_ena: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
`ifdef HAS_EXTRA_OUTPUT_IOS
		config_extra_io_ena: in std_logic_vector (IPTCL_EXTRA_OUTPUT_WIDTH-1 downto 0);
`endif
		config_dqs_io_ena: in std_logic;
		config_clock_in: in std_logic;
`endif
`ifdef USE_OFFSET_CTRL
		dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0);
`endif
`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
		lfifo_rdata_en: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
		lfifo_rdata_en_full: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
		lfifo_rd_latency: in std_logic_vector (4 downto 0);
		lfifo_reset_n: in std_logic; 
		lfifo_rdata_valid: out std_logic;
		vfifo_qvld : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
		vfifo_inc_wr_ptr : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0);
		vfifo_reset_n : in std_logic;
		rfifo_reset_n : in std_logic;
`endif
`endif
		dll_delayctrl_in:  in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0)
	);

end entity IPTCL_WRAPPER_NAME;



architecture RTL of IPTCL_WRAPPER_NAME is
	component IPTCL_DEFAULT_IMPLEMENTATION_NAME is
		generic (
                	PIN_WIDTH: integer := IPTCL_PIN_WIDTH;
                      	PIN_TYPE: string := "IPTCL_PIN_TYPE";
                      	USE_INPUT_PHASE_ALIGNMENT: string := "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
                      	USE_OUTPUT_PHASE_ALIGNMENT: string := "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
                      	USE_LDC_AS_LOW_SKEW_CLOCK: string := "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
                      	USE_HALF_RATE_INPUT: string := "IPTCL_USE_HALF_RATE_INPUT";
                      	USE_HALF_RATE_OUTPUT: string := "IPTCL_USE_HALF_RATE_OUTPUT";
                      	DIFFERENTIAL_CAPTURE_STROBE: string := "IPTCL_DIFFERENTIAL_CAPTURE_STROBE";
                      	SEPARATE_CAPTURE_STROBE: string := "IPTCL_SEPARATE_CAPTURE_STROBE";
                      	INPUT_FREQ:  real := real(IPTCL_INPUT_FREQ);
                      	INPUT_FREQ_PS: string := "IPTCL_INPUT_FREQ_PS ps";
                      	DELAY_CHAIN_BUFFER_MODE: string := "IPTCL_DELAY_CHAIN_BUFFER_MODE";
                      	DQS_PHASE_SETTING: integer := IPTCL_DQS_PHASE_SETTING;
                      	DQS_PHASE_SHIFT: integer := IPTCL_DQS_PHASE_SHIFT;
                      	DQS_ENABLE_PHASE_SETTING: integer := IPTCL_DQS_ENABLE_PHASE_SETTING;
                      	USE_DYNAMIC_CONFIG: string := "IPTCL_USE_DYNAMIC_CONFIG";
                      	INVERT_CAPTURE_STROBE: string := "IPTCL_INVERT_CAPTURE_STROBE";
                      	SWAP_CAPTURE_STROBE_POLARITY: string := "IPTCL_SWAP_CAPTURE_STROBE_POLARITY";
                      	USE_TERMINATION_CONTROL: string := "IPTCL_USE_TERMINATION_CONTROL";
                      	USE_DQS_ENABLE: string := "IPTCL_USE_DQS_ENABLE";
                      	USE_OUTPUT_STROBE: string := "IPTCL_USE_OUTPUT_STROBE";
                      	USE_OUTPUT_STROBE_RESET: string := "IPTCL_USE_OUTPUT_STROBE_RESET";
                      	DIFFERENTIAL_OUTPUT_STROBE: string := "IPTCL_DIFFERENTIAL_OUTPUT_STROBE";
                      	USE_BIDIR_STROBE: string := "IPTCL_USE_BIDIR_STROBE";
                      	REVERSE_READ_WORDS: string := "IPTCL_REVERSE_READ_WORDS";
                      	EXTRA_OUTPUT_WIDTH: integer := IPTCL_EXTRA_OUTPUT_WIDTH;
                      	DYNAMIC_MODE: string := "IPTCL_DYNAMIC_MODE";
                      	OCT_SERIES_TERM_CONTROL_WIDTH  : integer := IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH; 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH: integer := IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH; 
                      	DLL_WIDTH: integer := IPTCL_DLL_WIDTH;
                      	DLL_USE_2X_CLK: string := "IPTCL_DLL_USE_2X_CLK";
                      	USE_DATA_OE_FOR_OCT: string := "IPTCL_USE_DATA_OE_FOR_OCT";
                      	DQS_ENABLE_WIDTH: integer := IPTCL_STROBE_ENA_WIDTH;
                      	USE_OCT_ENA_IN_FOR_OCT: string := "IPTCL_USE_OCT_ENA_IN_FOR_OCT";
                      	PREAMBLE_TYPE: string := "IPTCL_PREAMBLE_TYPE";
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT: string := "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT";
                      	USE_OFFSET_CTRL: string := "IPTCL_USE_OFFSET_CTRL";
                      	HR_DDIO_OUT_HAS_THREE_REGS: string := "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS";
                      	DQS_ENABLE_PHASECTRL: string := "IPTCL_USE_DYNAMIC_CONFIG";
                      	USE_2X_FF: string := "IPTCL_USE_2X_FF";
                      	USE_DQS_TRACKING: string := "IPTCL_USE_DQS_TRACKING";
                      	USE_HARD_FIFOS: string := "IPTCL_USE_HARD_FIFOS";
                      	USE_DQSIN_FOR_VFIFO_READ: string := "IPTCL_USE_DQSIN_FOR_VFIFO_READ";
                      	NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
                      	SEPERATE_LDC_FOR_WRITE_STROBE: string := "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE";
                      	CALIBRATION_SUPPORT: string := "IPTCL_CALIBRATION_SUPPORT";
                      	HHP_HPS: string := "IPTCL_HHP_HPS"
                );
  		port (
			core_clock_in: in std_logic := '0';
			reset_n_core_clock_in: in std_logic := '0';
			fr_clock_in: in std_logic := '0';
			hr_clock_in: in std_logic := '0';
			dr_clock_in: in std_logic := '0';
			write_strobe_clock_in: in std_logic := '0';
			write_strobe: in std_logic_vector (3 downto 0) := (others => '0');
			strobe_ena_hr_clock_in: in std_logic := '0';
			capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0) := (others => '0');
`ifdef USE_DQS_TRACKING
			capture_strobe_tracking: out std_logic;
`endif
			read_write_data_io: inout std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
			write_oe_in: in std_logic_vector (IPTCL_OUTPUT_MULT*IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			read_data_in: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			write_data_out: out std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
			strobe_io: inout std_logic;
			output_strobe_ena: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			strobe_n_io: inout std_logic;
			output_strobe_out: out std_logic;
			output_strobe_n_out: out std_logic;
			capture_strobe_in: in std_logic := '0';
			capture_strobe_n_in: in std_logic := '0';
			oct_ena_in: in std_logic_vector (1 downto 0) := (others => '0');
			read_data_out: out std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0);
			capture_strobe_out: out std_logic;
			write_data_in: in std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			extra_write_data_in: in std_logic_vector (abs(2 * IPTCL_OUTPUT_MULT * IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0) := (others => '0');
			extra_write_data_out: out std_logic_vector (abs(IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0);
			parallelterminationcontrol_in: in std_logic_vector (IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1 downto 0) := (others => '0');
			seriesterminationcontrol_in: in std_logic_vector (IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1 downto 0) := (others => '0');
			config_data_in: in std_logic := '0';
			config_update: in std_logic := '0';
			config_dqs_ena: in std_logic := '0';
			config_io_ena: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			config_extra_io_ena: in std_logic_vector (abs(IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0) := (others => '0');
			config_dqs_io_ena: in std_logic := '0';
			config_clock_in: in std_logic := '0';
			dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			dll_delayctrl_in:  in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			lfifo_rdata_en: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			lfifo_rdata_en_full: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			lfifo_rd_latency: in std_logic_vector (4 downto 0) := (others => '0');
			lfifo_reset_n: in std_logic := '0'; 
			lfifo_rdata_valid: out std_logic := '0';
			vfifo_qvld : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			vfifo_inc_wr_ptr : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			vfifo_reset_n : in std_logic := '0';
			rfifo_reset_n : in std_logic := '0'
		);
	end component IPTCL_DEFAULT_IMPLEMENTATION_NAME;
`ifdef DUAL_IMPLEMENTATIONS
	component IPTCL_SECOND_IMPLEMENTATION_NAME is
		generic (
                	PIN_WIDTH: integer := IPTCL_PIN_WIDTH;
                      	PIN_TYPE: string := "IPTCL_PIN_TYPE";
                      	USE_INPUT_PHASE_ALIGNMENT: string := "IPTCL_USE_INPUT_PHASE_ALIGNMENT";
                      	USE_OUTPUT_PHASE_ALIGNMENT: string := "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT";
                      	USE_LDC_AS_LOW_SKEW_CLOCK: string := "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK";
                      	USE_HALF_RATE_INPUT: string := "IPTCL_USE_HALF_RATE_INPUT";
                      	USE_HALF_RATE_OUTPUT: string := "IPTCL_USE_HALF_RATE_OUTPUT";
                      	DIFFERENTIAL_CAPTURE_STROBE: string := "IPTCL_DIFFERENTIAL_CAPTURE_STROBE";
                      	SEPARATE_CAPTURE_STROBE: string := "IPTCL_SEPARATE_CAPTURE_STROBE";
                      	INPUT_FREQ:  real := real(IPTCL_INPUT_FREQ);
                      	INPUT_FREQ_PS: string := "IPTCL_INPUT_FREQ_PS ps";
                      	DELAY_CHAIN_BUFFER_MODE: string := "IPTCL_DELAY_CHAIN_BUFFER_MODE";
                      	DQS_PHASE_SETTING: integer := IPTCL_DQS_PHASE_SETTING;
                      	DQS_PHASE_SHIFT: integer := IPTCL_DQS_PHASE_SHIFT;
                      	DQS_ENABLE_PHASE_SETTING: integer := IPTCL_DQS_ENABLE_PHASE_SETTING;
                      	USE_DYNAMIC_CONFIG: string := "IPTCL_USE_DYNAMIC_CONFIG";
                      	INVERT_CAPTURE_STROBE: string := "IPTCL_INVERT_CAPTURE_STROBE";
                      	SWAP_CAPTURE_STROBE_POLARITY: string := "IPTCL_SWAP_CAPTURE_STROBE_POLARITY";
                      	USE_TERMINATION_CONTROL: string := "IPTCL_USE_TERMINATION_CONTROL";
                      	USE_DQS_ENABLE: string := "IPTCL_USE_DQS_ENABLE";
                      	USE_OUTPUT_STROBE: string := "IPTCL_USE_OUTPUT_STROBE";
                      	USE_OUTPUT_STROBE_RESET: string := "IPTCL_USE_OUTPUT_STROBE_RESET";
                      	DIFFERENTIAL_OUTPUT_STROBE: string := "IPTCL_DIFFERENTIAL_OUTPUT_STROBE";
                      	USE_BIDIR_STROBE: string := "IPTCL_USE_BIDIR_STROBE";
                      	REVERSE_READ_WORDS: string := "IPTCL_REVERSE_READ_WORDS";
                      	EXTRA_OUTPUT_WIDTH: integer := IPTCL_EXTRA_OUTPUT_WIDTH;
                      	DYNAMIC_MODE: string := "IPTCL_DYNAMIC_MODE";
                      	OCT_SERIES_TERM_CONTROL_WIDTH  : integer := IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH; 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH: integer := IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH; 
                      	DLL_WIDTH: integer := IPTCL_DLL_WIDTH;
                      	DLL_USE_2X_CLK: string := "IPTCL_DLL_USE_2X_CLK";
                      	USE_DATA_OE_FOR_OCT: string := "IPTCL_USE_DATA_OE_FOR_OCT";
                      	DQS_ENABLE_WIDTH: integer := IPTCL_STROBE_ENA_WIDTH;
                      	USE_OCT_ENA_IN_FOR_OCT: string := "IPTCL_USE_OCT_ENA_IN_FOR_OCT";
                      	PREAMBLE_TYPE: string := "IPTCL_PREAMBLE_TYPE";
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT: string := "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT";
                      	USE_OFFSET_CTRL: string := "IPTCL_USE_OFFSET_CTRL";
                      	HR_DDIO_OUT_HAS_THREE_REGS: string := "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS";
                      	DQS_ENABLE_PHASECTRL: string := "IPTCL_USE_DYNAMIC_CONFIG";
                      	USE_2X_FF: string := "IPTCL_USE_2X_FF";
                      	USE_DQS_TRACKING: string := "IPTCL_USE_DQS_TRACKING";
                      	USE_DQSIN_FOR_VFIFO_READ: string := "IPTCL_USE_DQSIN_FOR_VFIFO_READ";
                      	NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
                      	SEPERATE_LDC_FOR_WRITE_STROBE: string := "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE";
                      	CALIBRATION_SUPPORT: string := "IPTCL_CALIBRATION_SUPPORT";
                      	HHP_HPS: string := "IPTCL_HHP_HPS"
                );
  		port (
			core_clock_in: in std_logic := '0';
			reset_n_core_clock_in: in std_logic := '0';
			fr_clock_in: in std_logic := '0';
			hr_clock_in: in std_logic := '0';
			dr_clock_in: in std_logic := '0';
			write_strobe_clock_in: in std_logic := '0';
			write_strobe: in std_logic_vector (3 downto 0) := (others => '0');
			strobe_ena_hr_clock_in: in std_logic := '0';
			capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0) := (others => '0');
`ifdef USE_DQS_TRACKING
			capture_strobe_tracking: out std_logic;
`endif
			read_write_data_io: inout std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
			write_oe_in: in std_logic_vector (IPTCL_OUTPUT_MULT*IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			read_data_in: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			write_data_out: out std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0);
			strobe_io: inout std_logic;
			output_strobe_ena: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			strobe_n_io: inout std_logic;
			output_strobe_out: out std_logic;
			output_strobe_n_out: out std_logic;
			capture_strobe_in: in std_logic := '0';
			capture_strobe_n_in: in std_logic := '0';
			oct_ena_in: in std_logic_vector (1 downto 0) := (others => '0');
			read_data_out: out std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0);
			capture_strobe_out: out std_logic;
			write_data_in: in std_logic_vector (2 * IPTCL_OUTPUT_MULT * IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			extra_write_data_in: in std_logic_vector (abs(2 * IPTCL_OUTPUT_MULT * IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0) := (others => '0');
			extra_write_data_out: out std_logic_vector (abs(IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0);
			parallelterminationcontrol_in: in std_logic_vector (IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1 downto 0) := (others => '0');
			seriesterminationcontrol_in: in std_logic_vector (IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH-1 downto 0) := (others => '0');
			config_data_in: in std_logic := '0';
			config_update: in std_logic := '0';
			config_dqs_ena: in std_logic := '0';
			config_io_ena: in std_logic_vector (IPTCL_PIN_WIDTH-1 downto 0) := (others => '0');
			config_extra_io_ena: in std_logic_vector (abs(IPTCL_EXTRA_OUTPUT_WIDTH-1) downto 0) := (others => '0');
			config_dqs_io_ena: in std_logic := '0';
			config_clock_in: in std_logic := '0';
			dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			dll_delayctrl_in:  in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			lfifo_rdata_en: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			lfifo_rdata_en_full: in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			lfifo_rd_latency: in std_logic_vector (4 downto 0) := (others => '0');
			lfifo_reset_n: in std_logic := '0'; 
			lfifo_rdata_valid: out std_logic := '0';
			vfifo_qvld : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			vfifo_inc_wr_ptr : in std_logic_vector (IPTCL_OUTPUT_MULT-1 downto 0) := (others => '0');
			vfifo_reset_n : in std_logic := '0';
			rfifo_reset_n : in std_logic := '0'
		);
	end component IPTCL_SECOND_IMPLEMENTATION_NAME;
`endif 

begin

`ifdef DUAL_IMPLEMENTATIONS
fast: if (ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = 1) generate
begin
`endif 

	altdq_dqs2_inst: component IPTCL_DEFAULT_IMPLEMENTATION_NAME
		generic map (
                	PIN_WIDTH => IPTCL_PIN_WIDTH,
                      	PIN_TYPE => "IPTCL_PIN_TYPE",
                      	USE_INPUT_PHASE_ALIGNMENT => "IPTCL_USE_INPUT_PHASE_ALIGNMENT",
                      	USE_OUTPUT_PHASE_ALIGNMENT => "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT",
                      	USE_LDC_AS_LOW_SKEW_CLOCK => "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK",
                      	USE_HALF_RATE_INPUT => "IPTCL_USE_HALF_RATE_INPUT",
                      	USE_HALF_RATE_OUTPUT => "IPTCL_USE_HALF_RATE_OUTPUT",
                      	DIFFERENTIAL_CAPTURE_STROBE => "IPTCL_DIFFERENTIAL_CAPTURE_STROBE",
                      	SEPARATE_CAPTURE_STROBE => "IPTCL_SEPARATE_CAPTURE_STROBE",
                      	INPUT_FREQ => real(IPTCL_INPUT_FREQ),
                      	INPUT_FREQ_PS => "IPTCL_INPUT_FREQ_PS ps",
                      	DELAY_CHAIN_BUFFER_MODE => "IPTCL_DELAY_CHAIN_BUFFER_MODE",
                      	DQS_PHASE_SETTING => IPTCL_DQS_PHASE_SETTING,
                      	DQS_PHASE_SHIFT => IPTCL_DQS_PHASE_SHIFT,
                      	DQS_ENABLE_PHASE_SETTING => IPTCL_DQS_ENABLE_PHASE_SETTING,
                      	USE_DYNAMIC_CONFIG => "IPTCL_USE_DYNAMIC_CONFIG",
                      	INVERT_CAPTURE_STROBE => "IPTCL_INVERT_CAPTURE_STROBE",
                      	SWAP_CAPTURE_STROBE_POLARITY => "IPTCL_SWAP_CAPTURE_STROBE_POLARITY",
                      	USE_TERMINATION_CONTROL => "IPTCL_USE_TERMINATION_CONTROL",
                      	USE_DQS_ENABLE => "IPTCL_USE_DQS_ENABLE",
                      	USE_OUTPUT_STROBE => "IPTCL_USE_OUTPUT_STROBE",
                      	USE_OUTPUT_STROBE_RESET => "IPTCL_USE_OUTPUT_STROBE_RESET",
                      	DIFFERENTIAL_OUTPUT_STROBE => "IPTCL_DIFFERENTIAL_OUTPUT_STROBE",
                      	USE_BIDIR_STROBE => "IPTCL_USE_BIDIR_STROBE",
                      	REVERSE_READ_WORDS => "IPTCL_REVERSE_READ_WORDS",
                      	EXTRA_OUTPUT_WIDTH => IPTCL_EXTRA_OUTPUT_WIDTH,
                      	DYNAMIC_MODE => "IPTCL_DYNAMIC_MODE",
                      	OCT_SERIES_TERM_CONTROL_WIDTH   => IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH, 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH => IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH, 
                      	DLL_WIDTH => IPTCL_DLL_WIDTH,
                      	DLL_USE_2X_CLK => "IPTCL_DLL_USE_2X_CLK",
                      	USE_DATA_OE_FOR_OCT => "IPTCL_USE_DATA_OE_FOR_OCT",
                      	DQS_ENABLE_WIDTH => IPTCL_STROBE_ENA_WIDTH,
                      	USE_OCT_ENA_IN_FOR_OCT => "IPTCL_USE_OCT_ENA_IN_FOR_OCT",
                      	PREAMBLE_TYPE => "IPTCL_PREAMBLE_TYPE",
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT => "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT",
                      	USE_OFFSET_CTRL => "IPTCL_USE_OFFSET_CTRL",
                      	HR_DDIO_OUT_HAS_THREE_REGS => "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS",
                      	DQS_ENABLE_PHASECTRL => "IPTCL_USE_DYNAMIC_CONFIG",
                      	USE_2X_FF => "IPTCL_USE_2X_FF",
                      	USE_DQS_TRACKING => "IPTCL_USE_DQS_TRACKING",
                      	USE_HARD_FIFOS => "IPTCL_USE_HARD_FIFOS",
                      	USE_DQSIN_FOR_VFIFO_READ => "IPTCL_USE_DQSIN_FOR_VFIFO_READ",
                      	NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
                      	SEPERATE_LDC_FOR_WRITE_STROBE => "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE",
                      	CALIBRATION_SUPPORT => "IPTCL_CALIBRATION_SUPPORT",
                      	HHP_HPS => "IPTCL_HHP_HPS"
                )
  		port map (
`ifdef PIN_HAS_OUTPUT
			reset_n_core_clock_in => reset_n_core_clock_in,
			core_clock_in => core_clock_in,
`endif
			fr_clock_in => fr_clock_in,
			hr_clock_in => hr_clock_in,
`ifdef USE_2X_FF
			dr_clock_in => dr_clock_in,
`endif
			write_strobe_clock_in  =>write_strobe_clock_in,
`ifdef CONNECT_TO_HARD_PHY	
			write_strobe  => write_strobe,
`endif
`ifdef USE_DQS_ENABLE
			strobe_ena_hr_clock_in => strobe_ena_hr_clock_in,
	`ifndef USE_HARD_FIFOS
			capture_strobe_ena => capture_strobe_ena,
	`endif
`endif
`ifdef USE_DQS_TRACKING
			capture_strobe_tracking  =>capture_strobe_tracking,
`endif
`ifdef PIN_TYPE_BIDIR
			read_write_data_io => read_write_data_io,
`endif
`ifdef PIN_HAS_OUTPUT
			write_oe_in => write_oe_in,
`endif
`ifdef PIN_TYPE_INPUT
			read_data_in =>read_data_in ,
`endif
`ifdef PIN_TYPE_OUTPUT
			write_data_out => write_data_out,
`endif
`ifdef USE_BIDIR_STROBE
			strobe_io => strobe_io,
			output_strobe_ena => output_strobe_ena,
	`ifdef USE_STROBE_N
			strobe_n_io => strobe_n_io,
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
			output_strobe_out => output_strobe_out,
		`ifdef USE_STROBE_N
			output_strobe_n_out => output_strobe_n_out,
		`endif
	`endif
	`ifdef PIN_HAS_INPUT
			capture_strobe_in => capture_strobe_in,
		`ifdef USE_STROBE_N
			capture_strobe_n_in => capture_strobe_n_in,
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
			oct_ena_in(IPTCL_OUTPUT_MULT-1 downto 0) => oct_ena_in,
			oct_ena_in(1 downto IPTCL_OUTPUT_MULT) => (others => '0'),
`endif
`ifdef PIN_HAS_INPUT
			read_data_out => read_data_out,
			capture_strobe_out => capture_strobe_out,
`endif
`ifdef PIN_HAS_OUTPUT
			write_data_in => write_data_in,
`endif
`ifdef HAS_EXTRA_OUTPUT_IOS
			extra_write_data_in => extra_write_data_in,
			extra_write_data_out => extra_write_data_out,
`endif
`ifdef USE_TERMINATION_CONTROL
			parallelterminationcontrol_in => parallelterminationcontrol_in,
			seriesterminationcontrol_in => seriesterminationcontrol_in,
`endif
`ifdef USE_DYNAMIC_CONFIG
			config_data_in => config_data_in,
			config_update => config_update,
			config_dqs_ena => config_dqs_ena,
			config_io_ena => config_io_ena,
	`ifdef HAS_EXTRA_OUTPUT_IOS
			config_extra_io_ena => config_extra_io_ena,
	`endif
			config_dqs_io_ena => config_dqs_io_ena,
			config_clock_in => config_clock_in,
`endif
`ifdef USE_OFFSET_CTRL
			dll_offsetdelay_in  =>dll_offsetdelay_in,
`endif
`ifdef PIN_HAS_INPUT
`ifdef USE_HARD_FIFOS
			lfifo_rdata_en => lfifo_rdata_en,
			lfifo_rdata_en_full => lfifo_rdata_en_full,
			lfifo_rd_latency => lfifo_rd_latency,
			lfifo_reset_n => lfifo_reset_n,
			lfifo_rdata_valid => lfifo_rdata_valid,
			vfifo_qvld => vfifo_qvld,
			vfifo_inc_wr_ptr => vfifo_inc_wr_ptr,
			vfifo_reset_n => vfifo_reset_n,
			rfifo_reset_n => rfifo_reset_n,
`endif
`endif
			dll_delayctrl_in =>dll_delayctrl_in
		);

`ifdef DUAL_IMPLEMENTATIONS
 end generate;
        
slow: if (ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL /= 1) generate
begin
  
	altdq_dqs2_inst: component IPTCL_SECOND_IMPLEMENTATION_NAME
		generic map (
                	PIN_WIDTH => IPTCL_PIN_WIDTH,
                      	PIN_TYPE => "IPTCL_PIN_TYPE",
                      	USE_INPUT_PHASE_ALIGNMENT => "IPTCL_USE_INPUT_PHASE_ALIGNMENT",
                      	USE_OUTPUT_PHASE_ALIGNMENT => "IPTCL_USE_OUTPUT_PHASE_ALIGNMENT",
                      	USE_LDC_AS_LOW_SKEW_CLOCK => "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK",
                      	USE_HALF_RATE_INPUT => "IPTCL_USE_HALF_RATE_INPUT",
                      	USE_HALF_RATE_OUTPUT => "IPTCL_USE_HALF_RATE_OUTPUT",
                      	DIFFERENTIAL_CAPTURE_STROBE => "IPTCL_DIFFERENTIAL_CAPTURE_STROBE",
                      	SEPARATE_CAPTURE_STROBE => "IPTCL_SEPARATE_CAPTURE_STROBE",
                      	INPUT_FREQ => real(IPTCL_INPUT_FREQ),
                      	INPUT_FREQ_PS => "IPTCL_INPUT_FREQ_PS ps",
                      	DELAY_CHAIN_BUFFER_MODE => "IPTCL_DELAY_CHAIN_BUFFER_MODE",
                      	DQS_PHASE_SETTING => IPTCL_DQS_PHASE_SETTING,
                      	DQS_PHASE_SHIFT => IPTCL_DQS_PHASE_SHIFT,
                      	DQS_ENABLE_PHASE_SETTING => IPTCL_DQS_ENABLE_PHASE_SETTING,
                      	USE_DYNAMIC_CONFIG => "IPTCL_USE_DYNAMIC_CONFIG",
                      	INVERT_CAPTURE_STROBE => "IPTCL_INVERT_CAPTURE_STROBE",
                      	SWAP_CAPTURE_STROBE_POLARITY => "IPTCL_SWAP_CAPTURE_STROBE_POLARITY",
                      	USE_TERMINATION_CONTROL => "IPTCL_USE_TERMINATION_CONTROL",
                      	USE_DQS_ENABLE => "IPTCL_USE_DQS_ENABLE",
                      	USE_OUTPUT_STROBE => "IPTCL_USE_OUTPUT_STROBE",
                      	USE_OUTPUT_STROBE_RESET => "IPTCL_USE_OUTPUT_STROBE_RESET",
                      	DIFFERENTIAL_OUTPUT_STROBE => "IPTCL_DIFFERENTIAL_OUTPUT_STROBE",
                      	USE_BIDIR_STROBE => "IPTCL_USE_BIDIR_STROBE",
                      	REVERSE_READ_WORDS => "IPTCL_REVERSE_READ_WORDS",
                      	EXTRA_OUTPUT_WIDTH => IPTCL_EXTRA_OUTPUT_WIDTH,
                      	DYNAMIC_MODE => "IPTCL_DYNAMIC_MODE",
                      	OCT_SERIES_TERM_CONTROL_WIDTH   => IPTCL_OCT_SERIES_TERM_CONTROL_WIDTH, 
                      	OCT_PARALLEL_TERM_CONTROL_WIDTH => IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH, 
                      	DLL_WIDTH => IPTCL_DLL_WIDTH,
                      	DLL_USE_2X_CLK => "IPTCL_DLL_USE_2X_CLK",
                      	USE_DATA_OE_FOR_OCT => "IPTCL_USE_DATA_OE_FOR_OCT",
                      	DQS_ENABLE_WIDTH => IPTCL_STROBE_ENA_WIDTH,
                      	USE_OCT_ENA_IN_FOR_OCT => "IPTCL_USE_OCT_ENA_IN_FOR_OCT",
                      	PREAMBLE_TYPE => "IPTCL_PREAMBLE_TYPE",
                      	EMIF_UNALIGNED_PREAMBLE_SUPPORT => "IPTCL_EMIF_UNALIGNED_PREAMBLE_SUPPORT",
                      	USE_OFFSET_CTRL => "IPTCL_USE_OFFSET_CTRL",
                      	HR_DDIO_OUT_HAS_THREE_REGS => "IPTCL_HR_DDIO_OUT_HAS_THREE_REGS",
                      	REGULAR_WRITE_BUS_ORDERING => "IPTCL_REGULAR_WRITE_BUS_ORDERING",
                      	DQS_ENABLE_PHASECTRL => "IPTCL_USE_DYNAMIC_CONFIG",
                      	USE_2X_FF => "IPTCL_USE_2X_FF",
                      	USE_DQS_TRACKING => "IPTCL_USE_DQS_TRACKING",
                      	USE_DQSIN_FOR_VFIFO_READ => "IPTCL_USE_DQSIN_FOR_VFIFO_READ",
                      	NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
                      	SEPERATE_LDC_FOR_WRITE_STROBE => "IPTCL_SEPERATE_LDC_FOR_WRITE_STROBE",
                      	CALIBRATION_SUPPORT => "IPTCL_CALIBRATION_SUPPORT",
                      	HHP_HPS => "IPTCL_HHP_HPS"
                )
  		port map (
`ifdef PIN_HAS_OUTPUT
			reset_n_core_clock_in => reset_n_core_clock_in,
			core_clock_in => core_clock_in,
			fr_clock_in => fr_clock_in,
			hr_clock_in => hr_clock_in,
`endif
`ifdef USE_2X_FF
			dr_clock_in => dr_clock_in,
`endif
			write_strobe_clock_in  =>write_strobe_clock_in,
`ifdef CONNECT_TO_HARD_PHY	
			write_strobe  => write_strobe,
`endif
`ifdef USE_DQS_ENABLE
			strobe_ena_hr_clock_in => strobe_ena_hr_clock_in,
	`ifndef USE_HARD_FIFOS
			capture_strobe_ena => capture_strobe_ena,
	`endif
`endif
`ifdef USE_DQS_TRACKING
			capture_strobe_tracking  =>capture_strobe_tracking,
`endif
`ifdef PIN_TYPE_BIDIR
			read_write_data_io => read_write_data_io,
`endif
`ifdef PIN_HAS_OUTPUT
			write_oe_in => write_oe_in,
`endif
`ifdef PIN_TYPE_INPUT
			read_data_in =>read_data_in ,
`endif
`ifdef PIN_TYPE_OUTPUT
			write_data_out => write_data_out,
`endif
`ifdef USE_BIDIR_STROBE
			strobe_io => strobe_io,
			output_strobe_ena => output_strobe_ena,
	`ifdef USE_STROBE_N
			strobe_n_io => strobe_n_io,
	`endif
`else
	`ifdef USE_OUTPUT_STROBE
			output_strobe_out => output_strobe_out,
		`ifdef USE_STROBE_N
			output_strobe_n_out => output_strobe_n_out,
		`endif
	`endif
	`ifdef PIN_HAS_INPUT
			capture_strobe_in => capture_strobe_in,
		`ifdef USE_STROBE_N
			capture_strobe_n_in => capture_strobe_n_in,
		`endif
	`endif
`endif
`ifdef USE_OCT_ENA_IN
			oct_ena_in(IPTCL_OUTPUT_MULT-1 downto 0) => oct_ena_in,
			oct_ena_in(1 downto IPTCL_OUTPUT_MULT) => (others => '0'),
`endif
`ifdef PIN_HAS_INPUT
			read_data_out => read_data_out,
			capture_strobe_out => capture_strobe_out,
`endif
`ifdef PIN_HAS_OUTPUT
			write_data_in => write_data_in,
`endif
`ifdef HAS_EXTRA_OUTPUT_IOS
			extra_write_data_in => extra_write_data_in,
			extra_write_data_out => extra_write_data_out,
`endif
`ifdef USE_TERMINATION_CONTROL
			parallelterminationcontrol_in => parallelterminationcontrol_in,
			seriesterminationcontrol_in => seriesterminationcontrol_in,
`endif
`ifdef USE_DYNAMIC_CONFIG
			config_data_in => config_data_in,
			config_update => config_update,
			config_dqs_ena => config_dqs_ena,
			config_io_ena => config_io_ena,
	`ifdef HAS_EXTRA_OUTPUT_IOS
			config_extra_io_ena => config_extra_io_ena,
	`endif
			config_dqs_io_ena => config_dqs_io_ena,
			config_clock_in => config_clock_in,
`endif
`ifdef USE_OFFSET_CTRL
			dll_offsetdelay_in  =>dll_offsetdelay_in,
`endif
			dll_delayctrl_in =>dll_delayctrl_in
		);
end generate;

`endif 


end architecture RTL;
