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


module avalon_to_16bit_gmii_convertor(
        avalon_clk,
        gmii_clk,
        reset,
        avalon_sink_sop,
        avalon_sink_eop,
        avalon_sink_valid,
        avalon_sink_empty,
        avalon_sink_error,
        avalon_sink_data,
        avalon_sink_ready,
        gmii_data,
        gmii_enable,
        gmii_error
        
);

input gmii_clk;
input avalon_clk;
input reset;
input avalon_sink_sop;
input avalon_sink_eop;
input avalon_sink_valid;
input [2:0] avalon_sink_empty;
input avalon_sink_error;
input [63:0] avalon_sink_data;
output reg avalon_sink_ready;
output reg [15:0] gmii_data;
output reg [ 1:0] gmii_enable;
output reg [ 1:0] gmii_error;

reg [3:0] gmii_sm;
reg avalon_sm;

reg [63:0] avalon_sink_data_d1;
reg avalon_sink_valid_d1;
reg avalon_sink_eop_d1;
reg [2:0] avalon_sink_empty_d1;

reg [1:0] data_ctr;
reg [1:0] ready_ctr;


localparam IDLE=0;
localparam START_COUNTER=1;
localparam START_PREAMBLE=1;
localparam MID_PREAMBLE=2;
localparam END_PREAMBLE=3;
localparam DATA_TRANSFER=4;
localparam EMPTY_0_STATE=5;
localparam EMPTY_1_STATE=6;
localparam EMPTY_2_STATE=7;
localparam EMPTY_3_STATE=8;
localparam EMPTY_4_STATE=9;
localparam EMPTY_5_STATE=10;


//assign avalon_sink_ready = 1'b1;

always@(posedge reset or posedge avalon_clk)
begin
    if(reset) begin
        avalon_sink_data_d1  <= 64'b0;
        avalon_sink_valid_d1 <= 1'b0;
        avalon_sink_eop_d1   <= 1'b0;
        avalon_sink_empty_d1 <= 3'b0;
    end else begin
        avalon_sink_data_d1  <= avalon_sink_data;
        avalon_sink_valid_d1 <= avalon_sink_valid;
        avalon_sink_eop_d1   <= avalon_sink_eop;
        avalon_sink_empty_d1 <= avalon_sink_empty;
    end
end

