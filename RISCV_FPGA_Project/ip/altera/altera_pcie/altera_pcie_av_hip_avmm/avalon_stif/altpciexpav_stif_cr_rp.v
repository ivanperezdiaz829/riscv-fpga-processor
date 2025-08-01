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



module altpciexpav_stif_cr_rp
  (
   // All ports on this module are synchronous to CraClk_i
   input             CraClk_i,           // Clock for register access port
   input             CraRstn_i,          // Reset signal  
   // Broadcast Avalon signals
   input [13:2]      IcrAddress_i,       // Address 
   input [31:0]      IcrWriteData_i,     // Write Data 
   input [3:0]       IcrByteEnable_i,    // Byte Enables
   // Modified Avalon signals to/from specific internal modules
   // Local to Pci Mailbox
   input             RpWriteReqVld_i,    // Valid Write Cycle in 
   input             RpReadReqVld_i,     // Read Valid in  
   output reg [31:0] RpReadData_o,       // Read Data out
   output reg        RpReadDataVld_o,    // Read Valid out
   // Mailbox specific Interrupt Request pulses
   output   [7:0]  RpRuptReq_o,        // Interrupt Requests
   
   input             TxRpFifoRdReq_i,
   output    [130:0] TxRpFifoData_o,
   output            RpTLPReady_o,
   input             RxRpFifoWrReq_i,
   input     [130:0] RxRpFifoWrData_i,
   output            RpTxFifoFull_o
         
   ) ;
