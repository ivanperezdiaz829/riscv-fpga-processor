//------------------------------------------------------------------
//  Altera PCI testbench
//  MODULE NAME: mstr_pkg

//  FUNCTIONAL DESCRIPTION:
//  Master Package describes the tasks used by mstr_tranx

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
//  This reference design file is being provided on an 'as-is' basis and as an 
//  accommodation and therefore all warranties, representations or guarantees 
//  of any kind (whether express, implied or statutory) including, without limitation, 
//  warranties of merchantability, non-infringement, or fitness for a particular purpose, 
//  are specifically disclaimed.  By making this reference design file available, 
//  Altera expressly does not recommend, suggest or require that this reference design 
//  file be used in combination with any other product not provided by Altera.
//---------------------------------------------------------------------------------------

//*******************************************************************************
//TASKS
//*******************************************************************************

   //***************
   task idle_cycle;
   //***************
      input count; 
      integer count;

      integer idle_cycle_count; 

      begin
         
         idle_cycle_count = count;
         
         while (idle_cycle_count > 0)
         begin
            @(posedge clk); 
            idle_cycle_count = idle_cycle_count - 1; 
         end 
      end
   endtask



   //***********
   task cfg_wr;
   //***********
      input[31:0] address; 
      input[31:0] data; 
      input[3:0] byte_en; 

      begin
         
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out[63:32] <= {32{1'bz}} ; 
         cben_out[7:4] <= {4{1'bz}} ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b1011 ; 
         irdyn_out <= 1'b1 ; 
         par_en <= 1'b1 ; 
         
         //Data phase
         @(posedge clk); 
         #tdel; 
         framen_out <= 1'b1 ; 
         irdyn_out <= 1'b0 ; 
         cben_out[7:4] <= {4{1'b0}} ; 
         cben_out[3:0] <= byte_en ; 
         ad_out[31:0] <= data ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk);
           // #1; 
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         par_en <= 1'b0 ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
      end
   endtask

   //**********
   task cfg_rd;
   //**********
   
      input[31:0] address; 

      begin
         
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         irdyn_out <= 1'b1 ; 
         ad_out[63:32] <= {32{1'bz}} ; 
         cben_out[7:4] <= {4{1'bz}} ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b1010 ; 
         par_en <= 1'b1 ; 
         
         
         //Turnaround phase 
         @(posedge clk); 
         #tdel; 
         par_en <= 1'b0 ; 
         framen_out <= 1'b1 ; 
         irdyn_out <= 1'b0 ; 
         cben_out <= {8{1'b0}} ; 
         ad_out <= {64{1'bz}} ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         //Data Phase
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk);
            //#1; 
         end 
         irdyn_out <= 1'b1 ; 
         cben_out <= {8{1'bz}} ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
      end
   endtask


   //*************
   task mem_wr_64;
   //*************
      input[31:0] address; 
      input[63:0] data; 
      input qword; 
      integer qword;

      reg[31:0] data_inc_low; 
      reg[31:0] data_inc_high; 
      integer qword_cnt; 

      begin
        
         data_inc_low = data[31:0];
         data_inc_high = data[63:32];
         qword_cnt = qword;
        
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         req64n <= 1'b0 ; 
         irdyn_out <= 1'b1 ; 
         ad_out[63:32] <= {32{1'b0}} ; 
         cben_out[7:4] <= 4'b0000 ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0111 ; 
         par_en <= 1'b1 ; 
         par_en_64 <= 1'b1 ; 
         
         //Data phase
         @(posedge clk); 
         #tdel; 
         qword_cnt = qword_cnt - 1; 
         //deassert framen if it is not a burst transaction
         if (qword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
            req64n <= 1'b1 ; 
         end 
         ad_out <= data ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk);
            //#1; 
         end 
         
         //----------Burst transacton----------------------------------
         if (qword > 1 & !disengage_mstr)
         begin
            while (qword_cnt > 0 & !disengage_mstr)
            begin
               if (qword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
                  req64n <= 1'b1 ; 
               end 
               if (!irdyn & !trdyn)
               begin
                  qword_cnt = qword_cnt - 1; 
                  data_inc_low = data_inc_low + 32'h00000002; 
                  data_inc_high = data_inc_high + 32'h00000002; 
               end 
               ad_out[31:0] <= data_inc_low ; 
               ad_out[63:32] <= data_inc_high ; 
               
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         //------------------------------------------------------------
         
         if (!irdyn & !trdyn)
         begin
            data_inc_low = data_inc_low + 32'h00000002; 
            data_inc_high = data_inc_high + 32'h00000002; 
         end 
         
         ad_out[31:0] <= data_inc_low ; 
         ad_out[63:32] <= data_inc_high ; 
         
         if ((disengage_mstr & qword > 1 & !framen) | (!disengage_mstr & qword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            req64n <= 1'b1 ; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk);
               //#1; 
            end 
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

   //*************
   task mem_rd_64;
   //*************
      input[31:0] address; 
      input qword; 
      integer qword;

      integer qword_cnt; 

      begin
         
         qword_cnt = qword;
         
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free to start the transaction
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         req64n <= 1'b0 ; 
         ad_out[63:32] <= {32{1'b0}} ; 
         cben_out[7:4] <= 4'b0000 ; 
         
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0110 ; 
         par_en <= 1'b1 ; 
         par_en_64 <= 1'b1 ; 
         
         
         //Turnaround phase
         @(posedge clk); 
         #tdel; 
         qword_cnt = qword_cnt - 1; 
         if (qword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
         end 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         par_en <= 1'b0 ; 
         par_en_64 <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         //Data Phase
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk);
            //#1; 
         end 
         
         //---------Burst Transaction-------------------------
         if (qword > 1 & !disengage_mstr)
         begin
            while (qword_cnt > 0 & !disengage_mstr)
            begin
               if (qword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
               end 
               qword_cnt = qword_cnt - 1; 
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         
         //-------------------------------------------------------------
         
         if ((disengage_mstr & qword > 1 & !framen) | (!disengage_mstr & qword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            req64n <= 1'b1 ; 
            qword_cnt = qword_cnt - 1; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk); 
               //#1;
            end 
         end 
         irdyn_out <= 1'b1 ; 
         cben_out <= {8{1'bz}} ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

    
   //*************
   task mem_wr_dac;
   //*************
   input[63:0] address; 
      input[31:0] data; 
      input dword; 
      integer dword;

      reg[31:0] data_inc; 
      integer dword_cnt; 

      begin
        
        data_inc = data;
        dword_cnt = dword;
        
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out[63:0] <= address ; 
         cben_out[3:0] <= 4'b1101 ;
	 cben_out[7:4] <= 4'b0111; 
         par_en <= 1'b1 ; 
	 //req64n <= 1'b0;
         
	 @(posedge clk);
	 ad_out[31:0] <= address[63:32];
	 ad_out[63:32] <= address[63:32];
	 cben_out[3:0] <= 4'b0111;
	 cben_out[7:4] <= 4'b0111;

         //Data Phase
         @(posedge clk); 
         #tdel; 
         dword_cnt = dword_cnt - 1; 
         if (dword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
         end 
         ad_out <= data ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         
         //--------------Burst Transaction--------------
         
         if (dword > 1 & !disengage_mstr)
         begin
            while (dword_cnt > 0 & !disengage_mstr)
            begin
               if (dword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
               end 
               if (!irdyn & !trdyn)
               begin
                  dword_cnt = dword_cnt - 1; 
                  data_inc = data_inc + 32'h00000001; 
               end 
               ad_out[31:0] <= data_inc ; 
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         //--------------------------------------------------
         
         if (!irdyn & !trdyn)
         begin
            data_inc = data_inc + 32'h00000001; 
         end 
         ad_out[31:0] <= data_inc ; 
         if ((disengage_mstr & dword > 1 & !framen) | (!disengage_mstr & dword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk); 
               //#1;
            end 
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         par_en <= 1'b0 ;
	 //req64n <= 1'b1; 
        
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end

   endtask

   //*************
   task mem_rd_dac;
   //*************
   
      input[63:0] address; 
      input dword; 
      integer dword;

      integer dword_cnt; 

      begin
   
         dword_cnt = dword;
          
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free to start the transaction
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out <= address ; 
         cben_out[7:4] <= 4'b0110 ; 
	 cben_out[3:0] <= 4'b1101 ; 
         par_en <= 1'b1 ;
	 //req64n <= 1'b0 ;
         
	 @(posedge clk);
	 ad_out[31:0] <= address[63:32];
	 ad_out[63:32] <= address[63:32];
	 cben_out[7:4] <= 4'b0110;
	 cben_out[3:0] <= 4'b0110;

         //Turnaround Phase 
         @(posedge clk); 
         #tdel; 
         dword_cnt = dword_cnt - 1; 
         if (dword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
         end 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         par_en <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         //Data phase
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         
         //-----------Burst trasaction--------------------
         if (dword > 1 & !disengage_mstr)
         begin
            while (dword_cnt > 0 & !disengage_mstr)
            begin
               if (dword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
               end 
               dword_cnt = dword_cnt - 1; 
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         //----------------------------------------------------
         
         
         if ((disengage_mstr & dword > 1 & !framen) | (!disengage_mstr & dword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            dword_cnt = dword_cnt - 1; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk); 
               //#1;
            end 
         end 
         irdyn_out <= 1'b1 ; 
         cben_out <= {8{1'bz}} ;
	 //req64n <= 1'b1; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   
   endtask

   //*************
   task mem_wr_32;
   //*************
      input[31:0] address; 
      input[31:0] data; 
      input dword; 
      integer dword;

      reg[31:0] data_inc; 
      integer dword_cnt; 
      
      begin
        
        data_inc = data;
        dword_cnt = dword;
               
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out[63:32] <= {32{1'b0}} ; 
         cben_out[7:4] <= 4'b0000 ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0111 ; 
         par_en <= 1'b1 ; 
         
         //Data Phase
         @(posedge clk); 
         #tdel; 
         dword_cnt = dword_cnt - 1; 
         if (dword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
         end 
         ad_out <= data ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         
         //--------------Burst Transaction--------------
         
         if (dword > 1 & !disengage_mstr)
         begin
            while (dword_cnt > 0 & !disengage_mstr)
            begin
               if (dword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
               end 
               if (!irdyn & !trdyn)
               begin
                  dword_cnt = dword_cnt - 1; 
                  data_inc = data_inc + 32'h00000001; 
               end 
               ad_out[31:0] <= data_inc ; 
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         //--------------------------------------------------
         
         if (!irdyn & !trdyn)
         begin
            data_inc = data_inc + 32'h00000001; 
         end 
         ad_out[31:0] <= data_inc ; 
         if ((disengage_mstr & dword > 1 & !framen) | (!disengage_mstr & dword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk); 
               //#1;
            end 
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         par_en <= 1'b0 ; 
        
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

   //*************
   task mem_rd_32;
   //*************
   
      input[31:0] address; 
      input dword; 
      integer dword;

      integer dword_cnt; 
 
      begin
   
         dword_cnt = dword;
 
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free to start the transaction
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
          framen_out <= 1'b0 ; 
         ad_out[63:32] <= {32{1'b0}} ; 
         cben_out[7:4] <= 4'b0000 ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0110 ; 
         par_en <= 1'b1 ;
         
         //Turnaround Phase 
         @(posedge clk); 
         #tdel; 
         dword_cnt = dword_cnt - 1; 
         if (dword > 1)
         begin
            framen_out <= 1'b0 ; 
         end
         else
         begin
            framen_out <= 1'b1 ; 
         end 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'b0}} ; 
         irdyn_out <= 1'b0 ; 
         par_en <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         //Data phase
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         
         //-----------Burst trasaction--------------------
         if (dword > 1 & !disengage_mstr)
         begin
            while (dword_cnt > 0 & !disengage_mstr)
            begin
               if (dword_cnt == 1)
               begin
                  framen_out <= 1'b1 ; 
               end 
               dword_cnt = dword_cnt - 1; 
               @(posedge clk); 
               while (!tranx_success & !disengage_mstr)
               begin
                  @(posedge clk); 
                  //#1;
               end 
            end 
         end 
         //----------------------------------------------------
         
         
         if ((disengage_mstr & dword > 1 & !framen) | (!disengage_mstr & dword_cnt == 1))
         begin
            framen_out <= 1'b1 ; 
            dword_cnt = dword_cnt - 1; 
            @(posedge clk); 
            while (!tranx_success & !disengage_mstr)
            begin
               @(posedge clk); 
               //#1;
            end 
         end 
         irdyn_out <= 1'b1 ; 
         cben_out <= {8{1'bz}} ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

   
   //**********
   task io_wr;
   //**********
      input[31:0] address; 
      input[31:0] data; 

      begin
      
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free to start the transaction
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out[63:32] <= {32{1'b0}} ; 
         cben_out[7:4] <= 4'b0000 ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0011 ; 
         par_en <= 1'b1 ; 
         
         //Data phase
         @(posedge clk); 
         #tdel; 
         framen_out <= 1'b1 ; 
         irdyn_out <= 1'b0 ; 
         ad_out[31:0] <= data ; 
         cben_out[3:0] <= 4'b0000 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         par_en <= 1'b0 ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

   //*********
   task io_rd;
   //*********
      input[31:0] address; 

      begin
         
         //Request for the bus
         mstr_tranx_reqn <= 1'b0 ; 
         
         //Wait for the gnt to be asserted
         while (mstr_tranx_gntn)
         begin
            @(posedge clk); 
         end 
         
         //Wait for the bus to be free
         while (!busfree)
         begin
            @(posedge clk); 
         end 
         
         //Address Phase
         framen_out <= 1'b0 ; 
         ad_out[63:32] <= {32{1'bz}} ; 
         cben_out[7:4] <= {8{1'b0}} ; 
         ad_out[31:0] <= address ; 
         cben_out[3:0] <= 4'b0010 ; 
         par_en <= 1'b1 ; 
         
         //Turn around phase
         @(posedge clk); 
         #tdel; 
         framen_out <= 1'b1 ; 
         irdyn_out <= 1'b0 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= 4'b0000 ; 
         par_en <= 1'b0 ; 
         mstr_tranx_reqn <= 1'b1 ; 
         
         //Data phase
         while (!tranx_success & !disengage_mstr)
         begin
            @(posedge clk); 
            //#1;
         end 
         irdyn_out <= 1'b1 ; 
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         
         @(posedge clk); 
         #tdel; 
         drive_z; 
         if (!devseln)
         begin
            @(posedge devseln); 
         end 
      end
   endtask

   //***********
   task drive_z;
   //***********

      begin
         ad_out <= {64{1'bz}} ; 
         cben_out <= {8{1'bz}} ; 
         req64n <= 1'bz ; 
         framen_out <= 1'bz ; 
         irdyn_out <= 1'bz ; 

      end
   endtask 

   //***************
   task sys_rst;
   //***************
      input  Count1,Count2;
      integer Count1;
      integer Count2;
      begin
        rstn <= 1'b0 ; 
        idle_cycle(Count1); 
        rstn <= 1'b1 ; 
        idle_cycle(Count2); 
      end
   endtask
  
