// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module altpcied_cfbp_128b_control

#(
   parameter AVALON_WDATA        = 128,
   parameter AVALON_WADDR        = 20,  // Claim 1MB of memory space per function 
   parameter CB_RXM_DATA_WIDTH   = 32,
   parameter INTENDED_DEVICE_FAMILY = "Stratix V"
)

  ( 
  
    // clock, reset inputs
    input          Clk_i,
    input          Rstn_i,
    
    // Rx streamming interface to the HIP
  //input          RxStEmpty_i,
    output         RxStMask_o,
    input          RxStSop_i,
    input          RxStEop_i,
    input [AVALON_WDATA-1:0]   RxStData_i,
    input          RxStValid_i,
    output         RxStReady_o,
    
    // Tx streaming interface to the HIP
    input         TxStReady_i,
    output        TxStSop_o,
    output        TxStEop_o,
    output [((INTENDED_DEVICE_FAMILY == "Arria V" || INTENDED_DEVICE_FAMILY == "Cyclone V")?1:2)-1:0]        TxStEmpty_o,
    output [AVALON_WDATA-1:0] TxStData_o,
    output        TxStValid_o,

   // Avalon Rx Master interface 
   output                                 RxmWrite_0_o,  
   output [AVALON_WADDR-1:0]              RxmAddress_0_o,
   output [CB_RXM_DATA_WIDTH-1:0]         RxmWriteData_0_o,
   output [3:0]                           RxmByteEnable_0_o,
   input                                  RxmWaitRequest_0_i,
   output                                 RxmRead_0_o,
   input  [CB_RXM_DATA_WIDTH-1:0]         RxmReadData_0_i,          // this comes from Avalon Slave to be routed to Tx completion
   input                                  RxmReadDataValid_0_i,     // this comes from Avalon Slave to be routed to Tx completion
   output                                 RxmFunc1Sel_o,            // Select function 1  

    // Config interface
    output [31:0]                         cfg_addr_o,
    output [31:0]                         cfg_wrdata_o,
    output [ 3:0]                         cfg_be_o,
    output                                cfg_rden_o,
    output                                cfg_wren_o,
    input                                 cfg_waitrequest_i,
    output                                cfg_writeresponserequest_o,
    input                                 cfg_writeresponsevalid_i,
    input  [ 2:0]                         cfg_writeresponse_i,
    input                                 cfg_rddatavalid_i,
    input  [31:0]                         cfg_rddata_i,
    input  [ 2:0]                         cfg_readresponse_i,


    //=====================
    // cfg_ctl definition 
    // [13]   = mem_en;
    // [12:0] = {bus, dev} 
    input                           f0_mem_en,
    input                           f1_mem_en,
    input  [31 : AVALON_WADDR]      f0_bar0_msb,
    input  [31 : 0]                 f0_bar1,
    input  [31 : AVALON_WADDR]      f1_bar0_msb,
    input  [31 : 0]                 f1_bar1,
    input  [12:0]                   ep_bus_dev // Bus and device number are common for all function 
  );
  
  
  //state machine encoding
  localparam RX_IDLE              = 13'h0000;   
  localparam RX_RD_HEADER1        = 13'h0003;
  localparam RX_LATCH_HEADER1     = 13'h0005;
  localparam RX_CFG_PENDING       = 13'h0009;
  //localparam RX_LATCH_HEADER2     = 13'h0011;
  localparam RX_CHECK_HEADER      = 13'h0021;
  localparam RX_RD_DATA           = 13'h0041;
  localparam RX_LATCH_DATA        = 13'h0081; 
  localparam RX_PENDING           = 13'h0101;
  localparam RX_CPL_REQ           = 13'h0201;
  localparam RX_CLEAR_BUF         = 13'h0401;
  localparam RX_WAIT_EOP          = 13'h0801;
  localparam RX_NXT_VALID1        = 13'h1001;

  // Avalon_MM states
  localparam RXAVL_IDLE       = 4'h0;  
  localparam RXAVL_WRITE      = 4'h3; 
  localparam RXAVL_READ       = 4'h5;
  localparam RXAVL_WRITE_DONE = 4'h9;
  
  // CFG States
  localparam RXCFG_IDLE             = 5'h0;  
  localparam RXCFG_WRITE            = 5'h3; 
  localparam RXCFG_WRITE_RESPONSE   = 5'h9;
  localparam RXCFG_READ             = 5'h5;
  localparam RXCFG_WRITE_DONE       = 5'h11;
  
  // HIP TX
  localparam TX_IDLE          = 4'h0;   
  localparam TX_SOP           = 4'h3;
  localparam TX_SOP_EOP       = 4'h5;
  localparam TX_EOP           = 4'h9;
  
  // Completion Status
  localparam SC               = 3'h0;
  localparam UR               = 3'h1;
  localparam CA               = 3'h4;

 wire             is_cfg0, is_cfg1;
 wire             is_cfgwr0, is_cfgrd0;
 wire             is_read;
 wire             is_write;
 wire             is_flush;
 wire             is_msg;
 wire             is_msg_wd;
 wire             is_msg_wod;
 wire  [3:0]      rx_fbe;
 wire  [3:0]      rx_lbe;
 wire  [9:0]      rx_dwlen;
 wire  [9:0]      rx_dwlen_raw;
 wire             rx_3dw_header;
 wire  [31:0]     rx_addr;
 wire             cpl_with_data;
 wire             is_valid_read;
 wire             is_valid_cfgrd0;
 wire             is_valid_cfgwr0;
 wire             is_write_32;
 wire             addr_bit2;
 wire             is_valid_write;
 wire             is_flush_wr32;
 wire              is_flush_wr64;
