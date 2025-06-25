--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: monitor

--  FUNCTIONAL DESCRIPTION:
--  This file monitors the signals on the PCI bus and prints appropriate messages to the screen
--  It also logs the transactions in log.txt file.
--  You can modify the bus monitor to include additional PCI protocol checks 
--  as needed by your application.

--  REVISION HISTORY:  
--  Revision 1.1 Description: No change.
--  Revision 1.0 Description: Initial Release.
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
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.log.all;


entity monitor is 
      port(
            --system
            clk             : in std_logic;                                 
            rstn            : in std_logic;                                
            
            --address/data
            ad              : in std_logic_vector(63 downto 0);           
            cben            : in std_logic_vector(7 downto 0);          
            
            --PCI Control Signals
            req64n          : in std_logic;                           
            framen          : in std_logic;                           
            irdyn           : in std_logic;                            
            ack64n          : in std_logic;                           
            devseln         : in std_logic;                          
            trdyn           : in std_logic;                            
            stopn           : in std_logic;
            
            busfree         : out std_logic;  --This signal indicates that the bus is free
            disengage_mstr  : out std_logic;  --This signal indicates that there was abnormal termination by the target
            tranx_success   : out std_logic); --This signal indicates that the transaction was successful.                           
   
end monitor;


architecture behavior of monitor is

      
      signal tranx_active   : std_logic;                     -- Indicates that the transaction is active
      signal busfree_ind    : std_logic;                     -- Indicates that the bus is free
      signal devsel_cnt     : integer := 0;                  -- Keeps check of how many clocks devsel was high when tranx is active.
      signal trdyn_cnt      : integer := 0;                  -- Keeps check of how many clocks trdyn was high when tranx is active. 
      signal trdyn_asserted : std_logic;                     -- This signal is used to decide the type of target termination.
      signal addr           : std_logic_vector(31 downto 0); -- Latches the address at the begining of the transaction
      signal cben_reg       : std_logic_vector(3 downto 0);  -- Latches the command at the begining of the transaction
      signal tranx64        : std_logic;                     -- Indicates that it is a 64 bit transaction.
      
      constant header       :string := "    Time       Address         Data";  

