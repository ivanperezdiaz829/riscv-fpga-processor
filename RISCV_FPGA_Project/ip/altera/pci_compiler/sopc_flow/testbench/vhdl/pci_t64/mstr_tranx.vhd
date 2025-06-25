--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: mstr_tranx

--  FUNCTIONAL DESCRIPTION:
--  Master transactor initiates Master transaction on the PCI bus
--  This file is only for simulation.

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
--  This reference design file is being provided on an "as-is" basis and as an 
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

use work.mstr_pkg.all;

entity mstr_tranx is
       generic (
         trgt_tranx_bar0_data     : std_logic_vector(31 downto 0) :=  x"30000000";  --  Target Transactor Bar0 data
         trgt_tranx_bar1_data     : std_logic_vector(31 downto 0) :=  x"fffff2C0"  --  Target Transactor Bar1 data

                );
port(     clk               : in std_logic;                        -- clock
          rstn              : in std_logic;                       -- reset
                                                                   
  --address/data                                                   
          ad                : inout std_logic_vector(63 downto 0); -- Address
          cben              : inout std_logic_vector(7 downto 0);  -- command byte enable
          par               : inout std_logic;                     -- parity for low dword 
          par64             : inout std_logic;                     -- parity for high dword
          reqn              : out std_logic;                       -- Master transactor request
          gntn              : in std_logic;                        -- Master transactor grant
          req64n            : out  std_logic;                      -- Request for 64 bit transaction
          framen            : out  std_logic;                      -- framen
          irdyn             : out  std_logic;                      -- irdyn
          ack64n            : in    std_logic;                     -- acknowledge 64 bit transaction from target
          devseln           : in std_logic;                        -- devseln 
          trdyn             : in std_logic;                        -- target ready signal
          stopn             : in std_logic;                        -- stopn 
          perrn             : inout   std_logic;                   -- parity error
          serrn             : inout   std_logic;                   -- system error
          busfree           : in std_logic;                        -- indicates that the bus is idle
          disengage_mstr    : in std_logic;                        -- indicates to disengage the current transaction
          tranx_success     : in std_logic;                        -- transaction successful
          trgt_tranx_disca  : out std_logic;                       -- target TRANSACTOR disconnect-A
          trgt_tranx_discb  : out std_logic;                       -- target TRANSACTOR disconnect-B
          trgt_tranx_retry  : out std_logic);                      -- target TRANSACTOR retry.
end mstr_tranx;                                                      
         
architecture behavior of mstr_tranx is

     
    signal  pci             : pcisig_rec;                   -- Record that comprises of all the PCI signals declared in mstr_pkg 
    signal  mstr            : mstr_intsig;                  -- Record that comprises of all Master Transactor signals declared in mstr_pkg
    signal  mon             : mon_sig;                      -- Record that comprises of all Monitor signals declared in mstr_pkg
    signal end_sim          : boolean:=false;
  

begin


main: process   

--**********************************************
--PROCEDURES
--The sequence of events to be executed by
--these procudures are defined in mstr_pkg.vhd
--**********************************************


--************************************************************************
-- configurtion write
procedure cfg_wr(address :std_logic_vector(31 downto 0);
                       data    :std_logic_vector(31 downto 0);
                       byte_en :std_logic_vector(3 downto 0)) is
--**************************************************************************
begin 
        cfg_wr(pci,mstr,mon,address,data,byte_en); 
end cfg_wr;

--***********************************************************************
-- config read
procedure cfg_rd(address :std_logic_vector(31 downto 0)) is  
--***********************************************************************
begin
      cfg_rd(pci,mstr,mon,address);        
end cfg_rd;      

--*************************************************************                                          
--64 bit memory write
procedure mem_wr_64(       address  :std_logic_vector(31 downto 0);                                           
                           data     :std_logic_vector(63 downto 0);                       
                    constant qword  :integer := 1) is                            
--*************************************************************   
begin
        mem_wr_64(pci,mstr,mon,address,data,qword);   
end mem_wr_64;


