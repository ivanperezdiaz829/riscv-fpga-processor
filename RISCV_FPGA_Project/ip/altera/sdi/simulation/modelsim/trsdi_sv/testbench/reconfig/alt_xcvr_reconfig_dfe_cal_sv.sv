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


// dfe calibration
//
// This module handles write cycles to the User DFE Control register and
// it preforms calibration when power is enabled the first time. 
// (power enable is control reg bit 1)
//
// Calibration involves writing to DFE offset cancellation registers
// to determine the average value that causes the testbus input to
// oscillate. Six testbus lines are monitored in parallel.
//
// $Header$

module alt_xcvr_reconfig_dfe_cal_sv (
    input  wire        clk,
    input  wire        reset,
   
    // user interface
    input  wire        uif_go,       // start user cycle  
    input  wire [2:0]  uif_mode,     // cycle type
    output reg         uif_busy,     // transfer in process
    input  wire [5:0]  uif_addr,     // address offset
    input  wire [1:0]  uif_wdata,    // data in
    input  wire        uif_chan_err, // illegal channel
      
    // basic block control interface
    output reg         ctrl_go,      // start basic block cycle
    output reg  [2:0]  ctrl_opcode,  // cycle type;
    output reg         ctrl_lock,    // multicycle lock 
    input  wire        ctrl_wait,    // transfer in process
    output reg  [11:0] ctrl_addr,    // address
    input  wire [15:0] ctrl_rdata,   // data in
    output reg  [15:0] ctrl_wdata,   // data out
    input  wire [6:0]  ctrl_phys,    // physcal channel
    
    input  wire [7:0] ctrl_testbus   // testbus
);

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

parameter  TESTBUS_HARDWARE_TPD = 80; // delay for hardware to react to new offset
parameter  TESTBUS_SAMPLE_TIME  = 32; // delay to detect toggling
localparam WAIT_DELAY           = TESTBUS_HARDWARE_TPD + TESTBUS_SAMPLE_TIME;
localparam WAIT_DELAY_WIDTH     = log2(WAIT_DELAY -1);

// testbus sel in basic block
localparam [15:0] DFE_TESTBUS_SEL = 16'h000d;

// Control state assignments
localparam [4:0] STATE_IDLE         = 5'h00;
localparam [4:0] STATE_RD_PWR       = 5'h01;
localparam [4:0] STATE_WR_PWR       = 5'h02;
localparam [4:0] STATE_RD_VREF      = 5'h03;
localparam [4:0] STATE_WR_VREF      = 5'h04;
localparam [4:0] STATE_RD_ADPT_ON   = 5'h05;
localparam [4:0] STATE_WR_ADPT_ON   = 5'h06;
localparam [4:0] STATE_TESTBUS      = 5'h07;
localparam [4:0] STATE_RD_TB_ON     = 5'h08;
localparam [4:0] STATE_WR_TB_ON     = 5'h09;
localparam [4:0] STATE_RD_OC_ON     = 5'h0a;
localparam [4:0] STATE_WR_OC_ON     = 5'h0b;
localparam [4:0] STATE_RD_OFFSET12  = 5'h0c;
localparam [4:0] STATE_WR_OFFSET12  = 5'h0d;
localparam [4:0] STATE_WR_OFFSET15  = 5'h0e;
localparam [4:0] STATE_WAIT         = 5'h0f;
localparam [4:0] STATE_RD_TB_OFF    = 5'h10;
localparam [4:0] STATE_WR_TB_OFF    = 5'h11;
localparam [4:0] STATE_RD_OC_OFF    = 5'h12;
localparam [4:0] STATE_WR_OC_OFF    = 5'h13;
localparam [4:0] STATE_WR_VREF2     = 5'h14;
localparam [4:0] STATE_RD_ADPT      = 5'h15;
localparam [4:0] STATE_WR_ADPT      = 5'h16;

