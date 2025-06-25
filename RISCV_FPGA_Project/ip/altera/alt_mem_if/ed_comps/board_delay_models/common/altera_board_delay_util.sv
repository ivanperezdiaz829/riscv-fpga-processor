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


`ifndef NULL
	`define NULL 0
`endif

module altera_board_delay_util;

task read_config;
	input string file;
	input string name;
	inout integer delays[];



	integer i;
	integer fp;

	fp = $fopen(file, "r");
        if (fp == `NULL)
        begin
                $display("Warning: cannot open %0s.", file);
		return;
        end

	while(!$feof(fp)) 
	begin
		string line;
		string port;
		integer delay;
		integer index;
		
		if ($fgets(line,fp)) 
		begin
			if (line == "\n" || line[0] == "#")
			begin
			end
			else if ($sscanf(line, "%s [%d] %d\n", port, index, delay) == 3)
			begin
				if (port == name)
				begin
					$display("Found indexed %s[%0d] => %0d", port, index, delay);
					if (index < 0 || index >= delays.size())
					begin
						$display("Index %0d of array %s is out of range; size %0d",
							 index, port, delays.size());
						$finish;
					end
					delays[index] = delay;
				end
			end
			else if ($sscanf(line, "%s %d\n", port, delay) == 2)
			begin
				if (port == name)
				begin
					$display("Found %s => %0d", port, delay);
					for (i = 0; i < delays.size(); i++)
					begin
						delays[i] = delay;
					end
				end
			end
			else
			begin
				line = line.substr(0,line.len()-2);
				$display("Problem with line '%s'", line);
			end
		end
        end


	$fclose(fp);

endtask

endmodule
