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


//===============================================
// The following modules has two goals:
// 1. Provide mailbox register to LMI interface
// 2. Trigger MSI interrupt
// Starting address is at 0x400 
//===============================================

module altpcied_cfbp_mbox

#(
   parameter AVALON_WADDR          = 20,  // Claim 2MB of memory space per function 
   parameter CB_RXM_DATA_WIDTH     = 32,
   parameter VF_COUNT              = 32
)
  ( 
   // clock, reset inputs
   input          Clk_i,
   input          Rstn_i,

   input                                 RxmWrite_0_i,  
   input [AVALON_WADDR-1:0]              RxmAddress_0_i,
   input [CB_RXM_DATA_WIDTH-1:0]         RxmWriteData_0_i,
   input [3:0]                           RxmByteEnable_0_i,
   output                                RxmWaitRequest_0_o,
   input                                 RxmRead_0_i,
   output  [CB_RXM_DATA_WIDTH-1:0]       RxmReadData_0_o,          
   output                                RxmReadDataValid_0_o,     
   input                                 mbox_sel_i,             

   //Mail box registers
   input                                  mem_space_en_pf,  // Memory Space Enable for PF 0
   input                                  bus_master_en_pf, // Bus Master Enable for PF 0
   input [VF_COUNT-1:0]                   mem_space_en_vf,  // Memory Space Enable for VFs (common for all VFs)
   input [VF_COUNT-1:0]                   bus_master_en_vf, // Bus Master Enable for VFs

   // MSI Interrupts
   input                                 app_intx_disable,     // INTX Disable from PCI Command Register of PF 0
   input                                 app_msi_enable_pf,    // MSI Enable setting of PF 0
   input [2:0]                           app_msi_multi_msg_enable_pf,// MSI Multiple Msg field setting of PF 0
   input [VF_COUNT-1:0]                  app_msi_enable_vf,// MSI Enable setting of VFs
   input [VF_COUNT*3-1:0]                app_msi_multi_msg_enable_vf, // MSI Multiple Msg field setting of VFs

   output                 app_msi_req_o,
   input                  app_msi_ack_i,
   output  [7 : 0]        app_msi_req_fn_o,
   output  [4 : 0]        app_msi_num_o,
   output  [2 : 0]        app_msi_tc_o,
  
   // Legacy interrupts
   output                 app_int_sts_a_o,
   output                 app_int_sts_b_o,
   output                 app_int_sts_c_o,
   output                 app_int_sts_d_o,
   output [2:0]           app_int_sts_fn_o, // Function Num associated with the Legacy interrupt request
   output                 app_int_pend_status_o,
   input                  app_int_ack_i,

   // LMI interface
   input                  lmi_ack_i,
   input [31 : 0]         lmi_dout_i, // LMI read data
   output  wire [11 : 0]  lmi_addr_o,
   output  wire [ 8 : 0]  lmi_func_o,  // [7:0] =  Function Number,
                                     // [ 8] = 0 => access to Hard IP register
                                     // [ 8] = 1 => access to SR-IOV bridge config space
   output  wire [31 : 0]  lmi_din_o, // LMI Write data
   output  wire           lmi_rden_o,
   output  wire           lmi_wren_o

  );

  //==========================================
  // Mail Box registes: 
  // The starting byte addr offset = 0x400 
  // Ending address                = 0x7FF;
  //==========================================
  //
  // Memory register dword addresses 
  //
  localparam      LMI_CTL_STATUS_ADDR = 10'h100; // 0x400 Byte addr
  localparam      LMI_RDATA_ADDR      = 10'h101;
  localparam      LMI_WDATA_ADDR      = 10'h102;
  localparam      INT_CTL_STATUS_ADDR = 10'h103; // DW address

