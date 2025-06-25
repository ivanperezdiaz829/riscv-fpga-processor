//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group
//			       
//     Description:    PCI Avalon Light PCI Bus Access Avalon Bus Module (Avalon side FSM)
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

module altpciav_lite_pba_avl 
  #(
    parameter CG_PCI_DATA_WIDTH = 32,
    parameter CG_AVALON_S_ADDR_WIDTH = 32

    )
(

pci_clk_i,
pci_rstn_i,
valid_loc_data_xfr,
lm_tsr_i,
pba_clk_i,
pba_rstn_i,
pba_chipselect_i,
pba_address_i,
pba_byteenable_i,
pba_read_i,
pba_write_i,
pba_writedata_i,
pba_waitrequest_o,
pba_burstcount_i,
pba_begintransfer_i,
pba_beginbursttransfer_i,

// to A2P trans
pba_address_o,
read_wait,

// to PBA LB cntrl
pci_address_i,
pci_address_vld_i,
pci_cmd_space_i,
pci_ben_i,

pci_address_o,
pci_cmd_o,
pci_ben_o,

pba_write_state,
pba_read_state,

avl_mstr_wr_req,
avl_mstr_burst_o,
avl_mstr_rd_req,

pba_adr_vld_o,

rd_done_i,
lb_write_state_rise_i,
lb_req_state_rise_i,
lb_busy_i,

avl_fifo_wr_req_o,

unfinished_write_o,
unfinished_read_o,
fifo_empty_i,
rdusedw_i
);

// Port Declaration
input            pci_clk_i;
input            pci_rstn_i;
input            pba_clk_i;
input            pba_rstn_i;
input            pba_chipselect_i;
input            pba_read_i;
input            pba_write_i;
input            pba_begintransfer_i;
input            pba_beginbursttransfer_i;
input            read_wait;
input            pci_address_vld_i;
input            rd_done_i;
input            lb_write_state_rise_i;
input            lb_req_state_rise_i;
input            lb_busy_i;
input            valid_loc_data_xfr;
input            fifo_empty_i;
input [7:0]      pba_burstcount_i;
input [7:0]      rdusedw_i;
input [1:0]      pci_cmd_space_i;
input [9:0]      lm_tsr_i;
input [CG_PCI_DATA_WIDTH-1 : 0]                              pba_writedata_i;
input [CG_AVALON_S_ADDR_WIDTH-1 : (CG_PCI_DATA_WIDTH/32)+1 ] pba_address_i;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]                          pba_byteenable_i;
input [CG_PCI_DATA_WIDTH-1 : 0]                              pci_address_i;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]                          pci_ben_i;

output            pba_write_state;
output            pba_read_state;
output            avl_mstr_wr_req;
output            avl_mstr_rd_req;
output            pba_adr_vld_o;
output            avl_fifo_wr_req_o;
output            unfinished_write_o;
output            unfinished_read_o;
output reg        pba_waitrequest_o;
output [CG_PCI_DATA_WIDTH-1 : 0]                              pci_address_o;
output [(CG_PCI_DATA_WIDTH/8)-1 : 0]                          pci_cmd_o;
output [(CG_PCI_DATA_WIDTH/8)-1 : 0]                          pci_ben_o;
output [CG_AVALON_S_ADDR_WIDTH-1 : 0]                         pba_address_o;
output [7:0]                                                  avl_mstr_burst_o;

// Wire and Regs
wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_cmd_o;
wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_ben_o;

//wire pba_idle_state;
wire pba_write_state;
wire pba_read_state;
wire pba_wait_state;
//wire wait_full_flush;
reg wait_full_flush;

reg [3:0]pba_avl_current_state;
reg [3:0]pba_avl_next_state;

reg [CG_PCI_DATA_WIDTH-1 : 0]pci_address_o;
reg [7:0]burst_count;
reg [7:0]burst_counter;

reg [3:0]pci_cmd_reg_o;
reg [1:0]pci_cmd_space_reg;

//register to check which transaction is still dangling in fifo
reg      unfinished_write;
reg      unfinished_read;

reg [7:0]     burst_transfer;

// Local Param
localparam pba_idle = 4'h0;
localparam pba_write = 4'h3;
localparam pba_read = 4'h5;
localparam pba_wait = 4'h9;

