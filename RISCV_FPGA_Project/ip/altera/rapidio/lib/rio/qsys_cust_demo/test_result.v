/*
*******************************************************************************
# (C) 2001-2010 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.
*******************************************************************************
*/
//--------------------------------------------------------------------------
//Check the written data
//--------------------------------------------------------------------------
always @ go_check begin
   checked++;
   if(response_request == REQ_READ) begin 
   //Read value in Base Device ID offset 0x60, Port General Control 0x13c, 
   //Tx maintenance Window 0 Control 0x1010C and Tx Maintenance Window 0 Mask 0x10104
      expected_data = master_scoreboard.pop_front(); //get the expected data which was saved earlier
      if(response_data != expected_data) begin
         failure++;
         $sformat(message, "Donecheck %0d: Data mismatch at address 32'h%8h: 32'h%8h with expected 32'h%8h\n", checked, response_addr, response_data, expected_data);	       
         print(VERBOSITY_FAILURE, message);
      end else begin
         $sformat(message, "Donecheck %0d: Data matched at address 32'h%8h: 32'h%8h", checked, response_addr, response_data);	       
         print(VERBOSITY_INFO, message);
      end
   end else begin //REQ_WRITE
      $sformat(message, "Donecheck %0d: Data written", checked);
      print(VERBOSITY_INFO, message);
   end
end

//--------------------------------------------------------------------------
//Read registers
//--------------------------------------------------------------------------
always @ go_read_response begin
   checked++;
   if(response_request == REQ_READ) begin 
      $sformat(message, "Donecheck %0d: Read data at address 32'h%8h: 32'h%8h", checked, response_addr, response_data);
      print(VERBOSITY_INFO, message);
   end else begin //REQ_WRITE
      $sformat(message, "Donecheck %0d: Data written", checked);
      print(VERBOSITY_INFO, message);
   end
end

//--------------------------------------------------------------------------
//Check I/O 64-bit data
//--------------------------------------------------------------------------
always @ go_check_io begin
   checked++;
   if(response_request == REQ_READ) begin 
      response_burst_size = `MSTR_BFM_IO.get_response_burst_size();
      $sformat(message, "I/O burst size is %0d", response_burst_size);	       
      print(VERBOSITY_INFO, message);
      for ( int i = 0; i < response_burst_size; i = i + 1) begin 
         response_data_64b = `MSTR_BFM_IO.get_response_data(i);
         expected_data_64b = master_scoreboard_64b.pop_front(); //get the expected data which was saved earlier
         if(response_data_64b != expected_data_64b) begin
            failure++;
            $sformat(message, "Donecheck %0d: I/O burst readdata [%0d] mismatch at address 32'h%8h: 64'h%16h with expected 64'h%16h\n", checked, i, response_addr, response_data_64b, expected_data_64b);	       
            print(VERBOSITY_FAILURE, message);
         end else begin
            $sformat(message, "Donecheck %0d: I/O burst readdata [%0d] matched at address 32'h%8h: 64'h%16h", checked, i, response_addr, response_data_64b);	       
            print(VERBOSITY_INFO, message);
         end
      end //for loop
      response_burst_size = 0; //reset
   end else begin //REQ_WRITE
      $sformat(message, "Donecheck %0d: I/O burst data written", checked);
      print(VERBOSITY_INFO, message);
   end
end