// Interrupts state
  localparam IDLE                = 5'h1;  
  localparam MSI_INT             = 5'h2; 
  localparam ASSERT_LEGACY_INT   = 5'h4;
  localparam WAIT4CLR            = 5'h8;
  localparam DEASSERT_LEGACY_INT = 5'h10;
  reg [4:0]  int_st, n_int_st;  // One hot state

  wire            rxm_rden, rxm_wren;
  wire   [CB_RXM_DATA_WIDTH-1:0]   rxm_wdata;  
  wire   [AVALON_WADDR-1:0]   rxm_addr; 
  reg    [31:0]   rxm_rdata_r;
  wire   [ 3:0]   rxm_be;
  reg             rxm_rddatavalid_r;

// Mailbox registers
  wire   [AVALON_WADDR-1 :2]   tgt_dw_addr; // MSB bit is for func1 access: Double the target address size for func1
  reg    [11:0]   lmi_addr;
  reg    [31:0]   lmi_rdata, lmi_wdata;
  reg             int_req, int_req_r, lmi_req, lmi_busy, lmi_cmd, lmi_src;
  wire            lmi_rden, lmi_wren, lmi_start, int_start, clr_legacy_int;
  reg             lmi_req_r;
  reg    [ 7:0]   lmi_func;
  reg    [ 7:0]   int_func;
  reg    [ 4:0]   msi_num;
  //reg    [ 4:0]   msi_data;
  reg    [ 3:0]   int_type; //[0] = INTA, [1]=INTB, [2]=INTC, [3]=INTD
  wire            int_pending;
  reg             inta_req, intb_req, intc_req, intd_req;

  // Interrupt 
  wire       pf_msi_req, vf_msi_req, pf_legacy_int_req, vf_msi_en_mux;

  // LMI

///========================================== 
/// CFG control derived from inputs
///========================================== 
  assign rxm_addr    = RxmAddress_0_i; //byte address
  assign rxm_rden    = RxmRead_0_i  & mbox_sel_i;
  assign rxm_wren    = RxmWrite_0_i & mbox_sel_i;
  assign rxm_wdata   = RxmWriteData_0_i;
  assign rxm_be      = RxmByteEnable_0_i;
  
//========================================
// Matching target address with PF0 BAR0 
//========================================
assign tgt_dw_addr = rxm_addr[AVALON_WADDR-1: 2]; 

//==================================
// LMI Control registers
// [31]   = Start LMI access
// [30]   = LMI_busy
// [29:25]= Reserved
// [24]   = LMI_src: 0 = HIP, 1 = SRIOV bridge
// [23:16]= target function number
// [15:13]= Reserved
// [12]   = lmi_cmd: 0  => read, 1 => Write
// [11:0] = lmi_addr
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       lmi_req <= 1'b0;
    end else if (rxm_wren & (tgt_dw_addr[11:2] == LMI_CTL_STATUS_ADDR)) begin
       if (rxm_be[3] )    lmi_req <= rxm_wdata[31] ;

       lmi_src          <= rxm_be[3] ? rxm_wdata[24]     : lmi_src;
       lmi_func         <= rxm_be[2] ? rxm_wdata[23:16]  : lmi_func[7:0];
       lmi_cmd          <= rxm_be[1] ? rxm_wdata[12]     : lmi_cmd;
       lmi_addr[11:8]   <= rxm_be[1] ? rxm_wdata[11: 8]  : lmi_addr[11:8];
       lmi_addr[7:0]    <= rxm_be[0] ? rxm_wdata[ 7: 0]  : lmi_addr[7:0];
    end else if (lmi_busy)
       lmi_req <= 1'b0;
end

//==================================
// LMI write data
//==================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       lmi_wdata         <= 32'h0;
    end else if (rxm_wren & (tgt_dw_addr[11:2] == LMI_WDATA_ADDR)) begin
       lmi_wdata[31:24]  <= rxm_be[3] ? rxm_wdata[31:24] : lmi_wdata[31:24];
       lmi_wdata[23:16]  <= rxm_be[2] ? rxm_wdata[23:16] : lmi_wdata[23:16];
       lmi_wdata[15: 8]  <= rxm_be[1] ? rxm_wdata[15: 8] : lmi_wdata[15: 8];
       lmi_wdata[ 7: 0]  <= rxm_be[0] ? rxm_wdata[ 7: 0] : lmi_wdata[ 7: 0];
    end
end

