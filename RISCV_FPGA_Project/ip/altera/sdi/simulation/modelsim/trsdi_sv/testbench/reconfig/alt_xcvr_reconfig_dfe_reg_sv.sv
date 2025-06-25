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


// dfe register control
//
// This module handles remapping and rearranging DFE hardware
// registers to a nicer format for the user. 
//
// It receives user indirect registers from ALT_XRECONF_UIF and
// it generates write and read cycles to the ALT_XRECONF_BASIC.
//
// User writes to the control register are handled by the calibration
// module. (alt_xcvr_reconfig_dfe_cal_sv) 

module alt_xcvr_reconfig_dfe_reg_sv (
    input  wire        clk,
    input  wire        reset,
   
    // user interface
    input  wire        uif_go,       // start user cycle
    input  wire [2:0]  uif_mode,     // operation
    output reg         uif_busy,     // transfer in process
    input  wire [5:0]  uif_addr,     // address offset
    input  wire [15:0] uif_wdata,    // data in
    output reg  [15:0] uif_rdata,    // data out
    input  wire        uif_chan_err, // illegal channel
    output reg         uif_addr_err, // illegal address
   
    // basic block control interface
    output reg         ctrl_go,      // start basic block cycle
    output reg  [2:0]  ctrl_opcode,  // operation;
    output reg         ctrl_lock,    // multicycle lock 
    input  wire        ctrl_wait,    // transfer in process
    output reg  [11:0] ctrl_addr,
    input  wire [15:0] ctrl_rdata,   // data in
    output reg  [15:0] ctrl_wdata    // data out
);

parameter HIDDEN_REG_EN = 1'b1;

// done state machine
localparam [1:0] STATE_DONE0  = 2'b00;
localparam [1:0] STATE_DONE1  = 2'b01;
localparam [1:0] STATE_DONE2  = 2'b10;

// Control state assignments
localparam [2:0] STATE_IDLE = 3'b000;
localparam [2:0] STATE_WR2  = 3'b001;
localparam [2:0] STATE_WW2  = 3'b010;
localparam [2:0] STATE_WR1  = 3'b011;
localparam [2:0] STATE_WW1  = 3'b100;
localparam [2:0] STATE_R2   = 3'b101;
localparam [2:0] STATE_R1   = 3'b110;

// user modes
localparam UIF_RDFE_MODE_RD   = 3'h0;
localparam UIF_RDFE_MODE_WR   = 3'h1;
localparam UIF_RDFE_MODE_PHYS = 3'h2;

// basic control commands
localparam CTRL_RDFE_OP_RD = 3'h0;
localparam CTRL_RDFE_OP_WR = 3'h1;

// user bits
// control reg
localparam UIF_RDFE_ADAPT = 0;
localparam UIF_RDFE_PDB   = 1;
// tap 1 reg
localparam UIF_RDFE_T1_0  = 0; // bit 0
localparam UIF_RDFE_T1_1  = 1; // bit 1
localparam UIF_RDFE_T1_2  = 2; // bit 2
localparam UIF_RDFE_T1_3  = 3; // bit 3
// tap 2 reg
localparam UIF_RDFE_T2_0  = 0;
localparam UIF_RDFE_T2_1  = 1;
localparam UIF_RDFE_T2_2  = 2;
localparam UIF_RDFE_T2INV = 3;
// tap 3 reg
localparam UIF_RDFE_T3_0  = 0;
localparam UIF_RDFE_T3_1  = 1;
localparam UIF_RDFE_T3_2  = 2;
localparam UIF_RDFE_T3INV = 3;
// tap 4 reg
localparam UIF_RDFE_T4_0  = 0;
localparam UIF_RDFE_T4_1  = 1;
localparam UIF_RDFE_T4_2  = 2;
localparam UIF_RDFE_T4INV = 3;
// tap 5 reg
localparam UIF_RDFE_T5_0   = 0;
localparam UIF_RDFE_T5_1   = 1;
localparam UIF_RDFE_T5INV  = 2;
// reference reg
localparam UIF_RDFE_VREF_0 = 0;
localparam UIF_RDFE_VREF_1 = 1;
localparam UIF_RDFE_VREF_2 = 2;
localparam UIF_RDFE_CKEN   = 3;
localparam UIF_RDFE_FREQ_0 = 4;
localparam UIF_RDFE_FREQ_1 = 5;
// step
localparam UIF_RDFE_PIEN   = 0;
localparam UIF_RDFE_S0D    = 1;
localparam UIF_RDFE_S90D   = 2;
localparam UIF_RDFE_STEP_0 = 3;
localparam UIF_RDFE_STEP_1 = 4;
localparam UIF_RDFE_STEP_2 = 5;
localparam UIF_RDFE_STEP_3 = 6;