// Address space definitions
localparam [1:0] ADSP_CONFIG = 2'b11 ;
localparam [1:0] ADSP_IO =     2'b10 ;
localparam [1:0] ADSP_MEM64 =  2'b01 ;
localparam [1:0] ADSP_MEM32 =  2'b00 ;

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        pci_cmd_reg_o <= 4'h0;
    else if(pba_write_i)
	if(pci_cmd_space_reg == ADSP_CONFIG)
        	pci_cmd_reg_o <= 4'hB;
	else if (pci_cmd_space_reg == ADSP_IO)
        	pci_cmd_reg_o <= 4'h3;
	else if (pci_cmd_space_reg == ADSP_MEM32)
        	pci_cmd_reg_o <= 4'h7;
	else
        	pci_cmd_reg_o <= 4'h7;
    else if(pba_read_i)
	if(pci_cmd_space_reg == ADSP_CONFIG)
        	pci_cmd_reg_o <= 4'hA;
	else if (pci_cmd_space_reg == ADSP_IO)
        	pci_cmd_reg_o <= 4'h2;
	else if (pci_cmd_space_reg == ADSP_MEM32)
        	pci_cmd_reg_o <= 4'h6;
	else
        	pci_cmd_reg_o <= 4'h6;
    else
	pci_cmd_reg_o <= pci_cmd_reg_o;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        pci_address_o <= 0;
    else if(pci_address_vld_i)
        pci_address_o <= pci_address_i;
    else 
        pci_address_o <= pci_address_o;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        pci_cmd_space_reg <= 0;
    else if(pci_address_vld_i)
        pci_cmd_space_reg <= pci_cmd_space_i;
    else
        pci_cmd_space_reg <= pci_cmd_space_reg;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        pba_avl_current_state <= pba_idle;
    else
        pba_avl_current_state <= pba_avl_next_state;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        burst_count <= 8'h0;
    else if (pba_begintransfer_i | pba_beginbursttransfer_i)
        burst_count <= pba_burstcount_i;
    else
	    burst_count <= burst_count;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        burst_counter <= 8'h0;
    else if ((pba_beginbursttransfer_i | pba_begintransfer_i) & ~lb_busy_i)
        burst_counter <= pba_burstcount_i;
    else if(burst_counter > 0 & valid_loc_data_xfr)
        burst_counter <= burst_counter - 8'b1;
    else
        burst_counter <= burst_counter;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
   if(~pci_rstn_i)
      burst_transfer <= 8'h0;
   else if (pba_beginbursttransfer_i | pba_begintransfer_i)
      burst_transfer <= pba_burstcount_i;
   else if (pba_chipselect_i & burst_transfer != 0)
      burst_transfer <= burst_transfer - 8'b1;
   else 
      burst_transfer <= burst_transfer;
end

always @ (*)
begin
    case(pba_avl_current_state)
        pba_idle:
            begin
                if(pba_chipselect_i & pba_write_i)
                        pba_avl_next_state = pba_write;
                else if(pba_chipselect_i & pba_read_i)
                        pba_avl_next_state = pba_read;
                else if(unfinished_write)
                        pba_avl_next_state = pba_write;
                else if(unfinished_read)
                        pba_avl_next_state = pba_read;
                else
                        pba_avl_next_state = pba_idle;

            end
        pba_write:
	// When avalon starts burst, it must complete, stay in write state until all data received
	// PCI might ends early, but will have to wait for Avalon to be free again
		if((burst_counter > 1) & !(lm_tsr_i[7]|lm_tsr_i[6])) 
                        pba_avl_next_state = pba_write;
                else if (lm_tsr_i[7]|lm_tsr_i[6])
                        pba_avl_next_state = pba_idle;
		else
                        pba_avl_next_state = pba_idle;

        pba_read: //wait till read is done
		if(~rd_done_i)
                        pba_avl_next_state = pba_read;
		else
                        pba_avl_next_state = pba_idle;
        pba_wait: //wait till write is done
              if (~lb_busy_i)
                        pba_avl_next_state = pba_idle;
              else          
                        pba_avl_next_state = pba_wait;
        default:
              pba_avl_next_state = pba_idle;
    endcase


end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin 
if(~pci_rstn_i)
   unfinished_write <= 1'b0;
else if (pba_write_i)
   unfinished_write <= 1'b1;
else if (burst_counter == 8'h0)
   unfinished_write <= 1'b0;
else
   unfinished_write <= unfinished_write;
end

always @ (*)
begin 
if(~pci_rstn_i)
   wait_full_flush = 1'b0;
else if (burst_transfer <= 2 & !fifo_empty_i)
   wait_full_flush = 1'b1;
else
   wait_full_flush = 1'b0;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin 
   if(~pci_rstn_i)
      unfinished_read <= 1'b0;
   else if (pba_read_i)
      begin
         if (burst_counter < 8'h2)
            unfinished_read <= 1'b0;
         else
            unfinished_read <= 1'b1;
      end      
   else
      begin
         if (burst_counter < 8'h2)
            unfinished_read <= 1'b0;
         else
            unfinished_read <= unfinished_read;
      end      
end

assign pba_write_state = pba_avl_current_state[1];
assign pba_read_state = pba_avl_current_state[2];
assign pba_wait_state = pba_avl_current_state[3];

assign avl_mstr_wr_req = pba_write_i;
assign avl_mstr_burst_o = burst_count;
assign avl_mstr_rd_req = pba_read_state;

assign avl_fifo_wr_req_o = (burst_count > 1)? (pba_write_i & ~pba_waitrequest_o) : (lb_req_state_rise_i & pci_cmd_o != 4'hA);
always @ (*) 
begin
if (pba_write_i)
begin
   if (burst_count > 1) 
      pba_waitrequest_o = wait_full_flush;
   else 
      pba_waitrequest_o = ~lb_write_state_rise_i; 
end
else
      pba_waitrequest_o = (~read_wait & pba_read_i) | pba_wait_state;
end


assign pba_adr_vld_o = pba_begintransfer_i | pba_beginbursttransfer_i;
assign pci_cmd_o = pci_cmd_reg_o;
assign pci_ben_o =4'h0;

assign pba_address_o = {pba_address_i,2'b00};
assign      unfinished_write_o = unfinished_write;
assign      unfinished_read_o = unfinished_read;
endmodule
