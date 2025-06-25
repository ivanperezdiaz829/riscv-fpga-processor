//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: pull_up

//  FUNCTIONAL DESCRIPTION:
// This file provides a weak pullup on the PCI signals.                 

//  REVISION HISTORY:  
//  Revision 1.1 Description: No change.
//  Revision 1.0 Description: Initial Release.
//
//  Copyright (C) 1991-2004 Altera Corporation, All rights reserved.  
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

module pull_up (ad, 
                cben, 
                par, 
                par64, 
                framen, 
                irdyn, 
                ack64n, 
                devseln, 
                trdyn, 
                stopn, 
                req64n, 
                perrn, 
                serrn, 
                intan);

   output [63:0] ad; 
   tri1 [63:0]ad;
   
   output[7:0] cben; 
   tri1 [7:0]cben;
   
   output par; 
   tri1 par;
   
   output par64; 
   tri1 par64;
   
   output framen; 
   tri1 framen;
   output irdyn; 
   tri1 irdyn;
   output ack64n; 
   tri1 ack64n;
   output devseln; 
   tri1 devseln;
   output trdyn; 
   tri1 trdyn;
   output stopn; 
   tri1 stopn;
   output req64n; 
   tri1 req64n;
   output perrn; 
   tri1 perrn;
   output serrn; 
   tri1 serrn;
   output intan; 
   tri1 intan;

   
  
    bufif1(ad[63],ad[63],1'b0);
    bufif1(ad[62],ad[62],1'b0);
    bufif1(ad[61],ad[61],1'b0);
    bufif1(ad[60],ad[60],1'b0);
    bufif1(ad[59],ad[59],1'b0);
    bufif1(ad[58],ad[58],1'b0);
    bufif1(ad[57],ad[57],1'b0);
    bufif1(ad[56],ad[56],1'b0);
    bufif1(ad[55],ad[55],1'b0);
    bufif1(ad[54],ad[54],1'b0);
    bufif1(ad[53],ad[53],1'b0);
    bufif1(ad[52],ad[52],1'b0);
    bufif1(ad[51],ad[51],1'b0);
    bufif1(ad[50],ad[50],1'b0);
    bufif1(ad[49],ad[49],1'b0);
    bufif1(ad[48],ad[48],1'b0);
    bufif1(ad[47],ad[47],1'b0);
    bufif1(ad[46],ad[46],1'b0);
    bufif1(ad[45],ad[45],1'b0);
    bufif1(ad[44],ad[44],1'b0);
    bufif1(ad[43],ad[43],1'b0);
    bufif1(ad[42],ad[42],1'b0);
    bufif1(ad[41],ad[41],1'b0);
    bufif1(ad[40],ad[40],1'b0);
    bufif1(ad[39],ad[39],1'b0);
    bufif1(ad[38],ad[38],1'b0);
    bufif1(ad[37],ad[37],1'b0);
    bufif1(ad[36],ad[36],1'b0);
    bufif1(ad[35],ad[35],1'b0);
    bufif1(ad[34],ad[34],1'b0);
    bufif1(ad[33],ad[33],1'b0);
    bufif1(ad[32],ad[32],1'b0);
    bufif1(ad[31],ad[31],1'b0);
    bufif1(ad[30],ad[30],1'b0);
    bufif1(ad[29],ad[29],1'b0);
    bufif1(ad[28],ad[28],1'b0);
    bufif1(ad[27],ad[27],1'b0);
    bufif1(ad[26],ad[26],1'b0);
    bufif1(ad[25],ad[25],1'b0);
    bufif1(ad[24],ad[24],1'b0);
    bufif1(ad[23],ad[23],1'b0);
    bufif1(ad[22],ad[22],1'b0);
    bufif1(ad[21],ad[21],1'b0);
    bufif1(ad[20],ad[20],1'b0);
    bufif1(ad[19],ad[19],1'b0);
    bufif1(ad[18],ad[18],1'b0);
    bufif1(ad[17],ad[17],1'b0);
    bufif1(ad[16],ad[16],1'b0);
    bufif1(ad[15],ad[15],1'b0);
    bufif1(ad[14],ad[14],1'b0);
    bufif1(ad[13],ad[13],1'b0);
    bufif1(ad[12],ad[12],1'b0);
    bufif1(ad[11],ad[11],1'b0);
    bufif1(ad[10],ad[10],1'b0);
    bufif1(ad[9],ad[9],1'b0);
    bufif1(ad[8],ad[8],1'b0);
    bufif1(ad[7],ad[7],1'b0);
    bufif1(ad[6],ad[6],1'b0);
    bufif1(ad[5],ad[5],1'b0);
    bufif1(ad[4],ad[4],1'b0);
    bufif1(ad[3],ad[3],1'b0);
    bufif1(ad[2],ad[2],1'b0);
    bufif1(ad[1],ad[1],1'b0);
    bufif1(ad[0],ad[0],1'b0);


    bufif1(cben[7],cben[7],1'b0);
    bufif1(cben[6],cben[6],1'b0);
    bufif1(cben[5],cben[5],1'b0);
    bufif1(cben[4],cben[4],1'b0);
    bufif1(cben[3],cben[3],1'b0);
    bufif1(cben[2],cben[2],1'b0);
    bufif1(cben[1],cben[1],1'b0);
    bufif1(cben[0],cben[0],1'b0);    

    bufif1(par,par,1'b0);
    bufif1(par64,par64,1'b0);
    
    bufif1(framen,framen,1'b0);
    bufif1(irdyn,irdyn,1'b0);
    bufif1(trdyn,trdyn,1'b0);
    bufif1(ack64n,ack64n,1'b0);
    bufif1(devseln,devseln,1'b0);
    bufif1(stopn,stopn,1'b0);
    bufif1(req64n,req64n,1'b0);
    bufif1(perrn,perrn,1'b0);
    bufif1(serrn,serrn,1'b0);
    bufif1(intan,intan,1'b0);
    
    
endmodule
