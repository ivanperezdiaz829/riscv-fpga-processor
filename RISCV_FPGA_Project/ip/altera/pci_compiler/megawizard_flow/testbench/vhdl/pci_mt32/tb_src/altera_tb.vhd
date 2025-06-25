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
        
        --arbitration
        reqn            : out std_logic;                                                              
        gntn            : in std_logic;                                
        
        --address/data
        ad              : inout std_logic_vector(31 downto 0);           
        cben            : inout std_logic_vector(3 downto 0);          
        par             : inout std_logic;                              
        
        --control
        framen          : inout std_logic;                           
        irdyn           : inout std_logic;                            
        devseln         : inout std_logic;                          
        trdyn           : inout std_logic;                            
        stopn           : inout std_logic;                            
        
        --parity error
        perrn           : inout std_logic;                            
        serrn           : out std_logic;                              
        
        --interrupt
        intan           : out std_logic;                              
        
        --local singals
        --address/data
        l_adi           : in std_logic_vector(31 downto 0);           
        l_cbeni         : in std_logic_vector(3 downto 0);          
        
        l_dato          : out std_logic_vector(31 downto 0);         
        l_adro          : out std_logic_vector(31 downto 0);         
        l_beno          : out std_logic_vector(3 downto 0);          
        l_cmdo          : out std_logic_vector(3 downto 0);          
        
        
        --master control
        lm_req32n       : in std_logic;                           
        lm_lastn        : in std_logic;                            
        lm_rdyn         : in std_logic;                             
        
        lm_adr_ackn     : out std_logic;                        
        lm_ackn         : out std_logic;                            
        lm_dxfrn        : out std_logic;                           
        lm_tsr          : out std_logic_vector(9 downto 0);          
        
        
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
        cache           : out std_logic_vector(7 downto 0);           
        cmd_reg         : out std_logic_vector(6 downto 0);         
        stat_reg        : out std_logic_vector(6 downto 0));
        
        
end component;                                                                                                   
                                                                                                                 

--local side reference design
component top_local is
  port (
    --*************************************************************
    --Replace this section with your application design
    --*************************************************************
    --Clk                  : in std_logic;
    --Pcilmdr_ack_n_i     : in std_logic;
    --Pcil_adr_i           : in std_logic_vector (31 downto 0);
    --Pcil_ben_i           : in std_logic_vector (3 downto 0);
    --Pcil_cmd_i           : in std_logic_vector (3 downto 0);
    --Pcil_dat_i           : in std_logic_vector (31 downto 0);
    --Pcilm_ack_n_i        : in std_logic;
    --Pcilm_dxfr_n_i       : in std_logic;
    --Pcilm_tsr_i          : in std_logic_vector (9 downto 0);
    --Pcilt_ack_n_i        : in std_logic;
    --Pcilt_dxfr_n_i       : in std_logic;
    --Pcilt_frame_n_i      : in std_logic;
    --Pcilt_tsr_i          : in std_logic_vector (11 downto 0);
    --Rstn                 : in std_logic;
    --Pcil_adi_o           : out std_logic_vector (31 downto 0);
    --Pcil_cben_o          : out std_logic_vector (3 downto 0);
    --Pcilirq_n_o          : out std_logic;
    --Pcilm_last_n_o       : out std_logic;
    --Pcilm_rdy_n_o        : out std_logic;
    --Pcilm_req32_n_o      : out std_logic;
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
          
          busfree       : in std_logic;
             
          pci_reqn      : in std_logic_vector(1 downto 0);   
          pci_gntn      : out std_logic_vector(1 downto 0));   
end component;



