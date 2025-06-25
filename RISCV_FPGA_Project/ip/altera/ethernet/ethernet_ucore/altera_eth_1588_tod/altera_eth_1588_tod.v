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


`timescale 1ns / 1ns

// DEVICE   SPEED   ALM   ALUTS   REG     DSP    FMAX(clk / period_clk)     LATENCY
// SV_C4    10G     751   859     1850    1           249 / 390             1
// SV_C4    1G      730   791     1760    1           251 / 282             1
// AV_C5    10G     774   858     1864    1           184 / 254             1
// AV_C5    1G      735   791     1756    1           183 / 206             1

module altera_eth_1588_tod(
                           period_clk,
                           period_rst_n,
                           clk,
                           rst_n,
                           csr_write,
                           csr_read,
                           csr_address,
                           csr_writedata,
                           csr_readdata,
                           csr_waitrequest,
                           time_of_day_96b,
                           time_of_day_64b,
						   time_of_day_96b_load_valid,						   
                           time_of_day_96b_load_data,
 						   time_of_day_64b_load_valid,						   
                           time_of_day_64b_load_data
						   );
   
    parameter DEFAULT_NSEC_PERIOD = 4'd6;
    parameter DEFAULT_FNSEC_PERIOD = 16'h6666;
    parameter DEFAULT_NSEC_ADJPERIOD = DEFAULT_NSEC_PERIOD;
    parameter DEFAULT_FNSEC_ADJPERIOD = DEFAULT_FNSEC_PERIOD;
    parameter TOD_10G = 1; // for 1G (lower freq requirement), switch to "0" to turn on resource optimization

    localparam PERIOD_NSEC_WIDTH = TOD_10G == 1? 4 : 9;
    localparam PERIOD_FNSEC_WIDTH = 16;
    localparam SECOND_WIDTH = 48;
    localparam NSEC_FIELD_WIDTH = 32;
    localparam NSEC_FIELD_WIDTH_64B = 48;
    localparam NSEC_ACTUAL_WIDTH = 30;
    localparam FNSEC_WIDTH = 16;
    localparam ADJCOUNT_WIDTH = 20;
    localparam CSR_WIDTH = 32;

    /*
    * Abbreviations:
    *  NSEC: nanoseconds
    *  FNSEC: fractional nanoseconds
    */

    // Clocks
    // Period clock:
    //   Could be different than control clock. Must have a period correspondent to
    //   the loaded period.
    input period_clk;
    input period_rst_n;
   
    // Control clock
    //   Used for the CSR interface
    input clk;
    input rst_n;

    //  CSR Interface 
    input csr_write;
    input csr_read;
    input [3:0] csr_address;
    input [CSR_WIDTH-1:0] csr_writedata;
    output reg [CSR_WIDTH-1:0] csr_readdata;
    output                     csr_waitrequest;

    // Avalon ST DataOut (Source) Interface (running on period_clk)
    output [SECOND_WIDTH+NSEC_FIELD_WIDTH+FNSEC_WIDTH-1:0]  time_of_day_96b;
    output [NSEC_FIELD_WIDTH_64B+FNSEC_WIDTH-1:0]  time_of_day_64b;
   
	// Used to load TOD value immediately during synchronization
	input													time_of_day_96b_load_valid;
    input [SECOND_WIDTH+NSEC_FIELD_WIDTH+FNSEC_WIDTH-1:0]  time_of_day_96b_load_data;
	input													time_of_day_64b_load_valid;
    input [NSEC_FIELD_WIDTH_64B+FNSEC_WIDTH-1:0]  time_of_day_64b_load_data;	
   
    localparam BILLION = 30'd1000000000; // 11_1011_1001_1010_1100_1010_0000_0000
    localparam BILLION_22      = 22'b    11_1011_1001_1010_1100_1010;
    localparam BILLION_21      = 21'b    11_1011_1001_1010_1100_101;
    localparam ADDR_SECONDH = 4'd0;
    localparam ADDR_SECONDL = 4'd1;
    localparam ADDR_NSEC = 4'd2;
    // Address 3 reserved for possible FNSEC field
    localparam ADDR_PERIOD = 4'd4;
    localparam ADDR_ADJPERIOD = 4'd5;
    localparam ADDR_ADJCOUNT = 4'd6;
    localparam ADDR_TOD_CORR = 4'd7;
    localparam ADDR_TOD_CORR_COUNT = 4'd8; 


    // Period Registers

    // On "clk"
    reg [PERIOD_NSEC_WIDTH-1:0]  csr_period_nsec;
    reg [PERIOD_FNSEC_WIDTH-1:0] csr_period_fnsec;

    reg [PERIOD_NSEC_WIDTH-1:0]  csr_adjperiod_nsec;
    reg [PERIOD_FNSEC_WIDTH-1:0] csr_adjperiod_fnsec;

    // On "period_clk"
    reg [PERIOD_NSEC_WIDTH-1:0]  fast_period_nsec;
    reg [PERIOD_FNSEC_WIDTH-1:0] fast_period_fnsec;
    reg [PERIOD_NSEC_WIDTH-1:0]  fast_adjperiod_nsec;
    reg [PERIOD_FNSEC_WIDTH-1:0] fast_adjperiod_fnsec;
    reg [PERIOD_NSEC_WIDTH-1:0] fast_period_nsec_in;
    reg [PERIOD_FNSEC_WIDTH-1:0] fast_period_fnsec_in;

    // Transfer flop from "clk" to "period_clk"
    wire [PERIOD_NSEC_WIDTH-1:0]  transfer_period_nsec;
    wire [PERIOD_FNSEC_WIDTH-1:0] transfer_period_fnsec;
    wire [PERIOD_NSEC_WIDTH-1:0]  transfer_adjperiod_nsec;
    wire [PERIOD_FNSEC_WIDTH-1:0] transfer_adjperiod_fnsec;

    wire [SECOND_WIDTH-1:0]       transfer_time_sec;
    wire [NSEC_ACTUAL_WIDTH-1:0]  transfer_time_nsec;
    wire [NSEC_FIELD_WIDTH_64B-1:0]  transfer_time_nsec_64b;

    // Staging registers are used for providing a consistent time value across registers
    // When nanoseconds are read out, seconds field is captured in staging to be read out on
    // subsequent accesses.
    // So when reading time from the CSR, nanoseconds should be read first.
    reg [SECOND_WIDTH-1:0]        staging_sec;


    // These load registers facilitate an atomic load of time. The write to the NSEC field causes
    // the seconds and nanoseconds fields to be loaded into the counter.
    reg [SECOND_WIDTH-1:0]        load_sec;
    reg [NSEC_ACTUAL_WIDTH-1:0]   load_nsec;
    reg [NSEC_FIELD_WIDTH_64B-1:0]   load_nsec_64b;
	
	// TOD correction of tod_corr_nsec,tod_corr_fnsec in every tod_corr_count of cycles
	reg [15:0] corr_counter;
	reg		   correct_tod_now;
	reg [15:0] fast_tod_corr_count;
	reg [3:0]  fast_tod_corr_nsec;
	reg [15:0] fast_tod_corr_fnsec;	
	reg [3:0]  tod_corr_nsec;
	reg [15:0] tod_corr_fnsec;
	reg		   valid_load_tod_corr;	
	reg [15:0] tod_corr_count;
	reg		   valid_load_tod_corr_count;
	
	wire tod_corr_count_load_ack;
	wire tod_corr_load_ack;	
	wire fast_tod_corr_load;
	wire fast_tod_corr_count_load;
	wire [3:0] transfer_tod_corr_nsec;
	wire [15:0] transfer_tod_corr_fnsec;
	wire [15:0] transfer_tod_corr_count;	
	

    // These flags indicate the need to load the time or period into the actual time or period 
    // registers in the "period_clk" domain.
    reg                         valid_load_time,
                                valid_load_period,
                                valid_load_adjperiod,
                                valid_load_adjcount;
   

    wire                        time_load_ack,
                                period_load_ack,
                                adjperiod_load_ack;

    // The capture registers are always capturing the "period_clk" versions of the second and nanosecond
    // counters into "clk" registers.
    wire [SECOND_WIDTH-1:0]       capture_sec;
    wire [NSEC_ACTUAL_WIDTH-1:0]  capture_nsec;
    reg [SECOND_WIDTH-1:0]       capture_sec_reg;
    reg [NSEC_ACTUAL_WIDTH-1:0]  capture_nsec_reg;
   
    reg [ADJCOUNT_WIDTH-1:0]      csr_adjcount;
    reg [ADJCOUNT_WIDTH-1:0]      fast_adjcount;
    wire [ADJCOUNT_WIDTH-1:0]     transfer_adjcount;
   
    reg                           fast_adjcount_zero;
    wire                          adjcount_load_ack;
    wire                          transfer_adjcount_zero;
    wire                          valid_capture_time;
	
	wire [NSEC_FIELD_WIDTH+FNSEC_WIDTH-1:0]	load_tod_ns_fns_sum;
   

    // ###########################################################################################
    // ---------------------------------------------------------------------------
    // CSR Interface and Register Space
    // ---------------------------------------------------------------------------
    // ###########################################################################################
    always @(posedge clk or negedge rst_n) begin
	 	if (rst_n == 0) begin
	 		capture_sec_reg <= 0;
	 		capture_nsec_reg <= 0;
	 	end
	 	else begin
	 		if (valid_capture_time) begin
	 			capture_sec_reg <= capture_sec;
	 			capture_nsec_reg <= capture_nsec;	  
	 		end
	 	end
	 end


    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
           load_sec <= 0;
           load_nsec <= 0;
           load_nsec_64b <= 0;
           valid_load_time <= 0;
        end
        else begin
            // If either load flag is asserted, updates to registers should be ignored
            // until the load has been performed.
            
            if (valid_load_time == 1) begin
                if (time_load_ack == 1)
                    valid_load_time <= 0;
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                    ADDR_SECONDH: begin
                        load_sec <= {csr_writedata[15:0],load_sec[31:0]};
                    end
                    ADDR_SECONDL: begin
                        load_sec <= {load_sec[47:32],csr_writedata[31:0]};
                        //load_nsec_64b <= csr_writedata[17:0]*BILLION;
                        // do in the following way to optimize frequency
                        load_nsec_64b[NSEC_FIELD_WIDTH_64B-1:9] <= csr_writedata[17:0]*BILLION_21;
                        load_nsec_64b[8:0] <= 9'd0;
                    end
                    ADDR_NSEC: begin
                        load_nsec <= csr_writedata[NSEC_ACTUAL_WIDTH-1:0];
                        load_nsec_64b <= load_nsec_64b + csr_writedata[NSEC_ACTUAL_WIDTH-1:0];
                        valid_load_time <= 1;
                    end
                endcase
            end
        end
    end // always @ (posedge clk or negedge rst_n)


    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
           csr_period_nsec  <= DEFAULT_NSEC_PERIOD;
           csr_period_fnsec <= DEFAULT_FNSEC_PERIOD;
           valid_load_period <= 0;
        end
        else begin
            if (valid_load_period == 1) begin
                if (period_load_ack == 1)
                    valid_load_period <= 0;
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                    ADDR_PERIOD: begin
                        csr_period_nsec  <= csr_writedata[PERIOD_NSEC_WIDTH+PERIOD_FNSEC_WIDTH-1:PERIOD_FNSEC_WIDTH];
                        csr_period_fnsec <= csr_writedata[PERIOD_FNSEC_WIDTH-1:0];
                        valid_load_period <= 1;
                    end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
            csr_adjperiod_nsec  <= DEFAULT_NSEC_ADJPERIOD;
            csr_adjperiod_fnsec <= DEFAULT_FNSEC_ADJPERIOD;
            valid_load_adjperiod <= 0;
        end
        else begin
            if (valid_load_adjperiod == 1) begin
                if (adjperiod_load_ack == 1)
                valid_load_adjperiod <= 0;
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                ADDR_ADJPERIOD: begin
                    csr_adjperiod_nsec  <= csr_writedata[PERIOD_NSEC_WIDTH+PERIOD_FNSEC_WIDTH-1:PERIOD_FNSEC_WIDTH];
                    csr_adjperiod_fnsec <= csr_writedata[PERIOD_FNSEC_WIDTH-1:0];
                    valid_load_adjperiod <= 1;
                end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
            csr_adjcount <= 0;
            valid_load_adjcount <= 0;
        end
        else begin
            if (valid_load_adjcount == 1) begin
                if (adjcount_load_ack == 1)
                valid_load_adjcount <= 0;
            end else if (adjcount_load_ack == 1 &&  // Second time!
                        csr_adjcount != 0 && 
                        transfer_adjcount_zero == 1) begin
                csr_adjcount  <= {(ADJCOUNT_WIDTH){1'b0}};
                valid_load_adjcount <= 0; // redundant?
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                ADDR_ADJCOUNT: begin
                    csr_adjcount  <= csr_writedata[ADJCOUNT_WIDTH-1:0];
                    valid_load_adjcount <= 1;
                end
                endcase
            end
        end
    end

  always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
           tod_corr_nsec  <= 4'h0;
           tod_corr_fnsec <= 16'h0;
           valid_load_tod_corr <= 0;
        end
        else begin
            if (valid_load_tod_corr == 1) begin
                if (tod_corr_load_ack == 1)
                    valid_load_tod_corr <= 0;
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                    ADDR_TOD_CORR: begin
                        tod_corr_nsec  <= csr_writedata[19:16];
                        tod_corr_fnsec <= csr_writedata[15:0];
                        valid_load_tod_corr <= 1;
                    end
                endcase
            end
        end
    end	

  always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
           tod_corr_count  <= 16'h0;
           valid_load_tod_corr_count <= 0;
        end
        else begin
            if (valid_load_tod_corr_count == 1) begin
                if (tod_corr_count_load_ack == 1)
                    valid_load_tod_corr_count <= 0;
            end else if ((csr_waitrequest == 0) && (csr_write)) begin
                case(csr_address)
                    ADDR_TOD_CORR_COUNT: begin
                        tod_corr_count <= csr_writedata[15:0];
                        valid_load_tod_corr_count <= 1;
                    end
                endcase
            end
        end
    end	

    always @(posedge clk or negedge rst_n) begin
        if (rst_n==0) begin
            csr_readdata <= {CSR_WIDTH{1'b0}};
            staging_sec  <= {SECOND_WIDTH{1'b0}};
        end
        else begin
            if(csr_read == 1'b1) begin
                case(csr_address)
                ADDR_SECONDH: begin
                    csr_readdata <= {16'b0,staging_sec[47:32]};
                    staging_sec <= staging_sec;
                end
                ADDR_SECONDL: begin
                    csr_readdata <= staging_sec[31:0];
                    staging_sec <= staging_sec;
                end
                ADDR_NSEC: begin
                    // Read NSEC and capture Seconds
                        csr_readdata <= {{(CSR_WIDTH-NSEC_ACTUAL_WIDTH){1'b0}},
                                        capture_nsec_reg};
                        staging_sec <= capture_sec_reg;
                end
                ADDR_PERIOD: begin
                    csr_readdata <= {{(CSR_WIDTH-
                                        PERIOD_NSEC_WIDTH-
                                        PERIOD_FNSEC_WIDTH){1'b0}},
                                    csr_period_nsec, 
                                    csr_period_fnsec};
                    staging_sec <= staging_sec;
                end
                ADDR_ADJPERIOD: begin
                    csr_readdata <= {{(CSR_WIDTH-
                                        PERIOD_NSEC_WIDTH-
                                        PERIOD_FNSEC_WIDTH){1'b0}},
                                    csr_adjperiod_nsec, 
                                    csr_adjperiod_fnsec};
                    staging_sec <= staging_sec;
                end
                ADDR_ADJCOUNT: begin
                    csr_readdata <= {{(32-ADJCOUNT_WIDTH){1'b0}},
                                    csr_adjcount};
                    staging_sec <= staging_sec;
                end
                ADDR_TOD_CORR: begin
                    csr_readdata <= {{12{1'b0}},
                                    tod_corr_nsec,tod_corr_fnsec};
                    staging_sec <= staging_sec;
                end	
                ADDR_TOD_CORR_COUNT: begin
                    csr_readdata <= {{16{1'b0}},
                                    tod_corr_count};
                    staging_sec <= staging_sec;
                end				
                default : begin
                    csr_readdata <= csr_readdata;
                    staging_sec <= staging_sec;
                end
                endcase
            end
            else begin
                csr_readdata <= csr_readdata;
                staging_sec <= staging_sec;
            end
            
        end
    end

    /* Actual counters running on period_clk */

    wire                    fast_period_load,
                            fast_adjperiod_load,
                            fast_adjcount_load,
                            fast_time_load;

    assign csr_waitrequest =    (valid_load_period | !period_load_ack) |
                                (valid_load_adjperiod | !adjperiod_load_ack) |
                                (valid_load_adjcount | !adjcount_load_ack) |
                                (valid_load_time | !time_load_ack);


    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(SECOND_WIDTH+NSEC_ACTUAL_WIDTH+NSEC_FIELD_WIDTH_64B))
    time_transfer1(.in_clk(clk),
                    .in_reset(~rst_n),
                    .in_ready(time_load_ack),
                    .in_valid(valid_load_time),
                    .in_data({load_sec,load_nsec,load_nsec_64b}),
                    .out_clk(period_clk),
                    .out_reset(~period_rst_n),
                    .out_ready(1'b1),
                    .out_valid(fast_time_load),
                    .out_data({transfer_time_sec,
                               transfer_time_nsec,transfer_time_nsec_64b}));
                               

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(SECOND_WIDTH+NSEC_ACTUAL_WIDTH))
    time_transfer2(.in_clk(period_clk),
                    .in_reset(~period_rst_n),
                    .in_ready(),
                    .in_valid(1'b1),
                    .in_data({time_of_day_96b[95:48],time_of_day_96b[45:16]}),
                    .out_clk(clk),
                    .out_reset(~rst_n),
                    .out_ready(1'b1),
                    .out_valid(valid_capture_time),
                    .out_data({capture_sec,capture_nsec}));

    altera_std_synchronizer
        #(.depth(3))
    adjcount_zero_transfer(.clk(clk),
                            .reset_n(rst_n),
                            .din(fast_adjcount_zero),
                            .dout(transfer_adjcount_zero));

    // Assert out_valid is always asserted

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(PERIOD_NSEC_WIDTH+
                            PERIOD_FNSEC_WIDTH))
    period_transfer(.in_clk(clk),
                    .in_reset(~rst_n),
                    .in_ready(period_load_ack),
                    .in_valid(valid_load_period),
                    .in_data({csr_period_nsec,csr_period_fnsec}),
                    .out_clk(period_clk),
                    .out_reset(~period_rst_n),
                    .out_ready(1'b1),
                    .out_valid(fast_period_load),
                    .out_data({transfer_period_nsec,
                               transfer_period_fnsec}));

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(PERIOD_NSEC_WIDTH+
                            PERIOD_FNSEC_WIDTH))
    adjperiod_transfer(.in_clk(clk),
                        .in_reset(~rst_n),
                        .in_ready(adjperiod_load_ack),
                        .in_valid(valid_load_adjperiod),
                        .in_data({csr_adjperiod_nsec,csr_adjperiod_fnsec}),
                        .out_clk(period_clk),
                        .out_reset(~period_rst_n),
                        .out_ready(1'b1),
                        .out_valid(fast_adjperiod_load),
                        .out_data({transfer_adjperiod_nsec,
                                   transfer_adjperiod_fnsec}));

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(ADJCOUNT_WIDTH),
        .BACKWARD_SYNC_DEPTH(5)
        )
    adjcount_transfer(.in_clk(clk),
                        .in_reset(~rst_n),
                        .in_ready(adjcount_load_ack),
                        .in_valid(valid_load_adjcount),
                        .in_data(csr_adjcount),
                        .out_clk(period_clk),
                        .out_reset(~period_rst_n),
                        .out_ready(1'b1),
                        .out_valid(fast_adjcount_load),
                        .out_data(transfer_adjcount));

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(20))
    tod_corr_transfer(.in_clk(clk),
                    .in_reset(~rst_n),
                    .in_ready(tod_corr_load_ack),
                    .in_valid(valid_load_tod_corr),
                    .in_data({tod_corr_nsec,tod_corr_fnsec}),
                    .out_clk(period_clk),
                    .out_reset(~period_rst_n),
                    .out_ready(1'b1),
                    .out_valid(fast_tod_corr_load),
                    .out_data({transfer_tod_corr_nsec,
                               transfer_tod_corr_fnsec}));

    altera_avalon_st_clock_crosser
        #(.BITS_PER_SYMBOL(16))
    tod_corr_count_transfer(.in_clk(clk),
                    .in_reset(~rst_n),
                    .in_ready(tod_corr_count_load_ack),
                    .in_valid(valid_load_tod_corr_count),
                    .in_data(tod_corr_count),
                    .out_clk(period_clk),
                    .out_reset(~period_rst_n),
                    .out_ready(1'b1),
                    .out_valid(fast_tod_corr_count_load),
                    .out_data(transfer_tod_corr_count));

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_period_nsec  <= DEFAULT_NSEC_PERIOD; 
            fast_period_fnsec <= DEFAULT_FNSEC_PERIOD;
        end else begin
            // load the period and assert the loaded
            if (fast_period_load == 1) begin
                fast_period_nsec  <= transfer_period_nsec;
                fast_period_fnsec <= transfer_period_fnsec;
            end else begin
                fast_period_nsec  <= fast_period_nsec;
                fast_period_fnsec <= fast_period_fnsec;
            end
        end
    end

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_adjperiod_nsec  <= DEFAULT_NSEC_ADJPERIOD; 
            fast_adjperiod_fnsec <= DEFAULT_FNSEC_ADJPERIOD;
        end else begin
            // load the period and assert the loaded
            if (fast_adjperiod_load == 1) begin
                fast_adjperiod_nsec  <= transfer_adjperiod_nsec;
                fast_adjperiod_fnsec <= transfer_adjperiod_fnsec;
            end else begin
                fast_adjperiod_nsec  <= fast_adjperiod_nsec;
                fast_adjperiod_fnsec <= fast_adjperiod_fnsec;
            end
        end
    end

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_tod_corr_nsec  <= 4'h0; 
            fast_tod_corr_fnsec  <= 16'h0; 
        end else begin
            // load the period and assert the loaded
            if (fast_tod_corr_load == 1) begin
				fast_tod_corr_nsec  <= transfer_tod_corr_nsec; 
				fast_tod_corr_fnsec  <= transfer_tod_corr_fnsec; 
            end else begin
                fast_tod_corr_nsec  <= fast_tod_corr_nsec;
                fast_tod_corr_fnsec <= fast_tod_corr_fnsec;
            end
        end
    end

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_tod_corr_count  <= 16'h0; 
        end else begin
            // load the period and assert the loaded
            if (fast_tod_corr_count_load == 1) begin
				fast_tod_corr_count  <= transfer_tod_corr_count; 
            end else begin
                fast_tod_corr_count  <= fast_tod_corr_count;
            end
        end
    end

	//Counter that will add correction value to TOD once after every fast_tod_corr_count of cycles
    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            corr_counter  <= 16'h1;
			correct_tod_now <= 1'b0;
        end else begin
            // load the period and assert the loaded
            if (fast_tod_corr_count_load) begin
				corr_counter  <= 16'h1; //start from 1 because the count value provided by customer also start from 1
				correct_tod_now <= 1'b0;				
			end else if (corr_counter == fast_tod_corr_count) begin
				corr_counter  <= 16'h1;
				correct_tod_now <= 1'b1;					
            end else begin
				corr_counter  <= corr_counter + 1'b1;
				correct_tod_now <= 1'b0;
            end
        end
    end

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_adjcount  <= 0;
            fast_adjcount_zero  <= 1'b1;
        end else begin
            // load the period and assert the loaded
            if (fast_adjcount_load == 1'b1) begin
                fast_adjcount <= transfer_adjcount;
                fast_adjcount_zero  <= (transfer_adjcount == 0)? 1'b1:1'b0;
            end else if (fast_adjcount > 1'b1) begin
                fast_adjcount <= fast_adjcount - 20'd1;
                fast_adjcount_zero <= 1'b0;
            end else if (fast_adjcount <= 1) begin
                fast_adjcount <= 0;
                fast_adjcount_zero <= 1'b1;
            end
        end
    end

    always @(posedge period_clk or negedge period_rst_n) begin
        if (period_rst_n == 0) begin
            fast_period_nsec_in  <= DEFAULT_NSEC_PERIOD; 
            fast_period_fnsec_in <= DEFAULT_FNSEC_PERIOD;
        end else begin

            // load the period and assert the loaded
            if (fast_adjcount_zero == 1) begin
                fast_period_nsec_in  <= correct_tod_now ? fast_period_nsec + fast_tod_corr_nsec : fast_period_nsec;
                fast_period_fnsec_in <= correct_tod_now ? fast_period_fnsec+ fast_tod_corr_fnsec : fast_period_fnsec;
            end else begin
                fast_period_nsec_in  <= fast_adjperiod_nsec;
                fast_period_fnsec_in <= fast_adjperiod_fnsec;
            end
    
        end
    end
	
	
	//Quick way to get TOD module support TSE 800ns period width and 10G BIC Fmax requirement
	generate
	if (TOD_10G ==0) begin: period_addition 
		
		// Time counters 96-bit {second_counter, nanosecond_counter, fractional_nanosecond_counter}
		reg [47:0] sec_cntr;                // second counter
		reg [24:0] nsec_fnsec_cntr_low;     // 25-LSB of (nanosecond,fractional nanosecond) counter
		reg [20:0] nsec_fnsec_cntr_high;    // 21-MSB of (nanosecond,fractional nanosecond) counter
		//reg [47:0] sec_cntr_nxt;            // next predicted second counter
		reg        carry_96b_nxt;           // carry of next predicted nsec_fnsec_cntr_low
		reg [24:0] nsec_fnsec_cntr_low_nxt; // next predicted nsec_fnsec_cntr_low


		always @(posedge period_clk or negedge period_rst_n) begin
			if (period_rst_n == 0) begin
				sec_cntr <= 48'd0;
				nsec_fnsec_cntr_low <= 25'd0;
				nsec_fnsec_cntr_high <= 21'd0;
				
				//sec_cntr_nxt <= 48'd0;
				carry_96b_nxt <= 1'b0;
				nsec_fnsec_cntr_low_nxt <= 25'd0;
			
			end else begin

				if (fast_time_load) begin
					sec_cntr <= transfer_time_sec;
					nsec_fnsec_cntr_low <= {transfer_time_nsec[8:0], 16'd0};
					nsec_fnsec_cntr_high <= transfer_time_nsec[29:9];
					
					{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, transfer_time_nsec[8:0], 16'd0} + {1'd0, fast_period_nsec_in, fast_period_fnsec_in};
					
					//sec_cntr_nxt <= transfer_time_sec + 48'd1;

				end 
				else if (time_of_day_96b_load_valid) begin
					sec_cntr <= time_of_day_96b_load_data[95:48];
					nsec_fnsec_cntr_low <= time_of_day_96b_load_data[24:0];
					nsec_fnsec_cntr_high <= time_of_day_96b_load_data[45:25];
					
					{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, time_of_day_96b_load_data[24:0]} + {1'd0, fast_period_nsec_in, fast_period_fnsec_in};
					
					//sec_cntr_nxt <= time_of_day_96b_load_data[95:48] + 48'd1;

				end
				else begin
					if (carry_96b_nxt) begin
						if ((nsec_fnsec_cntr_high + 21'd1) == BILLION_21) begin
							sec_cntr <= sec_cntr + 48'd1;
							nsec_fnsec_cntr_high <= 21'd0;
						end
						else begin
							sec_cntr <= sec_cntr;
							nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high + 21'd1;
						end
					end
					else begin
						sec_cntr <= sec_cntr;
						nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high;
					end
					
					nsec_fnsec_cntr_low <= nsec_fnsec_cntr_low_nxt;
					{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, nsec_fnsec_cntr_low_nxt} + {1'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
			end
		end

		// Time counters 64-bit {nanosecond_counter, fractional_nanosecond_counter}
		reg [31:0] nsec_fnsec_cntr_64b_high; // 32-MSB of 64-bit time counter
		reg [31:0] nsec_fnsec_cntr_64b_low;  // 32-LSB of 64-bit time counter
		reg        carry_64b_nxt;            // carry of next predicted nsec_fnsec_cntr_64b_low
		reg [31:0] nsec_fnsec_cntr_64b_low_nxt; // next predicted nsec_fnsec_cntr_64b_low

		always @(posedge period_clk or negedge period_rst_n) begin
			if (period_rst_n == 0) begin
				nsec_fnsec_cntr_64b_high <= 32'd0;
				nsec_fnsec_cntr_64b_low <= 32'd0;
				nsec_fnsec_cntr_64b_low_nxt <= 32'd0;
				carry_64b_nxt <= 1'b0;
			end else begin
				if (fast_time_load) begin
					nsec_fnsec_cntr_64b_high <= transfer_time_nsec_64b[47:16];
					nsec_fnsec_cntr_64b_low <= {transfer_time_nsec_64b[15:0],16'd0};
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, transfer_time_nsec_64b[15:0],16'd0} + {8'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
				else if (time_of_day_64b_load_valid) begin
					nsec_fnsec_cntr_64b_high <= time_of_day_64b_load_data[63:32];
					nsec_fnsec_cntr_64b_low <= time_of_day_64b_load_data[31:0];
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, time_of_day_64b_load_data[31:0]} + {8'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
				else begin
					if (carry_64b_nxt) begin
						nsec_fnsec_cntr_64b_high <= nsec_fnsec_cntr_64b_high + 32'd1;
					end 
					else begin
						nsec_fnsec_cntr_64b_high <= nsec_fnsec_cntr_64b_high;
					end
					
					nsec_fnsec_cntr_64b_low <= nsec_fnsec_cntr_64b_low_nxt;
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, nsec_fnsec_cntr_64b_low_nxt} + {8'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
			end
		end
		
	   // Time-of-Day Output Ports
	   assign time_of_day_96b = {sec_cntr,2'b00,nsec_fnsec_cntr_high,nsec_fnsec_cntr_low};
	   assign time_of_day_64b = {nsec_fnsec_cntr_64b_high, nsec_fnsec_cntr_64b_low};		
		
		
	end else begin
		
		// Time counters 96-bit {second_counter, nanosecond_counter, fractional_nanosecond_counter}
		reg [47:0] sec_cntr;                // second counter
		reg [23:0] nsec_fnsec_cntr_low;     // 24-LSB of (nanosecond,fractional nanosecond) counter
		reg [21:0] nsec_fnsec_cntr_high;    // 22-MSB of (nanosecond,fractional nanosecond) counter
		reg [47:0] sec_cntr_nxt;            // next predicted second counter
		reg        carry_96b_nxt;           // carry of next predicted nsec_fnsec_cntr_low
		reg [23:0] nsec_fnsec_cntr_low_nxt; // next predicted nsec_fnsec_cntr_low
		reg [21:0] nsec_fnsec_cntr_high_nxt; // next predicted nsec_fnsec_cntr_high
		
		wire sec_incr;
		assign sec_incr = (nsec_fnsec_cntr_high_nxt == BILLION_22);

		always @(posedge period_clk or negedge period_rst_n) begin
			if (period_rst_n == 0) begin
				sec_cntr <= 48'd0;
				nsec_fnsec_cntr_low <= 24'd0;
				nsec_fnsec_cntr_high <= 22'd0;
				
				sec_cntr_nxt <= 48'd0;
				carry_96b_nxt <= 1'b0;
				nsec_fnsec_cntr_low_nxt <= 24'd0;
				nsec_fnsec_cntr_high_nxt <= 22'd0;
			
			end else begin

				if (fast_time_load) begin
					sec_cntr <= transfer_time_sec;
					nsec_fnsec_cntr_low <= {transfer_time_nsec[7:0], 16'd0};
					nsec_fnsec_cntr_high <= transfer_time_nsec[29:8];
					
					{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, transfer_time_nsec[7:0], 16'd0} + {5'd0, fast_period_nsec_in, fast_period_fnsec_in};
					
					if (TOD_10G) begin
						nsec_fnsec_cntr_high_nxt <= transfer_time_nsec[29:8] + 22'd1;
						sec_cntr_nxt <= transfer_time_sec + 48'd1;
					end
					else begin
						nsec_fnsec_cntr_high_nxt <= 22'd0;
						sec_cntr_nxt <= 48'd0;
					end

				end 
				else if (time_of_day_96b_load_valid) begin
					sec_cntr <= time_of_day_96b_load_data[95:48];
					nsec_fnsec_cntr_low <= time_of_day_96b_load_data[23:0];
					nsec_fnsec_cntr_high <= time_of_day_96b_load_data[45:24];
					
					{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, time_of_day_96b_load_data[23:0]} + {5'd0, fast_period_nsec_in, fast_period_fnsec_in};
					
					if (TOD_10G) begin
						nsec_fnsec_cntr_high_nxt <= time_of_day_96b_load_data[45:24] + 22'd1;
						sec_cntr_nxt <= time_of_day_96b_load_data[95:48] + 48'd1;
					end
					else begin
						nsec_fnsec_cntr_high_nxt <= 22'd0;
						sec_cntr_nxt <= 48'd0;
					end

				end
				else begin
					if (TOD_10G) begin
						// Second Increment occurs when carry_96b_nxt and sec_incr are both 1.
						if (carry_96b_nxt) begin
							if (sec_incr) begin
								sec_cntr <= sec_cntr_nxt;
								nsec_fnsec_cntr_high <= 22'd0;
							end
							else begin
								sec_cntr <= sec_cntr;
								nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high_nxt;
							end
						end
						else begin
							sec_cntr <= sec_cntr;
							nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high;
						end
						
						nsec_fnsec_cntr_low <= nsec_fnsec_cntr_low_nxt;
						{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, nsec_fnsec_cntr_low_nxt} + {5'd0, fast_period_nsec_in, fast_period_fnsec_in};
						nsec_fnsec_cntr_high_nxt <= nsec_fnsec_cntr_high + 22'd1;
						sec_cntr_nxt <= sec_cntr + 48'd1;
					end
					else begin
						// Second Increment occurs when carry_96b_nxt and sec_incr are both 1.
						if (carry_96b_nxt) begin
							if ((nsec_fnsec_cntr_high + 22'd1) == BILLION_22) begin
								sec_cntr <= sec_cntr + 48'd1;
								nsec_fnsec_cntr_high <= 22'd0;
							end
							else begin
								sec_cntr <= sec_cntr;
								nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high + 22'd1;
							end
						end
						else begin
							sec_cntr <= sec_cntr;
							nsec_fnsec_cntr_high <= nsec_fnsec_cntr_high;
						end
						
						nsec_fnsec_cntr_low <= nsec_fnsec_cntr_low_nxt;
						{carry_96b_nxt, nsec_fnsec_cntr_low_nxt} <= {1'b0, nsec_fnsec_cntr_low_nxt} + {5'd0, fast_period_nsec_in, fast_period_fnsec_in};
						nsec_fnsec_cntr_high_nxt <= 22'd0;
						sec_cntr_nxt <= 48'd0;                
					end

				end
			end
		end

		// Time counters 64-bit {nanosecond_counter, fractional_nanosecond_counter}
		reg [31:0] nsec_fnsec_cntr_64b_high; // 32-MSB of 64-bit time counter
		reg [31:0] nsec_fnsec_cntr_64b_low;  // 32-LSB of 64-bit time counter
		reg        carry_64b_nxt;            // carry of next predicted nsec_fnsec_cntr_64b_low
		reg [31:0] nsec_fnsec_cntr_64b_low_nxt; // next predicted nsec_fnsec_cntr_64b_low

		always @(posedge period_clk or negedge period_rst_n) begin
			if (period_rst_n == 0) begin
				nsec_fnsec_cntr_64b_high <= 32'd0;
				nsec_fnsec_cntr_64b_low <= 32'd0;
				nsec_fnsec_cntr_64b_low_nxt <= 32'd0;
				carry_64b_nxt <= 1'b0;
			end else begin
				if (fast_time_load) begin
					nsec_fnsec_cntr_64b_high <= transfer_time_nsec_64b[47:16];
					nsec_fnsec_cntr_64b_low <= {transfer_time_nsec_64b[15:0],16'd0};
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, transfer_time_nsec_64b[15:0],16'd0} + {13'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
				else if (time_of_day_64b_load_valid) begin
					nsec_fnsec_cntr_64b_high <= time_of_day_64b_load_data[63:32];
					nsec_fnsec_cntr_64b_low <= time_of_day_64b_load_data[31:0];
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, time_of_day_64b_load_data[31:0]} + {13'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
				else begin
					if (carry_64b_nxt) begin
						nsec_fnsec_cntr_64b_high <= nsec_fnsec_cntr_64b_high + 32'd1;
					end 
					else begin
						nsec_fnsec_cntr_64b_high <= nsec_fnsec_cntr_64b_high;
					end
					
					nsec_fnsec_cntr_64b_low <= nsec_fnsec_cntr_64b_low_nxt;
					{carry_64b_nxt, nsec_fnsec_cntr_64b_low_nxt} <= {1'b0, nsec_fnsec_cntr_64b_low_nxt} + {13'd0, fast_period_nsec_in, fast_period_fnsec_in};
				end
			end
		end	
		
	   // Time-of-Day Output Ports
	   assign time_of_day_96b = {sec_cntr,2'b00,nsec_fnsec_cntr_high,nsec_fnsec_cntr_low};
	   assign time_of_day_64b = {nsec_fnsec_cntr_64b_high, nsec_fnsec_cntr_64b_low};		
	
	end
	endgenerate



endmodule // altera_eth_1588_tod