wire              rx_check_header;
 
 reg  [63:0]       rx_header1_reg;
 reg  [63:0]       rx_header2_reg;
 reg               rx_bar_hit_reg;
 reg               f1_hit_reg;
 reg  [31:0]       rx_writedata_reg;
 reg  [12:0]        rx_state;
 reg   [12:0]       rx_nxt_state;
 reg               rx_pending_reg;
 
 reg  [3:0]        rxavl_state;
 reg  [3:0]        rxavl_nxt_state;
 
 reg  [4:0]        rxcfg_state;
 reg  [4:0]        rxcfg_nxt_state;

 reg [31:0]       read_data_reg;
 reg [11:0]       normal_byte_count;
 reg [11:0]       abort_byte_count;
 reg [6:0]        lower_addr;
 wire [63:0]      tx_st_header1;
 wire [63:0]      tx_st_header2;
 wire [63:0]      tx_st_data;
 reg              cpl_data_available;
 
 reg [3:0]        tx_state;
 reg [3:0]        tx_nxt_state;
 
 wire [127:0]     cpl_header;
 
 wire [2:0]       cpl_tc;
 wire [1:0]       cpl_attr;
 wire [9:0]       dw_len;
 wire [11:0]      remain_bytes;
 wire [15:0]      cpl_req_id;
 wire [7:0]       cpl_req_tag;
 wire             latch_rx_header1;
 wire             rx_nxt_valid;
 wire             ld_header;
 reg              ld_header_reg;
 wire             rxcfg_pndg;
 reg              rxcfg_pndg_reg;
 wire             rxcfg_req;
 wire             rx_get_header1;
 wire             adjusted_amount_dec_dw;
 wire             adjusted_amount_inc_dw;
reg  [10:0]       adjusted_data_dw_reg;
 wire [9:0]       adjusted_data_qw;
 wire [8:0]       adjusted_data_2qw;
 reg  [8:0]       rx_2qword_counter;
 wire             addr_bit2_reg;
 wire             rx_idle;
 wire             rx_get_write_data;
 wire             rx_latch_write_data;
 wire             rx_pndg;
 wire             tx_cpl_req;
 wire             clear_rxbuff;
 wire             rxavl_req;
 wire             tx_idle_st;            
 wire [31:0]      pcie_addr;
reg   [3:0]       header_poll_counter;
wire [11:0]       rx_byte_len;
wire              rxm_wait_request;   
wire  [31:0]      avl_addr;
reg   [31:0]      avl_addr_reg;
wire              wrena;
wire              rdena;
wire              rxm_read_data_valid;
wire  [31:0]      rxm_read_data;

wire              cfg_wrena;
wire              cfg_rdena;
wire              cfg_wait_request;
wire              cfg_wr_done;


wire          rxm_read_data_valid_0;
wire          rxm_wait_request_0;
wire  [31:0]  rxm_read_data_0;

