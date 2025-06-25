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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_hps_monitor_bfm (
                              ACLK,
                              ARESETn,  
                              // Write address channel signal
                              AWID,
                              AWADDR,
                              AWLEN,
                              AWSIZE,
                              AWBURST,
                              AWLOCK,
                              AWCACHE,
                              AWPROT,
                              AWVALID,
                              AWREADY,
                              // Write data channel signal
                              WID,
                              WDATA,
                              WSTRB,
                              WLAST,
                              WVALID,
                              WREADY,
                              // Write response channel signal
                              BID,
                              BRESP,
                              BVALID,
                              BREADY,
                              // Read address channel signal
                              ARID,
                              ARADDR,
                              ARLEN,
                              ARSIZE,
                              ARBURST,
                              ARLOCK,
                              ARCACHE,
                              ARPROT,
                              ARVALID,
                              ARREADY,
                              // Read data channel signal
                              RID,
                              RDATA,
                              RRESP,
                              RLAST,
                              RVALID,
                              RREADY
                             );
                             
   // =head1 PARAMETERS
   parameter ID_W       = 4; 
   parameter ADDR_W     = 32; 
   parameter WDATA_W    = 32; 
   parameter RDATA_W    = 32; 


   localparam WSTRB_W            = WDATA_W >> 3;
   localparam ADDR_CH_DATA_W     = ID_W + ADDR_W + 18;
   localparam WDATA_CH_DATA_W    = ID_W + WDATA_W + WSTRB_W + 1;
   localparam RDATA_CH_DATA_W    = RDATA_W + ID_W + 3;
   localparam WRESP_CH_DATA_W    = ID_W + 2;

   localparam ST_NUMSYMBOLS      = 1;   
   localparam ST_CHANNEL_W       = 1;   
   localparam ST_ERROR_W         = 1;   
   localparam ST_EMPTY_W         = 1;   
      
   localparam ST_READY_LATENCY   = 0;   // Number of cycles latency after ready (0 or 1 only)
   localparam ST_MAX_CHANNELS    = 1;   // Maximum number of channels 
   localparam USE_PACKET         = 0;   // Use packet pins on interface
   localparam USE_CHANNEL        = 0;   // Use channel pins on interface
   localparam USE_ERROR          = 0;   // Use error pin on interface
   localparam USE_READY          = 1;   // Use ready pin on interface
   localparam USE_VALID          = 1;   // Use valid pin on interface
   localparam USE_EMPTY          = 0;   // Use empty pin on interface          
   
   localparam ST_BEATSPERCYCLE   = 1;   // Max number of packets per cycle   
   
   localparam INT_W = 32;
   localparam MAX_BURST_SIZE     = 16;
   
   // =cut
   // =head1 PINS
   // =head2 Clock Interface
   input                            ACLK;
   input                            ARESETn; 
   
   // =head2 Write address channel signal
   input [lindex(ID_W) : 0]         AWID;
   input [lindex(ADDR_W) : 0]       AWADDR;
   input [3 : 0]                    AWLEN;
   input [2 : 0]                    AWSIZE;
   input [1 : 0]                    AWBURST;
   input [1 : 0]                    AWLOCK;
   input [3 : 0]                    AWCACHE;
   input [2 : 0]                    AWPROT;
   input                            AWVALID;
   input                            AWREADY;
   
   // =head2 Write data channel signal
   input [lindex(ID_W) : 0]         WID;
   input [lindex(WDATA_W) : 0]      WDATA;
   input [lindex(WSTRB_W) : 0]      WSTRB;
   input                            WLAST;
   input                            WVALID;
   input                            WREADY;
   
   // =head2 Write response channel signal
   input [lindex(ID_W) : 0]         BID;
   input [1 : 0]                    BRESP;
   input                            BVALID;
   input                            BREADY;
   
   // =head2 Read address channel signal
   input [lindex(ID_W) : 0]         ARID;
   input [lindex(ADDR_W) : 0]       ARADDR;
   input [3 : 0]                    ARLEN;
   input [2 : 0]                    ARSIZE;
   input [1 : 0]                    ARBURST;
   input [1 : 0]                    ARLOCK;
   input [3 : 0]                    ARCACHE;
   input [2 : 0]                    ARPROT;
   input                            ARVALID;
   input                            ARREADY;
   
   // =head2 Read data channel signal
   input [lindex(ID_W) : 0]         RID;
   input [lindex(RDATA_W) : 0]      RDATA;
   input [1 : 0]                    RRESP;
   input                            RLAST;
   input                            RVALID;
   input                            RREADY;
   
   //--------------------------------------------------------------------------
   // Private Data Structures
   // All internal data types are packed. SystemVerilog struct or array 
   // slices can be accessed directly and can be assigned to a logic array 
   // in Verilog or a std_logic_vector in VHDL.
   // All dommand transactions expect an associated response transaction even
   // when no data is returned. For example, a write transaction returns a
   // response indicating completion of the command with a wait latency value.
   // In the case of a write transaction, the response descriptor field values
   // for data and read_latency are "don't care".
   //--------------------------------------------------------------------------
   
   // synthesis translate_off
   import verbosity_pkg::*;
   import altera_hps_pkg::*;
   
   //--------------------------------------------------------------------------
   // Private Types and Variables
   //--------------------------------------------------------------------------
   typedef logic [lindex(ID_W) : 0]                                  AxiID_t;
   typedef logic [lindex(ADDR_W) : 0]                                AxiAddress_t; 
   typedef logic [3 : 0]                                             AxiBurstLength_t;  
   typedef logic [2 : 0]                                             AxiBurstSize_t;  
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(WDATA_W) : 0]     AxiWriteData_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(RDATA_W) : 0]     AxiReadData_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(WSTRB_W) : 0]     AxiWriteStrobe_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][1 : 0]                   AxiResponse_t;
   typedef logic [31 : 0]                                            AxiAddrIdles_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][31 : 0]                  AxiDataIdles_t;
   typedef logic [4 : 0]                                             AxiUser_t;
   
   typedef struct packed
   {
      AxiID_t                    id;
      AxiAddress_t               address;
      AxiBurstLength_t           burst_length;
      AxiBurstSize_t             burst_size;
      AxiBurstType_t             burst_type;
      AxiLockType_t              lock;
      AxiCacheType_t             cache;
      AxiProtectionType_t        protection;
      AxiTransactionType_t       transaction_type;
      AxiWriteData_t             write_data;
      AxiWriteStrobe_t           write_strobe;
      AxiAddrIdles_t             addr_idles;
      AxiDataIdles_t             data_idles;
      AxiUser_t                  user;
   } AxiCommandTrans_t;
        
   typedef struct packed
   {
      AxiID_t                    id;
      AxiResponse_t              response;  
      AxiDataIdles_t             response_latency;
      AxiTransactionType_t       transaction_type;
      AxiReadData_t              read_data;
      AxiBurstLength_t           burst_length;
   } AxiResponseTrans_t;

   
   typedef struct packed 
   {
      AxiCommandTrans_t command;
      int   burst_index;
   } AxiWriteDataCommand_t;
   

   AxiBurstLength_t  write_data_burst_length_queue[$];
   AxiBurstLength_t  write_address_burst_length_queue[$];
   AxiBurstLength_t  current_write_data_burst_length;
   AxiBurstLength_t  current_write_address_burst_length;

   int               current_num_data_command;
   int               num_write_address_command_received;
   int               num_write_data_command_received;
   int               num_write_command_received;
   int               number_of_bytes_for_write;
   int               number_of_bytes_for_read;
   int               write_size_width;
   int               read_size_width;
   int               outstanding_read_transaction;
   int               outstanding_write_transaction;
   int               illegal_response_time;
   int               illegal_command_time;
   bit               final_unlocking_write_transaction;
   bit               final_unlocking_read_transaction;
   bit               hold_awvalid;
   bit               hold_wvalid;
   bit               hold_arvalid;
   bit               lock_read_access;
   bit               lock_write_access;
   bit               compare;
   AxiID_t           initial_lock_read_id;
   AxiID_t           initial_lock_write_id;
   AxiID_t           local_read_id[(2**ID_W)-1];
   AxiID_t           local_write_id[(2**ID_W)-1];
   AxiID_t           locked_read_id[(2**ID_W)-1];
   AxiID_t           locked_write_id[(2**ID_W)-1];
   int               outstanding_read_id_num[(2**ID_W)-1];
   int               outstanding_write_id_num[(2**ID_W)-1];
   
   AxiCommandTrans_t exclusive_write_command;
   AxiCommandTrans_t exclusive_read_command[(2**ID_W)];
   logic [lindex(ADDR_W) : 0] exclusive_id_address[(2**ID_W)];
   
   event __signal_illegal_response_transaction;
   // This event indicate that illegal response transaction happens
   
   event __signal_illegal_response_transaction_once_per_time;
   // This event only triggered once if __signal_illegal_response_transaction 
   // event triggered more than once at the same time.
   
   event __signal_illegal_command_transaction;
   // This event indicate that illegal command transaction happens
   
   event __signal_illegal_command_transaction_once_per_time;
   // This event only triggered once if __signal_illegal_command_transaction 
   // event triggered more than once at the same time.
   
   task automatic __init();
      // Initializes the AXI Slave interface.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      __init_descriptors();
      __init_queues();
   endtask
   
   function automatic void __init_descriptors();
      foreach (exclusive_read_command[size]) begin
         exclusive_read_command[size] = 'x;
      end
      
      foreach (exclusive_id_address[size]) begin
         exclusive_id_address[size] = 'x;
      end
      
      exclusive_write_command = 'x;
      current_write_data_burst_length = 0;
      current_write_address_burst_length = 0;
      current_num_data_command = 0;
      num_write_address_command_received = 0;
      num_write_data_command_received = 0;
      num_write_command_received = 0;
      outstanding_read_transaction = 0;
      outstanding_write_transaction = 0;

      foreach (local_write_id[size]) begin
         local_write_id[size] = 0;
      end
      foreach (local_read_id[size]) begin
         local_read_id[size] = 0;
      end
      foreach (outstanding_write_id_num[size]) begin
         outstanding_write_id_num[size] = 0;
      end
      foreach (outstanding_read_id_num[size]) begin
         outstanding_read_id_num[size] = 0;
      end

      number_of_bytes_for_write = 0;
      number_of_bytes_for_read = 0;
      initial_lock_read_id = 'x;
      initial_lock_write_id = 'x;
      foreach (locked_read_id[size]) begin
         locked_read_id[size] = 'x;
      end
      foreach (locked_write_id[size]) begin
         locked_write_id[size] = 'x;
      end
      lock_read_access = 0;
      lock_write_access = 0;

      final_unlocking_write_transaction = 0;
      final_unlocking_read_transaction = 0;
      hold_awvalid = 0;
      hold_wvalid = 0;
      hold_arvalid = 0;
      compare = 1;
      illegal_response_time = 0;
      illegal_command_time = 0;

   endfunction 
   
   function automatic void __init_queues();
      write_data_burst_length_queue = {};
      write_address_burst_length_queue = {};
   endfunction

   task __update_num_command_received();
      if (num_write_address_command_received > num_write_data_command_received) begin
         if (num_write_command_received < num_write_data_command_received) begin
            num_write_command_received++;
            outstanding_write_transaction++;
         end
      end else begin
         if (num_write_command_received < num_write_address_command_received) begin
            num_write_command_received++;
            outstanding_write_transaction++;
         end
      end
   endtask
   
   function automatic string __response_str(logic [1:0] response);
      case(response)
         0:  return "OKAY";
         1:  return "EXOKAY";
         2:  return "SLVERR";
         3:  return "DECERR";
      endcase 
   endfunction

   function automatic void __print_command_transaction(AxiCommandTrans_t command_trans, int id);
      $display("-----------------------------------------------------------------------------");
      $display("                    Command Transaction Details                              ");
      $display("-----------------------------------------------------------------------------");
      $display("Command Transaction Number   :  %0d", id);
      $display("ID                                                         :  %0d", command_trans.id);
      $display("Address                                                    :  %0d", command_trans.address);
      $display("Burst Length                                               :  %0d", command_trans.burst_length);
      $display("Burst Size                                                 :  %0d", command_trans.burst_size);
      $display("Burst Type                                                 :  %0s", command_trans.burst_type.name);
      $display("Lock                                                       :  %0s", command_trans.lock.name);
      $display("Cache                                                      :  %0s", command_trans.cache.name);
      $display("Protection                                                 :  %0s", command_trans.protection.name);
      $display("Transaction Type                                           :  %0s", command_trans.transaction_type.name);
      $display("Address No Operation                                       :  %0d", command_trans.addr_idles);
      $display("User                                                       :  %0d", command_trans.user);
      if (command_trans.burst_length == 0) begin
         $display("Write Data                                                 :  %0d", command_trans.write_data[0]);
         $display("Write Strobe                                               :  %0d", command_trans.write_strobe[0]);
         $display("Data No Operation                                          :  %0d", command_trans.data_idles[0]);
      end else begin
         $display("Write Data                                                 :  - ");
         for (int i = 0; i <= command_trans.burst_length; i++) begin
            $display("   Write Data           [%0d]                                :  %0d", i, command_trans.write_data[i]);
         end
         $display("Write Strobe                                               :  - ");
         for (int i = 0; i <= command_trans.burst_length; i++) begin
            $display("   Write Strobe         [%0d]                                :  %0d", i, command_trans.write_strobe[i]);
         end         
         $display("Data No Operation                                          :  - ");
         for (int i = 0; i <= command_trans.burst_length; i++) begin
            $display("   Data No Operation    [%0d]                                :  %0d", i, command_trans.data_idles[i]);
         end
      end
      $display("-----------------------------------------------------------------------------\n");
   endfunction
   
   function automatic void __print_response_transaction(AxiResponseTrans_t resp_trans, int id);
      $display("-----------------------------------------------------------------------------");
      $display("                    Response Transaction Details                             ");
      $display("-----------------------------------------------------------------------------");
      $display("Response Transaction Number   :  %0d", id);
      $display("ID                                                         :  %0d", resp_trans.id);
      $display("Burst Length                                               :  %0d", resp_trans.burst_length);
      $display("Transaction Type                                           :  %0s", resp_trans.transaction_type.name);
      if (resp_trans.burst_length == 0) begin
         $display("Response                                                   :  %0s", __response_str(resp_trans.response[0]));
         $display("Response Latency                                           :  %0d", resp_trans.response_latency[0]);
         $display("Read Data                                                  :  %0d", resp_trans.read_data[0]);
      end else begin
         $display("Response                                                   :  - ");
         for (int i = 0; i <= resp_trans.burst_length; i++) begin
            $display("   Response         [%0d]                                    :  %0s", i, __response_str(resp_trans.response[i]));
         end
         $display("Response Latency                                           :  - ");
         for (int i = 0; i <= resp_trans.burst_length; i++) begin
            $display("   Response Latency [%0d]                                    :  %0d", i, resp_trans.response_latency[i]);
         end
         $display("Read Data                                                  :  - ");
         for (int i = 0; i <= resp_trans.burst_length; i++) begin
            $display("   Read Data        [%0d]                                    :  %0d", i, resp_trans.read_data[i]);
         end
      end
      $display("-----------------------------------------------------------------------------\n");
   endfunction
   
   initial begin
      __init();
   end
   
   always @ (posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
         __init();
      end
   end
   
   // command's reserve value checking
   always @ (posedge ACLK or negedge ARESETn) begin
      if (AWVALID && AWREADY) begin
         if (!AWCACHE[1] && (AWCACHE[2] || AWCACHE[3])) begin
            $sformat(message, "%m: AWCACHE = %0h is a reserved value", AWCACHE);
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
         
         if (AWBURST == 3) begin
            $sformat(message, "%m: AWBURST = 3 is a reserved value");
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
         
         if (AWLOCK == 3) begin
            $sformat(message, "%m: AWLOCK = 3 is a reserved value");
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
      
      if (ARVALID && ARREADY) begin
         if (!ARCACHE[1] && (ARCACHE[2] || ARCACHE[3])) begin
            $sformat(message, "%m: ARCACHE = %0h is a reserved value", ARCACHE);
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
         
         if (ARBURST == 3) begin
            $sformat(message, "%m: ARBURST = 3 is a reserved value");
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
         
         if (ARLOCK == 3) begin
            $sformat(message, "%m: ARLOCK = 3 is a reserved value");
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
   end
   
   // exclusive access checking - response
   always @ (posedge ACLK or negedge ARESETn) begin
      if (BVALID && BREADY) begin
         if (BRESP == 1) begin
            if (BID !== exclusive_write_command.id) begin
               $sformat(message, "%m: An EXOKAY response should not be returned for a normal write access.");
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_response_transaction;
            end
         
            if (exclusive_read_command[BID] !== 'x && exclusive_id_address[BID] !== 'x) begin
               compare = (exclusive_write_command.burst_size === exclusive_read_command[BID].burst_size);
               compare &= (exclusive_write_command.burst_length === exclusive_read_command[BID].burst_length);
               compare &= (exclusive_write_command.id === exclusive_read_command[BID].id);
               compare &= (exclusive_write_command.address === exclusive_read_command[BID].address);
               compare &= (exclusive_write_command.burst_type === exclusive_read_command[BID].burst_type);
               compare &= (exclusive_write_command.lock === exclusive_read_command[BID].lock);
               compare &= (exclusive_write_command.cache === exclusive_read_command[BID].cache);
               compare &= (exclusive_write_command.protection === exclusive_read_command[BID].protection);
               if (!compare) begin
                  $sformat(message, "%m: Write response EXOKAY only allowed if the control signals for the read and write portions of the exclusive access are identical."); 
                  print(VERBOSITY_ERROR, message);
                  -> __signal_illegal_response_transaction;
               end
               exclusive_write_command = 'x;
               exclusive_read_command[BID] = 'x;
            end else if (exclusive_read_command[BID] !== 'x) begin
               $sformat(message, "%m: Write response EXOKAY is not allowed because the address location has been updated since the exclusive read."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_response_transaction;
            end else begin
               $sformat(message, "%m: Write response EXOKAY is not allowed before exclusive read access with read response EXOKAY happen for ID %0d.", BID); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_response_transaction;
            end
         end
      end
    end
   
   // exclusive access checking - number of bytes
   always @ (posedge ACLK or negedge ARESETn) begin
      if (RVALID && RREADY) begin
         if (RRESP != 1 && RID == exclusive_read_command[RID].id) begin
            exclusive_read_command[RID] = 'x;
         end
         if (RRESP == 1) begin
            if (RID !== exclusive_read_command[RID].id) begin
               $sformat(message, "%m: An EXOKAY response should not be returned for a normal read access.");
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_response_transaction;
            end
         end
      end
      if (AWVALID && AWREADY) begin
         number_of_bytes_for_write = 2**AWSIZE;
         if (AWLOCK == 1) begin
            if (AWADDR % number_of_bytes_for_write != 0) begin
               $sformat(message, "%m: The address of a write exclusion access must be aligned to the total number of bytes in the transaction. Address : %0d - number_of_bytes : %0d",
                        AWADDR, number_of_bytes_for_write); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (number_of_bytes_for_write % 2 != 0 && number_of_bytes_for_write != 1) begin
               $sformat(message, "%m: The numbers of bytes to be transferred in exclusion write access burst must be a power of 2. number_of_bytes : %0d",
                        number_of_bytes_for_write); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (number_of_bytes_for_write > 128) begin
               $sformat(message, "%m: The maximum numbers of bytes that can be transferred in exclusion write burst is 128. number_of_bytes : %0d",
                        number_of_bytes_for_write); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            
            exclusive_write_command = 'x;
            $cast(exclusive_write_command.burst_type, AWBURST);
            $cast(exclusive_write_command.lock, AWLOCK);
            $cast(exclusive_write_command.cache, AWCACHE);
            $cast(exclusive_write_command.protection, AWPROT);
            exclusive_write_command.burst_size = AWSIZE;
            exclusive_write_command.burst_length = AWLEN;
            exclusive_write_command.id = AWID;
            exclusive_write_command.address = AWADDR;
            exclusive_write_command.transaction_type = AXI_WRITE;
         end else begin
            foreach (exclusive_id_address[size]) begin
               if (exclusive_id_address[size] == AWADDR) begin
                  exclusive_id_address[size] = 'x;
               end
            end
         end
      end
      
      if (ARVALID && ARREADY) begin
         number_of_bytes_for_read = 2**ARSIZE;
         if (ARLOCK == 1) begin
            if (ARADDR % number_of_bytes_for_read != 0) begin
               $sformat(message, "%m: The address of a read exclusion access must be aligned to the total number of bytes in the transaction. Address : %0d - number_of_bytes : %0d",
                        ARADDR, number_of_bytes_for_read);
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (number_of_bytes_for_read % 2 != 0 && number_of_bytes_for_read != 1) begin
               $sformat(message, "%m: The number of bytes to be transferred in exclusion read access burst must be a power of 2. number_of_bytes : %0d",
                        number_of_bytes_for_read); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (number_of_bytes_for_read > 128) begin
               $sformat(message, "%m: The maximum number of bytes that can be transferred in an exclusion read burst is 128. number_of_bytes : %0d",
                        number_of_bytes_for_read); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            
            exclusive_read_command[ARID] = 'x;
            $cast(exclusive_read_command[ARID].burst_type, ARBURST);
            $cast(exclusive_read_command[ARID].lock, ARLOCK);
            $cast(exclusive_read_command[ARID].cache, ARCACHE);
            $cast(exclusive_read_command[ARID].protection, ARPROT);
            exclusive_read_command[ARID].burst_size = ARSIZE;
            exclusive_read_command[ARID].burst_length = ARLEN;
            exclusive_read_command[ARID].id = ARID;
            exclusive_read_command[ARID].address = ARADDR;
            exclusive_read_command[ARID].transaction_type = AXI_READ;
            exclusive_id_address[ARID] = ARADDR;
         end 
      end
   end
   
   // exclusive access checking - cacheable attribute
   always @ (posedge ACLK or negedge ARESETn) begin
      if (AWVALID && AWREADY) begin
         if (AWLOCK == 1 && AWCACHE[1]) begin
            $sformat(message, "%m: An exclusive write access should not have the cacheable attribute set."); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
       
      if (ARVALID && ARREADY) begin
         if (ARLOCK == 1 && ARCACHE[1]) begin
            $sformat(message, "%m: An exclusive read access should not have the cacheable attribute set."); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
   end
   
   // store the id 
   always @ (posedge ACLK or negedge ARESETn) begin
      if (RVALID && RREADY && RLAST) begin
         outstanding_read_transaction--;
      end
      if (AWVALID && AWREADY) begin
         outstanding_write_id_num[BID]--;
         local_write_id[AWID] = 1;
         if (AWLOCK == 2) begin
            if (outstanding_write_transaction > 0 && lock_write_access == 0) begin
               $sformat(message, "%m: Locked write access is not allowed when other outstanding write transactions waiting to complete."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (outstanding_read_transaction > 0 && lock_write_access == 0) begin
               $sformat(message, "%m: Locked write access is not allowed when other outstanding read transactions waiting to complete."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (lock_write_access == 0) begin
               lock_write_access = 1;
               initial_lock_write_id = AWID;
            end else if (AWID != initial_lock_write_id) begin
               $sformat(message, "%m: All transaction within a locked write sequence should have the same AWID value."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            final_unlocking_write_transaction = 0;
         end else begin
            if (lock_write_access == 1) begin
               if (AWLOCK == 1) begin
                  if (AWID == initial_lock_write_id) begin
                     $sformat(message, "%m: Exclusive write access is not allowed before unlock the write transaction."); 
                     print(VERBOSITY_ERROR, message);
                     -> __signal_illegal_command_transaction;
                  end
               end else begin
                  if (AWID == initial_lock_write_id) begin
                     if (outstanding_write_transaction > 0) begin
                        $sformat(message, "%m: All previous locked write transaction must complete before issuing the final unlocking write transaction."); 
                        print(VERBOSITY_ERROR, message);
                        -> __signal_illegal_command_transaction;
                     end

                     lock_write_access = 0;
                     initial_lock_write_id = 'x;
                     final_unlocking_write_transaction = 1;
                  end
               end
            end else begin
               if (final_unlocking_write_transaction == 1 && outstanding_write_transaction > 0) begin
                  $sformat(message, "%m: Final unlocking write transaction must fully completed before any further write transaction are commenced."); 
                  print(VERBOSITY_ERROR, message);
                  -> __signal_illegal_command_transaction;
               end
               final_unlocking_write_transaction = 0;
            end
            
            if (lock_read_access) begin
               if (AWLOCK == 0) begin
                  if (AWID == initial_lock_read_id) begin
                     if (outstanding_read_transaction > 0) begin
                        $sformat(message, "%m: All previous locked read transaction must complete before issuing the final unlocking write transaction."); 
                        print(VERBOSITY_ERROR, message);
                        -> __signal_illegal_command_transaction;
                     end
                     lock_read_access = 0;
                     initial_lock_read_id = 'x;
                     final_unlocking_read_transaction = 1;
                  end
               end
            end
         end
         num_write_address_command_received++;
         __update_num_command_received();
      end
      
      if (ARVALID && ARREADY) begin
         outstanding_read_id_num[ARID]++;
         local_read_id[ARID] = 1;
         if (ARLOCK == 2) begin
            if (outstanding_read_transaction > 0 && lock_read_access == 0) begin
               $sformat(message, "%m: Locked read access is not allowed when other outstanding read transactions waiting to complete."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (outstanding_write_transaction > 0 && lock_read_access == 0) begin
               $sformat(message, "%m: Locked read access is not allowed when other outstanding write transactions waiting to complete."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            if (lock_read_access == 0) begin
               lock_read_access = 1;
               locked_read_id[ARID] = 1;
               initial_lock_read_id = ARID;
            end else if (ARID != initial_lock_read_id) begin
               $sformat(message, "%m: All transaction within a locked read sequence should have the same ARID value."); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            final_unlocking_read_transaction = 0;
         end else begin
            if (lock_read_access == 1) begin
               if (ARLOCK == 1) begin
                  if (locked_read_id[ARID] == 1) begin
                     $sformat(message, "%m: Exclusive read access is not allowed before unlock the read transaction."); 
                     print(VERBOSITY_ERROR, message);
                     -> __signal_illegal_command_transaction;
                  end
               end else begin
                  if (ARID == initial_lock_read_id) begin
                     if (outstanding_read_transaction > 0) begin
                        $sformat(message, "%m: All previous locked read transaction must complete before issuing the final unlocking read transaction."); 
                        print(VERBOSITY_ERROR, message);
                        -> __signal_illegal_command_transaction;
                     end
                     lock_read_access = 0;
                     locked_read_id[ARID] = 0;
                     initial_lock_read_id = 'x;
                     final_unlocking_read_transaction = 1;
                  end
               end
            end else begin
               if (final_unlocking_read_transaction == 1 && outstanding_read_transaction > 0) begin
                  $sformat(message, "%m: Final unlocking read transaction must fully completed before any further read transaction are commenced."); 
                  print(VERBOSITY_ERROR, message);
                  -> __signal_illegal_command_transaction;
               end
               final_unlocking_read_transaction = 0;
            end
            if (lock_write_access) begin
               if (ARLOCK == 0) begin
                  if (ARID == initial_lock_write_id) begin
                     if (outstanding_write_transaction > 0) begin
                        $sformat(message, "%m: All previous locked write transaction must complete before issuing the final unlocking read transaction."); 
                        print(VERBOSITY_ERROR, message);
                        -> __signal_illegal_command_transaction;
                     end
                     lock_write_access = 0;
                     initial_lock_write_id = 'x;
                     final_unlocking_write_transaction = 1;
                  end
               end
            end
         end
      end
      if (ARVALID && ARREADY) begin
         outstanding_read_transaction++;
      end
   end
   
   // count the burst length value for write data channel
   always @ (posedge ACLK or negedge ARESETn) begin
      if (WVALID && WREADY) begin
         current_num_data_command++;
      end
      
      if (WLAST && WREADY && WVALID) begin
         write_data_burst_length_queue.push_front(current_num_data_command-1);

         current_num_data_command = 0;
      end
      if (current_num_data_command >= MAX_BURST_SIZE) begin
         $sformat(message, "%m: WLAST not asserted while the number of write data received exceed Max Burst Size: %0d.",
                  current_num_data_command+1); 
         print(VERBOSITY_ERROR, message);
         -> __signal_illegal_command_transaction;
      end
   end

   // sampled the burst length value for write address channel
   always @ (posedge ACLK or negedge ARESETn) begin
      if (AWVALID && AWREADY) begin
         write_address_burst_length_queue.push_front(AWLEN);
      end
   end
   
   // check the burst length value sent by write address channel match the 
   // number of write data received
   always @ (posedge ACLK or negedge ARESETn) begin
      if (write_data_burst_length_queue.size() > 0 && write_address_burst_length_queue.size() > 0) begin
         current_write_data_burst_length = write_data_burst_length_queue.pop_back();
         current_write_address_burst_length = write_address_burst_length_queue.pop_back();
         if (current_write_address_burst_length != current_write_data_burst_length) begin
            $sformat(message, "%m: number of write data received missmatch with write address burst length: %0d : %0d",
                     current_write_data_burst_length, current_write_address_burst_length); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
   end
   
   // check command's burst size to the data width
   always @ (posedge ACLK or negedge ARESETn) begin
      if (AWVALID && AWREADY) begin
         write_size_width = 2**(AWSIZE + 3);
         if (write_size_width > WDATA_W) begin
            $sformat(message, "%m: Write burst size exceed the write data bus width"); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
      
      if (ARVALID && ARREADY) begin
         read_size_width = 2**(ARSIZE + 3);
         if (read_size_width > RDATA_W) begin
            $sformat(message, "%m: Read burst size exceed the read data bus width"); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_command_transaction;
         end
      end
   end
   
   // check wrapping burst command
   always @ (posedge ACLK or negedge ARESETn) begin
      if (AWVALID && AWREADY) begin
         number_of_bytes_for_write = 2**AWSIZE;
         if (AWBURST == 2) begin
            if (AWADDR % number_of_bytes_for_write != 0) begin
               $sformat(message, "%m: Wrapping write burst address must be align to the size of transfer"); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            
            if (!(AWLEN == 1 || AWLEN == 3 || AWLEN == 7 || AWLEN == 15)) begin
               $sformat(message, "%m: Wrapping write burst length must be either 1, 3, 7 or 15"); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
         end
      end
       if (ARVALID && ARREADY) begin
         number_of_bytes_for_read = 2**ARSIZE;
         if (ARBURST == 2) begin
            if (ARADDR % number_of_bytes_for_read != 0) begin
               $sformat(message, "%m: Wrapping read burst address must be align to the size of transfer");
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
            
            if (!(ARLEN == 1 || ARLEN == 3 || ARLEN == 7 || ARLEN == 15)) begin
               $sformat(message, "%m: Wrapping read burst length must be either 1, 3, 7 or 15"); 
               print(VERBOSITY_ERROR, message);
               -> __signal_illegal_command_transaction;
            end
         end
      end
   end
   
   always @ (posedge ACLK or negedge ARESETn) begin
      if (WVALID && WREADY && WLAST) begin
         num_write_data_command_received++;
         __update_num_command_received();
      end

      if (BVALID && BREADY) begin
         outstanding_write_transaction--;
      end
   end
   
      // assert error if awvalid is deasserted before awready asserted
   always @(posedge ACLK or negedge ARESETn) begin
      if (AWVALID && !AWREADY) begin
         hold_awvalid = 1;
      end
      
      if (AWVALID && AWREADY) begin
         hold_awvalid = 0;
      end
      
      if (hold_awvalid && !AWVALID) begin
         $sformat(message, "%m: AWVALID deasserted before AWREADY asserted."); 
         print(VERBOSITY_ERROR, message);
         -> __signal_illegal_command_transaction;
      end 
   end
   
      // assert error if wvalid is deasserted before wready asserted
   always @(posedge ACLK or negedge ARESETn) begin
      if (WVALID && !WREADY) begin
         hold_wvalid = 1;
      end
      
      if (WVALID && WREADY) begin
         hold_wvalid = 0;
      end
      
      if (hold_wvalid && !WVALID) begin
         $sformat(message, "%m: WVALID deasserted before WREADY asserted."); 
         print(VERBOSITY_ERROR, message);
         -> __signal_illegal_command_transaction;
      end 
   end
   
   // assert error if arvalid is deasserted before arready asserted
   always @(posedge ACLK or negedge ARESETn) begin
      if (ARVALID && !ARREADY) begin
         hold_arvalid = 1;
      end
      
      if (ARVALID && ARREADY) begin
         hold_arvalid = 0;
      end
      
      if (hold_arvalid && !ARVALID) begin
         $sformat(message, "%m: ARVALID deasserted before ARREADY asserted."); 
         print(VERBOSITY_ERROR, message);
         -> __signal_illegal_command_transaction;
      end 
   end
   
   always @(posedge ACLK or negedge ARESETn) begin
      if (BVALID && BREADY) begin
         if (local_write_id[BID] == 0) begin
            $sformat(message, "%m: Write response with ID %0d not allowed before write command with same ID accepted", BID); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_response_transaction;
         end else begin
            if (outstanding_write_id_num[BID] == 1)
               local_write_id[BID] = 0;
            outstanding_write_id_num[BID]--;
         end
      end
      
      if (RVALID && RREADY) begin
         if (local_read_id[RID] == 0) begin
            $sformat(message, "%m: Read response with ID %0d not allowed before read command with same ID accepted", RID); 
            print(VERBOSITY_ERROR, message);
            -> __signal_illegal_response_transaction;
         end else begin
            if (RLAST) begin
               if (outstanding_read_id_num[RID] == 1)
                  local_read_id[RID] = 0;
               outstanding_read_id_num[RID]--;
            end
         end
      end
   end
   
   always @(__signal_illegal_response_transaction) begin
      if (illegal_response_time != $time()) 
         -> __signal_illegal_response_transaction_once_per_time;
      illegal_response_time = $time();
   end
   
   always @(__signal_illegal_command_transaction) begin
      if (illegal_command_time != $time()) 
         -> __signal_illegal_command_transaction_once_per_time;
      illegal_command_time = $time();
   end
   
   // synthesis translate_on
   
endmodule
