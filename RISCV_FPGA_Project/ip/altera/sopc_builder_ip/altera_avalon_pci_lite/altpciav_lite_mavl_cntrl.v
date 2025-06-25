//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//       Logic Core:                         PCI/Avalon Bridge Lite Function
//       Company:                               Altera Corporation.
//                                                       www.altera.com
//       Author :                               Penang IP Group Ong Hui Leang
//
//       Description:       PCI Avalon Light Avalon Sode control
//
//       Copyright 2007 Altera Corporation. All rights reserved.    This source code is highly
//       confidential and proprietary information of Altera and is being provided in accordance with
//       and subject to the protections of a Non-Disclosure Agreement which governs its use and
//       disclosure.    Altera products and services are protected under numerous U.S. and foreign
//      patents, maskwork rights, copyrights and other intellectual property laws.  Altera assumes
//       no responsibility or liability arising out of the application or use of this source code.
//
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

module altpciav_lite_mavl_cntrl
#(
        parameter CG_PCI_DATA_WIDTH = 32,
        parameter CG_AVALON_M_ADDR_WIDTH = 32


    )

(
    input                                                               PciClk_i,
    input                                                               Rstn_i,
    input                                                               BarActive,
 // Avalon Interface
    input                                                                PmClk_i,
    input                                                                PmRstn_i,
    input                                                                PmWaitRequest_i,
    input                                                                PmReadDataValid_i,
    input [CG_AVALON_M_ADDR_WIDTH-1 : 0]    PmReadData_i,
    output                                                              PmWrite_o,
    output [CG_AVALON_M_ADDR_WIDTH-1 : 0] PmAddr_o,
    output [CG_PCI_DATA_WIDTH-1 : 0]            PmWriteData_o,
    output [(CG_PCI_DATA_WIDTH/8)-1 : 0]    PmByteEnable_o,
    output [7:0]                                                    PmBurstCount_o,
    output                                                              PmRead_o,
    output                                                              PmBeginBurstTransfer_o,
    output                                                              PmBeginTransfer_o,

    //signal from PCI
    input                                                                avl_wrreq,
    input                                                                avl_rdreq,

    //command data register
    input [17:0]                                                     rwinfo_i,
    input [CG_PCI_DATA_WIDTH-1:0]                   avl_addr_i,
    input [(CG_PCI_DATA_WIDTH/8)-1 : 0]     ben_i,
    input [((CG_PCI_DATA_WIDTH/8) + CG_PCI_DATA_WIDTH) -1:0]                    wr_data_i,
    output [CG_AVALON_M_ADDR_WIDTH-1 : 0]   rd_data_o,
    output                                                               rddata_valid_o,

    input [7:0]             fifo_dat_avail_i,
    output              fifo_rd_req_o,

    output              avl_wr_done_o,
    output              avl_rd_done_o
);

//local parameters for avalon state machine
localparam MAVL_IDLE                 = 7'b 0000000;
localparam MAVL_WREN                 = 7'b 0000011;
localparam MAVL_RDEN                 = 7'b 0000101;
localparam MAVL_WRDAT               = 7'b 0001001;
localparam MAVL_RDDONE           = 7'b 0010001;
localparam MAVL_RDFIFO           = 7'b 0100001;
localparam MAVL_WRDONE           = 7'b 1000001;

//wire for avalon state machine
//wire                                              mavl_idle;
wire                                                mavl_wren;
wire                                                mavl_rden;
wire                                                mavl_wrdat;
wire                                                mavl_rddone;
wire                                                mavl_rdfifo;
wire                                                mavl_wrdone;

//wire for command/data
wire                                                                avlrd_flag;
wire                                                                avlwr_flag;
wire [7:0]                                                  avlwr_burstcount;
wire [7:0]                                                  avlrd_burstcount;
wire [7:0]                                                  avl_burstcount;
wire [(CG_PCI_DATA_WIDTH/8)-1 : 0]  avl_ben;
wire [CG_PCI_DATA_WIDTH-1:0]                avl_wrdata;
wire                                                                npm_active;
//reg for avalon interface state machine
reg [6:0]                                    mavl_state;
reg [6:0]                                    mavl_nxt_state;

//reg for command/data
reg [7:0]                                                    avl_burstcount_reg;
reg avl_wrreq_reg;

//command/data fr altpciav_lite_mcd
assign avlrd_flag = rwinfo_i[17];
assign avlwr_flag = rwinfo_i[16];
assign avlrd_burstcount = rwinfo_i[15:8];
assign avlwr_burstcount = rwinfo_i[7:0];
assign avl_burstcount = (avlwr_flag)? avlwr_burstcount : avlrd_burstcount;

assign avl_ben      = wr_data_i[35:32];
assign avl_wrdata = wr_data_i[31:0];

/////////////////////////////////////////////////////////////////////////
////// Main target state machine interfacing to the AVL bus                 ////
/////////////////////////////////////////////////////////////////////////
//1. read/write share the same done state

//always block for sequential logic
always @(posedge PciClk_i or negedge Rstn_i)
    begin
        if(~Rstn_i)
            mavl_state <= MAVL_IDLE;
        else
            mavl_state <= mavl_nxt_state;
    end

