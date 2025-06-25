--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: altera_tb

--  FUNCTIONAL DESCRIPTION:
--  This is the top level file of Altera PCI testbench

-----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all; 

entity pci_tb is
port (     
          $$REPLACE_INPUT_CLOCK               : in std_logic;                       
          rstn              : out std_logic;                      
                                                                  
signal ArbReq_n_i : OUT $$REPLACE_ARB_WIDTH;
signal ArbGnt_n_o : IN $$REPLACE_ARB_WIDTH;

          idsel              : out std_logic;
          ad                : inout std_logic_vector(63 downto 0);
          cben              : inout std_logic_vector(7 downto 0); 
          par               : inout std_logic;                    
          par64             : inout std_logic;                    
          intan             : inout  std_logic;                     
                                 
          req64n            : inout  std_logic;                     
          framen            : inout  std_logic;                     
          irdyn             : inout  std_logic;                     
          ack64n            : inout    std_logic;                    
          devseln           : inout std_logic;                       
          trdyn             : inout std_logic;                       
          stopn             : inout std_logic;                       
          perrn             : inout   std_logic;                  
          serrn             : inout   std_logic;
          $$REPLACE_OUTPUT_CLOCK             : out   std_logic                 
          );   

end pci_tb;         

architecture behavior of pci_tb is

component clk_gen 
generic(pciclk_66Mhz_enable : boolean := true);                                                                                           
        port(                                                                                                 
        pciclk         : out std_logic);                                 
end component;

component mstr_tranx
       generic (
         trgt_tranx_bar0_data     : std_logic_vector(31 downto 0) :=  x"00000000";
         trgt_tranx_bar1_data     : std_logic_vector(31 downto 0) :=  x"fffff2C0"  --  Target Transactor Bar1 data
                );  
      port(
          clk           : in std_logic;                                 
          rstn          : in std_logic;                                
  
  --address/data
          ad            : inout std_logic_vector(63 downto 0);           
          cben          : inout std_logic_vector(7 downto 0);          
          par           : inout std_logic;                              
          par64         : inout std_logic;                            
  
  --control
          reqn          : out std_logic;
          gntn          : in std_logic;
          req64n        : out  std_logic;                           
          framen        : out  std_logic;                           
          irdyn         : out  std_logic;                            
          ack64n        : in    std_logic;                           
          devseln       : in std_logic;                          
          trdyn         : in std_logic;                            
          stopn         : in std_logic;
          perrn         : inout   std_logic;
          serrn         : inout   std_logic;
          busfree       : in std_logic;
          disengage_mstr : in std_logic;
          tranx_success  : in std_logic;
          trgt_tranx_disca : out std_logic;
          trgt_tranx_discb : out std_logic;
          trgt_tranx_retry : out std_logic);
end component;          
          

component trgt_tranx
         generic (
       
        address_lines       : integer := 1024;
        mem_hit_range       : std_logic_vector(31 downto 0) := x"00100000";
        io_hit_range        : std_logic_vector(31 downto 0) := x"0000000F"
                );  
      port(
          clk           : in std_logic;                                 
          rstn          : in std_logic;                                
  
  --address/data
          ad            : inout std_logic_vector(63 downto 0);           
          cben          : in    std_logic_vector(7 downto 0);          
          par           : inout std_logic;                              
          par64         : inout std_logic;                            
  
  --control
          idsel         : in  std_logic;
          req64n        : in  std_logic;                           
          framen        : in  std_logic;                           
          irdyn         : in  std_logic;                            
          ack64n        : out std_logic;                           
          devseln       : out std_logic;                          
          trdyn         : out std_logic;                            
          stopn         : out std_logic;
          perrn         : out std_logic;
          serrn         : out std_logic;
   trgt_tranx_disca   : in std_logic;
   trgt_tranx_discb   : in std_logic;
   trgt_tranx_retry   : in std_logic);
        
end component; 

 
 component monitor 
    port( clk          : in std_logic;                                 
          rstn         : in std_logic;                                
          ad           : in std_logic_vector(63 downto 0);           
          cben         : in std_logic_vector(7 downto 0);          
          req64n       : in std_logic;                           
          framen       : in std_logic;                           
          irdyn        : in std_logic;                            
          ack64n       : in std_logic;                           
          devseln      : in std_logic;                          
          trdyn        : in std_logic;                            
          stopn        : in std_logic;
          busfree      : out std_logic;
      disengage_mstr   : out std_logic;
      tranx_success    : out std_logic);                            