// dfe hardware bits
// reg 11
localparam CTRL_RDFE_T1_0  = 0;  // tap 1 bit 0
localparam CTRL_RDFE_T1_1  = 1;  // tap 1 bit 1
localparam CTRL_RDFE_T1_2  = 2;  // tap 1 bit 2
localparam CTRL_RDFE_T1_3  = 3;  // tap 1 bit 3
localparam CTRL_RDFE_T2_0  = 4;  // tap 2
localparam CTRL_RDFE_T2_1  = 5;
localparam CTRL_RDFE_T2_2  = 6;
localparam CTRL_RDFE_T3_0  = 7;
localparam CTRL_RDFE_T3_1  = 8;  // tap 3
localparam CTRL_RDFE_T3_2  = 9;
localparam CTRL_RDFE_T4_0  = 10;
localparam CTRL_RDFE_T4_1  = 11; // tap 4
localparam CTRL_RDFE_T4_2  = 12;
localparam CTRL_RDFE_T5_0  = 13; // tap 5
localparam CTRL_RDFE_T5_1  = 14;
localparam CTRL_RDFE_ADAPT = 15; // adapt en
// reg 12
localparam CTRL_RDFE_CKEN   = 0; // VCO clk
localparam CTRL_RDFE_FREQ_0 = 1; // bandwidth
localparam CTRL_RDFE_FREQ_1 = 2;
localparam CTRL_RDFE_PDB    = 7; // power
// reg 13
localparam CTRL_RDFE_PIEN   = 1;
localparam CTRL_RDFE_S0D    = 2; // step
localparam CTRL_RDFE_S90D   = 3;
localparam CTRL_RDFE_STEP_0 = 5; 
localparam CTRL_RDFE_STEP_1 = 6;
localparam CTRL_RDFE_STEP_2 = 7;
localparam CTRL_RDFE_STEP_3 = 8;
localparam CTRL_RDFE_T2INV  = 9;  // polarity
localparam CTRL_RDFE_T3INV  = 10;
localparam CTRL_RDFE_T4INV  = 11;
localparam CTRL_RDFE_T5INV  = 12;
localparam CTRL_RDFE_VREF_0 = 13; // reference
localparam CTRL_RDFE_VREF_1 = 14;
localparam CTRL_RDFE_VREF_2 = 15;

// register addresses
import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*;

// declarations
reg  [1:0]  state_done;
wire        ctrl_done;
reg  [3:0]  next_state;
reg  [3:0]  state;
reg         first_cycle;
reg         ctrl_go_ff1;
reg         ctrl_go_ff2;
reg         uif_rdata_ld;
reg  [15:0] uif_rdata_mux;
reg  [6:0]  reset_ff;
wire        reset_sync;

// creating CTRL_DONE from CTRL_WAIT
always @(posedge clk)
begin
    if (reset_sync)
        state_done <= STATE_DONE0;
    else
        case (state_done)
            STATE_DONE0:    if (ctrl_go)   // wait for ctrl_go
                                state_done <= STATE_DONE1;

            STATE_DONE1:    if (!ctrl_wait) // wait for ctlr_wait to negate               
                                state_done <= STATE_DONE2; 
                            
             // generate ctrl_done for 1 clock period
            STATE_DONE2:    state_done <= STATE_DONE0; 
       endcase
end

assign ctrl_done = (state_done == STATE_DONE2);

