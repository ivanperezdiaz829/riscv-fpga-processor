// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// DCD control
//
// Performs self calibration with VCO data to get best Sum A Sum B
// difference(D). 

// Performs DCD calibration by enabling 1010.. test pattern. 
// Determines the rcru_dc_tune value that gives a Sum A - Sum B difference
// that is closest to the value obtained in self calibration.

// Clock alignment is an external module.  

module alt_xcvr_reconfig_dcd_control (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,  // stops after current channel while asserted
    
    // Basic Block control
    output reg         ctrl_go,
    output reg         ctrl_lock,
    input  wire        ctrl_done,
    output reg  [6:0]  ctrl_chan,
    input  wire        ctrl_chan_err,
    output reg  [11:0] ctrl_addr,
    output reg  [2:0]  ctrl_opcode,
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    output reg         ctrl_sel,
    
    output reg         user_busy,
    
    // PHY counters
    output reg         align_go,
    input  wire        align_done,
    input  wire        align_timeout,
    input  wire [7:0]  align_sum_a,
    input  wire [7:0]  align_sum_b
    );  

parameter  [6:0] NUM_OF_CHANNELS = 66;  
parameter        PLL_TIMEOUT     = 10000; //(read cycles)
 
function integer log2;
    input [31:0] value;
    for (log2=0; value>0; log2=log2+1)
        value = value>>1;
endfunction

// states  
localparam [4:0] STATE_IDLE        = 5'h00;
localparam [4:0] STATE_RD_PHY_ID   = 5'h01;
localparam [4:0] STATE_RD_VCO_ON   = 5'h02;
localparam [4:0] STATE_WR_VCO_ON   = 5'h03;
localparam [4:0] STATE_WR_LOOP_ON  = 5'h04;
localparam [4:0] STATE_RD_PDB_ON   = 5'h05;
localparam [4:0] STATE_WR_PDB_ON   = 5'h06;
localparam [4:0] STATE_RD_EYE_ON   = 5'h07;
localparam [4:0] STATE_WR_EYE_ON   = 5'h08;
localparam [4:0] STATE_WAIT_PLL    = 5'h09;
localparam [4:0] STATE_ALIGN_D     = 5'h0a;
localparam [4:0] STATE_RD_VCO_OFF  = 5'h0b;
localparam [4:0] STATE_WR_VCO_OFF  = 5'h0c;
localparam [4:0] STATE_RD_VCO_OFF2 = 5'h0d;
localparam [4:0] STATE_WR_VCO_OFF2 = 5'h0e;
localparam [4:0] STATE_RD_TEST_ON  = 5'h0f;
localparam [4:0] STATE_WR_TEST_ON  = 5'h10;
localparam [4:0] STATE_WAIT_PLL2   = 5'h11;
localparam [4:0] STATE_RD_DCD      = 5'h12;
localparam [4:0] STATE_WR_DCD      = 5'h13;
localparam [4:0] STATE_ALIGN_DCD   = 5'h14;
localparam [4:0] STATE_WR_BEST     = 5'h15;
localparam [4:0] STATE_ALIGN_BEST  = 5'h16;
localparam [4:0] STATE_RD_PDB_OFF  = 5'h17;
localparam [4:0] STATE_WR_PDB_OFF  = 5'h18;
localparam [4:0] STATE_RD_TEST_OFF = 5'h19;
localparam [4:0] STATE_WR_TEST_OFF = 5'h1a;
localparam [4:0] STATE_WR_LOOP_OFF = 5'h1b;
localparam [4:0] STATE_RD_EYE_OFF  = 5'h1c;
localparam [4:0] STATE_WR_EYE_OFF  = 5'h1d;
localparam [4:0] STATE_DONE        = 5'h1e;

// register addresses
import sv_xcvr_h::*;
 