component mstr_tranx 
      port(
          clk           : in std_logic;                                 
          rstn          : out std_logic;                                
  
  --address/data
          ad            : inout std_logic_vector(31 downto 0);           
          cben          : inout std_logic_vector(3 downto 0);          
          par           : inout std_logic;                              
       
  
  --control
          reqn          : out std_logic;
          gntn          : in std_logic;
          framen        : out  std_logic;                           
          irdyn         : out  std_logic;                            
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
          ad            : inout std_logic_vector(31 downto 0);           
          cben          : in    std_logic_vector(3 downto 0);          
          par           : inout std_logic;                              
         
  
  --control
          idsel         : in std_logic;
          framen        : in  std_logic;                           
          irdyn         : in  std_logic;                            
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
          ad           : in std_logic_vector(31 downto 0);           
          cben         : in std_logic_vector(3 downto 0);          
          framen       : in std_logic;                           
          irdyn        : in std_logic;                            
          devseln      : in std_logic;                          
          trdyn        : in std_logic;                            
          stopn        : in std_logic;
          busfree      : out std_logic;
      disengage_mstr   : out std_logic;
      tranx_success    : out std_logic);                            
end component;
 
 component pull_up
    port( ad           : out std_logic_vector(31 downto 0);
          cben         : out std_logic_vector(3 downto 0);
          par          : out std_logic;
          framen       : out std_logic;                           
          irdyn        : out std_logic;                            
          devseln      : out std_logic;                          
          trdyn        : out std_logic;                            
          stopn        : out std_logic;
          perrn        : out std_logic;
          serrn        : out std_logic;
          intan        : out std_logic);                            
end component;
 
   
    signal clk          : std_logic;                                 
    signal rstn         : std_logic;                                    
    
   
   
    signal ad           : std_logic_vector (31 downto 0);
    signal cben         : std_logic_vector (3 downto 0);
   
    
    signal framen       : std_logic;
    signal irdyn        : std_logic;
    
    signal devseln      : std_logic;
    signal trdyn        : std_logic;
    signal stopn        : std_logic;
   
   
   
    --local signals    
    
    signal l_adi        : std_logic_vector(31 downto 0); 
    signal l_cbeni      : std_logic_vector(3 downto 0); 
    
    signal l_dato       : std_logic_vector(31 downto 0);
    signal l_adro       : std_logic_vector(31 downto 0);
    signal l_beno       : std_logic_vector(3 downto 0);
    signal l_cmdo       : std_logic_vector(3 downto 0);
    
    signal lm_req32n    : std_logic;                     
    
    signal lm_lastn     : std_logic;                     
    signal lm_rdyn      : std_logic;                     
    signal lm_adr_ackn  : std_logic;                    
    signal lm_ackn      : std_logic;                    
    signal lm_dxfrn     : std_logic;                    
    signal lm_tsr       : std_logic_vector(9 downto 0); 
           
    signal lt_abortn    : std_logic;                      
    signal lt_discn     : std_logic;                      
    signal lt_rdyn      : std_logic;                      
                                                              
    signal lt_framen    : std_logic;                     
    signal lt_ackn      : std_logic;                     
    signal lt_dxfrn     : std_logic;                     
    signal lt_tsr       : std_logic_vector(11 downto 0); 
    
    signal l_irqn       : std_logic;                             
           
    signal cache        : std_logic_vector(7 downto 0);                     
    signal cmd_reg      : std_logic_vector(6 downto 0);                     
    signal stat_reg     : std_logic_vector(6 downto 0);
 
     
    
    
    signal altr_pci_gntn  : std_logic ;
    signal altr_pci_reqn  : std_logic ;
    signal mstr_tranx_gntn  : std_logic ;
    signal mstr_tranx_reqn  : std_logic ;
    
    
    
    signal perrn : std_logic;
    signal serrn : std_logic;
    signal intan : std_logic;
    
    signal par    : std_logic;     
    
    signal busfree             : std_logic;
    signal disengage_mstr      : std_logic;
    signal tranx_success       : std_logic;
    
    signal trgt_tranx_disca    :std_logic;
    signal trgt_tranx_discb    :std_logic;
    signal trgt_tranx_retry    :std_logic;
    
    

begin
  

u0: clk_gen
        port map        
       (pciclk      =>  clk);         


