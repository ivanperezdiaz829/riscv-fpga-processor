//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI/Avalon Bridge Lite Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                Penang IP Group Ong Hui Leang
//
//     Description:    PCI Avalon Light PCI side control
//
//     Copyright 2007 Altera Corporation. All rights reserved.  This source code is highly
//     confidential and proprietary information of Altera and is being provided in accordance with
//     and subject to the protections of a Non-Disclosure Agreement which governs its use and
//     disclosure.  Altera products and services are protected under numerous U.S. and foreign
//    patents, maskwork rights, copyrights and other intellectual property laws.  Altera assumes
//     no responsibility or liability arising out of the application or use of this source code.
//
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//clean up note
//1. unused parameters have to be removed after finishing coding
// altera message_off 10230

module altpciav_lite_mpci_cntrl 
#(
    parameter  CG_PCI_TARGET_ONLY = 0,
    parameter  CG_PCI_DATA_WIDTH = 64,
    parameter  CB_P2A_PREF_DISCARD_CYCLES = 2047,
    parameter  CPCICOMP_NUMBER_OF_BARS = 1,
    parameter  CB_P2A_MR_INIT_DWORDS_B0 = 8
  ) 
    
(     
  input                                PciClk_i,
  input                                Rstn_i,
  
  // PCI core interface
  input                                LtFramen_i,
  input                                LtDxfrn_i,
  input                                LdatAckn_i,
  input                                HdatAckn_i,
  input [11:0]                         LtTsr_i,
  input [3:0]                          LtCmd_i,
  input [31:0]                         LtAddr_i,
  input [CG_PCI_DATA_WIDTH-1 : 0]      LtDat_i,  //write data
  input [(CG_PCI_DATA_WIDTH/8)-1 : 0]  LtBen_i,
  output                               LtRdyn_o,
  output                               LtDiscn_o,
  output                               LtAbortn_o,
  output [CG_PCI_DATA_WIDTH-1 : 0]     LtDat_o,  //read data

  // parameter inputs
  input  [31:0]                        cpcicomp_bar0_i,
  input  [31:0]                        cpcicomp_bar1_i,
  input  [31:0]                        cpcicomp_bar2_i,
  input  [31:0]                        cpcicomp_bar3_i,
  input  [31:0]                        cpcicomp_bar4_i,
  input  [31:0]                        cpcicomp_bar5_i,
  input  [31:0]                        cpcicomp_exp_rom_bar_i,
  input  [31:0]                        cb_p2a_avalon_addr_b0_i,
  input  [31:0]                        cb_p2a_avalon_addr_b1_i,
  input  [31:0]                        cb_p2a_avalon_addr_b2_i,
  input  [31:0]                        cb_p2a_avalon_addr_b3_i,
  input  [31:0]                        cb_p2a_avalon_addr_b4_i,
  input  [31:0]                        cb_p2a_avalon_addr_b5_i,
  input  [31:0]                        cb_p2a_avalon_addr_b6_i,
  input  [4:0]                         cb_p2a_nonp_max_init_lat_i,
  // command data 
  input                                avl_rddata_ready_i,
  input [7:0]			       avl_rdfifo_data_avail_i,
  input [CG_PCI_DATA_WIDTH-1:0]        rd_data_i,
  input [CG_PCI_DATA_WIDTH-1:0]        rd_fifo_data_i,
  output 			       rd_fifo_data_req_o,
  output [17:0]                        rwinfo_header_o,
  output [CG_PCI_DATA_WIDTH-1:0]       avl_addr_header_o,
  output [(CG_PCI_DATA_WIDTH/8)-1 : 0] ben_header_o,
  output [CG_PCI_DATA_WIDTH-1:0]       wr_data_o,
  output                               cdreg_wr,
  output                               cdreg_rd,
  output                               avl_rdreq,
  output [2:0]                        BarActive, 
  input                               avl_wr_done_i,
  input                               avl_rd_done_i,
  output                              rdfifo_flush_o,
  output                              pbar_hit_o
);


//local parameters for pci target state machine 
localparam MPCI_IDLE                = 12'h 000;
localparam MPCI_WR_AD_CMD           = 12'h 003;
localparam MPCI_WR_CLMD             = 12'h 005;
localparam MPCI_WR_DXFR             = 12'h 009;
localparam MPCI_WR_DONE             = 12'h 011;
localparam MPCI_RD_AD_CMD           = 12'h 021;
localparam MPCI_RD_WAITDATA         = 12'h 041;
localparam MPCI_RD_DONE             = 12'h 081;
localparam MPCI_DISC                = 12'h 101;
localparam MPCI_WR_WAITAVL          = 12'h 201;
localparam MPCI_RD_PEND             = 12'h 401;
localparam MPCI_RD_DISC             = 12'h 801;

