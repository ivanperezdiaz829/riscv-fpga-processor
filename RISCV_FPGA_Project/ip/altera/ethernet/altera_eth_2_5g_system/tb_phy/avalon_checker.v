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


module avalon_checker(
    avalon_clk,
    avalon_reset,
    
    avalon_st_tx_sop,
    avalon_st_tx_eop, 
    avalon_st_tx_valid, 
    avalon_st_tx_ready,
    avalon_st_tx_empty, 
    avalon_st_tx_error, 
    avalon_st_tx_data, 
    
    avalon_st_rx_sop,
    avalon_st_rx_eop, 
    avalon_st_rx_valid, 
    avalon_st_rx_empty, 
    avalon_st_rx_error,
    avalon_st_rx_data 

);

input avalon_clk;
input avalon_reset;
input avalon_st_tx_sop;
input avalon_st_tx_eop;
input avalon_st_tx_valid;
input [2:0] avalon_st_tx_empty; 
input avalon_st_tx_error; 
input [63:0] avalon_st_tx_data;
input avalon_st_tx_ready;

input avalon_st_rx_sop;
input avalon_st_rx_eop;
input avalon_st_rx_valid;
input [2:0] avalon_st_rx_empty; 
input avalon_st_rx_error; 
input [63:0] avalon_st_rx_data;

reg [70:0] avalon_packed_d1;
reg [70:0] avalon_packed_d2;
reg [70:0] avalon_packed_d3;
reg [70:0] avalon_packed_d4;
reg [70:0] avalon_packed_d5;
reg [70:0] avalon_packed_d6;
reg [70:0] avalon_packed_d7;
reg [70:0] avalon_packed_d8;
reg [70:0] avalon_packed_d9;
reg [70:0] avalon_packed_d10;
reg [70:0] avalon_packed_d11;
reg reg_a;

wire [70:0] avalon_packet_received;


assign avalon_packet_received = {avalon_st_rx_sop,avalon_st_rx_eop,avalon_st_rx_valid,avalon_st_rx_empty,avalon_st_rx_error,avalon_st_rx_data};

always@(posedge avalon_clk or posedge avalon_reset)
begin
        if(avalon_reset)begin
            avalon_packed_d1 <= 71'b0;
            avalon_packed_d2 <= 71'b0;
            avalon_packed_d3 <= 71'b0;
            avalon_packed_d4 <= 71'b0;
            avalon_packed_d5 <= 71'b0;
            avalon_packed_d6 <= 71'b0;
            avalon_packed_d7 <= 71'b0;
            avalon_packed_d8 <= 71'b0;
            avalon_packed_d9 <= 71'b0;
            avalon_packed_d10 <= 71'b0;
            avalon_packed_d11 <= 71'b0;
 
        end else begin
        
            if(avalon_st_tx_valid &avalon_st_tx_ready) begin
                avalon_packed_d1 <= {avalon_st_tx_sop,avalon_st_tx_eop,avalon_st_tx_valid,avalon_st_tx_empty,avalon_st_tx_error,avalon_st_tx_data};
            end else begin
                avalon_packed_d1 <= 71'b0;
            end
            
            avalon_packed_d2 <= avalon_packed_d1;
            avalon_packed_d3 <= avalon_packed_d2;
            avalon_packed_d4 <= avalon_packed_d3;
            avalon_packed_d5 <= avalon_packed_d4;
            avalon_packed_d6 <= avalon_packed_d5;
            avalon_packed_d7 <= avalon_packed_d6;
            avalon_packed_d8 <= avalon_packed_d7;
            avalon_packed_d9 <= avalon_packed_d8;
            avalon_packed_d10 <= avalon_packed_d9;
            avalon_packed_d11 <= avalon_packed_d10;
    
        end
end


//RX Data valid
always@(posedge avalon_clk or posedge avalon_reset)
begin
        if(avalon_reset)begin
            reg_a <= 1'b0;
        end else begin
            if(avalon_packed_d11[68]) begin
                    if (avalon_packed_d11 != avalon_packet_received) begin
                        $display("FAILURE: Avalon Data transmited and received is different! Time:%d", $time);
                        #100;
                        $finish;
                    end
            end        
        end
end

endmodule
