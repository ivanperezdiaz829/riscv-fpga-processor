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


module sdi_ii_reconfig_logic # (
    parameter NUM_CHS = 2,
              FAMILY  = "Stratix V",
              DIRECTION = "tx",
              VIDEO_STANDARD = "dl"
    
  )
  (
   input                       reconfig_clk,
   input                       rst,
   input       [NUM_CHS-1:0]   sdi_tx_start_reconfig,
   input       [NUM_CHS-1:0]   sdi_tx_pll_sel,
   input       [NUM_CHS-1:0]   sdi_rx_start_reconfig,
   input       [NUM_CHS*2-1:0] sdi_rx_std,
   output wire [NUM_CHS-1:0]   sdi_tx_reconfig_done,
   output wire [NUM_CHS-1:0]   sdi_rx_reconfig_done,
   
   //Reconfiguration connections
   input  wire        reconfig_busy,
   output reg  [8:0]  reconfig_mgmt_address,    
   output reg         reconfig_mgmt_read,        
   input  wire [31:0] reconfig_mgmt_readdata,   
   input  wire        reconfig_mgmt_waitrequest, 
   output reg         reconfig_mgmt_write,       
   output reg  [31:0] reconfig_mgmt_writedata    
  );

  reg [4:0]           ch_loops;
  reg                 inc_loops;
  reg [2:0]           cnt_exec;
  reg                 end_exec;
  reg [31:0]          reg_data;
  reg [31:0]          reg_offset;
  reg [31:0]          readdata;
  reg [1:0]           std_select;
  reg [7:0]           logical_ch_select;
  reg [NUM_CHS*2-1:0] reconfig_done;
  reg [NUM_CHS*2-1:0] sdi_reconfig_done;
  reg                 tx_pll_sel; 
  reg [3:0]           current_state;
  reg [3:0]           next_state;
  reg [6:0]           address;
  reg [31:0]          wdata;
  reg                 write;
  reg                 read;
  reg                 store_readdata;
  reg                 count;
  reg                 start_count;
  reg                 set_num_exec;
  reg                 set_num_exec_init;
  reg                 set_cnt_wait;
  reg [NUM_CHS*2-1:0] prev_reconfig;
  reg [NUM_CHS*2-1:0] sdi_tx_reconfig_done_dl;
      
  wire [31:0]          override_hd_data;
  wire [31:0]          override_m_sel;
  wire [31:0]          override_tx_pll_sel;
  wire [6:0]           log_ch_register;
  wire [6:0]           cs_register;
  wire [6:0]           offset_register;
  wire [6:0]           data_register;
  wire [NUM_CHS-1:0]   sdi_rx_start_reconfig_sync;
  //wire [NUM_CHS-1:0]   sdi_tx_start_reconfig_sync;
  wire [NUM_CHS*2-1:0] sdi_rx_std_sync;
  wire [NUM_CHS*2-1:0] sdi_start_reconfig;
  wire                 go_reconfig;
  wire                 tx_reconfig; 
   
  genvar i, j, k, m, n;
  
   //=================================================================================
   // Setting logical_channel number: See "Handles multi-channel reconfig" below.
   //=================================================================================   
   // Users need to set the value of LOG_CH_NUM[i], which represent the starting 
   // number of reconfiguration interface for RX channel i.
   // Users can add more RX/Duplex instances to reconfiguration interface [x] by 
   // assigning LOG_CH_NUM[i] appropriately.
   //=================================================================================				 
   // Ex:
   // Assuming for multi-channel, there are one duplex, one tx and one rx in the design.
   // - Channel 0 is tied to Duplex instance (two reconfig interfaces used for Duplex - 0 and 1),
   // - Channel 1 is tied to RX instance     (one reconfig interfaces used for RX     - 2),
   // - reconfiguration is NOT needed for tx (two reconfig interfaces used for TX     - 3 and 4)
   // 
   //===========================================================================================	 
   wire [7:0] rx_log_ch_num [0:NUM_CHS-1];
   assign rx_log_ch_num[0] = 8'd0; // Duplex Rx channel share same logical channel number with Tx
   assign rx_log_ch_num[1] = 8'd2; // Rx channel
   
   wire [7:0] tx_log_ch_num [0:NUM_CHS-1];
   wire [7:0] tx_log_ch_num_b [0:NUM_CHS-1];
   assign tx_log_ch_num[0] = 8'd0; // Duplex Tx channel share same logical channel number with Rx
   //assign tx_log_ch_num[1] = DIRECTION=="du" ? 8'd2 : 8'd3; // Tx channel
   
   assign tx_log_ch_num[1] = (VIDEO_STANDARD=="dl")? (DIRECTION=="du" ? 8'd4 : 8'd6) :
                             (DIRECTION=="du" ? 8'd2 : 8'd3); // Tx channel
        
   assign tx_log_ch_num_b[0] = 8'd0; // Duplex Tx channel share same logical channel number with Rx
   assign tx_log_ch_num_b[1] = (VIDEO_STANDARD=="dl")? (DIRECTION=="du" ? 8'd7 : 8'd9) : 8'd0;
   
   
   
   wire [7:0] rx_logical_ch_sel;
   wire [7:0] tx_logical_ch_sel;
   wire [7:0] tx_logical_ch_sel_b;
   assign rx_logical_ch_sel = rx_log_ch_num[ch_loops/2];
   assign tx_logical_ch_sel = tx_log_ch_num[ch_loops/2];
   assign tx_logical_ch_sel_b = tx_log_ch_num_b[ch_loops/2];
   
   //==========================================
   // 4 operation during first reconfiguration
   // 2 operation during other reconfig
   //==========================================
   // cnt_exec = 3: Read m_sel  (1st reconfig, only for Stratix V)
   // cnt_exec = 2: Write m_sel (1st reconfig, only for Stratix V)
   // cnt_exec = 1: Read m_counter, l_counter
   // cnt_exec = 0: Write m_counter, l_counter
   localparam [2:0] TOTAL_EXECUTION_INIT  = ((FAMILY == "Stratix V") | (FAMILY == "Arria V GZ")) ? 3'd4 : 3'd2;
   localparam [2:0] NUMBER_EXECUTION_NEXT = 3'd2;
   
   localparam [5:0] READ_DATA_CNT         = 6'd15;
   
   localparam [6:0] RX_LOG_CH_REGISTER    = 7'h38; 
   localparam [6:0] RX_CS_REGISTER        = 7'h3a; 
   localparam [6:0] RX_OFFSET_REGISTER    = 7'h3b;   
   localparam [6:0] RX_DATA_REGISTER      = 7'h3c;
   localparam [3:0] RX_OFFSET_M_L_COUNTER = ((FAMILY == "Stratix V") | (FAMILY == "Arria V GZ")) ? 4'hc : 4'he;
   localparam [3:0] RX_OFFSET_M_SEL       = 4'he;
   localparam [6:0] TX_LOG_CH_REGISTER    = 7'h40; 
   localparam [6:0] TX_CS_REGISTER        = 7'h42; 
   localparam [6:0] TX_OFFSET_REGISTER    = 7'h43;   
   localparam [6:0] TX_DATA_REGISTER      = 7'h44;
   
   assign log_ch_register = tx_reconfig ? TX_LOG_CH_REGISTER : RX_LOG_CH_REGISTER;
   assign cs_register     = tx_reconfig ? TX_CS_REGISTER     : RX_CS_REGISTER;
   assign offset_register = tx_reconfig ? TX_OFFSET_REGISTER : RX_OFFSET_REGISTER;
   assign data_register   = tx_reconfig ? TX_DATA_REGISTER   : RX_DATA_REGISTER;
   
   //=======================================================================
   // Handles for dual-link Tx PLL switching
   //=======================================================================
   generate if (VIDEO_STANDARD == "dl")
   begin : dl_tx_reconfig_done_gen  
      always @ (posedge reconfig_clk or posedge rst)
      begin
         if (rst) begin
            sdi_tx_reconfig_done_dl <= {(NUM_CHS*2){1'd0}};
         end else begin
            if ( sdi_reconfig_done[ch_loops] )
               sdi_tx_reconfig_done_dl[ch_loops] <= 1'd1;
            else if ( |sdi_tx_reconfig_done )
               sdi_tx_reconfig_done_dl <= {(NUM_CHS*2){1'd0}};
         end
      end
   end
   endgenerate
   
   //=====================================================
   // Synchronizer is required when crossing clock domains
   //=====================================================
   localparam SYNC_DEPTH = 3;
   
   // From receiver core clock domain
   generate 
      for (i=0; i<=NUM_CHS-1; i=i+1) 
        begin : sdi_rx_start_reconfig_sync_gen
         altera_std_synchronizer #(
            .depth(SYNC_DEPTH)
         ) u_rx_start_reconfig_sync (
            .clk(reconfig_clk),
            .reset_n(1'b1),
            .din(sdi_rx_start_reconfig[i]),
            .dout(sdi_rx_start_reconfig_sync[i])
         );

         
         if (VIDEO_STANDARD == "dl") begin
            assign sdi_start_reconfig[i*2]   = sdi_tx_start_reconfig[i]; //for link_a
            assign sdi_start_reconfig[i*2+1] = sdi_tx_start_reconfig[i]; //for link_b

            //assign sdi_rx_reconfig_done[i] = sdi_reconfig_done[i*2]; //ignore
            assign sdi_rx_reconfig_done[i] = 1'd0; //ignore
            assign sdi_tx_reconfig_done[i] = (sdi_reconfig_done[i*2] & sdi_tx_reconfig_done_dl[i*2+1]) | (sdi_reconfig_done[i*2+1] & sdi_tx_reconfig_done_dl[i*2]); //for link_b
         end else begin
            assign sdi_start_reconfig[i*2]   = sdi_rx_start_reconfig_sync[i];
            assign sdi_start_reconfig[i*2+1] = sdi_tx_start_reconfig[i];

            assign sdi_rx_reconfig_done[i] = sdi_reconfig_done[i*2];
            assign sdi_tx_reconfig_done[i] = sdi_reconfig_done[i*2+1];
         end
      end
   endgenerate
   
   //=========================================================================
   // Not a good idea/Not safe to synchronize data bus using std synchronizer
   // But since the synchronized version of sdi_rx_std_sync will only be read
   // few clock cycles later (cnt_exec==2'd0, state=WRITE_DATA), so it is safe 
   // here
   //=========================================================================
   generate 
      for (j=0; j<=2*NUM_CHS-1; j=j+1) 
        begin : rx_std_sync_gen
         altera_std_synchronizer #(
            .depth(SYNC_DEPTH)
         ) u_rx_std_sync (
            .clk(reconfig_clk),
            .reset_n(1'b1),
            .din(sdi_rx_std[j]),
            .dout(sdi_rx_std_sync[j])
         );
      end
   endgenerate

   //=======================================================================
   // Set approprite data to overwrite data in selected transceiver register
   //=======================================================================
   assign override_hd_data = ((FAMILY == "Stratix V") | (FAMILY == "Arria V GZ")) ?  ({readdata[31:16],  
                                                          ((std_select[0] && ~std_select[1]) ? 4'h3: 4'h5),  
                                                          ((std_select[0] && ~std_select[1]) ? 4'ha: 4'h5), 
                                                          readdata[7:5], 1'b0, readdata[3:0]}) :
                                                        
                                                        ({readdata[31:16], 2'b00, 
                                                          ((std_select[0] && !std_select[1]) ? 4'h3: 4'h5), 
                                                          ((std_select[0] && !std_select[1]) ? 4'ha: 4'h5), 
                                                          readdata[5:4],1'b0,readdata[2:0]});
   assign override_m_sel = ({readdata[31:5], 2'b00, readdata[2:0]});
   assign override_tx_pll_sel = {{31'd0, tx_pll_sel}};
   
   //=======================================================================
   // Handles multi-channel reconfig
   //=======================================================================
   
   always @ (posedge reconfig_clk or posedge rst)
   begin
      if (rst) begin
         ch_loops <= 5'd0;
      end else begin
         //==========================================================================================
         // Searching for sdi_start_reconfig assertion at every channel,
         // starting from channel 0.
         // IF (start_reconfig [channel i] == 0) OR (reconfig_done [channel i] == 1)
         //    then start checking for sdi_start_reconfig [channel i+1]
         //===========================================================================================
         if (inc_loops) begin
            if (ch_loops == NUM_CHS*2 - 1) begin 
               ch_loops <= 5'd0;
            end else begin 
               ch_loops <= ch_loops + 5'd1;
            end
         end
      end
   end
   
   // Launch reconfiguration once start_reconfig [ch i] is asserted AND if reconfig_done[ch i] == 0
   assign go_reconfig = sdi_start_reconfig[ch_loops] && (~sdi_reconfig_done[ch_loops]);
   
   // Indicate the current reconfiguration is target for Tx. 1:Tx, 0:Rx
   assign tx_reconfig = (VIDEO_STANDARD == "dl")? go_reconfig : (ch_loops % 2) && go_reconfig;
   
   always @ (posedge reconfig_clk or posedge rst)
   begin
      if (rst) begin
         logical_ch_select <= 8'd0;
         std_select <= 2'b00;
         sdi_reconfig_done <= {(NUM_CHS){1'b0}};
         tx_pll_sel <= 1'b0;
      end else begin
         // Choosing correct value for logical_ch_select, according to ch_loops value.
         // Kindly set appropriate value of rx_log_ch_num[i] and tx_log_ch_num[i] above.            
         // Rx:even, Tx:odd       
         if (ch_loops % 2) begin 
            logical_ch_select <= tx_logical_ch_sel;
         end else begin
            if(VIDEO_STANDARD == "dl") begin
               logical_ch_select <= tx_logical_ch_sel_b;
            end else begin
               logical_ch_select <= rx_logical_ch_sel;
            end
         end 

         // Setting std_select value
         std_select[1] <= sdi_rx_std_sync[ch_loops+1];
         std_select[0] <= sdi_rx_std_sync[ch_loops];
         
         // Setting tx_pll_sel value 
         tx_pll_sel <= sdi_tx_pll_sel[ch_loops/2];

         // Assert sdi_reconfig_done[ch_loops] once reconfiguration on channel ch_loops is done.
         // Deassert sdi_reconfig_done[ch_loops] once sdi_start_reconfig[ch_loops] is asserted.
         //if (sdi_start_reconfig_sync[ch_loops]) begin
         if (sdi_start_reconfig[ch_loops]) begin
            if (reconfig_done[ch_loops]) begin
               sdi_reconfig_done[ch_loops] <= 1'b1;
            end
         end else begin
            sdi_reconfig_done[ch_loops] <= 1'b0;
         end
      end
   end

   //=========================================================================
   // State Machine Development
   //=========================================================================   
   localparam [3:0] IDLE_LOOP0       = 4'b0000;  // initiate which channel to be reconfig
   localparam [3:0] IDLE_LOOP        = 4'b0001;  // check if selected channel require reconfig AND check it's reconfig_done flag
   localparam [3:0] SET_LOG_CH       = 4'b0010;  // set approriate logical channel number
   localparam [3:0] SET_MIF_MODE     = 4'b0011;  // set MIF MODE to direct access reconfiguration (manual mode)
   localparam [3:0] SET_OFFSET       = 4'b0100;  // set the offset of the register to be read/overwritten 
   localparam [3:0] TOGGLE_READ      = 4'b0101;  // If Read operation, toggle the read process
   localparam [3:0] WRITE_DATA       = 4'b0110;  // If Write operation, write new data to overwite existing data in the register which offset had been specified
   localparam [3:0] TOGGLE_WRITE     = 4'b0111;  // If Write operation, toggle the write process
   localparam [3:0] READ_BUSY_DELAY0 = 4'b1000;  // Wait for reconfig_busy assertion (reconfig_busy flag is only asserted a few clk cycle toggling read/write)
   localparam [3:0] READ_BUSY_DELAY  = 4'b1001;  // Wait for reconfig_busy deassertion (Read/Write process is done)
   // localparam [3:0] READ             = 4'b1010;  // Read or verify the data contains in the register which offset had been specified
   localparam [3:0] FINISH_RECONFIG  = 4'b1010;  // Check if all read/write operations on a channel is done
   
    //==========================================================
    // FSM synchronization
    //==========================================================
    always @ (posedge reconfig_clk or posedge rst)
    begin
       if (rst) begin
          current_state <= IDLE_LOOP0;
       end else begin
          current_state <= next_state;
       end
    end
  
    //==========================================================
    // FSM action (output)
    //==========================================================    
    always @ (current_state or go_reconfig or logical_ch_select or reconfig_mgmt_waitrequest or 
              reconfig_busy or count or cnt_exec or reg_offset or reg_data or ch_loops or log_ch_register or
              tx_reconfig or cs_register or offset_register or data_register)
    begin

      next_state     <= current_state;
      reconfig_done  <= {(NUM_CHS){1'b0}};
      write          <= 1'b0;
      address        <= 7'd0;
      wdata          <= 32'd0;
      read           <= 1'b0;
      start_count    <= 1'b0;
      end_exec       <= 1'b0;
      store_readdata <= 1'b0;
      inc_loops      <= 1'b0;
      set_num_exec   <= 1'b0;
      set_num_exec_init <= 1'b0;
      set_cnt_wait   <= 1'b0;
      
      case (current_state)

        IDLE_LOOP0:
           begin
              inc_loops <= 1'b1;
              set_num_exec_init <= 1'b1;
              set_cnt_wait <= 1'b1;
              next_state <= IDLE_LOOP;        
           end
  
        IDLE_LOOP:
           begin
              start_count <= 1'b1;
              if (go_reconfig) begin
                 next_state <= SET_LOG_CH;
                 set_num_exec <= 1'b1;
              end else if (~count) begin
                 next_state <= IDLE_LOOP0;
              end
           end

        SET_LOG_CH:
           begin
              address <= log_ch_register;
              write <= 1'b1;
              wdata <= logical_ch_select;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 if (tx_reconfig) begin
                    next_state <= SET_OFFSET;
                 end else begin
                    next_state <= SET_MIF_MODE;
                 end
              end
           end          

        SET_MIF_MODE:
           begin
              address <= cs_register;
              wdata <= 32'h00000004;
              write <= 1'b1;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 next_state <= SET_OFFSET;
              end
           end
        
        
        SET_OFFSET:
           begin
              address <= offset_register;
              write <= 1'b1;
              wdata <= reg_offset;  
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 if (tx_reconfig) begin
                    next_state <= WRITE_DATA;
                 end else 
                 if (cnt_exec % 2) begin
                    next_state <= TOGGLE_READ;
                 end else begin
                    next_state <= WRITE_DATA;
                 end
              end
           end  
      
        TOGGLE_READ: 
           begin
              address <= cs_register;
              write <= 1'b1;
              wdata <= 32'h00000006;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 next_state <= READ_BUSY_DELAY0;
              end
           end  
      
        WRITE_DATA:
           begin
              address <= data_register;
              write <= 1'b1;
              wdata <= reg_data;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 next_state <= TOGGLE_WRITE;
              end
           end

        TOGGLE_WRITE:
           begin
              address <= cs_register;
              write <= 1'b1;
              wdata <= 32'h00000005;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_mgmt_waitrequest) begin
                 next_state <= READ_BUSY_DELAY0;
              end
           end

        READ_BUSY_DELAY0:
           begin
              // start_count <= 1'b1;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (reconfig_busy) begin
                 next_state <= READ_BUSY_DELAY;
              end
           end
      
        READ_BUSY_DELAY:
           begin
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end else if (~reconfig_busy) begin
                 // set_cnt_read <= 1'b1;
                 // next_state <= READ;
                 end_exec <= 1'b1;
                 if (cnt_exec > 0) begin          
                    next_state <= SET_LOG_CH;
                 end else begin
                    next_state <= FINISH_RECONFIG;
                 end
              end
           end
        
        FINISH_RECONFIG:
           begin
              reconfig_done[ch_loops] <= 1'b1;
              // start_count <= 1'b0;
              if (~go_reconfig) begin
                 next_state <= IDLE_LOOP0;
              end
           end

        default: begin
           next_state <= IDLE_LOOP0;
        end
      
     endcase
  end

  //==========================================================
  // Counter used in state machine
  //==========================================================
  always @ (posedge reconfig_clk or posedge rst)
  begin
     if (rst) begin
        count <= 1'b1;
     end else begin
        if (start_count) begin
           count <= count - 1'b1;
        end else begin
           if (set_cnt_wait) begin
             count <= 1'b1;
           end
        end
     end
  end

  //==========================================================
  // Creating flags to indicate that at least one reconfig
  // had been executed on a particular channel before.
  //==========================================================
  always @ (posedge reconfig_clk or posedge rst)
  begin
     if (rst) begin
        prev_reconfig <= {(NUM_CHS*2){1'b0}};
     end else begin
        if (reconfig_done[ch_loops]) begin
           prev_reconfig[ch_loops] <= 1'b1;
        end
     end
  end

  //==========================================================
  // Execution counter during one reconfiguration.
  // 1 execution includes all sequences:
  //  -- Setting logical channel
  //  -- Setting MIF Manual mode
  //  -- Setting offset and register data
  //  -- Setting to Read / Write mode
  //  -- Waiting for the deassertion of Busy bit
  //==========================================================
  always @ (posedge reconfig_clk or posedge rst)
  begin
     if (rst) begin
        cnt_exec <= TOTAL_EXECUTION_INIT - 3'd1;
     end else begin
        if (end_exec) begin
           if (cnt_exec > 0) begin
              cnt_exec <= cnt_exec - 3'd1;
           end
        end else if (set_num_exec) begin
           if (tx_reconfig) begin
              cnt_exec <= 3'd0;
           end else if (prev_reconfig[ch_loops]) begin
              cnt_exec <= NUMBER_EXECUTION_NEXT - 3'd1;
           end  
        end else if (set_num_exec_init) begin
           cnt_exec <= TOTAL_EXECUTION_INIT - 3'd1;  
        end
     end
  end

  //==========================================================
  // Define Offset and Data value to be written into
  // Offset Register (0x3c) and Data Register (0x3c)
  // Note: If cnt_exec is even --> Read Operation,
  //       else                --> Write Operation (Overwrite)
  //==========================================================
  always @ (posedge reconfig_clk or posedge rst)
  begin
     if (rst) begin
        reg_offset <= 32'd0;
        reg_data <= 32'd0;
     end else begin
        if (tx_reconfig) begin
           reg_offset <= 32'd1;
           reg_data <= override_tx_pll_sel;
        end else begin
           if (cnt_exec == 2'd3 | cnt_exec == 2'd2) begin
              reg_offset <= RX_OFFSET_M_SEL; 
           end else begin
              reg_offset <= RX_OFFSET_M_L_COUNTER;
           end
      
           if (cnt_exec == 2'd2) begin
              reg_data <= override_m_sel;
           end else if (cnt_exec == 2'd0) begin
              reg_data <= override_hd_data;
           end else begin
              reg_data <= 32'd0;
           end
        end
     end
  end

  //==========================================================
  // Set all values to be sent to alt_xcvr_reconfig block
  // through reconfig_mgmt interface
  //==========================================================	
  always @ (posedge reconfig_clk or posedge rst)
  begin
     if (rst) begin
        reconfig_mgmt_address <= 9'h0;
        reconfig_mgmt_write <= 1'b0;
        reconfig_mgmt_writedata <= 32'h0;
        reconfig_mgmt_read <= 1'b0;
        readdata <= 32'h0;
     end else begin
        reconfig_mgmt_address <= {address, 2'b00};
        reconfig_mgmt_write <= write;
        reconfig_mgmt_writedata <= wdata;
        reconfig_mgmt_read <= read;
        if (store_readdata) begin
           readdata <= reconfig_mgmt_readdata;
        end
     end
  end
  
endmodule