// register bits values
localparam       VCO_DATA_SEL   = 1'b1;   // VCO data select
localparam       EYE_MON_SEL    = 1'b1;   // EYE mon / CDR data
localparam       FORCED_DATA_EN = 1'b1;   // Forced data (test pattern)
localparam       PHY_TX_ID      = 1'b1;   // PHY TX present
localparam       PHY_RX_ID      = 1'b1;   // PHY RX present
localparam       PHY_TX_RESET   = 1'b1;   // PHY TX_reset
localparam       PHY_RX_RESET   = 1'b1;   // PHY RX reset
localparam       PHY_LPBK       = 1'b1;   // PHY loopback
localparam [2:0] REYE_ISEL_ON   = 3'b010; // ISEL on 
localparam [2:0] REYE_ISEL_OFF  = 3'b001; // ISEL off
localparam       REYE_PDB_ON    = 1'b1;   // power on

 // Commands
localparam [2:0] OPCODE_READ  = 3'h0; 
localparam [2:0] OPCODE_WRITE = 3'h1;

reg         [1:0]                       hold_ff;
wire                                    hold_sync;
reg         [4:0]                       state;
wire                                    phy_id;
wire                                    phy_reset;
reg         [(log2(PLL_TIMEOUT)) -1 :0] pll_timeout_ctr;
reg                                     pll_timeout_ctr_tc;
wire                                    ctrl_chan_tc;
wire signed [9:0]                       sgn_sum_a;
wire signed [9:0]                       sgn_sum_b;
reg  signed [9:0]                       c;
reg  signed [9:0]                       d;
reg  signed [9:0]                       e;
reg         [9:0]                       e_abs;
reg         [9:0]                       best_e_value;
reg         [2:0]                       best_dcd_ctr;
reg                                     best_greater_than_e;
reg         [15:0]                      dcd_rdata;
reg         [2:0]                       dcd_ctr;
wire                                    dcd_ctr_tc;
reg                                     ctrl_go_ff; 
reg         [3:0]                       align_done_ff;
 
// synchronize asynchronous signals
always @(posedge clk)
begin
    hold_ff      <= {hold_ff[0], hold};
end
 
assign hold_sync  = hold_ff[1];