//=================================
// Interrupt control and status
//
// [31]    = Start interrupt
// [30]    = Interrupt pending 
// [29]    = clear legacy_int 
// [28:20] = N/A => 9bits
// [19:16] = legacy interrupt type: [16] = intA,[17]=intB,[18]=intC,[19]=INTD
// [15:13] = 3'h0
// [12: 8] = msi_number => Must be <= msi_multiple_msg_cable
// [ 7: 0] = int_func => interrupt function number
//
//=================================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
       int_req        <= 1'b0;
       int_func       <= 8'h0;
    end else if (rxm_wren & (tgt_dw_addr[11:2] == INT_CTL_STATUS_ADDR)) begin
       if (rxm_be[3])    int_req        <= rxm_wdata[31] ;
       int_type       <= rxm_be[2] ? rxm_wdata[19:16]  : int_type;
       msi_num        <= rxm_be[1] ? rxm_wdata[12: 8]  : msi_num;
       int_func       <= rxm_be[0] ? rxm_wdata[ 7: 0]  : int_func;
    end else if (int_pending) begin
       int_req <= 1'b0;
    end    
end

assign clr_legacy_int = rxm_wren & (tgt_dw_addr[11:2] == INT_CTL_STATUS_ADDR) & rxm_wdata[29];

//=========================
// Read data on Avalon-MM bus 
//=========================
always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)   rxm_rddatavalid_r <= 1'b0;
    else          rxm_rddatavalid_r <= rxm_rden; 
end

always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i)            rxm_rdata_r <= 32'b0;
    else if (rxm_rden) begin
         case (tgt_dw_addr[11:2])
            LMI_CTL_STATUS_ADDR: rxm_rdata_r <= { lmi_req, lmi_busy, 5'h0, lmi_src, lmi_func[7:0], 3'h0, lmi_cmd, lmi_addr[11:0]}; //[15:0]
            LMI_WDATA_ADDR:      rxm_rdata_r <= lmi_wdata;
            LMI_RDATA_ADDR:      rxm_rdata_r <= lmi_rdata;
            INT_CTL_STATUS_ADDR: rxm_rdata_r <= {int_req , int_pending, 10'h0, int_type, 2'h0, msi_num[4:0], int_func[7:0]}; 
            default:             rxm_rdata_r <= 32'h0;
         endcase
    end  
end

//=========================
// LMI interface
//=========================

  always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      lmi_req_r <= 1'b0;
    end else begin
      lmi_req_r <= lmi_req;
    end
  end

  assign lmi_start = lmi_req   & !lmi_req_r;
  assign lmi_rden  = lmi_start & !lmi_cmd;
  assign lmi_wren  = lmi_start &  lmi_cmd;

  always @(posedge Clk_i or negedge Rstn_i) begin
    if(~Rstn_i) begin
      lmi_busy <= 1'b0;
    end else if (lmi_ack_i) begin
      lmi_rdata <= lmi_dout_i;
      lmi_busy <= 1'b0;
    end else if (lmi_req) begin
      lmi_busy <= 1'b1;
    end
  end

