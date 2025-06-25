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
module alt_100gbe_tb ();


`include "dynamic_parameters.v"

reg clk_ref = 0;
reg pma_arst_ST = 1;
reg pcs_rx_arst_ST = 1;
reg pcs_tx_arst_ST = 1;

wire pll_locked;
wire tx_serial_clk;

reg         clk_status = 0;
reg  [15:0] status_addr = 0;
reg         status_read = 0;
reg         status_write = 0;
reg  [31:0] status_writedata = 0;
wire [31:0] status_readdata;
wire	    status_readdata_valid;

wire [9:0] serial;
wire [3:0] serial_caui4;
reg clk_rxmac = 1;
reg clk_txmac = 1;
reg mac_rx_arst_ST = 1;
reg mac_tx_arst_ST = 1;

reg [20*8:1] progress;
reg [19:0] lane_progress = 0;
reg [31:0] scratch = 0;
reg [19:0] am_status = 0;
integer lanes_locked = 0;
integer i = 0;

reg [511:0] l8_tx_data = 0;
reg [5:0] l8_tx_empty = 0;
reg l8_tx_startofpacket = 0;
reg l8_tx_endofpacket = 0;
wire l8_tx_ready;
reg l8_tx_valid = 0;

wire [511:0] l8_rx_data;
wire [5:0] l8_rx_empty;
wire l8_rx_startofpacket;
wire l8_rx_endofpacket;
wire l8_rx_error;
wire l8_rx_valid;
wire l8_rx_fcs_valid;
wire l8_rx_fcs_error;

reg [319:0] din = 0;
reg [4:0]   din_start = 0;
reg [39:0]  din_end_pos = 0;
wire         din_ack;
wire [319:0] dout_d;
wire [39:0]  dout_c;
wire [4:0]   dout_first_data;
wire [39:0]  dout_last_data;
wire [4:0]   dout_runt_last_data;
wire [4:0]   dout_payload;
wire         dout_fcs_error;
wire         dout_fcs_valid;
wire [4:0]   dout_dst_addr_match;
wire         dout_valid;	

initial begin
	#1000;
	$display("*****************************************");
	$display("**     100g Ethernet Testbench");
	$display("**");
	$display("**");
	$display("** Target Device: 		%s",DEVICE_FAMILY); // parameters defined in dynamic_parameters.v
	$display("** IP Configuration: 		%s", MAC_CONFIG);
	$display("** Variant Name: 			%s", VARIANT_NAME);
	$display("** Status Clock Rate: 	%d KHz", STATUS_CLK_KHZ);
	if (ENABLE_STATISTICS_CNTR == 1'b1) $display("** Statistics Registers:  Enabled");
	else $display("** Statistics Registers:  Disabled");
	
	
	if (HAS_MAC == 1'b0) begin
		$display("**");
		$display("** This variant is PHY only");
	end else if (HAS_PHY == 1'b0) begin
		$display("**");
		$display("** This variant is MAC only");
	
			if (HAS_ADAPTERS == 1'b1) $display("** Interface: 			Avalon-ST");
			else $display("** Interface: 			Custom-ST");
	
	end else begin
		$display("**");
		$display("** This variant is MAC & PHY");
		if (HAS_ADAPTERS == 1'b1) $display("** Interface: 			Avalon-ST");
		else $display("** Interface: 			Custom-ST");
	end
	
	if (HAS_MAC == 1'b0 || HAS_PHY == 1'b0 ||  VARIANT != 3) begin
		$display("***************************************************************************");
		$display("** This testbench only supports full duplex variants with a MAC and a PHY");
		$display("**");
		$display("**");
	    $display("**");
		$display("** Testbench complete.");
		$display("**");
		$display("*****************************************");
		#100000;
		$finish;
	end
	
	
	$display("*****************************************");
	$display("** Reseting the IP Core...");
	$display("**");
	$display("**");
	
	#10000;
	pma_arst_ST    = 0;
	pcs_rx_arst_ST = 0;
	pcs_tx_arst_ST = 0;
	mac_rx_arst_ST = 0;
	mac_tx_arst_ST = 0;
	#400000;
	
	$display("*****************************************");
	$display("** Waiting for alignment and deskew...");
	$display("**");
	$display("**");

	$display("** Virutal lane locked:        None (lanes left:          20) |@@@@@@@@@@@@@@@@@@@@|");
	while (scratch[19:0] != 20'hFFFFF) begin 
		stat_read(32'h00000013,scratch);
		if (scratch[19:0] != am_status) begin
			for (i = 0; i < 20; i = i + 1) begin
				if (scratch[i] ^ am_status[i]) begin
					lanes_locked = lanes_locked + 1;
					lane_progress[i] = 1'b1;
					progress = {lane_progress[19]?"/":"@",lane_progress[18]?"\\":"@",lane_progress[17]?"/":"@",lane_progress[16]?"\\":"@",lane_progress[15]?"/":"@",
								lane_progress[14]?"\\":"@",lane_progress[13]?"/":"@",lane_progress[12]?"\\":"@",lane_progress[11]?"/":"@",lane_progress[10]?"\\":"@",
								lane_progress[ 9]?"/":"@",lane_progress[ 8]?"\\":"@",lane_progress[ 7]?"/":"@",lane_progress[ 6]?"\\":"@",lane_progress[ 5]?"/":"@",
								lane_progress[ 4]?"\\":"@",lane_progress[ 3]?"/":"@",lane_progress[ 2]?"\\":"@",lane_progress[ 1]?"/":"@",lane_progress[ 0]?"\\":"@"};	
					$display("** Virtual lane locked: %d (lanes left: %d) |%s|", i,20-lanes_locked,progress);
				end
			end
			am_status = scratch[19:0];
			lane_progress = scratch[19:0];
		end
	end
	scratch = 0;
	
	while (scratch[1] != 1'b1) begin
		stat_read(32'h00000014,scratch);
		if (scratch[1]) $display("** All virtual lanes locked and deskewed, ready for data      |--------------------|");
	end
	
	$display("*****************************************");
	$display("** Starting TX traffic...");
	$display("**");
	$display("**");
	
	if (HAS_ADAPTERS) send_packets_100g_avl(10);
	else send_packets_100g_cus(10);
	
	
	$display("**");
	$display("** Testbench complete.");
	$display("**");
	$display("*****************************************");
	#100000;
	$finish;
	
end

always begin
	clk_status = ~clk_status;
	#(500000000/STATUS_CLK_KHZ); // parameter defined in dynamic_parameters.v
end

always begin
	clk_ref = ~clk_ref;
	#(REF_CLK_PERIOD/2); // parameter defined in dynamic_parameters.v
end

always begin
	clk_rxmac = ~clk_rxmac;
	clk_txmac = ~clk_txmac;
	#(MAC_CLK_PERIOD/2);
end

task stat_read;
  input  [31:0]  address;
  output [31:0]   data;
  begin
    @(posedge clk_status);
    status_addr = address;
    status_read = 1;
    while (!status_readdata_valid) begin
		@(posedge clk_status);
		status_addr = 0;
		status_read = 0;
	end
	data = status_readdata;
  end
endtask

task stat_write;
  input [31:0]  address;
  input [31:0]  data;
  begin
    @(posedge clk_status);
    status_addr      = address;
    status_write     = 1;
    status_writedata = data;
    @(posedge clk_status);
    status_addr      = 0;
    status_write     = 0;
    status_writedata = 0;
  end
endtask

task send_packets_100g_avl;
  input  [31:0]  number_of_packets;
  integer i,j;
  begin
  fork
  for (i = 1; i <= number_of_packets; i = i +1) begin
      @(posedge clk_txmac);
     wait_for_ready_avl;  
      $display("** Sending Packet %d...",i);
  
      l8_tx_data          = 512'h01E42339_F0001E42_339F0100_00000000_AAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA_BBBBBBBB_BBBBBBBB_BBBBBBBB_BBBBBBBB_CCCCCCCC_CCCCCCCC_CCCCCCCC_CCCCCCCC;
      l8_tx_startofpacket = 1'b1;
      l8_tx_valid         = 1'b1;
     wait_for_ready_avl;   
  
      l8_tx_data          = {16{i}};
      l8_tx_startofpacket = 1'b0;
     wait_for_ready_avl;    

  
      l8_tx_data          = 512'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      l8_tx_endofpacket   = 1'b1;
      l8_tx_empty         = 6'd32;
      wait_for_ready_avl; 
  
      l8_tx_data          = 0;
      l8_tx_endofpacket   = 0;
      l8_tx_startofpacket = 0;
      l8_tx_valid         = 0;
      l8_tx_empty         = 0;
      
  end
  
  for (j = 1; j <= number_of_packets; j = j+1) begin
  	while (!(l8_rx_valid && !l8_rx_startofpacket && !l8_rx_endofpacket)) @(posedge clk_rxmac);
	$display("** Received Packet %d...",l8_rx_data[31:0]);
      	@(posedge clk_rxmac);
  end
  

  join

  end
endtask

   task wait_for_ready_avl;
      #1
      
      if(!l8_tx_ready) begin
	 while(!l8_tx_ready) @(posedge clk_txmac);
	 
      end
      else begin
	 @(posedge clk_txmac);
	 
      end
      
   endtask // wait_for_ready_avl
   
   
   task wait_for_ack_cus;
      #1
      
      if(!din_ack) begin
	 while(!din_ack) @(posedge clk_txmac);
	 
      end
      else begin
	 @(posedge clk_txmac);
	 
      end
      
   endtask // wait_for_ack_cus   

task send_packets_100g_cus;
  input  [31:0]  number_of_packets;
  integer i,j;
  begin
  fork
  for (i = 1; i <= number_of_packets; i = i +1) begin
      @(posedge clk_txmac);
      

     wait_for_ack_cus;  
      $display("** Sending Packet %d...",i);
  
      din          = 320'h01E42339_F0001E42_339F0100_00000000_AAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA_BBBBBBBB_BBBBBBBB;
      din_start    = 5'b10000;
     wait_for_ack_cus;    
  
      din          = {10{i}};
      din_start = 5'b0;
     wait_for_ack_cus;  	  

  
      din          = 320'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_00000000;
      din_end_pos   = 40'h8;
     wait_for_ack_cus;
  
      din = 0;
      din_start = 0;
      din_end_pos = 0;
      
  end
  
  for (j = 1; j <= number_of_packets; j = j+1) begin
  	while (!(dout_valid && |dout_first_data)) @(posedge clk_rxmac);
	@(posedge clk_rxmac);
	while (!dout_valid) @(posedge clk_rxmac);
	$display("** Received Packet %d...",dout_d[31:0]);	
  end
  

  join

  end
endtask

generate


if (DEVICE_FAMILY == "Arria 10" && VARIANT == 3) begin : GEN_A10_TX_PLL
	atx_pll a10_tx_pll (
					.pll_powerdown(pma_arst_ST),   //   pll_powerdown.pll_powerdown input
					.pll_refclk0(clk_ref),     //     pll_refclk0.clk input
					.pll_locked(pll_locked),      //      pll_locked.pll_locked output
					.pll_cal_busy(),    //    pll_cal_busy.pll_cal_busy output
					.mcgb_rst(pma_arst_ST),        //        mcgb_rst.mcgb_rst input
					.mcgb_serial_clk(tx_serial_clk)// mcgb_serial_clk.clk output
			);
end




if (HAS_ADAPTERS == 1 && VARIANT == 3 && DEVICE_FAMILY == "Arria 10"  && !IS_CAUI4) begin : GEN_100_nf_avl

defparam GEN_100_nf_avl.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (



		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.pll_locked(pll_locked),//input  wire                        //            pll_if.pll_locked
		.tx_serial_clk({10{tx_serial_clk}}),//input  wire                     //                  .tx_serial_clk
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.l8_rx_data(l8_rx_data),//output wire                        //             l8_rx.l8_rx_data[511:0]
		.l8_rx_empty(l8_rx_empty),//output wire                       //                  .l8_rx_empty[5:0]
		.l8_rx_startofpacket(l8_rx_startofpacket),//output wire               //                  .l8_rx_startofpacket
		.l8_rx_endofpacket(l8_rx_endofpacket),//output wire                 //                  .l8_rx_endofpacket
		.l8_rx_error(l8_rx_error),//output wire                       //                  .l8_rx_error
		.l8_rx_valid(l8_rx_valid),//output wire                       //                  .l8_rx_valid
		.l8_rx_fcs_valid(l8_rx_fcs_valid),//output wire                   //                  .l8_rx_fcs_valid
		.l8_rx_fcs_error(l8_rx_fcs_error),//output wire                   //                  .l8_rx_fcs_error
		
		.l8_tx_data(l8_tx_data),//input  wire                        //             l8_tx.l8_tx_data[511:0]
		.l8_tx_empty(l8_tx_empty),//input  wire                       //                  .l8_tx_empty[5:0]
		.l8_tx_startofpacket(l8_tx_startofpacket),//input  wire               //                  .l8_tx_startofpacket
		.l8_tx_endofpacket(l8_tx_endofpacket),//input  wire                 //                  .l8_tx_endofpacket
		.l8_tx_ready(l8_tx_ready),//output wire                       //                  .l8_tx_ready
		.l8_tx_valid(l8_tx_valid),//input  wire                       //                  .l8_tx_valid
		
		.a10_reconfig_write(1'b0),//input  wire                // a10_reconfig_avmm.a10_reconfig_write
		.a10_reconfig_read(1'b0),//input  wire                 //                  .a10_reconfig_read
		.a10_reconfig_address(14'b0),//input  wire              //                  .a10_reconfig_address[13:0]
		.a10_reconfig_writedata(32'b0)//input  wire            //                  .a10_reconfig_writedata[31:0]

);

end

if (HAS_ADAPTERS == 0 && VARIANT == 3 && DEVICE_FAMILY == "Arria 10"  && !IS_CAUI4) begin : GEN_100_nf_cus

defparam GEN_100_nf_cus.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (



		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.pll_locked(pll_locked),//input  wire                        //            pll_if.pll_locked
		.tx_serial_clk({10{tx_serial_clk}}),//input  wire                     //                  .tx_serial_clk
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.din                       (din),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //     custom_st_din.din
		.din_start                 (din_start),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                  .din_start
		.din_end_pos               (din_end_pos),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //                  .din_end_pos
		.din_ack                   (din_ack),
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                  .din_ack
		.dout_d                    (dout_d),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //    custom_st_dout.dout_d
		.dout_c                    (dout_c),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                  .dout_c
		.dout_first_data           (dout_first_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                  .dout_first_data
		.dout_last_data            (dout_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_last_data
		.dout_runt_last_data       (dout_runt_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_runt_last_data
		.dout_payload              (dout_payload),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                  .dout_payload
		.dout_fcs_error            (dout_fcs_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_error
		.dout_fcs_valid            (dout_fcs_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_valid
		.dout_dst_addr_match       (dout_dst_addr_match),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_dst_addr_match
		.dout_valid                (dout_valid),      
		
		.a10_reconfig_write(1'b0),//input  wire                // a10_reconfig_avmm.a10_reconfig_write
		.a10_reconfig_read(1'b0),//input  wire                 //                  .a10_reconfig_read
		.a10_reconfig_address(14'b0),//input  wire              //                  .a10_reconfig_address[13:0]
		.a10_reconfig_writedata(32'b0)//input  wire            //                  .a10_reconfig_writedata[31:0]

);

end

if (HAS_ADAPTERS == 1 && VARIANT == 3 && DEVICE_FAMILY == "Stratix IV"  && !IS_CAUI4) begin : GEN_100_siv_avl

defparam GEN_100_siv_avl.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (

		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif

		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.l8_rx_data(l8_rx_data),//output wire                        //             l8_rx.l8_rx_data[511:0]
		.l8_rx_empty(l8_rx_empty),//output wire                       //                  .l8_rx_empty[5:0]
		.l8_rx_startofpacket(l8_rx_startofpacket),//output wire               //                  .l8_rx_startofpacket
		.l8_rx_endofpacket(l8_rx_endofpacket),//output wire                 //                  .l8_rx_endofpacket
		.l8_rx_error(l8_rx_error),//output wire                       //                  .l8_rx_error
		.l8_rx_valid(l8_rx_valid),//output wire                       //                  .l8_rx_valid
		.l8_rx_fcs_valid(l8_rx_fcs_valid),//output wire                   //                  .l8_rx_fcs_valid
		.l8_rx_fcs_error(l8_rx_fcs_error),//output wire                   //                  .l8_rx_fcs_error
		
		.l8_tx_data(l8_tx_data),//input  wire                        //             l8_tx.l8_tx_data[511:0]
		.l8_tx_empty(l8_tx_empty),//input  wire                       //                  .l8_tx_empty[5:0]
		.l8_tx_startofpacket(l8_tx_startofpacket),//input  wire               //                  .l8_tx_startofpacket
		.l8_tx_endofpacket(l8_tx_endofpacket),//input  wire                 //                  .l8_tx_endofpacket
		.l8_tx_ready(l8_tx_ready),//output wire                       //                  .l8_tx_ready
		.l8_tx_valid(l8_tx_valid)//input  wire                       //                  .l8_tx_valid
		


);

end

if (HAS_ADAPTERS == 0 && VARIANT == 3 && DEVICE_FAMILY == "Stratix IV"  && !IS_CAUI4) begin : GEN_100_siv_cus

defparam GEN_100_siv_cus.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (

		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif

		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.din                       (din),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //     custom_st_din.din
		.din_start                 (din_start),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                  .din_start
		.din_end_pos               (din_end_pos),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //                  .din_end_pos
		.din_ack                   (din_ack),
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                  .din_ack
		.dout_d                    (dout_d),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //    custom_st_dout.dout_d
		.dout_c                    (dout_c),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                  .dout_c
		.dout_first_data           (dout_first_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                  .dout_first_data
		.dout_last_data            (dout_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_last_data
		.dout_runt_last_data       (dout_runt_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_runt_last_data
		.dout_payload              (dout_payload),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                  .dout_payload
		.dout_fcs_error            (dout_fcs_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_error
		.dout_fcs_valid            (dout_fcs_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_valid
		.dout_dst_addr_match       (dout_dst_addr_match),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_dst_addr_match
		.dout_valid                (dout_valid)

);

end

if (HAS_ADAPTERS == 1 && VARIANT == 3 && (DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ") && !IS_CAUI4) begin : GEN_100_sv_avl

defparam GEN_100_sv_avl.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (

		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif
		
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.l8_rx_data(l8_rx_data),//output wire                        //             l8_rx.l8_rx_data[511:0]
		.l8_rx_empty(l8_rx_empty),//output wire                       //                  .l8_rx_empty[5:0]
		.l8_rx_startofpacket(l8_rx_startofpacket),//output wire               //                  .l8_rx_startofpacket
		.l8_rx_endofpacket(l8_rx_endofpacket),//output wire                 //                  .l8_rx_endofpacket
		.l8_rx_error(l8_rx_error),//output wire                       //                  .l8_rx_error
		.l8_rx_valid(l8_rx_valid),//output wire                       //                  .l8_rx_valid
		.l8_rx_fcs_valid(l8_rx_fcs_valid),//output wire                   //                  .l8_rx_fcs_valid
		.l8_rx_fcs_error(l8_rx_fcs_error),//output wire                   //                  .l8_rx_fcs_error
		
		.l8_tx_data(l8_tx_data),//input  wire                        //             l8_tx.l8_tx_data[511:0]
		.l8_tx_empty(l8_tx_empty),//input  wire                       //                  .l8_tx_empty[5:0]
		.l8_tx_startofpacket(l8_tx_startofpacket),//input  wire               //                  .l8_tx_startofpacket
		.l8_tx_endofpacket(l8_tx_endofpacket),//input  wire                 //                  .l8_tx_endofpacket
		.l8_tx_ready(l8_tx_ready),//output wire                       //                  .l8_tx_ready
		.l8_tx_valid(l8_tx_valid),//input  wire                       //                  .l8_tx_valid
		
		.reconfig_from_xcvr(),
		.reconfig_to_xcvr(1400'b0)
		
);

end

if (HAS_ADAPTERS == 0 && VARIANT == 3  && (DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ") && !IS_CAUI4) begin : GEN_100_sv_cus

defparam GEN_100_sv_cus.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (

		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif
		
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.din                       (din),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //     custom_st_din.din
		.din_start                 (din_start),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                  .din_start
		.din_end_pos               (din_end_pos),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //                  .din_end_pos
		.din_ack                   (din_ack),
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                  .din_ack
		.dout_d                    (dout_d),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //    custom_st_dout.dout_d
		.dout_c                    (dout_c),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                  .dout_c
		.dout_first_data           (dout_first_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                  .dout_first_data
		.dout_last_data            (dout_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_last_data
		.dout_runt_last_data       (dout_runt_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_runt_last_data
		.dout_payload              (dout_payload),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                  .dout_payload
		.dout_fcs_error            (dout_fcs_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_error
		.dout_fcs_valid            (dout_fcs_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_valid
		.dout_dst_addr_match       (dout_dst_addr_match),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_dst_addr_match
		.dout_valid                (dout_valid),
		
		.reconfig_from_xcvr(),
		.reconfig_to_xcvr(1400'b0)

);

end

if (HAS_ADAPTERS == 1 && VARIANT == 3 && DEVICE_FAMILY == "Stratix V" && IS_CAUI4) begin : GEN_100_sv_c4_avl

defparam GEN_100_sv_c4_avl.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (


		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif
		
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial_caui4),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial_caui4),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.l8_rx_data(l8_rx_data),//output wire                        //             l8_rx.l8_rx_data[511:0]
		.l8_rx_empty(l8_rx_empty),//output wire                       //                  .l8_rx_empty[5:0]
		.l8_rx_startofpacket(l8_rx_startofpacket),//output wire               //                  .l8_rx_startofpacket
		.l8_rx_endofpacket(l8_rx_endofpacket),//output wire                 //                  .l8_rx_endofpacket
		.l8_rx_error(l8_rx_error),//output wire                       //                  .l8_rx_error
		.l8_rx_valid(l8_rx_valid),//output wire                       //                  .l8_rx_valid
		.l8_rx_fcs_valid(l8_rx_fcs_valid),//output wire                   //                  .l8_rx_fcs_valid
		.l8_rx_fcs_error(l8_rx_fcs_error),//output wire                   //                  .l8_rx_fcs_error
		
		.l8_tx_data(l8_tx_data),//input  wire                        //             l8_tx.l8_tx_data[511:0]
		.l8_tx_empty(l8_tx_empty),//input  wire                       //                  .l8_tx_empty[5:0]
		.l8_tx_startofpacket(l8_tx_startofpacket),//input  wire               //                  .l8_tx_startofpacket
		.l8_tx_endofpacket(l8_tx_endofpacket),//input  wire                 //                  .l8_tx_endofpacket
		.l8_tx_ready(l8_tx_ready),//output wire                       //                  .l8_tx_ready
		.l8_tx_valid(l8_tx_valid),//input  wire                       //                  .l8_tx_valid
		
		.reconfig_from_xcvr0(),
		.reconfig_to_xcvr0(210'b0),
		.reconfig_from_xcvr1(),
		.reconfig_to_xcvr1(210'b0),
		.reconfig_from_xcvr2(),
		.reconfig_to_xcvr2(210'b0),
		.reconfig_from_xcvr3(),
		.reconfig_to_xcvr3(210'b0)
		
		


);

end

if (HAS_ADAPTERS == 0 && VARIANT == 3 && DEVICE_FAMILY == "Stratix V" && IS_CAUI4) begin : GEN_100_sv_c4_cus

defparam GEN_100_sv_c4_cus.dut.ENET_ENTITY_QMEGA_06072013_inst.FAST_SIMULATION = 1;

ENET_ENTITY_QMEGA_06072013 dut (

		`ifdef SYNC_E
		.rx_clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		.tx_clk_ref(!clk_ref),//input  wire                           //           clk_ref.clk
		`else
		.clk_ref(clk_ref),//input  wire                           //           clk_ref.clk
		`endif
		
		.pma_arst_ST(pma_arst_ST),//input  wire                       //       pma_arst_ST.pma_arst_ST
		.pcs_rx_arst_ST(pcs_rx_arst_ST),//input  wire                    //    pcs_rx_arst_ST.pcs_rx_arst_ST
		.pcs_tx_arst_ST(pcs_tx_arst_ST),//input  wire                    //    pcs_tx_arst_ST.pcs_tx_arst_ST
		
		.rx_serial(serial_caui4),//input  wire                         //         rx_serial.rx_serial[9:0]
		.tx_serial(serial_caui4),//output wire                         //         tx_serial.tx_serial[9:0] 
		
		.clk_status(clk_status),//input  wire                        //            status.clk
		.status_addr(status_addr),//input  wire                       //                  .address[15:0]
		.status_read(status_read),//input  wire                       //                  .read
		.status_write(status_write),//input  wire                      //                  .write
		.status_writedata(status_writedata),//input  wire                  //                  .writedata[31:0]
		.status_readdata(status_readdata),//output wire                   //                  .readdata[31:0] 
		.status_readdata_valid(status_readdata_valid),//output wire             //                  .readdatavalid
		
		.pause_insert_time(16'b0),
		.pause_insert_tx(1'b0),//input  wire                   //             pause.pause_insert_tx
		.pause_insert_mcast(1'b0),//input  wire                //                  .pause_insert_mcast
		.pause_insert_dst(48'b0),//input  wire                  //                  .pause_insert_dst[47:0]
		.pause_insert_src(48'b0),//input  wire                  //                  .pause_insert_src[47:0] 
		
		.clk_rxmac(clk_rxmac),//input  wire                         //         clk_rxmac.clk_rxmac
		.clk_txmac(clk_txmac),//input  wire                         //         clk_txmac.clk_txmac
		
		.mac_rx_arst_ST(mac_rx_arst_ST),//input  wire                    //    mac_rx_arst_ST.mac_rx_arst_ST
		.mac_tx_arst_ST(mac_tx_arst_ST),//input  wire                    //    mac_tx_arst_ST.mac_tx_arst_ST
		
		.din                       (din),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //     custom_st_din.din
		.din_start                 (din_start),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                  .din_start
		.din_end_pos               (din_end_pos),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //                  .din_end_pos
		.din_ack                   (din_ack),
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                  .din_ack
		.dout_d                    (dout_d),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //    custom_st_dout.dout_d
		.dout_c                    (dout_c),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                  .dout_c
		.dout_first_data           (dout_first_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                  .dout_first_data
		.dout_last_data            (dout_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_last_data
		.dout_runt_last_data       (dout_runt_last_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_runt_last_data
		.dout_payload              (dout_payload),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                  .dout_payload
		.dout_fcs_error            (dout_fcs_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_error
		.dout_fcs_valid            (dout_fcs_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                  .dout_fcs_valid
		.dout_dst_addr_match       (dout_dst_addr_match),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                  .dout_dst_addr_match
		.dout_valid                (dout_valid),      
		
		.reconfig_from_xcvr0(),
		.reconfig_to_xcvr0(210'b0),
		.reconfig_from_xcvr1(),
		.reconfig_to_xcvr1(210'b0),
		.reconfig_from_xcvr2(),
		.reconfig_to_xcvr2(210'b0),
		.reconfig_from_xcvr3(),
		.reconfig_to_xcvr3(210'b0)
		

);

end

endgenerate






endmodule