//always block for next state gen combo
always @ (*)
    begin
        case(mavl_state)
            MAVL_IDLE :
                if(avl_wrreq_reg & (fifo_dat_avail_i >=1) )             // write cycle
                    mavl_nxt_state <= MAVL_RDFIFO;
                else if(avl_rdreq)   // read cycle
                    mavl_nxt_state <= MAVL_RDEN;
                else
                    mavl_nxt_state <= MAVL_IDLE;

            MAVL_WREN : // assert write enable on Avalon NP port
                if(~PmWaitRequest_i & avl_burstcount >1)        // and waits for wait request to be de-asserted
                    mavl_nxt_state <= MAVL_WRDAT;
                else if(~PmWaitRequest_i    & avl_burstcount ==1)
                    mavl_nxt_state <= MAVL_WRDONE;
                else
                    mavl_nxt_state <= MAVL_WREN;

            MAVL_RDEN:   // assert read enable
                if(~PmWaitRequest_i)            // and waits for wait request to de-asserted
                    // need to also handle case where readdatavalid is returned same time
                    // as read is accepted and read is only 1 cycle.
                    if(avl_burstcount_reg ==1 & PmReadDataValid_i)
                        mavl_nxt_state <= MAVL_IDLE;
                    else
                        mavl_nxt_state <= MAVL_RDDONE;
                else
                    mavl_nxt_state <= MAVL_RDEN;

            MAVL_WRDAT:             // assert avalon wr done signal to the pci control sm
                if(avl_burstcount_reg ==1 & ~PmWaitRequest_i)
                    mavl_nxt_state <= MAVL_WRDONE;
                else
                    mavl_nxt_state <= MAVL_WRDAT;

            MAVL_RDDONE:                // assert avalon rd done signal to the pci control sm
                if(avl_burstcount_reg ==1 & PmReadDataValid_i)
                    mavl_nxt_state <= MAVL_IDLE;
                else
                    mavl_nxt_state <= MAVL_RDDONE;

            MAVL_RDFIFO :
                    mavl_nxt_state <= MAVL_WREN;

            MAVL_WRDONE :
                    mavl_nxt_state <= MAVL_IDLE;

            default:
                mavl_nxt_state <= MAVL_IDLE;

        endcase
 end

always @(posedge PciClk_i or negedge Rstn_i)
    begin
        if(~Rstn_i)
            avl_burstcount_reg <= 8'h1;
        else if ((mavl_wren | mavl_wrdat ) & ~PmWaitRequest_i )
            avl_burstcount_reg <= avl_burstcount_reg - 8'h1;
        else if (( mavl_rden | mavl_rddone) & PmReadDataValid_i)
            avl_burstcount_reg <= avl_burstcount_reg - 8'h1;
        else if (mavl_rdfifo | mavl_rden)
            avl_burstcount_reg <= avl_burstcount;
        else if (avl_burstcount==1)
            avl_burstcount_reg <= avl_burstcount;
        else
            avl_burstcount_reg <= avl_burstcount_reg;
    end

always @(posedge PciClk_i or negedge Rstn_i)
    begin
        if(~Rstn_i)
            avl_wrreq_reg <= 1'b0;
        else if (avl_wrreq )
            avl_wrreq_reg <= avl_wrreq;
        else if (mavl_wrdone )
            avl_wrreq_reg <= 1'b0;
        else
            avl_wrreq_reg <= avl_wrreq_reg;
    end


assign mavl_wren = mavl_state[1];
assign mavl_rden = mavl_state[2];
assign mavl_wrdat = mavl_state[3];
assign mavl_rddone = mavl_state[4];
assign mavl_rdfifo = mavl_state[5];
assign mavl_wrdone = mavl_state[6];
assign npm_active = (BarActive == (3'b010 | 3'b100))?1'b1:1'b0;

// Avalon Prefetchable port signals
assign PmAddr_o = (mavl_wren|mavl_rden | mavl_wrdat)? (avl_addr_i & 32'hFFFFFFFC) : 32'h0;
assign PmByteEnable_o = (mavl_wren|mavl_rden | mavl_wrdat | mavl_rddone)?(~avl_ben): 4'h0;
assign PmRead_o = (mavl_rden )?1'b1:1'b0;
assign PmWrite_o = npm_active?((mavl_wrdat)?1'b1:1'b0):((mavl_wren|mavl_wrdat)?1'b1:1'b0);
assign PmWriteData_o = (mavl_wren | mavl_wrdat)?avl_wrdata:32'h0;
assign PmBurstCount_o = (mavl_wren | mavl_rden | mavl_wrdat )?avl_burstcount : 8'h1 ;
assign PmBeginTransfer_o = (mavl_wren|mavl_rden)?1'b1:1'b0 ;
assign PmBeginBurstTransfer_o = ((mavl_wren|mavl_rden) & avl_burstcount >1)?1'b1:1'b0;

//command/data to altpciav_lite_mcd
assign rd_data_o = (PmReadDataValid_i)?(PmReadData_i):32'h0;
assign rddata_valid_o = PmReadDataValid_i;

assign fifo_rd_req_o = mavl_rdfifo;
assign avl_wr_done_o = mavl_wrdone;
assign avl_rd_done_o = (mavl_rddone | mavl_rden) & avl_burstcount_reg ==1 & PmReadDataValid_i;

endmodule