//wire for pci target state machine
wire                                     mpci_idle;         
wire                                     mpci_wr_ad_cmd;        
wire                                     mpci_wr_clmd;       
wire                                     mpci_wr_dxfr;   
wire                                     mpci_wr_done;         
wire                                     mpci_rd_ad_cmd ;    
//wire                                     mpci_rd_waitdata;   
wire                                     mpci_rd_done;  
wire                                     mpci_disc;  
wire                                     mpci_wr_waitavl;  
wire                                     mpci_rd_pend;  
wire                                     mpci_rd_disc;  

//wire for bar hit
wire                                     pbar_hit;
wire                                     npbar_hit;
wire                                     membar_hit;
wire                                     iobar_hit;
//wire for command data
wire [7:0]                               rd_burstcount;
wire [7:0]                               wr_burstcount;
wire                                     rd_flag;
wire                                     wr_flag;

//wire for PCI input signal. eg: edge triggered signal
wire                                     ltframen_assert;
wire                                     ltdxfrn_deassert;

//wire for p2a addrtrans
wire[CG_PCI_DATA_WIDTH-1:0]             avladdr_fr_p2a_addrtrans;
wire 					valid_io_be;
wire [17:0]                        	rwinfo_header;
wire					delayed_rd_matched;

wire [CG_PCI_DATA_WIDTH-1:0]		lt_dat_o;

//reg for pci target state machine
reg [11:0]                               mpci_state;
reg [11:0]                               mpci_nxt_state;

//reg for PCI input signal
reg[CG_PCI_DATA_WIDTH-1:0]               ladro_reg;
reg[CG_PCI_DATA_WIDTH-1:0]               ldato_reg;
reg[(CG_PCI_DATA_WIDTH/8)-1 : 0]         lbeno_reg;
reg                                      ltframen_reg;
reg                                      ltdxfrn_reg;

//reg for command data
reg[7:0]                wr_burstcount_reg;
reg[7:0]                rd_burstcount_reg;

reg                     invalid_ben;
reg			invalid_ben_reg;
reg                     rddata_vld_reg;

reg[CG_PCI_DATA_WIDTH-1:0]               avladdr_fr_p2a_addrtrans_reg;

reg [4:0] 				init_lat_cntr;
reg [31:0]				addr_reg;
reg					delayed_rd_matched_reg;
reg [2:0]                               BarActive_reg;
reg      Npmdisc;
reg      Npmdisc_reg;

assign BarActive = BarActive_reg;

reg wr_rdn;
assign pbar_hit_o = pbar_hit;
// command, address, byte enable, bar hit, and 64-bit transfer indicator
// registers. These information is latched at the begining of each
// PCI access to a non-prefetchable BAR. The latch enable is generated by the
// state machine module

always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      begin
       addr_reg <= 32'h00000000;
      end
    else if(mpci_rd_ad_cmd) // latching
      begin
        //addr_reg <= LtAddr_i[31:2];
        addr_reg <= LtAddr_i;
      end
  end


// initial target latency counter
// this counter is loaded with inital latency parameter mimus some clock
// cycle compensation at the begining of the PCI target cycle to used for
// read time out. The counter is count down to zero and the bus is released.
// Every clock is counted.
// if the parameter is set to 0, the counter will remaim at zero (expired)
// and the retry will happen imediately

