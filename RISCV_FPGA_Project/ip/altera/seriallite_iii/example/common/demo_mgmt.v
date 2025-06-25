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


`timescale 1 ps / 1 ps


//
// Bus state machine state definitions
//
`define  BSM_IDLE             2'b00
`define  BSM_ACTIVE_LOCAL     2'b01
`define  BSM_ACTIVE_SOURCE    2'b10
`define  BSM_ACTIVE_SINK      2'b11


//
// CSR offsets
//
`define  DEMO_MGMT_CONTROL_OFFSET                        9'b0000_00000     // Byte offset = 0x000

`define  DEMO_MGMT_SRC_BURST_COUNT_OFFSET                9'b0001_00000     // Byte offset = 0x080
`define  DEMO_MGMT_SRC_WORDS_TRANS_L_OFFSET              9'b0001_00001     // Byte offset = 0x084
`define  DEMO_MGMT_SRC_WORDS_TRANS_H_OFFSET              9'b0001_00010     // Byte offset = 0x088
`define  DEMO_MGMT_SRC_TOTAL_ERRORS_OFFSET               9'b0001_00011     // Byte offset = 0x08C

`define  DEMO_MGMT_SNK_BURST_COUNT_OFFSET                9'b0010_00000     // Byte offset = 0x100
`define  DEMO_MGMT_SNK_WORDS_RECVD_L_OFFSET              9'b0010_00001     // Byte offset = 0x104
`define  DEMO_MGMT_SNK_WORDS_RECVD_H_OFFSET              9'b0010_00010     // Byte offset = 0x108
`define  DEMO_MGMT_SNK_TOTAL_ERRORS_OFFSET               9'b0010_00011     // Byte offset = 0x10C
`define  DEMO_MGMT_SNK_OVERFLOW_ERRORS_OFFSET            9'b0010_00100     // Byte offset = 0x110
`define  DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_OFFSET   9'b0010_00101     // Byte offset = 0x114
`define  DEMO_MGMT_SNK_LOSS_ALIGN_INIT_ERRORS_OFFSET     9'b0010_00110     // Byte offset = 0x118
`define  DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET           9'b0010_00111     // Byte offset = 0x11C
`define  DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET       9'b0010_01000     // Byte offset = 0x120
`define  DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET      9'b0010_01001     // Byte offset = 0x124

`define  DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_OFFSET         9'b0011_00000     // Byte offset = 0x180
`define  DEMO_MGMT_SNK_UNDERFLOW_ERRORS_OFFSET           9'b0011_00001     // Byte offset = 0x184

