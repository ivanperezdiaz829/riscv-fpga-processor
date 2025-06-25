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

module twentynm_pll_reconfig_mif_reader  
#(
    parameter   RECONFIG_ADDR_WIDTH     = 9, 
    parameter   RECONFIG_DATA_WIDTH     = 32, 

    parameter   ROM_ADDR_WIDTH          = 9,    // 512 words x	
    parameter   ROM_DATA_WIDTH          = 32,   // 32 bits per word = 20kB 
    parameter	 ROM_NUM_WORDS           = 512, 	// Default 512 32-bit words = 1 M20K  

    parameter   DEVICE_FAMILY           = "Arria 10",
    parameter   ENABLE_MIF              = 0,     
    parameter   MIF_FILE_NAME           = "" 
) (

    // Inputs
    input   wire    mif_clk, 
    input   wire    mif_rst, 

    // Reconfig Module interface for internal register mapping
    input   wire                            reconfig_waitrequest,
	//input   wire [RECONFIG_DATA_WIDTH-1:0]  reconfig_read_data, 	
    output  wire [RECONFIG_DATA_WIDTH-1:0]   reconfig_write_data,
    output  wire [RECONFIG_ADDR_WIDTH-1:0]   reconfig_addr,
    output  wire                             reconfig_write,
    output  wire                             reconfig_read,

    // MIF Controller Interface
    input   wire [ROM_ADDR_WIDTH-1:0]       mif_base_addr,
    input   wire                            mif_start,
    output  wire                            mif_busy

);
        
// NOTE: Assumes settings opcodes/registers are continguous

// ROM Interface ctlr states

localparam  STATE_REG_WIDTH        			= 4;
localparam  MIF_IDLE                		= 4'b0000;
localparam  SET_INSTR_ADDR          		= 4'b0001;
localparam  FETCH_INSTR             		= 4'b0010;
localparam  WAIT_FOR_ROM_INSTR      		= 4'b0011;
localparam  STORE_AND_DECODE_INSTR  		= 4'b0100;
localparam  SET_DATA_ADDR           		= 4'b0101;
localparam  FETCH_DATA              		= 4'b0110;
localparam  WAIT_FOR_ROM_DATA       		= 4'b0111;
localparam  STORE_DATA_AND_INCREASE_COUNT   = 4'b1000;
localparam  WRITE_TO_RECONFIG_FIFO          = 4'b1001;
localparam  START_RECONFIG				    = 4'b1010;
localparam  WAIT_FOR_RECONFIG		        = 4'b1011;
localparam  STORE_GARBAGE_INSTR_AND_DATA  	= 4'b1100;

// MIF Opcodes
localparam OP_START          = 9'b000000000;  
localparam OP_N              = 9'b010100000;
localparam OP_M              = 9'b010010000;
localparam OP_C_COUNTERS     = 9'b011000000; //Base address (9 exist)
localparam OP_DPS            = 9'b100000000; //Base address (11 options exist)
localparam OP_BWCTRL         = 9'b001000000;
localparam OP_CP_CURRENT     = 9'b000100000;

localparam OP_SOM            = 9'b000011110;   
localparam OP_EOM            = 9'b000011111;   

//Control flow registers
reg [STATE_REG_WIDTH-1:0]       mif_curstate;
reg [STATE_REG_WIDTH-1:0]       mif_nextstate;

// Internal data registers
reg  [3:0]						instr_sent_cntr; 	//cntr for number of instructions sent to reconfig (sent 8 then reconfig)
reg [RECONFIG_DATA_WIDTH-1:0] 	stored_data; 		//data captured from rom
reg [RECONFIG_ADDR_WIDTH-1:0] 	stored_instr; 		//instr captured from rom
reg seen_SOM;
reg seen_EOM;
reg never_cleared_fifo;

// ROM Interface
wire 	[ROM_DATA_WIDTH-1:0]     rom_q;     
reg 	[ROM_ADDR_WIDTH-1:0]     rom_addr;

//Output: mif_busy - signal saying mif streaming/reconfig is still going
// if we're not in idle state then we're obviously busy
assign mif_busy = (mif_curstate != MIF_IDLE);

