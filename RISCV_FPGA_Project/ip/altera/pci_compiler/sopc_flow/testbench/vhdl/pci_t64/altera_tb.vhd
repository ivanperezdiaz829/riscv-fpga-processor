--------------------------------------------------------------------
--  Altera PCI testbench
--  MODULE NAME: altera_tb

--  FUNCTIONAL DESCRIPTION:
--  This is the top level file of Altera PCI testbench

-----------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all; 

entity altera_tb is
end altera_tb;         

architecture behavior of altera_tb is

component clk_gen 
generic(pciclk_66Mhz_enable : boolean := true);                                                                                           
        port(                                                                                                 
        pciclk         : out std_logic);                                 
end component;        


component pci_top                                                                                            
        port(                                                                                                 
        --pci signals
        --system
        clk             : in std_logic;                                 
        rstn            : in std_logic;                                
        idsel           : in std_logic;
        
        --address/data
        ad              : inout std_logic_vector(63 downto 0);           
        cben            : inout std_logic_vector(7 downto 0);          
        par             : inout std_logic;                              
        par64           : inout std_logic;                            
        
        --control
       
        framen          : in std_logic;                           
        irdyn           : in std_logic;                            
       
        req64n          : in  std_logic;
        ack64n          : out std_logic;
    
        devseln         : out std_logic;                          
        trdyn           : out std_logic;                            
        stopn           : out std_logic;                            
        
        --parity error
        perrn           : out std_logic;                            
        serrn           : out std_logic;                              
        
        --interrupt
        intan           : out std_logic;                              
        
        --local singals
        --address/data
        l_adi           : in std_logic_vector(63 downto 0);           
        
        l_dato          : out std_logic_vector(63 downto 0);         
        l_adro          : out std_logic_vector(63 downto 0);         
        l_beno          : out std_logic_vector(7 downto 0);          
        l_cmdo          : out std_logic_vector(3 downto 0);          
        
        --data/control
        l_ldat_ackn     : out std_logic;                        
        l_hdat_ackn     : out std_logic;                        
        
        
        
        --target control
        lt_abortn       : in std_logic;                           
        lt_discn        : in std_logic;                            
        lt_rdyn         : in std_logic;                             
        
        
        lt_framen       : out std_logic;                          
        lt_ackn         : out std_logic;                            
        lt_dxfrn        : out std_logic;                           
        lt_tsr          : out std_logic_vector(11 downto 0);         
        
        --interrupt
        lirqn           : in std_logic;                               
        
        --config outputs
        
        cmd_reg         : out std_logic_vector(6 downto 0);         
        stat_reg        : out std_logic_vector(6 downto 0));
        
        
end component;                                                                                                   
                                                                                                                 

--local side reference design
component top_local is
  port (
    --*******************************************************************
    --Replace this section with your application design
    --*******************************************************************
    --Clk                  : in std_logic;
    --Rstn                 : in std_logic;
    --
    --Pcil_adr_i           : in std_logic_vector (63 downto 0);
    --Pcil_ben_i           : in std_logic_vector (7 downto 0);
    --Pcil_cmd_i           : in std_logic_vector (3 downto 0);
    --Pcil_dat_i           : in std_logic_vector (63 downto 0);    
    --Pcildat_ack_n_i      : in std_logic;
    --Pcihdat_ack_n_i      : in std_logic;
    --Pcilt_ack_n_i        : in std_logic;
    --Pcilt_dxfr_n_i       : in std_logic;
    --Pcilt_frame_n_i      : in std_logic;
    --Pcilt_tsr_i          : in std_logic_vector (11 downto 0);    
    --Pcil_adi_o           : out std_logic_vector (63 downto 0);
    --Pcilirq_n_o          : out std_logic;
    --Pcilt_abort_n_o      : out std_logic;
    --Pcilt_disc_n_o       : out std_logic;
    --Pcilt_rdy_n_o        : out std_logic
   );
end component;


                                                                                                   
component arbiter 
   generic(park : boolean := false);
   port (
          clk           : in std_logic;   
          rstn          : in std_logic;
          
          framen        : in std_logic;     
          irdyn         : in std_logic;     
          trdyn         : in std_logic;     
          devseln       : in std_logic;     
          stopn         : in std_logic;     
          busfree       : in std_logic;
             
          pci_reqn      : in std_logic_vector(1 downto 0);   
          pci_gntn      : out std_logic_vector(1 downto 0));   
end component;



