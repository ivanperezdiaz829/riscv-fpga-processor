// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


////////////////////////////////////////////////////////////////////////////////
////This is user input address register.
////Read from user input file and shifted per each clock cycle
////////////////////////////////////////////////////////////////////////////////

module user_input(
	clk,
	reset_n,
	enable,
    	ready,
	data
);

////////////////////////////////////////////////////////////////////////////////
////BEGIN PARAMETER SECTION

parameter DATA_WIDTH		= "";
parameter USER_INPUT_ENABLED = 0;
parameter USER_INPUT_BINARY  = 1;
parameter USER_INPUT_DEPTH   = 300;
parameter USER_INPUT_FILE    = "user_input.hex";
parameter SHOW_AHEAD         = 1;

////END PARAMETER SECTION
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
////BEGIN PORT SECTION

////Clock and reset
input							clk;
input							reset_n;

////Control and status
input							enable;

////Outputs
output 	[DATA_WIDTH-1:0]		ready;
output 	[DATA_WIDTH-1:0]		data;

////END PORT SECTION
////////////////////////////////////////////////////////////////////////////////

reg 	[DATA_WIDTH-1:0]		data;
reg 	[DATA_WIDTH-1:0]		loaded_data[USER_INPUT_DEPTH-1:0];
reg 	[DATA_WIDTH-1:0]		data_array[USER_INPUT_DEPTH-1:0];
reg                             	data_loaded;

assign ready = data_loaded;

generate
if (USER_INPUT_BINARY == 1)
    initial $readmemb(USER_INPUT_FILE,loaded_data);
else
    initial $readmemh(USER_INPUT_FILE,loaded_data);
endgenerate

generate
if (SHOW_AHEAD == 1)
begin
    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            data <= '0;
        else
        begin
            if (!enable && data_loaded)
                data <= data_array[0];
            else if (enable && data_loaded)
                data <= data_array[1];
            else
                data <= data;
        end
    end
end
else
begin
    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            data <= '0;
        else
            if (enable && data_loaded)
                data <= data_array[0];
            else
                data <= data;
    end
end
endgenerate

int loc;
always_ff @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
    begin
        for (loc = 0; loc < USER_INPUT_DEPTH - 1; loc = loc + 1'b1)
        begin
            data_array[loc] <= '0;
        end
        data_loaded <= 1'b0;
    end
    else
    begin
        if (!data_loaded)
        begin
            data_array <= loaded_data;
            data_loaded <= 1'b1;
        end

        if (enable && data_loaded)
        begin
            for (loc = 0; loc < USER_INPUT_DEPTH - 1; loc = loc + 1'b1)
            begin
                data_array[loc] <= data_array[loc+1];
            end

             data_array[USER_INPUT_DEPTH - 1] <= data_array[0];
        end
    end
end
endmodule