--*********************************************************                   
-- 64 bit memory read
procedure mem_rd_64(        address :std_logic_vector(31 downto 0);                    
                   constant qword   :integer := 1) is                         
--*********************************************************   
begin
        mem_rd_64(pci,mstr,mon,address,qword);     
end mem_rd_64;

--***************************************************************************                                                 
-- 32 bit memory write
procedure mem_wr_32(        address  :std_logic_vector(31 downto 0);                                                  
                            data     :std_logic_vector(31 downto 0);                                                  
                     constant dword  :integer := 1) is                                                       
--***************************************************************************      
begin
        mem_wr_32(pci,mstr,mon,address,data,dword);  
end mem_wr_32;


--*********************************************************                                      
-- 32 bit memory read 
 procedure mem_rd_32(       address  :std_logic_vector(31 downto 0);                                       
                     constant dword  :integer := 1) is                                            
--********************************************************* 
begin
         mem_rd_32(pci,mstr,mon,address,dword);     
end mem_rd_32;

--*********************************************************                        
-- io write
procedure io_wr( address :std_logic_vector(31 downto 0);                                 
                 data    :std_logic_vector(31 downto 0)) is                              
--*********************************************************    
begin
        io_wr(pci,mstr,mon,address,data);
end io_wr;

--*********************************************************
--io read
procedure io_rd(address :std_logic_vector(31 downto 0)) is
--*********************************************************
begin
     io_rd(pci,mstr,mon,address);
end io_rd;



procedure sim_done is
begin
   assert false 
   report "Simulation Sucessful : End of simulation time reached"
   severity failure;  
end sim_done;
          

procedure sys_rst is
begin
     wait until rstn'event and rstn='1';
     idle_cycle(10);
end sys_rst;
          
--*************************************************************************
-- Configuration Address Space  
--*************************************************************************

constant DeviceVendorIDAddress    : std_logic_vector(31 downto 0) :=  x"00000800";  -- idsel of PCI MegaCore function is tied to ad[11]
constant StatusCommandRegAddress  : std_logic_vector(31 downto 0) :=  x"00000804";
                                       
constant bar0_address             : std_logic_vector(31 downto 0) :=  x"00000810";
constant bar1_address             : std_logic_vector(31 downto 0) :=  x"00000814";
constant bar2_address             : std_logic_vector(31 downto 0) :=  x"00000818";
                                       
constant trgt_tranx_bar0_address  : std_logic_vector(31 downto 0) :=  x"00001010";  -- idsel of Target Transactor is tied to ad[12]
constant trgt_tranx_bar1_address  : std_logic_vector(31 downto 0) :=  x"00001014";

     
--*************************************************************************
-- Defines the data to be written in the Configuration Space
--*************************************************************************
constant CommandRegister_Data     : std_logic_vector(31 downto 0) :=  x"00000147";   -- Command Register Data
                                        
constant bar0_data                : std_logic_vector(31 downto 0) :=  x"10000000";  --  PCI Bar0 data
constant bar1_data                : std_logic_vector(31 downto 0) :=  x"20000000";  --  PCI Bar1 data

                                      
constant EnableAll                : std_logic_vector(3 downto 0) :=   x"0";         -- Byte Enables

begin                                                                                                                                                                                 

    wait until pciclk'event and pciclk = '1';
     
      trgt_tranx_disca <= '0';
      trgt_tranx_discb <= '0';
      trgt_tranx_retry <= '0';
      mstr.par_en <= '0';     
--      mstr.par_en_64 <= '0';
      mstr.mstr_tranx_reqn <= '1';
      perrn <= 'Z';
      serrn <= 'Z';
      drive_z(pci);
    
     
     
--*************************************************************************************
--INITIALIZATION
--*************************************************************************************

     --System Reset       
     sys_rst;

--*********************************************************************************
--USER COMMANDS
--*********************************************************************************

