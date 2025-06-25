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


module gmii_to_avalon_convertor(
    avalon_clk,
    gmii_clk,
    reset,
    avalon_rx_data,
    avalon_rx_valid,
    avalon_rx_sop,
    avalon_rx_eop,
    avalon_rx_error,
    avalon_rx_empty,
    avalon_rx_ready,
    gmii_enable,
    gmii_error,
    gmii_data

);

input avalon_clk;
input gmii_clk;
input reset;
output reg [63:0] avalon_rx_data;
output reg avalon_rx_valid;
output reg avalon_rx_sop;
output reg avalon_rx_eop;
output reg [ 2:0] avalon_rx_empty;
output reg [ 2:0] avalon_rx_error;
input avalon_rx_ready;

input [ 1:0] gmii_enable;
input [15:0] gmii_data;
input [ 1:0] gmii_error;

reg [ 1:0] avalon_ctr;
reg [ 3:0] gmii_ctr;
reg gmii_sop;
reg gmii_eop;

reg read_ctr;
reg mem_ctr;
reg avalon_sop;
reg avalon_eop;
reg [63:0] avalon_out_data;
reg [63:0] avalon_data[0:1];
reg avalon_valid;
reg [ 2:0] avalon_empty;
reg [ 2:0] avalon_error; 

reg [8:0] avalon_mem[0:1];

reg [1:0] gmii_state;
reg avalon_state;

localparam IDLE=0;
localparam PREAMBLE_DETECTED=1;
localparam DATA=1;
localparam DATA_RECEIVED=2;


//Avalon side, taking data from a stack of array
always@(posedge avalon_clk or posedge reset)
begin
    if(reset)begin
        read_ctr        <= 1'b0;
        avalon_rx_sop   <= 1'b0;
        avalon_sop      <= 1'b0;
        avalon_rx_eop   <= 1'b0;
        avalon_eop      <= 1'b0;
        avalon_rx_data  <= 64'b0;
        avalon_out_data <= 64'b0;
        avalon_rx_valid <= 1'b0;
        avalon_valid    <= 1'b0;
        avalon_rx_empty <= 3'b0;
        avalon_empty    <= 3'b0;
        avalon_rx_error <= 3'b0;
        avalon_error    <= 3'b0;
        avalon_state    <= IDLE; 
    end else begin
    
         avalon_rx_sop   <= avalon_sop;
         avalon_rx_eop   <= avalon_eop;
         avalon_rx_data  <= avalon_out_data;
         avalon_rx_valid <= avalon_valid;
         avalon_rx_empty <= avalon_empty;
         avalon_rx_error <= avalon_error; 
    
    
        case (avalon_state)     
        IDLE:
        begin
            if(avalon_mem[read_ctr][8]) begin
                avalon_sop <= avalon_mem[read_ctr][8];                     
                avalon_eop <= avalon_mem[read_ctr][7];
                avalon_valid <= avalon_mem[read_ctr][6];
                avalon_empty <= avalon_mem[read_ctr][5:3];
                avalon_error <= avalon_mem[read_ctr][2:0];
                avalon_out_data <= avalon_data[read_ctr];
                read_ctr        <= read_ctr +1'b1;
                avalon_state    <= DATA;
            end else begin
                avalon_sop <= 1'b0;
                avalon_eop <= 1'b0;
                avalon_valid <= 1'b0;
                avalon_empty <= 3'b0;
                avalon_error <= 3'b0;
                avalon_out_data <= 64'b0;
            end
        end
        
        DATA:
        begin
                if(~avalon_mem[read_ctr][6] & avalon_mem[read_ctr][7]) begin //This means EOP detected in this cycle with no data(so previous cycle needs to be marked)
                    avalon_rx_eop   <= 1'b1;   
                    avalon_state    <= IDLE; 
                    read_ctr        <= read_ctr +1'b1;
                end else begin                 
                    avalon_sop <= avalon_mem[read_ctr][8];  
                    avalon_eop <= avalon_mem[read_ctr][7];
                    avalon_valid <= avalon_mem[read_ctr][6];
                    avalon_empty <= avalon_mem[read_ctr][5:3];
                    avalon_error <= avalon_mem[read_ctr][2:0];
                    avalon_out_data <= avalon_data[read_ctr];
                    read_ctr        <= read_ctr +1'b1;
                    
                    if(avalon_mem[read_ctr][7]) //if eop found, go back to IDLE
                        avalon_state    <= IDLE;
               end
        
        
        end
        
        endcase               
    end
end