localparam      RXCPL_IDLE       = 7'h00;  
localparam      RXCPL_RDFIFO     = 7'h03;
localparam      RXCPL_PIPE       = 7'h05;
localparam      RXCPL_LD_REG0    = 7'h09;
localparam      RXCPL_WAIT0      = 7'h11;
localparam      RXCPL_LD_REG1    = 7'h21;
localparam      RXCPL_WAIT1      = 7'h41;
   
   wire [15:0]       cra_address;
   reg [31:0]        tx_data_low_reg;
   reg [31:0]        tx_data_hi_reg;
   reg [31:0]        tx_control_reg;
   
   reg [31:0]        cpl_data_low_reg;
   reg [31:0]        cpl_data_hi_reg;
   reg [31:0]        cpl_control_reg;
   wire              reg0_wrena;
   wire              reg1_wrena;
   reg [6:0]         rxcpl_state;    
   reg [6:0]         rxcpl_nxt_state;
   wire              rxcpl_reg1_rdreq;
   wire              rxcpl_eop;
   wire              rxcpl_sop;
   wire              rxcpl_empty;        
   wire              rxsm_load_first64;
   wire              rxsm_load_second64;                     
   reg  [31:0]       rx_data_hi_reg;
   reg  [31:0]       rx_data_low_reg;
   wire [31:0]       rx_status_reg;
   reg  [7:0]        rx_fifo_usedw_reg;
   wire  [3:0]       rxrp_fifo_usedw;
   wire              rxrp_fifo_empty;
   wire  [130:0]     rxrp_fifo_dataout;
   reg               tx_ctl_wrena_reg;
   wire              tx_ctl_wrena;
   wire  [63:0]      tx_low64_fifo_data_in;
   wire [66:0]       tx_hi64_fifo_data_in;
   wire               tx_rp_sop;
   wire               tx_rp_eop;
   wire               tx_rp_empty;
   reg                low_hi_toggle_reg;
   wire               tx_low64_fifo_rdempty;
   wire  [63:0]       tx_low64_fifo_dataout;
   wire  [66:0]       tx_hi64_fifo_dataout;
   wire               tx_hi64_fifo_rdempty;
   wire  [3:0]        tx_low64_fifo_wrusedw;
   wire  [3:0]        tx_hi64_fifo_wrusedw;
   reg                rx_sop_reg;
   reg                rx_eop_reg;   
   wire               rxcpl_status_read;                   
   wire               rxrp_fifo_rdreq;
   
   
                                          
   assign cra_address[15:0] = {2'b00,IcrAddress_i[13:2], 2'b00}; // convert to byte address
   assign reg0_wrena = ((cra_address == 16'h2000) & RpWriteReqVld_i);    
   assign reg1_wrena = ((cra_address == 16'h2004) & RpWriteReqVld_i);
   assign tx_ctl_wrena = ((cra_address == 16'h2008) & RpWriteReqVld_i);
      
/// Tx Control Registers

   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           tx_data_low_reg <= 32'h0;
        else     
         begin
        if(reg0_wrena & IcrByteEnable_i[0])
           tx_data_low_reg[7:0] <= IcrWriteData_i[7:0];
        if(reg0_wrena & IcrByteEnable_i[1])   
           tx_data_low_reg[15:8] <= IcrWriteData_i[15:8];
        if(reg0_wrena & IcrByteEnable_i[2])  
           tx_data_low_reg[23:16] <= IcrWriteData_i[23:16];
        if(reg0_wrena & IcrByteEnable_i[2])            
           tx_data_low_reg[31:24] <= IcrWriteData_i[31:24]; 
        end
      end
      
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           tx_data_hi_reg <= 32'h0;
        else
          begin
         if(reg1_wrena & IcrByteEnable_i[0])
           tx_data_hi_reg[7:0] <= IcrWriteData_i[7:0];
         if(reg1_wrena & IcrByteEnable_i[1])   
           tx_data_hi_reg[15:8] <= IcrWriteData_i[15:8];
         if(reg1_wrena & IcrByteEnable_i[2])  
           tx_data_hi_reg[23:16] <= IcrWriteData_i[23:16];
         if(reg1_wrena & IcrByteEnable_i[2])            
           tx_data_hi_reg[31:24] <= IcrWriteData_i[31:24]; 
      end
      end    

   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           tx_control_reg <= 32'h0;
        else
          begin 
           if(tx_ctl_wrena & IcrByteEnable_i[0])
              tx_control_reg[7:0] <= IcrWriteData_i[7:0];
           if(tx_ctl_wrena & IcrByteEnable_i[1])   
              tx_control_reg[15:8] <= IcrWriteData_i[15:8];
           if(tx_ctl_wrena & IcrByteEnable_i[2])  
              tx_control_reg[23:16] <= IcrWriteData_i[23:16];
           if(tx_ctl_wrena & IcrByteEnable_i[2])            
             tx_control_reg[31:24] <= IcrWriteData_i[31:24]; 
         end
      end    
      
// Tx FIFO

	scfifo	# (
	       .add_ram_output_register("ON"),
		     .intended_device_family("Stratix V"),
		     .lpm_numwords(16),
		     .lpm_showahead("OFF"),
		     .lpm_type("scfifo"),
		     .lpm_width(64),
		     .lpm_widthu(4),
		     .overflow_checking("ON"),
		     .underflow_checking("ON"),
		     .use_eab("ON")
		  ) 
	          
       txrp_low64_fifo (
                     .rdreq (TxRpFifoRdReq_i),
                     .clock (CraClk_i),
                     .wrreq (tx_low64_fifo_wrreq),
                     .data (tx_low64_fifo_data_in),
                     .usedw (tx_low64_fifo_wrusedw),
                     .empty (tx_low64_fifo_rdempty),
                     .q (tx_low64_fifo_dataout),
                     .full (),
                     .aclr (~CraRstn_i),
                     .almost_empty (),
                     .almost_full (),
                     .sclr ()
);


	scfifo	# (
	       .add_ram_output_register("ON"),
		     .intended_device_family("Stratix V"),
		     .lpm_numwords(16),
		     .lpm_showahead("OFF"),
		     .lpm_type("scfifo"),
		     .lpm_width(67),
		     .lpm_widthu(4),
		     .overflow_checking("ON"),
		     .underflow_checking("ON"),
		     .use_eab("ON")
		  ) 
	          
       txrp_hi64_fifo (
                     .rdreq (TxRpFifoRdReq_i),
                     .clock (CraClk_i),
                     .wrreq (tx_hi64_fifo_wrreq),
                     .data (tx_hi64_fifo_data_in),
                     .usedw (tx_hi64_fifo_wrusedw),
                     .empty (tx_hi64_fifo_rdempty),
                     .q (tx_hi64_fifo_dataout),
                     .full (),
                     .aclr (~CraRstn_i),
                     .almost_empty (),
                     .almost_full (),
                     .sclr ()
);



/// fifo control
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
       if(~CraRstn_i)
     	   tx_ctl_wrena_reg <= 1'b0;
     	 else
     	   tx_ctl_wrena_reg <= tx_ctl_wrena;
     end
     
assign tx_low64_fifo_wrreq = tx_ctl_wrena_reg & ~low_hi_toggle_reg;
assign tx_low64_fifo_data_in = {tx_data_hi_reg, tx_data_low_reg};

assign tx_hi64_fifo_wrreq = tx_ctl_wrena_reg & (low_hi_toggle_reg | tx_rp_eop);
assign tx_hi64_fifo_data_in = {tx_rp_empty, tx_rp_eop, tx_rp_sop, tx_data_hi_reg, tx_data_low_reg};


// toggle ff to select hi or low 64-bit fifo to write
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
       if(~CraRstn_i)
     	   low_hi_toggle_reg <= 1'b0;
     	 else if(tx_ctl_wrena_reg & tx_control_reg[1] ) // EOP flag, reset
         low_hi_toggle_reg <= 1'b0;                                     
     	 else if(tx_ctl_wrena_reg ) // EOP flag, reset
     	   low_hi_toggle_reg <= ~low_hi_toggle_reg;
     end
     
 assign tx_rp_sop   = tx_control_reg[0];
 assign tx_rp_eop   = tx_control_reg[1];
 assign tx_rp_empty = tx_control_reg[1] & ~low_hi_toggle_reg;
 
 assign TxRpFifoData_o = {tx_hi64_fifo_dataout, tx_low64_fifo_dataout};
 assign RpTLPReady_o   = (tx_control_reg[1] & ~tx_hi64_fifo_rdempty) | (tx_hi64_fifo_wrusedw >= 2);
 
/// The RP Completion Data

	scfifo	# (
	       .add_ram_output_register("ON"),
		     .intended_device_family("Stratix V"),
		     .lpm_numwords(16),
		     .lpm_showahead("OFF"),
		     .lpm_type("scfifo"),
		     .lpm_width(131),
		     .lpm_widthu(4),
		     .overflow_checking("ON"),
		     .underflow_checking("ON"),
		     .use_eab("ON")
		  ) 
	          
       rxrp_fifo (
                     .rdreq (rxrp_fifo_rdreq),
                     .clock (CraClk_i),
                     .wrreq (RxRpFifoWrReq_i),
                     .data (RxRpFifoWrData_i),
                     .usedw (rxrp_fifo_usedw),
                     .empty (rxrp_fifo_empty),
                     .q (rxrp_fifo_dataout),
                     .full (),
                     .aclr (~CraRstn_i),
                     .almost_empty (),
                     .almost_full (),
                     .sclr ()
);
assign rxcpl_sop =   rxrp_fifo_dataout[128];
assign rxcpl_eop =   rxrp_fifo_dataout[129];
assign rxcpl_empty =   rxrp_fifo_dataout[130];

/// state machine to control the completion data

assign rxcpl_reg1_rdreq = RpReadReqVld_i & cra_address[7:0] == 8'h18;      
assign rxcpl_status_read = RpReadDataVld_o & cra_address[7:0] == 8'h10; 


always @(posedge CraClk_i or negedge CraRstn_i)  // state machine registers
  begin
    if(~CraRstn_i)
     rxcpl_state  <= RXCPL_IDLE;
    else
      rxcpl_state <= rxcpl_nxt_state;
  end

always @*
  begin
    case(rxcpl_state)
      RXCPL_IDLE :
        if(~rxrp_fifo_empty)
            rxcpl_nxt_state <= RXCPL_RDFIFO;
       else
          rxcpl_nxt_state <= RXCPL_IDLE;
          
      RXCPL_RDFIFO :
        rxcpl_nxt_state <= RXCPL_PIPE; 
        
      RXCPL_PIPE :
        rxcpl_nxt_state <= RXCPL_LD_REG0;
     
     RXCPL_LD_REG0:  // load the first 64-bit data
        rxcpl_nxt_state <= RXCPL_WAIT0;
        
     RXCPL_WAIT0:
       if(rxcpl_reg1_rdreq & rxcpl_eop & rxcpl_empty) 
         rxcpl_nxt_state <= RXCPL_IDLE;
       else if(rxcpl_reg1_rdreq)
         rxcpl_nxt_state <= RXCPL_LD_REG1;
       else
          rxcpl_nxt_state <= RXCPL_WAIT0;
    
    RXCPL_LD_REG1:
       rxcpl_nxt_state <= RXCPL_WAIT1;
    
     RXCPL_WAIT1:
       if(rxcpl_reg1_rdreq & rxcpl_eop) 
         rxcpl_nxt_state <= RXCPL_IDLE;
       else if(rxcpl_reg1_rdreq)
         rxcpl_nxt_state <= RXCPL_RDFIFO;
       else
          rxcpl_nxt_state <= RXCPL_WAIT1;
    
      default:
          rxcpl_nxt_state <= RXCPL_IDLE;
 endcase
 
end
 
/// assign state machine output

assign  rxrp_fifo_rdreq   = rxcpl_state[1];
assign  rxsm_load_first64 =  rxcpl_state[3];
assign  rxsm_load_second64 =  rxcpl_state[5];

/// Rx CPL registers
 
    always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           rx_data_low_reg <= 32'h0;
        else if(rxsm_load_first64)            
           rx_data_low_reg[31:0] <= rxrp_fifo_dataout[31:0];   
        else if(rxsm_load_second64)                          
           rx_data_low_reg[31:0] <= rxrp_fifo_dataout[95:64];
      end
     
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           rx_data_hi_reg <= 32'h0;
        else if(rxsm_load_first64)            
           rx_data_hi_reg[31:0] <= rxrp_fifo_dataout[63:32];      
         else if(rxsm_load_second64)                           
            rx_data_hi_reg[31:0] <= rxrp_fifo_dataout[127:96]; 
      end
 
  always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           rx_sop_reg <= 1'b0;
        else if(rxsm_load_first64 & rxcpl_sop)           
           rx_sop_reg <= 1'b1;
        else if (rxsm_load_second64 | rxcpl_status_read)
           rx_sop_reg <= 1'b0;
      end
      
  always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           rx_eop_reg <= 1'b0;
        else if(rxsm_load_first64 & rxcpl_eop & rxcpl_empty)           
           rx_eop_reg <= 1'b1;
        else if (rxsm_load_second64 & rxcpl_eop & ~rxcpl_empty)
           rx_eop_reg <= 1'b1;
        else if (rxsm_load_first64 | rxcpl_status_read)
           rx_eop_reg <= 1'b0;
      end
      
  always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
           rx_fifo_usedw_reg <= 8'h0;
        else if(rxrp_fifo_rdreq)           
           rx_fifo_usedw_reg[7:0] <= {4'b000, rxrp_fifo_usedw};
      end
      
assign rx_status_reg[31:0] = {16'h0, rx_fifo_usedw_reg[7:0], 6'h0, rx_eop_reg, rx_sop_reg};

// Muxing the read data
always @ *
  begin
  	  case (cra_address[7:0])
  	  	8'h10 : RpReadData_o = rx_status_reg;
  	  	8'h14 : RpReadData_o = rx_data_low_reg;
  	  	8'h18 : RpReadData_o = rx_data_hi_reg;
  	  	default : RpReadData_o = 32'h0;
  	  endcase
  end
  
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
       if(~CraRstn_i)
     	   RpReadDataVld_o <= 1'b0;
     	 else
     	   RpReadDataVld_o <= RpReadReqVld_i;
     end
     
       
assign RpRuptReq_o = 1'b0;  // tied to GND for now
assign RpTxFifoFull_o = tx_low64_fifo_wrusedw > 8 ;
endmodule
 
 
  