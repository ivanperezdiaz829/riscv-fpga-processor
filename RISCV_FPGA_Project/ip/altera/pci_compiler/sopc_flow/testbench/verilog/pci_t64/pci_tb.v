//-------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: altera_tb

//  FUNCTIONAL DESCRIPTION:
//  This is the top level file of Altera PCI testbench
//  REVISION HISTORY: 
//  Revision 1.1 Description: No change.
//  Revision 1.0 Description: Initial Release.
//
//  Copyright (C) 1991-2005 Altera Corporation, All rights reserved.
//  Altera products are protected under numerous U.S. and foreign patents, 
//  maskwork rights, copyrights and other intellectual property laws. 
//  This reference design file, and your use thereof, is subject to and 
//  governed by the terms and conditions of the applicable Altera Reference 
//  Design License Agreement (either as signed by you or found at www.altera.com).  
//  By using this reference design file, you indicate your acceptance of such terms 
//  and conditions between you and Altera Corporation.  In the event that you do
//  not agree with such terms and conditions, you may not use the reference design 
//  file and please promptly destroy any copies you have made. 
//  This reference design file is being provided on an "as-is" basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.

//---------------------------------------------------------------------------------------


`timescale 1 ns / 1 ns

module pci_tb (
	
	$$REPLACE_INPUT_CLOCK,	
	rstn,

        idsel,
	intan,
	ad,
	par64,
	cben,
	req64n,
	ack64n,
	framen,
	irdyn,
	devseln,
	trdyn,
	stopn,
	perrn,
	par,
	serrn,	
	$$REPLACE_OUTPUT_CLOCK
	); 

 
 	input		$$REPLACE_INPUT_CLOCK;
	output		rstn;

 	output		idsel;
	inout		intan;	
	inout	[63:0]	ad;	
	inout		par64;	
	inout	[7:0]	cben;	
	inout		req64n;	
	inout		ack64n;	
	inout		framen;	
	inout		irdyn;	
	inout		devseln;	
	inout		trdyn;	
	inout		stopn;	
	inout		perrn;	
	inout		par;	
	inout		serrn;
	
	output		$$REPLACE_OUTPUT_CLOCK;   
   
   	wire mstr_tranx_reqn; 
   	wire mstr_tranx_gntn; 
   
   
   
   	wire busfree; 
   	wire disengage_mstr; 
   	wire tranx_success; 
   	wire trgt_tranx_disca; 
   	wire trgt_tranx_discb; 
   	wire trgt_tranx_retry; 
        reg   rstn;   
   	wire [1:0] gntns;
   	wire [1:0] reqns;


   assign  {mstr_tranx_gntn,gntn} = gntns;
   assign reqns = {mstr_tranx_reqn, 1'b1};
assign 	  idsel = ad[11];

initial 
    begin
      rstn <= 0;
      #200 rstn <= 1;
    end

   arbiter u1 (.clk($$REPLACE_INPUT_CLOCK), 
               .rstn(rstn), 
               .busfree(busfree), 
               .pci_reqn(reqns), 
               .pci_gntn(gntns)); 
  
  
   
   mstr_tranx u2 (.clk($$REPLACE_INPUT_CLOCK), 
                  .rstn(rstn), 
                  .ad(ad), 
                  .cben(cben), 
                  .par(par), 
                  .par64(par64), 
                  .reqn(mstr_tranx_reqn), 
                  .gntn(mstr_tranx_gntn), 
                  .req64n(req64n), 
                  .framen(framen), 
                  .irdyn(irdyn), 
                  .ack64n(ack64n), 
                  .devseln(devseln), 
                  .trdyn(trdyn), 
                  .stopn(stopn), 
                  .perrn(perrn), 
                  .serrn(serrn), 
                  .busfree(busfree), 
                  .disengage_mstr(disengage_mstr), 
                  .tranx_success(tranx_success), 
                  .trgt_tranx_disca(trgt_tranx_disca), 
                  .trgt_tranx_discb(trgt_tranx_discb), 
                  .trgt_tranx_retry(trgt_tranx_retry)); 
                  
          defparam        
                 u2.trgt_tranx_bar0_data    =  32'h00000000,
                 u2.trgt_tranx_bar1_data    =  32'hfffff2C0; 
                  

   monitor u4 (.clk($$REPLACE_INPUT_CLOCK), 
               .rstn(rstn), 
               .ad(ad), 
               .cben(cben), 
               .req64n(req64n), 
               .framen(framen), 
               .irdyn(irdyn), 
               .ack64n(ack64n), 
               .devseln(devseln), 
               .trdyn(trdyn), 
               .stopn(stopn), 
               .busfree(busfree), 
               .disengage_mstr(disengage_mstr), 
               .tranx_success(tranx_success)); 
  
   pull_up u5 (.ad(ad), 
               .cben(cben), 
               .par(par), 
               .par64(par64), 
               .framen(framen), 
               .irdyn(irdyn), 
               .ack64n(ack64n), 
               .devseln(devseln), 
               .trdyn(trdyn), 
               .stopn(stopn), 
               .req64n(req64n), 
               .perrn(perrn), 
               .serrn(serrn), 
               .intan(intan));

  clk_gen u6 (.pciclk($$REPLACE_OUTPUT_CLOCK));
 
endmodule
