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



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  EMIF IOPLL instantiation for 20nm families
//
//  The following table describes the usage of IOPLL by EMIF. 
//
//  PLL Counter    Fanouts                          Usage
//  =====================================================================================
//  VCO Outputs    vcoph[7:0] -> phy_clk_phs[7:0]   FR clocks, 8 phases (45-deg apart)
//                 vcoph[0] -> DLL                  FR clock to DLL
//  C-counter 0    lvds_clk[0] -> phy_clk[1]        Secondary PHY clock tree
//                 hmc_clk[1]                       Secondary HMC clock tree
//  C-counter 1    loaden[0] -> phy_clk[0]          Primary PHY clock tree
//                 hmc_clk[0]                       Secondary HMC clock tree
//  C-counter 2    phy_clk[2]                       Feedback PHY clock tree
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
module pll #(
   parameter PLL_REF_CLK_FREQ_PS_STR                 = "0 ps",
   parameter PLL_VCO_FREQ_PS_STR                     = "0 ps",
   
   parameter PLL_M_COUNTER_BYPASS_EN                 = "true",
   parameter PLL_M_COUNTER_EVEN_DUTY_EN              = "false",
   parameter PLL_M_COUNTER_HIGH                      = 256,
   parameter PLL_M_COUNTER_LOW                       = 256,
   
   parameter PLL_PHYCLK_0_FREQ_PS_STR                = "0 ps",
   parameter PLL_PHYCLK_0_BYPASS_EN                  = "true",
   parameter PLL_PHYCLK_0_HIGH                       = 256,
   parameter PLL_PHYCLK_0_LOW                        = 256,
   
   parameter PLL_PHYCLK_1_FREQ_PS_STR                = "0 ps",
   parameter PLL_PHYCLK_1_BYPASS_EN                  = "true",
   parameter PLL_PHYCLK_1_HIGH                       = 256,
   parameter PLL_PHYCLK_1_LOW                        = 256,

   parameter PLL_PHYCLK_FB_FREQ_PS_STR               = "0 ps",
   parameter PLL_PHYCLK_FB_BYPASS_EN                 = "true",
   parameter PLL_PHYCLK_FB_HIGH                      = 256,
   parameter PLL_PHYCLK_FB_LOW                       = 256
   
) (
   input  logic       global_reset_n_int,     
   input  logic       pll_ref_clk_int,        
   output logic       pll_lock,               
   output logic       pll_dll_clk,            
   output logic [7:0] phy_clk_phs,            
   output logic [1:0] phy_clk,                
   output logic       phy_fb_clk_to_tile,     
   input  logic       phy_fb_clk_to_pll,      
   output logic [1:0] hmc_clk,                 
   output logic       core_clk_out
);
   timeunit 1ns;
   timeprecision 1ps;

   logic [7:0]        pll_vcoph;              
   logic [1:0]        pll_loaden;             
   logic [1:0]        pll_lvds_clk;           
   logic [8:0]        pll_outclk;             

   assign phy_clk_phs  = pll_vcoph;
   
   assign phy_clk[0]   = pll_loaden[0];       // C-cnt 1 drives phy_clk 0 through a delay chain (swapping is intentional)
   assign phy_clk[1]   = pll_lvds_clk[0];     // C-cnt 0 drives phy_clk 1 through a delay chain (swapping is intentional)
   
   assign hmc_clk[0]   = pll_outclk[1];       // C-cnt 1 drives hmc_clk 0 (swapping is intentional)
   assign hmc_clk[1]   = pll_outclk[0];       // C-cnt 0 drives hmc clk 1 (swapping is intentional)

   assign core_clk_out = pll_outclk[1];
   
   twentynm_iopll # (
   
      ////////////////////////////////////
      //  VCO and Ref clock
      ////////////////////////////////////
      .reference_clock_frequency                  (PLL_REF_CLK_FREQ_PS_STR),
      .vco_frequency                              (PLL_VCO_FREQ_PS_STR),
      
      .pll_vco_ph0_en                             ("true"),                        // vcoph[0] is required to drive phy_clk_phs[0]
      .pll_vco_ph1_en                             ("true"),                        // vcoph[1] is required to drive phy_clk_phs[1]
      .pll_vco_ph2_en                             ("true"),                        // vcoph[2] is required to drive phy_clk_phs[2]
      .pll_vco_ph3_en                             ("true"),                        // vcoph[3] is required to drive phy_clk_phs[3]
      .pll_vco_ph4_en                             ("true"),                        // vcoph[4] is required to drive phy_clk_phs[4]
      .pll_vco_ph5_en                             ("true"),                        // vcoph[5] is required to drive phy_clk_phs[5]
      .pll_vco_ph6_en                             ("true"),                        // vcoph[6] is required to drive phy_clk_phs[6]
      .pll_vco_ph7_en                             ("true"),                        // vcoph[7] is required to drive phy_clk_phs[7]
      
      ////////////////////////////////////
      //  Special clock selects
      ////////////////////////////////////
      .pll_dll_src                                ("pll_dll_src_ph0"),             // Use vcoph[0] as DLL input
      .pll_phyfb_mux                              ("lvds_tx_fclk"),                // PHY clock feedback path selector
      
      ////////////////////////////////////
      //  M Counter
      ////////////////////////////////////
      .pll_m_counter_bypass_en                    (PLL_M_COUNTER_BYPASS_EN),       // VCO Frequency = RefClk Freq * M * CCnt2 / N
      .pll_m_counter_even_duty_en                 (PLL_M_COUNTER_EVEN_DUTY_EN),
      .pll_m_counter_high                         (PLL_M_COUNTER_HIGH),
      .pll_m_counter_low                          (PLL_M_COUNTER_LOW),
      .pll_m_counter_ph_mux_prst                  (0),
      .pll_m_counter_prst                         (1),
      .pll_m_counter_coarse_dly                   ("0 ps"),
      .pll_m_counter_fine_dly                     ("0 ps"),
      .pll_m_counter_in_src                       ("c_m_cnt_in_src_cscd_clk"),    // Take cascade in from PHYFB mux
      
      ////////////////////////////////////
      //  N Counter
      ////////////////////////////////////
      .pll_n_counter_bypass_en                    ("true"),
      .pll_n_counter_odd_div_duty_en              ("false"),
      .pll_n_counter_high                         (256),
      .pll_n_counter_low                          (256),
      .pll_n_counter_coarse_dly                   ("0 ps"),
      .pll_n_counter_fine_dly                     ("0 ps"),
      
      ////////////////////////////////////
      //  C Counter 0 (phy_clk[1])
      ////////////////////////////////////
      .pll_c0_out_en                              ("true"),                        // C-counter driving phy_clk[1]
      .output_clock_frequency_0                   (PLL_PHYCLK_1_FREQ_PS_STR),
      .phase_shift_0                              ("0 ps"),
      .duty_cycle_0                               (50),
      .pll_c0_extclk_dllout_en                    ("true"),
      .pll_c_counter_0_bypass_en                  (PLL_PHYCLK_1_BYPASS_EN),
      .pll_c_counter_0_even_duty_en               ("false"),
      .pll_c_counter_0_high                       (PLL_PHYCLK_1_HIGH),
      .pll_c_counter_0_low                        (PLL_PHYCLK_1_LOW),
      .pll_c_counter_0_ph_mux_prst                (0),
      .pll_c_counter_0_prst                       (1),      
      .pll_c_counter_0_coarse_dly                 ("0 ps"),
      .pll_c_counter_0_fine_dly                   ("0 ps"),
      .pll_c_counter_0_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),
      
      ////////////////////////////////////
      //  C Counter 1 (phy_clk[0])
      ////////////////////////////////////
      .pll_c1_out_en                              ("true"),                        // C-counter driving phy_clk[0]
      .output_clock_frequency_1                   (PLL_PHYCLK_0_FREQ_PS_STR),
      .phase_shift_1                              ("0 ps"),
      .duty_cycle_1                               (50),
      .pll_c1_extclk_dllout_en                    ("true"),
      .pll_c_counter_1_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),
      .pll_c_counter_1_even_duty_en               ("false"),
      .pll_c_counter_1_high                       (PLL_PHYCLK_0_HIGH),
      .pll_c_counter_1_low                        (PLL_PHYCLK_0_LOW),
      .pll_c_counter_1_ph_mux_prst                (0),
      .pll_c_counter_1_prst                       (1),      
      .pll_c_counter_1_coarse_dly                 ("0 ps"),
      .pll_c_counter_1_fine_dly                   ("0 ps"),
      .pll_c_counter_1_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),

      ////////////////////////////////////
      //  C Counter 2 (phy_clk[2])
      ////////////////////////////////////
      .pll_c2_out_en                              ("true"),                        // C-counter driving phy_clk[2]
      .output_clock_frequency_2                   (PLL_PHYCLK_FB_FREQ_PS_STR),
      .phase_shift_2                              ("0 ps"),
      .duty_cycle_2                               (50),
      .pll_c2_extclk_dllout_en                    ("true"),
      .pll_c_counter_2_bypass_en                  (PLL_PHYCLK_FB_BYPASS_EN),
      .pll_c_counter_2_even_duty_en               ("false"),
      .pll_c_counter_2_high                       (PLL_PHYCLK_FB_HIGH),
      .pll_c_counter_2_low                        (PLL_PHYCLK_FB_LOW),
      .pll_c_counter_2_ph_mux_prst                (0),
      .pll_c_counter_2_prst                       (1),
      .pll_c_counter_2_coarse_dly                 ("0 ps"),
      .pll_c_counter_2_fine_dly                   ("0 ps"),
      .pll_c_counter_2_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),
      
      ////////////////////////////////////
      //  C Counter 3 (unused)
      ////////////////////////////////////
      .pll_c3_out_en                              ("false"),                       // Not used by EMIF
      .output_clock_frequency_3                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_3                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_3                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_3_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_3_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_3_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_3_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_3_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_3_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_3_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_3_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_3_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  C Counter 4 (unused)
      ////////////////////////////////////
      .pll_c4_out_en                              ("false"),                       // Not used by EMIF
      .output_clock_frequency_4                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_4                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_4                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_4_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_4_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_4_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_4_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_4_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_4_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_4_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_4_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_4_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  C Counter 5 (unused)
      ////////////////////////////////////
      //HACK (see case:110563)
      .pll_c5_out_en                              ("true"),                        // Not used by EMIF
      .output_clock_frequency_5                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_5                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_5                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_5_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_5_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_5_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_5_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_5_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_5_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_5_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_5_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_5_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  C Counter 6 (unused)
      ////////////////////////////////////
      .pll_c6_out_en                              ("false"),                       // Not used by EMIF
      .output_clock_frequency_6                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_6                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_6                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_6_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_6_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_6_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_6_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_6_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_6_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_6_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_6_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_6_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  C Counter 7 (unused)
      ////////////////////////////////////
      .pll_c7_out_en                              ("false"),                       // Not used by EMIF
      .output_clock_frequency_7                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_7                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_7                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_7_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_7_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_7_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_7_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_7_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_7_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_7_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_7_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_7_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  C Counter 8 (unused)
      ////////////////////////////////////
      .pll_c8_out_en                              ("false"),                       // Not used by EMIF
      .output_clock_frequency_8                   (PLL_PHYCLK_0_FREQ_PS_STR),      // Don't care (unused c-counter)
      .phase_shift_8                              ("0 ps"),                        // Don't care (unused c-counter)
      .duty_cycle_8                               (50),                            // Don't care (unused c-counter)
      .pll_c_counter_8_bypass_en                  (PLL_PHYCLK_0_BYPASS_EN),        // Don't care (unused c-counter)
      .pll_c_counter_8_even_duty_en               ("false"),                       // Don't care (unused c-counter)
      .pll_c_counter_8_high                       (PLL_PHYCLK_0_HIGH),             // Don't care (unused c-counter)
      .pll_c_counter_8_low                        (PLL_PHYCLK_0_LOW),              // Don't care (unused c-counter)
      .pll_c_counter_8_ph_mux_prst                (0),                             // Don't care (unused c-counter)
      .pll_c_counter_8_prst                       (1),                             // Don't care (unused c-counter)
      .pll_c_counter_8_coarse_dly                 ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_8_fine_dly                   ("0 ps"),                        // Don't care (unused c-counter)
      .pll_c_counter_8_in_src                     ("c_m_cnt_in_src_ph_mux_clk"),   // Don't care (unused c-counter)
      
      ////////////////////////////////////
      //  Misc Delay Chains
      ////////////////////////////////////
      .pll_ref_buf_dly                            ("0 ps"),
      .pll_cmp_buf_dly                            ("0 ps"),
      
      .pll_dly_0_enable                           ("true"),                        // Controls whether delay chain on phyclk[0] is enabled, must be true for phyclk to toggle
      .pll_dly_1_enable                           ("true"),                        // Controls whether delay chain on phyclk[1] is enabled, must be true for phyclk to toggle
      .pll_dly_2_enable                           ("true"),                        // Controls whether delay chain on phyclk[2] is enabled
      .pll_dly_3_enable                           ("true"),                        // Controls whether delay chain on phyclk[3] is enabled
      
      .pll_coarse_dly_0                           ("0 ps"),                        // Fine delay chain to skew phyclk[0]
      .pll_coarse_dly_1                           ("0 ps"),                        // Fine delay chain to skew phyclk[1]
      .pll_coarse_dly_2                           ("0 ps"),                        // Fine delay chain to skew phyclk[2]
      .pll_coarse_dly_3                           ("0 ps"),                        // Fine delay chain to skew phyclk[3]
      
      .pll_fine_dly_0                             ("0 ps"),                        // Fine delay chain to skew phyclk[0]
      .pll_fine_dly_1                             ("0 ps"),                        // Fine delay chain to skew phyclk[1]
      .pll_fine_dly_2                             ("0 ps"),                        // Fine delay chain to skew phyclk[2]
      .pll_fine_dly_3                             ("0 ps"),                        // Fine delay chain to skew phyclk[3]
      
      ////////////////////////////////////
      //  Misc PLL Modes and Features
      ////////////////////////////////////
      .pll_enable                                 ("true"),                        // Enable PLL
      .pll_powerdown_mode                         ("false"),                       // PLL power down mode
      .bw_sel                                     ("auto"),                        // Automatic bandwidth select
      .is_cascaded_pll                            ("false"),                       // EMIF assumes non-cascaded PLL for optimal jitter
      
      .compensation_mode                          ("direct"),                      // EMIF doesn't need PLL compensation. Alignment of core clocks and PHY clocks is handled by CPA
      .pll_fbclk_mux_1                            ("pll_fbclk_mux_1_glb"),         // Setting required by DIRECT compensation
      .pll_fbclk_mux_2                            ("pll_fbclk_mux_2_m_cnt"),       // Setting required by DIRECT compensation
      
      .pll_extclk_0_enable                        ("false"),                       // EMIF PLL does not need to drive output clock pin
      .pll_extclk_1_enable                        ("false"),                       // EMIF PLL does not need to drive output clock pin
      
      .pll_clkin_0_src                            ("pll_clkin_0_src_refclkin"),    // 
      .pll_clkin_1_src                            ("pll_clkin_1_src_refclkin"),    // 
      .pll_sw_refclk_src                          ("pll_sw_refclk_src_clk_0"),     // 
      .pll_auto_clk_sw_en                         ("false"),                       // EMIF PLL does not use the automatic clock switch-over feature
      .pll_clk_loss_sw_en                         ("false"),                       // EMIF PLL does not use the automatic clock switch-over feature
      .pll_manu_clk_sw_en                         ("false"),                       // EMIF PLL does not use the automatic clock switch-over feature
      .pll_ctrl_override_setting                  ("true")
      
   ) pll_inst (

      .refclk                                     (4'b0000),
      .rst_n                                      (global_reset_n_int),
      .loaden                                     (pll_loaden),
      .lvds_clk                                   (pll_lvds_clk),
      .vcoph                                      (pll_vcoph),
      .fblvds_in                                  (phy_fb_clk_to_pll),
      .fblvds_out                                 (phy_fb_clk_to_tile),
      .dll_output                                 (pll_dll_clk),
      .lock                                       (pll_lock),
      .outclk                                     (pll_outclk),
      .fbclk_in                                   ('0),
      .fbclk_out                                  (),
      .zdb_in                                     ('0),
      .phase_done                                 (),
      .pll_cascade_in                             (pll_ref_clk_int),
      .pll_cascade_out                            (),
      .extclk_output                              (),
      .core_refclk                                ('0),
      .dps_rst_n                                  ('0),
      .mdio_dis                                   ('0),
      .pfden                                      ('0),
      .phase_en                                   ('0),
      .pma_csr_test_dis                           ('0),
      .up_dn                                      ('0),
      .extswitch                                  ('0),
      .clken                                      ('0),                            // Don't care (extclk)
      .cnt_sel                                    ('0),
      .num_phase_shifts                           ('0),
      .clk0_bad                                   (),
      .clk1_bad                                   (),
      .clksel                                     (),
      .csr_clk                                    ('0),
      .csr_en                                     ('0),
      .csr_in                                     ('0),
      .csr_out                                    (),
      .dprio_clk                                  ('0),
      .dprio_rst_n                                ('1),
      .dprio_address                              ('0),
      .scan_mode_n                                ('1),
      .scan_shift_n                               ('1),
      .write                                      ('0),
      .read                                       ('0),
      .readdata                                   (),
      .writedata                                  ('0),
      .extclk_dft                                 (),
      .block_select                               (),
      .lf_reset                                   (),
      .pipeline_global_en_n                       (),
      .pll_pd                                     ()
   );
   
endmodule