// control state machine
always @(*)
begin
    case (state)
       // wait for user request
        STATE_IDLE:
            if (uif_go && !HIDDEN_REG_EN && (uif_mode == UIF_RDFE_MODE_WR)) 
                case (uif_addr)
                   XR_DFE_OFFSET_TAP1:  next_state = STATE_WR1;  // single rmw
                   XR_DFE_OFFSET_TAP2:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP3:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP4:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP5:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_REF:   next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_STEP:  next_state = STATE_WR1;  // single rmw
                   default:             next_state = STATE_IDLE;
                endcase
           else if (uif_go && !HIDDEN_REG_EN && (uif_mode == UIF_RDFE_MODE_RD)) 
                case (uif_addr)
                   XR_DFE_OFFSET_CTRL:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP1:  next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_TAP2:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP3:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP4:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP5:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_REF:   next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_STEP:  next_state = STATE_R1;   // single read
                   default:             next_state = STATE_IDLE;
               endcase  
           else if (uif_go && HIDDEN_REG_EN && (uif_mode == UIF_RDFE_MODE_WR)) 
                case (uif_addr)
                   XR_DFE_OFFSET_TAP1:  next_state = STATE_WR1;  // single rmw
                   XR_DFE_OFFSET_TAP2:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP3:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP4:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_TAP5:  next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_REF:   next_state = STATE_WR2;  // double rmw
                   XR_DFE_OFFSET_STEP:  next_state = STATE_WR1;  // single rmw
                   XR_DFE_OFFSET_DFE12: next_state = STATE_WW1;  // single write 
                   XR_DFE_OFFSET_DFE13: next_state = STATE_WW1;  // single write
                   XR_DFE_OFFSET_DFE14: next_state = STATE_WW1;  // single write
                   XR_DFE_OFFSET_DFE15: next_state = STATE_WW1;  // single write
                   default:             next_state = STATE_IDLE;
                endcase
           else if (uif_go && HIDDEN_REG_EN && (uif_mode == UIF_RDFE_MODE_RD)) 
                case (uif_addr)
                   XR_DFE_OFFSET_CTRL:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP1:  next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_TAP2:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP3:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP4:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_TAP5:  next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_REF:   next_state = STATE_R2;   // double read
                   XR_DFE_OFFSET_STEP:  next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_DFE12: next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_DFE13: next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_DFE14: next_state = STATE_R1;   // single read
                   XR_DFE_OFFSET_DFE15: next_state = STATE_R1;   // single read
                  default:              next_state = STATE_IDLE;
               endcase  
          else next_state = STATE_IDLE;
           
       // User writes are multiple read-modify-write cycles to Basic block 
       // RMW1 read cycle
       STATE_WR2:     if (ctrl_done)
                           next_state = STATE_WW2;
                      else
                           next_state = STATE_WR2;
       
       // RMW1 write cycle
       STATE_WW2:     if (ctrl_done)
                           next_state = STATE_WR1;
                      else
                           next_state = STATE_WW2;
             
       // RMW2 read cycle
       STATE_WR1:     if (ctrl_done)
                           next_state = STATE_WW1;
                      else
                           next_state = STATE_WR1;
      
       // RMW2 write cycle      
       STATE_WW1:     if (ctrl_done)
                           next_state = STATE_IDLE;
                      else
                           next_state = STATE_WW1;
      
   
       // User reads are multiple reads to the basic block
       // Read cycle 1
       STATE_R2:      if (ctrl_done)
                           next_state = STATE_R1;
                      else
                           next_state = STATE_R2;
      
       // Read cycle 2   
       STATE_R1:      if (ctrl_done)
                           next_state = STATE_IDLE;
                      else
                           next_state = STATE_R1;

       default:       next_state = STATE_IDLE;
  
    endcase     
end

// present state
always @(posedge clk)
begin
    if (reset_sync)
       state <= STATE_IDLE;
    else if (uif_chan_err && ctrl_done)
       state <= STATE_IDLE;
    else
       state <= next_state;
end

