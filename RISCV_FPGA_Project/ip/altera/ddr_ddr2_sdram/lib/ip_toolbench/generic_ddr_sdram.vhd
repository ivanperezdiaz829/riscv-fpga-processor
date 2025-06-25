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
-- Title        : DDR SDRAM Generic Model Wrapper
-- Project      : DDR SDRAM Controller
--
-- File         : generic_ddr_sdram.vhd
--
-- Abstract:
-- This is a wrapper that allows different memory simulation models to be instantiated
-- dependent on the generics that are set. It should be edited to include your chosen
-- DDR memory model.
--
--------------------------------------------------------------------------------

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
    USE IEEE.STD_LOGIC_ARITH.ALL;

LIBRARY auk_ddr_user_lib;
use auk_ddr_user_lib.all;


ENTITY generic_ddr_sdram is
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
        dqs   : inout std_logic;
        addr  : in    std_logic_vector (ROWBITS - 1 downto 0);
        ba    : in    std_logic_vector (BANKBITS-1 downto 0);
        clk   : in    std_logic;
        clk_n : in    std_logic;
        cke   : in    std_logic;
        cs_n  : in    std_logic;
        ras_n : in    std_logic;
        cas_n : in    std_logic;
        we_n  : in    std_logic;
        dm    : in    std_logic
    );
end generic_ddr_sdram;

architecture rtl of generic_ddr_sdram is

component generic_ddr_sdram_denali
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
    dqs   : inout STD_LOGIC
);
end component;

component generic_ddr_sdram_rtl
generic (
    BANKBITS    : integer := 2;
    ROWBITS     : integer := 12;
    COLBITS     : integer := 10;
    DATABITS    : integer := 8;
    DISABLE_TIMING_CHECK : boolean := TRUE;
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
    dqs   : inout STD_LOGIC
);
end component;



-- MT46V16M8 (4 Mb x 8 x 4 Banks) Micron 128 Mb SDRAM DDR (Double Data Rate)
COMPONENT mt46v16m8
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (DATABITS - 1 DOWNTO 0);
        Dqs   : INOUT STD_LOGIC;
        Addr  : IN    STD_LOGIC_VECTOR (ROWBITS - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC
    );
END COMPONENT;

-- MT46V32M8 (8 Mb x 8 x 4 Banks) Micron 256 Mb SDRAM DDR (Double Data Rate)
COMPONENT mt46v32m8
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (DATABITS - 1 DOWNTO 0);
        Dqs   : INOUT STD_LOGIC;
        Addr  : IN    STD_LOGIC_VECTOR (ROWBITS - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC
    );
END COMPONENT;

-- (16 Mb x 8 x 4 Banks) Micron 512 Mb SDRAM DDR (Double Data Rate)
COMPONENT mt46v64m8
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (DATABITS - 1 DOWNTO 0);
        Dqs   : INOUT STD_LOGIC;
        Addr  : IN    STD_LOGIC_VECTOR (ROWBITS - 1 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0);
        Clk   : IN    STD_LOGIC;
        Clk_n : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dm    : IN    STD_LOGIC
    );
END COMPONENT;


begin


    -- Instantiate example Micron memory models
    -- Download these models from www.micron.com, and place in the quartus project 'testbench' subdirectory
    gen_not_generic_model : if not GENERIC_MODEL generate

        gen_8bit : if DATABITS = 8 generate

            gen_8bit_12rowbits : if ROWBITS = 12 generate
                gen_8bit_row12_col10 : if COLBITS = 10 generate
                    mem : mt46v16m8  -- (4 Mb x 8 x 4 Banks) Micron 128 Mb SDRAM DDR (Double Data Rate)

                        port map (
                            clk    => clk,
                            clk_n  => clk_n,
                            cke    => cke,
                            cs_n   => cs_n,
                            ras_n  => ras_n,
                            cas_n  => cas_n,
                            we_n   => we_n,
                            dm     => dm,
                            ba     => ba,
                            addr   => addr,
                            dq     => dq,
                            dqs    => dqs
                        );
                end generate;
            end generate;

            gen_8bit_13rowbits : if ROWBITS = 13 generate
                gen_8bit_row13_col10 : if COLBITS = 10 generate
                    mem : mt46v32m8  -- (8 Mb x 8 x 4 Banks) Micron 256 Mb SDRAM DDR (Double Data Rate)
                        port map (
                            clk    => clk,
                            clk_n  => clk_n,
                            cke    => cke,
                            cs_n   => cs_n,
                            ras_n  => ras_n,
                            cas_n  => cas_n,
                            we_n   => we_n,
                            dm     => dm,
                            ba     => ba,
                            addr   => addr,
                            dq     => dq,
                            dqs    => dqs
                        );
                end generate;

                gen_8bit_row13_col11 : if COLBITS = 11 generate
                    mem : mt46v64m8 -- (16 Mb x 8 x 4 Banks) Micron 512 Mb SDRAM DDR (Double Data Rate)
                        port map (
                            clk    => clk,
                            clk_n  => clk_n,
                            cke    => cke,
                            cs_n   => cs_n,
                            ras_n  => ras_n,
                            cas_n  => cas_n,
                            we_n   => we_n,
                            dm     => dm,
                            ba     => ba,
                            addr   => addr,
                            dq     => dq,
                            dqs    => dqs
                        );
                end generate;

            end generate;

        end generate;
    end generate;


    gen_generic_model : if GENERIC_MODEL generate
        gen_denali_model : if DENALI generate
            mem : generic_ddr_sdram_denali
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
                    dm     => dm,
                    ba     => ba,
                    addr   => addr,
                    dq     => dq,
                    dqs    => dqs
                );
        end generate;
        gen_rtl_model : if not DENALI generate
            mem : generic_ddr_sdram_rtl
                generic map(
                    BANKBITS    => BANKBITS,
                    ROWBITS     => ROWBITS,
                    COLBITS     => COLBITS,
                    DATABITS    => DATABITS,
                    DISABLE_TIMING_CHECK => DISABLE_TIMING_CHECK,
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
                    dm     => dm,
                    ba     => ba,
                    addr   => addr,
                    dq     => dq,
                    dqs    => dqs
                );
        end generate;
    end generate;


END rtl;
