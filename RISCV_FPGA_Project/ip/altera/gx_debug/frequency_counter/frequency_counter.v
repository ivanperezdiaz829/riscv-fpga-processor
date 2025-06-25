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


//Frequency checker
//Author: Harold Wang

`timescale 1ns/1ns

module frequency_counter
#(
    parameter CROSS_CLK_SYNC_DEPTH = 2,
    parameter REG_WIDTH = 32,
    parameter DEFAULT_MAX_CNT = 1000
)
(
    input               reset,
    input               avs_clk,
    input      [2 : 0]  avs_address,
    input               avs_write,
    input               avs_read,
    input      [3 : 0]  avs_byteenable,
    input      [31: 0]  avs_writedata,
    output reg [31: 0]  avs_readdata,

    input               ref_clk,
    input               des_clk
);

    //Local parameters
    localparam DELAY                = 8;
    
    localparam STATUS_REG_ADDR      = 0;
    localparam CONTROL_REG_ADDR     = 1;
    localparam REF_CNTER_ADDR       = 2;
    localparam DES_CNTER_ADDR       = 3;

    localparam ENABLE_BIT           = 0;
    localparam READY_BIT            = 1;

    reg                 enable_reg;
    wire                ready;
    reg [REG_WIDTH-1:0] ctrl_reg;
    reg [REG_WIDTH-1:0] ref_cnter_reg;
    reg [REG_WIDTH-1:0] des_cnter_reg;

    // clock domain signals
    wire                read_enable;
    wire                enable_readback;
    wire                start_mm;
    
    wire                ref_cnter_incr_sync;
    wire                des_cnter_incr_sync;
    reg                 started;
    wire                stopping;
    wire                stop_status;

    // Ref clock domain signals 
    reg[REG_WIDTH-1:0]  ref_clk_cnter;
    
    wire                ref_cnter_full;
    wire                des_cnter_full_sync;
    wire                ref_cnter_incr;
    wire                ref_cnter_start_sync;
    wire                ref_cnter_reset;
    wire                ref_reset;

    // Des clock domain signals
    reg[REG_WIDTH-1:0]  des_clk_cnter;
    
    wire                des_cnter_full;
    wire                des_cnter_incr;
    wire                des_cnter_start_sync;
    wire                ref_cnter_full_sync;
    wire                des_cnter_reset;
    wire                des_reset;

    reg                 running;

    // Reset related signals
    reg [1:0]           rst_status;

    assign start_mm = enable_reg;

    // Ready signal to indicate that the fCnter is ready to start or read out 
    // 1. When fCnter is not enabled
    // 2. When fCnter is not incrementing in both ref clock and des clk domain
    // 3. When fCnter finished reseting
    assign ready = !(enable_reg | ref_cnter_incr_sync | des_cnter_incr_sync | |rst_status);

    reg enable_reg_prev;
    reg ref_reset_prev;
    reg des_reset_prev;

    wire ref_reseted; 
    wire des_reseted; 

    always @(posedge avs_clk or posedge reset) begin
        if ( reset ) begin
            rst_status <= 'b11;
            started <= 'b0;
        end else begin 
            if ( ~enable_reg_prev & enable_reg ) rst_status <= 'b11;
            if ( ref_reset_prev != ref_reseted ) rst_status[0] <= 'b0;
            if ( des_reset_prev != des_reseted ) rst_status[1] <= 'b0;

            enable_reg_prev <= enable_reg;
            ref_reset_prev <= ref_reseted;
            des_reset_prev <= des_reseted;

            if ( enable_reg & ref_cnter_incr_sync & des_cnter_incr_sync ) started <= 'b1;
            if ( ~(ref_cnter_incr_sync | des_cnter_incr_sync) ) started <= 'b0;
        end
    end

//-------------------------------------------------------------------
// debugging stuff
//------------------------------------------------------------------
    pulse_toggle 
     ref_gen (
        .clock (ref_clk),
        .in    (ref_reset),
        .out   (ref_reseted)
    );

    pulse_toggle 
     des_gen (
        .clock (des_clk),
        .in    (des_reset),
        .out   (des_reseted)
    );
//-------------------------------------------------------------------
// end
//---
    toggle_pulse #(
        .DELAY_CYCLE    (0),
        .EDGES          (2)
    ) stop_gen (
        .clock (avs_clk),
        .in    (started),
        .out   (stopping)
    );
   
    // ------------------------------------------------
    // Avalon-MM Slave
    // ------------------------------------------------
    always @(posedge avs_clk or posedge reset ) begin
        if ( reset ) begin
            avs_readdata <= 'b0;
            enable_reg <= 'b0;
            ctrl_reg <= DEFAULT_MAX_CNT; 
            ref_cnter_reg <= 'b0;
            des_cnter_reg <= 'b0;
        end else begin
            if ( stopping) begin
                ref_cnter_reg <= ref_clk_cnter;
                des_cnter_reg <= des_clk_cnter;        
                enable_reg <= 'b0;
            end

            if ( avs_write ) begin
                case ( avs_address )
                    STATUS_REG_ADDR: begin
                        if ( avs_byteenable[0] ) begin
                            enable_reg <= avs_writedata[ENABLE_BIT];
                            if ( avs_writedata[ENABLE_BIT] ) begin
                                ref_cnter_reg <= 'b0;
                                des_cnter_reg <= 'b0;
                            end
                        end
                    end
                    CONTROL_REG_ADDR: begin
                        if ( ready ) begin
                            if ( avs_byteenable[0] ) begin
                                ctrl_reg[7:0] <= avs_writedata[7:0];               
                            end 
                            if ( avs_byteenable[1] ) begin
                                ctrl_reg[15:8] <= avs_writedata[15:8];               
                            end 
                            if ( avs_byteenable[2] ) begin
                                ctrl_reg[23:16] <= avs_writedata[23:16];               
                            end 
                            if ( avs_byteenable[3] ) begin
                                ctrl_reg[31:24] <= avs_writedata[31:24];               
                            end 
                        end
                    end
                endcase                   
            end else if ( avs_read ) begin
                avs_readdata <= 'b0;
                case ( avs_address ) 
                    STATUS_REG_ADDR: begin
                        if ( avs_byteenable[0] ) begin
                            avs_readdata[0] <= enable_reg; 
                            avs_readdata[1] <= ready;
                        end
                        if ( avs_byteenable[2] ) begin
                            avs_readdata[23:16] <= REG_WIDTH[7:0];
                        end
                    end
                    CONTROL_REG_ADDR: begin
                        if ( avs_byteenable[0] ) begin
                            avs_readdata[7:0] <= ctrl_reg[7:0];               
                        end 
                        if ( avs_byteenable[1] ) begin
                            avs_readdata[15:8] <= ctrl_reg[15:8];               
                        end 
                        if ( avs_byteenable[2] ) begin
                            avs_readdata[23:16] <= ctrl_reg[23:16];               
                        end 
                        if ( avs_byteenable[3] ) begin
                            avs_readdata[31:24] <= ctrl_reg[31:24];               
                        end 
                    end
                    REF_CNTER_ADDR: begin
                        if ( avs_byteenable[0] ) begin
                            avs_readdata[7:0] <= ref_cnter_reg[7:0];               
                        end 
                        if ( avs_byteenable[1] ) begin
                            avs_readdata[15:8] <= ref_cnter_reg[15:8];               
                        end 
                        if ( avs_byteenable[2] ) begin
                            avs_readdata[23:16] <= ref_cnter_reg[23:16];               
                        end 
                        if ( avs_byteenable[3] ) begin
                            avs_readdata[31:24] <= ref_cnter_reg[31:24];               
                        end 
                    end
                    DES_CNTER_ADDR: begin
                        if ( avs_byteenable[0] ) begin
                            avs_readdata[7:0] <= des_cnter_reg[7:0];               
                        end 
                        if ( avs_byteenable[1] ) begin
                            avs_readdata[15:8] <= des_cnter_reg[15:8];               
                        end 
                        if ( avs_byteenable[2] ) begin
                            avs_readdata[23:16] <= des_cnter_reg[23:16];               
                        end 
                        if ( avs_byteenable[3] ) begin
                            avs_readdata[31:24] <= des_cnter_reg[31:24];               
                        end 
                    end
                endcase                 
            end //end read
        end //end reset
    end //end always

    // -------------------------------------------------
    // Cross clock domain synchronization 
    // -------------------------------------------------
    // mm clk domain to ref clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) ref_cnter_synchronizer (
        .clk (ref_clk),
        .reset_n (~reset),
        .din (start_mm),
        .dout (ref_cnter_start_sync)
    );

    // MM clk domain to des clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) des_cnter_synchronizer (
        .clk (des_clk),
        .reset_n (~reset),
        .din (start_mm),
        .dout (des_cnter_start_sync)
    );

    //Ref clk domain to des clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) ref_cnter_full_synchronizer (
        .clk (des_clk),
        .reset_n (~reset),
        .din (ref_cnter_full),
        .dout (ref_cnter_full_sync)
    );
    
    //Des clk domain to ref clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) des_cnter_full_synchronizer (
        .clk (ref_clk),
        .reset_n (~reset),
        .din (des_cnter_full),
        .dout (des_cnter_full_sync)
    );
     
    //Ref clk domain to mm clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) ref_cnter_start_synchronizer (
        .clk (avs_clk),
        .reset_n (~reset),
        .din (ref_cnter_incr),
        .dout (ref_cnter_incr_sync)
    );
    
    //Des clk domain to mm clk domain sync
    altera_std_synchronizer #(
        .depth (CROSS_CLK_SYNC_DEPTH)
    ) des_cnter_start_synchronizer (
        .clk (avs_clk),
        .reset_n (~reset),
        .din (des_cnter_incr),
        .dout (des_cnter_incr_sync)
    );

    pulse_toggle reset_gen(
        .reset (reset),
        .clock (avs_clk),
        .in    (stopping),
        .out   (stop_status)
    );   
    
    toggle_pulse #(
        .DELAY_CYCLE    (CROSS_CLK_SYNC_DEPTH),
        .EDGES          (0)
    ) ref_reset_gen (
        .clock (ref_clk),
        .in    (stop_status),
        .out   (ref_cnter_reset)
    ); 
    
    toggle_pulse #(
        .DELAY_CYCLE    (CROSS_CLK_SYNC_DEPTH),
        .EDGES          (0)
    ) des_reset_gen (
        .clock (des_clk),
        .in    (stop_status),
        .out   (des_cnter_reset)
    );
    
    altera_reset_controller
    #(
        .NUM_RESET_INPUTS        (2),
        .OUTPUT_RESET_SYNC_EDGES ("deassert"),
        .SYNC_DEPTH              (CROSS_CLK_SYNC_DEPTH)
    ) ref_reset_controller (
        .clk        (ref_clk),
        .reset_in0  (reset),
        .reset_in1  (ref_cnter_reset),
        .reset_out  (ref_reset)
    );
    
    altera_reset_controller
    #(
        .NUM_RESET_INPUTS        (2),
        .OUTPUT_RESET_SYNC_EDGES ("deassert"),
        .SYNC_DEPTH              (CROSS_CLK_SYNC_DEPTH)
    ) des_reset_controller (
        .clk        (des_clk),
        .reset_in0  (reset),
        .reset_in1  (des_cnter_reset),
        .reset_out  (des_reset)
    );
    // -------------------------------------------------
    // ref clock counter 
    // -------------------------------------------------
    assign ref_cnter_full = (ref_clk_cnter >= ctrl_reg);
    assign ref_cnter_incr = ref_cnter_start_sync & !ref_cnter_full & !des_cnter_full_sync & !ref_reset;

    always @(posedge ref_clk or posedge ref_reset ) begin
        if ( ref_reset ) begin
            ref_clk_cnter <= 'b0;
        end else begin
            if ( ref_cnter_incr ) begin
                ref_clk_cnter <= ref_clk_cnter + 1;
            end 
        end
    end        

    // -------------------------------------------------
    // des clock counter 
    // -------------------------------------------------
    assign des_cnter_full = (des_clk_cnter >= ctrl_reg);
    assign des_cnter_incr = des_cnter_start_sync & !des_cnter_full & !ref_cnter_full_sync & !des_reset;

    always @(posedge des_clk or posedge des_reset ) begin
        if ( des_reset ) begin
            des_clk_cnter <= 'b0;
        end else begin
            if ( des_cnter_incr) begin    
                des_clk_cnter <= des_clk_cnter + 1; 
            end
        end
    end 
    
endmodule

// A input pulse will toggle the output
// the pulse is active low 
module pulse_toggle
(
    input       reset,
    input       clock,
    input       in,
    output reg  out
);
    reg in_prev = 'b0;
    initial begin
        out <= 'b0;
    end
    always @(posedge clock) begin
        if ( reset ) out <= 'b0;
        else begin
            if ( in_prev & ~in ) begin
                out <=  !out; 
            end
            in_prev <= in;
        end
    end
endmodule

// Both edge toggle to pulse edge = 0
// Positive edge toggle to pulse edge = 1
// Negative edge toggle to pulse edge = 2
module toggle_pulse #(
    parameter DELAY_CYCLE = 2,
    parameter EDGES = 0
)
(
    input       clock,
    input       in,
    output      out
);
    reg in_q = 'b0;
    wire tmp;
    
    always @(posedge clock) in_q <= in;

    generate
        if      ( EDGES == 0 ) assign tmp = in_q ^ in;
        else if ( EDGES == 1 ) assign tmp = ~in_q & in;
        else if ( EDGES == 2 ) assign tmp = in_q & ~in;

        if ( DELAY_CYCLE == 0 ) begin
            assign out = tmp;
        end else if (DELAY_CYCLE == 1 ) begin
            reg out_buff = 0;
            assign out = out_buff;

            always @(posedge clock) begin
                out_buff <= tmp;
            end 
        end else begin 
            reg [DELAY_CYCLE-1:0] outputs = 'b0;
            assign out = outputs[DELAY_CYCLE-1];

            always @(posedge clock) begin
                outputs = {outputs[DELAY_CYCLE-2:0], tmp};        
            end 
        end
    endgenerate
endmodule
