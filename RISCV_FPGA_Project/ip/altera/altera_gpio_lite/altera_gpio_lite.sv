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


module altgpio_one_bit(
	inclock,
	outclock,
	phy_mem_clock,
	inclocken,
	outclocken,
	oe,
	din,
	dout,
	pad,
	pad_b,
	aset,
	hr_clock,
	fr_clock
);

	parameter PIN_TYPE = "output"; 
	parameter BUFFER_TYPE = "single-ended"; 
	parameter REGISTER_MODE = "bypass"; 
	parameter ASYNC_MODE = "none"; 
	parameter BUS_HOLD = "false"; 
	parameter SET_REGISTER_OUTPUTS_HIGH = "false";  
	parameter USE_ENHANCED_DDR_HIO_REGISTER = "false"; 
	parameter BYPASS_THREE_QUARTER_REGISTER = "true"; 
	parameter INVERT_OUTPUT = "false"; 
	parameter INVERT_INPUT_CLOCK = "false"; 
	parameter USE_ONE_REG_TO_DRIVE_OE = "false"; 
	parameter USE_DDIO_REG_TO_DRIVE_OE = "false"; 
	parameter OPEN_DRAIN_OUTPUT = "false"; 
	
	localparam DATA_SIZE = (REGISTER_MODE == "ddr") ? 2:1;
	localparam DDIO_REG_POWER_UP = (ASYNC_MODE == "preset" || SET_REGISTER_OUTPUTS_HIGH == "true") ? "high" : "low";

	input inclock;
	input outclock;
	input tri1 inclocken;
	input tri1 outclocken;
	input oe;
	input [DATA_SIZE - 1:0] din;
	output [DATA_SIZE - 1:0] dout;
	inout pad;	
	inout pad_b;
	input aset;
	input phy_mem_clock;
	input hr_clock;
	output fr_clock;

	wire din_ddr;
	wire buf_in;
	
	wire oe_out;
	wire oe_out_2;
	
    generate
        if (PIN_TYPE == "output" || PIN_TYPE == "bidir")
        begin 
			wire [1:0] din_fr;
            if (INVERT_OUTPUT == "false")
			begin 
				assign din_fr = din;
			end
			else
			begin	
				assign din_fr = ~din;
			end
            
			if (REGISTER_MODE == "ddr" && USE_ENHANCED_DDR_HIO_REGISTER == "true")
			begin
				if (ASYNC_MODE == "none")
						begin: out_path_enhanced_ddr
							fiftyfivenm_ddio_out
							#(
								.async_mode(ASYNC_MODE),
								.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
								.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
								.power_up(DDIO_REG_POWER_UP)
							) fr_out_data_ddio (		
								.datainhi(din_fr[1]),
								.datainlo(din_fr[0]),
								.dataout(din_ddr),	
								.clk(outclock),
								.ena(outclocken),
								.phymemclock(phy_mem_clock)
								`ifndef ALTERA_RESERVED_QIS
								,
								.areset(1'b0),
								.clkhi(1'b0),
								.clklo(1'b0),
								.muxsel(1'b0),
								.sreset(1'b0),
								.dfflo(),
								.dffhi(),
								.devpor(1'b1),
								.devclrn(1'b1)
								`endif 
							);
						end
				else
						begin: async_mode_out_path_enhanced_ddr
							fiftyfivenm_ddio_out
							#(
								.async_mode(ASYNC_MODE),
								.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
								.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
								.power_up(DDIO_REG_POWER_UP)
							) fr_out_data_ddio (		
								.datainhi(din_fr[1]),
								.datainlo(din_fr[0]),
								.dataout(din_ddr),
								.clk (outclock),
								.areset(aset),
								.ena(outclocken),
								.phymemclock(phy_mem_clock)
								`ifndef ALTERA_RESERVED_QIS
								,
								.clkhi(1'b0),
								.clklo(1'b0),
								.muxsel(1'b0),
								.sreset(1'b0),
								.dfflo(),
								.dffhi(),
								.devpor(1'b1),
								.devclrn(1'b1)
								`endif 
							);
						end
			end
			else if (REGISTER_MODE == "ddr" && USE_ENHANCED_DDR_HIO_REGISTER == "false")
			begin
				if (ASYNC_MODE == "none")
						begin: out_path_ddr
							fiftyfivenm_ddio_out
							#(
								.async_mode(ASYNC_MODE),
								.power_up(DDIO_REG_POWER_UP)
							) fr_out_data_ddio (		
								.datainhi(din_fr[1]),
								.datainlo(din_fr[0]),
								.dataout(din_ddr),	
								.clk(outclock),
								.ena(outclocken)
								`ifndef ALTERA_RESERVED_QIS
								,
								.areset(1'b0),
								.phymemclock(1'b0),
								.clkhi(1'b0),
								.clklo(1'b0),
								.muxsel(1'b0),
								.sreset(1'b0),
								.dfflo(),
								.dffhi(),
								.devpor(1'b1),
								.devclrn(1'b1)
								`endif 
							);
						end
						else
						begin: async_mode_out_path_ddr
							fiftyfivenm_ddio_out
							#(
								.async_mode(ASYNC_MODE),
								.power_up(DDIO_REG_POWER_UP)
							) fr_out_data_ddio (		
								.datainhi(din_fr[1]),
								.datainlo(din_fr[0]),
								.dataout(din_ddr),
								.clk (outclock),
								.areset(aset),
								.ena(outclocken)
								`ifndef ALTERA_RESERVED_QIS
								,
								.phymemclock(1'b0),
								.clkhi(1'b0),
								.clklo(1'b0),
								.muxsel(1'b0),
								.sreset(1'b0),
								.dfflo(),
								.dffhi(),
								.devpor(1'b1),
								.devclrn(1'b1)
								`endif 
							);
						end
				
			end
            else if (REGISTER_MODE == "single-register")
            begin: out_path_sdr
   			  reg reg_data_out /* synthesis altera_attribute="FAST_OUTPUT_REGISTER=on" */;
                always @(posedge outclock)
                    reg_data_out <= din_fr[0];

                assign din_ddr = reg_data_out;
			end
            else  
            begin: out_path_reg_none
                assign din_ddr = din_fr[0];
            end
        end 
    endgenerate

    generate
        
	    if (PIN_TYPE == "bidir" || PIN_TYPE == "output")
        begin
			if (USE_DDIO_REG_TO_DRIVE_OE == "true")
			begin
				if (REGISTER_MODE == "ddr" && USE_ENHANCED_DDR_HIO_REGISTER == "true")
				begin
					if (ASYNC_MODE == "none")
					begin: oe_path_enhanced_ddr
						if (BUFFER_TYPE ==  "pseudo_differential")
						begin
							fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_1 (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
							
							fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_2 (		
										.oe(~oe),
										.dataout(oe_out_2),
										.clk(outclock),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
						else
						begin
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
					end
					else
					begin: async_mode_oe_path_enhanced_ddr
						if (BUFFER_TYPE == "pseudo_differential")
						begin
							fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_1 (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
									
							fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_2 (		
										.oe(~oe),
										.dataout(oe_out_2),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
						else
						begin
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.use_enhanced_ddr_hio(USE_ENHANCED_DDR_HIO_REGISTER),
										.bypass_three_quarter_register(BYPASS_THREE_QUARTER_REGISTER),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken),
										.phymemclock(phy_mem_clock)
										`ifndef ALTERA_RESERVED_QIS
										,
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
					end
				end
				else if (REGISTER_MODE == "ddr" && USE_ENHANCED_DDR_HIO_REGISTER == "false")
				begin
					if (ASYNC_MODE == "none")
					begin: oe_path_ddr
						if (BUFFER_TYPE == "pseudo_differential")
						begin
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_1 (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
									
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_2 (		
										.oe(~oe),
										.dataout(oe_out_2),
										.clk(outclock),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
						else
						begin					
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.areset(1'b0),
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
					end
					else
					begin: async_mode_oe_path_ddr
						if (BUFFER_TYPE == "pseudo_differential")
						begin
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_1 (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
									
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio_2 (		
										.oe(~oe),
										.dataout(oe_out_2),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
						else
						begin
								fiftyfivenm_ddio_oe
									#(
										.async_mode(ASYNC_MODE),
										.power_up(DDIO_REG_POWER_UP)
									) fr_oe_data_ddio (		
										.oe(~oe),
										.dataout(oe_out),
										.clk(outclock),
										.areset(aset),
										.ena(outclocken)
										`ifndef ALTERA_RESERVED_QIS
										,
										.phymemclock(1'b0),
										.sreset(1'b0),
										.dfflo(),
										.dffhi(),
										.devpor(1'b1),
										.devclrn(1'b1)
										`endif 
									);
						end
					end
				end
			end
			else if (USE_ONE_REG_TO_DRIVE_OE == "true")
			begin: oe_path_sdr
					if (BUFFER_TYPE == "pseudo_differential")
					begin
						fiftyfivenm_ff oe_reg_1 (
							.clk(outclock),
							.d(~oe),
							.clrn(1'b1),
							.ena(1'b1),
							.q(oe_out)
						);
						
						fiftyfivenm_ff oe_reg_2 (
							.clk(outclock),
							.d(~oe),
							.clrn(1'b1),
							.ena(1'b1),
							.q(oe_out_2)
						);	
					end
					else
					begin
						fiftyfivenm_ff oe_reg (
							.clk(outclock),
							.d(~oe),
							.clrn(1'b1),
							.ena(1'b1),
							.q(oe_out)
						);
					end
				
            end
            else if (USE_ONE_REG_TO_DRIVE_OE == "false" && USE_DDIO_REG_TO_DRIVE_OE == "false")
            begin: oe_path_reg_none 
				assign oe_out = ~oe;
				if (BUFFER_TYPE == "pseudo_differential") 
				begin
					assign oe_out_2 = ~oe;
				end
            end
        end
	endgenerate

    generate
        if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
        begin
            wire [1:0] ddr_input;
			wire inclock_wire;
			
			if (REGISTER_MODE != "bypass")
			begin
				if (INVERT_INPUT_CLOCK == "false")
				begin: normal_input_clock
					assign inclock_wire = inclock;
				end
				else 
				begin: inverted_input_clock
					assign inclock_wire = ~inclock;		
				end			
			end

         	if (REGISTER_MODE == "ddr")
         	begin
		        if (USE_ENHANCED_DDR_HIO_REGISTER == "true")
		        begin
					if (ASYNC_MODE == "none")
					begin:in_path_enhanced_ddr
						fiftyfivenm_ddio_in
						#(
							.async_mode(ASYNC_MODE),
							.power_up(DDIO_REG_POWER_UP)
						) fr_in_ddio (
							.datain(buf_in),
							.clk (inclock_wire),
							.ena(inclocken),
							.halfrateresyncclk(hr_clock),
							.regouthi(ddr_input[1]),
							.regoutlo(ddr_input[0]),
							.clkout(fr_clock)
							`ifndef ALTERA_RESERVED_QIS
							,
							.clkn(1'b0),
							.sreset(1'b0),
							.areset(1'b0),
							.dfflo(),
							.devpor(1'b1),
							.devclrn(1'b1)
							`endif 
						);
					end
					else
					begin: async_mode_in_path_enhanced_ddr
						fiftyfivenm_ddio_in
						#(
							.async_mode(ASYNC_MODE),
							.power_up(DDIO_REG_POWER_UP)
						) fr_in_ddio (
							.datain(buf_in),
							.clk(inclock_wire),
							.ena(inclocken),
							.halfrateresyncclk(hr_clock),
							.regouthi(ddr_input[1]),
							.regoutlo(ddr_input[0]),
							.clkout(fr_clock),
							.areset(aset)
							`ifndef ALTERA_RESERVED_QIS
							,
							.clkn(1'b0),
							.sreset(1'b0),
							.dfflo(),
							.devpor(1'b1),
							.devclrn(1'b1)
							`endif 
						);
					end
				end
				else
				begin: in_path_ddr
					wire input_cell_l_q;
					wire input_aset;
					
					assign input_aset = ( ASYNC_MODE == "clear" || ASYNC_MODE == "preset") ? !aset : aset;
			
					fiftyfivenm_ff input_cell_l (
						.clk(inclock_wire),
						.d(buf_in),
						.clrn(input_aset),
						.ena(inclocken),
						.q(input_cell_l_q)
					);
					
					fiftyfivenm_ff input_latch_l (
						.clk(~inclock_wire),
						.d(input_cell_l_q),
						.clrn(input_aset),
						.ena(inclocken),
						.q(ddr_input[0])
					);
					
					fiftyfivenm_ff input_cell_h (
						.clk(~inclock_wire),
						.d(buf_in),
						.clrn(input_aset),
						.ena(inclocken),
						.q(ddr_input[1])
					);
				
				end
			end
			else if (REGISTER_MODE == "single-register")
            begin: in_path_sdr
                reg reg_data_in /* synthesis altera_attribute="FAST_INPUT_REGISTER=on" */;
                always @(posedge inclock) begin
                    reg_data_in <= buf_in;
                end
                assign ddr_input[0] = reg_data_in;
            end
            else
            begin: in_path_reg_none
                assign ddr_input[0] = buf_in;
            end
            
             assign dout[DATA_SIZE - 1:0] = ddr_input[DATA_SIZE - 1:0];
            
        end
    endgenerate

	generate
		if (PIN_TYPE == "output" || PIN_TYPE == "bidir")
		begin
			if(BUFFER_TYPE == "pseudo_differential") 
			begin: pseudo_diff_output_buf
			
				wire wire_pseudo_diff_o;
				wire wire_pseudo_diff_o_bar;
										
				fiftyfivenm_io_obuf 
				#(
					.bus_hold(BUS_HOLD),
					.open_drain_output(OPEN_DRAIN_OUTPUT)
				) obuf_a (
					.i(wire_pseudo_diff_o), 
					.oe(~oe_out),
					.o(pad),
					.obar()
					`ifndef ALTERA_RESERVED_QIS
					,				
					.seriesterminationcontrol(16'b0),
					.devoe(1'b1)
					`endif 
				); 	
				
				fiftyfivenm_io_obuf 
				#(
					.bus_hold(BUS_HOLD),
					.open_drain_output(OPEN_DRAIN_OUTPUT)
				) obuf_a_bar (
					.i(wire_pseudo_diff_o_bar), 
					.oe(~oe_out_2), 
					.o(pad_b),
					.obar()
					`ifndef ALTERA_RESERVED_QIS
					,				
					.seriesterminationcontrol(16'b0),
					.devoe(1'b1)
					`endif 
				); 
				
				fiftyfivenm_pseudo_diff_out pseudo_diff_a
				(
					.i(din_ddr),
					.o(wire_pseudo_diff_o),
					.obar(wire_pseudo_diff_o_bar)
				);
				
								
				
			end
			else if (BUFFER_TYPE == "true_differential") 
			begin: true_diff_output_buf
				fiftyfivenm_io_obuf
				#(
					.bus_hold(BUS_HOLD),
					.open_drain_output(OPEN_DRAIN_OUTPUT)
				) obuf (
					.i(din_ddr), 
					.oe(~oe_out),
					.o(pad),
					.obar(pad_b)
					`ifndef ALTERA_RESERVED_QIS
					,				
					.seriesterminationcontrol(16'b0),
					.devoe(1'b1)
					`endif 
				);	
			end
			else 
			begin: output_buf
				fiftyfivenm_io_obuf
				#(
					.bus_hold(BUS_HOLD),
					.open_drain_output(OPEN_DRAIN_OUTPUT)
				) obuf (
					.i(din_ddr), 
					.oe(~oe_out),
					.o(pad),
					.obar()
					`ifndef ALTERA_RESERVED_QIS
					,				
					.seriesterminationcontrol(16'b0),
					.devoe(1'b1)
					`endif 
				);
			end
		end
	endgenerate

	generate
		if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
		begin: diff_input_buf
			if(BUFFER_TYPE == "true_differential" || BUFFER_TYPE == "pseudo_differential") begin
				fiftyfivenm_io_ibuf
				#(
					.bus_hold(BUS_HOLD)
				) ibuf (
					.i(pad),
					.ibar(pad_b),
					.o(buf_in)
					`ifndef ALTERA_RESERVED_QIS
					,				
					.input_enable(1'b1)
					`endif 
				);         
			end
			else 
			begin:input_buf
				fiftyfivenm_io_ibuf  
				#(
					 .bus_hold(BUS_HOLD)
				) ibuf (
					.i(pad),
					.o(buf_in)
					`ifndef ALTERA_RESERVED_QIS
					,				
					.ibar(1'b0),
					.input_enable(1'b1)
					`endif 
				);        
			end
		end
	endgenerate
	
	generate
		if (PIN_TYPE == "output")
		begin			
			assign dout = {DATA_SIZE{1'b0}};
		end	

		if (PIN_TYPE == "output" || REGISTER_MODE != "ddr" || USE_ENHANCED_DDR_HIO_REGISTER == "false")
		begin
			assign fr_clock = 1'b0;
		end	
	endgenerate

endmodule

module altera_gpio_lite(
	inclock,
	outclock,
	inclocken,
	outclocken,
	oe,
	din,
	dout,
	pad_io,
	pad_io_b,
	pad_in,
	pad_in_b,
	pad_out,
	pad_out_b,
	aset,
	aclr,
	phy_mem_clock,
	clkdiv_sclr,
	hr_clock,
	fr_clock,
	invert_hr_clock
);

	parameter PIN_TYPE = "output"; 
	parameter BUFFER_TYPE = "single-ended"; 
	parameter REGISTER_MODE = "bypass"; 
	parameter SIZE = 4;
	parameter ASYNC_MODE = "none"; 
	parameter BUS_HOLD = "false"; 
	parameter SET_REGISTER_OUTPUTS_HIGH = "false"; 
	parameter INVERT_OUTPUT = "false"; 
	parameter INVERT_INPUT_CLOCK = "false"; 
	parameter USE_ONE_REG_TO_DRIVE_OE = "false"; 
	parameter USE_DDIO_REG_TO_DRIVE_OE = "false"; 
	parameter OPEN_DRAIN_OUTPUT = "false"; 
	parameter USE_ADVANCED_DDR_FEATURES = "false"; 
	parameter INVERT_CLKDIV_INPUT_CLOCK = "false"; 
	
    localparam USE_ENHANCED_DDR_HIO_REGISTER = USE_ADVANCED_DDR_FEATURES;
	localparam BYPASS_THREE_QUARTER_REGISTER = (USE_ADVANCED_DDR_FEATURES == "true") ? "false" : "true";
	localparam USE_IO_CLOCK_DIVIDER = USE_ADVANCED_DDR_FEATURES;
	localparam DATA_SIZE = (REGISTER_MODE == "ddr") ? 2 : 1;

	input inclock;
	input outclock;
	input tri1 inclocken;
	input tri1 outclocken;
	input tri1 [SIZE - 1:0] oe;
	input [SIZE * DATA_SIZE - 1:0] din;
	output [SIZE * DATA_SIZE - 1:0] dout;
	inout [SIZE - 1:0] pad_io;	
	inout [SIZE - 1:0] pad_io_b;
	input [SIZE - 1:0] pad_in;	
	input [SIZE - 1:0] pad_in_b;
	output [SIZE - 1:0] pad_out;	
	output [SIZE - 1:0] pad_out_b;
	input aset;
	input aclr;
	input phy_mem_clock;
	input tri0 clkdiv_sclr;
	input invert_hr_clock;
	output [SIZE - 1:0] fr_clock;
	output wire hr_clock;

	wire [SIZE * DATA_SIZE - 1:0] din_reordered;
	wire [SIZE * DATA_SIZE - 1:0] dout_reordered;
	wire aclr_aset_wire;
	wire [SIZE - 1:0] pad_io;	
	wire [SIZE - 1:0] pad_io_b;
	
	
	assign aclr_aset_wire = (ASYNC_MODE == "clear") ? aclr : (ASYNC_MODE == "preset") ? aset : 1'b1;
	
	generate
		if (PIN_TYPE == "input")
		begin
			assign pad_io = pad_in;
			assign pad_io_b = pad_in_b;
			assign pad_out = {SIZE{1'b0}};
			assign pad_out_b = {SIZE{1'b0}};
		end
		else if (PIN_TYPE == "output")
		begin
			assign pad_out = pad_io;
			assign pad_out_b = pad_io_b;
		end
		else begin
			assign pad_out = {SIZE{1'b0}};
			assign pad_out_b = {SIZE{1'b0}};
		end
	endgenerate
	
	genvar j, k;
	generate
		begin : reorder
			for(j = 0; j < SIZE ; j = j + 1) begin : j_loop
				for(k = 0; k < DATA_SIZE; k = k + 1) begin : k_d_loop
					assign din_reordered[j * DATA_SIZE + k] = din[j + k * SIZE];
					assign dout[j + k * SIZE] = dout_reordered[j * DATA_SIZE + k];
				end
			end
		end
	endgenerate

	genvar i;
	generate
		begin : gpio_one_bit
			for(i = 0 ; i < SIZE ; i = i + 1) begin : i_loop
				wire oe_wire;
				assign oe_wire = (PIN_TYPE == "output") ? 1'b1 : oe[i];
				
				altgpio_one_bit #(
					.PIN_TYPE(PIN_TYPE),
					.BUFFER_TYPE(BUFFER_TYPE),
					.REGISTER_MODE(REGISTER_MODE),
					.ASYNC_MODE(ASYNC_MODE),
					.BUS_HOLD(BUS_HOLD),
					.SET_REGISTER_OUTPUTS_HIGH(SET_REGISTER_OUTPUTS_HIGH),
					.USE_ENHANCED_DDR_HIO_REGISTER(USE_ENHANCED_DDR_HIO_REGISTER),
					.BYPASS_THREE_QUARTER_REGISTER(BYPASS_THREE_QUARTER_REGISTER),
					.INVERT_OUTPUT(INVERT_OUTPUT),
					.INVERT_INPUT_CLOCK(INVERT_INPUT_CLOCK),
					.USE_ONE_REG_TO_DRIVE_OE(USE_ONE_REG_TO_DRIVE_OE),
					.USE_DDIO_REG_TO_DRIVE_OE(USE_DDIO_REG_TO_DRIVE_OE),
					.OPEN_DRAIN_OUTPUT(OPEN_DRAIN_OUTPUT)
				) altgpio_bit_i (
					.inclock(inclock),
					.outclock(outclock),
					.phy_mem_clock(phy_mem_clock),
					.inclocken(inclocken),
					.outclocken(outclocken),
					.oe(oe_wire),
					.din(din_reordered[(i + 1) * DATA_SIZE - 1 : i * DATA_SIZE]),
					.dout(dout_reordered[(i + 1) * DATA_SIZE - 1 : i * DATA_SIZE]),
					.pad(pad_io[i]),
					.pad_b(pad_io_b[i]),
					.aset(aclr_aset_wire),
					.fr_clock(fr_clock[i]),
					.hr_clock(hr_clock)
				);
			end
		end
	endgenerate

	generate
		if ((PIN_TYPE == "input" || PIN_TYPE == "bidir") && (USE_IO_CLOCK_DIVIDER == "true"))
		begin : clock_divider
				fiftyfivenm_io_clock_divider
				#(
		            .invert_input_clock_phase(INVERT_CLKDIV_INPUT_CLOCK),
				    .use_phasectrlin("true"),
				    .sync_mode("clear")
				) io_clkdiv (
					.clk(inclock),
					.phaseinvertctrl(invert_hr_clock),
					.sreset(clkdiv_sclr),
					.clkout(hr_clock)
				);         
		end
	endgenerate

endmodule
