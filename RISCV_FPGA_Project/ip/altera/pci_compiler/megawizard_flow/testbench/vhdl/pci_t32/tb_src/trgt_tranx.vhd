--------------------------------------------------------------------------------------
-- Altera PCI testbench
-- MODULE NAME: trgt_tranx
-- COMPANY:  Altera Coporation.
--            www.altera.com    

-- FUNCTIONAL DESCRIPTION:
-- This file simulates the Target agent on the PCI bus.
-- You can modify the procedures or tasks to introduce different variations
-- in the PCI transaction as desired by your application. 
-- You can modify the memory range of trgtet transactor by changing 
-- the ADDRESS_LINES constant value and mem_hit_range

-- REVISION HISTORY:  
-- Revision 1.1 Description: Fixed the address increment logic for 32 bit transfers
-- Revision 1.0 Description: Initial Release.
--
--  Copyright (C) 1991-2004 Altera Corporation, All rights reserved.  
--  Altera products are protected under numerous U.S. and foreign patents, 
--  maskwork rights, copyrights and other intellectual property laws. 
--  This reference design file, and your use thereof, is subject to and 
--  governed by the terms and conditions of the applicable Altera Reference 
--  Design License Agreement (either as signed by you or found at www.altera.com).  
--  By using this reference design file, you indicate your acceptance of such terms 
--  and conditions between you and Altera Corporation.  In the event that you do
--  not agree with such terms and conditions, you may not use the reference design 
--  file and please promptly destroy any copies you have made. 
--  This reference design file is being provided on an 'as-is' basis and as an 
--  accommodation and therefore all warranties, representations or guarantees 
--  of any kind (whether express, implied or statutory) including, without limitation, 
--  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
--  are specifically disclaimed.  By making this reference design file available, 
--  Altera expressly does not recommend, suggest or require that this reference design 
--  file be used in combination with any other product not provided by Altera.
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity trgt_tranx is 
       generic (
       
        address_lines       : integer := 1024; --Must be a power of 2 
        mem_hit_range       : std_logic_vector(31 downto 0) := x"000003FF";
        io_hit_range        : std_logic_vector(31 downto 0) := x"0000000F"
                );
port(
        --pci signals
        --system
                clk                   : in std_logic;              --clock                    
                rstn                  : in std_logic;              --reset         
                                    
        --address/data              
                ad                    : inout std_logic_vector(31 downto 0); --Address          
                cben                  : in std_logic_vector(3 downto 0);     --Command byte enable     
                par                   : inout std_logic;                     --Parity for lower dword         
                     
                idsel                 : in std_logic;    -- Idsel signal which is connected to Ad(29) in the top level file
                                    
                framen                : in std_logic;                        
                irdyn                 : in std_logic;                        
                devseln               : out std_logic;                          
                trdyn                 : out std_logic;                            
                stopn                 : out std_logic;
                                    
                perrn                 : out std_logic;
                serrn                 : out std_logic;
                
                trgt_tranx_disca      : in std_logic;    -- Disconnect trgtet transactor with type-A
                trgt_tranx_discb      : in std_logic;    -- Disconnect trgtet transactor with type-B
                trgt_tranx_retry      : in std_logic);   -- Retry the trgtet transaction.     
   

end trgt_tranx;


architecture behavior of trgt_tranx is


----------------------------------------------------------------------------
-- ADDRESS LINE
-- You can modify the memory instantiated by trgtet transactor by changing 
-- the "address_lines" value
-- You also need to change the mem_hit_range value to correspond to 
-- the value specified by "address_lines"
-- for example if address_lines is defined as 1024, the trgtet transactor
-- is instantiating memory of size 1k.
-- that corresponds to memory hit range of 000-3FF in hex..
-----------------------------------------------------------------------------        
       