// outputs
always @(posedge clk)
begin
    if (reset_sync)
        begin
            uif_busy      <= 1'b0;
            ctrl_go       <= 1'b0;
            ctrl_go_ff1   <= 1'b0;
            ctrl_go_ff2   <= 1'b0;
            ctrl_lock     <= 1'b0;
            ctrl_opcode   <= 1'b0;
            first_cycle   <= 1'b0;
            uif_rdata_ld  <= 1'b0;
            uif_addr_err  <= 1'b0;
        end
    else
        begin
            // busy to user  
            uif_busy <= (next_state != STATE_IDLE); 
            
            // go to basic             
            ctrl_go_ff1  <= uif_go & (uif_addr == XR_DFE_OFFSET_CTRL) & 
                                     (uif_mode == UIF_RDFE_MODE_RD)    | // writes handled by dfe_cal module
                            uif_go & (uif_addr == XR_DFE_OFFSET_TAP1)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_TAP2)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_TAP3)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_TAP4)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_TAP5)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_REF)   |
                            uif_go & (uif_addr == XR_DFE_OFFSET_STEP)  |
                            uif_go & (uif_addr == XR_DFE_OFFSET_DFE12) |
                            uif_go & (uif_addr == XR_DFE_OFFSET_DFE13) |
                            uif_go & (uif_addr == XR_DFE_OFFSET_DFE14) |
                            uif_go & (uif_addr == XR_DFE_OFFSET_DFE15);
                            
             ctrl_go_ff2  <= (state == STATE_WR2)  & ctrl_done |
                             (state == STATE_WW2)  & ctrl_done |
                             (state == STATE_WR1)  & ctrl_done |
                             (state == STATE_R2)   & ctrl_done;
            
            //delay for address setup 
            ctrl_go      <= ctrl_go_ff1 | ctrl_go_ff2;
                      
            // lock to basic     
            ctrl_lock    <= (next_state == STATE_WR2) |
                            (next_state == STATE_WW2) |
                            (next_state == STATE_WR1) |
                            (next_state == STATE_R2); 
           
            // opcode to basic
            if ((next_state == STATE_WW2) || (next_state == STATE_WW1))
                ctrl_opcode <= CTRL_RDFE_OP_WR;
            else   
                ctrl_opcode <= CTRL_RDFE_OP_RD;
                
            // look up table select for first of 2 cycles
            first_cycle <= (next_state == STATE_WR2) |
                           (next_state == STATE_WW2) |  
                           (next_state == STATE_R2);
                           
            // load user read data              
            uif_rdata_ld  <= ((state == STATE_R1) & ctrl_done) |
                             ((state == STATE_R2) & ctrl_done);
                      
            // illegal address
            if (uif_go) 
                case (uif_addr)
                    XR_DFE_OFFSET_CTRL:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_TAP1:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_TAP2:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_TAP3:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_TAP4:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_TAP5:  uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_REF:   uif_addr_err <= 1'b0;
                    XR_DFE_OFFSET_STEP:  uif_addr_err <= 1'b0;
             
                    XR_DFE_OFFSET_DFE12: uif_addr_err <= ~HIDDEN_REG_EN;
                    XR_DFE_OFFSET_DFE13: uif_addr_err <= ~HIDDEN_REG_EN;
                    XR_DFE_OFFSET_DFE14: uif_addr_err <= ~HIDDEN_REG_EN;
                    XR_DFE_OFFSET_DFE15: uif_addr_err <= ~HIDDEN_REG_EN;
                    default:             uif_addr_err <= 1'b1;
                 endcase
        end
end

// ctrl_address 
always @(posedge clk)
 begin 
    if (first_cycle)
         case (uif_addr)
             XR_DFE_OFFSET_CTRL:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // adapt en
             XR_DFE_OFFSET_TAP2:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // coef 2 
             XR_DFE_OFFSET_TAP3:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // coef 3
             XR_DFE_OFFSET_TAP4:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // coef 4
             XR_DFE_OFFSET_TAP5:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // coef 5
             XR_DFE_OFFSET_REF:   ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // ref
         endcase
     else
         case (uif_addr)
             XR_DFE_OFFSET_CTRL:  ctrl_addr <= RECONFIG_PMA_CH0_DFE12; // power
             XR_DFE_OFFSET_TAP1:  ctrl_addr <= RECONFIG_PMA_CH0_DFE11; // coef 1
             XR_DFE_OFFSET_TAP2:  ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // pol 2
             XR_DFE_OFFSET_TAP3:  ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // pol 3
             XR_DFE_OFFSET_TAP4:  ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // pol 4
             XR_DFE_OFFSET_TAP5:  ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // pol 5
             XR_DFE_OFFSET_REF:   ctrl_addr <= RECONFIG_PMA_CH0_DFE12; // cken, freq
             XR_DFE_OFFSET_STEP:  ctrl_addr <= RECONFIG_PMA_CH0_DFE13; // step
             
             XR_DFE_OFFSET_DFE12: ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
             XR_DFE_OFFSET_DFE13: ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
             XR_DFE_OFFSET_DFE14: ctrl_addr <= RECONFIG_PMA_CH0_DFE14;
             XR_DFE_OFFSET_DFE15: ctrl_addr <= RECONFIG_PMA_CH0_DFE15;
             default:             ctrl_addr <= 4'd0;
         endcase
end