component mstr_tranx 
      port(
          clk           : in std_logic;                                 
          rstn          : out std_logic;                                
  
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
      port(
          clk           : in std_logic;                                 
          rstn          : in std_logic;                                
  
  --address/data
          ad            : inout std_logic_vector(63 downto 0);           
          cben          : in    std_logic_vector(7 downto 0);          
          par           : inout std_logic;                              
          par64         : inout std_logic;                            
  
  --control
          idsel         : in   std_logic;
          req64n        : in   std_logic;                           
          framen        : in   std_logic;                           
          irdyn         : in   std_logic;                            
          ack64n        : out  std_logic;                           
          devseln       : out  std_logic;                          
          trdyn         : out  std_logic;                            
          stopn         : out  std_logic;
          perrn         : out  std_logic;
          serrn         : out  std_logic;
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
 
   
    signal clk          : std_logic;                                 
    signal rstn         : std_logic;                                    
    
   
   
    signal ad           : std_logic_vector (63 downto 0);
    signal cben         : std_logic_vector (7 downto 0);
   
    signal req64n       : std_logic;
    signal framen       : std_logic;
    signal irdyn        : std_logic;
    signal ack64n       : std_logic;
    signal devseln      : std_logic;
    signal trdyn        : std_logic;
    signal stopn        : std_logic;
   
   
   
    --local signals    
    
    signal l_adi        : std_logic_vector(63 downto 0); 
    signal l_cbeni      : std_logic_vector(7 downto 0); 
    
    signal l_dato       : std_logic_vector(63 downto 0);
    signal l_adro       : std_logic_vector(63 downto 0);
    signal l_beno       : std_logic_vector(7 downto 0);
    signal l_cmdo       : std_logic_vector(3 downto 0);
    
    signal l_ldat_ackn  : std_logic;
    signal l_hdat_ackn  : std_logic;

           
    signal lt_abortn    : std_logic;                      
    signal lt_discn     : std_logic;                      
    signal lt_rdyn      : std_logic;                      
                                                              
    signal lt_framen    : std_logic;                     
    signal lt_ackn      : std_logic;                     
    signal lt_dxfrn     : std_logic;                     
    signal lt_tsr       : std_logic_vector(11 downto 0); 
    
    signal l_irqn       : std_logic;                             
           
  
    signal cmd_reg      : std_logic_vector(6 downto 0);                     
    signal stat_reg     : std_logic_vector(6 downto 0);
 
     
    
    
    signal mstr_tranx_gntn  : std_logic ;
    signal mstr_tranx_reqn  : std_logic ;
    
    
    
    signal perrn : std_logic;
    signal serrn : std_logic;
    signal intan : std_logic;
    
    signal par    : std_logic;     
    signal par64  : std_logic;
    
    
    
    signal busfree             : std_logic;
    signal disengage_mstr      : std_logic;
    signal tranx_success       : std_logic;
    
    signal trgt_tranx_disca    :std_logic;
    signal trgt_tranx_discb    :std_logic;
    signal trgt_tranx_retry    :std_logic;
    
    signal gntn                : std_logic;
    

begin
  

u0: clk_gen
        port map        
       (pciclk      =>  clk);         


u1: pci_top
        port map        
       (clk          =>  clk,         
        rstn         =>  rstn,        
        idsel        =>  ad(28),     
        ad           =>  ad,        
        cben         =>  cben,        
        par          =>  par,         
        par64        =>  par64,       
        req64n       =>  req64n,      
        framen       =>  framen,      
        irdyn        =>  irdyn,             
        ack64n       =>  ack64n,            
        devseln      =>  devseln,     
        trdyn        =>  trdyn,             
        stopn        =>  stopn,             
        perrn        =>  perrn,       
        serrn        =>  serrn,       
        intan        =>  intan,       
        l_adi        =>  l_adi,       
       
        l_dato       =>  l_dato,      
        l_adro       =>  l_adro,      
        l_beno       =>  l_beno,      
        l_cmdo       =>  l_cmdo,      
        l_ldat_ackn  =>  l_ldat_ackn, 
        l_hdat_ackn  =>  l_hdat_ackn, 
        lt_abortn    =>  lt_abortn,   
        lt_discn     =>  lt_discn,    
        lt_rdyn      =>  lt_rdyn,     
        lt_framen    =>  lt_framen,   
        lt_ackn      =>  lt_ackn,     
        lt_dxfrn     =>  lt_dxfrn,    
        lt_tsr       =>  lt_tsr,            
        lirqn        =>  l_irqn,       
        
        cmd_reg      =>  cmd_reg,     
        stat_reg     =>  stat_reg);
        
        
u2 : top_local
    port map(
    --*******************************************************************
    --Replace this section with your application design
    --*******************************************************************      
      --Clk        => clk,
      --Rstn       => rstn,
      --Pcil_adi_o => l_adi,
      --Pcil_dat_i => l_dato,
      --Pcil_adr_i => l_adro,
      --Pcil_ben_i => l_beno,
      --Pcil_cmd_i => l_cmdo,
      --Pcildat_ack_n_i => l_ldat_ackn,
      --Pcihdat_ack_n_i => l_hdat_ackn,
      --Pcilt_abort_n_o => lt_abortn,
      --Pcilt_disc_n_o => lt_discn,
      --Pcilt_rdy_n_o => lt_rdyn,
      --Pcilt_frame_n_i => lt_framen,
      --Pcilt_ack_n_i => lt_ackn,
      --Pcilt_dxfr_n_i => lt_dxfrn,
      --Pcilt_tsr_i => lt_tsr,
       Pcilirq_n_o => l_irqn
      );

               
u3: arbiter
       port map        
       (clk          =>  clk,         
        rstn         =>  rstn,        
        framen       =>  framen,      
        irdyn        =>  irdyn,             
        trdyn        =>  trdyn,             
        stopn        =>  stopn,
        busfree      =>  busfree,
        devseln      =>  devseln,             
        pci_reqn(1)  =>  mstr_tranx_reqn,
        pci_reqn(0)  =>  '1',
        pci_gntn(1)  =>  mstr_tranx_gntn,
        pci_gntn(0)  =>  gntn);
    

u4: mstr_tranx 
        port map
       (clk          =>  clk,          
        rstn         =>  rstn,         
        ad           =>  ad,          
        cben         =>  cben,         
        par          =>  par,         
        par64        =>  par64,       
        reqn         =>  mstr_tranx_reqn,
        gntn         =>  mstr_tranx_gntn,
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
        
        
u5: trgt_tranx
       port map        
       (clk          =>  clk,         
        rstn         =>  rstn,        
        ad           =>  ad,
        cben         =>  cben,
        idsel        =>  ad(29),
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



u6: monitor
       port map        
     (clk            =>  clk,         
      rstn           =>  rstn,        
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

u7: pull_up
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