// done state machine
localparam [1:0] STATE_DONE0  = 2'b00;
localparam [1:0] STATE_DONE1  = 2'b01;
localparam [1:0] STATE_DONE2  = 2'b10;

// user modes
localparam [2:0] UIF_MODE_RD   = 3'b000;
localparam [2:0] UIF_MODE_WR   = 3'b001;
localparam [2:0] UIF_MODE_PHYS = 3'b010;

// basic op codes
localparam CTRL_OP_RD   = 3'b000;
localparam CTRL_OP_WR   = 3'b001;
localparam CTRL_OP_PHYS = 3'b010;
localparam CTRL_OP_TBUS = 3'b011;

// DFE register bits
// register 11  
localparam CTRL_RDFE_ADAPT     = 15;

// register 12 
localparam CTRL_RDFE_PDOF_OD_3 = 15;
localparam CTRL_RDFE_PDOF_OD_2 = 14;
localparam CTRL_RDFE_PDOF_OD_1 = 13;
localparam CTRL_RDFE_PDOF_OD_0 = 12;
localparam CTRL_RDFE_PDOF_EV_3 = 11;
localparam CTRL_RDFE_PDOF_EV_2 = 10;
localparam CTRL_RDFE_PDOF_EV_1 = 9;
localparam CTRL_RDFE_PDOF_EV_0 = 8;
localparam CTRL_RDFE_PDB       = 7;

// register 13
localparam CTRL_RDFE_VREF_2    = 15;
localparam CTRL_RDFE_VREF_1    = 14;
localparam CTRL_RDFE_VREF_0    = 13;
localparam CTRL_RDFE_BYPASS    = 0;

// register 8 
localparam CTRL_RCRU_PDOF_TEST2 = 2; 

// register 21 
localparam CTRL_RRX_PDB         = 0;

// user register bits
// control register
localparam UIF_RDFE_ADAPT       = 0;           
localparam UIF_RDFE_PDB         = 1; 

// bit values
// reg 11 --bit 0 adaptation enable
localparam RDFE_ADAPT_ON        = 1'b1;

// reg 13 -- vref and bypass
localparam VREF_CAL_VALUE       = 3'b000;
localparam BYPASS_EN            = 1'b1;

// reg 8 --bit 2 testbus ouput enable
localparam TESTBUS_OE           = 1'b1;

// soft reg -- oc cal enable
localparam OC_CAL_ON            = 1'b1;

// declarations
reg  [1:0]                    state_done;  
wire                          ctrl_done;
reg  [4:0]                    next_state; 
reg  [4:0]                    state;
reg                           wait_timer_reset;
reg                           offset_count_reset;
reg  [15:0]                   vref_reg_save;
reg                           ctrl_go_ff;
reg  [(2**7)-1 :0]            cal_ram;
reg  [WAIT_DELAY_WIDTH -1 :0] wait_timer;
reg                           wait_timer_tc;
reg                           testbus_ready;
reg  [4:0]                    offset_count;
wire                          offset_count_tc;
wire [3:0]                    offset0;
wire [3:0]                    offset1;
wire [3:0]                    offset2;
wire [3:0]                    offset3;
wire [3:0]                    offset4; 
wire [3:0]                    offset5; 
wire [5:0]                    offset_done; 
wire                          cal_prior;            
wire                          cal_done;
reg  [3:0]                    reset_ff;
wire                          reset_sync;

import alt_xcvr_reconfig_h::*; 
import sv_xcvr_h::*;           

// creating CTRL_DONE from CTRL_WAIT
always @(posedge clk)
begin
    if (reset_sync)
        state_done <= STATE_DONE0;
    else
        case (state_done)
           // wait for ctrl_go
           STATE_DONE0:    if (ctrl_go)   
                               state_done <= STATE_DONE1;
       
           // wait ctrl_to negate     
           STATE_DONE1:    if (!ctrl_wait)   
                               state_done <= STATE_DONE2;
                           
          // generate ctrl_done for 1 clock period
           STATE_DONE2:    state_done <= STATE_DONE0;       
       endcase
