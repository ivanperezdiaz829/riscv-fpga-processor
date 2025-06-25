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


// DCD align clocks
//
// DCD algorithm clock alignment. Continually acquires sum of 1's 
// samples from PHY and adjusts reye_monitor register until near 50% ones.
// (50% == 80 ones) 

// Algorithm is:
// step 1. Increment reye_monitor by 4 until sum crosses 50% threshold. 
// step 2. Decrement reye_monitor by 1 until sum crosses 50% threshold again.
// step 3. Increment reye_monitor by 1 if last value closer to ideal.

module alt_xcvr_reconfig_dcd_align_clk (
    input  wire        clk,
    input  wire        reset,
    
    input  wire        go,
    output reg         done,
    output reg         timeout,
    
    output wire [7:0]  sum_a,
    output wire [7:0]  sum_b,

    // basic block interface    
    output wire        ctrl_go,
    input  wire        ctrl_done,
    output wire [11:0] ctrl_addr,
    output wire [2:0]  ctrl_opcode,
    output wire [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata
    );  

// control state machine
localparam [2:0] STATE_IDLE   = 3'b000;
localparam [2:0] STATE_INIT   = 3'b001;
localparam [2:0] STATE_COURSE = 3'b010;
localparam [2:0] STATE_FINE   = 3'b011;
localparam [2:0] STATE_ADJUST = 3'b100;
localparam [2:0] STATE_DONE   = 3'b101;

parameter        TIMEOUT_COUNT = 100; // times to fetch sum

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

reg  [2:0]                         state;
reg                                sum_go;
reg  [5:0]                         reye_mon_ctr;
wire                               sum_done;
reg                                sum_less_than_half_ones;
reg                                sum_half_ones;
reg                                last_sum_less_than_half_ones;
wire                               sum_direction_change;
reg  [8:0]                         sum_diff;
reg  [8:0]                         sum_diff_abs;
reg  [8:0]                         last_sum_diff_abs;
reg                                last_diff_less;
reg  [2:0]                         sum_done_ff;
reg  [log2(TIMEOUT_COUNT -1) -1:0] timeout_ctr;

// control
always @(posedge clk)
begin 
    if (reset)
        state <=  STATE_IDLE;
    else  
        case (state)
            STATE_IDLE:   if (go)
                              state <= STATE_INIT;
            
            // set offset = 0 and get sum      
            STATE_INIT:   if (sum_done_ff[2] && sum_half_ones)
                             state <= STATE_DONE;
                          else if (sum_done_ff[2])
                             state <= STATE_COURSE;     
            
            // increment offset by 4                  
            STATE_COURSE: if ((sum_done_ff[2] && sum_half_ones) || (sum_done_ff[2] && timeout))
                             state <= STATE_DONE;
                          else if (sum_done_ff[2] && sum_direction_change)
                             state <= STATE_FINE;
                                    
            // decrement offset by 1                                                                     
            STATE_FINE:   if (sum_done_ff[2] && sum_direction_change && last_diff_less)
                             state <= STATE_ADJUST;
                          else if ((sum_done_ff[2] && sum_direction_change) ||
                                   (sum_done_ff[2] && sum_half_ones ) ||
                                   (sum_done_ff[2] && timeout))
                             state <= STATE_DONE;
                             
            // backup if last was better                 
            STATE_ADJUST: if (sum_done_ff[2])
                             state <= STATE_DONE;  
                           
            STATE_DONE:   state <= STATE_IDLE; 

            default:      state <= STATE_IDLE;
             
       endcase
end

// request sum    
always @(posedge clk)
begin 
    if (reset)
        sum_go   <= 1'b0;
    else
        sum_go   <= ((state == STATE_IDLE)    & go) |
                    ((state == STATE_INIT)    & sum_done_ff[2] & ~sum_half_ones) |
                    ((state == STATE_COURSE)  & sum_done_ff[2] & ~sum_half_ones & ~timeout) |
                    ((state == STATE_FINE)    & sum_done_ff[2] & ~sum_half_ones & ~sum_direction_change & ~timeout) |
                    ((state == STATE_FINE)    & sum_done_ff[2] &  sum_direction_change &  last_diff_less );
end

// reye_monitor offset counter
always @(posedge clk)
begin
if ((state == STATE_IDLE) && go)
        reye_mon_ctr <= 6'h00;
    else if (((state == STATE_INIT)    && sum_done_ff[2]) ||
             ((state == STATE_COURSE)  && sum_done_ff[2] && !sum_direction_change))
        reye_mon_ctr <= reye_mon_ctr + 3'b100;
        
    else if (((state == STATE_COURSE)  && sum_done_ff[2] && sum_direction_change) ||
             ((state == STATE_FINE)    && sum_done_ff[2] && !sum_direction_change))
        reye_mon_ctr <= reye_mon_ctr - 1'b1;
        
    else if ((state == STATE_FINE)     && sum_done_ff[2])
        reye_mon_ctr <= reye_mon_ctr + 1'b1;
end        

// write reye_mon counter to PHY register and get sum A and sum B
alt_xcvr_reconfig_dcd_get_sum  u_alt_xcvr_reconfig_dcd_get_sum (
    .clk         (clk),
    .reset       (reset),
    
    .go          (sum_go),
    .done        (sum_done),
        
    .offset      (reye_mon_ctr),
    .sum_a       (sum_a),
    .sum_b       (sum_b),
    
    // basic interface 
    .ctrl_go     (ctrl_go),
    .ctrl_done   (ctrl_done),
    .ctrl_addr   (ctrl_addr),
    .ctrl_opcode (ctrl_opcode),
    .ctrl_wdata  (ctrl_wdata),
    .ctrl_rdata  (ctrl_rdata)
  );  

// sum - 80
always @(posedge clk)
begin
    sum_diff <= sum_a - 7'd80;
end 

// compare number of ones 
always @(posedge clk)
begin
    sum_less_than_half_ones <= ~sum_diff[8]; // sign bit
    sum_half_ones           <= (sum_diff == 9'h000);
end

// direction change
always @(posedge clk)
begin
    if (sum_done_ff[2])
        last_sum_less_than_half_ones <= sum_less_than_half_ones;
end

assign sum_direction_change = sum_less_than_half_ones ^ 
                              last_sum_less_than_half_ones;

// absolute value
always @(posedge clk)
begin
    if (sum_diff[8])
        sum_diff_abs <= -sum_diff;
    else
        sum_diff_abs <=  sum_diff;
end

// last difference
always @(posedge clk)
begin
    if (sum_done_ff[2])
        last_sum_diff_abs <= sum_diff_abs;
end

// compare last and curent differences
always @(posedge clk)
begin
    last_diff_less <= (last_sum_diff_abs < sum_diff_abs);
end

// delay sum_done to match last_diff_less ffs
always @(posedge clk)
begin
     sum_done_ff <= {sum_done_ff[1:0], sum_done};
end

// alignment done
always @(posedge clk)
begin 
    if (reset)
        done <= 1'b0;
    else
        done <= (state == STATE_DONE);
end

// timeout
always @(posedge clk)
begin 
    if (state == STATE_IDLE && go)
        timeout_ctr <= 'h0;
    else if (sum_done_ff[2]) 
        timeout_ctr <= timeout_ctr + 1'b1;
end

always @(posedge clk) 
begin
    if (state == STATE_IDLE && go)
       timeout <= 1'b0;
    else if (sum_done_ff[2] && (timeout_ctr == TIMEOUT_COUNT -2))
       timeout <= 1'b1;
end 

endmodule
