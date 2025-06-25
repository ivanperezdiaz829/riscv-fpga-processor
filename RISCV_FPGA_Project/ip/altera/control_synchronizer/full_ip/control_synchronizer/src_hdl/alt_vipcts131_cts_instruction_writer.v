/*
	This module has an avalon slave interface, which is imagestream compliant (has a status, and a go bit)
	It also features an interrupt which is to be used to tell the nios it has applied a change
	
	The core has 10 writeable registers, 2-7 are instructions combined with an offset
	8 is an address 
	9 is the number of addresses from 0 to transfer
	
	
	The other side of the core is an interface to another module
	completed is an output flag to say all commands + offsets have been ack'd
	ack_data is an input to say the current data value has been used
	data is an output of the data
	address is an output of the address to write to
	
	hold_before_image_data is an output to tell the connected module that it should not process the next image packet until this signal goes low (stop/go bit implementation)
	
	this module will fire an interrupt off when it has completed a write
	
	
*/

module alt_vipcts131_cts_instruction_writer
	#(	parameter MAX_INSTRUCTION_COUNT = 3,
		parameter DISARM_ON_TRIGGER = 1) (
	
	rst,
	clk,
	
	// Slave Control port
	av_slave_address,
	av_slave_read,
	av_slave_readdata,
	av_slave_write,
	av_slave_writedata,
	
	// Interrupt
	status_update_int,
	
	// Master port
	av_master_address,
	av_master_writedata,
	av_master_write,
	av_master_waitrequest,
	
	//instruction lines	
	do_transfer,
	done_transfer,
	
	//Used for go bit
	hold_before_image_data,
	
	//for status register
	stalled,
	
	//Used for disarming trigger / do transfer line
	disarm
	
);

parameter GO_REGISTER_POSITION = 0;
parameter STATUS_REGISTER_POSITION = 1;
parameter INTERRUPT_REGISTER_POSITION = 2;
parameter DISARM_REGISTER_POSITION = 3;
parameter NUMBER_OF_DATA_DUMPS_REGISTER_POSITION =4;
parameter INSTRUCTIONS_REG_START_POSITION = 5;
parameter INSTRUCTION_COUNT = MAX_INSTRUCTION_COUNT;
parameter REGISTERS_USED_FOR_INSTRUCTIONS = INSTRUCTION_COUNT * 2;
parameter DATA_STORE_SIZE = REGISTERS_USED_FOR_INSTRUCTIONS + 5; //4 is go, status, interrupt, number of writes, disarm

input rst;
input clk;
   
// Slave Control port
input [4:0] av_slave_address;
input av_slave_read;
output [31:0] av_slave_readdata;
input av_slave_write;
input [31:0] av_slave_writedata;
//output av_slave_waitrequest;
   
// Interrupt
output status_update_int;

//Master port
output [31:0] av_master_address;
output [31:0] av_master_writedata;
output av_master_write;
input av_master_waitrequest;

//instruction line
input do_transfer;
output done_transfer;

// Core flow control
output hold_before_image_data;
input stalled;

// Disarms core trigger
output disarm;


//av_slave_slave registers
reg [31:0] slave_data [DATA_STORE_SIZE-1:0]; 
/*generate 
	genvar i;
	for(i = 0; i < DATA_STORE_SIZE ; i = i + 1) begin : register_behaviour
		always @ (posedge rst or posedge clk) begin
    		if (rst) begin
    			slave_data[i] <= 0;
    		end
    	end
    end
endgenerate*/


//translation of ports to regs
reg [31:0] av_slave_readdata_proc;
assign av_slave_readdata = av_slave_readdata_proc;

//go bit reading/proporgating
assign hold_before_image_data = !slave_data[GO_REGISTER_POSITION][0];

//disarm bit
assign disarm = slave_data[DISARM_REGISTER_POSITION][0];

//counter for the writing of output //TODO replace with SR or get sizing parameterisable
reg [3:0] write_counter;