end

assign ctrl_done = (state_done == STATE_DONE2);

// control state machine
// next state
always @(*)
begin
    case (state)
      
       // wait for user write to control register 
       STATE_IDLE:        if (uif_go & (uif_mode == UIF_MODE_WR) &
                                       (uif_addr == XR_DFE_OFFSET_CTRL))
                                next_state = STATE_RD_PWR;
                          else 
                                next_state = STATE_IDLE;
                                
                                 
       // read-modify-write to power (user data)
       STATE_RD_PWR:      if (ctrl_done)
                                next_state = STATE_WR_PWR;
                          else
                                next_state = STATE_RD_PWR;
   
       STATE_WR_PWR:      if (ctrl_done)
                                next_state = STATE_RD_VREF;
                          else 
                                next_state = STATE_WR_PWR;
                                     
       // Save copy of VREF/BYPASS register
       // preform calibration if not previous performed and power is being enabled                         
       STATE_RD_VREF:     if (ctrl_done && uif_wdata[UIF_RDFE_PDB] && !cal_prior)
                                next_state = STATE_WR_VREF;
                          else if (ctrl_done)
                                next_state = STATE_WR_VREF2;
                          else 
                                next_state = STATE_RD_VREF; 
                                    
       // VREF and Bypass enable
       STATE_WR_VREF:     if (ctrl_done)
                              next_state = STATE_RD_ADPT_ON;
                          else
                              next_state = STATE_WR_VREF;
                          
       // read-modify-write to enable adaptation engine
       STATE_RD_ADPT_ON:  if (ctrl_done)
                               next_state = STATE_WR_ADPT_ON;
                          else
                               next_state = STATE_RD_ADPT_ON;
       
       STATE_WR_ADPT_ON:  if (ctrl_done)
                              next_state = STATE_TESTBUS;
                          else
                              next_state = STATE_WR_ADPT_ON;       

       // select testbus
       STATE_TESTBUS:     if (ctrl_done)
                              next_state = STATE_RD_TB_ON;
                          else 
                              next_state = STATE_TESTBUS;                       
                               
       // read-modify-write to enable test bus buffer
       STATE_RD_TB_ON:    if (ctrl_done)
                              next_state = STATE_WR_TB_ON;
                          else
                              next_state = STATE_RD_TB_ON;
         
       STATE_WR_TB_ON:    if (ctrl_done)
                              next_state = STATE_RD_OC_ON;
                          else
                              next_state = STATE_WR_TB_ON;
                              
      // read-modify-write enable hard OC cal
       STATE_RD_OC_ON:    if (ctrl_done)
                              next_state = STATE_WR_OC_ON;
                          else
                              next_state = STATE_RD_OC_ON;
         
       STATE_WR_OC_ON:    if (ctrl_done)
                              next_state = STATE_RD_OFFSET12;
                          else
                              next_state = STATE_WR_OC_ON;                    
                              
              
       // read DFE12 offset data for read modify writes during calibration
       // reset offset counter
       STATE_RD_OFFSET12: if (ctrl_done)
                              next_state = STATE_WR_OFFSET12;
                          else
                              next_state = STATE_RD_OFFSET12;
   
       // calibration loop
       // write to offset registers
       STATE_WR_OFFSET12: if (ctrl_done)
                               next_state = STATE_WR_OFFSET15;
                          else
                               next_state = STATE_WR_OFFSET12;
   
       STATE_WR_OFFSET15: if (ctrl_done && cal_done)
                               next_state = STATE_RD_TB_OFF;
                          else if (ctrl_done)
                               next_state = STATE_WAIT;
                          else
                               next_state = STATE_WR_OFFSET15;
   
       // wait cailbration time
       STATE_WAIT:        if (wait_timer_tc)
                               next_state = STATE_WR_OFFSET12;
                          else   
                               next_state = STATE_WAIT;
   
       // calibration complete; restore registers
       // read-modify-write to disable test bus buffer
       STATE_RD_TB_OFF:    if (ctrl_done)
                               next_state = STATE_WR_TB_OFF;
                           else
                               next_state = STATE_RD_TB_OFF;
         
       STATE_WR_TB_OFF:    if (ctrl_done)
                               next_state = STATE_RD_OC_OFF;
                           else
                               next_state = STATE_WR_TB_OFF;
                               
       // read-modify-write to disable hard OC cal
       STATE_RD_OC_OFF:    if (ctrl_done)
                              next_state = STATE_WR_OC_OFF;
                           else
                              next_state = STATE_RD_OC_OFF;
         
       STATE_WR_OC_OFF:    if (ctrl_done)
                              next_state = STATE_WR_VREF2;
                           else
                              next_state = STATE_WR_OC_OFF;                       
                                 
       // Bypass Enable set to opposite of Adaptation Engine Enable
       // VREF restored to initial state -- modified during calibration
       // use copy saved at start 
       STATE_WR_VREF2:    if (ctrl_done)
                              next_state = STATE_RD_ADPT;
                          else
                              next_state = STATE_WR_VREF2;                       
                               
       // read-modify-write to adaptation engine with user data
       STATE_RD_ADPT:     if (ctrl_done)
                               next_state = STATE_WR_ADPT;
                          else
                               next_state = STATE_RD_ADPT;
                               
       STATE_WR_ADPT:     if (ctrl_done)
                               next_state = STATE_IDLE;
                          else
                               next_state = STATE_WR_ADPT; 
                              
       default:           next_state = STATE_IDLE;   
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
    // busy to user  
    uif_busy <= (next_state != STATE_IDLE); 
                            
    // lock to basic     
    ctrl_lock <= (next_state != STATE_IDLE) & 
                 (next_state != STATE_WR_ADPT); 
            
    // wait counter reset  
    wait_timer_reset   <= (next_state != STATE_WAIT);
            
    // offset counter reset
    offset_count_reset <= (next_state == STATE_RD_OFFSET12);
