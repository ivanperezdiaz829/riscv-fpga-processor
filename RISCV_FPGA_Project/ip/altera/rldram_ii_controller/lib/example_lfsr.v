`timescale 1ps / 1ps

module example_lfsr (clk, reset_n, enable, pause, load, data);

   parameter seed  = 32;
   parameter gMEM_DQ_PER_DQS = 8;
   input clk;
   input reset_n;
   input enable;
   input pause;
   input load;
   output[gMEM_DQ_PER_DQS - 1:0] data;
   wire[gMEM_DQ_PER_DQS - 1:0] data;
   
   reg[17:0] lfsr_data;

   assign data[gMEM_DQ_PER_DQS - 1:0] = lfsr_data[gMEM_DQ_PER_DQS - 1:0];

   always @(posedge clk or negedge reset_n)
   begin
      if (!reset_n)
      begin
         // Reset - asynchronously reset to seed value
         lfsr_data[gMEM_DQ_PER_DQS - 1:0] <= seed[7:0] ;
      end
      else
      begin
         if (!enable)
         begin
            lfsr_data[gMEM_DQ_PER_DQS - 1:0] <= seed[7:0];
         end
         else
         begin
            if (load)
            begin
               lfsr_data[gMEM_DQ_PER_DQS - 1:0] <= seed[7:0];
            end
            else
            begin
               // Registered mode - synchronous propagation of signals
               if (!pause)
               begin
					lfsr_data[0]  <= lfsr_data[7] ;
					lfsr_data[1]  <= lfsr_data[0] ;
					lfsr_data[2]  <= lfsr_data[1] ^ lfsr_data[gMEM_DQ_PER_DQS - 1] ;
					lfsr_data[3]  <= lfsr_data[2] ^ lfsr_data[gMEM_DQ_PER_DQS - 1] ;
					lfsr_data[4]  <= lfsr_data[3] ^ lfsr_data[gMEM_DQ_PER_DQS - 1] ;
					lfsr_data[5]  <= lfsr_data[4] ;
					lfsr_data[6]  <= lfsr_data[5] ;
					lfsr_data[7]  <= lfsr_data[6] ;
					lfsr_data[8]  <= lfsr_data[7] ;
					lfsr_data[9]  <= lfsr_data[8] ;
					lfsr_data[10] <= lfsr_data[9] ;
					lfsr_data[11] <= lfsr_data[10] ;
					lfsr_data[12] <= lfsr_data[11] ;
					lfsr_data[13] <= lfsr_data[12] ;
					lfsr_data[14] <= lfsr_data[13] ;
					lfsr_data[15] <= lfsr_data[14] ;
					lfsr_data[16] <= lfsr_data[15] ;
					lfsr_data[17] <= lfsr_data[16] ;
               end
            end
         end
      end
   end
endmodule
