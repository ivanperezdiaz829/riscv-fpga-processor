//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group
//			       
//     Description:    PCI Avalon Light PCI Bus Access Local Bus Module
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

module altpciav_lite_pba_loc 
  #(
    parameter CG_PCI_DATA_WIDTH = 32
    )
(

pci_clk_i,
pci_rstn_i,
//l_ldat_ackn_i,
//l_hdat_ackn_i,
lm_adr_ackn_i,
lm_ackn_i,
l_dato_i,
lm_tsr_i,
stat_reg_i,
cmd_reg_i,
lm_dxfrn_i,
//cachesize_i,
lm_lastn_o,
lm_req32n_o,
lm_rdyn_o,
l_adi_o,
l_cben_o,
pci_address_o,
pci_cmd_o,
pci_ben_o, 
avl_mstr_wr_req,
avl_mstr_burst_i,
avl_mstr_rd_req,
pba_writedata_i,
fifo_data_i,
fifo_rd_req_o,
pba_readdata_o,
pba_readdatavalid_o,
pba_write_state_i,
lb_write_state_rise_o,
lb_req_state_rise_o,
lb_busy_o,
rdusedw_i,
unfinished_write_i,
unfinished_read_i
);

// Port Declaration
input pci_clk_i;
input pci_rstn_i;

//input l_ldat_ackn_i;
//input l_hdat_ackn_i;
input lm_adr_ackn_i;
input lm_ackn_i;
input [CG_PCI_DATA_WIDTH-1 : 0]l_dato_i;
input [9:0]lm_tsr_i;
input [6:0]stat_reg_i;
input [6:0]cmd_reg_i;
input lm_dxfrn_i;
//input cachesize_i;
output lm_lastn_o;
output lm_req32n_o;
output lm_rdyn_o;
output [CG_PCI_DATA_WIDTH-1 : 0]l_adi_o;
output [(CG_PCI_DATA_WIDTH/8)-1 : 0]l_cben_o;

input avl_mstr_wr_req;
input [7:0]avl_mstr_burst_i;
input avl_mstr_rd_req;

input [CG_PCI_DATA_WIDTH -1 :0] pba_writedata_i;
input [CG_PCI_DATA_WIDTH -1 :0] fifo_data_i;
output fifo_rd_req_o;
output [CG_PCI_DATA_WIDTH -1 :0] pba_readdata_o;
output pba_readdatavalid_o;

input pba_write_state_i;
output lb_write_state_rise_o;
output lb_req_state_rise_o;
output lb_busy_o;

input [7:0] rdusedw_i;

// Wire and Regs
input [CG_PCI_DATA_WIDTH-1 : 0]pci_address_o;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_cmd_o;
input [(CG_PCI_DATA_WIDTH/8)-1 : 0]pci_ben_o;
input unfinished_write_i;
input unfinished_read_i;

// PCI core command register
wire master_ena = cmd_reg_i[2];
wire transaction_active = (unfinished_write_i|unfinished_read_i);
reg [3:0]lb_current_state;
reg [3:0]lb_next_state;

// Local Param
localparam lb_idle = 4'h0;
localparam lb_req = 4'h3;
localparam lb_write = 4'h5;
localparam lb_read = 4'h9;

wire lb_idle_state;
wire lb_req_state;
wire lb_write_state;
wire lb_read_state;
wire lb_req_state_rise;
wire lb_write_state_rise;

reg wr_rdn_req;
reg [7:0]burst;
reg [7:0]burst_cnt;
reg  pci_data_phase_delayed; // delayed version of pci_data_phase lm_tsr[3]
reg lb_write_state_reg;
reg lb_req_state_reg;


always @ (posedge pci_clk_i or negedge pci_rstn_i) 
begin
    if (~pci_rstn_i)
        lb_write_state_reg <= 1'b0;
    else
        lb_write_state_reg <= lb_write_state;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if (~pci_rstn_i)
        lb_req_state_reg <= 1'b0;
    else
        lb_req_state_reg <= lb_req_state;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i) 
begin
    if (~pci_rstn_i)
        pci_data_phase_delayed <= 1'b0;
    else
        pci_data_phase_delayed <= lm_tsr_i[3];
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        wr_rdn_req <=0;
    else if(avl_mstr_wr_req)
        wr_rdn_req <=1;
    else if(avl_mstr_rd_req)
        wr_rdn_req <=0;
    else 
        wr_rdn_req <=wr_rdn_req;

end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        burst <= 0;
    else
        burst <= avl_mstr_burst_i;
end

always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        burst_cnt <= 0;
    else if(lb_idle_state |lb_req_state)
        burst_cnt <= burst;
    else if (lb_write_state & ~lm_dxfrn_i)
        burst_cnt <= burst_cnt -8'h1;
    else if (lb_read_state & ~lm_dxfrn_i  & burst_cnt >= 1)
        burst_cnt <= burst_cnt -8'h1;
    else if (lb_read_state & ~lm_ackn_i  & burst_cnt >= 1)
        burst_cnt <= burst_cnt -8'h1;
    else if (lb_current_state == 8'h0 & lm_tsr_i == 9'h0)
        burst_cnt <= 8'h0;
    else
        burst_cnt <= burst_cnt;

end


always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        lb_current_state <= lb_idle;
    else
        lb_current_state <= lb_next_state;
end
wire  master_abort_sig;