//Just to ensure reconfig works as expected 
assign reconfig_read = 1'b0;

// seen_SOM register - indicates whether OP_SOM has been seen yet
always @(posedge mif_clk)
begin
    if (mif_curstate == MIF_IDLE)
        seen_SOM <= 0;
    else if (stored_instr == OP_SOM && mif_curstate == STORE_AND_DECODE_INSTR)
        seen_SOM <= 1;
    else
        seen_SOM <= seen_SOM;
end

// seen_EOM register - indicates whether OP_EOM has been seen yet
always @(posedge mif_clk) //posedge mif_clk)
begin
    if (mif_curstate == MIF_IDLE)
        seen_EOM <= 0;
    else if (stored_instr == OP_EOM && mif_curstate == STORE_AND_DECODE_INSTR)
        seen_EOM <= 1;
    else
        seen_EOM <= seen_EOM;
end

//never cleared fifo - indicated whether we have flushed the fifo at least once (meaning there is no garbage in it
always @(posedge mif_clk) //posedge mif_clk)
begin
	if(mif_curstate == MIF_IDLE)
		never_cleared_fifo <= 1;
	else if (mif_curstate == START_RECONFIG)
		never_cleared_fifo <= 0;
	else
		never_cleared_fifo <= never_cleared_fifo;
end

//-------------------FSM--------------------------

// State register
always @(posedge mif_clk)
begin
    if (mif_rst)
        mif_curstate <= MIF_IDLE;
    else 
        mif_curstate <= mif_nextstate;
end

// Next state logic
always @(*)
begin
    case (mif_curstate)
	
		//------------ Idle State ---------------
		
        MIF_IDLE:
        begin
            if (mif_start)
                mif_nextstate = SET_INSTR_ADDR;
            else
                mif_nextstate = MIF_IDLE;
        end
        
		//------------- Retrieve MIF instruction line from ROM ----------
		
        // Set address for instruction to be fetched from ROM
        SET_INSTR_ADDR: 
        begin
            mif_nextstate = FETCH_INSTR;
        end

        FETCH_INSTR:
        begin
            mif_nextstate = WAIT_FOR_ROM_INSTR; 
        end
        
        WAIT_FOR_ROM_INSTR: 
        begin
            mif_nextstate = STORE_AND_DECODE_INSTR;
        end
        
        STORE_AND_DECODE_INSTR:
        begin

			//keep reading in lines from mif until you see OP_SOM
			//or if you have seen OP_SOM get the first instruction (next line)
			if(stored_instr == OP_SOM || ~seen_SOM) 				
				mif_nextstate = SET_INSTR_ADDR;
			//there is no more data - but you must fill the fifo with garbage to get rid of what was there before
			else if (stored_instr == OP_EOM && instr_sent_cntr != 0 && never_cleared_fifo)
				mif_nextstate = STORE_GARBAGE_INSTR_AND_DATA;
			//there is no more data - reconfig the queue in fifo
			else if (stored_instr == OP_EOM) //&& instr_sent_cntr == 0
				mif_nextstate = START_RECONFIG;
			//regular instruction  - go get data
			else
				mif_nextstate = SET_DATA_ADDR; 
        end

		//------------- Retrieve MIF data line from ROM ----------
		
        SET_DATA_ADDR:
        begin
            mif_nextstate = FETCH_DATA;
        end

        FETCH_DATA:
        begin
            mif_nextstate = WAIT_FOR_ROM_DATA; 
        end

        WAIT_FOR_ROM_DATA:
        begin
            mif_nextstate = STORE_DATA_AND_INCREASE_COUNT;
        end
        
        STORE_DATA_AND_INCREASE_COUNT:
        begin
            mif_nextstate = WRITE_TO_RECONFIG_FIFO;
        end
   

		//-------------- Write Current instruction to reconfig FIFO	-------------
		WRITE_TO_RECONFIG_FIFO:
		begin
			//full fifo - write to reconfig
			if(instr_sent_cntr == 8) 
				mif_nextstate = START_RECONFIG;
			//last instruction, but fifo's still got garbage in it
			else if (seen_EOM && never_cleared_fifo)
				mif_nextstate = STORE_GARBAGE_INSTR_AND_DATA;
			//otherwise - keep filling fifo with instructions
			else 
				mif_nextstate = SET_INSTR_ADDR;
		end
		
		//-------------- Fake store to fill fifo -------------------------
		STORE_GARBAGE_INSTR_AND_DATA:
		begin
			mif_nextstate = WRITE_TO_RECONFIG_FIFO;
		end
		
		//-------------- Start reconfig --------------
		
		START_RECONFIG:
		begin
			mif_nextstate = WAIT_FOR_RECONFIG;
		end
		
		//wait for reconfig to finish reconfiging (check reconfig_waitrequest)
		WAIT_FOR_RECONFIG:
		begin
			//keep waiting for reconfig to finish reconfiging
			if(reconfig_waitrequest)
				mif_nextstate = WAIT_FOR_RECONFIG;
			//reconfig's done and we've no more instructions
			else if (seen_EOM)
				mif_nextstate = MIF_IDLE;
			//reconfig's done - keep reading the mif file
			else
				mif_nextstate = SET_INSTR_ADDR;
		end
		
		//-------------default-------------------
        default:
        begin
            mif_nextstate = MIF_IDLE;
        end
	
	endcase
