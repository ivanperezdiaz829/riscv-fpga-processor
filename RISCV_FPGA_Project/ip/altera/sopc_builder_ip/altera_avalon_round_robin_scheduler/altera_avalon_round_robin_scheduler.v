// -----------------------------------------------------------
// Simple Round-Robin Scheduler
//
// 
// -----------------------------------------------------------

`timescale 1 ns / 1 ns

module altera_avalon_round_robin_scheduler
(
    // --------------------------------------------------
    // Ports
    // --------------------------------------------------
    clk,
    reset_n,

    // request
    request_address,
    request_write,
    request_writedata,
    request_waitrequest,

    // fill level status
    almost_full_data,
    almost_full_valid,
    almost_full_channel
);


    // --------------------------------------------------
    // Parameters
    // --------------------------------------------------
    parameter MAX_CHANNELS          = 24;
    parameter USE_ALMOST_FULL       = 1; 

    
    // Internally defined parameters
    localparam CHANNEL_WIDTH         = (MAX_CHANNELS == 1) ? 1 : log2ceil(MAX_CHANNELS);
    localparam CHANNEL_WIDTH_MASTER  = CHANNEL_WIDTH + 2;


    // --------------------------------------------------
    // Ports
    // --------------------------------------------------
    input wire clk;
    input wire reset_n;

    // request
    output reg [CHANNEL_WIDTH_MASTER - 1 : 0] request_address;
    output reg request_write;
    output wire [31 : 0] request_writedata;
    input wire request_waitrequest;

    // fill level status
    input wire almost_full_data;
    input wire almost_full_valid;
    input wire [CHANNEL_WIDTH - 1:0] almost_full_channel;
    
    

    // --------------------------------------------------
    // Internal Signals
    // --------------------------------------------------
    reg  [MAX_CHANNELS-1:0] read_en_reg;
    wire [MAX_CHANNELS-1:0] read_en;
    reg  read_en_sig;
    

    genvar i;
    integer k;


    // ----------------------------------------------------
    // Fill Level Status
    //
    // These status signals will be continuously monitored 
    // as they come in to determine if the particular 
    // channels are able to receive the scheduled data.
    // ----------------------------------------------------

    generate    
        for (i = 0 ; i<MAX_CHANNELS; i=i+1) 
            begin : FILL_STATUS_GENERATION
            
                always @(posedge clk or negedge reset_n) begin
                    if (!reset_n) begin
                        read_en_reg[i] <= 0;
                    end                  
                    else begin
                        if ((almost_full_channel == i) && almost_full_valid) begin
                            read_en_reg[i] <= !almost_full_data;
                        end
                    end
                end      
                                                     
            end            
    endgenerate

    generate 
        if (USE_ALMOST_FULL == 1) begin
            assign read_en = read_en_reg;
        end
        else begin
            assign read_en = {MAX_CHANNELS{1'b1}};
        end
    endgenerate
    



    // --------------------------------------------------
    // Request Connection Point
    //
    // Register map:
    //
    // |       Addr       |         Bits 31 - 0         |
    // | <Channel_number> |  <Number of fifo entries>   |
    //
    // --------------------------------------------------

    // The request address is kept incremented ina round robin fashion as it indicates the 
    // selected channel of request.
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            request_address[CHANNEL_WIDTH_MASTER-1:2] <= MAX_CHANNELS-1;
            request_address[1:0] <= 0;
        end
        
        else begin
            if (request_waitrequest == 0) begin
                if (request_address[CHANNEL_WIDTH_MASTER-1:2] == MAX_CHANNELS-1) begin
                    request_address <= 0;
                end
                else begin
                    request_address <= request_address + 4'h4;
                end            
            end      
        end             
    end

    // The "request_write" signal is dependent on the read enable signal of each channel.
    // We use the read enable signal of 1 signal ahead so that we can register the signal.
    always @ (*) begin
        read_en_sig = read_en[0] ;
        for (k = 0 ; k<MAX_CHANNELS; k=k+1)
             if ((request_address[CHANNEL_WIDTH_MASTER-1:2] + 1'b1) == k)
                 read_en_sig = read_en[k];
    end


    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            request_write <= 0;
        end
        
        else begin
            if (request_waitrequest == 0) begin
                if (request_address[CHANNEL_WIDTH_MASTER-1:2] == MAX_CHANNELS-1) begin
                    request_write <= read_en[0];
                end
                else begin
                    request_write <= read_en_sig;
                end            
            end      
        end             
    end

    // The amount of data requested is fixed to 1. This relates to 1 entry in the fifo if the 
    // request is intended for the Multi-Channel Shared FIFO.
    //always @ (*) begin
    //    request_writedata = 1'b1;
    //end
    assign request_writedata = 1;
    


    // --------------------------------------------------
    // Calculates the log2ceil of the input value
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1; 
            end
        end
    endfunction

    
endmodule
