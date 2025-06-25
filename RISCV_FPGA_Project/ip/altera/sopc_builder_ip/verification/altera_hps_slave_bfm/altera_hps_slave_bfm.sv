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

module altera_hps_slave_bfm (
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
                              AWUSER,
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
                              ARUSER,
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
   
   parameter MAX_OUTSTANDING_READS = 8;
   parameter MAX_OUTSTANDING_WRITES = 8;
   parameter MAX_OUTSTANDING_TRANSACTIONS = 16;
   parameter ENABLE_AUTO_BACKPRESSURE = 0;

   localparam WSTRB_W            = WDATA_W >> 3;
   localparam ADDR_CH_DATA_W     = ID_W + ADDR_W + 23;
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
   output                           AWREADY;
   input [4 : 0]                    AWUSER;
   
   // =head2 Write data channel signal
   input [lindex(ID_W) : 0]         WID;
   input [lindex(WDATA_W) : 0]      WDATA;
   input [lindex(WSTRB_W) : 0]      WSTRB;
   input                            WLAST;
   input                            WVALID;
   output                           WREADY;
   
   // =head2 Write response channel signal
   output [lindex(ID_W) : 0]        BID;
   output [1 : 0]                   BRESP;
   output                           BVALID;
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
   output                           ARREADY;
   input [4 : 0]                    ARUSER;
   
   // =head2 Read data channel signal
   output [lindex(ID_W) : 0]        RID;
   output [lindex(RDATA_W) : 0]     RDATA;
   output [1 : 0]                   RRESP;
   output                           RLAST;
   output                           RVALID;
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
   
   logic                            AWREADY;
   logic                            WREADY;
   logic [lindex(ID_W) : 0]         BID;
   logic [1 : 0]                    BRESP;
   logic                            BVALID;
   logic                            ARREADY;
   logic [lindex(ID_W) : 0]         RID;
   logic [lindex(RDATA_W) : 0]      RDATA;
   logic [1 : 0]                    RRESP;
   logic                            RLAST;
   logic                            RVALID;
   
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
   
   logic [lindex(ADDR_CH_DATA_W):0]    write_address_channel_data;
   logic [lindex(WDATA_CH_DATA_W):0]   write_data_channel_data;
   logic [lindex(ADDR_CH_DATA_W):0]    read_address_channel_data;
   logic [lindex(WRESP_CH_DATA_W):0]   write_response_channel_data;
   logic [lindex(RDATA_CH_DATA_W):0]   read_data_channel_data;
   
   typedef struct packed 
   {
      AxiCommandTrans_t command;
      int   burst_index;
   } AxiWriteDataCommand_t;
   
   AxiResponseTrans_t         new_response;
   AxiResponseTrans_t         response_info_queue[$];
   AxiResponseTrans_t         response_info;
   AxiCommandTrans_t          current_write_address_command;
   AxiCommandTrans_t          current_write_data_command;
   AxiCommandTrans_t          current_read_address_command;
   AxiCommandTrans_t          current_write_command;
   AxiCommandTrans_t          current_command;
   AxiCommandTrans_t          write_data_command_queue[$];
   AxiWriteDataCommand_t      local_write_data_command;
   AxiBurstLength_t           burst_length_queue[$];
   AxiBurstLength_t           read_data_burst_length_queue[$];
   AxiBurstLength_t           write_response_burst_length_queue[$];
   AxiBurstLength_t           current_burst_length;
   AxiBurstLength_t           read_data_burst_length;
   bit                        axi_ready_mode = 0;
   int                        awready_after_valid_cycles;
   int                        wready_after_valid_cycles;
   int                        arready_after_valid_cycles;
   int                        command_timeout = 100;
   int                        local_command_timeout;
   int                        current_num_data_command;
   int                        num_write_address_command_received;
   int                        num_write_data_command_received;
   int                        num_write_command_received;
   int                        num_of_response_completed;
   int                        outstanding_write_address_transaction;
   int                        outstanding_write_data_transaction;
   int                        outstanding_read_transaction;
   int                        outstanding_transaction;

   
   event  __signal_deassert_awready;
   event  __signal_set_awready;
   event  __signal_deassert_wready;
   event  __signal_set_wready;
   event  __signal_deassert_arready;
   event  __signal_set_arready;
   event  __signal_set_awready_wait_for_valid;
   event  __signal_set_wready_wait_for_valid;
   event  __signal_set_arready_wait_for_valid;
   
   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). The application program interface provides methods for 
   // a testbench which instantiates, controls and queries state in this BFM 
   // component. Test programs must only use these public access methods and 
   // events to communicate with this BFM component. The API and module pins
   // are the only interfaces of this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------

   event signal_aw_transaction_received; //public
   // This event indicate that BFM received a write address transaction
   
   event signal_w_transaction_received; //public
   // This event indicate that BFM received a write data transaction
   
   event signal_ar_transaction_received; //public
   // This event indicate that BFM received a read address transaction
   
   event signal_complete_write_command_received; //public
   // This event indicate that BFM received a complete write transaction
   
   event signal_read_response_issued; //public
   // This event indicate that BFM is driving a read response transaction on 
   // the AXI interface
   
   event signal_write_response_issued; //public
   // This event indicate that BFM is driving a write response transaction on 
   // the AXI interface
   
   event signal_fatal_error;
   // Signal that a fatal error has occurred. Terminates simulation.
   
   function automatic void do_write_response( // public
      AxiID_t              id,
      AxiResponse_t        response,
      AxiDataIdles_t       response_latency
   );
      // Sets the write response, response id and response latency to build
      // complete write response transaction to the response descriptor.
      
      new_response.id = id;
      $cast(new_response.response[0], response[0]);
      new_response.response_latency = response_latency[0];
      new_response.transaction_type = AXI_WRITE;
      new_response.burst_length = 0;
      new_response.read_data = 'x;
      push_response();
      
   endfunction 
   
   function automatic void do_read_response( // public
      AxiID_t              id,
      AxiResponse_t        response,
      AxiDataIdles_t       response_latency,
      AxiReadData_t        read_data,
      AxiBurstLength_t     burst_length
   );
      // Sets the read response, response id, response latency, read data
      // burst length to build a complete read response transaction to the 
      // response descriptor. The read response, read data and response 
      // latency must in array format and the array size should be same as
      // burst length value.
      
      new_response.id = id;
      new_response.transaction_type = AXI_READ;
      new_response.burst_length = burst_length;
      $cast(new_response.response, response);
      for (int i = 0; i <= burst_length; i++) begin
         new_response.response_latency[i] = response_latency[i];
         new_response.read_data[i] = read_data[i];
      end
      push_response();
      
   endfunction 
   
   function automatic int get_write_address_transaction_queue_size(); // public
      // Queries the write address command queue to determine number of 
      // write address command descriptors currently stored in the BFM.
      // This is the number of write address command the test program can 
      // immediately pop off the response queue for further processing.
      
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      
      return write_address_channel_bfm.get_transaction_queue_size();
   endfunction 
   
   function automatic int get_write_data_transaction_queue_size(); // public
      // Queries the write data command queue to determine number of 
      // write data command descriptors currently stored in the BFM.
      // This is the number of write data command the test program can 
      // immediately pop off the response queue for further processing.
      
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      
      return write_data_command_queue.size();
   endfunction 
   
   function automatic int get_write_transaction_queue_size(); // public
      // Queries the write command queue to determine number of 
      // write command descriptors currently stored in the BFM.
      // This is the number of write command the test program can 
      // immediately pop off the response queue for further processing.
      
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      
      if (get_write_data_transaction_queue_size() > get_write_address_transaction_queue_size())
         return get_write_address_transaction_queue_size();
      else
         return get_write_data_transaction_queue_size();
   endfunction 
   
   function automatic int get_read_address_transaction_queue_size(); // public
      // Queries the read address command queue to determine number of 
      // read address command descriptors currently stored in the BFM.
      // This is the number of read address command the test program can 
      // immediately pop off the response queue for further processing.
      
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      
      return read_address_channel_bfm.get_transaction_queue_size();
   endfunction 
   
   function automatic void assert_awready( // public
   );
      // Assert the interface awready signal synchronously with ACLK.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_awready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_set_awready;
      
   endfunction 
   
   function automatic void assert_awready_after_valid_asserted( // public
      logic [31:0]      cycles
   );
      // Assert the interface awready signal certan clock cycles later after awvalid 
      // been asserted. cycles value of one is not supported.
      // Been ignored if ENABLE_AUTO_BACKPRESSURE = 1.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_awready_after_valid_asserted() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else begin 
         if (cycles == 0) begin
            $sformat(message, "%m: cycles of zero is not supported. Set the cycles to one.");
            print(VERBOSITY_WARNING, message);
            cycles = 1;
         end
         awready_after_valid_cycles = cycles;
         -> __signal_set_awready_wait_for_valid;
      end
      
   endfunction 
   
   function automatic void deassert_awready( // public
   );
      // Deassert the interface awready signal synchronously with ACLK.
      // Been ignored if ENABLE_AUTO_BACKPRESSURE = 1.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: deassert_awready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_deassert_awready;
      
   endfunction 
   
   function automatic void assert_wready( // public
   );
      // Assert the interface wready signal synchronously with ACLK.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_wready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_set_wready;
      
   endfunction 
   
   function automatic void assert_wready_after_valid_asserted( // public
      logic [31:0]      cycles
   );
      // Assert the interface wready signal certan clock cycles later after wvalid 
      // been asserted. cycles value of one is not supported.
      // Been ignored if ENABLE_AUTO_BACKPRESSURE = 1.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_wready_after_valid_asserted() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else begin 
         if (cycles == 0) begin
            $sformat(message, "%m: cycles of zero is not supported. Set the cycles to one.");
            print(VERBOSITY_WARNING, message);
            cycles = 1;
         end
         wready_after_valid_cycles = cycles;
         -> __signal_set_wready_wait_for_valid;
      end
      
   endfunction 
   
   function automatic void deassert_wready( // public
   );
      // Deassert the interface wready signal synchronously with ACLK.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: deassert_wready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_deassert_wready;
      
   endfunction 
   
   function automatic void assert_arready( // public
   );
      // Deassert the interface arready signal synchronously with ACLK.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_arready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_set_arready;
      
   endfunction 
   
   function automatic void assert_arready_after_valid_asserted( // public
      logic [31:0]      cycles
   );
      // Assert the interface arready signal certan clock cycles later after arvalid 
      // been asserted. cycles value of one is not supported.
      // Been ignored if ENABLE_AUTO_BACKPRESSURE = 1.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: assert_arready_after_valid_asserted() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else begin 
         if (cycles == 0) begin
            $sformat(message, "%m: cycles of zero is not supported. Set the cycles to one.");
            print(VERBOSITY_WARNING, message);
            cycles = 1;
         end
         arready_after_valid_cycles = cycles;
         -> __signal_set_arready_wait_for_valid;
      end
      
   endfunction 
   
   function automatic void deassert_arready( // public
   );
      // Deassert the interface arready signal synchronously with ACLK.
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: deassert_arready() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         -> __signal_deassert_arready;
      
   endfunction
   
   function automatic AxiID_t get_command_id(AxiCommandType_t command_type); // public
      // Return the id in the command transaction. 
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WDATA indicates it is write data command.
      // command_type CMD_WCOMPLETE indicates it is full write command.       
      $sformat(message, "%m: called get_command_id, command_type: %0s", command_type);
      print(VERBOSITY_DEBUG, message);
      
      current_command = __get_command(command_type);
      
      return current_command.id;
   endfunction
   
   function automatic AxiAddress_t get_command_address(AxiCommandType_t command_type); // public
      // Return the address in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have address information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_address, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.address;
   endfunction
   
   function automatic AxiBurstLength_t get_command_burst_length(AxiCommandType_t command_type); // public
      // Return the burst_length in the transaction  
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have burst length information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_burst_length, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.burst_length;
   endfunction
   
   function automatic AxiBurstSize_t get_command_burst_size(AxiCommandType_t command_type); // public
      // Return the burst_size in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have burst size information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_burst_size, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.burst_size;
   endfunction
   
   function automatic AxiBurstType_t get_command_burst_type(AxiCommandType_t command_type); // public
      // Return the burst_type in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have burst length information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_burst_type, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.burst_type;
   endfunction
   
   function automatic AxiLockType_t get_command_lock(AxiCommandType_t command_type); // public
      // Return the lock in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have burst length information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_lock, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.lock;
   endfunction
   
   function automatic AxiCacheType_t get_command_cache(AxiCommandType_t command_type); // public
      // Return the cache in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have cache information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_cache, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.cache;
   endfunction
   
   function automatic AxiProtectionType_t get_command_protection(AxiCommandType_t command_type); // public
      // Return the protection in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command.  
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have protection information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_protection, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.protection;
   endfunction
   
   function automatic AxiDataIdles_t get_command_write_data_idles( // public
      int index
   );
      // Return the data_idles in the transaction.
      AxiCommandType_t command_type = CMD_WDATA;
      $sformat(message, "%m: called get_command_write_data_idles, index: %0d",
               index);
      print(VERBOSITY_DEBUG, message);

      current_command = __get_command(command_type);
      
      if (__check_transaction_index(index))
         return current_command.data_idles[index];
      else
         return('x);

   endfunction
   
   function automatic AxiAddrIdles_t get_command_address_idles(AxiCommandType_t command_type); // public
      // Return the addr_idles in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have address idle information.", command_type);
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: called get_command_address_idles, command_type: %0s", command_type);
         print(VERBOSITY_DEBUG, message);
      end
      
      current_command = __get_command(command_type);
      
      return current_command.addr_idles;
   endfunction
   
   function automatic AxiTransactionType_t get_command_transaction_type(AxiCommandType_t command_type); // public
      // Return the transaction_type in the transaction.
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WDATA indicates it is write data command.  
      // command_type CMD_WCOMPLETE indicates it is full write command.
      $sformat(message, "%m: called get_command_transaction_type, command_type: %0s", command_type);
      print(VERBOSITY_DEBUG, message);
      
      current_command = __get_command(command_type);
      if (current_command.transaction_type == AXI_READ)
         return AXI_READ;
      else
         return AXI_WRITE;
      
   endfunction
   
   function automatic AxiWriteData_t get_command_write_data( // public
      int index
   );  
      // Return the write_data in the transaction.
      AxiCommandType_t command_type = CMD_WDATA;
      
      $sformat(message, "%m: called get_command_write_data, index: %0d",
               index);
      print(VERBOSITY_DEBUG, message);
      
      current_command = __get_command(command_type);
      
      if (__check_transaction_index(index))
         return current_command.write_data[index];
      else
         return('x);
      
   endfunction
   
   function automatic AxiWriteStrobe_t get_command_write_strobe( // public
      int index
   );  
      // Return the write_strobe in the transaction.
      AxiCommandType_t command_type = CMD_WDATA;
      
      $sformat(message, "%m: called get_command_write_strobe, index: %0d", 
               index);
      print(VERBOSITY_DEBUG, message);
      
      current_command = __get_command(command_type);
      
      if (__check_transaction_index(index))
         return current_command.write_strobe[index];
      else
         return('x);

   endfunction
   
   function automatic AxiAddrIdles_t get_command_user(AxiCommandType_t command_type); // public
      // Return the user sideband signal's value
      // command_type CMD_WADDRESS indicates it is write address command. 
      // command_type CMD_RADDRESS indicates it is read address command. 
      // command_type CMD_WCOMPLETE indicates it is full write command.
      if (command_type == CMD_WDATA) begin
         $sformat(message, "%m: command_type %0s does not have sideband signals information.", command_type);
         print(VERBOSITY_WARNING, message);
      end
      $sformat(message, "%m: called get_command_user, command_type: %0s", command_type);
      print(VERBOSITY_DEBUG, message);
      
      current_command = __get_command(command_type);
      
      return current_command.user;
   endfunction
   
   function automatic void pop_write_channel_transaction(); // public
      // Pop the complete write transaction descriptor from the queue so that 
      // it can be queried with the get_command_ methods by the test bench.
      if (!ARESETn) begin
          $sformat(message, "%m: Illegal command while ARESETn asserted"); 
          print(VERBOSITY_ERROR, message);
          ->signal_fatal_error; 
      end
      
      pop_write_address_channel_transaction();
      pop_write_data_channel_transaction();
      
      if (get_command_id(CMD_WADDRESS) !== get_command_id(CMD_WDATA)) begin
          $sformat(message, "%m: ID mismatch for write address channel and write data channel - %0d : %0d ",
                  get_command_id(CMD_WADDRESS), get_command_id(CMD_WDATA)); 
          print(VERBOSITY_ERROR, message);
      end
      
      current_write_command.id               = get_command_id(CMD_WADDRESS);
      current_write_command.address          = get_command_address(CMD_WADDRESS);
      current_write_command.burst_length     = get_command_burst_length(CMD_WADDRESS);
      current_write_command.burst_size       = get_command_burst_size(CMD_WADDRESS);
      current_write_command.burst_type       = get_command_burst_type(CMD_WADDRESS);
      current_write_command.lock             = get_command_lock(CMD_WADDRESS);
      current_write_command.cache            = get_command_cache(CMD_WADDRESS);
      current_write_command.protection       = get_command_protection(CMD_WADDRESS);
      current_write_command.transaction_type = AXI_WRITE;
      current_write_command.addr_idles       = get_command_address_idles(CMD_WADDRESS);
      current_write_command.user             = get_command_user(CMD_WADDRESS);
      for (int i = 0; i <= current_write_command.burst_length; i++) begin
         current_write_command.write_data       = get_command_write_data(.index(i));
         current_write_command.write_strobe     = get_command_write_strobe(.index(i));
         current_write_command.data_idles       = get_command_write_data_idles(.index(i));
      end
      
   endfunction
   
   function automatic void pop_write_address_channel_transaction(); // public
      // Pop the write address command transaction descriptor from the queue 
      // so that it can be queried with the get_command methods by the 
      // test bench.
      if (!ARESETn) begin
          $sformat(message, "%m: Illegal command while ARESETn asserted"); 
          print(VERBOSITY_ERROR, message);
          ->signal_fatal_error; 
      end
      
      if (write_address_channel_bfm.get_transaction_queue_size() > 0) begin
         write_address_channel_bfm.pop_transaction();
         current_write_address_command = __get_transaction(CMD_WADDRESS, 0);
         $sformat(message, "%m: pop_write_address_channel_transaction. "); 
         print(VERBOSITY_DEBUG, message);
      end else begin
         $sformat(message, "%m: write_address_channel_command_queue is empty. "); 
         print(VERBOSITY_ERROR, message);
      end
      
   endfunction
   
   function automatic void pop_write_data_channel_transaction(); // public
      // Pop the write data transaction descriptor from the queue so that 
      // it can be queried with the get_command_ methods by the test bench.
      if (!ARESETn) begin
          $sformat(message, "%m: Illegal command while ARESETn asserted"); 
          print(VERBOSITY_ERROR, message);
          ->signal_fatal_error; 
      end
      
      if (get_write_data_transaction_queue_size() > 0) begin
         current_write_data_command = write_data_command_queue.pop_back();
      end else begin
         $sformat(message, "%m: write_data_channel_command_queue is empty. "); 
         print(VERBOSITY_ERROR, message);
      end
      
   endfunction
   
   function automatic void pop_read_address_channel_transaction(); // public
      // Pop the read address transaction descriptor from the queue so that 
      // it can be queried with the get_command methods by the test bench.
      if (!ARESETn) begin
          $sformat(message, "%m: Illegal command while ARESETn asserted"); 
          print(VERBOSITY_ERROR, message);
          ->signal_fatal_error; 
      end
      
      if (read_address_channel_bfm.get_transaction_queue_size() > 0) begin
         read_address_channel_bfm.pop_transaction();
         current_read_address_command = __get_transaction(CMD_RADDRESS, 0);
      end else begin
         $sformat(message, "%m: read_address_channel_command_queue is empty. "); 
         print(VERBOSITY_ERROR, message);
      end
      
   endfunction
   
   function automatic void set_response_id( // public
      AxiID_t  id
   );
      // Set the response id value
      $sformat(message, "%m: called set_response_id - %0h", id);
      print(VERBOSITY_DEBUG, message);

      new_response.id = id;
   endfunction
   
   function automatic void set_response( // public
      AxiResponseType_t response,
      int index
   );
      // Set the response value
      $sformat(message, "%m: called set_response - %0h", response);
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_response.response[index] = response;
      
   endfunction
   
   function automatic void set_response_latency( // public
      int   response_latency,
      int   index
   );
      // Set the response response_latency value
      $sformat(message, "%m: called set_response_latency - %0h, index - %0h", 
               response_latency, index);
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_response.response_latency[index] = response_latency;
      
   endfunction
   
   function automatic void set_response_transaction_type( // public
      AxiTransactionType_t transaction_type
   );
      // Set the response transaction_type value
      $sformat(message, "%m: called set_response_transaction_type - %0s", transaction_type);
      print(VERBOSITY_DEBUG, message);
      new_response.transaction_type = transaction_type;
   endfunction
   
   function automatic void set_response_read_data( // public
      logic [lindex(RDATA_W) : 0]   read_data,
      int                           index
   );
      // Set the response read_data value
      $sformat(message, "%m: called set_response_read_data - %0h", read_data);
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_response.read_data[index] = read_data;
     
   endfunction
   
   function automatic void set_response_burst_length( // public
      AxiBurstLength_t  burst_length
   );
      // Set the response burst_length value
      $sformat(message, "%m: called set_response_burst_length - %0h", burst_length);
      print(VERBOSITY_DEBUG, message);

      new_response.burst_length = burst_length;
   endfunction
   
   function automatic void push_response(); // public
      // Push the fully populated response transaction descriptor onto
      // response queue. The BFM will pop response descriptors off the
      // queue as soon as they are available, read them and drive the
      // AXI interface response plane.
      logic [lindex(RDATA_CH_DATA_W):0] temp_data;

      $sformat(message, "%m: push response");
      print(VERBOSITY_DEBUG, message);
      response_info_queue.push_front(new_response);
      if (!ARESETn) begin
         $sformat(message, "%m: Illegal response while ARESETn asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      
      temp_data                     = 'x;
      temp_data[lindex(ID_W)+2 : 2] = new_response.id;
      if (new_response.transaction_type == AXI_WRITE) begin
         new_response.burst_length = 0;
      end
      
      for (int i = 0; i <= new_response.burst_length; i++) begin
         if (new_response.transaction_type == AXI_WRITE) begin
            temp_data[1 : 0]  = new_response.response[0];
            write_response_channel_bfm.set_transaction_data(temp_data);
            write_response_channel_bfm.set_transaction_idles(new_response.response_latency[i]);
            write_response_channel_bfm.push_transaction();
         end else begin
            temp_data[lindex(ID_W)+lindex(RDATA_W)+3 : lindex(ID_W)+3] = new_response.read_data[i];
            temp_data[1 : 0]  = new_response.response[i];
            if (i == new_response.burst_length)
               temp_data[lindex(ID_W)+lindex(RDATA_W)+4 : lindex(ID_W)+lindex(RDATA_W)+4] = 1;
            else
               temp_data[lindex(ID_W)+lindex(RDATA_W)+4 : lindex(ID_W)+lindex(RDATA_W)+4] = 0;
            read_data_channel_bfm.set_transaction_data(temp_data);
            read_data_channel_bfm.set_transaction_idles(new_response.response_latency[i]);
            read_data_channel_bfm.push_transaction();
         end
      end
      
      if (new_response.transaction_type == AXI_READ) begin
         read_data_burst_length_queue.push_front(new_response.burst_length);
      end else begin
         write_response_burst_length_queue.push_front(new_response.burst_length);
      end

   endfunction
   
   function automatic void set_ready_deassertion_mode( // public
      bit   ready_mode
   );
      // Set the Slave BFM ready mode.
      // 0 means once awready/wready/arready signals are asserted, it will 
      // maintain asserted until user deassert the signals.
      // 1 means awready/wready/arready signals will be auto deasserted when
      // receive a valid transaction for corresponding channels.
      $sformat(message, "%m: called set_ready_deassertion_mode - %0h", ready_mode);
      print(VERBOSITY_DEBUG, message);
      if (ENABLE_AUTO_BACKPRESSURE == 1) begin
         $sformat(message, "%m: set_ready_deassertion_mode() been ignored when ENABLE_AUTO_BACKPRESSURE = 1.");
         print(VERBOSITY_WARNING, message);
      end else
         axi_ready_mode = ready_mode;
   endfunction
   
   function automatic void set_command_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse before command time out
      // Disable timeout by setting the value to 0.
      command_timeout = cycles;
      if (cycles == 0) begin
         $sformat(message, "%m: set to %0d cycles - disabled", 
                  command_timeout);
      end else begin
         $sformat(message, "%m: set to %0d cycles", 
                  command_timeout);
      end
      print(VERBOSITY_INFO, message);      
   endfunction  
   
   function automatic void set_response_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse before response time out
      // Disable timeout by setting the value to 0.
      write_response_channel_bfm.set_response_timeout(cycles);
      read_data_channel_bfm.set_response_timeout(cycles);
    
   endfunction  
   
   //--------------------------------------------------------------------------
   // Private Methods
   // Note that private methods and events are prefixed with '__'   
   //--------------------------------------------------------------------------
   
   function automatic AxiCommandTrans_t __get_command(AxiCommandType_t command_type);
      if (command_type == CMD_WADDRESS) 
         return current_write_address_command;
      else if (command_type == CMD_RADDRESS) 
         return current_read_address_command;
      else if (command_type == CMD_WDATA)
         return current_write_data_command;
      else
         return current_write_command;
   endfunction
  
   task automatic __init();
      // Initializes the AXI Slave interface.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      __init_descriptors();
      __init_queues();
   endtask
   
   function automatic void __init_descriptors();
      new_response                           = 'x;
      response_info                          = 'x;
      current_command                        = 'x;
      current_write_address_command          = 'x;
      current_write_data_command             = 'x;
      current_read_address_command           = 'x;
      current_write_command                  = 'x;
      local_write_data_command.command       = 'x;
      local_write_data_command.burst_index   = 0;
      
      current_burst_length                   = 0;
      current_num_data_command               = 0;
      num_write_address_command_received     = 0;
      num_write_data_command_received        = 0;
      num_write_command_received             = 0;
      num_of_response_completed              = 0;
      read_data_burst_length                 = 0;
      awready_after_valid_cycles             = 0;
      wready_after_valid_cycles              = 0;
      arready_after_valid_cycles             = 0;
      local_command_timeout                  = 0;
      outstanding_write_address_transaction  = 0;
      outstanding_write_data_transaction     = 0;
      outstanding_read_transaction           = 0;
      outstanding_transaction                = 0;
   endfunction      

   function automatic void __init_queues();
      read_data_burst_length_queue = {};
      write_response_burst_length_queue = {};
      write_data_command_queue = {};
      burst_length_queue = {};
      response_info_queue = {};
   endfunction

   task __assert_ready_with_idles(int cycles);
      repeat (cycles) begin
         @(posedge ACLK);
      end
   endtask
   
   task __update_num_command_received();
      if (num_write_address_command_received > num_write_data_command_received) begin
         if (num_write_command_received < num_write_data_command_received) begin
            num_write_command_received++;
            -> signal_complete_write_command_received;
         end
      end else begin
         if (num_write_command_received < num_write_address_command_received) begin
            num_write_command_received++;
            -> signal_complete_write_command_received;
         end
      end

   endtask

   function AxiCommandTrans_t __get_transaction (
      AxiCommandType_t  AxiCommandTrans_type,
      int               index = 0
   );
      AxiCommandTrans_t temp_command;
      
      bit [1023:0] temp_data;
      
      if (AxiCommandTrans_type == CMD_WADDRESS || AxiCommandTrans_type == CMD_RADDRESS) begin
         if (AxiCommandTrans_type == CMD_WADDRESS) begin
            temp_data                  = write_address_channel_bfm.get_transaction_data();
            temp_command.addr_idles    = write_address_channel_bfm.get_transaction_idles(); 
            temp_command.transaction_type       = AXI_WRITE;
         end else begin
            temp_data                  = read_address_channel_bfm.get_transaction_data();
            temp_command.addr_idles    = read_address_channel_bfm.get_transaction_idles(); 
            temp_command.transaction_type       = AXI_READ;
         end

         temp_command.data_idles    = 'x; 
         temp_command.write_data    = 'x; 
         temp_command.write_strobe  = 'x; 
         
         // decode the data signal
         temp_command.id            = temp_data[lindex(ADDR_W)+lindex(ID_W)+24 : lindex(ADDR_W)+24];
         temp_command.address       = temp_data[lindex(ADDR_W)+23              : 23];
         temp_command.user          = temp_data[lindex(ADDR_W)+22              : 18];
         temp_command.burst_length  = temp_data[17 : 14];
         temp_command.burst_size    = temp_data[13 : 11];
         
         $cast(temp_command.burst_type, temp_data[10 : 9]);
         $cast(temp_command.lock, temp_data[8 : 7]);
         $cast(temp_command.cache, temp_data[6  : 3]);
         $cast(temp_command.protection, temp_data[2 : 0]);
         
      end else if (AxiCommandTrans_type == CMD_WDATA) begin
         temp_data = write_data_channel_bfm.get_transaction_data();
         temp_command.transaction_type = AXI_WRITE;
         
         temp_command.address       = 'x; 
         temp_command.burst_length  = 'x; 
         temp_command.burst_size    = 'x;
         temp_command.user          = 'x;

         $cast(temp_command.burst_type, 'x);
         $cast(temp_command.lock, 'x);
         $cast(temp_command.cache, 'x);
         $cast(temp_command.protection, 'x);
         temp_command.addr_idles    = 'x;
         
         // decode the data signal
         if (index != 0)
            temp_command = local_write_data_command.command;
         temp_command.id                   = temp_data[WDATA_W + ID_W + WSTRB_W : WDATA_W + WSTRB_W + 1]; 
         temp_command.write_data[index]    = temp_data[WDATA_W + WSTRB_W : WSTRB_W + 1];
         temp_command.write_strobe[index]  = temp_data[WSTRB_W : 1];
         temp_command.data_idles[index]    = write_data_channel_bfm.get_transaction_idles();

      end else begin
         $sformat(message, "%m: unknown command type. %0s", AxiCommandTrans_type); 
         print(VERBOSITY_ERROR, message);
      end
      
      return temp_command;
   
   endfunction
   
   //--------------------------------------------------------------------------
   // Internal Machinery
   //--------------------------------------------------------------------------
   
   initial begin
      __init();
      write_data_channel_bfm.init();
      write_address_channel_bfm.init();
      read_address_channel_bfm.init();
   end

   always @ (posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
         __init();
      end
   end
   
   // count the burst length value for write data channel
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin
         if (WVALID && WREADY) begin
            current_num_data_command++;
         end
         
         if (WLAST && WREADY && WVALID) begin
            burst_length_queue.push_front(current_num_data_command-1);
            current_num_data_command = 0;
            num_write_data_command_received++;
            __update_num_command_received();
         end
      end
   end

   // construct a complete write data command transaction
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin
         if (write_data_channel_bfm.get_transaction_queue_size() > 0 && burst_length_queue.size() > 0) begin
            if (current_burst_length == 0)
               current_burst_length = burst_length_queue.pop_back();
            for (int i = 0; i <= current_burst_length; i++) begin
               write_data_channel_bfm.pop_transaction();
               local_write_data_command.command = __get_transaction(CMD_WDATA, local_write_data_command.burst_index);
            
               if (local_write_data_command.burst_index == current_burst_length) begin
                  local_write_data_command.command.burst_length = current_burst_length;
                  current_burst_length = 0;
                  write_data_command_queue.push_front(local_write_data_command.command);
                  local_write_data_command.burst_index = 0;
               end else
                  local_write_data_command.burst_index = local_write_data_command.burst_index +1;
            end
         end
      end
   end
   
   // checking for outstanding transactions
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin      
         if (ARVALID && ARREADY) begin
            outstanding_read_transaction++;
         end
         if (RVALID && RREADY && RLAST) begin
            outstanding_read_transaction--;
         end
         if (AWVALID && AWREADY) begin
            outstanding_write_address_transaction++;
         end
         
         if (WVALID && WREADY && WLAST)  begin
            outstanding_write_data_transaction++;
         end
         
         if (BVALID && BREADY) begin
            outstanding_write_address_transaction--;
            outstanding_write_data_transaction--;
         end
         
         if (outstanding_write_address_transaction > outstanding_write_data_transaction)
            outstanding_transaction = outstanding_read_transaction + outstanding_write_address_transaction;
         else
            outstanding_transaction = outstanding_read_transaction + outstanding_write_data_transaction;
         if (ENABLE_AUTO_BACKPRESSURE == 1) begin
            if (outstanding_read_transaction >= MAX_OUTSTANDING_READS ||
               outstanding_transaction >= MAX_OUTSTANDING_TRANSACTIONS) begin
               -> __signal_deassert_arready;
            end else
               ->__signal_set_arready;

            if (outstanding_write_address_transaction >= MAX_OUTSTANDING_WRITES ||
               outstanding_transaction >= MAX_OUTSTANDING_TRANSACTIONS)
               -> __signal_deassert_awready;
            else
               ->__signal_set_awready;

            if (outstanding_write_data_transaction >= MAX_OUTSTANDING_WRITES ||
               outstanding_transaction >= MAX_OUTSTANDING_TRANSACTIONS)
               -> __signal_deassert_wready;
            else
               ->__signal_set_wready;
         end
      end
   end
     
   // checking for command timeout
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin
         if (command_timeout > 0) begin
            if (local_command_timeout > command_timeout) begin
               $sformat(message, "%m: Command phase timeout");
               print(VERBOSITY_FAILURE, message);
            end
            
            if (AWVALID || WVALID || ARVALID)
               local_command_timeout = 0;
            else
               local_command_timeout++;
         end
      end
   end
   
   always @(write_address_channel_bfm.signal_transaction_received) begin
      if (axi_ready_mode == 1) begin
         if (ENABLE_AUTO_BACKPRESSURE == 0)
            write_address_channel_bfm.set_ready(0);
      end 
      num_write_address_command_received++;
      -> signal_aw_transaction_received;
      __update_num_command_received();
   end
   
   always @(read_address_channel_bfm.signal_transaction_received) begin
      if (axi_ready_mode == 1) begin
         if (ENABLE_AUTO_BACKPRESSURE == 0)
            read_address_channel_bfm.set_ready(0);
      end 
      -> signal_ar_transaction_received;
   end
   
   always @(write_data_channel_bfm.signal_transaction_received) begin
      if (axi_ready_mode == 1) begin
         if (ENABLE_AUTO_BACKPRESSURE == 0)
            write_data_channel_bfm.set_ready(0);
      end 
      -> signal_w_transaction_received;
   end
   
   always @(__signal_deassert_awready) begin
      write_address_channel_bfm.set_ready(0);
      $sformat(message, "%m: deassert awready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(__signal_set_awready) begin
      write_address_channel_bfm.set_ready(1);
      $sformat(message, "%m: assert awready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(__signal_set_awready_wait_for_valid) begin
      @(posedge ACLK);
      if (AWVALID == 0) begin
         fork: wait_for_awvalid
            begin
                do begin 
                    @(posedge ACLK);
                end while (AWVALID != 1);
                __assert_ready_with_idles(.cycles(awready_after_valid_cycles - 1));
                ->__signal_set_awready;
            end
            begin
               @(negedge ARESETn);
            end
         join_any: wait_for_awvalid
         disable fork;
      end else begin
         __assert_ready_with_idles(.cycles(awready_after_valid_cycles - 1));
         ->__signal_set_awready;
      end
   end
   
   always @(__signal_set_wready_wait_for_valid) begin
      @(posedge ACLK);
      if (WVALID == 0) begin
         fork: wait_for_wvalid
            begin
                do begin 
                    @(posedge ACLK);
                end while (WVALID != 1);
                __assert_ready_with_idles(.cycles(wready_after_valid_cycles - 1));
                ->__signal_set_wready;
            end
            begin
               @(negedge ARESETn);
            end
         join_any: wait_for_wvalid
         disable fork;
      end else begin
         __assert_ready_with_idles(.cycles(wready_after_valid_cycles - 1));
         ->__signal_set_wready;
      end
   end
   
   always @(__signal_set_arready_wait_for_valid) begin
      @(posedge ACLK);
      if (ARVALID == 0) begin
         fork: wait_for_arvalid
            begin
                do begin 
                    @(posedge ACLK);
                end while (ARVALID != 1);
                __assert_ready_with_idles(.cycles(arready_after_valid_cycles - 1));
                ->__signal_set_arready;
            end
            begin
               @(negedge ARESETn);
            end
         join_any: wait_for_arvalid
         disable fork;
      end else begin
         __assert_ready_with_idles(.cycles(arready_after_valid_cycles - 1));
         ->__signal_set_arready;
      end
   end
   
   always @(__signal_deassert_wready) begin
      write_data_channel_bfm.set_ready(0);
      $sformat(message, "%m: deassert awready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(__signal_set_wready) begin
      write_data_channel_bfm.set_ready(1);
      $sformat(message, "%m: assert wready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(__signal_deassert_arready) begin
      read_address_channel_bfm.set_ready(0);
      $sformat(message, "%m: deassert arready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(__signal_set_arready) begin
      read_address_channel_bfm.set_ready(1);
      $sformat(message, "%m: assert arready"); 
      print(VERBOSITY_DEBUG, message);
   end
   
   always @(write_response_channel_bfm.signal_src_driving_transaction) begin
      -> signal_write_response_issued;
   end
   
   always @(read_data_channel_bfm.signal_src_driving_transaction) begin
      if (read_data_burst_length == 0) begin
         read_data_burst_length = read_data_burst_length_queue.pop_back() + 1;
      end
      read_data_burst_length--;
      if (read_data_burst_length == 0) begin
         -> signal_read_response_issued;
      end
   end
   
   always @(signal_read_response_issued) begin
      num_of_response_completed++;
      response_info = response_info_queue.pop_back();
   end
   
   always @(signal_write_response_issued) begin
      num_of_response_completed++;
      response_info = response_info_queue.pop_back();
   end
   
   always @(signal_fatal_error) __abort_simulation();
   
   altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W     (WRESP_CH_DATA_W),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS),
        .ST_CHANNEL_W    (ST_CHANNEL_W),
        .ST_ERROR_W      (ST_ERROR_W),
        .ST_EMPTY_W      (ST_EMPTY_W),
        .ST_MAX_CHANNELS (ST_MAX_CHANNELS),
        .ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET),
        .USE_CHANNEL     (USE_CHANNEL),
        .USE_ERROR       (USE_ERROR),
        .USE_READY       (USE_READY),
        .USE_VALID       (USE_VALID),
        .USE_EMPTY       (USE_EMPTY)
    ) 
    write_response_channel_bfm (
         .clk               (ACLK),
         .reset             (~ARESETn),
         .src_data          (write_response_channel_data),
         .src_channel       (),
         .src_error         (),
         .src_empty         (),
         .src_valid         (BVALID),
         .src_startofpacket (),
         .src_endofpacket   (),
         .src_ready         (BREADY)
    );
    
   assign BID    = write_response_channel_data [lindex(ID_W)+2 : 2];
   assign BRESP  = write_response_channel_data [1 : 0];
    
   altera_avalon_st_source_bfm #(
        .ST_SYMBOL_W     (RDATA_CH_DATA_W),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS),
        .ST_CHANNEL_W    (ST_CHANNEL_W),
        .ST_ERROR_W      (ST_ERROR_W),
        .ST_EMPTY_W      (ST_EMPTY_W),
        .ST_MAX_CHANNELS (ST_MAX_CHANNELS),
        .ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET),
        .USE_CHANNEL     (USE_CHANNEL),
        .USE_ERROR       (USE_ERROR),
        .USE_READY       (USE_READY),
        .USE_VALID       (USE_VALID),
        .USE_EMPTY       (USE_EMPTY)
    ) 
    read_data_channel_bfm (
         .clk               (ACLK),
         .reset             (~ARESETn),
         .src_data          (read_data_channel_data),
         .src_channel       (),
         .src_error         (),
         .src_empty         (),
         .src_valid         (RVALID),
         .src_startofpacket (),
         .src_endofpacket   (),
         .src_ready         (RREADY)
    );
    
   assign RLAST  = read_data_channel_data [lindex(RDATA_W)+lindex(ID_W)+4 : lindex(RDATA_W)+lindex(ID_W)+4];
   assign RDATA  = read_data_channel_data [lindex(RDATA_W)+lindex(ID_W)+3 : lindex(ID_W)+3];
   assign RID    = read_data_channel_data [lindex(ID_W)+2 : 2];
   assign RRESP  = read_data_channel_data [1 : 0];
    
   altera_avalon_st_sink_bfm #(
        .ST_SYMBOL_W     (ADDR_CH_DATA_W),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS),
        .ST_CHANNEL_W    (ST_CHANNEL_W),
        .ST_ERROR_W      (ST_ERROR_W),
        .ST_EMPTY_W      (ST_EMPTY_W),
        .ST_MAX_CHANNELS (ST_MAX_CHANNELS),
        .ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET),
        .USE_CHANNEL     (USE_CHANNEL),
        .USE_ERROR       (USE_ERROR),
        .USE_READY       (USE_READY),
        .USE_VALID       (USE_VALID),
        .USE_EMPTY       (USE_EMPTY)
    ) 
    write_address_channel_bfm (
         .clk                (ACLK),
         .reset              (~ARESETn),
         .sink_data          (write_address_channel_data),
         .sink_channel       ('x),
         .sink_error         ('x),
         .sink_empty         ('x),
         .sink_valid         (AWVALID),      
         .sink_startofpacket ('x),
         .sink_endofpacket   ('x),
         .sink_ready         (AWREADY)
    );
    
   assign write_address_channel_data = {AWID, AWADDR, AWUSER, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT};
   
   altera_avalon_st_sink_bfm #(
        .ST_SYMBOL_W     (WDATA_CH_DATA_W),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS),
        .ST_CHANNEL_W    (ST_CHANNEL_W),
        .ST_ERROR_W      (ST_ERROR_W),
        .ST_EMPTY_W      (ST_EMPTY_W),
        .ST_MAX_CHANNELS (ST_MAX_CHANNELS),
        .ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET),
        .USE_CHANNEL     (USE_CHANNEL),
        .USE_ERROR       (USE_ERROR),
        .USE_READY       (USE_READY),
        .USE_VALID       (USE_VALID),
        .USE_EMPTY       (USE_EMPTY)
    ) 
    write_data_channel_bfm (
         .clk                (ACLK),
         .reset              (~ARESETn),
         .sink_data          (write_data_channel_data),
         .sink_channel       ('x),
         .sink_error         ('x),
         .sink_empty         ('x),
         .sink_valid         (WVALID),      
         .sink_startofpacket ('x),
         .sink_endofpacket   ('x),
         .sink_ready         (WREADY)
    );
    
   assign write_data_channel_data = {WID, WDATA, WSTRB, WLAST};
    
   altera_avalon_st_sink_bfm #(
        .ST_SYMBOL_W     (ADDR_CH_DATA_W),
        .ST_NUMSYMBOLS   (ST_NUMSYMBOLS),
        .ST_CHANNEL_W    (ST_CHANNEL_W),
        .ST_ERROR_W      (ST_ERROR_W),
        .ST_EMPTY_W      (ST_EMPTY_W),
        .ST_MAX_CHANNELS (ST_MAX_CHANNELS),
        .ST_READY_LATENCY(ST_READY_LATENCY),
        .USE_PACKET      (USE_PACKET),
        .USE_CHANNEL     (USE_CHANNEL),
        .USE_ERROR       (USE_ERROR),
        .USE_READY       (USE_READY),
        .USE_VALID       (USE_VALID),
        .USE_EMPTY       (USE_EMPTY)
    ) 
    read_address_channel_bfm (
         .clk                (ACLK),
         .reset              (~ARESETn),
         .sink_data          (read_address_channel_data),
         .sink_channel       ('x),
         .sink_error         ('x),
         .sink_empty         ('x),
         .sink_valid         (ARVALID),      
         .sink_startofpacket ('x),
         .sink_endofpacket   ('x),
         .sink_ready         (ARREADY)
    );
    
   assign read_address_channel_data = {ARID, ARADDR, ARUSER, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT};
   
   `ifdef DISABLE_ALTERA_HPS_PROTOCOL_CHECKING
   // Protocol Checking has been disabled

   `else
   
   altera_hps_monitor_bfm #(
      .ID_W(ID_W),
      .ADDR_W(ADDR_W),
      .WDATA_W(WDATA_W),
      .RDATA_W(RDATA_W)
   )
   monitor (
          .ACLK (ACLK),
          .ARESETn (ARESETn),  
          // Write address channel signal
          .AWID(AWID),
          .AWADDR(AWADDR),
          .AWLEN(AWLEN),
          .AWSIZE(AWSIZE),
          .AWBURST(AWBURST),
          .AWLOCK(AWLOCK),
          .AWCACHE(AWCACHE),
          .AWPROT(AWPROT),
          .AWVALID(AWVALID),
          .AWREADY(AWREADY),
          // Write data channel signal
          .WID(WID),
          .WDATA(WDATA),
          .WSTRB(WSTRB),
          .WLAST(WLAST),
          .WVALID(WVALID),
          .WREADY(WREADY),
          // Write response channel signal
          .BID(BID),
          .BRESP(BRESP),
          .BVALID(BVALID),
          .BREADY(BREADY),
          // Read address channel signal
          .ARID(ARID),
          .ARADDR(ARADDR),
          .ARLEN(ARLEN),
          .ARSIZE(ARSIZE),
          .ARBURST(ARBURST),
          .ARLOCK(ARLOCK),
          .ARCACHE(ARCACHE),
          .ARPROT(ARPROT),
          .ARVALID(ARVALID),
          .ARREADY(ARREADY),
          // Read data channel signal
          .RID(RID),
          .RDATA(RDATA),
          .RRESP(RRESP),
          .RLAST(RLAST),
          .RVALID(RVALID),
          .RREADY(RREADY)
   );
   
   always @(monitor.__signal_illegal_response_transaction_once_per_time) begin
      monitor.__print_response_transaction(response_info, num_of_response_completed);
   end
   
   `endif
   // synthesis translate_on
endmodule