reg doing_transfer;
reg doing_transfer_d1;
reg av_master_write_int;
assign av_master_write = av_master_write_int;
reg status_update_int;
reg done_transfer_internal;
assign done_transfer = done_transfer_internal;

wire  clear_interrupts ;
assign clear_interrupts = av_slave_write && av_slave_address == INTERRUPT_REGISTER_POSITION && av_slave_writedata[1] == 1'b1;
reg null_transfer_done;

wire disarm_value_after_trigger;

generate
	if (DISARM_ON_TRIGGER) begin
		assign disarm_value_after_trigger = 1;
	end else begin
		assign disarm_value_after_trigger = slave_data[DISARM_REGISTER_POSITION][0];
	end
endgenerate


integer i;

always @ (posedge rst or posedge clk) begin
	if (rst) begin
	//main process for the master interface
		write_counter <= 0;
		doing_transfer <= 0;
		doing_transfer_d1 <=0;
		av_master_write_int <= 0;
		status_update_int <= 0;
		done_transfer_internal <=0;
		null_transfer_done <= 0;
		av_slave_readdata_proc <= 0;
		
		//main process for avalon slave side of the module
		slave_data[GO_REGISTER_POSITION] <= 0;
		slave_data[STATUS_REGISTER_POSITION] <= 0;
		slave_data[INTERRUPT_REGISTER_POSITION] <= 0;
		slave_data[NUMBER_OF_DATA_DUMPS_REGISTER_POSITION] <= 0;
		
		//disarm register power up value is 1
		slave_data[DISARM_REGISTER_POSITION] <= 1;
		// reset registers not in array form
      
      // reset the rest of slave_data
      for (i = INSTRUCTIONS_REG_START_POSITION; i < DATA_STORE_SIZE; i = i + 1) begin
         slave_data[i] <= 0;
      end
      
	end else begin
		//standard clocked processes	
		
		//main process for avalon slave side of the module
		//read process
		if(av_slave_read && !av_slave_write) begin
			av_slave_readdata_proc <= slave_data[av_slave_address];
		end 
		//write process 
		else if(av_slave_write && !av_slave_read && av_slave_address != INTERRUPT_REGISTER_POSITION) begin
			slave_data[av_slave_address] <= av_slave_writedata;
		end

		//main process for the master interface
		slave_data[STATUS_REGISTER_POSITION][0] <= !stalled;
		doing_transfer_d1<=doing_transfer;
		done_transfer_internal <= (doing_transfer_d1 & !doing_transfer) | null_transfer_done;
		
		//latch do_transfer, releaseing doing tranfer when transfer complete.
		if(do_transfer) begin
			slave_data[DISARM_REGISTER_POSITION][0] <= disarm_value_after_trigger;
			if (slave_data[NUMBER_OF_DATA_DUMPS_REGISTER_POSITION]!=0) begin
				doing_transfer <= 1;
				av_master_write_int <= 1;
			end else begin
				null_transfer_done <=1;
			end
		end
		
		if(null_transfer_done) begin
			null_transfer_done <= 0;
		end
		
		if(clear_interrupts) begin
			 status_update_int<=0;
			 slave_data[INTERRUPT_REGISTER_POSITION][1] <= 0;
		end
			
		if(!av_master_waitrequest && doing_transfer) begin
			if(write_counter == slave_data[NUMBER_OF_DATA_DUMPS_REGISTER_POSITION] - 1) begin
				write_counter <= 0;
				av_master_write_int <= 0;
				doing_transfer <= 0;
				//interrupt trigger here				
				if(slave_data[GO_REGISTER_POSITION][1] == 1) begin
					slave_data[INTERRUPT_REGISTER_POSITION][1] <= 1;
					status_update_int<=1;
				end
			end else begin
				write_counter <= write_counter + 4'b1;				
			end						
		end			
	end
end

//set the address line
assign av_master_address = slave_data[(write_counter*2)+INSTRUCTIONS_REG_START_POSITION];
//set the data
assign av_master_writedata = slave_data[(write_counter*2)+1+INSTRUCTIONS_REG_START_POSITION];



endmodule