--------------------------------------------------
-- Configuration Writes( Address, Data, Byte_Enables) 
-- cfg_wr(x"10000004",x"00000147","0000"); 
--------------------------------------------------
     
     cfg_wr(StatusCommandRegAddress,CommandRegister_Data,EnableAll);   --config write to command register
     cfg_wr(bar0_address,bar0_data,EnableAll);                         --config write to bar0_data of Altera PCI MegaCore
     cfg_wr(bar1_address,bar1_data,EnableAll);                         --config write to bar1_data of Altera PCI MegaCore
     
     --cfg_wr(trgt_tranx_bar0_address,trgt_tranx_bar0_data,EnableAll);   --config write to bar0_data of target Transactor
     --cfg_wr(trgt_tranx_bar1_address,trgt_tranx_bar1_data,EnableAll);   --config write to bar1_data of target Transactor
     
     
-----------------------------------------------------
-- Configuration Read(Address)
-- cfg_rd(x"10000004"); 
-----------------------------------------------------     
    
     cfg_rd(StatusCommandRegAddress);   --config read of command register
     cfg_rd(bar0_address);                 --config read of bar0_data of Altera PCI MegaCore
     cfg_rd(bar1_address);
     
     --cfg_rd(trgt_tranx_bar0_address);
     --cfg_rd(trgt_tranx_bar1_address);


---------------------------------------------------
--64 bit memory write(address, data, no. of qwords) 
--This command is not applicable to a  32 bit Target
--mem_wr_64(x"10000000",x"0000000200000001",1);
---------------------------------------------------     
    
      --mem_wr_64(bar0_data,x"0000000200000001",1);
      --mem_wr_64(trgt_tranx_bar0_data,x"0000000200000001",1);
    
----------------------------------------------------
--64 bit memory read(Address, Numbrer of qwords)
--This command is not applicable to a  32 bit Target
--mem_rd_64(x"10000000",1);
----------------------------------------------------
 
      --mem_rd_64(bar0_data,1);
      --mem_rd_64(trgt_tranx_bar0_data,1);
     
---------------------------------------------------      
-- 32 bit memory write(Address, Data, Number of Dwords)   
-- mem_wr_32(x"10000000",x"00000001",1);
---------------------------------------------------

      --mem_wr_32(bar0_data,x"00000001",1);
      --mem_wr_32(trgt_tranx_bar0_data,x"00000001",1);
        
--------------------------------------------------
-- 32 bit memory read(Address, Number of Dwords)
-- mem_rd_32(x"10000000",1); 
---------------------------------------------------          

     --mem_rd_32(bar0_data,1);
     --mem_rd_32(trgt_tranx_bar0_data,1);

-----------------------------------------
-- io write transaction(Address, Data)  
-- io_wr(x"10000000",x"00000111");
-----------------------------------------      

       --io_wr(bar1_data,x"00000111");
       --io_wr(trgt_tranx_bar1_data,x"00000222");

-----------------------------------------------
-- io read transaction(Address) 
-- io_wr(x"10000000",);   
-----------------------------------------------        

      --io_rd(bar1_data);
      --io_rd(trgt_tranx_bar1_data);

-----------------------------------------------------------------------         
--Target termination examples  with TARGET TRANSACTOR(trgtet-tranx)
-----------------------------------------------------------------------     

--Target retry
     
      --trgt_tranx_retry <= '1';
      --mem_wr_64(trgt_tranx_bar0_data,x"0000000200000001",5);
      --trgt_tranx_retry <= '0';
     
      --trgt_tranx_retry <= '1';
      --mem_rd_64(trgt_tranx_bar0_data,5);
      --trgt_tranx_retry <= '0';
     
--Disconnect-A ( disconnect with data)
      
     --trgt_tranx_disca <= '1';
     --mem_wr_64(trgt_tranx_bar0_data,x"0000000200000001",5);
     --trgt_tranx_disca <= '0';
    
     --trgt_tranx_disca <= '1';
     --mem_rd_64(trgt_tranx_bar0_data,1);
     --trgt_tranx_disca <= '0';
     
--Disconnect-B( disconnect without data)
      
     --trgt_tranx_discb <= '1';
     --mem_wr_64(trgt_tranx_bar0_data,x"0000000200000001",5);
     --trgt_tranx_discb <= '0';
    
     --trgt_tranx_discb <= '1';
     --mem_rd_64(trgt_tranx_bar0_data,5);
     --trgt_tranx_discb <= '0';


     idle_cycle(20);
     sim_done;  

