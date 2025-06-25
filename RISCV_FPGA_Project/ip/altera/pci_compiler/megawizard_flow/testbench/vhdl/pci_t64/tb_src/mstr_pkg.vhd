--------------------------------------------------------------------
--  Altera PCI testbench
--  Package NAME: mstr_pkg
--  COMPANY:  Altera Coporation.
--            www.altera.com    

--  FUNCTIONAL DESCRIPTION:
--  This package has all the procedures that is used by the master 
--  to initiate PCI transaction on the PCI bus.
--  You can modify these  procedures to introduce different variations 
--  in the PCI transaction as desired by your application. 

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
use ieee.std_logic_1164.all; 
use ieee.std_logic_signed.all;

package mstr_pkg is
       
       --Record of PCI  signals.                                          
         type pcisig_rec is record
           ad           : std_logic_vector (63 downto 0);
           cben         : std_logic_vector (7 downto 0);
          
           req64n       : std_logic;
           framen       : std_logic;
           irdyn        : std_logic;
           ack64n       : std_logic;
           devseln      : std_logic;
           trdyn        : std_logic;
           stopn        : std_logic;
           
         end record;  
       
       --Record of Master transactor signals
       type mstr_intsig is record
           mstr_tranx_reqn  : std_logic;
           par_en       : std_logic;
           par_en_64    : std_logic;
       end record;  
       
       --Record of Monitor signals
       type mon_sig is record
           mstr_tranx_gntn  : std_logic; 
           busfree         : std_logic;
           disengage_mstr  : std_logic;
           tranx_success  : std_logic; 
       end record;  
       
       signal pciclk       : std_logic;
       constant tdel       : time := 0 ns; -- Do not change this value.  
       
       
       procedure idle_cycle(count :in  integer);
        
       procedure cfg_wr(signal pci     : inout pcisig_rec;
                              signal mstr    : inout mstr_intsig;
                              signal mon     : in mon_sig;
                                     address :std_logic_vector(31 downto 0);
                                     data    :std_logic_vector(31 downto 0);
                                     byte_en :std_logic_vector(3 downto 0));
       
       procedure cfg_rd(signal pci     : inout pcisig_rec;
                             signal mstr    : inout mstr_intsig;
                             signal mon     : in mon_sig;
                                    address :std_logic_vector(31 downto 0));
                                    
       procedure mem_wr_64(signal pci      : inout pcisig_rec;
                           signal mstr     : inout mstr_intsig;
                           signal mon      : in mon_sig;
                                  address  :std_logic_vector(31 downto 0);                                           
                                  data     :std_logic_vector(63 downto 0);                       
                           constant qword  :integer := 1);
       
       procedure mem_rd_64(signal  pci     : inout pcisig_rec;
                           signal  mstr    : inout mstr_intsig;
                           signal  mon     : in mon_sig;
                                   address :std_logic_vector(31 downto 0);                    
                          constant qword   :integer := 1);
       
       procedure mem_wr_dac( signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(63 downto 0);                                                  
                                   data     :std_logic_vector(31 downto 0);                                                  
                            constant dword  :integer := 1);
       
       procedure mem_rd_dac( signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(63 downto 0);                                       
                            constant dword  :integer := 1);			  
       
       procedure mem_wr_32( signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(31 downto 0);                                                  
                                   data     :std_logic_vector(31 downto 0);                                                  
                            constant dword  :integer := 1);
       
       procedure mem_rd_32( signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(31 downto 0);                                       
                            constant dword  :integer := 1);
                            
        procedure io_wr(signal pci     : inout pcisig_rec;
                       signal mstr    : inout mstr_intsig;
                       signal mon     : in mon_sig;
                              address :std_logic_vector(31 downto 0);                                 
                              data    :std_logic_vector(31 downto 0));                    
       
       procedure io_rd(signal pci     : inout pcisig_rec;
                       signal mstr    : inout mstr_intsig;
                       signal mon     : in mon_sig;
                              address :std_logic_vector(31 downto 0));
       
       
       PROCEDURE drive_z(signal pci  : inout pcisig_rec);
       
  
 end mstr_pkg;
  
       
 
 
 package body  mstr_pkg  is
       
       
       --*********************************************************
       -- Task for Waiting
       procedure idle_cycle(count :in  integer) is
       --*********************************************************
       variable idle_cycle_count : integer := count;
        begin
          while( idle_cycle_count > 0) loop
             wait until pciclk'event and pciclk='1';
             idle_cycle_count := idle_cycle_count - 1;
          end loop;
       end idle_cycle;
       
       
       
       --************************************************************************
       -- Configurtion Write
       procedure cfg_wr(signal pci     : inout pcisig_rec;
                              signal mstr    : inout mstr_intsig;
                              signal mon     : in mon_sig;
                                     address :std_logic_vector(31 downto 0);
                                     data    :std_logic_vector(31 downto 0);
                                     byte_en :std_logic_vector(3 downto 0)) is
       --**************************************************************************
       
       begin 
          
            --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
            while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
            end loop;
          
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           --Address phase
             pci.framen <= '0';
             pci.ad(63 downto 0) <=  (others => 'Z');
             pci.cben(7 downto 4) <= (others => 'Z');
             pci.ad(31 downto 0) <= address;
             pci.irdyn <= '1';
             pci.cben(3 downto 0) <= "1011";  
             mstr.par_en <= '1';
           
           --Data phase
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
             pci.framen <= '1';
             pci.irdyn <= '0';
             pci.cben(7 downto 4) <= (others => '0');
             pci.cben(3 downto 0) <= byte_en;
             pci.ad(31 downto 0) <= data;
           
             mstr.mstr_tranx_reqn <= '1';
           
           --Check for the Data Transfer
             while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
             
             pci.irdyn <= '1';
             pci.ad <= (others => 'Z'); 
             pci.cben <= (others => 'Z'); 
             mstr.par_en <= '0';
           
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
            drive_z(pci);
       
       end cfg_wr;
       
       --***********************************************************************
       --Configuration Read
       procedure cfg_rd(signal pci     : inout pcisig_rec;
                             signal mstr    : inout mstr_intsig;
                             signal mon     : in mon_sig;
                                    address :std_logic_vector(31 downto 0)) is  
       --***********************************************************************
       begin                                      
          
           --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
            while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
            end loop;
          
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
          
           --Address phase
              pci.framen <= '0';
              pci.irdyn <= '1';
              pci.ad(63 downto 32) <=  (others => 'Z');
              pci.cben(7 downto 4) <= (others => 'Z');
              pci.ad(31 downto 0) <= address;
              pci.cben(3 downto 0)<= "1010"; 
              mstr.par_en <= '1';
           
           --Turn around phase    
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
              mstr.par_en <= '0';
              pci.framen <= '1';
              pci.irdyn  <= '0';
              pci.cben   <= (others => '0');
              pci.ad(31 downto 0)  <= (others => 'Z');
            
            mstr.mstr_tranx_reqn <= '1';
            
            --Data Phase
            while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
            end loop;
              
              pci.irdyn <= '1';
              pci.cben <= (others => 'Z');
           
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
              drive_z(pci);
            
       end cfg_rd;
       
       
       
       --*************************************************************                                          
       --64 bit Memory Write
       procedure mem_wr_64(signal pci      : inout pcisig_rec;
                           signal mstr     : inout mstr_intsig;
                           signal mon      : in mon_sig;
                                  address  :std_logic_vector(31 downto 0);                                           
                                  data     :std_logic_vector(63 downto 0);                       
                           constant qword  :integer := 1) is                            
       --*************************************************************                      
                                                                                        
         variable data_inc_low  :  std_logic_vector(31 downto 0) := data(31 downto 0);
         variable data_inc_high :  std_logic_vector(31 downto 0) := data(63 downto 32);                            
         variable qword_cnt     :  integer := qword;                                        
          
                                                                                        
          begin                                                                         
           
           --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
            while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
            end loop;
          
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           
           --Address Phase
            pci.framen <= '0';
            pci.req64n <= '0';
            pci.irdyn <= '1';                                                            
            pci.ad(63 downto 32) <= (others => '0');                                        
            pci.cben(7 downto 4) <= "0000";                                               
            pci.ad(31 downto 0) <= address;                                                 
            pci.cben(3 downto 0) <= "0111";                                                 
            mstr.par_en <= '1';                                                              
            mstr.par_en_64 <= '1';
                                                                                        
           --Data Phase
           wait until pciclk'event and pciclk = '1';                                          
           wait for tdel;                                                               
            qword_cnt := qword_cnt - 1;                                                 
           
           --If it is not a Burst transaction deassert framen
            if (qword > 1) then                                                         
              pci.framen <= '0';                                                          
            else                                                                      
              pci.framen <= '1';
              pci.req64n <= '1';                                                                                                                  
            end if;                                                                     
           
            pci.ad(63 downto 0) <= data;                                                    
            pci.cben(7 downto 0) <= (others => '0');                                                 
            pci.irdyn <= '0';                                                             
            mstr.mstr_tranx_reqn <= '1';
          
          while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
           wait until pciclk'event and pciclk = '1';
          end loop;
        
       --------------Burst Transaction------------------------                    
         if (qword > 1 and mon.disengage_mstr = '0')then 
         
          while(qword_cnt > 0 and mon.disengage_mstr = '0') loop                                                     
            
              if qword_cnt = 1 then                                                  
                  pci.framen <= '1';                                                        
                  pci.req64n <= '1';                                                         
              end if;                                                                
              
              
              if(pci.irdyn = '0' and pci.trdyn = '0') then
                   qword_cnt := qword_cnt - 1; 
                   data_inc_low := data_inc_low + x"00000002";                                        
                   data_inc_high := data_inc_high + x"00000002";                                        
              end if;
              
              pci.ad(31 downto 0)  <= data_inc_low ;            
              pci.ad(63 downto 32) <= data_inc_high;
              
              wait until pciclk'event and pciclk = '1';
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
              
            end loop;
          
          end if;
       ------------------------------------------------------------------           
        
           if( pci.irdyn = '0' and pci.trdyn = '0') then
             data_inc_low := data_inc_low + x"00000002";                                        
             data_inc_high := data_inc_high + x"00000002";                                        
           end if;
             
             pci.ad(31 downto 0)  <= data_inc_low ;            
             pci.ad(63 downto 32) <= data_inc_high;
        
           if (mon.disengage_mstr = '1' and qword > 1 and pci.framen = '0')  or 
             (mon.disengage_mstr = '0' and qword_cnt = 1) then
        
             pci.framen <= '1';
             pci.req64n <= '1';                                                        
            
            wait until pciclk'event and pciclk = '1';
             while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
              
           end if;
         
              pci.irdyn <= '1';                                                         
              pci.ad <= (others => 'Z');                                                
              pci.cben <= (others => 'Z');                                              
              mstr.par_en <= '0';
              mstr.par_en_64 <= '0'; 
                                                                                    
           wait until pciclk'event and pciclk = '1';                                      
           wait for tdel;
             drive_z(pci);
           
        
           if (pci.devseln = '0') then
             wait until (pci.devseln = '1');
           end if;
          
       end mem_wr_64;                                                               
       ---------------------------------------------------------------------
       
      
      
       --*********************************************************                   
       --64 bit Memory Read
       procedure mem_rd_64(signal  pci     : inout pcisig_rec;
                           signal  mstr    : inout mstr_intsig;
                           signal  mon     : in mon_sig;
                                   address :std_logic_vector(31 downto 0);                    
                          constant qword   :integer := 1) is                         
       --*********************************************************                   
                                                                                     
         variable qword_cnt : integer := qword;
         
          begin 
          
            
           --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
            while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
            end loop;
          
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           --Address phase                                                                         
            pci.framen <= '0';
            pci.req64n <= '0';                                                          
            pci.ad(63 downto 32) <= (others => '0');                                     
            pci.cben(7 downto 4) <= "0000";                                             
            pci.ad(31 downto 0) <= address;                                              
            pci.cben(3 downto 0) <= "0110";                                              
            mstr.par_en <= '1';                                                           
            mstr.par_en_64 <= '1';
                                                                                     
           --Turn around phase
           wait until pciclk'event and pciclk = '1';                                       
           wait for tdel;                                                            
            
           --If it is not a Burst transaction deassert framen                                       
            qword_cnt := qword_cnt - 1;                                              
             if (qword > 1) then                                                      
                pci.framen <= '0';                                                        
              else                                                                   
               pci.framen <= '1';                                                        
             end if;                                                                  
            pci.ad(63 downto 0) <= (others => 'Z');   
            pci.cben(7 downto 0) <= (others => '0');                                              
            pci.irdyn <= '0';                                                           
            mstr.par_en <= '0';                                                           
            mstr.par_en_64 <= '0';
        
          mstr.mstr_tranx_reqn <= '1';
          
          --Data Phase
         while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
           wait until pciclk'event and pciclk = '1';
          end loop;
                                                                                    
       -------------Burst read transaction-----------------------
       if (qword > 1 and mon.disengage_mstr = '0')then 
                         
          while(qword_cnt > 0 and mon.disengage_mstr = '0') loop                                                  
             
             if qword_cnt = 1 then                                                  
             pci.framen <= '1';                                                         
             end if;                                                                
                                                                                    
             qword_cnt := qword_cnt - 1;
             
             wait until pciclk'event and pciclk = '1';                                        
             while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
              
             
          end loop;
       end if;                                                                       
       -------------------------------------------------------------          
            
          if (mon.disengage_mstr = '1' and qword > 1 and pci.framen = '0')  or 
             (mon.disengage_mstr = '0' and qword_cnt = 1) then
        
             pci.framen <= '1';
             pci.req64n <= '1';                                                        
             
             qword_cnt := qword_cnt - 1;
             
             wait until pciclk'event and pciclk = '1';                                        
             while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
             
         end if;
           
           pci.irdyn <= '1';                                                         
           pci.cben <= (others => 'Z');                                              
                                                                                    
          wait until pciclk'event and pciclk = '1';                                      
          wait for tdel;
           drive_z(pci);
           
          if (pci.devseln = '0') then
           wait until (pci.devseln = '1');
          end if;
       
       end mem_rd_64; 
      
      
       -----------------------------------------------------------------------------
       --***************************************************************************                                                 
       --64 bit DAC Memory Write
       procedure mem_wr_dac(signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(63 downto 0);                                                  
                                   data     :std_logic_vector(31 downto 0);                                                  
                            constant dword  :integer := 1) is                                                       
       --***************************************************************************                                                 
                                                                                                                    
          variable data_inc  : std_logic_vector(31 downto 0) := data(31 downto 0);                                 
          variable dword_cnt : integer := dword;                                                                    
                                                                                                                    
           begin                                                                                                    
             
             
             --Request for the bus
              mstr.mstr_tranx_reqn <= '0';
             
              --Wait till the gnt is asserted
              while (mon.mstr_tranx_gntn = '1') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
            
             --Wait for the bus to be free 
             while(mon.busfree = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
                                                                                                                
             --Address phase                                                                                        
             pci.framen <= '0';                                                                                         
             pci.ad(63 downto 0) <= address(63 downto 0);                                                                   
             pci.cben(7 downto 4) <= "0111"; 	     
             pci.cben(3 downto 0) <= "1101";                                                                            
             mstr.par_en <= '1';                                                                                         
            
	     wait until pciclk'event and pciclk = '1';
	     pci.ad(63 downto 32) <= address(63 downto 32); 
	     pci.ad(31 downto 0) <= address(63 downto 32);	     
             pci.cben(7 downto 4) <= "0111"; 	     
             pci.cben(3 downto 0) <= "0111";  

            --Data phase                                                                                            
            wait until pciclk'event and pciclk = '1';                                                                     
            wait for tdel;                                                                                          
            
             --deassert framen if it is not a burst transaction                                                                          
             dword_cnt := dword_cnt - 1;                                                                            
             if (dword > 1) then                                                                                    
               pci.framen <= '0';                                                                                       
               else                                                                                                 
               pci.framen <= '1';                                                                                       
             end if;                                                                                                
             pci.ad(31 downto 0) <= data;                                                                               
             pci.cben(7 downto 0) <= (others => '0');                                                                   
             pci.irdyn <= '0';                                                                                          
                                                                                                                    
             mstr.mstr_tranx_reqn <= '1';                                                                                    
                                                                                                                    
           while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
             wait until pciclk'event and pciclk = '1';
           end loop;
                                                                                                                       
       --------------burst transaction---------------------------------
         if (dword > 1 and mon.disengage_mstr = '0')then                                                                
                                                                                                                    
           while(dword_cnt > 0 and mon.disengage_mstr = '0') loop                                                       
                                                                                                                    
              if dword_cnt = 1 then                                                                                 
               pci.framen <= '1';                                                                                        
              end if;                                                                                               
                                                                                                                    
              if( pci.irdyn = '0' and pci.trdyn ='0') then                                                                  
               dword_cnt := dword_cnt - 1;                                                                           
               data_inc := data_inc + x"00000001";                                                                   
              end if;                                                                                               
                                                                                                                    
              pci.ad(31 downto 0) <= data_inc;                                                                          
                                                                                                                    
              wait until pciclk'event and pciclk = '1';                                                                   
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
                                                                                                              
           end loop;                                                                                                
                                                                                                                    
        end if;                                                                                                     
        ------------------------------------------------------------------                                          
                                                                                                                    
           if( pci.irdyn = '0' and pci.trdyn = '0') then                                                                      
                data_inc := data_inc + x"00000001";                                                                 
           end if;                                                                                                   
                                                                                                                    
               pci.ad(31 downto 0)  <= data_inc ;                                                                            
                                                                                                                    
           if (mon.disengage_mstr = '1' and dword > 1 and pci.framen = '0')  or                                               
              (mon.disengage_mstr = '0' and dword_cnt = 1) then                                                          
       
              pci.framen <= '1';                                                                                        
              --pci.ad <= (others => 'Z');
                                                                                                                    
              wait until pciclk'event and pciclk = '1';                                                                   
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
          end if;                                                                                                    
                                                                                                                    
             pci.irdyn <= '1';                                                                                        
             pci.ad <= (others => 'Z');                                                                               
             pci.cben <= (others => 'Z');                                                                             
             mstr.par_en <= '0';                                                                                       
                                                                                                                    
             wait until pciclk'event and pciclk = '1';                                                                     
             wait for tdel;                                                                                          
             drive_z(pci);
                                                                                                          
           if (pci.devseln = '0') then                                                                             
             wait until (pci.devseln = '1');                                                                               
           end if;                                                                                                   
            
       end mem_wr_dac;  
       
       
       --*********************************************************                                      
       --64 bit DAC Memory Read
       procedure mem_rd_dac(signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(63 downto 0);                                       
                            constant dword  :integer := 1) is                                            
       --*********************************************************                                      
                                                                                                         
          variable dword_cnt : integer := dword;                                                         
                                                                                                         
           begin                                                                                         
              
              --Request for the bus
              mstr.mstr_tranx_reqn <= '0';
             
              --Wait till the gnt is asserted
              while (mon.mstr_tranx_gntn = '1') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
            
             --Wait for the bus to be free 
             while(mon.busfree = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
                                                                                                   
                                                                                                         
             --Address phase                                                                                        
             pci.framen <= '0';                                                                                         
             pci.ad(63 downto 0) <= address(63 downto 0);                                                                   
             pci.cben(7 downto 4) <= "0110"; 	     
             pci.cben(3 downto 0) <= "1101";                                                                            
             mstr.par_en <= '1';                                                                                         
            
	     wait until pciclk'event and pciclk = '1';
	     pci.ad(63 downto 32) <= address(63 downto 32); 
	     pci.ad(31 downto 0) <= address(63 downto 32);	     
             pci.cben(7 downto 4) <= "0110"; 	     
             pci.cben(3 downto 0) <= "0110";                                                                             
                                                                                                         
            --Turnaround Phase
            wait until pciclk'event and pciclk = '1';                                                          
            wait for tdel;                                                                               
             --check for burst transaction                                                               
             dword_cnt := dword_cnt - 1;                                                                 
             if (dword > 1) then                                                                         
               pci.framen <= '0';                                                                            
               else                                                                                      
               pci.framen <= '1';                                                                            
             end if;                                                                                     
             pci.ad(63 downto 0) <= (others => 'Z');                                                         
             pci.cben(7 downto 0) <= (others => '0');                                                        
             pci.irdyn <= '0';                                                                               
             mstr.par_en <= '0';                                                                              
                                                                                                         
             mstr.mstr_tranx_reqn <= '1';                                                                        
           
           --Data Phase  
           while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;                                                                                           
                                                                                                         
        -------------burst read transaction-----------------------------------                                                              
        if (dword > 1 and mon.disengage_mstr = '0')then                                                      
                                                                                                         
           while(dword_cnt > 0 and mon.disengage_mstr = '0') loop                                            
                                                                                                         
              if dword_cnt = 1 then                                                                      
               pci.framen <= '1';                                                                             
              end if;                                                                                    
                                                                                                         
               dword_cnt := dword_cnt - 1;                                                                
                                                                                                         
              wait until pciclk'event and pciclk = '1';                                                        
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop; 
                                                                                                         
           end loop;                                                                                     
        end if;                                                                                          
       ------------------------                                                                         
                                                                                                         
         if (mon.disengage_mstr = '1' and dword > 1 and pci.framen = '0')  or                               
           ( mon.disengage_mstr = '0' and dword_cnt = 1) then                                             
                                                                                                      
              pci.framen <= '1';                                                                          
              dword_cnt := dword_cnt - 1;                                                             
                                                                                                      
              wait until pciclk'event and pciclk = '1';                                                     
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop; 
                                                                                                      
          end if;                                                                                     
                                                                                                      
                                                                                                      
            pci.irdyn <= '1';                                                                             
            pci.cben <= (others => 'Z');                                                                  
                                                                                                      
           wait until pciclk'event and pciclk = '1';                                                        
           wait for tdel;                                                                             
            drive_z(pci);
                                                                                                      
                                                                                                      
           if (pci.devseln = '0') then                                                                    
            wait until (pci.devseln = '1');                                                                
           end if;                                                                                    
                                                                                                                                                                               
       end mem_rd_dac;                                                                                
       
       -----------------------------------------------------------------------------


       -----------------------------------------------------------------------------
       --***************************************************************************                                                 
       --32 bit Memory Write
       procedure mem_wr_32( signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(31 downto 0);                                                  
                                   data     :std_logic_vector(31 downto 0);                                                  
                            constant dword  :integer := 1) is                                                       
       --***************************************************************************                                                 
                                                                                                                    
          variable data_inc  : std_logic_vector(31 downto 0) := data(31 downto 0);                                 
          variable dword_cnt : integer := dword;                                                                    
                                                                                                                    
           begin                                                                                                    
             
             
             --Request for the bus
              mstr.mstr_tranx_reqn <= '0';
             
              --Wait till the gnt is asserted
              while (mon.mstr_tranx_gntn = '1') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
            
             --Wait for the bus to be free 
             while(mon.busfree = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
                                                                                                                    
                                                                                                                    
             --Address phase                                                                                        
             pci.framen <= '0';                                                                                         
             pci.ad(63 downto 32) <= (others => '0');                                                                   
             pci.cben(7 downto 4) <= "0000";                                                                            
             pci.ad(31 downto 0) <= address;                                                                            
             pci.cben(3 downto 0) <= "0111";                                                                            
             mstr.par_en <= '1';                                                                                         
            
            --Data phase                                                                                            
            wait until pciclk'event and pciclk = '1';                                                                     
            wait for tdel;                                                                                          
            
             --deassert framen if it is not a burst transaction                                                                          
             dword_cnt := dword_cnt - 1;                                                                            
             if (dword > 1) then                                                                                    
               pci.framen <= '0';                                                                                       
               else                                                                                                 
               pci.framen <= '1';                                                                                       
             end if;                                                                                                
             pci.ad(31 downto 0) <= data;                                                                               
             pci.cben(7 downto 0) <= (others => '0');                                                                   
             pci.irdyn <= '0';                                                                                          
                                                                                                                    
             mstr.mstr_tranx_reqn <= '1';                                                                                    
                                                                                                                    
           while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
             wait until pciclk'event and pciclk = '1';
           end loop;
                                                                                                                       
       --------------burst transaction---------------------------------
         if (dword > 1 and mon.disengage_mstr = '0')then                                                                
                                                                                                                    
           while(dword_cnt > 0 and mon.disengage_mstr = '0') loop                                                       
                                                                                                                    
              if dword_cnt = 1 then                                                                                 
               pci.framen <= '1';                                                                                        
              end if;                                                                                               
                                                                                                                    
              if( pci.irdyn = '0' and pci.trdyn ='0') then                                                                  
               dword_cnt := dword_cnt - 1;                                                                           
               data_inc := data_inc + x"00000001";                                                                   
              end if;                                                                                               
                                                                                                                    
              pci.ad(31 downto 0) <= data_inc;                                                                          
                                                                                                                    
              wait until pciclk'event and pciclk = '1';                                                                   
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
                                                                                                              
           end loop;                                                                                                
                                                                                                                    
        end if;                                                                                                     
        ------------------------------------------------------------------                                          
                                                                                                                    
           if( pci.irdyn = '0' and pci.trdyn = '0') then                                                                      
                data_inc := data_inc + x"00000001";                                                                 
           end if;                                                                                                   
                                                                                                                    
               pci.ad(31 downto 0)  <= data_inc ;                                                                            
                                                                                                                    
           if (mon.disengage_mstr = '1' and dword > 1 and pci.framen = '0')  or                                               
              (mon.disengage_mstr = '0' and dword_cnt = 1) then                                                          
       
              pci.framen <= '1';                                                                                        
              --pci.ad <= (others => 'Z');
                                                                                                                    
              wait until pciclk'event and pciclk = '1';                                                                   
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
          end if;                                                                                                    
                                                                                                                    
             pci.irdyn <= '1';                                                                                        
             pci.ad <= (others => 'Z');                                                                               
             pci.cben <= (others => 'Z');                                                                             
             mstr.par_en <= '0';                                                                                       
                                                                                                                    
             wait until pciclk'event and pciclk = '1';                                                                     
             wait for tdel;                                                                                          
             drive_z(pci);
                                                                                                          
           if (pci.devseln = '0') then                                                                             
             wait until (pci.devseln = '1');                                                                               
           end if;                                                                                                   
            
       end mem_wr_32;  
       
       
       --*********************************************************                                      
       --32 bit Memory Read
        procedure mem_rd_32(signal pci      : inout pcisig_rec;
                            signal mstr     : inout mstr_intsig;
                            signal mon      : in mon_sig;
                                   address  :std_logic_vector(31 downto 0);                                       
                            constant dword  :integer := 1) is                                            
       --*********************************************************                                      
                                                                                                         
          variable dword_cnt : integer := dword;                                                         
                                                                                                         
           begin                                                                                         
              
              --Request for the bus
              mstr.mstr_tranx_reqn <= '0';
             
              --Wait till the gnt is asserted
              while (mon.mstr_tranx_gntn = '1') loop
                wait until pciclk'event and pciclk = '1';
              end loop;
            
             --Wait for the bus to be free 
             while(mon.busfree = '0') loop
                wait until pciclk'event and pciclk = '1';
             end loop;
                                                                                                   
                                                                                                         
            --Address phase                                                                              
             pci.framen <= '0';                                                                              
             pci.ad(63 downto 32) <= (others => '0');                                                        
             pci.cben(7 downto 4) <= "0000";                                                                 
             pci.ad(31 downto 0) <= address;                                                                 
             pci.cben(3 downto 0) <= "0110";                                                                 
             mstr.par_en <= '1';                                                                              
                                                                                                         
            --Turnaround Phase
            wait until pciclk'event and pciclk = '1';                                                          
            wait for tdel;                                                                               
             --check for burst transaction                                                               
             dword_cnt := dword_cnt - 1;                                                                 
             if (dword > 1) then                                                                         
               pci.framen <= '0';                                                                            
               else                                                                                      
               pci.framen <= '1';                                                                            
             end if;                                                                                     
             pci.ad(63 downto 0) <= (others => 'Z');                                                         
             pci.cben(7 downto 0) <= (others => '0');                                                        
             pci.irdyn <= '0';                                                                               
             mstr.par_en <= '0';                                                                              
                                                                                                         
             mstr.mstr_tranx_reqn <= '1';                                                                        
           
           --Data Phase  
           while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;                                                                                           
                                                                                                         
        -------------burst read transaction-----------------------------------                                                              
        if (dword > 1 and mon.disengage_mstr = '0')then                                                      
                                                                                                         
           while(dword_cnt > 0 and mon.disengage_mstr = '0') loop                                            
                                                                                                         
              if dword_cnt = 1 then                                                                      
               pci.framen <= '1';                                                                             
              end if;                                                                                    
                                                                                                         
               dword_cnt := dword_cnt - 1;                                                                
                                                                                                         
              wait until pciclk'event and pciclk = '1';                                                        
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop; 
                                                                                                         
           end loop;                                                                                     
        end if;                                                                                          
       ------------------------                                                                         
                                                                                                         
         if (mon.disengage_mstr = '1' and dword > 1 and pci.framen = '0')  or                               
           ( mon.disengage_mstr = '0' and dword_cnt = 1) then                                             
                                                                                                      
              pci.framen <= '1';                                                                          
              dword_cnt := dword_cnt - 1;                                                             
                                                                                                      
              wait until pciclk'event and pciclk = '1';                                                     
              while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
              end loop; 
                                                                                                      
          end if;                                                                                     
                                                                                                      
                                                                                                      
            pci.irdyn <= '1';                                                                             
            pci.cben <= (others => 'Z');                                                                  
                                                                                                      
           wait until pciclk'event and pciclk = '1';                                                        
           wait for tdel;                                                                             
            drive_z(pci);
                                                                                                      
                                                                                                      
           if (pci.devseln = '0') then                                                                    
            wait until (pci.devseln = '1');                                                                
           end if;                                                                                    
                                                                                                                                                                               
       end mem_rd_32;                                                                                
       
       -----------------------------------------------------------------------------
       
       --*********************************************************                        
       --IO write
       procedure io_wr(signal pci     : inout pcisig_rec;
                       signal mstr    : inout mstr_intsig;
                       signal mon     : in mon_sig;
                              address :std_logic_vector(31 downto 0);                                 
                              data    :std_logic_vector(31 downto 0)) is                              
       --*********************************************************                            
                                                                                              
         begin                                                                                
           
            --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
           while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
                                                                                            
           --Address phase                                                                    
            pci.framen <= '0';                                                                    
            pci.ad(63 downto 32) <= (others => '0');                                              
            pci.cben(7 downto 4) <= "0000";                                                       
            pci.ad(31 downto 0) <= address;                                                       
            pci.cben(3 downto 0) <= "0011";                                                       
            mstr.par_en <= '1';                                                                    
                                                                                              
           --Data phase                                                                       
           wait until pciclk'event and pciclk = '1';                                                
           wait for tdel;                                                                     
            pci.framen <= '1';                                                                    
            pci.irdyn <= '0';                                                                     
            pci.ad(31 downto 0) <= data;                                                          
            pci.cben(3 downto 0) <= "0000";                                                       
                                                                                              
            mstr.mstr_tranx_reqn <= '1';                                                           
            while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
                wait until pciclk'event and pciclk = '1';
            end loop;
                                                                                              
            pci.irdyn <= '1';                                                                     
            pci.ad <= (others => 'Z');                                                            
            pci.cben <= (others => 'Z');                                                          
            mstr.par_en <= '0';                                                                    
                                                                                              
           wait until pciclk'event and pciclk = '1';                                                
           wait for tdel;                                                                     
           drive_z(pci);
                                                                                              
          if (pci.devseln = '0') then                                                         
            wait until (pci.devseln = '1');                                                     
          end if;                                                                         
                                                                            
       end io_wr;                                                                             
                                                                                              
       --*********************************************************
       --IO Read
       procedure io_rd(signal pci     : inout pcisig_rec;
                       signal mstr    : inout mstr_intsig;
                       signal mon     : in mon_sig;
                              address :std_logic_vector(31 downto 0)) is
       --*********************************************************
         
         begin
           
           --Request for the bus
            mstr.mstr_tranx_reqn <= '0';
           
            --Wait till the gnt is asserted
           while (mon.mstr_tranx_gntn = '1') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           --Wait for the bus to be free 
           while(mon.busfree = '0') loop
              wait until pciclk'event and pciclk = '1';
           end loop;
           
           
           --Address phase
            pci.framen <= '0';
            pci.ad(63 downto 32) <= (others => 'Z');
            pci.cben(7 downto 4) <= (others => '0');
            pci.ad(31 downto 0) <= address;
            pci.cben(3 downto 0) <= "0010";
            mstr.par_en <= '1';
           
           --Turnaround Phase
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
            pci.framen <= '1';
            pci.irdyn <= '0';
            pci.ad(31 downto 0) <= (others => 'Z');
            pci.cben(3 downto 0) <= "0000"; 
            mstr.par_en <= '0';
             
            mstr.mstr_tranx_reqn <= '1';
            
           --Data Phase 
           while (mon.tranx_success = '0' and mon.disengage_mstr = '0') loop
             wait until pciclk'event and pciclk = '1';
           end loop;
          
           pci.irdyn <= '1';
           pci.ad <= (others => 'Z');  
           pci.cben <= (others => 'Z');
            
             
           wait until pciclk'event and pciclk = '1';
           wait for tdel;
           drive_z(pci);
                                                                                              
          if (pci.devseln = '0') then                                                         
            wait until(pci.devseln = '1');                                                     
          end if;                                                                         
                                                                                                                  
       end io_rd;
       
       
       --************************************************************                                          
       PROCEDURE drive_z(signal pci  : inout pcisig_rec) IS 
       
       --************************************************************                      
       begin
            
            pci.ad <= (others => 'Z');                                                                
            pci.cben <= (others => 'Z');  
            pci.req64n <= 'Z';
            pci.framen <= 'Z';                                                                        
            pci.irdyn <= 'Z';
            pci.ack64n <= 'Z';                                                                        
            pci.devseln <= 'Z';
            pci.trdyn <= 'Z';
            pci.stopn <= 'Z';
            
       end drive_z;
       
  end;
