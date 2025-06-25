// ------------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as authorized by
//  a licensing agreement from Altera Corporation.
//
//  (C) COPYRIGHT 2005 ALTERA CORPORATION
//  ALL RIGHTS RESERVED
//
//  The entire notice above must be reproduced on all authorized copies and any
//  such reproduction must be pursuant to a licensing agreement from Altera.
//
//  Title        : Memory Model for QDRII and QDRII+ memories
//  Project      : QDRII SRAM Controller
//
//
//  File         : $RCSfile: qdrii_model.v,v $
//
//  Last modified: $Date: 2013/08/11 $
//  Revision     : $Revision: #1 $
//
//  Abstract:
//
//  Notes: This is an example only and does not contain any timing information
//  ------------------------------------------------------------------------------

// byte masking is incorrect. It only masks the data from the memory to not use it but doesn't mask the data coming in.


`timescale 100ps / 100ps
module qdrii_model (d, q, sa, r_n, w_n, bw_n, k, k_n, c, c_n, cq, cq_n, doff_n);


    	parameter                   addr_bits =      6;    // This is external address
    	parameter                   data_bits =      16;
    	parameter                   mem_sizes =      ((2**6)*4) - 1; // ((2**addr_bits)*4) - 1

        parameter                   bw_bits   = 2;  // (data_bits == 8) ? 2 : (data_bits == 9) ? 1 : (data_bits == 16) ? 2 : (data_bits == 18) ? 2 : 4      
        parameter                   byte_mask_size   = (data_bits == 8) ? 4 : (data_bits == 9) ? 9 : (data_bits == 16) ? 8 : (data_bits == 18) ? 9 : (data_bits == 32) ? 8 : 9;      
        parameter                   burst_mode = 4; // 2 or 4 
        parameter                   latency = 1.5; // 1.5 (qdrii) 2 or 2.5 (qdrii+) 



        input [data_bits - 1 : 0] d;
        output [data_bits - 1 : 0] q;
        input [addr_bits -1 : 0] sa;
        input r_n;
        input w_n;
        input [bw_bits - 1:0] bw_n;
        input k;
        input k_n;
        input c; // unused
        input c_n; //unused
        input doff_n; // unused            
        output cq;
        output cq_n;
        

    
        reg [data_bits - 1 : 0] q;


        reg [addr_bits -1 :0] sa_reg1;
        reg [addr_bits -1 :0] sa_reg1n;
        reg [addr_bits -1 :0] sa_reg2;
        reg [addr_bits -1 :0] sa_reg3;          
        reg [addr_bits -1 :0] sa_reg4;          
        
        
        reg r_n_reg1	;
        reg r_n_reg2	;
        reg r_n_reg3	;
        reg r_n_reg4	;


        reg w_n_reg1	;
        reg w_n_reg1n	;
        reg w_n_reg2	;
        reg w_n_reg3	;
    	
 				wire [data_bits - 1 : 0] byte_mask;    	
 				reg [data_bits - 1 : 0] byte_mask_reg1;    	
 				reg [data_bits - 1 : 0] byte_mask_reg1n;    	
 				
 				reg [data_bits -1 :0] d_reg1;
 				reg [data_bits -1 :0] d_reg1n;
 				reg [data_bits -1 :0] temp_checks;
    	
// Write side
// On the write side, when a write signal appears, it will be registered n times and when the signal has propagated, then it will be put into the memory
// the write will have a mask and only the unmasked bytes will be written.

			genvar i;


generate
if (burst_mode == 4)            
begin                

   	
      reg [data_bits-1:0] main_memory_0 [0:mem_sizes];
      reg [data_bits-1:0] main_memory_1 [0:mem_sizes];
      reg [data_bits-1:0] main_memory_2 [0:mem_sizes];
      reg [data_bits-1:0] main_memory_3 [0:mem_sizes];
           

      reg [addr_bits -1 :0] sa_0;
      reg [addr_bits -1 :0] sa_1;
      reg [addr_bits -1 :0] sa_2;
      reg [addr_bits -1 :0] sa_3;
      reg [addr_bits -1 :0] sa_4;
      reg [addr_bits -1 :0] sa_5;
      reg [addr_bits -1 :0] sa_6;
      reg [addr_bits -1 :0] sa_7;
      reg [addr_bits -1 :0] sa_8;

			reg [data_bits - 1 : 0] d_0;
			reg [data_bits - 1 : 0] d_1;
			reg [data_bits - 1 : 0] d_2;
			reg [data_bits - 1 : 0] d_3;
			
			reg w_n_0;
			reg w_n_1;
			reg w_n_2;
			reg w_n_3;
			reg w_n_4;
			reg w_n_5;
			reg w_n_6;
			reg w_n_7;
			reg w_n_8;
			
			reg [data_bits - 1 : 0] byte_mask_0;    	
			reg [data_bits - 1 : 0] byte_mask_1;    	
			reg [data_bits - 1 : 0] byte_mask_2;    	
			reg [data_bits - 1 : 0] byte_mask_3;    	

	reg last_transaction;
	reg monitored_w_n;
	reg monitored_r_n;
	reg start_monitoring;
	
	initial
	begin
	last_transaction = 1'b0; // 1'b0 is a write, 1'b1 is a read
	start_monitoring = 1'b0;
	end
	
	// monitors that r_n and w_n are not triggered at the same time. The model should ideally cope with this.
	// The monitor needs to wait for a clock. It will assume that when the clock arrives, the system is not in reset. A counter could also be used
	always @(posedge k)
	begin
		start_monitoring <= 1'b0;// turning off the monitoring as it has some side effects in gate level> needs to trigger on clock edge, or sometime before the clock edge
	end
	always @(w_n or r_n)
	begin
		if (w_n === 1'b0 && r_n === 1'b0 && start_monitoring === 1'b1)
		begin
			if (last_transaction === 1'b0 )
			begin
				monitored_w_n <= 1'b1;
				monitored_r_n <= 1'b0;
				last_transaction <= 1'b1;
				$display ("** Warning ** QDRII memory model: simulataneous read and write. Model will READ in this transaction **");
			end
			else
			begin
				monitored_w_n <= 1'b0;
				monitored_r_n <= 1'b1;
				last_transaction <= 1'b0;
				$display ("** Warning ** QDRII memory model: simulataneous read and write. Model will WRITE in this transaction **");
			end
		end
		else
		begin
			if (w_n === 1'b0 && start_monitoring === 1'b1)
				last_transaction <= 1'b0;
			if (r_n === 1'b0 && start_monitoring === 1'b1)
				last_transaction <= 1'b1;
			monitored_w_n <= w_n;
			monitored_r_n <= r_n;
		end
	end
			
    always @(posedge k)
    begin
        w_n_reg1 <= monitored_w_n;
        w_n_reg2 <= w_n_reg1;
        w_n_reg3 <= w_n_reg2;

				sa_reg1 <= sa;    
				sa_reg2 <= sa_reg1;    
				sa_reg3 <= sa_reg2;    
				sa_reg4 <= sa_reg3;    
 // here we need to check if we have simultaneous read and write and pick one   
    		r_n_reg1 <= monitored_r_n;
    		r_n_reg2 <= r_n_reg1;
    		r_n_reg3 <= r_n_reg2;
    		r_n_reg4 <= r_n_reg3;
    
    end

    //creating the data mask            
    
    // get the data mask and multiply by the number of bits required
        for (i = 0; i < bw_bits; i = i + 1)
        begin:for_gen
           assign  byte_mask[byte_mask_size * (i + 1) -1 : byte_mask_size * i] = ~{byte_mask_size{bw_n[i]}};
           
        end



	always @(posedge k or negedge k)
	begin
		w_n_0 <= monitored_w_n;
		w_n_1 <= w_n_0;
		w_n_2 <= w_n_1;
		w_n_3 <= w_n_2;
		w_n_4 <= w_n_3;
		w_n_5 <= w_n_4;
		w_n_6 <= w_n_5;
		w_n_7 <= w_n_6;
		w_n_8 <= w_n_7;
		
		sa_0 <= sa;
		sa_1 <= sa_0;
		sa_2 <= sa_1;
		sa_3 <= sa_2;
		sa_4 <= sa_3;
		sa_5 <= sa_4;
		sa_6 <= sa_5;
		sa_7 <= sa_6;
		sa_8 <= sa_7;
		
		byte_mask_0 <= byte_mask;
		byte_mask_1 <= byte_mask_0;
		byte_mask_2 <= byte_mask_1;
		byte_mask_3 <= byte_mask_2;
		
		d_0 <= d;
		d_1 <= d_0;
		d_2 <= d_1;
		d_3 <= d_2;
	end

	if (latency == 2.5)
	begin
		always @(posedge k or negedge k)
		begin
			
			if (k == 1'b1)
				begin
					if (w_n_5 == 1'b0 )
						begin
              main_memory_0[sa_5] <= (d_3 & byte_mask_3) | (main_memory_0[sa_5] & ~byte_mask_3);
						end
					else if (w_n_7 == 1'b0 )
						begin
              main_memory_2[sa_7] <= (d_3 & byte_mask_3) | (main_memory_2[sa_7] & ~byte_mask_3);              
						end
				end
			if (k == 1'b0)
				begin
					if (w_n_6 == 1'b0 )
						begin
              main_memory_1[sa_6] <= (d_3 & byte_mask_3) | (main_memory_1[sa_6] & ~byte_mask_3);
						end
					else if (w_n_8 == 1'b0 )
						begin
							main_memory_3[sa_8] <= (d_3 & byte_mask_3)| (main_memory_3[sa_8] & ~byte_mask_3);
						end
				end
			
		end
	end
	else
	begin
		always @(posedge k or negedge k)
		begin
			
			if (k == 1'b1)
				begin
					if (w_n_3 == 1'b0 )
						begin
              main_memory_0[sa_3] <= (d_1 & byte_mask_1) | (main_memory_0[sa_3] & ~byte_mask_1);
						end
					else if (w_n_5 == 1'b0 )
						begin
              main_memory_2[sa_5] <= (d_1 & byte_mask_1) | (main_memory_2[sa_5] & ~byte_mask_1);
						end
				end
			if (k == 1'b0)
				begin
					if (w_n_4 == 1'b0 )
						begin
              main_memory_1[sa_4] <= (d_1 & byte_mask_1) | (main_memory_1[sa_4] & ~byte_mask_1);
						end
					else if (w_n_6 == 1'b0 )
						begin
               main_memory_3[sa_6] <= (d_1 & byte_mask_1)| (main_memory_3[sa_6] & ~byte_mask_1);
						end
				end
			
		end
	end



	  if (latency == 1.5)        
		  begin
				always @(posedge k or negedge k)
				begin
					q <= {data_bits{1'bz}};
					if (k == 1'b0)
						begin
							if (r_n_reg2 == 1'b0 )
								begin
                  q <= main_memory_0[sa_reg2];
								end
							else if (r_n_reg3 == 1'b0 )
								begin
                  q <= main_memory_2[sa_reg3];
								end
						end
					if (k == 1'b1)
						begin
							if (r_n_reg2 == 1'b0 )
								begin
                  q <= main_memory_1[sa_reg2];
								end
							else if (r_n_reg3 == 1'b0 )
								begin
                  q <= main_memory_3[sa_reg3];
								end
						end
					
				end
			end
    else if (latency == 2)        
		  begin
				always @(posedge k or negedge k)
				begin
					q <= {data_bits{1'bz}};
					if (k == 1'b0)
						begin
							if (r_n_reg3 == 1'b0 )
								begin
//									q <= lower_main_memory[sa_reg3][data_bits * 2 -1 : data_bits * 1];
									q <= main_memory_1[sa_reg3];
								end
							else if (r_n_reg4 == 1'b0 )
								begin
//									q <= upper_main_memory[sa_reg4][data_bits * 4 -1 : data_bits * 3];
									q <= main_memory_3[sa_reg4];
								end
						end
					if (k == 1'b1)
						begin
							if (r_n_reg2 == 1'b0 )
								begin
//									q <= lower_main_memory[sa_reg2][data_bits * 1 -1 : data_bits * 0];
									q <= main_memory_0[sa_reg2];
								end
							else if (r_n_reg3 == 1'b0 )
								begin
//									q <= upper_main_memory[sa_reg3][data_bits * 3 -1 : data_bits * 2];
									q <= main_memory_2[sa_reg3];
								end
						end
					
				end
			end
    else if (latency == 2.5)        
		  begin
				always @(posedge k or negedge k)
				begin
					q <= {data_bits{1'bz}};
					if (k == 1'b0)
						begin
							if (r_n_reg3 == 1'b0 )
								begin
//									q <= lower_main_memory[sa_reg3][data_bits * 1 -1 : data_bits * 0];
									q <= main_memory_0[sa_reg3];
								end
							else if (r_n_reg4 == 1'b0 )
								begin
//									q <= upper_main_memory[sa_reg4][data_bits * 3 -1 : data_bits * 2];
									q <= main_memory_2[sa_reg4];
								end
						end
					if (k == 1'b1)
						begin
							if (r_n_reg3 == 1'b0 )
								begin
//									q <= lower_main_memory[sa_reg3][data_bits * 2 -1 : data_bits * 1];
									q <= main_memory_1[sa_reg3];
								end
							else if (r_n_reg4 == 1'b0 )
								begin
									q <= main_memory_3[sa_reg4];
								end
						end
					
				end
			end
   	

end

else // burst of 2
begin    
// -------------------------------------------------------------------------------------------------------------------------------    
// -------------------------------------------------------------------------------------------------------------------------------    
// -------------------------------------------------------------------------------------------------------------------------------    
// -------------------------------------------------------------------------------------------------------------------------------    
// -------------------------------------------------------------------------------------------------------------------------------    

    reg     [data_bits-1 : 0] main_memory_0 [0 : mem_sizes];     
    reg     [data_bits-1 : 0] main_memory_1 [0 : mem_sizes];     
    

    always @(negedge k)
    begin
        w_n_reg1n <= w_n;

				sa_reg1n <= sa;    
				d_reg1n <= d;
				byte_mask_reg1n <= byte_mask;
    
//    		r_n_reg1 <= r_n;
//    		r_n_reg2 <= r_n_reg1;
//    		r_n_reg3 <= r_n_reg2;
//    		r_n_reg4 <= r_n_reg3;
    
    end
    always @(posedge k)
    begin
				sa_reg1 <= sa;    
				sa_reg2 <= sa_reg1;    
				w_n_reg1 <= w_n;
    
    		r_n_reg1 <= r_n;
    		r_n_reg2 <= r_n_reg1;
    		r_n_reg3 <= r_n_reg2;
    		r_n_reg4 <= r_n_reg3;
    
    		d_reg1 <= d;
    		byte_mask_reg1 <= byte_mask;
    end

  for (i = 0; i < bw_bits; i = i + 1)
  begin:for_gen
     assign  byte_mask[byte_mask_size * (i + 1) -1 : byte_mask_size * i] = ~{byte_mask_size{bw_n[i]}};
     
  end


	always @(posedge k or negedge k)
	begin
		if (k == 1'b0)
		  begin
				if (w_n == 1'b0)
				//if (w_n_reg1 == 1'b0)
					begin
						//main_memory[sa] <= { (d & byte_mask) | (main_memory[sa][data_bits * 2 -1 : data_bits * 1] & ~byte_mask), main_memory[sa][data_bits * 1 -1 : data_bits * 0]};
//						main_memory[sa] <= { (main_memory[sa_reg1][data_bits * 2 -1 : data_bits * 1] ), (d_reg1 & byte_mask_reg1) | (main_memory[sa_reg1][data_bits * 1 -1 : data_bits * 0] & ~byte_mask_reg1)};
						main_memory_0[sa] <= (d_reg1 & byte_mask_reg1) | (main_memory_0[sa_reg1] & ~byte_mask_reg1);
					end
			end
		if (k == 1'b1)
		  begin
				if (w_n_reg1n == 1'b0)
					begin
//						main_memory[sa_reg1n] <= {(d_reg1n & byte_mask_reg1n) | (main_memory[sa_reg1n][data_bits * 2 -1 : data_bits * 1] & ~byte_mask_reg1n), (main_memory[sa_reg1n][data_bits * 1 -1 : data_bits * 0] )};
						main_memory_1[sa_reg1n] <= (d_reg1n & byte_mask_reg1n) | (main_memory_1[sa_reg1n]& ~byte_mask_reg1n);
					end
		  end
				
	end

	always @(posedge k or negedge k)
	begin
		q <= {data_bits{1'bz}};
		if (k == 1'b0)
			begin
				if (r_n_reg2 == 1'b0 )
					begin
//						q <= main_memory[sa_reg2][data_bits * 1 -1 : data_bits * 0];
						q <= main_memory_0[sa_reg2];
					end
			end
		if (k == 1'b1)
			begin
				if (r_n_reg2 == 1'b0 )
					begin
//						q <= main_memory[sa_reg2][data_bits * 2 -1 : data_bits * 1];
						q <= main_memory_1[sa_reg2];
					end
			end
		
	end
    
    
    
    
end    
endgenerate


assign cq = k;                  
assign cq_n = k_n;                  

    	
    	
endmodule
    	
    	
    	
    	