begin


         --Busfree Indicator
         --*********************************************************
         process (framen, irdyn, devseln, trdyn, stopn)
         --*********************************************************
          begin
              if ( framen = 'H' and irdyn = 'H' and trdyn = 'H' and 
                   devseln = 'H' and stopn = 'H') then
                busfree_ind <= '1';
              else
                busfree_ind <= '0';
              end if;
          
         end process;
         
         busfree <= busfree_ind;
         
         
         --Transaction Active Signal
         --*********************************************************
         process (clk,framen,busfree_ind,rstn)
         --*********************************************************
          begin
              if (rstn = '0') or busfree_ind = '1'  then
                   tranx_active <= '0';
              elsif (clk'event and clk = '1') then
                  if (framen = '0') then 
                   tranx_active <= '1';
                  end if;
              end if; 
         end process;
         
         
         --Indicate 64 bit Transaction.
         --*********************************************************
         process (clk,framen,req64n,busfree_ind )
         --*********************************************************
          begin
           if (rstn = '0') or busfree_ind = '1'  then
                 tranx64 <= '0';
              elsif( clk'event and clk = '1') then
                if(framen = '0' and req64n = '0') then 
                   tranx64 <= '1';
                end if;   
            end if;
           
         end process;
         
         --This process stores the assertion of trdyn, this signal is
         --used to determine the type of target termination
         --*********************************************************
         process (clk,rstn,busfree_ind,trdyn )
         --*********************************************************
          begin
           if (rstn = '0') or busfree_ind = '1'  then
                 trdyn_asserted <= '0'; 
            elsif( clk'event and clk = '1') then
                if(trdyn = '0')  then 
                   trdyn_asserted <= '1';
                end if;   
            end if;
           
         end process;
         
         --Count for devseln and trdyn. 
         --**********************************************************                                          
         count:process (rstn,clk,devseln, trdyn, stopn,tranx_active)
         --**********************************************************
         begin
             if (rstn = '0' or busfree_ind = '1') then
                  devsel_cnt <= 0;
                  trdyn_cnt <= 0;  
            elsif (clk'event and clk = '1' and tranx_active = '1') then 
               if  (( devseln ='1' or  devseln ='H') and devsel_cnt<5) then
                  devsel_cnt <= devsel_cnt + 1;
               end if;
               
               if (trdyn='0') then
                  trdyn_cnt <= 7;            
               elsif (trdyn='1' or  trdyn='H')  and 
                    (stopn='1' or  stopn='H')  and 
                    (trdyn_cnt<16 and devsel_cnt<5) then
                   trdyn_cnt <= trdyn_cnt + 1;
               end if;
           end if; 
         end process;
         
         --Latch the start address of the transaction and increment 
         --the address if there is a successful data transfer
         --*********************************************************
         process (clk,framen,rstn,busfree_ind,ad,addr,irdyn,trdyn)
         --*********************************************************
         --variable address_inc : std_logic_vector(63 downto 0);
          begin
           if (rstn = '0') or busfree_ind = '1'  then
                 addr <= (others => '0');
                 cben_reg <= (others => '0');
                 
           elsif( clk'event and clk = '1') then
                 if(busfree_ind = '0' and tranx_active = '0' and framen = '0') then 
                      addr <= ad(31 downto 0);
                      cben_reg <= cben(3 downto 0);
                  elsif (irdyn = '0' and trdyn = '0') then
                       if (tranx64 = '1') then
                         addr <= addr + x"00000008";     
                       else
                         addr <= addr + x"00000004";
                       end if;     
                  end if;  
            end if;   
           
         end process;

         --This process monitors the PCI signals and sends out appropriate 
         -- messages to the screen and log.txt, It also sends out 
         -- tranx_successful and disengage_mstr status to the mstr_transx.
         --*********************************************************
         process (clk,framen,rstn,busfree_ind,ad,addr,irdyn,trdyn,
                  stopn,devseln,trdyn_asserted,devsel_cnt,trdyn_cnt,tranx_active )
         --*********************************************************
         variable address_inc : std_logic_vector(63 downto 0);
        
         begin
             if (rstn = '0') or busfree_ind = '1'  then
                   tranx_success <=  '0';
                   disengage_mstr <= '0';
             
              elsif (tranx_active = '1' and devsel_cnt<5) then
                  if (trdyn_cnt < 16) then
               
                     -----------------------------------------------------------------------------------
                     if (trdyn = '1' and  stopn = '0' and  devseln = '0' and trdyn_asserted = '0') then                                       
                     -----------------------------------------------------------------------------------    
                         disengage_mstr <= '1';
                          if (irdyn'event and irdyn = '1') then         
                             print_sig_val("Target terminated with a retry");
                          end if;
          
                     ------------------------------------------------------------
                     elsif (trdyn = '0' and  stopn = '0' and devseln = '0') then                                       
                     ------------------------------------------------------------
                          disengage_mstr <= '1';
                           
                           if(irdyn = '0' and trdyn = '0') then
                              if (clk = '1' and clk'event) then
                                 if (tranx64 = '1') then
                                    print_sig_val(addr,ad(63 downto 0));
                                 else
                                    print_sig_val(addr,ad(31 downto 0));
                                 end if;  
                               end if;
                            end if;
                           
                          if (irdyn'event and irdyn = '1') then         
                              print_sig_val("Target terminated with disconnect-a ");
                           end if;
                           
     
                     -----------------------------------------------------------------------------------
                     elsif(trdyn = '1' and  stopn = '0' and devseln = '0' and trdyn_asserted = '1') then
                     ------------------------------------------------------------------------------------
                     
                          disengage_mstr <= '1';
                          
                          if(irdyn = '0' and trdyn = '0') then
                              if (clk = '1' and clk'event) then
                                 if (tranx64 = '1') then
                                    print_sig_val(addr,ad(63 downto 0));
                                 else
                                    print_sig_val(addr,ad(31 downto 0));
                                 end if;  
                               end if;
                            end if;
                           
                           if (irdyn'event and irdyn = '1') then         
                              print_sig_val("Target terminated with disconnect-b ");
                           end if;
                          
               
                     ----------------------------------------------------------
                     elsif(trdyn = '1' and  stopn = '0' and devseln = '1') then
                     ----------------------------------------------------------
                        
                        disengage_mstr <= '1';
                           
                           if(irdyn = '0' and trdyn = '0') then
                              if (clk = '1' and clk'event) then
                                 if (tranx64 = '1') then
                                    print_sig_val(addr,ad(63 downto 0));
                                 else
                                    print_sig_val(addr,ad(31 downto 0));
                                 end if;  
                               end if;
                            end if;
                           
                           if (irdyn'event and irdyn = '1') then         
                               print_sig_val("Target abort detected");
                           end if;
                     
                     
                     ----------------------------------------------------------
                     elsif (irdyn = '0' and trdyn = '0' and devseln = '0') then
                     ----------------------------------------------------------
                     
                         tranx_success <= '1';
                          
                          if (clk = '1' and clk'event) then
                             if (tranx64 = '1') then
                                print_sig_val(addr,ad(63 downto 0));
                             else
                                print_sig_val(addr,ad(31 downto 0));
                              end if;  
                          end if;
                     --------------------------------------
                     elsif(irdyn = '1' or trdyn = '1') then
                     --------------------------------------    
                         tranx_success <= '0';
                     end if;        
     
                 ---------------------------
                 elsif (trdyn_cnt = 16) then
                 --------------------------- 
                      disengage_mstr <= '1';        
                       if (irdyn'event and irdyn = '1') then         
                         print_sig_val("Target is not responding");            
                       end if;
             end if;
                        
            ---------------------------
            elsif (devsel_cnt = 5) then
            ---------------------------            
               disengage_mstr <= '1';        
                if (irdyn'event and irdyn = '1') then         
                  print_sig_val("Master abort");            
                end if;
     end if;
  
end process;

--This process monitors the command and prints out appropriate 
--Messages to the screen and log.txt file.
--*********************************************************
process (trdyn_cnt,clk,cben_reg,framen)
--*********************************************************

 begin
  if (trdyn_cnt = 0 and clk'event and clk = '1') then
    
              if(cben_reg = "1011") then
                print(" ");
                print("     performing configuration write");
                print("     ************************************");
                print(header);                                                                                    
              
              elsif(cben_reg = "1010") then
               print(" ");
               print("     performing configuration read");
               print("     ************************************");
               print(header);                                                                                    
           elsif(cben_reg = "0111" or cben_reg = "1111") then    
              if(framen = '0' and tranx64 = '1') then
                print(" ");
                print("    performing 64 bit burst memory write");
                print("    ********************************************");                                                                                    
                print(header);                                                                                    
               elsif(framen = '1' and tranx64 = '1') then
                print(" ");
                print("    performing 64 bit single cycle memory write");
                print("    ***************************************************");                                                                                    
                print(header);                           
              elsif(framen = '0' and tranx64 = '0') then
                print(" ");
                print("    performing 32 bit burst memory write");
                print("    ********************************************");                                                                                    
                print(header);                                                                                    
               elsif(framen = '1' and tranx64 = '0') then
                print(" ");
                print("    performing 32 bit single cycle memory write");
                print("    ***************************************************");                                                                                    
                print(header);                           
              end if;
             
           elsif(cben_reg = "0110" or cben_reg = "1100" or cben_reg = "1110") then        
              if(framen = '0' and tranx64 = '1') then
                print(" ");
                print("    performing 64 bit burst memory read");
                print("    ********************************************");                                                                                    
                print(header);                                                                                    
               elsif(framen = '1' and tranx64 = '1') then
                print(" ");
                print("    performing 64 bit single cycle memory read");
                print("    ***************************************************");                                                                                    
                print(header);                           
              elsif(framen = '0' and tranx64 = '0') then
                print(" ");
                print("    performing 32 bit burst memory read");
                print("    ********************************************");                                                                                    
                print(header);                                                                                    
               elsif(framen = '1' and tranx64 = '0') then
                print(" ");
                print("    performing 32 bit single cycle memory read");
                print("    ***************************************************");                                                                                    
                print(header);                           
              end if;
        
             elsif(cben_reg = "0011") then
                print(" ");
                print("     performing io write");
                print("     *************************");
                print(header);                                                                                    
              
              elsif(cben_reg = "0010") then
               print(" ");
               print("     performing io read");
               print("     **************************");
               print(header);       
              
              end if;
     
   end if;   
  
end process;



end behavior;