//=========================
// Generate Interrupt 
//=========================
  always @(posedge Clk_i or negedge Rstn_i) begin // state machine registers
    if(~Rstn_i) int_req_r <= 1'b0;
    else        int_req_r <= int_req;
  end

  assign int_start = int_req & !int_req_r;

  altpcied_sriov_cfg_vf_mux #(VF_COUNT, 1)  vf_msi_sel_i (app_msi_enable_vf, int_func[4:0], vf_msi_en_mux);
  assign pf_msi_req = app_intx_disable & app_msi_enable_pf & (int_func == 8'h0) & int_start;
  assign vf_msi_req = vf_msi_en_mux & int_func[5] & int_start; // VF starts at func = 32
  assign pf_legacy_int_req = !app_intx_disable & (int_func == 8'h0) & int_start;


  always @(posedge Clk_i or negedge Rstn_i) begin // state machine registers
    if(~Rstn_i)
      int_st  <= IDLE;
    else
      int_st   <= n_int_st;
  end

  always @(*) begin
    n_int_st  <= int_st;

    case(int_st)
      IDLE : begin
          if( pf_msi_req) begin
            n_int_st <= MSI_INT;
          end else if ( vf_msi_req ) begin
            n_int_st <= MSI_INT;
          end else if ( pf_legacy_int_req) begin
            n_int_st <= ASSERT_LEGACY_INT;
          end
      end  
      MSI_INT: begin
          if(app_msi_ack_i) begin
            n_int_st <= IDLE;
          end  
      end  
      ASSERT_LEGACY_INT: begin
          if(app_int_ack_i) begin
            n_int_st <= WAIT4CLR;
          end  
      end  
      WAIT4CLR: begin
          if(clr_legacy_int) begin
            n_int_st <= DEASSERT_LEGACY_INT;
          end  
      end  
      DEASSERT_LEGACY_INT: begin
          if(app_int_ack_i) begin
            n_int_st <= IDLE;
          end  
      end

      default:
          n_int_st <= IDLE;
    endcase
  end
      
  wire  idle_st, msi_int_, assert_legacy_int_st;

  assign idle_st                =  int_st[0];
  assign msi_int_st             =  int_st[1];
  assign assert_legacy_int_st   =  int_st[2];
  assign wait4clr_st            =  int_st[3];
  assign deassert_legacy_int_st =  int_st[4];
  assign int_pending          = msi_int_st |assert_legacy_int_st |wait4clr_st | deassert_legacy_int_st;


//  always @(posedge Clk_i or negedge Rstn_i) begin // state machine registers
//    if(~Rstn_i) begin
//      msi_data <= 5'h0;
//    end else if (pf_msi_req & idle_st) begin
//      msi_data <=  (msi_num > {1'b0, app_msi_multi_msg_enable_pf}) ? app_msi_multi_msg_enable_pf : msi_num; 
//    end else if (vf_msi_req) begin
//      msi_data <=  (msi_num > {1'b0, app_msi_multi_msg_enable_vf}) ? app_msi_multi_msg_enable_vf : msi_num; 
//    end
//  end

//======================
// Legacy interrupt req
//======================

  always @(posedge Clk_i or negedge Rstn_i) begin // state machine registers
    if(~Rstn_i) begin
      inta_req  <= 1'b0; 
      intb_req  <= 1'b0; 
      intc_req  <= 1'b0; 
      intd_req  <= 1'b0; 
    end else if (idle_st & pf_legacy_int_req) begin  
      inta_req  <= int_type[0]; 
      intb_req  <= int_type[1]; 
      intc_req  <= int_type[2]; 
      intd_req  <= int_type[3]; 
    end else if (wait4clr_st & clr_legacy_int) begin  
      inta_req  <= 1'b0; 
      intb_req  <= 1'b0; 
      intc_req  <= 1'b0; 
      intd_req  <= 1'b0; 
    end  
  end

//=========================
// Output registers
//=========================
   assign RxmWaitRequest_0_o     = 1'b0;
   assign RxmReadData_0_o        = rxm_rdata_r;          
   assign RxmReadDataValid_0_o   = rxm_rddatavalid_r;     

  // LMI interface
   assign lmi_addr_o             = {lmi_addr[11:2], 2'h0};
   assign lmi_func_o             = {lmi_src, lmi_func} ;
   assign lmi_din_o              = lmi_wdata;
   assign lmi_wren_o             = lmi_wren;
   assign lmi_rden_o             = lmi_rden;

  // MSI
   assign app_msi_req_o          = int_st[1];
   assign app_msi_req_fn_o       = int_func[7:0];
   assign app_msi_num_o          = msi_num[4:0] ;
   assign app_msi_tc_o           = 3'h0;

  // Legacy 
   assign app_int_sts_a_o          = inta_req;
   assign app_int_sts_b_o          = intb_req;
   assign app_int_sts_c_o          = intc_req;
   assign app_int_sts_d_o          = intd_req;
   assign app_int_sts_fn_o         = int_func[2:0];
   assign app_int_pend_status_o    = int_pending;

endmodule
