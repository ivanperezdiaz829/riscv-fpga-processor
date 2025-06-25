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
`ifdef DUAL_WRITE_CLOCK
		fr_data_clock_in: in std_logic;
		fr_strobe_clock_in: in std_logic;
`else
		fr_clock_in: in std_logic;
`endif
`endif
		hr_clock_in: in std_logic;
`ifdef USE_2X_FF
		dr_clock_in: in std_logic;
`endif
`ifdef USE_OUTPUT_STROBE
		write_strobe_clock_in: in std_logic;
`endif	
`ifdef USE_DQS_ENABLE
		strobe_ena_hr_clock_in: in std_logic;
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
		strobe_ena_clock_in: in std_logic;
		`endif
	`endif
	`ifdef ARRIAVGZ
		capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0);
	`else
	`ifdef STRATIXV
		capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0);
	`else
		`ifndef USE_HARD_FIFOS
		capture_strobe_ena: in std_logic_vector (IPTCL_STROBE_ENA_WIDTH-1 downto 0);
		`endif
	`endif
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
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
    external_ddio_capture_clock: in std_logic;
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
    external_fifo_capture_clock: in std_logic;
`endif
`ifdef USE_SHADOW_REGS
    corerankselectwritein:  in std_logic_vector (1 downto 0);
    corerankselectreadin:  in std_logic;
    coredqsenabledelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0);
    coredqsdisablendelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0);
    coremultirankdelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0);
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
`ifndef ARRIAIIGX
		parallelterminationcontrol_in: in std_logic_vector (IPTCL_OCT_PARALLEL_TERM_CONTROL_WIDTH-1 downto 0);
`endif
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

`ifdef USE_HARD_FIFOS
		lfifo_rden: in std_logic;
		vfifo_qvld: in std_logic;
		rfifo_reset_n: in std_logic;
`endif 

`ifdef USE_OFFSET_CTRL
		dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0);
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
                        OUTPUT_DQS_PHASE_SETTING: integer := IPTCL_OUTPUT_DQS_PHASE_SETTING;
                        OUTPUT_DQ_PHASE_SETTING: integer := IPTCL_OUTPUT_DQ_PHASE_SETTING;												
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
                      	EXTRA_OUTPUTS_USE_SEPARATE_GROUP: string := "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP";
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
                      	DUAL_WRITE_CLOCK: string := "false";
                      	USE_HARD_FIFOS: string := "IPTCL_USE_HARD_FIFOS";
			USE_CAPTURE_REG_EXTERNAL_CLOCKING: string := "false";
			USE_READ_FIFO_EXTERNAL_CLOCKING: string := "false";
`ifdef ARRIAV
                        NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
`endif
`ifdef CYCLONEV
                        NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
`endif
`ifdef ARRIAVGZ
                        USE_SHADOW_REGS: string := "IPTCL_USE_SHADOW_REGS";
`else
`ifdef STRATIXV
                        USE_SHADOW_REGS: string := "IPTCL_USE_SHADOW_REGS";