end

// save vref register to restore user settings
always @(posedge clk)
begin
    if ((state == STATE_RD_VREF) && ctrl_done)
        vref_reg_save <= ctrl_rdata;
end

// ctrl go 
always @(posedge clk)
begin
    if (reset_sync)
        ctrl_go_ff <= 1'b0;
    else
        case (state)
            STATE_IDLE:         ctrl_go_ff <= (uif_go & (uif_mode == UIF_MODE_WR)) &
                                              (uif_addr == XR_DFE_OFFSET_CTRL); 
            STATE_RD_PWR:       ctrl_go_ff <= ctrl_done;
            STATE_WR_PWR:       ctrl_go_ff <= ctrl_done;
            STATE_RD_VREF:      ctrl_go_ff <= ctrl_done;
            STATE_WR_VREF:      ctrl_go_ff <= ctrl_done;
            STATE_RD_ADPT_ON:   ctrl_go_ff <= ctrl_done;
            STATE_WR_ADPT_ON:   ctrl_go_ff <= ctrl_done;
            STATE_TESTBUS:      ctrl_go_ff <= ctrl_done;
            STATE_RD_TB_ON:     ctrl_go_ff <= ctrl_done;
            STATE_WR_TB_ON:     ctrl_go_ff <= ctrl_done;
            STATE_RD_OC_ON:     ctrl_go_ff <= ctrl_done;
            STATE_WR_OC_ON:     ctrl_go_ff <= ctrl_done;
            STATE_RD_OFFSET12:  ctrl_go_ff <= ctrl_done;
            STATE_WR_OFFSET12:  ctrl_go_ff <= ctrl_done;
            STATE_WR_OFFSET15:  ctrl_go_ff <= ctrl_done & cal_done;
            STATE_WAIT:         ctrl_go_ff <= wait_timer_tc; 
            STATE_RD_TB_OFF:    ctrl_go_ff <= ctrl_done;
            STATE_WR_TB_OFF:    ctrl_go_ff <= ctrl_done;
            STATE_RD_OC_OFF:    ctrl_go_ff <= ctrl_done;
            STATE_WR_OC_OFF:    ctrl_go_ff <= ctrl_done;
            STATE_WR_VREF2:     ctrl_go_ff <= ctrl_done;
            STATE_RD_ADPT:      ctrl_go_ff <= ctrl_done;
            default:            ctrl_go_ff <= 1'b0;
        endcase
