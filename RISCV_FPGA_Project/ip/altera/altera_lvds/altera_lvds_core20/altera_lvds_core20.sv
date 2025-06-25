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


`timescale 1 ps / 1 ps

module altera_lvds_core20
#(
    parameter NUM_CHANNELS = 1,
    parameter J_FACTOR = 10,
    parameter USE_EXTERNAL_PLL = "false",
    parameter TX_OUTCLOCK_NON_STD_PHASE_SHIFT = "false", 
       
    parameter pll_tx_outclock_frequency = "0 ps",
    parameter pll_fclk_frequency = "0 ps",
    parameter pll_sclk_frequency = "0 ps",
    parameter pll_loaden_frequency = "0 ps", 
    parameter pll_tx_outclock_phase_shift = "0 ps",
    parameter pll_fclk_phase_shift = "0 ps",
    parameter pll_sclk_phase_shift = "0 ps",
    parameter pll_loaden_phase_shift = "0 ps",
    parameter pll_loaden_duty_cycle = 50, 
    parameter pll_inclock_frequency = "0 ps",
    parameter pll_vco_frequency = "0 ps", 
    
    parameter SERDES_DPA_MODE = "OFF_MODE",
    parameter ALIGN_TO_RISING_EDGE_ONLY = "false",
    parameter LOSE_LOCK_ON_ONE_CHANGE = "false",
    parameter RESET_FIFO_AT_FIRST_LOCK = "false",
    parameter ENABLE_CLOCK_PIN_MODE = "false",
    parameter LOOPBACK_MODE = "0",
    parameter NET_PPM_VARIATION = "0",
    parameter IS_NEGATIVE_PPM_DRIFT = "false",
    parameter REGISTER_PARALLEL_DATA = "false",
    parameter USE_FALLING_CLOCK_EDGE = "false", 
    parameter TX_OUTCLOCK_BYPASS_SERIALIZER = "false",
    parameter TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE = "false", 
    parameter TX_OUTCLOCK_DIV_WORD = 0, 

    parameter m_cnt_hi_div = 3,
    parameter m_cnt_lo_div = 2,
    parameter n_cnt_hi_div = 256,
    parameter n_cnt_lo_div = 256,
    parameter m_cnt_bypass_en = "false",
    parameter n_cnt_bypass_en = "true",
    parameter m_cnt_odd_div_duty_en = "true",
    parameter n_cnt_odd_div_duty_en = "false",
    parameter c_cnt_hi_div0 = 256,
    parameter c_cnt_lo_div0 = 256,
    parameter c_cnt_prst0 = 1,
    parameter c_cnt_ph_mux_prst0 = 4,
    parameter c_cnt_bypass_en0 = "true",
    parameter c_cnt_odd_div_duty_en0 = "false",
    parameter c_cnt_hi_div1 = 5,
    parameter c_cnt_lo_div1 = 5,
    parameter c_cnt_prst1 = 1,
    parameter c_cnt_ph_mux_prst1 = 4,
    parameter c_cnt_bypass_en1 = "false",
    parameter c_cnt_odd_div_duty_en1 = "false",
    parameter c_cnt_hi_div2 = 1,
    parameter c_cnt_lo_div2 = 9,
    parameter c_cnt_prst2 = 9,
    parameter c_cnt_ph_mux_prst2 = 0,
    parameter c_cnt_bypass_en2 = "false",
    parameter c_cnt_odd_div_duty_en2 = "false",
    parameter c_cnt_hi_div3 = 256,
    parameter c_cnt_lo_div3 = 256,
    parameter c_cnt_prst3 = 1,
    parameter c_cnt_ph_mux_prst3 = 0,
    parameter c_cnt_bypass_en3 = "true",
    parameter c_cnt_odd_div_duty_en3 = "false",
    parameter c_cnt_hi_div4 = 256,
    parameter c_cnt_lo_div4 = 256,
    parameter c_cnt_prst4 = 1,
    parameter c_cnt_ph_mux_prst4 = 0,
    parameter c_cnt_bypass_en4 = "true",
    parameter c_cnt_odd_div_duty_en4 = "false",
    parameter c_cnt_hi_div5 = 256,
    parameter c_cnt_lo_div5 = 256,
    parameter c_cnt_prst5 = 1,
    parameter c_cnt_ph_mux_prst5 = 0,
    parameter c_cnt_bypass_en5 = "true",
    parameter c_cnt_odd_div_duty_en5 = "false",
    parameter c_cnt_hi_div6 = 256,
    parameter c_cnt_lo_div6 = 256,
    parameter c_cnt_prst6 = 1,
    parameter c_cnt_ph_mux_prst6 = 0,
    parameter c_cnt_bypass_en6 = "true",
    parameter c_cnt_odd_div_duty_en6 = "false",
    parameter c_cnt_hi_div7 = 256,
    parameter c_cnt_lo_div7 = 256,
    parameter c_cnt_prst7 = 1,
    parameter c_cnt_ph_mux_prst7 = 0,
    parameter c_cnt_bypass_en7 = "true",
    parameter c_cnt_odd_div_duty_en7 = "false",
    parameter c_cnt_hi_div8 = 256,
    parameter c_cnt_lo_div8 = 256,
    parameter c_cnt_prst8 = 1,
    parameter c_cnt_ph_mux_prst8 = 0,
    parameter c_cnt_bypass_en8 = "true",
    parameter c_cnt_odd_div_duty_en8 = "false",
    parameter pll_cp_current = 5,
    parameter pll_bwctrl = 18000,
    parameter pll_output_clk_frequency = "500.0 MHz",
    parameter pll_fbclk_mux_1 = "pll_fbclk_mux_1_lvds",
    parameter pll_fbclk_mux_2 = "pll_fbclk_mux_2_fb_1",
    parameter pll_m_cnt_in_src = "c_m_cnt_in_src_ph_mux_clk"

) (
    input                                               ext_coreclock, 
    input                                               ext_fclk,
    input                                               ext_loaden,
    input                                               ext_tx_outclock,
    input       [7:0]                                   ext_vcoph,
    input                                               inclock, 
    input       [NUM_CHANNELS-1:0]                      loopback_in,
    input       [NUM_CHANNELS-1:0]                      loopback_out,
    input                                               pll_areset,
    input       [NUM_CHANNELS-1:0]                      rx_bitslip_reset,
    input       [NUM_CHANNELS-1:0]                      rx_bitslip_ctrl,
    input       [NUM_CHANNELS-1:0]                      rx_dpa_reset,
    input       [NUM_CHANNELS-1:0]                      rx_dpa_hold,
    input       [NUM_CHANNELS-1:0]                      rx_fifo_reset,
    input       [NUM_CHANNELS-1:0]                      rx_in,
    input       [NUM_CHANNELS*J_FACTOR-1:0]             tx_in,

    
    output      [NUM_CHANNELS-1:0]                      rx_bitslip_max, 
    output      [NUM_CHANNELS-1:0]                      rx_dpa_locked,
    output      [NUM_CHANNELS-1:0]                      rx_divfwdclk, 
    output      [NUM_CHANNELS*J_FACTOR-1:0]             rx_out,
    output                                              rx_coreclock,
    output                                              tx_coreclock, 
    output      [NUM_CHANNELS-1:0]                      tx_out,
    output                                              tx_outclock,
    output                                              pll_locked
);

    wire                                                clock_tree_loaden;
    wire                                                clock_tree_fclk;
    wire                                                tx_outclock_fclk;
    wire                                                pll_tx_outclock;
    wire                                                fclk;    
    wire                                                loaden;    
    wire        [7:0]                                   vcoph;   
    wire                                                coreclock; 




    
    assign rx_coreclock  = coreclock; 
    assign tx_coreclock  = coreclock; 
    
    generate
        if (USE_EXTERNAL_PLL == "true")
        begin : breakout_clock_connections
            assign fclk                     = ext_fclk; 
            assign loaden                   = ext_loaden; 
            assign vcoph                    = ext_vcoph; 
            assign coreclock                = ext_coreclock;
            assign pll_tx_outclock          = ext_tx_outclock;
        end
        else
        begin : internal_pll 
            altera_lvds_core20_pll #(
				.pll_fbclk_mux_1(pll_fbclk_mux_1),
				.pll_fbclk_mux_2(pll_fbclk_mux_2),
                .reference_clock_frequency(pll_inclock_frequency),
                .vco_frequency (pll_output_clk_frequency),
                .output_clock_frequency_0 (pll_fclk_frequency),
                .output_clock_frequency_1 (pll_loaden_frequency),
                .output_clock_frequency_2 (pll_sclk_frequency),
                .output_clock_frequency_3 ((TX_OUTCLOCK_NON_STD_PHASE_SHIFT == "true") ? pll_tx_outclock_frequency : "0 ps"),
                .duty_cycle_0 (50),
                .duty_cycle_1 (pll_loaden_duty_cycle),
                .duty_cycle_2 (50),
                .duty_cycle_3 (50),
                .phase_shift_0 (pll_fclk_phase_shift),
                .phase_shift_1 (pll_loaden_phase_shift), 
                .phase_shift_2 (pll_sclk_phase_shift),
                .phase_shift_3 ((TX_OUTCLOCK_NON_STD_PHASE_SHIFT == "true") ? pll_tx_outclock_phase_shift: "0 ps"),
				.pll_c0_out_en ((pll_fclk_frequency != "0 MHz") ? "true" : "false"),	
				.pll_c1_out_en ((pll_loaden_frequency != "0 MHz") ? "true" : "false"),	
				.pll_c2_out_en ((pll_sclk_frequency != "0 MHz") ? "true" : "false"),
                .pll_c3_out_en (TX_OUTCLOCK_NON_STD_PHASE_SHIFT),
				.pll_c4_out_en ("false"),
				.pll_c5_out_en ("false"),
				.pll_c6_out_en ("false"),
				.pll_c7_out_en ("false"),
				.pll_c8_out_en ("false"),
                .pll_c_counter_0_bypass_en (c_cnt_bypass_en0),
				.pll_c_counter_0_even_duty_en (c_cnt_odd_div_duty_en0),
				.pll_c_counter_0_high (c_cnt_hi_div0),
				.pll_c_counter_0_low (c_cnt_lo_div0),
				.pll_c_counter_0_ph_mux_prst (c_cnt_ph_mux_prst0),
				.pll_c_counter_0_prst (c_cnt_prst0),				
				.pll_c_counter_1_bypass_en (c_cnt_bypass_en1),
				.pll_c_counter_1_even_duty_en (c_cnt_odd_div_duty_en1),
				.pll_c_counter_1_high (c_cnt_hi_div1),
				.pll_c_counter_1_low (c_cnt_lo_div1),
				.pll_c_counter_1_ph_mux_prst (c_cnt_ph_mux_prst1),
				.pll_c_counter_1_prst (c_cnt_prst1),
				.pll_c_counter_2_bypass_en (c_cnt_bypass_en2),
				.pll_c_counter_2_even_duty_en (c_cnt_odd_div_duty_en2),
				.pll_c_counter_2_high (c_cnt_hi_div2),
				.pll_c_counter_2_low (c_cnt_lo_div2),
				.pll_c_counter_2_ph_mux_prst (c_cnt_ph_mux_prst2),
				.pll_c_counter_2_prst (c_cnt_prst2),
				.pll_c_counter_3_bypass_en (c_cnt_bypass_en3),
				.pll_c_counter_3_even_duty_en (c_cnt_odd_div_duty_en3),
				.pll_c_counter_3_high (c_cnt_hi_div3),
				.pll_c_counter_3_low (c_cnt_lo_div3),
				.pll_c_counter_3_ph_mux_prst (c_cnt_ph_mux_prst3),
				.pll_c_counter_3_prst (c_cnt_prst3),
				.pll_c_counter_4_bypass_en (c_cnt_bypass_en4),
				.pll_c_counter_4_even_duty_en (c_cnt_odd_div_duty_en4),
				.pll_c_counter_4_high (c_cnt_hi_div4),
				.pll_c_counter_4_low (c_cnt_lo_div4),
				.pll_c_counter_4_ph_mux_prst (c_cnt_ph_mux_prst4),
				.pll_c_counter_4_prst (c_cnt_prst4),
				.pll_c_counter_5_bypass_en (c_cnt_bypass_en5),
				.pll_c_counter_5_even_duty_en (c_cnt_odd_div_duty_en5),
				.pll_c_counter_5_high (c_cnt_hi_div5),
				.pll_c_counter_5_low (c_cnt_lo_div5),
				.pll_c_counter_5_ph_mux_prst (c_cnt_ph_mux_prst5),
				.pll_c_counter_5_prst (c_cnt_prst5),
				.pll_c_counter_6_bypass_en (c_cnt_bypass_en6),
				.pll_c_counter_6_even_duty_en (c_cnt_odd_div_duty_en6),
				.pll_c_counter_6_high (c_cnt_hi_div6),
				.pll_c_counter_6_low (c_cnt_lo_div6),
				.pll_c_counter_6_ph_mux_prst (c_cnt_ph_mux_prst6),
				.pll_c_counter_6_prst (c_cnt_prst6),
				.pll_c_counter_7_bypass_en (c_cnt_bypass_en7),
				.pll_c_counter_7_even_duty_en (c_cnt_odd_div_duty_en7),
				.pll_c_counter_7_high (c_cnt_hi_div7),
				.pll_c_counter_7_low (c_cnt_lo_div7),
				.pll_c_counter_7_ph_mux_prst (c_cnt_ph_mux_prst7),
				.pll_c_counter_7_prst (c_cnt_prst7),
				.pll_c_counter_8_bypass_en (c_cnt_bypass_en8),
				.pll_c_counter_8_even_duty_en (c_cnt_odd_div_duty_en8),
				.pll_c_counter_8_high (c_cnt_hi_div8),
				.pll_c_counter_8_low (c_cnt_lo_div8),
				.pll_c_counter_8_ph_mux_prst (c_cnt_ph_mux_prst8),
				.pll_c_counter_8_prst (c_cnt_prst8),
				.pll_m_counter_bypass_en (m_cnt_bypass_en),
				.pll_m_counter_even_duty_en (m_cnt_odd_div_duty_en),
				.pll_m_counter_high(m_cnt_hi_div),
				.pll_m_counter_low(m_cnt_lo_div),
				.pll_n_counter_bypass_en(n_cnt_bypass_en),
				.pll_n_counter_high(n_cnt_hi_div),
				.pll_n_counter_low(n_cnt_lo_div),
                .pll_n_counter_odd_div_duty_en (n_cnt_odd_div_duty_en),
				.pll_vco_ph0_en ("true"),
				.pll_vco_ph1_en ("true"),
				.pll_vco_ph2_en ("true"),
				.pll_vco_ph3_en ("true"),
				.pll_vco_ph4_en ("true"),
				.pll_vco_ph5_en ("true"),
				.pll_vco_ph6_en ("true"),
				.pll_vco_ph7_en ("true")
            
            ) pll_inst (
            
                .rst_n(~pll_areset), 
                .refclk(inclock),
                .fclk(fclk),
                .loaden(loaden),
                .tx_outclock(pll_tx_outclock),
                .coreclock(coreclock),
                .vcoph(vcoph),
                .lock(pll_locked));
        end
    endgenerate     

    
    

    generate 
        if  (ENABLE_CLOCK_PIN_MODE == "true" && (SERDES_DPA_MODE == "tx_mode" || SERDES_DPA_MODE == "non_dpa_mode")
            || SERDES_DPA_MODE == "dpa_mode_cdr") 
        begin : clock_pin_lvds_clock_tree
            twentynm_lvds_clock_tree lvds_clock_tree_inst (
                .lvdsfclk_in(fclk),
                .lvdsfclk_out(clock_tree_fclk)
                );
        end
        else if (SERDES_DPA_MODE == "tx_mode" || SERDES_DPA_MODE == "non_dpa_mode" || SERDES_DPA_MODE == "dpa_mode_fifo")
        begin : default_lvds_clock_tree  
                twentynm_lvds_clock_tree lvds_clock_tree_inst (
                .lvdsfclk_in(fclk),
                .loaden_in(loaden),
                .lvdsfclk_out(clock_tree_fclk),
                .loaden_out(clock_tree_loaden)
                );
        end
    endgenerate 

    genvar CH_INDEX;
    generate
        for (CH_INDEX=0;CH_INDEX<NUM_CHANNELS;CH_INDEX=CH_INDEX+1)
        begin : channels
            if (SERDES_DPA_MODE == "tx_mode")
            begin : tx                
                reg [J_FACTOR-1:0] tx_reg /* synthesis syn_preserve=1*/ ;

                always @(posedge coreclock or posedge pll_areset)
                begin : input_reg
                    if (pll_areset == 1'b1)
                        tx_reg <= 1'b0; 
                    else
                        tx_reg <= tx_in[(J_FACTOR*(CH_INDEX+1)-1):J_FACTOR*CH_INDEX];
                end     
                twentynm_io_serdes_dpa #(
                    .mode(SERDES_DPA_MODE),
                    .data_width(J_FACTOR),
                    .enable_clock_pin_mode(ENABLE_CLOCK_PIN_MODE),
                    .loopback_mode(LOOPBACK_MODE)
                ) serdes_dpa_inst (
                    .fclk(clock_tree_fclk),
                    .loaden(clock_tree_loaden),
                    .txdata(tx_reg),
                    .loopbackin(loopback_in[CH_INDEX]), 
                    .lvdsout(tx_out[CH_INDEX]),
                    .loopbackout(loopback_out[CH_INDEX])
                );
            end 
            else if (SERDES_DPA_MODE == "non_dpa_mode")
            begin : rx_non_dpa
                wire [9:0] inv_rx_data;
                reg [J_FACTOR-1:0] rx_reg /* synthesis syn_preserve=1*/; 

                twentynm_io_serdes_dpa #(
                    .mode(SERDES_DPA_MODE),
                    .bitslip_rollover(J_FACTOR-1),
                    .data_width(J_FACTOR),
                    .enable_clock_pin_mode(ENABLE_CLOCK_PIN_MODE),
                    .loopback_mode(LOOPBACK_MODE)
                ) serdes_dpa_inst (
                    .bitslipcntl(rx_bitslip_ctrl[CH_INDEX]),
                    .bitslipreset(pll_areset|rx_bitslip_reset[CH_INDEX]),
                    .fclk(clock_tree_fclk),
                    .loaden(clock_tree_loaden),
                    .lvdsin(rx_in[CH_INDEX]),
                    .loopbackin(loopback_in[CH_INDEX]),
                    .bitslipmax(rx_bitslip_max[CH_INDEX]),
                    .rxdata(inv_rx_data), 
                    .loopbackout(loopback_out)
                );

                genvar i; 
                for (i=0; i<J_FACTOR; i=i+1)
                begin : output_reg 
                    always @(posedge coreclock or posedge pll_areset)
                    begin
                        if (pll_areset)
                            rx_reg[i] <= 1'b0; 
                        else 
                            rx_reg[i] = inv_rx_data[J_FACTOR-1-i];
                    end
                end

                assign rx_out[(J_FACTOR*(CH_INDEX+1)-1):J_FACTOR*CH_INDEX] = rx_reg; 

           end
           else if (SERDES_DPA_MODE == "dpa_mode_fifo")
           begin : dpa_fifo
                wire [9:0] inv_rx_data;
                reg [J_FACTOR-1:0] rx_reg /* synthesis syn_preserve=1*/; 

                twentynm_io_serdes_dpa #(
                    .mode(SERDES_DPA_MODE),
                    .align_to_rising_edge_only(ALIGN_TO_RISING_EDGE_ONLY),
                    .bitslip_rollover(J_FACTOR-1),
                    .data_width(J_FACTOR),
                    .lose_lock_on_one_change(LOSE_LOCK_ON_ONE_CHANGE),
                    .reset_fifo_at_first_lock(RESET_FIFO_AT_FIRST_LOCK),
                    .loopback_mode(LOOPBACK_MODE)
                ) serdes_dpa_inst (
                    .bitslipcntl(rx_bitslip_ctrl[CH_INDEX]),
                    .bitslipreset(pll_areset|rx_bitslip_reset[CH_INDEX]),
                    .dpahold(rx_dpa_hold[CH_INDEX]|rx_dpa_locked[CH_INDEX]),
                    .dpareset(rx_dpa_reset[CH_INDEX]),
                    .fclk(clock_tree_fclk),
                    .dpafiforeset(rx_fifo_reset[CH_INDEX]),
                    .loaden(clock_tree_loaden),
                    .lvdsin(rx_in[CH_INDEX]),
                    .dpaclk(vcoph),
                    .loopbackin(loopback_in[CH_INDEX]),
                    .bitslipmax(rx_bitslip_max[CH_INDEX]),
                    .dpalock(rx_dpa_locked[CH_INDEX]),
                    .rxdata(inv_rx_data), 
                    .loopbackout(loopback_out)
                );

                genvar i; 
                for (i=0; i<J_FACTOR; i=i+1)
                begin : output_reg 
                    always @(posedge coreclock or posedge pll_areset)
                    begin
                        if (pll_areset)
                            rx_reg[i] <= 1'b0; 
                        else 
                            rx_reg[i] = inv_rx_data[J_FACTOR-1-i];
                    end
                end

                assign rx_out[(J_FACTOR*(CH_INDEX+1)-1):J_FACTOR*CH_INDEX] = rx_reg; 
           end
           else if (SERDES_DPA_MODE == "dpa_mode_cdr")
           begin : soft_cdr
                wire [9:0] inv_rx_data; 
                wire divfwdclk;

                twentynm_io_serdes_dpa #(
                    .mode(SERDES_DPA_MODE),
                    .align_to_rising_edge_only(ALIGN_TO_RISING_EDGE_ONLY),
                    .bitslip_rollover(J_FACTOR-1),
                    .data_width(J_FACTOR),
                    .lose_lock_on_one_change(LOSE_LOCK_ON_ONE_CHANGE),
                    .reset_fifo_at_first_lock(RESET_FIFO_AT_FIRST_LOCK),
                    .enable_clock_pin_mode(ENABLE_CLOCK_PIN_MODE),
                    .loopback_mode(LOOPBACK_MODE),
                    .net_ppm_variation(NET_PPM_VARIATION),
                    .is_negative_ppm_drift(IS_NEGATIVE_PPM_DRIFT)
                ) serdes_dpa_inst (
                    .bitslipcntl(rx_bitslip_ctrl[CH_INDEX]),
                    .bitslipreset(pll_areset|rx_bitslip_reset[CH_INDEX]),
                    .dpahold(rx_dpa_hold[CH_INDEX]|rx_dpa_locked[CH_INDEX]),
                    .dpareset(rx_dpa_reset[CH_INDEX]),
                    .fclk(clock_tree_fclk), 
                    .lvdsin(rx_in[CH_INDEX]),
                    .dpaclk(vcoph),
                    .loopbackin(loopback_in[CH_INDEX]),
                    .bitslipmax(rx_bitslip_max[CH_INDEX]),
                    .dpalock(rx_dpa_locked[CH_INDEX]),
                    .rxdata(inv_rx_data),
                    .pclk(divfwdclk), 
                    .loopbackout(loopback_out[CH_INDEX])
                );
                assign rx_divfwdclk[CH_INDEX] = ~divfwdclk;  

                /*
                genvar i; 
                for (i=0; i<J_FACTOR; i=i+1)
                begin : cdr_sync
                    always @(posedge divfwdclk or posedge pll_areset)
                    begin
                        if (pll_areset)
                            cdr_sync_reg[i] <= 1'b0; 
                        else 
                            cdr_sync_reg[i] = inv_rx_data[J_FACTOR-1-i];
                    end
                end
                
                always @(posedge rx_divfwdclk[CH_INDEX] or posedge pll_areset)
                begin 
                    if (pll_areset)
                        rx_reg <= {J_FACTOR{1'b0}}; 
                    else 
                        rx_reg <= cdr_sync_reg;
                end


                assign rx_out[(J_FACTOR*(CH_INDEX+1)-1):J_FACTOR*CH_INDEX] = rx_reg; 
            */
                genvar i; 
                for (i=0; i<J_FACTOR; i=i+1)
                begin : rx_data_inv 
                    assign rx_out[CH_INDEX*J_FACTOR + i] = inv_rx_data[J_FACTOR-1-i];
                end    
            end    
        end
    endgenerate 

	wire [9:0] tx_outclock_div_word = TX_OUTCLOCK_DIV_WORD;
	
    generate 
        if (SERDES_DPA_MODE == "tx_mode" && TX_OUTCLOCK_NON_STD_PHASE_SHIFT == "false") 
        begin : std_tx_outclock_serdes
        
        twentynm_io_serdes_dpa #(
            .mode("tx_mode"),
            .data_width(J_FACTOR),
            .enable_clock_pin_mode(ENABLE_CLOCK_PIN_MODE),
            .bypass_serializer(TX_OUTCLOCK_BYPASS_SERIALIZER),
            .use_falling_clock_edge(TX_OUTCLOCK_USE_FALLING_CLOCK_EDGE), 
            .loopback_mode(LOOPBACK_MODE)
        ) serdes_dpa_tx_outclock (
            .fclk(clock_tree_fclk),
            .loaden(clock_tree_loaden),
            .txdata(tx_outclock_div_word),
            .lvdsout(tx_outclock)
            );
        end
        else if (SERDES_DPA_MODE == "tx_mode" && TX_OUTCLOCK_NON_STD_PHASE_SHIFT == "true")
        begin : phase_shifted_tx_outclock_serdes 
        twentynm_lvds_clock_tree outclock_tree (
            .lvdsfclk_in(pll_tx_outclock),
            .lvdsfclk_out(clock_tree_tx_outclock)
            );

        twentynm_io_serdes_dpa #(
            .mode("tx_mode"),
            .bypass_serializer("true"),
            .loopback_mode(LOOPBACK_MODE)
        ) serdes_dpa_tx_outclock (
            .fclk(clock_tree_tx_outclock),
            .txdata(tx_outclock_div_word), 
            .lvdsout(tx_outclock)
            );
        end
    endgenerate 

endmodule

