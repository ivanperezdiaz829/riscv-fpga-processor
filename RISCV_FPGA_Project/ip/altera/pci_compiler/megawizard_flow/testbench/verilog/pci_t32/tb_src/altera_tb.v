//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: altera_tb

//  FUNCTIONAL DESCRIPTION:
//  This is the top level file of Altera PCI testbench

//---------------------------------------------------------------------------------------


`timescale 1 ns / 1 ns

module altera_tb ();

   wire clk; 
   wire rstn; 
   wire[31:0] ad; 
   wire[3:0] cben; 
   wire framen; 
   wire irdyn; 
   wire devseln; 
   wire trdyn; 
   wire stopn; 
   wire[31:0] l_adi; 
   wire[31:0] l_dato; 
   wire[31:0] l_adro; 
   wire[3:0] l_beno; 
   wire[3:0] l_cmdo; 
   wire lt_abortn; 
   wire lt_discn; 
   wire lt_rdyn; 
   wire lt_framen; 
   wire lt_ackn; 
   wire lt_dxfrn; 
   wire[11:0] lt_tsr; 
   wire l_irqn; 
   
   wire[6:0] cmd_reg; 
   wire[6:0] stat_reg; 
   wire perrn; 
   wire serrn; 
   wire intan; 
   wire par; 
   wire busfree; 
   wire disengage_mstr; 
   wire tranx_success; 
   wire trgt_tranx_disca; 
   wire trgt_tranx_discb; 
   wire trgt_tranx_retry; 

   wire mstr_tranx_gntn; 
   wire mstr_tranx_reqn; 
   wire gntn;
   wire [1:0] gntns;
   wire [1:0] reqns;

assign  {mstr_tranx_gntn,gntn} = gntns;
assign reqns = {mstr_tranx_reqn, 1'b1};


   
   clk_gen u0 (.pciclk(clk)); 
   
   pci_top u1 (.clk(clk),
               .rstn(rstn),
               .idsel(ad[28]),
               .ad(ad[31:0]),
               .cben(cben[3:0]),
               .par(par),
               .framen(framen),
               .irdyn(irdyn),
               .devseln(devseln),
               .trdyn(trdyn),
               .stopn(stopn),
               .perrn(perrn),
               .serrn(serrn),
               .intan(intan),
               .l_adi(l_adi),
               .l_dato(l_dato),
               .l_adro(l_adro),
               .l_beno(l_beno),
               .l_cmdo(l_cmdo),
               .lt_abortn(lt_abortn),
               .lt_discn(lt_discn),
               .lt_rdyn(lt_rdyn),
               .lt_framen(lt_framen),
               .lt_ackn(lt_ackn),
               .lt_dxfrn(lt_dxfrn),
               .lt_tsr(lt_tsr),
               .lirqn(l_irqn),
               
               .cmd_reg(cmd_reg),
               .stat_reg(stat_reg)); 
   
  top_local u2 (
                 //****************************************************
                 // Replace this section with your application design
                 //****************************************************
                 //.Clk(clk), 
                 //.Rstn(rstn), 
                 //.Pcil_adi_o(l_adi), 
                 //.Pcil_dat_i(l_dato), 
                 //.Pcil_adr_i(l_adro), 
                 //.Pcil_ben_i(l_beno), 
                 //.Pcil_cmd_i(l_cmdo),                  
                 //.Pcilt_abort_n_o(lt_abortn), 
                 //.Pcilt_disc_n_o(lt_discn), 
                 //.Pcilt_rdy_n_o(lt_rdyn), 
                 //.Pcilt_frame_n_i(lt_framen), 
                 //.Pcilt_ack_n_i(lt_ackn), 
                 //.Pcilt_dxfr_n_i(lt_dxfrn), 
                 //.Pcilt_tsr_i(lt_tsr), 
                 //.Pcilirq_n_o(l_irqn)
                 ); 
                 
                 
   arbiter u3 (.clk(clk),
               .rstn(rstn),
               .busfree(busfree),
               .pci_reqn(reqns),
               .pci_gntn(gntns)); 
   
   mstr_tranx u4 (.clk(clk),
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
   
   trgt_tranx u5 (.clk(clk),
                  .rstn(rstn),
                  .ad(ad),
                  .cben(cben),
                  .idsel(ad[29]),
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
   
   monitor u6 (.clk(clk),
               .rstn(rstn),
               .ad(ad),
               .cben(cben),
               .framen(framen),
               .irdyn(irdyn),
               .devseln(devseln),
               .trdyn(trdyn),
               .stopn(stopn),
               .busfree(busfree),
               .disengage_mstr(disengage_mstr),
               .tranx_success(tranx_success)); 
   
   pull_up u7 (.ad(ad),
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
endmodule