always @ (*)
begin
    case(lb_current_state)
        lb_idle:
            begin
                if(master_ena & (avl_mstr_wr_req | avl_mstr_rd_req | transaction_active))
                        lb_next_state = lb_req;
                else
                        lb_next_state = lb_idle;

            end
        lb_req:
                if(~lm_ackn_i & (wr_rdn_req | unfinished_write_i))
                        lb_next_state = lb_write;
                else if(~lm_adr_ackn_i & (~wr_rdn_req | unfinished_read_i))
                        lb_next_state = lb_read;
                else
                        lb_next_state = lb_req;
        lb_write:
		if(pba_write_state_i | burst_cnt == 1)
                        lb_next_state = lb_write;
		else
                        lb_next_state = lb_idle;
        lb_read:
		if(burst_cnt != 7'h0 & ~master_abort_sig)
                        lb_next_state = lb_read;
		else
                        lb_next_state = lb_idle;
        default:
                lb_next_state = lb_idle;
    endcase


end

reg [3:0]  latency_counter;
reg [31:0] data_feedback;
reg [31:0] data_feedback2;
reg [31:0] data_output;
reg        prev_disc_stat;
reg [31:0] addr_disc_recovery;
reg [3:0]  master_abort_cntr;

// Detecting master abort read
always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        master_abort_cntr <= 4'b0;
    else if (~lm_adr_ackn_i )
        master_abort_cntr <= 4'b0;
    else if(~lm_rdyn_o & lm_dxfrn_i)
        master_abort_cntr <= master_abort_cntr - 1'b1;
    else if(master_abort_sig)
        master_abort_cntr <= 4'b0;
    else
        master_abort_cntr <= master_abort_cntr;
end


assign master_abort_sig = (master_abort_cntr == 4'b1) ? 1'b1 : 1'b0;
assign lb_idle_state = ~lb_current_state[0];
assign lb_req_state = lb_current_state[1];
assign lb_write_state = lb_current_state[2];
assign lb_read_state = lb_current_state[3];

assign lb_req_state_rise = ~lb_req_state_reg & lb_req_state;
assign lb_req_state_rise_o = lb_req_state_rise;

assign lb_write_state_rise = ~lb_write_state_reg & lb_write_state;
assign lb_write_state_rise_o = lb_write_state_rise;
assign lb_busy_o = lb_write_state;

assign fifo_rd_req_o = ((pci_cmd_o ==4'h7 &  ~lm_adr_ackn_i | (lb_write_state & ~lm_dxfrn_i & ~lm_tsr_i[6] & ~lm_tsr_i[7]) | (burst==1 & lm_tsr_i[1]) ) & rdusedw_i >0 & ~prev_disc_stat)? 1'b1:1'b0;

assign lm_req32n_o = ~lb_req_state;
assign lm_rdyn_o = (burst ==1)? ~(lb_write_state | lb_read_state) : ((lb_write_state & (burst_cnt>0 | rdusedw_i >0)) | lb_read_state )? 1'b0:1'b1;
assign l_adi_o = data_output;
assign l_cben_o = (~lm_adr_ackn_i)? pci_cmd_o:pci_ben_o;
assign lm_lastn_o = ((lb_write_state & burst_cnt ==1 & ~lm_dxfrn_i) | (l_cben_o == 4'h6 & burst_cnt ==1) |(lb_read_state & burst_cnt == 2 & pci_data_phase_delayed) | (lb_read_state & burst_cnt == 3 & ~lm_dxfrn_i) | (latency_counter == 4) )? 1'b0:1'b1;

assign pba_readdata_o = l_dato_i;
assign pba_readdatavalid_o = (~wr_rdn_req & ~lm_dxfrn_i)|master_abort_sig;

//Latency Counter
always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
    if(~pci_rstn_i)
        latency_counter <= 4'h0;
    else if (~lm_rdyn_o)
        latency_counter <= 4'h8;
    else if(~lm_ackn_i & lm_dxfrn_i)
        latency_counter <= latency_counter - 4'b1;
    else
        latency_counter <= latency_counter;
end

//Block to handle Disconnect recovery
always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
   if (~pci_rstn_i)
      data_feedback <= 32'h0;
   else if(~(lm_ackn_i & lm_dxfrn_i))
      data_feedback <= l_adi_o;
   else 
      data_feedback <=data_feedback;
end

//Indicate that last transaction was a disconnect transaction
always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
   if (~pci_rstn_i)
      prev_disc_stat <= 1'b0;
   else if(lm_tsr_i[7] | lm_tsr_i[6])
      prev_disc_stat <= 1'b1;
   else if(~lm_dxfrn_i)
      prev_disc_stat <= 1'b0;
   else 
      prev_disc_stat <=prev_disc_stat;
end

//Disconnect data recovery
always @ (*)
begin
if (~lm_adr_ackn_i)
   data_output = (prev_disc_stat) ? (addr_disc_recovery - 4'h4) : pci_address_o;
else if (prev_disc_stat & ~lm_ackn_i)
   data_output = data_feedback;
else
   data_output = fifo_data_i;
end

//Disconnect Address recovery
always @ (posedge pci_clk_i or negedge pci_rstn_i)
begin
   if (~pci_rstn_i)
      addr_disc_recovery <= 1'b0;
   else if(~lm_adr_ackn_i)
      addr_disc_recovery <= l_adi_o;
   else if(~lm_dxfrn_i)
      addr_disc_recovery <= addr_disc_recovery + 4'h4;
   else 
      addr_disc_recovery <= addr_disc_recovery;
end


endmodule