// basic write data
always @(posedge clk)
begin
    ctrl_wdata <= ctrl_rdata;
    if (first_cycle)
        case (uif_addr)
                                                    
            XR_DFE_OFFSET_TAP2:  ctrl_wdata[CTRL_RDFE_T2_2 : CTRL_RDFE_T2_0]   
                                  <= uif_wdata[UIF_RDFE_T2_2 : UIF_RDFE_T2_0];
                                            
            XR_DFE_OFFSET_TAP3:  ctrl_wdata[CTRL_RDFE_T3_2 : CTRL_RDFE_T3_0]   
                                  <= uif_wdata[UIF_RDFE_T3_2 : UIF_RDFE_T3_0];
                                            
            XR_DFE_OFFSET_TAP4:  ctrl_wdata[CTRL_RDFE_T4_2 : CTRL_RDFE_T4_0]
                                  <= uif_wdata[UIF_RDFE_T4_2 : UIF_RDFE_T4_0];
                                            
            XR_DFE_OFFSET_TAP5:  ctrl_wdata[CTRL_RDFE_T5_1 : CTRL_RDFE_T5_0]   
                                  <= uif_wdata[UIF_RDFE_T5_1 : UIF_RDFE_T5_0];
            
            XR_DFE_OFFSET_REF:   ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                  <= uif_wdata[UIF_RDFE_VREF_2 : UIF_RDFE_VREF_0];
        endcase
    else
        case (uif_addr)
                                                  
            XR_DFE_OFFSET_TAP1:  ctrl_wdata[CTRL_RDFE_T1_3 : CTRL_RDFE_T1_0]
                                  <= uif_wdata[UIF_RDFE_T1_3 : UIF_RDFE_T1_0];
                                            
            XR_DFE_OFFSET_TAP2:  ctrl_wdata[CTRL_RDFE_T2INV]
                                  <= uif_wdata[UIF_RDFE_T2INV];
                                            
            XR_DFE_OFFSET_TAP3:  ctrl_wdata[CTRL_RDFE_T3INV]
                                  <= uif_wdata[UIF_RDFE_T3INV];
                                            
            XR_DFE_OFFSET_TAP4:  ctrl_wdata[CTRL_RDFE_T4INV]
                                  <= uif_wdata[UIF_RDFE_T4INV];
                                            
            XR_DFE_OFFSET_TAP5:  ctrl_wdata[CTRL_RDFE_T5INV]
                                  <= uif_wdata[UIF_RDFE_T5INV];
                                            
            XR_DFE_OFFSET_REF:   begin
                                     ctrl_wdata[CTRL_RDFE_CKEN]   
                                       <= uif_wdata[UIF_RDFE_CKEN];
                                  
                                     ctrl_wdata[CTRL_RDFE_FREQ_1 : CTRL_RDFE_FREQ_0]   
                                       <= uif_wdata[UIF_RDFE_FREQ_1 : UIF_RDFE_FREQ_0];
                                 end                    
           
            XR_DFE_OFFSET_STEP:  begin
                                     ctrl_wdata[CTRL_RDFE_PIEN]
                                       <= uif_wdata[UIF_RDFE_PIEN];
                                          
                                     ctrl_wdata[CTRL_RDFE_S0D]
                                       <= uif_wdata[UIF_RDFE_S0D];
                                          
                                     ctrl_wdata[CTRL_RDFE_S90D]
                                       <= uif_wdata[UIF_RDFE_S90D];  
                                          
                                     ctrl_wdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0]
                                       <= uif_wdata[UIF_RDFE_STEP_3 : UIF_RDFE_STEP_0];
                                 end
                                 
           XR_DFE_OFFSET_DFE12: ctrl_wdata  <= uif_wdata;
           XR_DFE_OFFSET_DFE13: ctrl_wdata  <= uif_wdata;
           XR_DFE_OFFSET_DFE14: ctrl_wdata  <= uif_wdata;
           XR_DFE_OFFSET_DFE15: ctrl_wdata  <= uif_wdata;
       endcase
end

