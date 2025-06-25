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



///////////////////////////////////////////////////////
//  sv_rcn_bundle.sv
//
//     fileset 5/29/2013
//     version 0.9
//
//  This version is to be a drop-in replacement for the sv_rcn_bundle in the existing 10GBaseKR design example if user reconfig controller access, CTLE and DFE features are not needed.
//  	The management_master has been replaced by state machines and the glue logic for channel value is sucked into the state machine, including provisions for handling DFE,CTLE provisions from the phy.
// 	arbiter              - used for multiple KR channel arbitration
//      channel_sel          - selects the KR PHY control signals of the associated selected channel
//      reconfig_master      - contains the reconfig controller setup state machine modules (PMA, MIF, CTLE, DFE)
//      user_reconfig_access - handles the user reconfig controller access
//
//      v0.5 5/14/2013 - added option to turn off DFE/CTLE engines before AN and CTLE bypass
//      v0.6 5/17/2013 - gated disable_ctle_dfe_before_an to only operate during AN (was initially setup to clear DFE/CTLE on every MIF)
//      v0.7 5/22/2013 - changed default value for ENA_RECONFIG_CONTROLLER_DFE_RCFG and ENA_RECONFIG_CONTROLLER_CTLE_RCFG to 0 to reduce reconfig controller size
//      v0.8 5/23/2013 - added register option to adjust Vref of the DFE circut and retrigger.  Also DISABLE_CTLE_DFE_BEFORE_AN now defaulted to 0.
//      v0.9 5/29/2013 - added separate DFE/CTLE disable before AN (disable_ctle_dfe_before_an is now 2 bits - [1] disables ctle, [0] disables dfe)

