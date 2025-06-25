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


// ******************************************************************************************************************************** 
// File name: crcerror_read_emr.v
// 
//   The crcerror_read_emr component shift out the content of EMR register.
// 
// User logic control block is user-defined. 
// Mechanism to read out the content of user update register:
//    1. Drive the SHIFTnLD signal low.
//    2. Wait at least two EDCLK cycles.
//    3. Clock CLK for one rising edge to load the contents of the user update register to the user shift register.
//    4. Drive the SHIFTnLD signal high.
//    5. Clock CLK 30 cycles to read out 30 bits of the error location information.
//    6. Clock CLK 16 cycles more to read out the syndrome of the error.
//

module crcerror_read_emr
    (
    clk,
    reset,
    start_write,
    emr_done,
    emr_clk,
    shiftnld
    );

    input     clk;
    input     reset;
    input     start_write;
        output  emr_done;
    output     emr_clk;    
    output    shiftnld;
    
    reg    shiftnld;
    reg     emr_done;
    reg     emr_clk;

    reg counter_enable;
    reg counter_set;
    reg [5:0] counter_value;
    reg [5:0] counter;
    wire counter_done;

    reg [2:0] current_state /* synthesis altera_attribute = "-name SUPPRESS_REG_MINIMIZATION_MSG ON" */;
    reg [2:0] next_state;
    localparam STATE_WAIT        = 3'd0;
    localparam STATE_LOAD        = 3'd1;
    localparam STATE_SHIFTSTART  = 3'd2;
    localparam STATE_CLOCKLOW    = 3'd3;
    localparam STATE_CLOCKHIGH   = 3'd4;
    localparam STATE_READY       = 3'd5;
    

//    State machine:
//      WAIT:        idle state, holds until crcerror
//      LOAD:        asserts shiftnld low, holds for counter cycles
//      SHIFTSTART:  asserts shiftnld low, shifts first bit
//      CLOCKLOW:    emr_clk low
//      CLOCKHIGH:   emr_clk high, loops to SHIFTSTART 45 times, then goes to READY
//      READY:       asserts ready output, holds until next crcerror

    always @(current_state or start_write or counter_done )
        begin
     
//                 default values
            emr_clk = 1'b0;
            counter_set = 1'b0;
            counter_value = 6'b0;
            counter_enable = 1'b0;
            shiftnld = 1'b1;
            emr_done = 1'b1;
            next_state = current_state;
            case (current_state)
            STATE_WAIT:
                begin
                    counter_set = 1'b1;
                    counter_value = 6'd10;
                    emr_done = 1'b1;
                    if (start_write)
                        next_state = STATE_LOAD;
                end
            STATE_LOAD:
                begin
                    shiftnld = 1'b0;
                    counter_enable = 1'b1;
                    emr_done = 1'b1;
                    if (counter_done)
                        next_state = STATE_SHIFTSTART;
                end
            STATE_SHIFTSTART:
                begin
                    shiftnld = 1'b0;
                    counter_set = 1'b1;
                    counter_value = 6'd45;
                    emr_clk = 1'b1;
                    emr_done = 1'b0;
                    next_state = STATE_CLOCKLOW;
                end
            STATE_CLOCKLOW:
                begin
                    counter_enable = 1'b1;
                    emr_done = 1'b0;
                    next_state = STATE_CLOCKHIGH;
                end
            STATE_CLOCKHIGH:
                begin
                    emr_clk = 1'b1;
                    emr_done = 1'b0;
                    if (counter_done)
                        next_state = STATE_READY;
                    else
                        next_state = STATE_CLOCKLOW;
                end
            STATE_READY:
                begin
                    counter_set = 1'b1;
                    counter_value = 6'd10;
                    emr_done = 1'b1;
                    if (~start_write)
                        next_state = STATE_WAIT;
                end
            endcase
        end
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            current_state = STATE_WAIT;
        end
        else
        begin
            current_state = next_state;
        end
    end

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        counter <= 6'd0;
    end
    else if (counter_set)
    begin
        counter <= counter_value;
    end
    else if (counter_enable)
    begin
        counter <= counter - 6'd1;
    end
end
    assign counter_done = (counter == 6'b0);

endmodule