end process;     


--************************************************************************************
-- End of User Commands
--************************************************************************************
 



--************************************************************************************* 
process (clk,pci.ad,pci.cben,pci.req64n,pci.framen,pci.irdyn,ack64n,devseln,trdyn,stopn,
         mstr.mstr_tranx_reqn,gntn,busfree,disengage_mstr,tranx_success)
--*************************************************************************************  
 begin
   pciclk <= clk;
   ad <= pci.ad;
   cben <= pci.cben;
   req64n <= pci.req64n;
   framen <= pci.framen;
   irdyn <= pci.irdyn;
   pci.ack64n <= ack64n;
   pci.devseln <= devseln;
   pci.trdyn <= trdyn;
   pci.stopn <= stopn;
   reqn  <= mstr.mstr_tranx_reqn ;
   mon.mstr_tranx_gntn <= gntn ;
   mon.busfree <= busfree;
   mon.disengage_mstr <= disengage_mstr;
   mon.tranx_success <= tranx_success;
 end process; 
 
        
        
--**************************************************************
--pci parity gen --lower dword
parity_gen: process (pciclk)
     variable result_reg : std_logic;
--**************************************************************     
  begin

     if pciclk'event and pciclk = '1' then
       result_reg :=   pci.ad(31) xor pci.ad(30) xor pci.ad(29) xor pci.ad(28)
                   xor pci.ad(27) xor pci.ad(26) xor pci.ad(25) xor pci.ad(24)
                   xor pci.ad(23) xor pci.ad(22) xor pci.ad(21) xor pci.ad(20)
                   xor pci.ad(19) xor pci.ad(18) xor pci.ad(17) xor pci.ad(16)
                   xor pci.ad(15) xor pci.ad(14) xor pci.ad(13) xor pci.ad(12)
                   xor pci.ad(11) xor pci.ad(10) xor pci.ad(9)  xor pci.ad(8)
                   xor pci.ad(7)  xor pci.ad(6)  xor pci.ad(5)  xor pci.ad(4)
                   xor pci.ad(3)  xor pci.ad(2)  xor pci.ad(1)  xor pci.ad(0)
                   xor pci.cben(3) xor pci.cben(2) xor pci.cben(1) xor pci.cben(0);
            
         if mstr.par_en = '1' then
             par <= result_reg after tdel;
          else
             par <= 'Z' after tdel ;
        end if;
   
     end if;
           
  end process;
   
--*********************************************************
--pci parity gen --higher dword-
parity_gen_64: process(pciclk)
     variable  result_reg_64 : std_logic;
--*********************************************************     
 begin

    if pciclk'event and pciclk = '1' then
       result_reg_64 :=   pci.ad(63) xor pci.ad(62) xor pci.ad(61) xor pci.ad(60)
                      xor pci.ad(59) xor pci.ad(58) xor pci.ad(57) xor pci.ad(56)
                      xor pci.ad(55) xor pci.ad(54) xor pci.ad(53) xor pci.ad(52)
                      xor pci.ad(51) xor pci.ad(50) xor pci.ad(49) xor pci.ad(48)
                      xor pci.ad(47) xor pci.ad(46) xor pci.ad(45) xor pci.ad(44)
                      xor pci.ad(43) xor pci.ad(42) xor pci.ad(41) xor pci.ad(40)
                      xor pci.ad(39) xor pci.ad(38) xor pci.ad(37) xor pci.ad(36)
                      xor pci.ad(35) xor pci.ad(34) xor pci.ad(33) xor pci.ad(32)
                      xor pci.cben(7) xor pci.cben(6) xor pci.cben(5) xor pci.cben(4);
             
             if mstr.par_en_64 = '1' then
              par64 <= result_reg_64 after tdel;
              else
              par64 <= 'Z' after tdel;
            end if;
      end if;
 end process;
      
end behavior;