u1: pci_top
        port map        
       (clk          =>  clk,         
        rstn         =>  rstn,        
        idsel        =>  ad(28),     
        reqn         =>  altr_pci_reqn,      
        gntn         =>  altr_pci_gntn,        
        ad           =>  ad(31 downto 0),        
        cben         =>  cben(3 downto 0),        
        par          =>  par,         
        framen       =>  framen,      
        irdyn        =>  irdyn,             
        devseln      =>  devseln,     
        trdyn        =>  trdyn,             
        stopn        =>  stopn,             
        perrn        =>  perrn,       
        serrn        =>  serrn,       
        intan        =>  intan,       
        l_adi        =>  l_adi,       
        l_cbeni      =>  l_cbeni,     
        l_dato       =>  l_dato,      
        l_adro       =>  l_adro,      
        l_beno       =>  l_beno,      
        l_cmdo       =>  l_cmdo,      
        lm_req32n    =>  lm_req32n,   
        lm_lastn     =>  lm_lastn,    
        lm_rdyn      =>  lm_rdyn,     
        lm_adr_ackn  =>  lm_adr_ackn, 
        lm_ackn      =>  lm_ackn,     
        lm_dxfrn     =>  lm_dxfrn,    
        lm_tsr       =>  lm_tsr,            
        lt_abortn    =>  lt_abortn,   
        lt_discn     =>  lt_discn,    
        lt_rdyn      =>  lt_rdyn,     
        lt_framen    =>  lt_framen,   
        lt_ackn      =>  lt_ackn,     
        lt_dxfrn     =>  lt_dxfrn,    
        lt_tsr       =>  lt_tsr,            
        lirqn        =>  l_irqn,       
        cache        =>  cache,       
        cmd_reg      =>  cmd_reg,     
        stat_reg     =>  stat_reg);
        

 u2 : top_local
    port map(

    --*************************************************************
    --Replace this section with your application design
    --*************************************************************
      --Clk        => clk,
      --Rstn       => rstn,
      --Pcil_adi_o => l_adi,
      --Pcil_cben_o => l_cbeni,
      --Pcil_dat_i => l_dato,
      --Pcil_adr_i => l_adro,
      --Pcil_ben_i => l_beno,
      --Pcil_cmd_i => l_cmdo,
      --Pcilm_req32_n_o => lm_req32n,
      --Pcilm_last_n_o => lm_lastn,
      --Pcilm_rdy_n_o => lm_rdyn,
      --Pcilmdr_ack_n_i => lm_adr_ackn,
      --Pcilm_ack_n_i => lm_ackn,
      --Pcilm_dxfr_n_i => lm_dxfrn,
      --Pcilm_tsr_i => lm_tsr,
      --Pcilt_abort_n_o => lt_abortn,
      --Pcilt_disc_n_o => lt_discn,
      --Pcilt_rdy_n_o => lt_rdyn,
      --Pcilt_frame_n_i => lt_framen,
      --Pcilt_ack_n_i => lt_ackn,
      --Pcilt_dxfr_n_i => lt_dxfrn,
      --Pcilt_tsr_i => lt_tsr,
      --Pcilirq_n_o => l_irqn
      );
        


               
u3: arbiter
       port map        
       (clk          =>  clk,         
        rstn         =>  rstn,        
        busfree      =>  busfree,
        pci_reqn(1)  =>  mstr_tranx_reqn,
        pci_reqn(0)  =>  altr_pci_reqn,
        pci_gntn(1)  =>  mstr_tranx_gntn,
        pci_gntn(0)  =>  altr_pci_gntn);
       

u4: mstr_tranx 
        port map
       (clk          =>  clk,          
        rstn         =>  rstn,         
        ad           =>  ad,          
        cben         =>  cben,         
        par          =>  par,         
        reqn         =>  mstr_tranx_reqn,
        gntn         =>  mstr_tranx_gntn,
        framen       =>  framen,     
        irdyn        =>  irdyn,      
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
        framen       =>  framen,      
        irdyn        =>  irdyn,             
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
      framen         =>  framen,      
      irdyn          =>  irdyn,             
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
      framen         =>  framen,      
      irdyn          =>  irdyn,             
      devseln        =>  devseln,             
      trdyn          =>  trdyn,
      stopn          =>  stopn,
      perrn          =>  perrn,
      serrn          =>  serrn,
      intan          =>  intan);
      
end behavior;