`endif
`endif
                        DELAY_CHAIN_WIDTH: integer := IPTCL_DELAY_CHAIN_WIDTH;
                        CALIBRATION_SUPPORT: string := "IPTCL_CALIBRATION_SUPPORT";
                        DQS_ENABLE_AFTER_T7: string := "IPTCL_DQS_ENABLE_AFTER_T7"

                );
  		port (
			core_clock_in: in std_logic := '0';
			reset_n_core_clock_in: in std_logic := '0';
			fr_clock_in: in std_logic := '0';
			fr_data_clock_in: in std_logic := '0';
			fr_strobe_clock_in: in std_logic := '0';
			hr_clock_in: in std_logic := '0';
			dr_clock_in: in std_logic := '0';
			write_strobe_clock_in: in std_logic := '0';
			strobe_ena_hr_clock_in: in std_logic := '0';
			strobe_ena_clock_in: in std_logic := '0';
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
			external_ddio_capture_clock: in std_logic := '0';
			external_fifo_capture_clock: in std_logic := '0';
			corerankselectwritein:  in std_logic_vector (1 downto 0) := (others => '0');
			corerankselectreadin:  in std_logic := '0';
			coredqsenabledelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
			coredqsdisablendelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
			coremultirankdelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
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

			lfifo_rden: in std_logic;
			vfifo_qvld: in std_logic;
			rfifo_reset_n: in std_logic;

			dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			dll_delayctrl_in:  in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0')
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
                        OUTPUT_DQS_PHASE_SETTING: integer := IPTCL_OUTPUT_DQS_PHASE_SETTING;
                        OUTPUT_DQ_PHASE_SETTING: integer := IPTCL_OUTPUT_DQ_PHASE_SETTING;						
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
                      	EXTRA_OUTPUTS_USE_SEPARATE_GROUP: string := "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP";
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
			DUAL_WRITE_CLOCK: string := "false";
			USE_CAPTURE_REG_EXTERNAL_CLOCKING: string := "false";
			USE_READ_FIFO_EXTERNAL_CLOCKING: string := "false";
`ifdef ARRIAV
                        NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
`endif
`ifdef CYCLONEV
                        NATURAL_ALIGNMENT: string := "IPTCL_NATURAL_ALIGNMENT";
`endif
`ifdef ARRIAVGZ
                        USE_SHADOW_REGS: string := "IPTCL_USE_SHADOW_REGS";
`else
`ifdef STRATIXV
                        USE_SHADOW_REGS: string := "IPTCL_USE_SHADOW_REGS";
`endif
`endif
                        DELAY_CHAIN_WIDTH: integer := IPTCL_DELAY_CHAIN_WIDTH;
                        CALIBRATION_SUPPORT: string := "IPTCL_CALIBRATION_SUPPORT";
                        DQS_ENABLE_AFTER_T7: string := "IPTCL_DQS_ENABLE_AFTER_T7"

                );
  		port (
			core_clock_in: in std_logic := '0';
			reset_n_core_clock_in: in std_logic := '0';
			fr_clock_in: in std_logic := '0';
			fr_data_clock_in: in std_logic := '0';
			fr_strobe_clock_in: in std_logic := '0';
			hr_clock_in: in std_logic := '0';
			dr_clock_in: in std_logic := '0';
			write_strobe_clock_in: in std_logic := '0';
			strobe_ena_hr_clock_in: in std_logic := '0';
			strobe_ena_clock_in: in std_logic := '0';
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
			external_ddio_capture_clock: in std_logic := '0';
			external_fifo_capture_clock: in std_logic := '0';
			corerankselectwritein:  in std_logic_vector (1 downto 0) := (others => '0');
			corerankselectreadin:  in std_logic := '0';
			coredqsenabledelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
			coredqsdisablendelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
			coremultirankdelayctrlin: in std_logic_vector (IPTCL_DELAY_CHAIN_WIDTH-1 downto 0) := (others => '0');
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

			lfifo_rden: in std_logic;
			vfifo_qvld: in std_logic;
			rfifo_reset_n: in std_logic;

			dll_offsetdelay_in: in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0');
			dll_delayctrl_in:  in std_logic_vector (IPTCL_DLL_WIDTH-1 downto 0) := (others => '0')
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
                        OUTPUT_DQS_PHASE_SETTING => IPTCL_OUTPUT_DQS_PHASE_SETTING,
                        OUTPUT_DQ_PHASE_SETTING => IPTCL_OUTPUT_DQ_PHASE_SETTING,
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
                      	EXTRA_OUTPUTS_USE_SEPARATE_GROUP => "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP",
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
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
			USE_CAPTURE_REG_EXTERNAL_CLOCKING => "true",
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
			USE_READ_FIFO_EXTERNAL_CLOCKING => "true",
`endif
`ifdef DUAL_WRITE_CLOCK
                      	DUAL_WRITE_CLOCK => "true",
`endif
`ifdef ARRIAV
                        NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
`endif
`ifdef CYCLONEV
                        NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
`endif
`ifdef ARRIAVGZ
                        USE_SHADOW_REGS => "IPTCL_USE_SHADOW_REGS",
`else
`ifdef STRATIXV
                        USE_SHADOW_REGS => "IPTCL_USE_SHADOW_REGS",
`endif
`endif
                        DELAY_CHAIN_WIDTH => IPTCL_DELAY_CHAIN_WIDTH,
                      	CALIBRATION_SUPPORT => "IPTCL_CALIBRATION_SUPPORT",
                        DQS_ENABLE_AFTER_T7 => "IPTCL_DQS_ENABLE_AFTER_T7"
                    
                )
  		port map (
`ifdef PIN_HAS_OUTPUT
			reset_n_core_clock_in => reset_n_core_clock_in,
			core_clock_in => core_clock_in,
`ifdef DUAL_WRITE_CLOCK
			fr_data_clock_in => fr_data_clock_in,
			fr_strobe_clock_in => fr_strobe_clock_in,
`else
			fr_clock_in => fr_clock_in,
`endif
`endif
			hr_clock_in => hr_clock_in,
`ifdef USE_2X_FF
			dr_clock_in => dr_clock_in,
`endif
`ifdef USE_OUTPUT_STROBE	
			write_strobe_clock_in  =>write_strobe_clock_in,
`endif
`ifdef USE_DQS_ENABLE
			strobe_ena_hr_clock_in => strobe_ena_hr_clock_in,
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
			strobe_ena_clock_in => strobe_ena_clock_in,
		`endif
	`endif
	`ifdef ARRIAVGZ
			capture_strobe_ena => capture_strobe_ena,
	`else
	`ifdef STRATIXV
			capture_strobe_ena => capture_strobe_ena,
	`else
		`ifndef USE_HARD_FIFOS
			capture_strobe_ena => capture_strobe_ena,
		`endif
	`endif
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

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
    external_ddio_capture_clock => external_ddio_capture_clock,
`else
    external_ddio_capture_clock => '0',
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
    external_fifo_capture_clock => external_fifo_capture_clock,
`else
    external_fifo_capture_clock => '0',
`endif

`ifdef USE_SHADOW_REGS
    corerankselectwritein => corerankselectwritein,
    corerankselectreadin => corerankselectreadin,
    coredqsenabledelayctrlin => coredqsenabledelayctrlin,
    coredqsdisablendelayctrlin => coredqsdisablendelayctrlin,
    coremultirankdelayctrlin => coremultirankdelayctrlin,
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
`ifndef ARRIAIIGX
			parallelterminationcontrol_in => parallelterminationcontrol_in,
`endif
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

`ifdef USE_HARD_FIFOS
			lfifo_rden => lfifo_rden,
			vfifo_qvld => vfifo_qvld,
			rfifo_reset_n => rfifo_reset_n,
`else
			lfifo_rden => '0',
			vfifo_qvld => '0',
			rfifo_reset_n => '0',
`endif

`ifdef USE_OFFSET_CTRL
			dll_offsetdelay_in  =>dll_offsetdelay_in,
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
                        OUTPUT_DQS_PHASE_SETTING => IPTCL_OUTPUT_DQS_PHASE_SETTING,
                        OUTPUT_DQ_PHASE_SETTING => IPTCL_OUTPUT_DQ_PHASE_SETTING,
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
                      	EXTRA_OUTPUTS_USE_SEPARATE_GROUP => "IPTCL_EXTRA_OUTPUTS_USE_SEPARATE_GROUP",
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
`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
			USE_CAPTURE_REG_EXTERNAL_CLOCKING => "true",
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
			USE_READ_FIFO_EXTERNAL_CLOCKING => "true",
`endif
`ifdef DUAL_WRITE_CLOCK
                      	DUAL_WRITE_CLOCK => "true",
`endif
`ifdef ARRIAV
                        NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
`endif
`ifdef CYCLONEV
                        NATURAL_ALIGNMENT => "IPTCL_NATURAL_ALIGNMENT",
`endif
`ifdef ARRIAVGZ
                        USE_SHADOW_REGS => "IPTCL_USE_SHADOW_REGS",
`else
`ifdef STRATIXV
                        USE_SHADOW_REGS => "IPTCL_USE_SHADOW_REGS",
`endif
`endif
                        DELAY_CHAIN_WIDTH => IPTCL_DELAY_CHAIN_WIDTH,
                        CALIBRATION_SUPPORT => "IPTCL_CALIBRATION_SUPPORT",
                        DQS_ENABLE_AFTER_T7 => "IPTCL_DQS_ENABLE_AFTER_T7"
                  )
  		port map (
`ifdef PIN_HAS_OUTPUT
			reset_n_core_clock_in => reset_n_core_clock_in,
			core_clock_in => core_clock_in,
`ifdef DUAL_WRITE_CLOCK
			fr_data_clock_in => fr_data_clock_in,
			fr_strobe_clock_in => fr_strobe_clock_in,
`else
			fr_clock_in => fr_clock_in,
`endif
`endif
			hr_clock_in => hr_clock_in,
`ifdef USE_2X_FF
			dr_clock_in => dr_clock_in,
`endif
`ifdef USE_OUTPUT_STROBE	
			write_strobe_clock_in  =>write_strobe_clock_in,
`endif
`ifdef USE_DQS_ENABLE
			strobe_ena_hr_clock_in => strobe_ena_hr_clock_in,
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
			strobe_ena_clock_in => strobe_ena_clock_in,
		`endif
	`endif
	`ifdef ARRIAVGZ
			capture_strobe_ena => capture_strobe_ena,
	`else
	`ifdef STRATIXV
			capture_strobe_ena => capture_strobe_ena,
	`else
		`ifndef USE_HARD_FIFOS
			capture_strobe_ena => capture_strobe_ena,
		`endif
	`endif
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

`ifdef USE_CAPTURE_REG_EXTERNAL_CLOCKING
    external_ddio_capture_clock => external_ddio_capture_clock,
`else
    external_ddio_capture_clock => '0',
`endif
`ifdef USE_READ_FIFO_EXTERNAL_CLOCKING
    external_fifo_capture_clock => external_fifo_capture_clock,
`else
    external_fifo_capture_clock => '0',
`endif

`ifdef USE_SHADOW_REGS
    corerankselectwritein => corerankselectwritein,
    corerankselectreadin => corerankselectreadin,
    coredqsenabledelayctrlin => coredqsenabledelayctrlin,
    coredqsdisablendelayctrlin => coredqsdisablendelayctrlin,
    coremultirankdelayctrlin => coremultirankdelayctrlin,
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
`ifndef ARRIAIIGX
			parallelterminationcontrol_in => parallelterminationcontrol_in,
`endif
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

`ifdef USE_HARD_FIFOS
			lfifo_rden => lfifo_rden,
			vfifo_qvld => vfifo_qvld,
			rfifo_reset_n => rfifo_reset_n,
`else
			lfifo_rden => '0',
			vfifo_qvld => '0',
			rfifo_reset_n => '0',
`endif

`ifdef USE_OFFSET_CTRL
			dll_offsetdelay_in  =>dll_offsetdelay_in,
`endif
			dll_delayctrl_in =>dll_delayctrl_in
		);
end generate;

`endif 


end architecture RTL;