----------------------------------------------------------------------------               
        
        --      type declaration
        type bit_array is array (0 to address_lines -1 ) of std_logic_vector(32 downto 1);


        signal pci_mem              : bit_array;     --This is a memory array used by the trgtet transactor 
        signal we_32                : std_logic;
        signal addr                 : integer := 0;  -- signal used to address memory
        signal mem_hit              : std_logic;     -- indicates this is memory BAR hit
        signal io_hit               : std_logic;     -- indicates this is IO BAR hit     
        signal par_en               : std_logic;     -- enable the lower dword parity output   
        signal trdyn_watch          : std_logic;
        signal address              : std_logic_vector(31 downto 0) := X"00000000";
        
        constant tdel               : time := 0 ns;  -- do not change this value
        
        --       registers
        signal io_reg_32            : std_logic_vector(31 downto 0):= X"00000000";  --io register
        signal trgt_tranx_bar0      : std_logic_vector(31 downto 0):= X"00000008";  -- BAR0 register of trgtet transactor
        signal trgt_tranx_bar1      : std_logic_vector(31 downto 0):= X"00000001";  -- BAR1 register of trgtet transactor
     
        signal addr_boundary        : integer := 0;  --Used to determine the which bits of the address to use for memory read / writes
	 
	signal cben_reg		    : std_logic_vector(3 downto 0):= X"0";
	signal cacheln_end	    : integer := 0;
	signal memory_end	    : integer := 0;
begin
                        
        --*********************************************************
        -- parity generation for lower dword
        parity_gen:
        --*********************************************************     
        process (clk,ad,cben)
                variable result_reg : std_logic;
        
        begin
                if clk'event and clk = '1' then
                        result_reg :=   ad(31) xor ad(30) xor ad(29) xor ad(28)
                        xor ad(27) xor ad(26) xor ad(25) xor ad(24)
                        xor ad(23) xor ad(22) xor ad(21) xor ad(20)
                        xor ad(19) xor ad(18) xor ad(17) xor ad(16)
                        xor ad(15) xor ad(14) xor ad(13) xor ad(12)
                        xor ad(11) xor ad(10) xor ad(9)  xor ad(8)
                        xor ad(7)  xor ad(6)  xor ad(5)  xor ad(4)
                        xor ad(3)  xor ad(2)  xor ad(1)  xor ad(0)
                        xor cben(3) xor cben(2) xor cben(1) xor cben(0);
                 
                        if par_en = '1' then
                                par <= result_reg;
                        else
                                par <= 'Z';
                        end if;
                end if;
        end process;




