//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: arbiter
//  COMPANY:  Altera Coporation.
//            www.altera.com    

//  FUNCTIONAL DESCRIPTION:
//  This Arbiter gives high priority to device connected to port 0                  
//  You can park the bus on device 0 by modifying the park to be true               
//  in the top level file.                                                          
 
//  This is the top level file of Altera PCI testbench

//  REVISION HISTORY:  
//	Revision 4.1.0: Corrected several issues to prevent bus contention.
//					Cleaned up the unused ports.
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
//  This reference design file is being provided on an as-is basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------


`timescale 1 ns / 1 ns
 
module arbiter (clk, 
                rstn, 
                busfree, 
                pci_reqn, 
                pci_gntn);

   parameter park  = 1'b0;
   
   input clk; 
   input rstn; 
   input busfree; 
   input[1:0] pci_reqn; 
   output[1:0] pci_gntn; 
   wire[1:0] pci_gntn;

   parameter[0:0] park_disable = 0; 
   parameter[0:0] park_enable = 1; 
   reg[0:0] state; 
   reg[0:0] nxstate; 
   reg[1:0] pci_gntn_tie; 

   assign pci_gntn = pci_gntn_tie ; 

   //***************************
   //grant request for device 0
   always @(posedge clk or rstn)
   begin
   //*****************************
      if (!rstn)
      begin
         pci_gntn_tie[0] <= 1'b1 ; 
      end
      else
      begin
         if (state == park_enable | (!pci_reqn[0] & pci_gntn_tie[1]) ) 
         begin
            pci_gntn_tie[0] <= 1'b0 ; 
         end
         else
         begin
            pci_gntn_tie[0] <= 1'b1 ; 
         end 
      end 
   end 

   //****************************
   //grant request for device 1
   always @(posedge clk or rstn)
   begin
   //****************************
      if (!rstn)
      begin
         pci_gntn_tie[1] <= 1'b1 ; 
      end
      else
      begin
         if (pci_reqn[1] | !pci_reqn[0])
         begin
            pci_gntn_tie[1] <= 1'b1 ; 
         end
         else if ((pci_reqn[0]) & state == park_disable & pci_gntn_tie[0])
         begin
            pci_gntn_tie[1] <= 1'b0 ; 
         end 
      end 
   end 

   //****************************
   //Next state generator for park
   //*****************************
   always @(posedge clk or rstn)
   begin
      if (!rstn)
      begin
         state <= park_disable ; 
      end
      else
      begin
         state <= nxstate ; 
      end 
   end 

   //data unit for park
   always @(state or busfree or pci_reqn)
   begin
      case (state)
         park_disable :
                  begin
                     if (busfree & park & (pci_reqn[1]))
                     begin
                        nxstate <= park_enable ; 
                     end
                     else
                     begin
                        nxstate <= park_disable ; 
                     end 
                  end
         park_enable :
                  begin
                     if (!(pci_reqn[1]))
                     begin
                        nxstate <= park_disable ; 
                     end
                     else
                     begin
                        nxstate <= park_enable ; 
                     end 
                  end
         default :
                  begin
                     nxstate <= park_disable ; 
                  end
      endcase 
   end 
endmodule