// control
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
       case (state)
            STATE_IDLE:         if (!hold_sync)
                                    state <= STATE_RD_PHY_ID;
                                    
            // check phy channel and channel ID
            STATE_RD_PHY_ID:    if ((ctrl_done && ctrl_chan_tc && ctrl_chan_err) ||
                                    (ctrl_done && ctrl_chan_tc && !phy_id))
                                    state <= STATE_DONE;
                                else if ((ctrl_done && !ctrl_chan_tc && ctrl_chan_err) ||
                                         (ctrl_done && !ctrl_chan_tc && !phy_id))
                                    state <= STATE_IDLE;
                                else if (ctrl_done )
                                    state <= STATE_RD_VCO_ON;                      
                                                
            // enable VCO data
            STATE_RD_VCO_ON:    if (ctrl_done)
                                    state <= STATE_WR_VCO_ON;
                                    
            STATE_WR_VCO_ON:    if (ctrl_done)
                                    state <= STATE_WR_LOOP_ON;
                                    
            // enable loop back
            STATE_WR_LOOP_ON:   if (ctrl_done)
                                    state <= STATE_RD_PDB_ON;           
            
            // enable pdb and isel
            STATE_RD_PDB_ON:    if (ctrl_done)
                                    state <= STATE_WR_PDB_ON;
                                    
            STATE_WR_PDB_ON:    if (ctrl_done)
                                    state <= STATE_RD_EYE_ON;
                                    
            // enable eye monitor data
            STATE_RD_EYE_ON:    if (ctrl_done)
                                    state <= STATE_WR_EYE_ON;
                                    
            STATE_WR_EYE_ON:    if (ctrl_done)
                                    state <= STATE_WAIT_PLL; 
         
            // wait PLL lock
            STATE_WAIT_PLL:     if (ctrl_done && !phy_reset)
                                    state <= STATE_ALIGN_D;
                                else if (pll_timeout_ctr_tc)
                                    state <= STATE_RD_VCO_OFF2;

            // self-calibration -- get  golden sum A - sum B
            STATE_ALIGN_D:      if (align_done_ff[3] && !align_timeout)
                                    state <= STATE_RD_VCO_OFF;
                                else if (align_done_ff[3])
                                    state <= STATE_RD_VCO_OFF2;
                                    
            // end calibration / disable VCO data 
            STATE_RD_VCO_OFF2:  if (ctrl_done)
                                    state <= STATE_WR_VCO_OFF2;
                                    
            STATE_WR_VCO_OFF2:  if (ctrl_done)
                                    state <= STATE_RD_PDB_OFF;
                        
            // disable VCO data
            STATE_RD_VCO_OFF:   if (ctrl_done)
                                    state <= STATE_WR_VCO_OFF;
                                    
            STATE_WR_VCO_OFF:   if (ctrl_done)
                                    state <= STATE_RD_TEST_ON;
 
            // enable test pattern
            STATE_RD_TEST_ON:   if (ctrl_done)
                                    state <= STATE_WR_TEST_ON;
                                    
            STATE_WR_TEST_ON:   if (ctrl_done)
                                    state <= STATE_WAIT_PLL2;
            
            // wait PLL lock
            STATE_WAIT_PLL2:    if (ctrl_done && !phy_reset)
                                    state <= STATE_RD_DCD;
                                else if (pll_timeout_ctr_tc)
                                    state <= STATE_RD_PDB_OFF;
                        
            // get DCD register for RMW
            STATE_RD_DCD:       if (ctrl_done)
                                    state <= STATE_WR_DCD;
                                    
            // DCD alignment
            // increment reye_mon and re-align clocks          
            STATE_WR_DCD:       if (ctrl_done)
                                    state <= STATE_ALIGN_DCD;
                                    
            STATE_ALIGN_DCD:    if ((align_done_ff[3] && dcd_ctr_tc && best_greater_than_e) || 
                                    (align_done_ff[3] && align_timeout))
                                    state <= STATE_RD_PDB_OFF;
                               
                                else if (align_done_ff[3] && dcd_ctr_tc)
                                    state <= STATE_WR_BEST;
                               
                                else if (align_done_ff[3])
                                    state <= STATE_WR_DCD;
                                    
            // write best DCD value
            STATE_WR_BEST:      if (ctrl_done)
                                    state <= STATE_ALIGN_BEST;
                                    
            // align best DCD value
            STATE_ALIGN_BEST:   if (align_done_ff[3])
                                    state <= STATE_RD_PDB_OFF;
                        
            // disable pdb and isel
            STATE_RD_PDB_OFF:    if (ctrl_done)
                                    state <= STATE_WR_PDB_OFF;
                                    
            STATE_WR_PDB_OFF:    if (ctrl_done)
                                    state <= STATE_RD_TEST_OFF;
            
            // disable test pattern
            STATE_RD_TEST_OFF:  if (ctrl_done)
                                    state <= STATE_WR_TEST_OFF;
                                    
            STATE_WR_TEST_OFF:  if (ctrl_done)
                                    state <= STATE_WR_LOOP_OFF;

            // disable loop back
            STATE_WR_LOOP_OFF:  if (ctrl_done)
                                    state <= STATE_RD_EYE_OFF;
            
            // enable eye monitor data
            STATE_RD_EYE_OFF:   if (ctrl_done)
                                    state <= STATE_WR_EYE_OFF;
                                    
            STATE_WR_EYE_OFF:   if (ctrl_done && ctrl_chan_tc)
                                    state <= STATE_DONE; 
                                else if (ctrl_done)
                                    state <= STATE_IDLE;                       
            // done            
            STATE_DONE:         state <= STATE_DONE; 
            
            default:            state <= STATE_IDLE; 
       endcase
end