end

// delay go for address and data setup
always @(posedge clk)
begin
    if (reset_sync)
        ctrl_go <= 1'b0;
    else
        ctrl_go <= ctrl_go_ff;
end

// ctrl opcode 
always @(posedge clk)
begin
    case (state)
        STATE_RD_PWR:       ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_PWR:       ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_VREF:      ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_VREF:      ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_ADPT_ON:   ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_ADPT_ON:   ctrl_opcode <= CTRL_OP_WR;
        STATE_TESTBUS:      ctrl_opcode <= CTRL_OP_TBUS;
        STATE_RD_TB_ON:     ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_TB_ON:     ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_OC_ON:     ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_OC_ON:     ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_OFFSET12:  ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_OFFSET12:  ctrl_opcode <= CTRL_OP_WR;
        STATE_WR_OFFSET15:  ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_TB_OFF:    ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_TB_OFF:    ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_OC_OFF:    ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_OC_OFF:    ctrl_opcode <= CTRL_OP_WR;
        STATE_WR_VREF2:     ctrl_opcode <= CTRL_OP_WR;
        STATE_RD_ADPT:      ctrl_opcode <= CTRL_OP_RD;
        STATE_WR_ADPT:      ctrl_opcode <= CTRL_OP_WR;
        default:            ctrl_opcode <= CTRL_OP_RD;
    endcase
end

// ctrl address 
always @(posedge clk)
begin
    case (state)
        STATE_RD_PWR:       ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_WR_PWR:       ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_RD_VREF:      ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        STATE_WR_VREF:      ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        STATE_RD_ADPT_ON:   ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        STATE_WR_ADPT_ON:   ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        STATE_RD_TB_ON:     ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        STATE_WR_TB_ON:     ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        STATE_RD_OC_ON:     ctrl_addr <= SV_XR_ABS_ADDR_OC;
        STATE_WR_OC_ON:     ctrl_addr <= SV_XR_ABS_ADDR_OC;
        STATE_RD_OFFSET12:  ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_WR_OFFSET12:  ctrl_addr <= RECONFIG_PMA_CH0_DFE12;
        STATE_WR_OFFSET15:  ctrl_addr <= RECONFIG_PMA_CH0_DFE15;
        STATE_RD_TB_OFF:    ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        STATE_WR_TB_OFF:    ctrl_addr <= RECONFIG_PMA_CH0_DFE8;
        STATE_RD_OC_OFF:    ctrl_addr <= SV_XR_ABS_ADDR_OC;
        STATE_WR_OC_OFF:    ctrl_addr <= SV_XR_ABS_ADDR_OC;
        STATE_WR_VREF2:     ctrl_addr <= RECONFIG_PMA_CH0_DFE13;
        STATE_RD_ADPT:      ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        STATE_WR_ADPT:      ctrl_addr <= RECONFIG_PMA_CH0_DFE11;
        default:            ctrl_addr <= 0;
    endcase
end

