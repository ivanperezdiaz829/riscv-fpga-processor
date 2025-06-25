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


//synthesis_resources = arriav_dll 1 
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  dllex_altdll_ui51
	( 
	dll_clk,
`ifdef USE_OFFSET_CTRL
        dll_offsetdelayctrlout,
        dll_offsetdelayctrlclkout,
`endif
	dll_delayctrlout) ;
	input   [0:0]  dll_clk;
`ifdef USE_OFFSET_CTRL
        output  [6:0] dll_offsetdelayctrlout;
        output  [0:0] dll_offsetdelayctrlclkout;
`endif
	output   [6:0]  dll_delayctrlout;

	wire  [6:0]   wire_dll_wys_m_delayctrlout;

`ifdef ARRIAV
	arriav_dll   dll_wys_m
`endif
`ifdef CYCLONEV
	cyclonev_dll   dll_wys_m
`endif
`ifdef STRATIXV
	stratixv_dll   dll_wys_m
`endif
`ifdef ARRIAVGZ
	arriavgz_dll   dll_wys_m
`endif
	( 
	.clk(dll_clk),
	.delayctrlout(wire_dll_wys_m_delayctrlout),
	.dqsupdate(),
	.locked(),
`ifdef USE_OFFSET_CTRL
        .offsetdelayctrlout(dll_offsetdelayctrlout),
        .offsetdelayctrlclkout(dll_offsetdelayctrlclkout),
`endif
	.upndnout()
	// synopsys translate_off
	,
	.aload(1'b0),
	.upndnin(1'b1),
	.upndninclkena(1'b1)
	// synopsys translate_on
	// synopsys translate_off
	,

`ifdef ARRIAV
	.dffin(),
	.dftcore() 
`endif
`ifdef CYCLONEV
	.dffin(),
	.dftcore() 
`endif
`ifdef STRATIXV
	.dffin()
`endif
`ifdef ARRIAVGZ
	.dffin()
`endif

	// synopsys translate_on
	);
	defparam
		dll_wys_m.jitter_reduction = "false",
		dll_wys_m.static_delay_ctrl = 8,
		dll_wys_m.lpm_type = "arriav_dll",
		dll_wys_m.input_frequency = "2500 ps";
	assign
		dll_delayctrlout = wire_dll_wys_m_delayctrlout;
endmodule //dllex_altdll_ui51
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module dllex (
	dll_clk,
`ifdef USE_OFFSET_CTRL
        dll_offsetctrlout,
`endif
	dll_delayctrlout);

	input	[0:0]  dll_clk;
`ifdef USE_OFFSET_CTRL
        output  [6:0]  dll_offsetctrlout;
`endif
	output	[6:0]  dll_delayctrlout;

	wire [6:0] sub_wire0;
	wire [6:0] dll_delayctrlout = sub_wire0[6:0];

        wire [0:0] dll_offsetdelayctrlclk;
        wire [6:0] dll_offsetdelayctrl;

	dllex_altdll_ui51	dllex_altdll_ui51_component (
				.dll_clk (dll_clk),
`ifdef USE_OFFSET_CTRL
                                .dll_offsetdelayctrlout(dll_offsetdelayctrl),
                                .dll_offsetdelayctrlclkout(dll_offsetdelayctrlclk),
`endif
				.dll_delayctrlout (sub_wire0));
                                
`ifdef USE_OFFSET_CTRL
	`ifdef STRATIXV
            stratixv_dll_offset_ctrl u_stratixv_dll_offset_ctrl (
           	.clk(dll_offsetdelayctrlclk),
       	   	.offsetdelayctrlin(dll_offsetdelayctrl),
      	    	.offset(7'd0),
           	.addnsub(1'b1),
           	.aload(1'b0),
           	.offsetctrlout(dll_offsetctrlout),
           	.offsettestout()
        	);
            defparam u_stratixv_dll_offset_ctrl.use_offset           = "false";
            defparam u_stratixv_dll_offset_ctrl.static_offset        = 0;
            defparam u_stratixv_dll_offset_ctrl.use_pvt_compensation = "false";
	`endif
	`ifdef ARRIAVGZ
    	    arriavgz_dll_offset_ctrl u_arriavgz_dll_offset_ctrl (
           	.clk(dll_offsetdelayctrlclk),
           	.offsetdelayctrlin(dll_offsetdelayctrl),
           	.offset(7'd0),
           	.addnsub(1'b1),
           	.aload(1'b0),
           	.offsetctrlout(dll_offsetctrlout),
           	.offsettestout()
        	);
            defparam u_arriavgz_dll_offset_ctrl.use_offset           = "false";
       	    defparam u_arriavgz_dll_offset_ctrl.static_offset        = 0;
            defparam u_arriavgz_dll_offset_ctrl.use_pvt_compensation = "false";
	`endif
`endif

endmodule
