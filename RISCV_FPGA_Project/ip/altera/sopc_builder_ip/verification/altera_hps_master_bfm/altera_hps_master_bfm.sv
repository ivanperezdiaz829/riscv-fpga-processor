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

module altera_hps_master_bfm (
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
                        AWREADY,
                        AWVALID,
                        AWUSER,
                        // Read address channel signal
                        ARID,
                        ARADDR,
                        ARLEN,
                        ARSIZE,
                        ARBURST,
                        ARLOCK,
                        ARCACHE,
                        ARPROT,
                        ARREADY,
                        ARVALID,
                        ARUSER,
                        // Write data channel signal
                        WID,
                        WDATA,
                        WSTRB,
                        WLAST,
                        WREADY,
                        WVALID,
                        // Read data channel signal
                        RID,
                        RDATA,
                        RRESP,
                        RLAST,
                        RREADY,
                        RVALID,
                        // Write response channel signal
                        BID,
                        BRESP,
                        BREADY,
                        BVALID
                        );
   // =head1 PARAMETERS
   parameter ID_W                = 4;
   parameter ADDR_W              = 32;
   parameter WDATA_W             = 32;
   parameter RDATA_W             = 32;
   
   // derived axi parameter
   localparam WSTRB_W            = WDATA_W >> 3;
   
   // convert to st parameter
   localparam ID_MAX             = (1 << ID_W) - 1; // highest possible value for ID
   localparam ADDR_CH_DATA_W     = ADDR_W + 23;
   localparam WDATA_CH_DATA_W    = WDATA_W + WSTRB_W + 1;
   localparam RDATA_CH_DATA_W    = RDATA_W + 3;
   
   // =cut
   // =head1 PINS
   // =head2 Clock Interface
   input                       ACLK;
   input                       ARESETn;
   
   // =head2 Write address channel signal
   input                       AWREADY;
   output                      AWVALID;
   output [ID_W-1:0]           AWID;
   output [ADDR_W-1:0]         AWADDR;
   output [3:0]                AWLEN;
   output [2:0]                AWSIZE;
   output [1:0]                AWBURST;
   output [1:0]                AWLOCK;
   output [3:0]                AWCACHE;
   output [2:0]                AWPROT;
   output [4:0]                AWUSER;
   
   // =head2 Read address channel signal
   input                       ARREADY;
   output                      ARVALID;
   output [ID_W-1:0]           ARID;
   output [ADDR_W-1:0]         ARADDR;
   output [3:0]                ARLEN;
   output [2:0]                ARSIZE;
   output [1:0]                ARBURST;
   output [1:0]                ARLOCK;
   output [3:0]                ARCACHE;
   output [2:0]                ARPROT;
   output [4:0]                ARUSER;
   
   // =head2 Write data channel signal
   input                       WREADY;
   output                      WVALID;
   output [ID_W-1:0]           WID;
   output [WDATA_W-1:0]        WDATA;
   output [WSTRB_W-1:0]        WSTRB;
   output                      WLAST;
   
   // =head2 Read data channel signal
   output                      RREADY;
   input                       RVALID;
   input  [ID_W-1:0]           RID;
   input  [RDATA_W-1:0]        RDATA;
   input  [1:0]                RRESP;
   input                       RLAST;
   
   // =head2 Write response channel signal
   output                      BREADY;
   input                       BVALID;
   input  [ID_W-1:0]           BID;
   input  [1:0]                BRESP;
   
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
   
   // transaction types
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

   string                       message               = "";
   AxiBurstLength_t             actual_burst_length   = 0;
   AxiBurstLength_t             received_burst_length = 0;
   AxiBurstLength_t             read_burstlength_q[$];
   AxiCommandTrans_t            new_command;
   AxiCommandTrans_t            current_read_command;
   AxiCommandTrans_t            current_write_address;
   AxiCommandTrans_t            current_write_data;
   AxiCommandTrans_t            read_command_q[$];
   AxiCommandTrans_t            write_address_q[$];
   AxiCommandTrans_t            write_data_q[$];
   AxiResponseTrans_t           new_readresp;
   AxiResponseTrans_t           readresp_queue[$];
   AxiResponseTrans_t           current_readresp;
   AxiResponseTrans_t           current_writeresp;
   int                          id = 0;
   int                          read_command_id;
   int                          write_address_id;
   int                          write_data_id;
   int                          read_command_id_q[$];
   int                          write_address_id_q[$];
   int                          write_data_id_q[$];
   int                          response_timeout = 100;
   int                          local_response_timeout;

   bit                          rlast;
   logic [RDATA_CH_DATA_W-1:0]  rdata_temp;
   
   // st data channel's internal signal
   wire  [ADDR_CH_DATA_W-1:0]   aw_data;
   wire  [ADDR_CH_DATA_W-1:0]   ar_data;
   wire  [WDATA_CH_DATA_W-1:0]  w_data;
   wire  [RDATA_CH_DATA_W-1:0]  r_data;   
   
   // write address channel
   altera_avalon_st_source_bfm # (
      .ST_SYMBOL_W       (1),
      .ST_NUMSYMBOLS     (ADDR_CH_DATA_W),
      .ST_ERROR_W        (ID_W),
      .ST_READY_LATENCY  (0),
      .USE_ERROR         (1),
      .USE_READY         (1),
      .USE_VALID         (1),
      .ST_CHANNEL_W      (1),
      .ST_EMPTY_W        (1),
      .ST_BEATSPERCYCLE  (1),
      .ST_MAX_CHANNELS   (1),
      .USE_PACKET        (0),
      .USE_CHANNEL       (0),
      .USE_EMPTY         (0)
   ) waddr_ch (
      .clk  		       (ACLK),
      .reset		       (~ARESETn),
      .src_ready         (AWREADY),
      .src_valid	       (AWVALID),
      .src_data	       (aw_data),
      .src_error         (AWID),
      .src_channel       (),
      .src_startofpacket (),
      .src_endofpacket   (),
      .src_empty         ()
   );
   
   // split the st data bus and drive out axi write address signals
   assign AWADDR  = aw_data[ADDR_W+22:23];
   assign AWUSER  = aw_data[22:18];
   assign AWLEN   = aw_data[17:14];
   assign AWSIZE  = aw_data[13:11];
   assign AWBURST = aw_data[10:9];
   assign AWLOCK  = aw_data[8:7];
   assign AWCACHE = aw_data[6:3];
   assign AWPROT  = aw_data[2:0];
   
   // read address channel
   altera_avalon_st_source_bfm # (
      .ST_SYMBOL_W       (1),
      .ST_NUMSYMBOLS     (ADDR_CH_DATA_W),
      .ST_ERROR_W        (ID_W),
      .ST_READY_LATENCY  (0),
      .USE_ERROR         (1),
      .USE_READY         (1),
      .USE_VALID         (1),
      .ST_CHANNEL_W      (1),
      .ST_EMPTY_W        (1),
      .ST_BEATSPERCYCLE  (1),
      .ST_MAX_CHANNELS   (1),
      .USE_PACKET        (0),
      .USE_CHANNEL       (0),
      .USE_EMPTY         (0)
   ) raddr_ch (
      .clk  		       (ACLK),
      .reset		       (~ARESETn),
      .src_ready         (ARREADY),
      .src_valid	       (ARVALID),
      .src_data	       (ar_data),
      .src_error         (ARID),      
      .src_channel       (),
      .src_startofpacket (),
      .src_endofpacket   (),
      .src_empty         ()
   );
   
   // split the st data bus and drive out axi read address signals
   assign ARADDR  = ar_data[ADDR_W+22:23];
   assign ARUSER  = ar_data[22:18];
   assign ARLEN   = ar_data[17:14];
   assign ARSIZE  = ar_data[13:11];
   assign ARBURST = ar_data[10:9];
   assign ARLOCK  = ar_data[8:7];
   assign ARCACHE = ar_data[6:3];
   assign ARPROT  = ar_data[2:0];
   
   // write data channel
   altera_avalon_st_source_bfm # (
      .ST_SYMBOL_W       (1),
      .ST_NUMSYMBOLS     (WDATA_CH_DATA_W),
      .ST_ERROR_W        (ID_W),
      .ST_READY_LATENCY  (0),
      .USE_ERROR         (1),
      .USE_READY         (1),
      .USE_VALID         (1),
      .ST_CHANNEL_W      (1),
      .ST_EMPTY_W        (1),
      .ST_BEATSPERCYCLE  (1),
      .ST_MAX_CHANNELS   (1),
      .USE_PACKET        (0),
      .USE_CHANNEL       (0),
      .USE_EMPTY         (0)
   ) wdata_ch (
      .clk  		       (ACLK),
      .reset		       (~ARESETn),
      .src_ready         (WREADY),
      .src_valid	       (WVALID),
      .src_data	       (w_data),
      .src_error         (WID),      
      .src_channel       (),
      .src_startofpacket (),
      .src_endofpacket   (),
      .src_empty         ()
   );
   
   // split the st data bus and drive out axi write data signals
   assign WDATA  = w_data[WDATA_W+WSTRB_W:WSTRB_W+1];
   assign WSTRB  = w_data[WSTRB_W:1];
   assign WLAST  = w_data[0];
   
   // read data channel
   altera_avalon_st_sink_bfm # (
      .ST_SYMBOL_W       (1),
      .ST_NUMSYMBOLS     (RDATA_CH_DATA_W),
      .ST_ERROR_W        (ID_W),
      .ST_READY_LATENCY  (0),
      .USE_ERROR         (1),
      .USE_READY         (1),
      .USE_VALID         (1),
      .ST_CHANNEL_W      (1),
      .ST_EMPTY_W        (1),
      .ST_BEATSPERCYCLE  (1),
      .ST_MAX_CHANNELS   (1),
      .USE_PACKET        (0),
      .USE_CHANNEL       (0),
      .USE_EMPTY         (0)
   ) rdata_ch (
      .clk  		       (ACLK),
      .reset		       (~ARESETn),
      .sink_ready        (RREADY),
      .sink_valid	       (RVALID),
      .sink_data	       (r_data),
      .sink_error        (RID),      
      .sink_channel       ('x),
      .sink_startofpacket ('x),
      .sink_endofpacket   ('x),
      .sink_empty         ('x)
   );
   // combine the input of axi read data signals to st data bus
   assign r_data  = {RDATA, RRESP, RLAST};
   
   // write response channel
   altera_avalon_st_sink_bfm # (
      .ST_SYMBOL_W       (1),
      .ST_NUMSYMBOLS     (2),
      .ST_ERROR_W        (ID_W),
      .ST_READY_LATENCY  (0),
      .USE_ERROR         (1),
      .USE_READY         (1),
      .USE_VALID         (1),
      .ST_CHANNEL_W      (1),
      .ST_EMPTY_W        (1),
      .ST_BEATSPERCYCLE  (1),
      .ST_MAX_CHANNELS   (1),
      .USE_PACKET        (0),
      .USE_CHANNEL       (0),
      .USE_EMPTY         (0)
   ) wresponse_ch (
      .clk  		       (ACLK),
      .reset		       (~ARESETn),
      .sink_ready        (BREADY),
      .sink_valid	       (BVALID),
      .sink_data	       (BRESP),
      .sink_error        (BID),      
      .sink_channel      ('x),
      .sink_startofpacket('x),
      .sink_endofpacket  ('x),
      .sink_empty        ('x)
   );
   
   `ifndef DISABLE_ALTERA_HPS_PROTOCOL_CHECKING
      altera_hps_monitor_bfm #(
         .ID_W(ID_W),
         .ADDR_W(ADDR_W),
         .WDATA_W(WDATA_W),
         .RDATA_W(RDATA_W)
      ) monitor (
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
      `endif
   
   event __push_command;
   
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
   
   event signal_fatal_error; // public
      // Signal that a fatal error has occurred. Terminates simulation.
   
   event signal_write_address_ready; // public
   // This event indicate that the write address channel's ready is asserted
   
   event signal_write_data_ready; // public
   // This event indicate that the write data channel's ready is asserted
   
   event signal_read_address_ready; // public
   // This event indicate that the read address channel's ready is asserted
   
   event signal_write_address_not_ready; // public
   // This event indicate that the write address channel's ready is deasserted
   
   event signal_write_data_not_ready; // public
   // This event indicate that the write data channel's ready is deasserted
   
   event signal_read_address_not_ready; // public
   // This event indicate that the read address channel's ready is deasserted
   
   event signal_write_address_driven; // public
   // This event indicate that the write address channel has driven
   // transaction to interface
   
   event signal_write_data_driven;// public
   // This event indicate that the write data channel has driven
   // transaction to interface
   
   event signal_read_address_driven;// public
   // This event indicate that the read address channel has driven 
   // transaction to interface
   
   event signal_read_data_received;// public
   // This event indicate that the read data channel has received a transaction
   
   event signal_read_data_transaction_complete;// public
   // This event indicate that the read data channel has received a 
   // completed burst transaction
   
   event signal_write_response_received;// public
   // This event indicate that the write response channel has 
   // received a transaction
   
   function automatic void set_command_type ( // public
      AxiTransactionType_t       transaction_type
   );
      // Set the command transaction's type
      $sformat(message, "%m: called set_command_type");
      print(VERBOSITY_DEBUG, message);
      new_command.transaction_type = transaction_type;
   endfunction
   
   function automatic void set_command_address ( // public
      AxiAddress_t   address
   );
      // Set the command's address value
      $sformat(message, "%m: called set_command_address");
      print(VERBOSITY_DEBUG, message);
      new_command.address = address;
   endfunction
   
   function automatic void set_command_user ( // public
      AxiUser_t      user
   );
      // Set the command's user value
      $sformat(message, "%m: called set_command_user");
      print(VERBOSITY_DEBUG, message);
      new_command.user = user;
   
   endfunction   
   
   function automatic void set_command_address_noop ( // public
      AxiAddrIdles_t     noop_cycles
   );
      // Set the address channel's idle cycle before the transaction
      // driven to interface
      $sformat(message, "%m: called set_address_idles");
      print(VERBOSITY_DEBUG, message);
      new_command.addr_idles = noop_cycles;
   endfunction
   
   function automatic void set_command_id ( // public
      AxiID_t             id
   );
      // Set command's id value
      $sformat(message, "%m: called set_command_id");
      print(VERBOSITY_DEBUG, message);
      new_command.id = id;
   endfunction
   
   function automatic void set_command_burst_length ( // public
      AxiBurstLength_t   burst_length
   );
      // Set command's burst length value
      $sformat(message, "%m: called set_command_burst_length");
      print(VERBOSITY_DEBUG, message);
      new_command.burst_length = burst_length;
   endfunction
   
   function automatic void set_command_burst_size ( // public
      AxiBurstSize_t    burst_size
   );
      // Set command's burst size value
      $sformat(message, "%m: called set_command_burst_size");
      print(VERBOSITY_DEBUG, message);
      $cast(new_command.burst_size, burst_size);
   endfunction
   
   function automatic void set_command_burst_type ( // public
      AxiBurstType_t   burst_type
   );
      // Set command's burst type value
      $sformat(message, "%m: called set_command_burst_type");
      print(VERBOSITY_DEBUG, message);
      $cast(new_command.burst_type, burst_type);
   endfunction
   
   function automatic void set_command_lock ( // public
      AxiLockType_t      lock
   );
      // Set command's lock value
      $sformat(message, "%m: called set_command_lock");
      print(VERBOSITY_DEBUG, message);
      $cast(new_command.lock, lock);
   endfunction
   
   function automatic void set_command_cache ( // public
      AxiCacheType_t       cache
   );
      // Set command's cache value
      $sformat(message, "%m: called set_command_cache");
      print(VERBOSITY_DEBUG, message);
      $cast(new_command.cache, cache);
   endfunction
   
   function automatic void set_command_protection ( // public
      AxiProtectionType_t  protection
   );
      // Set commands protection value
      $sformat(message, "%m: called set_command_protection");
      print(VERBOSITY_DEBUG, message);
      $cast(new_command.protection, protection);
   endfunction
   
   function automatic void set_command_write_data ( //public
      AxiWriteData_t    write_data,
      int               index
   );
      // Set the write command's write data value
      $sformat(message, "%m: called set_command_write_data");
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_command.write_data[index] = write_data;
   endfunction
   
   function automatic void set_command_write_data_noop ( // public
      AxiDataIdles_t    noop_cycles,
      int               index
   );
      // Set write command's idle cycle
      $sformat(message, "%m: called set_command_write_data_noop");
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_command.data_idles[index] = noop_cycles;
   endfunction   
  
   function automatic void set_command_write_strobe ( // public
      AxiWriteStrobe_t     write_strobe,
      int                  index
   );
       // Set write command's write strobes
      $sformat(message, "%m: called set_command_write_strobe");
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_command.write_strobe[index] = write_strobe;
   endfunction
      
   function automatic void push_command (); // public
      // Push the populated command transaction descriptor onto its appropriate
      // write/read command queue. The BFM will pop command descriptors off the
      // queue as soon as they are available, read them and drive it to the
      // AXI interface command plane.      
      AxiBurstLength_t                 burst_length;
      bit                              last;
      logic    [ADDR_CH_DATA_W-1:0]    addr_temp;
      logic    [WDATA_CH_DATA_W-1:0]   data_temp;
      
      $sformat(message, "%m: called push_command");
      print(VERBOSITY_DEBUG, message);
      
      if (!ARESETn) begin
         $sformat(message, "%m: Illegal to push command while ARESETn asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      
      addr_temp = {new_command.address,
                   new_command.user,
                   new_command.burst_length,
                   new_command.burst_size,
                   new_command.burst_type,
                   new_command.lock,
                   new_command.cache,
                   new_command.protection
                  };
      
      -> __push_command;
      if (new_command.transaction_type == AXI_WRITE) begin      
         // push write address
         waddr_ch.set_transaction_data(addr_temp);
         waddr_ch.set_transaction_error(new_command.id);
         waddr_ch.set_transaction_idles(new_command.addr_idles);
         waddr_ch.push_transaction();
               
         // push write data
         for (int i = 0; i <= new_command.burst_length; i++) begin
            if (i == new_command.burst_length)
               last = 1;
            else
               last = 0;
            
            data_temp = {new_command.write_data[i],
                         new_command.write_strobe[i],
                         last
                        };
                        
            wdata_ch.set_transaction_data(data_temp);
            wdata_ch.set_transaction_error(new_command.id);
            wdata_ch.set_transaction_idles(new_command.data_idles[i]);
            wdata_ch.push_transaction();
            write_address_q.push_back(new_command);
            write_data_q.push_back(new_command);
            write_address_id_q.push_back(id);
            write_data_id_q.push_back(id);
         end
      end else begin
         // push read address
         raddr_ch.set_transaction_data(addr_temp);
         raddr_ch.set_transaction_error(new_command.id);
         raddr_ch.set_transaction_idles(new_command.addr_idles);
         raddr_ch.push_transaction();
         read_command_q.push_back(new_command);
         read_command_id_q.push_back(id);
         
         // keep track of read data burst length according to id
         read_burstlength_q.push_back(new_command.burst_length); // treat all the same, - ignore id, in order trans only
         // rdata_length[new_command.id].push_back(new_command.burst_length); // for diff id - not working
      end
      id++;
   endfunction
   
   function automatic void pop_read_response (); // public
      // Pop the read response transaction descriptor from the queue 
      // so that it can be queried with the get_read_response methods 
      // by the test bench
      $sformat(message, "%m: called pop_read_response");
      print(VERBOSITY_DEBUG, message);
      
      if (!ARESETn) begin
         $sformat(message, "%m: Illegal to pop response while ARESETn asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      
      if (get_read_response_queue_size() > 0) begin
         current_readresp              = 'x;
         current_readresp              = readresp_queue.pop_front();
      end else begin
         $sformat(message, "%m: Read response queue is empty. "); 
         print(VERBOSITY_ERROR, message);
      end
   endfunction
   
   function automatic AxiBurstLength_t get_read_response_burst_length(); // public
      // Return read data channel's burst length value
      $sformat(message, "%m: called get_read_response_burst_length");
      print(VERBOSITY_DEBUG, message);
      
      return current_readresp.burst_length;
   endfunction
   
   function automatic AxiReadData_t get_read_response_data ( // public
      int           index
   );
      // Return read data channel's data value
      $sformat(message, "%m: called get_read_response_data");
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         return current_readresp.read_data[index];
   endfunction
   
   function automatic AxiID_t get_read_response_id (); // public
      // Get read data channel's id value
      $sformat(message, "%m: called get_read_response_id");
      print(VERBOSITY_DEBUG, message);
      
      return current_readresp.id;
   endfunction
   
   function automatic AxiDataIdles_t get_read_response_latency ( // public
      int            index
   );
      // Return read data channel's response latency
      $sformat(message, "%m: called get_read_response_latency");
      print(VERBOSITY_DEBUG, message);
      
       if (__check_transaction_index(index))
         return current_readresp.response_latency[index];
   endfunction
   
   function automatic AxiResponseType_t get_read_response ( // public
      int            index
   );
      // Return the read data channel's response value
      AxiResponseType_t response_enum;
      
      $sformat(message, "%m: called get_read_response");
      print(VERBOSITY_DEBUG, message);
      
       if (__check_transaction_index(index))
         $cast(response_enum, current_readresp.response[index]);
         return response_enum;
   endfunction
   
   task automatic assert_read_data_ready(); // public
      // Assert read data channel's ready signal
      rdata_ch.set_ready(1);
   endtask
   
   task automatic deassert_read_data_ready(); // public
      // Deassert read data channel's ready signal
      rdata_ch.set_ready(0);
   endtask
   
   task automatic assert_write_response_ready(); // public
      // Assert write response channel's ready signal
      wresponse_ch.set_ready(1);
   endtask
   
   task automatic deassert_write_response_ready(); // public
      // Deassert write response channel's ready signal
      wresponse_ch.set_ready(0);
   endtask   

   function automatic void pop_write_response (); // public
      // Pop the write response transaction descriptor from the queue 
      // so that it can be queried with the get_write_response methods 
      // by the test bench.
      AxiResponse_t   data_temp;
      
      $sformat(message, "%m: called pop_write_response");
      print(VERBOSITY_DEBUG, message);
      
      if (!ARESETn) begin
         $sformat(message, "%m: Illegal to pop response while ARESETn asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      
      if (get_write_response_queue_size() > 0) begin
         current_writeresp.read_data        = 'x;
         current_writeresp.response_latency = 'x;
         current_writeresp.burst_length     = 0;
         current_writeresp.transaction_type = AXI_WRITE;      
         $cast(current_writeresp.response, 'x);
         
         wresponse_ch.pop_transaction();
         data_temp                             = wresponse_ch.get_transaction_data();
         current_writeresp.id                  = wresponse_ch.get_transaction_error();   
         current_writeresp.response[0]         = data_temp[1:0];
         current_writeresp.response_latency[0] = wresponse_ch.get_transaction_idles();
      end else begin
         $sformat(message, "%m: Write response queue is empty"); 
         print(VERBOSITY_ERROR, message);
      end
   endfunction
   
   function automatic AxiResponse_t get_write_response (); // public
      // Return write response channel's response value
      AxiResponseType_t response_enum;
      
      $sformat(message, "%m: called get_write_response");
      print(VERBOSITY_DEBUG, message);
            
      $cast(response_enum, current_writeresp.response[0]);
      return response_enum;
   endfunction
   
   function automatic AxiResponse_t get_write_response_latency (); // public
      // Return write response channel's response latency
      $sformat(message, "%m: called get_write_response_latency");
      print(VERBOSITY_DEBUG, message);
      
      return current_writeresp.response_latency[0];
   endfunction
   
   function automatic AxiID_t get_write_response_id (); // public
      // Return write response channel's id value
      $sformat(message, "%m: called get_write_response_id");
      print(VERBOSITY_DEBUG, message);
      
      return current_writeresp.id;
   endfunction
   
   function automatic int get_read_response_queue_size(); // public
      // Queries the read response queue to determine number of read 
      // response descriptors currently stored in the BFM. This is 
      // the number of read response the test program can immediately
      // pop off the response queue for further processing
      $sformat(message, "%m: called get_read_response_queue_size");      
      print(VERBOSITY_DEBUG, message);
   
      return readresp_queue.size();
   endfunction
   
   function automatic int get_write_response_queue_size(); // public
      // Queries the write response queue to determine number of write 
      // response descriptors currently stored in the BFM. This is 
      // the number of write response the test program can immediately
      // pop off the response queue for further processing
      $sformat(message, "%m: called get_write_response_queue_size");      
      print(VERBOSITY_DEBUG, message);
   
      return wresponse_ch.get_transaction_queue_size();
   endfunction
   
   function automatic void set_command_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse before command time out
      // Disable timeout by setting the value to 0.
      waddr_ch.set_response_timeout(cycles);
      raddr_ch.set_response_timeout(cycles);
      wdata_ch.set_response_timeout(cycles);
   endfunction  
   
   function automatic void set_response_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse before response time out
      // Disable timeout by setting the value to 0.
      response_timeout = cycles;
      if (cycles == 0) begin
         $sformat(message, "%m: Response timeout disabled");
      end else begin
         $sformat(message, "%m: Set response timeout to %0d cycles", response_timeout);
      end
      print(VERBOSITY_INFO, message);
    
   endfunction  
   
   // clear queues and variables and set st bfms to initial state
   task automatic __init();
      rdata_ch.init();
      wresponse_ch.init();
      
      actual_burst_length     = 0;
      received_burst_length   = 0;
      read_burstlength_q      = {};
      readresp_queue          = {};
      new_readresp            = 'x;
      new_command             = 'x;
      current_readresp        = 'x;
      current_writeresp       = 'x;    
      current_read_command    = 'x;
      current_write_address   = 'x;
      current_write_data      = 'x;
      read_command_q          = {};
      write_address_q         = {};
      write_data_q            = {};
      read_command_id_q       = {};
      write_address_id_q      = {};
      write_data_id_q         = {};
      local_response_timeout  = 0;
   endtask
   
   //
   function automatic int __check_command_violation ();
      int   violation;
      int   burst_size;
      int   burst_size_w;
      int   total_byte;
      
      burst_size     = 2**(new_command.burst_size);
      burst_size_w   = 2**(new_command.burst_size + 3);
      total_byte     = (2**new_command.burst_size) * (new_command.burst_length + 1);
      
      if (new_command.transaction_type == AXI_READ) begin
         if (burst_size_w > RDATA_W) begin
            $sformat(message, "Read burst size exceeds the read data bus width. burst_size_w - %d", burst_size_w);
            print(VERBOSITY_WARNING, message);
            violation++;
         end
      end else begin
         if (burst_size_w > WDATA_W) begin
            $sformat(message, "Write burst size exceeds the read data bus width. burst_size_w - %d", burst_size_w);
            print(VERBOSITY_WARNING, message);
            violation++;
         end
      end
      
      // wrapping burst checking
      if (new_command.burst_type == 2) begin
         if (new_command.burst_length == 1 || new_command.burst_length == 3 ||
               new_command.burst_length == 7 || new_command.burst_length == 15) begin
         end else begin
            $sformat(message, "Burst length should be either 1, 3, 7, or 15 for wrapping burst");
            print(VERBOSITY_WARNING, message);
            violation++;
         end
         // address alignment check
         if ((new_command.address % burst_size) != 0) begin
            $sformat(message, "The start address must be aligned to the size of transfer for wrapping burst");
            print(VERBOSITY_WARNING, message);
            violation++;
         end
      end
      
      // exlcusive access checking
      if (new_command.lock == 1) begin
         // total byte transfer for exclusive access
         if (total_byte == 1 || total_byte == 2 || total_byte == 4 || total_byte == 8 ||
               total_byte == 16 || total_byte == 32 || total_byte == 64 || total_byte == 128) begin
         end else begin
            $sformat(message, "Total bytes transfer should be power of 2 for exclusive access");
            print(VERBOSITY_WARNING, message);
            violation++;
         end
         // address alignment check
         if ((new_command.address % burst_size) != 0) begin
            $sformat(message, "The start address must be aligned to the size of transfer for exclusive access");
            print(VERBOSITY_WARNING, message);
            violation++;
         end
      end      
      return violation;
   endfunction
   
   // todo: events, high level api, checking   
   initial begin
      __init();
   end
   
   // clear variables and queue upon reset
   always @(negedge ARESETn) begin
      if (!ARESETn)
         __init();
   end
   
   always @(waddr_ch.signal_src_driving_transaction)
      ->signal_write_address_driven;
   
   always @(wdata_ch.signal_src_driving_transaction)
      ->signal_write_data_driven;
   
   always @(raddr_ch.signal_src_driving_transaction)
      ->signal_read_address_driven;
   
   always @(rdata_ch.signal_transaction_received) begin
      ->signal_read_data_received;      
      // merge individual transfers to be one axi read data transaction when RLAST asserted
      if (RLAST == 1) begin
         ->signal_read_data_transaction_complete;
         
         // checking for outstanding read command - current check is for in-order transaction only
         if (read_burstlength_q.size() == 0) begin
            $sformat(message, "%m: Read response received without read command being issued");
            print(VERBOSITY_ERROR, message);
            ->signal_fatal_error;
         end else begin
            actual_burst_length  = read_burstlength_q.pop_front();
         end
         
         if (actual_burst_length != received_burst_length) begin
            $sformat(message, "%m: Number of transfer received from read data channel mismatched with burst length in read address channel");
            print(VERBOSITY_ERROR, message);
            ->signal_fatal_error;
         end
         
         for (int i = 0; i<= received_burst_length; i++) begin
            rdata_ch.pop_transaction();            
            rdata_temp                       = rdata_ch.get_transaction_data();
            new_readresp.response_latency[i] = rdata_ch.get_transaction_idles();
            new_readresp.read_data[i]        = rdata_temp[RDATA_W+2:3];
            new_readresp.response[i]         = rdata_temp[2:1];
            rlast                            = rdata_temp[0]; // not of use right now since we use RLAST input port
         end
         new_readresp.burst_length        = received_burst_length;
         new_readresp.id                  = rdata_ch.get_transaction_error();
         new_readresp.transaction_type    = AXI_READ;
         
         // push to the read data queue
         readresp_queue.push_back(new_readresp);
         received_burst_length = 0;
      end else begin
         received_burst_length++;
      end      
   end
   
   always @(wresponse_ch.signal_transaction_received)
      ->signal_write_response_received;  
   
   always @(waddr_ch.signal_src_ready)
      ->signal_write_address_ready;
      
   always @(waddr_ch.signal_src_not_ready)
      ->signal_write_address_not_ready;
      
   always @(raddr_ch.signal_src_ready)
      ->signal_write_data_ready;
      
   always @(raddr_ch.signal_src_not_ready)
      ->signal_write_data_not_ready;
      
   always @(wdata_ch.signal_src_ready)
      ->signal_read_address_ready;
      
   always @(wdata_ch.signal_src_not_ready)
      ->signal_read_address_not_ready;
      
   // checking for response timeout
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin
         if (response_timeout > 0) begin
            if (local_response_timeout > response_timeout) begin
               $sformat(message, "%m: Response phase timeout");
               print(VERBOSITY_FAILURE, message);
            end
            
            if (WVALID || BVALID)
               local_response_timeout = 0;
            else
               local_response_timeout++;
         end
      end
   end
   
   // keep track of current transactions on the interface
   always @ (posedge ACLK or negedge ARESETn) begin
      if (ARESETn) begin
         if (AWVALID && AWREADY) begin
            current_write_address = write_address_q.pop_front();
            write_address_id = write_address_id_q.pop_front();
         end else if (WVALID && WREADY && WLAST) begin
            current_write_data = write_data_q.pop_front();
            write_data_id = write_data_id_q.pop_front();
         end else if (ARVALID && ARREADY)begin
            current_read_command = read_command_q.pop_front();
            read_command_id = read_command_id_q.pop_front();
         end
      end
   end
   
   `ifndef DISABLE_ALTERA_HPS_PROTOCOL_CHECKING
      always @(monitor.__signal_illegal_command_transaction_once_per_time)
         if (AWVALID && AWREADY)
            monitor.__print_command_transaction(current_write_address, write_address_id);
         else if (WVALID && WREADY)
            monitor.__print_command_transaction(current_write_data, write_data_id);
         else if (ARVALID && ARREADY)
            monitor.__print_command_transaction(current_read_command, read_command_id);
   `endif
   
   always @(signal_fatal_error)
      __abort_simulation();
   
   // synthesis translate_on
endmodule 
