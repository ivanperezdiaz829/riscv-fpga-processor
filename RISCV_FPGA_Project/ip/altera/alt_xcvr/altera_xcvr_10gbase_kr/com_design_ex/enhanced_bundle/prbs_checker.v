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


//-----------------------------------------------------------------------------
// Title         : prbs_checker
//-----------------------------------------------------------------------------
// File          : prbs_checker.v
// Supported Patterns - 7, 10, 23, 31
// Supported Data widths = 8, 10, 16, 20, 32, 40, 64
//-----------------------------------------------------------------------------




module prbs_checker 
#(
  parameter NUM_CYCLES_FOR_LOCK = 8'd31,		
  parameter PRBS_INITIAL_VALUE = 97,
  parameter DATA_WIDTH = 8,
  parameter PRBS = 23,
  parameter PIPELINE = 3
  )(input  wire [DATA_WIDTH-1:0] dataIn, 
    output wire lock, 
    output reg  errorFlag,
    input  wire clk, 
    input  wire nreset,
    input  tri0 pause);
    
    localparam STATE_RESET            = 2'b00;
    localparam STATE_LOCK_MODE        = 2'b01;
    localparam STATE_ERROR_COUNT_MODE = 2'b10;
    
    reg [1:0] state;
    reg [7:0] matchCount;   
    wire [DATA_WIDTH-1:0] prbsnext;
    reg  [DATA_WIDTH-1:0] prbsnextreg = 0;
    wire [DATA_WIDTH-1:0] prbscurr 	       = (state == STATE_ERROR_COUNT_MODE)?prbsnextreg:dataIn;
    wire 		  count_value_reached  = (matchCount > NUM_CYCLES_FOR_LOCK)?1'b1:1'b0;
//    wire 		  datain_match 	       = !pause ? (dataIn == prbsnextreg) : datain_match;
   wire 		  datain_match 	       = (dataIn == prbsnextreg);
   
    wire 		  lock_state 	       = (state == STATE_LOCK_MODE)?1'b1:1'b0;
    
    assign     lock 			       = (state == STATE_ERROR_COUNT_MODE)? 1'b1: 1'b0;

    initial /* synthesis enable_verilog_initial_construct */
    begin                 
	if(NUM_CYCLES_FOR_LOCK > 5'b11111) begin
	    $display("Error: You have a value for NUM_CYCLES_FOR_LOCK that is to large.  Specify a number less than 31");
	    end
    end


    always@(posedge clk)begin
       if (!pause)
	 prbsnextreg 		  <= prbsnext;
    end


    always @ (posedge clk or negedge nreset)
	begin
	    if (~nreset) begin
		state 		  <= STATE_RESET;
	    end
	    else begin
		case (state)
		    STATE_RESET:begin
			if ((dataIn == PRBS_INITIAL_VALUE))
			    state <= STATE_LOCK_MODE;
			else
			    state <= STATE_RESET;
		    end
		    STATE_LOCK_MODE: begin
			if ( count_value_reached )begin
			    state <= STATE_ERROR_COUNT_MODE;
			end
			else begin
			    state <= STATE_LOCK_MODE;
			end
		    end
		    
		    STATE_ERROR_COUNT_MODE:begin
			state 	  <=STATE_ERROR_COUNT_MODE;
		    end
		    default:begin
			state 	  <= STATE_RESET;
		    end
		endcase // case (state)
	    end
	end
    

   always@(posedge clk or negedge nreset)
     begin
      if(~nreset)begin
	  matchCount <= 8'd0;
      end
     else if(~datain_match & !pause)begin
	  matchCount <= 8'd0;
      end	
      else if(lock_state & !pause)begin
	  matchCount  <= matchCount + 8'd1;
      end
      else begin
	  matchCount <= matchCount;
      end
     end



   always@(posedge clk or negedge nreset)begin
      if(~nreset)begin
	 errorFlag 		  <= 1'b0;
      end
      else if((prbsnextreg != dataIn) && 
	      (state == STATE_ERROR_COUNT_MODE) && 
	      (!pause))begin
	 errorFlag 		  <= 1'b1;
      end
      else begin
	 errorFlag 		  <= 1'b0;
      end
   end
    

prbs_poly #(.DATA_WIDTH(DATA_WIDTH),
		      .PRBS(PRBS))
    atso_prbs_poly_inst(.clk(clk),
			     .data_in(prbscurr),
			     .insert_error(1'b0),
			     .dout(prbsnext),
			     .nreset(nreset)	
			);
endmodule
