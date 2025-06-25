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


// DCD calibration
//
// DCD calibration top module.
// 
// dcd_control.v perform self calibration with VCO data and
// DCD calibration with test data.
//
// dcd_align_clk.v handles aligning clocks to counter A and counter B.  
// These counters are in the PHY.

module alt_xcvr_reconfig_dcd_cal (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,
    
    output wire        ctrl_go,
    output wire        ctrl_lock,
    input  wire        ctrl_wait,
    output wire [6:0]  ctrl_chan,
    input  wire        ctrl_chan_err,
    output wire [11:0] ctrl_addr,
    output wire [2:0]  ctrl_opcode,
    output wire [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    
    output wire        user_busy
    );  

parameter  [6:0] NUM_OF_CHANNELS = 66;  //number_of_reconfig_interfaces <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// done state machine
localparam [1:0] STATE_DONE0  = 2'b00;
localparam [1:0] STATE_DONE1  = 2'b01;
localparam [1:0] STATE_DONE2  = 2'b10;

// declarations
wire        dcd_ctrl_go;
wire [11:0] dcd_ctrl_addr; 
wire [2:0]  dcd_ctrl_opcode; 
wire [15:0] dcd_ctrl_wdata;
wire        dcd_ctrl_sel;
wire        align_ctrl_go;
wire [11:0] align_ctrl_addr; 
wire [2:0]  align_ctrl_opcode; 
wire [15:0] align_ctrl_wdata;
wire        align_go;
wire        align_done;
wire        align_timeout;
wire [7:0]  align_sum_a;
wire [7:0]  align_sum_b;
reg  [1:0]  state_done;
wire        align_ctrl_done;
wire        dcd_ctrl_done;  
wire        ctrl_done;
reg  [5:0]  reset_ff;
wire        reset_sync1;
wire        reset_sync2;

// control   
alt_xcvr_reconfig_dcd_control #(
    .NUM_OF_CHANNELS  (NUM_OF_CHANNELS)
)
u_dcd_control (
    .clk           (clk),
    .reset         (reset_sync1),
    .hold          (hold),
    
    .ctrl_go       (dcd_ctrl_go),
    .ctrl_lock     (ctrl_lock),
    .ctrl_done     (dcd_ctrl_done),
    .ctrl_chan     (ctrl_chan),
    .ctrl_chan_err (ctrl_chan_err),
    .ctrl_addr     (dcd_ctrl_addr),
    .ctrl_opcode   (dcd_ctrl_opcode),
    .ctrl_wdata    (dcd_ctrl_wdata),
    .ctrl_rdata    (ctrl_rdata),
    .ctrl_sel      (dcd_ctrl_sel),
    
    .user_busy     (user_busy),
    
    .align_go      (align_go),
    .align_done    (align_done),
    .align_timeout (align_timeout),
    .align_sum_a   (align_sum_a),
    .align_sum_b   (align_sum_b)
    );  

// clock alignment    
alt_xcvr_reconfig_dcd_align_clk u_dcd_align (
    .clk           (clk),
    .reset         (reset_sync2),
    
    .go            (align_go),
    .done          (align_done),
    .timeout       (align_timeout),
    
    .sum_a         (align_sum_a),
    .sum_b         (align_sum_b),
    
    .ctrl_go       (align_ctrl_go),
    .ctrl_done     (align_ctrl_done),
    .ctrl_addr     (align_ctrl_addr),
    .ctrl_opcode   (align_ctrl_opcode),
    .ctrl_wdata    (align_ctrl_wdata),
    .ctrl_rdata    (ctrl_rdata)
    );  

// multiplex basic block signals
assign ctrl_go     = (dcd_ctrl_sel) ? (align_ctrl_go)     : (dcd_ctrl_go);
assign ctrl_addr   = (dcd_ctrl_sel) ? (align_ctrl_addr)   : (dcd_ctrl_addr); 
assign ctrl_opcode = (dcd_ctrl_sel) ? (align_ctrl_opcode) : (dcd_ctrl_opcode); 
assign ctrl_wdata  = (dcd_ctrl_sel) ? (align_ctrl_wdata)  : (dcd_ctrl_wdata); 
assign align_ctrl_done   =  dcd_ctrl_sel & ctrl_done;
assign dcd_ctrl_done     = ~dcd_ctrl_sel & ctrl_done;

// creating CTRL_DONE from CTRL_WAIT
always @(posedge clk)
begin
    if (reset_sync1)
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

// synchronize reset
always @(posedge clk or posedge reset)
begin   
    if (reset)
       reset_ff <= 6'h00;
    else
       reset_ff <= {reset_ff[4:0], 1'b1};    
end

assign reset_sync1 = ~reset_ff[5];
assign reset_sync2 = ~reset_ff[4];

endmodule
