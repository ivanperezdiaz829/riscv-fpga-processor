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


module altpcieav_hip_interface
  # (
       DMA_WIDTH                 = 256,
       DMA_BE_WIDTH              = 32
    )

(
    input  logic                                     Clk_i,
    input  logic                                     Rstn_i,
    
    output logic                                     RxStReady_o,
    input  logic  [DMA_WIDTH-1:0]                    RxStData_i,
    input  logic  [1:0]                              RxStEmpty_i,
    input  logic                                     RxStSop_i,
    input  logic                                     RxStEop_i,
    input  logic                                     RxStValid_i,
    input  logic  [7:0]                              RxStBarDec1_i,
    
    input  logic                                     TxStReady_i  ,
    output logic   [DMA_WIDTH-1:0]                   TxStData_o   ,
    output logic                                     TxStSop_o    ,
    output logic                                     TxStEop_o    ,                      
    output logic   [1:0]                             TxStEmpty_o  ,
    output logic                                     TxStValid_o  ,
    
          // Rx fifo Interface
    input logic                                      RxFifoRdReq_i,
    output  logic [265:0]                            RxFifoDataq_o,
    output  logic [3:0]                              RxFifoCount_o,
    
    input   logic                                    PreDecodeTagRdReq_i,     
    output  logic [7:0]                              PreDecodeTag_o,         
    output  logic [3:0]                              PreDecodeTagCount_o, 
                                                    
    // Tx fifo Interface                            
    input logic                                      TxFifoWrReq_i,
    input logic [259:0]                              TxFifoData_i,
    output  logic [3:0]                              TxFifoCount_o,
    // Cfg interface
    output  logic  [81:0]                            MsiIntfc_o,
    output  logic  [15:0]                            MsixIntfc_o,
    input   logic  [3:0]                             CfgAddr_i, 
    input   logic  [31:0]                            CfgCtl_i, 
    output  logic  [12:0]                            CfgBusDev_o,
    output  logic  [31:0]                            DevCsr_o,
    output  logic  [31:0]                            PciCmd_o,     
    output  logic  [31:0]                            MsiDataCrl_o
    


);

    logic                                            rx_fifo_wrreq;
    logic  [265:0]                                   rx_fifo_data;
    logic  [265:0]                                   rx_fifo_dataq;       
    logic  [3:0]                                     rx_fifo_count;
    logic                                            tx_fifo_rdreq;
    logic  [3:0]                                     tx_fifo_count;
    logic  [259:0]                                   tx_fifo_dataq;
    logic  [255:0]                                   tx_tlp_out_reg;
    logic                                            tx_sop_out_reg;
    logic                                            tx_eop_out_reg;
    logic  [1:0]                                     tx_empty_out_reg;
    logic                                            output_valid_reg;
    logic                                            fifo_valid_reg;
    logic                                            output_transmit;
    logic                                            fifo_transmit;   
    logic                                            tx_st_ready_reg;     
    logic                                            output_fifo_rdempty;      
    logic  [12:0]                                    cfg_busdev;            
    logic  [31:0]                                    cfg_dev_csr;           
    logic  [15:0]                                    msi_ena;               
    logic  [15:0]                                    msix_control;          
    logic  [15:0]                                    cfg_prmcsr;            
    logic  [63:0]                                    msi_addr;              
    logic  [15:0]                                    msi_data;              
    logic  [63:0]                                    msi_addr_reg;          
    logic  [15:0]                                    msi_data_reg;          
    logic  [15:0]                                    msi_ena_reg;           
    logic  [15:0]                                    msix_control_reg;             
    logic                                            rstn_reg;
   logic                                            rstn_rr; 
   logic                                            rstn_r;       
    logic  [31:0]                                    dev_csr_reg;            /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =D101" */     
    logic  [3:0]                                     cfg_addr_reg;
    logic   [31:0]                                   cfg_data_reg;
    logic  [255:0]                                   rx_input_data_reg;
    logic                                            rx_input_valid_reg;
    logic                                            rx_input_sop_reg;
    logic                                            rx_input_eop_reg;
    logic  [1:0]                                     rx_input_empty_reg;
    logic  [5:0]                                     rx_input_bardesc_reg;

    logic  [255:0]                                   rx_input_data_reg2;
    logic                                            rx_input_valid_reg2;
    logic                                            rx_input_sop_reg2;
    logic                                            rx_input_eop_reg2;
    logic  [1:0]                                     rx_input_empty_reg2;
    logic  [5:0]                                     rx_input_bardesc_reg2;    
    
    logic  [7:0]                                     cpl_tag;
    logic                                            is_cpl_wd;
    logic                                            valid_dma_rd_cpl;
    logic                                            tag_predecode_fifo_wrreq;
   
/// Rx input FIFO

altpcie_fifo 
   #(
    .FIFO_DEPTH(10),    
    .DATA_WIDTH(266)   
    )
 rx_input_fifo   
