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


//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  ilk_mux
//
// Description     :  Parameterized multiplexer megafunctions.
//
// Limitation      :  n/a
//
// Results expected:  Selected input port.
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module ilk_mux ( 
    data,    // Data input. (Required)
    sel,     // Selects one of the input buses. (Required)
    clock,   // Clock for pipelined usage
    aclr,    // Asynchronous clear for pipelined usage.
    clken,   // Clock enable for pipelined usage.
    result   // Selected input port. (Required)
);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;  // Width of the data[][] and result[] ports. (Required)
    parameter lpm_size = 2;   // Number of input buses to the multiplexer. (Required)
    parameter lpm_widths = 1; // Width of the sel[] input port. (Required)
    parameter lpm_pipeline = 0; // Specifies the number of Clock cycles of latency
                                // associated with the result[] output.
    parameter lpm_type = "lpm_mux";
    parameter lpm_hint  = "UNUSED";

// INPUT PORT DECLARATION
    input [(lpm_size * lpm_width)-1:0] data;
    input [lpm_widths-1:0] sel;
    input clock;
    input aclr;
    input clken;
    
// OUTPUT PORT DECLARATION
    output [lpm_width-1:0] result;

// INTERNAL REGISTER/SIGNAL DECLARATION
    reg [lpm_width-1:0] result_pipe [lpm_pipeline+1:0];
    reg [lpm_width-1:0] tmp_result;

// LOCAL INTEGER DECLARATION
    integer i;
    integer pipe_ptr;

// INTERNAL TRI DECLARATION
    tri0 aclr;
    tri0 clock;
    tri1 clken;

    wire i_aclr;
    wire i_clock;
    wire i_clken;
    buf (i_aclr, aclr);
    buf (i_clock, clock);
    buf (i_clken, clken);

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if (lpm_width <= 0)
        begin
            $display("Value of lpm_width parameter must be greater than 0 (ERROR)");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (lpm_size <= 1)
        begin
            $display("Value of lpm_size parameter must be greater than 1 (ERROR)");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (lpm_widths <= 0)
        begin
            $display("Value of lpm_widths parameter must be greater than 0 (ERROR)");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (lpm_pipeline < 0)
        begin
            $display("Value of lpm_pipeline parameter must NOT less than 0 (ERROR)");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        pipe_ptr = 0;
    end
    
    
// ALWAYS CONSTRUCT BLOCK
    always @(data or sel)
    begin        
        tmp_result = 0;

        if (sel < lpm_size)
        begin
            for (i = 0; i < lpm_width; i = i + 1)
                tmp_result[i] = data[(sel * lpm_width) + i];
        end
        else
            tmp_result = {lpm_width{1'bx}};
    end

    always @(posedge i_clock or posedge i_aclr)
    begin
        if (i_aclr)
        begin
            for (i = 0; i <= (lpm_pipeline+1); i = i + 1)
                result_pipe[i] <= 1'b0;
            pipe_ptr <= 0;                
        end
        else if (i_clken == 1'b1)
        begin
            result_pipe[pipe_ptr] <= tmp_result;

            if (lpm_pipeline > 1)
                pipe_ptr <= (pipe_ptr + 1) % lpm_pipeline;
        end
    end

// CONTINOUS ASSIGNMENT
    assign result = (lpm_pipeline > 0) ? result_pipe[pipe_ptr] : tmp_result;
    
endmodule // ilk_mux