wire   [ 7:0]  rx_busno_reg; 
wire   [ 4:0]  rx_devno_reg; 
wire   [ 2:0]  rx_funcno_reg; 
wire   [ 2:0]  avm_cpl_status;
reg    [ 2:0]  cfg_cpl_status;
wire   [ 2:0]  cpl_status;
wire   [ 2:0]  cpl_funcno;
wire           is_rx_mem, is_rx_cfg0, is_rx_4dw_hdr;
wire           is_bar0_hit;
wire           is_bar1_hit;
reg            rx_eop_d1;
wire  [63:AVALON_WADDR] addr_64b_msb;
wire  [31:AVALON_WADDR] addr_32b_msb;


  // decode the Rx header from raw rxdata to extract various information 
  assign is_rx_mem     = (rx_header1_reg[28:24]== 5'b00000);
  assign is_rx_cfg0    = (rx_header1_reg[28:24]== 5'b00100);
  assign is_rx_4dw_hdr =  RxStData_i[29];
  assign addr_bit2     = is_rx_4dw_hdr ?  RxStData_i[98] : RxStData_i[66];
  assign addr_64b_msb  = {RxStData_i[95:64], RxStData_i[127:(96+AVALON_WADDR)]};
  assign addr_32b_msb  = {RxStData_i[95:(64+AVALON_WADDR)]};
  assign rx_dwlen_raw  = RxStData_i[9:0];

  // decode the Rx header from header register to extract various information to support the state machine
  //
  assign is_cfgrd0     = ~rx_header1_reg[30] & (rx_header1_reg[28:24]== 5'b00100);
  assign is_cfgwr0     =  rx_header1_reg[30] & (rx_header1_reg[28:24]== 5'b00100);
  assign is_cfg0       =  (rx_header1_reg[28:24]== 5'b00100);
  assign is_cfg1       =  (rx_header1_reg[28:24]== 5'b00101);

  assign is_read       = ~rx_header1_reg[30] & (rx_header1_reg[28:24]== 5'b00000);
  assign is_write      = rx_header1_reg[30] & (rx_header1_reg[28:24]==5'b00000);
  assign is_msg        = rx_header1_reg[29:27] == 3'b110;
  assign is_msg_wd     = rx_header1_reg[30] & is_msg;
  assign is_msg_wod    = ~rx_header1_reg[30] & is_msg;
  assign is_flush      = (is_read & rx_lbe == 4'h0 & rx_fbe == 4'h0);   /// read with no byte enable to flush
  assign rx_lbe        = rx_header1_reg[39:36];
  assign rx_fbe        = rx_header1_reg[35:32];
  assign rx_dwlen      = rx_header1_reg[9:0];
  assign rx_byte_len   = {rx_dwlen[9:0], 2'b00}; 
  assign rx_3dw_header = !rx_header1_reg[29];
  assign rx_addr[31:0] = rx_header1_reg[29]? rx_header2_reg[63:32] : rx_header2_reg[31:0];

  assign rx_busno_reg  = rx_header2_reg[31:24];
  assign rx_devno_reg  = rx_header2_reg[23:19];
  assign rx_funcno_reg = rx_header2_reg[18:16];
  
  assign is_valid_read   = is_read & (rx_dwlen == 4'h1);
  assign is_valid_cfgrd0 = is_cfgrd0 & (rx_dwlen == 4'h1) & (rx_funcno_reg < 2);
  assign is_valid_cfgwr0 = is_cfgwr0 & (rx_dwlen == 4'h1) & (rx_funcno_reg < 2);
  assign is_invalid_cfg0 = is_cfg0   & (rx_funcno_reg > 3'h1);
  assign cpl_with_data   = is_valid_read | is_valid_cfgrd0;

  assign is_write_32    = is_write & rx_3dw_header;
  assign is_flush_wr32  = is_valid_write & is_write_32 &  rx_fbe == 4'h0;
  assign is_flush_wr64  = is_valid_write & ~is_write_32 & rx_fbe == 4'h0;
  assign is_valid_write = is_write & (rx_dwlen == 4'h1);
  assign addr_bit2_reg  = rx_3dw_header? rx_header2_reg[2] : rx_header2_reg[34];


// poll counter to look for the first header
always @(posedge Clk_i or negedge Rstn_i) begin 
    if(~Rstn_i)
      header_poll_counter <= 0;
    else if(rx_idle)
      header_poll_counter <= 0;
    else if(rx_state[2])
      header_poll_counter <= header_poll_counter + 1;
end

// Delay rx_eop for one cycle
always @(posedge Clk_i or negedge Rstn_i) begin 
    if(~Rstn_i)
      rx_eop_d1 <= 1'b0;
    else   
      rx_eop_d1 <= RxStEop_i;
end

// Rx Control SM to the HIP ST interface

always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      rx_state <= RX_IDLE;
    else
      rx_state <= rx_nxt_state;
  end
  

always @*
  begin
    case(rx_state)
        
      RX_IDLE :
          rx_nxt_state <= RX_RD_HEADER1;
          
      RX_RD_HEADER1:
         rx_nxt_state <= RX_LATCH_HEADER1;

      RX_LATCH_HEADER1:
        if(RxStValid_i)
           rx_nxt_state <= RX_CHECK_HEADER;
         else if(header_poll_counter == 4'hF)
           rx_nxt_state <= RX_IDLE;
         else
            rx_nxt_state <= RX_LATCH_HEADER1;
           
      RX_CHECK_HEADER:
        if(is_msg_wod | is_flush_wr32 & addr_bit2_reg)
          rx_nxt_state <= RX_IDLE;
        else if(rx_eop_d1 & is_valid_cfgrd0 & (rx_fbe != 4'h0)) 
          rx_nxt_state <= RX_CFG_PENDING;
        else if(rx_eop_d1 & addr_bit2_reg & is_valid_cfgwr0 & (rx_fbe != 4'h0))
          rx_nxt_state <= RX_CFG_PENDING;
        else if(rx_eop_d1 & (is_valid_read & ~is_flush | addr_bit2_reg & is_valid_write) & (rx_fbe != 4'h0))
          rx_nxt_state <= RX_PENDING;
        else if(is_write | is_msg_wd |is_flush_wr32 | is_flush_wr64 | is_valid_cfgwr0)
          rx_nxt_state <= RX_RD_DATA;
        else if(rx_eop_d1 & (!is_valid_read | is_flush) )  // not a valid read or flush
          rx_nxt_state <= RX_CPL_REQ;          // completion without data
        else
          rx_nxt_state <= RX_CHECK_HEADER;
          
     RX_RD_DATA:
         rx_nxt_state <= RX_LATCH_DATA;
     
     RX_LATCH_DATA:
         
       if(RxStValid_i & RxStEop_i & (is_msg_wd & rx_dwlen <= 2 & ~addr_bit2_reg| is_flush_wr32 |is_flush_wr64) )
         rx_nxt_state <= RX_IDLE;
       else if(RxStValid_i & RxStEop_i & is_valid_write)
         rx_nxt_state <= RX_PENDING;
       else if(RxStValid_i & RxStEop_i & is_valid_cfgwr0)
         rx_nxt_state <= RX_CFG_PENDING;
       else if (~is_valid_write & RxStValid_i & RxStEop_i)
         rx_nxt_state <= RX_IDLE;
       else if((~is_valid_write & is_write & RxStValid_i)| (is_msg_wd & rx_dwlen > 2) |(is_msg_wd & rx_dwlen == 2 & addr_bit2_reg) )
         rx_nxt_state <= RX_CLEAR_BUF;
       else
         rx_nxt_state <= RX_LATCH_DATA;
         
     RX_CFG_PENDING:
          if(cfg_wr_done)
            rx_nxt_state <= RX_CPL_REQ; 
          else if(TxStEop_o) 
            rx_nxt_state <= RX_IDLE; 
          else
            rx_nxt_state <= RX_CFG_PENDING;
          
     RX_PENDING:
          if((wrena & ~rxm_wait_request) | TxStEop_o)
           rx_nxt_state <= RX_IDLE; 
          else
            rx_nxt_state <= RX_PENDING;
       
       RX_CPL_REQ:
         if(TxStEop_o)
           rx_nxt_state <= RX_IDLE;
         else
           rx_nxt_state <= RX_CPL_REQ;
          
       RX_CLEAR_BUF:
         if ((rx_2qword_counter == 1) & !(RxStEop_i & RxStValid_i))
            rx_nxt_state <= RX_WAIT_EOP;
         else if ((rx_2qword_counter == 1) & RxStEop_i & RxStValid_i)  
            rx_nxt_state <= RX_NXT_VALID1;
         else
            rx_nxt_state <= RX_CLEAR_BUF;
       RX_WAIT_EOP:
         if(RxStEop_i & RxStValid_i)
          rx_nxt_state <= RX_NXT_VALID1;
         else
           rx_nxt_state <= RX_WAIT_EOP;
        RX_NXT_VALID1: 
          if (RxStSop_i & RxStValid_i)
            rx_nxt_state <= RX_CHECK_HEADER;
          else   
            rx_nxt_state <= RX_IDLE;
       default:
          rx_nxt_state <= RX_IDLE;
          
    endcase
  end


assign rx_idle              = ~rx_state[0]; 
assign rx_get_header1       =  rx_state[1];                 // RX_RD_HEADER1
assign latch_rx_header1     =  rx_state[2] & RxStValid_i;   // RX_LATCH_HEADER1

assign rxcfg_pndg           =  rx_state[3];                 // RX_CFG_PENDING
//assign latch_rx_header2   =  rx_state[4] & RxStValid_i;   // RX_LATCH_HEADER2
assign rx_check_header      =  rx_state[5];                 // RX_CHECK_HEADER
assign rx_get_write_data    =  rx_state[6];                 // RX_RD_DATA
assign rx_latch_write_data  =  rx_state[7] & RxStValid_i;   // RX_LATCH_DATA   
assign rx_pndg              =  rx_state[8];                 // RX_PENDING
assign tx_cpl_req           =  rx_state[9];                 // RX_CPL_REQ
assign clear_rxbuff         =  rx_state[10];                // RX_CLEAR_BUF
assign rx_nxt_valid         =  rx_state[12];                // RX_NXT_VALID1

// latch the header 
assign ld_header            =  latch_rx_header1 | rx_nxt_valid;
assign is_bar0_hit = is_rx_4dw_hdr ? (f0_mem_en & (addr_64b_msb ==  {f0_bar1,f0_bar0_msb})) :
                                     (f0_mem_en & (addr_32b_msb ==   f0_bar0_msb)) ;

assign is_bar1_hit = is_rx_4dw_hdr ? (f1_mem_en & (addr_64b_msb ==  {f1_bar1,f1_bar0_msb})) :
                                     (f1_mem_en & (addr_32b_msb ==   f1_bar0_msb)) ;
                             

always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i) begin
      rx_header1_reg    <= 64'h0;
      rx_header2_reg    <= 64'h0;
      rx_bar_hit_reg    <= 1'b0;
      f1_hit_reg        <= 1'b0;
    end else if(ld_header) begin
      rx_header1_reg    <= RxStData_i[ 63: 0];
      rx_header2_reg    <= RxStData_i[127:64];
      rx_bar_hit_reg    <= is_bar0_hit | is_bar1_hit;
      f1_hit_reg        <= is_bar1_hit;
    end       
end    

// Latch RX write data
    
 always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rx_writedata_reg <= 32'h0;
    else if( ld_header  )
      rx_writedata_reg <= (addr_bit2 & !is_rx_4dw_hdr ) ? RxStData_i[127:96] : 32'h0;
    else if (rx_latch_write_data & addr_bit2_reg)
      rx_writedata_reg <= rx_3dw_header ? RxStData_i[127:96] :  RxStData_i[63:32];
    else if(rx_latch_write_data )
      rx_writedata_reg <= RxStData_i[31:0];
    end
 
always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i) 
       ld_header_reg <= 1'b0;
    else
       ld_header_reg <= ld_header;
  end
    
// logic to keep track the number of data word extracted from the Rx buffer

assign adjusted_amount_dec_dw = (!is_rx_4dw_hdr & addr_bit2); // 3 dw header and the data is not QWORD aligned => decrement by 1 dw, otherwise no adjustment
assign adjusted_amount_inc_dw = ( is_rx_4dw_hdr & addr_bit2); // 4 dw header and the data is not QWORD aligned => increment by 1 dw, otherwise no adjustment   
  
always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i) 
       adjusted_data_dw_reg <= 11'h0;
    else if (ld_header)
       adjusted_data_dw_reg <= rx_dwlen_raw - adjusted_amount_dec_dw + adjusted_amount_inc_dw;
  end
    
assign adjusted_data_qw  = adjusted_data_dw_reg[10:1] +  adjusted_data_dw_reg[0]; // divided by 2 plus the remainder DW
assign adjusted_data_2qw = adjusted_data_dw_reg[10:2] + (|adjusted_data_dw_reg[1:0]); // divided by 4 plus the remainder qw

always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rx_2qword_counter <= 10'h0;
    else if(ld_header_reg)   
      rx_2qword_counter <= adjusted_data_2qw; 
    else if(RxStReady_o)
      rx_2qword_counter <= rx_2qword_counter - 1;
  end   

assign avl_addr = rx_3dw_header ? rx_header2_reg[31:0] : rx_header2_reg[63:32];

always @(posedge Clk_i or negedge Rstn_i) 
  begin
    if(~Rstn_i)
     begin
         avl_addr_reg <= 32'h0;
     end else if (is_cfg0) begin 
         avl_addr_reg <= { rx_busno_reg,   // [31:24]
                           rx_devno_reg,   // [23:19]
                           rx_funcno_reg,  // [18:16]
                           4'b0, // reserved
                           rx_header2_reg[11:0] // [11:0]
                         };  
     end else begin
         avl_addr_reg <=  avl_addr;
    end
  end

 always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rx_pending_reg <= 1'b0;
    else
      rx_pending_reg <= rx_pndg;
  end   
  
// Bar0 Avalon-MM request
 assign RxmWrite_0_o     = wrena & rx_bar_hit_reg;
 assign RxmRead_0_o      = rdena & rx_bar_hit_reg;
 assign RxmAddress_0_o   = {avl_addr_reg[AVALON_WADDR-1:2], 2'h0};
 assign RxmWriteData_0_o = rx_writedata_reg;
    
 assign rxavl_req          = !rx_pending_reg & rx_pndg;

 assign RxmByteEnable_0_o  =  rx_fbe[3:0];
 assign RxmFunc1Sel_o      =  f1_hit_reg;

/// Tie off the inputs when not available

 assign rxm_read_data_valid_0 = RxmReadDataValid_0_i;
 assign rxm_wait_request_0    = RxmWaitRequest_0_i;  
 assign rxm_read_data_0       = RxmReadData_0_i;     

 assign rxm_read_data_valid =  rxm_read_data_valid_0 ;
 assign rxm_wait_request    = rxm_wait_request_0 & rx_bar_hit_reg; 
 assign rxm_read_data       = rxm_read_data_0;

 // Interface to the HIP streaming interface
 assign RxStReady_o =    rx_get_header1 | rx_get_write_data | clear_rxbuff; 
 
///========================================== 
/// Control logic interfacing to AvalonMM
///========================================== 

always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      rxavl_state <= RXAVL_IDLE;
    else
      rxavl_state <= rxavl_nxt_state;
  end


always @(rxavl_state, rxavl_req, is_write, is_read, rxm_wait_request )
  begin
    case(rxavl_state)
      RXAVL_IDLE :
        if(rxavl_req & is_write)
          rxavl_nxt_state <= RXAVL_WRITE;
        else if(rxavl_req & is_read)
          rxavl_nxt_state <= RXAVL_READ; 
        else
          rxavl_nxt_state <= RXAVL_IDLE;
      
      RXAVL_WRITE:
        if(~rxm_wait_request)
          rxavl_nxt_state <= RXAVL_WRITE_DONE;
        else                   
          rxavl_nxt_state <= RXAVL_WRITE;

       RXAVL_READ:
         if(~rxm_wait_request)
           rxavl_nxt_state <= RXAVL_IDLE; 
          else
           rxavl_nxt_state <= RXAVL_READ;
            
       RXAVL_WRITE_DONE:
          rxavl_nxt_state <= RXAVL_IDLE;
        
       default:
          rxavl_nxt_state <= RXAVL_IDLE;
          
    endcase
  end
  
  

assign wrena  = rxavl_state[1]; //RXAVL_WRITE
assign rdena  = rxavl_state[2]; //RXAVL_READ

///========================================== 
/// Control logic interfacing to config space
///========================================== 
assign cfg_wait_request    = cfg_waitrequest_i;                             

 always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      rxcfg_pndg_reg <= 1'b0;
    else
      rxcfg_pndg_reg <= rxcfg_pndg;
  end   
  
 assign rxcfg_req          = !rxcfg_pndg_reg & rxcfg_pndg;

always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      rxcfg_state <= RXCFG_IDLE;
    else
      rxcfg_state <= rxcfg_nxt_state;
  end


always @(*)
  begin
    case(rxcfg_state)
      RXCFG_IDLE :
        if(rxcfg_req & is_valid_cfgwr0)
          rxcfg_nxt_state <= RXCFG_WRITE;
        else if(rxcfg_req & is_valid_cfgrd0)
          rxcfg_nxt_state <= RXCFG_READ; 
        else
          rxcfg_nxt_state <= RXCFG_IDLE;
      
      RXCFG_WRITE:
        if(~cfg_wait_request)
          rxcfg_nxt_state <= RXCFG_WRITE_RESPONSE;
        else                   
          rxcfg_nxt_state <= RXCFG_WRITE;

       RXCFG_READ:
         if(~cfg_wait_request)
           rxcfg_nxt_state <= RXCFG_IDLE; 
          else
           rxcfg_nxt_state <= RXCFG_READ;
            
       RXCFG_WRITE_RESPONSE:
         if (cfg_writeresponsevalid_i) 
          rxcfg_nxt_state <= RXCFG_WRITE_DONE;
         else       
          rxcfg_nxt_state <= RXCFG_WRITE_RESPONSE;

       RXCFG_WRITE_DONE:
          rxcfg_nxt_state <= RXCFG_IDLE;

       default:
          rxcfg_nxt_state <= RXCFG_IDLE;
          
    endcase
  end
  
assign cfg_wrena   = rxcfg_state[1]; // RXCFG_WRITE
assign cfg_rdena   = rxcfg_state[2]; // RXCFG_READ
assign cfg_wr_done = rxcfg_state[4]; // RXCFG_WRITE_DONE 

assign cfg_addr_o      = {avl_addr_reg[31:2], 2'h0}; 
assign cfg_wrdata_o    = rx_writedata_reg;
assign cfg_be_o        = rx_fbe[3:0];
assign cfg_rden_o      = cfg_rdena;
assign cfg_wren_o      = cfg_wrena;
assign cfg_writeresponserequest_o = cfg_wrena; 

//====================
// Tx response logic
//====================

 // Latching the response data

always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      read_data_reg <= 32'h0;
    else if (is_valid_read & rxm_read_data_valid) 
      read_data_reg <= rxm_read_data[31:0];
    else if (is_cfgrd0 & cfg_rddatavalid_i)
      read_data_reg <= cfg_rddata_i;
    end     


// Form an Tx Completion packet

assign cpl_tc = rx_header1_reg[22:20];
assign cpl_attr= rx_header1_reg[13:12];
assign dw_len = tx_cpl_req & ~is_flush? 10'h0 : 10'h1;


always @(rx_fbe)   // only first completion uses the fbe for byte count
 begin
  case(rx_fbe)
    4'b0001 : normal_byte_count = 12'h1;
    4'b0010 : normal_byte_count = 12'h1;
    4'b0100 : normal_byte_count = 12'h1;
    4'b1000 : normal_byte_count = 12'h1;
    4'b0011 : normal_byte_count = 12'h2;
    4'b0110 : normal_byte_count = 12'h2;
    4'b1100 : normal_byte_count = 12'h2;
    4'b0111 : normal_byte_count = 12'h3;
    4'b1110 : normal_byte_count = 12'h3;
    default : normal_byte_count = 12'h4;
  endcase
end


always @*  // only first completion uses the fbe for byte count
 begin
  case({rx_fbe, rx_lbe})
    8'b1000_0001 : abort_byte_count = rx_byte_len - 6;
    8'b1000_0011 : abort_byte_count = rx_byte_len - 5;
    8'b1000_1111 : abort_byte_count = rx_byte_len - 3;
    
    8'b1100_0001 : abort_byte_count = rx_byte_len - 5;
    8'b1100_0011 : abort_byte_count = rx_byte_len - 4;
    8'b1100_1111 : abort_byte_count = rx_byte_len - 2;
    
    8'b1111_0001 : abort_byte_count = rx_byte_len - 3;
    8'b1111_0011 : abort_byte_count = rx_byte_len - 2;
    default :      abort_byte_count = rx_byte_len;
  endcase
end
 
assign remain_bytes = is_flush? 12'h1 : (is_cfg0 | is_cfg1) ? 12'h4 : tx_cpl_req? abort_byte_count: normal_byte_count;  
assign cpl_req_id   = rx_header1_reg[63:48];
assign cpl_req_tag  = rx_header1_reg[47:40];

// calculate the 7 bit lower address of the first enable byte
// based on the first byte enable

always @(rx_fbe, is_flush, rx_addr, is_cfg0)
 begin
  casex({rx_fbe, is_flush, is_cfg0})
    6'bxxx100: lower_addr = {rx_addr[6:2], 2'b00};
    6'bxx1000: lower_addr = {rx_addr[6:2], 2'b01};
    6'bx10000: lower_addr = {rx_addr[6:2], 2'b10};
    6'b100000: lower_addr = {rx_addr[6:2], 2'b11};
    6'bxxxx1x: lower_addr = {rx_addr[6:2], 2'b00};
    6'bxxxx01: lower_addr = 7'b0000000;
    default:   lower_addr = 7'b0000000;
  endcase
end


///////////// Synch and Demux the BusDev from configuration signals
    //Synchronise to pld side 
always @ (posedge Clk_i) begin
   if (is_valid_cfgrd0 & cfg_rddatavalid_i) 
      cfg_cpl_status <= cfg_readresponse_i;
   else if (is_valid_cfgwr0 & cfg_writeresponsevalid_i)
      cfg_cpl_status <= cfg_writeresponse_i;
end

assign  avm_cpl_status = {~is_valid_read,2'b00}; // return CA (3'h4) for invalid mem read
assign  cpl_status =  (is_valid_cfgrd0 | is_valid_cfgwr0) ? cfg_cpl_status : (is_invalid_cfg0 ? UR : avm_cpl_status);
assign  cpl_funcno =   is_invalid_cfg0  ? 3'h0  : (is_cfg0 ? rx_funcno_reg : {2'b00, f1_hit_reg});
assign  cpl_header = {                                            
                          1'b0, cpl_with_data, 6'b001010, 1'b0, cpl_tc, 4'h0, 2'h0, cpl_attr, 2'b00, dw_len, //hdr_dw0[127:96] 
                          ep_bus_dev,cpl_funcno, cpl_status, 1'b0, remain_bytes,                      //hdr_dw1[ 95:64]
                          cpl_req_id, cpl_req_tag, 1'b0,lower_addr,                                   //hdr_dw2[ 63:32]  
                          read_data_reg[31:0]                                                         //data   [ 31:0]
                     }; 
                     
assign tx_st_header1[63:0] = {cpl_header[95:64], cpl_header[127:96]};
assign tx_st_header2[63:0] = {cpl_header[31: 0], cpl_header[63:32]};
assign tx_st_data[63:0]    = {read_data_reg, read_data_reg};

 always @(posedge Clk_i or negedge Rstn_i)
  begin
    if(~Rstn_i)
      cpl_data_available <= 1'b0;
    else if ((is_valid_read & rxm_read_data_valid) | (is_valid_cfgrd0 & cfg_rddatavalid_i))
      cpl_data_available <= 1'b1;
    else if(TxStEop_o)
      cpl_data_available <= 1'b0;
  end
  
/// Control logic interfacing to Tx Streaming

always @(posedge Clk_i or negedge Rstn_i)  // state machine registers
  begin
    if(~Rstn_i)
      tx_state <= TX_IDLE;
    else
      tx_state <= tx_nxt_state;
  end


always @(tx_state, cpl_data_available, tx_cpl_req, TxStReady_i, addr_bit2_reg,
         cpl_with_data, is_valid_cfgrd0)
  begin
    case(tx_state)
      TX_IDLE :
        if( (cpl_data_available | tx_cpl_req )& TxStReady_i) begin
           if ((addr_bit2_reg & !is_valid_cfgrd0) | ~cpl_with_data) // write with data in MSB dued to unaligned address 
               tx_nxt_state <= TX_SOP_EOP;
           else 
               tx_nxt_state <= TX_SOP;
        end else begin 
          tx_nxt_state <= TX_IDLE; 
        end  
      TX_SOP_EOP:
         tx_nxt_state <= TX_IDLE;

      TX_SOP:
         tx_nxt_state <= TX_EOP;
            
       TX_EOP:
         tx_nxt_state <= TX_IDLE;
        
       default:
          tx_nxt_state <= TX_IDLE;
          
    endcase
 end

 assign tx_idle_st = !tx_state[0];
 assign TxStSop_o  =  tx_state[1] | tx_state[2];
 assign TxStEop_o  =  tx_state[3] | tx_state[2];
 assign TxStEmpty_o[1]  =  1'b0;
 assign TxStEmpty_o[0]  =  TxStEop_o & (!addr_bit2_reg | is_cfgrd0) & cpl_with_data ; 
 assign TxStData_o      = (TxStEop_o & (!addr_bit2_reg | is_cfgrd0) & ~tx_cpl_req) ? {tx_st_data[63:0], tx_st_data[63:0]} : {tx_st_header2[63:0], tx_st_header1[63:0]} ;
 assign TxStValid_o     = !tx_idle_st;
 assign RxStMask_o      = 1'b0;
  


endmodule
