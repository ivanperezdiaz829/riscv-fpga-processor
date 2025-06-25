//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: monitor

//  FUNCTIONAL DESCRIPTION:
//  This file monitors the signals on the PCI bus and prints appropriate messages to the screen        
//  It also logs the transactions in log.txt file.                                                     
//  You can modify the bus monitor to include additional PCI protocol checks                           
//  as needed by your application.                                                                     

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
//  This reference design file is being provided on an �as-is� basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------


`timescale 1 ns / 1 ns

module monitor (clk, 
               rstn, 
               ad, 
               cben, 
               framen, 
               irdyn, 
               devseln, 
               trdyn, 
               stopn,
               intan,
               busfree,              //This signal indicates that the bus is free                               
               disengage_mstr,       //This signal indicates that there was abnormal termination by the target  
               tranx_success);       //This signal indicates that the transaction was successful.               


   input clk; 
   input rstn; 
   input[31:0] ad; 
   input[3:0] cben; 
   input framen; 
   input irdyn; 
   input devseln; 
   input trdyn; 
   input stopn;
   input intan;
   output busfree; 
   wire busfree;
   output disengage_mstr; 
   reg disengage_mstr;
   output tranx_success; 
   reg tranx_success;

   reg tranx_active;               // Indicates that the transaction is active                                 
   reg busfree_ind;                // Indicates that the bus is free                                           
   integer devsel_cnt;             // Keeps check of how many clocks devsel was high when tranx is active.     
   integer trdyn_cnt;              // Keeps check of how many clocks trdyn was high when tranx is active.      
   reg trdyn_asserted;             // This signal is used to decide the type of target termination.            
   reg[31:0] addr;                 // Latches the address at the begining of the transaction                   
   reg[3:0] cben_reg;              // Latches the command at the begining of the transaction                   
   reg intan_reg;                                
                                                                                                               
   
   parameter header = "Time             Address                Data"; 
   integer check; 
   integer filehandle;

integer filecompleted;

   initial
   begin
      filehandle = $fopen("log.txt");
      filecompleted = 0;
   end

   always @(posedge rstn)
   begin
      if (filecompleted)
      begin
        $fclose(filehandle);
      end
      else
      begin
         filecompleted = 1;
      end
   end

   //*********************************************************
   //Busfree Indicator
   //*********************************************************
   always @(framen or irdyn or devseln or trdyn or stopn)
   begin
      if (framen & irdyn & trdyn & devseln & stopn)
      begin
         busfree_ind <= 1'b1 ; 
      end
      else
      begin
         busfree_ind <= 1'b0 ; 
      end 
   end 
   assign busfree = busfree_ind ; 

   
   //*********************************************************
   //Transaction Active Signal
   //*********************************************************
   
   always @(posedge clk or framen or busfree_ind or rstn)
   begin
      if ((!rstn) | busfree_ind)
      begin
         tranx_active <= 1'b0 ; 
      end
      else if (clk)
      begin
         if (!framen)
         begin
            tranx_active <= 1'b1 ; 
         end 
      end 
   end 

   
   //*********************************************************
   //This process stores the assertion of trdyn, this signal is
   //used to determine the type of target termination
   //********************************************************* 
    
   always @(posedge clk or rstn or busfree_ind or trdyn)
   begin
      if ((!rstn) | busfree_ind)
      begin
         trdyn_asserted <= 1'b0 ; 
      end
      else if (clk)
      begin
         if (!trdyn)
         begin
            trdyn_asserted <= 1'b1 ; 
         end 
      end 
   end 

   //*********************************************************
   //Count for devseln and trdyn. 
   //********************************************************* 
   
   always @(rstn or posedge clk)// or devseln or trdyn or stopn or tranx_active)
   begin : count
      if (!rstn | busfree_ind)
      begin
         devsel_cnt <= 0 ; 
         trdyn_cnt <= 0 ; 
      end
      else if (clk & tranx_active)
      begin
         if (devseln  & devsel_cnt < 5)
         begin
            devsel_cnt <= devsel_cnt + 1 ; 
         end 
         
         if (trdyn == 0)
         begin
         	trdyn_cnt <= 4'h7;
         end 
         else if (trdyn  & stopn  & (trdyn_cnt < 15 & devsel_cnt < 5))
         begin
            trdyn_cnt <= trdyn_cnt + 1 ; 
         end 
      end 
   end 
   //*********************************************************
   //Latch the start address of the transaction and increment 
   //the address if there is a successful data transfer
   //*********************************************************
   
    //always @(posedge clk or framen or rstn or busfree_ind or posedge irdyn or posedge trdyn  or tranx_active)
    //always @(posedge clk or rstn or busfree_ind or posedge irdyn or posedge trdyn  or tranx_active)
   always @(posedge clk or busfree_ind or rstn )
   begin
      if ((!rstn) | busfree_ind)
      begin
         addr <= {32{1'b0}} ; 
         cben_reg <= {4{1'b0}} ; 
      end
      else if (clk)
      begin
         if (!busfree_ind & !tranx_active & !framen)
         begin
            addr <= ad[31:0] ; 
            cben_reg <= cben[3:0] ; 
         end
         else if (!irdyn & !trdyn)
         begin
               addr <= addr + 32'h00000004 ; 
            
         end 
      end 
   end 

// Interrupt detector
always @ (posedge clk or negedge rstn)
   begin
      if (intan)
         intan_reg <= 1'b1;
      else 
         intan_reg <= 1'b0;
   end     

assign intan_detected = ((intan & !intan_reg)&rstn) ? 1'b1 : 1'b0;   
   
   always @( intan_detected )
                                               if (intan_detected)
                                                 begin
                                                    print_arg("-----> Interrupt Detected");
                                                 end

  
//********************************************************  
   always @( clk or rstn or busfree_ind or posedge irdyn )
//****************************************************   
   begin : xhdl_15
      reg[31:0] address_inc; 
      if ((!rstn) | busfree_ind)
      begin
         tranx_success <= 1'b0 ; 
         disengage_mstr <= 1'b0 ; 
      end
      else if (tranx_active & devsel_cnt <= 5)
      begin
    if (!stopn)
    begin



                                         
                                         
                                         //************************************************************
                                                     if (trdyn &  !devseln & !trdyn_asserted)
                                         //************************************************************
                                                     begin
                                                     
                                                        disengage_mstr <= 1'b1 ; 
                                                while (!devseln)
                                                begin               
                                                    @(posedge clk);                              
                                                    #1;
                                                           if (devseln)
                                                           begin
                                                              print_arg("Target terminated with a retry"); 
                                                           end 
                                         
                                                 end//while               
                                                     end//********
                                         //************************************************************
                                                     else if (!trdyn & !devseln)
                                         //************************************************************
                                                     begin
                                                        disengage_mstr <= 1'b1 ; 
                                                        
                                                        
                                                        
                                                          if (!irdyn & !trdyn)
                                                          begin
                                                             if (clk)
                                                             begin
                                                                
                                                                   print_sig_val_32(addr, ad[31:0]); 
                                                                
                                                             end//clk 
                                                          end//if 
                                                 while (!irdyn) 
                                                 begin
                                                            if (!irdyn & !trdyn)
                                                            begin
                                                               if (clk)
                                                               begin
                                                                     print_sig_val_32(addr, ad[31:0]); 
                                                                end//clk 
                                                            
                                                            end  //irdyn trdyn
                                                         
                                                           if (framen & !trdyn  & !devseln)
                                                            begin
                                                               print_arg("Target terminated with disconnect-a "); 
                                                            end
                                                            else if  (framen & trdyn  & !devseln)
                                                                begin
                                                               print_arg("Target terminated with disconnect-b "); 
                                                            end
                                                            

                                                     @(posedge clk);                              
                                                         end//while
                                                     end //end *******
                                         //************************************************************
                                                     else if (trdyn & !devseln & trdyn_asserted)
                                         //************************************************************
                                                     begin
                                                        disengage_mstr <= 1'b1 ; 
                                                 while (!irdyn) 
                                                 begin
                                                            if (!irdyn & !trdyn)
                                                            begin
                                                               if (clk)
                                                               begin
                                                                   print_sig_val_32(addr, ad[31:0]); 
                                                              
                                                                end //clk
                                                           end //irdyn trdyn
                                                     @(posedge clk);                              
                                         
                                                            if (framen &  trdyn &  !devseln)
                                                            begin
                                                               print_arg("Target terminated with disconnect-b "); 
                                                            end 
                                         
                                                 end //end while
                                                     end  //*************************
                                                     
                                                     //************************************************************
                                                     else if (trdyn & !stopn & devseln)
                                                     //************************************************************
                                                     begin
                                                        disengage_mstr <= 1'b1 ; 
                                                 while (!irdyn) 
                                                 begin
                                         
                                                            if (!irdyn & !trdyn)
                                                            begin
                                                               if (clk)
                                                               begin
                                                                  
                                                                     print_sig_val_32(addr, ad[31:0]); 
                                                                  
                                                               end //clk
                                                           end 
                                                     @(posedge clk);                                             
                                         
                                                            if (framen & trdyn & !stopn & devseln)
                                                            begin
                                                                   print_arg("Target abort detected"); 
                                                            end  
                                                 end  //while
                                            end //*************                  


    
    end// (!stopn)
    else  //stopn = 1
    
    begin      


                                                 if (trdyn_cnt < 15 & devsel_cnt != 5)
                                                  begin
                                             
                                                                              if (!irdyn & !trdyn & !devseln & stopn)
                                                                              begin
                                                                                 tranx_success <= 1'b1 ; 
                                                                                 if (clk)
                                                                                 begin
                                                                                       print_sig_val_32(addr, ad[31:0]);
                                                                                  end 
                                                                              end
                                                                              else if (irdyn | trdyn)
                                                                              begin
                                                                                 tranx_success <= 1'b0 ; 
                                                                              end 
                                                 end
                                                 else if (trdyn_cnt == 15 & devsel_cnt != 5)
                                                 begin

                                                                                    disengage_mstr <= 1'b1 ; 
                                                                                while (!irdyn) 
                                                                                 begin
                                                                                @(posedge clk);
                                                                                #1;                                             
                                                                                          if (irdyn)
                                                                                          begin
                                                                                             print_arg("Target is not responding"); 
                                                                                          end 
                                                                                       end            
                                                 end 
                                              
                                              else if (devsel_cnt == 5)
                                                  begin
 
                                                     disengage_mstr <= 1'b1 ; 
                                                      while (!irdyn) 
                                                  begin
                                                  @(posedge clk);
                                                  #1;                                             
                                                          if (irdyn)
                                                           begin
                                                             print_arg("Master abort"); 
                                                           end
                                                     end
                                              end
                                             
         end //!stopn     
      end //< 5
   
   
   
   
   
   
   end 

  always @(posedge clk)
   begin
      if (trdyn_cnt == 1)
      begin
         if (cben_reg == 4'b1011)
         begin
            print(" "); 
            print("performing configuration write"); 
            print("************************************************"); 
            print(header); 
         end
         else if (cben_reg == 4'b1010)
         begin
            print(" "); 
            print("performing configuration read"); 
            print("************************************************"); 
            print(header); 
         end
         else if (cben_reg == 4'h7 | cben_reg == 4'hf)
         begin
            if (!framen)
            begin
               print(" "); 
               print("performing 32 bit burst memory write"); 
               print("********************************************************"); 
               print(header); 
            end
            else if (framen)
            begin
               print(" "); 
               print("performing 32 bit single cycle memory write"); 
               print("***************************************************************"); 
               print(header); 
            end 
         end
         else if (cben_reg == 4'h6 | cben_reg == 4'hc | cben_reg == 4'he)
         begin
            if (!framen)
            begin
               print(" "); 
               print("performing 32 bit burst memory read"); 
               print("********************************************************"); 
               print(header); 
            end
            else if (framen)
            begin
               print(" "); 
               print("performing 32 bit single cycle memory read"); 
               print("***************************************************************"); 
               print(header); 
            end 
         end
         else if (cben_reg == 4'b0011)
         begin
            print(" "); 
            print("performing io write"); 
            print("*************************************"); 
            print(header); 
         end
         else if (cben_reg == 4'b0010)
         begin
            print(" "); 
            print("performing io read"); 
            print("**************************************"); 
            print(header); 
         end       
         end 
   end 



   
   
   

task print;
      input [400:0]s; 
     
      begin
         $display(            "              %s",s);
         $fdisplay(filehandle,"              %s",s);
      end
   endtask

 


task print_arg;
      input [287:0] arg; 
      begin
         $display(             "%d ns %s",$time,arg);
         $fdisplay(filehandle, "%d ns %s",$time,arg);
      end
   endtask

task print_sig_val_32;
      input [31:0]address; 
      input [31:0] data; 
      begin
         $display(            "%d ns          %h        %h",$time,address,data);
         $fdisplay(filehandle,"    %d ns          %h            %h",$time,address,data);
      end
   endtask

  
endmodule
