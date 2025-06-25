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


// ******************************************************************************************************************************** 
// File name: altera_crcerror_verify_top.v
// This file instantiates crcerror_verify component for Stratix IV and Arria II GZ. 
//
//  Include false failure checks at no-shift frames for all Stratix IV devices and Arria II GZ devices
//
//
//  altera_crcerror_verify_top module contains
//  1) crcblock instantiation
//  2) 2 copies of the crcerror checker
//  3) reset synchronizer
//  4) crc_error pin set up as open drain
// 
// ******************************************************************************************************************************** 

(* altera_attribute = "-name IP_TOOL_NAME altera_crcerror_verify; -name IP_TOOL_VERSION 13.1" *)
module altera_crcerror_verify_top (
  err_verify_in_clk,
  reset,
  crc_error
);

input err_verify_in_clk;
input reset;
output crc_error;


wire crcerror;
wire emr_clk;
wire emr_out;
wire shiftnld;


// Device family. Supported Stratix IV, Arria II, and Arria II GZ only 
//System parameter set and verified by megawizard  
parameter device_family    = "Stratix IV";				
// Error Detection frequency devisor, should match device settings 
parameter error_check_frequency_divisor   = 2;  
// Input clock frequency, in MHz. Should be in between 10 and 50 
parameter in_clk_frequency    = 50;				


crcerror_verify_wrapper crcerror_verify_component (
  .inclk(err_verify_in_clk)
`ifdef DEBUG
`else
, .reset(reset)
`endif
`ifdef HC_EDCRC_TIE_OFF
, .crcerror(1'b0)
, .crc_error()
, .emr_out(1'b0)
, .emr_clk()
, .shiftnld()
`else
, .crcerror(crcerror)
, .crc_error(crc_error)
, .emr_out(emr_out)
, .emr_clk(emr_clk)
, .shiftnld(shiftnld)
`endif
);
defparam crcerror_verify_component.CRC_DIVISOR = error_check_frequency_divisor;
defparam crcerror_verify_component.INCLK_FREQ = in_clk_frequency;

`ifdef HC_EDCRC_TIE_OFF
assign crc_error = 1'b0;
`else
stratixiv_crcblock_wrapper my_crc
(
.clk(emr_clk),
.shiftnld(shiftnld),
.crcerror(crcerror),
.regout(emr_out)
);
defparam my_crc.CRC_DIVISOR = error_check_frequency_divisor;
defparam my_crc.DEVICE_FAMILY = device_family;
`endif
endmodule


module crcerror_verify_wrapper (
  inclk
`ifdef DEBUG
`else
, reset
`endif
, crcerror
, emr_out
, crc_error
,  emr_clk
, shiftnld
);

input inclk;
`ifdef DEBUG
`else
 input reset;
`endif
input crcerror;
input emr_out;


output crc_error;
output emr_clk;
output shiftnld;

reg reset1;
reg reset_sync;
reg crcerror_sync1;
reg crcerror_sync;

reg crcerror_final;


wire crcerror;
wire crc_error0;
wire crc_error1;
wire crc_error;
wire emr_clk;
wire shiftnld;
wire emr_out;
wire emr_done;


`ifdef DEBUG
MySources    MySources_inst (
    .probe ( probe_sig ),
    .source ( reset )
    );
`endif

   parameter CRC_DIVISOR = -1;
   parameter INCLK_FREQ = -1;

// Remove always block if async reset is already sync'd to inclk
always @(posedge inclk or posedge reset)
begin
    if (reset == 1'b1)
    begin
       reset1 <= 1'b1;
       reset_sync <= 1'b1;
    end
    else 
    begin
       reset1 <= 1'b0;
       reset_sync <= reset1;
    end
end

always @(posedge inclk or posedge reset_sync)
begin
    if (reset_sync == 1'b1)
    begin
       crcerror_sync1 <= 1'b0;
       crcerror_sync <= 1'b0;
    end
    else 
    begin
       crcerror_sync1 <= crcerror;
       crcerror_sync <= crcerror_sync1;
    end
end


// Collect error message register information
crcerror_read_emr crcerror_read_emr_component
    (
    .clk(inclk),
    .reset(reset_sync),
    .start_write(crcerror_sync),
        .emr_done(emr_done),
    .emr_clk(emr_clk),
    .shiftnld(shiftnld)
    );

// Workaround module instantiation
crcerror_verify_core crccheck0
(
.inclk(inclk),
.reset(reset_sync),
.emr_in(emr_out),
.emr_done(emr_done),
.emr_reg_en(emr_clk),
.crcerror_in(crcerror_sync),
.crcerror_out(crc_error0)
);
defparam crccheck0.CRC_DIVISOR = CRC_DIVISOR;
defparam crccheck0.INCLK_FREQ = INCLK_FREQ;

// Double redundancy: second workaround module instantiation
crcerror_verify_core crccheck1
(
.inclk(inclk),
.reset(reset_sync),
.emr_in(emr_out),
.emr_done(emr_done),
.emr_reg_en(emr_clk),
.crcerror_in(crcerror_sync),
.crcerror_out(crc_error1)
);
defparam crccheck1.CRC_DIVISOR = CRC_DIVISOR;
defparam crccheck1.INCLK_FREQ = INCLK_FREQ;

// consolidate redundant signals and register final crcerror
always @(posedge inclk or posedge reset_sync)
begin
    if (reset_sync == 1'b1)
    begin
        crcerror_final <= 1'b0;
    end
    else
    begin
        crcerror_final <= (crc_error0 || crc_error1);
    end
end

// Open drain output. On the top design level this needs to be assign to original CRCERROR pin
assign crc_error = crcerror_final ? 1'bz : 1'b0;


endmodule

`ifdef HC_EDCRC_TIE_OFF
`else
module stratixiv_crcblock_wrapper
(
clk,
shiftnld,
crcerror,
regout
);
input clk;
input shiftnld;
output crcerror;
output regout;

wire clk;
wire regout;

parameter CRC_DIVISOR = -1;
parameter DEVICE_FAMILY = "Stratix IV";

generate
	if ( DEVICE_FAMILY == "Arria II" ||
		 DEVICE_FAMILY == "Arria II GX" )
		begin
		arriaii_crcblock emr_atom
		(
		.clk(clk),
		.shiftnld(shiftnld),
		.crcerror(crcerror),
		.regout(regout)
		);
		defparam emr_atom.oscillator_divider = CRC_DIVISOR;
		end
	else if ( DEVICE_FAMILY == "Arria II GZ" )
		begin
		arriaiigz_crcblock emr_atom
		(
		.clk(clk),
		.shiftnld(shiftnld),
		.crcerror(crcerror),
		.regout(regout)
		);
		defparam emr_atom.oscillator_divider = CRC_DIVISOR;
		end
	else
		begin
		stratixiv_crcblock emr_atom
		(
		.clk(clk),
		.shiftnld(shiftnld),
		.crcerror(crcerror),
		.regout(regout)
		);
		defparam emr_atom.oscillator_divider = CRC_DIVISOR;
		end
endgenerate

endmodule
`endif
