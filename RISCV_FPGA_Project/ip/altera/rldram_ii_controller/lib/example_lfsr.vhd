library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity example_lfsr is

    generic
    (
        seed                 : integer := 32;        -- starting seed
        gMEM_DQ_PER_DQS      : integer := 8
    );
    port
    (
        -- globals
        clk                  : in   std_logic;
        reset_n              : in   std_logic;

        -- local interface, read and write data
        enable               : in   std_logic;
        pause                : in   std_logic;
        load                 : in   std_logic;

        data                 : out  std_logic_vector(gMEM_DQ_PER_DQS - 1 downto 0)
    );

end example_lfsr;



architecture rtl of example_lfsr is

signal  lfsr_data  : std_logic_vector(17 downto 0);

begin

    data <= lfsr_data(gMEM_DQ_PER_DQS - 1 downto 0);

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset - asynchronously reset to seed value
            lfsr_data(gMEM_DQ_PER_DQS - 1 downto 0) <= conv_std_logic_vector(seed, gMEM_DQ_PER_DQS);

        elsif rising_edge(clk) then
            -- Registered mode - synchronous propagation of signals

			if (enable = '0') then
				lfsr_data(gMEM_DQ_PER_DQS - 1 downto 0) <= conv_std_logic_vector(seed, gMEM_DQ_PER_DQS);
			else
				if (load = '1') then
					lfsr_data(gMEM_DQ_PER_DQS - 1 downto 0) <= conv_std_logic_vector(seed, gMEM_DQ_PER_DQS);
				else
					if (pause = '0') then
						lfsr_data(0)  <= lfsr_data(7);
						lfsr_data(1)  <= lfsr_data(0);
						lfsr_data(2)  <= lfsr_data(1) xor lfsr_data(gMEM_DQ_PER_DQS - 1);
						lfsr_data(3)  <= lfsr_data(2) xor lfsr_data(gMEM_DQ_PER_DQS - 1);
						lfsr_data(4)  <= lfsr_data(3) xor lfsr_data(gMEM_DQ_PER_DQS - 1);
						lfsr_data(5)  <= lfsr_data(4);
						lfsr_data(6)  <= lfsr_data(5);
						lfsr_data(7)  <= lfsr_data(6);
						lfsr_data(8)  <= lfsr_data(7);			    		    
						lfsr_data(9)  <= lfsr_data(8);			    		    
						lfsr_data(10) <= lfsr_data(9);			    		    
						lfsr_data(11) <= lfsr_data(10);			    		    
						lfsr_data(12) <= lfsr_data(11);			    		    
						lfsr_data(13) <= lfsr_data(12);			    		    
						lfsr_data(14) <= lfsr_data(13);			    		    
						lfsr_data(15) <= lfsr_data(14);			    		    
						lfsr_data(16) <= lfsr_data(15);			    		    
						lfsr_data(17) <= lfsr_data(16);			    		    
					end if;
				end if;
			end if;
        end if;
    end process;

end rtl;