// user read data
always @(posedge clk)
begin
    uif_rdata_mux <= 0;
    if (first_cycle)
        case (uif_addr) // first cycle of 2
            XR_DFE_OFFSET_CTRL:  uif_rdata_mux[UIF_RDFE_ADAPT]                  
                                   <= ctrl_rdata[CTRL_RDFE_ADAPT];
                                           
            XR_DFE_OFFSET_TAP2:  uif_rdata_mux[UIF_RDFE_T2_2 : UIF_RDFE_T2_0]
                                   <= ctrl_rdata[CTRL_RDFE_T2_2 : CTRL_RDFE_T2_0];
                                             
            XR_DFE_OFFSET_TAP3:  uif_rdata_mux[UIF_RDFE_T3_2 : UIF_RDFE_T3_0]
                                   <= ctrl_rdata[CTRL_RDFE_T3_2 : CTRL_RDFE_T3_0];
                                          
            XR_DFE_OFFSET_TAP4:  uif_rdata_mux[UIF_RDFE_T4_2 : UIF_RDFE_T4_0]
                                   <= ctrl_rdata[CTRL_RDFE_T4_2 : CTRL_RDFE_T4_0];
                                          
            XR_DFE_OFFSET_TAP5:  uif_rdata_mux[UIF_RDFE_T5_1 : UIF_RDFE_T5_0]
                                   <= ctrl_rdata[CTRL_RDFE_T5_1 : CTRL_RDFE_T5_0];
                                   
            XR_DFE_OFFSET_REF:   uif_rdata_mux[UIF_RDFE_VREF_2 : UIF_RDFE_VREF_0]
                                   <= ctrl_rdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0];                    
                                   
       endcase
    else          
        case (uif_addr)
            XR_DFE_OFFSET_CTRL:  uif_rdata_mux[UIF_RDFE_PDB] 
                                   <= ctrl_rdata[CTRL_RDFE_PDB];
                                          
            XR_DFE_OFFSET_TAP1:  uif_rdata_mux[UIF_RDFE_T1_3 : UIF_RDFE_T1_0]
                                   <= ctrl_rdata[CTRL_RDFE_T1_3 : CTRL_RDFE_T1_0];
                                          
            XR_DFE_OFFSET_TAP2:  uif_rdata_mux[UIF_RDFE_T2INV]
                                   <= ctrl_rdata[CTRL_RDFE_T2INV];
                                          
            XR_DFE_OFFSET_TAP3:  uif_rdata_mux[UIF_RDFE_T3INV]
                                   <= ctrl_rdata[CTRL_RDFE_T3INV];
                                          
            XR_DFE_OFFSET_TAP4:  uif_rdata_mux[UIF_RDFE_T4INV]
                                   <= ctrl_rdata[CTRL_RDFE_T4INV];
                                          
            XR_DFE_OFFSET_TAP5:  uif_rdata_mux[UIF_RDFE_T5INV]
                                   <= ctrl_rdata[CTRL_RDFE_T5INV];
                                          
            XR_DFE_OFFSET_REF:   begin
                                     uif_rdata_mux[UIF_RDFE_CKEN]   
                                       <= ctrl_rdata[CTRL_RDFE_CKEN];
                                  
                                     uif_rdata_mux[UIF_RDFE_FREQ_1 : UIF_RDFE_FREQ_0]   
                                       <= ctrl_rdata[CTRL_RDFE_FREQ_1 : CTRL_RDFE_FREQ_0];
                                 end                    
           
            XR_DFE_OFFSET_STEP:  begin
                                     uif_rdata_mux[UIF_RDFE_PIEN]
                                       <= ctrl_rdata[CTRL_RDFE_PIEN];
                                          
                                     uif_rdata_mux[UIF_RDFE_S0D]
                                       <= ctrl_rdata[CTRL_RDFE_S0D];
                                          
                                     uif_rdata_mux[UIF_RDFE_S90D]
                                       <= ctrl_rdata[CTRL_RDFE_S90D];   
                                          
                                     uif_rdata_mux[UIF_RDFE_STEP_3 : UIF_RDFE_STEP_0]
                                       <= ctrl_rdata[CTRL_RDFE_STEP_3 : CTRL_RDFE_STEP_0];
                                 end
           
            XR_DFE_OFFSET_DFE12: uif_rdata_mux  <= ctrl_rdata;
            XR_DFE_OFFSET_DFE13: uif_rdata_mux  <= ctrl_rdata;
            XR_DFE_OFFSET_DFE14: uif_rdata_mux  <= ctrl_rdata;
            XR_DFE_OFFSET_DFE15: uif_rdata_mux  <= ctrl_rdata;
   endcase
end

always @(posedge clk)
begin   
   if (uif_go) 
       uif_rdata <= 16'h0000;
   else if (uif_rdata_ld)
       uif_rdata <= uif_rdata_mux | uif_rdata;
end

// local reset
always @(posedge clk or posedge reset)
begin   
    if (reset)
       reset_ff <= 7'h0;
    else
       reset_ff <= {reset_ff[5:0], 1'b1};
end

assign reset_sync = ~reset_ff[6];

endmodule
