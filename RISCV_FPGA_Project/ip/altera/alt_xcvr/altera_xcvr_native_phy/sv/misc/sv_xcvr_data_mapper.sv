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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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

module sv_xcvr_data_mapper 
  #(
    parameter LANES = 1,
    parameter DATA_PATH_SELECT = "pma_direct",
    parameter PLD_INTERFACE_WIDTH = 80,
    parameter PLD_DATA_MAX_WIDTH = 80,
    parameter INTERFACE_RECONFIG_ENABLE = 0
    ) (
    input wire [PLD_INTERFACE_WIDTH * LANES -1:0] tx_parallel_user_data,
    output wire [PLD_DATA_MAX_WIDTH * LANES -1:0] tx_datain_from_pld,

    input [PLD_DATA_MAX_WIDTH * LANES -1:0] rx_dataout_to_pld,
    output [PLD_INTERFACE_WIDTH * LANES -1:0] rx_parallel_user_data
       );

//   localparam LCL_PLD_CONTROL_USED_WIDTH = (PLD_INTERFACE_WIDTH == 66)? 2 : 0;
   
   

/* PMA Direct side table for data remapping
 
 TX Serializer side:
Serializer Mode of Operation
 
Mode	Div4	Div2	Div5	Active Input Data[79:0]
8 bits	0	0	0	Data[7:0]
10 bits	0	0	1	Data[9:0]
16 bits	0	1	0	Data[17:10, 7:0]
20 bits	0	1	1	Data[19:0]
32 bits	1	0	0	Data[37:30, 27:20, 17:10, 7:0]
40 bits	1	0	1	Data[39:0]
64 bits	1	1	0	Data[77:70, 67:60, 57:50, 47:40, 37:30, 27:20, 17:10, 7:0]
80 bits	1	1	1	Data[79:0]

Deserializer mode :

Mode DIV8   RDESER_DIV4	DIV2	DIV5	Active DOUT
8b	0	0	0	0	DOUT[7:0]
10b	0	0	0	1	DOUT[9:0]
16b	0	0	1	0	DOUT[17:10, 7:0]
20b	0	0	1	1	DOUT[19:0]
32b	0	1	0	0	DOUT[37:30,27:20,17:10,7:0]
40b	0	1	0	1	DOUT[39:0]
64b	1	1	0	0	DOUT_CORE[77:70,67:60,57:50,47:40,37:30,27:20,17:10,7:0]
80b	1	1	0	1	DOUT_CORE[79:0]

For PMA Direct case - need a special handling for 16bits 32 bits and 64 bits of data
 
*/

   
   generate begin:data_mapper
      genvar ig;

      for (ig = 0; ig < LANES; ig = ig +1) begin:channel
	
	case (DATA_PATH_SELECT)
	  "pma_direct" :
	    begin
	       // When INTERFACE_RECONFIG_ENABLE = 1, data_width = 80 in case of PMA Direct
	       if (INTERFACE_RECONFIG_ENABLE == 1)
		 begin
		    // Rearrange tx_data
		    assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_INTERFACE_WIDTH] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH];
		    // Rearrange rx_data	 
		    assign rx_parallel_user_data[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
		 end
	       // When INTERFACE_RECONFIG_ENABLE = 0, need to rearrange the daa properly as per the table described above
	       else
		 begin
		    // when width = 8, 10, 40, 80, active din, dout is [7:0], [9:0], [39:0], [79:0] respectively
		    if (PLD_INTERFACE_WIDTH == 8 || PLD_INTERFACE_WIDTH == 10 || PLD_INTERFACE_WIDTH == 20 || PLD_INTERFACE_WIDTH == 40 || PLD_INTERFACE_WIDTH == 80)
		      begin
			 // Rearrange tx_data
			 assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_INTERFACE_WIDTH] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH];
			 if (PLD_INTERFACE_WIDTH != PLD_DATA_MAX_WIDTH)	      
			   assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + PLD_INTERFACE_WIDTH) +: (PLD_DATA_MAX_WIDTH - PLD_INTERFACE_WIDTH)] = 0;
			 // Rearrange rx_data
			 assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_INTERFACE_WIDTH];
		      end
		    // when width = 16, 32, 64 needs proper data handling, as only chunck of data is active		 
		    else
		      begin
			 // when 16 valid data bits are Data[17:10, 7:0]
			 if (PLD_INTERFACE_WIDTH == 16)
			   begin
			      // Rearrange tx_data				   
			      assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: 8] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8];
			      // Terminate bits [8,9] and bits [79:18] to 0
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 8) +: 2] = 0;   			   
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 18) +: (PLD_DATA_MAX_WIDTH - 18)] = 0;
			      
			      // Rearrange rx_data
			      assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8];
			   end // if (PLD_INTERFACE_WIDTH == 16)
			 // when 32, valid data bits are Data[37:30, 27:20, 17:10, 7:0]
			 else if (PLD_INTERFACE_WIDTH == 32)
			   begin
			      // Rearrange tx_data	   
			      assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: 8] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+20) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+16) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+30) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+24) +: 8];				   
			      // Terminate bits [8,9, 18, 19, 28, 29] and bits [79:38] to 0
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 8) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 18) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 28) +: 2] = 0;				   
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 38) +: (PLD_DATA_MAX_WIDTH - 38)] = 0;
			      
			      // Rearrange rx_data
			      assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+16) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+20) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+24) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+30) +: 8];				   
			   end // if (PLD_INTERFACE_WIDTH == 32)
			 // when 32, valid data bits are Data[77:70, 67:60, 57:50, 47:40, 37:30, 27:20, 17:10, 7:0]			      
			 else if (PLD_INTERFACE_WIDTH == 64)
			   begin
			      // Rearrange tx_data	   
			      assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: 8] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+20) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+16) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+30) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+24) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+40) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+32) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+50) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+40) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+60) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+48) +: 8];
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH+70) +: 8] = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+56) +: 8];	   
			      
			      // Terminate bits [8,9, 18, 19, 28, 29, 38, 39, 48, 49, 58, 59, 68, 69, 78, 79] to 0
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 8) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 18) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 28) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 38) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 48) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 58) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 68) +: 2] = 0;
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + 78) +: 2] = 0;

			      // Rearrange rx_data
			      assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: 8] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+8) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+10) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+16) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+20) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+24) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+30) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+32) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+40) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+40) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+50) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+48) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+60) +: 8];
			      assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH+56) +: 8] = rx_dataout_to_pld[(ig*PLD_DATA_MAX_WIDTH+70) +: 8];	      

			      
			   end
		      end // else: !if(PLD_INTERFACE_WIDTH == 8 || PLD_INTERFACE_WIDTH == 10 || PLD_INTERFACE_WIDTH == 40 || PLD_INTERFACE_WIDTH == 80)
		 end // else: !if(INTERFACE_RECONFIG_ENABLE == 1)
	    end // case: "pma_direct"
	  
	  "10G" :
	    begin
	       if (PLD_INTERFACE_WIDTH <= PLD_DATA_MAX_WIDTH)
		 begin
		    if (INTERFACE_RECONFIG_ENABLE == 1)
		      begin
			 assign tx_datain_from_pld[ig*64+: 64] = tx_parallel_user_data[ig*64 +: 64];
			 assign rx_parallel_user_data[ig*64 +: 64] = rx_dataout_to_pld[ig*64 +: 64];
		      end
		    else
		      begin
			 // rearrange tx_data
			 assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_INTERFACE_WIDTH] = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH];
			 // Terminate rest of the bits to 0
			 if (PLD_INTERFACE_WIDTH != PLD_DATA_MAX_WIDTH)
			   begin
			      assign tx_datain_from_pld[(ig*PLD_DATA_MAX_WIDTH + PLD_INTERFACE_WIDTH) +: (PLD_DATA_MAX_WIDTH - PLD_INTERFACE_WIDTH)] = 0;
			   end
			 // Rearrange rx_data
			 assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH] = rx_dataout_to_pld[ig*PLD_INTERFACE_WIDTH +: PLD_INTERFACE_WIDTH];
		      end // else: !if(INTERFACE_RECONFIG_ENABLE == 1)
		 end // if (PLD_INTERFACE_WIDTH <= pld_max_data_width)
	       /*
	       else if (PLD_INTERFACE_WIDTH == 66)
		 begin
		    assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH]
			     = tx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_DATA_MAX_WIDTH];
		    assign tx_control_from_pld[ig*TX_CONTROL_MAX_WIDTH +: LCL_PLD_CONTROL_USED_WIDTH]
			     = tx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH + PLD_DATA_MAX_WIDTH) +: LCL_PLD_CONTROL_USED_WIDTH];
		    assign tx_control_from_pld[(ig*TX_CONTROL_MAX_WIDTH + LCL_PLD_CONTROL_USED_WIDTH) +: (TX_CONTROL_MAX_WIDTH - LCL_PLD_CONTROL_USED_WIDTH)] = 0; //padding
		    
		    assign rx_parallel_user_data[ig*PLD_INTERFACE_WIDTH +: PLD_DATA_MAX_WIDTH]
			     = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
		    assign rx_parallel_user_data[(ig*PLD_INTERFACE_WIDTH + PLD_DATA_MAX_WIDTH) +: LCL_PLD_CONTROL_USED_WIDTH]
			     = rx_control_to_pld[ig*RX_CONTROL_MAX_WIDTH +: LCL_PLD_CONTROL_USED_WIDTH];			     
		    
		 end // if (PLD_INTERFACE_WIDTH == 66)
		*/
	    end // case: "10G"

	  "8G":
	    begin
	       assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH+: PLD_DATA_MAX_WIDTH] = tx_parallel_user_data[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
	       assign rx_parallel_user_data[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
	    end
	  
	  default:
	    begin
	       assign tx_datain_from_pld[ig*PLD_DATA_MAX_WIDTH+: PLD_DATA_MAX_WIDTH] = tx_parallel_user_data[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
	       assign rx_parallel_user_data[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH] = rx_dataout_to_pld[ig*PLD_DATA_MAX_WIDTH +: PLD_DATA_MAX_WIDTH];
	    end	    
	    
	endcase // case (DATA_PATH_SELECT)
      end // block: channel
   end // block: data_mapper      
   endgenerate

endmodule // sv_xcvr_data_mapper

   
   
   
   
      

	       
      
