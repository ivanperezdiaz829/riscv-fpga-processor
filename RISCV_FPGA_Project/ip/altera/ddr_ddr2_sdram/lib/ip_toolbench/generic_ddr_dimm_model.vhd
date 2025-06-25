--------------------------------------------------------------------------------
-- This confidential and proprietary software may be used only as authorized by
-- a licensing agreement from Altera Corporation.
--
-- (C) COPYRIGHT 2004 ALTERA CORPORATION
-- ALL RIGHTS RESERVED
--
-- The entire notice above must be reproduced on all authorized copies and any
-- such reproduction must be pursuant to a licensing agreement from Altera.
--
-- Title        : DDR DIMM Model
-- Project      : DDR SDRAM Controller
--
-- File         : generic_ddr_dimm_model.vhd
--
-- Abstract:
-- This is a simulation model of a DDR DIMM which instantates all the memory
-- chips as necessary
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library auk_ddr_user_lib;
use auk_ddr_user_lib.all;


entity generic_ddr_dimm_model is
    generic
    (
        DIMM_ADDR_BITS  : integer := 12;
        DIMM_DATA_BITS  : integer := 64;
        DIMM_COL_BITS   : integer := 10;
        DIMM_BANK_BITS  : integer := 2;
        DIMM_CHIP_SELS  : integer := 2;
        DQ_PER_DQS      : integer := 8;
        DENALI          : BOOLEAN := FALSE;
        GENERIC_MODEL   : BOOLEAN := TRUE;
        DDR2            : BOOLEAN := FALSE;
        DISABLE_TIMING_CHECK : BOOLEAN := TRUE;
        registered      : boolean := FALSE;
        memory_spec     : string := "./generic_ddr_sdram.soma";
        init_file       : string := ""
    );
    port
    (
        clk         : in    std_logic;
        clk_n       : in    std_logic;

        dq          : inout std_logic_vector (DIMM_DATA_BITS - 1 downto 0) := (others => 'Z');
        dqs         : inout std_logic_vector (DIMM_DATA_BITS / DQ_PER_DQS - 1 downto 0) := (others => 'Z');
        dm          : in    std_logic_vector (DIMM_DATA_BITS / DQ_PER_DQS - 1 downto 0);

        addr        : in    std_logic_vector (DIMM_ADDR_BITS - 1 downto 0);
        ba          : in    std_logic_vector (DIMM_BANK_BITS - 1 downto 0);
        cke         : in    std_logic_vector (DIMM_CHIP_SELS - 1 downto 0);
        cs_n        : in    std_logic_vector (DIMM_CHIP_SELS - 1 downto 0);
        odt         : in    std_logic_vector (DIMM_CHIP_SELS - 1 downto 0) := (others => '0');
        ras_n       : in    std_logic;
        cas_n       : in    std_logic;
        we_n        : in    std_logic
    );
end generic_ddr_dimm_model;

architecture rtl of generic_ddr_dimm_model is


    component generic_ddr_sdram
    generic (
        BANKBITS    : integer := 2;
        ROWBITS     : integer := 12;
        DATABITS    : integer := 8;
        COLBITS     : integer := 10;
        DENALI      : boolean := FALSE;
        DISABLE_TIMING_CHECK : BOOLEAN := TRUE;
        GENERIC_MODEL   : BOOLEAN := TRUE;
        memory_spec : string := "";
        init_file   : string := ""
    );
    port (
        clk   : in    STD_LOGIC;
        clk_n : in    STD_LOGIC;
        cke   : in    STD_LOGIC;
        cs_n  : in    STD_LOGIC;
        ras_n : in    STD_LOGIC;
        cas_n : in    STD_LOGIC;
        we_n  : in    STD_LOGIC;
        dm    : in    STD_LOGIC;
        ba    : in    STD_LOGIC_VECTOR(BANKBITS-1 downto 0);
        addr  : in    STD_LOGIC_VECTOR(ROWBITS-1 downto 0);
        dq    : inout STD_LOGIC_VECTOR(DATABITS-1 downto 0);
        dqs   : inout STD_LOGIC
    );
    end component;

    component generic_ddr2_sdram
    generic (
        BANKBITS    : integer := 2;
        ROWBITS     : integer := 12;
        DATABITS    : integer := 8;
        COLBITS     : integer := 10;
        DENALI      : boolean := FALSE;
        DISABLE_TIMING_CHECK : BOOLEAN := TRUE;
        GENERIC_MODEL   : BOOLEAN := TRUE;
        memory_spec : string := "";
        init_file   : string := ""
    );
    port (
        clk   : in    STD_LOGIC;
        clk_n : in    STD_LOGIC;
        cke   : in    STD_LOGIC;
        cs_n  : in    STD_LOGIC;
        ras_n : in    STD_LOGIC;
        cas_n : in    STD_LOGIC;
        we_n  : in    STD_LOGIC;
        dm    : in    STD_LOGIC_VECTOR(0 downto 0);
        odt   : in    STD_LOGIC;
        ba    : in    STD_LOGIC_VECTOR(BANKBITS-1 downto 0);
        addr  : in    STD_LOGIC_VECTOR(ROWBITS-1 downto 0);
        dq    : inout STD_LOGIC_VECTOR(DATABITS-1 downto 0);
        dqs   : inout STD_LOGIC_VECTOR(0 downto 0);
        dqs_n : inout STD_LOGIC_VECTOR(0 downto 0)
    );
    end component;

    -- Registers
    signal r_addr   :  STD_LOGIC_VECTOR(DIMM_ADDR_BITS-1 downto 0) := (others => '0');
    signal r_cke    :  STD_LOGIC_VECTOR (DIMM_CHIP_SELS - 1 downto 0) := (others => '0');
    signal r_cs_n   :  STD_LOGIC_VECTOR (DIMM_CHIP_SELS - 1 downto 0) := (others => '0');
    signal r_odt    :  STD_LOGIC_VECTOR (DIMM_CHIP_SELS - 1 downto 0) := (others => '0');
    signal r_ras_n  :  STD_LOGIC := '1';
    signal r_cas_n  :  STD_LOGIC := '1';
    signal r_we_n   :  STD_LOGIC := '1';
    signal r_ba     :  STD_LOGIC_VECTOR(DIMM_BANK_BITS-1 downto 0) := (others => '0');

    constant tPD    : time := 3 ns;             -- Min = 2 ns, Max = 5 ns

    signal reset_n  : std_logic := '1';