// ctrl wdata 
always @(posedge clk)
begin
    ctrl_wdata <= ctrl_rdata;
    case (state)
        STATE_WR_PWR:       ctrl_wdata[CTRL_RDFE_PDB]        <= uif_wdata[UIF_RDFE_PDB];
        
        STATE_WR_VREF:      begin
                                ctrl_wdata[CTRL_RDFE_VREF_2 : CTRL_RDFE_VREF_0]
                                                             <= VREF_CAL_VALUE; 
                                ctrl_wdata[CTRL_RDFE_BYPASS] <= BYPASS_EN;  
                            end                  
       
        STATE_WR_ADPT_ON:   ctrl_wdata[CTRL_RDFE_ADAPT]      <= RDFE_ADAPT_ON;
        
        STATE_TESTBUS:      ctrl_wdata                       <= DFE_TESTBUS_SEL;
       
        STATE_WR_TB_ON:     ctrl_wdata[CTRL_RCRU_PDOF_TEST2] <= TESTBUS_OE;
        STATE_WR_OC_ON:     ctrl_wdata[SV_XR_OC_CALEN_OFST]  <= OC_CAL_ON;
        
        STATE_WR_OFFSET12:  begin
                                ctrl_wdata[CTRL_RDFE_PDOF_OD_3 : CTRL_RDFE_PDOF_OD_0]
                                                             <= offset0;
                                ctrl_wdata[CTRL_RDFE_PDOF_EV_3 : CTRL_RDFE_PDOF_EV_0]
                                                             <= offset1;
                            end
                            
        STATE_WR_OFFSET15: ctrl_wdata <= {offset5, offset4, offset3, offset2};
 
        STATE_WR_TB_OFF:   ctrl_wdata[CTRL_RCRU_PDOF_TEST2]  <= ~ TESTBUS_OE;
        
        STATE_WR_OC_OFF:   ctrl_wdata[SV_XR_OC_CALEN_OFST]   <= ~ OC_CAL_ON;
        
        STATE_WR_VREF2:    begin 
                                ctrl_wdata                   <=  vref_reg_save;  
                                ctrl_wdata[CTRL_RDFE_BYPASS] <= ~uif_wdata[UIF_RDFE_ADAPT];
                            end
        
        STATE_WR_ADPT:     ctrl_wdata[CTRL_RDFE_ADAPT]       <= uif_wdata[UIF_RDFE_ADAPT];
        
        default:           ctrl_wdata <= 16'h000;
    endcase
end

// prior calibration memory 
always @(posedge clk)
begin
    if (reset_sync)
        cal_ram <= 128'b0;
    else if ((state == STATE_TESTBUS) && ctrl_done)
        cal_ram[ctrl_phys[6:0]] <= 1'b1; 
end
        
assign cal_prior = cal_ram[ctrl_phys[6:0]];

// wait timer
always @(posedge clk)
begin
    if (wait_timer_reset)
        wait_timer <= 0;
    else 
        wait_timer <= wait_timer + 1'b1;
end

always @(posedge clk)
begin
    wait_timer_tc <= wait_timer == WAIT_DELAY -1;
    testbus_ready <= wait_timer == TESTBUS_HARDWARE_TPD -1;
end

// offset counter
always @(posedge clk)
begin
    if (offset_count_reset)
        offset_count <= 5'h00;
    else if (wait_timer_tc)
        offset_count <= offset_count + 1'b1;
end

assign offset_count_tc = (offset_count == 5'h10);

// offset cancellation values
dfe_calibrator_sv inst_calibrator[5:0] (
    .clk             (clk),
    .reset           (offset_count_reset),  
    .enable          (wait_timer_tc),
    .count           (offset_count),        
    .count_tc        (offset_count_tc),
              
    .testbus         ({ctrl_testbus[5], ctrl_testbus[4], ctrl_testbus[3],
                       ctrl_testbus[2], ctrl_testbus[1], ctrl_testbus[0]}),                   
                                   
    .testbus_ready   (testbus_ready),
      
    .offset          ({offset5, offset4, offset3, offset2, offset1, offset0}), // dfe register data
    .done            (offset_done)
    );         

assign cal_done = & offset_done;

// local reset
always @(posedge clk or posedge reset)
begin   
    if (reset)
       reset_ff <= 4'h0;
    else
       reset_ff <= {reset_ff[2:0], 1'b1};
end

assign reset_sync = ~reset_ff[3];

endmodule