// PHY_ID
assign    phy_id  = (ctrl_rdata[SV_XR_ID_TX_CHANNEL_OFST] == PHY_TX_ID) & 
                    (ctrl_rdata[SV_XR_ID_RX_CHANNEL_OFST] == PHY_RX_ID);

// PHY RESET
assign  phy_reset = (ctrl_rdata[SV_XR_STATUS_TX_DIGITAL_RESET_OFST] == PHY_TX_RESET) | 
                    (ctrl_rdata[SV_XR_STATUS_RX_DIGITAL_RESET_OFST] == PHY_RX_RESET);

// PLL lock timeout                   
always @(posedge clk)
begin
    if ((state == STATE_WR_TEST_ON) ||(state == STATE_WR_EYE_ON))                    
         pll_timeout_ctr <= 'h0;         
    else if (((state == STATE_WAIT_PLL)  && ctrl_done) ||
             ((state == STATE_WAIT_PLL2) && ctrl_done))
         pll_timeout_ctr <= pll_timeout_ctr + 1'b1;
end

always @(posedge clk)
begin
    if ((state == STATE_WR_TEST_ON) ||(state == STATE_WR_EYE_ON))       
        pll_timeout_ctr_tc <= 1'b0;
    else if (ctrl_done && (pll_timeout_ctr == PLL_TIMEOUT -2))
        pll_timeout_ctr_tc <= 1'b1;
end
     
// channel counter
always @(posedge clk)
begin
    if (reset)
        ctrl_chan <= 7'h00;
    else if (((state == STATE_RD_PHY_ID)  && ctrl_done &&  ctrl_chan_err) ||
             ((state == STATE_RD_PHY_ID)  && ctrl_done && !phy_id) ||
             ((state == STATE_WR_EYE_OFF) && ctrl_done))  
                    
        ctrl_chan <= ctrl_chan + 1'b1;
end
  
assign ctrl_chan_tc = (ctrl_chan == NUM_OF_CHANNELS -1);