module demo_mgmt #
(
   parameter                     lanes = 4
)
(
   // Source core interface
   output                        source_reset,
   input                         source_user_clock,
   input                         source_user_clock_reset,
   input                         source_error,

   // Sink core interface
   output                        sink_reset,
   input                         sink_user_clock,
   input                         sink_user_clock_reset,
   input       [(lanes+3)-1:0]   sink_error,

   // Traffic checker control and status
   input       [15:0]            tc_burst_count,
   input       [63:0]            tc_words_received,
   input       [lanes-1:0]       tc_lane_swap_error,
   input       [lanes-1:0]       tc_lane_sequence_error,
   input       [lanes-1:0]       tc_lane_alignment_error,

   // Traffic generator control and status
   output                        tg_enable,
   output                        tg_test_mode,
   output                        tg_enable_stalls,
   output                        crc_err_inject,
   input       [15:0]            tg_burst_count,
   input       [63:0]            tg_words_transferred,

   // Demo management interface
   input                         demo_mgmt_clk,
   input                         demo_mgmt_clk_reset,
   input       [8:0]             demo_mgmt_address,
   input                         demo_mgmt_read,
   output reg  [31:0]            demo_mgmt_readdata,
   input                         demo_mgmt_write,
   input       [31:0]            demo_mgmt_writedata,
   output reg                    demo_mgmt_waitrequest
);

   wire                          sync_demo_mgmt_clk_reset;

   reg                           demo_ctrl_dec;

   reg         [31:0]            demo_ctrl_stat_csr;

   reg         [31:0]            source_total_errors_csr;
   reg         [31:0]            source_csr_capture;
   reg         [31:0]            source_csr_mux_data;
   wire                          source_read_n;
   reg                           source_read_req_n;
   wire                          source_read_ack_n;
   wire                          ai_source_read_req_n;
   wire                          ai_source_read_ack_n;

   reg         [31:0]            sink_underflow_errors_csr;
   reg         [31:0]            sink_overflow_errors_csr;
   reg         [31:0]            sink_loss_of_alignment_normal_errors_csr;
   reg         [31:0]            sink_loss_of_alignment_init_errors_csr;
   reg         [31:0]            sink_meta_frame_crc_errors_csr[lanes];
   reg         [31:0]            sink_total_errors_csr;
   reg         [31:0]            sink_csr_capture;
   reg         [31:0]            sink_csr_mux_data;
   wire                          sink_read_n;
   reg                           sink_read_req_n;
   wire                          sink_read_ack_n;
   wire                          ai_sink_read_req_n;
   wire                          ai_sink_read_ack_n;

   reg         [31:0]            tc_lane_swap_errors_csr;
   reg         [31:0]            tc_lane_sequence_errors_csr;
   reg         [31:0]            tc_lane_alignment_errors_csr;

   reg         [1:0]             bus_state, next_bus_state;
   reg                           next_demo_mgmt_waitrequest;
   reg         [4:0]             timeout_counter, next_timeout_counter;
   reg         [5:0]             count_stretch_src_reset;
   reg         [5:0]             count_stretch_snk_reset;
	

   wire                          sink_error_decoded   = (sink_error != {(lanes+3){1'b0}}) ? 1'b1 : 1'b0;

   wire        [31:0]            lanes_wire32         = lanes;
   wire        [4:0]             lanes_wire5          = lanes_wire32[4:0];


   assign source_comb_reset           = demo_ctrl_stat_csr[0] ; 
   assign sink_comb_reset             = demo_ctrl_stat_csr[1] ; 

   assign tg_test_mode           = demo_ctrl_stat_csr[2];
   assign tg_enable_stalls       = demo_ctrl_stat_csr[3];
   assign tg_enable              = demo_ctrl_stat_csr[4];
   assign crc_err_inject         = demo_ctrl_stat_csr[5];


	//
   // source reset synchronizer.
   //
   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   source_reset_sync
   (
      .async_reset_n(~source_comb_reset),
      .sync_reset_n(1'b1),
      .clk(source_user_clock),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(source_reset)
   );

	
	//
   // sink reset synchronizer.
   //
   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   sink_reset_sync
   (
      .async_reset_n(~sink_comb_reset),
      .sync_reset_n(1'b1),
      .clk(sink_user_clock),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(sink_reset)
   );

	
	
   //
   // Management reset synchronizer.
   //
   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   demo_mgmt_clk_reset_sync
   (
      .async_reset_n(~demo_mgmt_clk_reset),
      .sync_reset_n(1'b1),
      .clk(demo_mgmt_clk),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(sync_demo_mgmt_clk_reset)
   );


   //
   // Handshake request block for read of source CSRs
   //
   dp_hs_req source_req_block
   (
      .async_reset_n(~sync_demo_mgmt_clk_reset),
      .sync_reset_n(1'b1),
      .sync_ctrl(2'd2),
      .si_clk(demo_mgmt_clk),
      .si_req_n(source_read_req_n),
      .si_ack_n(source_read_ack_n),
      .ai_req_n(ai_source_read_req_n),
      .ai_ack_n(ai_source_read_ack_n)
   );


   //
   // Handshake request block for read of sink CSRs
   //
   dp_hs_req sink_req_block
   (
      .async_reset_n(~sync_demo_mgmt_clk_reset),
      .sync_reset_n(1'b1),
      .sync_ctrl(2'd2),
      .si_clk(demo_mgmt_clk),
      .si_req_n(sink_read_req_n),
      .si_ack_n(sink_read_ack_n),
      .ai_req_n(ai_sink_read_req_n),
      .ai_ack_n(ai_sink_read_ack_n)
   );


   //
   // Decode register selects.
   //
   always @* begin

      demo_ctrl_dec  = 1'b0;

      case (demo_mgmt_address)

         `DEMO_MGMT_CONTROL_OFFSET:                         begin demo_ctrl_dec = 1'b1; source_read_req_n = 1'b1; sink_read_req_n = 1'b1; end

         `DEMO_MGMT_SRC_BURST_COUNT_OFFSET:                 begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b0; sink_read_req_n = 1'b1; end
         `DEMO_MGMT_SRC_WORDS_TRANS_L_OFFSET:               begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b0; sink_read_req_n = 1'b1; end
         `DEMO_MGMT_SRC_WORDS_TRANS_H_OFFSET:               begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b0; sink_read_req_n = 1'b1; end
         `DEMO_MGMT_SRC_TOTAL_ERRORS_OFFSET:                begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b0; sink_read_req_n = 1'b1; end

         `DEMO_MGMT_SNK_BURST_COUNT_OFFSET:                 begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_WORDS_RECVD_L_OFFSET:               begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_WORDS_RECVD_H_OFFSET:               begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_TOTAL_ERRORS_OFFSET:                begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_OVERFLOW_ERRORS_OFFSET:             begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_OFFSET:    begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_LOSS_ALIGN_INIT_ERRORS_OFFSET:      begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET:            begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET:        begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
         `DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET:       begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end

         `DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_OFFSET:          begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
			`DEMO_MGMT_SNK_UNDERFLOW_ERRORS_OFFSET:            begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b0; end
			
         default:                                           begin demo_ctrl_dec = 1'b0; source_read_req_n = 1'b1; sink_read_req_n = 1'b1; end

      endcase

   end


   /* synthesis translate_off */

   reg [0:255] bus_state_encode;     // This string is for simulation debug

   always @ (bus_state) begin

      case (bus_state)

         `BSM_IDLE:           bus_state_encode   <= "IDLE";
         `BSM_ACTIVE_LOCAL:   bus_state_encode   <= "ACTIVE_LOCAL";
         `BSM_ACTIVE_SOURCE:  bus_state_encode   <= "ACTIVE_SOURCE";
         `BSM_ACTIVE_SINK:    bus_state_encode   <= "ACTIVE_SINK";
         default:             bus_state_encode   <= "*** Error: Unknown State ***";

     endcase

   end

   /* synthesis translate_on */


   //
   // Bus State Machine storage
   //
   always @(posedge demo_mgmt_clk or posedge sync_demo_mgmt_clk_reset) begin

      if (sync_demo_mgmt_clk_reset == 1'b1) begin

         bus_state               <= `BSM_IDLE;
         demo_mgmt_waitrequest   <= 1'b1;
         timeout_counter         <= 5'h1F;

      end else begin

         bus_state               <= next_bus_state;
         demo_mgmt_waitrequest   <= next_demo_mgmt_waitrequest;
         timeout_counter         <= next_timeout_counter;

      end

   end


   //
   // Bus State Machine decoder
   //
   always @(*) begin


      case (bus_state)

         `BSM_IDLE: begin

            next_bus_state             = (source_read_req_n == 1'b0)                             ? `BSM_ACTIVE_SOURCE :
                                         (sink_read_req_n   == 1'b0)                             ? `BSM_ACTIVE_SINK   :
                                         ((demo_mgmt_read == 1'b1) || (demo_mgmt_write == 1'b1)) ? `BSM_ACTIVE_LOCAL  : `BSM_IDLE;

            next_demo_mgmt_waitrequest = (source_read_req_n == 1'b0) ? 1'b1 :
                                         (sink_read_req_n   == 1'b0) ? 1'b1 :
                                         (((demo_mgmt_read == 1'b1) || (demo_mgmt_write == 1'b1)) && (demo_mgmt_waitrequest == 1'b1)) ? 1'b0 : 1'b1;

            next_timeout_counter       = ((demo_mgmt_read == 1'b1) || (demo_mgmt_write == 1'b1)) ? 5'h1F : timeout_counter - 5'h01;

         end


         //
         // Access CSRs in the demo_mgmt_clk clock domain, zero wait states
         //
         `BSM_ACTIVE_LOCAL: begin

            next_bus_state             = `BSM_IDLE;

            next_demo_mgmt_waitrequest = 1'b1;

            next_timeout_counter       = 5'd0;

         end


         //
         // Access CSRs in the source_user_clock clock domain
         //
         `BSM_ACTIVE_SOURCE: begin

            next_bus_state             = (demo_mgmt_waitrequest == 1'b0) ? `BSM_IDLE : `BSM_ACTIVE_SOURCE;

            next_demo_mgmt_waitrequest = (timeout_counter == 5'h00) ?  1'b0 : source_read_ack_n;

            next_timeout_counter       = (demo_mgmt_waitrequest == 1'b0) ? 5'h1F : timeout_counter - 5'h01;

         end


         //
         // Access CSRs in the sink_user_clock clock domain
         //
         `BSM_ACTIVE_SINK: begin

            next_bus_state             = (demo_mgmt_waitrequest == 1'b0) ? `BSM_IDLE : `BSM_ACTIVE_SINK;

            next_demo_mgmt_waitrequest = (timeout_counter == 5'h00) ?  1'b0 : sink_read_ack_n;

            next_timeout_counter       = (demo_mgmt_waitrequest == 1'b0) ? 5'h1F : timeout_counter - 5'h01;

         end

      endcase

   end


   //
   // Output Data MUX. This block selects the register data for read cycles.
   //
   always @(posedge demo_mgmt_clk or posedge sync_demo_mgmt_clk_reset) begin

      if (sync_demo_mgmt_clk_reset == 1'b1) begin

         demo_mgmt_readdata      <= 32'd0;

      end else if (timeout_counter == 5'h00) begin

         demo_mgmt_readdata      <= 32'hFFFFFFFF;

      end else begin

         case (demo_mgmt_address)

            `DEMO_MGMT_CONTROL_OFFSET:                         demo_mgmt_readdata <= demo_ctrl_stat_csr;

            `DEMO_MGMT_SRC_BURST_COUNT_OFFSET:                 demo_mgmt_readdata <= source_csr_capture;
            `DEMO_MGMT_SRC_WORDS_TRANS_L_OFFSET:               demo_mgmt_readdata <= source_csr_capture;
            `DEMO_MGMT_SRC_WORDS_TRANS_H_OFFSET:               demo_mgmt_readdata <= source_csr_capture;
            `DEMO_MGMT_SRC_TOTAL_ERRORS_OFFSET:                demo_mgmt_readdata <= source_csr_capture;

            `DEMO_MGMT_SNK_BURST_COUNT_OFFSET:                 demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_WORDS_RECVD_L_OFFSET:               demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_WORDS_RECVD_H_OFFSET:               demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_TOTAL_ERRORS_OFFSET:                demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_OVERFLOW_ERRORS_OFFSET:             demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_OFFSET:    demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_LOSS_ALIGN_INIT_ERRORS_OFFSET:      demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET:            demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET:        demo_mgmt_readdata <= sink_csr_capture;
            `DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET:       demo_mgmt_readdata <= sink_csr_capture;

            `DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_OFFSET:          demo_mgmt_readdata <= sink_csr_capture;
				`DEMO_MGMT_SNK_UNDERFLOW_ERRORS_OFFSET:            demo_mgmt_readdata <= sink_csr_capture;

            default:                                           demo_mgmt_readdata <= 32'h00000000;

         endcase

      end

   end


   //
   // Demo Control/Status CSR - Generic control and status for the demo
   //
   // Register bitfields: [31:27] RO - Number of lanes on the link
   //                     [26:06] RO - reserved
   //                     [5]     RW - CRC Error Insertion
   //                     [4]     RW - Enable traffic generator
   //                     [3]     RW - Enable stall generation
   //                     [2]     RW - Test Mode
   //                     [1]     RW - Sink reset, active high
   //                     [0]     RW - Source reset, active high
   //
   always @(posedge demo_mgmt_clk or posedge sync_demo_mgmt_clk_reset) begin

      if (sync_demo_mgmt_clk_reset == 1'b1) begin

         demo_ctrl_stat_csr <= {lanes_wire5, 22'd0, 5'b00011};

      end else begin

         if ((demo_ctrl_dec == 1'b1) && (demo_mgmt_write == 1'b1)) begin

            demo_ctrl_stat_csr <= {lanes_wire5, 21'h000000, demo_mgmt_writedata[5:0]};

         end else begin

            demo_ctrl_stat_csr <= (demo_ctrl_stat_csr & 32'hFFFFFFFC) ;
				//demo_ctrl_stat_csr <= demo_ctrl_stat_csr ;
         end

      end

   end
	

	


   //*********************************************************************
   //
   // Source User Clock Domain Logic
   //
   //*********************************************************************

   //
   // Handshake response block for read request indication
   //
   dp_hs_resp source_resp_block
   (
      .async_reset_n(~source_user_clock_reset),
      .sync_reset_n(1'b1),
      .sync_ctrl(2'd2),
      .si_clk(source_user_clock),
      .si_req_n(source_read_n),
      .si_ack_n(source_read_n),
      .ai_req_n(ai_source_read_req_n),
      .ai_ack_n(ai_source_read_ack_n)
   );


   //
   // Source Capture Register MUX. This block selects the source register data for read cycles.
   //
   always @(*) begin

         case (demo_mgmt_address)

            `DEMO_MGMT_SRC_BURST_COUNT_OFFSET:                 source_csr_mux_data = {16'd0, tg_burst_count};
            `DEMO_MGMT_SRC_WORDS_TRANS_L_OFFSET:               source_csr_mux_data = tg_words_transferred[31:00];
            `DEMO_MGMT_SRC_WORDS_TRANS_H_OFFSET:               source_csr_mux_data = tg_words_transferred[63:32];
            `DEMO_MGMT_SRC_TOTAL_ERRORS_OFFSET:                source_csr_mux_data = source_total_errors_csr;
            default:                                           source_csr_mux_data = 32'h00000000;

         endcase

   end


   //
   // Source User Clock Domain CSR Capture Register
   //
   always @(posedge source_user_clock or posedge source_user_clock_reset) begin

      if (source_user_clock_reset == 1'b1) begin

         source_csr_capture <= 32'd0;

      end else begin

         source_csr_capture <= (source_read_n == 1'b0) ? source_csr_mux_data : source_csr_capture;

      end

   end


   //
   // Source Total Error Count CSR
   //
   always @(posedge source_user_clock or posedge source_user_clock_reset) begin

      if (source_user_clock_reset == 1'b1) begin

         source_total_errors_csr <= 32'd0;

      end else begin

         source_total_errors_csr <= (source_error == 1'b1) ? source_total_errors_csr + 32'd1 : source_total_errors_csr;

      end

   end


   //*********************************************************************
   //
   // Sink User Clock Domain Logic
   //
   //*********************************************************************

   //
   // Handshake response block for read request indication
   //
   dp_hs_resp sink_resp_block
   (
      .async_reset_n(~sink_user_clock_reset),
      .sync_reset_n(1'b1),
      .sync_ctrl(2'd2),
      .si_clk(sink_user_clock),
      .si_req_n(sink_read_n),
      .si_ack_n(sink_read_n),
      .ai_req_n(ai_sink_read_req_n),
      .ai_ack_n(ai_sink_read_ack_n)
   );


   //
   // Sink Capture Register MUX. This block selects the sink register data for read cycles.
   //
   wire [4:0] lane_num = demo_mgmt_address[4:0];
   always @(*) begin

         case (demo_mgmt_address)

            `DEMO_MGMT_SNK_BURST_COUNT_OFFSET:                 sink_csr_mux_data = {16'd0, tc_burst_count};
            `DEMO_MGMT_SNK_WORDS_RECVD_L_OFFSET:               sink_csr_mux_data = tc_words_received[31:00];
            `DEMO_MGMT_SNK_WORDS_RECVD_H_OFFSET:               sink_csr_mux_data = tc_words_received[63:32];
            `DEMO_MGMT_SNK_TOTAL_ERRORS_OFFSET:                sink_csr_mux_data = sink_total_errors_csr;
            `DEMO_MGMT_SNK_OVERFLOW_ERRORS_OFFSET:             sink_csr_mux_data = sink_overflow_errors_csr;
            `DEMO_MGMT_SNK_LOSS_ALIGN_NORMAL_ERRORS_OFFSET:    sink_csr_mux_data = sink_loss_of_alignment_normal_errors_csr;
            `DEMO_MGMT_SNK_LOSS_ALIGN_INIT_ERRORS_OFFSET:      sink_csr_mux_data = sink_loss_of_alignment_init_errors_csr;
            `DEMO_MGMT_SNK_LANE_SWAP_ERRORS_OFFSET:            sink_csr_mux_data = tc_lane_swap_errors_csr;
            `DEMO_MGMT_SNK_LANE_SEQUENCE_ERRORS_OFFSET:        sink_csr_mux_data = tc_lane_sequence_errors_csr;
            `DEMO_MGMT_SNK_LANE_ALIGNMENT_ERRORS_OFFSET:       sink_csr_mux_data = tc_lane_alignment_errors_csr;
            `DEMO_MGMT_SNK_MF_CRC_ERRORS_BASE_OFFSET: 
                case(lane_num)
                  0:  sink_csr_mux_data = sink_meta_frame_crc_errors_csr[0] ;
                  1:  sink_csr_mux_data = sink_meta_frame_crc_errors_csr[1] ;
                  default:  sink_csr_mux_data = 0;
                endcase
                //sink_csr_mux_data = (lane_num < lanes) ? sink_meta_frame_crc_errors_csr[32*(lane_num+1)-1:32*lane_num] : 32'h00000000; //[demo_mgmt_address[4:0]
            `DEMO_MGMT_SNK_UNDERFLOW_ERRORS_OFFSET:            sink_csr_mux_data = sink_underflow_errors_csr;       
            default:                                           sink_csr_mux_data = 32'h00000000;

         endcase

   end


   //
   // Sink User Clock Domain CSR Capture Register
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_csr_capture <= 32'd0;

      end else begin

         sink_csr_capture <= (sink_read_n == 1'b0) ? sink_csr_mux_data : sink_csr_capture;

      end

   end


   //
   // Sink Total Errors Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_total_errors_csr <= 32'd0;

      end else begin

         sink_total_errors_csr <= (sink_error_decoded == 1'b1) ? sink_total_errors_csr + 32'd1 : sink_total_errors_csr;

      end

   end


   //
   // Sink Adaptation FIFO Underflow Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_underflow_errors_csr <= 32'd0;

      end else begin

         sink_underflow_errors_csr <= (sink_error[lanes+1] == 1'b1) ? sink_underflow_errors_csr + 32'd1 : sink_underflow_errors_csr;

      end

   end
   //
   // Sink Adaptation FIFO Overflow Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_overflow_errors_csr <= 32'd0;

      end else begin

         sink_overflow_errors_csr <= (sink_error[lanes+2] == 1'b1) ? sink_overflow_errors_csr + 32'd1 : sink_overflow_errors_csr;

      end

   end

   //
   // Sink Loss of Lane Alignment During Normal Operation Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_loss_of_alignment_normal_errors_csr <= 32'd0;

      end else begin

         sink_loss_of_alignment_normal_errors_csr <= (sink_error[lanes] == 1'b1) ? sink_loss_of_alignment_normal_errors_csr + 32'd1 : sink_loss_of_alignment_normal_errors_csr;

      end

   end


   //
   // Sink Loss of Lane Alignment During Initialization Error Count CSR
   //
   /*always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         sink_loss_of_alignment_init_errors_csr <= 32'd0;

      end else begin

         sink_loss_of_alignment_init_errors_csr <= (sink_error[lanes] == 1'b1) ? sink_loss_of_alignment_init_errors_csr + 32'd1 : sink_loss_of_alignment_init_errors_csr;

      end

   end*/


   //
   // Traffic Checker Lane Swap Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         tc_lane_swap_errors_csr <= 32'd0;

      end else begin

         tc_lane_swap_errors_csr <= (tc_lane_swap_error != {lanes{1'b0}}) ? tc_lane_swap_errors_csr + 32'd1 : tc_lane_swap_errors_csr;

      end

   end


   //
   // Traffic Checker Lane Sequence Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         tc_lane_sequence_errors_csr <= 32'd0;

      end else begin

         tc_lane_sequence_errors_csr <= (tc_lane_sequence_error != {lanes{1'b0}}) ? tc_lane_sequence_errors_csr + 32'd1 : tc_lane_sequence_errors_csr;

      end

   end


   //
   // Traffic Checker Lane Alignment Error Count CSR
   //
   always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

      if (sink_user_clock_reset == 1'b1) begin

         tc_lane_alignment_errors_csr <= 32'd0;

      end else begin

         tc_lane_alignment_errors_csr <= (tc_lane_alignment_error != {lanes{1'b0}}) ? tc_lane_alignment_errors_csr + 32'd1 : tc_lane_alignment_errors_csr;

      end

   end


   //
   // Per-lane Register Instantiation
   //
   genvar lane;

   generate

      for (lane = 0; lane < lanes; lane = lane + 1) begin : lane_register_inst

         //
         // Sink Loss of Lane Alignment During Initialization Error Count CSR
         //
         always @(posedge sink_user_clock or posedge sink_user_clock_reset) begin

            if (sink_user_clock_reset == 1'b1) begin

               sink_meta_frame_crc_errors_csr[lane] <= 32'd0;

            end else begin

               sink_meta_frame_crc_errors_csr[lane] <= (sink_error[lane] == 1'b1) ? sink_meta_frame_crc_errors_csr[lane] + 32'd1 : sink_meta_frame_crc_errors_csr[lane];

            end

         end

      end

   endgenerate


endmodule  // demo_mgmt