always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      init_lat_cntr <= 5'h0;
    else if((mpci_rd_ad_cmd | (mpci_rd_pend & ltframen_assert)) & (cb_p2a_nonp_max_init_lat_i > 0))
      init_lat_cntr <= (cb_p2a_nonp_max_init_lat_i - 4'h8); // latency compensation
    else if(init_lat_cntr > 0)    // stopped countdown at 0
      init_lat_cntr <= init_lat_cntr - 1'b1;
  end

always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
       delayed_rd_matched_reg <= 1'b0;
    else if(delayed_rd_matched) 
        delayed_rd_matched_reg <= delayed_rd_matched;
    else if(mpci_rd_ad_cmd) 
        delayed_rd_matched_reg <= 1'b0;
   else
        delayed_rd_matched_reg <= delayed_rd_matched_reg;

  end

// wr_rdn 
always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
       wr_rdn <= 1'b1;
    else if(ltframen_assert & wr_flag) 
       wr_rdn <= 1'b1;
    else if(ltframen_assert & rd_flag) 
       wr_rdn <= 1'b0;
   else
       wr_rdn <= wr_rdn;

  end


//register PCI signals
always @ (posedge PciClk_i or negedge Rstn_i)
begin
  if (~Rstn_i)
      avladdr_fr_p2a_addrtrans_reg <= 0;
  else if(mpci_wr_clmd | mpci_rd_ad_cmd)
      avladdr_fr_p2a_addrtrans_reg <= avladdr_fr_p2a_addrtrans;
  else
      avladdr_fr_p2a_addrtrans_reg <= avladdr_fr_p2a_addrtrans_reg;
end



//LtFramen_reg
always @ (posedge PciClk_i or negedge Rstn_i)
begin 
  if (~Rstn_i)
      ltframen_reg <= 0;
  else  
      ltframen_reg <= LtFramen_i;
end

//LtDxfrn_reg
always @ (posedge PciClk_i or negedge Rstn_i)
begin 
  if (~Rstn_i)
      ltdxfrn_reg <= 0;
  else  
      ltdxfrn_reg <= LtDxfrn_i;
end

// IO Address Decode
// Checking for IO Space decoding With Read/Write BE support
always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rddata_vld_reg <= 1'b0;
    else
      rddata_vld_reg <= mpci_rd_ad_cmd;
  end

// To avoid combinatorial loop on invalid_ben
always @(posedge PciClk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      invalid_ben_reg <= 1'b0;
    else
      invalid_ben_reg <= invalid_ben;
  end

always @(invalid_ben_reg or valid_io_be or mpci_wr_ad_cmd or LtBen_i or LtAddr_i or LtCmd_i or rddata_vld_reg)
  begin
    if (~invalid_ben_reg)
      invalid_ben = 1'b1;
    else if ((LtCmd_i == 4'h3) & (mpci_wr_ad_cmd) & (~valid_io_be))
      invalid_ben = 1'b0;
    else if ((LtCmd_i == 4'h2) & (rddata_vld_reg == 1'b1) & (~valid_io_be))
      invalid_ben = 1'b0;
    else
      invalid_ben = 1'b1;
  end

//Based on IO Space decoding Specification
assign valid_io_be = (((LtAddr_i[1:0]==2'b00) & (LtBen_i[0:0]==1'b0)) |
                      ((LtAddr_i[1:0]==2'b01) & (LtBen_i[1:0]==2'b01)) |
                      ((LtAddr_i[1:0]==2'b10) & (LtBen_i[2:0]==3'b011)) |
                      ((LtAddr_i[1:0]==2'b11) & (LtBen_i[3:0]==4'b0111)) |
                      (LtBen_i[3:0]==4'b1111));

assign LtAbortn_o = invalid_ben;

// latch the command, address, bar hit from the PCI core
//assign WrCmdAddrLatch_o = pcinp_state[1] | pcinp_state[13];



//wire PCI signals
//1. ltDat_o trigger state ? mpci_rd_done is it correct?
//2. ltRyn_o is complex. Anyway to cut it down?
//3. ltdat_o: how to pull it to high when it is not using. 
assign ltframen_assert = ~LtFramen_i & ltframen_reg;
assign ltdxfrn_deassert= LtDxfrn_i & ~ltdxfrn_reg;
assign LtRdyn_o = ~(( ( mpci_wr_ad_cmd| mpci_wr_clmd| mpci_wr_dxfr) & ~LtFramen_i)|(avl_rddata_ready_i & ~LtFramen_i & ~delayed_rd_matched_reg & ~mpci_rd_pend) |(mpci_rd_done & delayed_rd_matched_reg ));
assign wr_flag = (LtCmd_i == 4'h3) | (LtCmd_i == 4'h7) | (LtCmd_i == 4'hF);
assign rd_flag = (LtCmd_i == 4'h2) | (LtCmd_i == 4'h6) | (LtCmd_i == 4'hC) | (LtCmd_i == 4'hE);
assign LtDiscn_o = ( (mpci_disc & ~LtFramen_i) | (mpci_wr_waitavl & ~LtFramen_i) | mpci_rd_disc | (wr_flag & ltframen_assert & ~mpci_idle) |(rd_flag & ltframen_assert & ~delayed_rd_matched & ~mpci_idle) | (delayed_rd_matched & avl_rdfifo_data_avail_i < 1) | (npbar_hit & Npmdisc & (LtCmd_i== 4'h7))|(mpci_rd_done & npbar_hit))? 1'b0: 1'b1;

assign lt_dat_o  = (delayed_rd_matched_reg)? rd_fifo_data_i: rd_data_i;
assign LtDat_o   = (mpci_rd_done | (mpci_disc) )? lt_dat_o : 32'h0;  


//bar hit
//1. both memory shared the membarhit - might seperate them into two different
//path

// translate into NPM disconnect
always @(posedge PciClk_i or negedge Rstn_i)  
begin
   if (~Rstn_i)
      Npmdisc_reg <= 1'b0;
   else 
      Npmdisc_reg <= ltframen_assert;
end

always @(posedge PciClk_i or negedge Rstn_i)  
begin
   if (~Rstn_i)
      Npmdisc <= 1'b0;
   else 
      Npmdisc <= Npmdisc_reg;
end

assign membar_hit = pbar_hit|npbar_hit|iobar_hit;


assign pbar_hit    =  (LtTsr_i[0] & ~LtTsr_i[1]& cpcicomp_bar0_i[3]) |
                    (LtTsr_i[1] & ~LtTsr_i[0]& cpcicomp_bar1_i[3]) |
                    (LtTsr_i[2] & cpcicomp_bar2_i[3]) |
                    (LtTsr_i[3] & cpcicomp_bar3_i[3]) |
                    (LtTsr_i[4] & cpcicomp_bar4_i[3]) |
                    (LtTsr_i[5] & cpcicomp_bar5_i[3]) |
                    (LtTsr_i[1] & LtTsr_i[0] & cpcicomp_bar0_i[3]);//64-bit BAR

assign npbar_hit = (LtTsr_i[0] & ~LtTsr_i[1] & ~cpcicomp_bar0_i[3]) & ~cpcicomp_bar0_i[0] |
                    (LtTsr_i[1] & ~LtTsr_i[0] & ~cpcicomp_bar1_i[3]) & ~cpcicomp_bar1_i[0] |
                    (LtTsr_i[2] & ~cpcicomp_bar2_i[3]) |
                    (LtTsr_i[3] & ~cpcicomp_bar3_i[3]) |
                    (LtTsr_i[4] & ~cpcicomp_bar4_i[3]) |
                    (LtTsr_i[5] & ~cpcicomp_bar5_i[3]) |
                    (LtTsr_i[6])                       |  // exp rom always NP
                    (LtTsr_i[1] & LtTsr_i[0] & ~cpcicomp_bar0_i[3]);//64-bit BAR

assign iobar_hit = (LtTsr_i[0] & ~LtTsr_i[1]& cpcicomp_bar0_i[0]) |
                    (LtTsr_i[1] & ~LtTsr_i[0]& cpcicomp_bar1_i[0]) |
                    (LtTsr_i[2] & ~cpcicomp_bar2_i[1]) |
                    (LtTsr_i[3] & ~cpcicomp_bar3_i[1]) |
                    (LtTsr_i[4] & ~cpcicomp_bar4_i[1]) |
                    (LtTsr_i[5] & ~cpcicomp_bar5_i[1]) |
                    (LtTsr_i[6])                       |  // exp rom always NP
                    (LtTsr_i[1] & LtTsr_i[0] & ~cpcicomp_bar0_i[1]);//64-bit BAR

always @(posedge PciClk_i or negedge Rstn_i)  
begin
if (~Rstn_i)
   BarActive_reg <= 3'b000;
else if (pbar_hit)
   BarActive_reg <= 3'b001;
else if (npbar_hit)
   BarActive_reg <= 3'b010;
else if (iobar_hit)
   BarActive_reg <= 3'b100;
else
   BarActive_reg <= BarActive;
end


//command data register information gen
//rwinfo_header=R, W, Rd_burst_size, Wr_burst_size
//1. cdreg_wr - need to have a strict signals
assign rwinfo_header_o   = {rd_flag,wr_rdn,rd_burstcount,wr_burstcount};
assign avl_addr_header_o = (mpci_wr_clmd | mpci_wr_dxfr | mpci_wr_done)? avladdr_fr_p2a_addrtrans_reg : avladdr_fr_p2a_addrtrans;
assign ben_header_o      = LtBen_i; //need to know the size of byte enable
assign wr_data_o         = LtDat_i; 
assign cdreg_wr          = (mpci_wr_done |mpci_rd_ad_cmd);
assign cdreg_rd          = mpci_wr_done;
assign avl_rdreq         = mpci_rd_ad_cmd;
assign rdfifo_flush_o       = mpci_disc;
assign rd_fifo_data_req_o       = rd_flag & (mpci_rd_done| ~LtRdyn_o);

assign rd_burstcount = (rd_flag)?((npbar_hit|iobar_hit)?8'h1:CB_P2A_MR_INIT_DWORDS_B0):8'h1; //-> Needs to change to take buffer size from parameter
assign wr_burstcount = (wr_rdn)? wr_burstcount_reg : 8'h1;
assign delayed_rd_matched = ltframen_assert & (LtAddr_i == addr_reg) &
                            (LtCmd_i== 4'h3 | LtCmd_i == 4'h2 | LtCmd_i == 4'h6 | LtCmd_i == 4'hC | LtCmd_i == 4'hE);


//counter for write data
always @(posedge PciClk_i or negedge Rstn_i)  
begin 
  if (~Rstn_i)
      wr_burstcount_reg <= 8'h1;
  else if ( ~LtDxfrn_i & wr_flag)
      wr_burstcount_reg <= wr_burstcount_reg + 8'h1;
  else if (npbar_hit & wr_flag)
      wr_burstcount_reg <= 8'h1 ;
  else if (ltframen_assert & wr_flag & ~mpci_wr_waitavl)
      wr_burstcount_reg <= 8'h0 ;
  else 
      wr_burstcount_reg <= wr_burstcount_reg;
end

//counter for prefetch read
always @(posedge PciClk_i or negedge Rstn_i)
begin
  if (~Rstn_i)
      rd_burstcount_reg <= 8'h1;
  else if (ltframen_assert & rd_flag)
      rd_burstcount_reg <= CB_P2A_MR_INIT_DWORDS_B0 ;
  else if ( ~LtDxfrn_i & rd_flag)
      rd_burstcount_reg <= rd_burstcount_reg - 8'h1;
  else if (avl_rd_done_i)
      rd_burstcount_reg <= 8'h1;
  else
      rd_burstcount_reg <= rd_burstcount_reg;
end


/////////////////////////////////////////////////////////////////////////
////// Main target state machine interfacing to the PCI Megacore     ////
/////////////////////////////////////////////////////////////////////////
// 1. assume target always ready
// 2. assume there is no retried transaction
// 3. may be the read & write trans can share the wr_ad_cmd state. ? blocking:
// thinking if there is delayed hit, then, the rd_ad_cmd phase need to check
// the availability of data and etc.

always @(posedge PciClk_i or negedge Rstn_i)  
  begin
    if(~Rstn_i)
      mpci_state <= MPCI_IDLE;
    else
      mpci_state <= mpci_nxt_state;
  end

always @ (*)
  begin
    case(mpci_state)
      MPCI_IDLE:
              if(ltframen_assert & wr_flag & membar_hit) 
                mpci_nxt_state <= MPCI_WR_AD_CMD;
              else if(ltframen_assert & rd_flag & membar_hit) 
                mpci_nxt_state <= MPCI_RD_AD_CMD;
              else
                mpci_nxt_state <= MPCI_IDLE;

      MPCI_WR_AD_CMD: 
	      if (~LtAbortn_o)
                mpci_nxt_state <= MPCI_IDLE;
              else
                mpci_nxt_state <= MPCI_WR_CLMD;
      
      MPCI_WR_CLMD: 
              if(~LtFramen_i) 
                mpci_nxt_state <= MPCI_WR_DXFR;
              else 
                mpci_nxt_state <= MPCI_WR_CLMD;

      MPCI_WR_DXFR:
              if (ltdxfrn_deassert & ~LtTsr_i[8])
                mpci_nxt_state <= MPCI_WR_DONE;
              else if (npbar_hit)
                mpci_nxt_state <= MPCI_WR_DONE;
              else 
                mpci_nxt_state <= MPCI_WR_DXFR;
      
      MPCI_WR_DONE:
                mpci_nxt_state <= MPCI_WR_WAITAVL;
     
      MPCI_WR_WAITAVL:
	      if (avl_wr_done_i)
                mpci_nxt_state <= MPCI_IDLE;
              else
                mpci_nxt_state <= MPCI_WR_WAITAVL;
     
      MPCI_RD_AD_CMD:
	      if (~LtAbortn_o)
                mpci_nxt_state <= MPCI_IDLE;
              else
                mpci_nxt_state <= MPCI_RD_WAITDATA;

  
      MPCI_RD_WAITDATA:
              if (avl_rddata_ready_i)
                mpci_nxt_state <= MPCI_RD_DONE; 
              else if (init_lat_cntr ==0)
                mpci_nxt_state <= MPCI_RD_DISC; 
              else 
                mpci_nxt_state <= MPCI_RD_WAITDATA;
      
     MPCI_RD_PEND:
              if(avl_rdfifo_data_avail_i > 4  & delayed_rd_matched)
                mpci_nxt_state <= MPCI_RD_DONE; 
              else if (init_lat_cntr == 8'h1)
                mpci_nxt_state <= MPCI_RD_DISC; 
	      else
                mpci_nxt_state <= MPCI_RD_PEND; 

     MPCI_RD_DONE:
       //If read burstcount is 2, we should disconnect
       //for single cycle, disconnect when rd burst is 1
             if((rd_burstcount_reg ==2 | rd_burstcount_reg ==1) & avl_rd_done_i)
                mpci_nxt_state <= MPCI_DISC;
	      else if(npbar_hit)
                mpci_nxt_state <= MPCI_IDLE;
	      else if(avl_rd_done_i)
                mpci_nxt_state <= MPCI_IDLE;
	      else if(~avl_rd_done_i)
                mpci_nxt_state <= MPCI_RD_DONE;
	      else
                mpci_nxt_state <= MPCI_IDLE;

     MPCI_DISC:
                mpci_nxt_state <= MPCI_IDLE;

     MPCI_RD_DISC:
                mpci_nxt_state <= MPCI_RD_PEND;
      default :
              mpci_nxt_state <= MPCI_IDLE;
          
 endcase
end


// state machine output assignments
assign mpci_idle                  = ~mpci_state[0];     
assign mpci_wr_ad_cmd             =  mpci_state[1];
assign mpci_wr_clmd               =  mpci_state[2];
assign mpci_wr_dxfr               =  mpci_state[3];
assign mpci_wr_done               =  mpci_state[4];
assign mpci_rd_ad_cmd             =  mpci_state[5];
assign mpci_rd_done               =  mpci_state[7];
assign mpci_disc                  =  mpci_state[8];
assign mpci_wr_waitavl            =  mpci_state[9];
assign mpci_rd_pend               =  mpci_state[10];
assign mpci_rd_disc               =  mpci_state[11];

/////////////////////////////////////////////////////////////////////////
////// P2A address translation                                       ////
/////////////////////////////////////////////////////////////////////////
altpciav_lite_p2a_addrtrans 
 
   p2a_paddr_trans
 (    .cpcicomp_bar0_i(cpcicomp_bar0_i), 
      .cpcicomp_bar1_i(cpcicomp_bar1_i),
      .cpcicomp_bar2_i(cpcicomp_bar2_i),
      .cpcicomp_bar3_i(cpcicomp_bar3_i),
      .cpcicomp_bar4_i(cpcicomp_bar4_i),
      .cpcicomp_bar5_i(cpcicomp_bar5_i),
      .cpcicomp_exp_rom_bar_i(32'h00000000),
      .cb_p2a_avalon_addr_b0_i(cb_p2a_avalon_addr_b0_i),
      .cb_p2a_avalon_addr_b1_i(cb_p2a_avalon_addr_b1_i),
      .cb_p2a_avalon_addr_b2_i(cb_p2a_avalon_addr_b2_i),
      .cb_p2a_avalon_addr_b3_i(cb_p2a_avalon_addr_b3_i),
      .cb_p2a_avalon_addr_b4_i(cb_p2a_avalon_addr_b4_i),
      .cb_p2a_avalon_addr_b5_i(cb_p2a_avalon_addr_b5_i),
      .cb_p2a_avalon_addr_b6_i(cb_p2a_avalon_addr_b6_i),
      .PCIAddr_i(LtAddr_i),   
      .BarHit_i(LtTsr_i[6:0]),    
      .AvlAddr_o(avladdr_fr_p2a_addrtrans)      
);                    


endmodule