end

//--------------------DATA FLOW---------------------------

//instr_sent_cntr
always @(posedge mif_clk) //posedge curstate?
begin
	if(mif_curstate == MIF_IDLE || mif_curstate == START_RECONFIG)
		instr_sent_cntr <= 0;
	else if(mif_curstate == STORE_DATA_AND_INCREASE_COUNT || mif_curstate == STORE_GARBAGE_INSTR_AND_DATA)
		instr_sent_cntr <= instr_sent_cntr + 1'b1;
end

//rom_addr - sent to the rom - line to read
always @(posedge mif_clk) //posedge curstate?
begin
	if(mif_curstate == MIF_IDLE)
		rom_addr <= mif_base_addr;
	else if(mif_curstate == STORE_AND_DECODE_INSTR || mif_curstate == STORE_DATA_AND_INCREASE_COUNT)
		rom_addr <= rom_addr + 1'b1;
	else
		rom_addr <= rom_addr;
end

//reconfig_write - either writing to reconfig fifo or sending start signal to reconfig
assign reconfig_write = (mif_curstate == START_RECONFIG || mif_curstate == WRITE_TO_RECONFIG_FIFO);

//stored_data - stores the "data" for reconfig produced by the rom
always @(posedge mif_clk)//posedge mif_clk) //posedge curstate?
begin
	if(mif_curstate == STORE_GARBAGE_INSTR_AND_DATA) 
		stored_data <= 32'b000000000;
	else if (mif_curstate == WAIT_FOR_ROM_DATA)//STORE_DATA_AND_INCREASE_COUNT) 
		stored_data <= rom_q;
	else 
		stored_data <= stored_data;
end

//stored_instr -  stores the "instr" for reconfig produced by the rom
always @(posedge mif_clk)//posedge mif_clk) //posedge curstate?
begin
	if(mif_curstate == STORE_GARBAGE_INSTR_AND_DATA) 
		stored_instr <= 9'b000001111;
	else if (mif_nextstate == START_RECONFIG)
		stored_instr <= OP_START;
	else if (mif_curstate == WAIT_FOR_ROM_INSTR)//STORE_AND_DECODE_INSTR) 
		stored_instr <= rom_q[8:0];
	else 
		stored_instr <= stored_instr;
end

//write data and read data
assign reconfig_addr = stored_instr;
assign reconfig_write_data = stored_data;

// ----------------RAM block -----------------------
	altsyncram	altsyncram_component (
				.address_a (rom_addr),
				.clock0 (mif_clk),
				.q_a (rom_q),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_a ({32{1'b1}}),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_a (1'b0),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = MIF_FILE_NAME,
		altsyncram_component.intended_device_family = "Arria 10",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = ROM_NUM_WORDS,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.widthad_a = ROM_ADDR_WIDTH,
		altsyncram_component.width_a = ROM_DATA_WIDTH,
		altsyncram_component.width_byteena_a = 1;
	
endmodule  // mif_reader

