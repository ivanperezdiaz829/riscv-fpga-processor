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


`timescale 1ps/1ps

module twentynm_iopll_reconfig_core
#(
	parameter FAMILY        = "Arria 10",
    parameter ADDR_WIDTH    = 9,
    parameter DATA_WIDTH    = 32   // DPRIO = 8, but for counter HI + LO need 2x that
) (
    // Inputs
    input   wire                    mgmt_clk,
    input   wire                    mgmt_rst_n,

    // Avalon-MM slave interface
    input   wire [ADDR_WIDTH-1:0]   mgmt_address,
    input   wire                    mgmt_read,
    input   wire                    mgmt_write,
    input   wire [DATA_WIDTH-1:0]   mgmt_writedata,

    output  wire [DATA_WIDTH-1:0]   mgmt_readdata,
    output  wire                    mgmt_waitrequest,

    // PLL signals
    input   wire [63:0]             reconfig_from_pll,
    output  wire [63:0]             reconfig_to_pll
);

    localparam  DPRIO_DATA_WIDTH    =   8;
    localparam  DPRIO_ADDR_WIDTH    =   9;

    // ADDRESS:
    //  |   is_dps      |   is_counter  |   M/N/C ID            |   C COUNTER INDEX |       -- if is_dps = 0, is_counter = 1    (Counter reconfig)
    //  |   1'b         |   1'b         |   3'b                 |   4'b             |
    //  |   is_dps      |   is_counter  |   DPRIO_ADDRESS                           |       -- if is_dps = 0, is_counter = 0    (Generic reconfig)
    //  |   1'b         |   1'b         |   7'b                                     |
    //  |   is_dps      |   RSVD                                |   cnt_sel         |       -- if is_dps = 1                    (DPS reconfig)
    //  |   1'b         |   4'b                                 |   4'b             |
    //
    // There are at most 70 DPRIO addresses for IOPLL --> 7 bits
    //  (7'b000_0000 to 7'b100_0110)
    // Start command:
    //  9'b0_0_111_1111
    //
    // M/N/C ID:
    //  - M     = 3'b001
    //  - N     = 3'b010
    //  - C*    = 3'b100
    //
    // C Counter Index:
    //  C0 - C8 = 4'b0000 - 4'b1001
    // 
    // Counter div values should be:
    //  |   HI_DIV value    |   LO_DIV value    |
    //  |   8'b             |   8'b             |
    //
    // In the DPRIO, the HI and LO div values are arranged as:
    //  (WIDTH = 8 bits [7 ..0])
    //  |   hi7     ..      hi1     |   bypass_en (cr_n_hi[8])                                              |       -- Register A
    //  |   lo7     ..      lo2     |   odd_duty_en (cr_n_lo[8])                                |   hi0     |       -- Register A + 1
    //  |   crprst10    ..  crprst7 |   crsel1  ..  crsel0                          |   lo1     |   lo0     |       -- Register A + 2
    //  |   RESERVED                |   crprst6     ..      crprst0                                         |       -- Register A + 3
    
    // C counter addresses (all base 10)
    // C0_hi[7:1]   = register 27
    // C0_hi[0]     = register 28
    // C0_lo[7:2]   = register 28
    // C0_lo[1:0]   = register 29
    //
    // C1_hi[7:1]   = register 31
    // C1_hi[0]     = register 32
    // C1_lo[7:2]   = register 32
    // C1_lo[1:0]   = register 33
    //
    // Cx_hi[7:1]   = register 27 + 4*x
    // Cx_hi[0]     = register 28 + 4*x    
    // Cx_lo[7:2]   = register 28 + 4*x 
    // Cx_lo[1:0]   = register 29 + 4*x
    // where x = {0..8}

    // M counter addresses
    // M_hi[7:1]    = register 4
    // M_hi[0]      = register 5
    // M_lo[7:2]    = register 5
    // M_lo[1:0]    = register 6
    
    // N counter addresses
    // N_hi[7:1]    = register 0
    // N_hi[0]      = register 1
    // N_lo[7:2]    = register 1
    // N_lo[1:0]    = register 2
	
	// Bypass enable
	// Bypass_en[0] = register 27 [0]
	
	// Analog attributes
	// BW_ctrl[3:0] = register 10 [6:3]
	// CP_ctrl[2:0] = register 9 [2:0]

    // USER DATA:
    // Counter:
    //  | odd_duty_en   | bypass_enable     |   hi7 ..  hi0     |   lo7 ..  lo0         |
    //  |       17      |       16          |   15  ..  8       |   7   ..  0           |
    // DPS:
    //  |               RSVD                |   up_dn           |   num_phase_shifts    |
    //  |   17          ..              4   |   3               |   2   ..  0           |

    // -----------------------------------------------------------------
    // Latencies (to DPRIO)
    //------------------------------------------------------------------
    //  READ Latencies:
    //  readWaitTime    = 0 (# of extra cycles to hold read high after captured)
    //  readlatency     = 3 (# of cycles for valid data - including read assert capturing cycle)
    //                          _______
    //  Read:               ___|       |_______________________
    //                          ___     ___     ___     ___
    //  CLK:                ___|   |___|   |___|   |___|   |___
    //
    //  CYCLE:                 |   1   |   2   |   3   |
    //                                          ________________
    //  DPRIO READDATA:     ___________________|    DATAOUT
    //
    //  WRITE Latencies:
    //  writeWaitTime   = 0     (one/current cycle write assert sufficient)
    //  writelatency    = n/a   (meaningless, we're not getting data back)

	//BW CP Addresses
	localparam BW_ADDRESS = 9'b1010;
	localparam CP_ADDRESS = 9'b1001;

    // -- Internal wires
    // Data Fifo
    wire readreq_data;
    wire almostfull_data;
    wire empty_data;
    wire full_data;
    wire [DATA_WIDTH-1:0] q_data;
    wire datafifo_write;

    // Cmd Fifo
    wire readreq_cmd;
    wire almostfull_cmd;
    wire empty_cmd;
    wire full_cmd;
    wire [ADDR_WIDTH-1:0] q_cmd;
    wire cmdfifo_write;
    
    // Dprio register addresses for counters
    // Need to write to 3 DPRIO registers
    // per (hi + lo) of each counter
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_0;    
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_1;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_2;

    // Temp DRPIO addresses for C counters
    // use if needed
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_0;    
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_1;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_2;

    // Interface to DPRIO
    // Inputs (of DPRIO)
    wire        dprio_clk;
    wire        dprio_rst_n;
    wire        dprio_read;
    wire        dprio_write;
    wire  [DPRIO_ADDR_WIDTH-1:0]  dprio_address;
    wire  [DPRIO_DATA_WIDTH-1:0]  dprio_writedata;
    // Outputs
    wire [DPRIO_DATA_WIDTH-1:0]  dprio_readdata;

    // Duplicate DPRIO regs for cntr/generic
    reg  [DPRIO_ADDR_WIDTH-1:0]  dprio_address_cnt;
    reg  [DPRIO_DATA_WIDTH-1:0]  dprio_writedata_cnt;
    wire        dprio_write_cnt;
    wire        dprio_read_cnt;

    // Other
    wire is_C;
    wire is_N;
    wire is_M;
    wire start;

    wire reconfig_op_done;      // Single reconfig operation

    reg [DPRIO_DATA_WIDTH-1:0]   dprio_read_reg;

    // Master FSM wires
    reg q1;         // s_chk_fifo
    reg q2;         // s_read_fifo
    reg q3;         // s_save_fifo
    reg q4;         // s_do_op
    reg q5;         // s_done

    wire master_start;
    wire fifo_empty;
    wire done_op;

    // Generic Read/Write wires
    wire    gen_read_en;
    reg     gen_read_start;
    reg     gen_read_dly;
    reg     gen_read_done;
    wire    gen_read_done_status;
	wire	dprio_write_gen;

    wire    gen_write_en;
    reg     gen_write_state;
    reg     gen_write_done;

    // Dynamic Phase Shift wires
    wire    is_dps;
    wire    dps_d0;
    wire    dps_d1;

    reg     dps_q0;
    reg     dps_q1;

    wire    dps_start;
    wire    dps_op_done;
    wire    dps_phase_done;
    wire    [2:0]   dps_num_phase_shifts;
    wire    dps_up_dn;
    wire    dps_phase_en;

    // Counter Read/Write FSM wires
    wire    is_cntr;
    wire    cntr_write_done;
    wire    cntr_write_en;
    wire    cntr_read_done;
    wire    cntr_read_en;
    
    reg     cntr_read1;
    reg     cntr_read2;
    reg     cntr_read3;
    reg     cntr_save1;
    reg     cntr_save2;
    reg     cntr_save3;
    reg     cntr_save4;
    reg     cntr_write1;
    reg     cntr_write2;
    reg     cntr_write3;
    reg     cntr_write4;
    reg     cntr_write5;

    reg     [DATA_WIDTH-1:0]  readdata_cnt;

    // DPRIO reg has pattern C counter index x 4, see comments above
    wire [5:0] physical_c_index_x4 /* synthesis keep */;
    
    wire dprio_busy;

    wire [6:0]  c_cnt_dprio_base;      // Register for Cx_hi[7:1]

    wire pll_locked;
    
    // On reads read from mgmt_address, on writes, read the address coming out of the fifo
    wire [3:0] logical_c_index      /* synthesis keep */; 
    wire [3:0] physical_c_index     /* synthesis keep */;

    wire user_start;
	
	//Analog wires
	wire is_bw;
	wire is_cp;
	
	reg analog_write_en;
	wire analog_read_en;
	wire dprio_write_analog;
	wire dprio_read_analog;
	wire analog_write_en_start;
	
    wire  [DPRIO_ADDR_WIDTH-1:0]  dprio_address_analog;
    wire  [DPRIO_DATA_WIDTH-1:0]  dprio_writedata_analog;
    reg  [DPRIO_DATA_WIDTH-1:0]  analog_old_data;
 
	reg analog_state_done;
	reg analog_state_read_start;
	reg analog_state_read_dly;
	reg analog_state_write;

    // -- END INTERNAL WIRES


    // -- Internal Logic
    // Set the dprio addresses depending on counter
    
    // For C counter rotation
    assign logical_c_index = (cntr_read_en) ? mgmt_address[3:0] : q_cmd[3:0];
    
    logical2physical #(
        .FAMILY(FAMILY)
    ) c_index_translate (
        .logical(logical_c_index),
        .physical(physical_c_index)
    );
    
    assign dprio_cntreg_0 = (is_C == 1'b1) ? dprio_c_cntreg_0   :
                            (is_N == 1'b1) ? 8'd0               :
                            (is_M == 1'b1) ? 8'd4               :
                            8'bx;

    assign dprio_cntreg_1 = (is_C == 1'b1) ? dprio_c_cntreg_1   :
                            (is_N == 1'b1) ? 8'd1               :
                            (is_M == 1'b1) ? 8'd5               :
                            8'bx;

    assign dprio_cntreg_2 = (is_C == 1'b1) ? dprio_c_cntreg_2   :
                            (is_N == 1'b1) ? 8'd2               :
                            (is_M == 1'b1) ? 8'd6               :
                            8'bx;

    assign user_start = mgmt_write & ~(|mgmt_address);     // Start = 9'b000000000
    assign mgmt_waitrequest = ~(q5 & pll_locked & cntr_read_done & gen_read_done_status & analog_state_done);  // q5 captures cntr_write_done and gen_write_done and dps_op_done
    assign reconfig_op_done = cntr_write_done & gen_write_done & dps_op_done & analog_state_done;      // writes only, if called by MASTER FSM.
    //assign reconfig_op_start = analog_write_en || gen_write_en || dps_start || cntr_write_en;
    // To PLL conduit assignments
    assign dprio_clk    = mgmt_clk;
    assign dprio_rst_n  = mgmt_rst_n;

    assign reconfig_to_pll[0]       = dprio_clk;
    assign reconfig_to_pll[1]       = dprio_rst_n;
    assign reconfig_to_pll[2]       = dprio_read;
    assign reconfig_to_pll[3]       = dprio_write;
    assign reconfig_to_pll[12:4]    = dprio_address;
    assign reconfig_to_pll[20:13]   = dprio_writedata;
    assign reconfig_to_pll[24:21]   = physical_c_index;             // directly to cntsel
    assign reconfig_to_pll[27:25]   = dps_num_phase_shifts;
    assign reconfig_to_pll[28]      = dps_up_dn;
    assign reconfig_to_pll[29]      = dps_phase_en;
    
    // From PLL conduit assignemnts
    assign dprio_readdata   = reconfig_from_pll[7:0];
    assign pll_locked       = reconfig_from_pll[8];
    assign dps_phase_done   = reconfig_from_pll[9];

    // Which Counter logic
    assign is_C       = (cntr_read_en) ? mgmt_address[6] : q_cmd[6];
    assign is_N       = (cntr_read_en) ? mgmt_address[5] : q_cmd[5];
    assign is_M       = (cntr_read_en) ? mgmt_address[4] : q_cmd[4];

    assign physical_c_index_x4[5:2] = physical_c_index[3:0];    // mult by 4
    assign physical_c_index_x4[1:0] = 2'b0;

    // DPRIO Muxing
	//which adress sent to pll depends on which mode we're in 
	
    assign dprio_address    =   (cntr_write_en | cntr_read_en)      		?   dprio_address_cnt           : 
                                (gen_write_en)                      		?   q_cmd                       :
                                (gen_read_en)                      	 		?   mgmt_address                : 
								(analog_read_en | analog_write_en)			? 	dprio_address_analog 		: 9'b0;

    assign dprio_writedata  =   (cntr_write_en | cntr_read_en)      		?   dprio_writedata_cnt         :
                                (gen_write_en)                      		?   q_data[7:0]                      : 
								(analog_read_en | analog_write_en)			?	dprio_writedata_analog		: 8'b0;

    assign dprio_write      =   (cntr_write_en | cntr_read_en)      		?   dprio_write_cnt             :
                                (gen_write_en)                      		?   dprio_write_gen                        : 
								(analog_read_en | analog_write_en)			?	dprio_write_analog			: 1'b0;

    assign dprio_read       =   (cntr_write_en | cntr_read_en)      		?   dprio_read_cnt              :
                                (gen_read_en)                       		?   mgmt_read                   : 
								(analog_read_en | analog_write_en)			?	dprio_read_analog			: 1'b0;

    assign mgmt_readdata    =   (cntr_read_done & cntr_read_en)     		?   readdata_cnt                :
                                (gen_read_en | analog_read_en)              ?   dprio_readdata              : 8'b0;
	
    // Find the DPRIO addresses of C counters
    adder_reconf dprio0_add (
        .A({2'b0,physical_c_index_x4}),         // 8b
        .B(8'd27),                              // + 27
        .sumout(dprio_c_cntreg_0)               // 9b
    );

    adder_reconf dprio1_add (
        .A({2'b0,physical_c_index_x4}),         // 8b
        .B(8'd28),                              // + 28
        .sumout(dprio_c_cntreg_1)               // 9b
    );
    
    adder_reconf dprio2_add (
        .A({2'b0,physical_c_index_x4}),         // 8b
        .B(8'd29),                              // + 29
        .sumout(dprio_c_cntreg_2)               // 9b
    );

    // -- END INTERNAL LOGIC


    // ---------- MASTER FSM ---------- //
    assign master_start     = user_start;
    assign fifo_empty       = empty_cmd;
    assign done_op          = reconfig_op_done;// & ~reconfig_op_start; 

    always @(posedge mgmt_clk)
    begin
        if (~mgmt_rst_n)
        begin
            // Default DONE state
            q1 <= 1'b0;
            q2 <= 1'b0;
            q3 <= 1'b0;
            q4 <= 1'b0;
            q5 <= 1'b1;
        end
        else
        begin
            q1 <= (q4 & done_op) | (q5 & master_start);
            q2 <= q1 & ~fifo_empty;
            q3 <= q2;
            q4 <= q3 | (q4 & ~done_op);
            q5 <= (q1 & fifo_empty) | (q5 & ~master_start);
        end
    end
    // -- END MASTER FSM

    // ---------- Counter Reconfig FSM ---------- //
	
	//bit settings
	
	//is_dps: (since write only) queue cmd set is_dps bit and not is_cntr bit
    assign  is_dps          = (mgmt_read) ? (mgmt_address[8] === 1'b1) : (q_cmd[8] === 1'b1); 
	
	//is_cntr: check mgmt for is_cntr bit = 1 during a read
	//		   check queue for is_cntr bit = 1 during a write
    assign  is_cntr         = (mgmt_read) ? (mgmt_address[7] === 1'b1) : (q_cmd[7] === 1'b1); 
	
	//is_bw: check mgmt for is_cp bit = 1 during a read (regardless of whether analog mode or not)
	//		 check queue for is_cp bit = 1 during a write (regardless of whether analog mode or not)	
	assign is_cp 			= (mgmt_read) ? (mgmt_address[5] === 1'b1) : (q_cmd[5] === 1'b1);
	
	//is_bw: check mgmt for is_bw bit = 1 during a read (regardless of whether analog mode or not)
	//		 check queue for is_bw bit = 1 during a write (regardless of whether analog mode or not)
	assign is_bw			= (mgmt_read) ? (mgmt_address[6] === 1'b1) : (q_cmd[6] === 1'b1);

    assign  cntr_write_en   = is_cntr & ~is_dps & (q3|q4);
    assign  cntr_write_done = (cntr_write_en) ? cntr_write5 : 1'b1;      // Last state

    assign  cntr_read_en    = is_cntr & ~is_dps & mgmt_read;
    assign  cntr_read_done  = (cntr_read_en) ? cntr_write5 : 1'b1;

    // Read logic
    assign dprio_read_cnt   = cntr_read2 & ~cntr_save4;            // one cycle behind the dprio_address reg

    // Write logic
    assign dprio_write_cnt  = cntr_write2 & ~cntr_write_done;        // one cycle behind the dprio_address reg

    // M/N/C Counter read-modify-write state machine
    always @(posedge mgmt_clk)
    begin
        if (mgmt_rst_n == 1'b0)
        begin
            cntr_read1      <= 1'b0;
            cntr_read2      <= 1'b0;
            cntr_read3      <= 1'b0;
            cntr_save1      <= 1'b0;
            cntr_save2      <= 1'b0;
            cntr_save3      <= 1'b0;
            cntr_save4      <= 1'b0;
            cntr_write1     <= 1'b0;
            cntr_write2     <= 1'b0;
            cntr_write3     <= 1'b0;
            cntr_write4     <= 1'b0;
            cntr_write5     <= 1'b0;
            readdata_cnt    <= 32'b0;
        end
        else
		  begin
            if (cntr_write_en != 1'b1 && cntr_read_en != 1'b1)
            begin
                cntr_read1      <= 1'b0;
                cntr_read2      <= 1'b0;
                cntr_read3      <= 1'b0;
                cntr_save1      <= 1'b0;
                cntr_save2      <= 1'b0;
                cntr_save3      <= 1'b0;
                cntr_save4      <= 1'b0;
                cntr_write1     <= 1'b0;
                cntr_write2     <= 1'b0;
                cntr_write3     <= 1'b0;
                cntr_write4     <= 1'b0;
                cntr_write5     <= 1'b0;
                readdata_cnt    <= 32'b0;
            end
            else
            begin
                cntr_read1      <= (cntr_write_en != 1'b1 && cntr_read_en != 1'b1)	? 1'b0 : 1'b1;
                cntr_read2      <= cntr_read1;
                cntr_read3      <= cntr_read2;
                cntr_save1      <= cntr_read3;
                cntr_save2      <= cntr_save1;
                cntr_save3      <= cntr_save2;
                cntr_save4      <= cntr_save3;
                cntr_write1     <= cntr_save4   & cntr_write_en;
                cntr_write2     <= cntr_write1  & cntr_write_en;
                cntr_write3     <= cntr_write2  & cntr_write_en;
                cntr_write4     <= cntr_write3  & cntr_write_en;
                cntr_write5     <= (cntr_write_en) ? cntr_write4 : cntr_save4;
                
                // Read reg A+2 for the lo1,lo0 register only
                if (cntr_read1  == 1'b1 && cntr_read2 == 1'b0)                          // reg0
                begin
                    dprio_address_cnt   <= dprio_cntreg_0;                              // hi[7:1], bypass_enable
                end
                if (cntr_read2  == 1'b1 && cntr_read3 == 1'b0)                          // reg1
                begin
                    dprio_address_cnt   <= dprio_cntreg_1;                              // lo[7:2], odd_duty_en, hi[0]
                end
                if (cntr_read3  == 1'b1 && cntr_save1 == 1'b0)                          // reg2
                begin
                    dprio_address_cnt   <= dprio_cntreg_2;                              // lo[1:0]
                end
                // Capture from dprio after 3 cyles of read latency
                if (cntr_save1 == 1'b1 && cntr_save2 == 1'b0)
                begin
                    dprio_read_reg      <= dprio_readdata;
                    readdata_cnt[16]    <= dprio_readdata[0];                           // bypass_en
                    readdata_cnt[15:9]  <= dprio_readdata[7:1];                         // hi[7:1]
                end
                if (cntr_save2 == 1'b1 && cntr_save3 == 1'b0)
                begin
                    dprio_read_reg <= dprio_readdata;
                    readdata_cnt[8]     <= dprio_readdata[0];                           // hi[0]
                    readdata_cnt[17]    <= dprio_readdata[1];                           // odd_duty_en
                    readdata_cnt[7:2]   <= dprio_readdata[7:2];                         // lo[7:2]
                end
                if (cntr_save4 == 1'b1 && cntr_write1 == 1'b0)
                begin
                    dprio_read_reg  <= dprio_readdata; 
                    readdata_cnt[1:0]   <= dprio_readdata[1:0];                         // lo[1:0]
                end
                // Write register 1 2 3 for hi[7:0] and lo[7:0]
                if (cntr_write1 == 1'b1 && cntr_write2 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_0;
                    dprio_writedata_cnt <= {q_data[15:9],q_data[16]};                   // hi7..hi1,byps_enable
                end
                if (cntr_write2 == 1'b1 && cntr_write3 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_1;
                    dprio_writedata_cnt <= {q_data[7:2],q_data[17],q_data[8]};          // lo7..lo2,odd_duty_en,hi0 
                end
                if (cntr_write3 == 1'b1 && cntr_write4 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_2;
                    dprio_writedata_cnt <= {dprio_read_reg[7:2],q_data[1:0]};           // (don't change),lo1..lo0
                end
            end
        end
    end
    // -- END COUNTER RECONFIG READ/WRITE FSM

    // ---------- Generic Address Reconfig FSM ----------//
	wire 	gen_write_en_start;
	assign 	gen_write_en = gen_write_state | gen_write_en_start;
    assign  gen_write_en_start = is_cntr & is_dps & q3;
	//assign gen_write_en = is_cntr & is_dps & q3;
	assign	dprio_write_gen = gen_write_state;
    
    // Delay 1 cycle, writeWaitTime is 0
    always @(posedge mgmt_clk)
    begin
        if (mgmt_rst_n == 1'b0)
        begin
            gen_write_state <= 1'b0;
            gen_write_done  <= 1'b1;
        end
        else
        begin
            gen_write_state <= gen_write_done & gen_write_en_start;
            gen_write_done <= gen_write_state | (gen_write_done & ~gen_write_en_start);     
        end
    end

    // Generic Read FSM
    assign  gen_read_en = is_cntr & mgmt_read & is_dps;
    assign  gen_read_done_status = (gen_read_en) ? gen_read_done : 1'b1;
    // Three cycle read latency
    always @(posedge mgmt_clk)
    begin
        if (mgmt_rst_n == 1'b0)
        begin
            gen_read_start  <= 1'b0;
            gen_read_dly    <= 1'b0;
            gen_read_done   <= 1'b0;
        end
        else
        begin
            gen_read_start  <= gen_read_en;
            gen_read_dly    <= gen_read_en & gen_read_start;
            //gen_read_done   <= gen_read_dly | (gen_read_done & ~gen_read_en);
            gen_read_done   <= gen_read_en & gen_read_dly;
        end
    end

    // -- END GENERIC ADDRESS RECONFIG FSM
	
	// ------- Analog Address reconfig FSM -----------
	assign analog_write_en_start = q3 & ~is_cntr & ~is_dps;
	assign analog_read_en = mgmt_read & ~is_cntr & ~is_dps;
	assign dprio_write_analog = analog_write_en & analog_state_write;
	assign dprio_read_analog = analog_read_en & (analog_state_read_start || analog_state_read_dly);
	
	//the values we want to pass to the dprio address if we're in analog mode
	
	//address is set regardless of the state
	assign dprio_address_analog = is_bw ? (BW_ADDRESS) :
								  is_cp ? (CP_ADDRESS) : 9'b0;
								  
	//writedata is a combo of what was there before and the new user's data (depending on which setting)
	assign dprio_writedata_analog[7] 	= 	analog_old_data[7]; //don't change me
	assign dprio_writedata_analog[6:4] = 	is_bw 				?	q_cmd[6:4]				:
											is_cp				?	q_cmd[2:0]				: 	3'b0;
	assign dprio_writedata_analog[3]	=	is_cp				?	analog_old_data[3]		:
											is_bw				? 	q_cmd[3]				:	1'b0;
	assign dprio_writedata_analog[2:0] 	= 	analog_old_data[2:0];
											
	always @(posedge mgmt_clk)
	begin
		if(mgmt_rst_n == 1'b0)
			analog_write_en <= 1'b0;
		else if(analog_write_en_start)	 //turn on write mode if we see a write
			analog_write_en <= 1'b1;
		else if (analog_state_write) //turn off write mode 
			analog_write_en <= 1'b0;
	end
	
	//data read from pll captured during read (for use in write later)
	always @(posedge mgmt_clk)
	begin
		if(mgmt_rst_n == 1'b0)
			analog_old_data <= dprio_readdata;
		else if(analog_state_read_dly)
			analog_old_data <= dprio_readdata;
		else
			analog_old_data <= analog_old_data;
	end
	
	always @(posedge mgmt_clk)
	begin
		if(mgmt_rst_n == 1'b0)
		begin
			analog_state_done <= 1'b1;
			analog_state_read_start <= 1'b0;
			analog_state_read_dly <= 1'b0;
			analog_state_write <= 1'b0;
		end
		else
		begin
			analog_state_done <= (analog_state_read_dly & ~analog_write_en) || analog_state_write || (~analog_write_en && ~analog_read_en && ~analog_write_en_start);
			analog_state_read_start <= analog_state_done & (analog_write_en_start || analog_read_en);
			analog_state_read_dly <= analog_state_read_start;
			analog_state_write <= analog_state_read_dly & analog_write_en;
		end
	end
	
	// -- END ANALOG ADDRESS RECONFIG FSM

    // Dynamic Phase Shift FSM
    assign dps_start = ~is_cntr & is_dps & (q3|q4);
    assign dps_phase_en = ~dps_q1 & dps_q0;
    assign dps_num_phase_shifts = q_data[2:0];
    assign dps_up_dn = q_data[3];
    assign dps_op_done = ~dps_d0 & ~dps_d1;     // next state != done

    assign dps_d0 = (dps_start & (~(dps_q1 | dps_q0))) | (dps_q1 & ~dps_q0) | (dps_q1 & dps_q0 & ~dps_phase_done);
    assign dps_d1 = (~dps_q1 & dps_q0) | (dps_q1 & ~dps_q0) | (dps_q1 & dps_q0 & ~dps_phase_done);

    always @(posedge mgmt_clk)
    begin
        if (~mgmt_rst_n)
        begin
            // Default DPS_DONE state
            dps_q0 <= 1'b0;
            dps_q1 <= 1'b0;
        end
        else
        begin
            dps_q0 <= dps_d0;
            dps_q1 <= dps_d1;
        end
    end

    // -- END DYNAMIC PHASE SHIFT FSM

    // --- FIFOS --- //
    assign datafifo_write   = mgmt_write & ~user_start;
    assign cmdfifo_write    = mgmt_write & ~user_start;

    assign readreq_data     = q2;
    assign readreq_cmd      = q2;

    // Data fifo
    fifo_reconfig #(
        .NUM_WORDS(8),
        .LOG2_NUM_WORDS(3),
        .WORD_WIDTH(DATA_WIDTH),
        .FAMILY(FAMILY)
    ) DataFifo
    (
        .clock(mgmt_clk),
        .data(mgmt_writedata),
        .rdreq(readreq_data),
        .sclr(~mgmt_rst_n),
        .wrreq(datafifo_write),
        .almost_full(almostfull_data),
        .empty(empty_data),
        .full(full_data),
        .q(q_data),
        .usedw()
    );
    
    // Address (command) fifo
    fifo_reconfig #(
        .NUM_WORDS(8),
        .LOG2_NUM_WORDS(3),
        .WORD_WIDTH(ADDR_WIDTH),
        .FAMILY(FAMILY)
    ) CmdFifo
    (
        .clock(mgmt_clk),
        .data(mgmt_address),
        .rdreq(readreq_cmd),
        .sclr(~mgmt_rst_n),
        .wrreq(cmdfifo_write),
        .almost_full(almostfull_cmd),
        .empty(empty_cmd),
        .full(full_cmd),
        .q(q_cmd),
        .usedw()
    );
    // -- END FIFOS

endmodule

// Translate logical to physica C counters
// for counter rotations
module logical2physical 
#(
    parameter FAMILY = "Arria 10"
)
(
    input   wire [3:0] logical,
    output  wire [3:0] physical
);
    // temporary
    // assign physical = logical;
    
    // Quartus rotates 5 luts, just use LSB 4
    
    //wire [4:0] logical_int      /* synthesis keep */;
    //wire [4:0] physical_int     /* synthesis keep */;

    //assign logical_int = {1'b0, logical};
    //assign physical = physical_int[3:0];
    
    assign gnd = 1'b0 /*synthesis keep*/;

    // LCELLS
    lcell_counter_remap lcell_cnt_sel_0 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[0]));
    defparam lcell_cnt_sel_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
    defparam lcell_cnt_sel_0.dont_touch = "on";
    defparam lcell_cnt_sel_0.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_1 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[1]));
    defparam lcell_cnt_sel_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
    defparam lcell_cnt_sel_1.dont_touch = "on";
    defparam lcell_cnt_sel_1.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_2 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[2]));
    defparam lcell_cnt_sel_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
    defparam lcell_cnt_sel_2.dont_touch = "on";
    defparam lcell_cnt_sel_2.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_3 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[3]));
    defparam lcell_cnt_sel_3.lut_mask = 64'hFF00FF00FF00FF00;
    defparam lcell_cnt_sel_3.dont_touch = "on";
    defparam lcell_cnt_sel_3.family = FAMILY;
    /*lcell_counter_remap lcell_cnt_sel_4 (
        .dataa(logical_int[0]),
        .datab(logical_int[1]),
        .datac(logical_int[2]),
        .datad(logical_int[3]),
        .datae(logical_int[4]),
        .dataf(gnd),
        .datag(gnd),
        .combout (physical_int[4]));
    defparam lcell_cnt_sel_4.lut_mask = 64'hFFFF0000FFFF0000;
    defparam lcell_cnt_sel_4.dont_touch = "on";
    defparam lcell_cnt_sel_4.family = FAMILY;
    */
    // -- END LCELLS

endmodule


module adder_reconf (
    input   wire [7:0]  A,
    input   wire [7:0]  B,
    output  wire [8:0]  sumout
);
    assign sumout = A + B;
endmodule


module fifo_reconfig #(
    parameter NUM_WORDS         = 8,
    parameter LOG2_NUM_WORDS    = 3,
    parameter WORD_WIDTH        = 32,
    parameter FAMILY            = "Arria 10"
) (
	clock,
	data,
	rdreq,
	sclr,
	wrreq,
	almost_full,
	empty,
	full,
	q,
	usedw);

	input	  clock;
	input	[WORD_WIDTH-1:0]  data;
	input	  rdreq;
	input	  sclr;
	input	  wrreq;
	output	  almost_full;
	output	  empty;
	output	  full;
	output	[WORD_WIDTH-1:0]  q;
	output	[LOG2_NUM_WORDS-1:0]  usedw;

	wire [LOG2_NUM_WORDS-1:0] sub_wire0;
	wire  sub_wire1;
	wire  sub_wire2;
	wire [WORD_WIDTH-1:0] sub_wire3;
	wire  sub_wire4;
	wire [LOG2_NUM_WORDS-1:0] usedw = sub_wire0[LOG2_NUM_WORDS-1:0];
	wire  empty = sub_wire1;
	wire  full = sub_wire2;
	wire [WORD_WIDTH-1:0] q = sub_wire3[WORD_WIDTH-1:0];
	wire  almost_full = sub_wire4;

	scfifo	scfifo_component (
				.clock (clock),
				.sclr (sclr),
				.wrreq (wrreq),
				.data (data),
				.rdreq (rdreq),
				.usedw (sub_wire0),
				.empty (sub_wire1),
				.full (sub_wire2),
				.q (sub_wire3),
				.almost_full (sub_wire4),
				.aclr (),
				.almost_empty ());
	defparam
		scfifo_component.add_ram_output_register = "OFF",
		scfifo_component.almost_full_value = NUM_WORDS-2,
		scfifo_component.intended_device_family = FAMILY,
		scfifo_component.lpm_numwords = NUM_WORDS,
		scfifo_component.lpm_showahead = "OFF",
		scfifo_component.lpm_type = "scfifo",
		scfifo_component.lpm_width = WORD_WIDTH,
		scfifo_component.lpm_widthu = LOG2_NUM_WORDS,    // ceil(log2(num_words))
		scfifo_component.overflow_checking = "ON",
		scfifo_component.underflow_checking = "ON",
		scfifo_component.use_eab = "ON";


endmodule

(* altera_attribute = "-name PHYSICAL_SYNTHESIS_COMBO_LOGIC OFF; -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING OFF; -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP OFF; -name REMOVE_REDUNDANT_LOGIC_CELLS OFF" *) module lcell_counter_remap 
#(
    //parameter
    parameter family             = "Arria 10",
    parameter lut_mask           = 64'hAAAAAAAAAAAAAAAA,
    parameter dont_touch         = "on"
) ( 

    input wire      dataa,
    input wire      datab,
    input wire      datac,
    input wire      datad,

    output wire     combout
);
    
    wire gnd /*synthesis keep*/;
    assign gnd = 1'b0;

    generate
        if (family == "Arria 10")
        begin
            twentynm_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(gnd),
                    .dataf(gnd),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
    endgenerate
endmodule