// data path
// c = sum A - sum B
assign sgn_sum_a = $signed({1'b0, align_sum_a});
assign sgn_sum_b = $signed({1'b0, align_sum_b});

always @(posedge clk)
begin
    c <= sgn_sum_a - sgn_sum_b;
end

// d = "golden reference"
always @(posedge clk)
begin
    if ((state == STATE_RD_VCO_OFF) && ctrl_done)
        d <= c;
end

// e = "golden reference" - (sum A - sum B)  
// e = d - c 
always @(posedge clk)
begin
    e <= d - c;
end

// absolute value e
always @(posedge clk)
begin
    if (e[8])
        e_abs <= -e;
    else   
        e_abs <=  e;
end

// compare best_e to current e
always @(posedge clk)
begin
    best_greater_than_e <= (best_e_value > e_abs);
end

// save the lowest (best) e value and dcd counter value
always @(posedge clk)
begin
    if ((state == STATE_RD_DCD) && ctrl_done)
        begin
            best_e_value <= 8'hff; 
            best_dcd_ctr <= 3'h0;
        end
    else if (best_greater_than_e && align_done_ff[3])
        begin 
            best_e_value <= e_abs;
            best_dcd_ctr <= dcd_ctr;
        end
end

// register data
// save read dcd register for RMW 
always @(posedge clk)
begin
    if ((state == STATE_RD_DCD) && ctrl_done)
         dcd_rdata <= ctrl_rdata;
end 
 
// dcd register counter 
always @(posedge clk)
begin
    if  ((state == STATE_RD_DCD) && ctrl_done)
        dcd_ctr <= 3'h0;
    else if  ((state == STATE_ALIGN_DCD) && align_done_ff[3])
        dcd_ctr <= dcd_ctr + 1'b1;
end
 
assign dcd_ctr_tc = (dcd_ctr == 3'h6);
 
// ctrl_wdata 
always @(posedge clk)
begin
    ctrl_wdata <= ctrl_rdata;
    case (state)
        STATE_WR_VCO_ON:   ctrl_wdata[RCRU_RCLK_MON_OFST]  <=  VCO_DATA_SEL;
        
        STATE_WR_LOOP_ON:  begin 
                               ctrl_wdata <= 16'h0000;
                               ctrl_wdata[SV_XR_SLPBK_SLPBKEN_OFST]
                                                           <=  PHY_LPBK;
                           end
          
        STATE_WR_PDB_ON:   begin
                               ctrl_wdata[REYE_PDB]        <= REYE_PDB_ON;
                               ctrl_wdata[REYE_ISEL_2:REYE_ISEL_0]
                                                           <= REYE_ISEL_ON; 
                           end                                            
                                   
        STATE_WR_EYE_ON:   ctrl_wdata[RCRU_EYE_OFST]       <=  EYE_MON_SEL;
        STATE_WR_VCO_OFF:  ctrl_wdata[RCRU_RCLK_MON_OFST]  <= ~VCO_DATA_SEL;
        STATE_WR_VCO_OFF2: ctrl_wdata[RCRU_RCLK_MON_OFST]  <= ~VCO_DATA_SEL;
        STATE_WR_TEST_ON:  ctrl_wdata[RSER_CLK_MON_OFST]   <=  FORCED_DATA_EN;
        
        STATE_WR_DCD:      begin
                               ctrl_wdata                  <=  dcd_rdata;
                               ctrl_wdata[RSER_DC_TUNE_2_OFST : RSER_DC_TUNE_0_OFST]
                                                           <=  dcd_ctr;
                           end
                                                          
        STATE_WR_BEST:     begin
                               ctrl_wdata                  <=  dcd_rdata;
                               ctrl_wdata[RSER_DC_TUNE_2_OFST : RSER_DC_TUNE_0_OFST] 
                                                           <=  best_dcd_ctr;
                           end
                           
                                  
        STATE_WR_PDB_OFF:  begin
                               ctrl_wdata[REYE_PDB]        <= ~REYE_PDB_ON;
                               ctrl_wdata[REYE_ISEL_2:REYE_ISEL_0]
                                                           <=  REYE_ISEL_OFF;
                           end                                               
       
        
        STATE_WR_TEST_OFF: ctrl_wdata[RSER_CLK_MON_OFST]   <= ~FORCED_DATA_EN;
                                                          
        STATE_WR_LOOP_OFF: begin 
                               ctrl_wdata <= 16'h0000;
                               ctrl_wdata[SV_XR_SLPBK_SLPBKEN_OFST]
                                                           <=  ~PHY_LPBK;
                           end
                           
        STATE_WR_EYE_OFF:  ctrl_wdata[RCRU_EYE_OFST]       <= ~EYE_MON_SEL;
        
        default:           ctrl_wdata                      <=  16'h0000;
    endcase
end
 
 // ctrl_addr 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:         ctrl_addr <= 11'h000;
        STATE_RD_PHY_ID:    ctrl_addr <= SV_XR_ABS_ADDR_ID;
        STATE_RD_VCO_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_WR_VCO_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_WR_LOOP_ON:   ctrl_addr <= SV_XR_ABS_ADDR_SLPBK;
        STATE_RD_PDB_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_WR_PDB_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_RD_EYE_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_EYE;
        STATE_WR_EYE_ON:    ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_EYE;
        STATE_WAIT_PLL:     ctrl_addr <= SV_XR_ABS_ADDR_STATUS;
        STATE_ALIGN_D:      ctrl_addr <= 11'h000;
        STATE_RD_VCO_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_WR_VCO_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_RD_VCO_OFF2:  ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_WR_VCO_OFF2:  ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_RCLK_MON;
        STATE_RD_TEST_ON:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RSER_CLK_MON;
        STATE_WR_TEST_ON:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RSER_CLK_MON;
        STATE_WAIT_PLL2:    ctrl_addr <= SV_XR_ABS_ADDR_STATUS;
        STATE_RD_DCD:       ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_WR_DCD:       ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_ALIGN_DCD:    ctrl_addr <= 11'h000;    
        STATE_WR_BEST:      ctrl_addr <= RECONFIG_PMA_CH0_DCD_DC_TUNE;
        STATE_ALIGN_BEST:   ctrl_addr <= 11'h000; 
        STATE_RD_PDB_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_WR_PDB_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_RD_TEST_OFF:  ctrl_addr <= RECONFIG_PMA_CH0_DCD_RSER_CLK_MON;
        STATE_WR_TEST_OFF:  ctrl_addr <= RECONFIG_PMA_CH0_DCD_RSER_CLK_MON;
        STATE_WR_LOOP_OFF:  ctrl_addr <= SV_XR_ABS_ADDR_SLPBK;
        STATE_RD_EYE_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_EYE;
        STATE_WR_EYE_OFF:   ctrl_addr <= RECONFIG_PMA_CH0_DCD_RCRU_EYE;
        STATE_DONE:         ctrl_addr <= 11'h000;
        default:            ctrl_addr <= 11'h000;
    endcase
end    
    
// ctrl_opcode 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:        ctrl_opcode <= 3'h0;
        STATE_RD_PHY_ID:   ctrl_opcode <= OPCODE_READ;
        STATE_RD_VCO_ON:   ctrl_opcode <= OPCODE_READ;
        STATE_WR_VCO_ON:   ctrl_opcode <= OPCODE_WRITE;
        STATE_WR_LOOP_ON:  ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_PDB_ON:   ctrl_opcode <= OPCODE_READ;
        STATE_WR_PDB_ON:   ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_EYE_ON:   ctrl_opcode <= OPCODE_READ;
        STATE_WR_EYE_ON:   ctrl_opcode <= OPCODE_WRITE;
        STATE_WAIT_PLL:    ctrl_opcode <= OPCODE_READ;
        STATE_ALIGN_D:     ctrl_opcode <= 3'h0;
        STATE_RD_VCO_OFF:  ctrl_opcode <= OPCODE_READ;
        STATE_WR_VCO_OFF:  ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_VCO_OFF2: ctrl_opcode <= OPCODE_READ;
        STATE_WR_VCO_OFF2: ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_TEST_ON:  ctrl_opcode <= OPCODE_READ;
        STATE_WR_TEST_ON:  ctrl_opcode <= OPCODE_WRITE;
        STATE_WAIT_PLL2:   ctrl_opcode <= OPCODE_READ;
        STATE_RD_DCD:      ctrl_opcode <= OPCODE_READ;
        STATE_WR_DCD:      ctrl_opcode <= OPCODE_WRITE;
        STATE_ALIGN_DCD:   ctrl_opcode <= 3'h0;    
        STATE_WR_BEST:     ctrl_opcode <= OPCODE_WRITE;
        STATE_ALIGN_BEST:  ctrl_opcode <= 3'h0;
        STATE_RD_PDB_OFF:  ctrl_opcode <= OPCODE_READ;
        STATE_WR_PDB_OFF:  ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_TEST_OFF: ctrl_opcode <= OPCODE_READ;
        STATE_WR_TEST_OFF: ctrl_opcode <= OPCODE_WRITE;
        STATE_WR_LOOP_OFF: ctrl_opcode <= OPCODE_WRITE;
        STATE_RD_EYE_OFF:  ctrl_opcode <= OPCODE_READ;
        STATE_WR_EYE_OFF:  ctrl_opcode <= OPCODE_WRITE;
        STATE_DONE:        ctrl_opcode <= 3'h0;
    endcase
end       
    
// ctrl_go 
always @(posedge clk)
begin
    if (reset)
        ctrl_go_ff <= 1'b0; 
    else 
        case (state)
            STATE_IDLE:        ctrl_go_ff <=  ~hold_sync;
            STATE_RD_PHY_ID:   ctrl_go_ff <=  ctrl_done & ~ctrl_chan_err & phy_id;
            STATE_RD_VCO_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_WR_VCO_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_WR_LOOP_ON:  ctrl_go_ff <=  ctrl_done;
            STATE_RD_PDB_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_WR_PDB_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_RD_EYE_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_WR_EYE_ON:   ctrl_go_ff <=  ctrl_done;
            STATE_WAIT_PLL:    ctrl_go_ff <=  ctrl_done & phy_reset;
            STATE_ALIGN_D:     ctrl_go_ff <=  align_done_ff[3];
            STATE_RD_VCO_OFF:  ctrl_go_ff <=  ctrl_done;
            STATE_WR_VCO_OFF:  ctrl_go_ff <=  ctrl_done;
            STATE_RD_VCO_OFF2: ctrl_go_ff <=  ctrl_done;
            STATE_WR_VCO_OFF2: ctrl_go_ff <=  ctrl_done;
            STATE_RD_TEST_ON:  ctrl_go_ff <=  ctrl_done;
            STATE_WR_TEST_ON:  ctrl_go_ff <=  ctrl_done;
            STATE_WAIT_PLL2:   ctrl_go_ff <=  ctrl_done;
            STATE_RD_DCD:      ctrl_go_ff <=  ctrl_done;
            STATE_WR_DCD:      ctrl_go_ff <=  1'b0;
            STATE_ALIGN_DCD:   ctrl_go_ff <=  align_done_ff[3];   
            STATE_WR_BEST:     ctrl_go_ff <=  1'b0;
            STATE_RD_PDB_OFF:  ctrl_go_ff <=  ctrl_done;
            STATE_WR_PDB_OFF:  ctrl_go_ff <=  ctrl_done;
            STATE_ALIGN_BEST:  ctrl_go_ff <=  align_done_ff[3];
            STATE_RD_TEST_OFF: ctrl_go_ff <=  ctrl_done;
            STATE_WR_TEST_OFF: ctrl_go_ff <=  ctrl_done;
            STATE_WR_LOOP_OFF: ctrl_go_ff <=  ctrl_done;
            STATE_RD_EYE_OFF:  ctrl_go_ff <=  ctrl_done;
            STATE_WR_EYE_OFF:  ctrl_go_ff <=  1'b0;
            STATE_DONE:        ctrl_go_ff <=  1'b0;
            default:           ctrl_go_ff <=  1'b0;
        endcase
end          

// delay GO to create setup time 
always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0;
    else 
        ctrl_go <= ctrl_go_ff;
end 
    
// ctrl_lock
always @(posedge clk)
begin
    ctrl_lock <= ~( (state == STATE_IDLE) |
                    (state == STATE_RD_PHY_ID)  |
                    (state == STATE_WR_EYE_OFF) |
                    (state == STATE_DONE) );
end 

// ctrl_sel 
// multiplex Basic Block I/F align and control signals
always @(posedge clk)
begin
    ctrl_sel <= (state == STATE_ALIGN_D) |
                (state == STATE_ALIGN_DCD) |
                (state == STATE_ALIGN_BEST);
end
                
// align_go  
always @(posedge clk)
begin
     align_go <= ((state == STATE_WAIT_PLL) & ~phy_reset & ctrl_done) |
                 ((state == STATE_WR_DCD)   & ctrl_done) |
                 ((state == STATE_WR_BEST)  & ctrl_done);
end 

// delay align_ack to match data pipeline delay
always @(posedge clk)
begin
     align_done_ff <= {align_done_ff[2:0], align_done};
end
                
// user busy    
always @(posedge clk)
begin
    if (reset)
        user_busy <= 1'b1;
    else
  //    user_busy <= ((state != STATE_DONE) & (state != STATE_IDLE)) |
  //                   ((state != STATE_DONE) & ~hold_sync);
        user_busy <=  (state != STATE_DONE);       
end       

endmodule
