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
//this file is used to initiate transactions and provide expected result for each transactions.
initial begin
   @ start_test;
   command_addr = 0;    //write address start from 0x0
   byte_enable  = 4'hF; //all byte lanes are used
   idle         = 0;    //no idle cycle between each command of the master BFM
   init_latency = 0;    //the command is launched to Avalon bus with no delay

//--------------------------------------------------------------------------
//Configure through RapidIO sys_mnt_s
//--------------------------------------------------------------------------
//1. Set DUT Base Device ID to 8'hAA
   print_info("Configure Base Device ID to 32'h00AAFFFF");
   master_set_and_push_command(REQ_WRITE, 26'h60 /*command_addr*/, 32'h00AA0000 /*command_data*/, byte_enable, idle, init_latency);
   master_scoreboard.push_back(32'h00AAFFFF); //make a local copy of the expected data; bit[15:0] is reserved for large device ID with default value 16'hFFFF.

   //Verify the setting
   master_set_and_push_command(REQ_READ, 26'h60, 0, byte_enable, idle, init_latency);

//2. Set Master Enable at offset 0x13c
   print_info("Configure Port General Control");
   command_addr = 26'h13C; 
   command_data = 32'h60000000;
   master_scoreboard.push_back(command_data); //make a local copy of the write data
   master_set_and_push_command(REQ_WRITE, command_addr, command_data, byte_enable, idle, init_latency);
   //Verify the setting
   master_set_and_push_command(REQ_READ, command_addr, 0, byte_enable, idle, init_latency);

//3. Setup address mapping window 0
   print_info("Configure Tx Maintenance Window 0 Control");
   command_addr = 26'h1010C; //Tx Maintenance Window 0 Control
   command_data = 32'h00AAFF00; //Destination ID same value as the value wrote to Base Device ID = 8'hAA, Hop Count = 8'hFF, priority = 2'b00
   master_scoreboard.push_back(command_data); //make a local copy of the write data
   master_set_and_push_command(REQ_WRITE, command_addr, command_data, byte_enable, idle, init_latency);
   //Verify the setting
   master_set_and_push_command(REQ_READ, command_addr, 0, byte_enable, idle, init_latency);

   print_info("Configure Tx Maintenance Window 0 Mask");
   command_addr = 26'h10104; //Tx Maintenance Window 0 Mask
   command_data = 32'h00000004; //Enable the window
   master_scoreboard.push_back(command_data); //make a local copy of the write data
   master_set_and_push_command(REQ_WRITE, command_addr, command_data, byte_enable, idle, init_latency);
   //Verify the setting
   master_set_and_push_command(REQ_READ, command_addr, 0, byte_enable, idle, init_latency);

//--------------------------------------------------------------------------
//Maintenance Transactions IF Maintenance Slave is enabled
//--------------------------------------------------------------------------
   print_info("Verify Maintenance Slave DUT to Master BFM: Maintenance Write and Maintenance Read");
   master_set_and_push_command(REQ_WRITE, 32'h10100, 32'h00000000, byte_enable, idle, init_latency);//Tx Maintenance Mapping Window 0 Base - set to 0
   master_set_and_push_command(REQ_WRITE, 32'h10108, 32'h00000000, byte_enable, idle, init_latency);//Tx Maintenance Mapping Window 0 Offset - set to 0
   print_info("Maintenance write data 32'h76543210 to address 32'h0400006c");
   command_data = 32'h76543210;
   master_set_and_push_command(REQ_WRITE, 32'h0400006c, command_data, byte_enable, idle, init_latency);
   master_scoreboard.push_back(command_data);
   //Read from Maintenance Slave
   master_set_and_push_command(REQ_READ, 32'h0400006c, 0, byte_enable, idle, 0/*init_latency*/);
end

//--------------------------------------------------------------------------
//IO Transactios if IO Slave and IO Master are enabled
//--------------------------------------------------------------------------
initial begin
   @ io_trans_config;
   print_info("Set up I/O Slave and I/O Master");
   byte_enable  = 4'hF; //all byte lanes are used
   idle         = 0;    //no idle cycle between each command of the master BFM
   init_latency = 0;    //the command is launched to Avalon bus with no delay
 
   master_set_and_push_command(REQ_WRITE, 26'h60, 32'h00AA0000, byte_enable, idle, init_latency);
   master_scoreboard.push_back(32'h00AAFFFF); //make a local copy of the expected data; bit[15:0] is reserved for large device ID with default value 16'hFFFF.

   //Enable Error Management Register
   print_info("Enable Error Management Register.");
   master_set_and_push_command(REQ_WRITE, 32'h10804, 32'h0fc00000, byte_enable, idle, init_latency);//General Control
   master_scoreboard.push_back(32'h0fc00000);//Logical/Transport layer Error Enable CSR

   // Enable Maintenance Interrupt
   print_info("Enable Maintenance Interrupt.");
   master_set_and_push_command(REQ_WRITE, 32'h10084, 32'h73, byte_enable, idle, init_latency);//General Control
   master_scoreboard.push_back(32'h73);//Maintenance Interrupt Enable

   // Enable IO Slave Interrupt
   print_info("Enable I/O Slave Interrupt.");
   master_set_and_push_command(REQ_WRITE, 32'h10504, 32'h1F, byte_enable, idle, init_latency);//General Control
   master_scoreboard.push_back(32'h1F);//I/O Slave Interrupt Enable

   master_set_and_push_command(REQ_WRITE, 32'h13c, 32'h60000000, byte_enable, idle, init_latency);//General Control
   master_scoreboard.push_back(32'h60000000);

   master_set_and_push_command(REQ_WRITE, 32'h10400, 32'h00000000, byte_enable, idle, init_latency);//IO Slave Window 0 Base
   master_scoreboard.push_back(32'h00000000);
   master_set_and_push_command(REQ_WRITE, 32'h10408, 32'h00000000, byte_enable, idle, init_latency);//IO Slave Window 0 Offset
   master_scoreboard.push_back(32'h00000000);
   master_set_and_push_command(REQ_WRITE, 32'h1040c, 32'h00AA0002, byte_enable, idle, init_latency);//IO Slave Window 0 Control, SWRITE_ENABLE=1, NWRITE_R_ENABLE=0
   master_scoreboard.push_back(32'h00AA0002);
   master_set_and_push_command(REQ_WRITE, 32'h10404, 32'h00000004, byte_enable, idle, init_latency);//IO Slave Window 0 Mask
   master_scoreboard.push_back(32'h00000004);

   master_set_and_push_command(REQ_WRITE, 32'h10300, 32'h00000000, byte_enable, idle, init_latency);//IO Master Window 0 Base
   master_scoreboard.push_back(32'h00000000);
   master_set_and_push_command(REQ_WRITE, 32'h10308, 32'h00000000, byte_enable, idle, init_latency);//IO Master Window 0 Offset
   master_scoreboard.push_back(32'h00000000);
   master_set_and_push_command(REQ_WRITE, 32'h10304, 32'h00000004, byte_enable, idle, init_latency);//IO Master Window 0 Mask
   master_scoreboard.push_back(32'h00000004);

   //Verify the IO configurations
   master_set_and_push_command(REQ_READ, 26'h   60, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10804, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10084, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10504, 0, byte_enable, idle, init_latency);

   master_set_and_push_command(REQ_READ, 26'h  13c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10400, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10408, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h1040c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10404, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10300, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10308, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h10304, 0, byte_enable, idle, init_latency);
end

initial begin
   @ io_trans;
   print_info("Verify I/O SWRITE Transactions");
   byte_enable_64b = 8'hFF;  //all byte lanes are used
   idle_64b        = 0;  //no idle cycle between each command of the master BFM
   init_latency    = 0;  //the command is launched to Avalon bus with no delay

   //Burst transfers
   begin
      logic [63:0] burst_data; 
      //Write burst
      burstcount = 4;
      `MSTR_BFM_IO.set_command_request(REQ_WRITE);
      `MSTR_BFM_IO.set_command_address(32'h4000_0200);
      `MSTR_BFM_IO.set_command_idle(idle, 3);
      `MSTR_BFM_IO.set_command_init_latency(init_latency);
      `MSTR_BFM_IO.set_command_burst_size(burstcount);
      `MSTR_BFM_IO.set_command_burst_count(burstcount);
      for ( int i = 0 ; i < burstcount ; i = i + 1 ) begin
         burst_data = 64'h77665544_33221100 + (64'h11111111_11111111 * i);
         `MSTR_BFM_IO.set_command_byte_enable(8'hff,i);
         `MSTR_BFM_IO.set_command_data(burst_data, i);
         master_scoreboard_64b.push_back(burst_data);
      end
      `MSTR_BFM_IO.push_command();
      
      //Read burst
      `MSTR_BFM_IO.set_command_request(REQ_READ);
      `MSTR_BFM_IO.set_command_address(32'h8000_0200);
      `MSTR_BFM_IO.set_command_idle(idle, 3);
      `MSTR_BFM_IO.set_command_init_latency(init_latency);
      `MSTR_BFM_IO.set_command_burst_size(burstcount);
      `MSTR_BFM_IO.set_command_burst_count(burstcount);
      `MSTR_BFM_IO.push_command();
   end

end

//--------------------------------------------------------------------------
//Read from CAR, CSR and Extended Feature Space registers
//--------------------------------------------------------------------------
initial begin
   @ read_register;
   master_set_and_push_command(REQ_READ, 26'h4c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h58, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h5c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h60, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h68, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h6c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h100, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h120, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h124, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h13c, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h158, 0, byte_enable, idle, init_latency);
   master_set_and_push_command(REQ_READ, 26'h15c, 0, byte_enable, idle, init_latency);
   print_info("Read some registers in DUT");
end
