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


// DCD get sum
//
// Module writes the offset to REYE_MON PHY register
// and reads the new SUM A and SUM B from the DCD accumulators.
 
module alt_xcvr_reconfig_dcd_get_sum (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        go,
    output reg         done,
    
    input  wire [5:0]  offset,
    output reg  [7:0]  sum_a,
    output reg  [7:0]  sum_b,
    
    // basic interface 
    output reg         ctrl_go,
    input  wire        ctrl_done,
    output reg  [11:0] ctrl_addr,
    output reg  [2:0]  ctrl_opcode,
    output reg  [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata
  );  

// state machine  
localparam [2:0] STATE_IDLE      = 3'b000;
localparam [2:0] STATE_RD_OFFSET = 3'b001;
localparam [2:0] STATE_WR_OFFSET = 3'b010;
localparam [2:0] STATE_REQ_ON    = 3'b011;
localparam [2:0] STATE_ACK       = 3'b100;
localparam [2:0] STATE_REQ_OFF   = 3'b101;
localparam [2:0] STATE_SUM       = 3'b110;

// register opcodes
localparam       CTRL_OP_RD   = 3'b000;
localparam       CTRL_OP_WR   = 3'b001;

// register addresses
import sv_xcvr_h::*;
localparam        SV_XR_DCD_RES_A_OFST_7 = SV_XR_DCD_RES_A_OFST + 7; // sum a msb
localparam        SV_XR_DCD_RES_B_OFST_7 = SV_XR_DCD_RES_B_OFST + 7; // sum b msb

reg  [2:0]  state;
reg         ctrl_go_ff;

// state machine 
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
       case (state)
            STATE_IDLE:      if (go)
                               state <= STATE_RD_OFFSET;
                             
            // write ofsset (RMW)
            STATE_RD_OFFSET: if (ctrl_done)
                                 state <= STATE_WR_OFFSET;
           
            STATE_WR_OFFSET: if (ctrl_done)
                                 state <= STATE_REQ_ON; 
         
             // assert request   
            STATE_REQ_ON:    if (ctrl_done)
                                 state <= STATE_ACK;
          
            // wait for ack          
            STATE_ACK:       if (ctrl_done && ctrl_rdata[SV_XR_DCD_ACK_OFST])
                                 state <= STATE_REQ_OFF;
         
            // negate request          
            STATE_REQ_OFF:   if (ctrl_done)
                                 state <= STATE_SUM;                
           
            // read sum A and sum B
            STATE_SUM:       if (ctrl_done)
                                 state <= STATE_IDLE;
            
            default:         state <= STATE_IDLE; 
       endcase
end

// ctrl_addr 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:      ctrl_addr <= 11'h000;
        STATE_RD_OFFSET: ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_WR_OFFSET: ctrl_addr <= RECONFIG_PMA_CH0_DCD_REYE_MON;
        STATE_REQ_ON:    ctrl_addr <= SV_XR_ABS_ADDR_DCD;
        STATE_ACK:       ctrl_addr <= SV_XR_ABS_ADDR_DCD;
        STATE_REQ_OFF:   ctrl_addr <= SV_XR_ABS_ADDR_DCD; 
        STATE_SUM:       ctrl_addr <= SV_XR_ABS_ADDR_DCD_RES;
        default:         ctrl_addr <= 11'h000;
    endcase
end 

// ctrl_go 
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:      ctrl_go_ff <= go;
        STATE_RD_OFFSET: ctrl_go_ff <= ctrl_done;
        STATE_WR_OFFSET: ctrl_go_ff <= ctrl_done;
        STATE_REQ_ON:    ctrl_go_ff <= ctrl_done;
        STATE_ACK:       ctrl_go_ff <= ctrl_done;
        STATE_REQ_OFF:   ctrl_go_ff <= ctrl_done; 
        STATE_SUM:       ctrl_go_ff <= 1'b0;
        default:         ctrl_go_ff <= 1'b0;
    endcase
end 

// delay ctrl_go for data, opcode and address setup
always @(posedge clk)
begin
    if (reset)
        ctrl_go <= 1'b0;
    else 
        ctrl_go <= ctrl_go_ff;
end  
        
// ctrl_opcode
always @(posedge clk)
begin
    case (state)
        STATE_IDLE:      ctrl_opcode <= 3'b000;
        STATE_RD_OFFSET: ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_OFFSET: ctrl_opcode <= CTRL_OP_WR;
        STATE_REQ_ON:    ctrl_opcode <= CTRL_OP_WR;
        STATE_ACK:       ctrl_opcode <= CTRL_OP_RD;
        STATE_REQ_OFF:   ctrl_opcode <= CTRL_OP_WR; 
        STATE_SUM:       ctrl_opcode <= CTRL_OP_RD;
        default:         ctrl_opcode <= 1'b0;
    endcase
end 

// ctrl_wdata     
always @(posedge clk)
begin
    ctrl_wdata <= 16'h0000;
    case (state)
        STATE_IDLE:      ctrl_wdata   <= 16'h00;
          STATE_RD_OFFSET: ctrl_wdata <= 16'h00;
          
        STATE_WR_OFFSET: begin
                               ctrl_wdata <= ctrl_rdata;
                               ctrl_wdata[REYE_MON_5_OFST : REYE_MON_0_OFST] <= offset;
                         end
                                 
        STATE_REQ_ON:    ctrl_wdata[SV_XR_DCD_REQ_OFST] <= 1'b1;
        STATE_ACK:       ctrl_wdata                     <= 16'h0000;
        STATE_REQ_OFF:   ctrl_wdata[SV_XR_DCD_REQ_OFST] <= 1'b0; 
        STATE_SUM:       ctrl_wdata                     <= 16'h0000;
        default:         ctrl_wdata                     <= 16'h0000;
    endcase
end 

// sum A/sum B
always @(posedge clk)
begin 
    if ((state == STATE_SUM) && ctrl_done) 
        sum_a <= ctrl_rdata[SV_XR_DCD_RES_A_OFST_7 : SV_XR_DCD_RES_A_OFST];
        sum_b <= ctrl_rdata[SV_XR_DCD_RES_B_OFST_7 : SV_XR_DCD_RES_B_OFST];
end

// done
always @(posedge clk)
begin
    if (reset)
       done <= 1'b0;
    else 
       done <= (state == STATE_SUM) & ctrl_done;
end  

endmodule