end component;
 
 component pull_up
    port( ad           : out std_logic_vector(63 downto 0);
          cben         : out std_logic_vector(7 downto 0);
          par          : out std_logic;
          par64        : out std_logic;
          req64n       : out std_logic;                           
          framen       : out std_logic;                           
          irdyn        : out std_logic;                            
          ack64n       : out std_logic;                           
          devseln      : out std_logic;                          
          trdyn        : out std_logic;                            
          stopn        : out std_logic;
          perrn        : out std_logic;
          serrn        : out std_logic;
          intan        : out std_logic);                            
end component;
 
   signal rstn_out	   : std_logic;       
        
    signal busfree             : std_logic;
    signal disengage_mstr      : std_logic;
    signal tranx_success       : std_logic;
    
    signal trgt_tranx_disca    :std_logic;
    signal trgt_tranx_discb    :std_logic;
    signal trgt_tranx_retry    :std_logic;
    
    

begin

idsel <= ad(11);

rstn <= rstn_out;

process
begin
rstn_out <= '0';
$$REPLACE_REQ_PULLUP
wait for 200 ns;
rstn_out <= '1';
wait;
end process;

u0: clk_gen
        port map        
       (pciclk      =>  $$REPLACE_OUTPUT_CLOCK);

u1: mstr_tranx
  generic map (
         trgt_tranx_bar0_data => x"00000000",
         trgt_tranx_bar1_data => x"fffff2C0"  --  Target Transactor Bar1 data
          )  
        port map
       (clk          =>  $$REPLACE_INPUT_CLOCK,          
        rstn         =>  rstn_out,         
        ad           =>  ad,          
        cben         =>  cben,         
        par          =>  par,         
        par64        =>  par64,       
	reqn         =>  $$REPLACE_ARBREQ,
        gntn         =>  $$REPLACE_ARBGNT,
        req64n       =>  req64n,      
        framen       =>  framen,     
        irdyn        =>  irdyn,      
        ack64n       =>  ack64n,      
        devseln      =>  devseln,   
        trdyn        =>  trdyn,    
        stopn        =>  stopn,
        perrn        =>  perrn,
        serrn        =>  serrn,
        busfree      =>  busfree,
   disengage_mstr    =>  disengage_mstr,
   tranx_success     =>  tranx_success,
   trgt_tranx_disca  =>  trgt_tranx_disca,
   trgt_tranx_discb  =>  trgt_tranx_discb,
   trgt_tranx_retry  =>  trgt_tranx_retry);
        
        
u2: trgt_tranx
      generic map (
        address_lines => 1024,
        mem_hit_range =>  x"00100000",
        io_hit_range  =>  x"0000000F"
                )
       port map        
       (clk          =>  $$REPLACE_INPUT_CLOCK,         
        rstn         =>  rstn_out,        
        ad           =>  ad,
        cben         =>  cben,
         idsel        =>  ad(12),
        par          =>  par,
        par64        =>  par64,
        req64n       =>  req64n,
        framen       =>  framen,      
        irdyn        =>  irdyn,             
        ack64n       =>  ack64n,
        devseln      =>  devseln,             
        stopn        =>  stopn,
        trdyn        =>  trdyn,
        perrn        =>  perrn,
        serrn        =>  serrn,
trgt_tranx_disca   => trgt_tranx_disca,   
trgt_tranx_discb   => trgt_tranx_discb,   
trgt_tranx_retry   =>  trgt_tranx_retry);            



u3: monitor
       port map        
     (clk            =>  $$REPLACE_INPUT_CLOCK,         
      rstn           =>  rstn_out,        
      ad             =>  ad,
      cben           =>  cben,
      req64n         =>  req64n,
      framen         =>  framen,      
      irdyn          =>  irdyn,             
      ack64n         =>  ack64n,
      devseln        =>  devseln,             
      trdyn          =>  trdyn,
      stopn          =>  stopn,
      busfree        =>  busfree,
      disengage_mstr =>  disengage_mstr,
      tranx_success  =>  tranx_success);

u4: pull_up
       port map        
     (ad             => ad,  
      cben           => cben,
      par            => par,
      par64          => par64,
      framen         =>  framen,      
      irdyn          =>  irdyn,             
      ack64n         =>  ack64n,
      devseln        =>  devseln,             
      trdyn          =>  trdyn,
      stopn          =>  stopn,
      req64n         =>  req64n,
      perrn          =>  perrn,
      serrn          =>  serrn,
      intan          =>  intan);
      
end behavior;

