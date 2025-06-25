//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: altera_tb

//  FUNCTIONAL DESCRIPTION:
//  This is the top level file of Altera PCI testbench

//---------------------------------------------------------------------------------------

`timescale 1 ns / 1 ns

module pci_tb (
	
	clk,	
	rstn,
	
	reqn,
	gntn,	
	
	intan,
	ad,
	idsel,
	cben,
	framen,
	irdyn,
	devseln,
	trdyn,
	stopn,
	perrn,
	par,
	serrn,	
	clk_pci_compiler	
	); 

 
 	input		clk;
	output		rstn;
	
	input		reqn;
	output		gntn;
	output		idsel;
		
	inout		intan;	
	inout	[31:0]	ad;	
	inout	[3:0]	cben;	
	inout		framen;	
	inout		irdyn;	
	inout		devseln;	
	inout		trdyn;	
	inout		stopn;	
	inout		perrn;	
	inout		par;	
	inout		serrn;

	output		clk_pci_compiler;
   
   
   	wire mstr_tranx_reqn; 
   	wire mstr_tranx_gntn; 
   
   
   	wire busfree; 
   	wire disengage_mstr; 
   	wire tranx_success; 
   	wire trgt_tranx_disca; 
   	wire trgt_tranx_discb; 
   	wire trgt_tranx_retry; 
   
   	wire [1:0] gntns;
   	wire [1:0] reqns;
        reg   rstn;

	assign  {mstr_tranx_gntn,gntn} = gntns;
	assign reqns = {mstr_tranx_reqn, reqn};
assign 	       idsel = ad[11];

initial 
    begin
      rstn <= 0;
      #200 rstn <= 1;
    end


   arbiter u1 (.clk(clk),
               .rstn(rstn),
               .busfree(busfree),
               .pci_reqn(reqns),
               .pci_gntn(gntns)); 
   
   defparam u1.park = 1'b0;


   
   mstr_tranx u2 (.clk(clk),
                  .rstn(rstn),
                  .ad(ad),
                  .cben(cben),
                  .par(par),
                  .reqn(mstr_tranx_reqn),
                  .gntn(mstr_tranx_gntn),
                  .framen(framen),
                  .irdyn(irdyn),
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


   trgt_tranx u3 (.clk(clk),
                  .rstn(rstn),
                  .ad(ad),
                  .cben(cben),
                  .idsel(ad[12]),
                  .par(par),
                  .framen(framen),
                  .irdyn(irdyn),
                  .devseln(devseln),
                  .stopn(stopn),
                  .trdyn(trdyn),
                  .perrn(perrn),
                  .serrn(serrn),
                  .trgt_tranx_disca(trgt_tranx_disca),
                  .trgt_tranx_discb(trgt_tranx_discb),
                  .trgt_tranx_retry(trgt_tranx_retry)); 
   
       defparam
		u3.address_lines = 1024,
		u3.mem_hit_range = 32'h00010000,
		u3.io_hit_range = 32'h0000000F;

   monitor u4 (.clk(clk),
               .rstn(rstn),
               .ad(ad),
               .cben(cben),
               .framen(framen),
               .irdyn(irdyn),
               .devseln(devseln),
               .trdyn(trdyn),
               .stopn(stopn),
               .intan(intan),
               .busfree(busfree),
               .disengage_mstr(disengage_mstr),
               .tranx_success(tranx_success)); 
   
   pull_up u5 (.ad(ad),
               .cben(cben),
               .par(par),
               .framen(framen),
               .irdyn(irdyn),
               .devseln(devseln),
               .trdyn(trdyn),
               .stopn(stopn),
               .perrn(perrn),
               .serrn(serrn),
               .intan(intan)); 

  clk_gen u6 (.pciclk(clk_pci_compiler));

endmodule