--******************************************************************************************
-- FILE IO
--*****************************************************************************************



        --This process initializes the memory by reading in the data file
        --and also performs all memory writes.
        --*****************************************
        memory_initialization_and_writes : 
        --*****************************************
        process (rstn,we_32,irdyn,clk,addr)

                variable temp_bit_array : bit_array;
                variable tmpbit : std_logic_vector(4 downto 1);
                file f : text;
                variable l : line;


        begin
                -- asynchronous reset will initialize the memory
                if (rstn'event and rstn = '1') then 
            
                        --Initialize the temp_bit_array with zeros
                        for i in 0 to address_lines-1 loop
                                temp_bit_array(i) := X"00000000";
                        end loop;

                        
                        file_open(f, "trgt_tranx_mem_init.dat",read_mode);
                        --Read in each line from the data file
                        for j in 0 to address_lines -1 loop   
                                --If it is not the end of the file then read line
                                if (not endfile(f)) then
                                        readline(f,l);
                                        hread(l,temp_bit_array(j));
                                end if;
                        end loop;
                        --Copy the data and store it into memory
                        for k in 0 to address_lines-1 loop
                                pci_mem(k) <= temp_bit_array(k);
                        end loop;
                        file_close(f);
		
		--32 bit write into the memory
		elsif (we_32 = '1' and clk'event and clk='1' and irdyn = '0' and cacheln_end = 0 and memory_end = 0) then 
                        --Grab current data in mem
                        pci_mem(addr) <= ad;
                end if;
        end process;


        --This process determines if there is a memory hit
        --********************************************
        check_memory_hit:
        --********************************************
        process(ad,cben,trgt_tranx_bar0)
        begin
                
                if((trgt_tranx_bar0 <= ad(31 downto 0)) and 
                    (ad(31 downto 0) < trgt_tranx_bar0 + mem_hit_range) and
                    (cben(3 downto 0) = "0110" or cben(3 downto 0) = "0111" or cben(3 downto 0) = "1110" or
                    cben(3 downto 0) = "1111" or cben(3 downto 0) = "1100" ) ) then
                        mem_hit <= '1';
                        else
                        mem_hit <= '0';
                end if;
        end process;

     
      
      
        --io register address space is defined and checked here
        --********************************************
        check_io_hit:
        --********************************************
        process(ad,cben,trgt_tranx_bar1)
        begin
                if(((trgt_tranx_bar1(31 downto 0)- x"01") <= ad(31 downto 0)) and 
                   ((ad(31 downto 0) < trgt_tranx_bar1 + io_hit_range)) and
                   (cben(3 downto 0) = "0010" or cben(3 downto 0) = "0011")) then
                        io_hit <= '1';
                else
                        io_hit <= '0';
                end if;
        end process;


        --This process will determine which bit slice of the address is used to for memory reads / writes
        --********************************************
        addr_determ:
        --********************************************
        process (rstn)
        variable temp, counter : integer;

        begin
                if (rstn = '0') then
                        temp := address_lines;
                        counter := 0;
                end if;
                --i.e. if there were 8 address lines in memory
                -- since 8 != 1,  addr_boundary = 1
                -- since 4 != 1,  addr_boundary = 2
                -- since 2 != 1,  addr_boundary = 3
                -- since 1 == 1,  exit loop
                --
                -- Therefore it will take 3 bits to represent the address space
                -- In this applications the bit slice that will be used will then be AD (5 downto 3)
                if (rstn'event and rstn = '1') then
                        while (temp /= 1) loop
                                temp := temp / 2;
                                counter := counter + 1;
                        end loop;
                end if;
                addr_boundary <= counter;
        
        end process;


       --This process will increment the address when necessary and assert the following control signals
        --********************************************
        addr_increment:
        --********************************************
        process (ad, framen,clk,mem_hit,trgt_tranx_retry,trdyn_watch,irdyn)
        
                variable capture_addr_reg     : std_logic_vector(31 downto 0); -- Captures the address at the beginning of a transaction
		
        begin
                --Capture the address at the begining of an address
               
                 if (framen = '0' and  irdyn /= '0' and clk'event and clk = '1' and mem_hit = '1') then
			cacheln_end <= 0; 
			capture_addr_reg := ad(31 downto 0);
                        addr <= conv_integer ( ad ( (1 + addr_boundary) downto 2) );
                elsif (clk'event and clk = '1') then
			--changing address
                        --Increment address to next dword
		        capture_addr_reg := capture_addr_reg + 4;
			if (capture_addr_reg > ((trgt_tranx_bar0 - 8) + mem_hit_range)) then
				memory_end <= 1;
			elsif (cben_reg = "1110" and (addr mod 8) = 7) then
				addr <= conv_integer ( capture_addr_reg ( (1+addr_boundary) downto 2) );
				cacheln_end <= 1;
			else
			   memory_end <= 0;		
			   --If it is a burst read or write then framen should still be asserted
                           if (framen = '0'  and  trgt_tranx_retry = '0') then
                                   if (trdyn_watch = '0' and irdyn = '0' ) then
                                      addr <= conv_integer ( capture_addr_reg ( (1+addr_boundary) downto 2) );
                                   end if;           
                           elsif (irdyn = '0') then
                                   if trdyn_watch = '0' then
                                          addr <= conv_integer ( ad ( (1+addr_boundary) downto 2) );
                                   end if;
		           end if;
                        end if;         
                end if;
        end process;




        --Here is where the trgtet transactor determines what kind of pci transaction 
        --is being attempted
        --********************************************
        main: process
        --********************************************



--*******************************************************************
--PROCEDURES
--********************************************************************

        
        --**************************
        --  memory write
        procedure mem_wr is
        --**************************
        begin
               --Initiate memory write
                wait until clk'event and clk='1';
                wait for tdel;
                devseln <= '0';
                perrn  <= '1';
                serrn <= '1';
                stopn   <= '1';
                trdyn   <= '1';
                trdyn_watch <= '1';
        
                we_32 <= '1';
               
                ---------------------------------------------------------
                wait until clk'event and clk = '1';
                wait for tdel;  
                --If the trgtet transactor is suppose to retry
                if (trgt_tranx_retry = '1') then
                        trdyn <= '1';
                        stopn <= '0';
                else
                        trdyn <= '0';
                        trdyn_watch <= '0';
                end if;  
       
                --Wait for the initiator to be ready
                if (irdyn = '1') then
                        wait until irdyn = '0';
                end if;

                --If the trgtet transactor is to be disconnected with type-A
                if (trgt_tranx_disca = '1') then
                    stopn <= '0';
                end if;

                wait until clk'event and clk ='1';
                wait for tdel;
                
                --If the trgtet transactor is to be disconnected with type-B
                if (trgt_tranx_discb = '1') then
                        stopn<= '0';
                        trdyn<= '1';
                        trdyn_watch <= '1';
                end if;

                ------------------------------------------------------------------              
                while (framen = '0'  and trgt_tranx_retry = '0' and 
                       trgt_tranx_disca = '0' and trgt_tranx_discb = '0' ) loop
                        wait until clk'event and clk = '1';
                end loop;

               --------------------------------------------------------------------------------

                if irdyn = '0' then
                        wait until irdyn = '1';
                end if;

                --write transaction completed

                --transaction end
                ad <= (others=>'Z');
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                trdyn_watch <= '1';
       
                we_32 <= '0';
                
                par_en <= '0';

        end mem_wr;



        --**********************
        --  memory read
        procedure mem_rd is
        --**********************

                variable vector_32 : std_logic_vector(32 downto 1);

        begin
                wait until clk'event and clk = '1';
                wait for tdel;

                -- initiate memory read
                trdyn_watch <= '1';
                devseln <= '0'; 
                stopn <= '1';
                ad(31 downto 0) <= X"00000000";
                par_en <= '1';
       	
     
                -------------------------------------------
        
                wait until clk'event and clk = '1';
                wait for tdel; 
                
                --If the trgtet transactor is suppose to retry
                if (trgt_tranx_retry = '1') then
                        trdyn <= '1';
                        stopn <= '0';
                else
                        trdyn <= '0';
                        trdyn_watch <= '0';   
                end if;
                      
                --If the trgtet transactor is to be disconnected with type-A
                if (trgt_tranx_disca = '1') then
                        stopn <= '0' after tdel;
                end if;
                
                
                if (irdyn = '1') then
                        wait until irdyn = '0';
                end if;     
                      
             
                vector_32 := pci_mem(addr);
                ad(31 downto 0) <= vector_32(32 downto 1);
         
                
                ------------------------------------------------------------------------
                wait until clk'event and clk = '1';
                wait for tdel;

                --If the trgtet transactor is to be disconnected with type-B   
                if (trgt_tranx_discb = '1') then
                        trdyn <= '1';
                        trdyn_watch <= '1';
                        stopn <= '0';
                end if;
                wait for tdel;
                
                while (framen = '0'  and  trgt_tranx_retry = '0' and cacheln_end = 0 and memory_end = 0) loop
                        vector_32 := pci_mem(addr);
                        ad(31 downto 0) <= vector_32(32 downto 1);
                        
                        wait until clk'event and clk = '1';
                        wait for 1 ns;
                end loop;

	        --last data tranfer
                if (irdyn = '0' and cacheln_end = 0 and memory_end = 0) then 
                        if (trdyn_watch = '0') then
        
                                vector_32 := pci_mem(addr);
                                ad(31 downto 0) <= vector_32(32 downto 1);
                        end if;
                        wait until irdyn'event and irdyn = '1';
                end if; 
	
                --If reach cache line boundary
	        if(cacheln_end = 1 or memory_end = 1) then
	 	   trdyn <= '1';
		   trdyn_watch <= '1';
		   stopn <= '0';
		   while (framen = '0') loop
			 wait until clk'event and clk = '1';
		   end loop;
	  	end if;

                --transaction end
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                trdyn_watch <= '1';
                ad <= (others=>'Z');
                we_32 <= '0';
                par_en <= '0';
	

        end mem_rd;

        --******************
         --  io write
        procedure io_wr is
        --******************
        begin
                -- initiate io write
                devseln <= '0';
                stopn   <= '1';
                trdyn   <= '1';
                trdyn_watch <= '1';
        
                wait until clk'event and clk = '1';
                wait for tdel;
                
                
                trdyn <= '0';
                trdyn_watch <= '0';
                
                if irdyn = '1' then
                        wait until irdyn = '0';
                end if;

                --regardless of address
                wait until clk'event and clk = '1'; 
                if(irdyn = '0' and trdyn_watch = '0') then 
                        io_reg_32 <= ad(31 downto 0);
                end if;
        

                --write transaction complete

                --transaction end
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                trdyn_watch <= '1';
                ad <= (others=>'Z');
                we_32 <= '0';
                par_en <= '0';

        end io_wr;


      
        --*****************
        --  io read
        procedure io_rd is
        --*****************
        begin

                wait until clk'event and clk = '1';
                wait for tdel;        
                
                devseln <= '0';
                stopn <= '1';
                trdyn <= '1';
                par_en <= '1';
                ad(31 downto 0) <= X"00000000";        
                wait until clk'event and clk = '1';
                trdyn <= '0';   --trgtet ready for transaction
                ad(31 downto 0) <= io_reg_32;

                if irdyn = '1' then
                        wait until irdyn = '0';
                end if;
                
                wait until clk'event and clk = '1';
                --write transaction complete

                --transaction end
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                ad <= (others=>'Z');
                we_32 <= '0';
                par_en <= '0';
                
        end io_rd;



        --*********************
        --  configuration write
        procedure cfg_wr is
        --*********************
        
        begin
        
                --io write initiate
                devseln <= '0';
                stopn   <= '1';
                trdyn   <= '1';
                trdyn_watch <= '1';
        
                wait until clk'event and clk = '1';
                wait for tdel;
                
                trdyn <= '0';
                trdyn_watch <= '0';
                
                if irdyn = '1' then
                        wait until irdyn = '0';
                end if;
                
                --regardless of address
        
                wait until clk'event and clk = '1'; 
                if(irdyn = '0' and trdyn_watch = '0' and address(7 downto 0) = X"10") then 
                        trgt_tranx_bar0 <= ad(31 downto 0);
                elsif (irdyn = '0' and trdyn_watch = '0' and address(7 downto 0) = X"14") then 
                        trgt_tranx_bar1(31 downto 1) <= ad(31 downto 1);
                        
                end if;
        
                --transaction end
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                trdyn_watch <= '1';
                ad <= (others=>'Z');
                we_32 <= '0';
                par_en <= '0';
        
        end cfg_wr;


        --*********************
        --  configuration read
        procedure cfg_rd is
        --********************
        begin
        
                wait until clk'event and clk = '1';
                wait for tdel;

                devseln <= '0';
                stopn <= '1';
                trdyn <= '1';
                par_en <= '1';
                ad(31 downto 0) <= X"00000000";
        
                wait until clk'event and clk = '1';
                wait for tdel;
                
                trdyn <= '0';   --trgtet ready for transaction
                if (address(7 downto 0) = X"10") then
                        ad(31 downto 0) <= trgt_tranx_bar0;
                elsif (address(7 downto 0) = X"14") then
                        ad(31 downto 0) <= trgt_tranx_bar1;
                end if;
 

                if irdyn = '1' then
                        wait until irdyn = '0';
                end if;
        
                wait until clk'event and clk = '1';
                wait for tdel;
        
                --transaction end
                devseln <= '1';
                stopn <= '1';
                trdyn <= '1';
                ad <= (others=>'Z');
                we_32 <= '0';
                par_en <= '0';
                
        end cfg_rd;

----------------------------------------------------------------------------------


        begin

                --Initialization
                ad   <= (others=>'Z');
                par  <= 'Z';
                trdyn <= 'Z';
                devseln <= 'Z';
                stopn <= 'Z';
                perrn <= 'Z';
                serrn <= 'Z';
                we_32 <= '0';
                par_en <= '0';
                trdyn_watch <= '1';
                
        
            -- write transaction
            if (framen = '0' and (cben (3 downto 0) = "0111" or cben (3 downto 0) = "1111") and mem_hit = '1') then
                    wait for tdel;
                    mem_wr;
    
            -- read   transaction
            elsif (framen = '0' and (cben(3 downto 0) = "0110" or cben(3 downto 0) = "1110" or
                                     cben(3 downto 0) = "1100" ) and mem_hit = '1')then
                    wait for tdel;
		    cben_reg <= cben(3 downto 0);
                    mem_rd;
		    cben_reg <= "0000";
    
            -- io write  transaction
            elsif (framen = '0' and cben(3 downto 0) = "0011" and io_hit = '1') then
                    wait for tdel;       
                    io_wr;
    
            -- io read   transaction
            elsif (framen = '0' and cben(3 downto 0) = "0010" and io_hit = '1') then
                    wait for tdel;
                    io_rd;
    
            -- configuration write transaction
            elsif (framen = '0' and cben(3 downto 0) = "1011" and idsel = '1' and 
                  (ad(7 downto 0) = x"10" or ad(7 downto 0) = x"14")) then
                    address <= ad(31 downto 0);
                    wait for tdel;
                    cfg_wr;
      
            -- configuration read transaction
            elsif (framen = '0' and cben(3 downto 0) = "1010" and idsel = '1' and
                   (ad(7 downto 0) = x"10" or ad(7 downto 0) = x"14")) then
                    address <= ad(31 downto 0);
                    wait for tdel;
                    cfg_rd;
     
            end if;
    
                wait until clk'event and clk='1';
        end process;


end behavior;