`timescale 1ps/1ps
 
module sv_rcn_bundle
  #(
//  parameter ONEG_TENG_MODE = 0,       // use the 1g_10g roms/mifs 
    parameter PMA_RD_AFTER_WRITE = 1,   // used for simulation to check if LT values are written correctly 1= check values, 0 = don't check values.
    parameter PLLS = 24,                 // can be #channel for 10G-only, 
                                        // can be 2x#channel for 1G_10G and KR
    parameter CHANNELS = 12,             // can be 1 for single channel, 2 for dual channel
    parameter MAP_PLLS = 1,             // remap logical channels to account for PLLs? (assuming one channel per xcvr instance)
    parameter SYNTH_1588_1G = 0,        // GigE data-path is not 1588-enabled 
    parameter SYNTH_1588_10G = 0,       // 10GBASE-R data-path is not 1588-enabled
    parameter KR_PHY_SYNTH_AN = 1,      // AN enabled
    parameter KR_PHY_SYNTH_LT = 1,      // LT enabled
    parameter KR_PHY_SYNTH_DFE = 0,     // DFE enabled
    parameter KR_PHY_SYNTH_CTLE = 0,    // CTLE enabled
    parameter USER_RECONFIG_CONTROL = 0, // user accessable reconfig controller
    parameter USER_RCFG_PRIORITY = 0,    // 1 = gives USER priority if reconfig controller access is requested, 0 = give PHY priority (only give user priority if seq_pcs_mode bits [1] and [0] are low for all channels)
    parameter KR_PHY_SYNTH_GIGE = 0,    // GigE not enabled              
    parameter PRI_RR = 0,                // use round-robin priority in arbiter
    parameter ENA_RECONFIG_CONTROLLER_ANALOG_RCFG = 1,  // enable reconfig controller analog reconfiguration logic (if KR_PHY_SYNTH_LT is 1, this needs to be 1)
    parameter ENA_RECONFIG_CONTROLLER_MIF_RCFG = 1,     // enable reconfig controller MIF  reconfiguration logic (if KR_PHY_SYNTH_AN  is 1, this needs to be 1)
    parameter ENA_RECONFIG_CONTROLLER_DFE_RCFG = 0,  // enable reconfig controller DFE reconfiguration logic (if KR_PHY_SYNTH_DFE is 1, this needs to be 1)
    parameter ENA_RECONFIG_CONTROLLER_CTLE_RCFG = 0,  // enable reconfig controller CTLE reconfiguration logic (if KR_PHY_SYNTH_CTLE is 1, this needs to be 1)
    parameter ENA_RECONFIG_CONTROLLER_PLL_RCFG = 1,  // enable reconfig controller PLL  reconfiguration logic (if PLL reconfiguration is needed this needs to be 1)

    parameter DISABLE_CTLE_DFE_BEFORE_AN = 2'b01,  // this will disable the CTLE and DFE blocks before AN start. LT will reenable CTLE and DFE after AN.  There is also a register from user AVMM that will enable or disable this. Register and parameter values will be OR'd together so any 1's will set the feature. bit [0] = disable DFE, bit [1] = disable CTLE (high asserted) e.g. a value of 3 will disable both. 

    parameter BYPASS_CTLE_RECONFIG = 0, // this will bypass CTLE reconfig even though the PHY is presetting it.  0 = normal mode PHY controls CTLE, and also gives control to bypass_ctle_reconfig register setting.  1 = bypass CTLE reconfig request from PHY (setting of 1 takes precedence over the bypass_ctle_reconfig register
    
    parameter WIDTH_CH = altera_xcvr_functions::clogb2(CHANNELS-1)	 
    )
   (
    input wire 														 reconfig_clk,
    input wire 														 reconfig_reset,

    input wire [altera_xcvr_functions::get_custom_reconfig_from_width ("Stratix V","duplex",CHANNELS,PLLS,CHANNELS)-1:0] reconfig_from_xcvr,
    output wire [altera_xcvr_functions::get_custom_reconfig_to_width ("Stratix V","duplex",CHANNELS,PLLS,CHANNELS)-1:0]  reconfig_to_xcvr,
    output wire 													 reconfig_mgmt_busy, // reconfig is busy

    //used for testing - unmodfied reconfig_controller busy signal
output wire reconfig_mgmt_busy_raw,
    //end testing
    
    input wire [CHANNELS*6-1:0] 											 seq_pcs_mode,
    input wire [CHANNELS*6-1:0] 											 seq_pma_vod,
    input wire [CHANNELS*5-1:0] 											 seq_pma_postap1,
    input wire [CHANNELS*4-1:0] 											 seq_pma_pretap,
    input wire [CHANNELS-1:0] 												 seq_start_rc, 
    input wire [CHANNELS-1:0] 												 lt_start_rc,
    input wire [CHANNELS*3-1:0] 											 tap_to_upd, 
    output wire [CHANNELS-1:0] 												 hdsk_rc_busy, // reconfig is busy 
    output wire [CHANNELS-1:0] 												 baser_ll_mif_done
															 
    
    // for DFE
    
    ,input [CHANNELS-1:0] dfe_start_rc 
    ,input [CHANNELS*2-1:0] dfe_mode // valid at the start of dfe_start_rc and is held after falling edge of rc_busy, 0 = one shot mode, 1 = continuous DFE mode 
    
    // for CTLE
    
    ,input [CHANNELS-1:0] ctle_start_rc
    ,input [CHANNELS*4-1:0] ctle_rc // Manual CTLE value, valid at rising edge of ctle_start_rc and held till rc_busy falling edge.  0000 = disable, 1111= max
    ,input [CHANNELS*2-1:0] ctle_mode // CTLE mode, valid at rising edge of ctle_start_rc and held till rc_busy falling edge. 00 = disble, 01 = CTLE 1-time adaptation mode, 10 = CTLE continuous adaptation mode, 11 = reserved
    
    
    // for USER reconfig

    ,input [7:0] avmm_address
    ,input avmm_read
    ,input avmm_write
    ,input [31:0] avmm_writedata
    ,output wire [31:0] avmm_readdata
    ,output wire avmm_waitrequest

	 
    );
	 
   wire [5:0] 		seq_pcs_mode_out;
   wire [5:0] 		pma_vod_out;
   wire [4:0] 		pma_post_out;
   wire [3:0] 		pma_pre_out;

   wire [2:0] 		tap_to_upd_out; 
	 
   wire [31:0] 		logical_ch_number;

   wire 		baser_ll_mif_done_wire;
	 
   wire [WIDTH_CH-1:0] 	rcfg_chan_select;
   wire [CHANNELS-1:0] 	chan_select_1hot;
	 
   wire [6:0] 		reconfig_mgmt_address;

   wire 		reconfig_mgmt_read;
   wire 		reconfig_mgmt_read_int;
//   wire [31:0] 		reconfig_mgmt_readdata;
 //  wire [31:0] 		reconfig_mgmt_readdata_phy;
   wire 		reconfig_mgmt_waitrequest;
   wire 		reconfig_mgmt_write;
//   wire [31:0] 		reconfig_mgmt_writedata;
   
   
   wire [31:0] 		reconfig_mif_address;   
   wire 		reconfig_mif_read;
   reg 			reconfig_mif_waitrequest;
   reg [15:0] 		reconfig_mif_readdata;
	
   wire [31:0] 		rom_mif_address;
   reg [9:0] 		rom_mif_address_reg;
   
   wire 		rc_mgmt_busy;
   wire 		mgmt_lt_start_rc;
   wire 		mgmt_seq_start_rc;

//   wire [31:0] 		reconfig_mgmt_writedata_to_rom;


   wire 		mgmt_dfe_start_rc;
   wire [1:0]		dfe_mode_out;
   

 

   wire 		mgmt_ctle_start_rc;
   wire [3:0]		ctle_rc_out;
   wire [1:0]		ctle_mode_out;
   



   wire [CHANNELS-1:0] 	dfe_start_rc_wire;
   wire [CHANNELS*2-1:0] dfe_mode_wire;
   
   
   wire [CHANNELS-1:0] 	 ctle_start_rc_wire;
   wire [CHANNELS*4-1:0] ctle_rc_wire;
   wire [CHANNELS*2-1:0] ctle_mode_wire; 
   
   wire 	      bypass_ctle_reconfig;
   wire [1:0]         disable_ctle_dfe_before_an;
   wire [2:0] 	      dfe_vref_low_reg;
   wire [2:0] 	      dfe_vref_high_reg;
   wire 	      dfe_ena_vref_reg;        


	    // AVMM reconfig_master interface (Slave)
   wire [6:0] from_reconfig_master_avmm_address;
   wire  from_reconfig_master_avmm_read;
   wire  from_reconfig_master_avmm_write;
   wire [31:0] from_reconfig_master_avmm_writedata;
   wire [31:0] to_reconfig_master_avmm_readdata;
   wire to_reconfig_master_avmm_waitrequest;
   
   // AVMM xcvr reconfig controller (Master)
   wire  [6:0] to_reconfig_mgmt_address;
   wire  to_reconfig_mgmt_read;
   wire  to_reconfig_mgmt_write;
   wire  [31:0] to_reconfig_mgmt_writedata;
   wire  [31:0] from_reconfig_mgmt_readdata;
   wire  from_reconfig_mgmt_waitrequest;

   // reconfig_mgmt_busy
   wire  to_user_reconfig_reconfig_mgmt_busy;
   wire  to_reconfig_master_reconfig_mgmt_busy;
   wire  from_reconfig_mgmt_reconfig_mgmt_busy;

 // reconfig master busy
   wire rc_mgmt_busy_to_arbiter;
   wire  rc_mgmt_busy_from_reconfig_master;
	 
   wire [CHANNELS*6-1:0] 	 seq_pma_vod_wire;
   wire [CHANNELS*5-1:0] 	 seq_pma_postap1_wire;
   wire [CHANNELS*4-1:0] 	 seq_pma_pretap_wire;
   wire [CHANNELS-1:0] 	 	 lt_start_rc_wire;
   wire [CHANNELS*3-1:0] 	 tap_to_upd_wire; 
	// output the busy status of the reconfig controller
	assign reconfig_mgmt_busy = from_reconfig_mgmt_reconfig_mgmt_busy;

// synchronize 	lt_start_rc,seq_pma_vod,seq_pma_postap1,seq_pma_pretap,tap_to_upd
   alt_xcvr_resync #(
   .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
   .WIDTH            (CHANNELS*19),  // Number of bits to resync
   .INIT_VALUE       (0)
   ) resync_req (
     .clk    (reconfig_clk),
     .reset  (reconfig_reset),
     .d      ({lt_start_rc,seq_pma_vod,seq_pma_postap1,seq_pma_pretap,tap_to_upd}),
     .q      ({lt_start_rc_wire,seq_pma_vod_wire,seq_pma_postap1_wire,seq_pma_pretap_wire,tap_to_upd_wire})
   );	
	
arbiter #(
 .CHANNELS (CHANNELS),
 .PRI_RR   (PRI_RR)
) arbiter_inst  (
  .clk               (reconfig_clk       ),             
  .reset             (reconfig_reset     ),
  .lt_start_rc       (lt_start_rc_wire   ),  // 1 per channel, synchronous with clk
  .seq_start_rc      (seq_start_rc       ),  // 1 per channel, synchronous with clk
  .seq_pcs_mode      (seq_pcs_mode       ),  // 1 per channel, synchronous with clk
  .hdsk_rc_busy      (hdsk_rc_busy       ),  // 1 per channel, synchronous with clk
 //rcfg_busy         (rc_mgmt_busy       ),  // reconfig_busy from controller
  .rcfg_busy         (rc_mgmt_busy_to_arbiter), //rc_mgmt_busy       ),  // reconfig_busy from reconfig_master  or user_reconfig_access
  .rcfg_lt_start_rc  (mgmt_lt_start_rc   ),   // pma reconfig request to reconfig_master
  .rcfg_seq_start_rc (mgmt_seq_start_rc  ),  // pcs reconfig request to reconfig_master
  .rcfg_chan_select  (rcfg_chan_select   )   // current selected channel


  ,.dfe_start_rc (dfe_start_rc_wire) // 1 per channel, synchronous with clk
  ,.rcfg_dfe_start_rc (mgmt_dfe_start_rc) //1 per channel, synchronous with clk



  ,.ctle_start_rc (ctle_start_rc_wire)
  ,.rcfg_ctle_start_rc (mgmt_ctle_start_rc)

		 
);

channel_sel #(
	.CHANNELS                       (CHANNELS),
	.PLLs                           (PLLS/CHANNELS),
	.MAP_PLLS                       (MAP_PLLS)
	
) channel_sel_inst(

	.clk                            (reconfig_clk), 	//i
	.reset                          (reconfig_clk),	//i	
	.seq_pcs_mode                   (seq_pcs_mode), 	//i6*ch
	.seq_pma_vod                    (seq_pma_vod_wire),	//i6*ch
	.seq_pma_posttap1               (seq_pma_postap1_wire),	//i5*ch
	.seq_pma_pretap                 (seq_pma_pretap_wire),	//i4*ch
	.tap_to_upd                     (tap_to_upd_wire),	//i3*ch
	.rcfg_chan_select               (rcfg_chan_select),	//i32
	.pma_vod_out                    (pma_vod_out),	//o6
	.pma_post_out                   (pma_post_out),	//o5
	.pma_pre_out                    (pma_pre_out),	//o4
	.seq_pcs_mode_out               (seq_pcs_mode_out),	//o6
	.tap_to_upd_out                 (tap_to_upd_out),	//o3
	.lc_address_out                 (logical_ch_number),		//o32 // size of AVMM write data port

	.dfe_mode                      (dfe_mode_wire),
	.dfe_mode_out                  (dfe_mode_out),



	.ctle_rc                       (ctle_rc_wire),
	.ctle_mode                     (ctle_mode_wire),
	.ctle_rc_out                   (ctle_rc_out),
	.ctle_mode_out                 (ctle_mode_out)
		       
);


reconfig_master reconfig_master_inst
       (

	.clk                            (reconfig_clk),		//i
	.reset                          (reconfig_reset),		//i
	
	.av_write                       (from_reconfig_master_avmm_write),		//o
	.av_read                        (from_reconfig_master_avmm_read),
	.av_address                     (from_reconfig_master_avmm_address),
	.av_writedata                   (from_reconfig_master_avmm_writedata),
	.av_readdata                    (to_reconfig_master_avmm_readdata),
	.av_waitrequest	              (to_reconfig_master_avmm_waitrequest),
	.logical_channel_number         (logical_ch_number),	//logical channel number to be worked on
	.rom_mif_address                (rom_mif_address),			// used for seq. tells the reconfig block what address the mif is at	
	.tap_to_upd                     (tap_to_upd_out),					// for PMA states, selects vod, post, pre taps to update.
	.main_tap_rc                    (pma_vod_out),						// setting for VOD tap
	.post_tap_rc                    (pma_post_out),						// setting for 1st post tap
	.pre_tap_rc                     (pma_pre_out),							// setting for pre tap
	.PIO_IN_LT_START_RC             (mgmt_lt_start_rc),
	.PIO_IN_SEQ_START_RC            (mgmt_seq_start_rc),
	.PIO_IN_RECONFIG_MGMT_BUSY      (to_reconfig_master_reconfig_mgmt_busy),					// ties to the reconfig_busy of the recontroller
	.PIO_OUT_BASER_LL_MIF_DONE      (baser_ll_mif_done_wire),
	.PIO_OUT_HDSK_RC_BUSY_WR        (rc_mgmt_busy_from_reconfig_master), //rc_mgmt_busy),			// write busy output (OR'd of all handshake busy signal)
	.PIO_OUT_HDSK_RC_BUSY_RD        (),			// read busy output (OR'd of all handshake busy signal)
	// following is not currently used as read function is not implemented
	.PIO_OUT_RC_PMA_RD_DONE         (),
	.PIO_IN_VERIFY_PMA_WRITE        (PMA_RD_AFTER_WRITE), //'d0),

	// following is for DFE and CTLE
	
	.ctle_rc                        (ctle_rc_out),
	.ctle_mode                      (ctle_mode_out),
	.ctle_start_rc                  (mgmt_ctle_start_rc),
	.dfe_mode                       (dfe_mode_out),
	.dfe_start_rc                   (mgmt_dfe_start_rc),

	// input control ports
//	.disable_ctle_dfe_before_an     (seq_pcs_mode_out == 'd1 && (disable_ctle_dfe_before_an || DISABLE_CTLE_DFE_BEFORE_AN)),
	.disable_ctle_dfe_before_an    ({(seq_pcs_mode_out == 'd1 && (disable_ctle_dfe_before_an[1] || DISABLE_CTLE_DFE_BEFORE_AN[1]) && ENA_RECONFIG_CONTROLLER_CTLE_RCFG),
	                                 (seq_pcs_mode_out == 'd1 && (disable_ctle_dfe_before_an[0] || DISABLE_CTLE_DFE_BEFORE_AN[0]) && ENA_RECONFIG_CONTROLLER_DFE_RCFG)}),

	.bypass_ctle_reconfig           (bypass_ctle_reconfig || BYPASS_CTLE_RECONFIG),


	.dfe_vref_low_reg               (dfe_vref_low_reg),                     //o3
	.dfe_vref_high_reg              (dfe_vref_high_reg),                   //o3
	.dfe_ena_vref_reg               (dfe_ena_vref_reg)                       //o	
);


/////////////// MIF streaming ROM /////////////////

   rom_all_modes all_modes_mif_rom (
	.address                        (reconfig_mif_address[10:1]),
        .clock                          (reconfig_clk),
        .q                              (reconfig_mif_readdata)
   );

    // Add a waitrequest with reconfig_mif_read
   always_ff @(posedge reconfig_clk) 
     begin
        reconfig_mif_waitrequest <= ~(reconfig_mif_read);
     end		 
		 
//////////////// Setup ROM starting address //////////////////
///MIF is arranged in following way
///0   - 163 - 10G MIF 
///164 - 327 - 1G MIF       (A4)
///328 - 491 - LL MIF       (148)
///492 - 655 - 10G 1588 MIF (1EC)
///656 - 819 - 1G 1588 MIF  (290) 
///820 - 983 - FEC LL MIF --(334) 


always @ (seq_pcs_mode or seq_pcs_mode_out)
	if 		((seq_pcs_mode_out=='d8) && !SYNTH_1588_1G)
		rom_mif_address_reg = 10'h0A4;		// 1G non 1588
	else if 	((|seq_pcs_mode_out[1:0]) && !SYNTH_1588_1G)
		rom_mif_address_reg = 10'h148;		// Low latency mode
	else if 	((seq_pcs_mode_out == 'd4) && SYNTH_1588_10G)
		rom_mif_address_reg = 10'h1EC;		// 10G 1588
	else if 	((seq_pcs_mode_out == 'd8) && SYNTH_1588_1G)
		rom_mif_address_reg = 10'h290;		// 1G 1588
	else if 	(seq_pcs_mode_out == 'd32) 
		rom_mif_address_reg = 10'h334;		//	FEC Low Latency mode
	else
		rom_mif_address_reg = 'd0;			// default 10G non 1588

		
		
   assign rom_mif_address[31:11] = 'd0;
   assign rom_mif_address[10:1] = rom_mif_address_reg;
   assign rom_mif_address[0] = 1'b0;
		
		
		
////////////////////////// ifdef section ///////////////////////////


   generate	

      if (KR_PHY_SYNTH_DFE)
	begin   
	  alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH            (CHANNELS*3),  // Number of bits to resync
          .INIT_VALUE       (0)
          ) resync_reset_fec (
            .clk    (reconfig_clk),
            .reset  (reconfig_reset),
            .d      ({dfe_start_rc,dfe_mode}),
            .q      ({dfe_start_rc_wire,dfe_mode_wire})
          );	
	end	

      else
	begin
	   assign dfe_start_rc_wire  = 'd0;
	   assign dfe_mode_wire      = 'd0;
	end
   endgenerate	


   generate   
      if (KR_PHY_SYNTH_CTLE)
	begin
	  alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH            (CHANNELS*7),  // Number of bits to resync
          .INIT_VALUE       (0)
          ) resync_reset_fec (
            .clk    (reconfig_clk),
            .reset  (reconfig_reset),
            .d      ({ctle_start_rc,ctle_rc,ctle_mode}),
            .q      ({ctle_start_rc_wire,ctle_rc_wire,ctle_mode_wire})
          );	
	end
   

      else
	begin
	   assign ctle_start_rc_wire = 'd0;
	   assign ctle_rc_wire       = 'd0;
	   assign ctle_mode_wire     = 'd0;
	end 
   	
   endgenerate	
		
		
   generate
      if (USER_RECONFIG_CONTROL)
	begin
			
	   // this is for the user reconfig access to the reconfig controller
	   user_reconfig_access  
	     #(
	       .USER_RCFG_PRIORITY (USER_RCFG_PRIORITY),
	       .CHANNELS (CHANNELS)
	    ) user_reconfig_access_inst (
	      .clk(reconfig_clk),  //i
	      .reset(reconfig_reset), //i
	      
	      .rc_mgmt_busy_from_reconfig_master(rc_mgmt_busy_from_reconfig_master || from_reconfig_mgmt_reconfig_mgmt_busy ), //i uses this to gate grant for user access  
	      //  .reconfig_rc_pending_from_arbiter(), //i this may be used to see if there are any pending request from the arbiter
	      
   
	      .rc_mgmt_busy_to_arbiter(rc_mgmt_busy_to_arbiter), //o will assert this if user requests access to reconfig controller
	      .seq_pcs_mode (seq_pcs_mode),


	      // user AVMM register access
	      .avmm_address(avmm_address),
	      .avmm_read (avmm_read),
	      .avmm_write(avmm_write),
              .avmm_writedata(avmm_writedata),
              .avmm_readdata(avmm_readdata),
              .avmm_waitrequest(avmm_waitrequest),		 
			       
					 


	      // AVMM reconfig_master interface (Slave)
	      .from_reconfig_master_avmm_address(from_reconfig_master_avmm_address), //i7
	      .from_reconfig_master_avmm_read(from_reconfig_master_avmm_read),          //i
	      .from_reconfig_master_avmm_write(from_reconfig_master_avmm_write),         //i
	      .from_reconfig_master_avmm_writedata(from_reconfig_master_avmm_writedata), //i32
	      .to_reconfig_master_avmm_readdata(to_reconfig_master_avmm_readdata),    //o32
	      .to_reconfig_master_avmm_waitrequest(to_reconfig_master_avmm_waitrequest),  //o
	      
	      // AVMM xcvr reconfig controller (Master)
	      .to_reconfig_mgmt_address(to_reconfig_mgmt_address),            //o7
	      .to_reconfig_mgmt_read(to_reconfig_mgmt_read),                //o
	      .to_reconfig_mgmt_write(to_reconfig_mgmt_write),               //o
	      .to_reconfig_mgmt_writedata(to_reconfig_mgmt_writedata),          //o32
	      .from_reconfig_mgmt_readdata(from_reconfig_mgmt_readdata),         //i32
	      .from_reconfig_mgmt_waitrequest(from_reconfig_mgmt_waitrequest),       //i
	      
	      // reconfig_mgmt_busy
	      .to_user_reconfig_reconfig_mgmt_busy(to_user_reconfig_reconfig_mgmt_busy),    //o
	      .to_reconfig_master_reconfig_mgmt_busy(to_reconfig_master_reconfig_mgmt_busy),  //o
	      .from_reconfig_mgmt_reconfig_mgmt_busy(from_reconfig_mgmt_reconfig_mgmt_busy),     //i

	     // output control ports
	      .disable_ctle_dfe_before_an (disable_ctle_dfe_before_an), //o
	      .bypass_ctle_reconfig (bypass_ctle_reconfig),             //o
	      .dfe_vref_low_reg (dfe_vref_low_reg),                     //o3
	      .dfe_vref_high_reg (dfe_vref_high_reg),                   //o3
	      .dfe_ena_vref_reg(dfe_ena_vref_reg)                       //o
	      );			
	end

      else
	begin

// rewire reconfig_controller to reconfig_master
	   assign to_reconfig_mgmt_address              = from_reconfig_master_avmm_address; 
	   assign to_reconfig_mgmt_read                 = from_reconfig_master_avmm_read;  
	   assign to_reconfig_mgmt_write                = from_reconfig_master_avmm_write;   
	   assign to_reconfig_mgmt_writedata            = from_reconfig_master_avmm_writedata;
	   
	   assign to_reconfig_master_avmm_readdata      = from_reconfig_mgmt_readdata;
	   assign to_reconfig_master_avmm_waitrequest   = from_reconfig_mgmt_waitrequest;
	   
// rewire reconfig controller busy
	   assign to_reconfig_master_reconfig_mgmt_busy = from_reconfig_mgmt_reconfig_mgmt_busy;
	
	
	
// rewire reconfig_master to arbiter
	   assign rc_mgmt_busy_to_arbiter = rc_mgmt_busy_from_reconfig_master;


	     // disable  control ports, Parameters will be used instead.
	   assign disable_ctle_dfe_before_an = 1'b0;
	   assign bypass_ctle_reconfig = 1'b0;
	   assign dfe_vref_low_reg = 3'd0;
	   assign dfe_vref_high_reg = 3'd0;
	   assign dfe_ena_vref_reg = 1'b0;
	   
	end // else: !if(USER_RECONFIG_CONTROL)

endgenerate
			
//////////////////////////////////// end `ifdef section /////////////////////////
	 
		 
		 