//avalon_sink_ready, to introduce a minimum of 2 clock cycle delay for IDLE usage
always@(posedge reset or posedge avalon_clk)
begin
    if(reset) begin
        avalon_sink_ready <= 1'b1;
        ready_ctr <= 2'b0;
        avalon_sm <= IDLE;
    end else begin
        case (avalon_sm)
        IDLE:
        begin
            if(avalon_sink_eop) begin
                avalon_sink_ready <= 1'b0;
                ready_ctr <= 2'b1;
                avalon_sm <= START_COUNTER;
            end       
        end
        
        START_COUNTER:
        begin
                ready_ctr <= ready_ctr + 2'b1;
                if(ready_ctr == 2'b11) begin
                   avalon_sink_ready <= 1'b1;
                   ready_ctr         <= 2'b0;
                   avalon_sm <= IDLE;
                end             
        end
        
        endcase     
    end
end



always@(posedge reset or posedge gmii_clk)
begin
    if(reset) begin
         gmii_data   <= 16'b0;
         gmii_enable <= 2'b0;
         gmii_error  <= 2'b0;
         gmii_sm     <= IDLE;
         data_ctr    <= 2'b0;
    end else begin
        case (gmii_sm)
        
        IDLE:
        begin
            if(avalon_sink_sop&avalon_sink_ready) begin
                gmii_data   <= 16'h5555;
                gmii_enable <= 2'b11;
                gmii_error  <= 2'b00;
                gmii_sm <= START_PREAMBLE;
            end else begin
                gmii_data   <= 16'h0707;
                gmii_enable <= 2'b00;
                gmii_error  <= 2'b00;
           
            end
        end
        
        START_PREAMBLE:
        begin
                gmii_data   <= 16'h5555;
                gmii_enable <= 2'b11;
                gmii_error  <= 2'b00;
                gmii_sm <= MID_PREAMBLE;        
        end
        
        MID_PREAMBLE:
        begin
                gmii_data   <= 16'h5555;
                gmii_enable <= 2'b11;
                gmii_error  <= 2'b00;
                gmii_sm <= END_PREAMBLE;        
        end 
        
        END_PREAMBLE:
        begin
                gmii_data   <= 16'h55d5;
                gmii_enable <= 2'b11;
                gmii_error  <= 2'b00;
                gmii_sm <= DATA_TRANSFER;        
        end  
        
        DATA_TRANSFER:
        begin
                if(~avalon_sink_eop_d1 & avalon_sink_valid_d1) begin
                    gmii_enable <= 2'b11;
                    gmii_error  <= 2'b00;
                    data_ctr <= data_ctr+1'b1;
   
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= avalon_sink_data_d1[63:48];
                    end else if (data_ctr == 2'b01) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                    end else if (data_ctr == 2'b10) begin
                        gmii_data   <= avalon_sink_data_d1[31:16];
                    end else begin
                        gmii_data   <= avalon_sink_data_d1[15:0];
                    end
                end else if (avalon_sink_eop_d1 & avalon_sink_valid_d1) begin                    
                    
                    if(avalon_sink_empty_d1 == 3'b000) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];
                        gmii_sm     <= EMPTY_0_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b001) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];
                        gmii_sm     <= EMPTY_1_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b010) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];
                        gmii_sm     <= EMPTY_2_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b011) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];                       
                        gmii_sm     <= EMPTY_3_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b100) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];                   
                        gmii_sm     <= EMPTY_4_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b101) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];
                        gmii_sm     <= EMPTY_5_STATE;
                    end else if (avalon_sink_empty_d1 == 3'b110) begin
                        gmii_enable <= 2'b11;
                        gmii_error  <= 2'b00;
                        gmii_data   <= avalon_sink_data_d1[63:48];
                        gmii_sm     <= IDLE;
                    end else if (avalon_sink_empty_d1 == 3'b111) begin
                        gmii_enable <= 2'b10;
                        gmii_error  <= 2'b00;
                        gmii_data   <= {avalon_sink_data_d1[63:55],8'h07};
                        gmii_sm <= IDLE;      
                    end
                end
                
          end
          
          EMPTY_0_STATE:
          begin
                    data_ctr <= data_ctr+1'b1;
                    
                    if (data_ctr == 2'b00) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                    end else if (data_ctr == 2'b01) begin
                        gmii_data   <= avalon_sink_data_d1[31:16];
                    end else if (data_ctr == 2'b10)begin
                        gmii_data   <= avalon_sink_data_d1[15:0];
                        gmii_enable <= 2'b11; 
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end           
          end
          
          
          EMPTY_1_STATE:
          begin
                    data_ctr <= data_ctr+1'b1;
                    
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                        gmii_enable <= 2'b11;
                    end else if (data_ctr == 2'b01) begin
                        gmii_data   <= avalon_sink_data_d1[31:16];
                        gmii_enable <= 2'b11; 
                    end else if (data_ctr == 2'b10) begin
                        gmii_data   <= {avalon_sink_data_d1[15:8],8'h07};
                        gmii_enable <= 2'b10; 
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end         
          end
          
          EMPTY_2_STATE:
          begin
                    data_ctr <= data_ctr+1'b1;
                    
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                        gmii_enable <= 2'b11;
                    end else if (data_ctr == 2'b01) begin
                        gmii_data   <= avalon_sink_data_d1[31:16];
                        gmii_enable <= 2'b11; 
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end                   
          end
          
          EMPTY_3_STATE:
          begin
                     data_ctr <= data_ctr+1'b1;
                    
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                        gmii_enable <= 2'b11;
                    end else if (data_ctr == 2'b01) begin
                        gmii_data   <= {avalon_sink_data_d1[31:24],8'h07};
                        gmii_enable <= 2'b10; 
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end                            
          end
          
          EMPTY_4_STATE:
          begin
                    data_ctr <= data_ctr+1'b1;
                    
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= avalon_sink_data_d1[47:32];
                        gmii_enable <= 2'b11;
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end                   
          end
          
          EMPTY_5_STATE:
          begin
                    data_ctr <= data_ctr+1'b1;
                    
                    if(data_ctr == 2'b0) begin
                        gmii_data   <= {avalon_sink_data_d1[47:39],8'h07};
                        gmii_enable <= 2'b11; 
                        gmii_sm     <= IDLE;
                        data_ctr    <= 2'b0;
                    end                   
          end
 
          
        endcase
    
    end
end





endmodule 