always@(posedge gmii_clk or posedge reset)
begin
    if(reset) begin
        avalon_data[0] <= 64'b0;
        avalon_data[1] <= 64'b0;
        avalon_mem[0]  <= 8'b0;
        avalon_mem[1]  <= 8'b0;
        gmii_state  <= IDLE;
        avalon_ctr  <= 2'b0;
        gmii_ctr    <= 4'b0;
        gmii_eop    <= 1'b0;
        gmii_sop    <= 1'b0;
        mem_ctr    <= 1'b0;
    end else begin
        case (gmii_state)
            
        IDLE:
        begin
            if(gmii_enable == 2'b11 && gmii_error == 2'b00 && gmii_data == 16'h5555)
                gmii_state <= PREAMBLE_DETECTED;
        end
        
        PREAMBLE_DETECTED:
        begin
             if(gmii_enable == 2'b11 && gmii_error == 2'b00 && gmii_data == 16'h5555)
                gmii_ctr <= gmii_ctr+1'b1; //detecion for 5555 5555 
             else
                gmii_ctr <= 4'b0;
             
             if(gmii_ctr == 4'b10 && gmii_enable == 2'b11 && gmii_error == 2'b00 && gmii_data == 16'h55d5) begin
                  gmii_state <= DATA_RECEIVED; //detection of 55d5
                  gmii_sop <= 1'b1;
             end
        end
        
        DATA_RECEIVED:
        begin
             if(gmii_enable == 2'b11) begin
               if(avalon_ctr == 0) begin
                    avalon_data[mem_ctr][63:48] <= gmii_data;
                    avalon_ctr  <= avalon_ctr+1'b1;
               end else if (avalon_ctr == 1) begin
                    avalon_data[mem_ctr][47:32] <= gmii_data;
                    avalon_ctr  <= avalon_ctr+1'b1;
               end else if (avalon_ctr == 2) begin
                    avalon_data[mem_ctr][31:16] <= gmii_data;
                    avalon_ctr  <= avalon_ctr+1'b1;
               end else if (avalon_ctr == 3) begin
                    avalon_data[mem_ctr][15:0]  <= gmii_data;
                    avalon_ctr  <= avalon_ctr+1'b1;
                    avalon_mem[mem_ctr] <=  {gmii_sop,1'b0,1'b1,3'b0, 3'b0};//{sop,eop,valid,empty,error};
                    gmii_sop <= 1'b0;
                    mem_ctr <= mem_ctr+1'b1;
               end
            end else if(gmii_enable == 2'b10) begin
               if(avalon_ctr == 0) begin
                    avalon_data[mem_ctr][63:48] <= {gmii_data,8'b0};
                    avalon_data[mem_ctr][47:0] <= 48'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h7, 3'b0};//{sop,eop,valid,empty,error};
                    avalon_ctr  <= 2'b0;
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 1) begin
                    avalon_data[mem_ctr][47:32] <= {gmii_data,8'b0};
                    avalon_data[mem_ctr][31:0] <= 32'b0;
                    avalon_ctr  <= 2'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h5, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 2) begin
                    avalon_data[mem_ctr][31:16] <= {gmii_data,8'b0};
                    avalon_data[mem_ctr][15:0] <= 16'b0;
                    avalon_ctr  <= 2'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h3, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 3) begin
                    avalon_data[mem_ctr][15:0]  <= {gmii_data,8'b0};
                    avalon_ctr  <= 2'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h1, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end
            end else if(gmii_enable == 2'b00) begin
                if(avalon_ctr == 0) begin
                    gmii_state <=IDLE;
                    avalon_data[mem_ctr] <= 64'b0;
                    avalon_mem[mem_ctr] <= {1'b0,1'b1,1'b0,3'b0,3'b0}; //{sop, eop, empty, error, data};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 1) begin
                    avalon_ctr  <= 2'b0;
                    avalon_data[mem_ctr][47:0] <= 48'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h6, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 2) begin
                    avalon_ctr  <= 2'b0;
                    avalon_data[mem_ctr][31:0] <= 32'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h4, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end else if (avalon_ctr == 3) begin
                    avalon_data[mem_ctr][15:0] <= 32'b0;
                    avalon_mem[mem_ctr] <=  {1'b0,1'b1,1'b1,3'h2, 3'b0};//{sop,eop,valid,empty,error};
                    mem_ctr <= mem_ctr+1'b1;
                    gmii_state  <= IDLE;
               end
            end
        end
        
        endcase
    
    end

end


endmodule
