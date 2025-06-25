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


module configure_reconfig (

    mm_clk,
    mm_reset,
    seq_start_rc,
    seq_pcs_mode,
    hdsk_rc_busy,
    address,
    write,
    writedata,
    read,
    readdata,
    waitrequest,
    speed_sel

);

    input       mm_clk;
    input       mm_reset;
    output      seq_start_rc;
    output      [5:0]seq_pcs_mode;
    input       hdsk_rc_busy;
    input       read;
    output      [31:0]readdata;
    output      waitrequest;
    input       address;
    input       write;
    input       [31:0]writedata;
    output      speed_sel;
    
    reg         [5:0]seq_pcs_mode;
    // reg         waitrequest;
    reg         seq_start_rc;
    reg         [31:0]readdata;
    reg         reg_hdsk_rc_busy;
    assign speed_sel = seq_pcs_mode[2]?1'b0:1'b1;
    assign waitrequest = hdsk_rc_busy;
    
    always @ (posedge mm_clk or posedge mm_reset)
        begin
        if(mm_reset)
            begin
            seq_pcs_mode <= 6'b0;
            seq_start_rc <= 1'b0;
            reg_hdsk_rc_busy <= 1'b0;
            readdata <= 32'b0;
            end
        else
            begin
            reg_hdsk_rc_busy <= hdsk_rc_busy;
            if(address == 1'b1)
                begin
                if(write == 1'b1)
                    begin
                    seq_pcs_mode <= writedata[5:0];
                    seq_start_rc <= 1'b1;
                    end
                else if(read == 1'b1)
                    begin
                    readdata <= {26'b0,seq_pcs_mode};
                    end
                end
            if(reg_hdsk_rc_busy == 1'b0 && hdsk_rc_busy == 1'b1)
                begin
                seq_start_rc <= 1'b0;
                end
            end    
        end
        
endmodule        
    
    
    
    