begin

    regblock : if registered = TRUE generate
        process(clk, reset_n)
        begin
            if reset_n = '0' then
                -- Reset - asynchronously force all register outputs LOW
                r_addr  <= (others => '0') after tPD;
                r_ba    <= (others => '0') after tPD;
                r_cke   <= (others => '0') after tPD;
                r_cs_n  <= (others => '0') after tPD;
                r_ras_n <= '0' after tPD;
                r_cas_n <= '0' after tPD;
                r_we_n  <= '0' after tPD;
                r_odt   <= (others => '0') after tPD;
            elsif rising_edge(clk) then
                -- Registered mode - synchronous propagation of signals
                r_addr  <= addr     after tPD;
                r_ba    <= ba       after tPD;
                r_cke   <= cke      after tPD;
                r_cs_n  <= cs_n     after tPD;
                r_ras_n <= ras_n    after tPD;
                r_cas_n <= cas_n    after tPD;
                r_we_n  <= we_n     after tPD;
                r_odt   <= odt      after tPD;
            end if;
        end process;
    end generate;

    unregblock : if not registered generate
        -- Unregistered mode
        r_addr  <= addr     ;
        r_ba    <= ba       ;
        r_cke   <= cke      ;
        r_cs_n  <= cs_n     ;
        r_ras_n <= ras_n    ;
        r_cas_n <= cas_n    ;
        r_we_n  <= we_n     ;
        r_odt   <= odt      ;
    end generate;



    dimm : if TRUE generate
        side : for i in 0 to (DIMM_CHIP_SELS - 1) generate
            chip : for j in 0 to (DIMM_DATA_BITS / DQ_PER_DQS  - 1) generate
                gddr : if not DDR2 generate
                    mem : generic_ddr_sdram
                        generic map(
                            BANKBITS    => DIMM_BANK_BITS,
                            ROWBITS     => DIMM_ADDR_BITS,
                            COLBITS     => DIMM_COL_BITS,
                            DATABITS    => DQ_PER_DQS,
                            DENALI      => DENALI,
                            DISABLE_TIMING_CHECK => DISABLE_TIMING_CHECK,
                            GENERIC_MODEL      => GENERIC_MODEL,

                            memory_spec => memory_spec,
                            init_file   => init_file
                        )
                        port map (
                            clk    => clk,
                            clk_n  => clk_n,
                            cke    => r_cke(i),
                            cs_n   => r_cs_n(i),
                            ras_n  => r_ras_n,
                            cas_n  => r_cas_n,
                            we_n   => r_we_n,
                            dm     => dm(j),
                            ba     => r_ba,
                            addr   => r_addr(DIMM_ADDR_BITS-1 downto 0),
                            dq     => dq(DQ_PER_DQS * (j + 1) - 1 downto DQ_PER_DQS*j),
                            dqs    => dqs(j)
                        );
                end generate;
                gddr2 : if DDR2 generate
                    mem : generic_ddr2_sdram
                        generic map(
                            BANKBITS    => DIMM_BANK_BITS,
                            ROWBITS     => DIMM_ADDR_BITS,
                            COLBITS     => DIMM_COL_BITS,
                            DATABITS    => DQ_PER_DQS,
                            DENALI      => DENALI,
                            DISABLE_TIMING_CHECK => DISABLE_TIMING_CHECK,
                            GENERIC_MODEL      => GENERIC_MODEL,

                            memory_spec => memory_spec,
                            init_file   => init_file
                        )
                        port map (
                            clk    => clk,
                            clk_n  => clk_n,
                            cke    => r_cke(i),
                            cs_n   => r_cs_n(i),
                            ras_n  => r_ras_n,
                            cas_n  => r_cas_n,
                            we_n   => r_we_n,
                            dm     => dm(j downto j),
                            ba     => r_ba,
                            addr   => r_addr(DIMM_ADDR_BITS-1 downto 0),
                            dq     => dq(DQ_PER_DQS * (j + 1) - 1 downto DQ_PER_DQS*j),
                            dqs    => dqs(j downto j),
                            dqs_n  => open, --dqs_n(j),
                            odt    => r_odt(i)
                        );
                end generate;
            end generate;
        end generate;
    end generate;


end rtl;