(
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(1'b0),      
      .wrreq(rx_fifo_wrreq),     
      .rdreq(RxFifoRdReq_i),     
      .data(rx_fifo_data),      
      .q(rx_fifo_dataq),         
      .fifo_count(rx_fifo_count) 
);


/// Tag predecode fifo used to look ahead tag array for fmax
assign cpl_tag       = rx_input_data_reg[79:72];
assign is_cpl_wd     = rx_input_data_reg[30] & (rx_input_data_reg[28:24]==5'b01010) & rx_input_sop_reg;
assign valid_dma_rd_cpl = is_cpl_wd & cpl_tag <= 15;
assign tag_predecode_fifo_wrreq = valid_dma_rd_cpl & rx_input_valid_reg;

altpcie_fifo 
   #(
    .FIFO_DEPTH(16),    
    .DATA_WIDTH(8)   
    )
 predecode_tag_fifo   
(
      .clk(Clk_i),       
      .rstn(Rstn_i),      
      .srst(1'b0),      
      .wrreq(tag_predecode_fifo_wrreq),     
      .rdreq(PreDecodeTagRdReq_i),     
      .data(cpl_tag),      
      .q(PreDecodeTag_o),         
      .fifo_count(PreDecodeTagCount_o) 
);
/// Tx output FIFO

	scfifo	tx_output_fifo (
				.rdreq (tx_fifo_rdreq),
				.clock (Clk_i),
				.wrreq (TxFifoWrReq_i),
				.data (TxFifoData_i),
				.usedw (tx_fifo_count),
				.empty (output_fifo_rdempty),
				.q (tx_fifo_dataq),
				.full (),
				.aclr (~Rstn_i),
				.almost_empty (),
				.almost_full (),
				.sclr ()
				);
	defparam
		tx_output_fifo.add_ram_output_register = "ON",
		tx_output_fifo.intended_device_family = "Stratix V",
		tx_output_fifo.lpm_numwords = 16,
		tx_output_fifo.lpm_showahead = "OFF",
		tx_output_fifo.lpm_type = "scfifo",
		tx_output_fifo.lpm_width = 260,
		tx_output_fifo.lpm_widthu = 4,
		tx_output_fifo.overflow_checking = "ON",
		tx_output_fifo.underflow_checking = "ON",
		tx_output_fifo.use_eab = "ON";


// Rx fifo Interface
assign rx_fifo_data[265:0] = {rx_input_bardesc_reg2[5:0], rx_input_empty_reg2,rx_input_eop_reg2, rx_input_sop_reg2, rx_input_data_reg2};
assign rx_fifo_wrreq = rx_input_valid_reg2;
assign RxStReady_o = (rx_fifo_count <= 5 );

always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
       begin
         cfg_addr_reg <= 4'h0;
         cfg_data_reg <= 32'h0;
         rx_input_data_reg <= 256'h0;
         rx_input_valid_reg <= 1'b0;
         rx_input_sop_reg <= 1'b0;
         rx_input_eop_reg <= 1'b0;
         rx_input_empty_reg <= 2'b00;
         rx_input_bardesc_reg <= 6'h0;
         
         rx_input_data_reg2 <= 256'h0;
         rx_input_valid_reg2 <= 1'b0;
         rx_input_sop_reg2 <= 1'b0;
         rx_input_eop_reg2 <= 1'b0;
         rx_input_empty_reg2 <= 2'b00;
         rx_input_bardesc_reg2 <= 6'h0;
         
       end
     else
       begin
         cfg_addr_reg <= CfgAddr_i[3:0];
         cfg_data_reg <= CfgCtl_i[31:0];
         rx_input_data_reg <= RxStData_i;
         rx_input_valid_reg <= RxStValid_i;
         rx_input_sop_reg <= RxStSop_i;
         rx_input_eop_reg <= RxStEop_i;
         rx_input_empty_reg <= RxStEmpty_i;
         rx_input_bardesc_reg <= RxStBarDec1_i;
         rx_input_data_reg2 <= rx_input_data_reg;
         rx_input_valid_reg2 <= rx_input_valid_reg;
         rx_input_sop_reg2 <= rx_input_sop_reg;
         rx_input_eop_reg2 <= rx_input_eop_reg;
         rx_input_empty_reg2 <= rx_input_empty_reg;
         rx_input_bardesc_reg2 <= rx_input_bardesc_reg;
      end
end


// Tx fifo interface
always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
       tx_tlp_out_reg <= 256'h0;
     else if(fifo_transmit)
       tx_tlp_out_reg <= tx_fifo_dataq[255:0];
  end

always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
      begin
       tx_sop_out_reg <= 1'b0;
       tx_eop_out_reg <= 1'b0; 
       tx_empty_out_reg <= 1'b0;
      end
     else if(fifo_transmit)
      begin
       tx_sop_out_reg <= tx_fifo_dataq[256];
       tx_eop_out_reg <= tx_fifo_dataq[257];
       tx_empty_out_reg <= tx_fifo_dataq[259:258];
      end
     else if(output_transmit)
      begin
       tx_sop_out_reg <= 1'b0;
       tx_eop_out_reg <= 1'b0;
       tx_empty_out_reg <= 2'b00;
      end
  end
  
always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
       output_valid_reg <= 1'b0;
     else if(fifo_transmit)
       output_valid_reg <= 1'b1;
     else if (output_transmit)
       output_valid_reg <= 1'b0;
  end
  
always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
       fifo_valid_reg <= 1'b0;
     else if(tx_fifo_rdreq)
       fifo_valid_reg <= 1'b1;
     else if (fifo_transmit)
       fifo_valid_reg <= 1'b0;
  end
  
always @ (posedge Clk_i or negedge Rstn_i)
  begin
     if (~Rstn_i)
       tx_st_ready_reg <= 1'b0;
     else
       tx_st_ready_reg <= TxStReady_i;
  end
  
  
assign output_transmit = output_valid_reg & tx_st_ready_reg;
assign fifo_transmit   = fifo_valid_reg & (~output_valid_reg | output_valid_reg & output_transmit);
assign tx_fifo_rdreq = ~output_fifo_rdempty & (~fifo_valid_reg | fifo_valid_reg & fifo_transmit);

assign TxStData_o =tx_tlp_out_reg;
assign TxStSop_o  = tx_sop_out_reg;
assign TxStEop_o  = tx_eop_out_reg; 
assign TxStEmpty_o[1:0] = tx_empty_out_reg[1:0];
assign TxStValid_o = output_transmit;

assign RxFifoCount_o = rx_fifo_count;

assign TxFifoCount_o = tx_fifo_count;


/// Config CTL
    //Configuration Demux logic 
    
 always @(posedge Clk_i or negedge Rstn_i)
  begin
  	if(~Rstn_i)
  	  begin
        rstn_r <= 1'b0; 
        rstn_rr <= 1'b0;
       end
    else
       begin
       	  rstn_r <= 1'b1;
          rstn_rr <= rstn_r;
       end
  end
 
 assign rstn_reg = rstn_rr;
    
    always @(posedge Clk_i or negedge rstn_reg) 
     begin
        if (rstn_reg == 0)
          begin
            cfg_busdev  <= 13'h0;
            cfg_dev_csr <= 32'h0;
            msi_ena     <= 16'b0;
            msix_control <= 16'h0;
            msi_data    <= 16'h0;
            msi_addr    <= 64'h0;
            cfg_prmcsr  <= 16'h0;
          end
        else 
          begin
            cfg_busdev          <= (cfg_addr_reg[3:0]==4'hF) ? cfg_data_reg[12 : 0]  : cfg_busdev;
            cfg_dev_csr         <= (cfg_addr_reg[3:0]==4'h0) ? {16'h0, cfg_data_reg[31 : 16]}  : cfg_dev_csr;
            msi_ena             <= (cfg_addr_reg[3:0]==4'hD) ? cfg_data_reg[15:0]   :  msi_ena;
            msix_control        <= (cfg_addr_reg[3:0] == 4'hD) ? cfg_data_reg[31:16]  :  msix_control; 
            cfg_prmcsr          <= (cfg_addr_reg[3:0]==4'h3) ? cfg_data_reg[23:8]   :  cfg_prmcsr;
            msi_addr[11:0]      <= (cfg_addr_reg[3:0]==4'h5) ? cfg_data_reg[31:20]  :  msi_addr[11:0];
            msi_addr[31:12]     <= (cfg_addr_reg[3:0]==4'h9) ? cfg_data_reg[31:12]  :  msi_addr[31:12];
            msi_addr[43:32]     <= (cfg_addr_reg[3:0]==4'h6) ? cfg_data_reg[31:20]  :  msi_addr[43:32];
            msi_addr[63:44]     <= (cfg_addr_reg[3:0]==4'hB) ? cfg_data_reg[31:12]  :  msi_addr[63:44];
            msi_data[15:0]      <= (cfg_addr_reg[3:0]==4'hF) ? cfg_data_reg[31:16]  :  msi_data[15:0];
          end
     end 
     
always @(posedge Clk_i or negedge rstn_reg)
  begin
    if(~rstn_reg)
     begin
      dev_csr_reg[31:0] <= 32'h0;
      msi_data_reg      <= 16'h0;
      msi_ena_reg       <= 16'h0;
      msix_control_reg  <= 16'h0;
      msi_addr_reg      <= 64'h0;
     end
    else
     begin
      dev_csr_reg[31:0] <= cfg_dev_csr;
      msi_data_reg      <= msi_data;
      msi_addr_reg      <= msi_addr;
      msi_ena_reg       <= msi_ena;   
      msix_control_reg  <= msix_control; 
     end
 end

assign MsiIntfc_o[63:0]  = msi_addr_reg;
assign MsiIntfc_o[79:64] = msi_data_reg;
assign MsiIntfc_o[80]    = msi_ena_reg[0];
assign MsiIntfc_o[81]    = cfg_prmcsr[2];  // Master Enable
assign MsixIntfc_o[15:0] = msix_control_reg;                 
assign CfgBusDev_o[12:0] = cfg_busdev;   
assign DevCsr_o[31:0]    = cfg_dev_csr;

assign RxFifoDataq_o = rx_fifo_dataq;       

assign PciCmd_o = {16'h0, cfg_prmcsr};
assign MsiDataCrl_o = {msi_data_reg, msi_ena_reg};

endmodule