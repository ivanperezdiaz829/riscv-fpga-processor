// -----------------------------------------------------------
// Single clock, multi-channel Avalon-ST FIFO with status information
// and interrupts.
//
// 
// -----------------------------------------------------------

`timescale 1 ns / 1 ns

module altera_avalon_multi_channel_shared_fifo
(
    // --------------------------------------------------
    // Ports
    // --------------------------------------------------
    clk,
    reset_n,
    
    // sink
    in_data,
    in_valid,
    in_startofpacket,
    in_endofpacket,
    in_empty,
    in_error,
    in_channel,
    in_ready,
    
    // source
    out_data,
    out_valid,
    out_startofpacket,
    out_endofpacket,
    out_empty,
    out_error,
    out_channel,
    out_ready,
    
    // status - fill_level
    status_address,
    status_read,
    status_readdata,
    
    // control
    control_address,
    control_write,
    control_read,
    control_writedata,
    control_readdata,

    // request
    request_address,
    request_write,
    request_writedata,

    // fill level status
    almost_full_data,
    almost_full_valid,
    almost_full_channel,
    
    almost_empty_data,
    almost_empty_valid,
    almost_empty_channel
 
);

    // --------------------------------------------------
    // Parameters
    // --------------------------------------------------
    parameter SYMBOLS_PER_BEAT      = 16;
    parameter BITS_PER_SYMBOL       = 8;
    parameter FIFO_DEPTH            = 0;
    parameter ADDR_WIDTH            = 9;
    parameter ERROR_WIDTH           = 5;
    parameter USE_PACKETS           = 1;
    parameter USE_FILL_LEVEL        = 1;
    parameter USE_REQUEST           = 1;
    parameter USE_ALMOST_FULL       = 1;
    parameter USE_ALMOST_EMPTY      = 1;
    parameter USE_ALMOST_FULL2      = 1;
    parameter USE_ALMOST_EMPTY2     = 1;
    parameter PACKET_BUFFER_MODE    = 1;
    parameter SAV_THRESHOLD         = 16;
    parameter DROP_ON_ERROR         = 1;    
    parameter MAX_CHANNELS          = 16;

    parameter NUM_OF_ALMOST_FULL_THRESHOLD = 0;
    parameter NUM_OF_ALMOST_EMPTY_THRESHOLD = 0;

    
    // Internally defined parameters
    localparam DATA_WIDTH            = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;
    localparam DEPTH                 = 2 ** (ADDR_WIDTH);
    localparam EMPTY_WIDTH           = log2ceil(SYMBOLS_PER_BEAT);
    localparam CHANNEL_WIDTH         = (MAX_CHANNELS == 1) ? 1 : log2ceil(MAX_CHANNELS);
    localparam PACKET_SIGNALS_WIDTH  = 2 + EMPTY_WIDTH;
    localparam PAYLOAD_WIDTH         = (USE_PACKETS)? DATA_WIDTH + 2 + EMPTY_WIDTH + ERROR_WIDTH :
                                                     DATA_WIDTH + ERROR_WIDTH;
    localparam MEM_ADDR_WIDTH        = ADDR_WIDTH + CHANNEL_WIDTH;
    localparam MEM_DEPTH             = 2 ** MEM_ADDR_WIDTH;
    localparam ALMOST_FULL_WIDTH     = (USE_ALMOST_FULL) ? (USE_ALMOST_FULL + USE_ALMOST_FULL2) : 2;
    localparam ALMOST_EMPTY_WIDTH    = (USE_ALMOST_EMPTY) ? (USE_ALMOST_EMPTY + USE_ALMOST_EMPTY2) : 2;


    // --------------------------------------------------
    // Ports
    // --------------------------------------------------
    input wire clk;
    input wire reset_n;
    
    // sink
    input wire [DATA_WIDTH - 1: 0] in_data;
    input wire in_valid;
    input wire in_startofpacket;
    input wire in_endofpacket;
    input wire [EMPTY_WIDTH - 1 : 0] in_empty;
    input wire [ERROR_WIDTH - 1 : 0] in_error;
    input wire [CHANNEL_WIDTH - 1 : 0] in_channel;
    output reg in_ready;
    
    // source
    output wire [DATA_WIDTH - 1 : 0] out_data;
    output reg  out_valid;
    output wire out_startofpacket;
    output wire out_endofpacket;
    output wire [EMPTY_WIDTH - 1 : 0] out_empty;
    output wire [ERROR_WIDTH - 1 : 0] out_error;
    output reg  [CHANNEL_WIDTH - 1 : 0] out_channel;
    input wire  out_ready;
    
    // status - fill_level
    input wire [3:0] status_address;
    input wire status_read;
    output reg [31 : 0] status_readdata;
    
    // control
    input wire [1:0] control_address;
    input wire control_write;
    input wire control_read;
    input wire [31 : 0] control_writedata;
    output reg [31 : 0] control_readdata;

    // request
    input wire [CHANNEL_WIDTH - 1 : 0] request_address;
    input wire request_write;
    input wire [31 : 0] request_writedata;

    // fill level status
    output wire [ALMOST_FULL_WIDTH - 1 :0] almost_full_data;
    output reg almost_full_valid;
    output reg [CHANNEL_WIDTH - 1:0] almost_full_channel;
    
    output wire [ALMOST_EMPTY_WIDTH - 1 :0] almost_empty_data;
    output reg almost_empty_valid;
    output reg [CHANNEL_WIDTH - 1:0] almost_empty_channel;



    // --------------------------------------------------
    // Internal Signals
    // --------------------------------------------------
    reg  [PAYLOAD_WIDTH - 1 : 0] mem [MEM_DEPTH - 1 : 0];
    reg  [MEM_ADDR_WIDTH - 1 : 0] mem_rd_ptr;
    reg  [MEM_ADDR_WIDTH - 1 : 0] mem_wr_ptr;
    wire [MEM_ADDR_WIDTH - 1 : 0] mem_next_rd_ptr;
    reg  [MEM_ADDR_WIDTH - 1 : 0] mem_rd_ptr_sig;
    
    wire mem_read;
    reg  [MAX_CHANNELS-1:0] mem_channel_en;

    wire [MAX_CHANNELS-1:0] read;
    wire [MAX_CHANNELS-1:0] write;    
    reg  [ADDR_WIDTH - 1 : 0] wr_ptr [MAX_CHANNELS-1:0];
    reg  [ADDR_WIDTH - 1 : 0] rd_ptr [MAX_CHANNELS-1:0]; 
    wire [ADDR_WIDTH - 1 : 0] next_wr_ptr [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] next_rd_ptr [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] incremented_wr_ptr [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] incremented_rd_ptr [MAX_CHANNELS-1:0];    

    wire [MAX_CHANNELS-1:0] fill_read;
    reg  [ADDR_WIDTH - 1 : 0] fill_rd_ptr [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] fill_incremented_rd_ptr [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] fill_next_rd_ptr [MAX_CHANNELS-1:0];

    reg  [MAX_CHANNELS-1:0] empty;
    reg  [MAX_CHANNELS-1:0] next_empty;
    reg  [MAX_CHANNELS-1:0] full;
    reg  [MAX_CHANNELS-1:0] next_full;

    wire [PACKET_SIGNALS_WIDTH - 1 : 0] in_packet_signals;
    wire [PACKET_SIGNALS_WIDTH - 1 : 0] out_packet_signals;
    wire [PAYLOAD_WIDTH - 1 : 0] in_payload;
    reg  [PAYLOAD_WIDTH - 1 : 0] internal_out_payload;
    reg  [PAYLOAD_WIDTH - 1 : 0] out_payload;

    reg  internal_out_valid_sig;
    reg  internal_out_valid;
    reg  internal_out_valid_reg;
    wire internal_out_ready;
    reg  [CHANNEL_WIDTH-1:0] internal_out_channel;

    reg [ADDR_WIDTH : 0] fifo_fill_level [15:0];
    reg [ADDR_WIDTH : 0] fill_level [15:0];

    reg  [ADDR_WIDTH - 1: 0] almost_full_threshold_reg;
    reg  [ADDR_WIDTH - 1 : 0] almost_empty_threshold_reg;  
    reg  [ADDR_WIDTH - 1: 0] almost_full2_threshold_reg;
    reg  [ADDR_WIDTH - 1 : 0] almost_empty2_threshold_reg; 
    wire [ADDR_WIDTH - 1 : 0] almost_full_threshold;
    wire [ADDR_WIDTH - 1 : 0] almost_empty_threshold;  
    wire [ADDR_WIDTH - 1 : 0] almost_full2_threshold;
    wire [ADDR_WIDTH - 1 : 0] almost_empty2_threshold; 
    
    reg  [MAX_CHANNELS-1:0] out_channel_en;
    wire [CHANNEL_WIDTH-1:0] out_channel_sel;
    reg  [CHANNEL_WIDTH-1:0] out_channel_sel_reg;
    wire out_channel_valid;
    reg  out_channel_valid_reg;
    reg  [MAX_CHANNELS-1:0] in_channel_en;
    wire [CHANNEL_WIDTH-1:0] in_channel_sig;

    reg  [MAX_CHANNELS-1:0] have_packets;
    wire [MAX_CHANNELS-1:0] pkt_mode_valid;
    reg  [ADDR_WIDTH - 1 : 0] eop_ptr_reg [MAX_CHANNELS-1:0];
    wire [ADDR_WIDTH - 1 : 0] eop_ptr [MAX_CHANNELS-1:0];
    wire [MAX_CHANNELS-1:0] drop_packet;
    reg  [MAX_CHANNELS-1:0] drop_packet_reg;
    reg  [ADDR_WIDTH - 1 : 0] sop_ptr [MAX_CHANNELS-1:0];
    wire [MAX_CHANNELS-1:0] err_packet;

    reg [1:0] almost_full_data_reg;
    reg [1:0] almost_empty_data_reg;
    reg  almost_full_sig = 0;
    reg  almost_empty_sig = 0;
    reg  almost_full2_sig = 0;
    reg  almost_empty2_sig = 0;
    wire [MAX_CHANNELS-1:0] almost_full_status_wire;
    wire [MAX_CHANNELS-1:0] almost_empty_status_wire;
    wire [MAX_CHANNELS-1:0] almost_full2_status_wire;
    wire [MAX_CHANNELS-1:0] almost_empty2_status_wire;
    reg  [CHANNEL_WIDTH-1:0] status_ctr;
    
    wire [MAX_CHANNELS-1:0] sav;

    genvar i;
    integer k;


    // --------------------------------------------------
    // Define Channel
    //
    // Set the channel value to be always 0 if only 1
    // selected
    // --------------------------------------------------
    generate
        if (MAX_CHANNELS == 1) begin
            assign in_channel_sig = 0;
        end 
        else begin
            assign in_channel_sig = in_channel;
        end
    endgenerate
 
    
    // --------------------------------------------------
    // Define Payload
    //
    // Icky part where we decide which signals form the
    // payload to the FIFO with generate blocks.
    // --------------------------------------------------
    generate
        if (EMPTY_WIDTH > 0) begin
            assign in_packet_signals = {in_startofpacket, in_endofpacket, in_empty};
            assign {out_startofpacket, out_endofpacket, out_empty} = out_packet_signals;
        end 
        else begin
            assign in_packet_signals = {in_startofpacket, in_endofpacket};
            assign {out_startofpacket, out_endofpacket} = out_packet_signals;
        end
    endgenerate

    generate
        if (USE_PACKETS) begin
            if (ERROR_WIDTH > 0) begin
                assign in_payload = {in_packet_signals, in_data, in_error};
                assign {out_packet_signals, out_data, out_error} = out_payload;
            end
            else begin
                assign in_payload = {in_packet_signals, in_data};
                assign {out_packet_signals, out_data} = out_payload;
            end            
        end
        else begin
            if (ERROR_WIDTH > 0) begin
                assign in_payload = {in_data, in_error};
                assign {out_data, out_error} = out_payload;
            end
            else begin
                assign in_payload = in_data;
                assign out_data = out_payload;
            end
        end
    endgenerate


    // The in_ready signal depends on whether the channel the 
    // data is intended for is full 
    always @ (*) begin
        in_ready = !full[0];
        for (k = 0 ; k<MAX_CHANNELS; k=k+1)
             if (in_channel_sig == k)
                 in_ready = !full[k];
    end




    // --------------------------------------------------
    // Channels Pointer Management
    // --------------------------------------------------

    // Input channel enable decoder
    always@(in_channel_sig)
        for (k=0; k<MAX_CHANNELS; k=k+1)
            if (in_channel_sig == k)
                in_channel_en[k] = 1'b1;
            else
                in_channel_en[k] = 1'b0;


    // Output channel enable decoder
    always@(out_channel_sel, out_channel_valid)
        for (k=0; k<MAX_CHANNELS; k=k+1)
            if ((out_channel_sel == k) && (out_channel_valid == 1'b1))
                out_channel_en[k] = 1'b1;
            else
                out_channel_en[k] = 1'b0;


    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : WR_RD_ENABLE

            assign write[i] = in_ready && in_valid && in_channel_en[i];
            assign incremented_wr_ptr[i] = wr_ptr[i] + 1'b1;
            
            // The write pointer is dropped to the previous SOP location if the current packet is dropped.
            assign next_wr_ptr[i] = (~write[i]) ? wr_ptr[i] :
                                    (drop_packet[i]) ? sop_ptr[i] : incremented_wr_ptr[i];

            // These pointers increments the read pointer location for every READ operation. 
            assign read[i] = (mem_read & ~empty[i]) & (out_channel_en[i] & pkt_mode_valid[i]);            
            assign incremented_rd_ptr[i] = rd_ptr[i] + 1'b1; 
            assign next_rd_ptr[i] = (read[i]) ? incremented_rd_ptr[i] : rd_ptr[i];

            // As the memory's read pointer is registered, the read pointers above do not indicate the true
            // fill level of the FIFO if the output is not ready. This is because the read pointer (above)
            // will move to the next location after a READ operation, but it will be registered in the memory's 
            // read pointer if the output is not ready. Thus, the data is not actually read out from the memory 
            // until the output is valid. These set of pointers are used to track the fill level by taking into 
            // account the read location in the memory's read pointer.
            assign fill_read[i] = internal_out_ready & internal_out_valid & mem_channel_en[i];
            assign fill_incremented_rd_ptr[i] = fill_rd_ptr[i] + 1'b1;
            assign fill_next_rd_ptr[i] = (fill_read[i]) ? fill_incremented_rd_ptr[i] : fill_rd_ptr[i];
          
          
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin  
                    wr_ptr[i] <= 0;
                    rd_ptr[i] <= 0;
                    fill_rd_ptr[i] <= 0;                  
                end
                else begin
                    wr_ptr[i] <= next_wr_ptr[i];
                    rd_ptr[i] <= next_rd_ptr[i]; 
                    fill_rd_ptr[i] <= fill_next_rd_ptr[i];          
                end
            end

        end
    endgenerate



    // --------------------------------------------------
    // Memory Pointer Management
    // --------------------------------------------------    
    
    // The memory must also be read if the current data is not valid because other 
    // channels might have valid data and the memory read operation should not get stuck
    // due to this
    assign mem_read = internal_out_ready | !internal_out_valid;
    assign mem_next_rd_ptr = (mem_read) ? mem_rd_ptr_sig : mem_rd_ptr;

    // Register the memory's read pointer. This ensures that a valid data can be presented to the
    // output buffer stage immedietly when it is ready to accept data. 
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mem_rd_ptr <= 0;
        end
        else begin
            mem_rd_ptr <= mem_next_rd_ptr;                
        end
    end 

    // Memory channel enable decoder
    always@(internal_out_channel)
        for (k=0; k<MAX_CHANNELS; k=k+1)
            if (internal_out_channel == k)
                mem_channel_en[k] = 1'b1;
            else
                mem_channel_en[k] = 1'b0;



    // --------------------------------------------------
    // Memory Read and Write Pointers
    //
    // This is actually a multiplexer that selects the 
    // appropriate read and write pointers based on the 
    // channel information. 
    // To allow a ready latency of 0, the read index is 
    // obtained from the next read pointer and memory 
    // outputs are unregistered.
    // --------------------------------------------------
    always @ (*) begin        
        mem_wr_ptr = {in_channel_sig, wr_ptr[0]} ;        
        for (k = 0 ; k<MAX_CHANNELS; k=k+1)
             if (in_channel_sig == k)
                 mem_wr_ptr = {in_channel_sig, wr_ptr[k]};
    end

    // The memory's read pointer is multiplexed from the read pointer instead of the 
    // next read pointer. This is because the read pointer is registered and this will 
    // increase the overall system frequency.
    // I have tried a combination using the next read pointer and found that it was the 
    // critical path.
    always @ (*) begin
        mem_rd_ptr_sig = {out_channel_sel, rd_ptr[0]} ;
        for (k = 0 ; k<MAX_CHANNELS; k=k+1)
             if (out_channel_sel == k)
                 mem_rd_ptr_sig = {out_channel_sel, rd_ptr[k]};
    end


    // --------------------------------------------------
    // Memory
    //
    // To allow a ready latency of 0, the read index is 
    // obtained from the next read pointer and memory 
    // outputs are unregistered.
    // --------------------------------------------------
    always @(posedge clk) begin
        if (in_valid && in_ready)
            mem[mem_wr_ptr] <= in_payload;
    
    internal_out_payload <= mem[mem_next_rd_ptr];           
    end



    // --------------------------------------------------
    // Internal Avalon-ST Signals
    //
    // The in_ready signal is straightforward, but memory 
    // latency between a write and data being available on
    // the read side means that the out_valid signal
    // must be a delayed version of the empty signal.
    //
    // However, out_valid deassertions must not be
    // delayed or the FIFO will underflow.
    // --------------------------------------------------

    // Valid generation for each channel    
    always @ (*) begin
        internal_out_valid_sig = 0 ;
        for (k = 0 ; k<MAX_CHANNELS; k=k+1)
             if (mem_next_rd_ptr[MEM_ADDR_WIDTH-1 : ADDR_WIDTH] == k )
                 begin
                     if (!mem_read)
                         internal_out_valid_sig = internal_out_valid_reg;
                     else
                         internal_out_valid_sig = ~empty[k] & out_channel_en[k] & pkt_mode_valid[k];                    
                 end
    end


    // Register the valid signal so that the value will be preserved if memory is not read
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            internal_out_valid_reg <= 0;
        end
        else begin
            if (mem_read)
                internal_out_valid_reg <= internal_out_valid_sig;
        end
    end 


    // Generate the internal valid signal
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            internal_out_valid <= 0;
        end
        else begin
            internal_out_valid <= internal_out_valid_sig;
        end
    end 
   

   // Generate the internal channel signal
   always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            internal_out_channel <= 0;
        end
        else begin
            internal_out_channel <= mem_next_rd_ptr[MEM_ADDR_WIDTH-1 : ADDR_WIDTH];
        end
    end
    
    
    // Generate the internal ready signal
    assign internal_out_ready = out_ready | !out_valid;  


    // --------------------------------------------------
    // Single Pipeline Stage
    //
    // The memory outputs are unregistered, so we have
    // to pipeline the output or fmax will drop like a
    // rock if someone puts combinatorial logic on the datapath.
    //
    // Q: Yes, so the Avalon-ST spec says that I have to register
    //    my outputs. But isn't the memory counted as a register?
    // A: The path from the address lookup to the memory output is
    //    slow. So in this case registering the outputs is a really
    //    good idea. Expecting you, dear engineer, to register your
    //    data inputs when using this FIFO seems lame.
    //
    // The registers get packed into the memory by the fitter
    // which means minimal resources are consumed. This output
    // stage acts as an extra slot in the FIFO, and complicates 
    // the fill level.
    // --------------------------------------------------   

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_valid <= 0;
            out_payload <= 0;
            out_channel <= 0;
        end
        else begin
            if (internal_out_ready) begin
                out_valid <= internal_out_valid;
                out_payload <= internal_out_payload;
                out_channel <= internal_out_channel;
            end
        end
    end


    // --------------------------------------------------
    // Status Management
    //
    // Generates the full and empty signals from the
    // pointers. The FIFO is full when the next write 
    // pointer will be equal to the read pointer after
    // a write. Reading from a FIFO clears full.
    //
    // The FIFO is empty when the next read pointer will
    // be equal to the write pointer after a read. Writing
    // to a FIFO clears empty.
    //
    // A simultaneous read and write must not change any of 
    // the empty or full flags.
    //
    // If packets are dropped, the write pointer goes down. 
    // So, the next write pointer is used to determine the 
    // full and empty signals
    // --------------------------------------------------
    
    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : FULL_EMPTY_SIGNALS
        
        always @* begin
            next_full[i] = full[i];
            next_empty[i] = empty[i];

            if (read[i] && !write[i]) begin
                if (!(full[i] & (fill_next_rd_ptr[i] == wr_ptr[i])))
                next_full[i] = 0;

                if (incremented_rd_ptr[i] == wr_ptr[i])
                    next_empty[i] = 1'b1;
            end
        
            if (write[i] && !drop_packet[i] && !read[i]) begin
                next_empty[i] = 0;

                if (next_wr_ptr[i] == fill_next_rd_ptr[i])

                    next_full[i] = 1'b1;
            end
  
            if (write[i] && drop_packet[i] && !read[i]) begin
                if (next_wr_ptr[i] == fill_next_rd_ptr[i])
                    next_empty[i] = 1'b1;
            end
            
            if (write[i] && drop_packet[i] && read[i]) begin
                next_full[i] = 0;
                
                if (next_wr_ptr[i] == fill_next_rd_ptr[i])
                    next_empty[i] = 1'b1;
            end

            if (write[i] && !drop_packet[i] && read[i]) begin

                if (next_wr_ptr[i] == fill_next_rd_ptr[i])

                    next_full[i] = 1;

            end


        end



        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                empty[i] <= 1;
                full[i] <= 0;
            end
            else begin 
                full[i] <= next_full[i];
                empty[i] <= next_empty[i];
            end
        end

        end
    endgenerate



    // --------------------------------------------------
    // Fill Level
    //
    // The fill level is calculated from the next write
    // and read pointers to avoid unnecessary latency.
    //
    // The fill level does not account for the output stage,
    // so we'll always be off by one. Some applications might
    // need accurate fill levels, such as a bursting DMA
    // that wants to know the current fill level of the
    // FIFO before it issues a burst. Other applications
    // such as Ethernet just want to use this information
    // for flow control purposes and do not require an
    // exact fill level.
    //
    // For now, we will not account for the output stage 
    // thus producing fill levels off by one.
    // --------------------------------------------------
   
    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : FILL_LEVEL_SIGNALS
    
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n)
                fifo_fill_level[i] <= 0;
            else if (next_full[i])
                fifo_fill_level[i] <= DEPTH;
            else if (read[i] && (next_wr_ptr[i] == fill_next_rd_ptr[i]))
                fifo_fill_level[i] <= DEPTH;
            else begin
                fifo_fill_level[i][ADDR_WIDTH] <= 0;
                fifo_fill_level[i][ADDR_WIDTH - 1 : 0] <= next_wr_ptr[i] - fill_next_rd_ptr[i];
            end
        end

        // In the future, we can add the output stage to the fill level here if we
        // intend to do so.
        always @* begin
            fill_level[i] = fifo_fill_level[i];
        end

        end
    endgenerate



    // --------------------------------------------------
    // Packet Buffer Mode
    //
    // 
    // --------------------------------------------------

    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : SECTION_AVAILABLE   

        assign sav[i] = (USE_PACKETS == 1 && PACKET_BUFFER_MODE == 0 && SAV_THRESHOLD > 1)? 
                        (fill_level[i] >= SAV_THRESHOLD) : 1'b1;
        end
    endgenerate


    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : PACKET_BUFFER

            assign eop_ptr[i] = (write[i] & in_endofpacket & !drop_packet[i]) ? wr_ptr[i] : eop_ptr_reg[i];

	        always @(posedge clk or negedge reset_n) begin
	            if (!reset_n) begin
	                eop_ptr_reg[i] <= 0;              
	            end
	            else begin
	                //if (next_empty[i])
	                //    eop_ptr_reg[i] <= next_rd_ptr[i];
	                //else    
	                    eop_ptr_reg[i] <= eop_ptr[i];     
	            end
	        end

	        always @(posedge clk or negedge reset_n) begin
	            if (!reset_n) begin
	                have_packets[i] <= 1'b0;             
	            end
	            else begin
	                if (write[i] & in_endofpacket & !drop_packet[i])
	                    have_packets[i] <= 1'b1;
	                else if ((rd_ptr[i] == eop_ptr_reg[i]) & (mem_read & internal_out_valid_sig) & out_channel_en[i])
	                    have_packets[i] <= 1'b0;    
	            end
	        end
 

            assign pkt_mode_valid[i] = (USE_PACKETS == 0) ? 1'b1 :
                                       (PACKET_BUFFER_MODE) ? have_packets[i]:
                                       have_packets[i] | sav[i];

        end
    endgenerate



    // --------------------------------------------------
    // Drop-On-Error Logic
    //
    // 
    // --------------------------------------------------
    
    generate for (i = 0 ; i<MAX_CHANNELS; i=i+1)
        begin : DROP_ERROR_PACKETS
                        
            always @(posedge clk or negedge reset_n) begin
	            if (!reset_n) begin
	                sop_ptr[i] <= 0;
	            end
	            else begin
	                if (write[i] & in_endofpacket)  
	                    sop_ptr[i] <= next_wr_ptr[i];	                   
	            end
	        end

            always @(posedge clk or negedge reset_n) begin
	            if (!reset_n) begin
	                drop_packet_reg[i] <= 1'b0;
	            end
	            else begin
	                if (write[i] & in_endofpacket)  
	                    drop_packet_reg[i] <= 1'b0;
	                else if (write[i])
	                    drop_packet_reg[i] <= drop_packet[i];	                   
	            end
	        end                    

            assign err_packet[i] = (ERROR_WIDTH > 0) ? |in_error : 0;
            assign drop_packet[i] = (DROP_ON_ERROR == 1)? 
                                     drop_packet_reg[i] | err_packet[i] : 1'b0; 
            
        end
    endgenerate





    // --------------------------------------------------
    // Status Connection Point
    //
    // Register map:
    //
    // | Addr   |    31 - 0         |
    // | 0 - 15 |   Fill level      |
    //
    // I've set a read latency of 1 for the status port
    // as the muxed output is registered 
    // (some scheduler/QOR component might need it).
    // --------------------------------------------------
    
    always @(posedge clk or negedge reset_n) begin 
        if (!reset_n)
            begin
            status_readdata <= {32{1'b 0}};   
            end
        else
            begin
            if (USE_FILL_LEVEL == 1 && status_read == 1'b 1)
                begin
         
                case (status_address)
                
                    8'h0:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[0] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ;   
                    end     

                    8'h1:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[1] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ;    
                    end
                    
                    8'h2:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[2] ; 
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ;   
                    end
                    
                    8'h3:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[3] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h4:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[4] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h5:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[5] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h6:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[6] ;
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h7:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[7] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h8:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[8] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'h9:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[9] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'hA:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[10] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'hB:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[11] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'hC:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[12] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'hD:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[13] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                    
                    8'hE:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[14] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end

                    8'hF:
                    begin
                    status_readdata[ADDR_WIDTH : 0] <= fill_level[15] ;   
                    status_readdata[31 : ADDR_WIDTH+1] <= {(31-ADDR_WIDTH){1'b 0}} ; 
                    end
                                           
                    default:
                    begin
                    status_readdata <= {32{1'b 0}}; 
                    end
                    
                endcase
                                
                end
            else
                begin
                status_readdata <= {32{1'b 0}};   
                end
            end
        end

   

    // --------------------------------------------------
    // Control Connection Point
    //
    // Register map:
    //
    // | Addr   |                31 - 0                  |
    // |  00    |         Almost full threshold 1        |
    // |  01    |         Almost empty threshold 1       |
    // |  10    |         Almost full threshold 2        |
    // |  11    |         Almost empty threshold 2       |
    //
    // --------------------------------------------------
    
    generate if (USE_ALMOST_FULL) 
        begin
                
        always @(posedge clk or negedge reset_n) 
            begin
            if (!reset_n) 
                begin
                almost_full_threshold_reg <= 0;
                end
            else if (control_write == 1'b1 && control_address == 2'b00)
                begin
                almost_full_threshold_reg <= control_writedata[ADDR_WIDTH - 1 : 0];                                
                end                            
            end
        
        assign almost_full_threshold = almost_full_threshold_reg;  
              
        end
    else
        begin
        
        assign almost_full_threshold = {ADDR_WIDTH{1'b0}};       
         
        end
    endgenerate


    generate if (USE_ALMOST_EMPTY) 
        begin
                
        always @(posedge clk or negedge reset_n) 
            begin
            if (!reset_n) 
                begin
                almost_empty_threshold_reg <= 0;
                end
            else if (control_write == 1'b1 && control_address == 2'b01)
                begin
                almost_empty_threshold_reg <= control_writedata[ADDR_WIDTH - 1 : 0];                
                end            
            end
        
        assign almost_empty_threshold = almost_empty_threshold_reg;  
              
        end
    else
        begin
        
        assign almost_empty_threshold = {ADDR_WIDTH{1'b0}};       
         
        end
    endgenerate
    

    generate if (USE_ALMOST_FULL2) 
        begin
                
        always @(posedge clk or negedge reset_n) 
            begin
            if (!reset_n) 
                begin
                almost_full2_threshold_reg <= 0;
                end
            else if (control_write == 1'b1 && control_address == 2'b10)
                begin
                almost_full2_threshold_reg <= control_writedata[ADDR_WIDTH - 1 : 0];                                
                end                            
            end
        
        assign almost_full2_threshold = almost_full2_threshold_reg;  
              
        end
    else
        begin
        
        assign almost_full2_threshold = {ADDR_WIDTH{1'b0}};       
         
        end
    endgenerate


    generate if (USE_ALMOST_EMPTY2) 
        begin
                
        always @(posedge clk or negedge reset_n) 
            begin
            if (!reset_n) 
                begin
                almost_empty2_threshold_reg <= 0;
                end
            else if (control_write == 1'b1 && control_address == 2'b11)
                begin
                almost_empty2_threshold_reg <= control_writedata[ADDR_WIDTH - 1 : 0];                
                end            
            end

        assign almost_empty2_threshold = almost_empty2_threshold_reg;  
              
        end
    else
        begin

        assign almost_empty2_threshold = {ADDR_WIDTH{1'b0}};       
         
        end
    endgenerate
    

    always @(*) begin
        control_readdata = 0;

        if (control_read) begin
            if (control_address == 2'b00)
                control_readdata = {{32-ADDR_WIDTH {1'b0}}, almost_full_threshold};
            else if (control_address == 2'b01)
                control_readdata = {{32-ADDR_WIDTH {1'b0}}, almost_empty_threshold};
            else if (control_address == 2'b10)
                control_readdata = {{32-ADDR_WIDTH {1'b0}}, almost_full2_threshold};
            else
                control_readdata = {{32-ADDR_WIDTH {1'b0}}, almost_empty2_threshold};
        end
    end



    // --------------------------------------------------
    // Fill Level Status
    //
    // These status signals will be continuously transmitted 
    // (valid always high) in a round robin fashion with 
    // the appropriate channel ID
    // --------------------------------------------------
    
    generate    
        for (i = 0 ; i<MAX_CHANNELS; i=i+1) 
            begin : FILL_STATUS_GENERATION      
                   
                assign almost_full_status_wire[i] = (USE_ALMOST_FULL) ? 
                                                   (fill_level[i] >= almost_full_threshold) : 1'b0;

                assign almost_full2_status_wire[i]        = (USE_ALMOST_FULL2) ? 
                                                   (fill_level[i] >= almost_full2_threshold) : 1'b0;

                assign almost_empty_status_wire[i] = (USE_ALMOST_EMPTY) ? 
                                                    (fill_level[i] <= almost_empty_threshold) : 1'b0;     

                assign almost_empty2_status_wire[i]        = (USE_ALMOST_EMPTY2) ? 
                                                    (fill_level[i] <= almost_empty2_threshold) : 1'b0;                                                     
            end            
    endgenerate


    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            status_ctr <= 0;
        end
        
        else if (status_ctr == MAX_CHANNELS-1) begin
            status_ctr <= 0;
        end 

        else begin
            status_ctr <= status_ctr + 1'b1;
        end                
    end


    generate if (USE_ALMOST_FULL) 
        begin
            always @ (*) begin        
                almost_full_sig = 0 ;        
                for (k = 0 ; k<MAX_CHANNELS; k=k+1)
                     if (status_ctr == k)
                         almost_full_sig = almost_full_status_wire[k];
            end
        end
    endgenerate

    generate if (USE_ALMOST_FULL2) 
        begin
            always @ (*) begin        
                almost_full2_sig = 0 ;         
                for (k = 0 ; k<MAX_CHANNELS; k=k+1)
                     if (status_ctr == k)
                         almost_full2_sig = almost_full2_status_wire[k];
            end
        end
    endgenerate

    generate if (USE_ALMOST_EMPTY) 
        begin
            always @ (*) begin        
                almost_empty_sig = 1'b1 ;          
                for (k = 0 ; k<MAX_CHANNELS; k=k+1)
                     if (status_ctr == k)
                         almost_empty_sig = almost_empty_status_wire[k];
            end
        end
    endgenerate

    generate if (USE_ALMOST_EMPTY2) 
        begin
            always @ (*) begin        
                almost_empty2_sig = 1'b1 ;        
                for (k = 0 ; k<MAX_CHANNELS; k=k+1)
                     if (status_ctr == k)
                         almost_empty2_sig = almost_empty2_status_wire[k];
            end
        end
    endgenerate
    
    assign almost_full_data = almost_full_data_reg[ALMOST_FULL_WIDTH - 1 :0];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            almost_full_data_reg <= 0;
            almost_full_valid <= 0;
            almost_full_channel <= 0;
        end

        else begin
            almost_full_data_reg <= {almost_full2_sig, almost_full_sig};
            almost_full_valid <= 1;
            almost_full_channel <= status_ctr;
        end                
    end
    
    assign almost_empty_data = almost_empty_data_reg[ALMOST_EMPTY_WIDTH - 1 :0];
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            almost_empty_data_reg <= 0;
            almost_empty_valid <= 0;
            almost_empty_channel <= 0;
        end

        else begin
            almost_empty_data_reg <= {almost_empty2_sig, almost_empty_sig};
            almost_empty_valid <= 1;
            almost_empty_channel <= status_ctr;
        end                
    end



    // --------------------------------------------------
    // Request Connection Point
    //
    // Register map:
    //
    // |       Addr       |         Bits 31 - 0         |
    // | <Channel_number> |  <Number of fifo entries>   |
    //
    // --------------------------------------------------

    generate if (USE_REQUEST == 1 && MAX_CHANNELS > 1) 
        begin

        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                out_channel_sel_reg <= 0;
                out_channel_valid_reg <= 0;
            end
        
            else if (request_write) begin
                out_channel_sel_reg <= request_address[CHANNEL_WIDTH-1:0];
                out_channel_valid_reg <= 1'b1;
            end

            else begin
                out_channel_valid_reg <= 1'b0;
            end
        end
        
        assign out_channel_sel = out_channel_sel_reg;
        assign out_channel_valid = out_channel_valid_reg;
        
        end
    else
        begin
        
        assign out_channel_sel = 0;
        assign out_channel_valid = 1'b1;
        
        end
    endgenerate


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
