//--------------------------------------------------------------------------------------------------
// (c)2003 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an ?as-is? basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: sdi_ancgen.v,v $
// Last modified : $Date: 2008/04/15 16:42:04 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//
// Track ancillary data packets. The DID, SDID/DBN, DC and UDW words are output and the checksum
// is checked.
//
//--------------------------------------------------------------------------------------------------

module sdi_ancgen (
  clk,
  rst,
  //din,
  din_valid,

  dout_port,                   
  anc_data,
  anc_valid,
  anc_error,
  state_out
  );

input        clk;              // Clock
input        rst;              // Active high reset
//input  [9:0] din;              // Data input
input        din_valid;        // Data valid flag

output [9:0] dout_port;   
output [9:0] anc_data;         // ANC data output
output       anc_valid;        // Asserted to accompany DID, SDID/DBN, DC and UDW words on anc_data
output       anc_error;        // ANC packet format or checksum error
output [3:0] state_out;

reg [9:0] dout;   
reg [7:0] did;
reg [7:0] sdid_dbn;
reg [7:0] udw;
reg       anc_valid;
reg [9:0] anc_data;
reg       anc_error;
reg [8:0] cs;
reg [3:0] state;

        reg [9:0] did_in = 10'h079;
        reg [9:0] sdid_in = 10'h079;        
        reg [7:0] dc_in = 8'h00f;
        reg [7:0] dc_reg;
        reg [8:0] din = 9'h055;
        
parameter [3:0] IDLE         = 4'b0000;
parameter [3:0] ANC_DF_2     = 4'b0001;
parameter [3:0] ANC_DF_3     = 4'b0010;
parameter [3:0] ANC_DID      = 4'b0011;
parameter [3:0] ANC_SDID_DBN = 4'b0100;
parameter [3:0] ANC_DC       = 4'b0101;
parameter [3:0] ANC_UDW      = 4'b0110;
parameter [3:0] ANC_CS       = 4'b0111;
parameter [3:0] ANC_BLANK    = 4'b1000;   

   parameter [9:0] BLANK_VALUE = 10'h200;
   
   

always @ (posedge clk or posedge rst)
begin
  if (rst) begin
    state <= IDLE;
    anc_valid <= 1'b0;
    anc_error <= 1'b0;
  end
  else begin

    anc_valid <= 1'b0;
    anc_data <= din;
    anc_error <= 1'b0;

    case (state)
      IDLE     : //if (din==10'h000) 
                  begin
                  dout <= 10'h000;
                  state <= ANC_DF_2;
                   cs <= 9'b0;
                 end

      ANC_DF_2 : //if (din==10'h3FF)
                 begin
                  dout <= 10'h3FF;
                  state <= ANC_DF_3;
                 //else
                 //state <= IDLE;
                 end

      ANC_DF_3 : //if (din==10'h3FF)
                 begin
                  dout <= 10'h3FF;
                  state <= ANC_DID;
                 //else
                 //  state <= IDLE;
                 end
      

      ANC_DID  : begin //data identifier
                   //did <= din[7:0];
                   // set did to be
                   dout[7:0] <= did_in; // make less than 80h
                   dout[8] <= (did_in[7]^did_in[6]^did_in[5]^did_in[4]^did_in[3]^did_in[2]^did_in[1]^did_in[0]);
                   dout[9] <= ~(did_in[7]^did_in[6]^did_in[5]^did_in[4]^did_in[3]^did_in[2]^did_in[1]^did_in[0]);
                   cs <= cs + {(did_in[7]^did_in[6]^did_in[5]^did_in[4]^did_in[3]^did_in[2]^did_in[1]^did_in[0]),did_in[7:0]};
                   state <= ANC_SDID_DBN;
         
                   //if (din[8]==(din[7]^din[6]^din[5]^din[4]^din[3]^din[2]^din[1]^din[0]) & din[9]==~din[8]) begin

                   //  anc_valid <= 1'b1;
                   //end
                   //else
                   //  state <= IDLE;
                 end

      ANC_SDID_DBN : begin //secondary data identifier or data block number
                   dout[7:0] <= sdid_in;
                   dout[8] <= (sdid_in[7]^sdid_in[6]^sdid_in[5]^sdid_in[4]^sdid_in[3]^sdid_in[2]^sdid_in[1]^sdid_in[0]);                 
                   dout[9] <= ~(sdid_in[7]^sdid_in[6]^sdid_in[5]^sdid_in[4]^sdid_in[3]^sdid_in[2]^sdid_in[1]^sdid_in[0]);
                   cs <= cs + {(sdid_in[7]^sdid_in[6]^sdid_in[5]^sdid_in[4]^sdid_in[3]^sdid_in[2]^sdid_in[1]^sdid_in[0]),sdid_in[7:0]};
                   state <= ANC_DC;
                   end

      ANC_DC   : begin //data count
                 dc_reg <= dc_in;
         
                 dout[7:0] <= dc_in;
                   dout[8] <= (dc_in[7]^dc_in[6]^dc_in[5]^dc_in[4]^dc_in[3]^dc_in[2]^dc_in[1]^dc_in[0]);
                   dout[9] <= ~(dc_in[7]^dc_in[6]^dc_in[5]^dc_in[4]^dc_in[3]^dc_in[2]^dc_in[1]^dc_in[0]);
                   cs <= cs + {(dc_in[7]^dc_in[6]^dc_in[5]^dc_in[4]^dc_in[3]^dc_in[2]^dc_in[1]^dc_in[0]),dc_in[7:0]};
                   state <= ANC_UDW;
                  
         
                 end // case: ANC_DC
      

      ANC_UDW  : begin  // user data words
                 dc_reg <= dc_reg-1;
                 cs <= cs + din[8:0];
                 dout <= din;
                 if (dc_reg==1) state <= ANC_CS;
                 end

      ANC_CS   : begin //checksum
                 dout[9] <= ~cs[8];
                 dout[8:0] <= cs[8:0];
                 state <= ANC_BLANK;
                 end

      ANC_BLANK   : begin //checksum
                 dout[9:0] <= BLANK_VALUE;
         
                 end
      

    endcase
  end
end

   assign dout_port = dout;
   assign state_out = state;
   
endmodule
