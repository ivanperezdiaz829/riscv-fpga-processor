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
-- Title        : DDR2 SDRAM Generic Model Wrapper
-- Project      : DDR SDRAM Controller
--
-- File         : generic_ddr2_sdram.vhd
--
-- Abstract:
-- This is a wrapper that allows different memory simulation models to be instantiated
-- dependent on the generics that are set. It should be edited to include your chosen
-- DDR2 memory model.
--
--------------------------------------------------------------------------------

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    USE IEEE.STD_LOGIC_ARITH.ALL;


ENTITY generic_ddr2_sdram is
    generic (
        ROWBITS : INTEGER := 12;
        DATABITS : INTEGER :=  8;
        COLBITS : INTEGER := 10;
        BANKBITS : INTEGER := 2;
        DENALI : BOOLEAN := FALSE;
        GENERIC_MODEL : BOOLEAN := TRUE;
        DISABLE_TIMING_CHECK : BOOLEAN := TRUE;
        memory_spec: string := "";
        init_file:   string := ""
    );
    PORT (
        dq    : inout std_logic_vector (DATABITS - 1 downto 0);
        dqs   : inout std_logic_vector(0 downto 0);
        odt   : in    std_logic;
        dqs_n : inout std_logic_vector(0 downto 0);
        addr  : in    std_logic_vector (ROWBITS - 1 downto 0);
        ba    : in    std_logic_vector (BANKBITS-1 downto 0);
        clk   : in    std_logic;
        clk_n : in    std_logic;
        cke   : in    std_logic;
        cs_n  : in    std_logic;
        ras_n : in    std_logic;
        cas_n : in    std_logic;
        we_n  : in    std_logic;
        dm    : in    std_logic_vector(0 downto 0)
    );
end generic_ddr2_sdram;

architecture rtl of generic_ddr2_sdram is

component generic_ddr2_sdram_denali
generic (
    BANKBITS    : integer := 2;
    ROWBITS     : integer := 12;
    DATABITS    : integer := 8;
    memory_spec: string := "";
    init_file:   string := ""
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
    dqs   : inout STD_LOGIC;
    dqs_n : inout STD_LOGIC;
    odt   : in    STD_LOGIC
);
end component;

component generic_ddr2_sdram_rtl
generic (
    BANKBITS    : integer := 2;
    ROWBITS     : integer := 12;
    COLBITS     : integer := 10;
    DATABITS    : integer := 8
);
port (
    CLK   : in    STD_LOGIC;
    CLK_N : in    STD_LOGIC;
    CKE   : in    STD_LOGIC;
    CS_N  : in    STD_LOGIC;
    RAS_N : in    STD_LOGIC;
    CAS_N : in    STD_LOGIC;
    WE_N  : in    STD_LOGIC;
    DM_RDQS    : inout    STD_LOGIC_VECTOR(0 downto 0);
    BA    : in    STD_LOGIC_VECTOR(BANKBITS-1 downto 0);
    ADDR  : in    STD_LOGIC_VECTOR(ROWBITS-1 downto 0);
    DQ    : inout STD_LOGIC_VECTOR(DATABITS-1 downto 0);
    DQS   : inout STD_LOGIC_VECTOR(0 downto 0);
    DQS_N : inout STD_LOGIC_VECTOR(0 downto 0);
    RDQS_N: out   STD_LOGIC_VECTOR(0 downto 0);
    ODT   : in    STD_LOGIC
);
end component;

signal dm_sig : std_logic_vector(0 downto 0);

begin

    dm_sig <= dm;

    gen_not_generic_model : if not GENERIC_MODEL generate
        gen_8bit : if DATABITS = 8 generate
            gen_8bit_12rowbits : if ROWBITS = 12 generate
                gen_8bit_row12_col10 : if COLBITS = 10 generate
--                    mem : MT123456
--                        port map (
--                            clk    => clk,
--                            clk_n  => clk_n,
--                            cke    => cke,
--                            cs_n   => cs_n,
--                            ras_n  => ras_n,
--                            cas_n  => cas_n,
--                            we_n   => we_n,
--                            dm     => dm,
--                            ba     => ba,
--                            addr   => addr,
--                            dq     => dq,
--                            dqs    => dqs
--                        );
                end generate;
            end generate;
        end generate;
    end generate;


    gen_generic_model : if GENERIC_MODEL generate
        gen_denali_model : if DENALI generate
            mem : generic_ddr2_sdram_denali
                generic map(
                    BANKBITS    => BANKBITS,
                    ROWBITS     => ROWBITS,
                    DATABITS    => DATABITS,
                    memory_spec => memory_spec,
                    init_file   => init_file
                )
                port map (
                    clk    => clk,
                    clk_n  => clk_n,
                    cke    => cke,
                    cs_n   => cs_n,
                    ras_n  => ras_n,
                    cas_n  => cas_n,
                    we_n   => we_n,
                    dm     => dm(0),
                    ba     => ba,
                    addr   => addr,
                    dq     => dq,
                    dqs    => dqs(0),
                    dqs_n  => dqs_n(0),
                    odt    => odt
                );
        end generate;
        gen_rtl_model : if not DENALI generate
            mem : generic_ddr2_sdram_rtl
                generic map(
                    BANKBITS    => BANKBITS,
                    ROWBITS     => ROWBITS,
                    COLBITS     => COLBITS,
                    DATABITS    => DATABITS
--                    DISABLE_TIMING_CHECK => DISABLE_TIMING_CHECK,
--                    memory_spec => memory_spec,
--                    init_file   => init_file
                )
                port map (
                    CLK    => clk,
                    CLK_N  => clk_n,
                    CKE    => cke,
                    CS_N   => cs_n,
                    RAS_N  => ras_n,
                    CAS_N  => cas_n,
                    WE_N   => we_n,
                    DM_RDQS     => dm_sig,
                    BA     => ba,
                    ADDR   => addr,
                    DQ     => dq,
                    DQS    => dqs,
                    DQS_N  => dqs_n,
                    RDQS_N => open,
                    ODT    => odt
                );
        end generate;
    end generate;


END rtl;
