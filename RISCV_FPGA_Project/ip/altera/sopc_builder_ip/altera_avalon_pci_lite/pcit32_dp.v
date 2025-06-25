//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//     Logic Core:             PCI Megacore Function
//     Company:                Altera Corporation.
//                             www.altera.com
//     Author :                PNSE Group Madzani
//
//     Description:    PCI Core Data Path
//
//     Copyright 2007 Altera Corporation. All rights reserved.  This source code is highly
//     confidential and proprietary information of Altera and is being provided in accordance with
//     and subject to the protections of a Non-Disclosure Agreement which governs its use and
//     disclosure.  Altera products and services are protected under numerous U.S. and foreign
//    patents, maskwork rights, copyrights and other intellectual property laws.  Altera assumes
//     no responsibility or liability arising out of the application or use of this source code.
//
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

module pcit32_dp 
  #(
    parameter TARGET_ONLY = "NO"
    )

(
    Clk_in,
    Rstn_in,
    Irdy_in,
    Trdy_in,
    Ad_ce_nc,
    Ad_out,
    Ad_or,
    Ad_or_fb
);

    input         Clk_in;
    input         Rstn_in;
    input         Irdy_in;
    input         Trdy_in;
    input         Ad_ce_nc;
    input  [31:0] Ad_out;
    output [31:0] Ad_or;
    output [31:0] Ad_or_fb;

    reg    [31:0] Ad_or;
    reg    [31:0] Ad_or_fb;
    
    wire    [31:0] Ad_d;
    wire    [31:0] Ad_d_fb;
    
    wire          pci_xfr_status;
    wire   [31:0] low_ad_lc1;
generate if (TARGET_ONLY == "NO")
begin
	assign pci_xfr_status = Trdy_in & Irdy_in;
end
else
begin
	assign pci_xfr_status = Irdy_in;
end
endgenerate
   
assign Ad_d =  (!Ad_ce_nc)?  Ad_or_fb : Ad_out; 

assign Ad_d_fb = Ad_d;
   
always @(posedge Clk_in or negedge Rstn_in)
    begin
    if (~Rstn_in)
       Ad_or <= 32'h0;
    else
       Ad_or <= Ad_d;
    end

always @(posedge Clk_in or negedge Rstn_in)
    begin
    if (~Rstn_in)
       Ad_or_fb <= 32'h0;
    else
       Ad_or_fb <= Ad_d_fb;

    end

endmodule