/////////////////////// ll_mif_done decoder /////////////////
assign chan_select_1hot 	= 		{{(CHANNELS-1){1'b0}},1'b1} << rcfg_chan_select ;	
assign baser_ll_mif_done	= 		{CHANNELS{baser_ll_mif_done_wire}}  & chan_select_1hot ; 		 
		 
   assign reconfig_mgmt_busy_raw = from_reconfig_mgmt_reconfig_mgmt_busy;  // for export: raw reconfig_controller busy signal (for monitoring, testing and checking when the reconfig controller is busy)
   
 		 
//////////////////////////////////////////////////////////////////////
////////
////////		The reconfig controller alt_xcvr_reconfig was copied from the reconfig controller variant file reconfig.v for parameterization
////////                reconfig.v can be opened by the MegaWizard and re-parameterized if needed, or for viewing the MegaWizard parameters
////////
////////		NOTE: This can be replaced by the reconfig.v, but the number of interfaces as well as the analog,dfe,ctle,mif,pll reconfig must be statically set in the MegaWizard
////////
//////////////////////////////////////////////////////////////////////



   
//============================================================================
// reconfig controller
//============================================================================
alt_xcvr_reconfig #(
  .device_family                 ("Stratix V"),
  .number_of_reconfig_interfaces (CHANNELS+PLLS),
  .enable_offset                 (1),
  .enable_dcd                    (0),
  .enable_lc                     (1),
  .enable_analog                 (ENA_RECONFIG_CONTROLLER_ANALOG_RCFG),
  .enable_eyemon                 (0),
  .enable_dfe                    (ENA_RECONFIG_CONTROLLER_DFE_RCFG),  //turned on for DFE, can be parameterized if needed
  .enable_adce                   (ENA_RECONFIG_CONTROLLER_CTLE_RCFG),  //turned on for ACDE, can be parameterized if needed
  .enable_mif                    (ENA_RECONFIG_CONTROLLER_MIF_RCFG),
  .enable_pll                    (ENA_RECONFIG_CONTROLLER_PLL_RCFG)
  ) reconfig_ctrl (
  .reconfig_busy             (from_reconfig_mgmt_reconfig_mgmt_busy),
  .mgmt_clk_clk              (reconfig_clk),
  .mgmt_rst_reset            (reconfig_reset),

  .reconfig_mgmt_address     (to_reconfig_mgmt_address),
  .reconfig_mgmt_read        (to_reconfig_mgmt_read),
  .reconfig_mgmt_readdata    (from_reconfig_mgmt_readdata),   //_phy
  .reconfig_mgmt_waitrequest (from_reconfig_mgmt_waitrequest),
  .reconfig_mgmt_write       (to_reconfig_mgmt_write),
  .reconfig_mgmt_writedata   (to_reconfig_mgmt_writedata),  //_to_rom

  .reconfig_mif_address      (reconfig_mif_address),
  .reconfig_mif_read         (reconfig_mif_read),
  .reconfig_mif_readdata     (reconfig_mif_readdata),
  .reconfig_mif_waitrequest  (reconfig_mif_waitrequest),

  .reconfig_to_xcvr          (reconfig_to_xcvr),
  .reconfig_from_xcvr        (reconfig_from_xcvr)
);	 





endmodule
