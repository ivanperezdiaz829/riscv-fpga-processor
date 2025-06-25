//--------------------------------------------------------------------------------------------------
// (c)2003 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an ??????as-is?????? basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------

`timescale 100 fs / 100 fs
module sdi_tr_reconfig_multi_av # (parameter NUM_CHS = 4)
  (
   input                        rst,
   input  [3:0]                 write_ctrl,
   input  [1:0]                 rx_std_ch0,
   input  [1:0]                 rx_std_ch1,   
   input  [1:0]                 rx_std_ch2,
   input  [1:0]                 rx_std_ch3,   
   input                        reconfig_clk,
   input  [91:0]                reconfig_fromgxb, // only 1 per quad
   output reg                   sdi_reconfig_done,
   output [139:0]               reconfig_togxb,
   //Reconfiguration connections
   output wire         reconfig_busy,             //      reconfig_busy.export
   //input wire       reconfig_clk,               //       mgmt_clk_clk.clk
   input  wire         reconfig_reset            //     mgmt_rst_reset.reset
    
  );
   //==========================================
   // 4 operation during first reconfiguration
   // 2 operation during other reconfig
   //==========================================
   // cnt_exec = 3: Read m_sel  (1st reconfig)
   // cnt_exec = 2: Write m_sel (1st reconfig)
   // cnt_exec = 1: Read m_counter, l_counter
   // cnt_exec = 0: Write m_counter, l_counter
   parameter [2:0] TOTAL_EXECUTION_INIT  = 2;
   parameter [2:0] NUMBER_EXECUTION_NEXT = 2;
   reg [2:0] cnt_exec;
   reg       end_exec;

   parameter [6:0] LOG_CH_REGISTER    = 7'h38; 
   parameter [6:0] CS_REGISTER        = 7'h3a; 
   parameter [6:0] OFFSET_REGISTER    = 7'h3b;   
   parameter [6:0] DATA_REGISTER      = 7'h3c;
   parameter [3:0] OFFSET_M_L_COUNTER = 32'he;
   // parameter [3:0] OFFSET_M_SEL       = 32'hd;
   
   parameter [2:0] BUSY_DELAY         = 6;
   parameter [1:0] RW_DELAY           = 1;
   parameter [3:0] READ_DATA_CNT      = 15;
  
   wire [31:0] override_hd_data;
   //wire [31:0] override_m_sel;
   reg  [31:0] reg_data;
   reg  [31:0] reg_offset;
   reg  [31:0] readdata;

   //assign override_hd_data = ({readdata[31:16], ((rx_std_ch0[0] && !rx_std_ch0[1]) ? 4'h3: 4'h5), ((rx_std_ch0[0] && !rx_std_ch0[1]) ? 4'ha: 4'h5), readdata[7:5],1'b0,readdata[3:0]});
   //assign override_m_sel   = ({readdata[31:5], 2'b00, readdata[2:0]});
   assign override_hd_data = ({readdata[31:16], 2'b00, ((rx_std_ch0[0] && !rx_std_ch0[1]) ? 4'h3: 4'h5), ((rx_std_ch0[0] && !rx_std_ch0[1]) ? 4'ha: 4'h5), readdata[5:4],1'b0,readdata[2:0]});

   //=========================================================================
   // State Machine Development
   //=========================================================================   
   reg [3:0] current_state;
   reg [3:0] next_state;
   parameter    [3:0] IDLE_UI                   = 4'b0000;
   parameter    [3:0] SET_LOG_CH                = 4'b0001;
   parameter    [3:0] SET_MIF_MODE              = 4'b0010;
   parameter    [3:0] SET_OFFSET                = 4'b0011;
   parameter    [3:0] TOGGLE_READ               = 4'b0100;
   parameter    [3:0] WRITE_DATA                = 4'b0101;
   parameter    [3:0] TOGGLE_WRITE              = 4'b0110;
   parameter    [3:0] READ_BUSY_DELAY           = 4'b0111;
   parameter    [3:0] READ                      = 4'b1000;
   parameter    [3:0] FINISH_RECONFIG           = 4'b1001;
   
   //Reconfig Management interface
   reg  [6:0]                 reconfig_mgmt_address;
   reg                        reconfig_mgmt_read;
   reg                        reconfig_mgmt_write;
   reg [31:0]                 reconfig_mgmt_writedata;
   wire                       reconfig_mgmt_waitrequest;
   wire [31:0]                reconfig_mgmt_readdata;
  
   reg [6:0]       address;
   reg [31:0]      wdata;
   reg             write;
   reg             read;
   reg             store_readdata;
    
   reg [5:0] count;
   reg       start_count;
   reg       set_cnt_rw;
   reg       set_cnt_busy;
   reg       set_cnt_read;
    
    //==========================================================
    // FSM synchronization
    //==========================================================
    always @ (posedge reconfig_clk or posedge rst)
    begin
      if (rst) begin
        current_state <= IDLE_UI;
      end
      else begin
        current_state <= next_state;
      end
    end

    //==========================================================
    // FSM action (output)
    //==========================================================    
    always @ (current_state or write_ctrl or reconfig_mgmt_waitrequest or
              count or cnt_exec or override_hd_data or
              reconfig_mgmt_readdata)
    begin

      next_state        <= current_state;
      sdi_reconfig_done <= 1'b0;
      write             <= 1'b0;
      address           <= 7'd0;
      wdata             <= 32'd0;
      read              <= 1'b0;
      start_count       <= 1'b1;
      set_cnt_rw        <= 1'b0;
      set_cnt_busy      <= 1'b0;
      set_cnt_read      <= 1'b0;
      end_exec          <= 1'b0;
      store_readdata    <= 1'b0;

      case (current_state)

        IDLE_UI:
          begin
            start_count       <= 1'b0;
            if (write_ctrl[0]) begin
              next_state      <= SET_LOG_CH;
              set_cnt_rw      <= 1'b1;
            end
          end

        SET_LOG_CH:
          begin
            address      <= LOG_CH_REGISTER;
            write        <= 1'b1;
            wdata        <= 32'd0;
            if (count == 0) begin
              start_count  <= 1'b0;
              if (!reconfig_mgmt_waitrequest) begin
                next_state <= SET_MIF_MODE;
                set_cnt_rw <= 1'b1;
                write      <= 1'b0;
              end
            end
          end          

        SET_MIF_MODE:
          begin
            address   <= CS_REGISTER;
            wdata     <= 32'h00000004;
            write     <= 1'b1;
            if (count == 0) begin
              start_count  <= 1'b0;
              if (!reconfig_mgmt_waitrequest) begin
                next_state <= SET_OFFSET;
                set_cnt_rw <= 1'b1;
                write      <= 1'b0;
              end
            end
          end
        
        
        SET_OFFSET:
          begin
            address <= OFFSET_REGISTER;
            write   <= 1'b1;
            wdata   <= reg_offset;  
            
            if (count == 0) begin
              start_count  <= 1'b0;
              if (!reconfig_mgmt_waitrequest) begin
                write   <= 1'b0;
                set_cnt_rw <= 1'b1;
                if (cnt_exec % 2) next_state <= TOGGLE_READ;
                else              next_state <= WRITE_DATA;
              end
            end
          end  
      
        
        TOGGLE_READ: 
        begin
          address <= CS_REGISTER;
          write   <= 1'b1;
          wdata   <= 32'h00000006;
          if (count == 0) begin
            start_count  <= 1'b0;
            if (!reconfig_mgmt_waitrequest) begin
              write        <= 1'b0;
              set_cnt_busy <= 1'b1;
              next_state   <= READ_BUSY_DELAY;
            end
          end
        end  

      
        WRITE_DATA:
        begin
          address <= DATA_REGISTER;
          write <= 1'b1;
        
          wdata <= reg_data;

          if (count == 0) begin
            start_count  <= 1'b0;
            if (!reconfig_mgmt_waitrequest) begin
              write      <= 1'b0;
              set_cnt_rw <= 1'b1;
              next_state <= TOGGLE_WRITE;               
            end
          end
        end


        TOGGLE_WRITE:
        begin
          address <= CS_REGISTER;
          write   <= 1'b1;
          wdata   <= 32'h00000005;
          if (count == 0) begin
            start_count  <= 1'b0;
            if (!reconfig_mgmt_waitrequest) begin
              write      <= 1'b0;
              set_cnt_busy <= 1'b1;
              next_state <= READ_BUSY_DELAY;
            end
          end
        end

      
        READ_BUSY_DELAY:
          begin
            address <= CS_REGISTER;
            write   <= 1'b0;
            read    <= 1'b1; 
            if (count == 0) begin
              start_count  <= 1'b0;
              if (reconfig_mgmt_readdata[8] == 1'b0) begin
                set_cnt_read <= 1'b1;
                next_state   <= READ;
              end
            end
          end

        
        READ:
        begin 
          if (count > 0) begin
            read <= 1'b1;
            if (count > 7) begin
              address        <= DATA_REGISTER;
              store_readdata <= 1'b1;
            end
            else if (count > 4) address <= CS_REGISTER;
            else                address <= OFFSET_REGISTER;
          end
          else begin
            start_count  <= 1'b0;
            set_cnt_rw   <= 1'b1;
            read         <= 1'b0;
            end_exec     <= 1'b1;
            if (cnt_exec > 0)           
              next_state <= SET_LOG_CH;
            else
              next_state <= FINISH_RECONFIG;
          end
        end

        
        FINISH_RECONFIG:
        begin
          sdi_reconfig_done <= 1'b1;
          start_count       <= 1'b0;
          if (~write_ctrl[0]) begin
            next_state <= IDLE_UI;
          end
        end

        default: begin
          next_state <= IDLE_UI;
        end
      
      endcase
  end //state_ui

  //==========================================================
  // Counter used in state machine
  //==========================================================
  always @ (posedge reconfig_clk or posedge rst)
  begin
    if (rst) begin
      count <= RW_DELAY;
    end else begin
      if (start_count) begin
        count <= count - 1;
      end 
      else begin
        if (set_cnt_rw)          count <= RW_DELAY;
        else if (set_cnt_busy)   count <= BUSY_DELAY;
        else if (set_cnt_read)   count <= READ_DATA_CNT;
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
      cnt_exec <= TOTAL_EXECUTION_INIT-1;
    end else begin
      if (end_exec) begin
        if (cnt_exec > 0) cnt_exec <= cnt_exec - 1;
        // no need to force m_sel value to 1 during next reconfig
        else              cnt_exec <= NUMBER_EXECUTION_NEXT - 1;
      end
    end
  end

  //==========================================================
  // Define Offset and Data value to be written into
  // Offset Register (0x3c) and Data Register (0x3c)
  // Note: If cnt_exec is even --> Read Operation,
  //       else                --> Write Operation (Overwrite)
  //==========================================================
  always @ (cnt_exec)
  begin
    reg_data   <= 32'h0;
    case (cnt_exec)
    
      // Read m_sel value
      // 3: begin
        // reg_offset <= 32'h0 | OFFSET_M_SEL;
      // end
      
      // // Overwrite m_sel value
      // 2: begin
        // reg_offset <= 32'h0 | OFFSET_M_SEL;
        // reg_data   <= override_m_sel;
      // end
 
      // Read m_counter and l_counter 
      1: begin 
        reg_offset <= 32'h0 | OFFSET_M_L_COUNTER;
      end

      // Overwrite m_counter and l_counter
      0: begin 
        reg_offset <= 32'h0 | OFFSET_M_L_COUNTER;
        reg_data   <= override_hd_data;
      end   

      default: begin
        reg_offset <= 32'h0;
        reg_data   <= 32'h0;
      end

    endcase
  end    
  
  
  always @ (posedge reconfig_clk or posedge rst)
  begin
    if (rst) begin
      reconfig_mgmt_address   <= 7'h0;
      reconfig_mgmt_write     <= 1'b0;
      reconfig_mgmt_writedata <= 32'h0;
      reconfig_mgmt_read      <= 1'b0;
      readdata                <= 32'h0;
    end
    else begin
      reconfig_mgmt_address   <= address;
      reconfig_mgmt_write     <= write;
      reconfig_mgmt_writedata <= wdata;
      reconfig_mgmt_read      <= read;
      if (store_readdata)  readdata <= reconfig_mgmt_readdata;
    end
  end
  
  
  //==========================================================
  // Instantiating Reconfig Module
  //==========================================================  
  reconfig reconfig_inst(
      .reconfig_busy              (reconfig_busy),             //      reconfig_busy.export
      .mgmt_clk_clk               (reconfig_clk),              //       mgmt_clk_clk.clk
      .mgmt_rst_reset             (reconfig_reset),            //     mgmt_rst_reset.reset
      .reconfig_mgmt_address      (reconfig_mgmt_address),     //      reconfig_mgmt.address
      .reconfig_mgmt_read         (reconfig_mgmt_read),        //                   .read
      .reconfig_mgmt_readdata     (reconfig_mgmt_readdata),    //                   .readdata
      .reconfig_mgmt_waitrequest  (reconfig_mgmt_waitrequest), //                   .waitrequest
      .reconfig_mgmt_write        (reconfig_mgmt_write),       //                   .write
      .reconfig_mgmt_writedata    (reconfig_mgmt_writedata),

      //PHY-IP interface  
      .reconfig_to_xcvr           (reconfig_togxb),         
      .reconfig_from_xcvr         (reconfig_fromgxb));


endmodule
